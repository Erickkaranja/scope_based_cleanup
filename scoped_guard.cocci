#include "guard_goto.cocci"
#include "cleanup.cocci"

@sg_bad_break exists@
expression list es;
iterator I;
position p;
identifier virtual.lock;
identifier virtual.unlock;
@@
(
I(...){
  <...
  lock@p(es);
   ... when != unlock(es);
       when any
(
    {
       ...
       unlock(es);
       ... when any
       break;
    }
|

break;
)
   ...>
}

 
|

for(...; ...; ...){
   <...
   lock@p(es);
   ... when != unlock(es);
       when any
(
     {
       ...
       unlock(es);
       ... when any
       break;
     }
|

break;
)
   ...>
}

|

while(...) {
 <...
 lock@p(es);
 ... when != unlock(es);
     when any
(
    {
     ...
     unlock(es);
     ... when any
     break;
    }
|
break;
)
 ...>
}
)

@script:python@
p << sg_bad_break.p;
@@
print(f"Transformation of node at line:{p[0].line} file:{p[0].file} \
may lead to an unintended use of break statement")

@sg_unlock_at_else@
expression list es;
identifier virtual.lock;
identifier virtual.unlock;
position p;
statement S;
@@
lock@p(es);
... when any
    when != unlock(es); 
  if(...)
  S
  else {
  ...
  unlock(es);
  }
@script:python@
p << sg_unlock_at_else.p;
@@
print(f"{p[0].file}-- line:{p[0].line} cannot transform this node as unlock happens at an else condition")

@is_goto@
position pl;
identifier lbl;
statement S;
@@
goto lbl;@S@pl

@sg_bad_early_unlock exists@
expression list es;
position p;
position p1 != is_goto.pl;
statement S;
identifier virtual.lock;
identifier virtual.unlock;
@@
lock@p(es);
... when != unlock(es);
   if(...){
    ...
    unlock(es);
    S@p1
    ... when any
    return ...;
   }

@script:python@
p << sg_bad_early_unlock.p1;
@@
print(f"Bad early unlock due to statement on line: {p[0].line} -- file:{p[0].file}")

@sg_bad_early_unlock_2 exists@
expression list es; 
position p, p1;
statement S;
identifier virtual.lock;
identifier virtual.unlock;
@@
lock@p(es);
... when != unlock(es);
   if(...){
    ... 
    unlock(es);
    S@p1
    ... when any 
    continue;
   }

@script:python@
p << sg_bad_early_unlock_2.p1;
@@
print(f"Bad early unlock due to statement on line: {p[0].line} -- file: {p[0].file}")

@sg_initial_lock@
expression list es;
identifier virtual.lock;

@@
lock(es);


/*Ensure a strict lock and unlock order
  lock should always come before the unlock
*/

@lock_unlock_order@
expression list sg_initial_lock.es;
position lp != {sg_bad_break.p, sg_unlock_at_else.p, sg_bad_early_unlock.p,
                sg_bad_early_unlock_2.p};
position up;
identifier virtual.lock;
identifier virtual.unlock; 
@@
lock@lp(es);
... when strict
unlock@up(es);

@script:python@
up << lock_unlock_order.up;
lp << lock_unlock_order.lp;
@@
for i in range(len(up)):
    if int(lp[0].line) > int(up[i].line):
        cocci.include_match(False)
        break

@lock_unlock_order_2@
expression list es;
position p;
identifier virtual.lock;
identifier virtual.unlock;
@@
lock@p(es);
... when exists
    unlock(es);
...
lock(es);

@script:python@
p << lock_unlock_order_2.p;

@@
if p:
   cocci.include_match(False)

//Identify early unlock which will help
//isolate them from the last unlock

@sg_early_unlock@
expression list sg_initial_lock.es;
position p, lock_unlock_order.up;
identifier virtual.unlock;

@@
if(...) { ...unlock@p@up(es); ... return ...; }

@sg_early_unlock_2@
expression list sg_initial_lock.es;
position p, lock_unlock_order.up;
identifier virtual.unlock;

@@
if(...) { ...unlock@p@up(es); continue; }

@sg_early_unlock_3@
expression list sg_initial_lock.es;
position p, lock_unlock_order.up;
identifier label;
identifier virtual.unlock;

@@
if(...) { ...unlock@p@up(es);  goto label; }

@sg_early_unlock_4@
expression list sg_initial_lock.es;
position p, lock_unlock_order.up;
identifier virtual.unlock;
@@
switch(...) {
  case ...: {...}
  ...
  default:
  ...
  unlock@p@up(es);
  return ...;
}

@sg_early_unlock_5@
expression list sg_initial_lock.es;
position p, lock_unlock_order.up;
identifier virtual.unlock;
@@
if(...) {... unlock@p@up(es); break;}
/*
  Identify the last unlock position which
  should be different from the early_unlocks
*/

@sg_last_unlock@
expression list sg_initial_lock.es;
position p != {sg_early_unlock.p, sg_early_unlock_2.p,
               sg_early_unlock_3.p, sg_early_unlock_4.p,
              sg_early_unlock_5.p};
position lock_unlock_order.lp, lock_unlock_order.up;
identifier virtual.lock;
identifier virtual.unlock;

@@

lock@lp(es);
 ... 
unlock@up@p(es);

/*
  Transform lock/unlock order to 
  scoped_guard
*/

@s_g@
expression list sg_initial_lock.es;
position sg_last_unlock.p, lock_unlock_order.lp;
identifier label;
identifier virtual.lock;
identifier virtual.unlock;
identifier virtual.lock_type;
@@
+scoped_guard(lock_type, es) {
-lock@lp(es);
<...
(
   if(...)
-   {   
-    unlock(es); 
     return ...; 
-  }

|

   if(...) 
   { 
     ...
-    unlock(es);
     return ...; 
  }

|

   if(...)
-   {   
-    unlock(es);
     continue;
-   }

|
  if(...)
    {
     ...
-    unlock(es);
     continue;
    }

|

 if(...)
-   {
-    unlock(es);
     goto label;
-   }
|

  if(...)
    {
     ...
-    unlock(es);
     goto label;
    }
|
 switch(...) {
 case ...:
 ...
 default:
   ...
-  unlock(es);
 return ...;
 }
)   
  ...>
-unlock@p(es);
+}

/*
  Functions that span more than 20 lines
  should use scoped_guard even when guard
  use is appropriate
*/
@guard@
position p;

@@
...
scoped_guard@p(...){...}
@script:python@
p << guard.p;
@@
if (int(p[0].current_element_line_end) - int(p[0].current_element_line)) > 20:
   cocci.include_match(False)

//To avoid CLANG complain, avoid
//transforming scoped_guard to guard in 
//nodes with goto labels.

@bad_guard exists@
identifier f;
identifier lbl;
type t;
position p;
statement S;
@@
(
t f(...) {
  ... when any
  scoped_guard@p(...) S
  ... when any
}
&
t f(...) {
  ...
  goto lbl;
  ... when any
}
)


@scoped_guard_to_guard@
position p != bad_guard.p;
expression E;
expression list es;
@@
-scoped_guard@p(E, es) {
+ guard(E)(es);
 ...
-}
return ...;

//Remove extra braces around single statements 
@remove_braces@
expression E;
@@
scoped_guard(...)
-{
  E;
-}
