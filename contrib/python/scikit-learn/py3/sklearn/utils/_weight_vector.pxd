
cdef class WeightVector64(object):
    cdef readonly double[::1] w
    cdef readonly double[::1] aw
    cdef double *w_data_ptr
    cdef double *aw_data_ptr

    cdef double wscale
    cdef double average_a
    cdef double average_b
    cdef int n_features
    cdef double sq_norm

    cdef void add(self, double *x_data_ptr, int *x_ind_ptr,
                  int xnnz, double c) noexcept nogil
    cdef void add_average(self, double *x_data_ptr, int *x_ind_ptr,
                          int xnnz, double c, double num_iter) noexcept nogil
    cdef double dot(self, double *x_data_ptr, int *x_ind_ptr,
                    int xnnz) noexcept nogil
    cdef void scale(self, double c) noexcept nogil
    cdef void reset_wscale(self) noexcept nogil
    cdef double norm(self) noexcept nogil

cdef class WeightVector32(object):
    cdef readonly float[::1] w
    cdef readonly float[::1] aw
    cdef float *w_data_ptr
    cdef float *aw_data_ptr

    cdef double wscale
    cdef double average_a
    cdef double average_b
    cdef int n_features
    cdef double sq_norm

    cdef void add(self, float *x_data_ptr, int *x_ind_ptr,
                  int xnnz, float c) noexcept nogil
    cdef void add_average(self, float *x_data_ptr, int *x_ind_ptr,
                          int xnnz, float c, float num_iter) noexcept nogil
    cdef float dot(self, float *x_data_ptr, int *x_ind_ptr,
                    int xnnz) noexcept nogil
    cdef void scale(self, float c) noexcept nogil
    cdef void reset_wscale(self) noexcept nogil
    cdef float norm(self) noexcept nogil
