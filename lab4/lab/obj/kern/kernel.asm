
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 e0 11 f0       	mov    $0xf011e000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5c 00 00 00       	call   f010009a <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 80 fe 22 f0 00 	cmpl   $0x0,0xf022fe80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 fe 22 f0    	mov    %esi,0xf022fe80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 25 5d 00 00       	call   f0105d86 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 20 64 10 f0       	push   $0xf0106420
f010006d:	e8 f0 36 00 00       	call   f0103762 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 c0 36 00 00       	call   f010373c <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 52 6c 10 f0 	movl   $0xf0106c52,(%esp)
f0100083:	e8 da 36 00 00       	call   f0103762 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 d5 07 00 00       	call   f010086a <monitor>
f0100095:	83 c4 10             	add    $0x10,%esp
f0100098:	eb f1                	jmp    f010008b <_panic+0x4b>

f010009a <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010009a:	55                   	push   %ebp
f010009b:	89 e5                	mov    %esp,%ebp
f010009d:	53                   	push   %ebx
f010009e:	83 ec 04             	sub    $0x4,%esp
	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000a1:	e8 82 05 00 00       	call   f0100628 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000a6:	83 ec 08             	sub    $0x8,%esp
f01000a9:	68 ac 1a 00 00       	push   $0x1aac
f01000ae:	68 8c 64 10 f0       	push   $0xf010648c
f01000b3:	e8 aa 36 00 00       	call   f0103762 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000b8:	e8 7e 11 00 00       	call   f010123b <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000bd:	e8 ca 2e 00 00       	call   f0102f8c <env_init>
	trap_init();
f01000c2:	e8 7f 37 00 00       	call   f0103846 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000c7:	e8 b0 59 00 00       	call   f0105a7c <mp_init>
	lapic_init();
f01000cc:	e8 d0 5c 00 00       	call   f0105da1 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000d1:	e8 b3 35 00 00       	call   f0103689 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000d6:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f01000dd:	e8 12 5f 00 00       	call   f0105ff4 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000e2:	83 c4 10             	add    $0x10,%esp
f01000e5:	83 3d 88 fe 22 f0 07 	cmpl   $0x7,0xf022fe88
f01000ec:	77 16                	ja     f0100104 <i386_init+0x6a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01000ee:	68 00 70 00 00       	push   $0x7000
f01000f3:	68 44 64 10 f0       	push   $0xf0106444
f01000f8:	6a 50                	push   $0x50
f01000fa:	68 a7 64 10 f0       	push   $0xf01064a7
f01000ff:	e8 3c ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100104:	83 ec 04             	sub    $0x4,%esp
f0100107:	b8 e2 59 10 f0       	mov    $0xf01059e2,%eax
f010010c:	2d 68 59 10 f0       	sub    $0xf0105968,%eax
f0100111:	50                   	push   %eax
f0100112:	68 68 59 10 f0       	push   $0xf0105968
f0100117:	68 00 70 00 f0       	push   $0xf0007000
f010011c:	e8 90 56 00 00       	call   f01057b1 <memmove>
f0100121:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100124:	bb 20 00 23 f0       	mov    $0xf0230020,%ebx
f0100129:	eb 4d                	jmp    f0100178 <i386_init+0xde>
		if (c == cpus + cpunum())  // We've started already.
f010012b:	e8 56 5c 00 00       	call   f0105d86 <cpunum>
f0100130:	6b c0 74             	imul   $0x74,%eax,%eax
f0100133:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0100138:	39 c3                	cmp    %eax,%ebx
f010013a:	74 39                	je     f0100175 <i386_init+0xdb>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010013c:	89 d8                	mov    %ebx,%eax
f010013e:	2d 20 00 23 f0       	sub    $0xf0230020,%eax
f0100143:	c1 f8 02             	sar    $0x2,%eax
f0100146:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010014c:	c1 e0 0f             	shl    $0xf,%eax
f010014f:	05 00 90 23 f0       	add    $0xf0239000,%eax
f0100154:	a3 84 fe 22 f0       	mov    %eax,0xf022fe84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100159:	83 ec 08             	sub    $0x8,%esp
f010015c:	68 00 70 00 00       	push   $0x7000
f0100161:	0f b6 03             	movzbl (%ebx),%eax
f0100164:	50                   	push   %eax
f0100165:	e8 85 5d 00 00       	call   f0105eef <lapic_startap>
f010016a:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f010016d:	8b 43 04             	mov    0x4(%ebx),%eax
f0100170:	83 f8 01             	cmp    $0x1,%eax
f0100173:	75 f8                	jne    f010016d <i386_init+0xd3>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100175:	83 c3 74             	add    $0x74,%ebx
f0100178:	6b 05 c4 03 23 f0 74 	imul   $0x74,0xf02303c4,%eax
f010017f:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0100184:	39 c3                	cmp    %eax,%ebx
f0100186:	72 a3                	jb     f010012b <i386_init+0x91>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100188:	83 ec 08             	sub    $0x8,%esp
f010018b:	6a 00                	push   $0x0
f010018d:	68 fc 4b 22 f0       	push   $0xf0224bfc
f0100192:	e8 c8 2f 00 00       	call   f010315f <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);

#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f0100197:	e8 c6 43 00 00       	call   f0104562 <sched_yield>

f010019c <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f010019c:	55                   	push   %ebp
f010019d:	89 e5                	mov    %esp,%ebp
f010019f:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001a2:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001a7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001ac:	77 12                	ja     f01001c0 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001ae:	50                   	push   %eax
f01001af:	68 68 64 10 f0       	push   $0xf0106468
f01001b4:	6a 67                	push   $0x67
f01001b6:	68 a7 64 10 f0       	push   $0xf01064a7
f01001bb:	e8 80 fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001c0:	05 00 00 00 10       	add    $0x10000000,%eax
f01001c5:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001c8:	e8 b9 5b 00 00       	call   f0105d86 <cpunum>
f01001cd:	83 ec 08             	sub    $0x8,%esp
f01001d0:	50                   	push   %eax
f01001d1:	68 b3 64 10 f0       	push   $0xf01064b3
f01001d6:	e8 87 35 00 00       	call   f0103762 <cprintf>

	lapic_init();
f01001db:	e8 c1 5b 00 00       	call   f0105da1 <lapic_init>
	env_init_percpu();
f01001e0:	e8 77 2d 00 00       	call   f0102f5c <env_init_percpu>
	trap_init_percpu();
f01001e5:	e8 8c 35 00 00       	call   f0103776 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001ea:	e8 97 5b 00 00       	call   f0105d86 <cpunum>
f01001ef:	6b d0 74             	imul   $0x74,%eax,%edx
f01001f2:	81 c2 20 00 23 f0    	add    $0xf0230020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01001f8:	b8 01 00 00 00       	mov    $0x1,%eax
f01001fd:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100201:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0100208:	e8 e7 5d 00 00       	call   f0105ff4 <spin_lock>
	//
	// Your code here:
	lock_kernel();
	// Remove this after you finish Exercise 6
	//for (;;);
	sched_yield();
f010020d:	e8 50 43 00 00       	call   f0104562 <sched_yield>

f0100212 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100212:	55                   	push   %ebp
f0100213:	89 e5                	mov    %esp,%ebp
f0100215:	53                   	push   %ebx
f0100216:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100219:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010021c:	ff 75 0c             	pushl  0xc(%ebp)
f010021f:	ff 75 08             	pushl  0x8(%ebp)
f0100222:	68 c9 64 10 f0       	push   $0xf01064c9
f0100227:	e8 36 35 00 00       	call   f0103762 <cprintf>
	vcprintf(fmt, ap);
f010022c:	83 c4 08             	add    $0x8,%esp
f010022f:	53                   	push   %ebx
f0100230:	ff 75 10             	pushl  0x10(%ebp)
f0100233:	e8 04 35 00 00       	call   f010373c <vcprintf>
	cprintf("\n");
f0100238:	c7 04 24 52 6c 10 f0 	movl   $0xf0106c52,(%esp)
f010023f:	e8 1e 35 00 00       	call   f0103762 <cprintf>
	va_end(ap);
}
f0100244:	83 c4 10             	add    $0x10,%esp
f0100247:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010024a:	c9                   	leave  
f010024b:	c3                   	ret    

f010024c <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010024c:	55                   	push   %ebp
f010024d:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010024f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100254:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100255:	a8 01                	test   $0x1,%al
f0100257:	74 0b                	je     f0100264 <serial_proc_data+0x18>
f0100259:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010025e:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010025f:	0f b6 c0             	movzbl %al,%eax
f0100262:	eb 05                	jmp    f0100269 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100264:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100269:	5d                   	pop    %ebp
f010026a:	c3                   	ret    

f010026b <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010026b:	55                   	push   %ebp
f010026c:	89 e5                	mov    %esp,%ebp
f010026e:	53                   	push   %ebx
f010026f:	83 ec 04             	sub    $0x4,%esp
f0100272:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100274:	eb 2b                	jmp    f01002a1 <cons_intr+0x36>
		if (c == 0)
f0100276:	85 c0                	test   %eax,%eax
f0100278:	74 27                	je     f01002a1 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010027a:	8b 0d 24 f2 22 f0    	mov    0xf022f224,%ecx
f0100280:	8d 51 01             	lea    0x1(%ecx),%edx
f0100283:	89 15 24 f2 22 f0    	mov    %edx,0xf022f224
f0100289:	88 81 20 f0 22 f0    	mov    %al,-0xfdd0fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010028f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100295:	75 0a                	jne    f01002a1 <cons_intr+0x36>
			cons.wpos = 0;
f0100297:	c7 05 24 f2 22 f0 00 	movl   $0x0,0xf022f224
f010029e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002a1:	ff d3                	call   *%ebx
f01002a3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002a6:	75 ce                	jne    f0100276 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002a8:	83 c4 04             	add    $0x4,%esp
f01002ab:	5b                   	pop    %ebx
f01002ac:	5d                   	pop    %ebp
f01002ad:	c3                   	ret    

f01002ae <kbd_proc_data>:
f01002ae:	ba 64 00 00 00       	mov    $0x64,%edx
f01002b3:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01002b4:	a8 01                	test   $0x1,%al
f01002b6:	0f 84 f8 00 00 00    	je     f01003b4 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01002bc:	a8 20                	test   $0x20,%al
f01002be:	0f 85 f6 00 00 00    	jne    f01003ba <kbd_proc_data+0x10c>
f01002c4:	ba 60 00 00 00       	mov    $0x60,%edx
f01002c9:	ec                   	in     (%dx),%al
f01002ca:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002cc:	3c e0                	cmp    $0xe0,%al
f01002ce:	75 0d                	jne    f01002dd <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01002d0:	83 0d 00 f0 22 f0 40 	orl    $0x40,0xf022f000
		return 0;
f01002d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01002dc:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01002dd:	55                   	push   %ebp
f01002de:	89 e5                	mov    %esp,%ebp
f01002e0:	53                   	push   %ebx
f01002e1:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01002e4:	84 c0                	test   %al,%al
f01002e6:	79 36                	jns    f010031e <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01002e8:	8b 0d 00 f0 22 f0    	mov    0xf022f000,%ecx
f01002ee:	89 cb                	mov    %ecx,%ebx
f01002f0:	83 e3 40             	and    $0x40,%ebx
f01002f3:	83 e0 7f             	and    $0x7f,%eax
f01002f6:	85 db                	test   %ebx,%ebx
f01002f8:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002fb:	0f b6 d2             	movzbl %dl,%edx
f01002fe:	0f b6 82 40 66 10 f0 	movzbl -0xfef99c0(%edx),%eax
f0100305:	83 c8 40             	or     $0x40,%eax
f0100308:	0f b6 c0             	movzbl %al,%eax
f010030b:	f7 d0                	not    %eax
f010030d:	21 c8                	and    %ecx,%eax
f010030f:	a3 00 f0 22 f0       	mov    %eax,0xf022f000
		return 0;
f0100314:	b8 00 00 00 00       	mov    $0x0,%eax
f0100319:	e9 a4 00 00 00       	jmp    f01003c2 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f010031e:	8b 0d 00 f0 22 f0    	mov    0xf022f000,%ecx
f0100324:	f6 c1 40             	test   $0x40,%cl
f0100327:	74 0e                	je     f0100337 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100329:	83 c8 80             	or     $0xffffff80,%eax
f010032c:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010032e:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100331:	89 0d 00 f0 22 f0    	mov    %ecx,0xf022f000
	}

	shift |= shiftcode[data];
f0100337:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010033a:	0f b6 82 40 66 10 f0 	movzbl -0xfef99c0(%edx),%eax
f0100341:	0b 05 00 f0 22 f0    	or     0xf022f000,%eax
f0100347:	0f b6 8a 40 65 10 f0 	movzbl -0xfef9ac0(%edx),%ecx
f010034e:	31 c8                	xor    %ecx,%eax
f0100350:	a3 00 f0 22 f0       	mov    %eax,0xf022f000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100355:	89 c1                	mov    %eax,%ecx
f0100357:	83 e1 03             	and    $0x3,%ecx
f010035a:	8b 0c 8d 20 65 10 f0 	mov    -0xfef9ae0(,%ecx,4),%ecx
f0100361:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100365:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100368:	a8 08                	test   $0x8,%al
f010036a:	74 1b                	je     f0100387 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f010036c:	89 da                	mov    %ebx,%edx
f010036e:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100371:	83 f9 19             	cmp    $0x19,%ecx
f0100374:	77 05                	ja     f010037b <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f0100376:	83 eb 20             	sub    $0x20,%ebx
f0100379:	eb 0c                	jmp    f0100387 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f010037b:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010037e:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100381:	83 fa 19             	cmp    $0x19,%edx
f0100384:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100387:	f7 d0                	not    %eax
f0100389:	a8 06                	test   $0x6,%al
f010038b:	75 33                	jne    f01003c0 <kbd_proc_data+0x112>
f010038d:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100393:	75 2b                	jne    f01003c0 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f0100395:	83 ec 0c             	sub    $0xc,%esp
f0100398:	68 e3 64 10 f0       	push   $0xf01064e3
f010039d:	e8 c0 33 00 00       	call   f0103762 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003a2:	ba 92 00 00 00       	mov    $0x92,%edx
f01003a7:	b8 03 00 00 00       	mov    $0x3,%eax
f01003ac:	ee                   	out    %al,(%dx)
f01003ad:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003b0:	89 d8                	mov    %ebx,%eax
f01003b2:	eb 0e                	jmp    f01003c2 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01003b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01003b9:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01003ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003bf:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003c0:	89 d8                	mov    %ebx,%eax
}
f01003c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003c5:	c9                   	leave  
f01003c6:	c3                   	ret    

f01003c7 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003c7:	55                   	push   %ebp
f01003c8:	89 e5                	mov    %esp,%ebp
f01003ca:	57                   	push   %edi
f01003cb:	56                   	push   %esi
f01003cc:	53                   	push   %ebx
f01003cd:	83 ec 1c             	sub    $0x1c,%esp
f01003d0:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003d2:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003d7:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003dc:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003e1:	eb 09                	jmp    f01003ec <cons_putc+0x25>
f01003e3:	89 ca                	mov    %ecx,%edx
f01003e5:	ec                   	in     (%dx),%al
f01003e6:	ec                   	in     (%dx),%al
f01003e7:	ec                   	in     (%dx),%al
f01003e8:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01003e9:	83 c3 01             	add    $0x1,%ebx
f01003ec:	89 f2                	mov    %esi,%edx
f01003ee:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003ef:	a8 20                	test   $0x20,%al
f01003f1:	75 08                	jne    f01003fb <cons_putc+0x34>
f01003f3:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01003f9:	7e e8                	jle    f01003e3 <cons_putc+0x1c>
f01003fb:	89 f8                	mov    %edi,%eax
f01003fd:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100400:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100405:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100406:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010040b:	be 79 03 00 00       	mov    $0x379,%esi
f0100410:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100415:	eb 09                	jmp    f0100420 <cons_putc+0x59>
f0100417:	89 ca                	mov    %ecx,%edx
f0100419:	ec                   	in     (%dx),%al
f010041a:	ec                   	in     (%dx),%al
f010041b:	ec                   	in     (%dx),%al
f010041c:	ec                   	in     (%dx),%al
f010041d:	83 c3 01             	add    $0x1,%ebx
f0100420:	89 f2                	mov    %esi,%edx
f0100422:	ec                   	in     (%dx),%al
f0100423:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100429:	7f 04                	jg     f010042f <cons_putc+0x68>
f010042b:	84 c0                	test   %al,%al
f010042d:	79 e8                	jns    f0100417 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010042f:	ba 78 03 00 00       	mov    $0x378,%edx
f0100434:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100438:	ee                   	out    %al,(%dx)
f0100439:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010043e:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100443:	ee                   	out    %al,(%dx)
f0100444:	b8 08 00 00 00       	mov    $0x8,%eax
f0100449:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010044a:	89 fa                	mov    %edi,%edx
f010044c:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100452:	89 f8                	mov    %edi,%eax
f0100454:	80 cc 07             	or     $0x7,%ah
f0100457:	85 d2                	test   %edx,%edx
f0100459:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010045c:	89 f8                	mov    %edi,%eax
f010045e:	0f b6 c0             	movzbl %al,%eax
f0100461:	83 f8 09             	cmp    $0x9,%eax
f0100464:	74 74                	je     f01004da <cons_putc+0x113>
f0100466:	83 f8 09             	cmp    $0x9,%eax
f0100469:	7f 0a                	jg     f0100475 <cons_putc+0xae>
f010046b:	83 f8 08             	cmp    $0x8,%eax
f010046e:	74 14                	je     f0100484 <cons_putc+0xbd>
f0100470:	e9 99 00 00 00       	jmp    f010050e <cons_putc+0x147>
f0100475:	83 f8 0a             	cmp    $0xa,%eax
f0100478:	74 3a                	je     f01004b4 <cons_putc+0xed>
f010047a:	83 f8 0d             	cmp    $0xd,%eax
f010047d:	74 3d                	je     f01004bc <cons_putc+0xf5>
f010047f:	e9 8a 00 00 00       	jmp    f010050e <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100484:	0f b7 05 28 f2 22 f0 	movzwl 0xf022f228,%eax
f010048b:	66 85 c0             	test   %ax,%ax
f010048e:	0f 84 e6 00 00 00    	je     f010057a <cons_putc+0x1b3>
			crt_pos--;
f0100494:	83 e8 01             	sub    $0x1,%eax
f0100497:	66 a3 28 f2 22 f0    	mov    %ax,0xf022f228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010049d:	0f b7 c0             	movzwl %ax,%eax
f01004a0:	66 81 e7 00 ff       	and    $0xff00,%di
f01004a5:	83 cf 20             	or     $0x20,%edi
f01004a8:	8b 15 2c f2 22 f0    	mov    0xf022f22c,%edx
f01004ae:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004b2:	eb 78                	jmp    f010052c <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004b4:	66 83 05 28 f2 22 f0 	addw   $0x50,0xf022f228
f01004bb:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004bc:	0f b7 05 28 f2 22 f0 	movzwl 0xf022f228,%eax
f01004c3:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004c9:	c1 e8 16             	shr    $0x16,%eax
f01004cc:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004cf:	c1 e0 04             	shl    $0x4,%eax
f01004d2:	66 a3 28 f2 22 f0    	mov    %ax,0xf022f228
f01004d8:	eb 52                	jmp    f010052c <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01004da:	b8 20 00 00 00       	mov    $0x20,%eax
f01004df:	e8 e3 fe ff ff       	call   f01003c7 <cons_putc>
		cons_putc(' ');
f01004e4:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e9:	e8 d9 fe ff ff       	call   f01003c7 <cons_putc>
		cons_putc(' ');
f01004ee:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f3:	e8 cf fe ff ff       	call   f01003c7 <cons_putc>
		cons_putc(' ');
f01004f8:	b8 20 00 00 00       	mov    $0x20,%eax
f01004fd:	e8 c5 fe ff ff       	call   f01003c7 <cons_putc>
		cons_putc(' ');
f0100502:	b8 20 00 00 00       	mov    $0x20,%eax
f0100507:	e8 bb fe ff ff       	call   f01003c7 <cons_putc>
f010050c:	eb 1e                	jmp    f010052c <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010050e:	0f b7 05 28 f2 22 f0 	movzwl 0xf022f228,%eax
f0100515:	8d 50 01             	lea    0x1(%eax),%edx
f0100518:	66 89 15 28 f2 22 f0 	mov    %dx,0xf022f228
f010051f:	0f b7 c0             	movzwl %ax,%eax
f0100522:	8b 15 2c f2 22 f0    	mov    0xf022f22c,%edx
f0100528:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010052c:	66 81 3d 28 f2 22 f0 	cmpw   $0x7cf,0xf022f228
f0100533:	cf 07 
f0100535:	76 43                	jbe    f010057a <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100537:	a1 2c f2 22 f0       	mov    0xf022f22c,%eax
f010053c:	83 ec 04             	sub    $0x4,%esp
f010053f:	68 00 0f 00 00       	push   $0xf00
f0100544:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010054a:	52                   	push   %edx
f010054b:	50                   	push   %eax
f010054c:	e8 60 52 00 00       	call   f01057b1 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100551:	8b 15 2c f2 22 f0    	mov    0xf022f22c,%edx
f0100557:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010055d:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100563:	83 c4 10             	add    $0x10,%esp
f0100566:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010056b:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010056e:	39 d0                	cmp    %edx,%eax
f0100570:	75 f4                	jne    f0100566 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100572:	66 83 2d 28 f2 22 f0 	subw   $0x50,0xf022f228
f0100579:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010057a:	8b 0d 30 f2 22 f0    	mov    0xf022f230,%ecx
f0100580:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100585:	89 ca                	mov    %ecx,%edx
f0100587:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100588:	0f b7 1d 28 f2 22 f0 	movzwl 0xf022f228,%ebx
f010058f:	8d 71 01             	lea    0x1(%ecx),%esi
f0100592:	89 d8                	mov    %ebx,%eax
f0100594:	66 c1 e8 08          	shr    $0x8,%ax
f0100598:	89 f2                	mov    %esi,%edx
f010059a:	ee                   	out    %al,(%dx)
f010059b:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005a0:	89 ca                	mov    %ecx,%edx
f01005a2:	ee                   	out    %al,(%dx)
f01005a3:	89 d8                	mov    %ebx,%eax
f01005a5:	89 f2                	mov    %esi,%edx
f01005a7:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005ab:	5b                   	pop    %ebx
f01005ac:	5e                   	pop    %esi
f01005ad:	5f                   	pop    %edi
f01005ae:	5d                   	pop    %ebp
f01005af:	c3                   	ret    

f01005b0 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005b0:	80 3d 34 f2 22 f0 00 	cmpb   $0x0,0xf022f234
f01005b7:	74 11                	je     f01005ca <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005b9:	55                   	push   %ebp
f01005ba:	89 e5                	mov    %esp,%ebp
f01005bc:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005bf:	b8 4c 02 10 f0       	mov    $0xf010024c,%eax
f01005c4:	e8 a2 fc ff ff       	call   f010026b <cons_intr>
}
f01005c9:	c9                   	leave  
f01005ca:	f3 c3                	repz ret 

f01005cc <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005cc:	55                   	push   %ebp
f01005cd:	89 e5                	mov    %esp,%ebp
f01005cf:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005d2:	b8 ae 02 10 f0       	mov    $0xf01002ae,%eax
f01005d7:	e8 8f fc ff ff       	call   f010026b <cons_intr>
}
f01005dc:	c9                   	leave  
f01005dd:	c3                   	ret    

f01005de <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005de:	55                   	push   %ebp
f01005df:	89 e5                	mov    %esp,%ebp
f01005e1:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005e4:	e8 c7 ff ff ff       	call   f01005b0 <serial_intr>
	kbd_intr();
f01005e9:	e8 de ff ff ff       	call   f01005cc <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01005ee:	a1 20 f2 22 f0       	mov    0xf022f220,%eax
f01005f3:	3b 05 24 f2 22 f0    	cmp    0xf022f224,%eax
f01005f9:	74 26                	je     f0100621 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01005fb:	8d 50 01             	lea    0x1(%eax),%edx
f01005fe:	89 15 20 f2 22 f0    	mov    %edx,0xf022f220
f0100604:	0f b6 88 20 f0 22 f0 	movzbl -0xfdd0fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f010060b:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f010060d:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100613:	75 11                	jne    f0100626 <cons_getc+0x48>
			cons.rpos = 0;
f0100615:	c7 05 20 f2 22 f0 00 	movl   $0x0,0xf022f220
f010061c:	00 00 00 
f010061f:	eb 05                	jmp    f0100626 <cons_getc+0x48>
		return c;
	}
	return 0;
f0100621:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100626:	c9                   	leave  
f0100627:	c3                   	ret    

f0100628 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100628:	55                   	push   %ebp
f0100629:	89 e5                	mov    %esp,%ebp
f010062b:	57                   	push   %edi
f010062c:	56                   	push   %esi
f010062d:	53                   	push   %ebx
f010062e:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100631:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100638:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010063f:	5a a5 
	if (*cp != 0xA55A) {
f0100641:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100648:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010064c:	74 11                	je     f010065f <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010064e:	c7 05 30 f2 22 f0 b4 	movl   $0x3b4,0xf022f230
f0100655:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100658:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010065d:	eb 16                	jmp    f0100675 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010065f:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100666:	c7 05 30 f2 22 f0 d4 	movl   $0x3d4,0xf022f230
f010066d:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100670:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100675:	8b 3d 30 f2 22 f0    	mov    0xf022f230,%edi
f010067b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100680:	89 fa                	mov    %edi,%edx
f0100682:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100683:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100686:	89 da                	mov    %ebx,%edx
f0100688:	ec                   	in     (%dx),%al
f0100689:	0f b6 c8             	movzbl %al,%ecx
f010068c:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010068f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100694:	89 fa                	mov    %edi,%edx
f0100696:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100697:	89 da                	mov    %ebx,%edx
f0100699:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010069a:	89 35 2c f2 22 f0    	mov    %esi,0xf022f22c
	crt_pos = pos;
f01006a0:	0f b6 c0             	movzbl %al,%eax
f01006a3:	09 c8                	or     %ecx,%eax
f01006a5:	66 a3 28 f2 22 f0    	mov    %ax,0xf022f228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006ab:	e8 1c ff ff ff       	call   f01005cc <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006b0:	83 ec 0c             	sub    $0xc,%esp
f01006b3:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f01006ba:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006bf:	50                   	push   %eax
f01006c0:	e8 4c 2f 00 00       	call   f0103611 <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006c5:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006ca:	b8 00 00 00 00       	mov    $0x0,%eax
f01006cf:	89 f2                	mov    %esi,%edx
f01006d1:	ee                   	out    %al,(%dx)
f01006d2:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006d7:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006dc:	ee                   	out    %al,(%dx)
f01006dd:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01006e2:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006e7:	89 da                	mov    %ebx,%edx
f01006e9:	ee                   	out    %al,(%dx)
f01006ea:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01006ef:	b8 00 00 00 00       	mov    $0x0,%eax
f01006f4:	ee                   	out    %al,(%dx)
f01006f5:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006fa:	b8 03 00 00 00       	mov    $0x3,%eax
f01006ff:	ee                   	out    %al,(%dx)
f0100700:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100705:	b8 00 00 00 00       	mov    $0x0,%eax
f010070a:	ee                   	out    %al,(%dx)
f010070b:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100710:	b8 01 00 00 00       	mov    $0x1,%eax
f0100715:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100716:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010071b:	ec                   	in     (%dx),%al
f010071c:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010071e:	83 c4 10             	add    $0x10,%esp
f0100721:	3c ff                	cmp    $0xff,%al
f0100723:	0f 95 05 34 f2 22 f0 	setne  0xf022f234
f010072a:	89 f2                	mov    %esi,%edx
f010072c:	ec                   	in     (%dx),%al
f010072d:	89 da                	mov    %ebx,%edx
f010072f:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100730:	80 f9 ff             	cmp    $0xff,%cl
f0100733:	75 10                	jne    f0100745 <cons_init+0x11d>
		cprintf("Serial port does not exist!\n");
f0100735:	83 ec 0c             	sub    $0xc,%esp
f0100738:	68 ef 64 10 f0       	push   $0xf01064ef
f010073d:	e8 20 30 00 00       	call   f0103762 <cprintf>
f0100742:	83 c4 10             	add    $0x10,%esp
}
f0100745:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100748:	5b                   	pop    %ebx
f0100749:	5e                   	pop    %esi
f010074a:	5f                   	pop    %edi
f010074b:	5d                   	pop    %ebp
f010074c:	c3                   	ret    

f010074d <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010074d:	55                   	push   %ebp
f010074e:	89 e5                	mov    %esp,%ebp
f0100750:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100753:	8b 45 08             	mov    0x8(%ebp),%eax
f0100756:	e8 6c fc ff ff       	call   f01003c7 <cons_putc>
}
f010075b:	c9                   	leave  
f010075c:	c3                   	ret    

f010075d <getchar>:

int
getchar(void)
{
f010075d:	55                   	push   %ebp
f010075e:	89 e5                	mov    %esp,%ebp
f0100760:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100763:	e8 76 fe ff ff       	call   f01005de <cons_getc>
f0100768:	85 c0                	test   %eax,%eax
f010076a:	74 f7                	je     f0100763 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010076c:	c9                   	leave  
f010076d:	c3                   	ret    

f010076e <iscons>:

int
iscons(int fdnum)
{
f010076e:	55                   	push   %ebp
f010076f:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100771:	b8 01 00 00 00       	mov    $0x1,%eax
f0100776:	5d                   	pop    %ebp
f0100777:	c3                   	ret    

f0100778 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100778:	55                   	push   %ebp
f0100779:	89 e5                	mov    %esp,%ebp
f010077b:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010077e:	68 40 67 10 f0       	push   $0xf0106740
f0100783:	68 5e 67 10 f0       	push   $0xf010675e
f0100788:	68 63 67 10 f0       	push   $0xf0106763
f010078d:	e8 d0 2f 00 00       	call   f0103762 <cprintf>
f0100792:	83 c4 0c             	add    $0xc,%esp
f0100795:	68 cc 67 10 f0       	push   $0xf01067cc
f010079a:	68 6c 67 10 f0       	push   $0xf010676c
f010079f:	68 63 67 10 f0       	push   $0xf0106763
f01007a4:	e8 b9 2f 00 00       	call   f0103762 <cprintf>
	return 0;
}
f01007a9:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ae:	c9                   	leave  
f01007af:	c3                   	ret    

f01007b0 <mon_kerninfo>:


int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007b0:	55                   	push   %ebp
f01007b1:	89 e5                	mov    %esp,%ebp
f01007b3:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007b6:	68 75 67 10 f0       	push   $0xf0106775
f01007bb:	e8 a2 2f 00 00       	call   f0103762 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007c0:	83 c4 08             	add    $0x8,%esp
f01007c3:	68 0c 00 10 00       	push   $0x10000c
f01007c8:	68 f4 67 10 f0       	push   $0xf01067f4
f01007cd:	e8 90 2f 00 00       	call   f0103762 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007d2:	83 c4 0c             	add    $0xc,%esp
f01007d5:	68 0c 00 10 00       	push   $0x10000c
f01007da:	68 0c 00 10 f0       	push   $0xf010000c
f01007df:	68 1c 68 10 f0       	push   $0xf010681c
f01007e4:	e8 79 2f 00 00       	call   f0103762 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007e9:	83 c4 0c             	add    $0xc,%esp
f01007ec:	68 01 64 10 00       	push   $0x106401
f01007f1:	68 01 64 10 f0       	push   $0xf0106401
f01007f6:	68 40 68 10 f0       	push   $0xf0106840
f01007fb:	e8 62 2f 00 00       	call   f0103762 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100800:	83 c4 0c             	add    $0xc,%esp
f0100803:	68 00 f0 22 00       	push   $0x22f000
f0100808:	68 00 f0 22 f0       	push   $0xf022f000
f010080d:	68 64 68 10 f0       	push   $0xf0106864
f0100812:	e8 4b 2f 00 00       	call   f0103762 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100817:	83 c4 0c             	add    $0xc,%esp
f010081a:	68 08 10 27 00       	push   $0x271008
f010081f:	68 08 10 27 f0       	push   $0xf0271008
f0100824:	68 88 68 10 f0       	push   $0xf0106888
f0100829:	e8 34 2f 00 00       	call   f0103762 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010082e:	b8 07 14 27 f0       	mov    $0xf0271407,%eax
f0100833:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100838:	83 c4 08             	add    $0x8,%esp
f010083b:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100840:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100846:	85 c0                	test   %eax,%eax
f0100848:	0f 48 c2             	cmovs  %edx,%eax
f010084b:	c1 f8 0a             	sar    $0xa,%eax
f010084e:	50                   	push   %eax
f010084f:	68 ac 68 10 f0       	push   $0xf01068ac
f0100854:	e8 09 2f 00 00       	call   f0103762 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100859:	b8 00 00 00 00       	mov    $0x0,%eax
f010085e:	c9                   	leave  
f010085f:	c3                   	ret    

f0100860 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100860:	55                   	push   %ebp
f0100861:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f0100863:	b8 00 00 00 00       	mov    $0x0,%eax
f0100868:	5d                   	pop    %ebp
f0100869:	c3                   	ret    

f010086a <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010086a:	55                   	push   %ebp
f010086b:	89 e5                	mov    %esp,%ebp
f010086d:	57                   	push   %edi
f010086e:	56                   	push   %esi
f010086f:	53                   	push   %ebx
f0100870:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100873:	68 d8 68 10 f0       	push   $0xf01068d8
f0100878:	e8 e5 2e 00 00       	call   f0103762 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010087d:	c7 04 24 fc 68 10 f0 	movl   $0xf01068fc,(%esp)
f0100884:	e8 d9 2e 00 00       	call   f0103762 <cprintf>

	if (tf != NULL)
f0100889:	83 c4 10             	add    $0x10,%esp
f010088c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100890:	74 0e                	je     f01008a0 <monitor+0x36>
		print_trapframe(tf);
f0100892:	83 ec 0c             	sub    $0xc,%esp
f0100895:	ff 75 08             	pushl  0x8(%ebp)
f0100898:	e8 25 36 00 00       	call   f0103ec2 <print_trapframe>
f010089d:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01008a0:	83 ec 0c             	sub    $0xc,%esp
f01008a3:	68 8e 67 10 f0       	push   $0xf010678e
f01008a8:	e8 60 4c 00 00       	call   f010550d <readline>
f01008ad:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01008af:	83 c4 10             	add    $0x10,%esp
f01008b2:	85 c0                	test   %eax,%eax
f01008b4:	74 ea                	je     f01008a0 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01008b6:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01008bd:	be 00 00 00 00       	mov    $0x0,%esi
f01008c2:	eb 0a                	jmp    f01008ce <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01008c4:	c6 03 00             	movb   $0x0,(%ebx)
f01008c7:	89 f7                	mov    %esi,%edi
f01008c9:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01008cc:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01008ce:	0f b6 03             	movzbl (%ebx),%eax
f01008d1:	84 c0                	test   %al,%al
f01008d3:	74 63                	je     f0100938 <monitor+0xce>
f01008d5:	83 ec 08             	sub    $0x8,%esp
f01008d8:	0f be c0             	movsbl %al,%eax
f01008db:	50                   	push   %eax
f01008dc:	68 92 67 10 f0       	push   $0xf0106792
f01008e1:	e8 41 4e 00 00       	call   f0105727 <strchr>
f01008e6:	83 c4 10             	add    $0x10,%esp
f01008e9:	85 c0                	test   %eax,%eax
f01008eb:	75 d7                	jne    f01008c4 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01008ed:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008f0:	74 46                	je     f0100938 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008f2:	83 fe 0f             	cmp    $0xf,%esi
f01008f5:	75 14                	jne    f010090b <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008f7:	83 ec 08             	sub    $0x8,%esp
f01008fa:	6a 10                	push   $0x10
f01008fc:	68 97 67 10 f0       	push   $0xf0106797
f0100901:	e8 5c 2e 00 00       	call   f0103762 <cprintf>
f0100906:	83 c4 10             	add    $0x10,%esp
f0100909:	eb 95                	jmp    f01008a0 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f010090b:	8d 7e 01             	lea    0x1(%esi),%edi
f010090e:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100912:	eb 03                	jmp    f0100917 <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100914:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100917:	0f b6 03             	movzbl (%ebx),%eax
f010091a:	84 c0                	test   %al,%al
f010091c:	74 ae                	je     f01008cc <monitor+0x62>
f010091e:	83 ec 08             	sub    $0x8,%esp
f0100921:	0f be c0             	movsbl %al,%eax
f0100924:	50                   	push   %eax
f0100925:	68 92 67 10 f0       	push   $0xf0106792
f010092a:	e8 f8 4d 00 00       	call   f0105727 <strchr>
f010092f:	83 c4 10             	add    $0x10,%esp
f0100932:	85 c0                	test   %eax,%eax
f0100934:	74 de                	je     f0100914 <monitor+0xaa>
f0100936:	eb 94                	jmp    f01008cc <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100938:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f010093f:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100940:	85 f6                	test   %esi,%esi
f0100942:	0f 84 58 ff ff ff    	je     f01008a0 <monitor+0x36>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100948:	83 ec 08             	sub    $0x8,%esp
f010094b:	68 5e 67 10 f0       	push   $0xf010675e
f0100950:	ff 75 a8             	pushl  -0x58(%ebp)
f0100953:	e8 71 4d 00 00       	call   f01056c9 <strcmp>
f0100958:	83 c4 10             	add    $0x10,%esp
f010095b:	85 c0                	test   %eax,%eax
f010095d:	74 1e                	je     f010097d <monitor+0x113>
f010095f:	83 ec 08             	sub    $0x8,%esp
f0100962:	68 6c 67 10 f0       	push   $0xf010676c
f0100967:	ff 75 a8             	pushl  -0x58(%ebp)
f010096a:	e8 5a 4d 00 00       	call   f01056c9 <strcmp>
f010096f:	83 c4 10             	add    $0x10,%esp
f0100972:	85 c0                	test   %eax,%eax
f0100974:	75 2f                	jne    f01009a5 <monitor+0x13b>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100976:	b8 01 00 00 00       	mov    $0x1,%eax
f010097b:	eb 05                	jmp    f0100982 <monitor+0x118>
		if (strcmp(argv[0], commands[i].name) == 0)
f010097d:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100982:	83 ec 04             	sub    $0x4,%esp
f0100985:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100988:	01 d0                	add    %edx,%eax
f010098a:	ff 75 08             	pushl  0x8(%ebp)
f010098d:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100990:	51                   	push   %ecx
f0100991:	56                   	push   %esi
f0100992:	ff 14 85 2c 69 10 f0 	call   *-0xfef96d4(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100999:	83 c4 10             	add    $0x10,%esp
f010099c:	85 c0                	test   %eax,%eax
f010099e:	78 1d                	js     f01009bd <monitor+0x153>
f01009a0:	e9 fb fe ff ff       	jmp    f01008a0 <monitor+0x36>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01009a5:	83 ec 08             	sub    $0x8,%esp
f01009a8:	ff 75 a8             	pushl  -0x58(%ebp)
f01009ab:	68 b4 67 10 f0       	push   $0xf01067b4
f01009b0:	e8 ad 2d 00 00       	call   f0103762 <cprintf>
f01009b5:	83 c4 10             	add    $0x10,%esp
f01009b8:	e9 e3 fe ff ff       	jmp    f01008a0 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01009bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009c0:	5b                   	pop    %ebx
f01009c1:	5e                   	pop    %esi
f01009c2:	5f                   	pop    %edi
f01009c3:	5d                   	pop    %ebp
f01009c4:	c3                   	ret    

f01009c5 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f01009c5:	55                   	push   %ebp
f01009c6:	89 e5                	mov    %esp,%ebp
f01009c8:	56                   	push   %esi
f01009c9:	53                   	push   %ebx
f01009ca:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01009cc:	83 ec 0c             	sub    $0xc,%esp
f01009cf:	50                   	push   %eax
f01009d0:	e8 0e 2c 00 00       	call   f01035e3 <mc146818_read>
f01009d5:	89 c6                	mov    %eax,%esi
f01009d7:	83 c3 01             	add    $0x1,%ebx
f01009da:	89 1c 24             	mov    %ebx,(%esp)
f01009dd:	e8 01 2c 00 00       	call   f01035e3 <mc146818_read>
f01009e2:	c1 e0 08             	shl    $0x8,%eax
f01009e5:	09 f0                	or     %esi,%eax
}
f01009e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01009ea:	5b                   	pop    %ebx
f01009eb:	5e                   	pop    %esi
f01009ec:	5d                   	pop    %ebp
f01009ed:	c3                   	ret    

f01009ee <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f01009ee:	55                   	push   %ebp
f01009ef:	89 e5                	mov    %esp,%ebp
f01009f1:	53                   	push   %ebx
f01009f2:	83 ec 04             	sub    $0x4,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01009f5:	83 3d 3c f2 22 f0 00 	cmpl   $0x0,0xf022f23c
f01009fc:	75 11                	jne    f0100a0f <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f01009fe:	ba 07 20 27 f0       	mov    $0xf0272007,%edx
f0100a03:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a09:	89 15 3c f2 22 f0    	mov    %edx,0xf022f23c
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100a0f:	8b 1d 3c f2 22 f0    	mov    0xf022f23c,%ebx
	
	nextfree=ROUNDUP(nextfree+n,PGSIZE);
f0100a15:	8d 94 03 ff 0f 00 00 	lea    0xfff(%ebx,%eax,1),%edx
f0100a1c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a22:	89 15 3c f2 22 f0    	mov    %edx,0xf022f23c
	if((uint32_t)nextfree - KERNBASE > (npages*PGSIZE))panic("Out of memory!\n");
f0100a28:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100a2e:	8b 0d 88 fe 22 f0    	mov    0xf022fe88,%ecx
f0100a34:	c1 e1 0c             	shl    $0xc,%ecx
f0100a37:	39 ca                	cmp    %ecx,%edx
f0100a39:	76 14                	jbe    f0100a4f <boot_alloc+0x61>
f0100a3b:	83 ec 04             	sub    $0x4,%esp
f0100a3e:	68 3c 69 10 f0       	push   $0xf010693c
f0100a43:	6a 6f                	push   $0x6f
f0100a45:	68 4c 69 10 f0       	push   $0xf010694c
f0100a4a:	e8 f1 f5 ff ff       	call   f0100040 <_panic>
	return result;
}
f0100a4f:	89 d8                	mov    %ebx,%eax
f0100a51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100a54:	c9                   	leave  
f0100a55:	c3                   	ret    

f0100a56 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100a56:	89 d1                	mov    %edx,%ecx
f0100a58:	c1 e9 16             	shr    $0x16,%ecx
f0100a5b:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100a5e:	a8 01                	test   $0x1,%al
f0100a60:	74 52                	je     f0100ab4 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a62:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a67:	89 c1                	mov    %eax,%ecx
f0100a69:	c1 e9 0c             	shr    $0xc,%ecx
f0100a6c:	3b 0d 88 fe 22 f0    	cmp    0xf022fe88,%ecx
f0100a72:	72 1b                	jb     f0100a8f <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a74:	55                   	push   %ebp
f0100a75:	89 e5                	mov    %esp,%ebp
f0100a77:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a7a:	50                   	push   %eax
f0100a7b:	68 44 64 10 f0       	push   $0xf0106444
f0100a80:	68 8e 03 00 00       	push   $0x38e
f0100a85:	68 4c 69 10 f0       	push   $0xf010694c
f0100a8a:	e8 b1 f5 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100a8f:	c1 ea 0c             	shr    $0xc,%edx
f0100a92:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a98:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a9f:	89 c2                	mov    %eax,%edx
f0100aa1:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100aa4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100aa9:	85 d2                	test   %edx,%edx
f0100aab:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100ab0:	0f 44 c2             	cmove  %edx,%eax
f0100ab3:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100ab4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100ab9:	c3                   	ret    

f0100aba <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100aba:	55                   	push   %ebp
f0100abb:	89 e5                	mov    %esp,%ebp
f0100abd:	57                   	push   %edi
f0100abe:	56                   	push   %esi
f0100abf:	53                   	push   %ebx
f0100ac0:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ac3:	84 c0                	test   %al,%al
f0100ac5:	0f 85 a0 02 00 00    	jne    f0100d6b <check_page_free_list+0x2b1>
f0100acb:	e9 ad 02 00 00       	jmp    f0100d7d <check_page_free_list+0x2c3>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100ad0:	83 ec 04             	sub    $0x4,%esp
f0100ad3:	68 bc 6c 10 f0       	push   $0xf0106cbc
f0100ad8:	68 c1 02 00 00       	push   $0x2c1
f0100add:	68 4c 69 10 f0       	push   $0xf010694c
f0100ae2:	e8 59 f5 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100ae7:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100aea:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100aed:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100af0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100af3:	89 c2                	mov    %eax,%edx
f0100af5:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0100afb:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b01:	0f 95 c2             	setne  %dl
f0100b04:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b07:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b0b:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b0d:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b11:	8b 00                	mov    (%eax),%eax
f0100b13:	85 c0                	test   %eax,%eax
f0100b15:	75 dc                	jne    f0100af3 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100b17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b1a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100b20:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b23:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100b26:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100b28:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100b2b:	a3 44 f2 22 f0       	mov    %eax,0xf022f244
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b30:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b35:	8b 1d 44 f2 22 f0    	mov    0xf022f244,%ebx
f0100b3b:	eb 53                	jmp    f0100b90 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f0100b3d:	89 d8                	mov    %ebx,%eax
f0100b3f:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0100b45:	c1 f8 03             	sar    $0x3,%eax
f0100b48:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b4b:	89 c2                	mov    %eax,%edx
f0100b4d:	c1 ea 16             	shr    $0x16,%edx
f0100b50:	39 f2                	cmp    %esi,%edx
f0100b52:	73 3a                	jae    f0100b8e <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b54:	89 c2                	mov    %eax,%edx
f0100b56:	c1 ea 0c             	shr    $0xc,%edx
f0100b59:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0100b5f:	72 12                	jb     f0100b73 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b61:	50                   	push   %eax
f0100b62:	68 44 64 10 f0       	push   $0xf0106444
f0100b67:	6a 58                	push   $0x58
f0100b69:	68 58 69 10 f0       	push   $0xf0106958
f0100b6e:	e8 cd f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100b73:	83 ec 04             	sub    $0x4,%esp
f0100b76:	68 80 00 00 00       	push   $0x80
f0100b7b:	68 97 00 00 00       	push   $0x97
f0100b80:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b85:	50                   	push   %eax
f0100b86:	e8 d9 4b 00 00       	call   f0105764 <memset>
f0100b8b:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b8e:	8b 1b                	mov    (%ebx),%ebx
f0100b90:	85 db                	test   %ebx,%ebx
f0100b92:	75 a9                	jne    f0100b3d <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100b94:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b99:	e8 50 fe ff ff       	call   f01009ee <boot_alloc>
f0100b9e:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ba1:	8b 15 44 f2 22 f0    	mov    0xf022f244,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ba7:	8b 0d 90 fe 22 f0    	mov    0xf022fe90,%ecx
		assert(pp < pages + npages);
f0100bad:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f0100bb2:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100bb5:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100bb8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bbb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100bbe:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bc3:	e9 52 01 00 00       	jmp    f0100d1a <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100bc8:	39 ca                	cmp    %ecx,%edx
f0100bca:	73 19                	jae    f0100be5 <check_page_free_list+0x12b>
f0100bcc:	68 66 69 10 f0       	push   $0xf0106966
f0100bd1:	68 72 69 10 f0       	push   $0xf0106972
f0100bd6:	68 db 02 00 00       	push   $0x2db
f0100bdb:	68 4c 69 10 f0       	push   $0xf010694c
f0100be0:	e8 5b f4 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100be5:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100be8:	72 19                	jb     f0100c03 <check_page_free_list+0x149>
f0100bea:	68 87 69 10 f0       	push   $0xf0106987
f0100bef:	68 72 69 10 f0       	push   $0xf0106972
f0100bf4:	68 dc 02 00 00       	push   $0x2dc
f0100bf9:	68 4c 69 10 f0       	push   $0xf010694c
f0100bfe:	e8 3d f4 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c03:	89 d0                	mov    %edx,%eax
f0100c05:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100c08:	a8 07                	test   $0x7,%al
f0100c0a:	74 19                	je     f0100c25 <check_page_free_list+0x16b>
f0100c0c:	68 e0 6c 10 f0       	push   $0xf0106ce0
f0100c11:	68 72 69 10 f0       	push   $0xf0106972
f0100c16:	68 dd 02 00 00       	push   $0x2dd
f0100c1b:	68 4c 69 10 f0       	push   $0xf010694c
f0100c20:	e8 1b f4 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f0100c25:	c1 f8 03             	sar    $0x3,%eax
f0100c28:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100c2b:	85 c0                	test   %eax,%eax
f0100c2d:	75 19                	jne    f0100c48 <check_page_free_list+0x18e>
f0100c2f:	68 9b 69 10 f0       	push   $0xf010699b
f0100c34:	68 72 69 10 f0       	push   $0xf0106972
f0100c39:	68 e0 02 00 00       	push   $0x2e0
f0100c3e:	68 4c 69 10 f0       	push   $0xf010694c
f0100c43:	e8 f8 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c48:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c4d:	75 19                	jne    f0100c68 <check_page_free_list+0x1ae>
f0100c4f:	68 ac 69 10 f0       	push   $0xf01069ac
f0100c54:	68 72 69 10 f0       	push   $0xf0106972
f0100c59:	68 e1 02 00 00       	push   $0x2e1
f0100c5e:	68 4c 69 10 f0       	push   $0xf010694c
f0100c63:	e8 d8 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c68:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c6d:	75 19                	jne    f0100c88 <check_page_free_list+0x1ce>
f0100c6f:	68 14 6d 10 f0       	push   $0xf0106d14
f0100c74:	68 72 69 10 f0       	push   $0xf0106972
f0100c79:	68 e2 02 00 00       	push   $0x2e2
f0100c7e:	68 4c 69 10 f0       	push   $0xf010694c
f0100c83:	e8 b8 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c88:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c8d:	75 19                	jne    f0100ca8 <check_page_free_list+0x1ee>
f0100c8f:	68 c5 69 10 f0       	push   $0xf01069c5
f0100c94:	68 72 69 10 f0       	push   $0xf0106972
f0100c99:	68 e3 02 00 00       	push   $0x2e3
f0100c9e:	68 4c 69 10 f0       	push   $0xf010694c
f0100ca3:	e8 98 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100ca8:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100cad:	0f 86 f1 00 00 00    	jbe    f0100da4 <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100cb3:	89 c7                	mov    %eax,%edi
f0100cb5:	c1 ef 0c             	shr    $0xc,%edi
f0100cb8:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100cbb:	77 12                	ja     f0100ccf <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cbd:	50                   	push   %eax
f0100cbe:	68 44 64 10 f0       	push   $0xf0106444
f0100cc3:	6a 58                	push   $0x58
f0100cc5:	68 58 69 10 f0       	push   $0xf0106958
f0100cca:	e8 71 f3 ff ff       	call   f0100040 <_panic>
f0100ccf:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100cd5:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100cd8:	0f 86 b6 00 00 00    	jbe    f0100d94 <check_page_free_list+0x2da>
f0100cde:	68 38 6d 10 f0       	push   $0xf0106d38
f0100ce3:	68 72 69 10 f0       	push   $0xf0106972
f0100ce8:	68 e4 02 00 00       	push   $0x2e4
f0100ced:	68 4c 69 10 f0       	push   $0xf010694c
f0100cf2:	e8 49 f3 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100cf7:	68 df 69 10 f0       	push   $0xf01069df
f0100cfc:	68 72 69 10 f0       	push   $0xf0106972
f0100d01:	68 e6 02 00 00       	push   $0x2e6
f0100d06:	68 4c 69 10 f0       	push   $0xf010694c
f0100d0b:	e8 30 f3 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100d10:	83 c6 01             	add    $0x1,%esi
f0100d13:	eb 03                	jmp    f0100d18 <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100d15:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d18:	8b 12                	mov    (%edx),%edx
f0100d1a:	85 d2                	test   %edx,%edx
f0100d1c:	0f 85 a6 fe ff ff    	jne    f0100bc8 <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100d22:	85 f6                	test   %esi,%esi
f0100d24:	7f 19                	jg     f0100d3f <check_page_free_list+0x285>
f0100d26:	68 fc 69 10 f0       	push   $0xf01069fc
f0100d2b:	68 72 69 10 f0       	push   $0xf0106972
f0100d30:	68 ee 02 00 00       	push   $0x2ee
f0100d35:	68 4c 69 10 f0       	push   $0xf010694c
f0100d3a:	e8 01 f3 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100d3f:	85 db                	test   %ebx,%ebx
f0100d41:	7f 19                	jg     f0100d5c <check_page_free_list+0x2a2>
f0100d43:	68 0e 6a 10 f0       	push   $0xf0106a0e
f0100d48:	68 72 69 10 f0       	push   $0xf0106972
f0100d4d:	68 ef 02 00 00       	push   $0x2ef
f0100d52:	68 4c 69 10 f0       	push   $0xf010694c
f0100d57:	e8 e4 f2 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100d5c:	83 ec 0c             	sub    $0xc,%esp
f0100d5f:	68 80 6d 10 f0       	push   $0xf0106d80
f0100d64:	e8 f9 29 00 00       	call   f0103762 <cprintf>
}
f0100d69:	eb 49                	jmp    f0100db4 <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100d6b:	a1 44 f2 22 f0       	mov    0xf022f244,%eax
f0100d70:	85 c0                	test   %eax,%eax
f0100d72:	0f 85 6f fd ff ff    	jne    f0100ae7 <check_page_free_list+0x2d>
f0100d78:	e9 53 fd ff ff       	jmp    f0100ad0 <check_page_free_list+0x16>
f0100d7d:	83 3d 44 f2 22 f0 00 	cmpl   $0x0,0xf022f244
f0100d84:	0f 84 46 fd ff ff    	je     f0100ad0 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d8a:	be 00 04 00 00       	mov    $0x400,%esi
f0100d8f:	e9 a1 fd ff ff       	jmp    f0100b35 <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d94:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100d99:	0f 85 76 ff ff ff    	jne    f0100d15 <check_page_free_list+0x25b>
f0100d9f:	e9 53 ff ff ff       	jmp    f0100cf7 <check_page_free_list+0x23d>
f0100da4:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100da9:	0f 85 61 ff ff ff    	jne    f0100d10 <check_page_free_list+0x256>
f0100daf:	e9 43 ff ff ff       	jmp    f0100cf7 <check_page_free_list+0x23d>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100db4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100db7:	5b                   	pop    %ebx
f0100db8:	5e                   	pop    %esi
f0100db9:	5f                   	pop    %edi
f0100dba:	5d                   	pop    %ebp
f0100dbb:	c3                   	ret    

f0100dbc <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100dbc:	55                   	push   %ebp
f0100dbd:	89 e5                	mov    %esp,%ebp
f0100dbf:	53                   	push   %ebx
f0100dc0:	83 ec 04             	sub    $0x4,%esp
f0100dc3:	8b 1d 44 f2 22 f0    	mov    0xf022f244,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100dc9:	ba 00 00 00 00       	mov    $0x0,%edx
f0100dce:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dd3:	eb 27                	jmp    f0100dfc <page_init+0x40>
f0100dd5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100ddc:	89 d1                	mov    %edx,%ecx
f0100dde:	03 0d 90 fe 22 f0    	add    0xf022fe90,%ecx
f0100de4:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100dea:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100dec:	83 c0 01             	add    $0x1,%eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i]; //不知道为啥这个list是倒过来连接的
f0100def:	89 d3                	mov    %edx,%ebx
f0100df1:	03 1d 90 fe 22 f0    	add    0xf022fe90,%ebx
f0100df7:	ba 01 00 00 00       	mov    $0x1,%edx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100dfc:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f0100e02:	72 d1                	jb     f0100dd5 <page_init+0x19>
f0100e04:	84 d2                	test   %dl,%dl
f0100e06:	74 06                	je     f0100e0e <page_init+0x52>
f0100e08:	89 1d 44 f2 22 f0    	mov    %ebx,0xf022f244
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i]; //不知道为啥这个list是倒过来连接的
	}
	// 根据上面他给的提示写，1) 是 0 号 页是实模式的IDT 和 BIOS 不应该添加到空闲页，所以
	pages[1].pp_link=pages[0].pp_link;
f0100e0e:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
f0100e13:	8b 10                	mov    (%eax),%edx
f0100e15:	89 50 08             	mov    %edx,0x8(%eax)
	pages[0].pp_ref = 1;//不知道为啥有大佬说这个可以不用设置
f0100e18:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link=NULL;
f0100e1e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	//2)是说那一块可以用，也就是上一次实验说的低地址，所以不用做修改
	//3)是说 上节课讲的有一部分 是不能用的，存IO的那一块，他告诉你地址是从[IOPHYSMEM,EXTPHYSMEM)
	size_t range_io=PGNUM(IOPHYSMEM),range_ext=PGNUM(EXTPHYSMEM);
	pages[range_ext].pp_link=pages[range_io].pp_link;
f0100e24:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
f0100e29:	8b 90 00 05 00 00    	mov    0x500(%eax),%edx
f0100e2f:	89 90 00 08 00 00    	mov    %edx,0x800(%eax)
f0100e35:	b8 00 05 00 00       	mov    $0x500,%eax
	for (i = range_io; i < range_ext; i++) pages[i].pp_link = NULL;
f0100e3a:	8b 15 90 fe 22 f0    	mov    0xf022fe90,%edx
f0100e40:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f0100e47:	83 c0 08             	add    $0x8,%eax
f0100e4a:	3d 00 08 00 00       	cmp    $0x800,%eax
f0100e4f:	75 e9                	jne    f0100e3a <page_init+0x7e>

	//4)后面分配了一些内存页面给内核，所以那一块也是不能用的，看了半天，和上面是连续的...
	size_t free_top = PGNUM(PADDR(boot_alloc(0)));
f0100e51:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e56:	e8 93 fb ff ff       	call   f01009ee <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e5b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e60:	77 15                	ja     f0100e77 <page_init+0xbb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e62:	50                   	push   %eax
f0100e63:	68 68 64 10 f0       	push   $0xf0106468
f0100e68:	68 5b 01 00 00       	push   $0x15b
f0100e6d:	68 4c 69 10 f0       	push   $0xf010694c
f0100e72:	e8 c9 f1 ff ff       	call   f0100040 <_panic>
f0100e77:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f0100e7d:	c1 e9 0c             	shr    $0xc,%ecx
	pages[free_top].pp_link = pages[range_ext].pp_link;
f0100e80:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
f0100e85:	8b 90 00 08 00 00    	mov    0x800(%eax),%edx
f0100e8b:	89 14 c8             	mov    %edx,(%eax,%ecx,8)
	for(i = range_ext; i < free_top; i++) pages[i].pp_link = NULL;
f0100e8e:	b8 00 01 00 00       	mov    $0x100,%eax
f0100e93:	eb 10                	jmp    f0100ea5 <page_init+0xe9>
f0100e95:	8b 15 90 fe 22 f0    	mov    0xf022fe90,%edx
f0100e9b:	c7 04 c2 00 00 00 00 	movl   $0x0,(%edx,%eax,8)
f0100ea2:	83 c0 01             	add    $0x1,%eax
f0100ea5:	39 c8                	cmp    %ecx,%eax
f0100ea7:	72 ec                	jb     f0100e95 <page_init+0xd9>

	// 把MPENTRY_PADDR这块地址也删处
	uint32_t range_mpentry = PGNUM(MPENTRY_PADDR);
	pages[range_mpentry+1].pp_link=pages[range_mpentry].pp_link;
f0100ea9:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
f0100eae:	8b 50 38             	mov    0x38(%eax),%edx
f0100eb1:	89 50 40             	mov    %edx,0x40(%eax)
	pages[range_mpentry].pp_link=NULL;
f0100eb4:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

}
f0100ebb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ebe:	c9                   	leave  
f0100ebf:	c3                   	ret    

f0100ec0 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100ec0:	55                   	push   %ebp
f0100ec1:	89 e5                	mov    %esp,%ebp
f0100ec3:	53                   	push   %ebx
f0100ec4:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	//这个就是真正的内存分配函数了
	if(page_free_list){
f0100ec7:	8b 1d 44 f2 22 f0    	mov    0xf022f244,%ebx
f0100ecd:	85 db                	test   %ebx,%ebx
f0100ecf:	74 58                	je     f0100f29 <page_alloc+0x69>
		struct PageInfo *allocated = page_free_list;
		page_free_list = allocated->pp_link;
f0100ed1:	8b 03                	mov    (%ebx),%eax
f0100ed3:	a3 44 f2 22 f0       	mov    %eax,0xf022f244
		allocated->pp_link = NULL;
f0100ed8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (alloc_flags & ALLOC_ZERO)
f0100ede:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100ee2:	74 45                	je     f0100f29 <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f0100ee4:	89 d8                	mov    %ebx,%eax
f0100ee6:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0100eec:	c1 f8 03             	sar    $0x3,%eax
f0100eef:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ef2:	89 c2                	mov    %eax,%edx
f0100ef4:	c1 ea 0c             	shr    $0xc,%edx
f0100ef7:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0100efd:	72 12                	jb     f0100f11 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100eff:	50                   	push   %eax
f0100f00:	68 44 64 10 f0       	push   $0xf0106444
f0100f05:	6a 58                	push   $0x58
f0100f07:	68 58 69 10 f0       	push   $0xf0106958
f0100f0c:	e8 2f f1 ff ff       	call   f0100040 <_panic>
			memset(page2kva(allocated), 0, PGSIZE);
f0100f11:	83 ec 04             	sub    $0x4,%esp
f0100f14:	68 00 10 00 00       	push   $0x1000
f0100f19:	6a 00                	push   $0x0
f0100f1b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f20:	50                   	push   %eax
f0100f21:	e8 3e 48 00 00       	call   f0105764 <memset>
f0100f26:	83 c4 10             	add    $0x10,%esp
		return allocated;
	}
	else return NULL;
	//return 0;
}
f0100f29:	89 d8                	mov    %ebx,%eax
f0100f2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f2e:	c9                   	leave  
f0100f2f:	c3                   	ret    

f0100f30 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100f30:	55                   	push   %ebp
f0100f31:	89 e5                	mov    %esp,%ebp
f0100f33:	83 ec 08             	sub    $0x8,%esp
f0100f36:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	// 前面两个提示你了，一个判断 pp_ref 是不是非0 ，一个是pp_link 是不是非空
	if(pp->pp_ref > 0||pp->pp_link != NULL)panic("Page table entries point to this physical page.");
f0100f39:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f3e:	75 05                	jne    f0100f45 <page_free+0x15>
f0100f40:	83 38 00             	cmpl   $0x0,(%eax)
f0100f43:	74 17                	je     f0100f5c <page_free+0x2c>
f0100f45:	83 ec 04             	sub    $0x4,%esp
f0100f48:	68 a4 6d 10 f0       	push   $0xf0106da4
f0100f4d:	68 8e 01 00 00       	push   $0x18e
f0100f52:	68 4c 69 10 f0       	push   $0xf010694c
f0100f57:	e8 e4 f0 ff ff       	call   f0100040 <_panic>
      	pp->pp_link = page_free_list;
f0100f5c:	8b 15 44 f2 22 f0    	mov    0xf022f244,%edx
f0100f62:	89 10                	mov    %edx,(%eax)
      	page_free_list = pp;
f0100f64:	a3 44 f2 22 f0       	mov    %eax,0xf022f244
}
f0100f69:	c9                   	leave  
f0100f6a:	c3                   	ret    

f0100f6b <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100f6b:	55                   	push   %ebp
f0100f6c:	89 e5                	mov    %esp,%ebp
f0100f6e:	83 ec 08             	sub    $0x8,%esp
f0100f71:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100f74:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100f78:	83 e8 01             	sub    $0x1,%eax
f0100f7b:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100f7f:	66 85 c0             	test   %ax,%ax
f0100f82:	75 0c                	jne    f0100f90 <page_decref+0x25>
		page_free(pp);
f0100f84:	83 ec 0c             	sub    $0xc,%esp
f0100f87:	52                   	push   %edx
f0100f88:	e8 a3 ff ff ff       	call   f0100f30 <page_free>
f0100f8d:	83 c4 10             	add    $0x10,%esp
}
f0100f90:	c9                   	leave  
f0100f91:	c3                   	ret    

f0100f92 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100f92:	55                   	push   %ebp
f0100f93:	89 e5                	mov    %esp,%ebp
f0100f95:	56                   	push   %esi
f0100f96:	53                   	push   %ebx
f0100f97:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	struct PageInfo * np;
	
	// PDX 是页目录里面的索引， pgdir 是 页目录，所以就找到了对应的地址
	pte_t * pd_entry =&pgdir[PDX(va)];
f0100f9a:	89 f3                	mov    %esi,%ebx
f0100f9c:	c1 eb 16             	shr    $0x16,%ebx
f0100f9f:	c1 e3 02             	shl    $0x2,%ebx
f0100fa2:	03 5d 08             	add    0x8(%ebp),%ebx
	
	//PTE_P 判断是不是已经存在该页，是的话就直接返回
	if(*pd_entry & PTE_P)
f0100fa5:	8b 03                	mov    (%ebx),%eax
f0100fa7:	a8 01                	test   $0x1,%al
f0100fa9:	74 39                	je     f0100fe4 <pgdir_walk+0x52>
		return (pte_t *)KADDR(PTE_ADDR(*pd_entry))+PTX(va);
f0100fab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fb0:	89 c2                	mov    %eax,%edx
f0100fb2:	c1 ea 0c             	shr    $0xc,%edx
f0100fb5:	39 15 88 fe 22 f0    	cmp    %edx,0xf022fe88
f0100fbb:	77 15                	ja     f0100fd2 <pgdir_walk+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fbd:	50                   	push   %eax
f0100fbe:	68 44 64 10 f0       	push   $0xf0106444
f0100fc3:	68 bf 01 00 00       	push   $0x1bf
f0100fc8:	68 4c 69 10 f0       	push   $0xf010694c
f0100fcd:	e8 6e f0 ff ff       	call   f0100040 <_panic>
f0100fd2:	c1 ee 0a             	shr    $0xa,%esi
f0100fd5:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0100fdb:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0100fe2:	eb 74                	jmp    f0101058 <pgdir_walk+0xc6>
	else if(create == true && (np=page_alloc(ALLOC_ZERO))){
f0100fe4:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
f0100fe8:	75 62                	jne    f010104c <pgdir_walk+0xba>
f0100fea:	83 ec 0c             	sub    $0xc,%esp
f0100fed:	6a 01                	push   $0x1
f0100fef:	e8 cc fe ff ff       	call   f0100ec0 <page_alloc>
f0100ff4:	83 c4 10             	add    $0x10,%esp
f0100ff7:	85 c0                	test   %eax,%eax
f0100ff9:	74 58                	je     f0101053 <pgdir_walk+0xc1>
		//如果可以创建就创建一个
		np->pp_ref++;//分配一个页
f0100ffb:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f0101000:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0101006:	c1 f8 03             	sar    $0x3,%eax
f0101009:	c1 e0 0c             	shl    $0xc,%eax
		*pd_entry=page2pa(np)|PTE_P|PTE_U|PTE_W; //设置一些值
f010100c:	89 c2                	mov    %eax,%edx
f010100e:	83 ca 07             	or     $0x7,%edx
f0101011:	89 13                	mov    %edx,(%ebx)
f0101013:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101018:	89 c2                	mov    %eax,%edx
f010101a:	c1 ea 0c             	shr    $0xc,%edx
f010101d:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0101023:	72 15                	jb     f010103a <pgdir_walk+0xa8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101025:	50                   	push   %eax
f0101026:	68 44 64 10 f0       	push   $0xf0106444
f010102b:	68 c4 01 00 00       	push   $0x1c4
f0101030:	68 4c 69 10 f0       	push   $0xf010694c
f0101035:	e8 06 f0 ff ff       	call   f0100040 <_panic>
		return (pte_t *)KADDR(PTE_ADDR(*pd_entry)) + PTX(va);
f010103a:	c1 ee 0a             	shr    $0xa,%esi
f010103d:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101043:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f010104a:	eb 0c                	jmp    f0101058 <pgdir_walk+0xc6>
	}
	else return NULL;
f010104c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101051:	eb 05                	jmp    f0101058 <pgdir_walk+0xc6>
f0101053:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101058:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010105b:	5b                   	pop    %ebx
f010105c:	5e                   	pop    %esi
f010105d:	5d                   	pop    %ebp
f010105e:	c3                   	ret    

f010105f <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010105f:	55                   	push   %ebp
f0101060:	89 e5                	mov    %esp,%ebp
f0101062:	57                   	push   %edi
f0101063:	56                   	push   %esi
f0101064:	53                   	push   %ebx
f0101065:	83 ec 1c             	sub    $0x1c,%esp
f0101068:	89 c7                	mov    %eax,%edi
f010106a:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010106d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	// Fill this function in
	uintptr_t vStep;
	pte_t *ptep;
	for(vStep=0;vStep<size;vStep+=PGSIZE){
f0101070:	bb 00 00 00 00       	mov    $0x0,%ebx
		ptep=pgdir_walk(pgdir,(void *)va+vStep,true);
		if(ptep)*ptep=pa|perm|PTE_P;
f0101075:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101078:	83 c8 01             	or     $0x1,%eax
f010107b:	89 45 dc             	mov    %eax,-0x24(%ebp)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	uintptr_t vStep;
	pte_t *ptep;
	for(vStep=0;vStep<size;vStep+=PGSIZE){
f010107e:	eb 23                	jmp    f01010a3 <boot_map_region+0x44>
		ptep=pgdir_walk(pgdir,(void *)va+vStep,true);
f0101080:	83 ec 04             	sub    $0x4,%esp
f0101083:	6a 01                	push   $0x1
f0101085:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101088:	01 d8                	add    %ebx,%eax
f010108a:	50                   	push   %eax
f010108b:	57                   	push   %edi
f010108c:	e8 01 ff ff ff       	call   f0100f92 <pgdir_walk>
		if(ptep)*ptep=pa|perm|PTE_P;
f0101091:	83 c4 10             	add    $0x10,%esp
f0101094:	85 c0                	test   %eax,%eax
f0101096:	74 05                	je     f010109d <boot_map_region+0x3e>
f0101098:	0b 75 dc             	or     -0x24(%ebp),%esi
f010109b:	89 30                	mov    %esi,(%eax)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	uintptr_t vStep;
	pte_t *ptep;
	for(vStep=0;vStep<size;vStep+=PGSIZE){
f010109d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01010a3:	89 de                	mov    %ebx,%esi
f01010a5:	03 75 08             	add    0x8(%ebp),%esi
f01010a8:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01010ab:	72 d3                	jb     f0101080 <boot_map_region+0x21>
		ptep=pgdir_walk(pgdir,(void *)va+vStep,true);
		if(ptep)*ptep=pa|perm|PTE_P;
		pa+=PGSIZE;
	}
}
f01010ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010b0:	5b                   	pop    %ebx
f01010b1:	5e                   	pop    %esi
f01010b2:	5f                   	pop    %edi
f01010b3:	5d                   	pop    %ebp
f01010b4:	c3                   	ret    

f01010b5 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01010b5:	55                   	push   %ebp
f01010b6:	89 e5                	mov    %esp,%ebp
f01010b8:	53                   	push   %ebx
f01010b9:	83 ec 08             	sub    $0x8,%esp
f01010bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *ptep =pgdir_walk(pgdir,va,false);
f01010bf:	6a 00                	push   $0x0
f01010c1:	ff 75 0c             	pushl  0xc(%ebp)
f01010c4:	ff 75 08             	pushl  0x8(%ebp)
f01010c7:	e8 c6 fe ff ff       	call   f0100f92 <pgdir_walk>
	if(ptep&&(*ptep&PTE_P)){
f01010cc:	83 c4 10             	add    $0x10,%esp
f01010cf:	85 c0                	test   %eax,%eax
f01010d1:	74 37                	je     f010110a <page_lookup+0x55>
f01010d3:	f6 00 01             	testb  $0x1,(%eax)
f01010d6:	74 39                	je     f0101111 <page_lookup+0x5c>
		if(pte_store){
f01010d8:	85 db                	test   %ebx,%ebx
f01010da:	74 02                	je     f01010de <page_lookup+0x29>
			*pte_store=ptep;	
f01010dc:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{	// 或得物理地址的数据结构
	if (PGNUM(pa) >= npages)
f01010de:	8b 00                	mov    (%eax),%eax
f01010e0:	c1 e8 0c             	shr    $0xc,%eax
f01010e3:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f01010e9:	72 14                	jb     f01010ff <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01010eb:	83 ec 04             	sub    $0x4,%esp
f01010ee:	68 d4 6d 10 f0       	push   $0xf0106dd4
f01010f3:	6a 51                	push   $0x51
f01010f5:	68 58 69 10 f0       	push   $0xf0106958
f01010fa:	e8 41 ef ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01010ff:	8b 15 90 fe 22 f0    	mov    0xf022fe90,%edx
f0101105:	8d 04 c2             	lea    (%edx,%eax,8),%eax
		}
		return pa2page(PTE_ADDR(*ptep));
f0101108:	eb 0c                	jmp    f0101116 <page_lookup+0x61>

	}
	return NULL;
f010110a:	b8 00 00 00 00       	mov    $0x0,%eax
f010110f:	eb 05                	jmp    f0101116 <page_lookup+0x61>
f0101111:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101116:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101119:	c9                   	leave  
f010111a:	c3                   	ret    

f010111b <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010111b:	55                   	push   %ebp
f010111c:	89 e5                	mov    %esp,%ebp
f010111e:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101121:	e8 60 4c 00 00       	call   f0105d86 <cpunum>
f0101126:	6b c0 74             	imul   $0x74,%eax,%eax
f0101129:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0101130:	74 16                	je     f0101148 <tlb_invalidate+0x2d>
f0101132:	e8 4f 4c 00 00       	call   f0105d86 <cpunum>
f0101137:	6b c0 74             	imul   $0x74,%eax,%eax
f010113a:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0101140:	8b 55 08             	mov    0x8(%ebp),%edx
f0101143:	39 50 60             	cmp    %edx,0x60(%eax)
f0101146:	75 06                	jne    f010114e <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101148:	8b 45 0c             	mov    0xc(%ebp),%eax
f010114b:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f010114e:	c9                   	leave  
f010114f:	c3                   	ret    

f0101150 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101150:	55                   	push   %ebp
f0101151:	89 e5                	mov    %esp,%ebp
f0101153:	56                   	push   %esi
f0101154:	53                   	push   %ebx
f0101155:	83 ec 14             	sub    $0x14,%esp
f0101158:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010115b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pte_t* pte_store;
	struct PageInfo *pgit=page_lookup(pgdir, va, &pte_store);
f010115e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101161:	50                   	push   %eax
f0101162:	56                   	push   %esi
f0101163:	53                   	push   %ebx
f0101164:	e8 4c ff ff ff       	call   f01010b5 <page_lookup>
	if(pgit){
f0101169:	83 c4 10             	add    $0x10,%esp
f010116c:	85 c0                	test   %eax,%eax
f010116e:	74 1f                	je     f010118f <page_remove+0x3f>
		page_decref(pgit);
f0101170:	83 ec 0c             	sub    $0xc,%esp
f0101173:	50                   	push   %eax
f0101174:	e8 f2 fd ff ff       	call   f0100f6b <page_decref>
		*pte_store=0;
f0101179:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010117c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir,va);
f0101182:	83 c4 08             	add    $0x8,%esp
f0101185:	56                   	push   %esi
f0101186:	53                   	push   %ebx
f0101187:	e8 8f ff ff ff       	call   f010111b <tlb_invalidate>
f010118c:	83 c4 10             	add    $0x10,%esp
	}
}
f010118f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101192:	5b                   	pop    %ebx
f0101193:	5e                   	pop    %esi
f0101194:	5d                   	pop    %ebp
f0101195:	c3                   	ret    

f0101196 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101196:	55                   	push   %ebp
f0101197:	89 e5                	mov    %esp,%ebp
f0101199:	57                   	push   %edi
f010119a:	56                   	push   %esi
f010119b:	53                   	push   %ebx
f010119c:	83 ec 10             	sub    $0x10,%esp
f010119f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01011a2:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *ptep=pgdir_walk(pgdir, va, true);
f01011a5:	6a 01                	push   $0x1
f01011a7:	57                   	push   %edi
f01011a8:	ff 75 08             	pushl  0x8(%ebp)
f01011ab:	e8 e2 fd ff ff       	call   f0100f92 <pgdir_walk>
	if(ptep){
f01011b0:	83 c4 10             	add    $0x10,%esp
f01011b3:	85 c0                	test   %eax,%eax
f01011b5:	74 38                	je     f01011ef <page_insert+0x59>
f01011b7:	89 c6                	mov    %eax,%esi
		pp->pp_ref++;
f01011b9:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
		if(*ptep&PTE_P)page_remove(pgdir, va);
f01011be:	f6 00 01             	testb  $0x1,(%eax)
f01011c1:	74 0f                	je     f01011d2 <page_insert+0x3c>
f01011c3:	83 ec 08             	sub    $0x8,%esp
f01011c6:	57                   	push   %edi
f01011c7:	ff 75 08             	pushl  0x8(%ebp)
f01011ca:	e8 81 ff ff ff       	call   f0101150 <page_remove>
f01011cf:	83 c4 10             	add    $0x10,%esp
		 *ptep = page2pa(pp) | perm | PTE_P;
f01011d2:	2b 1d 90 fe 22 f0    	sub    0xf022fe90,%ebx
f01011d8:	c1 fb 03             	sar    $0x3,%ebx
f01011db:	c1 e3 0c             	shl    $0xc,%ebx
f01011de:	8b 45 14             	mov    0x14(%ebp),%eax
f01011e1:	83 c8 01             	or     $0x1,%eax
f01011e4:	09 c3                	or     %eax,%ebx
f01011e6:	89 1e                	mov    %ebx,(%esi)
		return 0;
f01011e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01011ed:	eb 05                	jmp    f01011f4 <page_insert+0x5e>
	}
	return -E_NO_MEM;
f01011ef:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
f01011f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011f7:	5b                   	pop    %ebx
f01011f8:	5e                   	pop    %esi
f01011f9:	5f                   	pop    %edi
f01011fa:	5d                   	pop    %ebp
f01011fb:	c3                   	ret    

f01011fc <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01011fc:	55                   	push   %ebp
f01011fd:	89 e5                	mov    %esp,%ebp
f01011ff:	56                   	push   %esi
f0101200:	53                   	push   %ebx
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	uintptr_t oldBase = base;
f0101201:	8b 35 00 03 12 f0    	mov    0xf0120300,%esi
    size = ROUNDUP(size, PGSIZE);
f0101207:	8b 45 0c             	mov    0xc(%ebp),%eax
f010120a:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101210:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    boot_map_region(kern_pgdir, base, size, pa, PTE_W | PTE_PWT | PTE_PCD);
f0101216:	83 ec 08             	sub    $0x8,%esp
f0101219:	6a 1a                	push   $0x1a
f010121b:	ff 75 08             	pushl  0x8(%ebp)
f010121e:	89 d9                	mov    %ebx,%ecx
f0101220:	89 f2                	mov    %esi,%edx
f0101222:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101227:	e8 33 fe ff ff       	call   f010105f <boot_map_region>
    base += size;
f010122c:	01 1d 00 03 12 f0    	add    %ebx,0xf0120300
    return (void *)oldBase;
	//panic("mmio_map_region not implemented");
}
f0101232:	89 f0                	mov    %esi,%eax
f0101234:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101237:	5b                   	pop    %ebx
f0101238:	5e                   	pop    %esi
f0101239:	5d                   	pop    %ebp
f010123a:	c3                   	ret    

f010123b <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010123b:	55                   	push   %ebp
f010123c:	89 e5                	mov    %esp,%ebp
f010123e:	57                   	push   %edi
f010123f:	56                   	push   %esi
f0101240:	53                   	push   %ebx
f0101241:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0101244:	b8 15 00 00 00       	mov    $0x15,%eax
f0101249:	e8 77 f7 ff ff       	call   f01009c5 <nvram_read>
f010124e:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101250:	b8 17 00 00 00       	mov    $0x17,%eax
f0101255:	e8 6b f7 ff ff       	call   f01009c5 <nvram_read>
f010125a:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010125c:	b8 34 00 00 00       	mov    $0x34,%eax
f0101261:	e8 5f f7 ff ff       	call   f01009c5 <nvram_read>
f0101266:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0101269:	85 c0                	test   %eax,%eax
f010126b:	74 07                	je     f0101274 <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f010126d:	05 00 40 00 00       	add    $0x4000,%eax
f0101272:	eb 0b                	jmp    f010127f <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f0101274:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f010127a:	85 f6                	test   %esi,%esi
f010127c:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f010127f:	89 c2                	mov    %eax,%edx
f0101281:	c1 ea 02             	shr    $0x2,%edx
f0101284:	89 15 88 fe 22 f0    	mov    %edx,0xf022fe88
	npages_basemem = basemem / (PGSIZE / 1024);
f010128a:	89 da                	mov    %ebx,%edx
f010128c:	c1 ea 02             	shr    $0x2,%edx
f010128f:	89 15 48 f2 22 f0    	mov    %edx,0xf022f248

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101295:	89 c2                	mov    %eax,%edx
f0101297:	29 da                	sub    %ebx,%edx
f0101299:	52                   	push   %edx
f010129a:	53                   	push   %ebx
f010129b:	50                   	push   %eax
f010129c:	68 f4 6d 10 f0       	push   $0xf0106df4
f01012a1:	e8 bc 24 00 00       	call   f0103762 <cprintf>
	uint32_t cr0;
	size_t n;

	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();
	cprintf("\nnpages= %d npages_basemem = %d \n",npages,npages_basemem);
f01012a6:	83 c4 0c             	add    $0xc,%esp
f01012a9:	ff 35 48 f2 22 f0    	pushl  0xf022f248
f01012af:	ff 35 88 fe 22 f0    	pushl  0xf022fe88
f01012b5:	68 30 6e 10 f0       	push   $0xf0106e30
f01012ba:	e8 a3 24 00 00       	call   f0103762 <cprintf>
	// Remove this line when you're ready to test this function.
//	panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01012bf:	b8 00 10 00 00       	mov    $0x1000,%eax
f01012c4:	e8 25 f7 ff ff       	call   f01009ee <boot_alloc>
f01012c9:	a3 8c fe 22 f0       	mov    %eax,0xf022fe8c
	cprintf("PGSIZE = %d\n",PGSIZE);
f01012ce:	83 c4 08             	add    $0x8,%esp
f01012d1:	68 00 10 00 00       	push   $0x1000
f01012d6:	68 1f 6a 10 f0       	push   $0xf0106a1f
f01012db:	e8 82 24 00 00       	call   f0103762 <cprintf>
	memset(kern_pgdir, 0, PGSIZE);
f01012e0:	83 c4 0c             	add    $0xc,%esp
f01012e3:	68 00 10 00 00       	push   $0x1000
f01012e8:	6a 00                	push   $0x0
f01012ea:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f01012f0:	e8 6f 44 00 00       	call   f0105764 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01012f5:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01012fa:	83 c4 10             	add    $0x10,%esp
f01012fd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101302:	77 15                	ja     f0101319 <mem_init+0xde>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101304:	50                   	push   %eax
f0101305:	68 68 64 10 f0       	push   $0xf0106468
f010130a:	68 95 00 00 00       	push   $0x95
f010130f:	68 4c 69 10 f0       	push   $0xf010694c
f0101314:	e8 27 ed ff ff       	call   f0100040 <_panic>
f0101319:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010131f:	83 ca 05             	or     $0x5,%edx
f0101322:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	cprintf("PDX(UVPT) = %x UVPT=%x\n ",PDX(UVPT),UVPT);
f0101328:	83 ec 04             	sub    $0x4,%esp
f010132b:	68 00 00 40 ef       	push   $0xef400000
f0101330:	68 bd 03 00 00       	push   $0x3bd
f0101335:	68 2c 6a 10 f0       	push   $0xf0106a2c
f010133a:	e8 23 24 00 00       	call   f0103762 <cprintf>
	cprintf("kern_pgdir = %x PADDR(kern_pgdir) = %x\n",kern_pgdir,PADDR(kern_pgdir));
f010133f:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101344:	83 c4 10             	add    $0x10,%esp
f0101347:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010134c:	77 15                	ja     f0101363 <mem_init+0x128>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010134e:	50                   	push   %eax
f010134f:	68 68 64 10 f0       	push   $0xf0106468
f0101354:	68 97 00 00 00       	push   $0x97
f0101359:	68 4c 69 10 f0       	push   $0xf010694c
f010135e:	e8 dd ec ff ff       	call   f0100040 <_panic>
f0101363:	83 ec 04             	sub    $0x4,%esp
f0101366:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010136c:	52                   	push   %edx
f010136d:	50                   	push   %eax
f010136e:	68 54 6e 10 f0       	push   $0xf0106e54
f0101373:	e8 ea 23 00 00       	call   f0103762 <cprintf>
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages=(struct PageInfo *) boot_alloc(npages *sizeof(struct PageInfo));
f0101378:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f010137d:	c1 e0 03             	shl    $0x3,%eax
f0101380:	e8 69 f6 ff ff       	call   f01009ee <boot_alloc>
f0101385:	a3 90 fe 22 f0       	mov    %eax,0xf022fe90
	memset(pages,0,npages*sizeof(struct PageInfo));
f010138a:	83 c4 0c             	add    $0xc,%esp
f010138d:	8b 0d 88 fe 22 f0    	mov    0xf022fe88,%ecx
f0101393:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f010139a:	52                   	push   %edx
f010139b:	6a 00                	push   $0x0
f010139d:	50                   	push   %eax
f010139e:	e8 c1 43 00 00       	call   f0105764 <memset>
	cprintf("npages *sizeof(struct PageInfo)=%d\n",npages*sizeof(struct PageInfo));
f01013a3:	83 c4 08             	add    $0x8,%esp
f01013a6:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f01013ab:	c1 e0 03             	shl    $0x3,%eax
f01013ae:	50                   	push   %eax
f01013af:	68 7c 6e 10 f0       	push   $0xf0106e7c
f01013b4:	e8 a9 23 00 00       	call   f0103762 <cprintf>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env*)boot_alloc(NENV*sizeof(struct Env));
f01013b9:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01013be:	e8 2b f6 ff ff       	call   f01009ee <boot_alloc>
f01013c3:	a3 4c f2 22 f0       	mov    %eax,0xf022f24c
	memset(envs, 0, NENV * sizeof(struct Env));
f01013c8:	83 c4 0c             	add    $0xc,%esp
f01013cb:	68 00 f0 01 00       	push   $0x1f000
f01013d0:	6a 00                	push   $0x0
f01013d2:	50                   	push   %eax
f01013d3:	e8 8c 43 00 00       	call   f0105764 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01013d8:	e8 df f9 ff ff       	call   f0100dbc <page_init>

	check_page_free_list(1);
f01013dd:	b8 01 00 00 00       	mov    $0x1,%eax
f01013e2:	e8 d3 f6 ff ff       	call   f0100aba <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01013e7:	83 c4 10             	add    $0x10,%esp
f01013ea:	83 3d 90 fe 22 f0 00 	cmpl   $0x0,0xf022fe90
f01013f1:	75 17                	jne    f010140a <mem_init+0x1cf>
		panic("'pages' is a null pointer!");
f01013f3:	83 ec 04             	sub    $0x4,%esp
f01013f6:	68 45 6a 10 f0       	push   $0xf0106a45
f01013fb:	68 02 03 00 00       	push   $0x302
f0101400:	68 4c 69 10 f0       	push   $0xf010694c
f0101405:	e8 36 ec ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010140a:	a1 44 f2 22 f0       	mov    0xf022f244,%eax
f010140f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101414:	eb 05                	jmp    f010141b <mem_init+0x1e0>
		++nfree;
f0101416:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101419:	8b 00                	mov    (%eax),%eax
f010141b:	85 c0                	test   %eax,%eax
f010141d:	75 f7                	jne    f0101416 <mem_init+0x1db>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010141f:	83 ec 0c             	sub    $0xc,%esp
f0101422:	6a 00                	push   $0x0
f0101424:	e8 97 fa ff ff       	call   f0100ec0 <page_alloc>
f0101429:	89 c7                	mov    %eax,%edi
f010142b:	83 c4 10             	add    $0x10,%esp
f010142e:	85 c0                	test   %eax,%eax
f0101430:	75 19                	jne    f010144b <mem_init+0x210>
f0101432:	68 60 6a 10 f0       	push   $0xf0106a60
f0101437:	68 72 69 10 f0       	push   $0xf0106972
f010143c:	68 0a 03 00 00       	push   $0x30a
f0101441:	68 4c 69 10 f0       	push   $0xf010694c
f0101446:	e8 f5 eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010144b:	83 ec 0c             	sub    $0xc,%esp
f010144e:	6a 00                	push   $0x0
f0101450:	e8 6b fa ff ff       	call   f0100ec0 <page_alloc>
f0101455:	89 c6                	mov    %eax,%esi
f0101457:	83 c4 10             	add    $0x10,%esp
f010145a:	85 c0                	test   %eax,%eax
f010145c:	75 19                	jne    f0101477 <mem_init+0x23c>
f010145e:	68 76 6a 10 f0       	push   $0xf0106a76
f0101463:	68 72 69 10 f0       	push   $0xf0106972
f0101468:	68 0b 03 00 00       	push   $0x30b
f010146d:	68 4c 69 10 f0       	push   $0xf010694c
f0101472:	e8 c9 eb ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101477:	83 ec 0c             	sub    $0xc,%esp
f010147a:	6a 00                	push   $0x0
f010147c:	e8 3f fa ff ff       	call   f0100ec0 <page_alloc>
f0101481:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101484:	83 c4 10             	add    $0x10,%esp
f0101487:	85 c0                	test   %eax,%eax
f0101489:	75 19                	jne    f01014a4 <mem_init+0x269>
f010148b:	68 8c 6a 10 f0       	push   $0xf0106a8c
f0101490:	68 72 69 10 f0       	push   $0xf0106972
f0101495:	68 0c 03 00 00       	push   $0x30c
f010149a:	68 4c 69 10 f0       	push   $0xf010694c
f010149f:	e8 9c eb ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01014a4:	39 f7                	cmp    %esi,%edi
f01014a6:	75 19                	jne    f01014c1 <mem_init+0x286>
f01014a8:	68 a2 6a 10 f0       	push   $0xf0106aa2
f01014ad:	68 72 69 10 f0       	push   $0xf0106972
f01014b2:	68 0f 03 00 00       	push   $0x30f
f01014b7:	68 4c 69 10 f0       	push   $0xf010694c
f01014bc:	e8 7f eb ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014c4:	39 c6                	cmp    %eax,%esi
f01014c6:	74 04                	je     f01014cc <mem_init+0x291>
f01014c8:	39 c7                	cmp    %eax,%edi
f01014ca:	75 19                	jne    f01014e5 <mem_init+0x2aa>
f01014cc:	68 a0 6e 10 f0       	push   $0xf0106ea0
f01014d1:	68 72 69 10 f0       	push   $0xf0106972
f01014d6:	68 10 03 00 00       	push   $0x310
f01014db:	68 4c 69 10 f0       	push   $0xf010694c
f01014e0:	e8 5b eb ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f01014e5:	8b 0d 90 fe 22 f0    	mov    0xf022fe90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01014eb:	8b 15 88 fe 22 f0    	mov    0xf022fe88,%edx
f01014f1:	c1 e2 0c             	shl    $0xc,%edx
f01014f4:	89 f8                	mov    %edi,%eax
f01014f6:	29 c8                	sub    %ecx,%eax
f01014f8:	c1 f8 03             	sar    $0x3,%eax
f01014fb:	c1 e0 0c             	shl    $0xc,%eax
f01014fe:	39 d0                	cmp    %edx,%eax
f0101500:	72 19                	jb     f010151b <mem_init+0x2e0>
f0101502:	68 b4 6a 10 f0       	push   $0xf0106ab4
f0101507:	68 72 69 10 f0       	push   $0xf0106972
f010150c:	68 11 03 00 00       	push   $0x311
f0101511:	68 4c 69 10 f0       	push   $0xf010694c
f0101516:	e8 25 eb ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010151b:	89 f0                	mov    %esi,%eax
f010151d:	29 c8                	sub    %ecx,%eax
f010151f:	c1 f8 03             	sar    $0x3,%eax
f0101522:	c1 e0 0c             	shl    $0xc,%eax
f0101525:	39 c2                	cmp    %eax,%edx
f0101527:	77 19                	ja     f0101542 <mem_init+0x307>
f0101529:	68 d1 6a 10 f0       	push   $0xf0106ad1
f010152e:	68 72 69 10 f0       	push   $0xf0106972
f0101533:	68 12 03 00 00       	push   $0x312
f0101538:	68 4c 69 10 f0       	push   $0xf010694c
f010153d:	e8 fe ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101542:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101545:	29 c8                	sub    %ecx,%eax
f0101547:	c1 f8 03             	sar    $0x3,%eax
f010154a:	c1 e0 0c             	shl    $0xc,%eax
f010154d:	39 c2                	cmp    %eax,%edx
f010154f:	77 19                	ja     f010156a <mem_init+0x32f>
f0101551:	68 ee 6a 10 f0       	push   $0xf0106aee
f0101556:	68 72 69 10 f0       	push   $0xf0106972
f010155b:	68 13 03 00 00       	push   $0x313
f0101560:	68 4c 69 10 f0       	push   $0xf010694c
f0101565:	e8 d6 ea ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010156a:	a1 44 f2 22 f0       	mov    0xf022f244,%eax
f010156f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101572:	c7 05 44 f2 22 f0 00 	movl   $0x0,0xf022f244
f0101579:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010157c:	83 ec 0c             	sub    $0xc,%esp
f010157f:	6a 00                	push   $0x0
f0101581:	e8 3a f9 ff ff       	call   f0100ec0 <page_alloc>
f0101586:	83 c4 10             	add    $0x10,%esp
f0101589:	85 c0                	test   %eax,%eax
f010158b:	74 19                	je     f01015a6 <mem_init+0x36b>
f010158d:	68 0b 6b 10 f0       	push   $0xf0106b0b
f0101592:	68 72 69 10 f0       	push   $0xf0106972
f0101597:	68 1a 03 00 00       	push   $0x31a
f010159c:	68 4c 69 10 f0       	push   $0xf010694c
f01015a1:	e8 9a ea ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01015a6:	83 ec 0c             	sub    $0xc,%esp
f01015a9:	57                   	push   %edi
f01015aa:	e8 81 f9 ff ff       	call   f0100f30 <page_free>
	page_free(pp1);
f01015af:	89 34 24             	mov    %esi,(%esp)
f01015b2:	e8 79 f9 ff ff       	call   f0100f30 <page_free>
	page_free(pp2);
f01015b7:	83 c4 04             	add    $0x4,%esp
f01015ba:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015bd:	e8 6e f9 ff ff       	call   f0100f30 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015c9:	e8 f2 f8 ff ff       	call   f0100ec0 <page_alloc>
f01015ce:	89 c6                	mov    %eax,%esi
f01015d0:	83 c4 10             	add    $0x10,%esp
f01015d3:	85 c0                	test   %eax,%eax
f01015d5:	75 19                	jne    f01015f0 <mem_init+0x3b5>
f01015d7:	68 60 6a 10 f0       	push   $0xf0106a60
f01015dc:	68 72 69 10 f0       	push   $0xf0106972
f01015e1:	68 21 03 00 00       	push   $0x321
f01015e6:	68 4c 69 10 f0       	push   $0xf010694c
f01015eb:	e8 50 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01015f0:	83 ec 0c             	sub    $0xc,%esp
f01015f3:	6a 00                	push   $0x0
f01015f5:	e8 c6 f8 ff ff       	call   f0100ec0 <page_alloc>
f01015fa:	89 c7                	mov    %eax,%edi
f01015fc:	83 c4 10             	add    $0x10,%esp
f01015ff:	85 c0                	test   %eax,%eax
f0101601:	75 19                	jne    f010161c <mem_init+0x3e1>
f0101603:	68 76 6a 10 f0       	push   $0xf0106a76
f0101608:	68 72 69 10 f0       	push   $0xf0106972
f010160d:	68 22 03 00 00       	push   $0x322
f0101612:	68 4c 69 10 f0       	push   $0xf010694c
f0101617:	e8 24 ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010161c:	83 ec 0c             	sub    $0xc,%esp
f010161f:	6a 00                	push   $0x0
f0101621:	e8 9a f8 ff ff       	call   f0100ec0 <page_alloc>
f0101626:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101629:	83 c4 10             	add    $0x10,%esp
f010162c:	85 c0                	test   %eax,%eax
f010162e:	75 19                	jne    f0101649 <mem_init+0x40e>
f0101630:	68 8c 6a 10 f0       	push   $0xf0106a8c
f0101635:	68 72 69 10 f0       	push   $0xf0106972
f010163a:	68 23 03 00 00       	push   $0x323
f010163f:	68 4c 69 10 f0       	push   $0xf010694c
f0101644:	e8 f7 e9 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101649:	39 fe                	cmp    %edi,%esi
f010164b:	75 19                	jne    f0101666 <mem_init+0x42b>
f010164d:	68 a2 6a 10 f0       	push   $0xf0106aa2
f0101652:	68 72 69 10 f0       	push   $0xf0106972
f0101657:	68 25 03 00 00       	push   $0x325
f010165c:	68 4c 69 10 f0       	push   $0xf010694c
f0101661:	e8 da e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101666:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101669:	39 c7                	cmp    %eax,%edi
f010166b:	74 04                	je     f0101671 <mem_init+0x436>
f010166d:	39 c6                	cmp    %eax,%esi
f010166f:	75 19                	jne    f010168a <mem_init+0x44f>
f0101671:	68 a0 6e 10 f0       	push   $0xf0106ea0
f0101676:	68 72 69 10 f0       	push   $0xf0106972
f010167b:	68 26 03 00 00       	push   $0x326
f0101680:	68 4c 69 10 f0       	push   $0xf010694c
f0101685:	e8 b6 e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010168a:	83 ec 0c             	sub    $0xc,%esp
f010168d:	6a 00                	push   $0x0
f010168f:	e8 2c f8 ff ff       	call   f0100ec0 <page_alloc>
f0101694:	83 c4 10             	add    $0x10,%esp
f0101697:	85 c0                	test   %eax,%eax
f0101699:	74 19                	je     f01016b4 <mem_init+0x479>
f010169b:	68 0b 6b 10 f0       	push   $0xf0106b0b
f01016a0:	68 72 69 10 f0       	push   $0xf0106972
f01016a5:	68 27 03 00 00       	push   $0x327
f01016aa:	68 4c 69 10 f0       	push   $0xf010694c
f01016af:	e8 8c e9 ff ff       	call   f0100040 <_panic>
f01016b4:	89 f0                	mov    %esi,%eax
f01016b6:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f01016bc:	c1 f8 03             	sar    $0x3,%eax
f01016bf:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016c2:	89 c2                	mov    %eax,%edx
f01016c4:	c1 ea 0c             	shr    $0xc,%edx
f01016c7:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f01016cd:	72 12                	jb     f01016e1 <mem_init+0x4a6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016cf:	50                   	push   %eax
f01016d0:	68 44 64 10 f0       	push   $0xf0106444
f01016d5:	6a 58                	push   $0x58
f01016d7:	68 58 69 10 f0       	push   $0xf0106958
f01016dc:	e8 5f e9 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01016e1:	83 ec 04             	sub    $0x4,%esp
f01016e4:	68 00 10 00 00       	push   $0x1000
f01016e9:	6a 01                	push   $0x1
f01016eb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01016f0:	50                   	push   %eax
f01016f1:	e8 6e 40 00 00       	call   f0105764 <memset>
	page_free(pp0);
f01016f6:	89 34 24             	mov    %esi,(%esp)
f01016f9:	e8 32 f8 ff ff       	call   f0100f30 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01016fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101705:	e8 b6 f7 ff ff       	call   f0100ec0 <page_alloc>
f010170a:	83 c4 10             	add    $0x10,%esp
f010170d:	85 c0                	test   %eax,%eax
f010170f:	75 19                	jne    f010172a <mem_init+0x4ef>
f0101711:	68 1a 6b 10 f0       	push   $0xf0106b1a
f0101716:	68 72 69 10 f0       	push   $0xf0106972
f010171b:	68 2c 03 00 00       	push   $0x32c
f0101720:	68 4c 69 10 f0       	push   $0xf010694c
f0101725:	e8 16 e9 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f010172a:	39 c6                	cmp    %eax,%esi
f010172c:	74 19                	je     f0101747 <mem_init+0x50c>
f010172e:	68 38 6b 10 f0       	push   $0xf0106b38
f0101733:	68 72 69 10 f0       	push   $0xf0106972
f0101738:	68 2d 03 00 00       	push   $0x32d
f010173d:	68 4c 69 10 f0       	push   $0xf010694c
f0101742:	e8 f9 e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f0101747:	89 f0                	mov    %esi,%eax
f0101749:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f010174f:	c1 f8 03             	sar    $0x3,%eax
f0101752:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101755:	89 c2                	mov    %eax,%edx
f0101757:	c1 ea 0c             	shr    $0xc,%edx
f010175a:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0101760:	72 12                	jb     f0101774 <mem_init+0x539>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101762:	50                   	push   %eax
f0101763:	68 44 64 10 f0       	push   $0xf0106444
f0101768:	6a 58                	push   $0x58
f010176a:	68 58 69 10 f0       	push   $0xf0106958
f010176f:	e8 cc e8 ff ff       	call   f0100040 <_panic>
f0101774:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f010177a:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101780:	80 38 00             	cmpb   $0x0,(%eax)
f0101783:	74 19                	je     f010179e <mem_init+0x563>
f0101785:	68 48 6b 10 f0       	push   $0xf0106b48
f010178a:	68 72 69 10 f0       	push   $0xf0106972
f010178f:	68 30 03 00 00       	push   $0x330
f0101794:	68 4c 69 10 f0       	push   $0xf010694c
f0101799:	e8 a2 e8 ff ff       	call   f0100040 <_panic>
f010179e:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01017a1:	39 d0                	cmp    %edx,%eax
f01017a3:	75 db                	jne    f0101780 <mem_init+0x545>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01017a5:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01017a8:	a3 44 f2 22 f0       	mov    %eax,0xf022f244

	// free the pages we took
	page_free(pp0);
f01017ad:	83 ec 0c             	sub    $0xc,%esp
f01017b0:	56                   	push   %esi
f01017b1:	e8 7a f7 ff ff       	call   f0100f30 <page_free>
	page_free(pp1);
f01017b6:	89 3c 24             	mov    %edi,(%esp)
f01017b9:	e8 72 f7 ff ff       	call   f0100f30 <page_free>
	page_free(pp2);
f01017be:	83 c4 04             	add    $0x4,%esp
f01017c1:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017c4:	e8 67 f7 ff ff       	call   f0100f30 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017c9:	a1 44 f2 22 f0       	mov    0xf022f244,%eax
f01017ce:	83 c4 10             	add    $0x10,%esp
f01017d1:	eb 05                	jmp    f01017d8 <mem_init+0x59d>
		--nfree;
f01017d3:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017d6:	8b 00                	mov    (%eax),%eax
f01017d8:	85 c0                	test   %eax,%eax
f01017da:	75 f7                	jne    f01017d3 <mem_init+0x598>
		--nfree;
	assert(nfree == 0);
f01017dc:	85 db                	test   %ebx,%ebx
f01017de:	74 19                	je     f01017f9 <mem_init+0x5be>
f01017e0:	68 52 6b 10 f0       	push   $0xf0106b52
f01017e5:	68 72 69 10 f0       	push   $0xf0106972
f01017ea:	68 3d 03 00 00       	push   $0x33d
f01017ef:	68 4c 69 10 f0       	push   $0xf010694c
f01017f4:	e8 47 e8 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01017f9:	83 ec 0c             	sub    $0xc,%esp
f01017fc:	68 c0 6e 10 f0       	push   $0xf0106ec0
f0101801:	e8 5c 1f 00 00       	call   f0103762 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101806:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010180d:	e8 ae f6 ff ff       	call   f0100ec0 <page_alloc>
f0101812:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101815:	83 c4 10             	add    $0x10,%esp
f0101818:	85 c0                	test   %eax,%eax
f010181a:	75 19                	jne    f0101835 <mem_init+0x5fa>
f010181c:	68 60 6a 10 f0       	push   $0xf0106a60
f0101821:	68 72 69 10 f0       	push   $0xf0106972
f0101826:	68 a3 03 00 00       	push   $0x3a3
f010182b:	68 4c 69 10 f0       	push   $0xf010694c
f0101830:	e8 0b e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101835:	83 ec 0c             	sub    $0xc,%esp
f0101838:	6a 00                	push   $0x0
f010183a:	e8 81 f6 ff ff       	call   f0100ec0 <page_alloc>
f010183f:	89 c3                	mov    %eax,%ebx
f0101841:	83 c4 10             	add    $0x10,%esp
f0101844:	85 c0                	test   %eax,%eax
f0101846:	75 19                	jne    f0101861 <mem_init+0x626>
f0101848:	68 76 6a 10 f0       	push   $0xf0106a76
f010184d:	68 72 69 10 f0       	push   $0xf0106972
f0101852:	68 a4 03 00 00       	push   $0x3a4
f0101857:	68 4c 69 10 f0       	push   $0xf010694c
f010185c:	e8 df e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101861:	83 ec 0c             	sub    $0xc,%esp
f0101864:	6a 00                	push   $0x0
f0101866:	e8 55 f6 ff ff       	call   f0100ec0 <page_alloc>
f010186b:	89 c6                	mov    %eax,%esi
f010186d:	83 c4 10             	add    $0x10,%esp
f0101870:	85 c0                	test   %eax,%eax
f0101872:	75 19                	jne    f010188d <mem_init+0x652>
f0101874:	68 8c 6a 10 f0       	push   $0xf0106a8c
f0101879:	68 72 69 10 f0       	push   $0xf0106972
f010187e:	68 a5 03 00 00       	push   $0x3a5
f0101883:	68 4c 69 10 f0       	push   $0xf010694c
f0101888:	e8 b3 e7 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010188d:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101890:	75 19                	jne    f01018ab <mem_init+0x670>
f0101892:	68 a2 6a 10 f0       	push   $0xf0106aa2
f0101897:	68 72 69 10 f0       	push   $0xf0106972
f010189c:	68 a8 03 00 00       	push   $0x3a8
f01018a1:	68 4c 69 10 f0       	push   $0xf010694c
f01018a6:	e8 95 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018ab:	39 c3                	cmp    %eax,%ebx
f01018ad:	74 05                	je     f01018b4 <mem_init+0x679>
f01018af:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01018b2:	75 19                	jne    f01018cd <mem_init+0x692>
f01018b4:	68 a0 6e 10 f0       	push   $0xf0106ea0
f01018b9:	68 72 69 10 f0       	push   $0xf0106972
f01018be:	68 a9 03 00 00       	push   $0x3a9
f01018c3:	68 4c 69 10 f0       	push   $0xf010694c
f01018c8:	e8 73 e7 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018cd:	a1 44 f2 22 f0       	mov    0xf022f244,%eax
f01018d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01018d5:	c7 05 44 f2 22 f0 00 	movl   $0x0,0xf022f244
f01018dc:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018df:	83 ec 0c             	sub    $0xc,%esp
f01018e2:	6a 00                	push   $0x0
f01018e4:	e8 d7 f5 ff ff       	call   f0100ec0 <page_alloc>
f01018e9:	83 c4 10             	add    $0x10,%esp
f01018ec:	85 c0                	test   %eax,%eax
f01018ee:	74 19                	je     f0101909 <mem_init+0x6ce>
f01018f0:	68 0b 6b 10 f0       	push   $0xf0106b0b
f01018f5:	68 72 69 10 f0       	push   $0xf0106972
f01018fa:	68 b0 03 00 00       	push   $0x3b0
f01018ff:	68 4c 69 10 f0       	push   $0xf010694c
f0101904:	e8 37 e7 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101909:	83 ec 04             	sub    $0x4,%esp
f010190c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010190f:	50                   	push   %eax
f0101910:	6a 00                	push   $0x0
f0101912:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101918:	e8 98 f7 ff ff       	call   f01010b5 <page_lookup>
f010191d:	83 c4 10             	add    $0x10,%esp
f0101920:	85 c0                	test   %eax,%eax
f0101922:	74 19                	je     f010193d <mem_init+0x702>
f0101924:	68 e0 6e 10 f0       	push   $0xf0106ee0
f0101929:	68 72 69 10 f0       	push   $0xf0106972
f010192e:	68 b3 03 00 00       	push   $0x3b3
f0101933:	68 4c 69 10 f0       	push   $0xf010694c
f0101938:	e8 03 e7 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010193d:	6a 02                	push   $0x2
f010193f:	6a 00                	push   $0x0
f0101941:	53                   	push   %ebx
f0101942:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101948:	e8 49 f8 ff ff       	call   f0101196 <page_insert>
f010194d:	83 c4 10             	add    $0x10,%esp
f0101950:	85 c0                	test   %eax,%eax
f0101952:	78 19                	js     f010196d <mem_init+0x732>
f0101954:	68 18 6f 10 f0       	push   $0xf0106f18
f0101959:	68 72 69 10 f0       	push   $0xf0106972
f010195e:	68 b6 03 00 00       	push   $0x3b6
f0101963:	68 4c 69 10 f0       	push   $0xf010694c
f0101968:	e8 d3 e6 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010196d:	83 ec 0c             	sub    $0xc,%esp
f0101970:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101973:	e8 b8 f5 ff ff       	call   f0100f30 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101978:	6a 02                	push   $0x2
f010197a:	6a 00                	push   $0x0
f010197c:	53                   	push   %ebx
f010197d:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101983:	e8 0e f8 ff ff       	call   f0101196 <page_insert>
f0101988:	83 c4 20             	add    $0x20,%esp
f010198b:	85 c0                	test   %eax,%eax
f010198d:	74 19                	je     f01019a8 <mem_init+0x76d>
f010198f:	68 48 6f 10 f0       	push   $0xf0106f48
f0101994:	68 72 69 10 f0       	push   $0xf0106972
f0101999:	68 ba 03 00 00       	push   $0x3ba
f010199e:	68 4c 69 10 f0       	push   $0xf010694c
f01019a3:	e8 98 e6 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019a8:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f01019ae:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
f01019b3:	89 c1                	mov    %eax,%ecx
f01019b5:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01019b8:	8b 17                	mov    (%edi),%edx
f01019ba:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019c3:	29 c8                	sub    %ecx,%eax
f01019c5:	c1 f8 03             	sar    $0x3,%eax
f01019c8:	c1 e0 0c             	shl    $0xc,%eax
f01019cb:	39 c2                	cmp    %eax,%edx
f01019cd:	74 19                	je     f01019e8 <mem_init+0x7ad>
f01019cf:	68 78 6f 10 f0       	push   $0xf0106f78
f01019d4:	68 72 69 10 f0       	push   $0xf0106972
f01019d9:	68 bb 03 00 00       	push   $0x3bb
f01019de:	68 4c 69 10 f0       	push   $0xf010694c
f01019e3:	e8 58 e6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01019e8:	ba 00 00 00 00       	mov    $0x0,%edx
f01019ed:	89 f8                	mov    %edi,%eax
f01019ef:	e8 62 f0 ff ff       	call   f0100a56 <check_va2pa>
f01019f4:	89 da                	mov    %ebx,%edx
f01019f6:	2b 55 cc             	sub    -0x34(%ebp),%edx
f01019f9:	c1 fa 03             	sar    $0x3,%edx
f01019fc:	c1 e2 0c             	shl    $0xc,%edx
f01019ff:	39 d0                	cmp    %edx,%eax
f0101a01:	74 19                	je     f0101a1c <mem_init+0x7e1>
f0101a03:	68 a0 6f 10 f0       	push   $0xf0106fa0
f0101a08:	68 72 69 10 f0       	push   $0xf0106972
f0101a0d:	68 bc 03 00 00       	push   $0x3bc
f0101a12:	68 4c 69 10 f0       	push   $0xf010694c
f0101a17:	e8 24 e6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101a1c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a21:	74 19                	je     f0101a3c <mem_init+0x801>
f0101a23:	68 5d 6b 10 f0       	push   $0xf0106b5d
f0101a28:	68 72 69 10 f0       	push   $0xf0106972
f0101a2d:	68 bd 03 00 00       	push   $0x3bd
f0101a32:	68 4c 69 10 f0       	push   $0xf010694c
f0101a37:	e8 04 e6 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101a3c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a3f:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a44:	74 19                	je     f0101a5f <mem_init+0x824>
f0101a46:	68 6e 6b 10 f0       	push   $0xf0106b6e
f0101a4b:	68 72 69 10 f0       	push   $0xf0106972
f0101a50:	68 be 03 00 00       	push   $0x3be
f0101a55:	68 4c 69 10 f0       	push   $0xf010694c
f0101a5a:	e8 e1 e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a5f:	6a 02                	push   $0x2
f0101a61:	68 00 10 00 00       	push   $0x1000
f0101a66:	56                   	push   %esi
f0101a67:	57                   	push   %edi
f0101a68:	e8 29 f7 ff ff       	call   f0101196 <page_insert>
f0101a6d:	83 c4 10             	add    $0x10,%esp
f0101a70:	85 c0                	test   %eax,%eax
f0101a72:	74 19                	je     f0101a8d <mem_init+0x852>
f0101a74:	68 d0 6f 10 f0       	push   $0xf0106fd0
f0101a79:	68 72 69 10 f0       	push   $0xf0106972
f0101a7e:	68 c1 03 00 00       	push   $0x3c1
f0101a83:	68 4c 69 10 f0       	push   $0xf010694c
f0101a88:	e8 b3 e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a8d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a92:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101a97:	e8 ba ef ff ff       	call   f0100a56 <check_va2pa>
f0101a9c:	89 f2                	mov    %esi,%edx
f0101a9e:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0101aa4:	c1 fa 03             	sar    $0x3,%edx
f0101aa7:	c1 e2 0c             	shl    $0xc,%edx
f0101aaa:	39 d0                	cmp    %edx,%eax
f0101aac:	74 19                	je     f0101ac7 <mem_init+0x88c>
f0101aae:	68 0c 70 10 f0       	push   $0xf010700c
f0101ab3:	68 72 69 10 f0       	push   $0xf0106972
f0101ab8:	68 c2 03 00 00       	push   $0x3c2
f0101abd:	68 4c 69 10 f0       	push   $0xf010694c
f0101ac2:	e8 79 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ac7:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101acc:	74 19                	je     f0101ae7 <mem_init+0x8ac>
f0101ace:	68 7f 6b 10 f0       	push   $0xf0106b7f
f0101ad3:	68 72 69 10 f0       	push   $0xf0106972
f0101ad8:	68 c3 03 00 00       	push   $0x3c3
f0101add:	68 4c 69 10 f0       	push   $0xf010694c
f0101ae2:	e8 59 e5 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101ae7:	83 ec 0c             	sub    $0xc,%esp
f0101aea:	6a 00                	push   $0x0
f0101aec:	e8 cf f3 ff ff       	call   f0100ec0 <page_alloc>
f0101af1:	83 c4 10             	add    $0x10,%esp
f0101af4:	85 c0                	test   %eax,%eax
f0101af6:	74 19                	je     f0101b11 <mem_init+0x8d6>
f0101af8:	68 0b 6b 10 f0       	push   $0xf0106b0b
f0101afd:	68 72 69 10 f0       	push   $0xf0106972
f0101b02:	68 c6 03 00 00       	push   $0x3c6
f0101b07:	68 4c 69 10 f0       	push   $0xf010694c
f0101b0c:	e8 2f e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b11:	6a 02                	push   $0x2
f0101b13:	68 00 10 00 00       	push   $0x1000
f0101b18:	56                   	push   %esi
f0101b19:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101b1f:	e8 72 f6 ff ff       	call   f0101196 <page_insert>
f0101b24:	83 c4 10             	add    $0x10,%esp
f0101b27:	85 c0                	test   %eax,%eax
f0101b29:	74 19                	je     f0101b44 <mem_init+0x909>
f0101b2b:	68 d0 6f 10 f0       	push   $0xf0106fd0
f0101b30:	68 72 69 10 f0       	push   $0xf0106972
f0101b35:	68 c9 03 00 00       	push   $0x3c9
f0101b3a:	68 4c 69 10 f0       	push   $0xf010694c
f0101b3f:	e8 fc e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b44:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b49:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101b4e:	e8 03 ef ff ff       	call   f0100a56 <check_va2pa>
f0101b53:	89 f2                	mov    %esi,%edx
f0101b55:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0101b5b:	c1 fa 03             	sar    $0x3,%edx
f0101b5e:	c1 e2 0c             	shl    $0xc,%edx
f0101b61:	39 d0                	cmp    %edx,%eax
f0101b63:	74 19                	je     f0101b7e <mem_init+0x943>
f0101b65:	68 0c 70 10 f0       	push   $0xf010700c
f0101b6a:	68 72 69 10 f0       	push   $0xf0106972
f0101b6f:	68 ca 03 00 00       	push   $0x3ca
f0101b74:	68 4c 69 10 f0       	push   $0xf010694c
f0101b79:	e8 c2 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101b7e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b83:	74 19                	je     f0101b9e <mem_init+0x963>
f0101b85:	68 7f 6b 10 f0       	push   $0xf0106b7f
f0101b8a:	68 72 69 10 f0       	push   $0xf0106972
f0101b8f:	68 cb 03 00 00       	push   $0x3cb
f0101b94:	68 4c 69 10 f0       	push   $0xf010694c
f0101b99:	e8 a2 e4 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101b9e:	83 ec 0c             	sub    $0xc,%esp
f0101ba1:	6a 00                	push   $0x0
f0101ba3:	e8 18 f3 ff ff       	call   f0100ec0 <page_alloc>
f0101ba8:	83 c4 10             	add    $0x10,%esp
f0101bab:	85 c0                	test   %eax,%eax
f0101bad:	74 19                	je     f0101bc8 <mem_init+0x98d>
f0101baf:	68 0b 6b 10 f0       	push   $0xf0106b0b
f0101bb4:	68 72 69 10 f0       	push   $0xf0106972
f0101bb9:	68 cf 03 00 00       	push   $0x3cf
f0101bbe:	68 4c 69 10 f0       	push   $0xf010694c
f0101bc3:	e8 78 e4 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101bc8:	8b 15 8c fe 22 f0    	mov    0xf022fe8c,%edx
f0101bce:	8b 02                	mov    (%edx),%eax
f0101bd0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101bd5:	89 c1                	mov    %eax,%ecx
f0101bd7:	c1 e9 0c             	shr    $0xc,%ecx
f0101bda:	3b 0d 88 fe 22 f0    	cmp    0xf022fe88,%ecx
f0101be0:	72 15                	jb     f0101bf7 <mem_init+0x9bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101be2:	50                   	push   %eax
f0101be3:	68 44 64 10 f0       	push   $0xf0106444
f0101be8:	68 d2 03 00 00       	push   $0x3d2
f0101bed:	68 4c 69 10 f0       	push   $0xf010694c
f0101bf2:	e8 49 e4 ff ff       	call   f0100040 <_panic>
f0101bf7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101bfc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101bff:	83 ec 04             	sub    $0x4,%esp
f0101c02:	6a 00                	push   $0x0
f0101c04:	68 00 10 00 00       	push   $0x1000
f0101c09:	52                   	push   %edx
f0101c0a:	e8 83 f3 ff ff       	call   f0100f92 <pgdir_walk>
f0101c0f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101c12:	8d 51 04             	lea    0x4(%ecx),%edx
f0101c15:	83 c4 10             	add    $0x10,%esp
f0101c18:	39 d0                	cmp    %edx,%eax
f0101c1a:	74 19                	je     f0101c35 <mem_init+0x9fa>
f0101c1c:	68 3c 70 10 f0       	push   $0xf010703c
f0101c21:	68 72 69 10 f0       	push   $0xf0106972
f0101c26:	68 d3 03 00 00       	push   $0x3d3
f0101c2b:	68 4c 69 10 f0       	push   $0xf010694c
f0101c30:	e8 0b e4 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101c35:	6a 06                	push   $0x6
f0101c37:	68 00 10 00 00       	push   $0x1000
f0101c3c:	56                   	push   %esi
f0101c3d:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101c43:	e8 4e f5 ff ff       	call   f0101196 <page_insert>
f0101c48:	83 c4 10             	add    $0x10,%esp
f0101c4b:	85 c0                	test   %eax,%eax
f0101c4d:	74 19                	je     f0101c68 <mem_init+0xa2d>
f0101c4f:	68 7c 70 10 f0       	push   $0xf010707c
f0101c54:	68 72 69 10 f0       	push   $0xf0106972
f0101c59:	68 d6 03 00 00       	push   $0x3d6
f0101c5e:	68 4c 69 10 f0       	push   $0xf010694c
f0101c63:	e8 d8 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c68:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0101c6e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c73:	89 f8                	mov    %edi,%eax
f0101c75:	e8 dc ed ff ff       	call   f0100a56 <check_va2pa>
f0101c7a:	89 f2                	mov    %esi,%edx
f0101c7c:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0101c82:	c1 fa 03             	sar    $0x3,%edx
f0101c85:	c1 e2 0c             	shl    $0xc,%edx
f0101c88:	39 d0                	cmp    %edx,%eax
f0101c8a:	74 19                	je     f0101ca5 <mem_init+0xa6a>
f0101c8c:	68 0c 70 10 f0       	push   $0xf010700c
f0101c91:	68 72 69 10 f0       	push   $0xf0106972
f0101c96:	68 d7 03 00 00       	push   $0x3d7
f0101c9b:	68 4c 69 10 f0       	push   $0xf010694c
f0101ca0:	e8 9b e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ca5:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101caa:	74 19                	je     f0101cc5 <mem_init+0xa8a>
f0101cac:	68 7f 6b 10 f0       	push   $0xf0106b7f
f0101cb1:	68 72 69 10 f0       	push   $0xf0106972
f0101cb6:	68 d8 03 00 00       	push   $0x3d8
f0101cbb:	68 4c 69 10 f0       	push   $0xf010694c
f0101cc0:	e8 7b e3 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101cc5:	83 ec 04             	sub    $0x4,%esp
f0101cc8:	6a 00                	push   $0x0
f0101cca:	68 00 10 00 00       	push   $0x1000
f0101ccf:	57                   	push   %edi
f0101cd0:	e8 bd f2 ff ff       	call   f0100f92 <pgdir_walk>
f0101cd5:	83 c4 10             	add    $0x10,%esp
f0101cd8:	f6 00 04             	testb  $0x4,(%eax)
f0101cdb:	75 19                	jne    f0101cf6 <mem_init+0xabb>
f0101cdd:	68 bc 70 10 f0       	push   $0xf01070bc
f0101ce2:	68 72 69 10 f0       	push   $0xf0106972
f0101ce7:	68 d9 03 00 00       	push   $0x3d9
f0101cec:	68 4c 69 10 f0       	push   $0xf010694c
f0101cf1:	e8 4a e3 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101cf6:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101cfb:	f6 00 04             	testb  $0x4,(%eax)
f0101cfe:	75 19                	jne    f0101d19 <mem_init+0xade>
f0101d00:	68 90 6b 10 f0       	push   $0xf0106b90
f0101d05:	68 72 69 10 f0       	push   $0xf0106972
f0101d0a:	68 da 03 00 00       	push   $0x3da
f0101d0f:	68 4c 69 10 f0       	push   $0xf010694c
f0101d14:	e8 27 e3 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d19:	6a 02                	push   $0x2
f0101d1b:	68 00 10 00 00       	push   $0x1000
f0101d20:	56                   	push   %esi
f0101d21:	50                   	push   %eax
f0101d22:	e8 6f f4 ff ff       	call   f0101196 <page_insert>
f0101d27:	83 c4 10             	add    $0x10,%esp
f0101d2a:	85 c0                	test   %eax,%eax
f0101d2c:	74 19                	je     f0101d47 <mem_init+0xb0c>
f0101d2e:	68 d0 6f 10 f0       	push   $0xf0106fd0
f0101d33:	68 72 69 10 f0       	push   $0xf0106972
f0101d38:	68 dd 03 00 00       	push   $0x3dd
f0101d3d:	68 4c 69 10 f0       	push   $0xf010694c
f0101d42:	e8 f9 e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101d47:	83 ec 04             	sub    $0x4,%esp
f0101d4a:	6a 00                	push   $0x0
f0101d4c:	68 00 10 00 00       	push   $0x1000
f0101d51:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101d57:	e8 36 f2 ff ff       	call   f0100f92 <pgdir_walk>
f0101d5c:	83 c4 10             	add    $0x10,%esp
f0101d5f:	f6 00 02             	testb  $0x2,(%eax)
f0101d62:	75 19                	jne    f0101d7d <mem_init+0xb42>
f0101d64:	68 f0 70 10 f0       	push   $0xf01070f0
f0101d69:	68 72 69 10 f0       	push   $0xf0106972
f0101d6e:	68 de 03 00 00       	push   $0x3de
f0101d73:	68 4c 69 10 f0       	push   $0xf010694c
f0101d78:	e8 c3 e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d7d:	83 ec 04             	sub    $0x4,%esp
f0101d80:	6a 00                	push   $0x0
f0101d82:	68 00 10 00 00       	push   $0x1000
f0101d87:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101d8d:	e8 00 f2 ff ff       	call   f0100f92 <pgdir_walk>
f0101d92:	83 c4 10             	add    $0x10,%esp
f0101d95:	f6 00 04             	testb  $0x4,(%eax)
f0101d98:	74 19                	je     f0101db3 <mem_init+0xb78>
f0101d9a:	68 24 71 10 f0       	push   $0xf0107124
f0101d9f:	68 72 69 10 f0       	push   $0xf0106972
f0101da4:	68 df 03 00 00       	push   $0x3df
f0101da9:	68 4c 69 10 f0       	push   $0xf010694c
f0101dae:	e8 8d e2 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101db3:	6a 02                	push   $0x2
f0101db5:	68 00 00 40 00       	push   $0x400000
f0101dba:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101dbd:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101dc3:	e8 ce f3 ff ff       	call   f0101196 <page_insert>
f0101dc8:	83 c4 10             	add    $0x10,%esp
f0101dcb:	85 c0                	test   %eax,%eax
f0101dcd:	78 19                	js     f0101de8 <mem_init+0xbad>
f0101dcf:	68 5c 71 10 f0       	push   $0xf010715c
f0101dd4:	68 72 69 10 f0       	push   $0xf0106972
f0101dd9:	68 e2 03 00 00       	push   $0x3e2
f0101dde:	68 4c 69 10 f0       	push   $0xf010694c
f0101de3:	e8 58 e2 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101de8:	6a 02                	push   $0x2
f0101dea:	68 00 10 00 00       	push   $0x1000
f0101def:	53                   	push   %ebx
f0101df0:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101df6:	e8 9b f3 ff ff       	call   f0101196 <page_insert>
f0101dfb:	83 c4 10             	add    $0x10,%esp
f0101dfe:	85 c0                	test   %eax,%eax
f0101e00:	74 19                	je     f0101e1b <mem_init+0xbe0>
f0101e02:	68 94 71 10 f0       	push   $0xf0107194
f0101e07:	68 72 69 10 f0       	push   $0xf0106972
f0101e0c:	68 e5 03 00 00       	push   $0x3e5
f0101e11:	68 4c 69 10 f0       	push   $0xf010694c
f0101e16:	e8 25 e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e1b:	83 ec 04             	sub    $0x4,%esp
f0101e1e:	6a 00                	push   $0x0
f0101e20:	68 00 10 00 00       	push   $0x1000
f0101e25:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101e2b:	e8 62 f1 ff ff       	call   f0100f92 <pgdir_walk>
f0101e30:	83 c4 10             	add    $0x10,%esp
f0101e33:	f6 00 04             	testb  $0x4,(%eax)
f0101e36:	74 19                	je     f0101e51 <mem_init+0xc16>
f0101e38:	68 24 71 10 f0       	push   $0xf0107124
f0101e3d:	68 72 69 10 f0       	push   $0xf0106972
f0101e42:	68 e6 03 00 00       	push   $0x3e6
f0101e47:	68 4c 69 10 f0       	push   $0xf010694c
f0101e4c:	e8 ef e1 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101e51:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0101e57:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e5c:	89 f8                	mov    %edi,%eax
f0101e5e:	e8 f3 eb ff ff       	call   f0100a56 <check_va2pa>
f0101e63:	89 c1                	mov    %eax,%ecx
f0101e65:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e68:	89 d8                	mov    %ebx,%eax
f0101e6a:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0101e70:	c1 f8 03             	sar    $0x3,%eax
f0101e73:	c1 e0 0c             	shl    $0xc,%eax
f0101e76:	39 c1                	cmp    %eax,%ecx
f0101e78:	74 19                	je     f0101e93 <mem_init+0xc58>
f0101e7a:	68 d0 71 10 f0       	push   $0xf01071d0
f0101e7f:	68 72 69 10 f0       	push   $0xf0106972
f0101e84:	68 e9 03 00 00       	push   $0x3e9
f0101e89:	68 4c 69 10 f0       	push   $0xf010694c
f0101e8e:	e8 ad e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e93:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e98:	89 f8                	mov    %edi,%eax
f0101e9a:	e8 b7 eb ff ff       	call   f0100a56 <check_va2pa>
f0101e9f:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101ea2:	74 19                	je     f0101ebd <mem_init+0xc82>
f0101ea4:	68 fc 71 10 f0       	push   $0xf01071fc
f0101ea9:	68 72 69 10 f0       	push   $0xf0106972
f0101eae:	68 ea 03 00 00       	push   $0x3ea
f0101eb3:	68 4c 69 10 f0       	push   $0xf010694c
f0101eb8:	e8 83 e1 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101ebd:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101ec2:	74 19                	je     f0101edd <mem_init+0xca2>
f0101ec4:	68 a6 6b 10 f0       	push   $0xf0106ba6
f0101ec9:	68 72 69 10 f0       	push   $0xf0106972
f0101ece:	68 ec 03 00 00       	push   $0x3ec
f0101ed3:	68 4c 69 10 f0       	push   $0xf010694c
f0101ed8:	e8 63 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101edd:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101ee2:	74 19                	je     f0101efd <mem_init+0xcc2>
f0101ee4:	68 b7 6b 10 f0       	push   $0xf0106bb7
f0101ee9:	68 72 69 10 f0       	push   $0xf0106972
f0101eee:	68 ed 03 00 00       	push   $0x3ed
f0101ef3:	68 4c 69 10 f0       	push   $0xf010694c
f0101ef8:	e8 43 e1 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101efd:	83 ec 0c             	sub    $0xc,%esp
f0101f00:	6a 00                	push   $0x0
f0101f02:	e8 b9 ef ff ff       	call   f0100ec0 <page_alloc>
f0101f07:	83 c4 10             	add    $0x10,%esp
f0101f0a:	85 c0                	test   %eax,%eax
f0101f0c:	74 04                	je     f0101f12 <mem_init+0xcd7>
f0101f0e:	39 c6                	cmp    %eax,%esi
f0101f10:	74 19                	je     f0101f2b <mem_init+0xcf0>
f0101f12:	68 2c 72 10 f0       	push   $0xf010722c
f0101f17:	68 72 69 10 f0       	push   $0xf0106972
f0101f1c:	68 f0 03 00 00       	push   $0x3f0
f0101f21:	68 4c 69 10 f0       	push   $0xf010694c
f0101f26:	e8 15 e1 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101f2b:	83 ec 08             	sub    $0x8,%esp
f0101f2e:	6a 00                	push   $0x0
f0101f30:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101f36:	e8 15 f2 ff ff       	call   f0101150 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f3b:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0101f41:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f46:	89 f8                	mov    %edi,%eax
f0101f48:	e8 09 eb ff ff       	call   f0100a56 <check_va2pa>
f0101f4d:	83 c4 10             	add    $0x10,%esp
f0101f50:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f53:	74 19                	je     f0101f6e <mem_init+0xd33>
f0101f55:	68 50 72 10 f0       	push   $0xf0107250
f0101f5a:	68 72 69 10 f0       	push   $0xf0106972
f0101f5f:	68 f4 03 00 00       	push   $0x3f4
f0101f64:	68 4c 69 10 f0       	push   $0xf010694c
f0101f69:	e8 d2 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f6e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f73:	89 f8                	mov    %edi,%eax
f0101f75:	e8 dc ea ff ff       	call   f0100a56 <check_va2pa>
f0101f7a:	89 da                	mov    %ebx,%edx
f0101f7c:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0101f82:	c1 fa 03             	sar    $0x3,%edx
f0101f85:	c1 e2 0c             	shl    $0xc,%edx
f0101f88:	39 d0                	cmp    %edx,%eax
f0101f8a:	74 19                	je     f0101fa5 <mem_init+0xd6a>
f0101f8c:	68 fc 71 10 f0       	push   $0xf01071fc
f0101f91:	68 72 69 10 f0       	push   $0xf0106972
f0101f96:	68 f5 03 00 00       	push   $0x3f5
f0101f9b:	68 4c 69 10 f0       	push   $0xf010694c
f0101fa0:	e8 9b e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101fa5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101faa:	74 19                	je     f0101fc5 <mem_init+0xd8a>
f0101fac:	68 5d 6b 10 f0       	push   $0xf0106b5d
f0101fb1:	68 72 69 10 f0       	push   $0xf0106972
f0101fb6:	68 f6 03 00 00       	push   $0x3f6
f0101fbb:	68 4c 69 10 f0       	push   $0xf010694c
f0101fc0:	e8 7b e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101fc5:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fca:	74 19                	je     f0101fe5 <mem_init+0xdaa>
f0101fcc:	68 b7 6b 10 f0       	push   $0xf0106bb7
f0101fd1:	68 72 69 10 f0       	push   $0xf0106972
f0101fd6:	68 f7 03 00 00       	push   $0x3f7
f0101fdb:	68 4c 69 10 f0       	push   $0xf010694c
f0101fe0:	e8 5b e0 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101fe5:	6a 00                	push   $0x0
f0101fe7:	68 00 10 00 00       	push   $0x1000
f0101fec:	53                   	push   %ebx
f0101fed:	57                   	push   %edi
f0101fee:	e8 a3 f1 ff ff       	call   f0101196 <page_insert>
f0101ff3:	83 c4 10             	add    $0x10,%esp
f0101ff6:	85 c0                	test   %eax,%eax
f0101ff8:	74 19                	je     f0102013 <mem_init+0xdd8>
f0101ffa:	68 74 72 10 f0       	push   $0xf0107274
f0101fff:	68 72 69 10 f0       	push   $0xf0106972
f0102004:	68 fa 03 00 00       	push   $0x3fa
f0102009:	68 4c 69 10 f0       	push   $0xf010694c
f010200e:	e8 2d e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102013:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102018:	75 19                	jne    f0102033 <mem_init+0xdf8>
f010201a:	68 c8 6b 10 f0       	push   $0xf0106bc8
f010201f:	68 72 69 10 f0       	push   $0xf0106972
f0102024:	68 fb 03 00 00       	push   $0x3fb
f0102029:	68 4c 69 10 f0       	push   $0xf010694c
f010202e:	e8 0d e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102033:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102036:	74 19                	je     f0102051 <mem_init+0xe16>
f0102038:	68 d4 6b 10 f0       	push   $0xf0106bd4
f010203d:	68 72 69 10 f0       	push   $0xf0106972
f0102042:	68 fc 03 00 00       	push   $0x3fc
f0102047:	68 4c 69 10 f0       	push   $0xf010694c
f010204c:	e8 ef df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102051:	83 ec 08             	sub    $0x8,%esp
f0102054:	68 00 10 00 00       	push   $0x1000
f0102059:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f010205f:	e8 ec f0 ff ff       	call   f0101150 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102064:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f010206a:	ba 00 00 00 00       	mov    $0x0,%edx
f010206f:	89 f8                	mov    %edi,%eax
f0102071:	e8 e0 e9 ff ff       	call   f0100a56 <check_va2pa>
f0102076:	83 c4 10             	add    $0x10,%esp
f0102079:	83 f8 ff             	cmp    $0xffffffff,%eax
f010207c:	74 19                	je     f0102097 <mem_init+0xe5c>
f010207e:	68 50 72 10 f0       	push   $0xf0107250
f0102083:	68 72 69 10 f0       	push   $0xf0106972
f0102088:	68 00 04 00 00       	push   $0x400
f010208d:	68 4c 69 10 f0       	push   $0xf010694c
f0102092:	e8 a9 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102097:	ba 00 10 00 00       	mov    $0x1000,%edx
f010209c:	89 f8                	mov    %edi,%eax
f010209e:	e8 b3 e9 ff ff       	call   f0100a56 <check_va2pa>
f01020a3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020a6:	74 19                	je     f01020c1 <mem_init+0xe86>
f01020a8:	68 ac 72 10 f0       	push   $0xf01072ac
f01020ad:	68 72 69 10 f0       	push   $0xf0106972
f01020b2:	68 01 04 00 00       	push   $0x401
f01020b7:	68 4c 69 10 f0       	push   $0xf010694c
f01020bc:	e8 7f df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01020c1:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01020c6:	74 19                	je     f01020e1 <mem_init+0xea6>
f01020c8:	68 e9 6b 10 f0       	push   $0xf0106be9
f01020cd:	68 72 69 10 f0       	push   $0xf0106972
f01020d2:	68 02 04 00 00       	push   $0x402
f01020d7:	68 4c 69 10 f0       	push   $0xf010694c
f01020dc:	e8 5f df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01020e1:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01020e6:	74 19                	je     f0102101 <mem_init+0xec6>
f01020e8:	68 b7 6b 10 f0       	push   $0xf0106bb7
f01020ed:	68 72 69 10 f0       	push   $0xf0106972
f01020f2:	68 03 04 00 00       	push   $0x403
f01020f7:	68 4c 69 10 f0       	push   $0xf010694c
f01020fc:	e8 3f df ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102101:	83 ec 0c             	sub    $0xc,%esp
f0102104:	6a 00                	push   $0x0
f0102106:	e8 b5 ed ff ff       	call   f0100ec0 <page_alloc>
f010210b:	83 c4 10             	add    $0x10,%esp
f010210e:	39 c3                	cmp    %eax,%ebx
f0102110:	75 04                	jne    f0102116 <mem_init+0xedb>
f0102112:	85 c0                	test   %eax,%eax
f0102114:	75 19                	jne    f010212f <mem_init+0xef4>
f0102116:	68 d4 72 10 f0       	push   $0xf01072d4
f010211b:	68 72 69 10 f0       	push   $0xf0106972
f0102120:	68 06 04 00 00       	push   $0x406
f0102125:	68 4c 69 10 f0       	push   $0xf010694c
f010212a:	e8 11 df ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010212f:	83 ec 0c             	sub    $0xc,%esp
f0102132:	6a 00                	push   $0x0
f0102134:	e8 87 ed ff ff       	call   f0100ec0 <page_alloc>
f0102139:	83 c4 10             	add    $0x10,%esp
f010213c:	85 c0                	test   %eax,%eax
f010213e:	74 19                	je     f0102159 <mem_init+0xf1e>
f0102140:	68 0b 6b 10 f0       	push   $0xf0106b0b
f0102145:	68 72 69 10 f0       	push   $0xf0106972
f010214a:	68 09 04 00 00       	push   $0x409
f010214f:	68 4c 69 10 f0       	push   $0xf010694c
f0102154:	e8 e7 de ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102159:	8b 0d 8c fe 22 f0    	mov    0xf022fe8c,%ecx
f010215f:	8b 11                	mov    (%ecx),%edx
f0102161:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102167:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010216a:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102170:	c1 f8 03             	sar    $0x3,%eax
f0102173:	c1 e0 0c             	shl    $0xc,%eax
f0102176:	39 c2                	cmp    %eax,%edx
f0102178:	74 19                	je     f0102193 <mem_init+0xf58>
f010217a:	68 78 6f 10 f0       	push   $0xf0106f78
f010217f:	68 72 69 10 f0       	push   $0xf0106972
f0102184:	68 0c 04 00 00       	push   $0x40c
f0102189:	68 4c 69 10 f0       	push   $0xf010694c
f010218e:	e8 ad de ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102193:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102199:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010219c:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01021a1:	74 19                	je     f01021bc <mem_init+0xf81>
f01021a3:	68 6e 6b 10 f0       	push   $0xf0106b6e
f01021a8:	68 72 69 10 f0       	push   $0xf0106972
f01021ad:	68 0e 04 00 00       	push   $0x40e
f01021b2:	68 4c 69 10 f0       	push   $0xf010694c
f01021b7:	e8 84 de ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01021bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021bf:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01021c5:	83 ec 0c             	sub    $0xc,%esp
f01021c8:	50                   	push   %eax
f01021c9:	e8 62 ed ff ff       	call   f0100f30 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01021ce:	83 c4 0c             	add    $0xc,%esp
f01021d1:	6a 01                	push   $0x1
f01021d3:	68 00 10 40 00       	push   $0x401000
f01021d8:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f01021de:	e8 af ed ff ff       	call   f0100f92 <pgdir_walk>
f01021e3:	89 c7                	mov    %eax,%edi
f01021e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01021e8:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f01021ed:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01021f0:	8b 40 04             	mov    0x4(%eax),%eax
f01021f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01021f8:	8b 0d 88 fe 22 f0    	mov    0xf022fe88,%ecx
f01021fe:	89 c2                	mov    %eax,%edx
f0102200:	c1 ea 0c             	shr    $0xc,%edx
f0102203:	83 c4 10             	add    $0x10,%esp
f0102206:	39 ca                	cmp    %ecx,%edx
f0102208:	72 15                	jb     f010221f <mem_init+0xfe4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010220a:	50                   	push   %eax
f010220b:	68 44 64 10 f0       	push   $0xf0106444
f0102210:	68 15 04 00 00       	push   $0x415
f0102215:	68 4c 69 10 f0       	push   $0xf010694c
f010221a:	e8 21 de ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010221f:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102224:	39 c7                	cmp    %eax,%edi
f0102226:	74 19                	je     f0102241 <mem_init+0x1006>
f0102228:	68 fa 6b 10 f0       	push   $0xf0106bfa
f010222d:	68 72 69 10 f0       	push   $0xf0106972
f0102232:	68 16 04 00 00       	push   $0x416
f0102237:	68 4c 69 10 f0       	push   $0xf010694c
f010223c:	e8 ff dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102241:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102244:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f010224b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010224e:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f0102254:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f010225a:	c1 f8 03             	sar    $0x3,%eax
f010225d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102260:	89 c2                	mov    %eax,%edx
f0102262:	c1 ea 0c             	shr    $0xc,%edx
f0102265:	39 d1                	cmp    %edx,%ecx
f0102267:	77 12                	ja     f010227b <mem_init+0x1040>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102269:	50                   	push   %eax
f010226a:	68 44 64 10 f0       	push   $0xf0106444
f010226f:	6a 58                	push   $0x58
f0102271:	68 58 69 10 f0       	push   $0xf0106958
f0102276:	e8 c5 dd ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010227b:	83 ec 04             	sub    $0x4,%esp
f010227e:	68 00 10 00 00       	push   $0x1000
f0102283:	68 ff 00 00 00       	push   $0xff
f0102288:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010228d:	50                   	push   %eax
f010228e:	e8 d1 34 00 00       	call   f0105764 <memset>
	page_free(pp0);
f0102293:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102296:	89 3c 24             	mov    %edi,(%esp)
f0102299:	e8 92 ec ff ff       	call   f0100f30 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010229e:	83 c4 0c             	add    $0xc,%esp
f01022a1:	6a 01                	push   $0x1
f01022a3:	6a 00                	push   $0x0
f01022a5:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f01022ab:	e8 e2 ec ff ff       	call   f0100f92 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f01022b0:	89 fa                	mov    %edi,%edx
f01022b2:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f01022b8:	c1 fa 03             	sar    $0x3,%edx
f01022bb:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01022be:	89 d0                	mov    %edx,%eax
f01022c0:	c1 e8 0c             	shr    $0xc,%eax
f01022c3:	83 c4 10             	add    $0x10,%esp
f01022c6:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f01022cc:	72 12                	jb     f01022e0 <mem_init+0x10a5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01022ce:	52                   	push   %edx
f01022cf:	68 44 64 10 f0       	push   $0xf0106444
f01022d4:	6a 58                	push   $0x58
f01022d6:	68 58 69 10 f0       	push   $0xf0106958
f01022db:	e8 60 dd ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01022e0:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01022e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01022e9:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01022ef:	f6 00 01             	testb  $0x1,(%eax)
f01022f2:	74 19                	je     f010230d <mem_init+0x10d2>
f01022f4:	68 12 6c 10 f0       	push   $0xf0106c12
f01022f9:	68 72 69 10 f0       	push   $0xf0106972
f01022fe:	68 20 04 00 00       	push   $0x420
f0102303:	68 4c 69 10 f0       	push   $0xf010694c
f0102308:	e8 33 dd ff ff       	call   f0100040 <_panic>
f010230d:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102310:	39 d0                	cmp    %edx,%eax
f0102312:	75 db                	jne    f01022ef <mem_init+0x10b4>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102314:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0102319:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010231f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102322:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102328:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010232b:	89 0d 44 f2 22 f0    	mov    %ecx,0xf022f244

	// free the pages we took
	page_free(pp0);
f0102331:	83 ec 0c             	sub    $0xc,%esp
f0102334:	50                   	push   %eax
f0102335:	e8 f6 eb ff ff       	call   f0100f30 <page_free>
	page_free(pp1);
f010233a:	89 1c 24             	mov    %ebx,(%esp)
f010233d:	e8 ee eb ff ff       	call   f0100f30 <page_free>
	page_free(pp2);
f0102342:	89 34 24             	mov    %esi,(%esp)
f0102345:	e8 e6 eb ff ff       	call   f0100f30 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010234a:	83 c4 08             	add    $0x8,%esp
f010234d:	68 01 10 00 00       	push   $0x1001
f0102352:	6a 00                	push   $0x0
f0102354:	e8 a3 ee ff ff       	call   f01011fc <mmio_map_region>
f0102359:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f010235b:	83 c4 08             	add    $0x8,%esp
f010235e:	68 00 10 00 00       	push   $0x1000
f0102363:	6a 00                	push   $0x0
f0102365:	e8 92 ee ff ff       	call   f01011fc <mmio_map_region>
f010236a:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f010236c:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0102372:	83 c4 10             	add    $0x10,%esp
f0102375:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010237b:	76 07                	jbe    f0102384 <mem_init+0x1149>
f010237d:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102382:	76 19                	jbe    f010239d <mem_init+0x1162>
f0102384:	68 f8 72 10 f0       	push   $0xf01072f8
f0102389:	68 72 69 10 f0       	push   $0xf0106972
f010238e:	68 30 04 00 00       	push   $0x430
f0102393:	68 4c 69 10 f0       	push   $0xf010694c
f0102398:	e8 a3 dc ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f010239d:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f01023a3:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01023a9:	77 08                	ja     f01023b3 <mem_init+0x1178>
f01023ab:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01023b1:	77 19                	ja     f01023cc <mem_init+0x1191>
f01023b3:	68 20 73 10 f0       	push   $0xf0107320
f01023b8:	68 72 69 10 f0       	push   $0xf0106972
f01023bd:	68 31 04 00 00       	push   $0x431
f01023c2:	68 4c 69 10 f0       	push   $0xf010694c
f01023c7:	e8 74 dc ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01023cc:	89 da                	mov    %ebx,%edx
f01023ce:	09 f2                	or     %esi,%edx
f01023d0:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01023d6:	74 19                	je     f01023f1 <mem_init+0x11b6>
f01023d8:	68 48 73 10 f0       	push   $0xf0107348
f01023dd:	68 72 69 10 f0       	push   $0xf0106972
f01023e2:	68 33 04 00 00       	push   $0x433
f01023e7:	68 4c 69 10 f0       	push   $0xf010694c
f01023ec:	e8 4f dc ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f01023f1:	39 c6                	cmp    %eax,%esi
f01023f3:	73 19                	jae    f010240e <mem_init+0x11d3>
f01023f5:	68 29 6c 10 f0       	push   $0xf0106c29
f01023fa:	68 72 69 10 f0       	push   $0xf0106972
f01023ff:	68 35 04 00 00       	push   $0x435
f0102404:	68 4c 69 10 f0       	push   $0xf010694c
f0102409:	e8 32 dc ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010240e:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0102414:	89 da                	mov    %ebx,%edx
f0102416:	89 f8                	mov    %edi,%eax
f0102418:	e8 39 e6 ff ff       	call   f0100a56 <check_va2pa>
f010241d:	85 c0                	test   %eax,%eax
f010241f:	74 19                	je     f010243a <mem_init+0x11ff>
f0102421:	68 70 73 10 f0       	push   $0xf0107370
f0102426:	68 72 69 10 f0       	push   $0xf0106972
f010242b:	68 37 04 00 00       	push   $0x437
f0102430:	68 4c 69 10 f0       	push   $0xf010694c
f0102435:	e8 06 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010243a:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102440:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102443:	89 c2                	mov    %eax,%edx
f0102445:	89 f8                	mov    %edi,%eax
f0102447:	e8 0a e6 ff ff       	call   f0100a56 <check_va2pa>
f010244c:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102451:	74 19                	je     f010246c <mem_init+0x1231>
f0102453:	68 94 73 10 f0       	push   $0xf0107394
f0102458:	68 72 69 10 f0       	push   $0xf0106972
f010245d:	68 38 04 00 00       	push   $0x438
f0102462:	68 4c 69 10 f0       	push   $0xf010694c
f0102467:	e8 d4 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010246c:	89 f2                	mov    %esi,%edx
f010246e:	89 f8                	mov    %edi,%eax
f0102470:	e8 e1 e5 ff ff       	call   f0100a56 <check_va2pa>
f0102475:	85 c0                	test   %eax,%eax
f0102477:	74 19                	je     f0102492 <mem_init+0x1257>
f0102479:	68 c4 73 10 f0       	push   $0xf01073c4
f010247e:	68 72 69 10 f0       	push   $0xf0106972
f0102483:	68 39 04 00 00       	push   $0x439
f0102488:	68 4c 69 10 f0       	push   $0xf010694c
f010248d:	e8 ae db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102492:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102498:	89 f8                	mov    %edi,%eax
f010249a:	e8 b7 e5 ff ff       	call   f0100a56 <check_va2pa>
f010249f:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024a2:	74 19                	je     f01024bd <mem_init+0x1282>
f01024a4:	68 e8 73 10 f0       	push   $0xf01073e8
f01024a9:	68 72 69 10 f0       	push   $0xf0106972
f01024ae:	68 3a 04 00 00       	push   $0x43a
f01024b3:	68 4c 69 10 f0       	push   $0xf010694c
f01024b8:	e8 83 db ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01024bd:	83 ec 04             	sub    $0x4,%esp
f01024c0:	6a 00                	push   $0x0
f01024c2:	53                   	push   %ebx
f01024c3:	57                   	push   %edi
f01024c4:	e8 c9 ea ff ff       	call   f0100f92 <pgdir_walk>
f01024c9:	83 c4 10             	add    $0x10,%esp
f01024cc:	f6 00 1a             	testb  $0x1a,(%eax)
f01024cf:	75 19                	jne    f01024ea <mem_init+0x12af>
f01024d1:	68 14 74 10 f0       	push   $0xf0107414
f01024d6:	68 72 69 10 f0       	push   $0xf0106972
f01024db:	68 3c 04 00 00       	push   $0x43c
f01024e0:	68 4c 69 10 f0       	push   $0xf010694c
f01024e5:	e8 56 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01024ea:	83 ec 04             	sub    $0x4,%esp
f01024ed:	6a 00                	push   $0x0
f01024ef:	53                   	push   %ebx
f01024f0:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f01024f6:	e8 97 ea ff ff       	call   f0100f92 <pgdir_walk>
f01024fb:	8b 00                	mov    (%eax),%eax
f01024fd:	83 c4 10             	add    $0x10,%esp
f0102500:	83 e0 04             	and    $0x4,%eax
f0102503:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102506:	74 19                	je     f0102521 <mem_init+0x12e6>
f0102508:	68 58 74 10 f0       	push   $0xf0107458
f010250d:	68 72 69 10 f0       	push   $0xf0106972
f0102512:	68 3d 04 00 00       	push   $0x43d
f0102517:	68 4c 69 10 f0       	push   $0xf010694c
f010251c:	e8 1f db ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102521:	83 ec 04             	sub    $0x4,%esp
f0102524:	6a 00                	push   $0x0
f0102526:	53                   	push   %ebx
f0102527:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f010252d:	e8 60 ea ff ff       	call   f0100f92 <pgdir_walk>
f0102532:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102538:	83 c4 0c             	add    $0xc,%esp
f010253b:	6a 00                	push   $0x0
f010253d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102540:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102546:	e8 47 ea ff ff       	call   f0100f92 <pgdir_walk>
f010254b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102551:	83 c4 0c             	add    $0xc,%esp
f0102554:	6a 00                	push   $0x0
f0102556:	56                   	push   %esi
f0102557:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f010255d:	e8 30 ea ff ff       	call   f0100f92 <pgdir_walk>
f0102562:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102568:	c7 04 24 3b 6c 10 f0 	movl   $0xf0106c3b,(%esp)
f010256f:	e8 ee 11 00 00       	call   f0103762 <cprintf>
	page_init();

	check_page_free_list(1);
	check_page_alloc();
	check_page();
	cprintf("PTSIZE %d\n",PTSIZE);
f0102574:	83 c4 08             	add    $0x8,%esp
f0102577:	68 00 00 40 00       	push   $0x400000
f010257c:	68 54 6c 10 f0       	push   $0xf0106c54
f0102581:	e8 dc 11 00 00       	call   f0103762 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:	
	//
	flag=1;
f0102586:	c7 05 38 f2 22 f0 01 	movl   $0x1,0xf022f238
f010258d:	00 00 00 
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U|PTE_P);
f0102590:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102595:	83 c4 10             	add    $0x10,%esp
f0102598:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010259d:	77 15                	ja     f01025b4 <mem_init+0x1379>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010259f:	50                   	push   %eax
f01025a0:	68 68 64 10 f0       	push   $0xf0106468
f01025a5:	68 c4 00 00 00       	push   $0xc4
f01025aa:	68 4c 69 10 f0       	push   $0xf010694c
f01025af:	e8 8c da ff ff       	call   f0100040 <_panic>
f01025b4:	83 ec 08             	sub    $0x8,%esp
f01025b7:	6a 05                	push   $0x5
f01025b9:	05 00 00 00 10       	add    $0x10000000,%eax
f01025be:	50                   	push   %eax
f01025bf:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01025c4:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01025c9:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f01025ce:	e8 8c ea ff ff       	call   f010105f <boot_map_region>
	cprintf("UPAGES=%x PADDR(pages)=%x\n",UPAGES,PADDR(pages));
f01025d3:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025d8:	83 c4 10             	add    $0x10,%esp
f01025db:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025e0:	77 15                	ja     f01025f7 <mem_init+0x13bc>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025e2:	50                   	push   %eax
f01025e3:	68 68 64 10 f0       	push   $0xf0106468
f01025e8:	68 c5 00 00 00       	push   $0xc5
f01025ed:	68 4c 69 10 f0       	push   $0xf010694c
f01025f2:	e8 49 da ff ff       	call   f0100040 <_panic>
f01025f7:	83 ec 04             	sub    $0x4,%esp
f01025fa:	05 00 00 00 10       	add    $0x10000000,%eax
f01025ff:	50                   	push   %eax
f0102600:	68 00 00 00 ef       	push   $0xef000000
f0102605:	68 5f 6c 10 f0       	push   $0xf0106c5f
f010260a:	e8 53 11 00 00       	call   f0103762 <cprintf>
	flag=0;
f010260f:	c7 05 38 f2 22 f0 00 	movl   $0x0,0xf022f238
f0102616:	00 00 00 
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f0102619:	a1 4c f2 22 f0       	mov    0xf022f24c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010261e:	83 c4 10             	add    $0x10,%esp
f0102621:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102626:	77 15                	ja     f010263d <mem_init+0x1402>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102628:	50                   	push   %eax
f0102629:	68 68 64 10 f0       	push   $0xf0106468
f010262e:	68 ce 00 00 00       	push   $0xce
f0102633:	68 4c 69 10 f0       	push   $0xf010694c
f0102638:	e8 03 da ff ff       	call   f0100040 <_panic>
f010263d:	83 ec 08             	sub    $0x8,%esp
f0102640:	6a 04                	push   $0x4
f0102642:	05 00 00 00 10       	add    $0x10000000,%eax
f0102647:	50                   	push   %eax
f0102648:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010264d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102652:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0102657:	e8 03 ea ff ff       	call   f010105f <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010265c:	83 c4 10             	add    $0x10,%esp
f010265f:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f0102664:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102669:	77 15                	ja     f0102680 <mem_init+0x1445>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010266b:	50                   	push   %eax
f010266c:	68 68 64 10 f0       	push   $0xf0106468
f0102671:	68 dd 00 00 00       	push   $0xdd
f0102676:	68 4c 69 10 f0       	push   $0xf010694c
f010267b:	e8 c0 d9 ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	// 堆栈段映射 ，有一部分没用映射，这样栈炸了就直接报错了，而不是覆盖其他内存
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102680:	83 ec 08             	sub    $0x8,%esp
f0102683:	6a 02                	push   $0x2
f0102685:	68 00 60 11 00       	push   $0x116000
f010268a:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010268f:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102694:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0102699:	e8 c1 e9 ff ff       	call   f010105f <boot_map_region>
	cprintf("KSTACKTOP-KSTKSIZE=%x PADDR(bootstack)=%x\n",KSTACKTOP-KSTKSIZE,PADDR(bootstack));
f010269e:	83 c4 0c             	add    $0xc,%esp
f01026a1:	68 00 60 11 00       	push   $0x116000
f01026a6:	68 00 80 ff ef       	push   $0xefff8000
f01026ab:	68 8c 74 10 f0       	push   $0xf010748c
f01026b0:	e8 ad 10 00 00       	call   f0103762 <cprintf>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, 0x10000000, 0, PTE_W);
f01026b5:	83 c4 08             	add    $0x8,%esp
f01026b8:	6a 02                	push   $0x2
f01026ba:	6a 00                	push   $0x0
f01026bc:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01026c1:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01026c6:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f01026cb:	e8 8f e9 ff ff       	call   f010105f <boot_map_region>
	cprintf("KERNBASE=%x 0=%x\n",KERNBASE,0);	
f01026d0:	83 c4 0c             	add    $0xc,%esp
f01026d3:	6a 00                	push   $0x0
f01026d5:	68 00 00 00 f0       	push   $0xf0000000
f01026da:	68 7a 6c 10 f0       	push   $0xf0106c7a
f01026df:	e8 7e 10 00 00       	call   f0103762 <cprintf>
f01026e4:	c7 45 c4 00 10 23 f0 	movl   $0xf0231000,-0x3c(%ebp)
f01026eb:	83 c4 10             	add    $0x10,%esp
f01026ee:	bb 00 10 23 f0       	mov    $0xf0231000,%ebx
f01026f3:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026f8:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01026fe:	77 15                	ja     f0102715 <mem_init+0x14da>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102700:	53                   	push   %ebx
f0102701:	68 68 64 10 f0       	push   $0xf0106468
f0102706:	68 21 01 00 00       	push   $0x121
f010270b:	68 4c 69 10 f0       	push   $0xf010694c
f0102710:	e8 2b d9 ff ff       	call   f0100040 <_panic>
	//
	// LAB 4: Your code here:
	for (size_t i = 0; i < NCPU; i++)
	{
		/* code */
		boot_map_region(kern_pgdir,KSTACKTOP-i*(KSTKSIZE+KSTKGAP)-KSTKSIZE,KSTKSIZE,PADDR(percpu_kstacks[i]),PTE_W);
f0102715:	83 ec 08             	sub    $0x8,%esp
f0102718:	6a 02                	push   $0x2
f010271a:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102720:	50                   	push   %eax
f0102721:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102726:	89 f2                	mov    %esi,%edx
f0102728:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f010272d:	e8 2d e9 ff ff       	call   f010105f <boot_map_region>
f0102732:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102738:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             it will fault rather than overwrite another CPU's stack.
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	for (size_t i = 0; i < NCPU; i++)
f010273e:	83 c4 10             	add    $0x10,%esp
f0102741:	b8 00 10 27 f0       	mov    $0xf0271000,%eax
f0102746:	39 d8                	cmp    %ebx,%eax
f0102748:	75 ae                	jne    f01026f8 <mem_init+0x14bd>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010274a:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102750:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f0102755:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102758:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010275f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102764:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102767:	8b 35 90 fe 22 f0    	mov    0xf022fe90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010276d:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102770:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102775:	eb 55                	jmp    f01027cc <mem_init+0x1591>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102777:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010277d:	89 f8                	mov    %edi,%eax
f010277f:	e8 d2 e2 ff ff       	call   f0100a56 <check_va2pa>
f0102784:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010278b:	77 15                	ja     f01027a2 <mem_init+0x1567>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010278d:	56                   	push   %esi
f010278e:	68 68 64 10 f0       	push   $0xf0106468
f0102793:	68 55 03 00 00       	push   $0x355
f0102798:	68 4c 69 10 f0       	push   $0xf010694c
f010279d:	e8 9e d8 ff ff       	call   f0100040 <_panic>
f01027a2:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f01027a9:	39 c2                	cmp    %eax,%edx
f01027ab:	74 19                	je     f01027c6 <mem_init+0x158b>
f01027ad:	68 b8 74 10 f0       	push   $0xf01074b8
f01027b2:	68 72 69 10 f0       	push   $0xf0106972
f01027b7:	68 55 03 00 00       	push   $0x355
f01027bc:	68 4c 69 10 f0       	push   $0xf010694c
f01027c1:	e8 7a d8 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027c6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01027cc:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01027cf:	77 a6                	ja     f0102777 <mem_init+0x153c>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01027d1:	8b 35 4c f2 22 f0    	mov    0xf022f24c,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027d7:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01027da:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01027df:	89 da                	mov    %ebx,%edx
f01027e1:	89 f8                	mov    %edi,%eax
f01027e3:	e8 6e e2 ff ff       	call   f0100a56 <check_va2pa>
f01027e8:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f01027ef:	77 15                	ja     f0102806 <mem_init+0x15cb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027f1:	56                   	push   %esi
f01027f2:	68 68 64 10 f0       	push   $0xf0106468
f01027f7:	68 5a 03 00 00       	push   $0x35a
f01027fc:	68 4c 69 10 f0       	push   $0xf010694c
f0102801:	e8 3a d8 ff ff       	call   f0100040 <_panic>
f0102806:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f010280d:	39 d0                	cmp    %edx,%eax
f010280f:	74 19                	je     f010282a <mem_init+0x15ef>
f0102811:	68 ec 74 10 f0       	push   $0xf01074ec
f0102816:	68 72 69 10 f0       	push   $0xf0106972
f010281b:	68 5a 03 00 00       	push   $0x35a
f0102820:	68 4c 69 10 f0       	push   $0xf010694c
f0102825:	e8 16 d8 ff ff       	call   f0100040 <_panic>
f010282a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102830:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102836:	75 a7                	jne    f01027df <mem_init+0x15a4>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102838:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010283b:	c1 e6 0c             	shl    $0xc,%esi
f010283e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102843:	eb 30                	jmp    f0102875 <mem_init+0x163a>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102845:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f010284b:	89 f8                	mov    %edi,%eax
f010284d:	e8 04 e2 ff ff       	call   f0100a56 <check_va2pa>
f0102852:	39 c3                	cmp    %eax,%ebx
f0102854:	74 19                	je     f010286f <mem_init+0x1634>
f0102856:	68 20 75 10 f0       	push   $0xf0107520
f010285b:	68 72 69 10 f0       	push   $0xf0106972
f0102860:	68 5e 03 00 00       	push   $0x35e
f0102865:	68 4c 69 10 f0       	push   $0xf010694c
f010286a:	e8 d1 d7 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010286f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102875:	39 f3                	cmp    %esi,%ebx
f0102877:	72 cc                	jb     f0102845 <mem_init+0x160a>
f0102879:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f010287e:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102881:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102884:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102887:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f010288d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102890:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102892:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102895:	05 00 80 00 20       	add    $0x20008000,%eax
f010289a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010289d:	89 da                	mov    %ebx,%edx
f010289f:	89 f8                	mov    %edi,%eax
f01028a1:	e8 b0 e1 ff ff       	call   f0100a56 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028a6:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01028ac:	77 15                	ja     f01028c3 <mem_init+0x1688>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028ae:	56                   	push   %esi
f01028af:	68 68 64 10 f0       	push   $0xf0106468
f01028b4:	68 66 03 00 00       	push   $0x366
f01028b9:	68 4c 69 10 f0       	push   $0xf010694c
f01028be:	e8 7d d7 ff ff       	call   f0100040 <_panic>
f01028c3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01028c6:	8d 94 0b 00 10 23 f0 	lea    -0xfdcf000(%ebx,%ecx,1),%edx
f01028cd:	39 d0                	cmp    %edx,%eax
f01028cf:	74 19                	je     f01028ea <mem_init+0x16af>
f01028d1:	68 48 75 10 f0       	push   $0xf0107548
f01028d6:	68 72 69 10 f0       	push   $0xf0106972
f01028db:	68 66 03 00 00       	push   $0x366
f01028e0:	68 4c 69 10 f0       	push   $0xf010694c
f01028e5:	e8 56 d7 ff ff       	call   f0100040 <_panic>
f01028ea:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01028f0:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f01028f3:	75 a8                	jne    f010289d <mem_init+0x1662>
f01028f5:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01028f8:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f01028fe:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102901:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102903:	89 da                	mov    %ebx,%edx
f0102905:	89 f8                	mov    %edi,%eax
f0102907:	e8 4a e1 ff ff       	call   f0100a56 <check_va2pa>
f010290c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010290f:	74 19                	je     f010292a <mem_init+0x16ef>
f0102911:	68 90 75 10 f0       	push   $0xf0107590
f0102916:	68 72 69 10 f0       	push   $0xf0106972
f010291b:	68 68 03 00 00       	push   $0x368
f0102920:	68 4c 69 10 f0       	push   $0xf010694c
f0102925:	e8 16 d7 ff ff       	call   f0100040 <_panic>
f010292a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102930:	39 f3                	cmp    %esi,%ebx
f0102932:	75 cf                	jne    f0102903 <mem_init+0x16c8>
f0102934:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102937:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f010293e:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102945:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f010294b:	b8 00 10 27 f0       	mov    $0xf0271000,%eax
f0102950:	39 f0                	cmp    %esi,%eax
f0102952:	0f 85 2c ff ff ff    	jne    f0102884 <mem_init+0x1649>
f0102958:	b8 00 00 00 00       	mov    $0x0,%eax
f010295d:	eb 2a                	jmp    f0102989 <mem_init+0x174e>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010295f:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102965:	83 fa 04             	cmp    $0x4,%edx
f0102968:	77 1f                	ja     f0102989 <mem_init+0x174e>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f010296a:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f010296e:	75 7e                	jne    f01029ee <mem_init+0x17b3>
f0102970:	68 8c 6c 10 f0       	push   $0xf0106c8c
f0102975:	68 72 69 10 f0       	push   $0xf0106972
f010297a:	68 73 03 00 00       	push   $0x373
f010297f:	68 4c 69 10 f0       	push   $0xf010694c
f0102984:	e8 b7 d6 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102989:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010298e:	76 3f                	jbe    f01029cf <mem_init+0x1794>
				assert(pgdir[i] & PTE_P);
f0102990:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102993:	f6 c2 01             	test   $0x1,%dl
f0102996:	75 19                	jne    f01029b1 <mem_init+0x1776>
f0102998:	68 8c 6c 10 f0       	push   $0xf0106c8c
f010299d:	68 72 69 10 f0       	push   $0xf0106972
f01029a2:	68 77 03 00 00       	push   $0x377
f01029a7:	68 4c 69 10 f0       	push   $0xf010694c
f01029ac:	e8 8f d6 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01029b1:	f6 c2 02             	test   $0x2,%dl
f01029b4:	75 38                	jne    f01029ee <mem_init+0x17b3>
f01029b6:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01029bb:	68 72 69 10 f0       	push   $0xf0106972
f01029c0:	68 78 03 00 00       	push   $0x378
f01029c5:	68 4c 69 10 f0       	push   $0xf010694c
f01029ca:	e8 71 d6 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f01029cf:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01029d3:	74 19                	je     f01029ee <mem_init+0x17b3>
f01029d5:	68 ae 6c 10 f0       	push   $0xf0106cae
f01029da:	68 72 69 10 f0       	push   $0xf0106972
f01029df:	68 7a 03 00 00       	push   $0x37a
f01029e4:	68 4c 69 10 f0       	push   $0xf010694c
f01029e9:	e8 52 d6 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01029ee:	83 c0 01             	add    $0x1,%eax
f01029f1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01029f6:	0f 86 63 ff ff ff    	jbe    f010295f <mem_init+0x1724>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01029fc:	83 ec 0c             	sub    $0xc,%esp
f01029ff:	68 b4 75 10 f0       	push   $0xf01075b4
f0102a04:	e8 59 0d 00 00       	call   f0103762 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102a09:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a0e:	83 c4 10             	add    $0x10,%esp
f0102a11:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a16:	77 15                	ja     f0102a2d <mem_init+0x17f2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a18:	50                   	push   %eax
f0102a19:	68 68 64 10 f0       	push   $0xf0106468
f0102a1e:	68 f8 00 00 00       	push   $0xf8
f0102a23:	68 4c 69 10 f0       	push   $0xf010694c
f0102a28:	e8 13 d6 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102a2d:	05 00 00 00 10       	add    $0x10000000,%eax
f0102a32:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102a35:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a3a:	e8 7b e0 ff ff       	call   f0100aba <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102a3f:	0f 20 c0             	mov    %cr0,%eax
f0102a42:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102a45:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102a4a:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102a4d:	83 ec 0c             	sub    $0xc,%esp
f0102a50:	6a 00                	push   $0x0
f0102a52:	e8 69 e4 ff ff       	call   f0100ec0 <page_alloc>
f0102a57:	89 c3                	mov    %eax,%ebx
f0102a59:	83 c4 10             	add    $0x10,%esp
f0102a5c:	85 c0                	test   %eax,%eax
f0102a5e:	75 19                	jne    f0102a79 <mem_init+0x183e>
f0102a60:	68 60 6a 10 f0       	push   $0xf0106a60
f0102a65:	68 72 69 10 f0       	push   $0xf0106972
f0102a6a:	68 52 04 00 00       	push   $0x452
f0102a6f:	68 4c 69 10 f0       	push   $0xf010694c
f0102a74:	e8 c7 d5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102a79:	83 ec 0c             	sub    $0xc,%esp
f0102a7c:	6a 00                	push   $0x0
f0102a7e:	e8 3d e4 ff ff       	call   f0100ec0 <page_alloc>
f0102a83:	89 c7                	mov    %eax,%edi
f0102a85:	83 c4 10             	add    $0x10,%esp
f0102a88:	85 c0                	test   %eax,%eax
f0102a8a:	75 19                	jne    f0102aa5 <mem_init+0x186a>
f0102a8c:	68 76 6a 10 f0       	push   $0xf0106a76
f0102a91:	68 72 69 10 f0       	push   $0xf0106972
f0102a96:	68 53 04 00 00       	push   $0x453
f0102a9b:	68 4c 69 10 f0       	push   $0xf010694c
f0102aa0:	e8 9b d5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102aa5:	83 ec 0c             	sub    $0xc,%esp
f0102aa8:	6a 00                	push   $0x0
f0102aaa:	e8 11 e4 ff ff       	call   f0100ec0 <page_alloc>
f0102aaf:	89 c6                	mov    %eax,%esi
f0102ab1:	83 c4 10             	add    $0x10,%esp
f0102ab4:	85 c0                	test   %eax,%eax
f0102ab6:	75 19                	jne    f0102ad1 <mem_init+0x1896>
f0102ab8:	68 8c 6a 10 f0       	push   $0xf0106a8c
f0102abd:	68 72 69 10 f0       	push   $0xf0106972
f0102ac2:	68 54 04 00 00       	push   $0x454
f0102ac7:	68 4c 69 10 f0       	push   $0xf010694c
f0102acc:	e8 6f d5 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102ad1:	83 ec 0c             	sub    $0xc,%esp
f0102ad4:	53                   	push   %ebx
f0102ad5:	e8 56 e4 ff ff       	call   f0100f30 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f0102ada:	89 f8                	mov    %edi,%eax
f0102adc:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102ae2:	c1 f8 03             	sar    $0x3,%eax
f0102ae5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ae8:	89 c2                	mov    %eax,%edx
f0102aea:	c1 ea 0c             	shr    $0xc,%edx
f0102aed:	83 c4 10             	add    $0x10,%esp
f0102af0:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0102af6:	72 12                	jb     f0102b0a <mem_init+0x18cf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102af8:	50                   	push   %eax
f0102af9:	68 44 64 10 f0       	push   $0xf0106444
f0102afe:	6a 58                	push   $0x58
f0102b00:	68 58 69 10 f0       	push   $0xf0106958
f0102b05:	e8 36 d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102b0a:	83 ec 04             	sub    $0x4,%esp
f0102b0d:	68 00 10 00 00       	push   $0x1000
f0102b12:	6a 01                	push   $0x1
f0102b14:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b19:	50                   	push   %eax
f0102b1a:	e8 45 2c 00 00       	call   f0105764 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f0102b1f:	89 f0                	mov    %esi,%eax
f0102b21:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102b27:	c1 f8 03             	sar    $0x3,%eax
f0102b2a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b2d:	89 c2                	mov    %eax,%edx
f0102b2f:	c1 ea 0c             	shr    $0xc,%edx
f0102b32:	83 c4 10             	add    $0x10,%esp
f0102b35:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0102b3b:	72 12                	jb     f0102b4f <mem_init+0x1914>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b3d:	50                   	push   %eax
f0102b3e:	68 44 64 10 f0       	push   $0xf0106444
f0102b43:	6a 58                	push   $0x58
f0102b45:	68 58 69 10 f0       	push   $0xf0106958
f0102b4a:	e8 f1 d4 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102b4f:	83 ec 04             	sub    $0x4,%esp
f0102b52:	68 00 10 00 00       	push   $0x1000
f0102b57:	6a 02                	push   $0x2
f0102b59:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b5e:	50                   	push   %eax
f0102b5f:	e8 00 2c 00 00       	call   f0105764 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102b64:	6a 02                	push   $0x2
f0102b66:	68 00 10 00 00       	push   $0x1000
f0102b6b:	57                   	push   %edi
f0102b6c:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102b72:	e8 1f e6 ff ff       	call   f0101196 <page_insert>
	assert(pp1->pp_ref == 1);
f0102b77:	83 c4 20             	add    $0x20,%esp
f0102b7a:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b7f:	74 19                	je     f0102b9a <mem_init+0x195f>
f0102b81:	68 5d 6b 10 f0       	push   $0xf0106b5d
f0102b86:	68 72 69 10 f0       	push   $0xf0106972
f0102b8b:	68 59 04 00 00       	push   $0x459
f0102b90:	68 4c 69 10 f0       	push   $0xf010694c
f0102b95:	e8 a6 d4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102b9a:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102ba1:	01 01 01 
f0102ba4:	74 19                	je     f0102bbf <mem_init+0x1984>
f0102ba6:	68 d4 75 10 f0       	push   $0xf01075d4
f0102bab:	68 72 69 10 f0       	push   $0xf0106972
f0102bb0:	68 5a 04 00 00       	push   $0x45a
f0102bb5:	68 4c 69 10 f0       	push   $0xf010694c
f0102bba:	e8 81 d4 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102bbf:	6a 02                	push   $0x2
f0102bc1:	68 00 10 00 00       	push   $0x1000
f0102bc6:	56                   	push   %esi
f0102bc7:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102bcd:	e8 c4 e5 ff ff       	call   f0101196 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102bd2:	83 c4 10             	add    $0x10,%esp
f0102bd5:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102bdc:	02 02 02 
f0102bdf:	74 19                	je     f0102bfa <mem_init+0x19bf>
f0102be1:	68 f8 75 10 f0       	push   $0xf01075f8
f0102be6:	68 72 69 10 f0       	push   $0xf0106972
f0102beb:	68 5c 04 00 00       	push   $0x45c
f0102bf0:	68 4c 69 10 f0       	push   $0xf010694c
f0102bf5:	e8 46 d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102bfa:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102bff:	74 19                	je     f0102c1a <mem_init+0x19df>
f0102c01:	68 7f 6b 10 f0       	push   $0xf0106b7f
f0102c06:	68 72 69 10 f0       	push   $0xf0106972
f0102c0b:	68 5d 04 00 00       	push   $0x45d
f0102c10:	68 4c 69 10 f0       	push   $0xf010694c
f0102c15:	e8 26 d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102c1a:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c1f:	74 19                	je     f0102c3a <mem_init+0x19ff>
f0102c21:	68 e9 6b 10 f0       	push   $0xf0106be9
f0102c26:	68 72 69 10 f0       	push   $0xf0106972
f0102c2b:	68 5e 04 00 00       	push   $0x45e
f0102c30:	68 4c 69 10 f0       	push   $0xf010694c
f0102c35:	e8 06 d4 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c3a:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c41:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f0102c44:	89 f0                	mov    %esi,%eax
f0102c46:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102c4c:	c1 f8 03             	sar    $0x3,%eax
f0102c4f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c52:	89 c2                	mov    %eax,%edx
f0102c54:	c1 ea 0c             	shr    $0xc,%edx
f0102c57:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0102c5d:	72 12                	jb     f0102c71 <mem_init+0x1a36>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c5f:	50                   	push   %eax
f0102c60:	68 44 64 10 f0       	push   $0xf0106444
f0102c65:	6a 58                	push   $0x58
f0102c67:	68 58 69 10 f0       	push   $0xf0106958
f0102c6c:	e8 cf d3 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c71:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c78:	03 03 03 
f0102c7b:	74 19                	je     f0102c96 <mem_init+0x1a5b>
f0102c7d:	68 1c 76 10 f0       	push   $0xf010761c
f0102c82:	68 72 69 10 f0       	push   $0xf0106972
f0102c87:	68 60 04 00 00       	push   $0x460
f0102c8c:	68 4c 69 10 f0       	push   $0xf010694c
f0102c91:	e8 aa d3 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c96:	83 ec 08             	sub    $0x8,%esp
f0102c99:	68 00 10 00 00       	push   $0x1000
f0102c9e:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102ca4:	e8 a7 e4 ff ff       	call   f0101150 <page_remove>
	assert(pp2->pp_ref == 0);
f0102ca9:	83 c4 10             	add    $0x10,%esp
f0102cac:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102cb1:	74 19                	je     f0102ccc <mem_init+0x1a91>
f0102cb3:	68 b7 6b 10 f0       	push   $0xf0106bb7
f0102cb8:	68 72 69 10 f0       	push   $0xf0106972
f0102cbd:	68 62 04 00 00       	push   $0x462
f0102cc2:	68 4c 69 10 f0       	push   $0xf010694c
f0102cc7:	e8 74 d3 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ccc:	8b 0d 8c fe 22 f0    	mov    0xf022fe8c,%ecx
f0102cd2:	8b 11                	mov    (%ecx),%edx
f0102cd4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102cda:	89 d8                	mov    %ebx,%eax
f0102cdc:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102ce2:	c1 f8 03             	sar    $0x3,%eax
f0102ce5:	c1 e0 0c             	shl    $0xc,%eax
f0102ce8:	39 c2                	cmp    %eax,%edx
f0102cea:	74 19                	je     f0102d05 <mem_init+0x1aca>
f0102cec:	68 78 6f 10 f0       	push   $0xf0106f78
f0102cf1:	68 72 69 10 f0       	push   $0xf0106972
f0102cf6:	68 65 04 00 00       	push   $0x465
f0102cfb:	68 4c 69 10 f0       	push   $0xf010694c
f0102d00:	e8 3b d3 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102d05:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d0b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102d10:	74 19                	je     f0102d2b <mem_init+0x1af0>
f0102d12:	68 6e 6b 10 f0       	push   $0xf0106b6e
f0102d17:	68 72 69 10 f0       	push   $0xf0106972
f0102d1c:	68 67 04 00 00       	push   $0x467
f0102d21:	68 4c 69 10 f0       	push   $0xf010694c
f0102d26:	e8 15 d3 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102d2b:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102d31:	83 ec 0c             	sub    $0xc,%esp
f0102d34:	53                   	push   %ebx
f0102d35:	e8 f6 e1 ff ff       	call   f0100f30 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d3a:	c7 04 24 48 76 10 f0 	movl   $0xf0107648,(%esp)
f0102d41:	e8 1c 0a 00 00       	call   f0103762 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
	cprintf("mem_init() success!\n**************\n\n\n");
f0102d46:	c7 04 24 74 76 10 f0 	movl   $0xf0107674,(%esp)
f0102d4d:	e8 10 0a 00 00       	call   f0103762 <cprintf>
}
f0102d52:	83 c4 10             	add    $0x10,%esp
f0102d55:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d58:	5b                   	pop    %ebx
f0102d59:	5e                   	pop    %esi
f0102d5a:	5f                   	pop    %edi
f0102d5b:	5d                   	pop    %ebp
f0102d5c:	c3                   	ret    

f0102d5d <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102d5d:	55                   	push   %ebp
f0102d5e:	89 e5                	mov    %esp,%ebp
f0102d60:	57                   	push   %edi
f0102d61:	56                   	push   %esi
f0102d62:	53                   	push   %ebx
f0102d63:	83 ec 1c             	sub    $0x1c,%esp
f0102d66:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102d69:	8b 75 14             	mov    0x14(%ebp),%esi
    // LAB 3: Your code here.
    char * end = NULL;
    char * start = NULL;
    start = ROUNDDOWN((char *)va, PGSIZE); 
f0102d6c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d6f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102d74:	89 c3                	mov    %eax,%ebx
f0102d76:	89 45 e0             	mov    %eax,-0x20(%ebp)
    end = ROUNDUP((char *)(va + len), PGSIZE);
f0102d79:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d7c:	03 45 10             	add    0x10(%ebp),%eax
f0102d7f:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102d84:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102d89:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    pte_t *cur = NULL;

    for(; start < end; start += PGSIZE) {
f0102d8c:	eb 4e                	jmp    f0102ddc <user_mem_check+0x7f>
        cur = pgdir_walk(env->env_pgdir, (void *)start, 0);
f0102d8e:	83 ec 04             	sub    $0x4,%esp
f0102d91:	6a 00                	push   $0x0
f0102d93:	53                   	push   %ebx
f0102d94:	ff 77 60             	pushl  0x60(%edi)
f0102d97:	e8 f6 e1 ff ff       	call   f0100f92 <pgdir_walk>
        if((int)start > ULIM || cur == NULL || ((uint32_t)(*cur) & perm) != perm) {
f0102d9c:	89 da                	mov    %ebx,%edx
f0102d9e:	83 c4 10             	add    $0x10,%esp
f0102da1:	81 fb 00 00 80 ef    	cmp    $0xef800000,%ebx
f0102da7:	77 0c                	ja     f0102db5 <user_mem_check+0x58>
f0102da9:	85 c0                	test   %eax,%eax
f0102dab:	74 08                	je     f0102db5 <user_mem_check+0x58>
f0102dad:	89 f1                	mov    %esi,%ecx
f0102daf:	23 08                	and    (%eax),%ecx
f0102db1:	39 ce                	cmp    %ecx,%esi
f0102db3:	74 21                	je     f0102dd6 <user_mem_check+0x79>
              if(start == ROUNDDOWN((char *)va, PGSIZE)) {
f0102db5:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0102db8:	75 0f                	jne    f0102dc9 <user_mem_check+0x6c>
                    user_mem_check_addr = (uintptr_t)va;
f0102dba:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102dbd:	a3 40 f2 22 f0       	mov    %eax,0xf022f240
              }
              else {
                      user_mem_check_addr = (uintptr_t)start;
              }
              return -E_FAULT;
f0102dc2:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102dc7:	eb 1d                	jmp    f0102de6 <user_mem_check+0x89>
        if((int)start > ULIM || cur == NULL || ((uint32_t)(*cur) & perm) != perm) {
              if(start == ROUNDDOWN((char *)va, PGSIZE)) {
                    user_mem_check_addr = (uintptr_t)va;
              }
              else {
                      user_mem_check_addr = (uintptr_t)start;
f0102dc9:	89 15 40 f2 22 f0    	mov    %edx,0xf022f240
              }
              return -E_FAULT;
f0102dcf:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102dd4:	eb 10                	jmp    f0102de6 <user_mem_check+0x89>
    char * start = NULL;
    start = ROUNDDOWN((char *)va, PGSIZE); 
    end = ROUNDUP((char *)(va + len), PGSIZE);
    pte_t *cur = NULL;

    for(; start < end; start += PGSIZE) {
f0102dd6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ddc:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102ddf:	72 ad                	jb     f0102d8e <user_mem_check+0x31>
              }
              return -E_FAULT;
        }
    }
        
    return 0;
f0102de1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102de6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102de9:	5b                   	pop    %ebx
f0102dea:	5e                   	pop    %esi
f0102deb:	5f                   	pop    %edi
f0102dec:	5d                   	pop    %ebp
f0102ded:	c3                   	ret    

f0102dee <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102dee:	55                   	push   %ebp
f0102def:	89 e5                	mov    %esp,%ebp
f0102df1:	53                   	push   %ebx
f0102df2:	83 ec 04             	sub    $0x4,%esp
f0102df5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102df8:	8b 45 14             	mov    0x14(%ebp),%eax
f0102dfb:	83 c8 04             	or     $0x4,%eax
f0102dfe:	50                   	push   %eax
f0102dff:	ff 75 10             	pushl  0x10(%ebp)
f0102e02:	ff 75 0c             	pushl  0xc(%ebp)
f0102e05:	53                   	push   %ebx
f0102e06:	e8 52 ff ff ff       	call   f0102d5d <user_mem_check>
f0102e0b:	83 c4 10             	add    $0x10,%esp
f0102e0e:	85 c0                	test   %eax,%eax
f0102e10:	79 21                	jns    f0102e33 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102e12:	83 ec 04             	sub    $0x4,%esp
f0102e15:	ff 35 40 f2 22 f0    	pushl  0xf022f240
f0102e1b:	ff 73 48             	pushl  0x48(%ebx)
f0102e1e:	68 9c 76 10 f0       	push   $0xf010769c
f0102e23:	e8 3a 09 00 00       	call   f0103762 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102e28:	89 1c 24             	mov    %ebx,(%esp)
f0102e2b:	e8 5d 06 00 00       	call   f010348d <env_destroy>
f0102e30:	83 c4 10             	add    $0x10,%esp
	}
}
f0102e33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102e36:	c9                   	leave  
f0102e37:	c3                   	ret    

f0102e38 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102e38:	55                   	push   %ebp
f0102e39:	89 e5                	mov    %esp,%ebp
f0102e3b:	57                   	push   %edi
f0102e3c:	56                   	push   %esi
f0102e3d:	53                   	push   %ebx
f0102e3e:	83 ec 0c             	sub    $0xc,%esp
f0102e41:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *start=ROUNDDOWN(va,PGSIZE),*end=ROUNDUP(va+len,PGSIZE);
f0102e43:	89 d3                	mov    %edx,%ebx
f0102e45:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102e4b:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102e52:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for (void * addr=start;addr<end;addr+=PGSIZE){
f0102e58:	eb 59                	jmp    f0102eb3 <region_alloc+0x7b>
		struct PageInfo* p=page_alloc(0);
f0102e5a:	83 ec 0c             	sub    $0xc,%esp
f0102e5d:	6a 00                	push   $0x0
f0102e5f:	e8 5c e0 ff ff       	call   f0100ec0 <page_alloc>
		if(p==NULL){
f0102e64:	83 c4 10             	add    $0x10,%esp
f0102e67:	85 c0                	test   %eax,%eax
f0102e69:	75 17                	jne    f0102e82 <region_alloc+0x4a>
			panic("region alloc failed: No more page to be allocated.\n");
f0102e6b:	83 ec 04             	sub    $0x4,%esp
f0102e6e:	68 d4 76 10 f0       	push   $0xf01076d4
f0102e73:	68 29 01 00 00       	push   $0x129
f0102e78:	68 8c 77 10 f0       	push   $0xf010778c
f0102e7d:	e8 be d1 ff ff       	call   f0100040 <_panic>
		}
		else {
			if(page_insert(e->env_pgdir,p,addr, PTE_U | PTE_W)==-E_NO_MEM){
f0102e82:	6a 06                	push   $0x6
f0102e84:	53                   	push   %ebx
f0102e85:	50                   	push   %eax
f0102e86:	ff 77 60             	pushl  0x60(%edi)
f0102e89:	e8 08 e3 ff ff       	call   f0101196 <page_insert>
f0102e8e:	83 c4 10             	add    $0x10,%esp
f0102e91:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102e94:	75 17                	jne    f0102ead <region_alloc+0x75>
				panic("region alloc failed: page table couldn't be allocated.\n");
f0102e96:	83 ec 04             	sub    $0x4,%esp
f0102e99:	68 08 77 10 f0       	push   $0xf0107708
f0102e9e:	68 2d 01 00 00       	push   $0x12d
f0102ea3:	68 8c 77 10 f0       	push   $0xf010778c
f0102ea8:	e8 93 d1 ff ff       	call   f0100040 <_panic>
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *start=ROUNDDOWN(va,PGSIZE),*end=ROUNDUP(va+len,PGSIZE);
	for (void * addr=start;addr<end;addr+=PGSIZE){
f0102ead:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102eb3:	39 f3                	cmp    %esi,%ebx
f0102eb5:	72 a3                	jb     f0102e5a <region_alloc+0x22>
				panic("region alloc failed: page table couldn't be allocated.\n");
			}
		}
	}
	
}
f0102eb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102eba:	5b                   	pop    %ebx
f0102ebb:	5e                   	pop    %esi
f0102ebc:	5f                   	pop    %edi
f0102ebd:	5d                   	pop    %ebp
f0102ebe:	c3                   	ret    

f0102ebf <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102ebf:	55                   	push   %ebp
f0102ec0:	89 e5                	mov    %esp,%ebp
f0102ec2:	56                   	push   %esi
f0102ec3:	53                   	push   %ebx
f0102ec4:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ec7:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102eca:	85 c0                	test   %eax,%eax
f0102ecc:	75 1a                	jne    f0102ee8 <envid2env+0x29>
		*env_store = curenv;
f0102ece:	e8 b3 2e 00 00       	call   f0105d86 <cpunum>
f0102ed3:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ed6:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0102edc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102edf:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102ee1:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ee6:	eb 70                	jmp    f0102f58 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102ee8:	89 c3                	mov    %eax,%ebx
f0102eea:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102ef0:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102ef3:	03 1d 4c f2 22 f0    	add    0xf022f24c,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102ef9:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102efd:	74 05                	je     f0102f04 <envid2env+0x45>
f0102eff:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102f02:	74 10                	je     f0102f14 <envid2env+0x55>
		*env_store = 0;
f0102f04:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f07:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102f0d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102f12:	eb 44                	jmp    f0102f58 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102f14:	84 d2                	test   %dl,%dl
f0102f16:	74 36                	je     f0102f4e <envid2env+0x8f>
f0102f18:	e8 69 2e 00 00       	call   f0105d86 <cpunum>
f0102f1d:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f20:	3b 98 28 00 23 f0    	cmp    -0xfdcffd8(%eax),%ebx
f0102f26:	74 26                	je     f0102f4e <envid2env+0x8f>
f0102f28:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102f2b:	e8 56 2e 00 00       	call   f0105d86 <cpunum>
f0102f30:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f33:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0102f39:	3b 70 48             	cmp    0x48(%eax),%esi
f0102f3c:	74 10                	je     f0102f4e <envid2env+0x8f>
		*env_store = 0;
f0102f3e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f41:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102f47:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102f4c:	eb 0a                	jmp    f0102f58 <envid2env+0x99>
	}

	*env_store = e;
f0102f4e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f51:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102f53:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102f58:	5b                   	pop    %ebx
f0102f59:	5e                   	pop    %esi
f0102f5a:	5d                   	pop    %ebp
f0102f5b:	c3                   	ret    

f0102f5c <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102f5c:	55                   	push   %ebp
f0102f5d:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0102f5f:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f0102f64:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0102f67:	b8 23 00 00 00       	mov    $0x23,%eax
f0102f6c:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0102f6e:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0102f70:	b8 10 00 00 00       	mov    $0x10,%eax
f0102f75:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0102f77:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0102f79:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0102f7b:	ea 82 2f 10 f0 08 00 	ljmp   $0x8,$0xf0102f82
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0102f82:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f87:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102f8a:	5d                   	pop    %ebp
f0102f8b:	c3                   	ret    

f0102f8c <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102f8c:	55                   	push   %ebp
f0102f8d:	89 e5                	mov    %esp,%ebp
f0102f8f:	56                   	push   %esi
f0102f90:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	//上面分析过 要从0 开始，所以我们倒着遍历。
	env_free_list=NULL;
	for	(int i=NENV-1;i>=0;i--){
		envs[i].env_id=0;
f0102f91:	8b 35 4c f2 22 f0    	mov    0xf022f24c,%esi
f0102f97:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102f9d:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102fa0:	ba 00 00 00 00       	mov    $0x0,%edx
f0102fa5:	89 c1                	mov    %eax,%ecx
f0102fa7:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_status=ENV_FREE;
f0102fae:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_link=env_free_list;
f0102fb5:	89 50 44             	mov    %edx,0x44(%eax)
f0102fb8:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list=&envs[i];
f0102fbb:	89 ca                	mov    %ecx,%edx
{
	// Set up envs array
	// LAB 3: Your code here.
	//上面分析过 要从0 开始，所以我们倒着遍历。
	env_free_list=NULL;
	for	(int i=NENV-1;i>=0;i--){
f0102fbd:	39 d8                	cmp    %ebx,%eax
f0102fbf:	75 e4                	jne    f0102fa5 <env_init+0x19>
f0102fc1:	89 35 50 f2 22 f0    	mov    %esi,0xf022f250
		envs[i].env_status=ENV_FREE;
		envs[i].env_link=env_free_list;
		env_free_list=&envs[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0102fc7:	e8 90 ff ff ff       	call   f0102f5c <env_init_percpu>
}
f0102fcc:	5b                   	pop    %ebx
f0102fcd:	5e                   	pop    %esi
f0102fce:	5d                   	pop    %ebp
f0102fcf:	c3                   	ret    

f0102fd0 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102fd0:	55                   	push   %ebp
f0102fd1:	89 e5                	mov    %esp,%ebp
f0102fd3:	53                   	push   %ebx
f0102fd4:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102fd7:	8b 1d 50 f2 22 f0    	mov    0xf022f250,%ebx
f0102fdd:	85 db                	test   %ebx,%ebx
f0102fdf:	0f 84 69 01 00 00    	je     f010314e <env_alloc+0x17e>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102fe5:	83 ec 0c             	sub    $0xc,%esp
f0102fe8:	6a 01                	push   $0x1
f0102fea:	e8 d1 de ff ff       	call   f0100ec0 <page_alloc>
f0102fef:	83 c4 10             	add    $0x10,%esp
f0102ff2:	85 c0                	test   %eax,%eax
f0102ff4:	0f 84 5b 01 00 00    	je     f0103155 <env_alloc+0x185>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f0102ffa:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f0102fff:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0103005:	c1 f8 03             	sar    $0x3,%eax
f0103008:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010300b:	89 c2                	mov    %eax,%edx
f010300d:	c1 ea 0c             	shr    $0xc,%edx
f0103010:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0103016:	72 12                	jb     f010302a <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103018:	50                   	push   %eax
f0103019:	68 44 64 10 f0       	push   $0xf0106444
f010301e:	6a 58                	push   $0x58
f0103020:	68 58 69 10 f0       	push   $0xf0106958
f0103025:	e8 16 d0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010302a:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir=(pde_t *)page2kva(p);
f010302f:	89 43 60             	mov    %eax,0x60(%ebx)

	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103032:	83 ec 04             	sub    $0x4,%esp
f0103035:	68 00 10 00 00       	push   $0x1000
f010303a:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0103040:	50                   	push   %eax
f0103041:	e8 d3 27 00 00       	call   f0105819 <memcpy>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103046:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103049:	83 c4 10             	add    $0x10,%esp
f010304c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103051:	77 15                	ja     f0103068 <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103053:	50                   	push   %eax
f0103054:	68 68 64 10 f0       	push   $0xf0106468
f0103059:	68 c7 00 00 00       	push   $0xc7
f010305e:	68 8c 77 10 f0       	push   $0xf010778c
f0103063:	e8 d8 cf ff ff       	call   f0100040 <_panic>
f0103068:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010306e:	83 ca 05             	or     $0x5,%edx
f0103071:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103077:	8b 43 48             	mov    0x48(%ebx),%eax
f010307a:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010307f:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103084:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103089:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010308c:	89 da                	mov    %ebx,%edx
f010308e:	2b 15 4c f2 22 f0    	sub    0xf022f24c,%edx
f0103094:	c1 fa 02             	sar    $0x2,%edx
f0103097:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f010309d:	09 d0                	or     %edx,%eax
f010309f:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01030a2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030a5:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01030a8:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01030af:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01030b6:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01030bd:	83 ec 04             	sub    $0x4,%esp
f01030c0:	6a 44                	push   $0x44
f01030c2:	6a 00                	push   $0x0
f01030c4:	53                   	push   %ebx
f01030c5:	e8 9a 26 00 00       	call   f0105764 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01030ca:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01030d0:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01030d6:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01030dc:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01030e3:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f01030e9:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01030f0:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01030f7:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01030fb:	8b 43 44             	mov    0x44(%ebx),%eax
f01030fe:	a3 50 f2 22 f0       	mov    %eax,0xf022f250
	*newenv_store = e;
f0103103:	8b 45 08             	mov    0x8(%ebp),%eax
f0103106:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103108:	8b 5b 48             	mov    0x48(%ebx),%ebx
f010310b:	e8 76 2c 00 00       	call   f0105d86 <cpunum>
f0103110:	6b c0 74             	imul   $0x74,%eax,%eax
f0103113:	83 c4 10             	add    $0x10,%esp
f0103116:	ba 00 00 00 00       	mov    $0x0,%edx
f010311b:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0103122:	74 11                	je     f0103135 <env_alloc+0x165>
f0103124:	e8 5d 2c 00 00       	call   f0105d86 <cpunum>
f0103129:	6b c0 74             	imul   $0x74,%eax,%eax
f010312c:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103132:	8b 50 48             	mov    0x48(%eax),%edx
f0103135:	83 ec 04             	sub    $0x4,%esp
f0103138:	53                   	push   %ebx
f0103139:	52                   	push   %edx
f010313a:	68 97 77 10 f0       	push   $0xf0107797
f010313f:	e8 1e 06 00 00       	call   f0103762 <cprintf>
	return 0;
f0103144:	83 c4 10             	add    $0x10,%esp
f0103147:	b8 00 00 00 00       	mov    $0x0,%eax
f010314c:	eb 0c                	jmp    f010315a <env_alloc+0x18a>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010314e:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103153:	eb 05                	jmp    f010315a <env_alloc+0x18a>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103155:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f010315a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010315d:	c9                   	leave  
f010315e:	c3                   	ret    

f010315f <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010315f:	55                   	push   %ebp
f0103160:	89 e5                	mov    %esp,%ebp
f0103162:	57                   	push   %edi
f0103163:	56                   	push   %esi
f0103164:	53                   	push   %ebx
f0103165:	83 ec 34             	sub    $0x34,%esp
f0103168:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env * e;
	int r=env_alloc(&e,0);
f010316b:	6a 00                	push   $0x0
f010316d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103170:	50                   	push   %eax
f0103171:	e8 5a fe ff ff       	call   f0102fd0 <env_alloc>
	if(r!=0){
f0103176:	83 c4 10             	add    $0x10,%esp
f0103179:	85 c0                	test   %eax,%eax
f010317b:	74 25                	je     f01031a2 <env_create+0x43>
		cprintf("%e\n",r);
f010317d:	83 ec 08             	sub    $0x8,%esp
f0103180:	50                   	push   %eax
f0103181:	68 b0 7e 10 f0       	push   $0xf0107eb0
f0103186:	e8 d7 05 00 00       	call   f0103762 <cprintf>
		panic("env_create:error");
f010318b:	83 c4 0c             	add    $0xc,%esp
f010318e:	68 ac 77 10 f0       	push   $0xf01077ac
f0103193:	68 97 01 00 00       	push   $0x197
f0103198:	68 8c 77 10 f0       	push   $0xf010778c
f010319d:	e8 9e ce ff ff       	call   f0100040 <_panic>
	}
	load_icode(e,binary);
f01031a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01031a5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	//根据，分析 首先需要做的一件事 应该是讲binary 转换成 ELF，参照bootmain。
	struct Proghdr *ph, *eph;
	struct Elf * ELFHDR=(struct Elf *)binary;
	if (ELFHDR->e_magic != ELF_MAGIC)panic("The loaded file is not ELF format!\n");
f01031a8:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01031ae:	74 17                	je     f01031c7 <env_create+0x68>
f01031b0:	83 ec 04             	sub    $0x4,%esp
f01031b3:	68 40 77 10 f0       	push   $0xf0107740
f01031b8:	68 6d 01 00 00       	push   $0x16d
f01031bd:	68 8c 77 10 f0       	push   $0xf010778c
f01031c2:	e8 79 ce ff ff       	call   f0100040 <_panic>
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f01031c7:	89 fb                	mov    %edi,%ebx
f01031c9:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + ELFHDR->e_phnum;
f01031cc:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01031d0:	c1 e6 05             	shl    $0x5,%esi
f01031d3:	01 de                	add    %ebx,%esi
	//装载 用户目录
	lcr3(PADDR(e->env_pgdir));
f01031d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01031d8:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031db:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031e0:	77 15                	ja     f01031f7 <env_create+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031e2:	50                   	push   %eax
f01031e3:	68 68 64 10 f0       	push   $0xf0106468
f01031e8:	68 71 01 00 00       	push   $0x171
f01031ed:	68 8c 77 10 f0       	push   $0xf010778c
f01031f2:	e8 49 ce ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01031f7:	05 00 00 00 10       	add    $0x10000000,%eax
f01031fc:	0f 22 d8             	mov    %eax,%cr3
f01031ff:	eb 59                	jmp    f010325a <env_create+0xfb>
	//第二部应该是加载段到内存
	for(;ph<eph;ph++){
		//加载条件是  ph->p_type == ELF_PROG_LOAD，地址是 ph->p_va 大小ph->p_memsz
		if(ph->p_type == ELF_PROG_LOAD){
f0103201:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103204:	75 51                	jne    f0103257 <env_create+0xf8>
			if (ph->p_filesz > ph->p_memsz)
f0103206:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103209:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f010320c:	76 17                	jbe    f0103225 <env_create+0xc6>
                panic("load_icode failed: p_memsz < p_filesz.\n");
f010320e:	83 ec 04             	sub    $0x4,%esp
f0103211:	68 64 77 10 f0       	push   $0xf0107764
f0103216:	68 77 01 00 00       	push   $0x177
f010321b:	68 8c 77 10 f0       	push   $0xf010778c
f0103220:	e8 1b ce ff ff       	call   f0100040 <_panic>
			region_alloc(e, (void *)ph->p_va,ph->p_memsz);
f0103225:	8b 53 08             	mov    0x8(%ebx),%edx
f0103228:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010322b:	e8 08 fc ff ff       	call   f0102e38 <region_alloc>
			//复制ph->p_filesz bytes ，其他的补0
			memset((void *)ph->p_va,0,ph->p_memsz);
f0103230:	83 ec 04             	sub    $0x4,%esp
f0103233:	ff 73 14             	pushl  0x14(%ebx)
f0103236:	6a 00                	push   $0x0
f0103238:	ff 73 08             	pushl  0x8(%ebx)
f010323b:	e8 24 25 00 00       	call   f0105764 <memset>
			memcpy((void *)ph->p_va,binary + ph->p_offset,ph->p_filesz);
f0103240:	83 c4 0c             	add    $0xc,%esp
f0103243:	ff 73 10             	pushl  0x10(%ebx)
f0103246:	89 f8                	mov    %edi,%eax
f0103248:	03 43 04             	add    0x4(%ebx),%eax
f010324b:	50                   	push   %eax
f010324c:	ff 73 08             	pushl  0x8(%ebx)
f010324f:	e8 c5 25 00 00       	call   f0105819 <memcpy>
f0103254:	83 c4 10             	add    $0x10,%esp
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	//装载 用户目录
	lcr3(PADDR(e->env_pgdir));
	//第二部应该是加载段到内存
	for(;ph<eph;ph++){
f0103257:	83 c3 20             	add    $0x20,%ebx
f010325a:	39 de                	cmp    %ebx,%esi
f010325c:	77 a3                	ja     f0103201 <env_create+0xa2>
			//复制ph->p_filesz bytes ，其他的补0
			memset((void *)ph->p_va,0,ph->p_memsz);
			memcpy((void *)ph->p_va,binary + ph->p_offset,ph->p_filesz);
		}
	}
	 lcr3(PADDR(kern_pgdir));
f010325e:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103263:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103268:	77 15                	ja     f010327f <env_create+0x120>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010326a:	50                   	push   %eax
f010326b:	68 68 64 10 f0       	push   $0xf0106468
f0103270:	68 7e 01 00 00       	push   $0x17e
f0103275:	68 8c 77 10 f0       	push   $0xf010778c
f010327a:	e8 c1 cd ff ff       	call   f0100040 <_panic>
f010327f:	05 00 00 00 10       	add    $0x10000000,%eax
f0103284:	0f 22 d8             	mov    %eax,%cr3
	//最后是入口地址  这个实在 inc/trap.h 里面定义的
	 e->env_tf.tf_eip = ELFHDR->e_entry;
f0103287:	8b 47 18             	mov    0x18(%edi),%eax
f010328a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010328d:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	
	// LAB 3: Your code here.
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103290:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103295:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010329a:	89 f8                	mov    %edi,%eax
f010329c:	e8 97 fb ff ff       	call   f0102e38 <region_alloc>
	if(r!=0){
		cprintf("%e\n",r);
		panic("env_create:error");
	}
	load_icode(e,binary);
	e->env_type=type;
f01032a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01032a4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01032a7:	89 50 50             	mov    %edx,0x50(%eax)
}
f01032aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01032ad:	5b                   	pop    %ebx
f01032ae:	5e                   	pop    %esi
f01032af:	5f                   	pop    %edi
f01032b0:	5d                   	pop    %ebp
f01032b1:	c3                   	ret    

f01032b2 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01032b2:	55                   	push   %ebp
f01032b3:	89 e5                	mov    %esp,%ebp
f01032b5:	57                   	push   %edi
f01032b6:	56                   	push   %esi
f01032b7:	53                   	push   %ebx
f01032b8:	83 ec 1c             	sub    $0x1c,%esp
f01032bb:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01032be:	e8 c3 2a 00 00       	call   f0105d86 <cpunum>
f01032c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01032c6:	39 b8 28 00 23 f0    	cmp    %edi,-0xfdcffd8(%eax)
f01032cc:	75 29                	jne    f01032f7 <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f01032ce:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032d3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032d8:	77 15                	ja     f01032ef <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032da:	50                   	push   %eax
f01032db:	68 68 64 10 f0       	push   $0xf0106468
f01032e0:	68 ab 01 00 00       	push   $0x1ab
f01032e5:	68 8c 77 10 f0       	push   $0xf010778c
f01032ea:	e8 51 cd ff ff       	call   f0100040 <_panic>
f01032ef:	05 00 00 00 10       	add    $0x10000000,%eax
f01032f4:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01032f7:	8b 5f 48             	mov    0x48(%edi),%ebx
f01032fa:	e8 87 2a 00 00       	call   f0105d86 <cpunum>
f01032ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0103302:	ba 00 00 00 00       	mov    $0x0,%edx
f0103307:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f010330e:	74 11                	je     f0103321 <env_free+0x6f>
f0103310:	e8 71 2a 00 00       	call   f0105d86 <cpunum>
f0103315:	6b c0 74             	imul   $0x74,%eax,%eax
f0103318:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010331e:	8b 50 48             	mov    0x48(%eax),%edx
f0103321:	83 ec 04             	sub    $0x4,%esp
f0103324:	53                   	push   %ebx
f0103325:	52                   	push   %edx
f0103326:	68 bd 77 10 f0       	push   $0xf01077bd
f010332b:	e8 32 04 00 00       	call   f0103762 <cprintf>
f0103330:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103333:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010333a:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010333d:	89 d0                	mov    %edx,%eax
f010333f:	c1 e0 02             	shl    $0x2,%eax
f0103342:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103345:	8b 47 60             	mov    0x60(%edi),%eax
f0103348:	8b 34 90             	mov    (%eax,%edx,4),%esi
f010334b:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103351:	0f 84 a8 00 00 00    	je     f01033ff <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103357:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010335d:	89 f0                	mov    %esi,%eax
f010335f:	c1 e8 0c             	shr    $0xc,%eax
f0103362:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103365:	39 05 88 fe 22 f0    	cmp    %eax,0xf022fe88
f010336b:	77 15                	ja     f0103382 <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010336d:	56                   	push   %esi
f010336e:	68 44 64 10 f0       	push   $0xf0106444
f0103373:	68 ba 01 00 00       	push   $0x1ba
f0103378:	68 8c 77 10 f0       	push   $0xf010778c
f010337d:	e8 be cc ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103382:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103385:	c1 e0 16             	shl    $0x16,%eax
f0103388:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010338b:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103390:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103397:	01 
f0103398:	74 17                	je     f01033b1 <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010339a:	83 ec 08             	sub    $0x8,%esp
f010339d:	89 d8                	mov    %ebx,%eax
f010339f:	c1 e0 0c             	shl    $0xc,%eax
f01033a2:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01033a5:	50                   	push   %eax
f01033a6:	ff 77 60             	pushl  0x60(%edi)
f01033a9:	e8 a2 dd ff ff       	call   f0101150 <page_remove>
f01033ae:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01033b1:	83 c3 01             	add    $0x1,%ebx
f01033b4:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01033ba:	75 d4                	jne    f0103390 <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01033bc:	8b 47 60             	mov    0x60(%edi),%eax
f01033bf:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01033c2:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{	// 或得物理地址的数据结构
	if (PGNUM(pa) >= npages)
f01033c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01033cc:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f01033d2:	72 14                	jb     f01033e8 <env_free+0x136>
		panic("pa2page called with invalid pa");
f01033d4:	83 ec 04             	sub    $0x4,%esp
f01033d7:	68 d4 6d 10 f0       	push   $0xf0106dd4
f01033dc:	6a 51                	push   $0x51
f01033de:	68 58 69 10 f0       	push   $0xf0106958
f01033e3:	e8 58 cc ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f01033e8:	83 ec 0c             	sub    $0xc,%esp
f01033eb:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
f01033f0:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01033f3:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01033f6:	50                   	push   %eax
f01033f7:	e8 6f db ff ff       	call   f0100f6b <page_decref>
f01033fc:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01033ff:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103403:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103406:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010340b:	0f 85 29 ff ff ff    	jne    f010333a <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103411:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103414:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103419:	77 15                	ja     f0103430 <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010341b:	50                   	push   %eax
f010341c:	68 68 64 10 f0       	push   $0xf0106468
f0103421:	68 c8 01 00 00       	push   $0x1c8
f0103426:	68 8c 77 10 f0       	push   $0xf010778c
f010342b:	e8 10 cc ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103430:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{	// 或得物理地址的数据结构
	if (PGNUM(pa) >= npages)
f0103437:	05 00 00 00 10       	add    $0x10000000,%eax
f010343c:	c1 e8 0c             	shr    $0xc,%eax
f010343f:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f0103445:	72 14                	jb     f010345b <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f0103447:	83 ec 04             	sub    $0x4,%esp
f010344a:	68 d4 6d 10 f0       	push   $0xf0106dd4
f010344f:	6a 51                	push   $0x51
f0103451:	68 58 69 10 f0       	push   $0xf0106958
f0103456:	e8 e5 cb ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f010345b:	83 ec 0c             	sub    $0xc,%esp
f010345e:	8b 15 90 fe 22 f0    	mov    0xf022fe90,%edx
f0103464:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103467:	50                   	push   %eax
f0103468:	e8 fe da ff ff       	call   f0100f6b <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010346d:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103474:	a1 50 f2 22 f0       	mov    0xf022f250,%eax
f0103479:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010347c:	89 3d 50 f2 22 f0    	mov    %edi,0xf022f250
}
f0103482:	83 c4 10             	add    $0x10,%esp
f0103485:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103488:	5b                   	pop    %ebx
f0103489:	5e                   	pop    %esi
f010348a:	5f                   	pop    %edi
f010348b:	5d                   	pop    %ebp
f010348c:	c3                   	ret    

f010348d <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f010348d:	55                   	push   %ebp
f010348e:	89 e5                	mov    %esp,%ebp
f0103490:	53                   	push   %ebx
f0103491:	83 ec 04             	sub    $0x4,%esp
f0103494:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103497:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f010349b:	75 19                	jne    f01034b6 <env_destroy+0x29>
f010349d:	e8 e4 28 00 00       	call   f0105d86 <cpunum>
f01034a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01034a5:	3b 98 28 00 23 f0    	cmp    -0xfdcffd8(%eax),%ebx
f01034ab:	74 09                	je     f01034b6 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01034ad:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01034b4:	eb 33                	jmp    f01034e9 <env_destroy+0x5c>
	}

	env_free(e);
f01034b6:	83 ec 0c             	sub    $0xc,%esp
f01034b9:	53                   	push   %ebx
f01034ba:	e8 f3 fd ff ff       	call   f01032b2 <env_free>

	if (curenv == e) {
f01034bf:	e8 c2 28 00 00       	call   f0105d86 <cpunum>
f01034c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01034c7:	83 c4 10             	add    $0x10,%esp
f01034ca:	3b 98 28 00 23 f0    	cmp    -0xfdcffd8(%eax),%ebx
f01034d0:	75 17                	jne    f01034e9 <env_destroy+0x5c>
		curenv = NULL;
f01034d2:	e8 af 28 00 00       	call   f0105d86 <cpunum>
f01034d7:	6b c0 74             	imul   $0x74,%eax,%eax
f01034da:	c7 80 28 00 23 f0 00 	movl   $0x0,-0xfdcffd8(%eax)
f01034e1:	00 00 00 
		sched_yield();
f01034e4:	e8 79 10 00 00       	call   f0104562 <sched_yield>
	}
}
f01034e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01034ec:	c9                   	leave  
f01034ed:	c3                   	ret    

f01034ee <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01034ee:	55                   	push   %ebp
f01034ef:	89 e5                	mov    %esp,%ebp
f01034f1:	53                   	push   %ebx
f01034f2:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01034f5:	e8 8c 28 00 00       	call   f0105d86 <cpunum>
f01034fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01034fd:	8b 98 28 00 23 f0    	mov    -0xfdcffd8(%eax),%ebx
f0103503:	e8 7e 28 00 00       	call   f0105d86 <cpunum>
f0103508:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f010350b:	8b 65 08             	mov    0x8(%ebp),%esp
f010350e:	61                   	popa   
f010350f:	07                   	pop    %es
f0103510:	1f                   	pop    %ds
f0103511:	83 c4 08             	add    $0x8,%esp
f0103514:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103515:	83 ec 04             	sub    $0x4,%esp
f0103518:	68 d3 77 10 f0       	push   $0xf01077d3
f010351d:	68 ff 01 00 00       	push   $0x1ff
f0103522:	68 8c 77 10 f0       	push   $0xf010778c
f0103527:	e8 14 cb ff ff       	call   f0100040 <_panic>

f010352c <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010352c:	55                   	push   %ebp
f010352d:	89 e5                	mov    %esp,%ebp
f010352f:	53                   	push   %ebx
f0103530:	83 ec 04             	sub    $0x4,%esp
f0103533:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv!=NULL&&curenv->env_status==ENV_RUNNING){
f0103536:	e8 4b 28 00 00       	call   f0105d86 <cpunum>
f010353b:	6b c0 74             	imul   $0x74,%eax,%eax
f010353e:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0103545:	74 29                	je     f0103570 <env_run+0x44>
f0103547:	e8 3a 28 00 00       	call   f0105d86 <cpunum>
f010354c:	6b c0 74             	imul   $0x74,%eax,%eax
f010354f:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103555:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103559:	75 15                	jne    f0103570 <env_run+0x44>
		curenv->env_status=ENV_RUNNABLE;
f010355b:	e8 26 28 00 00       	call   f0105d86 <cpunum>
f0103560:	6b c0 74             	imul   $0x74,%eax,%eax
f0103563:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103569:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
	curenv=e;
f0103570:	e8 11 28 00 00       	call   f0105d86 <cpunum>
f0103575:	6b c0 74             	imul   $0x74,%eax,%eax
f0103578:	89 98 28 00 23 f0    	mov    %ebx,-0xfdcffd8(%eax)
	// if(&curenv->env_tf==NULL)cprintf("***");
	e->env_status=ENV_RUNNING;
f010357e:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	e->env_runs++;
f0103585:	83 43 58 01          	addl   $0x1,0x58(%ebx)
	lcr3(PADDR(curenv->env_pgdir));
f0103589:	e8 f8 27 00 00       	call   f0105d86 <cpunum>
f010358e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103591:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103597:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010359a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010359f:	77 15                	ja     f01035b6 <env_run+0x8a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035a1:	50                   	push   %eax
f01035a2:	68 68 64 10 f0       	push   $0xf0106468
f01035a7:	68 24 02 00 00       	push   $0x224
f01035ac:	68 8c 77 10 f0       	push   $0xf010778c
f01035b1:	e8 8a ca ff ff       	call   f0100040 <_panic>
f01035b6:	05 00 00 00 10       	add    $0x10000000,%eax
f01035bb:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01035be:	83 ec 0c             	sub    $0xc,%esp
f01035c1:	68 c0 03 12 f0       	push   $0xf01203c0
f01035c6:	e8 c6 2a 00 00       	call   f0106091 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01035cb:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(&curenv->env_tf);
f01035cd:	e8 b4 27 00 00       	call   f0105d86 <cpunum>
f01035d2:	83 c4 04             	add    $0x4,%esp
f01035d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01035d8:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f01035de:	e8 0b ff ff ff       	call   f01034ee <env_pop_tf>

f01035e3 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01035e3:	55                   	push   %ebp
f01035e4:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01035e6:	ba 70 00 00 00       	mov    $0x70,%edx
f01035eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01035ee:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01035ef:	ba 71 00 00 00       	mov    $0x71,%edx
f01035f4:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01035f5:	0f b6 c0             	movzbl %al,%eax
}
f01035f8:	5d                   	pop    %ebp
f01035f9:	c3                   	ret    

f01035fa <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01035fa:	55                   	push   %ebp
f01035fb:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01035fd:	ba 70 00 00 00       	mov    $0x70,%edx
f0103602:	8b 45 08             	mov    0x8(%ebp),%eax
f0103605:	ee                   	out    %al,(%dx)
f0103606:	ba 71 00 00 00       	mov    $0x71,%edx
f010360b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010360e:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010360f:	5d                   	pop    %ebp
f0103610:	c3                   	ret    

f0103611 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103611:	55                   	push   %ebp
f0103612:	89 e5                	mov    %esp,%ebp
f0103614:	56                   	push   %esi
f0103615:	53                   	push   %ebx
f0103616:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103619:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f010361f:	80 3d 54 f2 22 f0 00 	cmpb   $0x0,0xf022f254
f0103626:	74 5a                	je     f0103682 <irq_setmask_8259A+0x71>
f0103628:	89 c6                	mov    %eax,%esi
f010362a:	ba 21 00 00 00       	mov    $0x21,%edx
f010362f:	ee                   	out    %al,(%dx)
f0103630:	66 c1 e8 08          	shr    $0x8,%ax
f0103634:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103639:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f010363a:	83 ec 0c             	sub    $0xc,%esp
f010363d:	68 df 77 10 f0       	push   $0xf01077df
f0103642:	e8 1b 01 00 00       	call   f0103762 <cprintf>
f0103647:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f010364a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f010364f:	0f b7 f6             	movzwl %si,%esi
f0103652:	f7 d6                	not    %esi
f0103654:	0f a3 de             	bt     %ebx,%esi
f0103657:	73 11                	jae    f010366a <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103659:	83 ec 08             	sub    $0x8,%esp
f010365c:	53                   	push   %ebx
f010365d:	68 87 7c 10 f0       	push   $0xf0107c87
f0103662:	e8 fb 00 00 00       	call   f0103762 <cprintf>
f0103667:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010366a:	83 c3 01             	add    $0x1,%ebx
f010366d:	83 fb 10             	cmp    $0x10,%ebx
f0103670:	75 e2                	jne    f0103654 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103672:	83 ec 0c             	sub    $0xc,%esp
f0103675:	68 52 6c 10 f0       	push   $0xf0106c52
f010367a:	e8 e3 00 00 00       	call   f0103762 <cprintf>
f010367f:	83 c4 10             	add    $0x10,%esp
}
f0103682:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103685:	5b                   	pop    %ebx
f0103686:	5e                   	pop    %esi
f0103687:	5d                   	pop    %ebp
f0103688:	c3                   	ret    

f0103689 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103689:	c6 05 54 f2 22 f0 01 	movb   $0x1,0xf022f254
f0103690:	ba 21 00 00 00       	mov    $0x21,%edx
f0103695:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010369a:	ee                   	out    %al,(%dx)
f010369b:	ba a1 00 00 00       	mov    $0xa1,%edx
f01036a0:	ee                   	out    %al,(%dx)
f01036a1:	ba 20 00 00 00       	mov    $0x20,%edx
f01036a6:	b8 11 00 00 00       	mov    $0x11,%eax
f01036ab:	ee                   	out    %al,(%dx)
f01036ac:	ba 21 00 00 00       	mov    $0x21,%edx
f01036b1:	b8 20 00 00 00       	mov    $0x20,%eax
f01036b6:	ee                   	out    %al,(%dx)
f01036b7:	b8 04 00 00 00       	mov    $0x4,%eax
f01036bc:	ee                   	out    %al,(%dx)
f01036bd:	b8 03 00 00 00       	mov    $0x3,%eax
f01036c2:	ee                   	out    %al,(%dx)
f01036c3:	ba a0 00 00 00       	mov    $0xa0,%edx
f01036c8:	b8 11 00 00 00       	mov    $0x11,%eax
f01036cd:	ee                   	out    %al,(%dx)
f01036ce:	ba a1 00 00 00       	mov    $0xa1,%edx
f01036d3:	b8 28 00 00 00       	mov    $0x28,%eax
f01036d8:	ee                   	out    %al,(%dx)
f01036d9:	b8 02 00 00 00       	mov    $0x2,%eax
f01036de:	ee                   	out    %al,(%dx)
f01036df:	b8 01 00 00 00       	mov    $0x1,%eax
f01036e4:	ee                   	out    %al,(%dx)
f01036e5:	ba 20 00 00 00       	mov    $0x20,%edx
f01036ea:	b8 68 00 00 00       	mov    $0x68,%eax
f01036ef:	ee                   	out    %al,(%dx)
f01036f0:	b8 0a 00 00 00       	mov    $0xa,%eax
f01036f5:	ee                   	out    %al,(%dx)
f01036f6:	ba a0 00 00 00       	mov    $0xa0,%edx
f01036fb:	b8 68 00 00 00       	mov    $0x68,%eax
f0103700:	ee                   	out    %al,(%dx)
f0103701:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103706:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103707:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f010370e:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103712:	74 13                	je     f0103727 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103714:	55                   	push   %ebp
f0103715:	89 e5                	mov    %esp,%ebp
f0103717:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f010371a:	0f b7 c0             	movzwl %ax,%eax
f010371d:	50                   	push   %eax
f010371e:	e8 ee fe ff ff       	call   f0103611 <irq_setmask_8259A>
f0103723:	83 c4 10             	add    $0x10,%esp
}
f0103726:	c9                   	leave  
f0103727:	f3 c3                	repz ret 

f0103729 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103729:	55                   	push   %ebp
f010372a:	89 e5                	mov    %esp,%ebp
f010372c:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010372f:	ff 75 08             	pushl  0x8(%ebp)
f0103732:	e8 16 d0 ff ff       	call   f010074d <cputchar>
	*cnt++;
}
f0103737:	83 c4 10             	add    $0x10,%esp
f010373a:	c9                   	leave  
f010373b:	c3                   	ret    

f010373c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010373c:	55                   	push   %ebp
f010373d:	89 e5                	mov    %esp,%ebp
f010373f:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103742:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103749:	ff 75 0c             	pushl  0xc(%ebp)
f010374c:	ff 75 08             	pushl  0x8(%ebp)
f010374f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103752:	50                   	push   %eax
f0103753:	68 29 37 10 f0       	push   $0xf0103729
f0103758:	e8 e2 18 00 00       	call   f010503f <vprintfmt>
	return cnt;
}
f010375d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103760:	c9                   	leave  
f0103761:	c3                   	ret    

f0103762 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103762:	55                   	push   %ebp
f0103763:	89 e5                	mov    %esp,%ebp
f0103765:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103768:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010376b:	50                   	push   %eax
f010376c:	ff 75 08             	pushl  0x8(%ebp)
f010376f:	e8 c8 ff ff ff       	call   f010373c <vcprintf>
	va_end(ap);

	return cnt;
}
f0103774:	c9                   	leave  
f0103775:	c3                   	ret    

f0103776 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103776:	55                   	push   %ebp
f0103777:	89 e5                	mov    %esp,%ebp
f0103779:	57                   	push   %edi
f010377a:	56                   	push   %esi
f010377b:	53                   	push   %ebx
f010377c:	83 ec 0c             	sub    $0xc,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here
	int i=thiscpu->cpu_id;
f010377f:	e8 02 26 00 00       	call   f0105d86 <cpunum>
f0103784:	6b c0 74             	imul   $0x74,%eax,%eax
f0103787:	0f b6 98 20 00 23 f0 	movzbl -0xfdcffe0(%eax),%ebx
	thiscpu->cpu_ts.ts_esp0=KSTACKTOP-i*(KSTKSIZE+KSTKGAP);
f010378e:	e8 f3 25 00 00       	call   f0105d86 <cpunum>
f0103793:	6b c0 74             	imul   $0x74,%eax,%eax
f0103796:	89 d9                	mov    %ebx,%ecx
f0103798:	c1 e1 10             	shl    $0x10,%ecx
f010379b:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01037a0:	29 ca                	sub    %ecx,%edx
f01037a2:	89 90 30 00 23 f0    	mov    %edx,-0xfdcffd0(%eax)
	thiscpu->cpu_ts.ts_ss0=GD_KD;
f01037a8:	e8 d9 25 00 00       	call   f0105d86 <cpunum>
f01037ad:	6b c0 74             	imul   $0x74,%eax,%eax
f01037b0:	66 c7 80 34 00 23 f0 	movw   $0x10,-0xfdcffcc(%eax)
f01037b7:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f01037b9:	e8 c8 25 00 00       	call   f0105d86 <cpunum>
f01037be:	6b c0 74             	imul   $0x74,%eax,%eax
f01037c1:	66 c7 80 92 00 23 f0 	movw   $0x68,-0xfdcff6e(%eax)
f01037c8:	68 00 

	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f01037ca:	83 c3 05             	add    $0x5,%ebx
f01037cd:	e8 b4 25 00 00       	call   f0105d86 <cpunum>
f01037d2:	89 c7                	mov    %eax,%edi
f01037d4:	e8 ad 25 00 00       	call   f0105d86 <cpunum>
f01037d9:	89 c6                	mov    %eax,%esi
f01037db:	e8 a6 25 00 00       	call   f0105d86 <cpunum>
f01037e0:	66 c7 04 dd 40 03 12 	movw   $0x67,-0xfedfcc0(,%ebx,8)
f01037e7:	f0 67 00 
f01037ea:	6b ff 74             	imul   $0x74,%edi,%edi
f01037ed:	81 c7 2c 00 23 f0    	add    $0xf023002c,%edi
f01037f3:	66 89 3c dd 42 03 12 	mov    %di,-0xfedfcbe(,%ebx,8)
f01037fa:	f0 
f01037fb:	6b d6 74             	imul   $0x74,%esi,%edx
f01037fe:	81 c2 2c 00 23 f0    	add    $0xf023002c,%edx
f0103804:	c1 ea 10             	shr    $0x10,%edx
f0103807:	88 14 dd 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%ebx,8)
f010380e:	c6 04 dd 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%ebx,8)
f0103815:	40 
f0103816:	6b c0 74             	imul   $0x74,%eax,%eax
f0103819:	05 2c 00 23 f0       	add    $0xf023002c,%eax
f010381e:	c1 e8 18             	shr    $0x18,%eax
f0103821:	88 04 dd 47 03 12 f0 	mov    %al,-0xfedfcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f0103828:	c6 04 dd 45 03 12 f0 	movb   $0x89,-0xfedfcbb(,%ebx,8)
f010382f:	89 
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103830:	c1 e3 03             	shl    $0x3,%ebx
f0103833:	0f 00 db             	ltr    %bx
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103836:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f010383b:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0+8*i);

	// Load the IDT
	lidt(&idt_pd);
}
f010383e:	83 c4 0c             	add    $0xc,%esp
f0103841:	5b                   	pop    %ebx
f0103842:	5e                   	pop    %esi
f0103843:	5f                   	pop    %edi
f0103844:	5d                   	pop    %ebp
f0103845:	c3                   	ret    

f0103846 <trap_init>:
void IRQ15();


void
trap_init(void)
{
f0103846:	55                   	push   %ebp
f0103847:	89 e5                	mov    %esp,%ebp
f0103849:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];
	// LAB 3: Your code here.


	SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f010384c:	b8 84 43 10 f0       	mov    $0xf0104384,%eax
f0103851:	66 a3 60 f2 22 f0    	mov    %ax,0xf022f260
f0103857:	66 c7 05 62 f2 22 f0 	movw   $0x8,0xf022f262
f010385e:	08 00 
f0103860:	c6 05 64 f2 22 f0 00 	movb   $0x0,0xf022f264
f0103867:	c6 05 65 f2 22 f0 8e 	movb   $0x8e,0xf022f265
f010386e:	c1 e8 10             	shr    $0x10,%eax
f0103871:	66 a3 66 f2 22 f0    	mov    %ax,0xf022f266
	SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f0103877:	b8 8e 43 10 f0       	mov    $0xf010438e,%eax
f010387c:	66 a3 68 f2 22 f0    	mov    %ax,0xf022f268
f0103882:	66 c7 05 6a f2 22 f0 	movw   $0x8,0xf022f26a
f0103889:	08 00 
f010388b:	c6 05 6c f2 22 f0 00 	movb   $0x0,0xf022f26c
f0103892:	c6 05 6d f2 22 f0 8e 	movb   $0x8e,0xf022f26d
f0103899:	c1 e8 10             	shr    $0x10,%eax
f010389c:	66 a3 6e f2 22 f0    	mov    %ax,0xf022f26e
	SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f01038a2:	b8 98 43 10 f0       	mov    $0xf0104398,%eax
f01038a7:	66 a3 70 f2 22 f0    	mov    %ax,0xf022f270
f01038ad:	66 c7 05 72 f2 22 f0 	movw   $0x8,0xf022f272
f01038b4:	08 00 
f01038b6:	c6 05 74 f2 22 f0 00 	movb   $0x0,0xf022f274
f01038bd:	c6 05 75 f2 22 f0 8e 	movb   $0x8e,0xf022f275
f01038c4:	c1 e8 10             	shr    $0x10,%eax
f01038c7:	66 a3 76 f2 22 f0    	mov    %ax,0xf022f276
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f01038cd:	b8 a2 43 10 f0       	mov    $0xf01043a2,%eax
f01038d2:	66 a3 78 f2 22 f0    	mov    %ax,0xf022f278
f01038d8:	66 c7 05 7a f2 22 f0 	movw   $0x8,0xf022f27a
f01038df:	08 00 
f01038e1:	c6 05 7c f2 22 f0 00 	movb   $0x0,0xf022f27c
f01038e8:	c6 05 7d f2 22 f0 ee 	movb   $0xee,0xf022f27d
f01038ef:	c1 e8 10             	shr    $0x10,%eax
f01038f2:	66 a3 7e f2 22 f0    	mov    %ax,0xf022f27e
	SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f01038f8:	b8 ac 43 10 f0       	mov    $0xf01043ac,%eax
f01038fd:	66 a3 80 f2 22 f0    	mov    %ax,0xf022f280
f0103903:	66 c7 05 82 f2 22 f0 	movw   $0x8,0xf022f282
f010390a:	08 00 
f010390c:	c6 05 84 f2 22 f0 00 	movb   $0x0,0xf022f284
f0103913:	c6 05 85 f2 22 f0 8e 	movb   $0x8e,0xf022f285
f010391a:	c1 e8 10             	shr    $0x10,%eax
f010391d:	66 a3 86 f2 22 f0    	mov    %ax,0xf022f286
	SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f0103923:	b8 b6 43 10 f0       	mov    $0xf01043b6,%eax
f0103928:	66 a3 88 f2 22 f0    	mov    %ax,0xf022f288
f010392e:	66 c7 05 8a f2 22 f0 	movw   $0x8,0xf022f28a
f0103935:	08 00 
f0103937:	c6 05 8c f2 22 f0 00 	movb   $0x0,0xf022f28c
f010393e:	c6 05 8d f2 22 f0 8e 	movb   $0x8e,0xf022f28d
f0103945:	c1 e8 10             	shr    $0x10,%eax
f0103948:	66 a3 8e f2 22 f0    	mov    %ax,0xf022f28e
	SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f010394e:	b8 c0 43 10 f0       	mov    $0xf01043c0,%eax
f0103953:	66 a3 90 f2 22 f0    	mov    %ax,0xf022f290
f0103959:	66 c7 05 92 f2 22 f0 	movw   $0x8,0xf022f292
f0103960:	08 00 
f0103962:	c6 05 94 f2 22 f0 00 	movb   $0x0,0xf022f294
f0103969:	c6 05 95 f2 22 f0 8e 	movb   $0x8e,0xf022f295
f0103970:	c1 e8 10             	shr    $0x10,%eax
f0103973:	66 a3 96 f2 22 f0    	mov    %ax,0xf022f296
	SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f0103979:	b8 ca 43 10 f0       	mov    $0xf01043ca,%eax
f010397e:	66 a3 98 f2 22 f0    	mov    %ax,0xf022f298
f0103984:	66 c7 05 9a f2 22 f0 	movw   $0x8,0xf022f29a
f010398b:	08 00 
f010398d:	c6 05 9c f2 22 f0 00 	movb   $0x0,0xf022f29c
f0103994:	c6 05 9d f2 22 f0 8e 	movb   $0x8e,0xf022f29d
f010399b:	c1 e8 10             	shr    $0x10,%eax
f010399e:	66 a3 9e f2 22 f0    	mov    %ax,0xf022f29e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f01039a4:	b8 d4 43 10 f0       	mov    $0xf01043d4,%eax
f01039a9:	66 a3 a0 f2 22 f0    	mov    %ax,0xf022f2a0
f01039af:	66 c7 05 a2 f2 22 f0 	movw   $0x8,0xf022f2a2
f01039b6:	08 00 
f01039b8:	c6 05 a4 f2 22 f0 00 	movb   $0x0,0xf022f2a4
f01039bf:	c6 05 a5 f2 22 f0 8e 	movb   $0x8e,0xf022f2a5
f01039c6:	c1 e8 10             	shr    $0x10,%eax
f01039c9:	66 a3 a6 f2 22 f0    	mov    %ax,0xf022f2a6
	SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f01039cf:	b8 dc 43 10 f0       	mov    $0xf01043dc,%eax
f01039d4:	66 a3 b0 f2 22 f0    	mov    %ax,0xf022f2b0
f01039da:	66 c7 05 b2 f2 22 f0 	movw   $0x8,0xf022f2b2
f01039e1:	08 00 
f01039e3:	c6 05 b4 f2 22 f0 00 	movb   $0x0,0xf022f2b4
f01039ea:	c6 05 b5 f2 22 f0 8e 	movb   $0x8e,0xf022f2b5
f01039f1:	c1 e8 10             	shr    $0x10,%eax
f01039f4:	66 a3 b6 f2 22 f0    	mov    %ax,0xf022f2b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f01039fa:	b8 e4 43 10 f0       	mov    $0xf01043e4,%eax
f01039ff:	66 a3 b8 f2 22 f0    	mov    %ax,0xf022f2b8
f0103a05:	66 c7 05 ba f2 22 f0 	movw   $0x8,0xf022f2ba
f0103a0c:	08 00 
f0103a0e:	c6 05 bc f2 22 f0 00 	movb   $0x0,0xf022f2bc
f0103a15:	c6 05 bd f2 22 f0 8e 	movb   $0x8e,0xf022f2bd
f0103a1c:	c1 e8 10             	shr    $0x10,%eax
f0103a1f:	66 a3 be f2 22 f0    	mov    %ax,0xf022f2be
	SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f0103a25:	b8 ec 43 10 f0       	mov    $0xf01043ec,%eax
f0103a2a:	66 a3 c0 f2 22 f0    	mov    %ax,0xf022f2c0
f0103a30:	66 c7 05 c2 f2 22 f0 	movw   $0x8,0xf022f2c2
f0103a37:	08 00 
f0103a39:	c6 05 c4 f2 22 f0 00 	movb   $0x0,0xf022f2c4
f0103a40:	c6 05 c5 f2 22 f0 8e 	movb   $0x8e,0xf022f2c5
f0103a47:	c1 e8 10             	shr    $0x10,%eax
f0103a4a:	66 a3 c6 f2 22 f0    	mov    %ax,0xf022f2c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f0103a50:	b8 f4 43 10 f0       	mov    $0xf01043f4,%eax
f0103a55:	66 a3 c8 f2 22 f0    	mov    %ax,0xf022f2c8
f0103a5b:	66 c7 05 ca f2 22 f0 	movw   $0x8,0xf022f2ca
f0103a62:	08 00 
f0103a64:	c6 05 cc f2 22 f0 00 	movb   $0x0,0xf022f2cc
f0103a6b:	c6 05 cd f2 22 f0 8e 	movb   $0x8e,0xf022f2cd
f0103a72:	c1 e8 10             	shr    $0x10,%eax
f0103a75:	66 a3 ce f2 22 f0    	mov    %ax,0xf022f2ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f0103a7b:	b8 fc 43 10 f0       	mov    $0xf01043fc,%eax
f0103a80:	66 a3 d0 f2 22 f0    	mov    %ax,0xf022f2d0
f0103a86:	66 c7 05 d2 f2 22 f0 	movw   $0x8,0xf022f2d2
f0103a8d:	08 00 
f0103a8f:	c6 05 d4 f2 22 f0 00 	movb   $0x0,0xf022f2d4
f0103a96:	c6 05 d5 f2 22 f0 8e 	movb   $0x8e,0xf022f2d5
f0103a9d:	c1 e8 10             	shr    $0x10,%eax
f0103aa0:	66 a3 d6 f2 22 f0    	mov    %ax,0xf022f2d6
	SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f0103aa6:	b8 00 44 10 f0       	mov    $0xf0104400,%eax
f0103aab:	66 a3 e0 f2 22 f0    	mov    %ax,0xf022f2e0
f0103ab1:	66 c7 05 e2 f2 22 f0 	movw   $0x8,0xf022f2e2
f0103ab8:	08 00 
f0103aba:	c6 05 e4 f2 22 f0 00 	movb   $0x0,0xf022f2e4
f0103ac1:	c6 05 e5 f2 22 f0 8e 	movb   $0x8e,0xf022f2e5
f0103ac8:	c1 e8 10             	shr    $0x10,%eax
f0103acb:	66 a3 e6 f2 22 f0    	mov    %ax,0xf022f2e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f0103ad1:	b8 06 44 10 f0       	mov    $0xf0104406,%eax
f0103ad6:	66 a3 e8 f2 22 f0    	mov    %ax,0xf022f2e8
f0103adc:	66 c7 05 ea f2 22 f0 	movw   $0x8,0xf022f2ea
f0103ae3:	08 00 
f0103ae5:	c6 05 ec f2 22 f0 00 	movb   $0x0,0xf022f2ec
f0103aec:	c6 05 ed f2 22 f0 8e 	movb   $0x8e,0xf022f2ed
f0103af3:	c1 e8 10             	shr    $0x10,%eax
f0103af6:	66 a3 ee f2 22 f0    	mov    %ax,0xf022f2ee
	SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0103afc:	b8 0a 44 10 f0       	mov    $0xf010440a,%eax
f0103b01:	66 a3 f0 f2 22 f0    	mov    %ax,0xf022f2f0
f0103b07:	66 c7 05 f2 f2 22 f0 	movw   $0x8,0xf022f2f2
f0103b0e:	08 00 
f0103b10:	c6 05 f4 f2 22 f0 00 	movb   $0x0,0xf022f2f4
f0103b17:	c6 05 f5 f2 22 f0 8e 	movb   $0x8e,0xf022f2f5
f0103b1e:	c1 e8 10             	shr    $0x10,%eax
f0103b21:	66 a3 f6 f2 22 f0    	mov    %ax,0xf022f2f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f0103b27:	b8 10 44 10 f0       	mov    $0xf0104410,%eax
f0103b2c:	66 a3 f8 f2 22 f0    	mov    %ax,0xf022f2f8
f0103b32:	66 c7 05 fa f2 22 f0 	movw   $0x8,0xf022f2fa
f0103b39:	08 00 
f0103b3b:	c6 05 fc f2 22 f0 00 	movb   $0x0,0xf022f2fc
f0103b42:	c6 05 fd f2 22 f0 8e 	movb   $0x8e,0xf022f2fd
f0103b49:	c1 e8 10             	shr    $0x10,%eax
f0103b4c:	66 a3 fe f2 22 f0    	mov    %ax,0xf022f2fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f0103b52:	b8 16 44 10 f0       	mov    $0xf0104416,%eax
f0103b57:	66 a3 e0 f3 22 f0    	mov    %ax,0xf022f3e0
f0103b5d:	66 c7 05 e2 f3 22 f0 	movw   $0x8,0xf022f3e2
f0103b64:	08 00 
f0103b66:	c6 05 e4 f3 22 f0 00 	movb   $0x0,0xf022f3e4
f0103b6d:	c6 05 e5 f3 22 f0 ee 	movb   $0xee,0xf022f3e5
f0103b74:	c1 e8 10             	shr    $0x10,%eax
f0103b77:	66 a3 e6 f3 22 f0    	mov    %ax,0xf022f3e6

	SETGATE(idt[IRQ_OFFSET], 0, GD_KT, IRQ0, 0);
f0103b7d:	b8 1c 44 10 f0       	mov    $0xf010441c,%eax
f0103b82:	66 a3 60 f3 22 f0    	mov    %ax,0xf022f360
f0103b88:	66 c7 05 62 f3 22 f0 	movw   $0x8,0xf022f362
f0103b8f:	08 00 
f0103b91:	c6 05 64 f3 22 f0 00 	movb   $0x0,0xf022f364
f0103b98:	c6 05 65 f3 22 f0 8e 	movb   $0x8e,0xf022f365
f0103b9f:	c1 e8 10             	shr    $0x10,%eax
f0103ba2:	66 a3 66 f3 22 f0    	mov    %ax,0xf022f366
	SETGATE(idt[IRQ_OFFSET+1], 0, GD_KT, IRQ1, 0);
f0103ba8:	b8 22 44 10 f0       	mov    $0xf0104422,%eax
f0103bad:	66 a3 68 f3 22 f0    	mov    %ax,0xf022f368
f0103bb3:	66 c7 05 6a f3 22 f0 	movw   $0x8,0xf022f36a
f0103bba:	08 00 
f0103bbc:	c6 05 6c f3 22 f0 00 	movb   $0x0,0xf022f36c
f0103bc3:	c6 05 6d f3 22 f0 8e 	movb   $0x8e,0xf022f36d
f0103bca:	c1 e8 10             	shr    $0x10,%eax
f0103bcd:	66 a3 6e f3 22 f0    	mov    %ax,0xf022f36e
	SETGATE(idt[IRQ_OFFSET+2], 0, GD_KT, IRQ2, 0);
f0103bd3:	b8 28 44 10 f0       	mov    $0xf0104428,%eax
f0103bd8:	66 a3 70 f3 22 f0    	mov    %ax,0xf022f370
f0103bde:	66 c7 05 72 f3 22 f0 	movw   $0x8,0xf022f372
f0103be5:	08 00 
f0103be7:	c6 05 74 f3 22 f0 00 	movb   $0x0,0xf022f374
f0103bee:	c6 05 75 f3 22 f0 8e 	movb   $0x8e,0xf022f375
f0103bf5:	c1 e8 10             	shr    $0x10,%eax
f0103bf8:	66 a3 76 f3 22 f0    	mov    %ax,0xf022f376
	SETGATE(idt[IRQ_OFFSET+3], 0, GD_KT, IRQ3, 0);
f0103bfe:	b8 2e 44 10 f0       	mov    $0xf010442e,%eax
f0103c03:	66 a3 78 f3 22 f0    	mov    %ax,0xf022f378
f0103c09:	66 c7 05 7a f3 22 f0 	movw   $0x8,0xf022f37a
f0103c10:	08 00 
f0103c12:	c6 05 7c f3 22 f0 00 	movb   $0x0,0xf022f37c
f0103c19:	c6 05 7d f3 22 f0 8e 	movb   $0x8e,0xf022f37d
f0103c20:	c1 e8 10             	shr    $0x10,%eax
f0103c23:	66 a3 7e f3 22 f0    	mov    %ax,0xf022f37e
	SETGATE(idt[IRQ_OFFSET+4], 0, GD_KT, IRQ4, 0);
f0103c29:	b8 34 44 10 f0       	mov    $0xf0104434,%eax
f0103c2e:	66 a3 80 f3 22 f0    	mov    %ax,0xf022f380
f0103c34:	66 c7 05 82 f3 22 f0 	movw   $0x8,0xf022f382
f0103c3b:	08 00 
f0103c3d:	c6 05 84 f3 22 f0 00 	movb   $0x0,0xf022f384
f0103c44:	c6 05 85 f3 22 f0 8e 	movb   $0x8e,0xf022f385
f0103c4b:	c1 e8 10             	shr    $0x10,%eax
f0103c4e:	66 a3 86 f3 22 f0    	mov    %ax,0xf022f386
	SETGATE(idt[IRQ_OFFSET+5], 0, GD_KT, IRQ5, 0);
f0103c54:	b8 3a 44 10 f0       	mov    $0xf010443a,%eax
f0103c59:	66 a3 88 f3 22 f0    	mov    %ax,0xf022f388
f0103c5f:	66 c7 05 8a f3 22 f0 	movw   $0x8,0xf022f38a
f0103c66:	08 00 
f0103c68:	c6 05 8c f3 22 f0 00 	movb   $0x0,0xf022f38c
f0103c6f:	c6 05 8d f3 22 f0 8e 	movb   $0x8e,0xf022f38d
f0103c76:	c1 e8 10             	shr    $0x10,%eax
f0103c79:	66 a3 8e f3 22 f0    	mov    %ax,0xf022f38e
	SETGATE(idt[IRQ_OFFSET+6], 0, GD_KT, IRQ6, 0);
f0103c7f:	b8 40 44 10 f0       	mov    $0xf0104440,%eax
f0103c84:	66 a3 90 f3 22 f0    	mov    %ax,0xf022f390
f0103c8a:	66 c7 05 92 f3 22 f0 	movw   $0x8,0xf022f392
f0103c91:	08 00 
f0103c93:	c6 05 94 f3 22 f0 00 	movb   $0x0,0xf022f394
f0103c9a:	c6 05 95 f3 22 f0 8e 	movb   $0x8e,0xf022f395
f0103ca1:	c1 e8 10             	shr    $0x10,%eax
f0103ca4:	66 a3 96 f3 22 f0    	mov    %ax,0xf022f396
	SETGATE(idt[IRQ_OFFSET+7], 0, GD_KT, IRQ7, 0);
f0103caa:	b8 46 44 10 f0       	mov    $0xf0104446,%eax
f0103caf:	66 a3 98 f3 22 f0    	mov    %ax,0xf022f398
f0103cb5:	66 c7 05 9a f3 22 f0 	movw   $0x8,0xf022f39a
f0103cbc:	08 00 
f0103cbe:	c6 05 9c f3 22 f0 00 	movb   $0x0,0xf022f39c
f0103cc5:	c6 05 9d f3 22 f0 8e 	movb   $0x8e,0xf022f39d
f0103ccc:	c1 e8 10             	shr    $0x10,%eax
f0103ccf:	66 a3 9e f3 22 f0    	mov    %ax,0xf022f39e
	SETGATE(idt[IRQ_OFFSET+8], 0, GD_KT, IRQ8, 0);
f0103cd5:	b8 4c 44 10 f0       	mov    $0xf010444c,%eax
f0103cda:	66 a3 a0 f3 22 f0    	mov    %ax,0xf022f3a0
f0103ce0:	66 c7 05 a2 f3 22 f0 	movw   $0x8,0xf022f3a2
f0103ce7:	08 00 
f0103ce9:	c6 05 a4 f3 22 f0 00 	movb   $0x0,0xf022f3a4
f0103cf0:	c6 05 a5 f3 22 f0 8e 	movb   $0x8e,0xf022f3a5
f0103cf7:	c1 e8 10             	shr    $0x10,%eax
f0103cfa:	66 a3 a6 f3 22 f0    	mov    %ax,0xf022f3a6
	SETGATE(idt[IRQ_OFFSET+9], 0, GD_KT, IRQ9, 0);
f0103d00:	b8 52 44 10 f0       	mov    $0xf0104452,%eax
f0103d05:	66 a3 a8 f3 22 f0    	mov    %ax,0xf022f3a8
f0103d0b:	66 c7 05 aa f3 22 f0 	movw   $0x8,0xf022f3aa
f0103d12:	08 00 
f0103d14:	c6 05 ac f3 22 f0 00 	movb   $0x0,0xf022f3ac
f0103d1b:	c6 05 ad f3 22 f0 8e 	movb   $0x8e,0xf022f3ad
f0103d22:	c1 e8 10             	shr    $0x10,%eax
f0103d25:	66 a3 ae f3 22 f0    	mov    %ax,0xf022f3ae
	SETGATE(idt[IRQ_OFFSET+10], 0, GD_KT, IRQ10, 0);
f0103d2b:	b8 58 44 10 f0       	mov    $0xf0104458,%eax
f0103d30:	66 a3 b0 f3 22 f0    	mov    %ax,0xf022f3b0
f0103d36:	66 c7 05 b2 f3 22 f0 	movw   $0x8,0xf022f3b2
f0103d3d:	08 00 
f0103d3f:	c6 05 b4 f3 22 f0 00 	movb   $0x0,0xf022f3b4
f0103d46:	c6 05 b5 f3 22 f0 8e 	movb   $0x8e,0xf022f3b5
f0103d4d:	c1 e8 10             	shr    $0x10,%eax
f0103d50:	66 a3 b6 f3 22 f0    	mov    %ax,0xf022f3b6
	SETGATE(idt[IRQ_OFFSET+11], 0, GD_KT, IRQ11, 0);
f0103d56:	b8 5e 44 10 f0       	mov    $0xf010445e,%eax
f0103d5b:	66 a3 b8 f3 22 f0    	mov    %ax,0xf022f3b8
f0103d61:	66 c7 05 ba f3 22 f0 	movw   $0x8,0xf022f3ba
f0103d68:	08 00 
f0103d6a:	c6 05 bc f3 22 f0 00 	movb   $0x0,0xf022f3bc
f0103d71:	c6 05 bd f3 22 f0 8e 	movb   $0x8e,0xf022f3bd
f0103d78:	c1 e8 10             	shr    $0x10,%eax
f0103d7b:	66 a3 be f3 22 f0    	mov    %ax,0xf022f3be
	SETGATE(idt[IRQ_OFFSET+12], 0, GD_KT, IRQ12, 0);
f0103d81:	b8 64 44 10 f0       	mov    $0xf0104464,%eax
f0103d86:	66 a3 c0 f3 22 f0    	mov    %ax,0xf022f3c0
f0103d8c:	66 c7 05 c2 f3 22 f0 	movw   $0x8,0xf022f3c2
f0103d93:	08 00 
f0103d95:	c6 05 c4 f3 22 f0 00 	movb   $0x0,0xf022f3c4
f0103d9c:	c6 05 c5 f3 22 f0 8e 	movb   $0x8e,0xf022f3c5
f0103da3:	c1 e8 10             	shr    $0x10,%eax
f0103da6:	66 a3 c6 f3 22 f0    	mov    %ax,0xf022f3c6
	SETGATE(idt[IRQ_OFFSET+13], 0, GD_KT, IRQ13, 0);
f0103dac:	b8 6a 44 10 f0       	mov    $0xf010446a,%eax
f0103db1:	66 a3 c8 f3 22 f0    	mov    %ax,0xf022f3c8
f0103db7:	66 c7 05 ca f3 22 f0 	movw   $0x8,0xf022f3ca
f0103dbe:	08 00 
f0103dc0:	c6 05 cc f3 22 f0 00 	movb   $0x0,0xf022f3cc
f0103dc7:	c6 05 cd f3 22 f0 8e 	movb   $0x8e,0xf022f3cd
f0103dce:	c1 e8 10             	shr    $0x10,%eax
f0103dd1:	66 a3 ce f3 22 f0    	mov    %ax,0xf022f3ce
	SETGATE(idt[IRQ_OFFSET+14], 0, GD_KT, IRQ14, 0);
f0103dd7:	b8 70 44 10 f0       	mov    $0xf0104470,%eax
f0103ddc:	66 a3 d0 f3 22 f0    	mov    %ax,0xf022f3d0
f0103de2:	66 c7 05 d2 f3 22 f0 	movw   $0x8,0xf022f3d2
f0103de9:	08 00 
f0103deb:	c6 05 d4 f3 22 f0 00 	movb   $0x0,0xf022f3d4
f0103df2:	c6 05 d5 f3 22 f0 8e 	movb   $0x8e,0xf022f3d5
f0103df9:	c1 e8 10             	shr    $0x10,%eax
f0103dfc:	66 a3 d6 f3 22 f0    	mov    %ax,0xf022f3d6
	SETGATE(idt[IRQ_OFFSET+15], 0, GD_KT, IRQ15, 0);
f0103e02:	b8 76 44 10 f0       	mov    $0xf0104476,%eax
f0103e07:	66 a3 d8 f3 22 f0    	mov    %ax,0xf022f3d8
f0103e0d:	66 c7 05 da f3 22 f0 	movw   $0x8,0xf022f3da
f0103e14:	08 00 
f0103e16:	c6 05 dc f3 22 f0 00 	movb   $0x0,0xf022f3dc
f0103e1d:	c6 05 dd f3 22 f0 8e 	movb   $0x8e,0xf022f3dd
f0103e24:	c1 e8 10             	shr    $0x10,%eax
f0103e27:	66 a3 de f3 22 f0    	mov    %ax,0xf022f3de
	// Per-CPU setup 
	trap_init_percpu();
f0103e2d:	e8 44 f9 ff ff       	call   f0103776 <trap_init_percpu>
}
f0103e32:	c9                   	leave  
f0103e33:	c3                   	ret    

f0103e34 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103e34:	55                   	push   %ebp
f0103e35:	89 e5                	mov    %esp,%ebp
f0103e37:	53                   	push   %ebx
f0103e38:	83 ec 0c             	sub    $0xc,%esp
f0103e3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103e3e:	ff 33                	pushl  (%ebx)
f0103e40:	68 f3 77 10 f0       	push   $0xf01077f3
f0103e45:	e8 18 f9 ff ff       	call   f0103762 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103e4a:	83 c4 08             	add    $0x8,%esp
f0103e4d:	ff 73 04             	pushl  0x4(%ebx)
f0103e50:	68 02 78 10 f0       	push   $0xf0107802
f0103e55:	e8 08 f9 ff ff       	call   f0103762 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103e5a:	83 c4 08             	add    $0x8,%esp
f0103e5d:	ff 73 08             	pushl  0x8(%ebx)
f0103e60:	68 11 78 10 f0       	push   $0xf0107811
f0103e65:	e8 f8 f8 ff ff       	call   f0103762 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103e6a:	83 c4 08             	add    $0x8,%esp
f0103e6d:	ff 73 0c             	pushl  0xc(%ebx)
f0103e70:	68 20 78 10 f0       	push   $0xf0107820
f0103e75:	e8 e8 f8 ff ff       	call   f0103762 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103e7a:	83 c4 08             	add    $0x8,%esp
f0103e7d:	ff 73 10             	pushl  0x10(%ebx)
f0103e80:	68 2f 78 10 f0       	push   $0xf010782f
f0103e85:	e8 d8 f8 ff ff       	call   f0103762 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103e8a:	83 c4 08             	add    $0x8,%esp
f0103e8d:	ff 73 14             	pushl  0x14(%ebx)
f0103e90:	68 3e 78 10 f0       	push   $0xf010783e
f0103e95:	e8 c8 f8 ff ff       	call   f0103762 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103e9a:	83 c4 08             	add    $0x8,%esp
f0103e9d:	ff 73 18             	pushl  0x18(%ebx)
f0103ea0:	68 4d 78 10 f0       	push   $0xf010784d
f0103ea5:	e8 b8 f8 ff ff       	call   f0103762 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103eaa:	83 c4 08             	add    $0x8,%esp
f0103ead:	ff 73 1c             	pushl  0x1c(%ebx)
f0103eb0:	68 5c 78 10 f0       	push   $0xf010785c
f0103eb5:	e8 a8 f8 ff ff       	call   f0103762 <cprintf>
}
f0103eba:	83 c4 10             	add    $0x10,%esp
f0103ebd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103ec0:	c9                   	leave  
f0103ec1:	c3                   	ret    

f0103ec2 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103ec2:	55                   	push   %ebp
f0103ec3:	89 e5                	mov    %esp,%ebp
f0103ec5:	56                   	push   %esi
f0103ec6:	53                   	push   %ebx
f0103ec7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103eca:	e8 b7 1e 00 00       	call   f0105d86 <cpunum>
f0103ecf:	83 ec 04             	sub    $0x4,%esp
f0103ed2:	50                   	push   %eax
f0103ed3:	53                   	push   %ebx
f0103ed4:	68 c0 78 10 f0       	push   $0xf01078c0
f0103ed9:	e8 84 f8 ff ff       	call   f0103762 <cprintf>
	print_regs(&tf->tf_regs);
f0103ede:	89 1c 24             	mov    %ebx,(%esp)
f0103ee1:	e8 4e ff ff ff       	call   f0103e34 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103ee6:	83 c4 08             	add    $0x8,%esp
f0103ee9:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103eed:	50                   	push   %eax
f0103eee:	68 de 78 10 f0       	push   $0xf01078de
f0103ef3:	e8 6a f8 ff ff       	call   f0103762 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103ef8:	83 c4 08             	add    $0x8,%esp
f0103efb:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103eff:	50                   	push   %eax
f0103f00:	68 f1 78 10 f0       	push   $0xf01078f1
f0103f05:	e8 58 f8 ff ff       	call   f0103762 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f0a:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103f0d:	83 c4 10             	add    $0x10,%esp
f0103f10:	83 f8 13             	cmp    $0x13,%eax
f0103f13:	77 09                	ja     f0103f1e <print_trapframe+0x5c>
		return excnames[trapno];
f0103f15:	8b 14 85 60 7b 10 f0 	mov    -0xfef84a0(,%eax,4),%edx
f0103f1c:	eb 1f                	jmp    f0103f3d <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103f1e:	83 f8 30             	cmp    $0x30,%eax
f0103f21:	74 15                	je     f0103f38 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103f23:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103f26:	83 fa 10             	cmp    $0x10,%edx
f0103f29:	b9 8a 78 10 f0       	mov    $0xf010788a,%ecx
f0103f2e:	ba 77 78 10 f0       	mov    $0xf0107877,%edx
f0103f33:	0f 43 d1             	cmovae %ecx,%edx
f0103f36:	eb 05                	jmp    f0103f3d <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103f38:	ba 6b 78 10 f0       	mov    $0xf010786b,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f3d:	83 ec 04             	sub    $0x4,%esp
f0103f40:	52                   	push   %edx
f0103f41:	50                   	push   %eax
f0103f42:	68 04 79 10 f0       	push   $0xf0107904
f0103f47:	e8 16 f8 ff ff       	call   f0103762 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103f4c:	83 c4 10             	add    $0x10,%esp
f0103f4f:	3b 1d 60 fa 22 f0    	cmp    0xf022fa60,%ebx
f0103f55:	75 1a                	jne    f0103f71 <print_trapframe+0xaf>
f0103f57:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f5b:	75 14                	jne    f0103f71 <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103f5d:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103f60:	83 ec 08             	sub    $0x8,%esp
f0103f63:	50                   	push   %eax
f0103f64:	68 16 79 10 f0       	push   $0xf0107916
f0103f69:	e8 f4 f7 ff ff       	call   f0103762 <cprintf>
f0103f6e:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103f71:	83 ec 08             	sub    $0x8,%esp
f0103f74:	ff 73 2c             	pushl  0x2c(%ebx)
f0103f77:	68 25 79 10 f0       	push   $0xf0107925
f0103f7c:	e8 e1 f7 ff ff       	call   f0103762 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103f81:	83 c4 10             	add    $0x10,%esp
f0103f84:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f88:	75 49                	jne    f0103fd3 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103f8a:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103f8d:	89 c2                	mov    %eax,%edx
f0103f8f:	83 e2 01             	and    $0x1,%edx
f0103f92:	ba a4 78 10 f0       	mov    $0xf01078a4,%edx
f0103f97:	b9 99 78 10 f0       	mov    $0xf0107899,%ecx
f0103f9c:	0f 44 ca             	cmove  %edx,%ecx
f0103f9f:	89 c2                	mov    %eax,%edx
f0103fa1:	83 e2 02             	and    $0x2,%edx
f0103fa4:	ba b6 78 10 f0       	mov    $0xf01078b6,%edx
f0103fa9:	be b0 78 10 f0       	mov    $0xf01078b0,%esi
f0103fae:	0f 45 d6             	cmovne %esi,%edx
f0103fb1:	83 e0 04             	and    $0x4,%eax
f0103fb4:	be f0 79 10 f0       	mov    $0xf01079f0,%esi
f0103fb9:	b8 bb 78 10 f0       	mov    $0xf01078bb,%eax
f0103fbe:	0f 44 c6             	cmove  %esi,%eax
f0103fc1:	51                   	push   %ecx
f0103fc2:	52                   	push   %edx
f0103fc3:	50                   	push   %eax
f0103fc4:	68 33 79 10 f0       	push   $0xf0107933
f0103fc9:	e8 94 f7 ff ff       	call   f0103762 <cprintf>
f0103fce:	83 c4 10             	add    $0x10,%esp
f0103fd1:	eb 10                	jmp    f0103fe3 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103fd3:	83 ec 0c             	sub    $0xc,%esp
f0103fd6:	68 52 6c 10 f0       	push   $0xf0106c52
f0103fdb:	e8 82 f7 ff ff       	call   f0103762 <cprintf>
f0103fe0:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103fe3:	83 ec 08             	sub    $0x8,%esp
f0103fe6:	ff 73 30             	pushl  0x30(%ebx)
f0103fe9:	68 42 79 10 f0       	push   $0xf0107942
f0103fee:	e8 6f f7 ff ff       	call   f0103762 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103ff3:	83 c4 08             	add    $0x8,%esp
f0103ff6:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103ffa:	50                   	push   %eax
f0103ffb:	68 51 79 10 f0       	push   $0xf0107951
f0104000:	e8 5d f7 ff ff       	call   f0103762 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104005:	83 c4 08             	add    $0x8,%esp
f0104008:	ff 73 38             	pushl  0x38(%ebx)
f010400b:	68 64 79 10 f0       	push   $0xf0107964
f0104010:	e8 4d f7 ff ff       	call   f0103762 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104015:	83 c4 10             	add    $0x10,%esp
f0104018:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010401c:	74 25                	je     f0104043 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010401e:	83 ec 08             	sub    $0x8,%esp
f0104021:	ff 73 3c             	pushl  0x3c(%ebx)
f0104024:	68 73 79 10 f0       	push   $0xf0107973
f0104029:	e8 34 f7 ff ff       	call   f0103762 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010402e:	83 c4 08             	add    $0x8,%esp
f0104031:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104035:	50                   	push   %eax
f0104036:	68 82 79 10 f0       	push   $0xf0107982
f010403b:	e8 22 f7 ff ff       	call   f0103762 <cprintf>
f0104040:	83 c4 10             	add    $0x10,%esp
	}
}
f0104043:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104046:	5b                   	pop    %ebx
f0104047:	5e                   	pop    %esi
f0104048:	5d                   	pop    %ebp
f0104049:	c3                   	ret    

f010404a <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010404a:	55                   	push   %ebp
f010404b:	89 e5                	mov    %esp,%ebp
f010404d:	57                   	push   %edi
f010404e:	56                   	push   %esi
f010404f:	53                   	push   %ebx
f0104050:	83 ec 0c             	sub    $0xc,%esp
f0104053:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104056:	0f 20 d6             	mov    %cr2,%esi
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	   struct UTrapframe *utf;
	
	if (curenv->env_pgfault_upcall) {
f0104059:	e8 28 1d 00 00       	call   f0105d86 <cpunum>
f010405e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104061:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104067:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010406b:	0f 84 a7 00 00 00    	je     f0104118 <page_fault_handler+0xce>
		
		if (tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP) {
f0104071:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104074:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			// 异常模式下陷入
			utf = (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
f010407a:	83 e8 38             	sub    $0x38,%eax
f010407d:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104083:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f0104088:	0f 46 d0             	cmovbe %eax,%edx
f010408b:	89 d7                	mov    %edx,%edi
		else {
			// 非异常模式下陷入
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));	
		}
		// 检查异常栈是否溢出
		user_mem_assert(curenv, (const void *) utf, sizeof(struct UTrapframe), PTE_P|PTE_W);
f010408d:	e8 f4 1c 00 00       	call   f0105d86 <cpunum>
f0104092:	6a 03                	push   $0x3
f0104094:	6a 34                	push   $0x34
f0104096:	57                   	push   %edi
f0104097:	6b c0 74             	imul   $0x74,%eax,%eax
f010409a:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f01040a0:	e8 49 ed ff ff       	call   f0102dee <user_mem_assert>
			
		utf->utf_fault_va = fault_va;
f01040a5:	89 fa                	mov    %edi,%edx
f01040a7:	89 37                	mov    %esi,(%edi)
		utf->utf_err      = tf->tf_trapno;
f01040a9:	8b 43 28             	mov    0x28(%ebx),%eax
f01040ac:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs     = tf->tf_regs;
f01040af:	8d 7f 08             	lea    0x8(%edi),%edi
f01040b2:	b9 08 00 00 00       	mov    $0x8,%ecx
f01040b7:	89 de                	mov    %ebx,%esi
f01040b9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eflags   = tf->tf_eflags;
f01040bb:	8b 43 38             	mov    0x38(%ebx),%eax
f01040be:	89 42 2c             	mov    %eax,0x2c(%edx)
		// 保存陷入时现场，用于返回
		utf->utf_eip      = tf->tf_eip;
f01040c1:	8b 43 30             	mov    0x30(%ebx),%eax
f01040c4:	89 d7                	mov    %edx,%edi
f01040c6:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_esp      = tf->tf_esp;
f01040c9:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01040cc:	89 42 30             	mov    %eax,0x30(%edx)
		// 再次转向执行
		curenv->env_tf.tf_eip        = (uint32_t) curenv->env_pgfault_upcall;
f01040cf:	e8 b2 1c 00 00       	call   f0105d86 <cpunum>
f01040d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01040d7:	8b 98 28 00 23 f0    	mov    -0xfdcffd8(%eax),%ebx
f01040dd:	e8 a4 1c 00 00       	call   f0105d86 <cpunum>
f01040e2:	6b c0 74             	imul   $0x74,%eax,%eax
f01040e5:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01040eb:	8b 40 64             	mov    0x64(%eax),%eax
f01040ee:	89 43 30             	mov    %eax,0x30(%ebx)
		// 异常栈
		curenv->env_tf.tf_esp        = (uint32_t) utf;
f01040f1:	e8 90 1c 00 00       	call   f0105d86 <cpunum>
f01040f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01040f9:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01040ff:	89 78 3c             	mov    %edi,0x3c(%eax)
		env_run(curenv);
f0104102:	e8 7f 1c 00 00       	call   f0105d86 <cpunum>
f0104107:	83 c4 04             	add    $0x4,%esp
f010410a:	6b c0 74             	imul   $0x74,%eax,%eax
f010410d:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104113:	e8 14 f4 ff ff       	call   f010352c <env_run>
	}
	else {
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104118:	8b 7b 30             	mov    0x30(%ebx),%edi
			curenv->env_id, fault_va, tf->tf_eip);
f010411b:	e8 66 1c 00 00       	call   f0105d86 <cpunum>
		curenv->env_tf.tf_esp        = (uint32_t) utf;
		env_run(curenv);
	}
	else {
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104120:	57                   	push   %edi
f0104121:	56                   	push   %esi
			curenv->env_id, fault_va, tf->tf_eip);
f0104122:	6b c0 74             	imul   $0x74,%eax,%eax
		curenv->env_tf.tf_esp        = (uint32_t) utf;
		env_run(curenv);
	}
	else {
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104125:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010412b:	ff 70 48             	pushl  0x48(%eax)
f010412e:	68 3c 7b 10 f0       	push   $0xf0107b3c
f0104133:	e8 2a f6 ff ff       	call   f0103762 <cprintf>
			curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
f0104138:	89 1c 24             	mov    %ebx,(%esp)
f010413b:	e8 82 fd ff ff       	call   f0103ec2 <print_trapframe>
		env_destroy(curenv);
f0104140:	e8 41 1c 00 00       	call   f0105d86 <cpunum>
f0104145:	83 c4 04             	add    $0x4,%esp
f0104148:	6b c0 74             	imul   $0x74,%eax,%eax
f010414b:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104151:	e8 37 f3 ff ff       	call   f010348d <env_destroy>
	}

}
f0104156:	83 c4 10             	add    $0x10,%esp
f0104159:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010415c:	5b                   	pop    %ebx
f010415d:	5e                   	pop    %esi
f010415e:	5f                   	pop    %edi
f010415f:	5d                   	pop    %ebp
f0104160:	c3                   	ret    

f0104161 <trap>:
    }
}

void
trap(struct Trapframe *tf)
{
f0104161:	55                   	push   %ebp
f0104162:	89 e5                	mov    %esp,%ebp
f0104164:	57                   	push   %edi
f0104165:	56                   	push   %esi
f0104166:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104169:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f010416a:	83 3d 80 fe 22 f0 00 	cmpl   $0x0,0xf022fe80
f0104171:	74 01                	je     f0104174 <trap+0x13>
		asm volatile("hlt");
f0104173:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104174:	e8 0d 1c 00 00       	call   f0105d86 <cpunum>
f0104179:	6b d0 74             	imul   $0x74,%eax,%edx
f010417c:	81 c2 20 00 23 f0    	add    $0xf0230020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104182:	b8 01 00 00 00       	mov    $0x1,%eax
f0104187:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010418b:	83 f8 02             	cmp    $0x2,%eax
f010418e:	75 10                	jne    f01041a0 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104190:	83 ec 0c             	sub    $0xc,%esp
f0104193:	68 c0 03 12 f0       	push   $0xf01203c0
f0104198:	e8 57 1e 00 00       	call   f0105ff4 <spin_lock>
f010419d:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01041a0:	9c                   	pushf  
f01041a1:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01041a2:	f6 c4 02             	test   $0x2,%ah
f01041a5:	74 19                	je     f01041c0 <trap+0x5f>
f01041a7:	68 95 79 10 f0       	push   $0xf0107995
f01041ac:	68 72 69 10 f0       	push   $0xf0106972
f01041b1:	68 48 01 00 00       	push   $0x148
f01041b6:	68 ae 79 10 f0       	push   $0xf01079ae
f01041bb:	e8 80 be ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f01041c0:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01041c4:	83 e0 03             	and    $0x3,%eax
f01041c7:	66 83 f8 03          	cmp    $0x3,%ax
f01041cb:	0f 85 a0 00 00 00    	jne    f0104271 <trap+0x110>
f01041d1:	83 ec 0c             	sub    $0xc,%esp
f01041d4:	68 c0 03 12 f0       	push   $0xf01203c0
f01041d9:	e8 16 1e 00 00       	call   f0105ff4 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f01041de:	e8 a3 1b 00 00       	call   f0105d86 <cpunum>
f01041e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01041e6:	83 c4 10             	add    $0x10,%esp
f01041e9:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f01041f0:	75 19                	jne    f010420b <trap+0xaa>
f01041f2:	68 ba 79 10 f0       	push   $0xf01079ba
f01041f7:	68 72 69 10 f0       	push   $0xf0106972
f01041fc:	68 50 01 00 00       	push   $0x150
f0104201:	68 ae 79 10 f0       	push   $0xf01079ae
f0104206:	e8 35 be ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f010420b:	e8 76 1b 00 00       	call   f0105d86 <cpunum>
f0104210:	6b c0 74             	imul   $0x74,%eax,%eax
f0104213:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104219:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010421d:	75 2d                	jne    f010424c <trap+0xeb>
			env_free(curenv);
f010421f:	e8 62 1b 00 00       	call   f0105d86 <cpunum>
f0104224:	83 ec 0c             	sub    $0xc,%esp
f0104227:	6b c0 74             	imul   $0x74,%eax,%eax
f010422a:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104230:	e8 7d f0 ff ff       	call   f01032b2 <env_free>
			curenv = NULL;
f0104235:	e8 4c 1b 00 00       	call   f0105d86 <cpunum>
f010423a:	6b c0 74             	imul   $0x74,%eax,%eax
f010423d:	c7 80 28 00 23 f0 00 	movl   $0x0,-0xfdcffd8(%eax)
f0104244:	00 00 00 
			sched_yield();
f0104247:	e8 16 03 00 00       	call   f0104562 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010424c:	e8 35 1b 00 00       	call   f0105d86 <cpunum>
f0104251:	6b c0 74             	imul   $0x74,%eax,%eax
f0104254:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010425a:	b9 11 00 00 00       	mov    $0x11,%ecx
f010425f:	89 c7                	mov    %eax,%edi
f0104261:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104263:	e8 1e 1b 00 00       	call   f0105d86 <cpunum>
f0104268:	6b c0 74             	imul   $0x74,%eax,%eax
f010426b:	8b b0 28 00 23 f0    	mov    -0xfdcffd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104271:	89 35 60 fa 22 f0    	mov    %esi,0xf022fa60
	// LAB 3: Your code here.

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104277:	8b 46 28             	mov    0x28(%esi),%eax
f010427a:	83 f8 27             	cmp    $0x27,%eax
f010427d:	75 1d                	jne    f010429c <trap+0x13b>
		cprintf("Spurious interrupt on irq 7\n");
f010427f:	83 ec 0c             	sub    $0xc,%esp
f0104282:	68 c1 79 10 f0       	push   $0xf01079c1
f0104287:	e8 d6 f4 ff ff       	call   f0103762 <cprintf>
		print_trapframe(tf);
f010428c:	89 34 24             	mov    %esi,(%esp)
f010428f:	e8 2e fc ff ff       	call   f0103ec2 <print_trapframe>
f0104294:	83 c4 10             	add    $0x10,%esp
f0104297:	e9 a7 00 00 00       	jmp    f0104343 <trap+0x1e2>
	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	switch(tf->tf_trapno) {
f010429c:	83 f8 0e             	cmp    $0xe,%eax
f010429f:	74 18                	je     f01042b9 <trap+0x158>
f01042a1:	83 f8 0e             	cmp    $0xe,%eax
f01042a4:	77 07                	ja     f01042ad <trap+0x14c>
f01042a6:	83 f8 03             	cmp    $0x3,%eax
f01042a9:	74 1c                	je     f01042c7 <trap+0x166>
f01042ab:	eb 53                	jmp    f0104300 <trap+0x19f>
f01042ad:	83 f8 20             	cmp    $0x20,%eax
f01042b0:	74 44                	je     f01042f6 <trap+0x195>
f01042b2:	83 f8 30             	cmp    $0x30,%eax
f01042b5:	74 1e                	je     f01042d5 <trap+0x174>
f01042b7:	eb 47                	jmp    f0104300 <trap+0x19f>
        case (T_PGFLT):
            page_fault_handler(tf);
f01042b9:	83 ec 0c             	sub    $0xc,%esp
f01042bc:	56                   	push   %esi
f01042bd:	e8 88 fd ff ff       	call   f010404a <page_fault_handler>
f01042c2:	83 c4 10             	add    $0x10,%esp
f01042c5:	eb 7c                	jmp    f0104343 <trap+0x1e2>
            break; 
        case (T_BRKPT):
            monitor(tf);        
f01042c7:	83 ec 0c             	sub    $0xc,%esp
f01042ca:	56                   	push   %esi
f01042cb:	e8 9a c5 ff ff       	call   f010086a <monitor>
f01042d0:	83 c4 10             	add    $0x10,%esp
f01042d3:	eb 6e                	jmp    f0104343 <trap+0x1e2>
            break;
        case (T_SYSCALL):{
			int32_t ret_code = syscall(
f01042d5:	83 ec 08             	sub    $0x8,%esp
f01042d8:	ff 76 04             	pushl  0x4(%esi)
f01042db:	ff 36                	pushl  (%esi)
f01042dd:	ff 76 10             	pushl  0x10(%esi)
f01042e0:	ff 76 18             	pushl  0x18(%esi)
f01042e3:	ff 76 14             	pushl  0x14(%esi)
f01042e6:	ff 76 1c             	pushl  0x1c(%esi)
f01042e9:	e8 54 03 00 00       	call   f0104642 <syscall>
                    tf->tf_regs.reg_edx,
                    tf->tf_regs.reg_ecx,
                    tf->tf_regs.reg_ebx,
                    tf->tf_regs.reg_edi,
                    tf->tf_regs.reg_esi);
            tf->tf_regs.reg_eax = ret_code;
f01042ee:	89 46 1c             	mov    %eax,0x1c(%esi)
f01042f1:	83 c4 20             	add    $0x20,%esp
f01042f4:	eb 4d                	jmp    f0104343 <trap+0x1e2>
            break;
		}
		case IRQ_OFFSET + IRQ_TIMER:{
			lapic_eoi();
f01042f6:	e8 d6 1b 00 00       	call   f0105ed1 <lapic_eoi>
			sched_yield();
f01042fb:	e8 62 02 00 00       	call   f0104562 <sched_yield>
			break;
		}
         default:
            // Unexpected trap: The user process or the kernel has a bug.
            print_trapframe(tf);
f0104300:	83 ec 0c             	sub    $0xc,%esp
f0104303:	56                   	push   %esi
f0104304:	e8 b9 fb ff ff       	call   f0103ec2 <print_trapframe>
            if (tf->tf_cs == GD_KT)
f0104309:	83 c4 10             	add    $0x10,%esp
f010430c:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104311:	75 17                	jne    f010432a <trap+0x1c9>
                panic("unhandled trap in kernel");
f0104313:	83 ec 04             	sub    $0x4,%esp
f0104316:	68 de 79 10 f0       	push   $0xf01079de
f010431b:	68 2d 01 00 00       	push   $0x12d
f0104320:	68 ae 79 10 f0       	push   $0xf01079ae
f0104325:	e8 16 bd ff ff       	call   f0100040 <_panic>
            else {
                env_destroy(curenv);
f010432a:	e8 57 1a 00 00       	call   f0105d86 <cpunum>
f010432f:	83 ec 0c             	sub    $0xc,%esp
f0104332:	6b c0 74             	imul   $0x74,%eax,%eax
f0104335:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f010433b:	e8 4d f1 ff ff       	call   f010348d <env_destroy>
f0104340:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104343:	e8 3e 1a 00 00       	call   f0105d86 <cpunum>
f0104348:	6b c0 74             	imul   $0x74,%eax,%eax
f010434b:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0104352:	74 2a                	je     f010437e <trap+0x21d>
f0104354:	e8 2d 1a 00 00       	call   f0105d86 <cpunum>
f0104359:	6b c0 74             	imul   $0x74,%eax,%eax
f010435c:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104362:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104366:	75 16                	jne    f010437e <trap+0x21d>
		env_run(curenv);
f0104368:	e8 19 1a 00 00       	call   f0105d86 <cpunum>
f010436d:	83 ec 0c             	sub    $0xc,%esp
f0104370:	6b c0 74             	imul   $0x74,%eax,%eax
f0104373:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104379:	e8 ae f1 ff ff       	call   f010352c <env_run>
	else
		sched_yield();
f010437e:	e8 df 01 00 00       	call   f0104562 <sched_yield>
f0104383:	90                   	nop

f0104384 <t_divide>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
 /* 我现在也不知道为啥这个是这个  那个是那个*/
TRAPHANDLER_NOEC(t_divide, T_DIVIDE)
f0104384:	6a 00                	push   $0x0
f0104386:	6a 00                	push   $0x0
f0104388:	e9 ef 00 00 00       	jmp    f010447c <_alltraps>
f010438d:	90                   	nop

f010438e <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG)
f010438e:	6a 00                	push   $0x0
f0104390:	6a 01                	push   $0x1
f0104392:	e9 e5 00 00 00       	jmp    f010447c <_alltraps>
f0104397:	90                   	nop

f0104398 <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI)
f0104398:	6a 00                	push   $0x0
f010439a:	6a 02                	push   $0x2
f010439c:	e9 db 00 00 00       	jmp    f010447c <_alltraps>
f01043a1:	90                   	nop

f01043a2 <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)
f01043a2:	6a 00                	push   $0x0
f01043a4:	6a 03                	push   $0x3
f01043a6:	e9 d1 00 00 00       	jmp    f010447c <_alltraps>
f01043ab:	90                   	nop

f01043ac <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)
f01043ac:	6a 00                	push   $0x0
f01043ae:	6a 04                	push   $0x4
f01043b0:	e9 c7 00 00 00       	jmp    f010447c <_alltraps>
f01043b5:	90                   	nop

f01043b6 <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)
f01043b6:	6a 00                	push   $0x0
f01043b8:	6a 05                	push   $0x5
f01043ba:	e9 bd 00 00 00       	jmp    f010447c <_alltraps>
f01043bf:	90                   	nop

f01043c0 <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)
f01043c0:	6a 00                	push   $0x0
f01043c2:	6a 06                	push   $0x6
f01043c4:	e9 b3 00 00 00       	jmp    f010447c <_alltraps>
f01043c9:	90                   	nop

f01043ca <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)
f01043ca:	6a 00                	push   $0x0
f01043cc:	6a 07                	push   $0x7
f01043ce:	e9 a9 00 00 00       	jmp    f010447c <_alltraps>
f01043d3:	90                   	nop

f01043d4 <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT)
f01043d4:	6a 08                	push   $0x8
f01043d6:	e9 a1 00 00 00       	jmp    f010447c <_alltraps>
f01043db:	90                   	nop

f01043dc <t_tss>:
TRAPHANDLER(t_tss, T_TSS)
f01043dc:	6a 0a                	push   $0xa
f01043de:	e9 99 00 00 00       	jmp    f010447c <_alltraps>
f01043e3:	90                   	nop

f01043e4 <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP)
f01043e4:	6a 0b                	push   $0xb
f01043e6:	e9 91 00 00 00       	jmp    f010447c <_alltraps>
f01043eb:	90                   	nop

f01043ec <t_stack>:
TRAPHANDLER(t_stack, T_STACK)
f01043ec:	6a 0c                	push   $0xc
f01043ee:	e9 89 00 00 00       	jmp    f010447c <_alltraps>
f01043f3:	90                   	nop

f01043f4 <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)
f01043f4:	6a 0d                	push   $0xd
f01043f6:	e9 81 00 00 00       	jmp    f010447c <_alltraps>
f01043fb:	90                   	nop

f01043fc <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)
f01043fc:	6a 0e                	push   $0xe
f01043fe:	eb 7c                	jmp    f010447c <_alltraps>

f0104400 <t_fperr>:
TRAPHANDLER_NOEC(t_fperr, T_FPERR)
f0104400:	6a 00                	push   $0x0
f0104402:	6a 10                	push   $0x10
f0104404:	eb 76                	jmp    f010447c <_alltraps>

f0104406 <t_align>:
TRAPHANDLER(t_align, T_ALIGN)
f0104406:	6a 11                	push   $0x11
f0104408:	eb 72                	jmp    f010447c <_alltraps>

f010440a <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK)
f010440a:	6a 00                	push   $0x0
f010440c:	6a 12                	push   $0x12
f010440e:	eb 6c                	jmp    f010447c <_alltraps>

f0104410 <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)
f0104410:	6a 00                	push   $0x0
f0104412:	6a 13                	push   $0x13
f0104414:	eb 66                	jmp    f010447c <_alltraps>

f0104416 <t_syscall>:

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f0104416:	6a 00                	push   $0x0
f0104418:	6a 30                	push   $0x30
f010441a:	eb 60                	jmp    f010447c <_alltraps>

f010441c <IRQ0>:

TRAPHANDLER_NOEC(IRQ0, IRQ_OFFSET)
f010441c:	6a 00                	push   $0x0
f010441e:	6a 20                	push   $0x20
f0104420:	eb 5a                	jmp    f010447c <_alltraps>

f0104422 <IRQ1>:
TRAPHANDLER_NOEC(IRQ1, IRQ_OFFSET+1)
f0104422:	6a 00                	push   $0x0
f0104424:	6a 21                	push   $0x21
f0104426:	eb 54                	jmp    f010447c <_alltraps>

f0104428 <IRQ2>:
TRAPHANDLER_NOEC(IRQ2, IRQ_OFFSET+2)
f0104428:	6a 00                	push   $0x0
f010442a:	6a 22                	push   $0x22
f010442c:	eb 4e                	jmp    f010447c <_alltraps>

f010442e <IRQ3>:
TRAPHANDLER_NOEC(IRQ3, IRQ_OFFSET+3)
f010442e:	6a 00                	push   $0x0
f0104430:	6a 23                	push   $0x23
f0104432:	eb 48                	jmp    f010447c <_alltraps>

f0104434 <IRQ4>:
TRAPHANDLER_NOEC(IRQ4, IRQ_OFFSET+4)
f0104434:	6a 00                	push   $0x0
f0104436:	6a 24                	push   $0x24
f0104438:	eb 42                	jmp    f010447c <_alltraps>

f010443a <IRQ5>:
TRAPHANDLER_NOEC(IRQ5, IRQ_OFFSET+5)
f010443a:	6a 00                	push   $0x0
f010443c:	6a 25                	push   $0x25
f010443e:	eb 3c                	jmp    f010447c <_alltraps>

f0104440 <IRQ6>:
TRAPHANDLER_NOEC(IRQ6, IRQ_OFFSET+6)
f0104440:	6a 00                	push   $0x0
f0104442:	6a 26                	push   $0x26
f0104444:	eb 36                	jmp    f010447c <_alltraps>

f0104446 <IRQ7>:
TRAPHANDLER_NOEC(IRQ7, IRQ_OFFSET+7)
f0104446:	6a 00                	push   $0x0
f0104448:	6a 27                	push   $0x27
f010444a:	eb 30                	jmp    f010447c <_alltraps>

f010444c <IRQ8>:
TRAPHANDLER_NOEC(IRQ8, IRQ_OFFSET+8)
f010444c:	6a 00                	push   $0x0
f010444e:	6a 28                	push   $0x28
f0104450:	eb 2a                	jmp    f010447c <_alltraps>

f0104452 <IRQ9>:
TRAPHANDLER_NOEC(IRQ9, IRQ_OFFSET+9)
f0104452:	6a 00                	push   $0x0
f0104454:	6a 29                	push   $0x29
f0104456:	eb 24                	jmp    f010447c <_alltraps>

f0104458 <IRQ10>:
TRAPHANDLER_NOEC(IRQ10, IRQ_OFFSET+10)
f0104458:	6a 00                	push   $0x0
f010445a:	6a 2a                	push   $0x2a
f010445c:	eb 1e                	jmp    f010447c <_alltraps>

f010445e <IRQ11>:
TRAPHANDLER_NOEC(IRQ11, IRQ_OFFSET+11)
f010445e:	6a 00                	push   $0x0
f0104460:	6a 2b                	push   $0x2b
f0104462:	eb 18                	jmp    f010447c <_alltraps>

f0104464 <IRQ12>:
TRAPHANDLER_NOEC(IRQ12, IRQ_OFFSET+12)
f0104464:	6a 00                	push   $0x0
f0104466:	6a 2c                	push   $0x2c
f0104468:	eb 12                	jmp    f010447c <_alltraps>

f010446a <IRQ13>:
TRAPHANDLER_NOEC(IRQ13, IRQ_OFFSET+13)
f010446a:	6a 00                	push   $0x0
f010446c:	6a 2d                	push   $0x2d
f010446e:	eb 0c                	jmp    f010447c <_alltraps>

f0104470 <IRQ14>:
TRAPHANDLER_NOEC(IRQ14, IRQ_OFFSET+14)
f0104470:	6a 00                	push   $0x0
f0104472:	6a 2e                	push   $0x2e
f0104474:	eb 06                	jmp    f010447c <_alltraps>

f0104476 <IRQ15>:
TRAPHANDLER_NOEC(IRQ15, IRQ_OFFSET+15)
f0104476:	6a 00                	push   $0x0
f0104478:	6a 2f                	push   $0x2f
f010447a:	eb 00                	jmp    f010447c <_alltraps>

f010447c <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
 
 _alltraps:
 	pushl %ds
f010447c:	1e                   	push   %ds
	pushl %es
f010447d:	06                   	push   %es
	pushal /* push all general registers */
f010447e:	60                   	pusha  

	movl $GD_KD, %eax
f010447f:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f0104484:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104486:	8e c0                	mov    %eax,%es

	push %esp
f0104488:	54                   	push   %esp
	call trap	
f0104489:	e8 d3 fc ff ff       	call   f0104161 <trap>

f010448e <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010448e:	55                   	push   %ebp
f010448f:	89 e5                	mov    %esp,%ebp
f0104491:	83 ec 08             	sub    $0x8,%esp
f0104494:	a1 4c f2 22 f0       	mov    0xf022f24c,%eax
f0104499:	8d 50 54             	lea    0x54(%eax),%edx
	int i;
	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010449c:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01044a1:	8b 02                	mov    (%edx),%eax
f01044a3:	83 e8 01             	sub    $0x1,%eax
f01044a6:	83 f8 02             	cmp    $0x2,%eax
f01044a9:	76 10                	jbe    f01044bb <sched_halt+0x2d>
sched_halt(void)
{
	int i;
	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01044ab:	83 c1 01             	add    $0x1,%ecx
f01044ae:	83 c2 7c             	add    $0x7c,%edx
f01044b1:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01044b7:	75 e8                	jne    f01044a1 <sched_halt+0x13>
f01044b9:	eb 08                	jmp    f01044c3 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f01044bb:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01044c1:	75 1f                	jne    f01044e2 <sched_halt+0x54>
		cprintf("No runnable environmeants in the system!\n");
f01044c3:	83 ec 0c             	sub    $0xc,%esp
f01044c6:	68 b0 7b 10 f0       	push   $0xf0107bb0
f01044cb:	e8 92 f2 ff ff       	call   f0103762 <cprintf>
f01044d0:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01044d3:	83 ec 0c             	sub    $0xc,%esp
f01044d6:	6a 00                	push   $0x0
f01044d8:	e8 8d c3 ff ff       	call   f010086a <monitor>
f01044dd:	83 c4 10             	add    $0x10,%esp
f01044e0:	eb f1                	jmp    f01044d3 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01044e2:	e8 9f 18 00 00       	call   f0105d86 <cpunum>
f01044e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01044ea:	c7 80 28 00 23 f0 00 	movl   $0x0,-0xfdcffd8(%eax)
f01044f1:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01044f4:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01044f9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01044fe:	77 12                	ja     f0104512 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104500:	50                   	push   %eax
f0104501:	68 68 64 10 f0       	push   $0xf0106468
f0104506:	6a 51                	push   $0x51
f0104508:	68 da 7b 10 f0       	push   $0xf0107bda
f010450d:	e8 2e bb ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104512:	05 00 00 00 10       	add    $0x10000000,%eax
f0104517:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f010451a:	e8 67 18 00 00       	call   f0105d86 <cpunum>
f010451f:	6b d0 74             	imul   $0x74,%eax,%edx
f0104522:	81 c2 20 00 23 f0    	add    $0xf0230020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104528:	b8 02 00 00 00       	mov    $0x2,%eax
f010452d:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104531:	83 ec 0c             	sub    $0xc,%esp
f0104534:	68 c0 03 12 f0       	push   $0xf01203c0
f0104539:	e8 53 1b 00 00       	call   f0106091 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010453e:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104540:	e8 41 18 00 00       	call   f0105d86 <cpunum>
f0104545:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104548:	8b 80 30 00 23 f0    	mov    -0xfdcffd0(%eax),%eax
f010454e:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104553:	89 c4                	mov    %eax,%esp
f0104555:	6a 00                	push   $0x0
f0104557:	6a 00                	push   $0x0
f0104559:	fb                   	sti    
f010455a:	f4                   	hlt    
f010455b:	eb fd                	jmp    f010455a <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f010455d:	83 c4 10             	add    $0x10,%esp
f0104560:	c9                   	leave  
f0104561:	c3                   	ret    

f0104562 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104562:	55                   	push   %ebp
f0104563:	89 e5                	mov    %esp,%ebp
f0104565:	57                   	push   %edi
f0104566:	56                   	push   %esi
f0104567:	53                   	push   %ebx
f0104568:	83 ec 0c             	sub    $0xc,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int i, nxenvid;
    if (curenv)
f010456b:	e8 16 18 00 00       	call   f0105d86 <cpunum>
f0104570:	6b c0 74             	imul   $0x74,%eax,%eax
        nxenvid = ENVX(curenv->env_id); 
    else 
        nxenvid = 0;
f0104573:	b9 00 00 00 00       	mov    $0x0,%ecx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int i, nxenvid;
    if (curenv)
f0104578:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f010457f:	74 17                	je     f0104598 <sched_yield+0x36>
        nxenvid = ENVX(curenv->env_id); 
f0104581:	e8 00 18 00 00       	call   f0105d86 <cpunum>
f0104586:	6b c0 74             	imul   $0x74,%eax,%eax
f0104589:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010458f:	8b 48 48             	mov    0x48(%eax),%ecx
f0104592:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
    else 
        nxenvid = 0;
	
    for (i = 0; i < NENV; i++) {
		//cprintf("cpu =%d %d status=%d\n",cpunum(),i,envs[(nxenvid + i) % NENV].env_status);
        if (envs[(nxenvid + i) % NENV].env_status == ENV_RUNNABLE){
f0104598:	8b 3d 4c f2 22 f0    	mov    0xf022f24c,%edi
f010459e:	89 ca                	mov    %ecx,%edx
f01045a0:	81 c1 00 04 00 00    	add    $0x400,%ecx
f01045a6:	89 d3                	mov    %edx,%ebx
f01045a8:	c1 fb 1f             	sar    $0x1f,%ebx
f01045ab:	c1 eb 16             	shr    $0x16,%ebx
f01045ae:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f01045b1:	25 ff 03 00 00       	and    $0x3ff,%eax
f01045b6:	29 d8                	sub    %ebx,%eax
f01045b8:	6b c0 7c             	imul   $0x7c,%eax,%eax
f01045bb:	89 c6                	mov    %eax,%esi
f01045bd:	8d 1c 07             	lea    (%edi,%eax,1),%ebx
f01045c0:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f01045c4:	75 17                	jne    f01045dd <sched_yield+0x7b>
			envs[(nxenvid + i) % NENV].env_cpunum=cpunum();
f01045c6:	e8 bb 17 00 00       	call   f0105d86 <cpunum>
f01045cb:	89 43 5c             	mov    %eax,0x5c(%ebx)
			env_run(&envs[(nxenvid + i) % NENV]);
f01045ce:	83 ec 0c             	sub    $0xc,%esp
f01045d1:	03 35 4c f2 22 f0    	add    0xf022f24c,%esi
f01045d7:	56                   	push   %esi
f01045d8:	e8 4f ef ff ff       	call   f010352c <env_run>
f01045dd:	83 c2 01             	add    $0x1,%edx
    if (curenv)
        nxenvid = ENVX(curenv->env_id); 
    else 
        nxenvid = 0;
	
    for (i = 0; i < NENV; i++) {
f01045e0:	39 ca                	cmp    %ecx,%edx
f01045e2:	75 c2                	jne    f01045a6 <sched_yield+0x44>
        if (envs[(nxenvid + i) % NENV].env_status == ENV_RUNNABLE){
			envs[(nxenvid + i) % NENV].env_cpunum=cpunum();
			env_run(&envs[(nxenvid + i) % NENV]);
		}
    }
    if (curenv && curenv->env_status == ENV_RUNNING){
f01045e4:	e8 9d 17 00 00       	call   f0105d86 <cpunum>
f01045e9:	6b c0 74             	imul   $0x74,%eax,%eax
f01045ec:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f01045f3:	74 40                	je     f0104635 <sched_yield+0xd3>
f01045f5:	e8 8c 17 00 00       	call   f0105d86 <cpunum>
f01045fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01045fd:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104603:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104607:	75 2c                	jne    f0104635 <sched_yield+0xd3>
		curenv->env_cpunum=cpunum();
f0104609:	e8 78 17 00 00       	call   f0105d86 <cpunum>
f010460e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104611:	8b 98 28 00 23 f0    	mov    -0xfdcffd8(%eax),%ebx
f0104617:	e8 6a 17 00 00       	call   f0105d86 <cpunum>
f010461c:	89 43 5c             	mov    %eax,0x5c(%ebx)
		env_run(curenv);
f010461f:	e8 62 17 00 00       	call   f0105d86 <cpunum>
f0104624:	83 ec 0c             	sub    $0xc,%esp
f0104627:	6b c0 74             	imul   $0x74,%eax,%eax
f010462a:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104630:	e8 f7 ee ff ff       	call   f010352c <env_run>
	}
	
	// sched_halt never returns
	sched_halt();
f0104635:	e8 54 fe ff ff       	call   f010448e <sched_halt>
}
f010463a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010463d:	5b                   	pop    %ebx
f010463e:	5e                   	pop    %esi
f010463f:	5f                   	pop    %edi
f0104640:	5d                   	pop    %ebp
f0104641:	c3                   	ret    

f0104642 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104642:	55                   	push   %ebp
f0104643:	89 e5                	mov    %esp,%ebp
f0104645:	57                   	push   %edi
f0104646:	56                   	push   %esi
f0104647:	53                   	push   %ebx
f0104648:	83 ec 1c             	sub    $0x1c,%esp
f010464b:	8b 45 08             	mov    0x8(%ebp),%eax
    // Return any appropriate return value.
    // LAB 3: Your code here.

    //    panic("syscall not implemented");

    switch (syscallno) {
f010464e:	83 f8 0c             	cmp    $0xc,%eax
f0104651:	0f 87 23 06 00 00    	ja     f0104c7a <syscall+0x638>
f0104657:	ff 24 85 2c 7c 10 f0 	jmp    *-0xfef83d4(,%eax,4)
{
    // Check that the user has permission to read memory [s, s+len).
    // Destroy the environment if not:.

    // LAB 3: Your code here.
    user_mem_assert(curenv, s, len, 0);
f010465e:	e8 23 17 00 00       	call   f0105d86 <cpunum>
f0104663:	6a 00                	push   $0x0
f0104665:	ff 75 10             	pushl  0x10(%ebp)
f0104668:	ff 75 0c             	pushl  0xc(%ebp)
f010466b:	6b c0 74             	imul   $0x74,%eax,%eax
f010466e:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104674:	e8 75 e7 ff ff       	call   f0102dee <user_mem_assert>
    // Print the string supplied by the user.
    cprintf("%.*s", len, s);
f0104679:	83 c4 0c             	add    $0xc,%esp
f010467c:	ff 75 0c             	pushl  0xc(%ebp)
f010467f:	ff 75 10             	pushl  0x10(%ebp)
f0104682:	68 e7 7b 10 f0       	push   $0xf0107be7
f0104687:	e8 d6 f0 ff ff       	call   f0103762 <cprintf>
f010468c:	83 c4 10             	add    $0x10,%esp
    //    panic("syscall not implemented");

    switch (syscallno) {
        case (SYS_cputs):
            sys_cputs((const char *)a1, a2);
            return 0;
f010468f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104694:	e9 ed 05 00 00       	jmp    f0104c86 <syscall+0x644>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104699:	e8 40 bf ff ff       	call   f01005de <cons_getc>
f010469e:	89 c3                	mov    %eax,%ebx
    switch (syscallno) {
        case (SYS_cputs):
            sys_cputs((const char *)a1, a2);
            return 0;
        case (SYS_cgetc):
            return sys_cgetc();
f01046a0:	e9 e1 05 00 00       	jmp    f0104c86 <syscall+0x644>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01046a5:	e8 dc 16 00 00       	call   f0105d86 <cpunum>
f01046aa:	6b c0 74             	imul   $0x74,%eax,%eax
f01046ad:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01046b3:	8b 58 48             	mov    0x48(%eax),%ebx
            sys_cputs((const char *)a1, a2);
            return 0;
        case (SYS_cgetc):
            return sys_cgetc();
        case (SYS_getenvid):
            return sys_getenvid();
f01046b6:	e9 cb 05 00 00       	jmp    f0104c86 <syscall+0x644>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01046bb:	83 ec 04             	sub    $0x4,%esp
f01046be:	6a 01                	push   $0x1
f01046c0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046c3:	50                   	push   %eax
f01046c4:	ff 75 0c             	pushl  0xc(%ebp)
f01046c7:	e8 f3 e7 ff ff       	call   f0102ebf <envid2env>
f01046cc:	83 c4 10             	add    $0x10,%esp
		return r;
f01046cf:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01046d1:	85 c0                	test   %eax,%eax
f01046d3:	0f 88 ad 05 00 00    	js     f0104c86 <syscall+0x644>
		return r;
	if (e == curenv)
f01046d9:	e8 a8 16 00 00       	call   f0105d86 <cpunum>
f01046de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01046e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01046e4:	39 90 28 00 23 f0    	cmp    %edx,-0xfdcffd8(%eax)
f01046ea:	75 23                	jne    f010470f <syscall+0xcd>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01046ec:	e8 95 16 00 00       	call   f0105d86 <cpunum>
f01046f1:	83 ec 08             	sub    $0x8,%esp
f01046f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01046f7:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01046fd:	ff 70 48             	pushl  0x48(%eax)
f0104700:	68 ec 7b 10 f0       	push   $0xf0107bec
f0104705:	e8 58 f0 ff ff       	call   f0103762 <cprintf>
f010470a:	83 c4 10             	add    $0x10,%esp
f010470d:	eb 25                	jmp    f0104734 <syscall+0xf2>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010470f:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104712:	e8 6f 16 00 00       	call   f0105d86 <cpunum>
f0104717:	83 ec 04             	sub    $0x4,%esp
f010471a:	53                   	push   %ebx
f010471b:	6b c0 74             	imul   $0x74,%eax,%eax
f010471e:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104724:	ff 70 48             	pushl  0x48(%eax)
f0104727:	68 07 7c 10 f0       	push   $0xf0107c07
f010472c:	e8 31 f0 ff ff       	call   f0103762 <cprintf>
f0104731:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104734:	83 ec 0c             	sub    $0xc,%esp
f0104737:	ff 75 e4             	pushl  -0x1c(%ebp)
f010473a:	e8 4e ed ff ff       	call   f010348d <env_destroy>
f010473f:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104742:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104747:	e9 3a 05 00 00       	jmp    f0104c86 <syscall+0x644>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f010474c:	e8 11 fe ff ff       	call   f0104562 <sched_yield>
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env*child=NULL;
f0104751:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r=env_alloc(&child,curenv->env_id);
f0104758:	e8 29 16 00 00       	call   f0105d86 <cpunum>
f010475d:	83 ec 08             	sub    $0x8,%esp
f0104760:	6b c0 74             	imul   $0x74,%eax,%eax
f0104763:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104769:	ff 70 48             	pushl  0x48(%eax)
f010476c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010476f:	50                   	push   %eax
f0104770:	e8 5b e8 ff ff       	call   f0102fd0 <env_alloc>
	if(r!=0)return r;
f0104775:	83 c4 10             	add    $0x10,%esp
f0104778:	89 c3                	mov    %eax,%ebx
f010477a:	85 c0                	test   %eax,%eax
f010477c:	0f 85 04 05 00 00    	jne    f0104c86 <syscall+0x644>
	child->env_tf=curenv->env_tf;
f0104782:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104785:	e8 fc 15 00 00       	call   f0105d86 <cpunum>
f010478a:	6b c0 74             	imul   $0x74,%eax,%eax
f010478d:	8b b0 28 00 23 f0    	mov    -0xfdcffd8(%eax),%esi
f0104793:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104798:	89 df                	mov    %ebx,%edi
f010479a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child->env_status=ENV_NOT_RUNNABLE;
f010479c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010479f:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	cprintf("status:%d\n",child->env_status);
f01047a6:	83 ec 08             	sub    $0x8,%esp
f01047a9:	6a 04                	push   $0x4
f01047ab:	68 1f 7c 10 f0       	push   $0xf0107c1f
f01047b0:	e8 ad ef ff ff       	call   f0103762 <cprintf>
	child->env_tf.tf_regs.reg_eax = 0;
f01047b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047b8:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return child->env_id;
f01047bf:	8b 58 48             	mov    0x48(%eax),%ebx
f01047c2:	83 c4 10             	add    $0x10,%esp
f01047c5:	e9 bc 04 00 00       	jmp    f0104c86 <syscall+0x644>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	struct Env * env=NULL;
f01047ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r=envid2env(envid,&env,1);
f01047d1:	83 ec 04             	sub    $0x4,%esp
f01047d4:	6a 01                	push   $0x1
f01047d6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01047d9:	50                   	push   %eax
f01047da:	ff 75 0c             	pushl  0xc(%ebp)
f01047dd:	e8 dd e6 ff ff       	call   f0102ebf <envid2env>
	if(r<0)return -E_BAD_ENV;
f01047e2:	83 c4 10             	add    $0x10,%esp
f01047e5:	85 c0                	test   %eax,%eax
f01047e7:	78 20                	js     f0104809 <syscall+0x1c7>
	else {
		if(status!=ENV_NOT_RUNNABLE&&status!=ENV_RUNNABLE)return -E_INVAL;
f01047e9:	8b 45 10             	mov    0x10(%ebp),%eax
f01047ec:	83 e8 02             	sub    $0x2,%eax
f01047ef:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f01047f4:	75 1d                	jne    f0104813 <syscall+0x1d1>
		env->env_status=status;
f01047f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047f9:	8b 7d 10             	mov    0x10(%ebp),%edi
f01047fc:	89 78 54             	mov    %edi,0x54(%eax)
	}
	return 0;
f01047ff:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104804:	e9 7d 04 00 00       	jmp    f0104c86 <syscall+0x644>
	// envid's status.

	// LAB 4: Your code here.
	struct Env * env=NULL;
	int r=envid2env(envid,&env,1);
	if(r<0)return -E_BAD_ENV;
f0104809:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f010480e:	e9 73 04 00 00       	jmp    f0104c86 <syscall+0x644>
	else {
		if(status!=ENV_NOT_RUNNABLE&&status!=ENV_RUNNABLE)return -E_INVAL;
f0104813:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			sys_yield();
			return 0;
		case SYS_exofork:
           	return sys_exofork();
		case SYS_env_set_status:
           	return sys_env_set_status((envid_t)a1, (int)a2);
f0104818:	e9 69 04 00 00       	jmp    f0104c86 <syscall+0x644>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	struct Env * env;
	if(envid2env(envid,&env,1)<0)return -E_BAD_ENV;
f010481d:	83 ec 04             	sub    $0x4,%esp
f0104820:	6a 01                	push   $0x1
f0104822:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104825:	50                   	push   %eax
f0104826:	ff 75 0c             	pushl  0xc(%ebp)
f0104829:	e8 91 e6 ff ff       	call   f0102ebf <envid2env>
f010482e:	83 c4 10             	add    $0x10,%esp
f0104831:	85 c0                	test   %eax,%eax
f0104833:	78 6e                	js     f01048a3 <syscall+0x261>
	if((uintptr_t)va>=UTOP||PGOFF(va))return  -E_INVAL;
f0104835:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010483c:	77 6f                	ja     f01048ad <syscall+0x26b>
f010483e:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104845:	75 70                	jne    f01048b7 <syscall+0x275>
	int flag=PTE_U | PTE_P;
	if((perm & ~(PTE_SYSCALL))!=0||(perm&flag)!=flag)return -E_INVAL;
f0104847:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010484a:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f0104850:	75 6f                	jne    f01048c1 <syscall+0x27f>
f0104852:	8b 45 14             	mov    0x14(%ebp),%eax
f0104855:	83 e0 05             	and    $0x5,%eax
f0104858:	83 f8 05             	cmp    $0x5,%eax
f010485b:	75 6e                	jne    f01048cb <syscall+0x289>
	struct PageInfo* pi=page_alloc(1);
f010485d:	83 ec 0c             	sub    $0xc,%esp
f0104860:	6a 01                	push   $0x1
f0104862:	e8 59 c6 ff ff       	call   f0100ec0 <page_alloc>
f0104867:	89 c6                	mov    %eax,%esi
	if(pi==NULL)return -E_NO_MEM;
f0104869:	83 c4 10             	add    $0x10,%esp
f010486c:	85 c0                	test   %eax,%eax
f010486e:	74 65                	je     f01048d5 <syscall+0x293>
	if(page_insert(env->env_pgdir,pi,va,perm)<0){
f0104870:	ff 75 14             	pushl  0x14(%ebp)
f0104873:	ff 75 10             	pushl  0x10(%ebp)
f0104876:	50                   	push   %eax
f0104877:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010487a:	ff 70 60             	pushl  0x60(%eax)
f010487d:	e8 14 c9 ff ff       	call   f0101196 <page_insert>
f0104882:	83 c4 10             	add    $0x10,%esp
f0104885:	85 c0                	test   %eax,%eax
f0104887:	0f 89 f9 03 00 00    	jns    f0104c86 <syscall+0x644>
		page_free(pi);
f010488d:	83 ec 0c             	sub    $0xc,%esp
f0104890:	56                   	push   %esi
f0104891:	e8 9a c6 ff ff       	call   f0100f30 <page_free>
f0104896:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f0104899:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f010489e:	e9 e3 03 00 00       	jmp    f0104c86 <syscall+0x644>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	struct Env * env;
	if(envid2env(envid,&env,1)<0)return -E_BAD_ENV;
f01048a3:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01048a8:	e9 d9 03 00 00       	jmp    f0104c86 <syscall+0x644>
	if((uintptr_t)va>=UTOP||PGOFF(va))return  -E_INVAL;
f01048ad:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048b2:	e9 cf 03 00 00       	jmp    f0104c86 <syscall+0x644>
f01048b7:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048bc:	e9 c5 03 00 00       	jmp    f0104c86 <syscall+0x644>
	int flag=PTE_U | PTE_P;
	if((perm & ~(PTE_SYSCALL))!=0||(perm&flag)!=flag)return -E_INVAL;
f01048c1:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048c6:	e9 bb 03 00 00       	jmp    f0104c86 <syscall+0x644>
f01048cb:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048d0:	e9 b1 03 00 00       	jmp    f0104c86 <syscall+0x644>
	struct PageInfo* pi=page_alloc(1);
	if(pi==NULL)return -E_NO_MEM;
f01048d5:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
		case SYS_exofork:
           	return sys_exofork();
		case SYS_env_set_status:
           	return sys_env_set_status((envid_t)a1, (int)a2);
		case SYS_page_alloc:
           	return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
f01048da:	e9 a7 03 00 00       	jmp    f0104c86 <syscall+0x644>
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	int r=0;
	struct Env * srccur=NULL,*dstcur=NULL;
f01048df:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01048e6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	r=envid2env(srcenvid,&srccur,1);
f01048ed:	83 ec 04             	sub    $0x4,%esp
f01048f0:	6a 01                	push   $0x1
f01048f2:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01048f5:	50                   	push   %eax
f01048f6:	ff 75 0c             	pushl  0xc(%ebp)
f01048f9:	e8 c1 e5 ff ff       	call   f0102ebf <envid2env>
	if(r<0)return -E_BAD_ENV;
f01048fe:	83 c4 10             	add    $0x10,%esp
f0104901:	85 c0                	test   %eax,%eax
f0104903:	0f 88 b2 00 00 00    	js     f01049bb <syscall+0x379>
	r=envid2env(dstenvid,&dstcur,1);
f0104909:	83 ec 04             	sub    $0x4,%esp
f010490c:	6a 01                	push   $0x1
f010490e:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104911:	50                   	push   %eax
f0104912:	ff 75 14             	pushl  0x14(%ebp)
f0104915:	e8 a5 e5 ff ff       	call   f0102ebf <envid2env>
	if(r<0)return -E_BAD_ENV;
f010491a:	83 c4 10             	add    $0x10,%esp
f010491d:	85 c0                	test   %eax,%eax
f010491f:	0f 88 a0 00 00 00    	js     f01049c5 <syscall+0x383>
	if((uintptr_t)srcva >= UTOP||(uintptr_t)dstva >= UTOP||PGOFF(srcva)|| PGOFF(dstva))return -E_INVAL;
f0104925:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010492c:	0f 87 9d 00 00 00    	ja     f01049cf <syscall+0x38d>
f0104932:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104939:	0f 87 90 00 00 00    	ja     f01049cf <syscall+0x38d>
f010493f:	8b 45 10             	mov    0x10(%ebp),%eax
f0104942:	0b 45 18             	or     0x18(%ebp),%eax
f0104945:	a9 ff 0f 00 00       	test   $0xfff,%eax
f010494a:	0f 85 89 00 00 00    	jne    f01049d9 <syscall+0x397>
	pte_t * store=NULL;
f0104950:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	struct PageInfo* pg=NULL;
	if((pg=page_lookup(srccur->env_pgdir,srcva,&store))==NULL)return -E_INVAL;
f0104957:	83 ec 04             	sub    $0x4,%esp
f010495a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010495d:	50                   	push   %eax
f010495e:	ff 75 10             	pushl  0x10(%ebp)
f0104961:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104964:	ff 70 60             	pushl  0x60(%eax)
f0104967:	e8 49 c7 ff ff       	call   f01010b5 <page_lookup>
f010496c:	83 c4 10             	add    $0x10,%esp
f010496f:	85 c0                	test   %eax,%eax
f0104971:	74 70                	je     f01049e3 <syscall+0x3a1>
	int flag=PTE_U | PTE_P;
	if((perm & ~(PTE_SYSCALL))!=0||(perm&flag)!=flag)return -E_INVAL;
f0104973:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f0104976:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f010497c:	75 6f                	jne    f01049ed <syscall+0x3ab>
f010497e:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0104981:	83 e2 05             	and    $0x5,%edx
f0104984:	83 fa 05             	cmp    $0x5,%edx
f0104987:	75 6e                	jne    f01049f7 <syscall+0x3b5>
	if((perm&PTE_W)&&!(*store&PTE_W))return E_INVAL;
f0104989:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f010498d:	74 08                	je     f0104997 <syscall+0x355>
f010498f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104992:	f6 02 02             	testb  $0x2,(%edx)
f0104995:	74 6a                	je     f0104a01 <syscall+0x3bf>
	if (page_insert(dstcur->env_pgdir, pg, dstva, perm) < 0) 
f0104997:	ff 75 1c             	pushl  0x1c(%ebp)
f010499a:	ff 75 18             	pushl  0x18(%ebp)
f010499d:	50                   	push   %eax
f010499e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049a1:	ff 70 60             	pushl  0x60(%eax)
f01049a4:	e8 ed c7 ff ff       	call   f0101196 <page_insert>
f01049a9:	83 c4 10             	add    $0x10,%esp
        return -E_NO_MEM;
f01049ac:	85 c0                	test   %eax,%eax
f01049ae:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01049b3:	0f 48 d8             	cmovs  %eax,%ebx
f01049b6:	e9 cb 02 00 00       	jmp    f0104c86 <syscall+0x644>

	// LAB 4: Your code here.
	int r=0;
	struct Env * srccur=NULL,*dstcur=NULL;
	r=envid2env(srcenvid,&srccur,1);
	if(r<0)return -E_BAD_ENV;
f01049bb:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01049c0:	e9 c1 02 00 00       	jmp    f0104c86 <syscall+0x644>
	r=envid2env(dstenvid,&dstcur,1);
	if(r<0)return -E_BAD_ENV;
f01049c5:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01049ca:	e9 b7 02 00 00       	jmp    f0104c86 <syscall+0x644>
	if((uintptr_t)srcva >= UTOP||(uintptr_t)dstva >= UTOP||PGOFF(srcva)|| PGOFF(dstva))return -E_INVAL;
f01049cf:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049d4:	e9 ad 02 00 00       	jmp    f0104c86 <syscall+0x644>
f01049d9:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049de:	e9 a3 02 00 00       	jmp    f0104c86 <syscall+0x644>
	pte_t * store=NULL;
	struct PageInfo* pg=NULL;
	if((pg=page_lookup(srccur->env_pgdir,srcva,&store))==NULL)return -E_INVAL;
f01049e3:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049e8:	e9 99 02 00 00       	jmp    f0104c86 <syscall+0x644>
	int flag=PTE_U | PTE_P;
	if((perm & ~(PTE_SYSCALL))!=0||(perm&flag)!=flag)return -E_INVAL;
f01049ed:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049f2:	e9 8f 02 00 00       	jmp    f0104c86 <syscall+0x644>
f01049f7:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049fc:	e9 85 02 00 00       	jmp    f0104c86 <syscall+0x644>
	if((perm&PTE_W)&&!(*store&PTE_W))return E_INVAL;
f0104a01:	bb 03 00 00 00       	mov    $0x3,%ebx
f0104a06:	e9 7b 02 00 00       	jmp    f0104c86 <syscall+0x644>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env *env;
	int r=envid2env(envid,&env,1);
f0104a0b:	83 ec 04             	sub    $0x4,%esp
f0104a0e:	6a 01                	push   $0x1
f0104a10:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a13:	50                   	push   %eax
f0104a14:	ff 75 0c             	pushl  0xc(%ebp)
f0104a17:	e8 a3 e4 ff ff       	call   f0102ebf <envid2env>
	if(r<0)return -E_BAD_ENV;
f0104a1c:	83 c4 10             	add    $0x10,%esp
f0104a1f:	85 c0                	test   %eax,%eax
f0104a21:	78 30                	js     f0104a53 <syscall+0x411>
	if((uintptr_t)va>=UTOP||PGOFF(va))return  -E_INVAL;
f0104a23:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104a2a:	77 31                	ja     f0104a5d <syscall+0x41b>
f0104a2c:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104a33:	75 32                	jne    f0104a67 <syscall+0x425>
	page_remove(env->env_pgdir,va);
f0104a35:	83 ec 08             	sub    $0x8,%esp
f0104a38:	ff 75 10             	pushl  0x10(%ebp)
f0104a3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a3e:	ff 70 60             	pushl  0x60(%eax)
f0104a41:	e8 0a c7 ff ff       	call   f0101150 <page_remove>
f0104a46:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104a49:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104a4e:	e9 33 02 00 00       	jmp    f0104c86 <syscall+0x644>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env *env;
	int r=envid2env(envid,&env,1);
	if(r<0)return -E_BAD_ENV;
f0104a53:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104a58:	e9 29 02 00 00       	jmp    f0104c86 <syscall+0x644>
	if((uintptr_t)va>=UTOP||PGOFF(va))return  -E_INVAL;
f0104a5d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a62:	e9 1f 02 00 00       	jmp    f0104c86 <syscall+0x644>
f0104a67:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_page_alloc:
           	return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
       	case SYS_page_map:
           	return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
       	case SYS_page_unmap:
           	return sys_page_unmap((envid_t)a1, (void *)a2);
f0104a6c:	e9 15 02 00 00       	jmp    f0104c86 <syscall+0x644>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env * env;
	if(envid2env(envid,&env,1)<0)return -E_BAD_ENV;
f0104a71:	83 ec 04             	sub    $0x4,%esp
f0104a74:	6a 01                	push   $0x1
f0104a76:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a79:	50                   	push   %eax
f0104a7a:	ff 75 0c             	pushl  0xc(%ebp)
f0104a7d:	e8 3d e4 ff ff       	call   f0102ebf <envid2env>
f0104a82:	83 c4 10             	add    $0x10,%esp
f0104a85:	85 c0                	test   %eax,%eax
f0104a87:	78 13                	js     f0104a9c <syscall+0x45a>
	env->env_pgfault_upcall=func;
f0104a89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a8c:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104a8f:	89 48 64             	mov    %ecx,0x64(%eax)

	return 0;
f0104a92:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104a97:	e9 ea 01 00 00       	jmp    f0104c86 <syscall+0x644>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env * env;
	if(envid2env(envid,&env,1)<0)return -E_BAD_ENV;
f0104a9c:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
       	case SYS_page_map:
           	return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
       	case SYS_page_unmap:
           	return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1,(void *)a2);
f0104aa1:	e9 e0 01 00 00       	jmp    f0104c86 <syscall+0x644>
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	struct Env* env;
	if(envid2env(envid,&env,0)<0)return -E_BAD_ENV;
f0104aa6:	83 ec 04             	sub    $0x4,%esp
f0104aa9:	6a 00                	push   $0x0
f0104aab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104aae:	50                   	push   %eax
f0104aaf:	ff 75 0c             	pushl  0xc(%ebp)
f0104ab2:	e8 08 e4 ff ff       	call   f0102ebf <envid2env>
f0104ab7:	83 c4 10             	add    $0x10,%esp
f0104aba:	85 c0                	test   %eax,%eax
f0104abc:	0f 88 25 01 00 00    	js     f0104be7 <syscall+0x5a5>
	if(env->env_ipc_recving==0)return -E_IPC_NOT_RECV;
f0104ac2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ac5:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104ac9:	0f 84 22 01 00 00    	je     f0104bf1 <syscall+0x5af>
	env->env_ipc_perm = 0;
f0104acf:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	unsigned flag= PTE_P | PTE_U;
	if((uintptr_t)srcva<UTOP){
f0104ad6:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104add:	0f 87 c8 00 00 00    	ja     f0104bab <syscall+0x569>
		if(PGOFF(srcva))return -E_INVAL;
f0104ae3:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104aea:	0f 85 0b 01 00 00    	jne    f0104bfb <syscall+0x5b9>
		if ((perm & ~(PTE_SYSCALL)) || ((perm & flag) != flag))return -E_INVAL;
f0104af0:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f0104af7:	0f 85 08 01 00 00    	jne    f0104c05 <syscall+0x5c3>
f0104afd:	8b 45 18             	mov    0x18(%ebp),%eax
f0104b00:	83 e0 05             	and    $0x5,%eax
f0104b03:	83 f8 05             	cmp    $0x5,%eax
f0104b06:	0f 85 00 01 00 00    	jne    f0104c0c <syscall+0x5ca>
		if (user_mem_check(curenv, (const void *)srcva, PGSIZE, PTE_U) < 0)
f0104b0c:	e8 75 12 00 00       	call   f0105d86 <cpunum>
f0104b11:	6a 04                	push   $0x4
f0104b13:	68 00 10 00 00       	push   $0x1000
f0104b18:	ff 75 14             	pushl  0x14(%ebp)
f0104b1b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b1e:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104b24:	e8 34 e2 ff ff       	call   f0102d5d <user_mem_check>
f0104b29:	83 c4 10             	add    $0x10,%esp
f0104b2c:	85 c0                	test   %eax,%eax
f0104b2e:	0f 88 df 00 00 00    	js     f0104c13 <syscall+0x5d1>
            return -E_INVAL;
		if (perm& PTE_W&&user_mem_check(curenv, (const void *)srcva, PGSIZE, PTE_U |PTE_W) < 0)
f0104b34:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104b38:	74 28                	je     f0104b62 <syscall+0x520>
f0104b3a:	e8 47 12 00 00       	call   f0105d86 <cpunum>
f0104b3f:	6a 06                	push   $0x6
f0104b41:	68 00 10 00 00       	push   $0x1000
f0104b46:	ff 75 14             	pushl  0x14(%ebp)
f0104b49:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b4c:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104b52:	e8 06 e2 ff ff       	call   f0102d5d <user_mem_check>
f0104b57:	83 c4 10             	add    $0x10,%esp
f0104b5a:	85 c0                	test   %eax,%eax
f0104b5c:	0f 88 b8 00 00 00    	js     f0104c1a <syscall+0x5d8>
            return -E_INVAL;
		if((uintptr_t)(env->env_ipc_dstva)<UTOP){
f0104b62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b65:	81 78 6c ff ff bf ee 	cmpl   $0xeebfffff,0x6c(%eax)
f0104b6c:	77 3d                	ja     f0104bab <syscall+0x569>
			env->env_ipc_perm=perm;
f0104b6e:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0104b71:	89 48 78             	mov    %ecx,0x78(%eax)
			struct PageInfo *pi = page_lookup(curenv->env_pgdir, srcva, 0);
f0104b74:	e8 0d 12 00 00       	call   f0105d86 <cpunum>
f0104b79:	83 ec 04             	sub    $0x4,%esp
f0104b7c:	6a 00                	push   $0x0
f0104b7e:	ff 75 14             	pushl  0x14(%ebp)
f0104b81:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b84:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104b8a:	ff 70 60             	pushl  0x60(%eax)
f0104b8d:	e8 23 c5 ff ff       	call   f01010b5 <page_lookup>
			if (page_insert(env->env_pgdir, pi, env->env_ipc_dstva,  perm) < 0)
f0104b92:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104b95:	ff 75 18             	pushl  0x18(%ebp)
f0104b98:	ff 72 6c             	pushl  0x6c(%edx)
f0104b9b:	50                   	push   %eax
f0104b9c:	ff 72 60             	pushl  0x60(%edx)
f0104b9f:	e8 f2 c5 ff ff       	call   f0101196 <page_insert>
f0104ba4:	83 c4 20             	add    $0x20,%esp
f0104ba7:	85 c0                	test   %eax,%eax
f0104ba9:	78 76                	js     f0104c21 <syscall+0x5df>
                return -E_NO_MEM; 
		}
	}
	env->env_ipc_recving = false;
f0104bab:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104bae:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
    env->env_ipc_from = curenv->env_id;
f0104bb2:	e8 cf 11 00 00       	call   f0105d86 <cpunum>
f0104bb7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bba:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104bc0:	8b 40 48             	mov    0x48(%eax),%eax
f0104bc3:	89 43 74             	mov    %eax,0x74(%ebx)
    env->env_ipc_value = value;
f0104bc6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104bc9:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104bcc:	89 78 70             	mov    %edi,0x70(%eax)
    env->env_status = ENV_RUNNABLE;
f0104bcf:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
    env->env_tf.tf_regs.reg_eax = 0;
f0104bd6:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f0104bdd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104be2:	e9 9f 00 00 00       	jmp    f0104c86 <syscall+0x644>
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	struct Env* env;
	if(envid2env(envid,&env,0)<0)return -E_BAD_ENV;
f0104be7:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104bec:	e9 95 00 00 00       	jmp    f0104c86 <syscall+0x644>
	if(env->env_ipc_recving==0)return -E_IPC_NOT_RECV;
f0104bf1:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104bf6:	e9 8b 00 00 00       	jmp    f0104c86 <syscall+0x644>
	env->env_ipc_perm = 0;
	unsigned flag= PTE_P | PTE_U;
	if((uintptr_t)srcva<UTOP){
		if(PGOFF(srcva))return -E_INVAL;
f0104bfb:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c00:	e9 81 00 00 00       	jmp    f0104c86 <syscall+0x644>
		if ((perm & ~(PTE_SYSCALL)) || ((perm & flag) != flag))return -E_INVAL;
f0104c05:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c0a:	eb 7a                	jmp    f0104c86 <syscall+0x644>
f0104c0c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c11:	eb 73                	jmp    f0104c86 <syscall+0x644>
		if (user_mem_check(curenv, (const void *)srcva, PGSIZE, PTE_U) < 0)
            return -E_INVAL;
f0104c13:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c18:	eb 6c                	jmp    f0104c86 <syscall+0x644>
		if (perm& PTE_W&&user_mem_check(curenv, (const void *)srcva, PGSIZE, PTE_U |PTE_W) < 0)
            return -E_INVAL;
f0104c1a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c1f:	eb 65                	jmp    f0104c86 <syscall+0x644>
		if((uintptr_t)(env->env_ipc_dstva)<UTOP){
			env->env_ipc_perm=perm;
			struct PageInfo *pi = page_lookup(curenv->env_pgdir, srcva, 0);
			if (page_insert(env->env_pgdir, pi, env->env_ipc_dstva,  perm) < 0)
                return -E_NO_MEM; 
f0104c21:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
       	case SYS_page_unmap:
           	return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1,(void *)a2);
		case SYS_ipc_try_send:                                                                                          
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);                               
f0104c26:	eb 5e                	jmp    f0104c86 <syscall+0x644>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if((dstva < (void *)UTOP) && PGOFF(dstva))
f0104c28:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104c2f:	77 09                	ja     f0104c3a <syscall+0x5f8>
f0104c31:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104c38:	75 47                	jne    f0104c81 <syscall+0x63f>
        return -E_INVAL;
	curenv->env_ipc_recving = true; 
f0104c3a:	e8 47 11 00 00       	call   f0105d86 <cpunum>
f0104c3f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c42:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104c48:	c6 40 68 01          	movb   $0x1,0x68(%eax)
    curenv->env_ipc_dstva = dstva;
f0104c4c:	e8 35 11 00 00       	call   f0105d86 <cpunum>
f0104c51:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c54:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104c5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104c5d:	89 48 6c             	mov    %ecx,0x6c(%eax)
    curenv->env_status = ENV_NOT_RUNNABLE;
f0104c60:	e8 21 11 00 00       	call   f0105d86 <cpunum>
f0104c65:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c68:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104c6e:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
    sched_yield();
f0104c75:	e8 e8 f8 ff ff       	call   f0104562 <sched_yield>
		case SYS_ipc_try_send:                                                                                          
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);                               
		case SYS_ipc_recv:                                                                                              
			return sys_ipc_recv((void *)a1);
        default:
            return -E_INVAL;
f0104c7a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c7f:	eb 05                	jmp    f0104c86 <syscall+0x644>
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1,(void *)a2);
		case SYS_ipc_try_send:                                                                                          
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);                               
		case SYS_ipc_recv:                                                                                              
			return sys_ipc_recv((void *)a1);
f0104c81:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
        default:
            return -E_INVAL;
    }
}
f0104c86:	89 d8                	mov    %ebx,%eax
f0104c88:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104c8b:	5b                   	pop    %ebx
f0104c8c:	5e                   	pop    %esi
f0104c8d:	5f                   	pop    %edi
f0104c8e:	5d                   	pop    %ebp
f0104c8f:	c3                   	ret    

f0104c90 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104c90:	55                   	push   %ebp
f0104c91:	89 e5                	mov    %esp,%ebp
f0104c93:	57                   	push   %edi
f0104c94:	56                   	push   %esi
f0104c95:	53                   	push   %ebx
f0104c96:	83 ec 14             	sub    $0x14,%esp
f0104c99:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104c9c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104c9f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104ca2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104ca5:	8b 1a                	mov    (%edx),%ebx
f0104ca7:	8b 01                	mov    (%ecx),%eax
f0104ca9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104cac:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104cb3:	eb 7f                	jmp    f0104d34 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104cb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104cb8:	01 d8                	add    %ebx,%eax
f0104cba:	89 c6                	mov    %eax,%esi
f0104cbc:	c1 ee 1f             	shr    $0x1f,%esi
f0104cbf:	01 c6                	add    %eax,%esi
f0104cc1:	d1 fe                	sar    %esi
f0104cc3:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104cc6:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104cc9:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104ccc:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104cce:	eb 03                	jmp    f0104cd3 <stab_binsearch+0x43>
			m--;
f0104cd0:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104cd3:	39 c3                	cmp    %eax,%ebx
f0104cd5:	7f 0d                	jg     f0104ce4 <stab_binsearch+0x54>
f0104cd7:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104cdb:	83 ea 0c             	sub    $0xc,%edx
f0104cde:	39 f9                	cmp    %edi,%ecx
f0104ce0:	75 ee                	jne    f0104cd0 <stab_binsearch+0x40>
f0104ce2:	eb 05                	jmp    f0104ce9 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104ce4:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104ce7:	eb 4b                	jmp    f0104d34 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104ce9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104cec:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104cef:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104cf3:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104cf6:	76 11                	jbe    f0104d09 <stab_binsearch+0x79>
			*region_left = m;
f0104cf8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104cfb:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104cfd:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104d00:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104d07:	eb 2b                	jmp    f0104d34 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104d09:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104d0c:	73 14                	jae    f0104d22 <stab_binsearch+0x92>
			*region_right = m - 1;
f0104d0e:	83 e8 01             	sub    $0x1,%eax
f0104d11:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104d14:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104d17:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104d19:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104d20:	eb 12                	jmp    f0104d34 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104d22:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104d25:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104d27:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104d2b:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104d2d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104d34:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104d37:	0f 8e 78 ff ff ff    	jle    f0104cb5 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104d3d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104d41:	75 0f                	jne    f0104d52 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104d43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d46:	8b 00                	mov    (%eax),%eax
f0104d48:	83 e8 01             	sub    $0x1,%eax
f0104d4b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104d4e:	89 06                	mov    %eax,(%esi)
f0104d50:	eb 2c                	jmp    f0104d7e <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d52:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d55:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104d57:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104d5a:	8b 0e                	mov    (%esi),%ecx
f0104d5c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104d5f:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104d62:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d65:	eb 03                	jmp    f0104d6a <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104d67:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d6a:	39 c8                	cmp    %ecx,%eax
f0104d6c:	7e 0b                	jle    f0104d79 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104d6e:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104d72:	83 ea 0c             	sub    $0xc,%edx
f0104d75:	39 df                	cmp    %ebx,%edi
f0104d77:	75 ee                	jne    f0104d67 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104d79:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104d7c:	89 06                	mov    %eax,(%esi)
	}
}
f0104d7e:	83 c4 14             	add    $0x14,%esp
f0104d81:	5b                   	pop    %ebx
f0104d82:	5e                   	pop    %esi
f0104d83:	5f                   	pop    %edi
f0104d84:	5d                   	pop    %ebp
f0104d85:	c3                   	ret    

f0104d86 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104d86:	55                   	push   %ebp
f0104d87:	89 e5                	mov    %esp,%ebp
f0104d89:	57                   	push   %edi
f0104d8a:	56                   	push   %esi
f0104d8b:	53                   	push   %ebx
f0104d8c:	83 ec 2c             	sub    $0x2c,%esp
f0104d8f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104d92:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104d95:	c7 06 60 7c 10 f0    	movl   $0xf0107c60,(%esi)
	info->eip_line = 0;
f0104d9b:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0104da2:	c7 46 08 60 7c 10 f0 	movl   $0xf0107c60,0x8(%esi)
	info->eip_fn_namelen = 9;
f0104da9:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0104db0:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0104db3:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104dba:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104dc0:	77 21                	ja     f0104de3 <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104dc2:	a1 00 00 20 00       	mov    0x200000,%eax
f0104dc7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f0104dca:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104dcf:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f0104dd5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f0104dd8:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f0104dde:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0104de1:	eb 1a                	jmp    f0104dfd <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104de3:	c7 45 d0 cf 58 11 f0 	movl   $0xf01158cf,-0x30(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104dea:	c7 45 cc 69 22 11 f0 	movl   $0xf0112269,-0x34(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104df1:	b8 68 22 11 f0       	mov    $0xf0112268,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104df6:	c7 45 d4 34 81 10 f0 	movl   $0xf0108134,-0x2c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104dfd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104e00:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f0104e03:	0f 83 2b 01 00 00    	jae    f0104f34 <debuginfo_eip+0x1ae>
f0104e09:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104e0d:	0f 85 28 01 00 00    	jne    f0104f3b <debuginfo_eip+0x1b5>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104e13:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104e1a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104e1d:	29 d8                	sub    %ebx,%eax
f0104e1f:	c1 f8 02             	sar    $0x2,%eax
f0104e22:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104e28:	83 e8 01             	sub    $0x1,%eax
f0104e2b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104e2e:	57                   	push   %edi
f0104e2f:	6a 64                	push   $0x64
f0104e31:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104e34:	89 c1                	mov    %eax,%ecx
f0104e36:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104e39:	89 d8                	mov    %ebx,%eax
f0104e3b:	e8 50 fe ff ff       	call   f0104c90 <stab_binsearch>
	if (lfile == 0)
f0104e40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e43:	83 c4 08             	add    $0x8,%esp
f0104e46:	85 c0                	test   %eax,%eax
f0104e48:	0f 84 f4 00 00 00    	je     f0104f42 <debuginfo_eip+0x1bc>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104e4e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104e51:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e54:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104e57:	57                   	push   %edi
f0104e58:	6a 24                	push   $0x24
f0104e5a:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0104e5d:	89 c1                	mov    %eax,%ecx
f0104e5f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104e62:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0104e65:	89 d8                	mov    %ebx,%eax
f0104e67:	e8 24 fe ff ff       	call   f0104c90 <stab_binsearch>

	if (lfun <= rfun) {
f0104e6c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104e6f:	83 c4 08             	add    $0x8,%esp
f0104e72:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0104e75:	7f 24                	jg     f0104e9b <debuginfo_eip+0x115>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104e77:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104e7a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104e7d:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104e80:	8b 02                	mov    (%edx),%eax
f0104e82:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104e85:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104e88:	29 f9                	sub    %edi,%ecx
f0104e8a:	39 c8                	cmp    %ecx,%eax
f0104e8c:	73 05                	jae    f0104e93 <debuginfo_eip+0x10d>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104e8e:	01 f8                	add    %edi,%eax
f0104e90:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104e93:	8b 42 08             	mov    0x8(%edx),%eax
f0104e96:	89 46 10             	mov    %eax,0x10(%esi)
f0104e99:	eb 06                	jmp    f0104ea1 <debuginfo_eip+0x11b>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104e9b:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0104e9e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104ea1:	83 ec 08             	sub    $0x8,%esp
f0104ea4:	6a 3a                	push   $0x3a
f0104ea6:	ff 76 08             	pushl  0x8(%esi)
f0104ea9:	e8 9a 08 00 00       	call   f0105748 <strfind>
f0104eae:	2b 46 08             	sub    0x8(%esi),%eax
f0104eb1:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104eb4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104eb7:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104eba:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104ebd:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0104ec0:	83 c4 10             	add    $0x10,%esp
f0104ec3:	eb 06                	jmp    f0104ecb <debuginfo_eip+0x145>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104ec5:	83 eb 01             	sub    $0x1,%ebx
f0104ec8:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104ecb:	39 fb                	cmp    %edi,%ebx
f0104ecd:	7c 2d                	jl     f0104efc <debuginfo_eip+0x176>
	       && stabs[lline].n_type != N_SOL
f0104ecf:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0104ed3:	80 fa 84             	cmp    $0x84,%dl
f0104ed6:	74 0b                	je     f0104ee3 <debuginfo_eip+0x15d>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104ed8:	80 fa 64             	cmp    $0x64,%dl
f0104edb:	75 e8                	jne    f0104ec5 <debuginfo_eip+0x13f>
f0104edd:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0104ee1:	74 e2                	je     f0104ec5 <debuginfo_eip+0x13f>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104ee3:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104ee6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104ee9:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104eec:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104eef:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104ef2:	29 f8                	sub    %edi,%eax
f0104ef4:	39 c2                	cmp    %eax,%edx
f0104ef6:	73 04                	jae    f0104efc <debuginfo_eip+0x176>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104ef8:	01 fa                	add    %edi,%edx
f0104efa:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104efc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104eff:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f02:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104f07:	39 cb                	cmp    %ecx,%ebx
f0104f09:	7d 43                	jge    f0104f4e <debuginfo_eip+0x1c8>
		for (lline = lfun + 1;
f0104f0b:	8d 53 01             	lea    0x1(%ebx),%edx
f0104f0e:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104f11:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104f14:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0104f17:	eb 07                	jmp    f0104f20 <debuginfo_eip+0x19a>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104f19:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0104f1d:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104f20:	39 ca                	cmp    %ecx,%edx
f0104f22:	74 25                	je     f0104f49 <debuginfo_eip+0x1c3>
f0104f24:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104f27:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0104f2b:	74 ec                	je     f0104f19 <debuginfo_eip+0x193>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f2d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f32:	eb 1a                	jmp    f0104f4e <debuginfo_eip+0x1c8>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104f34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f39:	eb 13                	jmp    f0104f4e <debuginfo_eip+0x1c8>
f0104f3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f40:	eb 0c                	jmp    f0104f4e <debuginfo_eip+0x1c8>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104f42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f47:	eb 05                	jmp    f0104f4e <debuginfo_eip+0x1c8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f49:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104f4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f51:	5b                   	pop    %ebx
f0104f52:	5e                   	pop    %esi
f0104f53:	5f                   	pop    %edi
f0104f54:	5d                   	pop    %ebp
f0104f55:	c3                   	ret    

f0104f56 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104f56:	55                   	push   %ebp
f0104f57:	89 e5                	mov    %esp,%ebp
f0104f59:	57                   	push   %edi
f0104f5a:	56                   	push   %esi
f0104f5b:	53                   	push   %ebx
f0104f5c:	83 ec 1c             	sub    $0x1c,%esp
f0104f5f:	89 c7                	mov    %eax,%edi
f0104f61:	89 d6                	mov    %edx,%esi
f0104f63:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f66:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104f69:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f6c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104f6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104f72:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104f77:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104f7a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104f7d:	39 d3                	cmp    %edx,%ebx
f0104f7f:	72 05                	jb     f0104f86 <printnum+0x30>
f0104f81:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104f84:	77 45                	ja     f0104fcb <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104f86:	83 ec 0c             	sub    $0xc,%esp
f0104f89:	ff 75 18             	pushl  0x18(%ebp)
f0104f8c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f8f:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104f92:	53                   	push   %ebx
f0104f93:	ff 75 10             	pushl  0x10(%ebp)
f0104f96:	83 ec 08             	sub    $0x8,%esp
f0104f99:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104f9c:	ff 75 e0             	pushl  -0x20(%ebp)
f0104f9f:	ff 75 dc             	pushl  -0x24(%ebp)
f0104fa2:	ff 75 d8             	pushl  -0x28(%ebp)
f0104fa5:	e8 d6 11 00 00       	call   f0106180 <__udivdi3>
f0104faa:	83 c4 18             	add    $0x18,%esp
f0104fad:	52                   	push   %edx
f0104fae:	50                   	push   %eax
f0104faf:	89 f2                	mov    %esi,%edx
f0104fb1:	89 f8                	mov    %edi,%eax
f0104fb3:	e8 9e ff ff ff       	call   f0104f56 <printnum>
f0104fb8:	83 c4 20             	add    $0x20,%esp
f0104fbb:	eb 18                	jmp    f0104fd5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104fbd:	83 ec 08             	sub    $0x8,%esp
f0104fc0:	56                   	push   %esi
f0104fc1:	ff 75 18             	pushl  0x18(%ebp)
f0104fc4:	ff d7                	call   *%edi
f0104fc6:	83 c4 10             	add    $0x10,%esp
f0104fc9:	eb 03                	jmp    f0104fce <printnum+0x78>
f0104fcb:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104fce:	83 eb 01             	sub    $0x1,%ebx
f0104fd1:	85 db                	test   %ebx,%ebx
f0104fd3:	7f e8                	jg     f0104fbd <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104fd5:	83 ec 08             	sub    $0x8,%esp
f0104fd8:	56                   	push   %esi
f0104fd9:	83 ec 04             	sub    $0x4,%esp
f0104fdc:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104fdf:	ff 75 e0             	pushl  -0x20(%ebp)
f0104fe2:	ff 75 dc             	pushl  -0x24(%ebp)
f0104fe5:	ff 75 d8             	pushl  -0x28(%ebp)
f0104fe8:	e8 c3 12 00 00       	call   f01062b0 <__umoddi3>
f0104fed:	83 c4 14             	add    $0x14,%esp
f0104ff0:	0f be 80 6a 7c 10 f0 	movsbl -0xfef8396(%eax),%eax
f0104ff7:	50                   	push   %eax
f0104ff8:	ff d7                	call   *%edi
}
f0104ffa:	83 c4 10             	add    $0x10,%esp
f0104ffd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105000:	5b                   	pop    %ebx
f0105001:	5e                   	pop    %esi
f0105002:	5f                   	pop    %edi
f0105003:	5d                   	pop    %ebp
f0105004:	c3                   	ret    

f0105005 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105005:	55                   	push   %ebp
f0105006:	89 e5                	mov    %esp,%ebp
f0105008:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010500b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010500f:	8b 10                	mov    (%eax),%edx
f0105011:	3b 50 04             	cmp    0x4(%eax),%edx
f0105014:	73 0a                	jae    f0105020 <sprintputch+0x1b>
		*b->buf++ = ch;
f0105016:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105019:	89 08                	mov    %ecx,(%eax)
f010501b:	8b 45 08             	mov    0x8(%ebp),%eax
f010501e:	88 02                	mov    %al,(%edx)
}
f0105020:	5d                   	pop    %ebp
f0105021:	c3                   	ret    

f0105022 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105022:	55                   	push   %ebp
f0105023:	89 e5                	mov    %esp,%ebp
f0105025:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0105028:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010502b:	50                   	push   %eax
f010502c:	ff 75 10             	pushl  0x10(%ebp)
f010502f:	ff 75 0c             	pushl  0xc(%ebp)
f0105032:	ff 75 08             	pushl  0x8(%ebp)
f0105035:	e8 05 00 00 00       	call   f010503f <vprintfmt>
	va_end(ap);
}
f010503a:	83 c4 10             	add    $0x10,%esp
f010503d:	c9                   	leave  
f010503e:	c3                   	ret    

f010503f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010503f:	55                   	push   %ebp
f0105040:	89 e5                	mov    %esp,%ebp
f0105042:	57                   	push   %edi
f0105043:	56                   	push   %esi
f0105044:	53                   	push   %ebx
f0105045:	83 ec 2c             	sub    $0x2c,%esp
f0105048:	8b 75 08             	mov    0x8(%ebp),%esi
f010504b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010504e:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105051:	eb 12                	jmp    f0105065 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105053:	85 c0                	test   %eax,%eax
f0105055:	0f 84 42 04 00 00    	je     f010549d <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
f010505b:	83 ec 08             	sub    $0x8,%esp
f010505e:	53                   	push   %ebx
f010505f:	50                   	push   %eax
f0105060:	ff d6                	call   *%esi
f0105062:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105065:	83 c7 01             	add    $0x1,%edi
f0105068:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010506c:	83 f8 25             	cmp    $0x25,%eax
f010506f:	75 e2                	jne    f0105053 <vprintfmt+0x14>
f0105071:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0105075:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f010507c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105083:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f010508a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010508f:	eb 07                	jmp    f0105098 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105091:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105094:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105098:	8d 47 01             	lea    0x1(%edi),%eax
f010509b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010509e:	0f b6 07             	movzbl (%edi),%eax
f01050a1:	0f b6 d0             	movzbl %al,%edx
f01050a4:	83 e8 23             	sub    $0x23,%eax
f01050a7:	3c 55                	cmp    $0x55,%al
f01050a9:	0f 87 d3 03 00 00    	ja     f0105482 <vprintfmt+0x443>
f01050af:	0f b6 c0             	movzbl %al,%eax
f01050b2:	ff 24 85 20 7d 10 f0 	jmp    *-0xfef82e0(,%eax,4)
f01050b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01050bc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01050c0:	eb d6                	jmp    f0105098 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01050c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01050ca:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01050cd:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01050d0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f01050d4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f01050d7:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01050da:	83 f9 09             	cmp    $0x9,%ecx
f01050dd:	77 3f                	ja     f010511e <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01050df:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01050e2:	eb e9                	jmp    f01050cd <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01050e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01050e7:	8b 00                	mov    (%eax),%eax
f01050e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01050ec:	8b 45 14             	mov    0x14(%ebp),%eax
f01050ef:	8d 40 04             	lea    0x4(%eax),%eax
f01050f2:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01050f8:	eb 2a                	jmp    f0105124 <vprintfmt+0xe5>
f01050fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01050fd:	85 c0                	test   %eax,%eax
f01050ff:	ba 00 00 00 00       	mov    $0x0,%edx
f0105104:	0f 49 d0             	cmovns %eax,%edx
f0105107:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010510a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010510d:	eb 89                	jmp    f0105098 <vprintfmt+0x59>
f010510f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105112:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0105119:	e9 7a ff ff ff       	jmp    f0105098 <vprintfmt+0x59>
f010511e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105121:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0105124:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105128:	0f 89 6a ff ff ff    	jns    f0105098 <vprintfmt+0x59>
				width = precision, precision = -1;
f010512e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105131:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105134:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010513b:	e9 58 ff ff ff       	jmp    f0105098 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105140:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105143:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105146:	e9 4d ff ff ff       	jmp    f0105098 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010514b:	8b 45 14             	mov    0x14(%ebp),%eax
f010514e:	8d 78 04             	lea    0x4(%eax),%edi
f0105151:	83 ec 08             	sub    $0x8,%esp
f0105154:	53                   	push   %ebx
f0105155:	ff 30                	pushl  (%eax)
f0105157:	ff d6                	call   *%esi
			break;
f0105159:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010515c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010515f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105162:	e9 fe fe ff ff       	jmp    f0105065 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105167:	8b 45 14             	mov    0x14(%ebp),%eax
f010516a:	8d 78 04             	lea    0x4(%eax),%edi
f010516d:	8b 00                	mov    (%eax),%eax
f010516f:	99                   	cltd   
f0105170:	31 d0                	xor    %edx,%eax
f0105172:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105174:	83 f8 08             	cmp    $0x8,%eax
f0105177:	7f 0b                	jg     f0105184 <vprintfmt+0x145>
f0105179:	8b 14 85 80 7e 10 f0 	mov    -0xfef8180(,%eax,4),%edx
f0105180:	85 d2                	test   %edx,%edx
f0105182:	75 1b                	jne    f010519f <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
f0105184:	50                   	push   %eax
f0105185:	68 82 7c 10 f0       	push   $0xf0107c82
f010518a:	53                   	push   %ebx
f010518b:	56                   	push   %esi
f010518c:	e8 91 fe ff ff       	call   f0105022 <printfmt>
f0105191:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105194:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105197:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f010519a:	e9 c6 fe ff ff       	jmp    f0105065 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f010519f:	52                   	push   %edx
f01051a0:	68 84 69 10 f0       	push   $0xf0106984
f01051a5:	53                   	push   %ebx
f01051a6:	56                   	push   %esi
f01051a7:	e8 76 fe ff ff       	call   f0105022 <printfmt>
f01051ac:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f01051af:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051b5:	e9 ab fe ff ff       	jmp    f0105065 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01051ba:	8b 45 14             	mov    0x14(%ebp),%eax
f01051bd:	83 c0 04             	add    $0x4,%eax
f01051c0:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01051c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01051c6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01051c8:	85 ff                	test   %edi,%edi
f01051ca:	b8 7b 7c 10 f0       	mov    $0xf0107c7b,%eax
f01051cf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f01051d2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01051d6:	0f 8e 94 00 00 00    	jle    f0105270 <vprintfmt+0x231>
f01051dc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01051e0:	0f 84 98 00 00 00    	je     f010527e <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
f01051e6:	83 ec 08             	sub    $0x8,%esp
f01051e9:	ff 75 d0             	pushl  -0x30(%ebp)
f01051ec:	57                   	push   %edi
f01051ed:	e8 0c 04 00 00       	call   f01055fe <strnlen>
f01051f2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01051f5:	29 c1                	sub    %eax,%ecx
f01051f7:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f01051fa:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f01051fd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105201:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105204:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105207:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105209:	eb 0f                	jmp    f010521a <vprintfmt+0x1db>
					putch(padc, putdat);
f010520b:	83 ec 08             	sub    $0x8,%esp
f010520e:	53                   	push   %ebx
f010520f:	ff 75 e0             	pushl  -0x20(%ebp)
f0105212:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105214:	83 ef 01             	sub    $0x1,%edi
f0105217:	83 c4 10             	add    $0x10,%esp
f010521a:	85 ff                	test   %edi,%edi
f010521c:	7f ed                	jg     f010520b <vprintfmt+0x1cc>
f010521e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105221:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0105224:	85 c9                	test   %ecx,%ecx
f0105226:	b8 00 00 00 00       	mov    $0x0,%eax
f010522b:	0f 49 c1             	cmovns %ecx,%eax
f010522e:	29 c1                	sub    %eax,%ecx
f0105230:	89 75 08             	mov    %esi,0x8(%ebp)
f0105233:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105236:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105239:	89 cb                	mov    %ecx,%ebx
f010523b:	eb 4d                	jmp    f010528a <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010523d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105241:	74 1b                	je     f010525e <vprintfmt+0x21f>
f0105243:	0f be c0             	movsbl %al,%eax
f0105246:	83 e8 20             	sub    $0x20,%eax
f0105249:	83 f8 5e             	cmp    $0x5e,%eax
f010524c:	76 10                	jbe    f010525e <vprintfmt+0x21f>
					putch('?', putdat);
f010524e:	83 ec 08             	sub    $0x8,%esp
f0105251:	ff 75 0c             	pushl  0xc(%ebp)
f0105254:	6a 3f                	push   $0x3f
f0105256:	ff 55 08             	call   *0x8(%ebp)
f0105259:	83 c4 10             	add    $0x10,%esp
f010525c:	eb 0d                	jmp    f010526b <vprintfmt+0x22c>
				else
					putch(ch, putdat);
f010525e:	83 ec 08             	sub    $0x8,%esp
f0105261:	ff 75 0c             	pushl  0xc(%ebp)
f0105264:	52                   	push   %edx
f0105265:	ff 55 08             	call   *0x8(%ebp)
f0105268:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010526b:	83 eb 01             	sub    $0x1,%ebx
f010526e:	eb 1a                	jmp    f010528a <vprintfmt+0x24b>
f0105270:	89 75 08             	mov    %esi,0x8(%ebp)
f0105273:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105276:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105279:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010527c:	eb 0c                	jmp    f010528a <vprintfmt+0x24b>
f010527e:	89 75 08             	mov    %esi,0x8(%ebp)
f0105281:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105284:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105287:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010528a:	83 c7 01             	add    $0x1,%edi
f010528d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105291:	0f be d0             	movsbl %al,%edx
f0105294:	85 d2                	test   %edx,%edx
f0105296:	74 23                	je     f01052bb <vprintfmt+0x27c>
f0105298:	85 f6                	test   %esi,%esi
f010529a:	78 a1                	js     f010523d <vprintfmt+0x1fe>
f010529c:	83 ee 01             	sub    $0x1,%esi
f010529f:	79 9c                	jns    f010523d <vprintfmt+0x1fe>
f01052a1:	89 df                	mov    %ebx,%edi
f01052a3:	8b 75 08             	mov    0x8(%ebp),%esi
f01052a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01052a9:	eb 18                	jmp    f01052c3 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01052ab:	83 ec 08             	sub    $0x8,%esp
f01052ae:	53                   	push   %ebx
f01052af:	6a 20                	push   $0x20
f01052b1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01052b3:	83 ef 01             	sub    $0x1,%edi
f01052b6:	83 c4 10             	add    $0x10,%esp
f01052b9:	eb 08                	jmp    f01052c3 <vprintfmt+0x284>
f01052bb:	89 df                	mov    %ebx,%edi
f01052bd:	8b 75 08             	mov    0x8(%ebp),%esi
f01052c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01052c3:	85 ff                	test   %edi,%edi
f01052c5:	7f e4                	jg     f01052ab <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01052c7:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01052ca:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01052d0:	e9 90 fd ff ff       	jmp    f0105065 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01052d5:	83 f9 01             	cmp    $0x1,%ecx
f01052d8:	7e 19                	jle    f01052f3 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
f01052da:	8b 45 14             	mov    0x14(%ebp),%eax
f01052dd:	8b 50 04             	mov    0x4(%eax),%edx
f01052e0:	8b 00                	mov    (%eax),%eax
f01052e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01052e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01052e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01052eb:	8d 40 08             	lea    0x8(%eax),%eax
f01052ee:	89 45 14             	mov    %eax,0x14(%ebp)
f01052f1:	eb 38                	jmp    f010532b <vprintfmt+0x2ec>
	else if (lflag)
f01052f3:	85 c9                	test   %ecx,%ecx
f01052f5:	74 1b                	je     f0105312 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
f01052f7:	8b 45 14             	mov    0x14(%ebp),%eax
f01052fa:	8b 00                	mov    (%eax),%eax
f01052fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01052ff:	89 c1                	mov    %eax,%ecx
f0105301:	c1 f9 1f             	sar    $0x1f,%ecx
f0105304:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105307:	8b 45 14             	mov    0x14(%ebp),%eax
f010530a:	8d 40 04             	lea    0x4(%eax),%eax
f010530d:	89 45 14             	mov    %eax,0x14(%ebp)
f0105310:	eb 19                	jmp    f010532b <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f0105312:	8b 45 14             	mov    0x14(%ebp),%eax
f0105315:	8b 00                	mov    (%eax),%eax
f0105317:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010531a:	89 c1                	mov    %eax,%ecx
f010531c:	c1 f9 1f             	sar    $0x1f,%ecx
f010531f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105322:	8b 45 14             	mov    0x14(%ebp),%eax
f0105325:	8d 40 04             	lea    0x4(%eax),%eax
f0105328:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010532b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010532e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105331:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105336:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010533a:	0f 89 0e 01 00 00    	jns    f010544e <vprintfmt+0x40f>
				putch('-', putdat);
f0105340:	83 ec 08             	sub    $0x8,%esp
f0105343:	53                   	push   %ebx
f0105344:	6a 2d                	push   $0x2d
f0105346:	ff d6                	call   *%esi
				num = -(long long) num;
f0105348:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010534b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010534e:	f7 da                	neg    %edx
f0105350:	83 d1 00             	adc    $0x0,%ecx
f0105353:	f7 d9                	neg    %ecx
f0105355:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0105358:	b8 0a 00 00 00       	mov    $0xa,%eax
f010535d:	e9 ec 00 00 00       	jmp    f010544e <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105362:	83 f9 01             	cmp    $0x1,%ecx
f0105365:	7e 18                	jle    f010537f <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
f0105367:	8b 45 14             	mov    0x14(%ebp),%eax
f010536a:	8b 10                	mov    (%eax),%edx
f010536c:	8b 48 04             	mov    0x4(%eax),%ecx
f010536f:	8d 40 08             	lea    0x8(%eax),%eax
f0105372:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0105375:	b8 0a 00 00 00       	mov    $0xa,%eax
f010537a:	e9 cf 00 00 00       	jmp    f010544e <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f010537f:	85 c9                	test   %ecx,%ecx
f0105381:	74 1a                	je     f010539d <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
f0105383:	8b 45 14             	mov    0x14(%ebp),%eax
f0105386:	8b 10                	mov    (%eax),%edx
f0105388:	b9 00 00 00 00       	mov    $0x0,%ecx
f010538d:	8d 40 04             	lea    0x4(%eax),%eax
f0105390:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0105393:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105398:	e9 b1 00 00 00       	jmp    f010544e <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f010539d:	8b 45 14             	mov    0x14(%ebp),%eax
f01053a0:	8b 10                	mov    (%eax),%edx
f01053a2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01053a7:	8d 40 04             	lea    0x4(%eax),%eax
f01053aa:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f01053ad:	b8 0a 00 00 00       	mov    $0xa,%eax
f01053b2:	e9 97 00 00 00       	jmp    f010544e <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f01053b7:	83 ec 08             	sub    $0x8,%esp
f01053ba:	53                   	push   %ebx
f01053bb:	6a 58                	push   $0x58
f01053bd:	ff d6                	call   *%esi
			putch('X', putdat);
f01053bf:	83 c4 08             	add    $0x8,%esp
f01053c2:	53                   	push   %ebx
f01053c3:	6a 58                	push   $0x58
f01053c5:	ff d6                	call   *%esi
			putch('X', putdat);
f01053c7:	83 c4 08             	add    $0x8,%esp
f01053ca:	53                   	push   %ebx
f01053cb:	6a 58                	push   $0x58
f01053cd:	ff d6                	call   *%esi
			break;
f01053cf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01053d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f01053d5:	e9 8b fc ff ff       	jmp    f0105065 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
f01053da:	83 ec 08             	sub    $0x8,%esp
f01053dd:	53                   	push   %ebx
f01053de:	6a 30                	push   $0x30
f01053e0:	ff d6                	call   *%esi
			putch('x', putdat);
f01053e2:	83 c4 08             	add    $0x8,%esp
f01053e5:	53                   	push   %ebx
f01053e6:	6a 78                	push   $0x78
f01053e8:	ff d6                	call   *%esi
			num = (unsigned long long)
f01053ea:	8b 45 14             	mov    0x14(%ebp),%eax
f01053ed:	8b 10                	mov    (%eax),%edx
f01053ef:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01053f4:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01053f7:	8d 40 04             	lea    0x4(%eax),%eax
f01053fa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01053fd:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0105402:	eb 4a                	jmp    f010544e <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105404:	83 f9 01             	cmp    $0x1,%ecx
f0105407:	7e 15                	jle    f010541e <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
f0105409:	8b 45 14             	mov    0x14(%ebp),%eax
f010540c:	8b 10                	mov    (%eax),%edx
f010540e:	8b 48 04             	mov    0x4(%eax),%ecx
f0105411:	8d 40 08             	lea    0x8(%eax),%eax
f0105414:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0105417:	b8 10 00 00 00       	mov    $0x10,%eax
f010541c:	eb 30                	jmp    f010544e <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f010541e:	85 c9                	test   %ecx,%ecx
f0105420:	74 17                	je     f0105439 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
f0105422:	8b 45 14             	mov    0x14(%ebp),%eax
f0105425:	8b 10                	mov    (%eax),%edx
f0105427:	b9 00 00 00 00       	mov    $0x0,%ecx
f010542c:	8d 40 04             	lea    0x4(%eax),%eax
f010542f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0105432:	b8 10 00 00 00       	mov    $0x10,%eax
f0105437:	eb 15                	jmp    f010544e <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0105439:	8b 45 14             	mov    0x14(%ebp),%eax
f010543c:	8b 10                	mov    (%eax),%edx
f010543e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105443:	8d 40 04             	lea    0x4(%eax),%eax
f0105446:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0105449:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f010544e:	83 ec 0c             	sub    $0xc,%esp
f0105451:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105455:	57                   	push   %edi
f0105456:	ff 75 e0             	pushl  -0x20(%ebp)
f0105459:	50                   	push   %eax
f010545a:	51                   	push   %ecx
f010545b:	52                   	push   %edx
f010545c:	89 da                	mov    %ebx,%edx
f010545e:	89 f0                	mov    %esi,%eax
f0105460:	e8 f1 fa ff ff       	call   f0104f56 <printnum>
			break;
f0105465:	83 c4 20             	add    $0x20,%esp
f0105468:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010546b:	e9 f5 fb ff ff       	jmp    f0105065 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105470:	83 ec 08             	sub    $0x8,%esp
f0105473:	53                   	push   %ebx
f0105474:	52                   	push   %edx
f0105475:	ff d6                	call   *%esi
			break;
f0105477:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010547a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010547d:	e9 e3 fb ff ff       	jmp    f0105065 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105482:	83 ec 08             	sub    $0x8,%esp
f0105485:	53                   	push   %ebx
f0105486:	6a 25                	push   $0x25
f0105488:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010548a:	83 c4 10             	add    $0x10,%esp
f010548d:	eb 03                	jmp    f0105492 <vprintfmt+0x453>
f010548f:	83 ef 01             	sub    $0x1,%edi
f0105492:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105496:	75 f7                	jne    f010548f <vprintfmt+0x450>
f0105498:	e9 c8 fb ff ff       	jmp    f0105065 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f010549d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01054a0:	5b                   	pop    %ebx
f01054a1:	5e                   	pop    %esi
f01054a2:	5f                   	pop    %edi
f01054a3:	5d                   	pop    %ebp
f01054a4:	c3                   	ret    

f01054a5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01054a5:	55                   	push   %ebp
f01054a6:	89 e5                	mov    %esp,%ebp
f01054a8:	83 ec 18             	sub    $0x18,%esp
f01054ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01054ae:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01054b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01054b4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01054b8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01054bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01054c2:	85 c0                	test   %eax,%eax
f01054c4:	74 26                	je     f01054ec <vsnprintf+0x47>
f01054c6:	85 d2                	test   %edx,%edx
f01054c8:	7e 22                	jle    f01054ec <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01054ca:	ff 75 14             	pushl  0x14(%ebp)
f01054cd:	ff 75 10             	pushl  0x10(%ebp)
f01054d0:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01054d3:	50                   	push   %eax
f01054d4:	68 05 50 10 f0       	push   $0xf0105005
f01054d9:	e8 61 fb ff ff       	call   f010503f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01054de:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01054e1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01054e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01054e7:	83 c4 10             	add    $0x10,%esp
f01054ea:	eb 05                	jmp    f01054f1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01054ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01054f1:	c9                   	leave  
f01054f2:	c3                   	ret    

f01054f3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01054f3:	55                   	push   %ebp
f01054f4:	89 e5                	mov    %esp,%ebp
f01054f6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01054f9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01054fc:	50                   	push   %eax
f01054fd:	ff 75 10             	pushl  0x10(%ebp)
f0105500:	ff 75 0c             	pushl  0xc(%ebp)
f0105503:	ff 75 08             	pushl  0x8(%ebp)
f0105506:	e8 9a ff ff ff       	call   f01054a5 <vsnprintf>
	va_end(ap);

	return rc;
}
f010550b:	c9                   	leave  
f010550c:	c3                   	ret    

f010550d <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010550d:	55                   	push   %ebp
f010550e:	89 e5                	mov    %esp,%ebp
f0105510:	57                   	push   %edi
f0105511:	56                   	push   %esi
f0105512:	53                   	push   %ebx
f0105513:	83 ec 0c             	sub    $0xc,%esp
f0105516:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105519:	85 c0                	test   %eax,%eax
f010551b:	74 11                	je     f010552e <readline+0x21>
		cprintf("%s", prompt);
f010551d:	83 ec 08             	sub    $0x8,%esp
f0105520:	50                   	push   %eax
f0105521:	68 84 69 10 f0       	push   $0xf0106984
f0105526:	e8 37 e2 ff ff       	call   f0103762 <cprintf>
f010552b:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010552e:	83 ec 0c             	sub    $0xc,%esp
f0105531:	6a 00                	push   $0x0
f0105533:	e8 36 b2 ff ff       	call   f010076e <iscons>
f0105538:	89 c7                	mov    %eax,%edi
f010553a:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010553d:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105542:	e8 16 b2 ff ff       	call   f010075d <getchar>
f0105547:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105549:	85 c0                	test   %eax,%eax
f010554b:	79 18                	jns    f0105565 <readline+0x58>
			cprintf("read error: %e\n", c);
f010554d:	83 ec 08             	sub    $0x8,%esp
f0105550:	50                   	push   %eax
f0105551:	68 a4 7e 10 f0       	push   $0xf0107ea4
f0105556:	e8 07 e2 ff ff       	call   f0103762 <cprintf>
			return NULL;
f010555b:	83 c4 10             	add    $0x10,%esp
f010555e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105563:	eb 79                	jmp    f01055de <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105565:	83 f8 08             	cmp    $0x8,%eax
f0105568:	0f 94 c2             	sete   %dl
f010556b:	83 f8 7f             	cmp    $0x7f,%eax
f010556e:	0f 94 c0             	sete   %al
f0105571:	08 c2                	or     %al,%dl
f0105573:	74 1a                	je     f010558f <readline+0x82>
f0105575:	85 f6                	test   %esi,%esi
f0105577:	7e 16                	jle    f010558f <readline+0x82>
			if (echoing)
f0105579:	85 ff                	test   %edi,%edi
f010557b:	74 0d                	je     f010558a <readline+0x7d>
				cputchar('\b');
f010557d:	83 ec 0c             	sub    $0xc,%esp
f0105580:	6a 08                	push   $0x8
f0105582:	e8 c6 b1 ff ff       	call   f010074d <cputchar>
f0105587:	83 c4 10             	add    $0x10,%esp
			i--;
f010558a:	83 ee 01             	sub    $0x1,%esi
f010558d:	eb b3                	jmp    f0105542 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010558f:	83 fb 1f             	cmp    $0x1f,%ebx
f0105592:	7e 23                	jle    f01055b7 <readline+0xaa>
f0105594:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010559a:	7f 1b                	jg     f01055b7 <readline+0xaa>
			if (echoing)
f010559c:	85 ff                	test   %edi,%edi
f010559e:	74 0c                	je     f01055ac <readline+0x9f>
				cputchar(c);
f01055a0:	83 ec 0c             	sub    $0xc,%esp
f01055a3:	53                   	push   %ebx
f01055a4:	e8 a4 b1 ff ff       	call   f010074d <cputchar>
f01055a9:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01055ac:	88 9e 80 fa 22 f0    	mov    %bl,-0xfdd0580(%esi)
f01055b2:	8d 76 01             	lea    0x1(%esi),%esi
f01055b5:	eb 8b                	jmp    f0105542 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01055b7:	83 fb 0a             	cmp    $0xa,%ebx
f01055ba:	74 05                	je     f01055c1 <readline+0xb4>
f01055bc:	83 fb 0d             	cmp    $0xd,%ebx
f01055bf:	75 81                	jne    f0105542 <readline+0x35>
			if (echoing)
f01055c1:	85 ff                	test   %edi,%edi
f01055c3:	74 0d                	je     f01055d2 <readline+0xc5>
				cputchar('\n');
f01055c5:	83 ec 0c             	sub    $0xc,%esp
f01055c8:	6a 0a                	push   $0xa
f01055ca:	e8 7e b1 ff ff       	call   f010074d <cputchar>
f01055cf:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01055d2:	c6 86 80 fa 22 f0 00 	movb   $0x0,-0xfdd0580(%esi)
			return buf;
f01055d9:	b8 80 fa 22 f0       	mov    $0xf022fa80,%eax
		}
	}
}
f01055de:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01055e1:	5b                   	pop    %ebx
f01055e2:	5e                   	pop    %esi
f01055e3:	5f                   	pop    %edi
f01055e4:	5d                   	pop    %ebp
f01055e5:	c3                   	ret    

f01055e6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01055e6:	55                   	push   %ebp
f01055e7:	89 e5                	mov    %esp,%ebp
f01055e9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01055ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01055f1:	eb 03                	jmp    f01055f6 <strlen+0x10>
		n++;
f01055f3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01055f6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01055fa:	75 f7                	jne    f01055f3 <strlen+0xd>
		n++;
	return n;
}
f01055fc:	5d                   	pop    %ebp
f01055fd:	c3                   	ret    

f01055fe <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01055fe:	55                   	push   %ebp
f01055ff:	89 e5                	mov    %esp,%ebp
f0105601:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105604:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105607:	ba 00 00 00 00       	mov    $0x0,%edx
f010560c:	eb 03                	jmp    f0105611 <strnlen+0x13>
		n++;
f010560e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105611:	39 c2                	cmp    %eax,%edx
f0105613:	74 08                	je     f010561d <strnlen+0x1f>
f0105615:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105619:	75 f3                	jne    f010560e <strnlen+0x10>
f010561b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010561d:	5d                   	pop    %ebp
f010561e:	c3                   	ret    

f010561f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010561f:	55                   	push   %ebp
f0105620:	89 e5                	mov    %esp,%ebp
f0105622:	53                   	push   %ebx
f0105623:	8b 45 08             	mov    0x8(%ebp),%eax
f0105626:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105629:	89 c2                	mov    %eax,%edx
f010562b:	83 c2 01             	add    $0x1,%edx
f010562e:	83 c1 01             	add    $0x1,%ecx
f0105631:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105635:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105638:	84 db                	test   %bl,%bl
f010563a:	75 ef                	jne    f010562b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010563c:	5b                   	pop    %ebx
f010563d:	5d                   	pop    %ebp
f010563e:	c3                   	ret    

f010563f <strcat>:

char *
strcat(char *dst, const char *src)
{
f010563f:	55                   	push   %ebp
f0105640:	89 e5                	mov    %esp,%ebp
f0105642:	53                   	push   %ebx
f0105643:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105646:	53                   	push   %ebx
f0105647:	e8 9a ff ff ff       	call   f01055e6 <strlen>
f010564c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010564f:	ff 75 0c             	pushl  0xc(%ebp)
f0105652:	01 d8                	add    %ebx,%eax
f0105654:	50                   	push   %eax
f0105655:	e8 c5 ff ff ff       	call   f010561f <strcpy>
	return dst;
}
f010565a:	89 d8                	mov    %ebx,%eax
f010565c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010565f:	c9                   	leave  
f0105660:	c3                   	ret    

f0105661 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105661:	55                   	push   %ebp
f0105662:	89 e5                	mov    %esp,%ebp
f0105664:	56                   	push   %esi
f0105665:	53                   	push   %ebx
f0105666:	8b 75 08             	mov    0x8(%ebp),%esi
f0105669:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010566c:	89 f3                	mov    %esi,%ebx
f010566e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105671:	89 f2                	mov    %esi,%edx
f0105673:	eb 0f                	jmp    f0105684 <strncpy+0x23>
		*dst++ = *src;
f0105675:	83 c2 01             	add    $0x1,%edx
f0105678:	0f b6 01             	movzbl (%ecx),%eax
f010567b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010567e:	80 39 01             	cmpb   $0x1,(%ecx)
f0105681:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105684:	39 da                	cmp    %ebx,%edx
f0105686:	75 ed                	jne    f0105675 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105688:	89 f0                	mov    %esi,%eax
f010568a:	5b                   	pop    %ebx
f010568b:	5e                   	pop    %esi
f010568c:	5d                   	pop    %ebp
f010568d:	c3                   	ret    

f010568e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010568e:	55                   	push   %ebp
f010568f:	89 e5                	mov    %esp,%ebp
f0105691:	56                   	push   %esi
f0105692:	53                   	push   %ebx
f0105693:	8b 75 08             	mov    0x8(%ebp),%esi
f0105696:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105699:	8b 55 10             	mov    0x10(%ebp),%edx
f010569c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010569e:	85 d2                	test   %edx,%edx
f01056a0:	74 21                	je     f01056c3 <strlcpy+0x35>
f01056a2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01056a6:	89 f2                	mov    %esi,%edx
f01056a8:	eb 09                	jmp    f01056b3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01056aa:	83 c2 01             	add    $0x1,%edx
f01056ad:	83 c1 01             	add    $0x1,%ecx
f01056b0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01056b3:	39 c2                	cmp    %eax,%edx
f01056b5:	74 09                	je     f01056c0 <strlcpy+0x32>
f01056b7:	0f b6 19             	movzbl (%ecx),%ebx
f01056ba:	84 db                	test   %bl,%bl
f01056bc:	75 ec                	jne    f01056aa <strlcpy+0x1c>
f01056be:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01056c0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01056c3:	29 f0                	sub    %esi,%eax
}
f01056c5:	5b                   	pop    %ebx
f01056c6:	5e                   	pop    %esi
f01056c7:	5d                   	pop    %ebp
f01056c8:	c3                   	ret    

f01056c9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01056c9:	55                   	push   %ebp
f01056ca:	89 e5                	mov    %esp,%ebp
f01056cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01056cf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01056d2:	eb 06                	jmp    f01056da <strcmp+0x11>
		p++, q++;
f01056d4:	83 c1 01             	add    $0x1,%ecx
f01056d7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01056da:	0f b6 01             	movzbl (%ecx),%eax
f01056dd:	84 c0                	test   %al,%al
f01056df:	74 04                	je     f01056e5 <strcmp+0x1c>
f01056e1:	3a 02                	cmp    (%edx),%al
f01056e3:	74 ef                	je     f01056d4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01056e5:	0f b6 c0             	movzbl %al,%eax
f01056e8:	0f b6 12             	movzbl (%edx),%edx
f01056eb:	29 d0                	sub    %edx,%eax
}
f01056ed:	5d                   	pop    %ebp
f01056ee:	c3                   	ret    

f01056ef <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01056ef:	55                   	push   %ebp
f01056f0:	89 e5                	mov    %esp,%ebp
f01056f2:	53                   	push   %ebx
f01056f3:	8b 45 08             	mov    0x8(%ebp),%eax
f01056f6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01056f9:	89 c3                	mov    %eax,%ebx
f01056fb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01056fe:	eb 06                	jmp    f0105706 <strncmp+0x17>
		n--, p++, q++;
f0105700:	83 c0 01             	add    $0x1,%eax
f0105703:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105706:	39 d8                	cmp    %ebx,%eax
f0105708:	74 15                	je     f010571f <strncmp+0x30>
f010570a:	0f b6 08             	movzbl (%eax),%ecx
f010570d:	84 c9                	test   %cl,%cl
f010570f:	74 04                	je     f0105715 <strncmp+0x26>
f0105711:	3a 0a                	cmp    (%edx),%cl
f0105713:	74 eb                	je     f0105700 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105715:	0f b6 00             	movzbl (%eax),%eax
f0105718:	0f b6 12             	movzbl (%edx),%edx
f010571b:	29 d0                	sub    %edx,%eax
f010571d:	eb 05                	jmp    f0105724 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010571f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105724:	5b                   	pop    %ebx
f0105725:	5d                   	pop    %ebp
f0105726:	c3                   	ret    

f0105727 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105727:	55                   	push   %ebp
f0105728:	89 e5                	mov    %esp,%ebp
f010572a:	8b 45 08             	mov    0x8(%ebp),%eax
f010572d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105731:	eb 07                	jmp    f010573a <strchr+0x13>
		if (*s == c)
f0105733:	38 ca                	cmp    %cl,%dl
f0105735:	74 0f                	je     f0105746 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105737:	83 c0 01             	add    $0x1,%eax
f010573a:	0f b6 10             	movzbl (%eax),%edx
f010573d:	84 d2                	test   %dl,%dl
f010573f:	75 f2                	jne    f0105733 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105741:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105746:	5d                   	pop    %ebp
f0105747:	c3                   	ret    

f0105748 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105748:	55                   	push   %ebp
f0105749:	89 e5                	mov    %esp,%ebp
f010574b:	8b 45 08             	mov    0x8(%ebp),%eax
f010574e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105752:	eb 03                	jmp    f0105757 <strfind+0xf>
f0105754:	83 c0 01             	add    $0x1,%eax
f0105757:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010575a:	38 ca                	cmp    %cl,%dl
f010575c:	74 04                	je     f0105762 <strfind+0x1a>
f010575e:	84 d2                	test   %dl,%dl
f0105760:	75 f2                	jne    f0105754 <strfind+0xc>
			break;
	return (char *) s;
}
f0105762:	5d                   	pop    %ebp
f0105763:	c3                   	ret    

f0105764 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105764:	55                   	push   %ebp
f0105765:	89 e5                	mov    %esp,%ebp
f0105767:	57                   	push   %edi
f0105768:	56                   	push   %esi
f0105769:	53                   	push   %ebx
f010576a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010576d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105770:	85 c9                	test   %ecx,%ecx
f0105772:	74 36                	je     f01057aa <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105774:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010577a:	75 28                	jne    f01057a4 <memset+0x40>
f010577c:	f6 c1 03             	test   $0x3,%cl
f010577f:	75 23                	jne    f01057a4 <memset+0x40>
		c &= 0xFF;
f0105781:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105785:	89 d3                	mov    %edx,%ebx
f0105787:	c1 e3 08             	shl    $0x8,%ebx
f010578a:	89 d6                	mov    %edx,%esi
f010578c:	c1 e6 18             	shl    $0x18,%esi
f010578f:	89 d0                	mov    %edx,%eax
f0105791:	c1 e0 10             	shl    $0x10,%eax
f0105794:	09 f0                	or     %esi,%eax
f0105796:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105798:	89 d8                	mov    %ebx,%eax
f010579a:	09 d0                	or     %edx,%eax
f010579c:	c1 e9 02             	shr    $0x2,%ecx
f010579f:	fc                   	cld    
f01057a0:	f3 ab                	rep stos %eax,%es:(%edi)
f01057a2:	eb 06                	jmp    f01057aa <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01057a4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01057a7:	fc                   	cld    
f01057a8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01057aa:	89 f8                	mov    %edi,%eax
f01057ac:	5b                   	pop    %ebx
f01057ad:	5e                   	pop    %esi
f01057ae:	5f                   	pop    %edi
f01057af:	5d                   	pop    %ebp
f01057b0:	c3                   	ret    

f01057b1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01057b1:	55                   	push   %ebp
f01057b2:	89 e5                	mov    %esp,%ebp
f01057b4:	57                   	push   %edi
f01057b5:	56                   	push   %esi
f01057b6:	8b 45 08             	mov    0x8(%ebp),%eax
f01057b9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01057bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01057bf:	39 c6                	cmp    %eax,%esi
f01057c1:	73 35                	jae    f01057f8 <memmove+0x47>
f01057c3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01057c6:	39 d0                	cmp    %edx,%eax
f01057c8:	73 2e                	jae    f01057f8 <memmove+0x47>
		s += n;
		d += n;
f01057ca:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057cd:	89 d6                	mov    %edx,%esi
f01057cf:	09 fe                	or     %edi,%esi
f01057d1:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01057d7:	75 13                	jne    f01057ec <memmove+0x3b>
f01057d9:	f6 c1 03             	test   $0x3,%cl
f01057dc:	75 0e                	jne    f01057ec <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01057de:	83 ef 04             	sub    $0x4,%edi
f01057e1:	8d 72 fc             	lea    -0x4(%edx),%esi
f01057e4:	c1 e9 02             	shr    $0x2,%ecx
f01057e7:	fd                   	std    
f01057e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01057ea:	eb 09                	jmp    f01057f5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01057ec:	83 ef 01             	sub    $0x1,%edi
f01057ef:	8d 72 ff             	lea    -0x1(%edx),%esi
f01057f2:	fd                   	std    
f01057f3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01057f5:	fc                   	cld    
f01057f6:	eb 1d                	jmp    f0105815 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057f8:	89 f2                	mov    %esi,%edx
f01057fa:	09 c2                	or     %eax,%edx
f01057fc:	f6 c2 03             	test   $0x3,%dl
f01057ff:	75 0f                	jne    f0105810 <memmove+0x5f>
f0105801:	f6 c1 03             	test   $0x3,%cl
f0105804:	75 0a                	jne    f0105810 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105806:	c1 e9 02             	shr    $0x2,%ecx
f0105809:	89 c7                	mov    %eax,%edi
f010580b:	fc                   	cld    
f010580c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010580e:	eb 05                	jmp    f0105815 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105810:	89 c7                	mov    %eax,%edi
f0105812:	fc                   	cld    
f0105813:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105815:	5e                   	pop    %esi
f0105816:	5f                   	pop    %edi
f0105817:	5d                   	pop    %ebp
f0105818:	c3                   	ret    

f0105819 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105819:	55                   	push   %ebp
f010581a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010581c:	ff 75 10             	pushl  0x10(%ebp)
f010581f:	ff 75 0c             	pushl  0xc(%ebp)
f0105822:	ff 75 08             	pushl  0x8(%ebp)
f0105825:	e8 87 ff ff ff       	call   f01057b1 <memmove>
}
f010582a:	c9                   	leave  
f010582b:	c3                   	ret    

f010582c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010582c:	55                   	push   %ebp
f010582d:	89 e5                	mov    %esp,%ebp
f010582f:	56                   	push   %esi
f0105830:	53                   	push   %ebx
f0105831:	8b 45 08             	mov    0x8(%ebp),%eax
f0105834:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105837:	89 c6                	mov    %eax,%esi
f0105839:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010583c:	eb 1a                	jmp    f0105858 <memcmp+0x2c>
		if (*s1 != *s2)
f010583e:	0f b6 08             	movzbl (%eax),%ecx
f0105841:	0f b6 1a             	movzbl (%edx),%ebx
f0105844:	38 d9                	cmp    %bl,%cl
f0105846:	74 0a                	je     f0105852 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105848:	0f b6 c1             	movzbl %cl,%eax
f010584b:	0f b6 db             	movzbl %bl,%ebx
f010584e:	29 d8                	sub    %ebx,%eax
f0105850:	eb 0f                	jmp    f0105861 <memcmp+0x35>
		s1++, s2++;
f0105852:	83 c0 01             	add    $0x1,%eax
f0105855:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105858:	39 f0                	cmp    %esi,%eax
f010585a:	75 e2                	jne    f010583e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010585c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105861:	5b                   	pop    %ebx
f0105862:	5e                   	pop    %esi
f0105863:	5d                   	pop    %ebp
f0105864:	c3                   	ret    

f0105865 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105865:	55                   	push   %ebp
f0105866:	89 e5                	mov    %esp,%ebp
f0105868:	53                   	push   %ebx
f0105869:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010586c:	89 c1                	mov    %eax,%ecx
f010586e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0105871:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105875:	eb 0a                	jmp    f0105881 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105877:	0f b6 10             	movzbl (%eax),%edx
f010587a:	39 da                	cmp    %ebx,%edx
f010587c:	74 07                	je     f0105885 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010587e:	83 c0 01             	add    $0x1,%eax
f0105881:	39 c8                	cmp    %ecx,%eax
f0105883:	72 f2                	jb     f0105877 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105885:	5b                   	pop    %ebx
f0105886:	5d                   	pop    %ebp
f0105887:	c3                   	ret    

f0105888 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105888:	55                   	push   %ebp
f0105889:	89 e5                	mov    %esp,%ebp
f010588b:	57                   	push   %edi
f010588c:	56                   	push   %esi
f010588d:	53                   	push   %ebx
f010588e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105891:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105894:	eb 03                	jmp    f0105899 <strtol+0x11>
		s++;
f0105896:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105899:	0f b6 01             	movzbl (%ecx),%eax
f010589c:	3c 20                	cmp    $0x20,%al
f010589e:	74 f6                	je     f0105896 <strtol+0xe>
f01058a0:	3c 09                	cmp    $0x9,%al
f01058a2:	74 f2                	je     f0105896 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01058a4:	3c 2b                	cmp    $0x2b,%al
f01058a6:	75 0a                	jne    f01058b2 <strtol+0x2a>
		s++;
f01058a8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01058ab:	bf 00 00 00 00       	mov    $0x0,%edi
f01058b0:	eb 11                	jmp    f01058c3 <strtol+0x3b>
f01058b2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01058b7:	3c 2d                	cmp    $0x2d,%al
f01058b9:	75 08                	jne    f01058c3 <strtol+0x3b>
		s++, neg = 1;
f01058bb:	83 c1 01             	add    $0x1,%ecx
f01058be:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01058c3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01058c9:	75 15                	jne    f01058e0 <strtol+0x58>
f01058cb:	80 39 30             	cmpb   $0x30,(%ecx)
f01058ce:	75 10                	jne    f01058e0 <strtol+0x58>
f01058d0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01058d4:	75 7c                	jne    f0105952 <strtol+0xca>
		s += 2, base = 16;
f01058d6:	83 c1 02             	add    $0x2,%ecx
f01058d9:	bb 10 00 00 00       	mov    $0x10,%ebx
f01058de:	eb 16                	jmp    f01058f6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01058e0:	85 db                	test   %ebx,%ebx
f01058e2:	75 12                	jne    f01058f6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01058e4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01058e9:	80 39 30             	cmpb   $0x30,(%ecx)
f01058ec:	75 08                	jne    f01058f6 <strtol+0x6e>
		s++, base = 8;
f01058ee:	83 c1 01             	add    $0x1,%ecx
f01058f1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01058f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01058fb:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01058fe:	0f b6 11             	movzbl (%ecx),%edx
f0105901:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105904:	89 f3                	mov    %esi,%ebx
f0105906:	80 fb 09             	cmp    $0x9,%bl
f0105909:	77 08                	ja     f0105913 <strtol+0x8b>
			dig = *s - '0';
f010590b:	0f be d2             	movsbl %dl,%edx
f010590e:	83 ea 30             	sub    $0x30,%edx
f0105911:	eb 22                	jmp    f0105935 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105913:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105916:	89 f3                	mov    %esi,%ebx
f0105918:	80 fb 19             	cmp    $0x19,%bl
f010591b:	77 08                	ja     f0105925 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010591d:	0f be d2             	movsbl %dl,%edx
f0105920:	83 ea 57             	sub    $0x57,%edx
f0105923:	eb 10                	jmp    f0105935 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0105925:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105928:	89 f3                	mov    %esi,%ebx
f010592a:	80 fb 19             	cmp    $0x19,%bl
f010592d:	77 16                	ja     f0105945 <strtol+0xbd>
			dig = *s - 'A' + 10;
f010592f:	0f be d2             	movsbl %dl,%edx
f0105932:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105935:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105938:	7d 0b                	jge    f0105945 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010593a:	83 c1 01             	add    $0x1,%ecx
f010593d:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105941:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105943:	eb b9                	jmp    f01058fe <strtol+0x76>

	if (endptr)
f0105945:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105949:	74 0d                	je     f0105958 <strtol+0xd0>
		*endptr = (char *) s;
f010594b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010594e:	89 0e                	mov    %ecx,(%esi)
f0105950:	eb 06                	jmp    f0105958 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105952:	85 db                	test   %ebx,%ebx
f0105954:	74 98                	je     f01058ee <strtol+0x66>
f0105956:	eb 9e                	jmp    f01058f6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105958:	89 c2                	mov    %eax,%edx
f010595a:	f7 da                	neg    %edx
f010595c:	85 ff                	test   %edi,%edi
f010595e:	0f 45 c2             	cmovne %edx,%eax
}
f0105961:	5b                   	pop    %ebx
f0105962:	5e                   	pop    %esi
f0105963:	5f                   	pop    %edi
f0105964:	5d                   	pop    %ebp
f0105965:	c3                   	ret    
f0105966:	66 90                	xchg   %ax,%ax

f0105968 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105968:	fa                   	cli    

	xorw    %ax, %ax
f0105969:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010596b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010596d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010596f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105971:	0f 01 16             	lgdtl  (%esi)
f0105974:	74 70                	je     f01059e6 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105976:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105979:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f010597d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105980:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105986:	08 00                	or     %al,(%eax)

f0105988 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105988:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f010598c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010598e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105990:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105992:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105996:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105998:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010599a:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f010599f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01059a2:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01059a5:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01059aa:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01059ad:	8b 25 84 fe 22 f0    	mov    0xf022fe84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01059b3:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01059b8:	b8 9c 01 10 f0       	mov    $0xf010019c,%eax
	call    *%eax
f01059bd:	ff d0                	call   *%eax

f01059bf <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01059bf:	eb fe                	jmp    f01059bf <spin>
f01059c1:	8d 76 00             	lea    0x0(%esi),%esi

f01059c4 <gdt>:
	...
f01059cc:	ff                   	(bad)  
f01059cd:	ff 00                	incl   (%eax)
f01059cf:	00 00                	add    %al,(%eax)
f01059d1:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01059d8:	00                   	.byte 0x0
f01059d9:	92                   	xchg   %eax,%edx
f01059da:	cf                   	iret   
	...

f01059dc <gdtdesc>:
f01059dc:	17                   	pop    %ss
f01059dd:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01059e2 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01059e2:	90                   	nop

f01059e3 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01059e3:	55                   	push   %ebp
f01059e4:	89 e5                	mov    %esp,%ebp
f01059e6:	57                   	push   %edi
f01059e7:	56                   	push   %esi
f01059e8:	53                   	push   %ebx
f01059e9:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01059ec:	8b 0d 88 fe 22 f0    	mov    0xf022fe88,%ecx
f01059f2:	89 c3                	mov    %eax,%ebx
f01059f4:	c1 eb 0c             	shr    $0xc,%ebx
f01059f7:	39 cb                	cmp    %ecx,%ebx
f01059f9:	72 12                	jb     f0105a0d <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01059fb:	50                   	push   %eax
f01059fc:	68 44 64 10 f0       	push   $0xf0106444
f0105a01:	6a 5d                	push   $0x5d
f0105a03:	68 41 80 10 f0       	push   $0xf0108041
f0105a08:	e8 33 a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105a0d:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105a13:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a15:	89 c2                	mov    %eax,%edx
f0105a17:	c1 ea 0c             	shr    $0xc,%edx
f0105a1a:	39 ca                	cmp    %ecx,%edx
f0105a1c:	72 12                	jb     f0105a30 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a1e:	50                   	push   %eax
f0105a1f:	68 44 64 10 f0       	push   $0xf0106444
f0105a24:	6a 5d                	push   $0x5d
f0105a26:	68 41 80 10 f0       	push   $0xf0108041
f0105a2b:	e8 10 a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105a30:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105a36:	eb 2f                	jmp    f0105a67 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105a38:	83 ec 04             	sub    $0x4,%esp
f0105a3b:	6a 04                	push   $0x4
f0105a3d:	68 51 80 10 f0       	push   $0xf0108051
f0105a42:	53                   	push   %ebx
f0105a43:	e8 e4 fd ff ff       	call   f010582c <memcmp>
f0105a48:	83 c4 10             	add    $0x10,%esp
f0105a4b:	85 c0                	test   %eax,%eax
f0105a4d:	75 15                	jne    f0105a64 <mpsearch1+0x81>
f0105a4f:	89 da                	mov    %ebx,%edx
f0105a51:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105a54:	0f b6 0a             	movzbl (%edx),%ecx
f0105a57:	01 c8                	add    %ecx,%eax
f0105a59:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a5c:	39 d7                	cmp    %edx,%edi
f0105a5e:	75 f4                	jne    f0105a54 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105a60:	84 c0                	test   %al,%al
f0105a62:	74 0e                	je     f0105a72 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105a64:	83 c3 10             	add    $0x10,%ebx
f0105a67:	39 f3                	cmp    %esi,%ebx
f0105a69:	72 cd                	jb     f0105a38 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105a6b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a70:	eb 02                	jmp    f0105a74 <mpsearch1+0x91>
f0105a72:	89 d8                	mov    %ebx,%eax
}
f0105a74:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105a77:	5b                   	pop    %ebx
f0105a78:	5e                   	pop    %esi
f0105a79:	5f                   	pop    %edi
f0105a7a:	5d                   	pop    %ebp
f0105a7b:	c3                   	ret    

f0105a7c <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105a7c:	55                   	push   %ebp
f0105a7d:	89 e5                	mov    %esp,%ebp
f0105a7f:	57                   	push   %edi
f0105a80:	56                   	push   %esi
f0105a81:	53                   	push   %ebx
f0105a82:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105a85:	c7 05 c0 03 23 f0 20 	movl   $0xf0230020,0xf02303c0
f0105a8c:	00 23 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a8f:	83 3d 88 fe 22 f0 00 	cmpl   $0x0,0xf022fe88
f0105a96:	75 16                	jne    f0105aae <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a98:	68 00 04 00 00       	push   $0x400
f0105a9d:	68 44 64 10 f0       	push   $0xf0106444
f0105aa2:	6a 75                	push   $0x75
f0105aa4:	68 41 80 10 f0       	push   $0xf0108041
f0105aa9:	e8 92 a5 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105aae:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105ab5:	85 c0                	test   %eax,%eax
f0105ab7:	74 16                	je     f0105acf <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105ab9:	c1 e0 04             	shl    $0x4,%eax
f0105abc:	ba 00 04 00 00       	mov    $0x400,%edx
f0105ac1:	e8 1d ff ff ff       	call   f01059e3 <mpsearch1>
f0105ac6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105ac9:	85 c0                	test   %eax,%eax
f0105acb:	75 3c                	jne    f0105b09 <mp_init+0x8d>
f0105acd:	eb 20                	jmp    f0105aef <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105acf:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105ad6:	c1 e0 0a             	shl    $0xa,%eax
f0105ad9:	2d 00 04 00 00       	sub    $0x400,%eax
f0105ade:	ba 00 04 00 00       	mov    $0x400,%edx
f0105ae3:	e8 fb fe ff ff       	call   f01059e3 <mpsearch1>
f0105ae8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105aeb:	85 c0                	test   %eax,%eax
f0105aed:	75 1a                	jne    f0105b09 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105aef:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105af4:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105af9:	e8 e5 fe ff ff       	call   f01059e3 <mpsearch1>
f0105afe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105b01:	85 c0                	test   %eax,%eax
f0105b03:	0f 84 5d 02 00 00    	je     f0105d66 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105b09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b0c:	8b 70 04             	mov    0x4(%eax),%esi
f0105b0f:	85 f6                	test   %esi,%esi
f0105b11:	74 06                	je     f0105b19 <mp_init+0x9d>
f0105b13:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105b17:	74 15                	je     f0105b2e <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105b19:	83 ec 0c             	sub    $0xc,%esp
f0105b1c:	68 b4 7e 10 f0       	push   $0xf0107eb4
f0105b21:	e8 3c dc ff ff       	call   f0103762 <cprintf>
f0105b26:	83 c4 10             	add    $0x10,%esp
f0105b29:	e9 38 02 00 00       	jmp    f0105d66 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105b2e:	89 f0                	mov    %esi,%eax
f0105b30:	c1 e8 0c             	shr    $0xc,%eax
f0105b33:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f0105b39:	72 15                	jb     f0105b50 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b3b:	56                   	push   %esi
f0105b3c:	68 44 64 10 f0       	push   $0xf0106444
f0105b41:	68 96 00 00 00       	push   $0x96
f0105b46:	68 41 80 10 f0       	push   $0xf0108041
f0105b4b:	e8 f0 a4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105b50:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105b56:	83 ec 04             	sub    $0x4,%esp
f0105b59:	6a 04                	push   $0x4
f0105b5b:	68 56 80 10 f0       	push   $0xf0108056
f0105b60:	53                   	push   %ebx
f0105b61:	e8 c6 fc ff ff       	call   f010582c <memcmp>
f0105b66:	83 c4 10             	add    $0x10,%esp
f0105b69:	85 c0                	test   %eax,%eax
f0105b6b:	74 15                	je     f0105b82 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105b6d:	83 ec 0c             	sub    $0xc,%esp
f0105b70:	68 e4 7e 10 f0       	push   $0xf0107ee4
f0105b75:	e8 e8 db ff ff       	call   f0103762 <cprintf>
f0105b7a:	83 c4 10             	add    $0x10,%esp
f0105b7d:	e9 e4 01 00 00       	jmp    f0105d66 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105b82:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105b86:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105b8a:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105b8d:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105b92:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b97:	eb 0d                	jmp    f0105ba6 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105b99:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105ba0:	f0 
f0105ba1:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105ba3:	83 c0 01             	add    $0x1,%eax
f0105ba6:	39 c7                	cmp    %eax,%edi
f0105ba8:	75 ef                	jne    f0105b99 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105baa:	84 d2                	test   %dl,%dl
f0105bac:	74 15                	je     f0105bc3 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105bae:	83 ec 0c             	sub    $0xc,%esp
f0105bb1:	68 18 7f 10 f0       	push   $0xf0107f18
f0105bb6:	e8 a7 db ff ff       	call   f0103762 <cprintf>
f0105bbb:	83 c4 10             	add    $0x10,%esp
f0105bbe:	e9 a3 01 00 00       	jmp    f0105d66 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105bc3:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105bc7:	3c 01                	cmp    $0x1,%al
f0105bc9:	74 1d                	je     f0105be8 <mp_init+0x16c>
f0105bcb:	3c 04                	cmp    $0x4,%al
f0105bcd:	74 19                	je     f0105be8 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105bcf:	83 ec 08             	sub    $0x8,%esp
f0105bd2:	0f b6 c0             	movzbl %al,%eax
f0105bd5:	50                   	push   %eax
f0105bd6:	68 3c 7f 10 f0       	push   $0xf0107f3c
f0105bdb:	e8 82 db ff ff       	call   f0103762 <cprintf>
f0105be0:	83 c4 10             	add    $0x10,%esp
f0105be3:	e9 7e 01 00 00       	jmp    f0105d66 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105be8:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105bec:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105bf0:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105bf5:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105bfa:	01 ce                	add    %ecx,%esi
f0105bfc:	eb 0d                	jmp    f0105c0b <mp_init+0x18f>
f0105bfe:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105c05:	f0 
f0105c06:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105c08:	83 c0 01             	add    $0x1,%eax
f0105c0b:	39 c7                	cmp    %eax,%edi
f0105c0d:	75 ef                	jne    f0105bfe <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105c0f:	89 d0                	mov    %edx,%eax
f0105c11:	02 43 2a             	add    0x2a(%ebx),%al
f0105c14:	74 15                	je     f0105c2b <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105c16:	83 ec 0c             	sub    $0xc,%esp
f0105c19:	68 5c 7f 10 f0       	push   $0xf0107f5c
f0105c1e:	e8 3f db ff ff       	call   f0103762 <cprintf>
f0105c23:	83 c4 10             	add    $0x10,%esp
f0105c26:	e9 3b 01 00 00       	jmp    f0105d66 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105c2b:	85 db                	test   %ebx,%ebx
f0105c2d:	0f 84 33 01 00 00    	je     f0105d66 <mp_init+0x2ea>
		return;
	ismp = 1;
f0105c33:	c7 05 00 00 23 f0 01 	movl   $0x1,0xf0230000
f0105c3a:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105c3d:	8b 43 24             	mov    0x24(%ebx),%eax
f0105c40:	a3 00 10 27 f0       	mov    %eax,0xf0271000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105c45:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105c48:	be 00 00 00 00       	mov    $0x0,%esi
f0105c4d:	e9 85 00 00 00       	jmp    f0105cd7 <mp_init+0x25b>
		switch (*p) {
f0105c52:	0f b6 07             	movzbl (%edi),%eax
f0105c55:	84 c0                	test   %al,%al
f0105c57:	74 06                	je     f0105c5f <mp_init+0x1e3>
f0105c59:	3c 04                	cmp    $0x4,%al
f0105c5b:	77 55                	ja     f0105cb2 <mp_init+0x236>
f0105c5d:	eb 4e                	jmp    f0105cad <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105c5f:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105c63:	74 11                	je     f0105c76 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105c65:	6b 05 c4 03 23 f0 74 	imul   $0x74,0xf02303c4,%eax
f0105c6c:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0105c71:	a3 c0 03 23 f0       	mov    %eax,0xf02303c0
			if (ncpu < NCPU) {
f0105c76:	a1 c4 03 23 f0       	mov    0xf02303c4,%eax
f0105c7b:	83 f8 07             	cmp    $0x7,%eax
f0105c7e:	7f 13                	jg     f0105c93 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105c80:	6b d0 74             	imul   $0x74,%eax,%edx
f0105c83:	88 82 20 00 23 f0    	mov    %al,-0xfdcffe0(%edx)
				ncpu++;
f0105c89:	83 c0 01             	add    $0x1,%eax
f0105c8c:	a3 c4 03 23 f0       	mov    %eax,0xf02303c4
f0105c91:	eb 15                	jmp    f0105ca8 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105c93:	83 ec 08             	sub    $0x8,%esp
f0105c96:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105c9a:	50                   	push   %eax
f0105c9b:	68 8c 7f 10 f0       	push   $0xf0107f8c
f0105ca0:	e8 bd da ff ff       	call   f0103762 <cprintf>
f0105ca5:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105ca8:	83 c7 14             	add    $0x14,%edi
			continue;
f0105cab:	eb 27                	jmp    f0105cd4 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105cad:	83 c7 08             	add    $0x8,%edi
			continue;
f0105cb0:	eb 22                	jmp    f0105cd4 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105cb2:	83 ec 08             	sub    $0x8,%esp
f0105cb5:	0f b6 c0             	movzbl %al,%eax
f0105cb8:	50                   	push   %eax
f0105cb9:	68 b4 7f 10 f0       	push   $0xf0107fb4
f0105cbe:	e8 9f da ff ff       	call   f0103762 <cprintf>
			ismp = 0;
f0105cc3:	c7 05 00 00 23 f0 00 	movl   $0x0,0xf0230000
f0105cca:	00 00 00 
			i = conf->entry;
f0105ccd:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105cd1:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105cd4:	83 c6 01             	add    $0x1,%esi
f0105cd7:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105cdb:	39 c6                	cmp    %eax,%esi
f0105cdd:	0f 82 6f ff ff ff    	jb     f0105c52 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105ce3:	a1 c0 03 23 f0       	mov    0xf02303c0,%eax
f0105ce8:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105cef:	83 3d 00 00 23 f0 00 	cmpl   $0x0,0xf0230000
f0105cf6:	75 26                	jne    f0105d1e <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105cf8:	c7 05 c4 03 23 f0 01 	movl   $0x1,0xf02303c4
f0105cff:	00 00 00 
		lapicaddr = 0;
f0105d02:	c7 05 00 10 27 f0 00 	movl   $0x0,0xf0271000
f0105d09:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105d0c:	83 ec 0c             	sub    $0xc,%esp
f0105d0f:	68 d4 7f 10 f0       	push   $0xf0107fd4
f0105d14:	e8 49 da ff ff       	call   f0103762 <cprintf>
		return;
f0105d19:	83 c4 10             	add    $0x10,%esp
f0105d1c:	eb 48                	jmp    f0105d66 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105d1e:	83 ec 04             	sub    $0x4,%esp
f0105d21:	ff 35 c4 03 23 f0    	pushl  0xf02303c4
f0105d27:	0f b6 00             	movzbl (%eax),%eax
f0105d2a:	50                   	push   %eax
f0105d2b:	68 5b 80 10 f0       	push   $0xf010805b
f0105d30:	e8 2d da ff ff       	call   f0103762 <cprintf>

	if (mp->imcrp) {
f0105d35:	83 c4 10             	add    $0x10,%esp
f0105d38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d3b:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105d3f:	74 25                	je     f0105d66 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105d41:	83 ec 0c             	sub    $0xc,%esp
f0105d44:	68 00 80 10 f0       	push   $0xf0108000
f0105d49:	e8 14 da ff ff       	call   f0103762 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105d4e:	ba 22 00 00 00       	mov    $0x22,%edx
f0105d53:	b8 70 00 00 00       	mov    $0x70,%eax
f0105d58:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105d59:	ba 23 00 00 00       	mov    $0x23,%edx
f0105d5e:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105d5f:	83 c8 01             	or     $0x1,%eax
f0105d62:	ee                   	out    %al,(%dx)
f0105d63:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105d66:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105d69:	5b                   	pop    %ebx
f0105d6a:	5e                   	pop    %esi
f0105d6b:	5f                   	pop    %edi
f0105d6c:	5d                   	pop    %ebp
f0105d6d:	c3                   	ret    

f0105d6e <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105d6e:	55                   	push   %ebp
f0105d6f:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105d71:	8b 0d 04 10 27 f0    	mov    0xf0271004,%ecx
f0105d77:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105d7a:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105d7c:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105d81:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105d84:	5d                   	pop    %ebp
f0105d85:	c3                   	ret    

f0105d86 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105d86:	55                   	push   %ebp
f0105d87:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105d89:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105d8e:	85 c0                	test   %eax,%eax
f0105d90:	74 08                	je     f0105d9a <cpunum+0x14>
		return lapic[ID] >> 24;
f0105d92:	8b 40 20             	mov    0x20(%eax),%eax
f0105d95:	c1 e8 18             	shr    $0x18,%eax
f0105d98:	eb 05                	jmp    f0105d9f <cpunum+0x19>
	return 0;
f0105d9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105d9f:	5d                   	pop    %ebp
f0105da0:	c3                   	ret    

f0105da1 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105da1:	a1 00 10 27 f0       	mov    0xf0271000,%eax
f0105da6:	85 c0                	test   %eax,%eax
f0105da8:	0f 84 21 01 00 00    	je     f0105ecf <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105dae:	55                   	push   %ebp
f0105daf:	89 e5                	mov    %esp,%ebp
f0105db1:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105db4:	68 00 10 00 00       	push   $0x1000
f0105db9:	50                   	push   %eax
f0105dba:	e8 3d b4 ff ff       	call   f01011fc <mmio_map_region>
f0105dbf:	a3 04 10 27 f0       	mov    %eax,0xf0271004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105dc4:	ba 27 01 00 00       	mov    $0x127,%edx
f0105dc9:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105dce:	e8 9b ff ff ff       	call   f0105d6e <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105dd3:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105dd8:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105ddd:	e8 8c ff ff ff       	call   f0105d6e <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105de2:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105de7:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105dec:	e8 7d ff ff ff       	call   f0105d6e <lapicw>
	lapicw(TICR, 10000000); 
f0105df1:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105df6:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105dfb:	e8 6e ff ff ff       	call   f0105d6e <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105e00:	e8 81 ff ff ff       	call   f0105d86 <cpunum>
f0105e05:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e08:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0105e0d:	83 c4 10             	add    $0x10,%esp
f0105e10:	39 05 c0 03 23 f0    	cmp    %eax,0xf02303c0
f0105e16:	74 0f                	je     f0105e27 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105e18:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e1d:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105e22:	e8 47 ff ff ff       	call   f0105d6e <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105e27:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e2c:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105e31:	e8 38 ff ff ff       	call   f0105d6e <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105e36:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105e3b:	8b 40 30             	mov    0x30(%eax),%eax
f0105e3e:	c1 e8 10             	shr    $0x10,%eax
f0105e41:	3c 03                	cmp    $0x3,%al
f0105e43:	76 0f                	jbe    f0105e54 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105e45:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e4a:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105e4f:	e8 1a ff ff ff       	call   f0105d6e <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105e54:	ba 33 00 00 00       	mov    $0x33,%edx
f0105e59:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105e5e:	e8 0b ff ff ff       	call   f0105d6e <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105e63:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e68:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105e6d:	e8 fc fe ff ff       	call   f0105d6e <lapicw>
	lapicw(ESR, 0);
f0105e72:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e77:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105e7c:	e8 ed fe ff ff       	call   f0105d6e <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105e81:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e86:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105e8b:	e8 de fe ff ff       	call   f0105d6e <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105e90:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e95:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105e9a:	e8 cf fe ff ff       	call   f0105d6e <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105e9f:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105ea4:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ea9:	e8 c0 fe ff ff       	call   f0105d6e <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105eae:	8b 15 04 10 27 f0    	mov    0xf0271004,%edx
f0105eb4:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105eba:	f6 c4 10             	test   $0x10,%ah
f0105ebd:	75 f5                	jne    f0105eb4 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105ebf:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ec4:	b8 20 00 00 00       	mov    $0x20,%eax
f0105ec9:	e8 a0 fe ff ff       	call   f0105d6e <lapicw>
}
f0105ece:	c9                   	leave  
f0105ecf:	f3 c3                	repz ret 

f0105ed1 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105ed1:	83 3d 04 10 27 f0 00 	cmpl   $0x0,0xf0271004
f0105ed8:	74 13                	je     f0105eed <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105eda:	55                   	push   %ebp
f0105edb:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105edd:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ee2:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105ee7:	e8 82 fe ff ff       	call   f0105d6e <lapicw>
}
f0105eec:	5d                   	pop    %ebp
f0105eed:	f3 c3                	repz ret 

f0105eef <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105eef:	55                   	push   %ebp
f0105ef0:	89 e5                	mov    %esp,%ebp
f0105ef2:	56                   	push   %esi
f0105ef3:	53                   	push   %ebx
f0105ef4:	8b 75 08             	mov    0x8(%ebp),%esi
f0105ef7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105efa:	ba 70 00 00 00       	mov    $0x70,%edx
f0105eff:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105f04:	ee                   	out    %al,(%dx)
f0105f05:	ba 71 00 00 00       	mov    $0x71,%edx
f0105f0a:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105f0f:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105f10:	83 3d 88 fe 22 f0 00 	cmpl   $0x0,0xf022fe88
f0105f17:	75 19                	jne    f0105f32 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f19:	68 67 04 00 00       	push   $0x467
f0105f1e:	68 44 64 10 f0       	push   $0xf0106444
f0105f23:	68 9b 00 00 00       	push   $0x9b
f0105f28:	68 78 80 10 f0       	push   $0xf0108078
f0105f2d:	e8 0e a1 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105f32:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105f39:	00 00 
	wrv[1] = addr >> 4;
f0105f3b:	89 d8                	mov    %ebx,%eax
f0105f3d:	c1 e8 04             	shr    $0x4,%eax
f0105f40:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105f46:	c1 e6 18             	shl    $0x18,%esi
f0105f49:	89 f2                	mov    %esi,%edx
f0105f4b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f50:	e8 19 fe ff ff       	call   f0105d6e <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105f55:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105f5a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f5f:	e8 0a fe ff ff       	call   f0105d6e <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105f64:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105f69:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f6e:	e8 fb fd ff ff       	call   f0105d6e <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f73:	c1 eb 0c             	shr    $0xc,%ebx
f0105f76:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105f79:	89 f2                	mov    %esi,%edx
f0105f7b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f80:	e8 e9 fd ff ff       	call   f0105d6e <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f85:	89 da                	mov    %ebx,%edx
f0105f87:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f8c:	e8 dd fd ff ff       	call   f0105d6e <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105f91:	89 f2                	mov    %esi,%edx
f0105f93:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f98:	e8 d1 fd ff ff       	call   f0105d6e <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f9d:	89 da                	mov    %ebx,%edx
f0105f9f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fa4:	e8 c5 fd ff ff       	call   f0105d6e <lapicw>
		microdelay(200);
	}
}
f0105fa9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105fac:	5b                   	pop    %ebx
f0105fad:	5e                   	pop    %esi
f0105fae:	5d                   	pop    %ebp
f0105faf:	c3                   	ret    

f0105fb0 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105fb0:	55                   	push   %ebp
f0105fb1:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105fb3:	8b 55 08             	mov    0x8(%ebp),%edx
f0105fb6:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105fbc:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fc1:	e8 a8 fd ff ff       	call   f0105d6e <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105fc6:	8b 15 04 10 27 f0    	mov    0xf0271004,%edx
f0105fcc:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105fd2:	f6 c4 10             	test   $0x10,%ah
f0105fd5:	75 f5                	jne    f0105fcc <lapic_ipi+0x1c>
		;
}
f0105fd7:	5d                   	pop    %ebp
f0105fd8:	c3                   	ret    

f0105fd9 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105fd9:	55                   	push   %ebp
f0105fda:	89 e5                	mov    %esp,%ebp
f0105fdc:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105fdf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105fe5:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105fe8:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105feb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105ff2:	5d                   	pop    %ebp
f0105ff3:	c3                   	ret    

f0105ff4 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105ff4:	55                   	push   %ebp
f0105ff5:	89 e5                	mov    %esp,%ebp
f0105ff7:	56                   	push   %esi
f0105ff8:	53                   	push   %ebx
f0105ff9:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105ffc:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105fff:	74 14                	je     f0106015 <spin_lock+0x21>
f0106001:	8b 73 08             	mov    0x8(%ebx),%esi
f0106004:	e8 7d fd ff ff       	call   f0105d86 <cpunum>
f0106009:	6b c0 74             	imul   $0x74,%eax,%eax
f010600c:	05 20 00 23 f0       	add    $0xf0230020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106011:	39 c6                	cmp    %eax,%esi
f0106013:	74 07                	je     f010601c <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106015:	ba 01 00 00 00       	mov    $0x1,%edx
f010601a:	eb 20                	jmp    f010603c <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f010601c:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010601f:	e8 62 fd ff ff       	call   f0105d86 <cpunum>
f0106024:	83 ec 0c             	sub    $0xc,%esp
f0106027:	53                   	push   %ebx
f0106028:	50                   	push   %eax
f0106029:	68 88 80 10 f0       	push   $0xf0108088
f010602e:	6a 41                	push   $0x41
f0106030:	68 ec 80 10 f0       	push   $0xf01080ec
f0106035:	e8 06 a0 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010603a:	f3 90                	pause  
f010603c:	89 d0                	mov    %edx,%eax
f010603e:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106041:	85 c0                	test   %eax,%eax
f0106043:	75 f5                	jne    f010603a <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106045:	e8 3c fd ff ff       	call   f0105d86 <cpunum>
f010604a:	6b c0 74             	imul   $0x74,%eax,%eax
f010604d:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0106052:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106055:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0106058:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010605a:	b8 00 00 00 00       	mov    $0x0,%eax
f010605f:	eb 0b                	jmp    f010606c <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106061:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106064:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106067:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106069:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f010606c:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106072:	76 11                	jbe    f0106085 <spin_lock+0x91>
f0106074:	83 f8 09             	cmp    $0x9,%eax
f0106077:	7e e8                	jle    f0106061 <spin_lock+0x6d>
f0106079:	eb 0a                	jmp    f0106085 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f010607b:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106082:	83 c0 01             	add    $0x1,%eax
f0106085:	83 f8 09             	cmp    $0x9,%eax
f0106088:	7e f1                	jle    f010607b <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f010608a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010608d:	5b                   	pop    %ebx
f010608e:	5e                   	pop    %esi
f010608f:	5d                   	pop    %ebp
f0106090:	c3                   	ret    

f0106091 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106091:	55                   	push   %ebp
f0106092:	89 e5                	mov    %esp,%ebp
f0106094:	57                   	push   %edi
f0106095:	56                   	push   %esi
f0106096:	53                   	push   %ebx
f0106097:	83 ec 4c             	sub    $0x4c,%esp
f010609a:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f010609d:	83 3e 00             	cmpl   $0x0,(%esi)
f01060a0:	74 18                	je     f01060ba <spin_unlock+0x29>
f01060a2:	8b 5e 08             	mov    0x8(%esi),%ebx
f01060a5:	e8 dc fc ff ff       	call   f0105d86 <cpunum>
f01060aa:	6b c0 74             	imul   $0x74,%eax,%eax
f01060ad:	05 20 00 23 f0       	add    $0xf0230020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01060b2:	39 c3                	cmp    %eax,%ebx
f01060b4:	0f 84 a5 00 00 00    	je     f010615f <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01060ba:	83 ec 04             	sub    $0x4,%esp
f01060bd:	6a 28                	push   $0x28
f01060bf:	8d 46 0c             	lea    0xc(%esi),%eax
f01060c2:	50                   	push   %eax
f01060c3:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01060c6:	53                   	push   %ebx
f01060c7:	e8 e5 f6 ff ff       	call   f01057b1 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01060cc:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01060cf:	0f b6 38             	movzbl (%eax),%edi
f01060d2:	8b 76 04             	mov    0x4(%esi),%esi
f01060d5:	e8 ac fc ff ff       	call   f0105d86 <cpunum>
f01060da:	57                   	push   %edi
f01060db:	56                   	push   %esi
f01060dc:	50                   	push   %eax
f01060dd:	68 b4 80 10 f0       	push   $0xf01080b4
f01060e2:	e8 7b d6 ff ff       	call   f0103762 <cprintf>
f01060e7:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01060ea:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01060ed:	eb 54                	jmp    f0106143 <spin_unlock+0xb2>
f01060ef:	83 ec 08             	sub    $0x8,%esp
f01060f2:	57                   	push   %edi
f01060f3:	50                   	push   %eax
f01060f4:	e8 8d ec ff ff       	call   f0104d86 <debuginfo_eip>
f01060f9:	83 c4 10             	add    $0x10,%esp
f01060fc:	85 c0                	test   %eax,%eax
f01060fe:	78 27                	js     f0106127 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106100:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106102:	83 ec 04             	sub    $0x4,%esp
f0106105:	89 c2                	mov    %eax,%edx
f0106107:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010610a:	52                   	push   %edx
f010610b:	ff 75 b0             	pushl  -0x50(%ebp)
f010610e:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106111:	ff 75 ac             	pushl  -0x54(%ebp)
f0106114:	ff 75 a8             	pushl  -0x58(%ebp)
f0106117:	50                   	push   %eax
f0106118:	68 fc 80 10 f0       	push   $0xf01080fc
f010611d:	e8 40 d6 ff ff       	call   f0103762 <cprintf>
f0106122:	83 c4 20             	add    $0x20,%esp
f0106125:	eb 12                	jmp    f0106139 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106127:	83 ec 08             	sub    $0x8,%esp
f010612a:	ff 36                	pushl  (%esi)
f010612c:	68 13 81 10 f0       	push   $0xf0108113
f0106131:	e8 2c d6 ff ff       	call   f0103762 <cprintf>
f0106136:	83 c4 10             	add    $0x10,%esp
f0106139:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010613c:	8d 45 e8             	lea    -0x18(%ebp),%eax
f010613f:	39 c3                	cmp    %eax,%ebx
f0106141:	74 08                	je     f010614b <spin_unlock+0xba>
f0106143:	89 de                	mov    %ebx,%esi
f0106145:	8b 03                	mov    (%ebx),%eax
f0106147:	85 c0                	test   %eax,%eax
f0106149:	75 a4                	jne    f01060ef <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f010614b:	83 ec 04             	sub    $0x4,%esp
f010614e:	68 1b 81 10 f0       	push   $0xf010811b
f0106153:	6a 67                	push   $0x67
f0106155:	68 ec 80 10 f0       	push   $0xf01080ec
f010615a:	e8 e1 9e ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f010615f:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106166:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010616d:	b8 00 00 00 00       	mov    $0x0,%eax
f0106172:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106175:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106178:	5b                   	pop    %ebx
f0106179:	5e                   	pop    %esi
f010617a:	5f                   	pop    %edi
f010617b:	5d                   	pop    %ebp
f010617c:	c3                   	ret    
f010617d:	66 90                	xchg   %ax,%ax
f010617f:	90                   	nop

f0106180 <__udivdi3>:
f0106180:	55                   	push   %ebp
f0106181:	57                   	push   %edi
f0106182:	56                   	push   %esi
f0106183:	53                   	push   %ebx
f0106184:	83 ec 1c             	sub    $0x1c,%esp
f0106187:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010618b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010618f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0106193:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106197:	85 f6                	test   %esi,%esi
f0106199:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010619d:	89 ca                	mov    %ecx,%edx
f010619f:	89 f8                	mov    %edi,%eax
f01061a1:	75 3d                	jne    f01061e0 <__udivdi3+0x60>
f01061a3:	39 cf                	cmp    %ecx,%edi
f01061a5:	0f 87 c5 00 00 00    	ja     f0106270 <__udivdi3+0xf0>
f01061ab:	85 ff                	test   %edi,%edi
f01061ad:	89 fd                	mov    %edi,%ebp
f01061af:	75 0b                	jne    f01061bc <__udivdi3+0x3c>
f01061b1:	b8 01 00 00 00       	mov    $0x1,%eax
f01061b6:	31 d2                	xor    %edx,%edx
f01061b8:	f7 f7                	div    %edi
f01061ba:	89 c5                	mov    %eax,%ebp
f01061bc:	89 c8                	mov    %ecx,%eax
f01061be:	31 d2                	xor    %edx,%edx
f01061c0:	f7 f5                	div    %ebp
f01061c2:	89 c1                	mov    %eax,%ecx
f01061c4:	89 d8                	mov    %ebx,%eax
f01061c6:	89 cf                	mov    %ecx,%edi
f01061c8:	f7 f5                	div    %ebp
f01061ca:	89 c3                	mov    %eax,%ebx
f01061cc:	89 d8                	mov    %ebx,%eax
f01061ce:	89 fa                	mov    %edi,%edx
f01061d0:	83 c4 1c             	add    $0x1c,%esp
f01061d3:	5b                   	pop    %ebx
f01061d4:	5e                   	pop    %esi
f01061d5:	5f                   	pop    %edi
f01061d6:	5d                   	pop    %ebp
f01061d7:	c3                   	ret    
f01061d8:	90                   	nop
f01061d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01061e0:	39 ce                	cmp    %ecx,%esi
f01061e2:	77 74                	ja     f0106258 <__udivdi3+0xd8>
f01061e4:	0f bd fe             	bsr    %esi,%edi
f01061e7:	83 f7 1f             	xor    $0x1f,%edi
f01061ea:	0f 84 98 00 00 00    	je     f0106288 <__udivdi3+0x108>
f01061f0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01061f5:	89 f9                	mov    %edi,%ecx
f01061f7:	89 c5                	mov    %eax,%ebp
f01061f9:	29 fb                	sub    %edi,%ebx
f01061fb:	d3 e6                	shl    %cl,%esi
f01061fd:	89 d9                	mov    %ebx,%ecx
f01061ff:	d3 ed                	shr    %cl,%ebp
f0106201:	89 f9                	mov    %edi,%ecx
f0106203:	d3 e0                	shl    %cl,%eax
f0106205:	09 ee                	or     %ebp,%esi
f0106207:	89 d9                	mov    %ebx,%ecx
f0106209:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010620d:	89 d5                	mov    %edx,%ebp
f010620f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106213:	d3 ed                	shr    %cl,%ebp
f0106215:	89 f9                	mov    %edi,%ecx
f0106217:	d3 e2                	shl    %cl,%edx
f0106219:	89 d9                	mov    %ebx,%ecx
f010621b:	d3 e8                	shr    %cl,%eax
f010621d:	09 c2                	or     %eax,%edx
f010621f:	89 d0                	mov    %edx,%eax
f0106221:	89 ea                	mov    %ebp,%edx
f0106223:	f7 f6                	div    %esi
f0106225:	89 d5                	mov    %edx,%ebp
f0106227:	89 c3                	mov    %eax,%ebx
f0106229:	f7 64 24 0c          	mull   0xc(%esp)
f010622d:	39 d5                	cmp    %edx,%ebp
f010622f:	72 10                	jb     f0106241 <__udivdi3+0xc1>
f0106231:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106235:	89 f9                	mov    %edi,%ecx
f0106237:	d3 e6                	shl    %cl,%esi
f0106239:	39 c6                	cmp    %eax,%esi
f010623b:	73 07                	jae    f0106244 <__udivdi3+0xc4>
f010623d:	39 d5                	cmp    %edx,%ebp
f010623f:	75 03                	jne    f0106244 <__udivdi3+0xc4>
f0106241:	83 eb 01             	sub    $0x1,%ebx
f0106244:	31 ff                	xor    %edi,%edi
f0106246:	89 d8                	mov    %ebx,%eax
f0106248:	89 fa                	mov    %edi,%edx
f010624a:	83 c4 1c             	add    $0x1c,%esp
f010624d:	5b                   	pop    %ebx
f010624e:	5e                   	pop    %esi
f010624f:	5f                   	pop    %edi
f0106250:	5d                   	pop    %ebp
f0106251:	c3                   	ret    
f0106252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106258:	31 ff                	xor    %edi,%edi
f010625a:	31 db                	xor    %ebx,%ebx
f010625c:	89 d8                	mov    %ebx,%eax
f010625e:	89 fa                	mov    %edi,%edx
f0106260:	83 c4 1c             	add    $0x1c,%esp
f0106263:	5b                   	pop    %ebx
f0106264:	5e                   	pop    %esi
f0106265:	5f                   	pop    %edi
f0106266:	5d                   	pop    %ebp
f0106267:	c3                   	ret    
f0106268:	90                   	nop
f0106269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106270:	89 d8                	mov    %ebx,%eax
f0106272:	f7 f7                	div    %edi
f0106274:	31 ff                	xor    %edi,%edi
f0106276:	89 c3                	mov    %eax,%ebx
f0106278:	89 d8                	mov    %ebx,%eax
f010627a:	89 fa                	mov    %edi,%edx
f010627c:	83 c4 1c             	add    $0x1c,%esp
f010627f:	5b                   	pop    %ebx
f0106280:	5e                   	pop    %esi
f0106281:	5f                   	pop    %edi
f0106282:	5d                   	pop    %ebp
f0106283:	c3                   	ret    
f0106284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106288:	39 ce                	cmp    %ecx,%esi
f010628a:	72 0c                	jb     f0106298 <__udivdi3+0x118>
f010628c:	31 db                	xor    %ebx,%ebx
f010628e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106292:	0f 87 34 ff ff ff    	ja     f01061cc <__udivdi3+0x4c>
f0106298:	bb 01 00 00 00       	mov    $0x1,%ebx
f010629d:	e9 2a ff ff ff       	jmp    f01061cc <__udivdi3+0x4c>
f01062a2:	66 90                	xchg   %ax,%ax
f01062a4:	66 90                	xchg   %ax,%ax
f01062a6:	66 90                	xchg   %ax,%ax
f01062a8:	66 90                	xchg   %ax,%ax
f01062aa:	66 90                	xchg   %ax,%ax
f01062ac:	66 90                	xchg   %ax,%ax
f01062ae:	66 90                	xchg   %ax,%ax

f01062b0 <__umoddi3>:
f01062b0:	55                   	push   %ebp
f01062b1:	57                   	push   %edi
f01062b2:	56                   	push   %esi
f01062b3:	53                   	push   %ebx
f01062b4:	83 ec 1c             	sub    $0x1c,%esp
f01062b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01062bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01062bf:	8b 74 24 34          	mov    0x34(%esp),%esi
f01062c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01062c7:	85 d2                	test   %edx,%edx
f01062c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01062cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01062d1:	89 f3                	mov    %esi,%ebx
f01062d3:	89 3c 24             	mov    %edi,(%esp)
f01062d6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01062da:	75 1c                	jne    f01062f8 <__umoddi3+0x48>
f01062dc:	39 f7                	cmp    %esi,%edi
f01062de:	76 50                	jbe    f0106330 <__umoddi3+0x80>
f01062e0:	89 c8                	mov    %ecx,%eax
f01062e2:	89 f2                	mov    %esi,%edx
f01062e4:	f7 f7                	div    %edi
f01062e6:	89 d0                	mov    %edx,%eax
f01062e8:	31 d2                	xor    %edx,%edx
f01062ea:	83 c4 1c             	add    $0x1c,%esp
f01062ed:	5b                   	pop    %ebx
f01062ee:	5e                   	pop    %esi
f01062ef:	5f                   	pop    %edi
f01062f0:	5d                   	pop    %ebp
f01062f1:	c3                   	ret    
f01062f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01062f8:	39 f2                	cmp    %esi,%edx
f01062fa:	89 d0                	mov    %edx,%eax
f01062fc:	77 52                	ja     f0106350 <__umoddi3+0xa0>
f01062fe:	0f bd ea             	bsr    %edx,%ebp
f0106301:	83 f5 1f             	xor    $0x1f,%ebp
f0106304:	75 5a                	jne    f0106360 <__umoddi3+0xb0>
f0106306:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010630a:	0f 82 e0 00 00 00    	jb     f01063f0 <__umoddi3+0x140>
f0106310:	39 0c 24             	cmp    %ecx,(%esp)
f0106313:	0f 86 d7 00 00 00    	jbe    f01063f0 <__umoddi3+0x140>
f0106319:	8b 44 24 08          	mov    0x8(%esp),%eax
f010631d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106321:	83 c4 1c             	add    $0x1c,%esp
f0106324:	5b                   	pop    %ebx
f0106325:	5e                   	pop    %esi
f0106326:	5f                   	pop    %edi
f0106327:	5d                   	pop    %ebp
f0106328:	c3                   	ret    
f0106329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106330:	85 ff                	test   %edi,%edi
f0106332:	89 fd                	mov    %edi,%ebp
f0106334:	75 0b                	jne    f0106341 <__umoddi3+0x91>
f0106336:	b8 01 00 00 00       	mov    $0x1,%eax
f010633b:	31 d2                	xor    %edx,%edx
f010633d:	f7 f7                	div    %edi
f010633f:	89 c5                	mov    %eax,%ebp
f0106341:	89 f0                	mov    %esi,%eax
f0106343:	31 d2                	xor    %edx,%edx
f0106345:	f7 f5                	div    %ebp
f0106347:	89 c8                	mov    %ecx,%eax
f0106349:	f7 f5                	div    %ebp
f010634b:	89 d0                	mov    %edx,%eax
f010634d:	eb 99                	jmp    f01062e8 <__umoddi3+0x38>
f010634f:	90                   	nop
f0106350:	89 c8                	mov    %ecx,%eax
f0106352:	89 f2                	mov    %esi,%edx
f0106354:	83 c4 1c             	add    $0x1c,%esp
f0106357:	5b                   	pop    %ebx
f0106358:	5e                   	pop    %esi
f0106359:	5f                   	pop    %edi
f010635a:	5d                   	pop    %ebp
f010635b:	c3                   	ret    
f010635c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106360:	8b 34 24             	mov    (%esp),%esi
f0106363:	bf 20 00 00 00       	mov    $0x20,%edi
f0106368:	89 e9                	mov    %ebp,%ecx
f010636a:	29 ef                	sub    %ebp,%edi
f010636c:	d3 e0                	shl    %cl,%eax
f010636e:	89 f9                	mov    %edi,%ecx
f0106370:	89 f2                	mov    %esi,%edx
f0106372:	d3 ea                	shr    %cl,%edx
f0106374:	89 e9                	mov    %ebp,%ecx
f0106376:	09 c2                	or     %eax,%edx
f0106378:	89 d8                	mov    %ebx,%eax
f010637a:	89 14 24             	mov    %edx,(%esp)
f010637d:	89 f2                	mov    %esi,%edx
f010637f:	d3 e2                	shl    %cl,%edx
f0106381:	89 f9                	mov    %edi,%ecx
f0106383:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106387:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010638b:	d3 e8                	shr    %cl,%eax
f010638d:	89 e9                	mov    %ebp,%ecx
f010638f:	89 c6                	mov    %eax,%esi
f0106391:	d3 e3                	shl    %cl,%ebx
f0106393:	89 f9                	mov    %edi,%ecx
f0106395:	89 d0                	mov    %edx,%eax
f0106397:	d3 e8                	shr    %cl,%eax
f0106399:	89 e9                	mov    %ebp,%ecx
f010639b:	09 d8                	or     %ebx,%eax
f010639d:	89 d3                	mov    %edx,%ebx
f010639f:	89 f2                	mov    %esi,%edx
f01063a1:	f7 34 24             	divl   (%esp)
f01063a4:	89 d6                	mov    %edx,%esi
f01063a6:	d3 e3                	shl    %cl,%ebx
f01063a8:	f7 64 24 04          	mull   0x4(%esp)
f01063ac:	39 d6                	cmp    %edx,%esi
f01063ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01063b2:	89 d1                	mov    %edx,%ecx
f01063b4:	89 c3                	mov    %eax,%ebx
f01063b6:	72 08                	jb     f01063c0 <__umoddi3+0x110>
f01063b8:	75 11                	jne    f01063cb <__umoddi3+0x11b>
f01063ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01063be:	73 0b                	jae    f01063cb <__umoddi3+0x11b>
f01063c0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01063c4:	1b 14 24             	sbb    (%esp),%edx
f01063c7:	89 d1                	mov    %edx,%ecx
f01063c9:	89 c3                	mov    %eax,%ebx
f01063cb:	8b 54 24 08          	mov    0x8(%esp),%edx
f01063cf:	29 da                	sub    %ebx,%edx
f01063d1:	19 ce                	sbb    %ecx,%esi
f01063d3:	89 f9                	mov    %edi,%ecx
f01063d5:	89 f0                	mov    %esi,%eax
f01063d7:	d3 e0                	shl    %cl,%eax
f01063d9:	89 e9                	mov    %ebp,%ecx
f01063db:	d3 ea                	shr    %cl,%edx
f01063dd:	89 e9                	mov    %ebp,%ecx
f01063df:	d3 ee                	shr    %cl,%esi
f01063e1:	09 d0                	or     %edx,%eax
f01063e3:	89 f2                	mov    %esi,%edx
f01063e5:	83 c4 1c             	add    $0x1c,%esp
f01063e8:	5b                   	pop    %ebx
f01063e9:	5e                   	pop    %esi
f01063ea:	5f                   	pop    %edi
f01063eb:	5d                   	pop    %ebp
f01063ec:	c3                   	ret    
f01063ed:	8d 76 00             	lea    0x0(%esi),%esi
f01063f0:	29 f9                	sub    %edi,%ecx
f01063f2:	19 d6                	sbb    %edx,%esi
f01063f4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01063f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01063fc:	e9 18 ff ff ff       	jmp    f0106319 <__umoddi3+0x69>
