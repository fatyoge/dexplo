#cython: boundscheck=False
#cython: wraparound=False
import numpy as np
cimport numpy as np
from numpy cimport ndarray
from numpy import nan
import cython
from cpython cimport dict, set, list, tuple
from libc.math cimport isnan, sqrt, floor, ceil
import cmath
import groupby as gb
import math as _math
from libc.stdlib cimport free, malloc
from libc.string cimport memcpy

try:
    import bottleneck as bn
except ImportError:
    import numpy as bn


MAX_FLOAT = np.finfo(np.float64).max
MIN_FLOAT = np.finfo(np.float64).min

MAX_INT = np.iinfo(np.int64).max
MIN_INT = np.iinfo(np.int64).min

MAX_CHAR = chr(1_000_000)
MIN_CHAR = chr(0)

def add_obj(ndarray[object, ndim=2] arr, str other):
    cdef int i, j
    cdef int nr = arr.shape[0]
    cdef int nc = arr.shape[1]
    cdef ndarray[object, ndim=2] final = np.empty((nr, nc), dtype='O')
    for i in range(nr):
        for j in range(nc):
            try:
                final[i, j] = arr[i, j] + other
            except:
                final[i, j] = None
    return final

def add_obj_two(ndarray[object, ndim=2] arr, ndarray[object, ndim=2] arr2):
    cdef int i, j
    cdef int nr = arr.shape[0]
    cdef int nc = arr.shape[1]
    cdef ndarray[object, ndim=2] final = np.empty((nr, nc), dtype='O')
    for i in range(nr):
        for j in range(nc):
            if arr[i, j] is None or arr2[i, j] is None:
                final[i, j] = None
            else:
                final[i, j] = arr[i, j] + arr2[i, j]
    return final

def add_obj_two_bc(ndarray[object, ndim=2] arr, ndarray[object, ndim=2] arr2):
    cdef int i, j
    cdef int nr = arr.shape[0]
    cdef int nc = arr.shape[1]
    cdef ndarray[object, ndim=2] final = np.empty((nr, nc), dtype='O')
    cdef ndarray[object] arr2b = arr2.squeeze()

    if arr2.shape[1] == 1:
        for i in range(nr):
            for j in range(nc):
                if arr[i, j] is None or arr2b[i] is None:
                    final[i, j] = None
                else:
                    final[i, j] = arr[i, j] + arr2b[i]
    else:
        for i in range(nr):
            for j in range(nc):
                if arr[i, j] is None or arr2b[j] is None:
                    final[i, j] = None
                else:
                    final[i, j] = arr[i, j] + arr2b[j]
        return final

def radd_obj(ndarray[object, ndim=2] arr, str other):
    cdef int i, j
    cdef int nr = arr.shape[0]
    cdef int nc = arr.shape[1]
    cdef ndarray[object, ndim=2] final = np.empty((nr, nc), dtype='O')
    for i in range(nr):
        for j in range(nc):
            try:
                final[i, j] = other + arr[i, j]
            except:
                final[i, j] = None
    return final

def radd_obj_two(ndarray[object, ndim=2] arr, ndarray[object, ndim=2] arr2):
    cdef int i, j
    cdef int nr = arr.shape[0]
    cdef int nc = arr.shape[1]
    cdef ndarray[object, ndim=2] final = np.empty((nr, nc), dtype='O')

    for i in range(nr):
        for j in range(nc):
            if arr[i, j] is None or arr2[i, j] is None:
                final[i, j] = None
            else:
                final[i, j] = arr2[i, j] + arr[i, j]
    return final

def radd_obj_two_bc(ndarray[object, ndim=2] arr, ndarray[object, ndim=2] arr2):
    cdef int i, j
    cdef int nr = arr.shape[0]
    cdef int nc = arr.shape[1]
    cdef ndarray[object, ndim=2] final = np.empty((nr, nc), dtype='O')
    cdef ndarray[object] arr2b = arr2.squeeze()

    if arr2.shape[1] == 1:
        for i in range(nr):
            for j in range(nc):
                if arr[i, j] is None or arr2b[i] is None:
                    final[i, j] = None
                else:
                    final[i, j] = arr2[i] + arr2b[i]
    else:
        for i in range(nr):
            for j in range(nc):
                if arr[i, j] is None or arr2b[j] is None:
                    final[i, j] = None
                else:
                    final[i, j] = arr2[i] + arr2b[j]
    return final

def mul_obj(ndarray[object, ndim=2] arr, int other):
    cdef int i, j
    cdef int nr = arr.shape[0]
    cdef int nc = arr.shape[1]
    cdef ndarray[object, ndim=2] final = np.empty((nr, nc), dtype='O')
    for i in range(nr):
        for j in range(nc):
            try:
                final[i, j] = arr[i, j] * other
            except:
                final[i, j] = None
    return final

def lt_obj(ndarray[object, ndim=2] arr, str other):
    cdef int i, j
    cdef int nr = arr.shape[0]
    cdef int nc = arr.shape[1]
    cdef ndarray[np.uint8_t, ndim=2, cast=True] final = np.empty((nr, nc), dtype='bool')
    for i in range(nr):
        for j in range(nc):
            try:
                final[i, j] = arr[i, j] < other
            except:
                final[i, j] = False
    return final

def lt_obj_two(ndarray[object, ndim=2] arr, ndarray[object, ndim=2] arr2):
    cdef int i, j
    cdef int nr = arr.shape[0]
    cdef int nc = arr.shape[1]
    cdef ndarray[np.uint8_t, ndim=2, cast=True] final = np.empty((nr, nc), dtype='bool')

    for i in range(nr):
        for j in range(nc):
            try:
                final[i, j] = arr[i, j] < arr2[i, j]
            except:
                final[i, j] = False
    return final

def lt_obj_two_bc(ndarray[object, ndim=2] arr, ndarray[object, ndim=2] arr2):
    cdef int i, j
    cdef int nr = arr.shape[0]
    cdef int nc = arr.shape[1]
    cdef ndarray[np.uint8_t, ndim=2, cast=True] final = np.empty((nr, nc), dtype='bool')
    cdef ndarray[object] arr2b = arr2.squeeze()

    if arr2.shape[1] == 1:
        for i in range(nr):
            for j in range(nc):
                try:
                    final[i, j] = arr[i, j] < arr2b[i]
                except:
                    final[i, j] = False
    else:
        for i in range(nr):
            for j in range(nc):
                try:
                    final[i, j] = arr[i, j] < arr2b[j]
                except:
                    final[i, j] = False
    return final

def le_obj(ndarray[object, ndim=2] arr, str other):
    cdef int i, j
    cdef int nr = arr.shape[0]
    cdef int nc = arr.shape[1]
    cdef ndarray[np.uint8_t, ndim=2, cast=True] final = np.empty((nr, nc), dtype='bool')
    for i in range(nr):
        for j in range(nc):
            try:
                final[i, j] = arr[i, j] <= other
            except:
                final[i, j] = False
    return final

def le_obj_two(ndarray[object, ndim=2] arr, ndarray[object, ndim=2] arr2):
    cdef int i, j
    cdef int nr = arr.shape[0]
    cdef int nc = arr.shape[1]
    cdef ndarray[np.uint8_t, ndim=2, cast=True] final = np.empty((nr, nc), dtype='bool')
    for i in range(nr):
        for j in range(nc):
            try:
                final[i, j] = arr[i, j] <= arr2[i, j]
            except:
                final[i, j] = False
    return final

def le_obj_two_bc(ndarray[object, ndim=2] arr, ndarray[object, ndim=2] arr2):
    cdef int i, j
    cdef int nr = arr.shape[0]
    cdef int nc = arr.shape[1]
    cdef ndarray[np.uint8_t, ndim=2, cast=True] final = np.empty((nr, nc), dtype='bool')
    cdef ndarray[object] arr2b = arr2.squeeze()

    if arr2.shape[1] == 1:
        for i in range(nr):
            for j in range(nc):
                try:
                    final[i, j] = arr[i, j] <= arr2b[i]
                except:
                    final[i, j] = False
    else:
        for i in range(nr):
            for j in range(nc):
                try:
                    final[i, j] = arr[i, j] <= arr2b[j]
                except:
                    final[i, j] = False
    return final

def gt_obj(ndarray[object, ndim=2] arr, str other):
    cdef int i, j
    cdef int nr = arr.shape[0]
    cdef int nc = arr.shape[1]
    cdef ndarray[np.uint8_t, ndim=2, cast=True] final = np.empty((nr, nc), dtype='bool')
    for i in range(nr):
        for j in range(nc):
            try:
                final[i, j] = arr[i, j] > other
            except:
                final[i, j] = False
    return final

def gt_obj_two(ndarray[object, ndim=2] arr, ndarray[object, ndim=2] arr2):
    cdef int i, j
    cdef int nr = arr.shape[0]
    cdef int nc = arr.shape[1]
    cdef ndarray[np.uint8_t, ndim=2, cast=True] final = np.empty((nr, nc), dtype='bool')
    for i in range(nr):
        for j in range(nc):
            try:
                final[i, j] = arr[i, j] > arr2[i, j]
            except:
                final[i, j] = False
    return final

def gt_obj_two_bc(ndarray[object, ndim=2] arr, ndarray[object, ndim=2] arr2):
    cdef int i, j
    cdef int nr = arr.shape[0]
    cdef int nc = arr.shape[1]
    cdef ndarray[np.uint8_t, ndim=2, cast=True] final = np.empty((nr, nc), dtype='bool')
    cdef ndarray[object] arr2b = arr2.squeeze()

    if arr2.shape[1] == 1:
        for i in range(nr):
            for j in range(nc):
                try:
                    final[i, j] = arr[i, j] > arr2b[i]
                except:
                    final[i, j] = False
    else:
        for i in range(nr):
            for j in range(nc):
                try:
                    final[i, j] = arr[i, j] > arr2b[j]
                except:
                    final[i, j] = False
    return final

def ge_obj(ndarray[object, ndim=2] arr, str other):
    cdef int i, j
    cdef int nr = arr.shape[0]
    cdef int nc = arr.shape[1]
    cdef ndarray[np.uint8_t, ndim=2, cast=True] final = np.empty((nr, nc), dtype='bool')
    for i in range(nr):
        for j in range(nc):
            try:
                final[i, j] = arr[i, j] >= other
            except:
                final[i, j] = False
    return final

def ge_obj_two(ndarray[object, ndim=2] arr, ndarray[object, ndim=2] arr2):
    cdef int i, j
    cdef int nr = arr.shape[0]
    cdef int nc = arr.shape[1]
    cdef ndarray[np.uint8_t, ndim=2, cast=True] final = np.empty((nr, nc), dtype='bool')
    for i in range(nr):
        for j in range(nc):
            try:
                final[i, j] = arr[i, j] >= arr2[i, j]
            except:
                final[i, j] = False
    return final

def ge_obj_two_bc(ndarray[object, ndim=2] arr, ndarray[object, ndim=2] arr2):
    cdef int i, j
    cdef int nr = arr.shape[0]
    cdef int nc = arr.shape[1]
    cdef ndarray[np.uint8_t, ndim=2, cast=True] final = np.empty((nr, nc), dtype='bool')
    cdef ndarray[object] arr2b = arr2.squeeze()

    if arr2.shape[1] == 1:
        for i in range(nr):
            for j in range(nc):
                try:
                    final[i, j] = arr[i, j] >= arr2b[i]
                except:
                    final[i, j] = False
    else:
        for i in range(nr):
            for j in range(nc):
                try:
                    final[i, j] = arr[i, j] >= arr2b[j]
                except:
                    final[i, j] = False
    return final

def min_max_int(ndarray[np.int64_t] a):
    cdef int i, n = len(a)
    cdef long low = a[0]
    cdef long high = a[0]
    for i in range(n):
        if a[i] < low:
            low = a[i]
        if a[i] > high:
            high = a[i]
    return low, high

def min_max_float(ndarray[np.float64_t] a):
    cdef int i, n = len(a)
    cdef np.float64_t low = a[0]
    cdef np.float64_t high = a[0]
    for i in range(n):
        if a[i] < low:
            low = a[i]
        if a[i] > high:
            high = a[i]
    return low, high


def min_max_int2(ndarray[np.int64_t, ndim=2] a, axis):
    cdef int i, j
    cdef int nr = a.shape[0]
    cdef int nc = a.shape[1]
    cdef ndarray[np.int64_t] lows
    cdef ndarray[np.int64_t] highs
    cdef np.int64_t low, high

    if axis == 0:
        lows = np.empty(nc, dtype='int64')
        highs = np.empty(nc, dtype='int64')
        for i in range(nc):
            low = a[0, i]
            high = a[0, i]
            for j in range(nr):
                if a[j, i] < low:
                    low = a[j, i]
                if a[j, i] > high:
                    high = a[j, i]
            lows[i] = low
            highs[i] = high
    return lows, highs


