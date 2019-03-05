/* sys_main.i */

// http://www.swig.org/Doc1.3/Python.html
// 31.9.1 Converting Python list to a char **

// ----------------------------------------------------------------------------

// This tells SWIG to treat char ** as a special case

%typemap(in) char ** {
  /* Check if is a list */
  if (PyList_Check($input)) {
    int size = PyList_Size($input);
    int i = 0;
    $1 = (char **) malloc((size+1)*sizeof(char *));
    for (i = 0; i < size; i++) {
      PyObject *o = PyList_GetItem($input,i);
      if (PyString_Check(o)) {
        $1[i] = PyString_AsString(PyList_GetItem($input,i));
      } else {
        PyErr_SetString(PyExc_TypeError,"list must contain strings");
        free($1);
        return NULL;
      }
    }
    $1[i] = 0;
  } else {
    PyErr_SetString(PyExc_TypeError,"not a list");
    return NULL;
  }
}

// This cleans up the char ** array we malloc'd before the function call
%typemap(freearg) char ** {
  free((char *) $1);
}

// Now a test function
%inline %{
int print_args(char **argv) {
    int i = 0;
    while (argv[i]) {
         printf("argv[%d] = %s\n", i,argv[i]);
         i++;
    }
    return i;
}
%}

// ----------------------------------------------------------------------------

%module sys_main

// event callback setup
%typemap(in) void (*f)(int, int, int, int) {
    $1 = (void (*)(int, int, int, int))PyInt_AsLong($input);;
}

%{
extern int pymain( int argc, char **argv );
extern void Py_SetEventCallback(void (*f)(int a, int b, int c, int d));
extern void Py_PushEventCallback(int a, int b, int c, int d);
%}

extern int pymain( int argc, char **argv );
extern void Py_SetEventCallback(void (*f)(int a, int b, int c, int d));
extern void Py_PushEventCallback(int a, int b, int c, int d);


%pythoncode
%{

import ctypes

# a ctypes callback prototype
py_callback_type = ctypes.CFUNCTYPE(None, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_int)

def Py_SetEventCallback(py_callback):

    # wrap the python callback with a ctypes function pointer
    f = py_callback_type(py_callback)

    # get the function pointer of the ctypes wrapper by casting it to void* and taking its value
    f_ptr = ctypes.cast(f, ctypes.c_void_p).value

    _sys_main.Py_SetEventCallback(f_ptr)

%}
