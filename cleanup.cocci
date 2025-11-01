#include "guard_goto.cocci"
#include "scoped_guard.cocci"
//clean-up after transformation
@@
identifier I;
constant C;
statement S;
@@
(
if(...)
-{
-  I = C;
-  return I;
+ return C;
-}
|
if(...)
{
 S
- I = C;
- return I;
+ return C;
}
)

@last@
identifier virtual.lock_type;
expression E1; 
statement S;
identifier flags;
@@
(
 scoped_guard(lock_type, E1
-, flags
 ) S
|
 guard(lock_type)(E1
-, flags
 );
)

@@
identifier last.flags;
type T;
@@
-T flags;
... when != flags
    when strict