def nunique_str(ndarray[object, ndim=2] a, axis, count_na=False, **kwargs):
    cdef int i, j, ct_nan
    cdef int nr = a.shape[0]
    cdef int nc = a.shape[1]
    cdef set s
    cdef ndarray[np.int64_t] result

    if axis == 0:
        result = np.empty(nc, dtype='int64')
        for i in range(nc):
            s = set()
            for j in range(nr):
                s.add(a[j, i])
            if None in s:
                if count_na:
                    result[i] = len(s)
                else:
                    result[i] = len(s) - 1
            else:
                result[i] = len(s)

    if axis == 1:
        result = np.empty(nr, dtype='int64')
        if count_na:
            for i in range(nr):
                s = set()
                ct_nan = 0
                for j in range(nc):
                    if (isinstance(a[i, j], (float, np.floating)) and np.isnan(a[i, j])) or a[i, j] is None:
                        ct_nan = 1
                    else:
                        s.add(a[i, j])
                result[i] = len(s) + ct_nan
        else:
            for i in range(nr):
                s = set()
                for j in range(nc):
                    if not(isinstance(a[i, j], (float, np.floating)) and np.isnan(a[i, j])) and a[i, j] is not None:
                        s.add(a[i, j])
                result[i] = len(s)

    return result

def nunique_int(ndarray[np.int64_t, ndim=2] a, axis, **kwargs):
    cdef int i, j
    cdef int nr = a.shape[0]
    cdef int nc = a.shape[1]
    cdef set s = set()
    cdef ndarray[np.int64_t] result

    lows, highs = min_max_int2(a, axis)
    if (highs - lows < 10_000_000).all():
        return nunique_int_bounded(a, axis, lows, highs)

    if axis == 0:
        result = np.empty(nc, dtype='int64')
        for i in range(nc):
            s = set()
            for j in range(nr):
                s.add(a[j, i])
            result[i] = len(s)
    else:
        result = np.empty(nr, dtype='int64')
        for i in range(nr):
            s = set()
            for j in range(nc):
                s.add(a[i, j])
            result[i] = len(s)

    return result

def nunique_bool(ndarray[np.uint8_t, cast=True, ndim=2] a, axis, **kwargs):
    cdef int i, j
    cdef int nr = a.shape[0]
    cdef int nc = a.shape[1]
    cdef ndarray[np.uint8_t, cast=True] unique
    cdef list result
    cdef ndarray[np.int64_t] final_result

    if axis == 0:
        final_result = np.empty(nc, dtype='int64')
        for i in range(nc):
            result = []
            unique = np.zeros(2, dtype=bool)
            for j in range(nr):
                if not unique[a[j, i]]:
                    unique[a[j, i]] = True
                    result.append(a[j, i])
                if len(result) == 2:
                    break
            final_result[i] = len(result)
    else:
        final_result = np.empty(nr, dtype='int64')
        for i in range(nr):
            result = []
            unique = np.zeros(2, dtype=bool)
            for j in range(nc):
                if not unique[a[i, j]]:
                    unique[a[i, j]] = True
                    result.append(a[i, j])
                if len(result) == 2:
                    break
            final_result[i] = len(result)

    return final_result

def nunique_float(ndarray[np.float64_t, ndim=2] a, axis, count_na=False, **kwargs):
    cdef int i, j, ct_nan
    cdef int nr = a.shape[0]
    cdef int nc = a.shape[1]
    cdef set s
    cdef ndarray[np.int64_t] result

    if axis == 0:
        result = np.empty(nc, dtype='int64')
        if count_na:
            for i in range(nc):
                s = set()
                ct_nan = 0
                for j in range(nr):
                    if isnan(a[j, i]):
                        ct_nan = 1
                    else:
                        s.add(a[j, i])
                result[i] = len(s) + ct_nan
        else:
            for i in range(nc):
                s = set()
                for j in range(nr):
                    if not isnan(a[j, i]):
                        s.add(a[j, i])
                result[i] = len(s)

    if axis == 1:
        result = np.empty(nr, dtype='int64')
        if count_na:
            for i in range(nr):
                s = set()
                ct_nan = 0
                for j in range(nc):
                    if isnan(a[j, i]):
                        ct_nan = 1
                    else:
                        s.add(a[i, j])
                result[i] = len(s) + ct_nan
        else:
            for i in range(nr):
                s = set()
                for j in range(nc):
                    if not isnan(a[i, j]):
                        s.add(a[i, j])
                result[i] = len(s)

    return result

def nunique_int_bounded(ndarray[np.int64_t, ndim=2] a, axis,
                        ndarray[np.int64_t] lows, ndarray[np.int64_t] highs,  **kwargs):
    cdef int i, j
    cdef int nr = a.shape[0]
    cdef int nc = a.shape[1]
    cdef ndarray[np.uint8_t, cast=True] unique
    cdef np.int64_t count, amin, rng
    cdef ndarray[np.int64_t] result

    if axis == 0:
        result = np.empty(nc, dtype='int64')
        for i in range(nc):
            count = 0
            amin = lows[i]
            rng = highs[i] - lows[i] + 1
            unique = np.zeros(rng, dtype=bool)
            for j in range(nr):
                if not unique[a[j, i] - amin]:
                    unique[a[j, i] - amin] = True
                    count += 1
            result[i] = count
    else:
        result = np.empty(nr, dtype='int64')
        for i in range(nr):
            count = 0
            amin = lows[i]
            rng = highs[i] - lows[i] + 1
            unique = np.zeros(rng, dtype=bool)
            for j in range(nc):
                if not unique[a[i, j] - amin]:
                    unique[a[i, j] - amin] = True
                    count += 1
            result[i] = count
    return result

def sum_int(ndarray[np.int64_t, ndim=2] a, axis, **kwargs):
    cdef long *arr = <long*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.int64_t] total

    if axis == 0:
        total = np.zeros(nc, dtype=np.int64)
        for i in range(nc):
            for j in range(nr):
                total[i] += arr[i * nr + j]
    else:
        total = np.zeros(nr, dtype=np.int64)
        for i in range(nr):
            for j in range(nc):
                total[i] += arr[j * nr + i]
    return total

def sum_bool(ndarray[np.uint8_t, ndim=2, cast=True] a, axis, **kwargs):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.int64_t] total

    if axis == 0:
        total = np.zeros(nc, dtype='int64')
        for i in range(nc):
            for j in range(nr):
                if a[j, i]:
                    total[i] += 1
    else:
        total = np.zeros(nr, dtype='int64')
        for i in range(nr):
            for j in range(nc):
                if a[i, j]:
                    total[i] += 1
    return total.astype(np.int64)

def sum_float(ndarray[np.float64_t, ndim=2] a, axis, hasnans, **kwargs):
    cdef double *arr = <double*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef long idx
    cdef ndarray[np.float64_t] total

    if axis == 0:
        total = np.zeros(nc, dtype=np.float64)
        for i in range(nc):
            if hasnans[i] is None or hasnans[i] == True:
                for j in range(nr):
                    if not isnan(arr[i * nr + j]):
                        total[i] += arr[i * nr + j]
            else:
                for j in range(nr):
                    total[i] += arr[i * nr + j]

    else:
        total = np.zeros(nr, dtype=np.float64)
        for i in range(nc):
            if hasnans[i] is None or hasnans[i] == True:
                for j in range(nr):
                    if not isnan(arr[i * nr + j]):
                        total[j] += arr[i * nr + j]
            else:
                for j in range(nr):
                    total[j] += arr[i * nr + j]
    return total

def sum_str(ndarray[object, ndim=2] a, axis, hasnans):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[object] total
    cdef int ct

    if axis == 0:
        total = np.zeros(nc, dtype='U').astype('O')
        for i in range(nc):
            ct = 0
            if hasnans[i] is None or hasnans[i] == True:
                for j in range(nr):
                    if a[j, i] is not None:
                        total[i] = total[i] + a[j, i]
                        ct += 1
                if ct == 0:
                    total[i] = None
            else:
                for j in range(nr):
                    total[i] = total[i] + a[j, i]
    else:
        total = np.zeros(nr, dtype='U').astype('O')
        for i in range(nc):
            ct = 0
            if hasnans[i] is None or hasnans[i] == True:
                for j in range(nr):
                    if a[j, i] is not None:
                        total[j] = total[j] + a[j, i]
                        ct += 1
                if ct == 0:
                    total[i] = None
            else:
                for j in range(nr):
                    total[j] = total[j] + a[j, i]
    return total

def mode_int(ndarray[np.int64_t, ndim=2] a, axis, hasnans, keep):
    cdef int i, j, order, low, high, last
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.int64_t] result, col_arr, uniques, counts, groups

    if axis == 0:
        result = np.empty(nc, dtype='int64')
        for i in range(nc):
            col_arr = a[:, i]
            low, high = _math.min_max_int(col_arr)
            if high - low < 10_000_000:
                uniques, counts = gb.value_counts_int_bounded(col_arr, low, high)
            else:
                groups, counts = gb.value_counts_int(col_arr)
                uniques = col_arr[groups]

            last = np.argsort(counts)[len(counts) - 1]
            result[i] = uniques[last]
    else:
        result = np.empty(nr, dtype='int64')
        for i in range(nr):
            col_arr = a[i, :]
            low, high = _math.min_max_int(col_arr)
            if high - low < 10_000_000:
                uniques, counts = gb.value_counts_int_bounded(col_arr, low, high)
            else:
                groups, counts = gb.value_counts_int(col_arr)
                uniques = col_arr[groups]

            last = np.argsort(counts)[len(counts) - 1]
            result[i] = uniques[last]
    return result

def mode_float(ndarray[np.float64_t, ndim=2] a, axis, hasnans, keep):
    cdef int i, j, order, low, high, last
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.int64_t] groups, counts
    cdef ndarray[np.float64_t] result, col_arr, uniques

    if axis == 0:
        result = np.empty(nc, dtype='float64')
        for i in range(nc):
            col_arr = a[:, i]
            groups, counts = gb.value_counts_float(col_arr, dropna=True)
            uniques = col_arr[groups]

            if len(uniques) == 0:
                result[i] = nan
            else:
                last = np.argsort(counts)[len(counts) - 1]
                result[i] = uniques[last]
    else:
        result = np.empty(nr, dtype='float64')
        for i in range(nr):
            col_arr = a[i, :]
            groups, counts = gb.value_counts_float(col_arr, dropna=True)
            uniques = col_arr[groups]

            if len(uniques) == 0:
                result[i] = nan
            else:
                last = np.argsort(counts)[len(counts) - 1]
                result[i] = uniques[last]
    return result

def mode_str(ndarray[object, ndim=2] a, axis, hasnans, keep):
    cdef int i, j, order, low, high, last
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.int64_t] groups, counts
    cdef ndarray[object] result, col_arr, uniques

    if axis == 0:
        result = np.empty(nc, dtype='O')
        for i in range(nc):
            col_arr = a[:, i]
            groups, counts = gb.value_counts_str(col_arr, dropna=True)
            uniques = col_arr[groups]

            if len(uniques) == 0:
                result[i] = None
            else:
                last = np.argsort(counts)[len(counts) - 1]
                result[i] = uniques[last]
    else:
        result = np.empty(nr, dtype='O')
        for i in range(nr):
            col_arr = a[i, :]
            groups, counts = gb.value_counts_str(col_arr, dropna=True)
            uniques = col_arr[groups]

            if len(uniques) == 0:
                result[i] = None
            else:
                last = np.argsort(counts)[len(counts) - 1]
                result[i] = uniques[last]
    return result


def mode_bool(ndarray[np.uint8_t, ndim=2, cast=True] a, axis, hasnans, keep):
    cdef int i, j, order, low, high, last
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.int64_t] groups, counts
    cdef ndarray[np.int8_t, cast=True] result, col_arr, uniques

    if axis == 0:
        result = np.empty(nc, dtype='bool')
        for i in range(nc):
            col_arr = a[:, i]
            uniques, counts = gb.value_counts_bool(col_arr)

            last = np.argsort(counts)[len(counts) - 1]
            result[i] = uniques[last]
    else:
        result = np.empty(nr, dtype='bool')
        for i in range(nr):
            col_arr = a[i, :]
            uniques, counts = gb.value_counts_bool(col_arr)

            last = np.argsort(counts)[len(counts) - 1]
            result[i] = uniques[last]
    return result

def prod_int(ndarray[np.int64_t, ndim=2] a, axis, **kwargs):
    cdef long *arr = <long*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.int64_t] total

    if axis == 0:
        total = np.ones(nc, dtype=np.int64)
        for i in range(nc):
            for j in range(nr):
                total[i] *= arr[i * nr + j]
    else:
        total = np.zeros(nr, dtype=np.int64)
        for i in range(nr):
            for j in range(nc):
                total[i] *= arr[j * nr + i]
    return total

def prod_bool(ndarray[np.uint8_t, ndim=2, cast=True] a, axis, **kwargs):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.int64_t] total

    if axis == 0:
        total = np.ones(nc, dtype='int64')
        for i in range(nc):
            for j in range(nr):
                total[i] *= a[j, i]
    else:
        total = np.zeros(nr, dtype='int64')
        for i in range(nr):
            for j in range(nc):
                total[i] *= a[i, j]
    return total

