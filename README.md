# Scope based cleanup
## Introduction
This repository contains Coccinelle semantic patch
that transforms explicit lock/unlock patterns into a scope-based
cleanup style using guard macros.
## Prerequisites
Before running the script, you need to have Coccinelle installed on your system.
### Install Coccinelle
#### On Ubuntu/debian
```
sudo apt install coccinelle
```
#### On Fedora
```
sudo dnf install coccinelle
```
#### On Arch Linux
```
sudo pacman -S coccinelle
```
#### Verify installation
``` 
spatch --version
```
### How to Run the Script
#### Directly with Coccinelle
The top of file scoped_guard includes two file, guard_goto.cocci
and cleanup.cocci. The files should be run in this precedence.
```
spatch --sp-file path_to/scoped_guard.cocci [path_to_c_file] --very-quiet -D lock=[lock pattern] -D unlock=[unlock pattern] -D lock_type=[lock type]
```
##### Example of mutex transformation
```
spatch --sp-file ./scoped_guard.cocci file.c --very-quiet -D lock=mutex_lock -D unlock=mutex_unlock -D lock_type=mutex
```
#### Using the Makefile
To simplify running of the script one could use the provide Makefile.
Before running the make file please configure 
 1. COCCI_SCRIPT with the path to your coccinelle script
 2. SOURCE_DIR with path of your test c file

After making above configurations simply run:-
```
make [target]
```
##### Example for spinlock target
```
make spinlock
```
### References
For further understanding on the inner working of the script, please reffer
to the blog posts below:-
 1. https://erickkaranja1.wordpress.com/2025/06/08/smarter-resource-management-with-scoped_guard/
 2. https://erickkaranja1.wordpress.com/2025/07/02/from-mutex_lock-mutex_unlock-to-scoped_guard-part-2/
 3. https://erickkaranja1.wordpress.com/2025/08/07/from-lock-unlock-to-scoped_guard-part-3/
