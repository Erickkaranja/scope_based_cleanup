# Makefile for running Coccinelle script against ~/git/kernels/linux

# Variables
COCCI_SCRIPT = ./cleanup.cocci
#consider passing SOURCE_DIR as env
SOURCE_DIR = ~/git/kernels/linux-next
SPATCH = spatch
SPATCH_FLAGS = --sp-file $(COCCI_SCRIPT) --dir $(SOURCE_DIR) --very-quiet

# Lock type configurations
LOCK_TYPES = mutex spinlock write_lock read_lock raw_spinlock_irqsave spinlock_irqsave \
	     spinlock_bh spinlock_irq rwsem_write rwsem_read \
	     raw_spinlock

# Default target
all: $(LOCK_TYPES)

# Rules for each lock type
mutex: 
	$(SPATCH) $(SPATCH_FLAGS) -D lock=mutex_lock -D unlock=mutex_unlock -D lock_type=mutex
spinlock:
	$(SPATCH) $(SPATCH_FLAGS) -D lock=spin_lock -D unlock=spin_unlock -D lock_type=spinlock
write_lock:
	$(SPATCH) $(SPATCH_FLAGS) -D lock=write_lock -D unlock=write_unlock -D lock_type=write_lock
read_lock:
	$(SPATCH) $(SPATCH_FLAGS) -D lock=read_lock -D unlock=read_unlock -D lock_type=read_lock
raw_spinlock_irqsave:
	$(SPATCH) $(SPATCH_FLAGS) -D lock=raw_spin_lock_irqsave -D unlock=raw_spin_unlock_irqrestore -D lock_type=raw_spinlock_irqsave
spinlock_irqsave:
	$(SPATCH) $(SPATCH_FLAGS) -D lock=spin_lock_irqsave -D unlock=spin_unlock_irqrestore -D lock_type=spinlock_irqsave
rcu:
	$(SPATCH) $(SPATCH_FLAGS) -D lock=rcu_read_lock -D unlock=rcu_read_unlock -D lock_type=rcu
spinlock_bh:
	$(SPATCH) $(SPATCH_FLAGS) -D lock=spin_lock_bh -D unlock=spin_unlock_bh -D lock_type=spinlock_bh
spinlock_irq:
	$(SPATCH) $(SPATCH_FLAGS) -D lock=spin_lock_irq -D unlock=spin_unlock_irq -D lock_type=spinlock_irq
rwsem_write:
	$(SPATCH) $(SPATCH_FLAGS) -D lock=down_write -D unlock=up_write -D lock_type=rwsem_write
rwsem_read:
	$(SPATCH) $(SPATCH_FLAGS) -D lock=down_read -D unlock=up_read -D lock_type=rwsem_read
raw_spinlock:
	$(SPATCH) $(SPATCH_FLAGS) -D lock=raw_spin_lock -D unlock=raw_spin_unlock -D lock_type=raw_spinlock
cpus_read_lock:
	$(SPATCH) $(SPATCH_FLAGS) -D lock=cpus_read_lock -D unlock=cpus_read_unlock -D lock_type=cpus_read_lock