def prod_float(ndarray[np.float64_t, ndim=2] a, axis, hasnans, **kwargs):
    cdef double *arr = <double*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef long idx
    cdef ndarray[np.float64_t] total

    if axis == 0:
        total = np.ones(nc, dtype=np.float64)
        for i in range(nc):
            for j in range(nr):
                if not isnan(arr[i * nr + j]):
                    total[i] *= arr[i * nr + j]
            # else:
            #     for j in range(nr):
            #         total[i] *= arr[i * nr + j]

    else:
        total = np.zeros(nr, dtype=np.float64)
        for i in range(nc):
            for j in range(nr):
                if not isnan(arr[i * nr + j]):
                    total[j] *= arr[i * nr + j]
            # else:
            #     for j in range(nr):
            #         total[j] *= arr[i * nr + j]
    return total

def max_int(ndarray[np.int64_t, ndim=2] a, axis, **kwargs):
    cdef long *arr = <long*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.int64_t] amax
    
    if axis ==0:
        amax = np.empty(nc, dtype='int64')
        for i in range(nc):
            amax[i] = a[0, i]
            for j in range(nr):
                if arr[i * nr + j] > amax[i]:
                    amax[i] = arr[i * nr + j]
    else:
        amax = a[:, 0].copy('F')
        for i in range(nc):
            for j in range(nr):
                if arr[i * nr + j] > amax[j]:
                    amax[j] = arr[i * nr + j]
    return amax

def min_int(ndarray[np.int64_t, ndim=2] a, axis, **kwargs):
    cdef long *arr = <long*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.int64_t] amin

    if axis == 0:
        amin = np.empty(nc, dtype='int64')
        for i in range(nc):
            amin[i] = a[0]
            for j in range(nr):
                if arr[i * nr + j] < amin[i]:
                    amin[i] = arr[i * nr + j]
    else:
        amin = a[:, 0].copy('F')
        for i in range(nc):
            for j in range(nr):
                if arr[i * nr + j] < amin[j]:
                    amin[j] = arr[i * nr + j]
    return amin


def max_bool(ndarray[np.uint8_t, ndim=2, cast=True] a, axis, **kwargs):
    cdef unsigned char *arr = <unsigned char*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.uint8_t] amax
    if axis == 0:
        amax = np.zeros(nc, dtype=np.uint8)
        for i in range(nc):
            for j in range(nr):
                if arr[i * nr + j] == 1:
                    amax[i] = 1
                    break
    else:
        amax = np.zeros(nr, dtype=np.uint8)
        for i in range(nc):
            for j in range(nr):
                if arr[i * nr + j] == 1:
                    amax[j] = 1
                    break
    return amax.astype(np.int64)

def min_bool(ndarray[np.uint8_t, ndim=2, cast=True] a, axis, **kwargs):
    cdef unsigned char *arr = <unsigned char*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.uint8_t] amin

    if axis == 0:
        amin = np.ones(nc, dtype=np.uint8)
        for i in range(nc):
            for j in range(nr):
                if arr[i * nr + j] == 0:
                    amin[i] = 0
                    break
    else:
        amin = np.ones(nr, dtype=np.uint8)
        for i in range(nc):
            for j in range(nr):
                if arr[i * nr + j] == 0:
                    amin[j] = 0
                    break
    return amin.astype(np.int64)

def max_float(ndarray[np.float64_t, ndim=2] a, axis, hasnans):
    cdef double *arr = <double*> a.data
    cdef int i, j, k
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.float64_t] amax

    if axis == 0:
        amax = np.full(nc, nan, dtype=np.float64)
        for i in range(nc):
            if hasnans[i] is None or hasnans[i] == True:
                k = 0
                while isnan(arr[i * nr + k]) and k < nr - 1:
                    k += 1
                amax[i] = arr[i * nr + k]
                for j in range(k, nr):
                    if not isnan(arr[i * nr + j]):
                        if arr[i * nr + j] > amax[i]:
                            amax[i] = arr[i * nr + j]
            else:
                amax[i] = arr[i * nr]
                for j in range(nr):
                    if arr[i * nr + j] > amax[i]:
                        amax[i] = arr[i * nr + j]
    else:
        amax = np.full(nr, nan, dtype=np.float64)
        if hasnans.sum() > 0:
            for i in range(nr):
                k = 0
                while isnan(arr[k * nr + i]) and k < nc - 1:
                    k += 1
                amax[i] = arr[k * nr + i]
                for j in range(k, nc):
                    if not isnan(arr[j * nr + i]):
                        if arr[j * nr + i] > amax[i]:
                            amax[i] = arr[j * nr + i]
        else:
            for i in range(nr):
                for j in range(nc):
                    if arr[j * nr + i] > amax[i]:
                        amax[i] = arr[j * nr + i]
    return amax

def min_float(ndarray[np.float64_t, ndim=2] a, axis, hasnans):
    cdef double *arr = <double*> a.data
    cdef int i, j, k
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.float64_t] amin

    if axis == 0:
        amin = np.full(nc, nan, dtype=np.float64)
        for i in range(nc):
            if hasnans[i] is None or hasnans[i] == True:
                k = 0
                while isnan(arr[i * nr + k]) and k < nr - 1:
                    k += 1
                amin[i] = arr[i * nr + k]
                for j in range(k, nr):
                    if not isnan(arr[i * nr + j]):
                        if arr[i * nr + j] < amin[i]:
                            amin[i] = arr[i * nr + j]
            else:
                amin[i] = arr[i * nr]
                for j in range(nr):
                    if arr[i * nr + j] < amin[i]:
                        amin[i] = arr[i * nr + j]
    else:
        amin = np.full(nr, nan, dtype=np.float64)
        if hasnans.sum() > 0:
            for i in range(nr):
                k = 0
                while isnan(arr[k * nr + i]) and k < nc - 1:
                    k += 1
                amin[i] = arr[k * nr + i]
                for j in range(k, nc):
                    if not isnan(arr[j * nr + i]):
                        if arr[j * nr + i] < amin[i]:
                            amin[i] = arr[j * nr + i]
        else:
            for i in range(nr):
                for j in range(nc):
                    if arr[j * nr + i] < amin[i]:
                        amin[i] = arr[j * nr + i]
    return amin

def max_str(ndarray[object, ndim=2] a, axis, hasnans):
    cdef int i, j, k
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[object] amax

    if axis == 0:
        amax = np.full(nc, None, dtype='O')
        for i in range(nc):
            if hasnans[i] is None or hasnans[i] == True:
                k = 0
                while a[k, i] is None and k < nr:
                    k += 1
                amax[i] = a[k, i]
                for j in range(k, nr):
                    if a[j, i] is not None:
                        if a[j, i] > amax[i]:
                            amax[i] = a[j, i]
            else:
                amax[i] = a[0, i]
                for j in range(nr):
                    if a[j, i] > amax[i]:
                        amax[i] = a[j, i]
    else:
        amax = np.full(nr, None, dtype='O')
        if hasnans.sum() > 0:
            for i in range(nr):
                k = 0
                while a[i, k] is None and k < nc:
                    k += 1
                amax[i] = a[i, k]
                for j in range(k, nc):
                    if not a[i, j] is None:
                        if a[i, j]  > amax[i]:
                            amax[i] = a[i, j] 
        else:
            for i in range(nr):
                for j in range(nc):
                    if a[i, j]  > amax[i]:
                        amax[i] = a[i, j]
    return amax

def min_str(ndarray[object, ndim=2] a, axis, hasnans):
    cdef int i, j, k
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[object] amin

    if axis == 0:
        amin = np.full(nc, nan, dtype='O')
        for i in range(nc):
            if hasnans[i] is None or hasnans[i] == True:
                k = 0
                while a[k, i] is None and k < nr:
                    k += 1
                amin[i] = a[k, i]
                for j in range(k, nr):
                    if not a[j, i] is None:
                        if a[j, i] < amin[i]:
                            amin[i] = a[j, i]
            else:
                amin[i] = a[0, i]
                for j in range(nr):
                    if a[j, i] < amin[i]:
                        amin[i] = a[j, i]
    else:
        amin = np.full(nr, nan, dtype='O')
        if hasnans.sum() > 0:
            for i in range(nr):
                k = 0
                while a[i, k] is None and k < nc:
                    k += 1
                amin[i] = a[i, k]
                for j in range(k, nc):
                    if not a[i, j] is None:
                        if a[i, j] < amin[i]:
                            amin[i] = a[i, j]
        else:
            for i in range(nr):
                for j in range(nc):
                    if a[i, j] < amin[i]:
                        amin[i] = a[i, j]
    return amin

def mean_int(ndarray[np.int64_t, ndim=2] a, axis, **kwargs):
    cdef long *arr = <long*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.int64_t] total

    if axis == 0:
        #return a.mean(0)
        total = np.zeros(nc, dtype=np.int64)
        for i in range(nc):
            for j in range(nr):
                total[i] += arr[i * nr + j]
        return total / nr
    else:
        #return a.mean(1)
        total = np.zeros(nr, dtype=np.int64)
        for i in range(nc):
            for j in range(nr):
                total[j] += arr[i * nr + j]
        return total / nc

def mean_bool(ndarray[np.uint8_t, ndim=2, cast=True] a, axis, **kwargs):
    cdef unsigned char *arr = <unsigned char*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.int64_t] total

    if axis == 0:
        total = np.zeros(nc, dtype='int64')
        for i in range(nc):
            for j in range(nr):
                total[i] += arr[i * nr + j]
        return total / nr
    else:
        total = np.zeros(nr, dtype='int64')
        for i in range(nc):
            for j in range(nr):
                total[j] += arr[i * nr + j]
        return total / nc

def mean_float(ndarray[np.float64_t, ndim=2] a, axis, hasnans):
    cdef double *arr = <double*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef int ct = 0
    cdef ndarray[np.float64_t] total

    if axis == 0:
        total = np.zeros(nc, dtype=np.float64)
        for i in range(nc):
            if hasnans[i] is None or hasnans[i] == True:
                ct = 0
                for j in range(nr):
                    if not isnan(arr[i * nr + j]):
                        total[i] += arr[i * nr + j]
                        ct += 1
                if ct != 0:
                    total[i] = total[i] / ct
                else:
                    total[i] = nan
            else:
                for j in range(nr):
                    total[i] += arr[i * nr + j]
                total[i] = total[i] / nr
    else:
        total = np.zeros(nr, dtype=np.float64)
        for i in range(nr):
            ct = 0
            for j in range(nc):
                if not isnan(arr[j * nr + i]):
                    total[i] += arr[j * nr + i]
                    ct += 1
            if ct != 0:
                total[i] = total[i] / ct
            else:
                total[i] = nan
    return total

