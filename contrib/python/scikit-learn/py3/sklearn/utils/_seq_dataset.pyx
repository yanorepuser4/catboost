"""Dataset abstractions for sequential data access."""

cimport cython
from libc.limits cimport INT_MAX
cimport numpy as cnp
import numpy as np

cnp.import_array()

from ._random cimport our_rand_r

#------------------------------------------------------------------------------

cdef class SequentialDataset64:
    """Base class for datasets with sequential data access.

    SequentialDataset is used to iterate over the rows of a matrix X and
    corresponding target values y, i.e. to iterate over samples.
    There are two methods to get the next sample:
        - next : Iterate sequentially (optionally randomized)
        - random : Iterate randomly (with replacement)

    Attributes
    ----------
    index : np.ndarray
        Index array for fast shuffling.

    index_data_ptr : int
        Pointer to the index array.

    current_index : int
        Index of current sample in ``index``.
        The index of current sample in the data is given by
        index_data_ptr[current_index].

    n_samples : Py_ssize_t
        Number of samples in the dataset.

    seed : cnp.uint32_t
        Seed used for random sampling. This attribute is modified at each call to the
        `random` method.
    """

    cdef void next(self, double **x_data_ptr, int **x_ind_ptr,
                   int *nnz, double *y, double *sample_weight) noexcept nogil:
        """Get the next example ``x`` from the dataset.

        This method gets the next sample looping sequentially over all samples.
        The order can be shuffled with the method ``shuffle``.
        Shuffling once before iterating over all samples corresponds to a
        random draw without replacement. It is used for instance in SGD solver.

        Parameters
        ----------
        x_data_ptr : double**
            A pointer to the double array which holds the feature
            values of the next example.

        x_ind_ptr : np.intc**
            A pointer to the int array which holds the feature
            indices of the next example.

        nnz : int*
            A pointer to an int holding the number of non-zero
            values of the next example.

        y : double*
            The target value of the next example.

        sample_weight : double*
            The weight of the next example.
        """
        cdef int current_index = self._get_next_index()
        self._sample(x_data_ptr, x_ind_ptr, nnz, y, sample_weight,
                     current_index)

    cdef int random(self, double **x_data_ptr, int **x_ind_ptr,
                    int *nnz, double *y, double *sample_weight) noexcept nogil:
        """Get a random example ``x`` from the dataset.

        This method gets next sample chosen randomly over a uniform
        distribution. It corresponds to a random draw with replacement.
        It is used for instance in SAG solver.

        Parameters
        ----------
        x_data_ptr : double**
            A pointer to the double array which holds the feature
            values of the next example.

        x_ind_ptr : np.intc**
            A pointer to the int array which holds the feature
            indices of the next example.

        nnz : int*
            A pointer to an int holding the number of non-zero
            values of the next example.

        y : double*
            The target value of the next example.

        sample_weight : double*
            The weight of the next example.

        Returns
        -------
        current_index : int
            Index of current sample.
        """
        cdef int current_index = self._get_random_index()
        self._sample(x_data_ptr, x_ind_ptr, nnz, y, sample_weight,
                     current_index)
        return current_index

    cdef void shuffle(self, cnp.uint32_t seed) noexcept nogil:
        """Permutes the ordering of examples."""
        # Fisher-Yates shuffle
        cdef int *ind = self.index_data_ptr
        cdef int n = self.n_samples
        cdef unsigned i, j
        for i in range(n - 1):
            j = i + our_rand_r(&seed) % (n - i)
            ind[i], ind[j] = ind[j], ind[i]

    cdef int _get_next_index(self) noexcept nogil:
        cdef int current_index = self.current_index
        if current_index >= (self.n_samples - 1):
            current_index = -1

        current_index += 1
        self.current_index = current_index
        return self.current_index

    cdef int _get_random_index(self) noexcept nogil:
        cdef int n = self.n_samples
        cdef int current_index = our_rand_r(&self.seed) % n
        self.current_index = current_index
        return current_index

    cdef void _sample(self, double **x_data_ptr, int **x_ind_ptr,
                      int *nnz, double *y, double *sample_weight,
                      int current_index) noexcept nogil:
        pass

    def _shuffle_py(self, cnp.uint32_t seed):
        """python function used for easy testing"""
        self.shuffle(seed)

    def _next_py(self):
        """python function used for easy testing"""
        cdef int current_index = self._get_next_index()
        return self._sample_py(current_index)

    def _random_py(self):
        """python function used for easy testing"""
        cdef int current_index = self._get_random_index()
        return self._sample_py(current_index)

    def _sample_py(self, int current_index):
        """python function used for easy testing"""
        cdef double* x_data_ptr
        cdef int* x_indices_ptr
        cdef int nnz, j
        cdef double y, sample_weight

        # call _sample in cython
        self._sample(&x_data_ptr, &x_indices_ptr, &nnz, &y, &sample_weight,
                     current_index)

        # transform the pointed data in numpy CSR array
        cdef double[:] x_data = np.empty(nnz, dtype=np.float64)
        cdef int[:] x_indices = np.empty(nnz, dtype=np.int32)
        cdef int[:] x_indptr = np.asarray([0, nnz], dtype=np.int32)

        for j in range(nnz):
            x_data[j] = x_data_ptr[j]
            x_indices[j] = x_indices_ptr[j]

        cdef int sample_idx = self.index_data_ptr[current_index]

        return (
            (np.asarray(x_data), np.asarray(x_indices), np.asarray(x_indptr)),
            y,
            sample_weight,
            sample_idx,
        )


