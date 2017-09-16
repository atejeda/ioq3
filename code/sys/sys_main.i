/* sys_main.i */

%module sys_main
%{

/* headers files or declarations below */
extern int pymain( int argc, char **argv );

%}

extern int pymain( int argc, char **argv );