def median_int(ndarray[np.int64_t, ndim=2] a, axis, **kwargs):
    cdef:
        Py_ssize_t i, nr = a.shape[0], nc = a.shape[1]
        np.float64_t first, second
        ndarray[np.float64_t] result

    if axis == 0:
        result = np.empty(nc, dtype='float64')
    else:
        result = np.empty(nr, dtype='float64')

    if axis == 0:
        if nr % 2 == 1:
            for i in range(nc):
                result[i] = quick_select_int2(a[:, i], nr, nr // 2)
        else:
            for i in range(nc):
                first = quick_select_int2(a[:, i], nr, nr // 2 - 1)
                second = quick_select_int2(a[:, i], nr, nr // 2)
                result[i] = (first + second) / 2
    else:
        if nc % 2 == 1:
            for i in range(nr):
                result[i] = quick_select_int2(a[i], nc, nc // 2)
        else:
            for i in range(nc):
                first = quick_select_int2(a[i], nc, nc // 2 - 1)
                second = quick_select_int2(a[i], nc, nc // 2)
                result[i] = (first + second) / 2
    return result

def median_bool(ndarray[np.uint8_t, cast=True, ndim=2] a, axis, **kwargs):
    # return np.median(a, axis=axis)
    return median_int(a.astype('int64'), axis=axis)

def median_float(ndarray[np.float64_t, ndim=2] a, axis, hasnans):
    if axis == 0:
        if hasnans.any():
            return bn.nanmedian(a, axis=0)
        return bn.median(a, axis=0)
    else:
        return bn.nanmedian(a, axis=1)

def median_int_1d(ndarray[np.int64_t] a):
    cdef:
        Py_ssize_t i, n = a.shape[0]
        np.float64_t first, second
        np.float64_t result

    if n % 2 == 1:
        result = quick_select_int2(a, n, n // 2)
    else:
        first = quick_select_int2(a, n, n // 2 - 1)
        second = quick_select_int2(a, n, n // 2)
        result = (first + second) / 2
    return result

def median_bool_1d(ndarray[np.uint8_t, cast=True] a):
    return median_int_1d(a.astype('int64'))

def median_float_1d(ndarray[np.float64_t] a, hasnans):
    if hasnans.any():
        return bn.nanmedian(a)
    return bn.median(a)

# def median_float(ndarray[np.float64_t, ndim=2] a, axis, hasnans):
#     cdef:
#         Py_ssize_t i, nr = a.shape[0], nc = a.shape[1]
#         long xlen
#         np.float64_t first, second
#         ndarray[np.float64_t] result, x
#
#     if axis == 0:
#         result = np.empty(nc, dtype='float64')
#     else:
#         result = np.empty(nr, dtype='float64')
#
#     if axis == 0:
#         if hasnans.any():
#             for i in range(nc):
#                 x = a[:, i]
#                 x = x[~np.isnan(x)]
#                 xlen = len(x)
#                 if xlen % 2 == 1:
#                     result[i] = quick_select_float2(x, xlen, xlen // 2)
#                 else:
#                     first = quick_select_float2(x, xlen, xlen // 2 - 1)
#                     second = quick_select_float2(x, xlen, xlen // 2)
#                     result[i] = (first + second) / 2
#         else:
#             if nr % 2 == 1:
#                 for i in range(nc):
#                     x = a[:, i]
#                     result[i] = quick_select_float2(x, nr, nr // 2)
#             else:
#                 for i in range(nc):
#                     x = a[:, i]
#                     first = quick_select_float2(x, nr, nr // 2 - 1)
#                     second = quick_select_float2(x, nr, nr // 2)
#                     result[i] = (first + second) / 2
#         return result
#     else:
#         return bn.nanmedian(a, axis=1)

def var_float(ndarray[double, ndim=2] a, axis, int ddof, hasnans):

    cdef double *x = <double*> a.data
    cdef int i, j, i1
    cdef int ct = 0
    cdef int n = len(a)

    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.float64_t] total
    
    cdef double K = nan
    cdef double Ex = 0
    cdef double Ex2 = 0

    if axis == 0:
        total = np.zeros(nc, dtype=np.float64)
        for i in range(nc):
            i1 = 0
            K = x[i * nr + i1]
            while isnan(K):
                i1 += 1
                K = x[i * nr + i1]
            Ex = 0
            Ex2 = 0
            ct = 0
            for j in range(i1, nr):
                if isnan(x[i * nr + j]):
                    continue
                ct += 1
                Ex += x[i * nr + j] - K
                Ex2 += (x[i * nr + j] - K) * (x[i * nr + j] - K)
            if ct <= ddof:
                total[i] = nan
            else:
                total[i] = (Ex2 - (Ex * Ex) / ct) / (ct - ddof)
    else:
        total = np.zeros(nr, dtype=np.float64)
        for i in range(nr):
            i1 = 0
            K = x[i1 * nr + i]
            while isnan(K):
                i1 += 1
                K = x[i1 * nr + i]
            Ex = 0
            Ex2 = 0
            ct = 0
            for j in range(i1, nc):
                if isnan(x[j * nr + i]):
                    continue
                ct += 1
                Ex += x[j * nr + i] - K
                Ex2 += (x[j * nr + i] - K) * (x[j * nr + i] - K)
            if ct <= ddof:
                total[i] = nan
            else:
                total[i] = (Ex2 - (Ex * Ex) / ct) / (ct - ddof)

    return total

def var_int(ndarray[np.int64_t, ndim=2] a, axis, int ddof, hasnans):

    cdef long *x = <long*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.float64_t] total
    
    cdef double K
    cdef double Ex = 0
    cdef double Ex2 = 0

    if axis == 0:
        total = np.zeros(nc, dtype=np.float64)
        for i in range(nc):
            if nr <= ddof:
                total[i] = nan
                continue
            K = x[i * nr]
            Ex = 0
            Ex2 = 0
            for j in range(nr):
                Ex += x[i * nr + j] - K
                Ex2 += (x[i * nr + j] - K) * (x[i * nr + j] - K)
            
            total[i] = (Ex2 - (Ex * Ex) / nr) / (nr - ddof)
    else:
        total = np.zeros(nr, dtype=np.float64)
        for i in range(nr):
            if nc <= ddof:
                total[i] = nan
                continue
            K = x[i]
            Ex = 0
            Ex2 = 0
            for j in range(nc):
                Ex += x[j * nr + i] - K
                Ex2 += (x[j * nr + i] - K) * (x[j * nr + i] - K)
            
            total[i] = (Ex2 - (Ex * Ex) / nc) / (nc - ddof)
    return total

def var_bool(ndarray[np.uint8_t, ndim=2, cast=True] a, axis, int ddof, hasnans):

    cdef unsigned char *x = <unsigned char *> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.float64_t] total
    
    cdef double K
    cdef double Ex = 0
    cdef double Ex2 = 0

    if axis == 0:
        total = np.zeros(nc, dtype=np.float64)
        for i in range(nc):
            if nr <= ddof:
                total[i] = nan
                continue
            K = x[i * nr]
            Ex = 0
            Ex2 = 0
            for j in range(nr):
                Ex += x[i * nr + j] - K
                Ex2 += (x[i * nr + j] - K) * (x[i * nr + j] - K)
            
            total[i] = (Ex2 - (Ex * Ex) / nr) / (nr - ddof)
    else:
        total = np.zeros(nr, dtype=np.float64)
        for i in range(nr):
            if nc <= ddof:
                total[i] = nan
                continue
            K = x[i]
            Ex = 0
            Ex2 = 0
            for j in range(nc):
                Ex += x[j * nr + i] - K
                Ex2 += (x[j * nr + i] - K) * (x[j * nr + i] - K)
            
            total[i] = (Ex2 - (Ex * Ex) / nc) / (nc - ddof)
    return total

def std_float(ndarray[np.float64_t, ndim=2] a, axis, int ddof, hasnans):
    return np.sqrt(var_float(a, axis, ddof, hasnans))

def std_int(ndarray[np.int64_t, ndim=2] a, axis, int ddof, hasnans):
    return np.sqrt(var_int(a, axis, ddof, hasnans))

def std_bool(ndarray[np.uint8_t, cast=True, ndim=2] a, axis, int ddof, hasnans):
    return np.sqrt(var_bool(a, axis, ddof, hasnans))

def any_int(ndarray[np.int64_t, ndim=2] a, axis, hasnans):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.uint8_t, cast=True] result

    if axis == 0:
        result = np.full(nc, False, dtype='bool')
        for i in range(nc):
            for j in range(nr):
                if a[j, i] != 0:
                    result[i] = True
                    break
    else:
        result = np.full(nr, False, dtype='bool')
        for i in range(nr):
            for j in range(nc):
                if a[i, j] != 0:
                    result[i] = True
                    break
    return result

def any_bool(ndarray[np.uint8_t, ndim=2, cast=True] a, axis, hasnans):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.uint8_t, cast=True] result

    if axis == 0:
        result = np.full(nc, False, dtype='bool')
        for i in range(nc):
            for j in range(nr):
                if a[j, i] == True:
                    result[i] = True
                    break
    else:
        result = np.full(nr, False, dtype='bool')
        for i in range(nr):
            for j in range(nc):
                if a[i, j] == True:
                    result[i] = True
                    break
    return result

def any_float(ndarray[np.float64_t, ndim=2] a, axis, hasnans):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.uint8_t, cast=True] result

    if axis == 0:
        result = np.full(nc, False, dtype='bool')
        for i in range(nc):
            for j in range(nr):
                if a[j, i] != 0 and not isnan(a[j, i]):
                    result[i] = True
                    break
    else:
        result = np.full(nr, False, dtype='bool')
        for i in range(nr):
            for j in range(nc):
                if a[i, j] != 0 and not isnan(a[i, j]):
                    result[i] = True
                    break
    return result

def any_str(ndarray[object, ndim=2] a, axis, hasnans):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.uint8_t, cast=True] result

    if axis == 0:
        result = np.full(nc, False, dtype='bool')
        for i in range(nc):
            for j in range(nr):
                if a[j, i] != '' and a[j, i] is not None:
                    result[i] = True
                    break
    else:
        result = np.full(nr, False, dtype='bool')
        for i in range(nr):
            for j in range(nc):
                if a[i, j] != '' and a[i, j] is not None:
                    result[i] = True
                    break
    return result

def all_int(ndarray[np.int64_t, ndim=2] a, axis, hasnans):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.uint8_t, cast=True] result
    if axis == 0:
        result = np.full(nc, True, dtype='bool')
        for i in range(nc):
            for j in range(nr):
                if a[j, i] == 0:
                    result[i] = False
                    break
    else:
        result = np.full(nr, True, dtype='bool')
        for i in range(nr):
            for j in range(nc):
                if a[i, j] == 0:
                    result[i] = False
                    break
    return result

def all_bool(ndarray[np.uint8_t, ndim=2, cast=True] a, axis, hasnans):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.uint8_t, cast=True] result

    if axis == 0:
        result = np.full(nc, True, dtype='bool')
        for i in range(nc):
            for j in range(nr):
                if a[j, i] == False:
                    result[i] = False
                    break
    else:
        result = np.full(nr, True, dtype='bool')
        for i in range(nr):
            for j in range(nc):
                if a[i, j] == False:
                    result[i] = False
                    break
    return result

def all_float(ndarray[np.float64_t, ndim=2] a, axis, hasnans):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.uint8_t, cast=True] result

    if axis == 0:
        result = np.full(nc, True, dtype='bool')
        for i in range(nc):
            for j in range(nr):
                if a[j, i] == 0 or isnan(a[j, i]):
                    result[i] = False
                    break
    else:
        result = np.full(nr, True, dtype='bool')
        for i in range(nr):
            for j in range(nc):
                if a[i, j] == 0 or isnan(a[i, j]):
                    result[i] = False
                    break
    return result

def all_str(ndarray[object, ndim=2] a, axis, hasnans):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.uint8_t, cast=True] result

    if axis == 0:
        result = np.full(nc, True, dtype='bool')
        for i in range(nc):
            for j in range(nr):
                if a[j, i] == '' or a[j, i] is None:
                    result[i] = False
                    break
    else:
        result = np.full(nr, True, dtype='bool')
        for i in range(nr):
            for j in range(nc):
                if a[i, j] == '' or a[i, j] is None:
                    result[i] = False
                    break
    return result

def argmax_int(ndarray[np.int64_t, ndim=2] a, axis, hasnans):
    cdef long *arr = <long*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef long amax
    cdef ndarray[np.int64_t] result

    if axis == 0:
        result = np.zeros(nc, dtype=np.int64)
        for i in range(nc):
            amax = arr[i * nr] 
            for j in range(nr):
                if arr[i * nr + j] > amax:
                    amax = arr[i * nr + j]
                    result[i] = j
    else:
        result = np.zeros(nr, dtype=np.int64)
        for i in range(nr):
            amax = arr[i] 
            for j in range(nc):
                if arr[j * nr + i] > amax:
                    amax = arr[j * nr + i]
                    result[i] = j
    return result

def argmin_int(ndarray[np.int64_t, ndim=2] a, axis, hasnans):
    cdef long *arr = <long*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef long amin
    cdef ndarray[np.int64_t] result

    if axis == 0:
        result = np.zeros(nc, dtype=np.int64)
        for i in range(nc):
            amin = arr[i * nr]
            for j in range(nr):
                if arr[i * nr + j] < amin:
                    amin = arr[i * nr + j]
                    result[i] = j
    else:
        result = np.zeros(nr, dtype=np.int64)
        for i in range(nr):
            amin = arr[i] 
            for j in range(nc):
                if arr[j * nr + i] < amin:
                    amin = arr[j * nr + i]
                    result[i] = j
    return result

def argmax_bool(ndarray[np.uint8_t, cast=True, ndim=2] a, axis, hasnans):
    cdef unsigned char *arr = <unsigned char*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.int64_t] result

    if axis == 0:
        result = np.zeros(nc, dtype=np.int64)
        for i in range(nc):
            for j in range(nr):
                if arr[i * nr + j]  == True:
                    result[i] = j
                    break
    else:
        result = np.zeros(nr, dtype=np.int64)
        for i in range(nr):
            for j in range(nc):
                if arr[j * nr + i]  == True:
                    result[i] = j
                    break
    return result

def argmin_bool(ndarray[np.uint8_t, cast=True, ndim=2] a, axis, hasnans):
    cdef unsigned char *arr = <unsigned char*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.int64_t] result

    if axis == 0:
        result = np.zeros(nc, dtype=np.int64)
        for i in range(nc):
            for j in range(nr):
                if arr[i * nr + j]  == False:
                    result[i] = j
                    break
    else:
        result = np.zeros(nr, dtype=np.int64)
        for i in range(nr):
            for j in range(nc):
                if arr[j * nr + i]  == False:
                    result[i] = j
                    break
    return result