cdef class ArrayDataset64(SequentialDataset64):
    """Dataset backed by a two-dimensional numpy array.

    The dtype of the numpy array is expected to be ``np.float64`` (double)
    and C-style memory layout.
    """

    def __cinit__(
        self,
        const double[:, ::1] X,
        const double[::1] Y,
        const double[::1] sample_weights,
        cnp.uint32_t seed=1,
    ):
        """A ``SequentialDataset`` backed by a two-dimensional numpy array.

        Parameters
        ----------
        X : ndarray, dtype=double, ndim=2, mode='c'
            The sample array, of shape(n_samples, n_features)

        Y : ndarray, dtype=double, ndim=1, mode='c'
            The target array, of shape(n_samples, )

        sample_weights : ndarray, dtype=double, ndim=1, mode='c'
            The weight of each sample, of shape(n_samples,)
        """
        if X.shape[0] > INT_MAX or X.shape[1] > INT_MAX:
            raise ValueError("More than %d samples or features not supported;"
                             " got (%d, %d)."
                             % (INT_MAX, X.shape[0], X.shape[1]))

        # keep a reference to the data to prevent garbage collection
        self.X = X
        self.Y = Y
        self.sample_weights = sample_weights

        self.n_samples = X.shape[0]
        self.n_features = X.shape[1]

        self.feature_indices = np.arange(0, self.n_features, dtype=np.intc)
        self.feature_indices_ptr = <int *> &self.feature_indices[0]

        self.current_index = -1
        self.X_stride = X.strides[0] // X.itemsize
        self.X_data_ptr = <double *> &X[0, 0]
        self.Y_data_ptr = <double *> &Y[0]
        self.sample_weight_data = <double *> &sample_weights[0]

        # Use index array for fast shuffling
        self.index = np.arange(0, self.n_samples, dtype=np.intc)
        self.index_data_ptr = <int *> &self.index[0]
        # seed should not be 0 for our_rand_r
        self.seed = max(seed, 1)

    cdef void _sample(self, double **x_data_ptr, int **x_ind_ptr,
                      int *nnz, double *y, double *sample_weight,
                      int current_index) noexcept nogil:
        cdef long long sample_idx = self.index_data_ptr[current_index]
        cdef long long offset = sample_idx * self.X_stride

        y[0] = self.Y_data_ptr[sample_idx]
        x_data_ptr[0] = self.X_data_ptr + offset
        x_ind_ptr[0] = self.feature_indices_ptr
        nnz[0] = self.n_features
        sample_weight[0] = self.sample_weight_data[sample_idx]


