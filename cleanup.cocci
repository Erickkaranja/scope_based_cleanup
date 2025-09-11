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

expression E, E1; 
statement S;
identifier flags;

@@
(
 scoped_guard(E, E1
-, flags
 ) S

|

 guard(E)(E1
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

