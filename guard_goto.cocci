//Ensure a strict lock and unlock order

@gt_lock_order@
expression list es;
position lp;
position up;
identifier virtual.lock;
identifier virtual.unlock;
@@
lock@lp(es);
... when strict
unlock@up(es);

@script:python@
up << gt_lock_order.up;
lp << gt_lock_order.lp;
@@
for i in range(len(up)):
    if int(lp[0].line) > int(up[i].line):
        cocci.include_match(False)
        break

@gt_lock_order_2@
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
p << gt_lock_order_2.p;
@@
if p:
   cocci.include_match(False)

@unbraced_if@
identifier lbl;
expression E1;
@@
if(E1)
+{
goto lbl;
+}

@goto_unlock exists@
expression list es;
identifier label;
position p;
position p1;
statement s;
identifier virtual.lock;
identifier virtual.unlock;
@@
lock@p1(es);
... when != unlock(es);
    goto label;
...
label:
(
    unlock(es);
|
    s@p 
)
@script:python@
p << goto_unlock.p;
@@
print(f"{p[0].file} --- {p[0].line} goto matched a statement")

@badr4 exists@
expression list es;
position p2;
position goto_unlock.p;
position goto_unlock.p1;
statement s;
identifier virtual.lock;
@@
lock@p1@p2(es);
...
s@p

@gt_early_unlock@
position p != badr4.p2;
position p3;
expression list es;
position goto_unlock.p1;
identifier label;
identifier virtual.lock;
identifier virtual.unlock;
@@
lock@p@p1(es);
... when != unlock(es);
    when exists
goto label;
...
unlock@p3(es);

@@
expression list es;
expression E;
position gt_early_unlock.p;
identifier lbl, lbl_2;
position px != gt_early_unlock.p3;
identifier virtual.lock;
identifier virtual.unlock;
identifier virtual.lock_type;
@@
-lock@p(es);
+scoped_guard(lock_type, es) {
<...
(
if(...) {
...
-goto lbl;
+ return;
...
-lbl:
-unlock(es);
-return;
}
|
if(...) {
...
-goto lbl;
+ return E;
...
-lbl:
-unlock(es);
-return E;
}
|
if(...){
...
-goto lbl;
+goto lbl_2; 
...
-lbl:
-unlock(es);
lbl_2:
...
return ...; 
}
|
if(...){
...
goto lbl;
...
-unlock(es);
...
return ...;
}
)
...>
-unlock@px(es);
+}

@@
identifier lbl;
expression list es;
identifier virtual.lock;
identifier virtual.unlock;
identifier virtual.lock_type;
@@
-lock(es);
+guard(lock_type)(es);
<... when != unlock(es);
-goto lbl;
+ return;
...>
-lbl:
- unlock(es);
-  return;

@@
identifier lbl;
expression list es;
expression E;
identifier virtual.lock;
identifier virtual.unlock;
identifier virtual.lock_type;
@@
-lock(es);
+guard(lock_type)(es);
<... when != unlock(es);
-goto lbl;
+ return E;
...>
-lbl:
- unlock(es);
  return E;

@clean_up@
expression unbraced_if.E1;
identifier unbraced_if.lbl;
@@
(
if(E1)
-{
goto lbl;
-}
|
if(E1)
-{
return ...;
-}
)