cdef class CSRDataset64(SequentialDataset64):
    """A ``SequentialDataset`` backed by a scipy sparse CSR matrix. """

    def __cinit__(
        self,
        const double[::1] X_data,
        const int[::1] X_indptr,
        const int[::1] X_indices,
        const double[::1] Y,
        const double[::1] sample_weights,
        cnp.uint32_t seed=1,
    ):
        """Dataset backed by a scipy sparse CSR matrix.

        The feature indices of ``x`` are given by x_ind_ptr[0:nnz].
        The corresponding feature values are given by
        x_data_ptr[0:nnz].

        Parameters
        ----------
        X_data : ndarray, dtype=double, ndim=1, mode='c'
            The data array of the CSR features matrix.

        X_indptr : ndarray, dtype=np.intc, ndim=1, mode='c'
            The index pointer array of the CSR features matrix.

        X_indices : ndarray, dtype=np.intc, ndim=1, mode='c'
            The column indices array of the CSR features matrix.

        Y : ndarray, dtype=double, ndim=1, mode='c'
            The target values.

        sample_weights : ndarray, dtype=double, ndim=1, mode='c'
            The weight of each sample.
        """
        # keep a reference to the data to prevent garbage collection
        self.X_data = X_data
        self.X_indptr = X_indptr
        self.X_indices = X_indices
        self.Y = Y
        self.sample_weights = sample_weights

        self.n_samples = Y.shape[0]
        self.current_index = -1
        self.X_data_ptr = <double *> &X_data[0]
        self.X_indptr_ptr = <int *> &X_indptr[0]
        self.X_indices_ptr = <int *> &X_indices[0]

        self.Y_data_ptr = <double *> &Y[0]
        self.sample_weight_data = <double *> &sample_weights[0]

        # Use index array for fast shuffling
        self.index = np.arange(self.n_samples, dtype=np.intc)
        self.index_data_ptr = <int *> &self.index[0]
        # seed should not be 0 for our_rand_r
        self.seed = max(seed, 1)

    cdef void _sample(self, double **x_data_ptr, int **x_ind_ptr,
                      int *nnz, double *y, double *sample_weight,
                      int current_index) noexcept nogil:
        cdef long long sample_idx = self.index_data_ptr[current_index]
        cdef long long offset = self.X_indptr_ptr[sample_idx]
        y[0] = self.Y_data_ptr[sample_idx]
        x_data_ptr[0] = self.X_data_ptr + offset
        x_ind_ptr[0] = self.X_indices_ptr + offset
        nnz[0] = self.X_indptr_ptr[sample_idx + 1] - offset
        sample_weight[0] = self.sample_weight_data[sample_idx]


#------------------------------------------------------------------------------

