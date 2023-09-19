"""Dataset abstractions for sequential data access."""

cimport numpy as cnp

# SequentialDataset and its two concrete subclasses are (optionally randomized)
# iterators over the rows of a matrix X and corresponding target values y.

#------------------------------------------------------------------------------

cdef class SequentialDataset64:
    cdef int current_index
    cdef int[::1] index
    cdef int *index_data_ptr
    cdef Py_ssize_t n_samples
    cdef cnp.uint32_t seed

    cdef void shuffle(self, cnp.uint32_t seed) noexcept nogil
    cdef int _get_next_index(self) noexcept nogil
    cdef int _get_random_index(self) noexcept nogil

    cdef void _sample(self, double **x_data_ptr, int **x_ind_ptr,
                      int *nnz, double *y, double *sample_weight,
                      int current_index) noexcept nogil
    cdef void next(self, double **x_data_ptr, int **x_ind_ptr,
                   int *nnz, double *y, double *sample_weight) noexcept nogil
    cdef int random(self, double **x_data_ptr, int **x_ind_ptr,
                    int *nnz, double *y, double *sample_weight) noexcept nogil


cdef class ArrayDataset64(SequentialDataset64):
    cdef const double[:, ::1] X
    cdef const double[::1] Y
    cdef const double[::1] sample_weights
    cdef Py_ssize_t n_features
    cdef cnp.npy_intp X_stride
    cdef double *X_data_ptr
    cdef double *Y_data_ptr
    cdef const int[::1] feature_indices
    cdef int *feature_indices_ptr
    cdef double *sample_weight_data


cdef class CSRDataset64(SequentialDataset64):
    cdef const double[::1] X_data
    cdef const int[::1] X_indptr
    cdef const int[::1] X_indices
    cdef const double[::1] Y
    cdef const double[::1] sample_weights
    cdef double *X_data_ptr
    cdef int *X_indptr_ptr
    cdef int *X_indices_ptr
    cdef double *Y_data_ptr
    cdef double *sample_weight_data

#------------------------------------------------------------------------------

cdef class SequentialDataset32:
    cdef int current_index
    cdef int[::1] index
    cdef int *index_data_ptr
    cdef Py_ssize_t n_samples
    cdef cnp.uint32_t seed

    cdef void shuffle(self, cnp.uint32_t seed) noexcept nogil
    cdef int _get_next_index(self) noexcept nogil
    cdef int _get_random_index(self) noexcept nogil

    cdef void _sample(self, float **x_data_ptr, int **x_ind_ptr,
                      int *nnz, float *y, float *sample_weight,
                      int current_index) noexcept nogil
    cdef void next(self, float **x_data_ptr, int **x_ind_ptr,
                   int *nnz, float *y, float *sample_weight) noexcept nogil
    cdef int random(self, float **x_data_ptr, int **x_ind_ptr,
                    int *nnz, float *y, float *sample_weight) noexcept nogil


cdef class ArrayDataset32(SequentialDataset32):
    cdef const float[:, ::1] X
    cdef const float[::1] Y
    cdef const float[::1] sample_weights
    cdef Py_ssize_t n_features
    cdef cnp.npy_intp X_stride
    cdef float *X_data_ptr
    cdef float *Y_data_ptr
    cdef const int[::1] feature_indices
    cdef int *feature_indices_ptr
    cdef float *sample_weight_data


cdef class CSRDataset32(SequentialDataset32):
    cdef const float[::1] X_data
    cdef const int[::1] X_indptr
    cdef const int[::1] X_indices
    cdef const float[::1] Y
    cdef const float[::1] sample_weights
    cdef float *X_data_ptr
    cdef int *X_indptr_ptr
    cdef int *X_indices_ptr
    cdef float *Y_data_ptr
    cdef float *sample_weight_data