def argmax_float(ndarray[np.float64_t, ndim=2] a, axis, hasnans):
    cdef double *arr = <double*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef long iloc = -1
    cdef double amax
    cdef ndarray[np.float64_t] result

    if axis == 0:
        result = np.empty(nc, dtype=np.float64)
        for i in range(nc):
            amax = MIN_FLOAT
            for j in range(nr):
                if arr[i * nr + j] > amax:
                    amax = arr[i * nr + j]
                    iloc = j
            if amax <= MIN_FLOAT + 1:
                result[i] = np.nan
            else:
                result[i] = iloc
    else:
        result = np.empty(nr, dtype=np.float64)
        for i in range(nr):
            amax = MIN_FLOAT
            for j in range(nc):
                if arr[j * nr + i] > amax:
                    amax = arr[j * nr + i]
                    iloc = j
            if amax <= MIN_FLOAT + 1:
                result[i] = np.nan
            else:
                result[i] = iloc

    if (result % 1).sum() == 0:
        return result.astype('int64')
    return result

def argmin_float(ndarray[np.float64_t, ndim=2] a, axis, hasnans):
    cdef double *arr = <double*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef long iloc = -1
    cdef double amin
    cdef ndarray[np.float64_t] result

    if axis == 0:
        result = np.empty(nc, dtype=np.float64)
        for i in range(nc):
            amin = MAX_FLOAT
            for j in range(nr):
                if arr[i * nr + j] < amin:
                    amin = arr[i * nr + j]
                    iloc = j
            if amin >= MAX_FLOAT - 1:
                result[i] = np.nan
            else:
                result[i] = iloc
    else:
        result = np.empty(nr, dtype=np.float64)
        for i in range(nr):
            amin = MAX_FLOAT
            for j in range(nc):
                if arr[j * nr + i] < amin:
                    amin = arr[j * nr + i]
                    iloc = j
            if amin >= MAX_FLOAT - 1:
                result[i] = np.nan
            else:
                result[i] = iloc

    if (result % 1).sum() == 0:
        return result.astype('int64')
    return result

def argmax_str(ndarray[object, ndim=2] a, axis, hasnans):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef long iloc = -1
    cdef str amax
    cdef ndarray[np.float64_t] result

    if axis == 0:
        result = np.empty(nc, dtype=np.float64)
        for i in range(nc):
            amax = MIN_CHAR
            for j in range(nr):
                try:
                    if a[j, i] > amax:
                        amax = a[j, i]
                        iloc = j
                except TypeError:
                    pass
            if amax == MIN_CHAR:
                result[i] = nan
            else:
                result[i] = iloc
    else:
        result = np.empty(nr, dtype=np.float64)
        for i in range(nr):
            amax = MIN_CHAR
            for j in range(nc):
                try:
                    if a[i, j] > amax:
                        amax = a[i, j]
                        iloc = j
                except TypeError:
                    pass
            if amax == MIN_CHAR:
                result[i] = nan
            else:
                result[i] = iloc

    if (result % 1).sum() == 0:
        return result.astype('int64')
    return result

def argmin_str(ndarray[object, ndim=2] a, axis, hasnans):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef long iloc = -1
    cdef str amin
    cdef ndarray[np.float64_t] result

    if axis == 0:
        result = np.empty(nc, dtype=np.float64)
        for i in range(nc):
            amin = MAX_CHAR
            for j in range(nr):
                try:
                    if a[j, i] < amin:
                        amin = a[j, i]
                        iloc = j
                except TypeError:
                    pass
            if amin == MAX_CHAR:
                result[i] = nan
            else:
                result[i] = iloc
    else:
        result = np.empty(nr, dtype=np.float64)
        for i in range(nr):
            amin = MAX_CHAR
            for j in range(nc):
                try:
                    if a[i, j] < amin:
                        amin = a[i, j]
                        iloc = j
                except TypeError:
                    pass
            if amin == MAX_CHAR:
                result[i] = nan
            else:
                result[i] = iloc

    if (result % 1).sum() == 0:
        return result.astype('int64')
    return result

def count_int(ndarray[np.int64_t, ndim=2] a, axis, hasnans):
    if axis == 0:
        result = np.full(a.shape[1], a.shape[0], dtype=np.int64)
    else:
        result = np.full(a.shape[0], a.shape[1], dtype=np.int64)
    return result

def count_bool(ndarray[np.uint8_t, cast=True, ndim=2] a, axis, hasnans):
    if axis == 0:
        result = np.full(a.shape[1], a.shape[0], dtype=np.int64)
    else:
        result = np.full(a.shape[0], a.shape[1], dtype=np.int64)
    return result

def count_float(ndarray[np.float64_t, ndim=2] a, axis, hasnans):
    cdef double *arr = <double*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef long ct
    cdef ndarray[np.int64_t] result

    if axis == 0:
        result = np.zeros(nc, dtype=np.int64)
        for i in range(nc):
            ct = 0
            for j in range(nr):
                if not isnan(arr[i * nr + j]):
                    ct += 1
            result[i] = ct
    else:
        result = np.zeros(nr, dtype=np.int64)
        for i in range(nr):
            ct = 0
            for j in range(nc):
                if not isnan(arr[j * nr + i]):
                    ct += 1
            result[i] = ct
    return result
            
def count_str(ndarray[object, ndim=2] a, axis, hasnans):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef long ct
    cdef ndarray[np.int64_t] result

    if axis == 0:
        result = np.zeros(nc, dtype=np.int64)
        for i in range(nc):
            ct = 0
            for j in range(nr):
                if a[j, i] is not None:
                    ct += 1
            result[i] = ct
    else:
        result = np.zeros(nr, dtype=np.int64)
        for i in range(nr):
            ct = 0
            for j in range(nc):
                if a[i, j] is not None:
                    ct += 1
            result[i] = ct
    return result

def clip_str_lower(ndarray[object, ndim=2] a, str lower):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[object, ndim=2] b = np.empty((nr, nc), dtype='O')
    hasnans = True
    if hasnans == True or hasnans is None:
        for i in range(nc):
            for j in range(nr):
                if a[j, i] is None:
                    b[j, i] = None
                else:
                    if a[j, i] < lower:
                        b[j, i] = lower
                    else:
                        b[j, i] = a[j, i]
        return b
    return a.clip(lower)

def clip_str_upper(ndarray[object, ndim=2] a, str upper):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[object, ndim=2] b = np.empty((nr, nc), dtype='O')
    hasnans = True
    if hasnans == True or hasnans is None:
        for i in range(nc):
            for j in range(nr):
                if a[j, i] is None:
                    b[j, i] = None
                else:
                    if a[j, i] > upper:
                        b[j, i] = upper
                    else:
                        b[j, i] = a[j, i]
        return b
    return a.clip(max=upper)

def clip_str_both(ndarray[object, ndim=2] a, str lower, str upper):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[object, ndim=2] b = np.empty((nr, nc), dtype='O')
    hasnans = True
    if hasnans == True or hasnans is None:
        for i in range(nc):
            for j in range(nr):
                if a[j, i] is None:
                    b[j, i] = None
                else:
                    if a[j, i] < lower:
                        b[j, i] = lower
                    elif a[j, i] > upper:
                        b[j, i] = upper
                    else:
                        b[j, i] = a[j, i]
        return b
    return a.clip(lower, upper)

def cummax_float(ndarray[np.float64_t, ndim=2] a, axis, hasnans):
    cdef np.float64_t *arr = <np.float64_t*> a.data
    cdef int i, j, k = 0
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef np.float64_t amax
    cdef ndarray[np.float64_t, ndim=2] b

    if axis == 0:
        b = np.empty((nr, nc), dtype=np.float64, order='F')
        for i in range(nc):
            k = 0
            amax = arr[i * nr + k]
            b[k, i] = amax
            while isnan(amax) and k < nr - 1:
                k += 1
                amax = arr[i * nr + k]
                b[k, i] = nan
            for j in range(k, nr):
                if arr[i * nr + j] > amax:
                    amax = arr[i * nr + j]
                b[j, i] = amax
    else:
        b = np.empty((nr, nc), dtype=np.float64, order='F')
        for i in range(nr):
            k = 0
            amax = arr[k * nr + i]
            b[i, k] = amax
            while isnan(amax) and k < nc - 1:
                k += 1
                amax = arr[k * nr + i]
                b[i, k] = nan
            for j in range(k, nc):
                if arr[j * nr + i] > amax:
                    amax = arr[j * nr + i]
                b[i, j] = amax
    return b

def cummin_float(ndarray[np.float64_t, ndim=2] a, axis, hasnans):
    cdef np.float64_t *arr = <np.float64_t*> a.data
    cdef int i, j, k = 0
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef np.float64_t amin
    cdef ndarray[np.float64_t, ndim=2] b

    if axis == 0:
        b = np.empty((nr, nc), dtype=np.float64, order='F')
        for i in range(nc):
            k = 0
            amin = arr[i * nr + k]
            b[k, i] = amin
            while isnan(amin) and k < nr - 1:
                k += 1
                amin = arr[i * nr + k]
                b[k, i] = nan
            for j in range(k, nr):
                if arr[i * nr + j] < amin:
                    amin = arr[i * nr + j]
                b[j, i] = amin
    else:
        b = np.empty((nr, nc), dtype=np.float64, order='F')
        for i in range(nr):
            k = 0
            amin = arr[k * nr + i]
            b[i, k] = amin
            while isnan(amin) and k < nc - 1:
                k += 1
                amin = arr[k * nr + i]
                b[i, k] = nan
            for j in range(k, nc):
                if arr[j * nr + i] < amin:
                    amin = arr[j * nr + i]
                b[i, j] = amin
    return b

def cummax_int(ndarray[np.int64_t, ndim=2] a, axis, hasnans):
    cdef np.int64_t *arr = <np.int64_t*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef np.int64_t amax
    cdef ndarray[np.int64_t, ndim=2] b = np.empty((nr, nc), dtype=np.int64)

    if axis == 0:
        b = np.empty((nr, nc), dtype=np.int64)
        for i in range(nc):
            amax = arr[i * nr]
            for j in range(nr):
                if arr[i * nr + j] > amax:
                    amax = arr[i * nr + j]
                b[j, i] = amax
    else:
        b = np.empty((nr, nc), dtype=np.int64)
        for i in range(nr):
            amax = arr[i]
            for j in range(nc):
                if arr[j * nr + i] > amax:
                    amax = arr[j * nr + i]
                b[i, j] = amax
    return b

def cummin_int(ndarray[np.int64_t, ndim=2] a, axis, hasnans):
    cdef np.int64_t *arr = <np.int64_t*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef np.int64_t amin
    cdef ndarray[np.int64_t, ndim=2] b = np.empty((nr, nc), dtype=np.int64)

    if axis == 0:
        b = np.empty((nr, nc), dtype=np.int64)
        for i in range(nc):
            amin = arr[i * nr]
            for j in range(nr):
                if arr[i * nr + j] < amin:
                    amin = arr[i * nr + j]
                b[j, i] = amin
    else:
        b = np.empty((nr, nc), dtype=np.int64)
        for i in range(nr):
            amin = arr[i]
            for j in range(nc):
                if arr[j * nr + i] < amin:
                    amin = arr[j * nr + i]
                b[i, j] = amin
    return b

def cummax_bool(ndarray[np.uint8_t, cast=True, ndim=2] a, axis, hasnans):
    cdef unsigned char *arr = <unsigned char*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef int amax = 0
    cdef ndarray[np.uint8_t, ndim=2, cast=True] b

    if axis == 0:
        for i in range(nc):
            b = np.empty((nr, nc), dtype='bool')
            amax = False
            for j in range(nr):
                if amax == True:
                    b[j, i] = True
                elif arr[i * nr + j] == True:
                    amax = True
                    b[j, i] = True
                else:
                    b[j, i] = False
    else:
        for i in range(nr):
            b = np.empty((nr, nc), dtype='bool')
            amax = False
            for j in range(nc):
                if amax == True:
                    b[i, j] = True
                elif arr[j * nr + i] == True:
                    amax = True
                    b[i, j] = True
                else:
                    b[i, j] = False
    return b

def cummin_bool(ndarray[np.uint8_t, cast=True, ndim=2] a, axis, hasnans):
    cdef unsigned char *arr = <unsigned char*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef int amin = 0
    cdef ndarray[np.uint8_t, ndim=2, cast=True] b

    if axis == 0:
        for i in range(nc):
            b = np.empty((nr, nc), dtype='bool')
            amin = True
            for j in range(nr):
                if amin == False:
                    b[j, i] = False
                elif arr[i * nr + j] == False:
                    amin = False
                    b[j, i] = False
                else:
                    b[j, i] = True
    else:
        for i in range(nr):
            b = np.empty((nr, nc), dtype='bool')
            amin = True
            for j in range(nc):
                if amin == False:
                    b[i, j] = False
                elif arr[j * nr + i] == False:
                    amin = False
                    b[i, j] = False
                else:
                    b[i, j] = True
    return b