cdef class SequentialDataset32:
    """Base class for datasets with sequential data access.

    SequentialDataset is used to iterate over the rows of a matrix X and
    corresponding target values y, i.e. to iterate over samples.
    There are two methods to get the next sample:
        - next : Iterate sequentially (optionally randomized)
        - random : Iterate randomly (with replacement)

    Attributes
    ----------
    index : np.ndarray
        Index array for fast shuffling.

    index_data_ptr : int
        Pointer to the index array.

    current_index : int
        Index of current sample in ``index``.
        The index of current sample in the data is given by
        index_data_ptr[current_index].

    n_samples : Py_ssize_t
        Number of samples in the dataset.

    seed : cnp.uint32_t
        Seed used for random sampling. This attribute is modified at each call to the
        `random` method.
    """

    cdef void next(self, float **x_data_ptr, int **x_ind_ptr,
                   int *nnz, float *y, float *sample_weight) noexcept nogil:
        """Get the next example ``x`` from the dataset.

        This method gets the next sample looping sequentially over all samples.
        The order can be shuffled with the method ``shuffle``.
        Shuffling once before iterating over all samples corresponds to a
        random draw without replacement. It is used for instance in SGD solver.

        Parameters
        ----------
        x_data_ptr : float**
            A pointer to the float array which holds the feature
            values of the next example.

        x_ind_ptr : np.intc**
            A pointer to the int array which holds the feature
            indices of the next example.

        nnz : int*
            A pointer to an int holding the number of non-zero
            values of the next example.

        y : float*
            The target value of the next example.

        sample_weight : float*
            The weight of the next example.
        """
        cdef int current_index = self._get_next_index()
        self._sample(x_data_ptr, x_ind_ptr, nnz, y, sample_weight,
                     current_index)

    cdef int random(self, float **x_data_ptr, int **x_ind_ptr,
                    int *nnz, float *y, float *sample_weight) noexcept nogil:
        """Get a random example ``x`` from the dataset.

        This method gets next sample chosen randomly over a uniform
        distribution. It corresponds to a random draw with replacement.
        It is used for instance in SAG solver.

        Parameters
        ----------
        x_data_ptr : float**
            A pointer to the float array which holds the feature
            values of the next example.

        x_ind_ptr : np.intc**
            A pointer to the int array which holds the feature
            indices of the next example.

        nnz : int*
            A pointer to an int holding the number of non-zero
            values of the next example.

        y : float*
            The target value of the next example.

        sample_weight : float*
            The weight of the next example.

        Returns
        -------
        current_index : int
            Index of current sample.
        """
        cdef int current_index = self._get_random_index()
        self._sample(x_data_ptr, x_ind_ptr, nnz, y, sample_weight,
                     current_index)
        return current_index

    cdef void shuffle(self, cnp.uint32_t seed) noexcept nogil:
        """Permutes the ordering of examples."""
        # Fisher-Yates shuffle
        cdef int *ind = self.index_data_ptr
        cdef int n = self.n_samples
        cdef unsigned i, j
        for i in range(n - 1):
            j = i + our_rand_r(&seed) % (n - i)
            ind[i], ind[j] = ind[j], ind[i]

    cdef int _get_next_index(self) noexcept nogil:
        cdef int current_index = self.current_index
        if current_index >= (self.n_samples - 1):
            current_index = -1

        current_index += 1
        self.current_index = current_index
        return self.current_index

    cdef int _get_random_index(self) noexcept nogil:
        cdef int n = self.n_samples
        cdef int current_index = our_rand_r(&self.seed) % n
        self.current_index = current_index
        return current_index

    cdef void _sample(self, float **x_data_ptr, int **x_ind_ptr,
                      int *nnz, float *y, float *sample_weight,
                      int current_index) noexcept nogil:
        pass

    def _shuffle_py(self, cnp.uint32_t seed):
        """python function used for easy testing"""
        self.shuffle(seed)

    def _next_py(self):
        """python function used for easy testing"""
        cdef int current_index = self._get_next_index()
        return self._sample_py(current_index)

    def _random_py(self):
        """python function used for easy testing"""
        cdef int current_index = self._get_random_index()
        return self._sample_py(current_index)

    def _sample_py(self, int current_index):
        """python function used for easy testing"""
        cdef float* x_data_ptr
        cdef int* x_indices_ptr
        cdef int nnz, j
        cdef float y, sample_weight

        # call _sample in cython
        self._sample(&x_data_ptr, &x_indices_ptr, &nnz, &y, &sample_weight,
                     current_index)

        # transform the pointed data in numpy CSR array
        cdef float[:] x_data = np.empty(nnz, dtype=np.float32)
        cdef int[:] x_indices = np.empty(nnz, dtype=np.int32)
        cdef int[:] x_indptr = np.asarray([0, nnz], dtype=np.int32)

        for j in range(nnz):
            x_data[j] = x_data_ptr[j]
            x_indices[j] = x_indices_ptr[j]

        cdef int sample_idx = self.index_data_ptr[current_index]

        return (
            (np.asarray(x_data), np.asarray(x_indices), np.asarray(x_indptr)),
            y,
            sample_weight,
            sample_idx,
        )