def cummax_str(ndarray[object, ndim=2] a, axis, hasnans):
    cdef int i, j, ct
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef str amax
    cdef ndarray[object, ndim=2] b

    if axis == 0:
        b = np.empty((nr, nc), dtype='O')
        for i in range(nc):
            amax = ''
            ct = 0
            for j in range(nr):
                if a[j, i] is None:
                    if ct == 0:
                        b[j, i] = None
                    else:
                        b[j, i] = amax 
                else:
                    ct = 1
                    if a[j, i] > amax:
                        amax = a[j, i]
                    b[j, i] = amax
    else:
        b = np.empty((nr, nc), dtype='O')
        for i in range(nr):
            amax = ''
            ct = 0
            for j in range(nc):
                if a[i, j] is None:
                    if ct == 0:
                        b[i, j] = None
                    else:
                        b[i, j] = amax 
                else:
                    ct = 1
                    if a[i, j] > amax:
                        amax = a[i, j]
                    b[i, j] = amax
    return b

def cummin_str(ndarray[object, ndim=2] a, axis, hasnans):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef str amin
    cdef ndarray[object, ndim=2] b

    if axis == 0:
        b = np.empty((nr, nc), dtype='O')
        for i in range(nc):
            amin = MAX_CHAR
            for j in range(nr):
                if a[j, i] is None:
                    if amin == MAX_CHAR:
                        b[j, i] = None
                    else:
                        b[j, i] = amin 
                else:
                    if a[j, i] < amin:
                        amin = a[j, i]
                    b[j, i] = amin
    else:
        b = np.empty((nr, nc), dtype='O')
        for i in range(nr):
            amin = MAX_CHAR
            for j in range(nc):
                if a[i, j] is None:
                    if amin == MAX_CHAR:
                        b[i, j] = None
                    else:
                        b[i, j] = amin 
                else:
                    if a[i, j] < amin:
                        amin = a[i, j]
                    b[i, j] = amin
    return b

def cumsum_float(ndarray[np.float64_t, ndim=2] a, axis, hasnans):
    cdef np.float64_t *arr = <np.float64_t*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.float64_t, ndim=2] total = np.zeros((nr, nc), dtype=np.float64)
    cdef double cur_total = 0

    if axis == 0:
        for i in range(nc):
            cur_total = 0
            for j in range(nr):
                if not isnan(arr[i * nr + j]):
                    cur_total += arr[i * nr + j]
                total[j, i] = cur_total
    else:
        for i in range(nr):
            cur_total = 0
            for j in range(nc):
                if not isnan(arr[j * nr + i]):
                    cur_total += arr[j * nr + i]
                total[i, j] = cur_total
    return total

def cumsum_int(ndarray[np.int64_t, ndim=2] a, axis, hasnans):
    cdef np.int64_t *arr = <np.int64_t*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.int64_t, ndim=2] total = np.empty((nr, nc), dtype=np.int64)
    cdef np.int64_t cur_total

    if axis == 0:
        for i in range(nc):
            cur_total = 0
            for j in range(nr):
                cur_total += arr[i * nr + j]
                total[j, i] = cur_total
    else:
        for i in range(nr):
            cur_total = 0
            for j in range(nc):
                cur_total += arr[j * nr + i]
                total[i, j] = cur_total
    return total

def cumsum_bool(ndarray[np.int8_t, ndim=2, cast=True] a, axis, hasnans):
    cdef np.int8_t *arr = <np.int8_t*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.int64_t, ndim=2] total = np.empty((nr, nc), dtype=np.int64)
    cdef np.int64_t cur_total

    if axis == 0:
        for i in range(nc):
            cur_total = 0
            for j in range(nr):
                cur_total += arr[i * nr + j]
                total[j, i] = cur_total
    else:
        for i in range(nr):
            cur_total = 0
            for j in range(nc):
                cur_total += arr[j * nr + i]
                total[i, j] = cur_total
    return total

def cumsum_str(ndarray[object, ndim=2] a, axis, hasnans):
    cdef int i, j, k
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef str cur_total
    cdef ndarray[object, ndim=2] total = np.full((nr, nc), nan, dtype='O')

    if axis == 0:
        for i in range(nc):
            k = 0
            while a[k, i] is None and k < nr - 1:
                total[k, i] = None
                k += 1
            if a[k, i] is not None:
                cur_total = a[k, i]
                total[k, i] = cur_total
            else:
                total[k, i] = None
            for j in range(k + 1, nr):
                try:
                    cur_total += a[j, i]
                except TypeError:
                    pass
                total[j, i] = cur_total
    else:
        for i in range(nr):
            k = 0
            while a[i, k] is None and k < nc - 1:
                total[i, k] = None
                k += 1
            if a[i, k] is not None:
                cur_total = a[i, k]
                total[i, k] = cur_total
            else:
                total[i, k] = None
            for j in range(k + 1, nc):
                try:
                    cur_total += a[i, j]
                except TypeError:
                    pass
                total[i, j] = cur_total
    return total


def cumprod_float(ndarray[np.float64_t, ndim=2] a, axis, hasnans):
    cdef np.float64_t *arr = <np.float64_t*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.float64_t, ndim=2] total = np.zeros((nr, nc), dtype=np.float64)
    cdef double cur_total = 0

    if axis == 0:
        for i in range(nc):
            cur_total = 1
            for j in range(nr):
                if not isnan(arr[i * nr + j]):
                    cur_total *= arr[i * nr + j]
                total[j, i] = cur_total
    else:
        for i in range(nr):
            cur_total = 1
            for j in range(nc):
                if not isnan(arr[j * nr + i]):
                    cur_total *= arr[j * nr + i]
                total[i, j] = cur_total
    return total

def cumprod_int(ndarray[np.int64_t, ndim=2] a, axis, hasnans):
    cdef np.int64_t *arr = <np.int64_t*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.int64_t, ndim=2] total = np.empty((nr, nc), dtype=np.int64)
    cdef np.int64_t cur_total

    if axis == 0:
        for i in range(nc):
            cur_total = 1
            for j in range(nr):
                cur_total *= arr[i * nr + j]
                total[j, i] = cur_total
    else:
        for i in range(nr):
            cur_total = 1
            for j in range(nc):
                cur_total *= arr[j * nr + i]
                total[i, j] = cur_total
    return total

def cumprod_bool(ndarray[np.int8_t, ndim=2, cast=True] a, axis, hasnans):
    cdef np.int8_t *arr = <np.int8_t*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.int64_t, ndim=2] total = np.empty((nr, nc), dtype=np.int64)
    cdef np.int64_t cur_total

    if axis == 0:
        for i in range(nc):
            cur_total = 1
            for j in range(nr):
                cur_total *= arr[i * nr + j]
                total[j, i] = cur_total
    else:
        for i in range(nr):
            cur_total = 1
            for j in range(nc):
                cur_total *= arr[j * nr + i]
                total[i, j] = cur_total
    return total

def isna_str(ndarray[object, ndim=2] a, ndarray[np.uint8_t, cast=True] hasnans):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.int8_t, cast=True, ndim=2] b = np.zeros((nr, nc), dtype='bool')
    for i in range(nc):
        if hasnans[i] is False:
            continue
        for j in range(nr):
            b[j, i] = a[j, i] is None
    return b

def isna_str_1d(ndarray[object] a):
    cdef int i
    cdef int n = a.shape[0]
    cdef ndarray[np.int8_t, cast=True] b = np.zeros(n, dtype='bool')
    for i in range(n):
        b[i] = a[i] is None
    return b

def isna_float(ndarray[np.float64_t, ndim=2] a, ndarray[np.uint8_t, cast=True] hasnans):
    # slower than numpy
    cdef np.float64_t *arr = <np.float64_t*> a.data
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef ndarray[np.int8_t, cast=True, ndim=2] b = np.zeros((nr, nc), dtype=bool)
    for i in range(nc):
        if hasnans[i] is False:
            continue
        for j in range(nr):
            b[j, i] = isnan(arr[i * nr + j])
    return b

def get_first_non_nan(ndarray[np.float64_t, ndim=2] a):
    cdef int i, j
    cdef int nr = a.shape[0]
    cdef int nc = a.shape[1]
    cdef ndarray[np.float64_t] result = np.full(nc, nan)

    for i in range(nc):
        for j in range(nr):
            if not isnan(a[j, i]):
                result[i] = a[j, i]
                break
    return result

def get_quantile_float(ndarray[np.float64_t] a, double percent):

    cdef double k = (len(a) - 1) * percent
    cdef int f, c
    cdef double d0, d1

    f = <int> floor(k)
    c = <int> ceil(k)
    if f == c:
        return a[f]
    d0 = a[f] * (c - k)
    d1 = a[c] * (k - f)
    return d0 + d1

def quantile_float(ndarray[np.float64_t, ndim=2] a, axis, double q, ndarray[np.uint8_t, cast=True] hasnans):
    cdef int i, n
    cdef ndarray[np.int64_t] count
    cdef ndarray[np.float64_t] b

    count = (~np.isnan(a)).sum(axis)
    if count.sum() == a.size:
        return np.percentile(a, q * 100, axis)

    a = np.sort(a, axis=axis)
    n = len(count)
    b = np.empty(n, dtype='float64')
    if axis == 0:
        for i in range(n):
            if count[i] == 0:
                b[i] = nan
            elif count[i] == 1:
                b[i] = a[0, i]
            else:
                b[i] = get_quantile_float(a[:count[i], i], q)
    else:
        for i in range(n):
            if count[i] == 0:
                b[i] = nan
            elif count[i] == 1:
                b[i] = a[i, 0]
            else:
                b[i] = get_quantile_float(a[i, :count[i]], q)

    return b

def quantile_int(ndarray[np.int64_t, ndim=2] a, axis, double q, ndarray[np.uint8_t, cast=True] hasnans):
    return np.percentile(a, q * 100, axis)

def quantile_bool(ndarray[np.uint8_t, ndim=2, cast=True] a, axis, double q, ndarray[np.uint8_t, cast=True] hasnans):
    return np.percentile(a, q * 100, axis)

# def fillna_float(ndarray[np.float64_t, ndim=2] a, int limit, np.float64_t value):
#     cdef i, j, k, ct
#     cdef nr = a.shape[0]
#     cdef nc = a.shape[1]
#     cdef ndarray[np.float64_t, ndim=2] a_new = np.empty((nr, nc), dtype='float64')
#
#     if limit == -1:
#         for i in range(nc):
#             for j in range(nr):
#                 if isnan(a[j, i]):
#                     a_new[j, i] = value
#                 else:
#                     a_new[j, i] = a[j, i]
#     else:
#         for i in range(nc):
#             ct = 0
#             for j in range(nr):
#                 if isnan(a[j, i]):
#                     a_new[j, i] = value
#                     ct += 1
#                 else:
#                     a_new[j, i] = a[j, i]
#                 if ct == limit:
#                     for k in range(j + 1, nr):
#                         a_new[k, i] = a[k, i]
#                     break
#     return a_new
#
# def fillna_str(ndarray[object, ndim=2] a, int limit, str value):
#     cdef i, j, k, ct
#     cdef nr = a.shape[0]
#     cdef nc = a.shape[1]
#     cdef ndarray[object, ndim=2] a_new = np.empty((nr, nc), dtype='O')
#
#     if limit == -1:
#         for i in range(nc):
#             for j in range(nr):
#                 if a[j, i] is None:
#                     a_new[j, i] = value
#                 else:
#                     a_new[j, i] = a[j, i]
#     else:
#         for i in range(nc):
#             ct = 0
#             for j in range(nr):
#                 if a[j, i] is None:
#                     a_new[j, i] = value
#                     ct += 1
#                 else:
#                     a_new[j, i] = a[j, i]
#                 if ct == limit:
#                     for k in range(j + 1, nr):
#                         a_new[k, i] = a[k, i]
#                     break
#     return a_new

def ffill_float(ndarray[np.float64_t, ndim=2] a, int limit):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef int ct = 0

    if limit == -1:
        for i in range(nc):
            for j in range(1, nr):
                if isnan(a[j, i]):
                    a[j, i] = a[j - 1, i]
    else:
        for i in range(nc):
            for j in range(1, nr):
                if isnan(a[j, i]):
                    if ct == limit:
                        continue
                    a[j, i] = a[j - 1, i]
                    ct += 1
                else:
                    ct = 0
    return a

def ffill_str(ndarray[object, ndim=2] a, int limit):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef int ct = 0
    if limit == -1:
        for i in range(nc):
            for j in range(1, nr):
                if a[j, i] is None:
                    a[j, i] = a[j - 1, i]
    else:
        for i in range(nc):
            for j in range(1, nr):
                if a[j, i] is None:
                    if ct == limit:
                        continue
                    a[j, i] = a[j - 1, i]
                    ct += 1
                else:
                    ct = 0
    return a

def bfill_float(ndarray[np.float64_t, ndim=2] a, int limit):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef int ct = 0

    if limit == -1:
        for i in range(nc):
            for j in range(nr - 2, -1, -1):
                if isnan(a[j, i]):
                    a[j, i] = a[j + 1, i]
    else:
        for i in range(nc):
            for j in range(nr - 2, -1, -1):
                if isnan(a[j, i]):
                    if ct == limit:
                        continue
                    a[j, i] = a[j + 1, i]
                    ct += 1
                else:
                    ct = 0
    return a