cdef class ArrayDataset32(SequentialDataset32):
    """Dataset backed by a two-dimensional numpy array.

    The dtype of the numpy array is expected to be ``np.float32`` (float)
    and C-style memory layout.
    """

    def __cinit__(
        self,
        const float[:, ::1] X,
        const float[::1] Y,
        const float[::1] sample_weights,
        cnp.uint32_t seed=1,
    ):
        """A ``SequentialDataset`` backed by a two-dimensional numpy array.

        Parameters
        ----------
        X : ndarray, dtype=float, ndim=2, mode='c'
            The sample array, of shape(n_samples, n_features)

        Y : ndarray, dtype=float, ndim=1, mode='c'
            The target array, of shape(n_samples, )

        sample_weights : ndarray, dtype=float, ndim=1, mode='c'
            The weight of each sample, of shape(n_samples,)
        """
        if X.shape[0] > INT_MAX or X.shape[1] > INT_MAX:
            raise ValueError("More than %d samples or features not supported;"
                             " got (%d, %d)."
                             % (INT_MAX, X.shape[0], X.shape[1]))

        # keep a reference to the data to prevent garbage collection
        self.X = X
        self.Y = Y
        self.sample_weights = sample_weights

        self.n_samples = X.shape[0]
        self.n_features = X.shape[1]

        self.feature_indices = np.arange(0, self.n_features, dtype=np.intc)
        self.feature_indices_ptr = <int *> &self.feature_indices[0]

        self.current_index = -1
        self.X_stride = X.strides[0] // X.itemsize
        self.X_data_ptr = <float *> &X[0, 0]
        self.Y_data_ptr = <float *> &Y[0]
        self.sample_weight_data = <float *> &sample_weights[0]

        # Use index array for fast shuffling
        self.index = np.arange(0, self.n_samples, dtype=np.intc)
        self.index_data_ptr = <int *> &self.index[0]
        # seed should not be 0 for our_rand_r
        self.seed = max(seed, 1)

    cdef void _sample(self, float **x_data_ptr, int **x_ind_ptr,
                      int *nnz, float *y, float *sample_weight,
                      int current_index) noexcept nogil:
        cdef long long sample_idx = self.index_data_ptr[current_index]
        cdef long long offset = sample_idx * self.X_stride

        y[0] = self.Y_data_ptr[sample_idx]
        x_data_ptr[0] = self.X_data_ptr + offset
        x_ind_ptr[0] = self.feature_indices_ptr
        nnz[0] = self.n_features
        sample_weight[0] = self.sample_weight_data[sample_idx]


cdef class CSRDataset32(SequentialDataset32):
    """A ``SequentialDataset`` backed by a scipy sparse CSR matrix. """

    def __cinit__(
        self,
        const float[::1] X_data,
        const int[::1] X_indptr,
        const int[::1] X_indices,
        const float[::1] Y,
        const float[::1] sample_weights,
        cnp.uint32_t seed=1,
    ):
        """Dataset backed by a scipy sparse CSR matrix.

        The feature indices of ``x`` are given by x_ind_ptr[0:nnz].
        The corresponding feature values are given by
        x_data_ptr[0:nnz].

        Parameters
        ----------
        X_data : ndarray, dtype=float, ndim=1, mode='c'
            The data array of the CSR features matrix.

        X_indptr : ndarray, dtype=np.intc, ndim=1, mode='c'
            The index pointer array of the CSR features matrix.

        X_indices : ndarray, dtype=np.intc, ndim=1, mode='c'
            The column indices array of the CSR features matrix.

        Y : ndarray, dtype=float, ndim=1, mode='c'
            The target values.

        sample_weights : ndarray, dtype=float, ndim=1, mode='c'
            The weight of each sample.
        """
        # keep a reference to the data to prevent garbage collection
        self.X_data = X_data
        self.X_indptr = X_indptr
        self.X_indices = X_indices
        self.Y = Y
        self.sample_weights = sample_weights

        self.n_samples = Y.shape[0]
        self.current_index = -1
        self.X_data_ptr = <float *> &X_data[0]
        self.X_indptr_ptr = <int *> &X_indptr[0]
        self.X_indices_ptr = <int *> &X_indices[0]

        self.Y_data_ptr = <float *> &Y[0]
        self.sample_weight_data = <float *> &sample_weights[0]

        # Use index array for fast shuffling
        self.index = np.arange(self.n_samples, dtype=np.intc)
        self.index_data_ptr = <int *> &self.index[0]
        # seed should not be 0 for our_rand_r
        self.seed = max(seed, 1)

    cdef void _sample(self, float **x_data_ptr, int **x_ind_ptr,
                      int *nnz, float *y, float *sample_weight,
                      int current_index) noexcept nogil:
        cdef long long sample_idx = self.index_data_ptr[current_index]
        cdef long long offset = self.X_indptr_ptr[sample_idx]
        y[0] = self.Y_data_ptr[sample_idx]
        x_data_ptr[0] = self.X_data_ptr + offset
        x_ind_ptr[0] = self.X_indices_ptr + offset
        nnz[0] = self.X_indptr_ptr[sample_idx + 1] - offset
        sample_weight[0] = self.sample_weight_data[sample_idx]