def bfill_str(ndarray[object, ndim=2] a, int limit):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef int ct = 0
    if limit == -1:
        for i in range(nc):
            for j in range(nr - 2, -1, -1):
                if a[j, i] is None:
                    a[j, i] = a[j + 1, i]
    else:
        for i in range(nc):
            for j in range(nr - 2, -1, -1):
                if a[j, i] is None:
                    if ct == limit:
                        continue
                    a[j, i] = a[j + 1, i]
                    ct += 1
                else:
                    ct = 0
    return a

def ffill_date(ndarray[np.int64_t, ndim=2] a, int limit, ndarray[np.uint8_t, cast=True, ndim=2] nans):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef int ct = 0

    if limit == -1:
        for i in range(nc):
            for j in range(1, nr):
                if nans[j, i]:
                    a[j, i] = a[j - 1, i]
    else:
        for i in range(nc):
            for j in range(1, nr):
                if nans[j, i]:
                    if ct == limit:
                        continue
                    a[j, i] = a[j - 1, i]
                    ct += 1
                else:
                    ct = 0
    return a

def bfill_date(ndarray[np.int64_t, ndim=2] a, int limit, ndarray[np.uint8_t, cast=True, ndim=2] nans):
    cdef int i, j
    cdef int nc = a.shape[1]
    cdef int nr = a.shape[0]
    cdef int ct = 0

    if limit == -1:
        for i in range(nc):
            for j in range(nr - 2, -1, -1):
                if nans[j, i]:
                    a[j, i] = a[j + 1, i]
    else:
        for i in range(nc):
            for j in range(nr - 2, -1, -1):
                if nans[j, i]:
                    if ct == limit:
                        continue
                    a[j, i] = a[j + 1, i]
                    ct += 1
                else:
                    ct = 0
    return a

def streak_int(ndarray[np.int64_t] a):
    cdef int i, n = len(a)
    cdef int count = 1
    cdef ndarray[np.int64_t] b = np.empty(n, dtype='int64')

    b[0] = 1

    for i in range(1, n):
        if a[i] == a[i - 1]:
            b[i] = count + 1
            count += 1
        else:
            count = 1
            b[i] = 1
    return b

def streak_float(ndarray[np.float64_t] a):
    cdef int i, n = len(a)
    cdef int count = 1
    cdef ndarray[np.int64_t] b = np.empty(n, dtype='int64')

    b[0] = 1

    for i in range(1, n):
        if a[i] == a[i - 1]:
            b[i] = count + 1
            count += 1
        else:
            count = 1
            b[i] = 1
    return b

def streak_bool(ndarray[np.uint8_t, cast=True] a):
    cdef int i, n = len(a)
    cdef int count = 1
    cdef ndarray[np.int64_t] b = np.empty(n, dtype='int64')

    b[0] = 1

    for i in range(1, n):
        if a[i] == a[i -1]:
            b[i] = count + 1
            count += 1
        else:
            count = 1
            b[i] = 1
    return b

def streak_str(ndarray[object] a):
    cdef int i, n = len(a)
    cdef int count = 1
    cdef ndarray[np.int64_t] b = np.empty(n, dtype='int64')

    b[0] = 1

    for i in range(1, n):
        if a[i] == a[i -1] and a[i] is not None:
            b[i] = count + 1
            count += 1
        else:
            count = 1
            b[i] = 1
    return b

def streak_date(ndarray[np.int64_t] a):
    cdef int i, n = len(a)
    cdef int count = 1
    cdef ndarray[np.int64_t] b = np.empty(n, dtype='int64')
    cdef np.int64_t nat = np.datetime64('nat').astype('int64')

    b[0] = 1

    for i in range(1, n):
        if a[i] == a[i - 1] and a[i] != nat:
            b[i] = count + 1
            count += 1
        else:
            count = 1
            b[i] = 1
    return b

def streak_value_int(ndarray[np.int64_t] a, long value):
    cdef int i, n = len(a)
    cdef int count = 0
    cdef ndarray[np.int64_t] b = np.empty(n, dtype='int64')

    for i in range(n):
        if a[i] == value:
            b[i] = count + 1
            count += 1
        else:
            count = 0
            b[i] = 0
    return b

def streak_value_float(ndarray[np.float64_t] a, float value):
    cdef int i, n = len(a)
    cdef int count = 0
    cdef ndarray[np.int64_t] b = np.empty(n, dtype='int64')

    for i in range(n):
        if a[i] == value:
            b[i] = count + 1
            count += 1
        else:
            count = 0
            b[i] = 0
    return b

def streak_value_bool(ndarray[np.uint8_t, cast=True] a, np.uint8_t value):
    cdef int i, n = len(a)
    cdef int count = 0
    cdef ndarray[np.int64_t] b = np.empty(n, dtype='int64')

    for i in range(n):
        if a[i] == value:
            b[i] = count + 1
            count += 1
        else:
            count = 0
            b[i] = 0
    return b

def streak_value_str(ndarray[object] a, str value):
    cdef int i, n = len(a)
    cdef int count = 0
    cdef ndarray[np.int64_t] b = np.empty(n, dtype='int64')

    for i in range(n):
        if a[i] == value:
            b[i] = count + 1
            count += 1
        else:
            count = 0
            b[i] = 0
    return b

def streak_group_int(ndarray[np.int64_t] a):
    cdef int i, n = len(a)
    cdef int count = 1
    cdef ndarray[np.int64_t] b = np.empty(n, dtype='int64')

    b[0] = 1

    for i in range(1, n):
        if a[i] == a[i -1]:
            b[i] = count
        else:
            count += 1
            b[i] = count
    return b

def streak_group_float(ndarray[np.float64_t] a):
    cdef int i, n = len(a)
    cdef int count = 1
    cdef ndarray[np.int64_t] b = np.empty(n, dtype='int64')

    b[0] = 1

    for i in range(1, n):
        if a[i] == a[i -1]:
            b[i] = count
        else:
            count += 1
            b[i] = count
    return b

def streak_group_bool(ndarray[np.uint8_t, cast=True] a):
    cdef int i, n = len(a)
    cdef int count = 1
    cdef ndarray[np.int64_t] b = np.empty(n, dtype='int64')

    b[0] = 1

    for i in range(1, n):
        if a[i] == a[i -1]:
            b[i] = count
        else:
            count += 1
            b[i] = count
    return b

def streak_group_str(ndarray[object] a):
    cdef int i, n = len(a)
    cdef int count = 1
    cdef ndarray[np.int64_t] b = np.empty(n, dtype='int64')

    b[0] = 1

    for i in range(1, n):
        if a[i] == a[i -1] and a[i] is not None:
            b[i] = count
        else:
            count += 1
            b[i] = count
    return b

def streak_group_date(ndarray[np.int64_t] a):
    cdef int i, n = len(a)
    cdef int count = 1
    cdef ndarray[np.int64_t] b = np.empty(n, dtype='int64')
    cdef np.int64_t nat = np.datetime64('nat').astype('int64')

    b[0] = 1

    for i in range(1, n):
        if a[i] == a[i -1] and a[i] != nat:
            b[i] = count
        else:
            count += 1
            b[i] = count
    return b

def quick_select_int(ndarray[np.int64_t] a, int k):
    cdef int i, n = len(a)
    cdef int ct1 = 0
    cdef int ct2 = 0

    cdef long r = np.random.randint(n)
    cdef long pivot = a[r]

    cdef ndarray[np.int64_t] a1 = np.empty(n, dtype='int64')
    cdef ndarray[np.int64_t] a2 = np.empty(n, dtype='int64')

    for i in range(len(a)):
        if a[i] < pivot:
            a1[ct1] = a[i]
            ct1 += 1
        elif a[i] > pivot:
            a2[ct2] = a[i]
            ct2 += 1

    if k <= ct1:
        return quick_select_int(a1[:ct1], k)
    elif k > len(a) - ct2:
        return quick_select_int(a2[:ct2], k - (len(a) - ct2))
    return pivot

def quick_select_float(ndarray[np.float64_t] a, int k):
    cdef int i, n = len(a)
    cdef int ct1 = 0
    cdef int ct2 = 0

    cdef int r = np.random.randint(n)
    cdef np.float64_t pivot = a[r]

    cdef ndarray[np.float64_t] a1 = np.empty(n, dtype='float64')
    cdef ndarray[np.float64_t] a2 = np.empty(n, dtype='float64')

    for i in range(len(a)):
        if a[i] < pivot:
            a1[ct1] = a[i]
            ct1 += 1
        elif a[i] > pivot:
            a2[ct2] = a[i]
            ct2 += 1

    if k <= ct1:
        return quick_select_float(a1[:ct1], k)
    elif k > len(a) - ct2:
        return quick_select_float(a2[:ct2], k - (len(a) - ct2))
    return pivot

def quick_select_str(ndarray[object] a, int k):
    cdef int i, n = len(a)
    cdef int ct1 = 0
    cdef int ct2 = 0

    cdef int r = np.random.randint(n)
    cdef str pivot = a[r]

    cdef ndarray[object] a1 = np.empty(n, dtype='O')
    cdef ndarray[object] a2 = np.empty(n, dtype='O')

    for i in range(len(a)):
        if a[i] < pivot:
            a1[ct1] = a[i]
            ct1 += 1
        elif a[i] > pivot:
            a2[ct2] = a[i]
            ct2 += 1

    if k <= ct1:
        return quick_select_str(a1[:ct1], k)
    elif k > len(a) - ct2:
        return quick_select_str(a2[:ct2], k - (len(a) - ct2))
    return pivot

def nlargest_int(ndarray[np.int64_t] a, n):
    cdef int i, j, k, prev, prev2
    cdef int prev_arg, prev_arg2
    cdef int nr = len(a)
    cdef ndarray[np.int64_t] topn_arg = np.argsort(-a[:n], kind='mergesort')
    cdef ndarray[np.int64_t] topn = a[topn_arg]
    cdef list ties = []
    cdef int n1 = n - 1

    for i in range(n, nr):
        if a[i] < topn[n1]:
            continue
        if a[i] == topn[n1]:
            ties.append(i)
            continue

        for j in range(n):
            if a[i] > topn[j]:
                prev = topn[j]
                prev_arg = topn_arg[j]

                topn[j] = a[i]
                topn_arg[j] = i
                for k in range(j + 1, n):
                    prev2 = topn[k]
                    prev2_arg = topn_arg[k]

                    topn[k] = prev
                    topn_arg[k] = prev_arg
                    prev = prev2
                    prev_arg = prev2_arg
                break

        if topn[n1] == prev:
            ties = [prev_arg] + ties
        else:
            ties = []

    return topn_arg, ties

# saves a bit of time when doing just first
# def nlargest_int_first(ndarray[np.int64_t] a, n):
#     cdef int i, j, k, prev, prev2
#     cdef int prev_arg, prev_arg2
#     cdef int nr = len(a)
#     cdef ndarray[np.int64_t] topn_arg = np.argsort(-a[:n], kind='mergesort')
#     cdef ndarray[np.int64_t] topn = a[topn_arg]
#     cdef int n1 = n - 1
#
#     for i in range(n, nr):
#         if a[i] <= topn[n1]:
#             continue
#
#         for j in range(n):
#             if a[i] > topn[j]:
#                 prev = topn[j]
#                 prev_arg = topn_arg[j]
#
#                 topn[j] = a[i]
#                 topn_arg[j] = i
#                 for k in range(j + 1, n):
#                     prev2 = topn[k]
#                     prev2_arg = topn_arg[k]
#
#                     topn[k] = prev
#                     topn_arg[k] = prev_arg
#                     prev = prev2
#                     prev_arg = prev2_arg
#                 break
#
#     return topn_arg

def nlargest_float(ndarray[np.float64_t] a, n):
    cdef int i, j, k, init_count = 0
    cdef float prev, prev2
    cdef int prev_arg, prev_arg2
    cdef int nr = len(a)
    cdef ndarray[np.int64_t] topn_arg = np.empty(n, dtype='int64')
    cdef ndarray[np.float64_t] topn = np.empty(n, dtype='float64')
    cdef list ties = []
    cdef list none_idx = []
    cdef int n1 = n - 1

    for i in range(nr):
        if isnan(a[i]):
            none_idx.append(i)
            continue
        topn[init_count] = a[i]
        topn_arg[init_count] = i
        init_count += 1
        if init_count == n:
            first_row = i + 1
            break

    if init_count < n:
        temp_arg = np.argsort(-topn[:init_count], kind='mergesort')
        temp_arg = topn_arg[temp_arg]
        if none_idx:
            return np.append(temp_arg, none_idx)[:n], []
        else:
            return temp_arg, []
    else:
        temp_arg = np.argsort(-topn, kind='mergesort')
        topn = topn[temp_arg]
        topn_arg = topn_arg[temp_arg]

    for i in range(first_row, nr):
        if a[i] < topn[n1] or isnan(a[i]):
            continue
        if a[i] == topn[n1]:
            ties.append(i)
            continue

        for j in range(n):
            if a[i] > topn[j]:
                prev = topn[j]
                prev_arg = topn_arg[j]

                topn[j] = a[i]
                topn_arg[j] = i
                for k in range(j + 1, n):
                    prev2 = topn[k]
                    prev2_arg = topn_arg[k]

                    topn[k] = prev
                    topn_arg[k] = prev_arg
                    prev = prev2
                    prev_arg = prev2_arg
                break

        if topn[n1] == prev:
            ties = [prev_arg] + ties
        else:
            ties = []

    return topn_arg, ties

def nlargest_str(ndarray[object] a, n):
    cdef int i, j, k, first_row, init_count = 0
    cdef str prev, prev2
    cdef int prev_arg, prev_arg2
    cdef int nr = len(a)
    cdef ndarray[np.int64_t] topn_arg = np.empty(n, dtype='int64')
    cdef ndarray[np.int64_t] temp_arg
    cdef ndarray[object] topn = np.empty(n, dtype='O')
    cdef list ties = []
    cdef list none_idx = []
    cdef int n1 = n - 1

    for i in range(nr):
        if a[i] is None:
            none_idx.append(i)
            continue
        topn[init_count] = a[i]
        topn_arg[init_count] = i
        init_count += 1
        if init_count == n:
            first_row = i + 1
            break

    if init_count < n:
        temp_arg = (init_count - 1 - np.argsort(topn[:init_count][::-1], kind='mergesort'))[::-1]
        temp_arg = topn_arg[temp_arg]
        if none_idx:
            return np.append(temp_arg, none_idx)[:n], []
        else:
            return temp_arg, []
    else:
        temp_arg = (n - 1 - np.argsort(topn[::-1], kind='mergesort'))[::-1]
        topn = topn[temp_arg]
        topn_arg = topn_arg[temp_arg]

    for i in range(first_row, nr):
        if a[i] is None or a[i] < topn[n1]:
            continue
        if a[i] == topn[n1]:
            ties.append(i)
            continue

        for j in range(n):
            if a[i] > topn[j]:
                prev = topn[j]
                prev_arg = topn_arg[j]

                topn[j] = a[i]
                topn_arg[j] = i
                for k in range(j + 1, n):
                    prev2 = topn[k]
                    prev2_arg = topn_arg[k]

                    topn[k] = prev
                    topn_arg[k] = prev_arg
                    prev = prev2
                    prev_arg = prev2_arg
                break

        if topn[n1] == prev:
            ties = [prev_arg] + ties
        else:
            ties = []

    return topn_arg, ties

def nlargest_bool(ndarray[np.uint8_t, cast=True] a, n):
    cdef int i, j, k, prev, prev2
    cdef int prev_arg, prev_arg2
    cdef int nr = len(a)
    cdef ndarray[np.int64_t] topn_arg = np.argsort(~a[:n], kind='mergesort')
    cdef ndarray[np.uint8_t, cast=True] topn = a[topn_arg]
    cdef list ties = []
    cdef int n1 = n - 1

    for i in range(n, nr):
        if a[i] < topn[n1]:
            continue
        if a[i] == topn[n1]:
            ties.append(i)
            continue

        for j in range(n):
            if a[i] > topn[j]:
                prev = topn[j]
                prev_arg = topn_arg[j]

                topn[j] = a[i]
                topn_arg[j] = i
                for k in range(j + 1, n):
                    prev2 = topn[k]
                    prev2_arg = topn_arg[k]

                    topn[k] = prev
                    topn_arg[k] = prev_arg
                    prev = prev2
                    prev_arg = prev2_arg
                break

        if topn[n1] == prev:
            ties = [prev_arg] + ties
        else:
            ties = []

    return topn_arg, ties

def nsmallest_int(ndarray[np.int64_t] a, n):
    cdef int i, j, k, prev, prev2
    cdef int prev_arg, prev_arg2
    cdef int nr = len(a)
    cdef ndarray[np.int64_t] topn_arg = np.argsort(a[:n], kind='mergesort')
    cdef ndarray[np.int64_t] topn = a[topn_arg]
    cdef list ties = []
    cdef int n1 = n - 1

    for i in range(n, nr):
        if a[i] > topn[n1]:
            continue
        if a[i] == topn[n1]:
            ties.append(i)
            continue

        for j in range(n):
            if a[i] < topn[j]:
                prev = topn[j]
                prev_arg = topn_arg[j]

                topn[j] = a[i]
                topn_arg[j] = i
                for k in range(j + 1, n):
                    prev2 = topn[k]
                    prev2_arg = topn_arg[k]

                    topn[k] = prev
                    topn_arg[k] = prev_arg
                    prev = prev2
                    prev_arg = prev2_arg
                break

        if topn[n1] == prev:
            ties.append(prev_arg)
        else:
            ties = []

    return topn_arg, ties

def nsmallest_float(ndarray[np.float64_t] a, n):
    cdef int i, j, k, init_count = 0
    cdef float prev, prev2
    cdef int prev_arg, prev_arg2
    cdef int nr = len(a)
    cdef ndarray[np.int64_t] topn_arg = np.empty(n, dtype='int64')
    cdef ndarray[np.float64_t] topn = np.empty(n, dtype='float64')
    cdef list ties = []
    cdef list none_idx = []
    cdef int n1 = n - 1

    for i in range(nr):
        if isnan(a[i]):
            none_idx.append(i)
            continue
        topn[init_count] = a[i]
        topn_arg[init_count] = i
        init_count += 1
        if init_count == n:
            first_row = i + 1
            break

    if init_count < n:
        temp_arg = np.argsort(topn[:init_count], kind='mergesort')
        temp_arg = topn_arg[temp_arg]
        if none_idx:
            return np.append(temp_arg, none_idx)[:n], []
        else:
            return temp_arg, []
    else:
        temp_arg = np.argsort(topn, kind='mergesort')
        topn = topn[temp_arg]
        topn_arg = topn_arg[temp_arg]

    for i in range(first_row, nr):
        if a[i] > topn[n1] or isnan(a[i]):
            continue
        if a[i] == topn[n1]:
            ties.append(i)
            continue

        for j in range(n):
            if a[i] < topn[j]:
                prev = topn[j]
                prev_arg = topn_arg[j]

                topn[j] = a[i]
                topn_arg[j] = i
                for k in range(j + 1, n):
                    prev2 = topn[k]
                    prev2_arg = topn_arg[k]

                    topn[k] = prev
                    topn_arg[k] = prev_arg
                    prev = prev2
                    prev_arg = prev2_arg
                break

        if topn[n1] == prev:
            ties = [prev_arg] + ties
        else:
            ties = []

    return topn_arg, ties

def nsmallest_str(ndarray[object] a, n):
    cdef int i, j, k, first_row, init_count = 0
    cdef str prev, prev2
    cdef int prev_arg, prev_arg2
    cdef int nr = len(a)
    cdef ndarray[np.int64_t] topn_arg = np.empty(n, dtype='int64')
    cdef ndarray[np.int64_t] temp_arg
    cdef ndarray[object] topn = np.empty(n, dtype='O')
    cdef list ties = []
    cdef list none_idx = []
    cdef int n1 = n - 1

    for i in range(nr):
        if a[i] is None:
            none_idx.append(i)
            continue
        topn[init_count] = a[i]
        topn_arg[init_count] = i
        init_count += 1
        if init_count == n:
            first_row = i + 1
            break

    if init_count < n:
        temp_arg = np.argsort(topn[:init_count], kind='mergesort')
        temp_arg = topn_arg[temp_arg]
        if none_idx:
            return np.append(temp_arg, none_idx)[:n], []
        else:
            return temp_arg, []
    else:
        temp_arg = np.argsort(topn[:init_count], kind='mergesort')
        topn = topn[temp_arg]
        topn_arg = topn_arg[temp_arg]

    for i in range(first_row, nr):
        if a[i] is None or a[i] > topn[n1]:
            continue
        if a[i] == topn[n1]:
            ties.append(i)
            continue

        for j in range(n):
            if a[i] < topn[j]:
                prev = topn[j]
                prev_arg = topn_arg[j]

                topn[j] = a[i]
                topn_arg[j] = i
                for k in range(j + 1, n):
                    prev2 = topn[k]
                    prev2_arg = topn_arg[k]

                    topn[k] = prev
                    topn_arg[k] = prev_arg
                    prev = prev2
                    prev_arg = prev2_arg
                break

        if topn[n1] == prev:
            ties = [prev_arg] + ties
        else:
            ties = []

    return topn_arg, ties

def nsmallest_bool(ndarray[np.uint8_t, cast=True] a, n):
    cdef int i, j, k, prev, prev2
    cdef int prev_arg, prev_arg2
    cdef int nr = len(a)
    cdef ndarray[np.int64_t] topn_arg = np.argsort(a[:n], kind='mergesort')
    cdef ndarray[np.uint8_t, cast=True] topn = a[topn_arg]
    cdef list ties = []
    cdef int n1 = n - 1

    for i in range(n, nr):
        if a[i] > topn[n1]:
            continue
        if a[i] == topn[n1]:
            ties.append(i)
            continue

        for j in range(n):
            if a[i] < topn[j]:
                prev = topn[j]
                prev_arg = topn_arg[j]

                topn[j] = a[i]
                topn_arg[j] = i
                for k in range(j + 1, n):
                    prev2 = topn[k]
                    prev2_arg = topn_arg[k]

                    topn[k] = prev
                    topn_arg[k] = prev_arg
                    prev = prev2
                    prev_arg = prev2_arg
                break

        if topn[n1] == prev:
            ties = [prev_arg] + ties
        else:
            ties = []

    return topn_arg, ties

def quick_select_int2(ndarray[np.int64_t] arr, int n, int k):
    # Credit: Ryan Tibshirani - http://www.stat.cmu.edu/~ryantibs/median/
    cdef:
        long i, ir, j, l, mid, a, temp

    l = 0
    ir = n - 1
    while True:
        if ir <= l + 1:
            if (ir == l + 1) and (arr[ir] < arr[l]):
                temp = arr[l]
                arr[l] = arr[ir]
                arr[ir] = temp
            return arr[k]
        else:
            mid = (l + ir) // 2

            temp = arr[mid]
            arr[mid] = arr[l + 1]
            arr[l + 1] = temp

            if arr[l] > arr[ir]:
                temp = arr[l]
                arr[l] = arr[ir]
                arr[ir] = temp

            if arr[l + 1] > arr[ir]:
                temp = arr[l + 1]
                arr[l + 1] = arr[ir]
                arr[ir] = temp

            if arr[l] > arr[l + 1]:
                temp = arr[l]
                arr[l] = arr[l + 1]
                arr[l + 1] = temp

            i = l+1
            j = ir

            a = arr[l+1]
            while True:
                i += 1
                while arr[i] < a:
                    i += 1

                j -= 1
                while arr[j] > a:
                    j -= 1

                if j < i:
                    break

                temp = arr[i]
                arr[i] = arr[j]
                arr[j] = temp

            arr[l + 1] = arr[j]
            arr[j] = a
            if j >= k:
                ir = j - 1
            if j <= k:
                l = i

def quick_select_float2(ndarray[np.float64_t] arr, int n, int k):
    # Credit: Ryan Tibshirani - http://www.stat.cmu.edu/~ryantibs/median/
    cdef:
        long i, ir, j, l, mid
        np.float64_t a, temp

    l = 0
    ir = n - 1
    while True:
        if ir <= l + 1:
            if (ir == l + 1) and (arr[ir] < arr[l]):
                temp = arr[l]
                arr[l] = arr[ir]
                arr[ir] = temp
            return arr[k]
        else:
            mid = (l + ir) // 2

            temp = arr[mid]
            arr[mid] = arr[l + 1]
            arr[l + 1] = temp

            if arr[l] > arr[ir]:
                temp = arr[l]
                arr[l] = arr[ir]
                arr[ir] = temp

            if arr[l + 1] > arr[ir]:
                temp = arr[l + 1]
                arr[l + 1] = arr[ir]
                arr[ir] = temp

            if arr[l] > arr[l + 1]:
                temp = arr[l]
                arr[l] = arr[l + 1]
                arr[l + 1] = temp

            i = l+1
            j = ir

            a = arr[l+1]
            while True:
                i += 1
                while arr[i] < a:
                    i += 1

                j -= 1
                while arr[j] > a:
                    j -= 1

                if j < i:
                    break

                temp = arr[i]
                arr[i] = arr[j]
                arr[j] = temp

            arr[l + 1] = arr[j]
            arr[j] = a
            if j >= k:
                ir = j - 1
            if j <= k:
                l = i

def copy(ndarray[np.float64_t] a):
    cdef:
        Py_ssize_t n = len(a), s = sizeof(np.float64_t) * n
        np.float64_t *arr = <np.float64_t*> a.data
        np.float64_t *arr2 = <np.float64_t *> malloc(s)

    memcpy(arr2, arr, s)
    try:
        return np.asarray(<np.float64_t[:n]> arr2)
    finally:
        free(arr2)