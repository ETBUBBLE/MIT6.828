
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
f0100048:	83 3d 80 1e 21 f0 00 	cmpl   $0x0,0xf0211e80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 1e 21 f0    	mov    %esi,0xf0211e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 21 5d 00 00       	call   f0105d82 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 20 64 10 f0       	push   $0xf0106420
f010006d:	e8 c0 36 00 00       	call   f0103732 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 90 36 00 00       	call   f010370c <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 52 6c 10 f0 	movl   $0xf0106c52,(%esp)
f0100083:	e8 aa 36 00 00       	call   f0103732 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 0a 08 00 00       	call   f010089f <monitor>
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
f01000a1:	e8 96 05 00 00       	call   f010063c <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000a6:	83 ec 08             	sub    $0x8,%esp
f01000a9:	68 ac 1a 00 00       	push   $0x1aac
f01000ae:	68 8c 64 10 f0       	push   $0xf010648c
f01000b3:	e8 7a 36 00 00       	call   f0103732 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000b8:	e8 b3 11 00 00       	call   f0101270 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000bd:	e8 ff 2e 00 00       	call   f0102fc1 <env_init>
	trap_init();
f01000c2:	e8 4f 37 00 00       	call   f0103816 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000c7:	e8 ac 59 00 00       	call   f0105a78 <mp_init>
	lapic_init();
f01000cc:	e8 cc 5c 00 00       	call   f0105d9d <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000d1:	e8 83 35 00 00       	call   f0103659 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000d6:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f01000dd:	e8 0e 5f 00 00       	call   f0105ff0 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000e2:	83 c4 10             	add    $0x10,%esp
f01000e5:	83 3d 88 1e 21 f0 07 	cmpl   $0x7,0xf0211e88
f01000ec:	77 16                	ja     f0100104 <i386_init+0x6a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01000ee:	68 00 70 00 00       	push   $0x7000
f01000f3:	68 44 64 10 f0       	push   $0xf0106444
f01000f8:	6a 57                	push   $0x57
f01000fa:	68 a7 64 10 f0       	push   $0xf01064a7
f01000ff:	e8 3c ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100104:	83 ec 04             	sub    $0x4,%esp
f0100107:	b8 de 59 10 f0       	mov    $0xf01059de,%eax
f010010c:	2d 64 59 10 f0       	sub    $0xf0105964,%eax
f0100111:	50                   	push   %eax
f0100112:	68 64 59 10 f0       	push   $0xf0105964
f0100117:	68 00 70 00 f0       	push   $0xf0007000
f010011c:	e8 8e 56 00 00       	call   f01057af <memmove>
f0100121:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100124:	bb 20 20 21 f0       	mov    $0xf0212020,%ebx
f0100129:	eb 4d                	jmp    f0100178 <i386_init+0xde>
		if (c == cpus + cpunum())  // We've started already.
f010012b:	e8 52 5c 00 00       	call   f0105d82 <cpunum>
f0100130:	6b c0 74             	imul   $0x74,%eax,%eax
f0100133:	05 20 20 21 f0       	add    $0xf0212020,%eax
f0100138:	39 c3                	cmp    %eax,%ebx
f010013a:	74 39                	je     f0100175 <i386_init+0xdb>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010013c:	89 d8                	mov    %ebx,%eax
f010013e:	2d 20 20 21 f0       	sub    $0xf0212020,%eax
f0100143:	c1 f8 02             	sar    $0x2,%eax
f0100146:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010014c:	c1 e0 0f             	shl    $0xf,%eax
f010014f:	05 00 b0 21 f0       	add    $0xf021b000,%eax
f0100154:	a3 84 1e 21 f0       	mov    %eax,0xf0211e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100159:	83 ec 08             	sub    $0x8,%esp
f010015c:	68 00 70 00 00       	push   $0x7000
f0100161:	0f b6 03             	movzbl (%ebx),%eax
f0100164:	50                   	push   %eax
f0100165:	e8 81 5d 00 00       	call   f0105eeb <lapic_startap>
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
f0100178:	6b 05 c4 23 21 f0 74 	imul   $0x74,0xf02123c4,%eax
f010017f:	05 20 20 21 f0       	add    $0xf0212020,%eax
f0100184:	39 c3                	cmp    %eax,%ebx
f0100186:	72 a3                	jb     f010012b <i386_init+0x91>
	lock_kernel();
	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f0100188:	83 ec 08             	sub    $0x8,%esp
f010018b:	6a 01                	push   $0x1
f010018d:	68 a8 08 1d f0       	push   $0xf01d08a8
f0100192:	e8 c1 2f 00 00       	call   f0103158 <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100197:	83 c4 08             	add    $0x8,%esp
f010019a:	6a 00                	push   $0x0
f010019c:	68 50 08 20 f0       	push   $0xf0200850
f01001a1:	e8 b2 2f 00 00       	call   f0103158 <env_create>
	// ENV_CREATE(user_yield, ENV_TYPE_USER);

#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001a6:	e8 35 04 00 00       	call   f01005e0 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01001ab:	e8 aa 43 00 00       	call   f010455a <sched_yield>

f01001b0 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001b0:	55                   	push   %ebp
f01001b1:	89 e5                	mov    %esp,%ebp
f01001b3:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001b6:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001bb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001c0:	77 12                	ja     f01001d4 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001c2:	50                   	push   %eax
f01001c3:	68 68 64 10 f0       	push   $0xf0106468
f01001c8:	6a 6e                	push   $0x6e
f01001ca:	68 a7 64 10 f0       	push   $0xf01064a7
f01001cf:	e8 6c fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001d4:	05 00 00 00 10       	add    $0x10000000,%eax
f01001d9:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001dc:	e8 a1 5b 00 00       	call   f0105d82 <cpunum>
f01001e1:	83 ec 08             	sub    $0x8,%esp
f01001e4:	50                   	push   %eax
f01001e5:	68 b3 64 10 f0       	push   $0xf01064b3
f01001ea:	e8 43 35 00 00       	call   f0103732 <cprintf>

	lapic_init();
f01001ef:	e8 a9 5b 00 00       	call   f0105d9d <lapic_init>
	env_init_percpu();
f01001f4:	e8 98 2d 00 00       	call   f0102f91 <env_init_percpu>
	trap_init_percpu();
f01001f9:	e8 48 35 00 00       	call   f0103746 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001fe:	e8 7f 5b 00 00       	call   f0105d82 <cpunum>
f0100203:	6b d0 74             	imul   $0x74,%eax,%edx
f0100206:	81 c2 20 20 21 f0    	add    $0xf0212020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010020c:	b8 01 00 00 00       	mov    $0x1,%eax
f0100211:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100215:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f010021c:	e8 cf 5d 00 00       	call   f0105ff0 <spin_lock>
	//
	// Your code here:
	lock_kernel();
	// Remove this after you finish Exercise 6
	//for (;;);
	sched_yield();
f0100221:	e8 34 43 00 00       	call   f010455a <sched_yield>

f0100226 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100226:	55                   	push   %ebp
f0100227:	89 e5                	mov    %esp,%ebp
f0100229:	53                   	push   %ebx
f010022a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010022d:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100230:	ff 75 0c             	pushl  0xc(%ebp)
f0100233:	ff 75 08             	pushl  0x8(%ebp)
f0100236:	68 c9 64 10 f0       	push   $0xf01064c9
f010023b:	e8 f2 34 00 00       	call   f0103732 <cprintf>
	vcprintf(fmt, ap);
f0100240:	83 c4 08             	add    $0x8,%esp
f0100243:	53                   	push   %ebx
f0100244:	ff 75 10             	pushl  0x10(%ebp)
f0100247:	e8 c0 34 00 00       	call   f010370c <vcprintf>
	cprintf("\n");
f010024c:	c7 04 24 52 6c 10 f0 	movl   $0xf0106c52,(%esp)
f0100253:	e8 da 34 00 00       	call   f0103732 <cprintf>
	va_end(ap);
}
f0100258:	83 c4 10             	add    $0x10,%esp
f010025b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010025e:	c9                   	leave  
f010025f:	c3                   	ret    

f0100260 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100260:	55                   	push   %ebp
f0100261:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100263:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100268:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100269:	a8 01                	test   $0x1,%al
f010026b:	74 0b                	je     f0100278 <serial_proc_data+0x18>
f010026d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100272:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100273:	0f b6 c0             	movzbl %al,%eax
f0100276:	eb 05                	jmp    f010027d <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100278:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010027d:	5d                   	pop    %ebp
f010027e:	c3                   	ret    

f010027f <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010027f:	55                   	push   %ebp
f0100280:	89 e5                	mov    %esp,%ebp
f0100282:	53                   	push   %ebx
f0100283:	83 ec 04             	sub    $0x4,%esp
f0100286:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100288:	eb 2b                	jmp    f01002b5 <cons_intr+0x36>
		if (c == 0)
f010028a:	85 c0                	test   %eax,%eax
f010028c:	74 27                	je     f01002b5 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010028e:	8b 0d 24 12 21 f0    	mov    0xf0211224,%ecx
f0100294:	8d 51 01             	lea    0x1(%ecx),%edx
f0100297:	89 15 24 12 21 f0    	mov    %edx,0xf0211224
f010029d:	88 81 20 10 21 f0    	mov    %al,-0xfdeefe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002a3:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002a9:	75 0a                	jne    f01002b5 <cons_intr+0x36>
			cons.wpos = 0;
f01002ab:	c7 05 24 12 21 f0 00 	movl   $0x0,0xf0211224
f01002b2:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002b5:	ff d3                	call   *%ebx
f01002b7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002ba:	75 ce                	jne    f010028a <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002bc:	83 c4 04             	add    $0x4,%esp
f01002bf:	5b                   	pop    %ebx
f01002c0:	5d                   	pop    %ebp
f01002c1:	c3                   	ret    

f01002c2 <kbd_proc_data>:
f01002c2:	ba 64 00 00 00       	mov    $0x64,%edx
f01002c7:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01002c8:	a8 01                	test   $0x1,%al
f01002ca:	0f 84 f8 00 00 00    	je     f01003c8 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01002d0:	a8 20                	test   $0x20,%al
f01002d2:	0f 85 f6 00 00 00    	jne    f01003ce <kbd_proc_data+0x10c>
f01002d8:	ba 60 00 00 00       	mov    $0x60,%edx
f01002dd:	ec                   	in     (%dx),%al
f01002de:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002e0:	3c e0                	cmp    $0xe0,%al
f01002e2:	75 0d                	jne    f01002f1 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01002e4:	83 0d 00 10 21 f0 40 	orl    $0x40,0xf0211000
		return 0;
f01002eb:	b8 00 00 00 00       	mov    $0x0,%eax
f01002f0:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01002f1:	55                   	push   %ebp
f01002f2:	89 e5                	mov    %esp,%ebp
f01002f4:	53                   	push   %ebx
f01002f5:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01002f8:	84 c0                	test   %al,%al
f01002fa:	79 36                	jns    f0100332 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01002fc:	8b 0d 00 10 21 f0    	mov    0xf0211000,%ecx
f0100302:	89 cb                	mov    %ecx,%ebx
f0100304:	83 e3 40             	and    $0x40,%ebx
f0100307:	83 e0 7f             	and    $0x7f,%eax
f010030a:	85 db                	test   %ebx,%ebx
f010030c:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010030f:	0f b6 d2             	movzbl %dl,%edx
f0100312:	0f b6 82 40 66 10 f0 	movzbl -0xfef99c0(%edx),%eax
f0100319:	83 c8 40             	or     $0x40,%eax
f010031c:	0f b6 c0             	movzbl %al,%eax
f010031f:	f7 d0                	not    %eax
f0100321:	21 c8                	and    %ecx,%eax
f0100323:	a3 00 10 21 f0       	mov    %eax,0xf0211000
		return 0;
f0100328:	b8 00 00 00 00       	mov    $0x0,%eax
f010032d:	e9 a4 00 00 00       	jmp    f01003d6 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100332:	8b 0d 00 10 21 f0    	mov    0xf0211000,%ecx
f0100338:	f6 c1 40             	test   $0x40,%cl
f010033b:	74 0e                	je     f010034b <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010033d:	83 c8 80             	or     $0xffffff80,%eax
f0100340:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100342:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100345:	89 0d 00 10 21 f0    	mov    %ecx,0xf0211000
	}

	shift |= shiftcode[data];
f010034b:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010034e:	0f b6 82 40 66 10 f0 	movzbl -0xfef99c0(%edx),%eax
f0100355:	0b 05 00 10 21 f0    	or     0xf0211000,%eax
f010035b:	0f b6 8a 40 65 10 f0 	movzbl -0xfef9ac0(%edx),%ecx
f0100362:	31 c8                	xor    %ecx,%eax
f0100364:	a3 00 10 21 f0       	mov    %eax,0xf0211000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100369:	89 c1                	mov    %eax,%ecx
f010036b:	83 e1 03             	and    $0x3,%ecx
f010036e:	8b 0c 8d 20 65 10 f0 	mov    -0xfef9ae0(,%ecx,4),%ecx
f0100375:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100379:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010037c:	a8 08                	test   $0x8,%al
f010037e:	74 1b                	je     f010039b <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f0100380:	89 da                	mov    %ebx,%edx
f0100382:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100385:	83 f9 19             	cmp    $0x19,%ecx
f0100388:	77 05                	ja     f010038f <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f010038a:	83 eb 20             	sub    $0x20,%ebx
f010038d:	eb 0c                	jmp    f010039b <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f010038f:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100392:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100395:	83 fa 19             	cmp    $0x19,%edx
f0100398:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010039b:	f7 d0                	not    %eax
f010039d:	a8 06                	test   $0x6,%al
f010039f:	75 33                	jne    f01003d4 <kbd_proc_data+0x112>
f01003a1:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003a7:	75 2b                	jne    f01003d4 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01003a9:	83 ec 0c             	sub    $0xc,%esp
f01003ac:	68 e3 64 10 f0       	push   $0xf01064e3
f01003b1:	e8 7c 33 00 00       	call   f0103732 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b6:	ba 92 00 00 00       	mov    $0x92,%edx
f01003bb:	b8 03 00 00 00       	mov    $0x3,%eax
f01003c0:	ee                   	out    %al,(%dx)
f01003c1:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003c4:	89 d8                	mov    %ebx,%eax
f01003c6:	eb 0e                	jmp    f01003d6 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01003c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01003cd:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01003ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003d3:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003d4:	89 d8                	mov    %ebx,%eax
}
f01003d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003d9:	c9                   	leave  
f01003da:	c3                   	ret    

f01003db <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003db:	55                   	push   %ebp
f01003dc:	89 e5                	mov    %esp,%ebp
f01003de:	57                   	push   %edi
f01003df:	56                   	push   %esi
f01003e0:	53                   	push   %ebx
f01003e1:	83 ec 1c             	sub    $0x1c,%esp
f01003e4:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003e6:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003eb:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003f0:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003f5:	eb 09                	jmp    f0100400 <cons_putc+0x25>
f01003f7:	89 ca                	mov    %ecx,%edx
f01003f9:	ec                   	in     (%dx),%al
f01003fa:	ec                   	in     (%dx),%al
f01003fb:	ec                   	in     (%dx),%al
f01003fc:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01003fd:	83 c3 01             	add    $0x1,%ebx
f0100400:	89 f2                	mov    %esi,%edx
f0100402:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100403:	a8 20                	test   $0x20,%al
f0100405:	75 08                	jne    f010040f <cons_putc+0x34>
f0100407:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010040d:	7e e8                	jle    f01003f7 <cons_putc+0x1c>
f010040f:	89 f8                	mov    %edi,%eax
f0100411:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100414:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100419:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010041a:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010041f:	be 79 03 00 00       	mov    $0x379,%esi
f0100424:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100429:	eb 09                	jmp    f0100434 <cons_putc+0x59>
f010042b:	89 ca                	mov    %ecx,%edx
f010042d:	ec                   	in     (%dx),%al
f010042e:	ec                   	in     (%dx),%al
f010042f:	ec                   	in     (%dx),%al
f0100430:	ec                   	in     (%dx),%al
f0100431:	83 c3 01             	add    $0x1,%ebx
f0100434:	89 f2                	mov    %esi,%edx
f0100436:	ec                   	in     (%dx),%al
f0100437:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010043d:	7f 04                	jg     f0100443 <cons_putc+0x68>
f010043f:	84 c0                	test   %al,%al
f0100441:	79 e8                	jns    f010042b <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100443:	ba 78 03 00 00       	mov    $0x378,%edx
f0100448:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010044c:	ee                   	out    %al,(%dx)
f010044d:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100452:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100457:	ee                   	out    %al,(%dx)
f0100458:	b8 08 00 00 00       	mov    $0x8,%eax
f010045d:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010045e:	89 fa                	mov    %edi,%edx
f0100460:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100466:	89 f8                	mov    %edi,%eax
f0100468:	80 cc 07             	or     $0x7,%ah
f010046b:	85 d2                	test   %edx,%edx
f010046d:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100470:	89 f8                	mov    %edi,%eax
f0100472:	0f b6 c0             	movzbl %al,%eax
f0100475:	83 f8 09             	cmp    $0x9,%eax
f0100478:	74 74                	je     f01004ee <cons_putc+0x113>
f010047a:	83 f8 09             	cmp    $0x9,%eax
f010047d:	7f 0a                	jg     f0100489 <cons_putc+0xae>
f010047f:	83 f8 08             	cmp    $0x8,%eax
f0100482:	74 14                	je     f0100498 <cons_putc+0xbd>
f0100484:	e9 99 00 00 00       	jmp    f0100522 <cons_putc+0x147>
f0100489:	83 f8 0a             	cmp    $0xa,%eax
f010048c:	74 3a                	je     f01004c8 <cons_putc+0xed>
f010048e:	83 f8 0d             	cmp    $0xd,%eax
f0100491:	74 3d                	je     f01004d0 <cons_putc+0xf5>
f0100493:	e9 8a 00 00 00       	jmp    f0100522 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100498:	0f b7 05 28 12 21 f0 	movzwl 0xf0211228,%eax
f010049f:	66 85 c0             	test   %ax,%ax
f01004a2:	0f 84 e6 00 00 00    	je     f010058e <cons_putc+0x1b3>
			crt_pos--;
f01004a8:	83 e8 01             	sub    $0x1,%eax
f01004ab:	66 a3 28 12 21 f0    	mov    %ax,0xf0211228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004b1:	0f b7 c0             	movzwl %ax,%eax
f01004b4:	66 81 e7 00 ff       	and    $0xff00,%di
f01004b9:	83 cf 20             	or     $0x20,%edi
f01004bc:	8b 15 2c 12 21 f0    	mov    0xf021122c,%edx
f01004c2:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004c6:	eb 78                	jmp    f0100540 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004c8:	66 83 05 28 12 21 f0 	addw   $0x50,0xf0211228
f01004cf:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004d0:	0f b7 05 28 12 21 f0 	movzwl 0xf0211228,%eax
f01004d7:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004dd:	c1 e8 16             	shr    $0x16,%eax
f01004e0:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004e3:	c1 e0 04             	shl    $0x4,%eax
f01004e6:	66 a3 28 12 21 f0    	mov    %ax,0xf0211228
f01004ec:	eb 52                	jmp    f0100540 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01004ee:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f3:	e8 e3 fe ff ff       	call   f01003db <cons_putc>
		cons_putc(' ');
f01004f8:	b8 20 00 00 00       	mov    $0x20,%eax
f01004fd:	e8 d9 fe ff ff       	call   f01003db <cons_putc>
		cons_putc(' ');
f0100502:	b8 20 00 00 00       	mov    $0x20,%eax
f0100507:	e8 cf fe ff ff       	call   f01003db <cons_putc>
		cons_putc(' ');
f010050c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100511:	e8 c5 fe ff ff       	call   f01003db <cons_putc>
		cons_putc(' ');
f0100516:	b8 20 00 00 00       	mov    $0x20,%eax
f010051b:	e8 bb fe ff ff       	call   f01003db <cons_putc>
f0100520:	eb 1e                	jmp    f0100540 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100522:	0f b7 05 28 12 21 f0 	movzwl 0xf0211228,%eax
f0100529:	8d 50 01             	lea    0x1(%eax),%edx
f010052c:	66 89 15 28 12 21 f0 	mov    %dx,0xf0211228
f0100533:	0f b7 c0             	movzwl %ax,%eax
f0100536:	8b 15 2c 12 21 f0    	mov    0xf021122c,%edx
f010053c:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100540:	66 81 3d 28 12 21 f0 	cmpw   $0x7cf,0xf0211228
f0100547:	cf 07 
f0100549:	76 43                	jbe    f010058e <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010054b:	a1 2c 12 21 f0       	mov    0xf021122c,%eax
f0100550:	83 ec 04             	sub    $0x4,%esp
f0100553:	68 00 0f 00 00       	push   $0xf00
f0100558:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010055e:	52                   	push   %edx
f010055f:	50                   	push   %eax
f0100560:	e8 4a 52 00 00       	call   f01057af <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100565:	8b 15 2c 12 21 f0    	mov    0xf021122c,%edx
f010056b:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100571:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100577:	83 c4 10             	add    $0x10,%esp
f010057a:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010057f:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100582:	39 d0                	cmp    %edx,%eax
f0100584:	75 f4                	jne    f010057a <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100586:	66 83 2d 28 12 21 f0 	subw   $0x50,0xf0211228
f010058d:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010058e:	8b 0d 30 12 21 f0    	mov    0xf0211230,%ecx
f0100594:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100599:	89 ca                	mov    %ecx,%edx
f010059b:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010059c:	0f b7 1d 28 12 21 f0 	movzwl 0xf0211228,%ebx
f01005a3:	8d 71 01             	lea    0x1(%ecx),%esi
f01005a6:	89 d8                	mov    %ebx,%eax
f01005a8:	66 c1 e8 08          	shr    $0x8,%ax
f01005ac:	89 f2                	mov    %esi,%edx
f01005ae:	ee                   	out    %al,(%dx)
f01005af:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005b4:	89 ca                	mov    %ecx,%edx
f01005b6:	ee                   	out    %al,(%dx)
f01005b7:	89 d8                	mov    %ebx,%eax
f01005b9:	89 f2                	mov    %esi,%edx
f01005bb:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005bf:	5b                   	pop    %ebx
f01005c0:	5e                   	pop    %esi
f01005c1:	5f                   	pop    %edi
f01005c2:	5d                   	pop    %ebp
f01005c3:	c3                   	ret    

f01005c4 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005c4:	80 3d 34 12 21 f0 00 	cmpb   $0x0,0xf0211234
f01005cb:	74 11                	je     f01005de <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005cd:	55                   	push   %ebp
f01005ce:	89 e5                	mov    %esp,%ebp
f01005d0:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005d3:	b8 60 02 10 f0       	mov    $0xf0100260,%eax
f01005d8:	e8 a2 fc ff ff       	call   f010027f <cons_intr>
}
f01005dd:	c9                   	leave  
f01005de:	f3 c3                	repz ret 

f01005e0 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005e0:	55                   	push   %ebp
f01005e1:	89 e5                	mov    %esp,%ebp
f01005e3:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005e6:	b8 c2 02 10 f0       	mov    $0xf01002c2,%eax
f01005eb:	e8 8f fc ff ff       	call   f010027f <cons_intr>
}
f01005f0:	c9                   	leave  
f01005f1:	c3                   	ret    

f01005f2 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005f2:	55                   	push   %ebp
f01005f3:	89 e5                	mov    %esp,%ebp
f01005f5:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005f8:	e8 c7 ff ff ff       	call   f01005c4 <serial_intr>
	kbd_intr();
f01005fd:	e8 de ff ff ff       	call   f01005e0 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100602:	a1 20 12 21 f0       	mov    0xf0211220,%eax
f0100607:	3b 05 24 12 21 f0    	cmp    0xf0211224,%eax
f010060d:	74 26                	je     f0100635 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f010060f:	8d 50 01             	lea    0x1(%eax),%edx
f0100612:	89 15 20 12 21 f0    	mov    %edx,0xf0211220
f0100618:	0f b6 88 20 10 21 f0 	movzbl -0xfdeefe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f010061f:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100621:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100627:	75 11                	jne    f010063a <cons_getc+0x48>
			cons.rpos = 0;
f0100629:	c7 05 20 12 21 f0 00 	movl   $0x0,0xf0211220
f0100630:	00 00 00 
f0100633:	eb 05                	jmp    f010063a <cons_getc+0x48>
		return c;
	}
	return 0;
f0100635:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010063a:	c9                   	leave  
f010063b:	c3                   	ret    

f010063c <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010063c:	55                   	push   %ebp
f010063d:	89 e5                	mov    %esp,%ebp
f010063f:	57                   	push   %edi
f0100640:	56                   	push   %esi
f0100641:	53                   	push   %ebx
f0100642:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100645:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010064c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100653:	5a a5 
	if (*cp != 0xA55A) {
f0100655:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010065c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100660:	74 11                	je     f0100673 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100662:	c7 05 30 12 21 f0 b4 	movl   $0x3b4,0xf0211230
f0100669:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010066c:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100671:	eb 16                	jmp    f0100689 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100673:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010067a:	c7 05 30 12 21 f0 d4 	movl   $0x3d4,0xf0211230
f0100681:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100684:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100689:	8b 3d 30 12 21 f0    	mov    0xf0211230,%edi
f010068f:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100694:	89 fa                	mov    %edi,%edx
f0100696:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100697:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010069a:	89 da                	mov    %ebx,%edx
f010069c:	ec                   	in     (%dx),%al
f010069d:	0f b6 c8             	movzbl %al,%ecx
f01006a0:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006a3:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006a8:	89 fa                	mov    %edi,%edx
f01006aa:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ab:	89 da                	mov    %ebx,%edx
f01006ad:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006ae:	89 35 2c 12 21 f0    	mov    %esi,0xf021122c
	crt_pos = pos;
f01006b4:	0f b6 c0             	movzbl %al,%eax
f01006b7:	09 c8                	or     %ecx,%eax
f01006b9:	66 a3 28 12 21 f0    	mov    %ax,0xf0211228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006bf:	e8 1c ff ff ff       	call   f01005e0 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006c4:	83 ec 0c             	sub    $0xc,%esp
f01006c7:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f01006ce:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006d3:	50                   	push   %eax
f01006d4:	e8 08 2f 00 00       	call   f01035e1 <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006d9:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006de:	b8 00 00 00 00       	mov    $0x0,%eax
f01006e3:	89 f2                	mov    %esi,%edx
f01006e5:	ee                   	out    %al,(%dx)
f01006e6:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006eb:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006f0:	ee                   	out    %al,(%dx)
f01006f1:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01006f6:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006fb:	89 da                	mov    %ebx,%edx
f01006fd:	ee                   	out    %al,(%dx)
f01006fe:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100703:	b8 00 00 00 00       	mov    $0x0,%eax
f0100708:	ee                   	out    %al,(%dx)
f0100709:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010070e:	b8 03 00 00 00       	mov    $0x3,%eax
f0100713:	ee                   	out    %al,(%dx)
f0100714:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100719:	b8 00 00 00 00       	mov    $0x0,%eax
f010071e:	ee                   	out    %al,(%dx)
f010071f:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100724:	b8 01 00 00 00       	mov    $0x1,%eax
f0100729:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010072a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010072f:	ec                   	in     (%dx),%al
f0100730:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100732:	83 c4 10             	add    $0x10,%esp
f0100735:	3c ff                	cmp    $0xff,%al
f0100737:	0f 95 05 34 12 21 f0 	setne  0xf0211234
f010073e:	89 f2                	mov    %esi,%edx
f0100740:	ec                   	in     (%dx),%al
f0100741:	89 da                	mov    %ebx,%edx
f0100743:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f0100744:	80 f9 ff             	cmp    $0xff,%cl
f0100747:	74 21                	je     f010076a <cons_init+0x12e>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100749:	83 ec 0c             	sub    $0xc,%esp
f010074c:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f0100753:	25 ef ff 00 00       	and    $0xffef,%eax
f0100758:	50                   	push   %eax
f0100759:	e8 83 2e 00 00       	call   f01035e1 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010075e:	83 c4 10             	add    $0x10,%esp
f0100761:	80 3d 34 12 21 f0 00 	cmpb   $0x0,0xf0211234
f0100768:	75 10                	jne    f010077a <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f010076a:	83 ec 0c             	sub    $0xc,%esp
f010076d:	68 ef 64 10 f0       	push   $0xf01064ef
f0100772:	e8 bb 2f 00 00       	call   f0103732 <cprintf>
f0100777:	83 c4 10             	add    $0x10,%esp
}
f010077a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010077d:	5b                   	pop    %ebx
f010077e:	5e                   	pop    %esi
f010077f:	5f                   	pop    %edi
f0100780:	5d                   	pop    %ebp
f0100781:	c3                   	ret    

f0100782 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100782:	55                   	push   %ebp
f0100783:	89 e5                	mov    %esp,%ebp
f0100785:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100788:	8b 45 08             	mov    0x8(%ebp),%eax
f010078b:	e8 4b fc ff ff       	call   f01003db <cons_putc>
}
f0100790:	c9                   	leave  
f0100791:	c3                   	ret    

f0100792 <getchar>:

int
getchar(void)
{
f0100792:	55                   	push   %ebp
f0100793:	89 e5                	mov    %esp,%ebp
f0100795:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100798:	e8 55 fe ff ff       	call   f01005f2 <cons_getc>
f010079d:	85 c0                	test   %eax,%eax
f010079f:	74 f7                	je     f0100798 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007a1:	c9                   	leave  
f01007a2:	c3                   	ret    

f01007a3 <iscons>:

int
iscons(int fdnum)
{
f01007a3:	55                   	push   %ebp
f01007a4:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007a6:	b8 01 00 00 00       	mov    $0x1,%eax
f01007ab:	5d                   	pop    %ebp
f01007ac:	c3                   	ret    

f01007ad <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007ad:	55                   	push   %ebp
f01007ae:	89 e5                	mov    %esp,%ebp
f01007b0:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007b3:	68 40 67 10 f0       	push   $0xf0106740
f01007b8:	68 5e 67 10 f0       	push   $0xf010675e
f01007bd:	68 63 67 10 f0       	push   $0xf0106763
f01007c2:	e8 6b 2f 00 00       	call   f0103732 <cprintf>
f01007c7:	83 c4 0c             	add    $0xc,%esp
f01007ca:	68 cc 67 10 f0       	push   $0xf01067cc
f01007cf:	68 6c 67 10 f0       	push   $0xf010676c
f01007d4:	68 63 67 10 f0       	push   $0xf0106763
f01007d9:	e8 54 2f 00 00       	call   f0103732 <cprintf>
	return 0;
}
f01007de:	b8 00 00 00 00       	mov    $0x0,%eax
f01007e3:	c9                   	leave  
f01007e4:	c3                   	ret    

f01007e5 <mon_kerninfo>:


int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007e5:	55                   	push   %ebp
f01007e6:	89 e5                	mov    %esp,%ebp
f01007e8:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007eb:	68 75 67 10 f0       	push   $0xf0106775
f01007f0:	e8 3d 2f 00 00       	call   f0103732 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007f5:	83 c4 08             	add    $0x8,%esp
f01007f8:	68 0c 00 10 00       	push   $0x10000c
f01007fd:	68 f4 67 10 f0       	push   $0xf01067f4
f0100802:	e8 2b 2f 00 00       	call   f0103732 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100807:	83 c4 0c             	add    $0xc,%esp
f010080a:	68 0c 00 10 00       	push   $0x10000c
f010080f:	68 0c 00 10 f0       	push   $0xf010000c
f0100814:	68 1c 68 10 f0       	push   $0xf010681c
f0100819:	e8 14 2f 00 00       	call   f0103732 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010081e:	83 c4 0c             	add    $0xc,%esp
f0100821:	68 01 64 10 00       	push   $0x106401
f0100826:	68 01 64 10 f0       	push   $0xf0106401
f010082b:	68 40 68 10 f0       	push   $0xf0106840
f0100830:	e8 fd 2e 00 00       	call   f0103732 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100835:	83 c4 0c             	add    $0xc,%esp
f0100838:	68 00 10 21 00       	push   $0x211000
f010083d:	68 00 10 21 f0       	push   $0xf0211000
f0100842:	68 64 68 10 f0       	push   $0xf0106864
f0100847:	e8 e6 2e 00 00       	call   f0103732 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010084c:	83 c4 0c             	add    $0xc,%esp
f010084f:	68 08 30 25 00       	push   $0x253008
f0100854:	68 08 30 25 f0       	push   $0xf0253008
f0100859:	68 88 68 10 f0       	push   $0xf0106888
f010085e:	e8 cf 2e 00 00       	call   f0103732 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100863:	b8 07 34 25 f0       	mov    $0xf0253407,%eax
f0100868:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010086d:	83 c4 08             	add    $0x8,%esp
f0100870:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100875:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010087b:	85 c0                	test   %eax,%eax
f010087d:	0f 48 c2             	cmovs  %edx,%eax
f0100880:	c1 f8 0a             	sar    $0xa,%eax
f0100883:	50                   	push   %eax
f0100884:	68 ac 68 10 f0       	push   $0xf01068ac
f0100889:	e8 a4 2e 00 00       	call   f0103732 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010088e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100893:	c9                   	leave  
f0100894:	c3                   	ret    

f0100895 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100895:	55                   	push   %ebp
f0100896:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f0100898:	b8 00 00 00 00       	mov    $0x0,%eax
f010089d:	5d                   	pop    %ebp
f010089e:	c3                   	ret    

f010089f <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010089f:	55                   	push   %ebp
f01008a0:	89 e5                	mov    %esp,%ebp
f01008a2:	57                   	push   %edi
f01008a3:	56                   	push   %esi
f01008a4:	53                   	push   %ebx
f01008a5:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008a8:	68 d8 68 10 f0       	push   $0xf01068d8
f01008ad:	e8 80 2e 00 00       	call   f0103732 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008b2:	c7 04 24 fc 68 10 f0 	movl   $0xf01068fc,(%esp)
f01008b9:	e8 74 2e 00 00       	call   f0103732 <cprintf>

	if (tf != NULL)
f01008be:	83 c4 10             	add    $0x10,%esp
f01008c1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01008c5:	74 0e                	je     f01008d5 <monitor+0x36>
		print_trapframe(tf);
f01008c7:	83 ec 0c             	sub    $0xc,%esp
f01008ca:	ff 75 08             	pushl  0x8(%ebp)
f01008cd:	e8 c0 35 00 00       	call   f0103e92 <print_trapframe>
f01008d2:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01008d5:	83 ec 0c             	sub    $0xc,%esp
f01008d8:	68 8e 67 10 f0       	push   $0xf010678e
f01008dd:	e8 11 4c 00 00       	call   f01054f3 <readline>
f01008e2:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01008e4:	83 c4 10             	add    $0x10,%esp
f01008e7:	85 c0                	test   %eax,%eax
f01008e9:	74 ea                	je     f01008d5 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01008eb:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01008f2:	be 00 00 00 00       	mov    $0x0,%esi
f01008f7:	eb 0a                	jmp    f0100903 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01008f9:	c6 03 00             	movb   $0x0,(%ebx)
f01008fc:	89 f7                	mov    %esi,%edi
f01008fe:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100901:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100903:	0f b6 03             	movzbl (%ebx),%eax
f0100906:	84 c0                	test   %al,%al
f0100908:	74 63                	je     f010096d <monitor+0xce>
f010090a:	83 ec 08             	sub    $0x8,%esp
f010090d:	0f be c0             	movsbl %al,%eax
f0100910:	50                   	push   %eax
f0100911:	68 92 67 10 f0       	push   $0xf0106792
f0100916:	e8 0a 4e 00 00       	call   f0105725 <strchr>
f010091b:	83 c4 10             	add    $0x10,%esp
f010091e:	85 c0                	test   %eax,%eax
f0100920:	75 d7                	jne    f01008f9 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100922:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100925:	74 46                	je     f010096d <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100927:	83 fe 0f             	cmp    $0xf,%esi
f010092a:	75 14                	jne    f0100940 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010092c:	83 ec 08             	sub    $0x8,%esp
f010092f:	6a 10                	push   $0x10
f0100931:	68 97 67 10 f0       	push   $0xf0106797
f0100936:	e8 f7 2d 00 00       	call   f0103732 <cprintf>
f010093b:	83 c4 10             	add    $0x10,%esp
f010093e:	eb 95                	jmp    f01008d5 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100940:	8d 7e 01             	lea    0x1(%esi),%edi
f0100943:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100947:	eb 03                	jmp    f010094c <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100949:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010094c:	0f b6 03             	movzbl (%ebx),%eax
f010094f:	84 c0                	test   %al,%al
f0100951:	74 ae                	je     f0100901 <monitor+0x62>
f0100953:	83 ec 08             	sub    $0x8,%esp
f0100956:	0f be c0             	movsbl %al,%eax
f0100959:	50                   	push   %eax
f010095a:	68 92 67 10 f0       	push   $0xf0106792
f010095f:	e8 c1 4d 00 00       	call   f0105725 <strchr>
f0100964:	83 c4 10             	add    $0x10,%esp
f0100967:	85 c0                	test   %eax,%eax
f0100969:	74 de                	je     f0100949 <monitor+0xaa>
f010096b:	eb 94                	jmp    f0100901 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f010096d:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100974:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100975:	85 f6                	test   %esi,%esi
f0100977:	0f 84 58 ff ff ff    	je     f01008d5 <monitor+0x36>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010097d:	83 ec 08             	sub    $0x8,%esp
f0100980:	68 5e 67 10 f0       	push   $0xf010675e
f0100985:	ff 75 a8             	pushl  -0x58(%ebp)
f0100988:	e8 3a 4d 00 00       	call   f01056c7 <strcmp>
f010098d:	83 c4 10             	add    $0x10,%esp
f0100990:	85 c0                	test   %eax,%eax
f0100992:	74 1e                	je     f01009b2 <monitor+0x113>
f0100994:	83 ec 08             	sub    $0x8,%esp
f0100997:	68 6c 67 10 f0       	push   $0xf010676c
f010099c:	ff 75 a8             	pushl  -0x58(%ebp)
f010099f:	e8 23 4d 00 00       	call   f01056c7 <strcmp>
f01009a4:	83 c4 10             	add    $0x10,%esp
f01009a7:	85 c0                	test   %eax,%eax
f01009a9:	75 2f                	jne    f01009da <monitor+0x13b>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009ab:	b8 01 00 00 00       	mov    $0x1,%eax
f01009b0:	eb 05                	jmp    f01009b7 <monitor+0x118>
		if (strcmp(argv[0], commands[i].name) == 0)
f01009b2:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f01009b7:	83 ec 04             	sub    $0x4,%esp
f01009ba:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01009bd:	01 d0                	add    %edx,%eax
f01009bf:	ff 75 08             	pushl  0x8(%ebp)
f01009c2:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f01009c5:	51                   	push   %ecx
f01009c6:	56                   	push   %esi
f01009c7:	ff 14 85 2c 69 10 f0 	call   *-0xfef96d4(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01009ce:	83 c4 10             	add    $0x10,%esp
f01009d1:	85 c0                	test   %eax,%eax
f01009d3:	78 1d                	js     f01009f2 <monitor+0x153>
f01009d5:	e9 fb fe ff ff       	jmp    f01008d5 <monitor+0x36>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01009da:	83 ec 08             	sub    $0x8,%esp
f01009dd:	ff 75 a8             	pushl  -0x58(%ebp)
f01009e0:	68 b4 67 10 f0       	push   $0xf01067b4
f01009e5:	e8 48 2d 00 00       	call   f0103732 <cprintf>
f01009ea:	83 c4 10             	add    $0x10,%esp
f01009ed:	e9 e3 fe ff ff       	jmp    f01008d5 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01009f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009f5:	5b                   	pop    %ebx
f01009f6:	5e                   	pop    %esi
f01009f7:	5f                   	pop    %edi
f01009f8:	5d                   	pop    %ebp
f01009f9:	c3                   	ret    

f01009fa <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f01009fa:	55                   	push   %ebp
f01009fb:	89 e5                	mov    %esp,%ebp
f01009fd:	56                   	push   %esi
f01009fe:	53                   	push   %ebx
f01009ff:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a01:	83 ec 0c             	sub    $0xc,%esp
f0100a04:	50                   	push   %eax
f0100a05:	e8 a9 2b 00 00       	call   f01035b3 <mc146818_read>
f0100a0a:	89 c6                	mov    %eax,%esi
f0100a0c:	83 c3 01             	add    $0x1,%ebx
f0100a0f:	89 1c 24             	mov    %ebx,(%esp)
f0100a12:	e8 9c 2b 00 00       	call   f01035b3 <mc146818_read>
f0100a17:	c1 e0 08             	shl    $0x8,%eax
f0100a1a:	09 f0                	or     %esi,%eax
}
f0100a1c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100a1f:	5b                   	pop    %ebx
f0100a20:	5e                   	pop    %esi
f0100a21:	5d                   	pop    %ebp
f0100a22:	c3                   	ret    

f0100a23 <boot_alloc>:
// before the page_free_list list has been set up.
// Note that when this function is called, we are still using entry_pgdir,
// which only maps the first 4MB of physical memory.
static void *
boot_alloc(uint32_t n)
{
f0100a23:	55                   	push   %ebp
f0100a24:	89 e5                	mov    %esp,%ebp
f0100a26:	53                   	push   %ebx
f0100a27:	83 ec 04             	sub    $0x4,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a2a:	83 3d 3c 12 21 f0 00 	cmpl   $0x0,0xf021123c
f0100a31:	75 11                	jne    f0100a44 <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a33:	ba 07 40 25 f0       	mov    $0xf0254007,%edx
f0100a38:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a3e:	89 15 3c 12 21 f0    	mov    %edx,0xf021123c
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100a44:	8b 1d 3c 12 21 f0    	mov    0xf021123c,%ebx
	
	nextfree=ROUNDUP(nextfree+n,PGSIZE);
f0100a4a:	8d 94 03 ff 0f 00 00 	lea    0xfff(%ebx,%eax,1),%edx
f0100a51:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a57:	89 15 3c 12 21 f0    	mov    %edx,0xf021123c
	if((uint32_t)nextfree - KERNBASE > (npages*PGSIZE))panic("Out of memory!\n");
f0100a5d:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100a63:	8b 0d 88 1e 21 f0    	mov    0xf0211e88,%ecx
f0100a69:	c1 e1 0c             	shl    $0xc,%ecx
f0100a6c:	39 ca                	cmp    %ecx,%edx
f0100a6e:	76 14                	jbe    f0100a84 <boot_alloc+0x61>
f0100a70:	83 ec 04             	sub    $0x4,%esp
f0100a73:	68 3c 69 10 f0       	push   $0xf010693c
f0100a78:	6a 71                	push   $0x71
f0100a7a:	68 4c 69 10 f0       	push   $0xf010694c
f0100a7f:	e8 bc f5 ff ff       	call   f0100040 <_panic>
	return result;
}
f0100a84:	89 d8                	mov    %ebx,%eax
f0100a86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100a89:	c9                   	leave  
f0100a8a:	c3                   	ret    

f0100a8b <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100a8b:	89 d1                	mov    %edx,%ecx
f0100a8d:	c1 e9 16             	shr    $0x16,%ecx
f0100a90:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100a93:	a8 01                	test   $0x1,%al
f0100a95:	74 52                	je     f0100ae9 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a97:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a9c:	89 c1                	mov    %eax,%ecx
f0100a9e:	c1 e9 0c             	shr    $0xc,%ecx
f0100aa1:	3b 0d 88 1e 21 f0    	cmp    0xf0211e88,%ecx
f0100aa7:	72 1b                	jb     f0100ac4 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100aa9:	55                   	push   %ebp
f0100aaa:	89 e5                	mov    %esp,%ebp
f0100aac:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100aaf:	50                   	push   %eax
f0100ab0:	68 44 64 10 f0       	push   $0xf0106444
f0100ab5:	68 90 03 00 00       	push   $0x390
f0100aba:	68 4c 69 10 f0       	push   $0xf010694c
f0100abf:	e8 7c f5 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100ac4:	c1 ea 0c             	shr    $0xc,%edx
f0100ac7:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100acd:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100ad4:	89 c2                	mov    %eax,%edx
f0100ad6:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100ad9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ade:	85 d2                	test   %edx,%edx
f0100ae0:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100ae5:	0f 44 c2             	cmove  %edx,%eax
f0100ae8:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100ae9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100aee:	c3                   	ret    

f0100aef <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100aef:	55                   	push   %ebp
f0100af0:	89 e5                	mov    %esp,%ebp
f0100af2:	57                   	push   %edi
f0100af3:	56                   	push   %esi
f0100af4:	53                   	push   %ebx
f0100af5:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100af8:	84 c0                	test   %al,%al
f0100afa:	0f 85 a0 02 00 00    	jne    f0100da0 <check_page_free_list+0x2b1>
f0100b00:	e9 ad 02 00 00       	jmp    f0100db2 <check_page_free_list+0x2c3>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b05:	83 ec 04             	sub    $0x4,%esp
f0100b08:	68 bc 6c 10 f0       	push   $0xf0106cbc
f0100b0d:	68 c3 02 00 00       	push   $0x2c3
f0100b12:	68 4c 69 10 f0       	push   $0xf010694c
f0100b17:	e8 24 f5 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b1c:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b1f:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b22:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b25:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b28:	89 c2                	mov    %eax,%edx
f0100b2a:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0100b30:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b36:	0f 95 c2             	setne  %dl
f0100b39:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b3c:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b40:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b42:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b46:	8b 00                	mov    (%eax),%eax
f0100b48:	85 c0                	test   %eax,%eax
f0100b4a:	75 dc                	jne    f0100b28 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100b4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b4f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100b55:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b58:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100b5b:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100b5d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100b60:	a3 44 12 21 f0       	mov    %eax,0xf0211244
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b65:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b6a:	8b 1d 44 12 21 f0    	mov    0xf0211244,%ebx
f0100b70:	eb 53                	jmp    f0100bc5 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f0100b72:	89 d8                	mov    %ebx,%eax
f0100b74:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0100b7a:	c1 f8 03             	sar    $0x3,%eax
f0100b7d:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b80:	89 c2                	mov    %eax,%edx
f0100b82:	c1 ea 16             	shr    $0x16,%edx
f0100b85:	39 f2                	cmp    %esi,%edx
f0100b87:	73 3a                	jae    f0100bc3 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b89:	89 c2                	mov    %eax,%edx
f0100b8b:	c1 ea 0c             	shr    $0xc,%edx
f0100b8e:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0100b94:	72 12                	jb     f0100ba8 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b96:	50                   	push   %eax
f0100b97:	68 44 64 10 f0       	push   $0xf0106444
f0100b9c:	6a 58                	push   $0x58
f0100b9e:	68 58 69 10 f0       	push   $0xf0106958
f0100ba3:	e8 98 f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100ba8:	83 ec 04             	sub    $0x4,%esp
f0100bab:	68 80 00 00 00       	push   $0x80
f0100bb0:	68 97 00 00 00       	push   $0x97
f0100bb5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bba:	50                   	push   %eax
f0100bbb:	e8 a2 4b 00 00       	call   f0105762 <memset>
f0100bc0:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bc3:	8b 1b                	mov    (%ebx),%ebx
f0100bc5:	85 db                	test   %ebx,%ebx
f0100bc7:	75 a9                	jne    f0100b72 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100bc9:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bce:	e8 50 fe ff ff       	call   f0100a23 <boot_alloc>
f0100bd3:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bd6:	8b 15 44 12 21 f0    	mov    0xf0211244,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100bdc:	8b 0d 90 1e 21 f0    	mov    0xf0211e90,%ecx
		assert(pp < pages + npages);
f0100be2:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f0100be7:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100bea:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100bed:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bf0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100bf3:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bf8:	e9 52 01 00 00       	jmp    f0100d4f <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100bfd:	39 ca                	cmp    %ecx,%edx
f0100bff:	73 19                	jae    f0100c1a <check_page_free_list+0x12b>
f0100c01:	68 66 69 10 f0       	push   $0xf0106966
f0100c06:	68 72 69 10 f0       	push   $0xf0106972
f0100c0b:	68 dd 02 00 00       	push   $0x2dd
f0100c10:	68 4c 69 10 f0       	push   $0xf010694c
f0100c15:	e8 26 f4 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c1a:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c1d:	72 19                	jb     f0100c38 <check_page_free_list+0x149>
f0100c1f:	68 87 69 10 f0       	push   $0xf0106987
f0100c24:	68 72 69 10 f0       	push   $0xf0106972
f0100c29:	68 de 02 00 00       	push   $0x2de
f0100c2e:	68 4c 69 10 f0       	push   $0xf010694c
f0100c33:	e8 08 f4 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c38:	89 d0                	mov    %edx,%eax
f0100c3a:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100c3d:	a8 07                	test   $0x7,%al
f0100c3f:	74 19                	je     f0100c5a <check_page_free_list+0x16b>
f0100c41:	68 e0 6c 10 f0       	push   $0xf0106ce0
f0100c46:	68 72 69 10 f0       	push   $0xf0106972
f0100c4b:	68 df 02 00 00       	push   $0x2df
f0100c50:	68 4c 69 10 f0       	push   $0xf010694c
f0100c55:	e8 e6 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f0100c5a:	c1 f8 03             	sar    $0x3,%eax
f0100c5d:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100c60:	85 c0                	test   %eax,%eax
f0100c62:	75 19                	jne    f0100c7d <check_page_free_list+0x18e>
f0100c64:	68 9b 69 10 f0       	push   $0xf010699b
f0100c69:	68 72 69 10 f0       	push   $0xf0106972
f0100c6e:	68 e2 02 00 00       	push   $0x2e2
f0100c73:	68 4c 69 10 f0       	push   $0xf010694c
f0100c78:	e8 c3 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c7d:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c82:	75 19                	jne    f0100c9d <check_page_free_list+0x1ae>
f0100c84:	68 ac 69 10 f0       	push   $0xf01069ac
f0100c89:	68 72 69 10 f0       	push   $0xf0106972
f0100c8e:	68 e3 02 00 00       	push   $0x2e3
f0100c93:	68 4c 69 10 f0       	push   $0xf010694c
f0100c98:	e8 a3 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c9d:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100ca2:	75 19                	jne    f0100cbd <check_page_free_list+0x1ce>
f0100ca4:	68 14 6d 10 f0       	push   $0xf0106d14
f0100ca9:	68 72 69 10 f0       	push   $0xf0106972
f0100cae:	68 e4 02 00 00       	push   $0x2e4
f0100cb3:	68 4c 69 10 f0       	push   $0xf010694c
f0100cb8:	e8 83 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100cbd:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100cc2:	75 19                	jne    f0100cdd <check_page_free_list+0x1ee>
f0100cc4:	68 c5 69 10 f0       	push   $0xf01069c5
f0100cc9:	68 72 69 10 f0       	push   $0xf0106972
f0100cce:	68 e5 02 00 00       	push   $0x2e5
f0100cd3:	68 4c 69 10 f0       	push   $0xf010694c
f0100cd8:	e8 63 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100cdd:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100ce2:	0f 86 f1 00 00 00    	jbe    f0100dd9 <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ce8:	89 c7                	mov    %eax,%edi
f0100cea:	c1 ef 0c             	shr    $0xc,%edi
f0100ced:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100cf0:	77 12                	ja     f0100d04 <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cf2:	50                   	push   %eax
f0100cf3:	68 44 64 10 f0       	push   $0xf0106444
f0100cf8:	6a 58                	push   $0x58
f0100cfa:	68 58 69 10 f0       	push   $0xf0106958
f0100cff:	e8 3c f3 ff ff       	call   f0100040 <_panic>
f0100d04:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100d0a:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100d0d:	0f 86 b6 00 00 00    	jbe    f0100dc9 <check_page_free_list+0x2da>
f0100d13:	68 38 6d 10 f0       	push   $0xf0106d38
f0100d18:	68 72 69 10 f0       	push   $0xf0106972
f0100d1d:	68 e6 02 00 00       	push   $0x2e6
f0100d22:	68 4c 69 10 f0       	push   $0xf010694c
f0100d27:	e8 14 f3 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d2c:	68 df 69 10 f0       	push   $0xf01069df
f0100d31:	68 72 69 10 f0       	push   $0xf0106972
f0100d36:	68 e8 02 00 00       	push   $0x2e8
f0100d3b:	68 4c 69 10 f0       	push   $0xf010694c
f0100d40:	e8 fb f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100d45:	83 c6 01             	add    $0x1,%esi
f0100d48:	eb 03                	jmp    f0100d4d <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100d4a:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d4d:	8b 12                	mov    (%edx),%edx
f0100d4f:	85 d2                	test   %edx,%edx
f0100d51:	0f 85 a6 fe ff ff    	jne    f0100bfd <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100d57:	85 f6                	test   %esi,%esi
f0100d59:	7f 19                	jg     f0100d74 <check_page_free_list+0x285>
f0100d5b:	68 fc 69 10 f0       	push   $0xf01069fc
f0100d60:	68 72 69 10 f0       	push   $0xf0106972
f0100d65:	68 f0 02 00 00       	push   $0x2f0
f0100d6a:	68 4c 69 10 f0       	push   $0xf010694c
f0100d6f:	e8 cc f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100d74:	85 db                	test   %ebx,%ebx
f0100d76:	7f 19                	jg     f0100d91 <check_page_free_list+0x2a2>
f0100d78:	68 0e 6a 10 f0       	push   $0xf0106a0e
f0100d7d:	68 72 69 10 f0       	push   $0xf0106972
f0100d82:	68 f1 02 00 00       	push   $0x2f1
f0100d87:	68 4c 69 10 f0       	push   $0xf010694c
f0100d8c:	e8 af f2 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100d91:	83 ec 0c             	sub    $0xc,%esp
f0100d94:	68 80 6d 10 f0       	push   $0xf0106d80
f0100d99:	e8 94 29 00 00       	call   f0103732 <cprintf>
}
f0100d9e:	eb 49                	jmp    f0100de9 <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100da0:	a1 44 12 21 f0       	mov    0xf0211244,%eax
f0100da5:	85 c0                	test   %eax,%eax
f0100da7:	0f 85 6f fd ff ff    	jne    f0100b1c <check_page_free_list+0x2d>
f0100dad:	e9 53 fd ff ff       	jmp    f0100b05 <check_page_free_list+0x16>
f0100db2:	83 3d 44 12 21 f0 00 	cmpl   $0x0,0xf0211244
f0100db9:	0f 84 46 fd ff ff    	je     f0100b05 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100dbf:	be 00 04 00 00       	mov    $0x400,%esi
f0100dc4:	e9 a1 fd ff ff       	jmp    f0100b6a <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100dc9:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100dce:	0f 85 76 ff ff ff    	jne    f0100d4a <check_page_free_list+0x25b>
f0100dd4:	e9 53 ff ff ff       	jmp    f0100d2c <check_page_free_list+0x23d>
f0100dd9:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100dde:	0f 85 61 ff ff ff    	jne    f0100d45 <check_page_free_list+0x256>
f0100de4:	e9 43 ff ff ff       	jmp    f0100d2c <check_page_free_list+0x23d>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100de9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100dec:	5b                   	pop    %ebx
f0100ded:	5e                   	pop    %esi
f0100dee:	5f                   	pop    %edi
f0100def:	5d                   	pop    %ebp
f0100df0:	c3                   	ret    

f0100df1 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100df1:	55                   	push   %ebp
f0100df2:	89 e5                	mov    %esp,%ebp
f0100df4:	53                   	push   %ebx
f0100df5:	83 ec 04             	sub    $0x4,%esp
f0100df8:	8b 1d 44 12 21 f0    	mov    0xf0211244,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100dfe:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e03:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e08:	eb 27                	jmp    f0100e31 <page_init+0x40>
f0100e0a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100e11:	89 d1                	mov    %edx,%ecx
f0100e13:	03 0d 90 1e 21 f0    	add    0xf0211e90,%ecx
f0100e19:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100e1f:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100e21:	83 c0 01             	add    $0x1,%eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i]; //不知道为啥这个list是倒过来连接的
f0100e24:	89 d3                	mov    %edx,%ebx
f0100e26:	03 1d 90 1e 21 f0    	add    0xf0211e90,%ebx
f0100e2c:	ba 01 00 00 00       	mov    $0x1,%edx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100e31:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f0100e37:	72 d1                	jb     f0100e0a <page_init+0x19>
f0100e39:	84 d2                	test   %dl,%dl
f0100e3b:	74 06                	je     f0100e43 <page_init+0x52>
f0100e3d:	89 1d 44 12 21 f0    	mov    %ebx,0xf0211244
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i]; //不知道为啥这个list是倒过来连接的
	}
	// 根据上面他给的提示写，1) 是 0 号 页是实模式的IDT 和 BIOS 不应该添加到空闲页，所以
	pages[1].pp_link=pages[0].pp_link;
f0100e43:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
f0100e48:	8b 10                	mov    (%eax),%edx
f0100e4a:	89 50 08             	mov    %edx,0x8(%eax)
	pages[0].pp_ref = 1;//不知道为啥有大佬说这个可以不用设置
f0100e4d:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link=NULL;
f0100e53:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	//2)是说那一块可以用，也就是上一次实验说的低地址，所以不用做修改
	//3)是说 上节课讲的有一部分 是不能用的，存IO的那一块，他告诉你地址是从[IOPHYSMEM,EXTPHYSMEM)
	size_t range_io=PGNUM(IOPHYSMEM),range_ext=PGNUM(EXTPHYSMEM);
	pages[range_ext].pp_link=pages[range_io].pp_link;
f0100e59:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
f0100e5e:	8b 90 00 05 00 00    	mov    0x500(%eax),%edx
f0100e64:	89 90 00 08 00 00    	mov    %edx,0x800(%eax)
f0100e6a:	b8 00 05 00 00       	mov    $0x500,%eax
	for (i = range_io; i < range_ext; i++) pages[i].pp_link = NULL;
f0100e6f:	8b 15 90 1e 21 f0    	mov    0xf0211e90,%edx
f0100e75:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f0100e7c:	83 c0 08             	add    $0x8,%eax
f0100e7f:	3d 00 08 00 00       	cmp    $0x800,%eax
f0100e84:	75 e9                	jne    f0100e6f <page_init+0x7e>

	//4)后面分配了一些内存页面给内核，所以那一块也是不能用的，看了半天，和上面是连续的...
	size_t free_top = PGNUM(PADDR(boot_alloc(0)));
f0100e86:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e8b:	e8 93 fb ff ff       	call   f0100a23 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e90:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e95:	77 15                	ja     f0100eac <page_init+0xbb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e97:	50                   	push   %eax
f0100e98:	68 68 64 10 f0       	push   $0xf0106468
f0100e9d:	68 5d 01 00 00       	push   $0x15d
f0100ea2:	68 4c 69 10 f0       	push   $0xf010694c
f0100ea7:	e8 94 f1 ff ff       	call   f0100040 <_panic>
f0100eac:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f0100eb2:	c1 e9 0c             	shr    $0xc,%ecx
	pages[free_top].pp_link = pages[range_ext].pp_link;
f0100eb5:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
f0100eba:	8b 90 00 08 00 00    	mov    0x800(%eax),%edx
f0100ec0:	89 14 c8             	mov    %edx,(%eax,%ecx,8)
	for(i = range_ext; i < free_top; i++) pages[i].pp_link = NULL;
f0100ec3:	b8 00 01 00 00       	mov    $0x100,%eax
f0100ec8:	eb 10                	jmp    f0100eda <page_init+0xe9>
f0100eca:	8b 15 90 1e 21 f0    	mov    0xf0211e90,%edx
f0100ed0:	c7 04 c2 00 00 00 00 	movl   $0x0,(%edx,%eax,8)
f0100ed7:	83 c0 01             	add    $0x1,%eax
f0100eda:	39 c8                	cmp    %ecx,%eax
f0100edc:	72 ec                	jb     f0100eca <page_init+0xd9>

	// 把MPENTRY_PADDR这块地址也删除
	uint32_t range_mpentry = PGNUM(MPENTRY_PADDR);
	pages[range_mpentry+1].pp_link=pages[range_mpentry].pp_link;
f0100ede:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
f0100ee3:	8b 50 38             	mov    0x38(%eax),%edx
f0100ee6:	89 50 40             	mov    %edx,0x40(%eax)
	pages[range_mpentry].pp_link=NULL;
f0100ee9:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

}
f0100ef0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ef3:	c9                   	leave  
f0100ef4:	c3                   	ret    

f0100ef5 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100ef5:	55                   	push   %ebp
f0100ef6:	89 e5                	mov    %esp,%ebp
f0100ef8:	53                   	push   %ebx
f0100ef9:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	//这个就是真正的内存分配函数了
	if(page_free_list){
f0100efc:	8b 1d 44 12 21 f0    	mov    0xf0211244,%ebx
f0100f02:	85 db                	test   %ebx,%ebx
f0100f04:	74 58                	je     f0100f5e <page_alloc+0x69>
		struct PageInfo *allocated = page_free_list;
		page_free_list = allocated->pp_link;
f0100f06:	8b 03                	mov    (%ebx),%eax
f0100f08:	a3 44 12 21 f0       	mov    %eax,0xf0211244
		allocated->pp_link = NULL;
f0100f0d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (alloc_flags & ALLOC_ZERO)
f0100f13:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f17:	74 45                	je     f0100f5e <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f0100f19:	89 d8                	mov    %ebx,%eax
f0100f1b:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0100f21:	c1 f8 03             	sar    $0x3,%eax
f0100f24:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f27:	89 c2                	mov    %eax,%edx
f0100f29:	c1 ea 0c             	shr    $0xc,%edx
f0100f2c:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0100f32:	72 12                	jb     f0100f46 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f34:	50                   	push   %eax
f0100f35:	68 44 64 10 f0       	push   $0xf0106444
f0100f3a:	6a 58                	push   $0x58
f0100f3c:	68 58 69 10 f0       	push   $0xf0106958
f0100f41:	e8 fa f0 ff ff       	call   f0100040 <_panic>
			memset(page2kva(allocated), 0, PGSIZE);
f0100f46:	83 ec 04             	sub    $0x4,%esp
f0100f49:	68 00 10 00 00       	push   $0x1000
f0100f4e:	6a 00                	push   $0x0
f0100f50:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f55:	50                   	push   %eax
f0100f56:	e8 07 48 00 00       	call   f0105762 <memset>
f0100f5b:	83 c4 10             	add    $0x10,%esp
		return allocated;
	}
	else return NULL;
	//return 0;
}
f0100f5e:	89 d8                	mov    %ebx,%eax
f0100f60:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f63:	c9                   	leave  
f0100f64:	c3                   	ret    

f0100f65 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100f65:	55                   	push   %ebp
f0100f66:	89 e5                	mov    %esp,%ebp
f0100f68:	83 ec 08             	sub    $0x8,%esp
f0100f6b:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	// 前面两个提示你了，一个判断 pp_ref 是不是非0 ，一个是pp_link 是不是非空
	if(pp->pp_ref > 0||pp->pp_link != NULL)panic("Page table entries point to this physical page.");
f0100f6e:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f73:	75 05                	jne    f0100f7a <page_free+0x15>
f0100f75:	83 38 00             	cmpl   $0x0,(%eax)
f0100f78:	74 17                	je     f0100f91 <page_free+0x2c>
f0100f7a:	83 ec 04             	sub    $0x4,%esp
f0100f7d:	68 a4 6d 10 f0       	push   $0xf0106da4
f0100f82:	68 90 01 00 00       	push   $0x190
f0100f87:	68 4c 69 10 f0       	push   $0xf010694c
f0100f8c:	e8 af f0 ff ff       	call   f0100040 <_panic>
      	pp->pp_link = page_free_list;
f0100f91:	8b 15 44 12 21 f0    	mov    0xf0211244,%edx
f0100f97:	89 10                	mov    %edx,(%eax)
      	page_free_list = pp;
f0100f99:	a3 44 12 21 f0       	mov    %eax,0xf0211244
}
f0100f9e:	c9                   	leave  
f0100f9f:	c3                   	ret    

f0100fa0 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100fa0:	55                   	push   %ebp
f0100fa1:	89 e5                	mov    %esp,%ebp
f0100fa3:	83 ec 08             	sub    $0x8,%esp
f0100fa6:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100fa9:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100fad:	83 e8 01             	sub    $0x1,%eax
f0100fb0:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100fb4:	66 85 c0             	test   %ax,%ax
f0100fb7:	75 0c                	jne    f0100fc5 <page_decref+0x25>
		page_free(pp);
f0100fb9:	83 ec 0c             	sub    $0xc,%esp
f0100fbc:	52                   	push   %edx
f0100fbd:	e8 a3 ff ff ff       	call   f0100f65 <page_free>
f0100fc2:	83 c4 10             	add    $0x10,%esp
}
f0100fc5:	c9                   	leave  
f0100fc6:	c3                   	ret    

f0100fc7 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100fc7:	55                   	push   %ebp
f0100fc8:	89 e5                	mov    %esp,%ebp
f0100fca:	56                   	push   %esi
f0100fcb:	53                   	push   %ebx
f0100fcc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	struct PageInfo * np;
	
	// PDX 是页目录里面的索引， pgdir 是 页目录，所以就找到了对应的地址
	pte_t * pd_entry =&pgdir[PDX(va)];
f0100fcf:	89 f3                	mov    %esi,%ebx
f0100fd1:	c1 eb 16             	shr    $0x16,%ebx
f0100fd4:	c1 e3 02             	shl    $0x2,%ebx
f0100fd7:	03 5d 08             	add    0x8(%ebp),%ebx
	
	//PTE_P 判断是不是已经存在该页，是的话就直接返回
	if(*pd_entry & PTE_P)
f0100fda:	8b 03                	mov    (%ebx),%eax
f0100fdc:	a8 01                	test   $0x1,%al
f0100fde:	74 39                	je     f0101019 <pgdir_walk+0x52>
		return (pte_t *)KADDR(PTE_ADDR(*pd_entry))+PTX(va);
f0100fe0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fe5:	89 c2                	mov    %eax,%edx
f0100fe7:	c1 ea 0c             	shr    $0xc,%edx
f0100fea:	39 15 88 1e 21 f0    	cmp    %edx,0xf0211e88
f0100ff0:	77 15                	ja     f0101007 <pgdir_walk+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ff2:	50                   	push   %eax
f0100ff3:	68 44 64 10 f0       	push   $0xf0106444
f0100ff8:	68 c1 01 00 00       	push   $0x1c1
f0100ffd:	68 4c 69 10 f0       	push   $0xf010694c
f0101002:	e8 39 f0 ff ff       	call   f0100040 <_panic>
f0101007:	c1 ee 0a             	shr    $0xa,%esi
f010100a:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101010:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0101017:	eb 74                	jmp    f010108d <pgdir_walk+0xc6>
	else if(create == true && (np=page_alloc(ALLOC_ZERO))){
f0101019:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
f010101d:	75 62                	jne    f0101081 <pgdir_walk+0xba>
f010101f:	83 ec 0c             	sub    $0xc,%esp
f0101022:	6a 01                	push   $0x1
f0101024:	e8 cc fe ff ff       	call   f0100ef5 <page_alloc>
f0101029:	83 c4 10             	add    $0x10,%esp
f010102c:	85 c0                	test   %eax,%eax
f010102e:	74 58                	je     f0101088 <pgdir_walk+0xc1>
		//如果可以创建就创建一个
		np->pp_ref++;//分配一个页
f0101030:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f0101035:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f010103b:	c1 f8 03             	sar    $0x3,%eax
f010103e:	c1 e0 0c             	shl    $0xc,%eax
		*pd_entry=page2pa(np)|PTE_P|PTE_U|PTE_W; //设置一些值
f0101041:	89 c2                	mov    %eax,%edx
f0101043:	83 ca 07             	or     $0x7,%edx
f0101046:	89 13                	mov    %edx,(%ebx)
f0101048:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010104d:	89 c2                	mov    %eax,%edx
f010104f:	c1 ea 0c             	shr    $0xc,%edx
f0101052:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0101058:	72 15                	jb     f010106f <pgdir_walk+0xa8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010105a:	50                   	push   %eax
f010105b:	68 44 64 10 f0       	push   $0xf0106444
f0101060:	68 c6 01 00 00       	push   $0x1c6
f0101065:	68 4c 69 10 f0       	push   $0xf010694c
f010106a:	e8 d1 ef ff ff       	call   f0100040 <_panic>
		return (pte_t *)KADDR(PTE_ADDR(*pd_entry)) + PTX(va);
f010106f:	c1 ee 0a             	shr    $0xa,%esi
f0101072:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101078:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f010107f:	eb 0c                	jmp    f010108d <pgdir_walk+0xc6>
	}
	else return NULL;
f0101081:	b8 00 00 00 00       	mov    $0x0,%eax
f0101086:	eb 05                	jmp    f010108d <pgdir_walk+0xc6>
f0101088:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010108d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101090:	5b                   	pop    %ebx
f0101091:	5e                   	pop    %esi
f0101092:	5d                   	pop    %ebp
f0101093:	c3                   	ret    

f0101094 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101094:	55                   	push   %ebp
f0101095:	89 e5                	mov    %esp,%ebp
f0101097:	57                   	push   %edi
f0101098:	56                   	push   %esi
f0101099:	53                   	push   %ebx
f010109a:	83 ec 1c             	sub    $0x1c,%esp
f010109d:	89 c7                	mov    %eax,%edi
f010109f:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01010a2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	// Fill this function in
	uintptr_t vStep;
	pte_t *ptep;
	for(vStep=0;vStep<size;vStep+=PGSIZE){
f01010a5:	bb 00 00 00 00       	mov    $0x0,%ebx
		ptep=pgdir_walk(pgdir,(void *)va+vStep,true);
		if(ptep)*ptep=pa|perm|PTE_P;
f01010aa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010ad:	83 c8 01             	or     $0x1,%eax
f01010b0:	89 45 dc             	mov    %eax,-0x24(%ebp)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	uintptr_t vStep;
	pte_t *ptep;
	for(vStep=0;vStep<size;vStep+=PGSIZE){
f01010b3:	eb 23                	jmp    f01010d8 <boot_map_region+0x44>
		ptep=pgdir_walk(pgdir,(void *)va+vStep,true);
f01010b5:	83 ec 04             	sub    $0x4,%esp
f01010b8:	6a 01                	push   $0x1
f01010ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01010bd:	01 d8                	add    %ebx,%eax
f01010bf:	50                   	push   %eax
f01010c0:	57                   	push   %edi
f01010c1:	e8 01 ff ff ff       	call   f0100fc7 <pgdir_walk>
		if(ptep)*ptep=pa|perm|PTE_P;
f01010c6:	83 c4 10             	add    $0x10,%esp
f01010c9:	85 c0                	test   %eax,%eax
f01010cb:	74 05                	je     f01010d2 <boot_map_region+0x3e>
f01010cd:	0b 75 dc             	or     -0x24(%ebp),%esi
f01010d0:	89 30                	mov    %esi,(%eax)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	uintptr_t vStep;
	pte_t *ptep;
	for(vStep=0;vStep<size;vStep+=PGSIZE){
f01010d2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01010d8:	89 de                	mov    %ebx,%esi
f01010da:	03 75 08             	add    0x8(%ebp),%esi
f01010dd:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01010e0:	72 d3                	jb     f01010b5 <boot_map_region+0x21>
		ptep=pgdir_walk(pgdir,(void *)va+vStep,true);
		if(ptep)*ptep=pa|perm|PTE_P;
		pa+=PGSIZE;
	}
}
f01010e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010e5:	5b                   	pop    %ebx
f01010e6:	5e                   	pop    %esi
f01010e7:	5f                   	pop    %edi
f01010e8:	5d                   	pop    %ebp
f01010e9:	c3                   	ret    

f01010ea <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01010ea:	55                   	push   %ebp
f01010eb:	89 e5                	mov    %esp,%ebp
f01010ed:	53                   	push   %ebx
f01010ee:	83 ec 08             	sub    $0x8,%esp
f01010f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *ptep =pgdir_walk(pgdir,va,false);
f01010f4:	6a 00                	push   $0x0
f01010f6:	ff 75 0c             	pushl  0xc(%ebp)
f01010f9:	ff 75 08             	pushl  0x8(%ebp)
f01010fc:	e8 c6 fe ff ff       	call   f0100fc7 <pgdir_walk>
	if(ptep&&(*ptep&PTE_P)){
f0101101:	83 c4 10             	add    $0x10,%esp
f0101104:	85 c0                	test   %eax,%eax
f0101106:	74 37                	je     f010113f <page_lookup+0x55>
f0101108:	f6 00 01             	testb  $0x1,(%eax)
f010110b:	74 39                	je     f0101146 <page_lookup+0x5c>
		if(pte_store){
f010110d:	85 db                	test   %ebx,%ebx
f010110f:	74 02                	je     f0101113 <page_lookup+0x29>
			*pte_store=ptep;	
f0101111:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{	// 或得物理地址的数据结构
	if (PGNUM(pa) >= npages)
f0101113:	8b 00                	mov    (%eax),%eax
f0101115:	c1 e8 0c             	shr    $0xc,%eax
f0101118:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f010111e:	72 14                	jb     f0101134 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0101120:	83 ec 04             	sub    $0x4,%esp
f0101123:	68 d4 6d 10 f0       	push   $0xf0106dd4
f0101128:	6a 51                	push   $0x51
f010112a:	68 58 69 10 f0       	push   $0xf0106958
f010112f:	e8 0c ef ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101134:	8b 15 90 1e 21 f0    	mov    0xf0211e90,%edx
f010113a:	8d 04 c2             	lea    (%edx,%eax,8),%eax
		}
		return pa2page(PTE_ADDR(*ptep));
f010113d:	eb 0c                	jmp    f010114b <page_lookup+0x61>

	}
	return NULL;
f010113f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101144:	eb 05                	jmp    f010114b <page_lookup+0x61>
f0101146:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010114b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010114e:	c9                   	leave  
f010114f:	c3                   	ret    

f0101150 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101150:	55                   	push   %ebp
f0101151:	89 e5                	mov    %esp,%ebp
f0101153:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101156:	e8 27 4c 00 00       	call   f0105d82 <cpunum>
f010115b:	6b c0 74             	imul   $0x74,%eax,%eax
f010115e:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f0101165:	74 16                	je     f010117d <tlb_invalidate+0x2d>
f0101167:	e8 16 4c 00 00       	call   f0105d82 <cpunum>
f010116c:	6b c0 74             	imul   $0x74,%eax,%eax
f010116f:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0101175:	8b 55 08             	mov    0x8(%ebp),%edx
f0101178:	39 50 60             	cmp    %edx,0x60(%eax)
f010117b:	75 06                	jne    f0101183 <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010117d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101180:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101183:	c9                   	leave  
f0101184:	c3                   	ret    

f0101185 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101185:	55                   	push   %ebp
f0101186:	89 e5                	mov    %esp,%ebp
f0101188:	56                   	push   %esi
f0101189:	53                   	push   %ebx
f010118a:	83 ec 14             	sub    $0x14,%esp
f010118d:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101190:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pte_t* pte_store;
	struct PageInfo *pgit=page_lookup(pgdir, va, &pte_store);
f0101193:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101196:	50                   	push   %eax
f0101197:	56                   	push   %esi
f0101198:	53                   	push   %ebx
f0101199:	e8 4c ff ff ff       	call   f01010ea <page_lookup>
	if(pgit){
f010119e:	83 c4 10             	add    $0x10,%esp
f01011a1:	85 c0                	test   %eax,%eax
f01011a3:	74 1f                	je     f01011c4 <page_remove+0x3f>
		page_decref(pgit);
f01011a5:	83 ec 0c             	sub    $0xc,%esp
f01011a8:	50                   	push   %eax
f01011a9:	e8 f2 fd ff ff       	call   f0100fa0 <page_decref>
		*pte_store=0;
f01011ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011b1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir,va);
f01011b7:	83 c4 08             	add    $0x8,%esp
f01011ba:	56                   	push   %esi
f01011bb:	53                   	push   %ebx
f01011bc:	e8 8f ff ff ff       	call   f0101150 <tlb_invalidate>
f01011c1:	83 c4 10             	add    $0x10,%esp
	}
}
f01011c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01011c7:	5b                   	pop    %ebx
f01011c8:	5e                   	pop    %esi
f01011c9:	5d                   	pop    %ebp
f01011ca:	c3                   	ret    

f01011cb <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01011cb:	55                   	push   %ebp
f01011cc:	89 e5                	mov    %esp,%ebp
f01011ce:	57                   	push   %edi
f01011cf:	56                   	push   %esi
f01011d0:	53                   	push   %ebx
f01011d1:	83 ec 10             	sub    $0x10,%esp
f01011d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01011d7:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *ptep=pgdir_walk(pgdir, va, true);
f01011da:	6a 01                	push   $0x1
f01011dc:	57                   	push   %edi
f01011dd:	ff 75 08             	pushl  0x8(%ebp)
f01011e0:	e8 e2 fd ff ff       	call   f0100fc7 <pgdir_walk>
	if(ptep){
f01011e5:	83 c4 10             	add    $0x10,%esp
f01011e8:	85 c0                	test   %eax,%eax
f01011ea:	74 38                	je     f0101224 <page_insert+0x59>
f01011ec:	89 c6                	mov    %eax,%esi
		pp->pp_ref++;
f01011ee:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
		if(*ptep&PTE_P)page_remove(pgdir, va);
f01011f3:	f6 00 01             	testb  $0x1,(%eax)
f01011f6:	74 0f                	je     f0101207 <page_insert+0x3c>
f01011f8:	83 ec 08             	sub    $0x8,%esp
f01011fb:	57                   	push   %edi
f01011fc:	ff 75 08             	pushl  0x8(%ebp)
f01011ff:	e8 81 ff ff ff       	call   f0101185 <page_remove>
f0101204:	83 c4 10             	add    $0x10,%esp
		 *ptep = page2pa(pp) | perm | PTE_P;
f0101207:	2b 1d 90 1e 21 f0    	sub    0xf0211e90,%ebx
f010120d:	c1 fb 03             	sar    $0x3,%ebx
f0101210:	c1 e3 0c             	shl    $0xc,%ebx
f0101213:	8b 45 14             	mov    0x14(%ebp),%eax
f0101216:	83 c8 01             	or     $0x1,%eax
f0101219:	09 c3                	or     %eax,%ebx
f010121b:	89 1e                	mov    %ebx,(%esi)
		return 0;
f010121d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101222:	eb 05                	jmp    f0101229 <page_insert+0x5e>
	}
	return -E_NO_MEM;
f0101224:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
f0101229:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010122c:	5b                   	pop    %ebx
f010122d:	5e                   	pop    %esi
f010122e:	5f                   	pop    %edi
f010122f:	5d                   	pop    %ebp
f0101230:	c3                   	ret    

f0101231 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101231:	55                   	push   %ebp
f0101232:	89 e5                	mov    %esp,%ebp
f0101234:	53                   	push   %ebx
f0101235:	83 ec 0c             	sub    $0xc,%esp
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
//	uintptr_t oldBase = base;
    size = ROUNDUP(size, PGSIZE);
f0101238:	8b 45 0c             	mov    0xc(%ebp),%eax
f010123b:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101241:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    boot_map_region(kern_pgdir, base, size, pa, PTE_W | PTE_PWT | PTE_PCD);
f0101247:	6a 1a                	push   $0x1a
f0101249:	ff 75 08             	pushl  0x8(%ebp)
f010124c:	89 d9                	mov    %ebx,%ecx
f010124e:	8b 15 00 03 12 f0    	mov    0xf0120300,%edx
f0101254:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0101259:	e8 36 fe ff ff       	call   f0101094 <boot_map_region>
    base += size;
f010125e:	a1 00 03 12 f0       	mov    0xf0120300,%eax
f0101263:	01 c3                	add    %eax,%ebx
f0101265:	89 1d 00 03 12 f0    	mov    %ebx,0xf0120300
    return (void *)base-size;
	//panic("mmio_map_region not implemented");
}
f010126b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010126e:	c9                   	leave  
f010126f:	c3                   	ret    

f0101270 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101270:	55                   	push   %ebp
f0101271:	89 e5                	mov    %esp,%ebp
f0101273:	57                   	push   %edi
f0101274:	56                   	push   %esi
f0101275:	53                   	push   %ebx
f0101276:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0101279:	b8 15 00 00 00       	mov    $0x15,%eax
f010127e:	e8 77 f7 ff ff       	call   f01009fa <nvram_read>
f0101283:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101285:	b8 17 00 00 00       	mov    $0x17,%eax
f010128a:	e8 6b f7 ff ff       	call   f01009fa <nvram_read>
f010128f:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101291:	b8 34 00 00 00       	mov    $0x34,%eax
f0101296:	e8 5f f7 ff ff       	call   f01009fa <nvram_read>
f010129b:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f010129e:	85 c0                	test   %eax,%eax
f01012a0:	74 07                	je     f01012a9 <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f01012a2:	05 00 40 00 00       	add    $0x4000,%eax
f01012a7:	eb 0b                	jmp    f01012b4 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f01012a9:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01012af:	85 f6                	test   %esi,%esi
f01012b1:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f01012b4:	89 c2                	mov    %eax,%edx
f01012b6:	c1 ea 02             	shr    $0x2,%edx
f01012b9:	89 15 88 1e 21 f0    	mov    %edx,0xf0211e88
	npages_basemem = basemem / (PGSIZE / 1024);
f01012bf:	89 da                	mov    %ebx,%edx
f01012c1:	c1 ea 02             	shr    $0x2,%edx
f01012c4:	89 15 48 12 21 f0    	mov    %edx,0xf0211248

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01012ca:	89 c2                	mov    %eax,%edx
f01012cc:	29 da                	sub    %ebx,%edx
f01012ce:	52                   	push   %edx
f01012cf:	53                   	push   %ebx
f01012d0:	50                   	push   %eax
f01012d1:	68 f4 6d 10 f0       	push   $0xf0106df4
f01012d6:	e8 57 24 00 00       	call   f0103732 <cprintf>
	uint32_t cr0;
	size_t n;

	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();
	cprintf("\nnpages= %d npages_basemem = %d \n",npages,npages_basemem);
f01012db:	83 c4 0c             	add    $0xc,%esp
f01012de:	ff 35 48 12 21 f0    	pushl  0xf0211248
f01012e4:	ff 35 88 1e 21 f0    	pushl  0xf0211e88
f01012ea:	68 30 6e 10 f0       	push   $0xf0106e30
f01012ef:	e8 3e 24 00 00       	call   f0103732 <cprintf>
	// Remove this line when you're ready to test this function.
//	panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01012f4:	b8 00 10 00 00       	mov    $0x1000,%eax
f01012f9:	e8 25 f7 ff ff       	call   f0100a23 <boot_alloc>
f01012fe:	a3 8c 1e 21 f0       	mov    %eax,0xf0211e8c
	cprintf("PGSIZE = %d\n",PGSIZE);
f0101303:	83 c4 08             	add    $0x8,%esp
f0101306:	68 00 10 00 00       	push   $0x1000
f010130b:	68 1f 6a 10 f0       	push   $0xf0106a1f
f0101310:	e8 1d 24 00 00       	call   f0103732 <cprintf>
	memset(kern_pgdir, 0, PGSIZE);
f0101315:	83 c4 0c             	add    $0xc,%esp
f0101318:	68 00 10 00 00       	push   $0x1000
f010131d:	6a 00                	push   $0x0
f010131f:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101325:	e8 38 44 00 00       	call   f0105762 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010132a:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010132f:	83 c4 10             	add    $0x10,%esp
f0101332:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101337:	77 15                	ja     f010134e <mem_init+0xde>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101339:	50                   	push   %eax
f010133a:	68 68 64 10 f0       	push   $0xf0106468
f010133f:	68 97 00 00 00       	push   $0x97
f0101344:	68 4c 69 10 f0       	push   $0xf010694c
f0101349:	e8 f2 ec ff ff       	call   f0100040 <_panic>
f010134e:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101354:	83 ca 05             	or     $0x5,%edx
f0101357:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	cprintf("PDX(UVPT) = %x UVPT=%x\n ",PDX(UVPT),UVPT);
f010135d:	83 ec 04             	sub    $0x4,%esp
f0101360:	68 00 00 40 ef       	push   $0xef400000
f0101365:	68 bd 03 00 00       	push   $0x3bd
f010136a:	68 2c 6a 10 f0       	push   $0xf0106a2c
f010136f:	e8 be 23 00 00       	call   f0103732 <cprintf>
	cprintf("kern_pgdir = %x PADDR(kern_pgdir) = %x\n",kern_pgdir,PADDR(kern_pgdir));
f0101374:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101379:	83 c4 10             	add    $0x10,%esp
f010137c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101381:	77 15                	ja     f0101398 <mem_init+0x128>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101383:	50                   	push   %eax
f0101384:	68 68 64 10 f0       	push   $0xf0106468
f0101389:	68 99 00 00 00       	push   $0x99
f010138e:	68 4c 69 10 f0       	push   $0xf010694c
f0101393:	e8 a8 ec ff ff       	call   f0100040 <_panic>
f0101398:	83 ec 04             	sub    $0x4,%esp
f010139b:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01013a1:	52                   	push   %edx
f01013a2:	50                   	push   %eax
f01013a3:	68 54 6e 10 f0       	push   $0xf0106e54
f01013a8:	e8 85 23 00 00       	call   f0103732 <cprintf>
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages=(struct PageInfo *) boot_alloc(npages *sizeof(struct PageInfo));
f01013ad:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f01013b2:	c1 e0 03             	shl    $0x3,%eax
f01013b5:	e8 69 f6 ff ff       	call   f0100a23 <boot_alloc>
f01013ba:	a3 90 1e 21 f0       	mov    %eax,0xf0211e90
	memset(pages,0,npages*sizeof(struct PageInfo));
f01013bf:	83 c4 0c             	add    $0xc,%esp
f01013c2:	8b 0d 88 1e 21 f0    	mov    0xf0211e88,%ecx
f01013c8:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01013cf:	52                   	push   %edx
f01013d0:	6a 00                	push   $0x0
f01013d2:	50                   	push   %eax
f01013d3:	e8 8a 43 00 00       	call   f0105762 <memset>
	cprintf("npages *sizeof(struct PageInfo)=%d\n",npages*sizeof(struct PageInfo));
f01013d8:	83 c4 08             	add    $0x8,%esp
f01013db:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f01013e0:	c1 e0 03             	shl    $0x3,%eax
f01013e3:	50                   	push   %eax
f01013e4:	68 7c 6e 10 f0       	push   $0xf0106e7c
f01013e9:	e8 44 23 00 00       	call   f0103732 <cprintf>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env*)boot_alloc(NENV*sizeof(struct Env));
f01013ee:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01013f3:	e8 2b f6 ff ff       	call   f0100a23 <boot_alloc>
f01013f8:	a3 4c 12 21 f0       	mov    %eax,0xf021124c
	memset(envs, 0, NENV * sizeof(struct Env));
f01013fd:	83 c4 0c             	add    $0xc,%esp
f0101400:	68 00 f0 01 00       	push   $0x1f000
f0101405:	6a 00                	push   $0x0
f0101407:	50                   	push   %eax
f0101408:	e8 55 43 00 00       	call   f0105762 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010140d:	e8 df f9 ff ff       	call   f0100df1 <page_init>

	check_page_free_list(1);
f0101412:	b8 01 00 00 00       	mov    $0x1,%eax
f0101417:	e8 d3 f6 ff ff       	call   f0100aef <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010141c:	83 c4 10             	add    $0x10,%esp
f010141f:	83 3d 90 1e 21 f0 00 	cmpl   $0x0,0xf0211e90
f0101426:	75 17                	jne    f010143f <mem_init+0x1cf>
		panic("'pages' is a null pointer!");
f0101428:	83 ec 04             	sub    $0x4,%esp
f010142b:	68 45 6a 10 f0       	push   $0xf0106a45
f0101430:	68 04 03 00 00       	push   $0x304
f0101435:	68 4c 69 10 f0       	push   $0xf010694c
f010143a:	e8 01 ec ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010143f:	a1 44 12 21 f0       	mov    0xf0211244,%eax
f0101444:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101449:	eb 05                	jmp    f0101450 <mem_init+0x1e0>
		++nfree;
f010144b:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010144e:	8b 00                	mov    (%eax),%eax
f0101450:	85 c0                	test   %eax,%eax
f0101452:	75 f7                	jne    f010144b <mem_init+0x1db>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101454:	83 ec 0c             	sub    $0xc,%esp
f0101457:	6a 00                	push   $0x0
f0101459:	e8 97 fa ff ff       	call   f0100ef5 <page_alloc>
f010145e:	89 c7                	mov    %eax,%edi
f0101460:	83 c4 10             	add    $0x10,%esp
f0101463:	85 c0                	test   %eax,%eax
f0101465:	75 19                	jne    f0101480 <mem_init+0x210>
f0101467:	68 60 6a 10 f0       	push   $0xf0106a60
f010146c:	68 72 69 10 f0       	push   $0xf0106972
f0101471:	68 0c 03 00 00       	push   $0x30c
f0101476:	68 4c 69 10 f0       	push   $0xf010694c
f010147b:	e8 c0 eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101480:	83 ec 0c             	sub    $0xc,%esp
f0101483:	6a 00                	push   $0x0
f0101485:	e8 6b fa ff ff       	call   f0100ef5 <page_alloc>
f010148a:	89 c6                	mov    %eax,%esi
f010148c:	83 c4 10             	add    $0x10,%esp
f010148f:	85 c0                	test   %eax,%eax
f0101491:	75 19                	jne    f01014ac <mem_init+0x23c>
f0101493:	68 76 6a 10 f0       	push   $0xf0106a76
f0101498:	68 72 69 10 f0       	push   $0xf0106972
f010149d:	68 0d 03 00 00       	push   $0x30d
f01014a2:	68 4c 69 10 f0       	push   $0xf010694c
f01014a7:	e8 94 eb ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01014ac:	83 ec 0c             	sub    $0xc,%esp
f01014af:	6a 00                	push   $0x0
f01014b1:	e8 3f fa ff ff       	call   f0100ef5 <page_alloc>
f01014b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014b9:	83 c4 10             	add    $0x10,%esp
f01014bc:	85 c0                	test   %eax,%eax
f01014be:	75 19                	jne    f01014d9 <mem_init+0x269>
f01014c0:	68 8c 6a 10 f0       	push   $0xf0106a8c
f01014c5:	68 72 69 10 f0       	push   $0xf0106972
f01014ca:	68 0e 03 00 00       	push   $0x30e
f01014cf:	68 4c 69 10 f0       	push   $0xf010694c
f01014d4:	e8 67 eb ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01014d9:	39 f7                	cmp    %esi,%edi
f01014db:	75 19                	jne    f01014f6 <mem_init+0x286>
f01014dd:	68 a2 6a 10 f0       	push   $0xf0106aa2
f01014e2:	68 72 69 10 f0       	push   $0xf0106972
f01014e7:	68 11 03 00 00       	push   $0x311
f01014ec:	68 4c 69 10 f0       	push   $0xf010694c
f01014f1:	e8 4a eb ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014f6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014f9:	39 c6                	cmp    %eax,%esi
f01014fb:	74 04                	je     f0101501 <mem_init+0x291>
f01014fd:	39 c7                	cmp    %eax,%edi
f01014ff:	75 19                	jne    f010151a <mem_init+0x2aa>
f0101501:	68 a0 6e 10 f0       	push   $0xf0106ea0
f0101506:	68 72 69 10 f0       	push   $0xf0106972
f010150b:	68 12 03 00 00       	push   $0x312
f0101510:	68 4c 69 10 f0       	push   $0xf010694c
f0101515:	e8 26 eb ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f010151a:	8b 0d 90 1e 21 f0    	mov    0xf0211e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101520:	8b 15 88 1e 21 f0    	mov    0xf0211e88,%edx
f0101526:	c1 e2 0c             	shl    $0xc,%edx
f0101529:	89 f8                	mov    %edi,%eax
f010152b:	29 c8                	sub    %ecx,%eax
f010152d:	c1 f8 03             	sar    $0x3,%eax
f0101530:	c1 e0 0c             	shl    $0xc,%eax
f0101533:	39 d0                	cmp    %edx,%eax
f0101535:	72 19                	jb     f0101550 <mem_init+0x2e0>
f0101537:	68 b4 6a 10 f0       	push   $0xf0106ab4
f010153c:	68 72 69 10 f0       	push   $0xf0106972
f0101541:	68 13 03 00 00       	push   $0x313
f0101546:	68 4c 69 10 f0       	push   $0xf010694c
f010154b:	e8 f0 ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101550:	89 f0                	mov    %esi,%eax
f0101552:	29 c8                	sub    %ecx,%eax
f0101554:	c1 f8 03             	sar    $0x3,%eax
f0101557:	c1 e0 0c             	shl    $0xc,%eax
f010155a:	39 c2                	cmp    %eax,%edx
f010155c:	77 19                	ja     f0101577 <mem_init+0x307>
f010155e:	68 d1 6a 10 f0       	push   $0xf0106ad1
f0101563:	68 72 69 10 f0       	push   $0xf0106972
f0101568:	68 14 03 00 00       	push   $0x314
f010156d:	68 4c 69 10 f0       	push   $0xf010694c
f0101572:	e8 c9 ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101577:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010157a:	29 c8                	sub    %ecx,%eax
f010157c:	c1 f8 03             	sar    $0x3,%eax
f010157f:	c1 e0 0c             	shl    $0xc,%eax
f0101582:	39 c2                	cmp    %eax,%edx
f0101584:	77 19                	ja     f010159f <mem_init+0x32f>
f0101586:	68 ee 6a 10 f0       	push   $0xf0106aee
f010158b:	68 72 69 10 f0       	push   $0xf0106972
f0101590:	68 15 03 00 00       	push   $0x315
f0101595:	68 4c 69 10 f0       	push   $0xf010694c
f010159a:	e8 a1 ea ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010159f:	a1 44 12 21 f0       	mov    0xf0211244,%eax
f01015a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01015a7:	c7 05 44 12 21 f0 00 	movl   $0x0,0xf0211244
f01015ae:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01015b1:	83 ec 0c             	sub    $0xc,%esp
f01015b4:	6a 00                	push   $0x0
f01015b6:	e8 3a f9 ff ff       	call   f0100ef5 <page_alloc>
f01015bb:	83 c4 10             	add    $0x10,%esp
f01015be:	85 c0                	test   %eax,%eax
f01015c0:	74 19                	je     f01015db <mem_init+0x36b>
f01015c2:	68 0b 6b 10 f0       	push   $0xf0106b0b
f01015c7:	68 72 69 10 f0       	push   $0xf0106972
f01015cc:	68 1c 03 00 00       	push   $0x31c
f01015d1:	68 4c 69 10 f0       	push   $0xf010694c
f01015d6:	e8 65 ea ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01015db:	83 ec 0c             	sub    $0xc,%esp
f01015de:	57                   	push   %edi
f01015df:	e8 81 f9 ff ff       	call   f0100f65 <page_free>
	page_free(pp1);
f01015e4:	89 34 24             	mov    %esi,(%esp)
f01015e7:	e8 79 f9 ff ff       	call   f0100f65 <page_free>
	page_free(pp2);
f01015ec:	83 c4 04             	add    $0x4,%esp
f01015ef:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015f2:	e8 6e f9 ff ff       	call   f0100f65 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015fe:	e8 f2 f8 ff ff       	call   f0100ef5 <page_alloc>
f0101603:	89 c6                	mov    %eax,%esi
f0101605:	83 c4 10             	add    $0x10,%esp
f0101608:	85 c0                	test   %eax,%eax
f010160a:	75 19                	jne    f0101625 <mem_init+0x3b5>
f010160c:	68 60 6a 10 f0       	push   $0xf0106a60
f0101611:	68 72 69 10 f0       	push   $0xf0106972
f0101616:	68 23 03 00 00       	push   $0x323
f010161b:	68 4c 69 10 f0       	push   $0xf010694c
f0101620:	e8 1b ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101625:	83 ec 0c             	sub    $0xc,%esp
f0101628:	6a 00                	push   $0x0
f010162a:	e8 c6 f8 ff ff       	call   f0100ef5 <page_alloc>
f010162f:	89 c7                	mov    %eax,%edi
f0101631:	83 c4 10             	add    $0x10,%esp
f0101634:	85 c0                	test   %eax,%eax
f0101636:	75 19                	jne    f0101651 <mem_init+0x3e1>
f0101638:	68 76 6a 10 f0       	push   $0xf0106a76
f010163d:	68 72 69 10 f0       	push   $0xf0106972
f0101642:	68 24 03 00 00       	push   $0x324
f0101647:	68 4c 69 10 f0       	push   $0xf010694c
f010164c:	e8 ef e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101651:	83 ec 0c             	sub    $0xc,%esp
f0101654:	6a 00                	push   $0x0
f0101656:	e8 9a f8 ff ff       	call   f0100ef5 <page_alloc>
f010165b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010165e:	83 c4 10             	add    $0x10,%esp
f0101661:	85 c0                	test   %eax,%eax
f0101663:	75 19                	jne    f010167e <mem_init+0x40e>
f0101665:	68 8c 6a 10 f0       	push   $0xf0106a8c
f010166a:	68 72 69 10 f0       	push   $0xf0106972
f010166f:	68 25 03 00 00       	push   $0x325
f0101674:	68 4c 69 10 f0       	push   $0xf010694c
f0101679:	e8 c2 e9 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010167e:	39 fe                	cmp    %edi,%esi
f0101680:	75 19                	jne    f010169b <mem_init+0x42b>
f0101682:	68 a2 6a 10 f0       	push   $0xf0106aa2
f0101687:	68 72 69 10 f0       	push   $0xf0106972
f010168c:	68 27 03 00 00       	push   $0x327
f0101691:	68 4c 69 10 f0       	push   $0xf010694c
f0101696:	e8 a5 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010169b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010169e:	39 c7                	cmp    %eax,%edi
f01016a0:	74 04                	je     f01016a6 <mem_init+0x436>
f01016a2:	39 c6                	cmp    %eax,%esi
f01016a4:	75 19                	jne    f01016bf <mem_init+0x44f>
f01016a6:	68 a0 6e 10 f0       	push   $0xf0106ea0
f01016ab:	68 72 69 10 f0       	push   $0xf0106972
f01016b0:	68 28 03 00 00       	push   $0x328
f01016b5:	68 4c 69 10 f0       	push   $0xf010694c
f01016ba:	e8 81 e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01016bf:	83 ec 0c             	sub    $0xc,%esp
f01016c2:	6a 00                	push   $0x0
f01016c4:	e8 2c f8 ff ff       	call   f0100ef5 <page_alloc>
f01016c9:	83 c4 10             	add    $0x10,%esp
f01016cc:	85 c0                	test   %eax,%eax
f01016ce:	74 19                	je     f01016e9 <mem_init+0x479>
f01016d0:	68 0b 6b 10 f0       	push   $0xf0106b0b
f01016d5:	68 72 69 10 f0       	push   $0xf0106972
f01016da:	68 29 03 00 00       	push   $0x329
f01016df:	68 4c 69 10 f0       	push   $0xf010694c
f01016e4:	e8 57 e9 ff ff       	call   f0100040 <_panic>
f01016e9:	89 f0                	mov    %esi,%eax
f01016eb:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f01016f1:	c1 f8 03             	sar    $0x3,%eax
f01016f4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016f7:	89 c2                	mov    %eax,%edx
f01016f9:	c1 ea 0c             	shr    $0xc,%edx
f01016fc:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0101702:	72 12                	jb     f0101716 <mem_init+0x4a6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101704:	50                   	push   %eax
f0101705:	68 44 64 10 f0       	push   $0xf0106444
f010170a:	6a 58                	push   $0x58
f010170c:	68 58 69 10 f0       	push   $0xf0106958
f0101711:	e8 2a e9 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101716:	83 ec 04             	sub    $0x4,%esp
f0101719:	68 00 10 00 00       	push   $0x1000
f010171e:	6a 01                	push   $0x1
f0101720:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101725:	50                   	push   %eax
f0101726:	e8 37 40 00 00       	call   f0105762 <memset>
	page_free(pp0);
f010172b:	89 34 24             	mov    %esi,(%esp)
f010172e:	e8 32 f8 ff ff       	call   f0100f65 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101733:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010173a:	e8 b6 f7 ff ff       	call   f0100ef5 <page_alloc>
f010173f:	83 c4 10             	add    $0x10,%esp
f0101742:	85 c0                	test   %eax,%eax
f0101744:	75 19                	jne    f010175f <mem_init+0x4ef>
f0101746:	68 1a 6b 10 f0       	push   $0xf0106b1a
f010174b:	68 72 69 10 f0       	push   $0xf0106972
f0101750:	68 2e 03 00 00       	push   $0x32e
f0101755:	68 4c 69 10 f0       	push   $0xf010694c
f010175a:	e8 e1 e8 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f010175f:	39 c6                	cmp    %eax,%esi
f0101761:	74 19                	je     f010177c <mem_init+0x50c>
f0101763:	68 38 6b 10 f0       	push   $0xf0106b38
f0101768:	68 72 69 10 f0       	push   $0xf0106972
f010176d:	68 2f 03 00 00       	push   $0x32f
f0101772:	68 4c 69 10 f0       	push   $0xf010694c
f0101777:	e8 c4 e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f010177c:	89 f0                	mov    %esi,%eax
f010177e:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0101784:	c1 f8 03             	sar    $0x3,%eax
f0101787:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010178a:	89 c2                	mov    %eax,%edx
f010178c:	c1 ea 0c             	shr    $0xc,%edx
f010178f:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0101795:	72 12                	jb     f01017a9 <mem_init+0x539>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101797:	50                   	push   %eax
f0101798:	68 44 64 10 f0       	push   $0xf0106444
f010179d:	6a 58                	push   $0x58
f010179f:	68 58 69 10 f0       	push   $0xf0106958
f01017a4:	e8 97 e8 ff ff       	call   f0100040 <_panic>
f01017a9:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01017af:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01017b5:	80 38 00             	cmpb   $0x0,(%eax)
f01017b8:	74 19                	je     f01017d3 <mem_init+0x563>
f01017ba:	68 48 6b 10 f0       	push   $0xf0106b48
f01017bf:	68 72 69 10 f0       	push   $0xf0106972
f01017c4:	68 32 03 00 00       	push   $0x332
f01017c9:	68 4c 69 10 f0       	push   $0xf010694c
f01017ce:	e8 6d e8 ff ff       	call   f0100040 <_panic>
f01017d3:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01017d6:	39 d0                	cmp    %edx,%eax
f01017d8:	75 db                	jne    f01017b5 <mem_init+0x545>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01017da:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01017dd:	a3 44 12 21 f0       	mov    %eax,0xf0211244

	// free the pages we took
	page_free(pp0);
f01017e2:	83 ec 0c             	sub    $0xc,%esp
f01017e5:	56                   	push   %esi
f01017e6:	e8 7a f7 ff ff       	call   f0100f65 <page_free>
	page_free(pp1);
f01017eb:	89 3c 24             	mov    %edi,(%esp)
f01017ee:	e8 72 f7 ff ff       	call   f0100f65 <page_free>
	page_free(pp2);
f01017f3:	83 c4 04             	add    $0x4,%esp
f01017f6:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017f9:	e8 67 f7 ff ff       	call   f0100f65 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017fe:	a1 44 12 21 f0       	mov    0xf0211244,%eax
f0101803:	83 c4 10             	add    $0x10,%esp
f0101806:	eb 05                	jmp    f010180d <mem_init+0x59d>
		--nfree;
f0101808:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010180b:	8b 00                	mov    (%eax),%eax
f010180d:	85 c0                	test   %eax,%eax
f010180f:	75 f7                	jne    f0101808 <mem_init+0x598>
		--nfree;
	assert(nfree == 0);
f0101811:	85 db                	test   %ebx,%ebx
f0101813:	74 19                	je     f010182e <mem_init+0x5be>
f0101815:	68 52 6b 10 f0       	push   $0xf0106b52
f010181a:	68 72 69 10 f0       	push   $0xf0106972
f010181f:	68 3f 03 00 00       	push   $0x33f
f0101824:	68 4c 69 10 f0       	push   $0xf010694c
f0101829:	e8 12 e8 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010182e:	83 ec 0c             	sub    $0xc,%esp
f0101831:	68 c0 6e 10 f0       	push   $0xf0106ec0
f0101836:	e8 f7 1e 00 00       	call   f0103732 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010183b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101842:	e8 ae f6 ff ff       	call   f0100ef5 <page_alloc>
f0101847:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010184a:	83 c4 10             	add    $0x10,%esp
f010184d:	85 c0                	test   %eax,%eax
f010184f:	75 19                	jne    f010186a <mem_init+0x5fa>
f0101851:	68 60 6a 10 f0       	push   $0xf0106a60
f0101856:	68 72 69 10 f0       	push   $0xf0106972
f010185b:	68 a5 03 00 00       	push   $0x3a5
f0101860:	68 4c 69 10 f0       	push   $0xf010694c
f0101865:	e8 d6 e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010186a:	83 ec 0c             	sub    $0xc,%esp
f010186d:	6a 00                	push   $0x0
f010186f:	e8 81 f6 ff ff       	call   f0100ef5 <page_alloc>
f0101874:	89 c3                	mov    %eax,%ebx
f0101876:	83 c4 10             	add    $0x10,%esp
f0101879:	85 c0                	test   %eax,%eax
f010187b:	75 19                	jne    f0101896 <mem_init+0x626>
f010187d:	68 76 6a 10 f0       	push   $0xf0106a76
f0101882:	68 72 69 10 f0       	push   $0xf0106972
f0101887:	68 a6 03 00 00       	push   $0x3a6
f010188c:	68 4c 69 10 f0       	push   $0xf010694c
f0101891:	e8 aa e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101896:	83 ec 0c             	sub    $0xc,%esp
f0101899:	6a 00                	push   $0x0
f010189b:	e8 55 f6 ff ff       	call   f0100ef5 <page_alloc>
f01018a0:	89 c6                	mov    %eax,%esi
f01018a2:	83 c4 10             	add    $0x10,%esp
f01018a5:	85 c0                	test   %eax,%eax
f01018a7:	75 19                	jne    f01018c2 <mem_init+0x652>
f01018a9:	68 8c 6a 10 f0       	push   $0xf0106a8c
f01018ae:	68 72 69 10 f0       	push   $0xf0106972
f01018b3:	68 a7 03 00 00       	push   $0x3a7
f01018b8:	68 4c 69 10 f0       	push   $0xf010694c
f01018bd:	e8 7e e7 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018c2:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01018c5:	75 19                	jne    f01018e0 <mem_init+0x670>
f01018c7:	68 a2 6a 10 f0       	push   $0xf0106aa2
f01018cc:	68 72 69 10 f0       	push   $0xf0106972
f01018d1:	68 aa 03 00 00       	push   $0x3aa
f01018d6:	68 4c 69 10 f0       	push   $0xf010694c
f01018db:	e8 60 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018e0:	39 c3                	cmp    %eax,%ebx
f01018e2:	74 05                	je     f01018e9 <mem_init+0x679>
f01018e4:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01018e7:	75 19                	jne    f0101902 <mem_init+0x692>
f01018e9:	68 a0 6e 10 f0       	push   $0xf0106ea0
f01018ee:	68 72 69 10 f0       	push   $0xf0106972
f01018f3:	68 ab 03 00 00       	push   $0x3ab
f01018f8:	68 4c 69 10 f0       	push   $0xf010694c
f01018fd:	e8 3e e7 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101902:	a1 44 12 21 f0       	mov    0xf0211244,%eax
f0101907:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010190a:	c7 05 44 12 21 f0 00 	movl   $0x0,0xf0211244
f0101911:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101914:	83 ec 0c             	sub    $0xc,%esp
f0101917:	6a 00                	push   $0x0
f0101919:	e8 d7 f5 ff ff       	call   f0100ef5 <page_alloc>
f010191e:	83 c4 10             	add    $0x10,%esp
f0101921:	85 c0                	test   %eax,%eax
f0101923:	74 19                	je     f010193e <mem_init+0x6ce>
f0101925:	68 0b 6b 10 f0       	push   $0xf0106b0b
f010192a:	68 72 69 10 f0       	push   $0xf0106972
f010192f:	68 b2 03 00 00       	push   $0x3b2
f0101934:	68 4c 69 10 f0       	push   $0xf010694c
f0101939:	e8 02 e7 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010193e:	83 ec 04             	sub    $0x4,%esp
f0101941:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101944:	50                   	push   %eax
f0101945:	6a 00                	push   $0x0
f0101947:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f010194d:	e8 98 f7 ff ff       	call   f01010ea <page_lookup>
f0101952:	83 c4 10             	add    $0x10,%esp
f0101955:	85 c0                	test   %eax,%eax
f0101957:	74 19                	je     f0101972 <mem_init+0x702>
f0101959:	68 e0 6e 10 f0       	push   $0xf0106ee0
f010195e:	68 72 69 10 f0       	push   $0xf0106972
f0101963:	68 b5 03 00 00       	push   $0x3b5
f0101968:	68 4c 69 10 f0       	push   $0xf010694c
f010196d:	e8 ce e6 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101972:	6a 02                	push   $0x2
f0101974:	6a 00                	push   $0x0
f0101976:	53                   	push   %ebx
f0101977:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f010197d:	e8 49 f8 ff ff       	call   f01011cb <page_insert>
f0101982:	83 c4 10             	add    $0x10,%esp
f0101985:	85 c0                	test   %eax,%eax
f0101987:	78 19                	js     f01019a2 <mem_init+0x732>
f0101989:	68 18 6f 10 f0       	push   $0xf0106f18
f010198e:	68 72 69 10 f0       	push   $0xf0106972
f0101993:	68 b8 03 00 00       	push   $0x3b8
f0101998:	68 4c 69 10 f0       	push   $0xf010694c
f010199d:	e8 9e e6 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01019a2:	83 ec 0c             	sub    $0xc,%esp
f01019a5:	ff 75 d4             	pushl  -0x2c(%ebp)
f01019a8:	e8 b8 f5 ff ff       	call   f0100f65 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01019ad:	6a 02                	push   $0x2
f01019af:	6a 00                	push   $0x0
f01019b1:	53                   	push   %ebx
f01019b2:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01019b8:	e8 0e f8 ff ff       	call   f01011cb <page_insert>
f01019bd:	83 c4 20             	add    $0x20,%esp
f01019c0:	85 c0                	test   %eax,%eax
f01019c2:	74 19                	je     f01019dd <mem_init+0x76d>
f01019c4:	68 48 6f 10 f0       	push   $0xf0106f48
f01019c9:	68 72 69 10 f0       	push   $0xf0106972
f01019ce:	68 bc 03 00 00       	push   $0x3bc
f01019d3:	68 4c 69 10 f0       	push   $0xf010694c
f01019d8:	e8 63 e6 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019dd:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f01019e3:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
f01019e8:	89 c1                	mov    %eax,%ecx
f01019ea:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01019ed:	8b 17                	mov    (%edi),%edx
f01019ef:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019f8:	29 c8                	sub    %ecx,%eax
f01019fa:	c1 f8 03             	sar    $0x3,%eax
f01019fd:	c1 e0 0c             	shl    $0xc,%eax
f0101a00:	39 c2                	cmp    %eax,%edx
f0101a02:	74 19                	je     f0101a1d <mem_init+0x7ad>
f0101a04:	68 78 6f 10 f0       	push   $0xf0106f78
f0101a09:	68 72 69 10 f0       	push   $0xf0106972
f0101a0e:	68 bd 03 00 00       	push   $0x3bd
f0101a13:	68 4c 69 10 f0       	push   $0xf010694c
f0101a18:	e8 23 e6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a1d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a22:	89 f8                	mov    %edi,%eax
f0101a24:	e8 62 f0 ff ff       	call   f0100a8b <check_va2pa>
f0101a29:	89 da                	mov    %ebx,%edx
f0101a2b:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101a2e:	c1 fa 03             	sar    $0x3,%edx
f0101a31:	c1 e2 0c             	shl    $0xc,%edx
f0101a34:	39 d0                	cmp    %edx,%eax
f0101a36:	74 19                	je     f0101a51 <mem_init+0x7e1>
f0101a38:	68 a0 6f 10 f0       	push   $0xf0106fa0
f0101a3d:	68 72 69 10 f0       	push   $0xf0106972
f0101a42:	68 be 03 00 00       	push   $0x3be
f0101a47:	68 4c 69 10 f0       	push   $0xf010694c
f0101a4c:	e8 ef e5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101a51:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a56:	74 19                	je     f0101a71 <mem_init+0x801>
f0101a58:	68 5d 6b 10 f0       	push   $0xf0106b5d
f0101a5d:	68 72 69 10 f0       	push   $0xf0106972
f0101a62:	68 bf 03 00 00       	push   $0x3bf
f0101a67:	68 4c 69 10 f0       	push   $0xf010694c
f0101a6c:	e8 cf e5 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101a71:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a74:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a79:	74 19                	je     f0101a94 <mem_init+0x824>
f0101a7b:	68 6e 6b 10 f0       	push   $0xf0106b6e
f0101a80:	68 72 69 10 f0       	push   $0xf0106972
f0101a85:	68 c0 03 00 00       	push   $0x3c0
f0101a8a:	68 4c 69 10 f0       	push   $0xf010694c
f0101a8f:	e8 ac e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a94:	6a 02                	push   $0x2
f0101a96:	68 00 10 00 00       	push   $0x1000
f0101a9b:	56                   	push   %esi
f0101a9c:	57                   	push   %edi
f0101a9d:	e8 29 f7 ff ff       	call   f01011cb <page_insert>
f0101aa2:	83 c4 10             	add    $0x10,%esp
f0101aa5:	85 c0                	test   %eax,%eax
f0101aa7:	74 19                	je     f0101ac2 <mem_init+0x852>
f0101aa9:	68 d0 6f 10 f0       	push   $0xf0106fd0
f0101aae:	68 72 69 10 f0       	push   $0xf0106972
f0101ab3:	68 c3 03 00 00       	push   $0x3c3
f0101ab8:	68 4c 69 10 f0       	push   $0xf010694c
f0101abd:	e8 7e e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ac2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ac7:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0101acc:	e8 ba ef ff ff       	call   f0100a8b <check_va2pa>
f0101ad1:	89 f2                	mov    %esi,%edx
f0101ad3:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0101ad9:	c1 fa 03             	sar    $0x3,%edx
f0101adc:	c1 e2 0c             	shl    $0xc,%edx
f0101adf:	39 d0                	cmp    %edx,%eax
f0101ae1:	74 19                	je     f0101afc <mem_init+0x88c>
f0101ae3:	68 0c 70 10 f0       	push   $0xf010700c
f0101ae8:	68 72 69 10 f0       	push   $0xf0106972
f0101aed:	68 c4 03 00 00       	push   $0x3c4
f0101af2:	68 4c 69 10 f0       	push   $0xf010694c
f0101af7:	e8 44 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101afc:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b01:	74 19                	je     f0101b1c <mem_init+0x8ac>
f0101b03:	68 7f 6b 10 f0       	push   $0xf0106b7f
f0101b08:	68 72 69 10 f0       	push   $0xf0106972
f0101b0d:	68 c5 03 00 00       	push   $0x3c5
f0101b12:	68 4c 69 10 f0       	push   $0xf010694c
f0101b17:	e8 24 e5 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101b1c:	83 ec 0c             	sub    $0xc,%esp
f0101b1f:	6a 00                	push   $0x0
f0101b21:	e8 cf f3 ff ff       	call   f0100ef5 <page_alloc>
f0101b26:	83 c4 10             	add    $0x10,%esp
f0101b29:	85 c0                	test   %eax,%eax
f0101b2b:	74 19                	je     f0101b46 <mem_init+0x8d6>
f0101b2d:	68 0b 6b 10 f0       	push   $0xf0106b0b
f0101b32:	68 72 69 10 f0       	push   $0xf0106972
f0101b37:	68 c8 03 00 00       	push   $0x3c8
f0101b3c:	68 4c 69 10 f0       	push   $0xf010694c
f0101b41:	e8 fa e4 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b46:	6a 02                	push   $0x2
f0101b48:	68 00 10 00 00       	push   $0x1000
f0101b4d:	56                   	push   %esi
f0101b4e:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101b54:	e8 72 f6 ff ff       	call   f01011cb <page_insert>
f0101b59:	83 c4 10             	add    $0x10,%esp
f0101b5c:	85 c0                	test   %eax,%eax
f0101b5e:	74 19                	je     f0101b79 <mem_init+0x909>
f0101b60:	68 d0 6f 10 f0       	push   $0xf0106fd0
f0101b65:	68 72 69 10 f0       	push   $0xf0106972
f0101b6a:	68 cb 03 00 00       	push   $0x3cb
f0101b6f:	68 4c 69 10 f0       	push   $0xf010694c
f0101b74:	e8 c7 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b79:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b7e:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0101b83:	e8 03 ef ff ff       	call   f0100a8b <check_va2pa>
f0101b88:	89 f2                	mov    %esi,%edx
f0101b8a:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0101b90:	c1 fa 03             	sar    $0x3,%edx
f0101b93:	c1 e2 0c             	shl    $0xc,%edx
f0101b96:	39 d0                	cmp    %edx,%eax
f0101b98:	74 19                	je     f0101bb3 <mem_init+0x943>
f0101b9a:	68 0c 70 10 f0       	push   $0xf010700c
f0101b9f:	68 72 69 10 f0       	push   $0xf0106972
f0101ba4:	68 cc 03 00 00       	push   $0x3cc
f0101ba9:	68 4c 69 10 f0       	push   $0xf010694c
f0101bae:	e8 8d e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101bb3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101bb8:	74 19                	je     f0101bd3 <mem_init+0x963>
f0101bba:	68 7f 6b 10 f0       	push   $0xf0106b7f
f0101bbf:	68 72 69 10 f0       	push   $0xf0106972
f0101bc4:	68 cd 03 00 00       	push   $0x3cd
f0101bc9:	68 4c 69 10 f0       	push   $0xf010694c
f0101bce:	e8 6d e4 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101bd3:	83 ec 0c             	sub    $0xc,%esp
f0101bd6:	6a 00                	push   $0x0
f0101bd8:	e8 18 f3 ff ff       	call   f0100ef5 <page_alloc>
f0101bdd:	83 c4 10             	add    $0x10,%esp
f0101be0:	85 c0                	test   %eax,%eax
f0101be2:	74 19                	je     f0101bfd <mem_init+0x98d>
f0101be4:	68 0b 6b 10 f0       	push   $0xf0106b0b
f0101be9:	68 72 69 10 f0       	push   $0xf0106972
f0101bee:	68 d1 03 00 00       	push   $0x3d1
f0101bf3:	68 4c 69 10 f0       	push   $0xf010694c
f0101bf8:	e8 43 e4 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101bfd:	8b 15 8c 1e 21 f0    	mov    0xf0211e8c,%edx
f0101c03:	8b 02                	mov    (%edx),%eax
f0101c05:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c0a:	89 c1                	mov    %eax,%ecx
f0101c0c:	c1 e9 0c             	shr    $0xc,%ecx
f0101c0f:	3b 0d 88 1e 21 f0    	cmp    0xf0211e88,%ecx
f0101c15:	72 15                	jb     f0101c2c <mem_init+0x9bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c17:	50                   	push   %eax
f0101c18:	68 44 64 10 f0       	push   $0xf0106444
f0101c1d:	68 d4 03 00 00       	push   $0x3d4
f0101c22:	68 4c 69 10 f0       	push   $0xf010694c
f0101c27:	e8 14 e4 ff ff       	call   f0100040 <_panic>
f0101c2c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c31:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101c34:	83 ec 04             	sub    $0x4,%esp
f0101c37:	6a 00                	push   $0x0
f0101c39:	68 00 10 00 00       	push   $0x1000
f0101c3e:	52                   	push   %edx
f0101c3f:	e8 83 f3 ff ff       	call   f0100fc7 <pgdir_walk>
f0101c44:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101c47:	8d 51 04             	lea    0x4(%ecx),%edx
f0101c4a:	83 c4 10             	add    $0x10,%esp
f0101c4d:	39 d0                	cmp    %edx,%eax
f0101c4f:	74 19                	je     f0101c6a <mem_init+0x9fa>
f0101c51:	68 3c 70 10 f0       	push   $0xf010703c
f0101c56:	68 72 69 10 f0       	push   $0xf0106972
f0101c5b:	68 d5 03 00 00       	push   $0x3d5
f0101c60:	68 4c 69 10 f0       	push   $0xf010694c
f0101c65:	e8 d6 e3 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101c6a:	6a 06                	push   $0x6
f0101c6c:	68 00 10 00 00       	push   $0x1000
f0101c71:	56                   	push   %esi
f0101c72:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101c78:	e8 4e f5 ff ff       	call   f01011cb <page_insert>
f0101c7d:	83 c4 10             	add    $0x10,%esp
f0101c80:	85 c0                	test   %eax,%eax
f0101c82:	74 19                	je     f0101c9d <mem_init+0xa2d>
f0101c84:	68 7c 70 10 f0       	push   $0xf010707c
f0101c89:	68 72 69 10 f0       	push   $0xf0106972
f0101c8e:	68 d8 03 00 00       	push   $0x3d8
f0101c93:	68 4c 69 10 f0       	push   $0xf010694c
f0101c98:	e8 a3 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c9d:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f0101ca3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ca8:	89 f8                	mov    %edi,%eax
f0101caa:	e8 dc ed ff ff       	call   f0100a8b <check_va2pa>
f0101caf:	89 f2                	mov    %esi,%edx
f0101cb1:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0101cb7:	c1 fa 03             	sar    $0x3,%edx
f0101cba:	c1 e2 0c             	shl    $0xc,%edx
f0101cbd:	39 d0                	cmp    %edx,%eax
f0101cbf:	74 19                	je     f0101cda <mem_init+0xa6a>
f0101cc1:	68 0c 70 10 f0       	push   $0xf010700c
f0101cc6:	68 72 69 10 f0       	push   $0xf0106972
f0101ccb:	68 d9 03 00 00       	push   $0x3d9
f0101cd0:	68 4c 69 10 f0       	push   $0xf010694c
f0101cd5:	e8 66 e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101cda:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101cdf:	74 19                	je     f0101cfa <mem_init+0xa8a>
f0101ce1:	68 7f 6b 10 f0       	push   $0xf0106b7f
f0101ce6:	68 72 69 10 f0       	push   $0xf0106972
f0101ceb:	68 da 03 00 00       	push   $0x3da
f0101cf0:	68 4c 69 10 f0       	push   $0xf010694c
f0101cf5:	e8 46 e3 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101cfa:	83 ec 04             	sub    $0x4,%esp
f0101cfd:	6a 00                	push   $0x0
f0101cff:	68 00 10 00 00       	push   $0x1000
f0101d04:	57                   	push   %edi
f0101d05:	e8 bd f2 ff ff       	call   f0100fc7 <pgdir_walk>
f0101d0a:	83 c4 10             	add    $0x10,%esp
f0101d0d:	f6 00 04             	testb  $0x4,(%eax)
f0101d10:	75 19                	jne    f0101d2b <mem_init+0xabb>
f0101d12:	68 bc 70 10 f0       	push   $0xf01070bc
f0101d17:	68 72 69 10 f0       	push   $0xf0106972
f0101d1c:	68 db 03 00 00       	push   $0x3db
f0101d21:	68 4c 69 10 f0       	push   $0xf010694c
f0101d26:	e8 15 e3 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101d2b:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0101d30:	f6 00 04             	testb  $0x4,(%eax)
f0101d33:	75 19                	jne    f0101d4e <mem_init+0xade>
f0101d35:	68 90 6b 10 f0       	push   $0xf0106b90
f0101d3a:	68 72 69 10 f0       	push   $0xf0106972
f0101d3f:	68 dc 03 00 00       	push   $0x3dc
f0101d44:	68 4c 69 10 f0       	push   $0xf010694c
f0101d49:	e8 f2 e2 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d4e:	6a 02                	push   $0x2
f0101d50:	68 00 10 00 00       	push   $0x1000
f0101d55:	56                   	push   %esi
f0101d56:	50                   	push   %eax
f0101d57:	e8 6f f4 ff ff       	call   f01011cb <page_insert>
f0101d5c:	83 c4 10             	add    $0x10,%esp
f0101d5f:	85 c0                	test   %eax,%eax
f0101d61:	74 19                	je     f0101d7c <mem_init+0xb0c>
f0101d63:	68 d0 6f 10 f0       	push   $0xf0106fd0
f0101d68:	68 72 69 10 f0       	push   $0xf0106972
f0101d6d:	68 df 03 00 00       	push   $0x3df
f0101d72:	68 4c 69 10 f0       	push   $0xf010694c
f0101d77:	e8 c4 e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101d7c:	83 ec 04             	sub    $0x4,%esp
f0101d7f:	6a 00                	push   $0x0
f0101d81:	68 00 10 00 00       	push   $0x1000
f0101d86:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101d8c:	e8 36 f2 ff ff       	call   f0100fc7 <pgdir_walk>
f0101d91:	83 c4 10             	add    $0x10,%esp
f0101d94:	f6 00 02             	testb  $0x2,(%eax)
f0101d97:	75 19                	jne    f0101db2 <mem_init+0xb42>
f0101d99:	68 f0 70 10 f0       	push   $0xf01070f0
f0101d9e:	68 72 69 10 f0       	push   $0xf0106972
f0101da3:	68 e0 03 00 00       	push   $0x3e0
f0101da8:	68 4c 69 10 f0       	push   $0xf010694c
f0101dad:	e8 8e e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101db2:	83 ec 04             	sub    $0x4,%esp
f0101db5:	6a 00                	push   $0x0
f0101db7:	68 00 10 00 00       	push   $0x1000
f0101dbc:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101dc2:	e8 00 f2 ff ff       	call   f0100fc7 <pgdir_walk>
f0101dc7:	83 c4 10             	add    $0x10,%esp
f0101dca:	f6 00 04             	testb  $0x4,(%eax)
f0101dcd:	74 19                	je     f0101de8 <mem_init+0xb78>
f0101dcf:	68 24 71 10 f0       	push   $0xf0107124
f0101dd4:	68 72 69 10 f0       	push   $0xf0106972
f0101dd9:	68 e1 03 00 00       	push   $0x3e1
f0101dde:	68 4c 69 10 f0       	push   $0xf010694c
f0101de3:	e8 58 e2 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101de8:	6a 02                	push   $0x2
f0101dea:	68 00 00 40 00       	push   $0x400000
f0101def:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101df2:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101df8:	e8 ce f3 ff ff       	call   f01011cb <page_insert>
f0101dfd:	83 c4 10             	add    $0x10,%esp
f0101e00:	85 c0                	test   %eax,%eax
f0101e02:	78 19                	js     f0101e1d <mem_init+0xbad>
f0101e04:	68 5c 71 10 f0       	push   $0xf010715c
f0101e09:	68 72 69 10 f0       	push   $0xf0106972
f0101e0e:	68 e4 03 00 00       	push   $0x3e4
f0101e13:	68 4c 69 10 f0       	push   $0xf010694c
f0101e18:	e8 23 e2 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101e1d:	6a 02                	push   $0x2
f0101e1f:	68 00 10 00 00       	push   $0x1000
f0101e24:	53                   	push   %ebx
f0101e25:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101e2b:	e8 9b f3 ff ff       	call   f01011cb <page_insert>
f0101e30:	83 c4 10             	add    $0x10,%esp
f0101e33:	85 c0                	test   %eax,%eax
f0101e35:	74 19                	je     f0101e50 <mem_init+0xbe0>
f0101e37:	68 94 71 10 f0       	push   $0xf0107194
f0101e3c:	68 72 69 10 f0       	push   $0xf0106972
f0101e41:	68 e7 03 00 00       	push   $0x3e7
f0101e46:	68 4c 69 10 f0       	push   $0xf010694c
f0101e4b:	e8 f0 e1 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e50:	83 ec 04             	sub    $0x4,%esp
f0101e53:	6a 00                	push   $0x0
f0101e55:	68 00 10 00 00       	push   $0x1000
f0101e5a:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101e60:	e8 62 f1 ff ff       	call   f0100fc7 <pgdir_walk>
f0101e65:	83 c4 10             	add    $0x10,%esp
f0101e68:	f6 00 04             	testb  $0x4,(%eax)
f0101e6b:	74 19                	je     f0101e86 <mem_init+0xc16>
f0101e6d:	68 24 71 10 f0       	push   $0xf0107124
f0101e72:	68 72 69 10 f0       	push   $0xf0106972
f0101e77:	68 e8 03 00 00       	push   $0x3e8
f0101e7c:	68 4c 69 10 f0       	push   $0xf010694c
f0101e81:	e8 ba e1 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101e86:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f0101e8c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e91:	89 f8                	mov    %edi,%eax
f0101e93:	e8 f3 eb ff ff       	call   f0100a8b <check_va2pa>
f0101e98:	89 c1                	mov    %eax,%ecx
f0101e9a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e9d:	89 d8                	mov    %ebx,%eax
f0101e9f:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0101ea5:	c1 f8 03             	sar    $0x3,%eax
f0101ea8:	c1 e0 0c             	shl    $0xc,%eax
f0101eab:	39 c1                	cmp    %eax,%ecx
f0101ead:	74 19                	je     f0101ec8 <mem_init+0xc58>
f0101eaf:	68 d0 71 10 f0       	push   $0xf01071d0
f0101eb4:	68 72 69 10 f0       	push   $0xf0106972
f0101eb9:	68 eb 03 00 00       	push   $0x3eb
f0101ebe:	68 4c 69 10 f0       	push   $0xf010694c
f0101ec3:	e8 78 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ec8:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ecd:	89 f8                	mov    %edi,%eax
f0101ecf:	e8 b7 eb ff ff       	call   f0100a8b <check_va2pa>
f0101ed4:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101ed7:	74 19                	je     f0101ef2 <mem_init+0xc82>
f0101ed9:	68 fc 71 10 f0       	push   $0xf01071fc
f0101ede:	68 72 69 10 f0       	push   $0xf0106972
f0101ee3:	68 ec 03 00 00       	push   $0x3ec
f0101ee8:	68 4c 69 10 f0       	push   $0xf010694c
f0101eed:	e8 4e e1 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101ef2:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101ef7:	74 19                	je     f0101f12 <mem_init+0xca2>
f0101ef9:	68 a6 6b 10 f0       	push   $0xf0106ba6
f0101efe:	68 72 69 10 f0       	push   $0xf0106972
f0101f03:	68 ee 03 00 00       	push   $0x3ee
f0101f08:	68 4c 69 10 f0       	push   $0xf010694c
f0101f0d:	e8 2e e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101f12:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f17:	74 19                	je     f0101f32 <mem_init+0xcc2>
f0101f19:	68 b7 6b 10 f0       	push   $0xf0106bb7
f0101f1e:	68 72 69 10 f0       	push   $0xf0106972
f0101f23:	68 ef 03 00 00       	push   $0x3ef
f0101f28:	68 4c 69 10 f0       	push   $0xf010694c
f0101f2d:	e8 0e e1 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101f32:	83 ec 0c             	sub    $0xc,%esp
f0101f35:	6a 00                	push   $0x0
f0101f37:	e8 b9 ef ff ff       	call   f0100ef5 <page_alloc>
f0101f3c:	83 c4 10             	add    $0x10,%esp
f0101f3f:	85 c0                	test   %eax,%eax
f0101f41:	74 04                	je     f0101f47 <mem_init+0xcd7>
f0101f43:	39 c6                	cmp    %eax,%esi
f0101f45:	74 19                	je     f0101f60 <mem_init+0xcf0>
f0101f47:	68 2c 72 10 f0       	push   $0xf010722c
f0101f4c:	68 72 69 10 f0       	push   $0xf0106972
f0101f51:	68 f2 03 00 00       	push   $0x3f2
f0101f56:	68 4c 69 10 f0       	push   $0xf010694c
f0101f5b:	e8 e0 e0 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101f60:	83 ec 08             	sub    $0x8,%esp
f0101f63:	6a 00                	push   $0x0
f0101f65:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101f6b:	e8 15 f2 ff ff       	call   f0101185 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f70:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f0101f76:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f7b:	89 f8                	mov    %edi,%eax
f0101f7d:	e8 09 eb ff ff       	call   f0100a8b <check_va2pa>
f0101f82:	83 c4 10             	add    $0x10,%esp
f0101f85:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f88:	74 19                	je     f0101fa3 <mem_init+0xd33>
f0101f8a:	68 50 72 10 f0       	push   $0xf0107250
f0101f8f:	68 72 69 10 f0       	push   $0xf0106972
f0101f94:	68 f6 03 00 00       	push   $0x3f6
f0101f99:	68 4c 69 10 f0       	push   $0xf010694c
f0101f9e:	e8 9d e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101fa3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fa8:	89 f8                	mov    %edi,%eax
f0101faa:	e8 dc ea ff ff       	call   f0100a8b <check_va2pa>
f0101faf:	89 da                	mov    %ebx,%edx
f0101fb1:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0101fb7:	c1 fa 03             	sar    $0x3,%edx
f0101fba:	c1 e2 0c             	shl    $0xc,%edx
f0101fbd:	39 d0                	cmp    %edx,%eax
f0101fbf:	74 19                	je     f0101fda <mem_init+0xd6a>
f0101fc1:	68 fc 71 10 f0       	push   $0xf01071fc
f0101fc6:	68 72 69 10 f0       	push   $0xf0106972
f0101fcb:	68 f7 03 00 00       	push   $0x3f7
f0101fd0:	68 4c 69 10 f0       	push   $0xf010694c
f0101fd5:	e8 66 e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101fda:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101fdf:	74 19                	je     f0101ffa <mem_init+0xd8a>
f0101fe1:	68 5d 6b 10 f0       	push   $0xf0106b5d
f0101fe6:	68 72 69 10 f0       	push   $0xf0106972
f0101feb:	68 f8 03 00 00       	push   $0x3f8
f0101ff0:	68 4c 69 10 f0       	push   $0xf010694c
f0101ff5:	e8 46 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101ffa:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fff:	74 19                	je     f010201a <mem_init+0xdaa>
f0102001:	68 b7 6b 10 f0       	push   $0xf0106bb7
f0102006:	68 72 69 10 f0       	push   $0xf0106972
f010200b:	68 f9 03 00 00       	push   $0x3f9
f0102010:	68 4c 69 10 f0       	push   $0xf010694c
f0102015:	e8 26 e0 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010201a:	6a 00                	push   $0x0
f010201c:	68 00 10 00 00       	push   $0x1000
f0102021:	53                   	push   %ebx
f0102022:	57                   	push   %edi
f0102023:	e8 a3 f1 ff ff       	call   f01011cb <page_insert>
f0102028:	83 c4 10             	add    $0x10,%esp
f010202b:	85 c0                	test   %eax,%eax
f010202d:	74 19                	je     f0102048 <mem_init+0xdd8>
f010202f:	68 74 72 10 f0       	push   $0xf0107274
f0102034:	68 72 69 10 f0       	push   $0xf0106972
f0102039:	68 fc 03 00 00       	push   $0x3fc
f010203e:	68 4c 69 10 f0       	push   $0xf010694c
f0102043:	e8 f8 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102048:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010204d:	75 19                	jne    f0102068 <mem_init+0xdf8>
f010204f:	68 c8 6b 10 f0       	push   $0xf0106bc8
f0102054:	68 72 69 10 f0       	push   $0xf0106972
f0102059:	68 fd 03 00 00       	push   $0x3fd
f010205e:	68 4c 69 10 f0       	push   $0xf010694c
f0102063:	e8 d8 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102068:	83 3b 00             	cmpl   $0x0,(%ebx)
f010206b:	74 19                	je     f0102086 <mem_init+0xe16>
f010206d:	68 d4 6b 10 f0       	push   $0xf0106bd4
f0102072:	68 72 69 10 f0       	push   $0xf0106972
f0102077:	68 fe 03 00 00       	push   $0x3fe
f010207c:	68 4c 69 10 f0       	push   $0xf010694c
f0102081:	e8 ba df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102086:	83 ec 08             	sub    $0x8,%esp
f0102089:	68 00 10 00 00       	push   $0x1000
f010208e:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102094:	e8 ec f0 ff ff       	call   f0101185 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102099:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f010209f:	ba 00 00 00 00       	mov    $0x0,%edx
f01020a4:	89 f8                	mov    %edi,%eax
f01020a6:	e8 e0 e9 ff ff       	call   f0100a8b <check_va2pa>
f01020ab:	83 c4 10             	add    $0x10,%esp
f01020ae:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020b1:	74 19                	je     f01020cc <mem_init+0xe5c>
f01020b3:	68 50 72 10 f0       	push   $0xf0107250
f01020b8:	68 72 69 10 f0       	push   $0xf0106972
f01020bd:	68 02 04 00 00       	push   $0x402
f01020c2:	68 4c 69 10 f0       	push   $0xf010694c
f01020c7:	e8 74 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01020cc:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020d1:	89 f8                	mov    %edi,%eax
f01020d3:	e8 b3 e9 ff ff       	call   f0100a8b <check_va2pa>
f01020d8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020db:	74 19                	je     f01020f6 <mem_init+0xe86>
f01020dd:	68 ac 72 10 f0       	push   $0xf01072ac
f01020e2:	68 72 69 10 f0       	push   $0xf0106972
f01020e7:	68 03 04 00 00       	push   $0x403
f01020ec:	68 4c 69 10 f0       	push   $0xf010694c
f01020f1:	e8 4a df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01020f6:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01020fb:	74 19                	je     f0102116 <mem_init+0xea6>
f01020fd:	68 e9 6b 10 f0       	push   $0xf0106be9
f0102102:	68 72 69 10 f0       	push   $0xf0106972
f0102107:	68 04 04 00 00       	push   $0x404
f010210c:	68 4c 69 10 f0       	push   $0xf010694c
f0102111:	e8 2a df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102116:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010211b:	74 19                	je     f0102136 <mem_init+0xec6>
f010211d:	68 b7 6b 10 f0       	push   $0xf0106bb7
f0102122:	68 72 69 10 f0       	push   $0xf0106972
f0102127:	68 05 04 00 00       	push   $0x405
f010212c:	68 4c 69 10 f0       	push   $0xf010694c
f0102131:	e8 0a df ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102136:	83 ec 0c             	sub    $0xc,%esp
f0102139:	6a 00                	push   $0x0
f010213b:	e8 b5 ed ff ff       	call   f0100ef5 <page_alloc>
f0102140:	83 c4 10             	add    $0x10,%esp
f0102143:	39 c3                	cmp    %eax,%ebx
f0102145:	75 04                	jne    f010214b <mem_init+0xedb>
f0102147:	85 c0                	test   %eax,%eax
f0102149:	75 19                	jne    f0102164 <mem_init+0xef4>
f010214b:	68 d4 72 10 f0       	push   $0xf01072d4
f0102150:	68 72 69 10 f0       	push   $0xf0106972
f0102155:	68 08 04 00 00       	push   $0x408
f010215a:	68 4c 69 10 f0       	push   $0xf010694c
f010215f:	e8 dc de ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102164:	83 ec 0c             	sub    $0xc,%esp
f0102167:	6a 00                	push   $0x0
f0102169:	e8 87 ed ff ff       	call   f0100ef5 <page_alloc>
f010216e:	83 c4 10             	add    $0x10,%esp
f0102171:	85 c0                	test   %eax,%eax
f0102173:	74 19                	je     f010218e <mem_init+0xf1e>
f0102175:	68 0b 6b 10 f0       	push   $0xf0106b0b
f010217a:	68 72 69 10 f0       	push   $0xf0106972
f010217f:	68 0b 04 00 00       	push   $0x40b
f0102184:	68 4c 69 10 f0       	push   $0xf010694c
f0102189:	e8 b2 de ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010218e:	8b 0d 8c 1e 21 f0    	mov    0xf0211e8c,%ecx
f0102194:	8b 11                	mov    (%ecx),%edx
f0102196:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010219c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010219f:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f01021a5:	c1 f8 03             	sar    $0x3,%eax
f01021a8:	c1 e0 0c             	shl    $0xc,%eax
f01021ab:	39 c2                	cmp    %eax,%edx
f01021ad:	74 19                	je     f01021c8 <mem_init+0xf58>
f01021af:	68 78 6f 10 f0       	push   $0xf0106f78
f01021b4:	68 72 69 10 f0       	push   $0xf0106972
f01021b9:	68 0e 04 00 00       	push   $0x40e
f01021be:	68 4c 69 10 f0       	push   $0xf010694c
f01021c3:	e8 78 de ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01021c8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01021ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021d1:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01021d6:	74 19                	je     f01021f1 <mem_init+0xf81>
f01021d8:	68 6e 6b 10 f0       	push   $0xf0106b6e
f01021dd:	68 72 69 10 f0       	push   $0xf0106972
f01021e2:	68 10 04 00 00       	push   $0x410
f01021e7:	68 4c 69 10 f0       	push   $0xf010694c
f01021ec:	e8 4f de ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01021f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021f4:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01021fa:	83 ec 0c             	sub    $0xc,%esp
f01021fd:	50                   	push   %eax
f01021fe:	e8 62 ed ff ff       	call   f0100f65 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102203:	83 c4 0c             	add    $0xc,%esp
f0102206:	6a 01                	push   $0x1
f0102208:	68 00 10 40 00       	push   $0x401000
f010220d:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102213:	e8 af ed ff ff       	call   f0100fc7 <pgdir_walk>
f0102218:	89 c7                	mov    %eax,%edi
f010221a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010221d:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102222:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102225:	8b 40 04             	mov    0x4(%eax),%eax
f0102228:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010222d:	8b 0d 88 1e 21 f0    	mov    0xf0211e88,%ecx
f0102233:	89 c2                	mov    %eax,%edx
f0102235:	c1 ea 0c             	shr    $0xc,%edx
f0102238:	83 c4 10             	add    $0x10,%esp
f010223b:	39 ca                	cmp    %ecx,%edx
f010223d:	72 15                	jb     f0102254 <mem_init+0xfe4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010223f:	50                   	push   %eax
f0102240:	68 44 64 10 f0       	push   $0xf0106444
f0102245:	68 17 04 00 00       	push   $0x417
f010224a:	68 4c 69 10 f0       	push   $0xf010694c
f010224f:	e8 ec dd ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102254:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102259:	39 c7                	cmp    %eax,%edi
f010225b:	74 19                	je     f0102276 <mem_init+0x1006>
f010225d:	68 fa 6b 10 f0       	push   $0xf0106bfa
f0102262:	68 72 69 10 f0       	push   $0xf0106972
f0102267:	68 18 04 00 00       	push   $0x418
f010226c:	68 4c 69 10 f0       	push   $0xf010694c
f0102271:	e8 ca dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102276:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102279:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102280:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102283:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f0102289:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f010228f:	c1 f8 03             	sar    $0x3,%eax
f0102292:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102295:	89 c2                	mov    %eax,%edx
f0102297:	c1 ea 0c             	shr    $0xc,%edx
f010229a:	39 d1                	cmp    %edx,%ecx
f010229c:	77 12                	ja     f01022b0 <mem_init+0x1040>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010229e:	50                   	push   %eax
f010229f:	68 44 64 10 f0       	push   $0xf0106444
f01022a4:	6a 58                	push   $0x58
f01022a6:	68 58 69 10 f0       	push   $0xf0106958
f01022ab:	e8 90 dd ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01022b0:	83 ec 04             	sub    $0x4,%esp
f01022b3:	68 00 10 00 00       	push   $0x1000
f01022b8:	68 ff 00 00 00       	push   $0xff
f01022bd:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01022c2:	50                   	push   %eax
f01022c3:	e8 9a 34 00 00       	call   f0105762 <memset>
	page_free(pp0);
f01022c8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01022cb:	89 3c 24             	mov    %edi,(%esp)
f01022ce:	e8 92 ec ff ff       	call   f0100f65 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01022d3:	83 c4 0c             	add    $0xc,%esp
f01022d6:	6a 01                	push   $0x1
f01022d8:	6a 00                	push   $0x0
f01022da:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01022e0:	e8 e2 ec ff ff       	call   f0100fc7 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f01022e5:	89 fa                	mov    %edi,%edx
f01022e7:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f01022ed:	c1 fa 03             	sar    $0x3,%edx
f01022f0:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01022f3:	89 d0                	mov    %edx,%eax
f01022f5:	c1 e8 0c             	shr    $0xc,%eax
f01022f8:	83 c4 10             	add    $0x10,%esp
f01022fb:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f0102301:	72 12                	jb     f0102315 <mem_init+0x10a5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102303:	52                   	push   %edx
f0102304:	68 44 64 10 f0       	push   $0xf0106444
f0102309:	6a 58                	push   $0x58
f010230b:	68 58 69 10 f0       	push   $0xf0106958
f0102310:	e8 2b dd ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102315:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010231b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010231e:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102324:	f6 00 01             	testb  $0x1,(%eax)
f0102327:	74 19                	je     f0102342 <mem_init+0x10d2>
f0102329:	68 12 6c 10 f0       	push   $0xf0106c12
f010232e:	68 72 69 10 f0       	push   $0xf0106972
f0102333:	68 22 04 00 00       	push   $0x422
f0102338:	68 4c 69 10 f0       	push   $0xf010694c
f010233d:	e8 fe dc ff ff       	call   f0100040 <_panic>
f0102342:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102345:	39 d0                	cmp    %edx,%eax
f0102347:	75 db                	jne    f0102324 <mem_init+0x10b4>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102349:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f010234e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102354:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102357:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f010235d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102360:	89 0d 44 12 21 f0    	mov    %ecx,0xf0211244

	// free the pages we took
	page_free(pp0);
f0102366:	83 ec 0c             	sub    $0xc,%esp
f0102369:	50                   	push   %eax
f010236a:	e8 f6 eb ff ff       	call   f0100f65 <page_free>
	page_free(pp1);
f010236f:	89 1c 24             	mov    %ebx,(%esp)
f0102372:	e8 ee eb ff ff       	call   f0100f65 <page_free>
	page_free(pp2);
f0102377:	89 34 24             	mov    %esi,(%esp)
f010237a:	e8 e6 eb ff ff       	call   f0100f65 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010237f:	83 c4 08             	add    $0x8,%esp
f0102382:	68 01 10 00 00       	push   $0x1001
f0102387:	6a 00                	push   $0x0
f0102389:	e8 a3 ee ff ff       	call   f0101231 <mmio_map_region>
f010238e:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102390:	83 c4 08             	add    $0x8,%esp
f0102393:	68 00 10 00 00       	push   $0x1000
f0102398:	6a 00                	push   $0x0
f010239a:	e8 92 ee ff ff       	call   f0101231 <mmio_map_region>
f010239f:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f01023a1:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f01023a7:	83 c4 10             	add    $0x10,%esp
f01023aa:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01023b0:	76 07                	jbe    f01023b9 <mem_init+0x1149>
f01023b2:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01023b7:	76 19                	jbe    f01023d2 <mem_init+0x1162>
f01023b9:	68 f8 72 10 f0       	push   $0xf01072f8
f01023be:	68 72 69 10 f0       	push   $0xf0106972
f01023c3:	68 32 04 00 00       	push   $0x432
f01023c8:	68 4c 69 10 f0       	push   $0xf010694c
f01023cd:	e8 6e dc ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f01023d2:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f01023d8:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01023de:	77 08                	ja     f01023e8 <mem_init+0x1178>
f01023e0:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01023e6:	77 19                	ja     f0102401 <mem_init+0x1191>
f01023e8:	68 20 73 10 f0       	push   $0xf0107320
f01023ed:	68 72 69 10 f0       	push   $0xf0106972
f01023f2:	68 33 04 00 00       	push   $0x433
f01023f7:	68 4c 69 10 f0       	push   $0xf010694c
f01023fc:	e8 3f dc ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102401:	89 da                	mov    %ebx,%edx
f0102403:	09 f2                	or     %esi,%edx
f0102405:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f010240b:	74 19                	je     f0102426 <mem_init+0x11b6>
f010240d:	68 48 73 10 f0       	push   $0xf0107348
f0102412:	68 72 69 10 f0       	push   $0xf0106972
f0102417:	68 35 04 00 00       	push   $0x435
f010241c:	68 4c 69 10 f0       	push   $0xf010694c
f0102421:	e8 1a dc ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0102426:	39 c6                	cmp    %eax,%esi
f0102428:	73 19                	jae    f0102443 <mem_init+0x11d3>
f010242a:	68 29 6c 10 f0       	push   $0xf0106c29
f010242f:	68 72 69 10 f0       	push   $0xf0106972
f0102434:	68 37 04 00 00       	push   $0x437
f0102439:	68 4c 69 10 f0       	push   $0xf010694c
f010243e:	e8 fd db ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102443:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f0102449:	89 da                	mov    %ebx,%edx
f010244b:	89 f8                	mov    %edi,%eax
f010244d:	e8 39 e6 ff ff       	call   f0100a8b <check_va2pa>
f0102452:	85 c0                	test   %eax,%eax
f0102454:	74 19                	je     f010246f <mem_init+0x11ff>
f0102456:	68 70 73 10 f0       	push   $0xf0107370
f010245b:	68 72 69 10 f0       	push   $0xf0106972
f0102460:	68 39 04 00 00       	push   $0x439
f0102465:	68 4c 69 10 f0       	push   $0xf010694c
f010246a:	e8 d1 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010246f:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102475:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102478:	89 c2                	mov    %eax,%edx
f010247a:	89 f8                	mov    %edi,%eax
f010247c:	e8 0a e6 ff ff       	call   f0100a8b <check_va2pa>
f0102481:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102486:	74 19                	je     f01024a1 <mem_init+0x1231>
f0102488:	68 94 73 10 f0       	push   $0xf0107394
f010248d:	68 72 69 10 f0       	push   $0xf0106972
f0102492:	68 3a 04 00 00       	push   $0x43a
f0102497:	68 4c 69 10 f0       	push   $0xf010694c
f010249c:	e8 9f db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01024a1:	89 f2                	mov    %esi,%edx
f01024a3:	89 f8                	mov    %edi,%eax
f01024a5:	e8 e1 e5 ff ff       	call   f0100a8b <check_va2pa>
f01024aa:	85 c0                	test   %eax,%eax
f01024ac:	74 19                	je     f01024c7 <mem_init+0x1257>
f01024ae:	68 c4 73 10 f0       	push   $0xf01073c4
f01024b3:	68 72 69 10 f0       	push   $0xf0106972
f01024b8:	68 3b 04 00 00       	push   $0x43b
f01024bd:	68 4c 69 10 f0       	push   $0xf010694c
f01024c2:	e8 79 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01024c7:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01024cd:	89 f8                	mov    %edi,%eax
f01024cf:	e8 b7 e5 ff ff       	call   f0100a8b <check_va2pa>
f01024d4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024d7:	74 19                	je     f01024f2 <mem_init+0x1282>
f01024d9:	68 e8 73 10 f0       	push   $0xf01073e8
f01024de:	68 72 69 10 f0       	push   $0xf0106972
f01024e3:	68 3c 04 00 00       	push   $0x43c
f01024e8:	68 4c 69 10 f0       	push   $0xf010694c
f01024ed:	e8 4e db ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01024f2:	83 ec 04             	sub    $0x4,%esp
f01024f5:	6a 00                	push   $0x0
f01024f7:	53                   	push   %ebx
f01024f8:	57                   	push   %edi
f01024f9:	e8 c9 ea ff ff       	call   f0100fc7 <pgdir_walk>
f01024fe:	83 c4 10             	add    $0x10,%esp
f0102501:	f6 00 1a             	testb  $0x1a,(%eax)
f0102504:	75 19                	jne    f010251f <mem_init+0x12af>
f0102506:	68 14 74 10 f0       	push   $0xf0107414
f010250b:	68 72 69 10 f0       	push   $0xf0106972
f0102510:	68 3e 04 00 00       	push   $0x43e
f0102515:	68 4c 69 10 f0       	push   $0xf010694c
f010251a:	e8 21 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f010251f:	83 ec 04             	sub    $0x4,%esp
f0102522:	6a 00                	push   $0x0
f0102524:	53                   	push   %ebx
f0102525:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f010252b:	e8 97 ea ff ff       	call   f0100fc7 <pgdir_walk>
f0102530:	8b 00                	mov    (%eax),%eax
f0102532:	83 c4 10             	add    $0x10,%esp
f0102535:	83 e0 04             	and    $0x4,%eax
f0102538:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010253b:	74 19                	je     f0102556 <mem_init+0x12e6>
f010253d:	68 58 74 10 f0       	push   $0xf0107458
f0102542:	68 72 69 10 f0       	push   $0xf0106972
f0102547:	68 3f 04 00 00       	push   $0x43f
f010254c:	68 4c 69 10 f0       	push   $0xf010694c
f0102551:	e8 ea da ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102556:	83 ec 04             	sub    $0x4,%esp
f0102559:	6a 00                	push   $0x0
f010255b:	53                   	push   %ebx
f010255c:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102562:	e8 60 ea ff ff       	call   f0100fc7 <pgdir_walk>
f0102567:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f010256d:	83 c4 0c             	add    $0xc,%esp
f0102570:	6a 00                	push   $0x0
f0102572:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102575:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f010257b:	e8 47 ea ff ff       	call   f0100fc7 <pgdir_walk>
f0102580:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102586:	83 c4 0c             	add    $0xc,%esp
f0102589:	6a 00                	push   $0x0
f010258b:	56                   	push   %esi
f010258c:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102592:	e8 30 ea ff ff       	call   f0100fc7 <pgdir_walk>
f0102597:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010259d:	c7 04 24 3b 6c 10 f0 	movl   $0xf0106c3b,(%esp)
f01025a4:	e8 89 11 00 00       	call   f0103732 <cprintf>
	page_init();

	check_page_free_list(1);
	check_page_alloc();
	check_page();
	cprintf("PTSIZE %d\n",PTSIZE);
f01025a9:	83 c4 08             	add    $0x8,%esp
f01025ac:	68 00 00 40 00       	push   $0x400000
f01025b1:	68 54 6c 10 f0       	push   $0xf0106c54
f01025b6:	e8 77 11 00 00       	call   f0103732 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:	
	//
	flag=1;
f01025bb:	c7 05 38 12 21 f0 01 	movl   $0x1,0xf0211238
f01025c2:	00 00 00 
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U|PTE_P);
f01025c5:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025ca:	83 c4 10             	add    $0x10,%esp
f01025cd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025d2:	77 15                	ja     f01025e9 <mem_init+0x1379>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025d4:	50                   	push   %eax
f01025d5:	68 68 64 10 f0       	push   $0xf0106468
f01025da:	68 c6 00 00 00       	push   $0xc6
f01025df:	68 4c 69 10 f0       	push   $0xf010694c
f01025e4:	e8 57 da ff ff       	call   f0100040 <_panic>
f01025e9:	83 ec 08             	sub    $0x8,%esp
f01025ec:	6a 05                	push   $0x5
f01025ee:	05 00 00 00 10       	add    $0x10000000,%eax
f01025f3:	50                   	push   %eax
f01025f4:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01025f9:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01025fe:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102603:	e8 8c ea ff ff       	call   f0101094 <boot_map_region>
	cprintf("UPAGES=%x PADDR(pages)=%x\n",UPAGES,PADDR(pages));
f0102608:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010260d:	83 c4 10             	add    $0x10,%esp
f0102610:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102615:	77 15                	ja     f010262c <mem_init+0x13bc>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102617:	50                   	push   %eax
f0102618:	68 68 64 10 f0       	push   $0xf0106468
f010261d:	68 c7 00 00 00       	push   $0xc7
f0102622:	68 4c 69 10 f0       	push   $0xf010694c
f0102627:	e8 14 da ff ff       	call   f0100040 <_panic>
f010262c:	83 ec 04             	sub    $0x4,%esp
f010262f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102634:	50                   	push   %eax
f0102635:	68 00 00 00 ef       	push   $0xef000000
f010263a:	68 5f 6c 10 f0       	push   $0xf0106c5f
f010263f:	e8 ee 10 00 00       	call   f0103732 <cprintf>
	flag=0;
f0102644:	c7 05 38 12 21 f0 00 	movl   $0x0,0xf0211238
f010264b:	00 00 00 
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f010264e:	a1 4c 12 21 f0       	mov    0xf021124c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102653:	83 c4 10             	add    $0x10,%esp
f0102656:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010265b:	77 15                	ja     f0102672 <mem_init+0x1402>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010265d:	50                   	push   %eax
f010265e:	68 68 64 10 f0       	push   $0xf0106468
f0102663:	68 d0 00 00 00       	push   $0xd0
f0102668:	68 4c 69 10 f0       	push   $0xf010694c
f010266d:	e8 ce d9 ff ff       	call   f0100040 <_panic>
f0102672:	83 ec 08             	sub    $0x8,%esp
f0102675:	6a 04                	push   $0x4
f0102677:	05 00 00 00 10       	add    $0x10000000,%eax
f010267c:	50                   	push   %eax
f010267d:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102682:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102687:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f010268c:	e8 03 ea ff ff       	call   f0101094 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102691:	83 c4 10             	add    $0x10,%esp
f0102694:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f0102699:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010269e:	77 15                	ja     f01026b5 <mem_init+0x1445>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026a0:	50                   	push   %eax
f01026a1:	68 68 64 10 f0       	push   $0xf0106468
f01026a6:	68 df 00 00 00       	push   $0xdf
f01026ab:	68 4c 69 10 f0       	push   $0xf010694c
f01026b0:	e8 8b d9 ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	// 堆栈段映射 ，有一部分没用映射，这样栈炸了就直接报错了，而不是覆盖其他内存
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01026b5:	83 ec 08             	sub    $0x8,%esp
f01026b8:	6a 02                	push   $0x2
f01026ba:	68 00 60 11 00       	push   $0x116000
f01026bf:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01026c4:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01026c9:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01026ce:	e8 c1 e9 ff ff       	call   f0101094 <boot_map_region>
	cprintf("KSTACKTOP-KSTKSIZE=%x PADDR(bootstack)=%x\n",KSTACKTOP-KSTKSIZE,PADDR(bootstack));
f01026d3:	83 c4 0c             	add    $0xc,%esp
f01026d6:	68 00 60 11 00       	push   $0x116000
f01026db:	68 00 80 ff ef       	push   $0xefff8000
f01026e0:	68 8c 74 10 f0       	push   $0xf010748c
f01026e5:	e8 48 10 00 00       	call   f0103732 <cprintf>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, 0x10000000, 0, PTE_W);
f01026ea:	83 c4 08             	add    $0x8,%esp
f01026ed:	6a 02                	push   $0x2
f01026ef:	6a 00                	push   $0x0
f01026f1:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01026f6:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01026fb:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102700:	e8 8f e9 ff ff       	call   f0101094 <boot_map_region>
	cprintf("KERNBASE=%x 0=%x\n",KERNBASE,0);	
f0102705:	83 c4 0c             	add    $0xc,%esp
f0102708:	6a 00                	push   $0x0
f010270a:	68 00 00 00 f0       	push   $0xf0000000
f010270f:	68 7a 6c 10 f0       	push   $0xf0106c7a
f0102714:	e8 19 10 00 00       	call   f0103732 <cprintf>
f0102719:	c7 45 c4 00 30 21 f0 	movl   $0xf0213000,-0x3c(%ebp)
f0102720:	83 c4 10             	add    $0x10,%esp
f0102723:	bb 00 30 21 f0       	mov    $0xf0213000,%ebx
f0102728:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010272d:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102733:	77 15                	ja     f010274a <mem_init+0x14da>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102735:	53                   	push   %ebx
f0102736:	68 68 64 10 f0       	push   $0xf0106468
f010273b:	68 23 01 00 00       	push   $0x123
f0102740:	68 4c 69 10 f0       	push   $0xf010694c
f0102745:	e8 f6 d8 ff ff       	call   f0100040 <_panic>
	//
	// LAB 4: Your code here:
	for (size_t i = 0; i < NCPU; i++)
	{
		/* code */
		boot_map_region(kern_pgdir,KSTACKTOP-i*(KSTKSIZE+KSTKGAP)-KSTKSIZE,KSTKSIZE,PADDR(percpu_kstacks[i]),PTE_W);
f010274a:	83 ec 08             	sub    $0x8,%esp
f010274d:	6a 02                	push   $0x2
f010274f:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102755:	50                   	push   %eax
f0102756:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010275b:	89 f2                	mov    %esi,%edx
f010275d:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102762:	e8 2d e9 ff ff       	call   f0101094 <boot_map_region>
f0102767:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010276d:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             it will fault rather than overwrite another CPU's stack.
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	for (size_t i = 0; i < NCPU; i++)
f0102773:	83 c4 10             	add    $0x10,%esp
f0102776:	b8 00 30 25 f0       	mov    $0xf0253000,%eax
f010277b:	39 d8                	cmp    %ebx,%eax
f010277d:	75 ae                	jne    f010272d <mem_init+0x14bd>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010277f:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102785:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f010278a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010278d:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102794:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102799:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010279c:	8b 35 90 1e 21 f0    	mov    0xf0211e90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027a2:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027a5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01027aa:	eb 55                	jmp    f0102801 <mem_init+0x1591>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01027ac:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01027b2:	89 f8                	mov    %edi,%eax
f01027b4:	e8 d2 e2 ff ff       	call   f0100a8b <check_va2pa>
f01027b9:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01027c0:	77 15                	ja     f01027d7 <mem_init+0x1567>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027c2:	56                   	push   %esi
f01027c3:	68 68 64 10 f0       	push   $0xf0106468
f01027c8:	68 57 03 00 00       	push   $0x357
f01027cd:	68 4c 69 10 f0       	push   $0xf010694c
f01027d2:	e8 69 d8 ff ff       	call   f0100040 <_panic>
f01027d7:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f01027de:	39 c2                	cmp    %eax,%edx
f01027e0:	74 19                	je     f01027fb <mem_init+0x158b>
f01027e2:	68 b8 74 10 f0       	push   $0xf01074b8
f01027e7:	68 72 69 10 f0       	push   $0xf0106972
f01027ec:	68 57 03 00 00       	push   $0x357
f01027f1:	68 4c 69 10 f0       	push   $0xf010694c
f01027f6:	e8 45 d8 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027fb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102801:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102804:	77 a6                	ja     f01027ac <mem_init+0x153c>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102806:	8b 35 4c 12 21 f0    	mov    0xf021124c,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010280c:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010280f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102814:	89 da                	mov    %ebx,%edx
f0102816:	89 f8                	mov    %edi,%eax
f0102818:	e8 6e e2 ff ff       	call   f0100a8b <check_va2pa>
f010281d:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102824:	77 15                	ja     f010283b <mem_init+0x15cb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102826:	56                   	push   %esi
f0102827:	68 68 64 10 f0       	push   $0xf0106468
f010282c:	68 5c 03 00 00       	push   $0x35c
f0102831:	68 4c 69 10 f0       	push   $0xf010694c
f0102836:	e8 05 d8 ff ff       	call   f0100040 <_panic>
f010283b:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102842:	39 d0                	cmp    %edx,%eax
f0102844:	74 19                	je     f010285f <mem_init+0x15ef>
f0102846:	68 ec 74 10 f0       	push   $0xf01074ec
f010284b:	68 72 69 10 f0       	push   $0xf0106972
f0102850:	68 5c 03 00 00       	push   $0x35c
f0102855:	68 4c 69 10 f0       	push   $0xf010694c
f010285a:	e8 e1 d7 ff ff       	call   f0100040 <_panic>
f010285f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102865:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f010286b:	75 a7                	jne    f0102814 <mem_init+0x15a4>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010286d:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102870:	c1 e6 0c             	shl    $0xc,%esi
f0102873:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102878:	eb 30                	jmp    f01028aa <mem_init+0x163a>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010287a:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102880:	89 f8                	mov    %edi,%eax
f0102882:	e8 04 e2 ff ff       	call   f0100a8b <check_va2pa>
f0102887:	39 c3                	cmp    %eax,%ebx
f0102889:	74 19                	je     f01028a4 <mem_init+0x1634>
f010288b:	68 20 75 10 f0       	push   $0xf0107520
f0102890:	68 72 69 10 f0       	push   $0xf0106972
f0102895:	68 60 03 00 00       	push   $0x360
f010289a:	68 4c 69 10 f0       	push   $0xf010694c
f010289f:	e8 9c d7 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01028a4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01028aa:	39 f3                	cmp    %esi,%ebx
f01028ac:	72 cc                	jb     f010287a <mem_init+0x160a>
f01028ae:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01028b3:	89 75 cc             	mov    %esi,-0x34(%ebp)
f01028b6:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01028b9:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01028bc:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f01028c2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01028c5:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01028c7:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01028ca:	05 00 80 00 20       	add    $0x20008000,%eax
f01028cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01028d2:	89 da                	mov    %ebx,%edx
f01028d4:	89 f8                	mov    %edi,%eax
f01028d6:	e8 b0 e1 ff ff       	call   f0100a8b <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028db:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01028e1:	77 15                	ja     f01028f8 <mem_init+0x1688>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028e3:	56                   	push   %esi
f01028e4:	68 68 64 10 f0       	push   $0xf0106468
f01028e9:	68 68 03 00 00       	push   $0x368
f01028ee:	68 4c 69 10 f0       	push   $0xf010694c
f01028f3:	e8 48 d7 ff ff       	call   f0100040 <_panic>
f01028f8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01028fb:	8d 94 0b 00 30 21 f0 	lea    -0xfded000(%ebx,%ecx,1),%edx
f0102902:	39 d0                	cmp    %edx,%eax
f0102904:	74 19                	je     f010291f <mem_init+0x16af>
f0102906:	68 48 75 10 f0       	push   $0xf0107548
f010290b:	68 72 69 10 f0       	push   $0xf0106972
f0102910:	68 68 03 00 00       	push   $0x368
f0102915:	68 4c 69 10 f0       	push   $0xf010694c
f010291a:	e8 21 d7 ff ff       	call   f0100040 <_panic>
f010291f:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102925:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0102928:	75 a8                	jne    f01028d2 <mem_init+0x1662>
f010292a:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010292d:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102933:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102936:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102938:	89 da                	mov    %ebx,%edx
f010293a:	89 f8                	mov    %edi,%eax
f010293c:	e8 4a e1 ff ff       	call   f0100a8b <check_va2pa>
f0102941:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102944:	74 19                	je     f010295f <mem_init+0x16ef>
f0102946:	68 90 75 10 f0       	push   $0xf0107590
f010294b:	68 72 69 10 f0       	push   $0xf0106972
f0102950:	68 6a 03 00 00       	push   $0x36a
f0102955:	68 4c 69 10 f0       	push   $0xf010694c
f010295a:	e8 e1 d6 ff ff       	call   f0100040 <_panic>
f010295f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102965:	39 f3                	cmp    %esi,%ebx
f0102967:	75 cf                	jne    f0102938 <mem_init+0x16c8>
f0102969:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010296c:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102973:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f010297a:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102980:	b8 00 30 25 f0       	mov    $0xf0253000,%eax
f0102985:	39 f0                	cmp    %esi,%eax
f0102987:	0f 85 2c ff ff ff    	jne    f01028b9 <mem_init+0x1649>
f010298d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102992:	eb 2a                	jmp    f01029be <mem_init+0x174e>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102994:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f010299a:	83 fa 04             	cmp    $0x4,%edx
f010299d:	77 1f                	ja     f01029be <mem_init+0x174e>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f010299f:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f01029a3:	75 7e                	jne    f0102a23 <mem_init+0x17b3>
f01029a5:	68 8c 6c 10 f0       	push   $0xf0106c8c
f01029aa:	68 72 69 10 f0       	push   $0xf0106972
f01029af:	68 75 03 00 00       	push   $0x375
f01029b4:	68 4c 69 10 f0       	push   $0xf010694c
f01029b9:	e8 82 d6 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01029be:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01029c3:	76 3f                	jbe    f0102a04 <mem_init+0x1794>
				assert(pgdir[i] & PTE_P);
f01029c5:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01029c8:	f6 c2 01             	test   $0x1,%dl
f01029cb:	75 19                	jne    f01029e6 <mem_init+0x1776>
f01029cd:	68 8c 6c 10 f0       	push   $0xf0106c8c
f01029d2:	68 72 69 10 f0       	push   $0xf0106972
f01029d7:	68 79 03 00 00       	push   $0x379
f01029dc:	68 4c 69 10 f0       	push   $0xf010694c
f01029e1:	e8 5a d6 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01029e6:	f6 c2 02             	test   $0x2,%dl
f01029e9:	75 38                	jne    f0102a23 <mem_init+0x17b3>
f01029eb:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01029f0:	68 72 69 10 f0       	push   $0xf0106972
f01029f5:	68 7a 03 00 00       	push   $0x37a
f01029fa:	68 4c 69 10 f0       	push   $0xf010694c
f01029ff:	e8 3c d6 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102a04:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102a08:	74 19                	je     f0102a23 <mem_init+0x17b3>
f0102a0a:	68 ae 6c 10 f0       	push   $0xf0106cae
f0102a0f:	68 72 69 10 f0       	push   $0xf0106972
f0102a14:	68 7c 03 00 00       	push   $0x37c
f0102a19:	68 4c 69 10 f0       	push   $0xf010694c
f0102a1e:	e8 1d d6 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102a23:	83 c0 01             	add    $0x1,%eax
f0102a26:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102a2b:	0f 86 63 ff ff ff    	jbe    f0102994 <mem_init+0x1724>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102a31:	83 ec 0c             	sub    $0xc,%esp
f0102a34:	68 b4 75 10 f0       	push   $0xf01075b4
f0102a39:	e8 f4 0c 00 00       	call   f0103732 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102a3e:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a43:	83 c4 10             	add    $0x10,%esp
f0102a46:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a4b:	77 15                	ja     f0102a62 <mem_init+0x17f2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a4d:	50                   	push   %eax
f0102a4e:	68 68 64 10 f0       	push   $0xf0106468
f0102a53:	68 fa 00 00 00       	push   $0xfa
f0102a58:	68 4c 69 10 f0       	push   $0xf010694c
f0102a5d:	e8 de d5 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102a62:	05 00 00 00 10       	add    $0x10000000,%eax
f0102a67:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102a6a:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a6f:	e8 7b e0 ff ff       	call   f0100aef <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102a74:	0f 20 c0             	mov    %cr0,%eax
f0102a77:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102a7a:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102a7f:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102a82:	83 ec 0c             	sub    $0xc,%esp
f0102a85:	6a 00                	push   $0x0
f0102a87:	e8 69 e4 ff ff       	call   f0100ef5 <page_alloc>
f0102a8c:	89 c3                	mov    %eax,%ebx
f0102a8e:	83 c4 10             	add    $0x10,%esp
f0102a91:	85 c0                	test   %eax,%eax
f0102a93:	75 19                	jne    f0102aae <mem_init+0x183e>
f0102a95:	68 60 6a 10 f0       	push   $0xf0106a60
f0102a9a:	68 72 69 10 f0       	push   $0xf0106972
f0102a9f:	68 54 04 00 00       	push   $0x454
f0102aa4:	68 4c 69 10 f0       	push   $0xf010694c
f0102aa9:	e8 92 d5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102aae:	83 ec 0c             	sub    $0xc,%esp
f0102ab1:	6a 00                	push   $0x0
f0102ab3:	e8 3d e4 ff ff       	call   f0100ef5 <page_alloc>
f0102ab8:	89 c7                	mov    %eax,%edi
f0102aba:	83 c4 10             	add    $0x10,%esp
f0102abd:	85 c0                	test   %eax,%eax
f0102abf:	75 19                	jne    f0102ada <mem_init+0x186a>
f0102ac1:	68 76 6a 10 f0       	push   $0xf0106a76
f0102ac6:	68 72 69 10 f0       	push   $0xf0106972
f0102acb:	68 55 04 00 00       	push   $0x455
f0102ad0:	68 4c 69 10 f0       	push   $0xf010694c
f0102ad5:	e8 66 d5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102ada:	83 ec 0c             	sub    $0xc,%esp
f0102add:	6a 00                	push   $0x0
f0102adf:	e8 11 e4 ff ff       	call   f0100ef5 <page_alloc>
f0102ae4:	89 c6                	mov    %eax,%esi
f0102ae6:	83 c4 10             	add    $0x10,%esp
f0102ae9:	85 c0                	test   %eax,%eax
f0102aeb:	75 19                	jne    f0102b06 <mem_init+0x1896>
f0102aed:	68 8c 6a 10 f0       	push   $0xf0106a8c
f0102af2:	68 72 69 10 f0       	push   $0xf0106972
f0102af7:	68 56 04 00 00       	push   $0x456
f0102afc:	68 4c 69 10 f0       	push   $0xf010694c
f0102b01:	e8 3a d5 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102b06:	83 ec 0c             	sub    $0xc,%esp
f0102b09:	53                   	push   %ebx
f0102b0a:	e8 56 e4 ff ff       	call   f0100f65 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f0102b0f:	89 f8                	mov    %edi,%eax
f0102b11:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102b17:	c1 f8 03             	sar    $0x3,%eax
f0102b1a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b1d:	89 c2                	mov    %eax,%edx
f0102b1f:	c1 ea 0c             	shr    $0xc,%edx
f0102b22:	83 c4 10             	add    $0x10,%esp
f0102b25:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0102b2b:	72 12                	jb     f0102b3f <mem_init+0x18cf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b2d:	50                   	push   %eax
f0102b2e:	68 44 64 10 f0       	push   $0xf0106444
f0102b33:	6a 58                	push   $0x58
f0102b35:	68 58 69 10 f0       	push   $0xf0106958
f0102b3a:	e8 01 d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102b3f:	83 ec 04             	sub    $0x4,%esp
f0102b42:	68 00 10 00 00       	push   $0x1000
f0102b47:	6a 01                	push   $0x1
f0102b49:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b4e:	50                   	push   %eax
f0102b4f:	e8 0e 2c 00 00       	call   f0105762 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f0102b54:	89 f0                	mov    %esi,%eax
f0102b56:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102b5c:	c1 f8 03             	sar    $0x3,%eax
f0102b5f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b62:	89 c2                	mov    %eax,%edx
f0102b64:	c1 ea 0c             	shr    $0xc,%edx
f0102b67:	83 c4 10             	add    $0x10,%esp
f0102b6a:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0102b70:	72 12                	jb     f0102b84 <mem_init+0x1914>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b72:	50                   	push   %eax
f0102b73:	68 44 64 10 f0       	push   $0xf0106444
f0102b78:	6a 58                	push   $0x58
f0102b7a:	68 58 69 10 f0       	push   $0xf0106958
f0102b7f:	e8 bc d4 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102b84:	83 ec 04             	sub    $0x4,%esp
f0102b87:	68 00 10 00 00       	push   $0x1000
f0102b8c:	6a 02                	push   $0x2
f0102b8e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b93:	50                   	push   %eax
f0102b94:	e8 c9 2b 00 00       	call   f0105762 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102b99:	6a 02                	push   $0x2
f0102b9b:	68 00 10 00 00       	push   $0x1000
f0102ba0:	57                   	push   %edi
f0102ba1:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102ba7:	e8 1f e6 ff ff       	call   f01011cb <page_insert>
	assert(pp1->pp_ref == 1);
f0102bac:	83 c4 20             	add    $0x20,%esp
f0102baf:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102bb4:	74 19                	je     f0102bcf <mem_init+0x195f>
f0102bb6:	68 5d 6b 10 f0       	push   $0xf0106b5d
f0102bbb:	68 72 69 10 f0       	push   $0xf0106972
f0102bc0:	68 5b 04 00 00       	push   $0x45b
f0102bc5:	68 4c 69 10 f0       	push   $0xf010694c
f0102bca:	e8 71 d4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102bcf:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102bd6:	01 01 01 
f0102bd9:	74 19                	je     f0102bf4 <mem_init+0x1984>
f0102bdb:	68 d4 75 10 f0       	push   $0xf01075d4
f0102be0:	68 72 69 10 f0       	push   $0xf0106972
f0102be5:	68 5c 04 00 00       	push   $0x45c
f0102bea:	68 4c 69 10 f0       	push   $0xf010694c
f0102bef:	e8 4c d4 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102bf4:	6a 02                	push   $0x2
f0102bf6:	68 00 10 00 00       	push   $0x1000
f0102bfb:	56                   	push   %esi
f0102bfc:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102c02:	e8 c4 e5 ff ff       	call   f01011cb <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c07:	83 c4 10             	add    $0x10,%esp
f0102c0a:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c11:	02 02 02 
f0102c14:	74 19                	je     f0102c2f <mem_init+0x19bf>
f0102c16:	68 f8 75 10 f0       	push   $0xf01075f8
f0102c1b:	68 72 69 10 f0       	push   $0xf0106972
f0102c20:	68 5e 04 00 00       	push   $0x45e
f0102c25:	68 4c 69 10 f0       	push   $0xf010694c
f0102c2a:	e8 11 d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102c2f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c34:	74 19                	je     f0102c4f <mem_init+0x19df>
f0102c36:	68 7f 6b 10 f0       	push   $0xf0106b7f
f0102c3b:	68 72 69 10 f0       	push   $0xf0106972
f0102c40:	68 5f 04 00 00       	push   $0x45f
f0102c45:	68 4c 69 10 f0       	push   $0xf010694c
f0102c4a:	e8 f1 d3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102c4f:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c54:	74 19                	je     f0102c6f <mem_init+0x19ff>
f0102c56:	68 e9 6b 10 f0       	push   $0xf0106be9
f0102c5b:	68 72 69 10 f0       	push   $0xf0106972
f0102c60:	68 60 04 00 00       	push   $0x460
f0102c65:	68 4c 69 10 f0       	push   $0xf010694c
f0102c6a:	e8 d1 d3 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c6f:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c76:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f0102c79:	89 f0                	mov    %esi,%eax
f0102c7b:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102c81:	c1 f8 03             	sar    $0x3,%eax
f0102c84:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c87:	89 c2                	mov    %eax,%edx
f0102c89:	c1 ea 0c             	shr    $0xc,%edx
f0102c8c:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0102c92:	72 12                	jb     f0102ca6 <mem_init+0x1a36>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c94:	50                   	push   %eax
f0102c95:	68 44 64 10 f0       	push   $0xf0106444
f0102c9a:	6a 58                	push   $0x58
f0102c9c:	68 58 69 10 f0       	push   $0xf0106958
f0102ca1:	e8 9a d3 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ca6:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102cad:	03 03 03 
f0102cb0:	74 19                	je     f0102ccb <mem_init+0x1a5b>
f0102cb2:	68 1c 76 10 f0       	push   $0xf010761c
f0102cb7:	68 72 69 10 f0       	push   $0xf0106972
f0102cbc:	68 62 04 00 00       	push   $0x462
f0102cc1:	68 4c 69 10 f0       	push   $0xf010694c
f0102cc6:	e8 75 d3 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102ccb:	83 ec 08             	sub    $0x8,%esp
f0102cce:	68 00 10 00 00       	push   $0x1000
f0102cd3:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102cd9:	e8 a7 e4 ff ff       	call   f0101185 <page_remove>
	assert(pp2->pp_ref == 0);
f0102cde:	83 c4 10             	add    $0x10,%esp
f0102ce1:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102ce6:	74 19                	je     f0102d01 <mem_init+0x1a91>
f0102ce8:	68 b7 6b 10 f0       	push   $0xf0106bb7
f0102ced:	68 72 69 10 f0       	push   $0xf0106972
f0102cf2:	68 64 04 00 00       	push   $0x464
f0102cf7:	68 4c 69 10 f0       	push   $0xf010694c
f0102cfc:	e8 3f d3 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d01:	8b 0d 8c 1e 21 f0    	mov    0xf0211e8c,%ecx
f0102d07:	8b 11                	mov    (%ecx),%edx
f0102d09:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102d0f:	89 d8                	mov    %ebx,%eax
f0102d11:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102d17:	c1 f8 03             	sar    $0x3,%eax
f0102d1a:	c1 e0 0c             	shl    $0xc,%eax
f0102d1d:	39 c2                	cmp    %eax,%edx
f0102d1f:	74 19                	je     f0102d3a <mem_init+0x1aca>
f0102d21:	68 78 6f 10 f0       	push   $0xf0106f78
f0102d26:	68 72 69 10 f0       	push   $0xf0106972
f0102d2b:	68 67 04 00 00       	push   $0x467
f0102d30:	68 4c 69 10 f0       	push   $0xf010694c
f0102d35:	e8 06 d3 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102d3a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d40:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102d45:	74 19                	je     f0102d60 <mem_init+0x1af0>
f0102d47:	68 6e 6b 10 f0       	push   $0xf0106b6e
f0102d4c:	68 72 69 10 f0       	push   $0xf0106972
f0102d51:	68 69 04 00 00       	push   $0x469
f0102d56:	68 4c 69 10 f0       	push   $0xf010694c
f0102d5b:	e8 e0 d2 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102d60:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102d66:	83 ec 0c             	sub    $0xc,%esp
f0102d69:	53                   	push   %ebx
f0102d6a:	e8 f6 e1 ff ff       	call   f0100f65 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d6f:	c7 04 24 48 76 10 f0 	movl   $0xf0107648,(%esp)
f0102d76:	e8 b7 09 00 00       	call   f0103732 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
	cprintf("mem_init() success!\n**************\n\n\n");
f0102d7b:	c7 04 24 74 76 10 f0 	movl   $0xf0107674,(%esp)
f0102d82:	e8 ab 09 00 00       	call   f0103732 <cprintf>
}
f0102d87:	83 c4 10             	add    $0x10,%esp
f0102d8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d8d:	5b                   	pop    %ebx
f0102d8e:	5e                   	pop    %esi
f0102d8f:	5f                   	pop    %edi
f0102d90:	5d                   	pop    %ebp
f0102d91:	c3                   	ret    

f0102d92 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102d92:	55                   	push   %ebp
f0102d93:	89 e5                	mov    %esp,%ebp
f0102d95:	57                   	push   %edi
f0102d96:	56                   	push   %esi
f0102d97:	53                   	push   %ebx
f0102d98:	83 ec 1c             	sub    $0x1c,%esp
f0102d9b:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102d9e:	8b 75 14             	mov    0x14(%ebp),%esi
    // LAB 3: Your code here.
    char * end = NULL;
    char * start = NULL;
    start = ROUNDDOWN((char *)va, PGSIZE); 
f0102da1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102da4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102da9:	89 c3                	mov    %eax,%ebx
f0102dab:	89 45 e0             	mov    %eax,-0x20(%ebp)
    end = ROUNDUP((char *)(va + len), PGSIZE);
f0102dae:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102db1:	03 45 10             	add    0x10(%ebp),%eax
f0102db4:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102db9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102dbe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    pte_t *cur = NULL;

    for(; start < end; start += PGSIZE) {
f0102dc1:	eb 4e                	jmp    f0102e11 <user_mem_check+0x7f>
        cur = pgdir_walk(env->env_pgdir, (void *)start, 0);
f0102dc3:	83 ec 04             	sub    $0x4,%esp
f0102dc6:	6a 00                	push   $0x0
f0102dc8:	53                   	push   %ebx
f0102dc9:	ff 77 60             	pushl  0x60(%edi)
f0102dcc:	e8 f6 e1 ff ff       	call   f0100fc7 <pgdir_walk>
        if((int)start > ULIM || cur == NULL || ((uint32_t)(*cur) & perm) != perm) {
f0102dd1:	89 da                	mov    %ebx,%edx
f0102dd3:	83 c4 10             	add    $0x10,%esp
f0102dd6:	81 fb 00 00 80 ef    	cmp    $0xef800000,%ebx
f0102ddc:	77 0c                	ja     f0102dea <user_mem_check+0x58>
f0102dde:	85 c0                	test   %eax,%eax
f0102de0:	74 08                	je     f0102dea <user_mem_check+0x58>
f0102de2:	89 f1                	mov    %esi,%ecx
f0102de4:	23 08                	and    (%eax),%ecx
f0102de6:	39 ce                	cmp    %ecx,%esi
f0102de8:	74 21                	je     f0102e0b <user_mem_check+0x79>
              if(start == ROUNDDOWN((char *)va, PGSIZE)) {
f0102dea:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0102ded:	75 0f                	jne    f0102dfe <user_mem_check+0x6c>
                    user_mem_check_addr = (uintptr_t)va;
f0102def:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102df2:	a3 40 12 21 f0       	mov    %eax,0xf0211240
              }
              else {
                      user_mem_check_addr = (uintptr_t)start;
              }
              return -E_FAULT;
f0102df7:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102dfc:	eb 1d                	jmp    f0102e1b <user_mem_check+0x89>
        if((int)start > ULIM || cur == NULL || ((uint32_t)(*cur) & perm) != perm) {
              if(start == ROUNDDOWN((char *)va, PGSIZE)) {
                    user_mem_check_addr = (uintptr_t)va;
              }
              else {
                      user_mem_check_addr = (uintptr_t)start;
f0102dfe:	89 15 40 12 21 f0    	mov    %edx,0xf0211240
              }
              return -E_FAULT;
f0102e04:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102e09:	eb 10                	jmp    f0102e1b <user_mem_check+0x89>
    char * start = NULL;
    start = ROUNDDOWN((char *)va, PGSIZE); 
    end = ROUNDUP((char *)(va + len), PGSIZE);
    pte_t *cur = NULL;

    for(; start < end; start += PGSIZE) {
f0102e0b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e11:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102e14:	72 ad                	jb     f0102dc3 <user_mem_check+0x31>
              }
              return -E_FAULT;
        }
    }
        
    return 0;
f0102e16:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102e1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e1e:	5b                   	pop    %ebx
f0102e1f:	5e                   	pop    %esi
f0102e20:	5f                   	pop    %edi
f0102e21:	5d                   	pop    %ebp
f0102e22:	c3                   	ret    

f0102e23 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102e23:	55                   	push   %ebp
f0102e24:	89 e5                	mov    %esp,%ebp
f0102e26:	53                   	push   %ebx
f0102e27:	83 ec 04             	sub    $0x4,%esp
f0102e2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102e2d:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e30:	83 c8 04             	or     $0x4,%eax
f0102e33:	50                   	push   %eax
f0102e34:	ff 75 10             	pushl  0x10(%ebp)
f0102e37:	ff 75 0c             	pushl  0xc(%ebp)
f0102e3a:	53                   	push   %ebx
f0102e3b:	e8 52 ff ff ff       	call   f0102d92 <user_mem_check>
f0102e40:	83 c4 10             	add    $0x10,%esp
f0102e43:	85 c0                	test   %eax,%eax
f0102e45:	79 21                	jns    f0102e68 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102e47:	83 ec 04             	sub    $0x4,%esp
f0102e4a:	ff 35 40 12 21 f0    	pushl  0xf0211240
f0102e50:	ff 73 48             	pushl  0x48(%ebx)
f0102e53:	68 9c 76 10 f0       	push   $0xf010769c
f0102e58:	e8 d5 08 00 00       	call   f0103732 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102e5d:	89 1c 24             	mov    %ebx,(%esp)
f0102e60:	e8 f8 05 00 00       	call   f010345d <env_destroy>
f0102e65:	83 c4 10             	add    $0x10,%esp
	}
}
f0102e68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102e6b:	c9                   	leave  
f0102e6c:	c3                   	ret    

f0102e6d <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102e6d:	55                   	push   %ebp
f0102e6e:	89 e5                	mov    %esp,%ebp
f0102e70:	57                   	push   %edi
f0102e71:	56                   	push   %esi
f0102e72:	53                   	push   %ebx
f0102e73:	83 ec 0c             	sub    $0xc,%esp
f0102e76:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *start=ROUNDDOWN(va,PGSIZE),*end=ROUNDUP(va+len,PGSIZE);
f0102e78:	89 d3                	mov    %edx,%ebx
f0102e7a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102e80:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102e87:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for (void * addr=start;addr<end;addr+=PGSIZE){
f0102e8d:	eb 59                	jmp    f0102ee8 <region_alloc+0x7b>
		struct PageInfo* p=page_alloc(0);
f0102e8f:	83 ec 0c             	sub    $0xc,%esp
f0102e92:	6a 00                	push   $0x0
f0102e94:	e8 5c e0 ff ff       	call   f0100ef5 <page_alloc>
		if(p==NULL){
f0102e99:	83 c4 10             	add    $0x10,%esp
f0102e9c:	85 c0                	test   %eax,%eax
f0102e9e:	75 17                	jne    f0102eb7 <region_alloc+0x4a>
			panic("region alloc failed: No more page to be allocated.\n");
f0102ea0:	83 ec 04             	sub    $0x4,%esp
f0102ea3:	68 d4 76 10 f0       	push   $0xf01076d4
f0102ea8:	68 29 01 00 00       	push   $0x129
f0102ead:	68 8c 77 10 f0       	push   $0xf010778c
f0102eb2:	e8 89 d1 ff ff       	call   f0100040 <_panic>
		}
		else {
			if(page_insert(e->env_pgdir,p,addr, PTE_U | PTE_W)==-E_NO_MEM){
f0102eb7:	6a 06                	push   $0x6
f0102eb9:	53                   	push   %ebx
f0102eba:	50                   	push   %eax
f0102ebb:	ff 77 60             	pushl  0x60(%edi)
f0102ebe:	e8 08 e3 ff ff       	call   f01011cb <page_insert>
f0102ec3:	83 c4 10             	add    $0x10,%esp
f0102ec6:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102ec9:	75 17                	jne    f0102ee2 <region_alloc+0x75>
				panic("region alloc failed: page table couldn't be allocated.\n");
f0102ecb:	83 ec 04             	sub    $0x4,%esp
f0102ece:	68 08 77 10 f0       	push   $0xf0107708
f0102ed3:	68 2d 01 00 00       	push   $0x12d
f0102ed8:	68 8c 77 10 f0       	push   $0xf010778c
f0102edd:	e8 5e d1 ff ff       	call   f0100040 <_panic>
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *start=ROUNDDOWN(va,PGSIZE),*end=ROUNDUP(va+len,PGSIZE);
	for (void * addr=start;addr<end;addr+=PGSIZE){
f0102ee2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ee8:	39 f3                	cmp    %esi,%ebx
f0102eea:	72 a3                	jb     f0102e8f <region_alloc+0x22>
				panic("region alloc failed: page table couldn't be allocated.\n");
			}
		}
	}
	
}
f0102eec:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102eef:	5b                   	pop    %ebx
f0102ef0:	5e                   	pop    %esi
f0102ef1:	5f                   	pop    %edi
f0102ef2:	5d                   	pop    %ebp
f0102ef3:	c3                   	ret    

f0102ef4 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102ef4:	55                   	push   %ebp
f0102ef5:	89 e5                	mov    %esp,%ebp
f0102ef7:	56                   	push   %esi
f0102ef8:	53                   	push   %ebx
f0102ef9:	8b 45 08             	mov    0x8(%ebp),%eax
f0102efc:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102eff:	85 c0                	test   %eax,%eax
f0102f01:	75 1a                	jne    f0102f1d <envid2env+0x29>
		*env_store = curenv;
f0102f03:	e8 7a 2e 00 00       	call   f0105d82 <cpunum>
f0102f08:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f0b:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0102f11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102f14:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102f16:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f1b:	eb 70                	jmp    f0102f8d <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102f1d:	89 c3                	mov    %eax,%ebx
f0102f1f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102f25:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102f28:	03 1d 4c 12 21 f0    	add    0xf021124c,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102f2e:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102f32:	74 05                	je     f0102f39 <envid2env+0x45>
f0102f34:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102f37:	74 10                	je     f0102f49 <envid2env+0x55>
		*env_store = 0;
f0102f39:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f3c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102f42:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102f47:	eb 44                	jmp    f0102f8d <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102f49:	84 d2                	test   %dl,%dl
f0102f4b:	74 36                	je     f0102f83 <envid2env+0x8f>
f0102f4d:	e8 30 2e 00 00       	call   f0105d82 <cpunum>
f0102f52:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f55:	3b 98 28 20 21 f0    	cmp    -0xfdedfd8(%eax),%ebx
f0102f5b:	74 26                	je     f0102f83 <envid2env+0x8f>
f0102f5d:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102f60:	e8 1d 2e 00 00       	call   f0105d82 <cpunum>
f0102f65:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f68:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0102f6e:	3b 70 48             	cmp    0x48(%eax),%esi
f0102f71:	74 10                	je     f0102f83 <envid2env+0x8f>
		*env_store = 0;
f0102f73:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f76:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102f7c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102f81:	eb 0a                	jmp    f0102f8d <envid2env+0x99>
	}

	*env_store = e;
f0102f83:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f86:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102f88:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102f8d:	5b                   	pop    %ebx
f0102f8e:	5e                   	pop    %esi
f0102f8f:	5d                   	pop    %ebp
f0102f90:	c3                   	ret    

f0102f91 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102f91:	55                   	push   %ebp
f0102f92:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0102f94:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f0102f99:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0102f9c:	b8 23 00 00 00       	mov    $0x23,%eax
f0102fa1:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0102fa3:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0102fa5:	b8 10 00 00 00       	mov    $0x10,%eax
f0102faa:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0102fac:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0102fae:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0102fb0:	ea b7 2f 10 f0 08 00 	ljmp   $0x8,$0xf0102fb7
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0102fb7:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fbc:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102fbf:	5d                   	pop    %ebp
f0102fc0:	c3                   	ret    

f0102fc1 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102fc1:	55                   	push   %ebp
f0102fc2:	89 e5                	mov    %esp,%ebp
f0102fc4:	56                   	push   %esi
f0102fc5:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	//上面分析过 要从0 开始，所以我们倒着遍历。
	env_free_list=NULL;
	for	(int i=NENV-1;i>=0;i--){
		envs[i].env_id=0;
f0102fc6:	8b 35 4c 12 21 f0    	mov    0xf021124c,%esi
f0102fcc:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102fd2:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102fd5:	ba 00 00 00 00       	mov    $0x0,%edx
f0102fda:	89 c1                	mov    %eax,%ecx
f0102fdc:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_status=ENV_FREE;
f0102fe3:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_link=env_free_list;
f0102fea:	89 50 44             	mov    %edx,0x44(%eax)
f0102fed:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list=&envs[i];
f0102ff0:	89 ca                	mov    %ecx,%edx
{
	// Set up envs array
	// LAB 3: Your code here.
	//上面分析过 要从0 开始，所以我们倒着遍历。
	env_free_list=NULL;
	for	(int i=NENV-1;i>=0;i--){
f0102ff2:	39 d8                	cmp    %ebx,%eax
f0102ff4:	75 e4                	jne    f0102fda <env_init+0x19>
f0102ff6:	89 35 50 12 21 f0    	mov    %esi,0xf0211250
		envs[i].env_status=ENV_FREE;
		envs[i].env_link=env_free_list;
		env_free_list=&envs[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0102ffc:	e8 90 ff ff ff       	call   f0102f91 <env_init_percpu>
}
f0103001:	5b                   	pop    %ebx
f0103002:	5e                   	pop    %esi
f0103003:	5d                   	pop    %ebp
f0103004:	c3                   	ret    

f0103005 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103005:	55                   	push   %ebp
f0103006:	89 e5                	mov    %esp,%ebp
f0103008:	53                   	push   %ebx
f0103009:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010300c:	8b 1d 50 12 21 f0    	mov    0xf0211250,%ebx
f0103012:	85 db                	test   %ebx,%ebx
f0103014:	0f 84 2d 01 00 00    	je     f0103147 <env_alloc+0x142>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010301a:	83 ec 0c             	sub    $0xc,%esp
f010301d:	6a 01                	push   $0x1
f010301f:	e8 d1 de ff ff       	call   f0100ef5 <page_alloc>
f0103024:	83 c4 10             	add    $0x10,%esp
f0103027:	85 c0                	test   %eax,%eax
f0103029:	0f 84 1f 01 00 00    	je     f010314e <env_alloc+0x149>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f010302f:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{  	//将 PagaInfo 转换成真正的物理地址
	return (pp - pages) << PGSHIFT;
f0103034:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f010303a:	c1 f8 03             	sar    $0x3,%eax
f010303d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103040:	89 c2                	mov    %eax,%edx
f0103042:	c1 ea 0c             	shr    $0xc,%edx
f0103045:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f010304b:	72 12                	jb     f010305f <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010304d:	50                   	push   %eax
f010304e:	68 44 64 10 f0       	push   $0xf0106444
f0103053:	6a 58                	push   $0x58
f0103055:	68 58 69 10 f0       	push   $0xf0106958
f010305a:	e8 e1 cf ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010305f:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir=(pde_t *)page2kva(p);
f0103064:	89 43 60             	mov    %eax,0x60(%ebx)

	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103067:	83 ec 04             	sub    $0x4,%esp
f010306a:	68 00 10 00 00       	push   $0x1000
f010306f:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0103075:	50                   	push   %eax
f0103076:	e8 9c 27 00 00       	call   f0105817 <memcpy>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010307b:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010307e:	83 c4 10             	add    $0x10,%esp
f0103081:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103086:	77 15                	ja     f010309d <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103088:	50                   	push   %eax
f0103089:	68 68 64 10 f0       	push   $0xf0106468
f010308e:	68 c7 00 00 00       	push   $0xc7
f0103093:	68 8c 77 10 f0       	push   $0xf010778c
f0103098:	e8 a3 cf ff ff       	call   f0100040 <_panic>
f010309d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01030a3:	83 ca 05             	or     $0x5,%edx
f01030a6:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01030ac:	8b 43 48             	mov    0x48(%ebx),%eax
f01030af:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01030b4:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01030b9:	ba 00 10 00 00       	mov    $0x1000,%edx
f01030be:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01030c1:	89 da                	mov    %ebx,%edx
f01030c3:	2b 15 4c 12 21 f0    	sub    0xf021124c,%edx
f01030c9:	c1 fa 02             	sar    $0x2,%edx
f01030cc:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01030d2:	09 d0                	or     %edx,%eax
f01030d4:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01030d7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030da:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01030dd:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01030e4:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01030eb:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01030f2:	83 ec 04             	sub    $0x4,%esp
f01030f5:	6a 44                	push   $0x44
f01030f7:	6a 00                	push   $0x0
f01030f9:	53                   	push   %ebx
f01030fa:	e8 63 26 00 00       	call   f0105762 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01030ff:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103105:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010310b:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103111:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103118:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f010311e:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103125:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f010312c:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103130:	8b 43 44             	mov    0x44(%ebx),%eax
f0103133:	a3 50 12 21 f0       	mov    %eax,0xf0211250
	*newenv_store = e;
f0103138:	8b 45 08             	mov    0x8(%ebp),%eax
f010313b:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f010313d:	83 c4 10             	add    $0x10,%esp
f0103140:	b8 00 00 00 00       	mov    $0x0,%eax
f0103145:	eb 0c                	jmp    f0103153 <env_alloc+0x14e>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103147:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010314c:	eb 05                	jmp    f0103153 <env_alloc+0x14e>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010314e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103153:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103156:	c9                   	leave  
f0103157:	c3                   	ret    

f0103158 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103158:	55                   	push   %ebp
f0103159:	89 e5                	mov    %esp,%ebp
f010315b:	57                   	push   %edi
f010315c:	56                   	push   %esi
f010315d:	53                   	push   %ebx
f010315e:	83 ec 34             	sub    $0x34,%esp
f0103161:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env * e;
	int r=env_alloc(&e,0);
f0103164:	6a 00                	push   $0x0
f0103166:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103169:	50                   	push   %eax
f010316a:	e8 96 fe ff ff       	call   f0103005 <env_alloc>
	if(r!=0){
f010316f:	83 c4 10             	add    $0x10,%esp
f0103172:	85 c0                	test   %eax,%eax
f0103174:	74 25                	je     f010319b <env_create+0x43>
		cprintf("%e\n",r);
f0103176:	83 ec 08             	sub    $0x8,%esp
f0103179:	50                   	push   %eax
f010317a:	68 2b 7f 10 f0       	push   $0xf0107f2b
f010317f:	e8 ae 05 00 00       	call   f0103732 <cprintf>
		panic("env_create:error");
f0103184:	83 c4 0c             	add    $0xc,%esp
f0103187:	68 97 77 10 f0       	push   $0xf0107797
f010318c:	68 97 01 00 00       	push   $0x197
f0103191:	68 8c 77 10 f0       	push   $0xf010778c
f0103196:	e8 a5 ce ff ff       	call   f0100040 <_panic>
	}
	load_icode(e,binary);
f010319b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010319e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	//根据，分析 首先需要做的一件事 应该是讲binary 转换成 ELF，参照bootmain。
	struct Proghdr *ph, *eph;
	struct Elf * ELFHDR=(struct Elf *)binary;
	if (ELFHDR->e_magic != ELF_MAGIC)panic("The loaded file is not ELF format!\n");
f01031a1:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01031a7:	74 17                	je     f01031c0 <env_create+0x68>
f01031a9:	83 ec 04             	sub    $0x4,%esp
f01031ac:	68 40 77 10 f0       	push   $0xf0107740
f01031b1:	68 6d 01 00 00       	push   $0x16d
f01031b6:	68 8c 77 10 f0       	push   $0xf010778c
f01031bb:	e8 80 ce ff ff       	call   f0100040 <_panic>
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f01031c0:	89 fb                	mov    %edi,%ebx
f01031c2:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + ELFHDR->e_phnum;
f01031c5:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01031c9:	c1 e6 05             	shl    $0x5,%esi
f01031cc:	01 de                	add    %ebx,%esi
	//装载 用户目录
	lcr3(PADDR(e->env_pgdir));
f01031ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01031d1:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031d4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031d9:	77 15                	ja     f01031f0 <env_create+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031db:	50                   	push   %eax
f01031dc:	68 68 64 10 f0       	push   $0xf0106468
f01031e1:	68 71 01 00 00       	push   $0x171
f01031e6:	68 8c 77 10 f0       	push   $0xf010778c
f01031eb:	e8 50 ce ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01031f0:	05 00 00 00 10       	add    $0x10000000,%eax
f01031f5:	0f 22 d8             	mov    %eax,%cr3
f01031f8:	eb 59                	jmp    f0103253 <env_create+0xfb>
	//第二部应该是加载段到内存
	for(;ph<eph;ph++){
		//加载条件是  ph->p_type == ELF_PROG_LOAD，地址是 ph->p_va 大小ph->p_memsz
		if(ph->p_type == ELF_PROG_LOAD){
f01031fa:	83 3b 01             	cmpl   $0x1,(%ebx)
f01031fd:	75 51                	jne    f0103250 <env_create+0xf8>
			if (ph->p_filesz > ph->p_memsz)
f01031ff:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103202:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103205:	76 17                	jbe    f010321e <env_create+0xc6>
                panic("load_icode failed: p_memsz < p_filesz.\n");
f0103207:	83 ec 04             	sub    $0x4,%esp
f010320a:	68 64 77 10 f0       	push   $0xf0107764
f010320f:	68 77 01 00 00       	push   $0x177
f0103214:	68 8c 77 10 f0       	push   $0xf010778c
f0103219:	e8 22 ce ff ff       	call   f0100040 <_panic>
			region_alloc(e, (void *)ph->p_va,ph->p_memsz);
f010321e:	8b 53 08             	mov    0x8(%ebx),%edx
f0103221:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103224:	e8 44 fc ff ff       	call   f0102e6d <region_alloc>
			//复制ph->p_filesz bytes ，其他的补0
			memset((void *)ph->p_va,0,ph->p_memsz);
f0103229:	83 ec 04             	sub    $0x4,%esp
f010322c:	ff 73 14             	pushl  0x14(%ebx)
f010322f:	6a 00                	push   $0x0
f0103231:	ff 73 08             	pushl  0x8(%ebx)
f0103234:	e8 29 25 00 00       	call   f0105762 <memset>
			memcpy((void *)ph->p_va,binary + ph->p_offset,ph->p_filesz);
f0103239:	83 c4 0c             	add    $0xc,%esp
f010323c:	ff 73 10             	pushl  0x10(%ebx)
f010323f:	89 f8                	mov    %edi,%eax
f0103241:	03 43 04             	add    0x4(%ebx),%eax
f0103244:	50                   	push   %eax
f0103245:	ff 73 08             	pushl  0x8(%ebx)
f0103248:	e8 ca 25 00 00       	call   f0105817 <memcpy>
f010324d:	83 c4 10             	add    $0x10,%esp
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	//装载 用户目录
	lcr3(PADDR(e->env_pgdir));
	//第二部应该是加载段到内存
	for(;ph<eph;ph++){
f0103250:	83 c3 20             	add    $0x20,%ebx
f0103253:	39 de                	cmp    %ebx,%esi
f0103255:	77 a3                	ja     f01031fa <env_create+0xa2>
			//复制ph->p_filesz bytes ，其他的补0
			memset((void *)ph->p_va,0,ph->p_memsz);
			memcpy((void *)ph->p_va,binary + ph->p_offset,ph->p_filesz);
		}
	}
	 lcr3(PADDR(kern_pgdir));
f0103257:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010325c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103261:	77 15                	ja     f0103278 <env_create+0x120>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103263:	50                   	push   %eax
f0103264:	68 68 64 10 f0       	push   $0xf0106468
f0103269:	68 7e 01 00 00       	push   $0x17e
f010326e:	68 8c 77 10 f0       	push   $0xf010778c
f0103273:	e8 c8 cd ff ff       	call   f0100040 <_panic>
f0103278:	05 00 00 00 10       	add    $0x10000000,%eax
f010327d:	0f 22 d8             	mov    %eax,%cr3
	//最后是入口地址  这个实在 inc/trap.h 里面定义的
	 e->env_tf.tf_eip = ELFHDR->e_entry;
f0103280:	8b 47 18             	mov    0x18(%edi),%eax
f0103283:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103286:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	
	// LAB 3: Your code here.
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103289:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010328e:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103293:	89 f8                	mov    %edi,%eax
f0103295:	e8 d3 fb ff ff       	call   f0102e6d <region_alloc>
	if(r!=0){
		cprintf("%e\n",r);
		panic("env_create:error");
	}
	load_icode(e,binary);
	e->env_type=type;
f010329a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010329d:	8b 55 0c             	mov    0xc(%ebp),%edx
f01032a0:	89 50 50             	mov    %edx,0x50(%eax)

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
	if(type==ENV_TYPE_FS)e->env_tf.tf_eflags|=FL_IOPL_MASK;
f01032a3:	83 fa 01             	cmp    $0x1,%edx
f01032a6:	75 07                	jne    f01032af <env_create+0x157>
f01032a8:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
}
f01032af:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01032b2:	5b                   	pop    %ebx
f01032b3:	5e                   	pop    %esi
f01032b4:	5f                   	pop    %edi
f01032b5:	5d                   	pop    %ebp
f01032b6:	c3                   	ret    

f01032b7 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01032b7:	55                   	push   %ebp
f01032b8:	89 e5                	mov    %esp,%ebp
f01032ba:	57                   	push   %edi
f01032bb:	56                   	push   %esi
f01032bc:	53                   	push   %ebx
f01032bd:	83 ec 1c             	sub    $0x1c,%esp
f01032c0:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01032c3:	e8 ba 2a 00 00       	call   f0105d82 <cpunum>
f01032c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01032cb:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01032d2:	39 b8 28 20 21 f0    	cmp    %edi,-0xfdedfd8(%eax)
f01032d8:	75 30                	jne    f010330a <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f01032da:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032df:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032e4:	77 15                	ja     f01032fb <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032e6:	50                   	push   %eax
f01032e7:	68 68 64 10 f0       	push   $0xf0106468
f01032ec:	68 af 01 00 00       	push   $0x1af
f01032f1:	68 8c 77 10 f0       	push   $0xf010778c
f01032f6:	e8 45 cd ff ff       	call   f0100040 <_panic>
f01032fb:	05 00 00 00 10       	add    $0x10000000,%eax
f0103300:	0f 22 d8             	mov    %eax,%cr3
f0103303:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010330a:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010330d:	89 d0                	mov    %edx,%eax
f010330f:	c1 e0 02             	shl    $0x2,%eax
f0103312:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103315:	8b 47 60             	mov    0x60(%edi),%eax
f0103318:	8b 34 90             	mov    (%eax,%edx,4),%esi
f010331b:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103321:	0f 84 a8 00 00 00    	je     f01033cf <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103327:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010332d:	89 f0                	mov    %esi,%eax
f010332f:	c1 e8 0c             	shr    $0xc,%eax
f0103332:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103335:	39 05 88 1e 21 f0    	cmp    %eax,0xf0211e88
f010333b:	77 15                	ja     f0103352 <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010333d:	56                   	push   %esi
f010333e:	68 44 64 10 f0       	push   $0xf0106444
f0103343:	68 be 01 00 00       	push   $0x1be
f0103348:	68 8c 77 10 f0       	push   $0xf010778c
f010334d:	e8 ee cc ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103352:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103355:	c1 e0 16             	shl    $0x16,%eax
f0103358:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010335b:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103360:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103367:	01 
f0103368:	74 17                	je     f0103381 <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010336a:	83 ec 08             	sub    $0x8,%esp
f010336d:	89 d8                	mov    %ebx,%eax
f010336f:	c1 e0 0c             	shl    $0xc,%eax
f0103372:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103375:	50                   	push   %eax
f0103376:	ff 77 60             	pushl  0x60(%edi)
f0103379:	e8 07 de ff ff       	call   f0101185 <page_remove>
f010337e:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103381:	83 c3 01             	add    $0x1,%ebx
f0103384:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010338a:	75 d4                	jne    f0103360 <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010338c:	8b 47 60             	mov    0x60(%edi),%eax
f010338f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103392:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{	// 或得物理地址的数据结构
	if (PGNUM(pa) >= npages)
f0103399:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010339c:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f01033a2:	72 14                	jb     f01033b8 <env_free+0x101>
		panic("pa2page called with invalid pa");
f01033a4:	83 ec 04             	sub    $0x4,%esp
f01033a7:	68 d4 6d 10 f0       	push   $0xf0106dd4
f01033ac:	6a 51                	push   $0x51
f01033ae:	68 58 69 10 f0       	push   $0xf0106958
f01033b3:	e8 88 cc ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f01033b8:	83 ec 0c             	sub    $0xc,%esp
f01033bb:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
f01033c0:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01033c3:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01033c6:	50                   	push   %eax
f01033c7:	e8 d4 db ff ff       	call   f0100fa0 <page_decref>
f01033cc:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01033cf:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01033d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01033d6:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01033db:	0f 85 29 ff ff ff    	jne    f010330a <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01033e1:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033e4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033e9:	77 15                	ja     f0103400 <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033eb:	50                   	push   %eax
f01033ec:	68 68 64 10 f0       	push   $0xf0106468
f01033f1:	68 cc 01 00 00       	push   $0x1cc
f01033f6:	68 8c 77 10 f0       	push   $0xf010778c
f01033fb:	e8 40 cc ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103400:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{	// 或得物理地址的数据结构
	if (PGNUM(pa) >= npages)
f0103407:	05 00 00 00 10       	add    $0x10000000,%eax
f010340c:	c1 e8 0c             	shr    $0xc,%eax
f010340f:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f0103415:	72 14                	jb     f010342b <env_free+0x174>
		panic("pa2page called with invalid pa");
f0103417:	83 ec 04             	sub    $0x4,%esp
f010341a:	68 d4 6d 10 f0       	push   $0xf0106dd4
f010341f:	6a 51                	push   $0x51
f0103421:	68 58 69 10 f0       	push   $0xf0106958
f0103426:	e8 15 cc ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f010342b:	83 ec 0c             	sub    $0xc,%esp
f010342e:	8b 15 90 1e 21 f0    	mov    0xf0211e90,%edx
f0103434:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103437:	50                   	push   %eax
f0103438:	e8 63 db ff ff       	call   f0100fa0 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010343d:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103444:	a1 50 12 21 f0       	mov    0xf0211250,%eax
f0103449:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010344c:	89 3d 50 12 21 f0    	mov    %edi,0xf0211250
}
f0103452:	83 c4 10             	add    $0x10,%esp
f0103455:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103458:	5b                   	pop    %ebx
f0103459:	5e                   	pop    %esi
f010345a:	5f                   	pop    %edi
f010345b:	5d                   	pop    %ebp
f010345c:	c3                   	ret    

f010345d <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f010345d:	55                   	push   %ebp
f010345e:	89 e5                	mov    %esp,%ebp
f0103460:	53                   	push   %ebx
f0103461:	83 ec 04             	sub    $0x4,%esp
f0103464:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103467:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f010346b:	75 19                	jne    f0103486 <env_destroy+0x29>
f010346d:	e8 10 29 00 00       	call   f0105d82 <cpunum>
f0103472:	6b c0 74             	imul   $0x74,%eax,%eax
f0103475:	3b 98 28 20 21 f0    	cmp    -0xfdedfd8(%eax),%ebx
f010347b:	74 09                	je     f0103486 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f010347d:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103484:	eb 33                	jmp    f01034b9 <env_destroy+0x5c>
	}

	env_free(e);
f0103486:	83 ec 0c             	sub    $0xc,%esp
f0103489:	53                   	push   %ebx
f010348a:	e8 28 fe ff ff       	call   f01032b7 <env_free>

	if (curenv == e) {
f010348f:	e8 ee 28 00 00       	call   f0105d82 <cpunum>
f0103494:	6b c0 74             	imul   $0x74,%eax,%eax
f0103497:	83 c4 10             	add    $0x10,%esp
f010349a:	3b 98 28 20 21 f0    	cmp    -0xfdedfd8(%eax),%ebx
f01034a0:	75 17                	jne    f01034b9 <env_destroy+0x5c>
		curenv = NULL;
f01034a2:	e8 db 28 00 00       	call   f0105d82 <cpunum>
f01034a7:	6b c0 74             	imul   $0x74,%eax,%eax
f01034aa:	c7 80 28 20 21 f0 00 	movl   $0x0,-0xfdedfd8(%eax)
f01034b1:	00 00 00 
		sched_yield();
f01034b4:	e8 a1 10 00 00       	call   f010455a <sched_yield>
	}
}
f01034b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01034bc:	c9                   	leave  
f01034bd:	c3                   	ret    

f01034be <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01034be:	55                   	push   %ebp
f01034bf:	89 e5                	mov    %esp,%ebp
f01034c1:	53                   	push   %ebx
f01034c2:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01034c5:	e8 b8 28 00 00       	call   f0105d82 <cpunum>
f01034ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01034cd:	8b 98 28 20 21 f0    	mov    -0xfdedfd8(%eax),%ebx
f01034d3:	e8 aa 28 00 00       	call   f0105d82 <cpunum>
f01034d8:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f01034db:	8b 65 08             	mov    0x8(%ebp),%esp
f01034de:	61                   	popa   
f01034df:	07                   	pop    %es
f01034e0:	1f                   	pop    %ds
f01034e1:	83 c4 08             	add    $0x8,%esp
f01034e4:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01034e5:	83 ec 04             	sub    $0x4,%esp
f01034e8:	68 a8 77 10 f0       	push   $0xf01077a8
f01034ed:	68 03 02 00 00       	push   $0x203
f01034f2:	68 8c 77 10 f0       	push   $0xf010778c
f01034f7:	e8 44 cb ff ff       	call   f0100040 <_panic>

f01034fc <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01034fc:	55                   	push   %ebp
f01034fd:	89 e5                	mov    %esp,%ebp
f01034ff:	53                   	push   %ebx
f0103500:	83 ec 04             	sub    $0x4,%esp
f0103503:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv!=NULL&&curenv->env_status==ENV_RUNNING){
f0103506:	e8 77 28 00 00       	call   f0105d82 <cpunum>
f010350b:	6b c0 74             	imul   $0x74,%eax,%eax
f010350e:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f0103515:	74 29                	je     f0103540 <env_run+0x44>
f0103517:	e8 66 28 00 00       	call   f0105d82 <cpunum>
f010351c:	6b c0 74             	imul   $0x74,%eax,%eax
f010351f:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103525:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103529:	75 15                	jne    f0103540 <env_run+0x44>
		curenv->env_status=ENV_RUNNABLE;
f010352b:	e8 52 28 00 00       	call   f0105d82 <cpunum>
f0103530:	6b c0 74             	imul   $0x74,%eax,%eax
f0103533:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103539:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
	curenv=e;
f0103540:	e8 3d 28 00 00       	call   f0105d82 <cpunum>
f0103545:	6b c0 74             	imul   $0x74,%eax,%eax
f0103548:	89 98 28 20 21 f0    	mov    %ebx,-0xfdedfd8(%eax)
	// if(&curenv->env_tf==NULL)cprintf("***");
	e->env_status=ENV_RUNNING;
f010354e:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	e->env_runs++;
f0103555:	83 43 58 01          	addl   $0x1,0x58(%ebx)
	lcr3(PADDR(curenv->env_pgdir));
f0103559:	e8 24 28 00 00       	call   f0105d82 <cpunum>
f010355e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103561:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103567:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010356a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010356f:	77 15                	ja     f0103586 <env_run+0x8a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103571:	50                   	push   %eax
f0103572:	68 68 64 10 f0       	push   $0xf0106468
f0103577:	68 28 02 00 00       	push   $0x228
f010357c:	68 8c 77 10 f0       	push   $0xf010778c
f0103581:	e8 ba ca ff ff       	call   f0100040 <_panic>
f0103586:	05 00 00 00 10       	add    $0x10000000,%eax
f010358b:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010358e:	83 ec 0c             	sub    $0xc,%esp
f0103591:	68 c0 03 12 f0       	push   $0xf01203c0
f0103596:	e8 f2 2a 00 00       	call   f010608d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010359b:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(&curenv->env_tf);
f010359d:	e8 e0 27 00 00       	call   f0105d82 <cpunum>
f01035a2:	83 c4 04             	add    $0x4,%esp
f01035a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01035a8:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f01035ae:	e8 0b ff ff ff       	call   f01034be <env_pop_tf>

f01035b3 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01035b3:	55                   	push   %ebp
f01035b4:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01035b6:	ba 70 00 00 00       	mov    $0x70,%edx
f01035bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01035be:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01035bf:	ba 71 00 00 00       	mov    $0x71,%edx
f01035c4:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01035c5:	0f b6 c0             	movzbl %al,%eax
}
f01035c8:	5d                   	pop    %ebp
f01035c9:	c3                   	ret    

f01035ca <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01035ca:	55                   	push   %ebp
f01035cb:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01035cd:	ba 70 00 00 00       	mov    $0x70,%edx
f01035d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01035d5:	ee                   	out    %al,(%dx)
f01035d6:	ba 71 00 00 00       	mov    $0x71,%edx
f01035db:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035de:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01035df:	5d                   	pop    %ebp
f01035e0:	c3                   	ret    

f01035e1 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01035e1:	55                   	push   %ebp
f01035e2:	89 e5                	mov    %esp,%ebp
f01035e4:	56                   	push   %esi
f01035e5:	53                   	push   %ebx
f01035e6:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f01035e9:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f01035ef:	80 3d 54 12 21 f0 00 	cmpb   $0x0,0xf0211254
f01035f6:	74 5a                	je     f0103652 <irq_setmask_8259A+0x71>
f01035f8:	89 c6                	mov    %eax,%esi
f01035fa:	ba 21 00 00 00       	mov    $0x21,%edx
f01035ff:	ee                   	out    %al,(%dx)
f0103600:	66 c1 e8 08          	shr    $0x8,%ax
f0103604:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103609:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f010360a:	83 ec 0c             	sub    $0xc,%esp
f010360d:	68 b4 77 10 f0       	push   $0xf01077b4
f0103612:	e8 1b 01 00 00       	call   f0103732 <cprintf>
f0103617:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f010361a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f010361f:	0f b7 f6             	movzwl %si,%esi
f0103622:	f7 d6                	not    %esi
f0103624:	0f a3 de             	bt     %ebx,%esi
f0103627:	73 11                	jae    f010363a <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103629:	83 ec 08             	sub    $0x8,%esp
f010362c:	53                   	push   %ebx
f010362d:	68 2b 7c 10 f0       	push   $0xf0107c2b
f0103632:	e8 fb 00 00 00       	call   f0103732 <cprintf>
f0103637:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010363a:	83 c3 01             	add    $0x1,%ebx
f010363d:	83 fb 10             	cmp    $0x10,%ebx
f0103640:	75 e2                	jne    f0103624 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103642:	83 ec 0c             	sub    $0xc,%esp
f0103645:	68 52 6c 10 f0       	push   $0xf0106c52
f010364a:	e8 e3 00 00 00       	call   f0103732 <cprintf>
f010364f:	83 c4 10             	add    $0x10,%esp
}
f0103652:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103655:	5b                   	pop    %ebx
f0103656:	5e                   	pop    %esi
f0103657:	5d                   	pop    %ebp
f0103658:	c3                   	ret    

f0103659 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103659:	c6 05 54 12 21 f0 01 	movb   $0x1,0xf0211254
f0103660:	ba 21 00 00 00       	mov    $0x21,%edx
f0103665:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010366a:	ee                   	out    %al,(%dx)
f010366b:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103670:	ee                   	out    %al,(%dx)
f0103671:	ba 20 00 00 00       	mov    $0x20,%edx
f0103676:	b8 11 00 00 00       	mov    $0x11,%eax
f010367b:	ee                   	out    %al,(%dx)
f010367c:	ba 21 00 00 00       	mov    $0x21,%edx
f0103681:	b8 20 00 00 00       	mov    $0x20,%eax
f0103686:	ee                   	out    %al,(%dx)
f0103687:	b8 04 00 00 00       	mov    $0x4,%eax
f010368c:	ee                   	out    %al,(%dx)
f010368d:	b8 03 00 00 00       	mov    $0x3,%eax
f0103692:	ee                   	out    %al,(%dx)
f0103693:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103698:	b8 11 00 00 00       	mov    $0x11,%eax
f010369d:	ee                   	out    %al,(%dx)
f010369e:	ba a1 00 00 00       	mov    $0xa1,%edx
f01036a3:	b8 28 00 00 00       	mov    $0x28,%eax
f01036a8:	ee                   	out    %al,(%dx)
f01036a9:	b8 02 00 00 00       	mov    $0x2,%eax
f01036ae:	ee                   	out    %al,(%dx)
f01036af:	b8 01 00 00 00       	mov    $0x1,%eax
f01036b4:	ee                   	out    %al,(%dx)
f01036b5:	ba 20 00 00 00       	mov    $0x20,%edx
f01036ba:	b8 68 00 00 00       	mov    $0x68,%eax
f01036bf:	ee                   	out    %al,(%dx)
f01036c0:	b8 0a 00 00 00       	mov    $0xa,%eax
f01036c5:	ee                   	out    %al,(%dx)
f01036c6:	ba a0 00 00 00       	mov    $0xa0,%edx
f01036cb:	b8 68 00 00 00       	mov    $0x68,%eax
f01036d0:	ee                   	out    %al,(%dx)
f01036d1:	b8 0a 00 00 00       	mov    $0xa,%eax
f01036d6:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01036d7:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f01036de:	66 83 f8 ff          	cmp    $0xffff,%ax
f01036e2:	74 13                	je     f01036f7 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01036e4:	55                   	push   %ebp
f01036e5:	89 e5                	mov    %esp,%ebp
f01036e7:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f01036ea:	0f b7 c0             	movzwl %ax,%eax
f01036ed:	50                   	push   %eax
f01036ee:	e8 ee fe ff ff       	call   f01035e1 <irq_setmask_8259A>
f01036f3:	83 c4 10             	add    $0x10,%esp
}
f01036f6:	c9                   	leave  
f01036f7:	f3 c3                	repz ret 

f01036f9 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01036f9:	55                   	push   %ebp
f01036fa:	89 e5                	mov    %esp,%ebp
f01036fc:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01036ff:	ff 75 08             	pushl  0x8(%ebp)
f0103702:	e8 7b d0 ff ff       	call   f0100782 <cputchar>
	*cnt++;
}
f0103707:	83 c4 10             	add    $0x10,%esp
f010370a:	c9                   	leave  
f010370b:	c3                   	ret    

f010370c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010370c:	55                   	push   %ebp
f010370d:	89 e5                	mov    %esp,%ebp
f010370f:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103712:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103719:	ff 75 0c             	pushl  0xc(%ebp)
f010371c:	ff 75 08             	pushl  0x8(%ebp)
f010371f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103722:	50                   	push   %eax
f0103723:	68 f9 36 10 f0       	push   $0xf01036f9
f0103728:	e8 f8 18 00 00       	call   f0105025 <vprintfmt>
	return cnt;
}
f010372d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103730:	c9                   	leave  
f0103731:	c3                   	ret    

f0103732 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103732:	55                   	push   %ebp
f0103733:	89 e5                	mov    %esp,%ebp
f0103735:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103738:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010373b:	50                   	push   %eax
f010373c:	ff 75 08             	pushl  0x8(%ebp)
f010373f:	e8 c8 ff ff ff       	call   f010370c <vcprintf>
	va_end(ap);

	return cnt;
}
f0103744:	c9                   	leave  
f0103745:	c3                   	ret    

f0103746 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103746:	55                   	push   %ebp
f0103747:	89 e5                	mov    %esp,%ebp
f0103749:	57                   	push   %edi
f010374a:	56                   	push   %esi
f010374b:	53                   	push   %ebx
f010374c:	83 ec 0c             	sub    $0xc,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here
	int i=thiscpu->cpu_id;
f010374f:	e8 2e 26 00 00       	call   f0105d82 <cpunum>
f0103754:	6b c0 74             	imul   $0x74,%eax,%eax
f0103757:	0f b6 98 20 20 21 f0 	movzbl -0xfdedfe0(%eax),%ebx
	thiscpu->cpu_ts.ts_esp0=KSTACKTOP-i*(KSTKSIZE+KSTKGAP);
f010375e:	e8 1f 26 00 00       	call   f0105d82 <cpunum>
f0103763:	6b c0 74             	imul   $0x74,%eax,%eax
f0103766:	89 d9                	mov    %ebx,%ecx
f0103768:	c1 e1 10             	shl    $0x10,%ecx
f010376b:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0103770:	29 ca                	sub    %ecx,%edx
f0103772:	89 90 30 20 21 f0    	mov    %edx,-0xfdedfd0(%eax)
	thiscpu->cpu_ts.ts_ss0=GD_KD;
f0103778:	e8 05 26 00 00       	call   f0105d82 <cpunum>
f010377d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103780:	66 c7 80 34 20 21 f0 	movw   $0x10,-0xfdedfcc(%eax)
f0103787:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103789:	e8 f4 25 00 00       	call   f0105d82 <cpunum>
f010378e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103791:	66 c7 80 92 20 21 f0 	movw   $0x68,-0xfdedf6e(%eax)
f0103798:	68 00 

	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f010379a:	83 c3 05             	add    $0x5,%ebx
f010379d:	e8 e0 25 00 00       	call   f0105d82 <cpunum>
f01037a2:	89 c7                	mov    %eax,%edi
f01037a4:	e8 d9 25 00 00       	call   f0105d82 <cpunum>
f01037a9:	89 c6                	mov    %eax,%esi
f01037ab:	e8 d2 25 00 00       	call   f0105d82 <cpunum>
f01037b0:	66 c7 04 dd 40 03 12 	movw   $0x67,-0xfedfcc0(,%ebx,8)
f01037b7:	f0 67 00 
f01037ba:	6b ff 74             	imul   $0x74,%edi,%edi
f01037bd:	81 c7 2c 20 21 f0    	add    $0xf021202c,%edi
f01037c3:	66 89 3c dd 42 03 12 	mov    %di,-0xfedfcbe(,%ebx,8)
f01037ca:	f0 
f01037cb:	6b d6 74             	imul   $0x74,%esi,%edx
f01037ce:	81 c2 2c 20 21 f0    	add    $0xf021202c,%edx
f01037d4:	c1 ea 10             	shr    $0x10,%edx
f01037d7:	88 14 dd 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%ebx,8)
f01037de:	c6 04 dd 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%ebx,8)
f01037e5:	40 
f01037e6:	6b c0 74             	imul   $0x74,%eax,%eax
f01037e9:	05 2c 20 21 f0       	add    $0xf021202c,%eax
f01037ee:	c1 e8 18             	shr    $0x18,%eax
f01037f1:	88 04 dd 47 03 12 f0 	mov    %al,-0xfedfcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f01037f8:	c6 04 dd 45 03 12 f0 	movb   $0x89,-0xfedfcbb(,%ebx,8)
f01037ff:	89 
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103800:	c1 e3 03             	shl    $0x3,%ebx
f0103803:	0f 00 db             	ltr    %bx
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103806:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f010380b:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0+8*i);

	// Load the IDT
	lidt(&idt_pd);
}
f010380e:	83 c4 0c             	add    $0xc,%esp
f0103811:	5b                   	pop    %ebx
f0103812:	5e                   	pop    %esi
f0103813:	5f                   	pop    %edi
f0103814:	5d                   	pop    %ebp
f0103815:	c3                   	ret    

f0103816 <trap_init>:
void IRQ15();


void
trap_init(void)
{
f0103816:	55                   	push   %ebp
f0103817:	89 e5                	mov    %esp,%ebp
f0103819:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];
	// LAB 3: Your code here.


	SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f010381c:	b8 7c 43 10 f0       	mov    $0xf010437c,%eax
f0103821:	66 a3 60 12 21 f0    	mov    %ax,0xf0211260
f0103827:	66 c7 05 62 12 21 f0 	movw   $0x8,0xf0211262
f010382e:	08 00 
f0103830:	c6 05 64 12 21 f0 00 	movb   $0x0,0xf0211264
f0103837:	c6 05 65 12 21 f0 8e 	movb   $0x8e,0xf0211265
f010383e:	c1 e8 10             	shr    $0x10,%eax
f0103841:	66 a3 66 12 21 f0    	mov    %ax,0xf0211266
	SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f0103847:	b8 86 43 10 f0       	mov    $0xf0104386,%eax
f010384c:	66 a3 68 12 21 f0    	mov    %ax,0xf0211268
f0103852:	66 c7 05 6a 12 21 f0 	movw   $0x8,0xf021126a
f0103859:	08 00 
f010385b:	c6 05 6c 12 21 f0 00 	movb   $0x0,0xf021126c
f0103862:	c6 05 6d 12 21 f0 8e 	movb   $0x8e,0xf021126d
f0103869:	c1 e8 10             	shr    $0x10,%eax
f010386c:	66 a3 6e 12 21 f0    	mov    %ax,0xf021126e
	SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f0103872:	b8 90 43 10 f0       	mov    $0xf0104390,%eax
f0103877:	66 a3 70 12 21 f0    	mov    %ax,0xf0211270
f010387d:	66 c7 05 72 12 21 f0 	movw   $0x8,0xf0211272
f0103884:	08 00 
f0103886:	c6 05 74 12 21 f0 00 	movb   $0x0,0xf0211274
f010388d:	c6 05 75 12 21 f0 8e 	movb   $0x8e,0xf0211275
f0103894:	c1 e8 10             	shr    $0x10,%eax
f0103897:	66 a3 76 12 21 f0    	mov    %ax,0xf0211276
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f010389d:	b8 9a 43 10 f0       	mov    $0xf010439a,%eax
f01038a2:	66 a3 78 12 21 f0    	mov    %ax,0xf0211278
f01038a8:	66 c7 05 7a 12 21 f0 	movw   $0x8,0xf021127a
f01038af:	08 00 
f01038b1:	c6 05 7c 12 21 f0 00 	movb   $0x0,0xf021127c
f01038b8:	c6 05 7d 12 21 f0 ee 	movb   $0xee,0xf021127d
f01038bf:	c1 e8 10             	shr    $0x10,%eax
f01038c2:	66 a3 7e 12 21 f0    	mov    %ax,0xf021127e
	SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f01038c8:	b8 a4 43 10 f0       	mov    $0xf01043a4,%eax
f01038cd:	66 a3 80 12 21 f0    	mov    %ax,0xf0211280
f01038d3:	66 c7 05 82 12 21 f0 	movw   $0x8,0xf0211282
f01038da:	08 00 
f01038dc:	c6 05 84 12 21 f0 00 	movb   $0x0,0xf0211284
f01038e3:	c6 05 85 12 21 f0 8e 	movb   $0x8e,0xf0211285
f01038ea:	c1 e8 10             	shr    $0x10,%eax
f01038ed:	66 a3 86 12 21 f0    	mov    %ax,0xf0211286
	SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f01038f3:	b8 ae 43 10 f0       	mov    $0xf01043ae,%eax
f01038f8:	66 a3 88 12 21 f0    	mov    %ax,0xf0211288
f01038fe:	66 c7 05 8a 12 21 f0 	movw   $0x8,0xf021128a
f0103905:	08 00 
f0103907:	c6 05 8c 12 21 f0 00 	movb   $0x0,0xf021128c
f010390e:	c6 05 8d 12 21 f0 8e 	movb   $0x8e,0xf021128d
f0103915:	c1 e8 10             	shr    $0x10,%eax
f0103918:	66 a3 8e 12 21 f0    	mov    %ax,0xf021128e
	SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f010391e:	b8 b8 43 10 f0       	mov    $0xf01043b8,%eax
f0103923:	66 a3 90 12 21 f0    	mov    %ax,0xf0211290
f0103929:	66 c7 05 92 12 21 f0 	movw   $0x8,0xf0211292
f0103930:	08 00 
f0103932:	c6 05 94 12 21 f0 00 	movb   $0x0,0xf0211294
f0103939:	c6 05 95 12 21 f0 8e 	movb   $0x8e,0xf0211295
f0103940:	c1 e8 10             	shr    $0x10,%eax
f0103943:	66 a3 96 12 21 f0    	mov    %ax,0xf0211296
	SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f0103949:	b8 c2 43 10 f0       	mov    $0xf01043c2,%eax
f010394e:	66 a3 98 12 21 f0    	mov    %ax,0xf0211298
f0103954:	66 c7 05 9a 12 21 f0 	movw   $0x8,0xf021129a
f010395b:	08 00 
f010395d:	c6 05 9c 12 21 f0 00 	movb   $0x0,0xf021129c
f0103964:	c6 05 9d 12 21 f0 8e 	movb   $0x8e,0xf021129d
f010396b:	c1 e8 10             	shr    $0x10,%eax
f010396e:	66 a3 9e 12 21 f0    	mov    %ax,0xf021129e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f0103974:	b8 cc 43 10 f0       	mov    $0xf01043cc,%eax
f0103979:	66 a3 a0 12 21 f0    	mov    %ax,0xf02112a0
f010397f:	66 c7 05 a2 12 21 f0 	movw   $0x8,0xf02112a2
f0103986:	08 00 
f0103988:	c6 05 a4 12 21 f0 00 	movb   $0x0,0xf02112a4
f010398f:	c6 05 a5 12 21 f0 8e 	movb   $0x8e,0xf02112a5
f0103996:	c1 e8 10             	shr    $0x10,%eax
f0103999:	66 a3 a6 12 21 f0    	mov    %ax,0xf02112a6
	SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f010399f:	b8 d4 43 10 f0       	mov    $0xf01043d4,%eax
f01039a4:	66 a3 b0 12 21 f0    	mov    %ax,0xf02112b0
f01039aa:	66 c7 05 b2 12 21 f0 	movw   $0x8,0xf02112b2
f01039b1:	08 00 
f01039b3:	c6 05 b4 12 21 f0 00 	movb   $0x0,0xf02112b4
f01039ba:	c6 05 b5 12 21 f0 8e 	movb   $0x8e,0xf02112b5
f01039c1:	c1 e8 10             	shr    $0x10,%eax
f01039c4:	66 a3 b6 12 21 f0    	mov    %ax,0xf02112b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f01039ca:	b8 dc 43 10 f0       	mov    $0xf01043dc,%eax
f01039cf:	66 a3 b8 12 21 f0    	mov    %ax,0xf02112b8
f01039d5:	66 c7 05 ba 12 21 f0 	movw   $0x8,0xf02112ba
f01039dc:	08 00 
f01039de:	c6 05 bc 12 21 f0 00 	movb   $0x0,0xf02112bc
f01039e5:	c6 05 bd 12 21 f0 8e 	movb   $0x8e,0xf02112bd
f01039ec:	c1 e8 10             	shr    $0x10,%eax
f01039ef:	66 a3 be 12 21 f0    	mov    %ax,0xf02112be
	SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f01039f5:	b8 e4 43 10 f0       	mov    $0xf01043e4,%eax
f01039fa:	66 a3 c0 12 21 f0    	mov    %ax,0xf02112c0
f0103a00:	66 c7 05 c2 12 21 f0 	movw   $0x8,0xf02112c2
f0103a07:	08 00 
f0103a09:	c6 05 c4 12 21 f0 00 	movb   $0x0,0xf02112c4
f0103a10:	c6 05 c5 12 21 f0 8e 	movb   $0x8e,0xf02112c5
f0103a17:	c1 e8 10             	shr    $0x10,%eax
f0103a1a:	66 a3 c6 12 21 f0    	mov    %ax,0xf02112c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f0103a20:	b8 ec 43 10 f0       	mov    $0xf01043ec,%eax
f0103a25:	66 a3 c8 12 21 f0    	mov    %ax,0xf02112c8
f0103a2b:	66 c7 05 ca 12 21 f0 	movw   $0x8,0xf02112ca
f0103a32:	08 00 
f0103a34:	c6 05 cc 12 21 f0 00 	movb   $0x0,0xf02112cc
f0103a3b:	c6 05 cd 12 21 f0 8e 	movb   $0x8e,0xf02112cd
f0103a42:	c1 e8 10             	shr    $0x10,%eax
f0103a45:	66 a3 ce 12 21 f0    	mov    %ax,0xf02112ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f0103a4b:	b8 f4 43 10 f0       	mov    $0xf01043f4,%eax
f0103a50:	66 a3 d0 12 21 f0    	mov    %ax,0xf02112d0
f0103a56:	66 c7 05 d2 12 21 f0 	movw   $0x8,0xf02112d2
f0103a5d:	08 00 
f0103a5f:	c6 05 d4 12 21 f0 00 	movb   $0x0,0xf02112d4
f0103a66:	c6 05 d5 12 21 f0 8e 	movb   $0x8e,0xf02112d5
f0103a6d:	c1 e8 10             	shr    $0x10,%eax
f0103a70:	66 a3 d6 12 21 f0    	mov    %ax,0xf02112d6
	SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f0103a76:	b8 f8 43 10 f0       	mov    $0xf01043f8,%eax
f0103a7b:	66 a3 e0 12 21 f0    	mov    %ax,0xf02112e0
f0103a81:	66 c7 05 e2 12 21 f0 	movw   $0x8,0xf02112e2
f0103a88:	08 00 
f0103a8a:	c6 05 e4 12 21 f0 00 	movb   $0x0,0xf02112e4
f0103a91:	c6 05 e5 12 21 f0 8e 	movb   $0x8e,0xf02112e5
f0103a98:	c1 e8 10             	shr    $0x10,%eax
f0103a9b:	66 a3 e6 12 21 f0    	mov    %ax,0xf02112e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f0103aa1:	b8 fe 43 10 f0       	mov    $0xf01043fe,%eax
f0103aa6:	66 a3 e8 12 21 f0    	mov    %ax,0xf02112e8
f0103aac:	66 c7 05 ea 12 21 f0 	movw   $0x8,0xf02112ea
f0103ab3:	08 00 
f0103ab5:	c6 05 ec 12 21 f0 00 	movb   $0x0,0xf02112ec
f0103abc:	c6 05 ed 12 21 f0 8e 	movb   $0x8e,0xf02112ed
f0103ac3:	c1 e8 10             	shr    $0x10,%eax
f0103ac6:	66 a3 ee 12 21 f0    	mov    %ax,0xf02112ee
	SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0103acc:	b8 02 44 10 f0       	mov    $0xf0104402,%eax
f0103ad1:	66 a3 f0 12 21 f0    	mov    %ax,0xf02112f0
f0103ad7:	66 c7 05 f2 12 21 f0 	movw   $0x8,0xf02112f2
f0103ade:	08 00 
f0103ae0:	c6 05 f4 12 21 f0 00 	movb   $0x0,0xf02112f4
f0103ae7:	c6 05 f5 12 21 f0 8e 	movb   $0x8e,0xf02112f5
f0103aee:	c1 e8 10             	shr    $0x10,%eax
f0103af1:	66 a3 f6 12 21 f0    	mov    %ax,0xf02112f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f0103af7:	b8 08 44 10 f0       	mov    $0xf0104408,%eax
f0103afc:	66 a3 f8 12 21 f0    	mov    %ax,0xf02112f8
f0103b02:	66 c7 05 fa 12 21 f0 	movw   $0x8,0xf02112fa
f0103b09:	08 00 
f0103b0b:	c6 05 fc 12 21 f0 00 	movb   $0x0,0xf02112fc
f0103b12:	c6 05 fd 12 21 f0 8e 	movb   $0x8e,0xf02112fd
f0103b19:	c1 e8 10             	shr    $0x10,%eax
f0103b1c:	66 a3 fe 12 21 f0    	mov    %ax,0xf02112fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f0103b22:	b8 0e 44 10 f0       	mov    $0xf010440e,%eax
f0103b27:	66 a3 e0 13 21 f0    	mov    %ax,0xf02113e0
f0103b2d:	66 c7 05 e2 13 21 f0 	movw   $0x8,0xf02113e2
f0103b34:	08 00 
f0103b36:	c6 05 e4 13 21 f0 00 	movb   $0x0,0xf02113e4
f0103b3d:	c6 05 e5 13 21 f0 ee 	movb   $0xee,0xf02113e5
f0103b44:	c1 e8 10             	shr    $0x10,%eax
f0103b47:	66 a3 e6 13 21 f0    	mov    %ax,0xf02113e6

	SETGATE(idt[IRQ_OFFSET], 0, GD_KT, IRQ0, 0);
f0103b4d:	b8 14 44 10 f0       	mov    $0xf0104414,%eax
f0103b52:	66 a3 60 13 21 f0    	mov    %ax,0xf0211360
f0103b58:	66 c7 05 62 13 21 f0 	movw   $0x8,0xf0211362
f0103b5f:	08 00 
f0103b61:	c6 05 64 13 21 f0 00 	movb   $0x0,0xf0211364
f0103b68:	c6 05 65 13 21 f0 8e 	movb   $0x8e,0xf0211365
f0103b6f:	c1 e8 10             	shr    $0x10,%eax
f0103b72:	66 a3 66 13 21 f0    	mov    %ax,0xf0211366
	SETGATE(idt[IRQ_OFFSET+1], 0, GD_KT, IRQ1, 0);
f0103b78:	b8 1a 44 10 f0       	mov    $0xf010441a,%eax
f0103b7d:	66 a3 68 13 21 f0    	mov    %ax,0xf0211368
f0103b83:	66 c7 05 6a 13 21 f0 	movw   $0x8,0xf021136a
f0103b8a:	08 00 
f0103b8c:	c6 05 6c 13 21 f0 00 	movb   $0x0,0xf021136c
f0103b93:	c6 05 6d 13 21 f0 8e 	movb   $0x8e,0xf021136d
f0103b9a:	c1 e8 10             	shr    $0x10,%eax
f0103b9d:	66 a3 6e 13 21 f0    	mov    %ax,0xf021136e
	SETGATE(idt[IRQ_OFFSET+2], 0, GD_KT, IRQ2, 0);
f0103ba3:	b8 20 44 10 f0       	mov    $0xf0104420,%eax
f0103ba8:	66 a3 70 13 21 f0    	mov    %ax,0xf0211370
f0103bae:	66 c7 05 72 13 21 f0 	movw   $0x8,0xf0211372
f0103bb5:	08 00 
f0103bb7:	c6 05 74 13 21 f0 00 	movb   $0x0,0xf0211374
f0103bbe:	c6 05 75 13 21 f0 8e 	movb   $0x8e,0xf0211375
f0103bc5:	c1 e8 10             	shr    $0x10,%eax
f0103bc8:	66 a3 76 13 21 f0    	mov    %ax,0xf0211376
	SETGATE(idt[IRQ_OFFSET+3], 0, GD_KT, IRQ3, 0);
f0103bce:	b8 26 44 10 f0       	mov    $0xf0104426,%eax
f0103bd3:	66 a3 78 13 21 f0    	mov    %ax,0xf0211378
f0103bd9:	66 c7 05 7a 13 21 f0 	movw   $0x8,0xf021137a
f0103be0:	08 00 
f0103be2:	c6 05 7c 13 21 f0 00 	movb   $0x0,0xf021137c
f0103be9:	c6 05 7d 13 21 f0 8e 	movb   $0x8e,0xf021137d
f0103bf0:	c1 e8 10             	shr    $0x10,%eax
f0103bf3:	66 a3 7e 13 21 f0    	mov    %ax,0xf021137e
	SETGATE(idt[IRQ_OFFSET+4], 0, GD_KT, IRQ4, 0);
f0103bf9:	b8 2c 44 10 f0       	mov    $0xf010442c,%eax
f0103bfe:	66 a3 80 13 21 f0    	mov    %ax,0xf0211380
f0103c04:	66 c7 05 82 13 21 f0 	movw   $0x8,0xf0211382
f0103c0b:	08 00 
f0103c0d:	c6 05 84 13 21 f0 00 	movb   $0x0,0xf0211384
f0103c14:	c6 05 85 13 21 f0 8e 	movb   $0x8e,0xf0211385
f0103c1b:	c1 e8 10             	shr    $0x10,%eax
f0103c1e:	66 a3 86 13 21 f0    	mov    %ax,0xf0211386
	SETGATE(idt[IRQ_OFFSET+5], 0, GD_KT, IRQ5, 0);
f0103c24:	b8 32 44 10 f0       	mov    $0xf0104432,%eax
f0103c29:	66 a3 88 13 21 f0    	mov    %ax,0xf0211388
f0103c2f:	66 c7 05 8a 13 21 f0 	movw   $0x8,0xf021138a
f0103c36:	08 00 
f0103c38:	c6 05 8c 13 21 f0 00 	movb   $0x0,0xf021138c
f0103c3f:	c6 05 8d 13 21 f0 8e 	movb   $0x8e,0xf021138d
f0103c46:	c1 e8 10             	shr    $0x10,%eax
f0103c49:	66 a3 8e 13 21 f0    	mov    %ax,0xf021138e
	SETGATE(idt[IRQ_OFFSET+6], 0, GD_KT, IRQ6, 0);
f0103c4f:	b8 38 44 10 f0       	mov    $0xf0104438,%eax
f0103c54:	66 a3 90 13 21 f0    	mov    %ax,0xf0211390
f0103c5a:	66 c7 05 92 13 21 f0 	movw   $0x8,0xf0211392
f0103c61:	08 00 
f0103c63:	c6 05 94 13 21 f0 00 	movb   $0x0,0xf0211394
f0103c6a:	c6 05 95 13 21 f0 8e 	movb   $0x8e,0xf0211395
f0103c71:	c1 e8 10             	shr    $0x10,%eax
f0103c74:	66 a3 96 13 21 f0    	mov    %ax,0xf0211396
	SETGATE(idt[IRQ_OFFSET+7], 0, GD_KT, IRQ7, 0);
f0103c7a:	b8 3e 44 10 f0       	mov    $0xf010443e,%eax
f0103c7f:	66 a3 98 13 21 f0    	mov    %ax,0xf0211398
f0103c85:	66 c7 05 9a 13 21 f0 	movw   $0x8,0xf021139a
f0103c8c:	08 00 
f0103c8e:	c6 05 9c 13 21 f0 00 	movb   $0x0,0xf021139c
f0103c95:	c6 05 9d 13 21 f0 8e 	movb   $0x8e,0xf021139d
f0103c9c:	c1 e8 10             	shr    $0x10,%eax
f0103c9f:	66 a3 9e 13 21 f0    	mov    %ax,0xf021139e
	SETGATE(idt[IRQ_OFFSET+8], 0, GD_KT, IRQ8, 0);
f0103ca5:	b8 44 44 10 f0       	mov    $0xf0104444,%eax
f0103caa:	66 a3 a0 13 21 f0    	mov    %ax,0xf02113a0
f0103cb0:	66 c7 05 a2 13 21 f0 	movw   $0x8,0xf02113a2
f0103cb7:	08 00 
f0103cb9:	c6 05 a4 13 21 f0 00 	movb   $0x0,0xf02113a4
f0103cc0:	c6 05 a5 13 21 f0 8e 	movb   $0x8e,0xf02113a5
f0103cc7:	c1 e8 10             	shr    $0x10,%eax
f0103cca:	66 a3 a6 13 21 f0    	mov    %ax,0xf02113a6
	SETGATE(idt[IRQ_OFFSET+9], 0, GD_KT, IRQ9, 0);
f0103cd0:	b8 4a 44 10 f0       	mov    $0xf010444a,%eax
f0103cd5:	66 a3 a8 13 21 f0    	mov    %ax,0xf02113a8
f0103cdb:	66 c7 05 aa 13 21 f0 	movw   $0x8,0xf02113aa
f0103ce2:	08 00 
f0103ce4:	c6 05 ac 13 21 f0 00 	movb   $0x0,0xf02113ac
f0103ceb:	c6 05 ad 13 21 f0 8e 	movb   $0x8e,0xf02113ad
f0103cf2:	c1 e8 10             	shr    $0x10,%eax
f0103cf5:	66 a3 ae 13 21 f0    	mov    %ax,0xf02113ae
	SETGATE(idt[IRQ_OFFSET+10], 0, GD_KT, IRQ10, 0);
f0103cfb:	b8 50 44 10 f0       	mov    $0xf0104450,%eax
f0103d00:	66 a3 b0 13 21 f0    	mov    %ax,0xf02113b0
f0103d06:	66 c7 05 b2 13 21 f0 	movw   $0x8,0xf02113b2
f0103d0d:	08 00 
f0103d0f:	c6 05 b4 13 21 f0 00 	movb   $0x0,0xf02113b4
f0103d16:	c6 05 b5 13 21 f0 8e 	movb   $0x8e,0xf02113b5
f0103d1d:	c1 e8 10             	shr    $0x10,%eax
f0103d20:	66 a3 b6 13 21 f0    	mov    %ax,0xf02113b6
	SETGATE(idt[IRQ_OFFSET+11], 0, GD_KT, IRQ11, 0);
f0103d26:	b8 56 44 10 f0       	mov    $0xf0104456,%eax
f0103d2b:	66 a3 b8 13 21 f0    	mov    %ax,0xf02113b8
f0103d31:	66 c7 05 ba 13 21 f0 	movw   $0x8,0xf02113ba
f0103d38:	08 00 
f0103d3a:	c6 05 bc 13 21 f0 00 	movb   $0x0,0xf02113bc
f0103d41:	c6 05 bd 13 21 f0 8e 	movb   $0x8e,0xf02113bd
f0103d48:	c1 e8 10             	shr    $0x10,%eax
f0103d4b:	66 a3 be 13 21 f0    	mov    %ax,0xf02113be
	SETGATE(idt[IRQ_OFFSET+12], 0, GD_KT, IRQ12, 0);
f0103d51:	b8 5c 44 10 f0       	mov    $0xf010445c,%eax
f0103d56:	66 a3 c0 13 21 f0    	mov    %ax,0xf02113c0
f0103d5c:	66 c7 05 c2 13 21 f0 	movw   $0x8,0xf02113c2
f0103d63:	08 00 
f0103d65:	c6 05 c4 13 21 f0 00 	movb   $0x0,0xf02113c4
f0103d6c:	c6 05 c5 13 21 f0 8e 	movb   $0x8e,0xf02113c5
f0103d73:	c1 e8 10             	shr    $0x10,%eax
f0103d76:	66 a3 c6 13 21 f0    	mov    %ax,0xf02113c6
	SETGATE(idt[IRQ_OFFSET+13], 0, GD_KT, IRQ13, 0);
f0103d7c:	b8 62 44 10 f0       	mov    $0xf0104462,%eax
f0103d81:	66 a3 c8 13 21 f0    	mov    %ax,0xf02113c8
f0103d87:	66 c7 05 ca 13 21 f0 	movw   $0x8,0xf02113ca
f0103d8e:	08 00 
f0103d90:	c6 05 cc 13 21 f0 00 	movb   $0x0,0xf02113cc
f0103d97:	c6 05 cd 13 21 f0 8e 	movb   $0x8e,0xf02113cd
f0103d9e:	c1 e8 10             	shr    $0x10,%eax
f0103da1:	66 a3 ce 13 21 f0    	mov    %ax,0xf02113ce
	SETGATE(idt[IRQ_OFFSET+14], 0, GD_KT, IRQ14, 0);
f0103da7:	b8 68 44 10 f0       	mov    $0xf0104468,%eax
f0103dac:	66 a3 d0 13 21 f0    	mov    %ax,0xf02113d0
f0103db2:	66 c7 05 d2 13 21 f0 	movw   $0x8,0xf02113d2
f0103db9:	08 00 
f0103dbb:	c6 05 d4 13 21 f0 00 	movb   $0x0,0xf02113d4
f0103dc2:	c6 05 d5 13 21 f0 8e 	movb   $0x8e,0xf02113d5
f0103dc9:	c1 e8 10             	shr    $0x10,%eax
f0103dcc:	66 a3 d6 13 21 f0    	mov    %ax,0xf02113d6
	SETGATE(idt[IRQ_OFFSET+15], 0, GD_KT, IRQ15, 0);
f0103dd2:	b8 6e 44 10 f0       	mov    $0xf010446e,%eax
f0103dd7:	66 a3 d8 13 21 f0    	mov    %ax,0xf02113d8
f0103ddd:	66 c7 05 da 13 21 f0 	movw   $0x8,0xf02113da
f0103de4:	08 00 
f0103de6:	c6 05 dc 13 21 f0 00 	movb   $0x0,0xf02113dc
f0103ded:	c6 05 dd 13 21 f0 8e 	movb   $0x8e,0xf02113dd
f0103df4:	c1 e8 10             	shr    $0x10,%eax
f0103df7:	66 a3 de 13 21 f0    	mov    %ax,0xf02113de
	// Per-CPU setup 
	trap_init_percpu();
f0103dfd:	e8 44 f9 ff ff       	call   f0103746 <trap_init_percpu>
}
f0103e02:	c9                   	leave  
f0103e03:	c3                   	ret    

f0103e04 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103e04:	55                   	push   %ebp
f0103e05:	89 e5                	mov    %esp,%ebp
f0103e07:	53                   	push   %ebx
f0103e08:	83 ec 0c             	sub    $0xc,%esp
f0103e0b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103e0e:	ff 33                	pushl  (%ebx)
f0103e10:	68 c8 77 10 f0       	push   $0xf01077c8
f0103e15:	e8 18 f9 ff ff       	call   f0103732 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103e1a:	83 c4 08             	add    $0x8,%esp
f0103e1d:	ff 73 04             	pushl  0x4(%ebx)
f0103e20:	68 d7 77 10 f0       	push   $0xf01077d7
f0103e25:	e8 08 f9 ff ff       	call   f0103732 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103e2a:	83 c4 08             	add    $0x8,%esp
f0103e2d:	ff 73 08             	pushl  0x8(%ebx)
f0103e30:	68 e6 77 10 f0       	push   $0xf01077e6
f0103e35:	e8 f8 f8 ff ff       	call   f0103732 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103e3a:	83 c4 08             	add    $0x8,%esp
f0103e3d:	ff 73 0c             	pushl  0xc(%ebx)
f0103e40:	68 f5 77 10 f0       	push   $0xf01077f5
f0103e45:	e8 e8 f8 ff ff       	call   f0103732 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103e4a:	83 c4 08             	add    $0x8,%esp
f0103e4d:	ff 73 10             	pushl  0x10(%ebx)
f0103e50:	68 04 78 10 f0       	push   $0xf0107804
f0103e55:	e8 d8 f8 ff ff       	call   f0103732 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103e5a:	83 c4 08             	add    $0x8,%esp
f0103e5d:	ff 73 14             	pushl  0x14(%ebx)
f0103e60:	68 13 78 10 f0       	push   $0xf0107813
f0103e65:	e8 c8 f8 ff ff       	call   f0103732 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103e6a:	83 c4 08             	add    $0x8,%esp
f0103e6d:	ff 73 18             	pushl  0x18(%ebx)
f0103e70:	68 22 78 10 f0       	push   $0xf0107822
f0103e75:	e8 b8 f8 ff ff       	call   f0103732 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103e7a:	83 c4 08             	add    $0x8,%esp
f0103e7d:	ff 73 1c             	pushl  0x1c(%ebx)
f0103e80:	68 31 78 10 f0       	push   $0xf0107831
f0103e85:	e8 a8 f8 ff ff       	call   f0103732 <cprintf>
}
f0103e8a:	83 c4 10             	add    $0x10,%esp
f0103e8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103e90:	c9                   	leave  
f0103e91:	c3                   	ret    

f0103e92 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103e92:	55                   	push   %ebp
f0103e93:	89 e5                	mov    %esp,%ebp
f0103e95:	56                   	push   %esi
f0103e96:	53                   	push   %ebx
f0103e97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103e9a:	e8 e3 1e 00 00       	call   f0105d82 <cpunum>
f0103e9f:	83 ec 04             	sub    $0x4,%esp
f0103ea2:	50                   	push   %eax
f0103ea3:	53                   	push   %ebx
f0103ea4:	68 95 78 10 f0       	push   $0xf0107895
f0103ea9:	e8 84 f8 ff ff       	call   f0103732 <cprintf>
	print_regs(&tf->tf_regs);
f0103eae:	89 1c 24             	mov    %ebx,(%esp)
f0103eb1:	e8 4e ff ff ff       	call   f0103e04 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103eb6:	83 c4 08             	add    $0x8,%esp
f0103eb9:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103ebd:	50                   	push   %eax
f0103ebe:	68 b3 78 10 f0       	push   $0xf01078b3
f0103ec3:	e8 6a f8 ff ff       	call   f0103732 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103ec8:	83 c4 08             	add    $0x8,%esp
f0103ecb:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103ecf:	50                   	push   %eax
f0103ed0:	68 c6 78 10 f0       	push   $0xf01078c6
f0103ed5:	e8 58 f8 ff ff       	call   f0103732 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103eda:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103edd:	83 c4 10             	add    $0x10,%esp
f0103ee0:	83 f8 13             	cmp    $0x13,%eax
f0103ee3:	77 09                	ja     f0103eee <print_trapframe+0x5c>
		return excnames[trapno];
f0103ee5:	8b 14 85 40 7b 10 f0 	mov    -0xfef84c0(,%eax,4),%edx
f0103eec:	eb 1f                	jmp    f0103f0d <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103eee:	83 f8 30             	cmp    $0x30,%eax
f0103ef1:	74 15                	je     f0103f08 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103ef3:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103ef6:	83 fa 10             	cmp    $0x10,%edx
f0103ef9:	b9 5f 78 10 f0       	mov    $0xf010785f,%ecx
f0103efe:	ba 4c 78 10 f0       	mov    $0xf010784c,%edx
f0103f03:	0f 43 d1             	cmovae %ecx,%edx
f0103f06:	eb 05                	jmp    f0103f0d <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103f08:	ba 40 78 10 f0       	mov    $0xf0107840,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f0d:	83 ec 04             	sub    $0x4,%esp
f0103f10:	52                   	push   %edx
f0103f11:	50                   	push   %eax
f0103f12:	68 d9 78 10 f0       	push   $0xf01078d9
f0103f17:	e8 16 f8 ff ff       	call   f0103732 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103f1c:	83 c4 10             	add    $0x10,%esp
f0103f1f:	3b 1d 60 1a 21 f0    	cmp    0xf0211a60,%ebx
f0103f25:	75 1a                	jne    f0103f41 <print_trapframe+0xaf>
f0103f27:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f2b:	75 14                	jne    f0103f41 <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103f2d:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103f30:	83 ec 08             	sub    $0x8,%esp
f0103f33:	50                   	push   %eax
f0103f34:	68 eb 78 10 f0       	push   $0xf01078eb
f0103f39:	e8 f4 f7 ff ff       	call   f0103732 <cprintf>
f0103f3e:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103f41:	83 ec 08             	sub    $0x8,%esp
f0103f44:	ff 73 2c             	pushl  0x2c(%ebx)
f0103f47:	68 fa 78 10 f0       	push   $0xf01078fa
f0103f4c:	e8 e1 f7 ff ff       	call   f0103732 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103f51:	83 c4 10             	add    $0x10,%esp
f0103f54:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f58:	75 49                	jne    f0103fa3 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103f5a:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103f5d:	89 c2                	mov    %eax,%edx
f0103f5f:	83 e2 01             	and    $0x1,%edx
f0103f62:	ba 79 78 10 f0       	mov    $0xf0107879,%edx
f0103f67:	b9 6e 78 10 f0       	mov    $0xf010786e,%ecx
f0103f6c:	0f 44 ca             	cmove  %edx,%ecx
f0103f6f:	89 c2                	mov    %eax,%edx
f0103f71:	83 e2 02             	and    $0x2,%edx
f0103f74:	ba 8b 78 10 f0       	mov    $0xf010788b,%edx
f0103f79:	be 85 78 10 f0       	mov    $0xf0107885,%esi
f0103f7e:	0f 45 d6             	cmovne %esi,%edx
f0103f81:	83 e0 04             	and    $0x4,%eax
f0103f84:	be c5 79 10 f0       	mov    $0xf01079c5,%esi
f0103f89:	b8 90 78 10 f0       	mov    $0xf0107890,%eax
f0103f8e:	0f 44 c6             	cmove  %esi,%eax
f0103f91:	51                   	push   %ecx
f0103f92:	52                   	push   %edx
f0103f93:	50                   	push   %eax
f0103f94:	68 08 79 10 f0       	push   $0xf0107908
f0103f99:	e8 94 f7 ff ff       	call   f0103732 <cprintf>
f0103f9e:	83 c4 10             	add    $0x10,%esp
f0103fa1:	eb 10                	jmp    f0103fb3 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103fa3:	83 ec 0c             	sub    $0xc,%esp
f0103fa6:	68 52 6c 10 f0       	push   $0xf0106c52
f0103fab:	e8 82 f7 ff ff       	call   f0103732 <cprintf>
f0103fb0:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103fb3:	83 ec 08             	sub    $0x8,%esp
f0103fb6:	ff 73 30             	pushl  0x30(%ebx)
f0103fb9:	68 17 79 10 f0       	push   $0xf0107917
f0103fbe:	e8 6f f7 ff ff       	call   f0103732 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103fc3:	83 c4 08             	add    $0x8,%esp
f0103fc6:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103fca:	50                   	push   %eax
f0103fcb:	68 26 79 10 f0       	push   $0xf0107926
f0103fd0:	e8 5d f7 ff ff       	call   f0103732 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103fd5:	83 c4 08             	add    $0x8,%esp
f0103fd8:	ff 73 38             	pushl  0x38(%ebx)
f0103fdb:	68 39 79 10 f0       	push   $0xf0107939
f0103fe0:	e8 4d f7 ff ff       	call   f0103732 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103fe5:	83 c4 10             	add    $0x10,%esp
f0103fe8:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103fec:	74 25                	je     f0104013 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103fee:	83 ec 08             	sub    $0x8,%esp
f0103ff1:	ff 73 3c             	pushl  0x3c(%ebx)
f0103ff4:	68 48 79 10 f0       	push   $0xf0107948
f0103ff9:	e8 34 f7 ff ff       	call   f0103732 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103ffe:	83 c4 08             	add    $0x8,%esp
f0104001:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104005:	50                   	push   %eax
f0104006:	68 57 79 10 f0       	push   $0xf0107957
f010400b:	e8 22 f7 ff ff       	call   f0103732 <cprintf>
f0104010:	83 c4 10             	add    $0x10,%esp
	}
}
f0104013:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104016:	5b                   	pop    %ebx
f0104017:	5e                   	pop    %esi
f0104018:	5d                   	pop    %ebp
f0104019:	c3                   	ret    

f010401a <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010401a:	55                   	push   %ebp
f010401b:	89 e5                	mov    %esp,%ebp
f010401d:	57                   	push   %edi
f010401e:	56                   	push   %esi
f010401f:	53                   	push   %ebx
f0104020:	83 ec 0c             	sub    $0xc,%esp
f0104023:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104026:	0f 20 d6             	mov    %cr2,%esi
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	   struct UTrapframe *utf;
	
	if (curenv->env_pgfault_upcall) {
f0104029:	e8 54 1d 00 00       	call   f0105d82 <cpunum>
f010402e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104031:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104037:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010403b:	0f 84 a7 00 00 00    	je     f01040e8 <page_fault_handler+0xce>
		
		if (tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP) {
f0104041:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104044:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			// 异常模式下陷入
			utf = (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
f010404a:	83 e8 38             	sub    $0x38,%eax
f010404d:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104053:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f0104058:	0f 46 d0             	cmovbe %eax,%edx
f010405b:	89 d7                	mov    %edx,%edi
		else {
			// 非异常模式下陷入
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));	
		}
		// 检查异常栈是否溢出
		user_mem_assert(curenv, (const void *) utf, sizeof(struct UTrapframe), PTE_P|PTE_W);
f010405d:	e8 20 1d 00 00       	call   f0105d82 <cpunum>
f0104062:	6a 03                	push   $0x3
f0104064:	6a 34                	push   $0x34
f0104066:	57                   	push   %edi
f0104067:	6b c0 74             	imul   $0x74,%eax,%eax
f010406a:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104070:	e8 ae ed ff ff       	call   f0102e23 <user_mem_assert>
			
		utf->utf_fault_va = fault_va;
f0104075:	89 fa                	mov    %edi,%edx
f0104077:	89 37                	mov    %esi,(%edi)
		utf->utf_err      = tf->tf_trapno;
f0104079:	8b 43 28             	mov    0x28(%ebx),%eax
f010407c:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs     = tf->tf_regs;
f010407f:	8d 7f 08             	lea    0x8(%edi),%edi
f0104082:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104087:	89 de                	mov    %ebx,%esi
f0104089:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eflags   = tf->tf_eflags;
f010408b:	8b 43 38             	mov    0x38(%ebx),%eax
f010408e:	89 42 2c             	mov    %eax,0x2c(%edx)
		// 保存陷入时现场，用于返回
		utf->utf_eip      = tf->tf_eip;
f0104091:	8b 43 30             	mov    0x30(%ebx),%eax
f0104094:	89 d7                	mov    %edx,%edi
f0104096:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_esp      = tf->tf_esp;
f0104099:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010409c:	89 42 30             	mov    %eax,0x30(%edx)
		// 再次转向执行
		curenv->env_tf.tf_eip        = (uint32_t) curenv->env_pgfault_upcall;
f010409f:	e8 de 1c 00 00       	call   f0105d82 <cpunum>
f01040a4:	6b c0 74             	imul   $0x74,%eax,%eax
f01040a7:	8b 98 28 20 21 f0    	mov    -0xfdedfd8(%eax),%ebx
f01040ad:	e8 d0 1c 00 00       	call   f0105d82 <cpunum>
f01040b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01040b5:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01040bb:	8b 40 64             	mov    0x64(%eax),%eax
f01040be:	89 43 30             	mov    %eax,0x30(%ebx)
		// 异常栈
		curenv->env_tf.tf_esp        = (uint32_t) utf;
f01040c1:	e8 bc 1c 00 00       	call   f0105d82 <cpunum>
f01040c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01040c9:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01040cf:	89 78 3c             	mov    %edi,0x3c(%eax)
		env_run(curenv);
f01040d2:	e8 ab 1c 00 00       	call   f0105d82 <cpunum>
f01040d7:	83 c4 04             	add    $0x4,%esp
f01040da:	6b c0 74             	imul   $0x74,%eax,%eax
f01040dd:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f01040e3:	e8 14 f4 ff ff       	call   f01034fc <env_run>
	}
	else {
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01040e8:	8b 7b 30             	mov    0x30(%ebx),%edi
			curenv->env_id, fault_va, tf->tf_eip);
f01040eb:	e8 92 1c 00 00       	call   f0105d82 <cpunum>
		curenv->env_tf.tf_esp        = (uint32_t) utf;
		env_run(curenv);
	}
	else {
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01040f0:	57                   	push   %edi
f01040f1:	56                   	push   %esi
			curenv->env_id, fault_va, tf->tf_eip);
f01040f2:	6b c0 74             	imul   $0x74,%eax,%eax
		curenv->env_tf.tf_esp        = (uint32_t) utf;
		env_run(curenv);
	}
	else {
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01040f5:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01040fb:	ff 70 48             	pushl  0x48(%eax)
f01040fe:	68 10 7b 10 f0       	push   $0xf0107b10
f0104103:	e8 2a f6 ff ff       	call   f0103732 <cprintf>
			curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
f0104108:	89 1c 24             	mov    %ebx,(%esp)
f010410b:	e8 82 fd ff ff       	call   f0103e92 <print_trapframe>
		env_destroy(curenv);
f0104110:	e8 6d 1c 00 00       	call   f0105d82 <cpunum>
f0104115:	83 c4 04             	add    $0x4,%esp
f0104118:	6b c0 74             	imul   $0x74,%eax,%eax
f010411b:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104121:	e8 37 f3 ff ff       	call   f010345d <env_destroy>
	}

}
f0104126:	83 c4 10             	add    $0x10,%esp
f0104129:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010412c:	5b                   	pop    %ebx
f010412d:	5e                   	pop    %esi
f010412e:	5f                   	pop    %edi
f010412f:	5d                   	pop    %ebp
f0104130:	c3                   	ret    

f0104131 <trap>:
    }
}

void
trap(struct Trapframe *tf)
{
f0104131:	55                   	push   %ebp
f0104132:	89 e5                	mov    %esp,%ebp
f0104134:	57                   	push   %edi
f0104135:	56                   	push   %esi
f0104136:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104139:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f010413a:	83 3d 80 1e 21 f0 00 	cmpl   $0x0,0xf0211e80
f0104141:	74 01                	je     f0104144 <trap+0x13>
		asm volatile("hlt");
f0104143:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104144:	e8 39 1c 00 00       	call   f0105d82 <cpunum>
f0104149:	6b d0 74             	imul   $0x74,%eax,%edx
f010414c:	81 c2 20 20 21 f0    	add    $0xf0212020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104152:	b8 01 00 00 00       	mov    $0x1,%eax
f0104157:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010415b:	83 f8 02             	cmp    $0x2,%eax
f010415e:	75 10                	jne    f0104170 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104160:	83 ec 0c             	sub    $0xc,%esp
f0104163:	68 c0 03 12 f0       	push   $0xf01203c0
f0104168:	e8 83 1e 00 00       	call   f0105ff0 <spin_lock>
f010416d:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104170:	9c                   	pushf  
f0104171:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104172:	f6 c4 02             	test   $0x2,%ah
f0104175:	74 19                	je     f0104190 <trap+0x5f>
f0104177:	68 6a 79 10 f0       	push   $0xf010796a
f010417c:	68 72 69 10 f0       	push   $0xf0106972
f0104181:	68 55 01 00 00       	push   $0x155
f0104186:	68 83 79 10 f0       	push   $0xf0107983
f010418b:	e8 b0 be ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104190:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104194:	83 e0 03             	and    $0x3,%eax
f0104197:	66 83 f8 03          	cmp    $0x3,%ax
f010419b:	0f 85 a0 00 00 00    	jne    f0104241 <trap+0x110>
f01041a1:	83 ec 0c             	sub    $0xc,%esp
f01041a4:	68 c0 03 12 f0       	push   $0xf01203c0
f01041a9:	e8 42 1e 00 00       	call   f0105ff0 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f01041ae:	e8 cf 1b 00 00       	call   f0105d82 <cpunum>
f01041b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01041b6:	83 c4 10             	add    $0x10,%esp
f01041b9:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f01041c0:	75 19                	jne    f01041db <trap+0xaa>
f01041c2:	68 8f 79 10 f0       	push   $0xf010798f
f01041c7:	68 72 69 10 f0       	push   $0xf0106972
f01041cc:	68 5d 01 00 00       	push   $0x15d
f01041d1:	68 83 79 10 f0       	push   $0xf0107983
f01041d6:	e8 65 be ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01041db:	e8 a2 1b 00 00       	call   f0105d82 <cpunum>
f01041e0:	6b c0 74             	imul   $0x74,%eax,%eax
f01041e3:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01041e9:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01041ed:	75 2d                	jne    f010421c <trap+0xeb>
			env_free(curenv);
f01041ef:	e8 8e 1b 00 00       	call   f0105d82 <cpunum>
f01041f4:	83 ec 0c             	sub    $0xc,%esp
f01041f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01041fa:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104200:	e8 b2 f0 ff ff       	call   f01032b7 <env_free>
			curenv = NULL;
f0104205:	e8 78 1b 00 00       	call   f0105d82 <cpunum>
f010420a:	6b c0 74             	imul   $0x74,%eax,%eax
f010420d:	c7 80 28 20 21 f0 00 	movl   $0x0,-0xfdedfd8(%eax)
f0104214:	00 00 00 
			sched_yield();
f0104217:	e8 3e 03 00 00       	call   f010455a <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010421c:	e8 61 1b 00 00       	call   f0105d82 <cpunum>
f0104221:	6b c0 74             	imul   $0x74,%eax,%eax
f0104224:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f010422a:	b9 11 00 00 00       	mov    $0x11,%ecx
f010422f:	89 c7                	mov    %eax,%edi
f0104231:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104233:	e8 4a 1b 00 00       	call   f0105d82 <cpunum>
f0104238:	6b c0 74             	imul   $0x74,%eax,%eax
f010423b:	8b b0 28 20 21 f0    	mov    -0xfdedfd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104241:	89 35 60 1a 21 f0    	mov    %esi,0xf0211a60
	// LAB 3: Your code here.

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104247:	8b 46 28             	mov    0x28(%esi),%eax
f010424a:	83 f8 27             	cmp    $0x27,%eax
f010424d:	75 1d                	jne    f010426c <trap+0x13b>
		cprintf("Spurious interrupt on irq 7\n");
f010424f:	83 ec 0c             	sub    $0xc,%esp
f0104252:	68 96 79 10 f0       	push   $0xf0107996
f0104257:	e8 d6 f4 ff ff       	call   f0103732 <cprintf>
		print_trapframe(tf);
f010425c:	89 34 24             	mov    %esi,(%esp)
f010425f:	e8 2e fc ff ff       	call   f0103e92 <print_trapframe>
f0104264:	83 c4 10             	add    $0x10,%esp
f0104267:	e9 cf 00 00 00       	jmp    f010433b <trap+0x20a>

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	switch(tf->tf_trapno) {
f010426c:	83 f8 20             	cmp    $0x20,%eax
f010426f:	74 65                	je     f01042d6 <trap+0x1a5>
f0104271:	83 f8 20             	cmp    $0x20,%eax
f0104274:	77 0c                	ja     f0104282 <trap+0x151>
f0104276:	83 f8 03             	cmp    $0x3,%eax
f0104279:	74 29                	je     f01042a4 <trap+0x173>
f010427b:	83 f8 0e             	cmp    $0xe,%eax
f010427e:	74 13                	je     f0104293 <trap+0x162>
f0104280:	eb 76                	jmp    f01042f8 <trap+0x1c7>
f0104282:	83 f8 24             	cmp    $0x24,%eax
f0104285:	74 65                	je     f01042ec <trap+0x1bb>
f0104287:	83 f8 30             	cmp    $0x30,%eax
f010428a:	74 29                	je     f01042b5 <trap+0x184>
f010428c:	83 f8 21             	cmp    $0x21,%eax
f010428f:	75 67                	jne    f01042f8 <trap+0x1c7>
f0104291:	eb 4d                	jmp    f01042e0 <trap+0x1af>
        case (T_PGFLT):
            page_fault_handler(tf);
f0104293:	83 ec 0c             	sub    $0xc,%esp
f0104296:	56                   	push   %esi
f0104297:	e8 7e fd ff ff       	call   f010401a <page_fault_handler>
f010429c:	83 c4 10             	add    $0x10,%esp
f010429f:	e9 97 00 00 00       	jmp    f010433b <trap+0x20a>
            break; 
        case (T_BRKPT):
            monitor(tf);        
f01042a4:	83 ec 0c             	sub    $0xc,%esp
f01042a7:	56                   	push   %esi
f01042a8:	e8 f2 c5 ff ff       	call   f010089f <monitor>
f01042ad:	83 c4 10             	add    $0x10,%esp
f01042b0:	e9 86 00 00 00       	jmp    f010433b <trap+0x20a>
            break;
        case (T_SYSCALL):{
			int32_t ret_code = syscall(
f01042b5:	83 ec 08             	sub    $0x8,%esp
f01042b8:	ff 76 04             	pushl  0x4(%esi)
f01042bb:	ff 36                	pushl  (%esi)
f01042bd:	ff 76 10             	pushl  0x10(%esi)
f01042c0:	ff 76 18             	pushl  0x18(%esi)
f01042c3:	ff 76 14             	pushl  0x14(%esi)
f01042c6:	ff 76 1c             	pushl  0x1c(%esi)
f01042c9:	e8 6c 03 00 00       	call   f010463a <syscall>
                    tf->tf_regs.reg_edx,
                    tf->tf_regs.reg_ecx,
                    tf->tf_regs.reg_ebx,
                    tf->tf_regs.reg_edi,
                    tf->tf_regs.reg_esi);
            tf->tf_regs.reg_eax = ret_code;
f01042ce:	89 46 1c             	mov    %eax,0x1c(%esi)
f01042d1:	83 c4 20             	add    $0x20,%esp
f01042d4:	eb 65                	jmp    f010433b <trap+0x20a>
            break;
		}
		case IRQ_OFFSET + IRQ_TIMER:{
			lapic_eoi();
f01042d6:	e8 f2 1b 00 00       	call   f0105ecd <lapic_eoi>
			sched_yield();
f01042db:	e8 7a 02 00 00       	call   f010455a <sched_yield>
			break;
		}
		case IRQ_OFFSET+IRQ_KBD:{
			lapic_eoi();
f01042e0:	e8 e8 1b 00 00       	call   f0105ecd <lapic_eoi>
			kbd_intr();
f01042e5:	e8 f6 c2 ff ff       	call   f01005e0 <kbd_intr>
f01042ea:	eb 4f                	jmp    f010433b <trap+0x20a>
			break;
		}
		case IRQ_OFFSET+IRQ_SERIAL:{
			lapic_eoi();
f01042ec:	e8 dc 1b 00 00       	call   f0105ecd <lapic_eoi>
			serial_intr();
f01042f1:	e8 ce c2 ff ff       	call   f01005c4 <serial_intr>
f01042f6:	eb 43                	jmp    f010433b <trap+0x20a>
			break;
		}
         default:
            // Unexpected trap: The user process or the kernel has a bug.
            print_trapframe(tf);
f01042f8:	83 ec 0c             	sub    $0xc,%esp
f01042fb:	56                   	push   %esi
f01042fc:	e8 91 fb ff ff       	call   f0103e92 <print_trapframe>
            if (tf->tf_cs == GD_KT)
f0104301:	83 c4 10             	add    $0x10,%esp
f0104304:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104309:	75 17                	jne    f0104322 <trap+0x1f1>
                panic("unhandled trap in kernel");
f010430b:	83 ec 04             	sub    $0x4,%esp
f010430e:	68 b3 79 10 f0       	push   $0xf01079b3
f0104313:	68 3a 01 00 00       	push   $0x13a
f0104318:	68 83 79 10 f0       	push   $0xf0107983
f010431d:	e8 1e bd ff ff       	call   f0100040 <_panic>
            else {
                env_destroy(curenv);
f0104322:	e8 5b 1a 00 00       	call   f0105d82 <cpunum>
f0104327:	83 ec 0c             	sub    $0xc,%esp
f010432a:	6b c0 74             	imul   $0x74,%eax,%eax
f010432d:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104333:	e8 25 f1 ff ff       	call   f010345d <env_destroy>
f0104338:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f010433b:	e8 42 1a 00 00       	call   f0105d82 <cpunum>
f0104340:	6b c0 74             	imul   $0x74,%eax,%eax
f0104343:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f010434a:	74 2a                	je     f0104376 <trap+0x245>
f010434c:	e8 31 1a 00 00       	call   f0105d82 <cpunum>
f0104351:	6b c0 74             	imul   $0x74,%eax,%eax
f0104354:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f010435a:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010435e:	75 16                	jne    f0104376 <trap+0x245>
		env_run(curenv);
f0104360:	e8 1d 1a 00 00       	call   f0105d82 <cpunum>
f0104365:	83 ec 0c             	sub    $0xc,%esp
f0104368:	6b c0 74             	imul   $0x74,%eax,%eax
f010436b:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104371:	e8 86 f1 ff ff       	call   f01034fc <env_run>
	else
		sched_yield();
f0104376:	e8 df 01 00 00       	call   f010455a <sched_yield>
f010437b:	90                   	nop

f010437c <t_divide>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
 /* 我现在也不知道为啥这个是这个  那个是那个*/
TRAPHANDLER_NOEC(t_divide, T_DIVIDE)
f010437c:	6a 00                	push   $0x0
f010437e:	6a 00                	push   $0x0
f0104380:	e9 ef 00 00 00       	jmp    f0104474 <_alltraps>
f0104385:	90                   	nop

f0104386 <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG)
f0104386:	6a 00                	push   $0x0
f0104388:	6a 01                	push   $0x1
f010438a:	e9 e5 00 00 00       	jmp    f0104474 <_alltraps>
f010438f:	90                   	nop

f0104390 <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI)
f0104390:	6a 00                	push   $0x0
f0104392:	6a 02                	push   $0x2
f0104394:	e9 db 00 00 00       	jmp    f0104474 <_alltraps>
f0104399:	90                   	nop

f010439a <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)
f010439a:	6a 00                	push   $0x0
f010439c:	6a 03                	push   $0x3
f010439e:	e9 d1 00 00 00       	jmp    f0104474 <_alltraps>
f01043a3:	90                   	nop

f01043a4 <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)
f01043a4:	6a 00                	push   $0x0
f01043a6:	6a 04                	push   $0x4
f01043a8:	e9 c7 00 00 00       	jmp    f0104474 <_alltraps>
f01043ad:	90                   	nop

f01043ae <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)
f01043ae:	6a 00                	push   $0x0
f01043b0:	6a 05                	push   $0x5
f01043b2:	e9 bd 00 00 00       	jmp    f0104474 <_alltraps>
f01043b7:	90                   	nop

f01043b8 <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)
f01043b8:	6a 00                	push   $0x0
f01043ba:	6a 06                	push   $0x6
f01043bc:	e9 b3 00 00 00       	jmp    f0104474 <_alltraps>
f01043c1:	90                   	nop

f01043c2 <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)
f01043c2:	6a 00                	push   $0x0
f01043c4:	6a 07                	push   $0x7
f01043c6:	e9 a9 00 00 00       	jmp    f0104474 <_alltraps>
f01043cb:	90                   	nop

f01043cc <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT)
f01043cc:	6a 08                	push   $0x8
f01043ce:	e9 a1 00 00 00       	jmp    f0104474 <_alltraps>
f01043d3:	90                   	nop

f01043d4 <t_tss>:
TRAPHANDLER(t_tss, T_TSS)
f01043d4:	6a 0a                	push   $0xa
f01043d6:	e9 99 00 00 00       	jmp    f0104474 <_alltraps>
f01043db:	90                   	nop

f01043dc <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP)
f01043dc:	6a 0b                	push   $0xb
f01043de:	e9 91 00 00 00       	jmp    f0104474 <_alltraps>
f01043e3:	90                   	nop

f01043e4 <t_stack>:
TRAPHANDLER(t_stack, T_STACK)
f01043e4:	6a 0c                	push   $0xc
f01043e6:	e9 89 00 00 00       	jmp    f0104474 <_alltraps>
f01043eb:	90                   	nop

f01043ec <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)
f01043ec:	6a 0d                	push   $0xd
f01043ee:	e9 81 00 00 00       	jmp    f0104474 <_alltraps>
f01043f3:	90                   	nop

f01043f4 <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)
f01043f4:	6a 0e                	push   $0xe
f01043f6:	eb 7c                	jmp    f0104474 <_alltraps>

f01043f8 <t_fperr>:
TRAPHANDLER_NOEC(t_fperr, T_FPERR)
f01043f8:	6a 00                	push   $0x0
f01043fa:	6a 10                	push   $0x10
f01043fc:	eb 76                	jmp    f0104474 <_alltraps>

f01043fe <t_align>:
TRAPHANDLER(t_align, T_ALIGN)
f01043fe:	6a 11                	push   $0x11
f0104400:	eb 72                	jmp    f0104474 <_alltraps>

f0104402 <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK)
f0104402:	6a 00                	push   $0x0
f0104404:	6a 12                	push   $0x12
f0104406:	eb 6c                	jmp    f0104474 <_alltraps>

f0104408 <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)
f0104408:	6a 00                	push   $0x0
f010440a:	6a 13                	push   $0x13
f010440c:	eb 66                	jmp    f0104474 <_alltraps>

f010440e <t_syscall>:

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f010440e:	6a 00                	push   $0x0
f0104410:	6a 30                	push   $0x30
f0104412:	eb 60                	jmp    f0104474 <_alltraps>

f0104414 <IRQ0>:

TRAPHANDLER_NOEC(IRQ0, IRQ_OFFSET)
f0104414:	6a 00                	push   $0x0
f0104416:	6a 20                	push   $0x20
f0104418:	eb 5a                	jmp    f0104474 <_alltraps>

f010441a <IRQ1>:
TRAPHANDLER_NOEC(IRQ1, IRQ_OFFSET+1)
f010441a:	6a 00                	push   $0x0
f010441c:	6a 21                	push   $0x21
f010441e:	eb 54                	jmp    f0104474 <_alltraps>

f0104420 <IRQ2>:
TRAPHANDLER_NOEC(IRQ2, IRQ_OFFSET+2)
f0104420:	6a 00                	push   $0x0
f0104422:	6a 22                	push   $0x22
f0104424:	eb 4e                	jmp    f0104474 <_alltraps>

f0104426 <IRQ3>:
TRAPHANDLER_NOEC(IRQ3, IRQ_OFFSET+3)
f0104426:	6a 00                	push   $0x0
f0104428:	6a 23                	push   $0x23
f010442a:	eb 48                	jmp    f0104474 <_alltraps>

f010442c <IRQ4>:
TRAPHANDLER_NOEC(IRQ4, IRQ_OFFSET+4)
f010442c:	6a 00                	push   $0x0
f010442e:	6a 24                	push   $0x24
f0104430:	eb 42                	jmp    f0104474 <_alltraps>

f0104432 <IRQ5>:
TRAPHANDLER_NOEC(IRQ5, IRQ_OFFSET+5)
f0104432:	6a 00                	push   $0x0
f0104434:	6a 25                	push   $0x25
f0104436:	eb 3c                	jmp    f0104474 <_alltraps>

f0104438 <IRQ6>:
TRAPHANDLER_NOEC(IRQ6, IRQ_OFFSET+6)
f0104438:	6a 00                	push   $0x0
f010443a:	6a 26                	push   $0x26
f010443c:	eb 36                	jmp    f0104474 <_alltraps>

f010443e <IRQ7>:
TRAPHANDLER_NOEC(IRQ7, IRQ_OFFSET+7)
f010443e:	6a 00                	push   $0x0
f0104440:	6a 27                	push   $0x27
f0104442:	eb 30                	jmp    f0104474 <_alltraps>

f0104444 <IRQ8>:
TRAPHANDLER_NOEC(IRQ8, IRQ_OFFSET+8)
f0104444:	6a 00                	push   $0x0
f0104446:	6a 28                	push   $0x28
f0104448:	eb 2a                	jmp    f0104474 <_alltraps>

f010444a <IRQ9>:
TRAPHANDLER_NOEC(IRQ9, IRQ_OFFSET+9)
f010444a:	6a 00                	push   $0x0
f010444c:	6a 29                	push   $0x29
f010444e:	eb 24                	jmp    f0104474 <_alltraps>

f0104450 <IRQ10>:
TRAPHANDLER_NOEC(IRQ10, IRQ_OFFSET+10)
f0104450:	6a 00                	push   $0x0
f0104452:	6a 2a                	push   $0x2a
f0104454:	eb 1e                	jmp    f0104474 <_alltraps>

f0104456 <IRQ11>:
TRAPHANDLER_NOEC(IRQ11, IRQ_OFFSET+11)
f0104456:	6a 00                	push   $0x0
f0104458:	6a 2b                	push   $0x2b
f010445a:	eb 18                	jmp    f0104474 <_alltraps>

f010445c <IRQ12>:
TRAPHANDLER_NOEC(IRQ12, IRQ_OFFSET+12)
f010445c:	6a 00                	push   $0x0
f010445e:	6a 2c                	push   $0x2c
f0104460:	eb 12                	jmp    f0104474 <_alltraps>

f0104462 <IRQ13>:
TRAPHANDLER_NOEC(IRQ13, IRQ_OFFSET+13)
f0104462:	6a 00                	push   $0x0
f0104464:	6a 2d                	push   $0x2d
f0104466:	eb 0c                	jmp    f0104474 <_alltraps>

f0104468 <IRQ14>:
TRAPHANDLER_NOEC(IRQ14, IRQ_OFFSET+14)
f0104468:	6a 00                	push   $0x0
f010446a:	6a 2e                	push   $0x2e
f010446c:	eb 06                	jmp    f0104474 <_alltraps>

f010446e <IRQ15>:
TRAPHANDLER_NOEC(IRQ15, IRQ_OFFSET+15)
f010446e:	6a 00                	push   $0x0
f0104470:	6a 2f                	push   $0x2f
f0104472:	eb 00                	jmp    f0104474 <_alltraps>

f0104474 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
 
 _alltraps:
 	pushl %ds
f0104474:	1e                   	push   %ds
	pushl %es
f0104475:	06                   	push   %es
	pushal /* push all general registers */
f0104476:	60                   	pusha  

	movl $GD_KD, %eax
f0104477:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f010447c:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f010447e:	8e c0                	mov    %eax,%es

	push %esp
f0104480:	54                   	push   %esp
	call trap	
f0104481:	e8 ab fc ff ff       	call   f0104131 <trap>

f0104486 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104486:	55                   	push   %ebp
f0104487:	89 e5                	mov    %esp,%ebp
f0104489:	83 ec 08             	sub    $0x8,%esp
f010448c:	a1 4c 12 21 f0       	mov    0xf021124c,%eax
f0104491:	8d 50 54             	lea    0x54(%eax),%edx
	int i;
	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104494:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104499:	8b 02                	mov    (%edx),%eax
f010449b:	83 e8 01             	sub    $0x1,%eax
f010449e:	83 f8 02             	cmp    $0x2,%eax
f01044a1:	76 10                	jbe    f01044b3 <sched_halt+0x2d>
sched_halt(void)
{
	int i;
	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01044a3:	83 c1 01             	add    $0x1,%ecx
f01044a6:	83 c2 7c             	add    $0x7c,%edx
f01044a9:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01044af:	75 e8                	jne    f0104499 <sched_halt+0x13>
f01044b1:	eb 08                	jmp    f01044bb <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f01044b3:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01044b9:	75 1f                	jne    f01044da <sched_halt+0x54>
		cprintf("No runnable environmeants in the system!\n");
f01044bb:	83 ec 0c             	sub    $0xc,%esp
f01044be:	68 90 7b 10 f0       	push   $0xf0107b90
f01044c3:	e8 6a f2 ff ff       	call   f0103732 <cprintf>
f01044c8:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01044cb:	83 ec 0c             	sub    $0xc,%esp
f01044ce:	6a 00                	push   $0x0
f01044d0:	e8 ca c3 ff ff       	call   f010089f <monitor>
f01044d5:	83 c4 10             	add    $0x10,%esp
f01044d8:	eb f1                	jmp    f01044cb <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01044da:	e8 a3 18 00 00       	call   f0105d82 <cpunum>
f01044df:	6b c0 74             	imul   $0x74,%eax,%eax
f01044e2:	c7 80 28 20 21 f0 00 	movl   $0x0,-0xfdedfd8(%eax)
f01044e9:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01044ec:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01044f1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01044f6:	77 12                	ja     f010450a <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01044f8:	50                   	push   %eax
f01044f9:	68 68 64 10 f0       	push   $0xf0106468
f01044fe:	6a 52                	push   $0x52
f0104500:	68 ba 7b 10 f0       	push   $0xf0107bba
f0104505:	e8 36 bb ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010450a:	05 00 00 00 10       	add    $0x10000000,%eax
f010450f:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104512:	e8 6b 18 00 00       	call   f0105d82 <cpunum>
f0104517:	6b d0 74             	imul   $0x74,%eax,%edx
f010451a:	81 c2 20 20 21 f0    	add    $0xf0212020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104520:	b8 02 00 00 00       	mov    $0x2,%eax
f0104525:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104529:	83 ec 0c             	sub    $0xc,%esp
f010452c:	68 c0 03 12 f0       	push   $0xf01203c0
f0104531:	e8 57 1b 00 00       	call   f010608d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104536:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104538:	e8 45 18 00 00       	call   f0105d82 <cpunum>
f010453d:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104540:	8b 80 30 20 21 f0    	mov    -0xfdedfd0(%eax),%eax
f0104546:	bd 00 00 00 00       	mov    $0x0,%ebp
f010454b:	89 c4                	mov    %eax,%esp
f010454d:	6a 00                	push   $0x0
f010454f:	6a 00                	push   $0x0
f0104551:	fb                   	sti    
f0104552:	f4                   	hlt    
f0104553:	eb fd                	jmp    f0104552 <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104555:	83 c4 10             	add    $0x10,%esp
f0104558:	c9                   	leave  
f0104559:	c3                   	ret    

f010455a <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f010455a:	55                   	push   %ebp
f010455b:	89 e5                	mov    %esp,%ebp
f010455d:	57                   	push   %edi
f010455e:	56                   	push   %esi
f010455f:	53                   	push   %ebx
f0104560:	83 ec 0c             	sub    $0xc,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int i, nxenvid;
    if (curenv)
f0104563:	e8 1a 18 00 00       	call   f0105d82 <cpunum>
f0104568:	6b c0 74             	imul   $0x74,%eax,%eax
        nxenvid = ENVX(curenv->env_id); 
    else 
        nxenvid = 0;
f010456b:	b9 00 00 00 00       	mov    $0x0,%ecx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int i, nxenvid;
    if (curenv)
f0104570:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f0104577:	74 17                	je     f0104590 <sched_yield+0x36>
        nxenvid = ENVX(curenv->env_id); 
f0104579:	e8 04 18 00 00       	call   f0105d82 <cpunum>
f010457e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104581:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104587:	8b 48 48             	mov    0x48(%eax),%ecx
f010458a:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
    else 
        nxenvid = 0;
	
    for (i = 0; i < NENV; i++) {
		//cprintf("cpu =%d %d status=%d\n",cpunum(),i,envs[(nxenvid + i) % NENV].env_status);
        if (envs[(nxenvid + i) % NENV].env_status == ENV_RUNNABLE){
f0104590:	8b 3d 4c 12 21 f0    	mov    0xf021124c,%edi
f0104596:	89 ca                	mov    %ecx,%edx
f0104598:	81 c1 00 04 00 00    	add    $0x400,%ecx
f010459e:	89 d3                	mov    %edx,%ebx
f01045a0:	c1 fb 1f             	sar    $0x1f,%ebx
f01045a3:	c1 eb 16             	shr    $0x16,%ebx
f01045a6:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f01045a9:	25 ff 03 00 00       	and    $0x3ff,%eax
f01045ae:	29 d8                	sub    %ebx,%eax
f01045b0:	6b c0 7c             	imul   $0x7c,%eax,%eax
f01045b3:	89 c6                	mov    %eax,%esi
f01045b5:	8d 1c 07             	lea    (%edi,%eax,1),%ebx
f01045b8:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f01045bc:	75 17                	jne    f01045d5 <sched_yield+0x7b>
			envs[(nxenvid + i) % NENV].env_cpunum=cpunum();
f01045be:	e8 bf 17 00 00       	call   f0105d82 <cpunum>
f01045c3:	89 43 5c             	mov    %eax,0x5c(%ebx)
			env_run(&envs[(nxenvid + i) % NENV]);
f01045c6:	83 ec 0c             	sub    $0xc,%esp
f01045c9:	03 35 4c 12 21 f0    	add    0xf021124c,%esi
f01045cf:	56                   	push   %esi
f01045d0:	e8 27 ef ff ff       	call   f01034fc <env_run>
f01045d5:	83 c2 01             	add    $0x1,%edx
    if (curenv)
        nxenvid = ENVX(curenv->env_id); 
    else 
        nxenvid = 0;
	
    for (i = 0; i < NENV; i++) {
f01045d8:	39 ca                	cmp    %ecx,%edx
f01045da:	75 c2                	jne    f010459e <sched_yield+0x44>
        if (envs[(nxenvid + i) % NENV].env_status == ENV_RUNNABLE){
			envs[(nxenvid + i) % NENV].env_cpunum=cpunum();
			env_run(&envs[(nxenvid + i) % NENV]);
		}
    }
    if (curenv && curenv->env_status == ENV_RUNNING){
f01045dc:	e8 a1 17 00 00       	call   f0105d82 <cpunum>
f01045e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01045e4:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f01045eb:	74 40                	je     f010462d <sched_yield+0xd3>
f01045ed:	e8 90 17 00 00       	call   f0105d82 <cpunum>
f01045f2:	6b c0 74             	imul   $0x74,%eax,%eax
f01045f5:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01045fb:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01045ff:	75 2c                	jne    f010462d <sched_yield+0xd3>
		curenv->env_cpunum=cpunum();
f0104601:	e8 7c 17 00 00       	call   f0105d82 <cpunum>
f0104606:	6b c0 74             	imul   $0x74,%eax,%eax
f0104609:	8b 98 28 20 21 f0    	mov    -0xfdedfd8(%eax),%ebx
f010460f:	e8 6e 17 00 00       	call   f0105d82 <cpunum>
f0104614:	89 43 5c             	mov    %eax,0x5c(%ebx)
		env_run(curenv);
f0104617:	e8 66 17 00 00       	call   f0105d82 <cpunum>
f010461c:	83 ec 0c             	sub    $0xc,%esp
f010461f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104622:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104628:	e8 cf ee ff ff       	call   f01034fc <env_run>
	}
	
	// sched_halt never returns
	sched_halt();
f010462d:	e8 54 fe ff ff       	call   f0104486 <sched_halt>
}
f0104632:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104635:	5b                   	pop    %ebx
f0104636:	5e                   	pop    %esi
f0104637:	5f                   	pop    %edi
f0104638:	5d                   	pop    %ebp
f0104639:	c3                   	ret    

f010463a <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010463a:	55                   	push   %ebp
f010463b:	89 e5                	mov    %esp,%ebp
f010463d:	57                   	push   %edi
f010463e:	56                   	push   %esi
f010463f:	53                   	push   %ebx
f0104640:	83 ec 1c             	sub    $0x1c,%esp
f0104643:	8b 45 08             	mov    0x8(%ebp),%eax
    // Return any appropriate return value.
    // LAB 3: Your code here.

    //    panic("syscall not implemented");

    switch (syscallno) {
f0104646:	83 f8 0d             	cmp    $0xd,%eax
f0104649:	0f 87 11 06 00 00    	ja     f0104c60 <syscall+0x626>
f010464f:	ff 24 85 cc 7b 10 f0 	jmp    *-0xfef8434(,%eax,4)
{
    // Check that the user has permission to read memory [s, s+len).
    // Destroy the environment if not:.

    // LAB 3: Your code here.
    user_mem_assert(curenv, s, len, 0);
f0104656:	e8 27 17 00 00       	call   f0105d82 <cpunum>
f010465b:	6a 00                	push   $0x0
f010465d:	ff 75 10             	pushl  0x10(%ebp)
f0104660:	ff 75 0c             	pushl  0xc(%ebp)
f0104663:	6b c0 74             	imul   $0x74,%eax,%eax
f0104666:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f010466c:	e8 b2 e7 ff ff       	call   f0102e23 <user_mem_assert>
    // Print the string supplied by the user.
    cprintf("%.*s", len, s);
f0104671:	83 c4 0c             	add    $0xc,%esp
f0104674:	ff 75 0c             	pushl  0xc(%ebp)
f0104677:	ff 75 10             	pushl  0x10(%ebp)
f010467a:	68 c7 7b 10 f0       	push   $0xf0107bc7
f010467f:	e8 ae f0 ff ff       	call   f0103732 <cprintf>
f0104684:	83 c4 10             	add    $0x10,%esp
    //    panic("syscall not implemented");

    switch (syscallno) {
        case (SYS_cputs):
            sys_cputs((const char *)a1, a2);
            return 0;
f0104687:	be 00 00 00 00       	mov    $0x0,%esi
f010468c:	e9 db 05 00 00       	jmp    f0104c6c <syscall+0x632>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104691:	e8 5c bf ff ff       	call   f01005f2 <cons_getc>
f0104696:	89 c6                	mov    %eax,%esi
    switch (syscallno) {
        case (SYS_cputs):
            sys_cputs((const char *)a1, a2);
            return 0;
        case (SYS_cgetc):
            return sys_cgetc();
f0104698:	e9 cf 05 00 00       	jmp    f0104c6c <syscall+0x632>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010469d:	e8 e0 16 00 00       	call   f0105d82 <cpunum>
f01046a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01046a5:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01046ab:	8b 70 48             	mov    0x48(%eax),%esi
            sys_cputs((const char *)a1, a2);
            return 0;
        case (SYS_cgetc):
            return sys_cgetc();
        case (SYS_getenvid):
            return sys_getenvid();
f01046ae:	e9 b9 05 00 00       	jmp    f0104c6c <syscall+0x632>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01046b3:	83 ec 04             	sub    $0x4,%esp
f01046b6:	6a 01                	push   $0x1
f01046b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046bb:	50                   	push   %eax
f01046bc:	ff 75 0c             	pushl  0xc(%ebp)
f01046bf:	e8 30 e8 ff ff       	call   f0102ef4 <envid2env>
f01046c4:	83 c4 10             	add    $0x10,%esp
		return r;
f01046c7:	89 c6                	mov    %eax,%esi
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01046c9:	85 c0                	test   %eax,%eax
f01046cb:	0f 88 9b 05 00 00    	js     f0104c6c <syscall+0x632>
		return r;
	env_destroy(e);
f01046d1:	83 ec 0c             	sub    $0xc,%esp
f01046d4:	ff 75 e4             	pushl  -0x1c(%ebp)
f01046d7:	e8 81 ed ff ff       	call   f010345d <env_destroy>
f01046dc:	83 c4 10             	add    $0x10,%esp
	return 0;
f01046df:	be 00 00 00 00       	mov    $0x0,%esi
f01046e4:	e9 83 05 00 00       	jmp    f0104c6c <syscall+0x632>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f01046e9:	e8 6c fe ff ff       	call   f010455a <sched_yield>
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env*child=NULL;
f01046ee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r=env_alloc(&child,curenv->env_id);
f01046f5:	e8 88 16 00 00       	call   f0105d82 <cpunum>
f01046fa:	83 ec 08             	sub    $0x8,%esp
f01046fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104700:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104706:	ff 70 48             	pushl  0x48(%eax)
f0104709:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010470c:	50                   	push   %eax
f010470d:	e8 f3 e8 ff ff       	call   f0103005 <env_alloc>
	if(r!=0)return r;
f0104712:	83 c4 10             	add    $0x10,%esp
f0104715:	89 c6                	mov    %eax,%esi
f0104717:	85 c0                	test   %eax,%eax
f0104719:	0f 85 4d 05 00 00    	jne    f0104c6c <syscall+0x632>
	child->env_tf=curenv->env_tf;
f010471f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104722:	e8 5b 16 00 00       	call   f0105d82 <cpunum>
f0104727:	6b c0 74             	imul   $0x74,%eax,%eax
f010472a:	8b b0 28 20 21 f0    	mov    -0xfdedfd8(%eax),%esi
f0104730:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104735:	89 df                	mov    %ebx,%edi
f0104737:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child->env_status=ENV_NOT_RUNNABLE;
f0104739:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010473c:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	//cprintf("status:%d\n",child->env_status);
	child->env_tf.tf_regs.reg_eax = 0;
f0104743:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return child->env_id;
f010474a:	8b 70 48             	mov    0x48(%eax),%esi
f010474d:	e9 1a 05 00 00       	jmp    f0104c6c <syscall+0x632>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	struct Env * env=NULL;
f0104752:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r=envid2env(envid,&env,1);
f0104759:	83 ec 04             	sub    $0x4,%esp
f010475c:	6a 01                	push   $0x1
f010475e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104761:	50                   	push   %eax
f0104762:	ff 75 0c             	pushl  0xc(%ebp)
f0104765:	e8 8a e7 ff ff       	call   f0102ef4 <envid2env>
	if(r<0)return -E_BAD_ENV;
f010476a:	83 c4 10             	add    $0x10,%esp
f010476d:	85 c0                	test   %eax,%eax
f010476f:	78 20                	js     f0104791 <syscall+0x157>
	else {
		if(status!=ENV_NOT_RUNNABLE&&status!=ENV_RUNNABLE)return -E_INVAL;
f0104771:	8b 45 10             	mov    0x10(%ebp),%eax
f0104774:	83 e8 02             	sub    $0x2,%eax
f0104777:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f010477c:	75 1d                	jne    f010479b <syscall+0x161>
		env->env_status=status;
f010477e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104781:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104784:	89 78 54             	mov    %edi,0x54(%eax)
	}
	return 0;
f0104787:	be 00 00 00 00       	mov    $0x0,%esi
f010478c:	e9 db 04 00 00       	jmp    f0104c6c <syscall+0x632>
	// envid's status.

	// LAB 4: Your code here.
	struct Env * env=NULL;
	int r=envid2env(envid,&env,1);
	if(r<0)return -E_BAD_ENV;
f0104791:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f0104796:	e9 d1 04 00 00       	jmp    f0104c6c <syscall+0x632>
	else {
		if(status!=ENV_NOT_RUNNABLE&&status!=ENV_RUNNABLE)return -E_INVAL;
f010479b:	be fd ff ff ff       	mov    $0xfffffffd,%esi
			sys_yield();
			return 0;
		case SYS_exofork:
           	return sys_exofork();
		case SYS_env_set_status:
           	return sys_env_set_status((envid_t)a1, (int)a2);
f01047a0:	e9 c7 04 00 00       	jmp    f0104c6c <syscall+0x632>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	struct Env * env;
	if(envid2env(envid,&env,1)<0)return -E_BAD_ENV;
f01047a5:	83 ec 04             	sub    $0x4,%esp
f01047a8:	6a 01                	push   $0x1
f01047aa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01047ad:	50                   	push   %eax
f01047ae:	ff 75 0c             	pushl  0xc(%ebp)
f01047b1:	e8 3e e7 ff ff       	call   f0102ef4 <envid2env>
f01047b6:	83 c4 10             	add    $0x10,%esp
f01047b9:	85 c0                	test   %eax,%eax
f01047bb:	78 6e                	js     f010482b <syscall+0x1f1>
	if((uintptr_t)va>=UTOP||PGOFF(va))return  -E_INVAL;
f01047bd:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01047c4:	77 6f                	ja     f0104835 <syscall+0x1fb>
f01047c6:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01047cd:	75 70                	jne    f010483f <syscall+0x205>
	int flag=PTE_U | PTE_P;
	if((perm & ~(PTE_SYSCALL))!=0||(perm&flag)!=flag)return -E_INVAL;
f01047cf:	8b 75 14             	mov    0x14(%ebp),%esi
f01047d2:	81 e6 f8 f1 ff ff    	and    $0xfffff1f8,%esi
f01047d8:	75 6f                	jne    f0104849 <syscall+0x20f>
f01047da:	8b 45 14             	mov    0x14(%ebp),%eax
f01047dd:	83 e0 05             	and    $0x5,%eax
f01047e0:	83 f8 05             	cmp    $0x5,%eax
f01047e3:	75 6e                	jne    f0104853 <syscall+0x219>
	struct PageInfo* pi=page_alloc(1);
f01047e5:	83 ec 0c             	sub    $0xc,%esp
f01047e8:	6a 01                	push   $0x1
f01047ea:	e8 06 c7 ff ff       	call   f0100ef5 <page_alloc>
f01047ef:	89 c3                	mov    %eax,%ebx
	if(pi==NULL)return -E_NO_MEM;
f01047f1:	83 c4 10             	add    $0x10,%esp
f01047f4:	85 c0                	test   %eax,%eax
f01047f6:	74 65                	je     f010485d <syscall+0x223>
	if(page_insert(env->env_pgdir,pi,va,perm)<0){
f01047f8:	ff 75 14             	pushl  0x14(%ebp)
f01047fb:	ff 75 10             	pushl  0x10(%ebp)
f01047fe:	50                   	push   %eax
f01047ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104802:	ff 70 60             	pushl  0x60(%eax)
f0104805:	e8 c1 c9 ff ff       	call   f01011cb <page_insert>
f010480a:	83 c4 10             	add    $0x10,%esp
f010480d:	85 c0                	test   %eax,%eax
f010480f:	0f 89 57 04 00 00    	jns    f0104c6c <syscall+0x632>
		page_free(pi);
f0104815:	83 ec 0c             	sub    $0xc,%esp
f0104818:	53                   	push   %ebx
f0104819:	e8 47 c7 ff ff       	call   f0100f65 <page_free>
f010481e:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f0104821:	be fc ff ff ff       	mov    $0xfffffffc,%esi
f0104826:	e9 41 04 00 00       	jmp    f0104c6c <syscall+0x632>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	struct Env * env;
	if(envid2env(envid,&env,1)<0)return -E_BAD_ENV;
f010482b:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f0104830:	e9 37 04 00 00       	jmp    f0104c6c <syscall+0x632>
	if((uintptr_t)va>=UTOP||PGOFF(va))return  -E_INVAL;
f0104835:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f010483a:	e9 2d 04 00 00       	jmp    f0104c6c <syscall+0x632>
f010483f:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104844:	e9 23 04 00 00       	jmp    f0104c6c <syscall+0x632>
	int flag=PTE_U | PTE_P;
	if((perm & ~(PTE_SYSCALL))!=0||(perm&flag)!=flag)return -E_INVAL;
f0104849:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f010484e:	e9 19 04 00 00       	jmp    f0104c6c <syscall+0x632>
f0104853:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104858:	e9 0f 04 00 00       	jmp    f0104c6c <syscall+0x632>
	struct PageInfo* pi=page_alloc(1);
	if(pi==NULL)return -E_NO_MEM;
f010485d:	be fc ff ff ff       	mov    $0xfffffffc,%esi
		case SYS_exofork:
           	return sys_exofork();
		case SYS_env_set_status:
           	return sys_env_set_status((envid_t)a1, (int)a2);
		case SYS_page_alloc:
           	return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
f0104862:	e9 05 04 00 00       	jmp    f0104c6c <syscall+0x632>
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	int r=0;
	struct Env * srccur=NULL,*dstcur=NULL;
f0104867:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010486e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	r=envid2env(srcenvid,&srccur,1);
f0104875:	83 ec 04             	sub    $0x4,%esp
f0104878:	6a 01                	push   $0x1
f010487a:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010487d:	50                   	push   %eax
f010487e:	ff 75 0c             	pushl  0xc(%ebp)
f0104881:	e8 6e e6 ff ff       	call   f0102ef4 <envid2env>
	if(r<0)return -E_BAD_ENV;
f0104886:	83 c4 10             	add    $0x10,%esp
f0104889:	85 c0                	test   %eax,%eax
f010488b:	0f 88 b2 00 00 00    	js     f0104943 <syscall+0x309>
	r=envid2env(dstenvid,&dstcur,1);
f0104891:	83 ec 04             	sub    $0x4,%esp
f0104894:	6a 01                	push   $0x1
f0104896:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104899:	50                   	push   %eax
f010489a:	ff 75 14             	pushl  0x14(%ebp)
f010489d:	e8 52 e6 ff ff       	call   f0102ef4 <envid2env>
	if(r<0)return -E_BAD_ENV;
f01048a2:	83 c4 10             	add    $0x10,%esp
f01048a5:	85 c0                	test   %eax,%eax
f01048a7:	0f 88 a0 00 00 00    	js     f010494d <syscall+0x313>
	if((uintptr_t)srcva >= UTOP||(uintptr_t)dstva >= UTOP||PGOFF(srcva)|| PGOFF(dstva))return -E_INVAL;
f01048ad:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01048b4:	0f 87 9d 00 00 00    	ja     f0104957 <syscall+0x31d>
f01048ba:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01048c1:	0f 87 90 00 00 00    	ja     f0104957 <syscall+0x31d>
f01048c7:	8b 45 10             	mov    0x10(%ebp),%eax
f01048ca:	0b 45 18             	or     0x18(%ebp),%eax
f01048cd:	a9 ff 0f 00 00       	test   $0xfff,%eax
f01048d2:	0f 85 89 00 00 00    	jne    f0104961 <syscall+0x327>
	pte_t * store=NULL;
f01048d8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	struct PageInfo* pg=NULL;
	if((pg=page_lookup(srccur->env_pgdir,srcva,&store))==NULL)return -E_INVAL;
f01048df:	83 ec 04             	sub    $0x4,%esp
f01048e2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01048e5:	50                   	push   %eax
f01048e6:	ff 75 10             	pushl  0x10(%ebp)
f01048e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01048ec:	ff 70 60             	pushl  0x60(%eax)
f01048ef:	e8 f6 c7 ff ff       	call   f01010ea <page_lookup>
f01048f4:	83 c4 10             	add    $0x10,%esp
f01048f7:	85 c0                	test   %eax,%eax
f01048f9:	74 70                	je     f010496b <syscall+0x331>
	int flag=PTE_U | PTE_P;
	if((perm & ~(PTE_SYSCALL))!=0||(perm&flag)!=flag)return -E_INVAL;
f01048fb:	8b 75 1c             	mov    0x1c(%ebp),%esi
f01048fe:	81 e6 f8 f1 ff ff    	and    $0xfffff1f8,%esi
f0104904:	75 6f                	jne    f0104975 <syscall+0x33b>
f0104906:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0104909:	83 e2 05             	and    $0x5,%edx
f010490c:	83 fa 05             	cmp    $0x5,%edx
f010490f:	75 6e                	jne    f010497f <syscall+0x345>
	if((perm&PTE_W)&&!(*store&PTE_W))return E_INVAL;
f0104911:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104915:	74 08                	je     f010491f <syscall+0x2e5>
f0104917:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010491a:	f6 02 02             	testb  $0x2,(%edx)
f010491d:	74 6a                	je     f0104989 <syscall+0x34f>
	if (page_insert(dstcur->env_pgdir, pg, dstva, perm) < 0) 
f010491f:	ff 75 1c             	pushl  0x1c(%ebp)
f0104922:	ff 75 18             	pushl  0x18(%ebp)
f0104925:	50                   	push   %eax
f0104926:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104929:	ff 70 60             	pushl  0x60(%eax)
f010492c:	e8 9a c8 ff ff       	call   f01011cb <page_insert>
f0104931:	83 c4 10             	add    $0x10,%esp
        return -E_NO_MEM;
f0104934:	85 c0                	test   %eax,%eax
f0104936:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010493b:	0f 48 f0             	cmovs  %eax,%esi
f010493e:	e9 29 03 00 00       	jmp    f0104c6c <syscall+0x632>

	// LAB 4: Your code here.
	int r=0;
	struct Env * srccur=NULL,*dstcur=NULL;
	r=envid2env(srcenvid,&srccur,1);
	if(r<0)return -E_BAD_ENV;
f0104943:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f0104948:	e9 1f 03 00 00       	jmp    f0104c6c <syscall+0x632>
	r=envid2env(dstenvid,&dstcur,1);
	if(r<0)return -E_BAD_ENV;
f010494d:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f0104952:	e9 15 03 00 00       	jmp    f0104c6c <syscall+0x632>
	if((uintptr_t)srcva >= UTOP||(uintptr_t)dstva >= UTOP||PGOFF(srcva)|| PGOFF(dstva))return -E_INVAL;
f0104957:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f010495c:	e9 0b 03 00 00       	jmp    f0104c6c <syscall+0x632>
f0104961:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104966:	e9 01 03 00 00       	jmp    f0104c6c <syscall+0x632>
	pte_t * store=NULL;
	struct PageInfo* pg=NULL;
	if((pg=page_lookup(srccur->env_pgdir,srcva,&store))==NULL)return -E_INVAL;
f010496b:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104970:	e9 f7 02 00 00       	jmp    f0104c6c <syscall+0x632>
	int flag=PTE_U | PTE_P;
	if((perm & ~(PTE_SYSCALL))!=0||(perm&flag)!=flag)return -E_INVAL;
f0104975:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f010497a:	e9 ed 02 00 00       	jmp    f0104c6c <syscall+0x632>
f010497f:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104984:	e9 e3 02 00 00       	jmp    f0104c6c <syscall+0x632>
	if((perm&PTE_W)&&!(*store&PTE_W))return E_INVAL;
f0104989:	be 03 00 00 00       	mov    $0x3,%esi
f010498e:	e9 d9 02 00 00       	jmp    f0104c6c <syscall+0x632>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env *env;
	int r=envid2env(envid,&env,1);
f0104993:	83 ec 04             	sub    $0x4,%esp
f0104996:	6a 01                	push   $0x1
f0104998:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010499b:	50                   	push   %eax
f010499c:	ff 75 0c             	pushl  0xc(%ebp)
f010499f:	e8 50 e5 ff ff       	call   f0102ef4 <envid2env>
	if(r<0)return -E_BAD_ENV;
f01049a4:	83 c4 10             	add    $0x10,%esp
f01049a7:	85 c0                	test   %eax,%eax
f01049a9:	78 30                	js     f01049db <syscall+0x3a1>
	if((uintptr_t)va>=UTOP||PGOFF(va))return  -E_INVAL;
f01049ab:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01049b2:	77 31                	ja     f01049e5 <syscall+0x3ab>
f01049b4:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01049bb:	75 32                	jne    f01049ef <syscall+0x3b5>
	page_remove(env->env_pgdir,va);
f01049bd:	83 ec 08             	sub    $0x8,%esp
f01049c0:	ff 75 10             	pushl  0x10(%ebp)
f01049c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049c6:	ff 70 60             	pushl  0x60(%eax)
f01049c9:	e8 b7 c7 ff ff       	call   f0101185 <page_remove>
f01049ce:	83 c4 10             	add    $0x10,%esp
	return 0;
f01049d1:	be 00 00 00 00       	mov    $0x0,%esi
f01049d6:	e9 91 02 00 00       	jmp    f0104c6c <syscall+0x632>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env *env;
	int r=envid2env(envid,&env,1);
	if(r<0)return -E_BAD_ENV;
f01049db:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f01049e0:	e9 87 02 00 00       	jmp    f0104c6c <syscall+0x632>
	if((uintptr_t)va>=UTOP||PGOFF(va))return  -E_INVAL;
f01049e5:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01049ea:	e9 7d 02 00 00       	jmp    f0104c6c <syscall+0x632>
f01049ef:	be fd ff ff ff       	mov    $0xfffffffd,%esi
		case SYS_page_alloc:
           	return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
       	case SYS_page_map:
           	return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
       	case SYS_page_unmap:
           	return sys_page_unmap((envid_t)a1, (void *)a2);
f01049f4:	e9 73 02 00 00       	jmp    f0104c6c <syscall+0x632>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env * env;
	if(envid2env(envid,&env,1)<0)return -E_BAD_ENV;
f01049f9:	83 ec 04             	sub    $0x4,%esp
f01049fc:	6a 01                	push   $0x1
f01049fe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a01:	50                   	push   %eax
f0104a02:	ff 75 0c             	pushl  0xc(%ebp)
f0104a05:	e8 ea e4 ff ff       	call   f0102ef4 <envid2env>
f0104a0a:	83 c4 10             	add    $0x10,%esp
f0104a0d:	85 c0                	test   %eax,%eax
f0104a0f:	78 13                	js     f0104a24 <syscall+0x3ea>
	env->env_pgfault_upcall=func;
f0104a11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a14:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104a17:	89 48 64             	mov    %ecx,0x64(%eax)

	return 0;
f0104a1a:	be 00 00 00 00       	mov    $0x0,%esi
f0104a1f:	e9 48 02 00 00       	jmp    f0104c6c <syscall+0x632>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env * env;
	if(envid2env(envid,&env,1)<0)return -E_BAD_ENV;
f0104a24:	be fe ff ff ff       	mov    $0xfffffffe,%esi
       	case SYS_page_map:
           	return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
       	case SYS_page_unmap:
           	return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1,(void *)a2);
f0104a29:	e9 3e 02 00 00       	jmp    f0104c6c <syscall+0x632>
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	struct Env* env;
	if(envid2env(envid,&env,0)<0)return -E_BAD_ENV;
f0104a2e:	83 ec 04             	sub    $0x4,%esp
f0104a31:	6a 00                	push   $0x0
f0104a33:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a36:	50                   	push   %eax
f0104a37:	ff 75 0c             	pushl  0xc(%ebp)
f0104a3a:	e8 b5 e4 ff ff       	call   f0102ef4 <envid2env>
f0104a3f:	83 c4 10             	add    $0x10,%esp
f0104a42:	85 c0                	test   %eax,%eax
f0104a44:	0f 88 29 01 00 00    	js     f0104b73 <syscall+0x539>
	if(env->env_ipc_recving==0)return -E_IPC_NOT_RECV;
f0104a4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a4d:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104a51:	0f 84 26 01 00 00    	je     f0104b7d <syscall+0x543>
	env->env_ipc_perm = 0;
f0104a57:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	unsigned flag= PTE_P | PTE_U;
	if((uintptr_t)srcva<UTOP){
f0104a5e:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104a65:	0f 87 cc 00 00 00    	ja     f0104b37 <syscall+0x4fd>
		if(PGOFF(srcva))return -E_INVAL;
f0104a6b:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104a72:	0f 85 0f 01 00 00    	jne    f0104b87 <syscall+0x54d>
		if ((perm & ~(PTE_SYSCALL)) || ((perm & flag) != flag))return -E_INVAL;
f0104a78:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f0104a7f:	0f 85 0c 01 00 00    	jne    f0104b91 <syscall+0x557>
f0104a85:	8b 45 18             	mov    0x18(%ebp),%eax
f0104a88:	83 e0 05             	and    $0x5,%eax
f0104a8b:	83 f8 05             	cmp    $0x5,%eax
f0104a8e:	0f 85 07 01 00 00    	jne    f0104b9b <syscall+0x561>
		if (user_mem_check(curenv, (const void *)srcva, PGSIZE, PTE_U) < 0)
f0104a94:	e8 e9 12 00 00       	call   f0105d82 <cpunum>
f0104a99:	6a 04                	push   $0x4
f0104a9b:	68 00 10 00 00       	push   $0x1000
f0104aa0:	ff 75 14             	pushl  0x14(%ebp)
f0104aa3:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aa6:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104aac:	e8 e1 e2 ff ff       	call   f0102d92 <user_mem_check>
f0104ab1:	83 c4 10             	add    $0x10,%esp
f0104ab4:	85 c0                	test   %eax,%eax
f0104ab6:	0f 88 e9 00 00 00    	js     f0104ba5 <syscall+0x56b>
            return -E_INVAL;
		if (perm& PTE_W&&user_mem_check(curenv, (const void *)srcva, PGSIZE, PTE_U |PTE_W) < 0)
f0104abc:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104ac0:	74 28                	je     f0104aea <syscall+0x4b0>
f0104ac2:	e8 bb 12 00 00       	call   f0105d82 <cpunum>
f0104ac7:	6a 06                	push   $0x6
f0104ac9:	68 00 10 00 00       	push   $0x1000
f0104ace:	ff 75 14             	pushl  0x14(%ebp)
f0104ad1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ad4:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104ada:	e8 b3 e2 ff ff       	call   f0102d92 <user_mem_check>
f0104adf:	83 c4 10             	add    $0x10,%esp
f0104ae2:	85 c0                	test   %eax,%eax
f0104ae4:	0f 88 c5 00 00 00    	js     f0104baf <syscall+0x575>
            return -E_INVAL;
		if((uintptr_t)(env->env_ipc_dstva)<UTOP){
f0104aea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104aed:	81 78 6c ff ff bf ee 	cmpl   $0xeebfffff,0x6c(%eax)
f0104af4:	77 41                	ja     f0104b37 <syscall+0x4fd>
			env->env_ipc_perm=perm;
f0104af6:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0104af9:	89 58 78             	mov    %ebx,0x78(%eax)
			struct PageInfo *pi = page_lookup(curenv->env_pgdir, srcva, 0);
f0104afc:	e8 81 12 00 00       	call   f0105d82 <cpunum>
f0104b01:	83 ec 04             	sub    $0x4,%esp
f0104b04:	6a 00                	push   $0x0
f0104b06:	ff 75 14             	pushl  0x14(%ebp)
f0104b09:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b0c:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104b12:	ff 70 60             	pushl  0x60(%eax)
f0104b15:	e8 d0 c5 ff ff       	call   f01010ea <page_lookup>
			if (page_insert(env->env_pgdir, pi, env->env_ipc_dstva,  perm) < 0)
f0104b1a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104b1d:	ff 75 18             	pushl  0x18(%ebp)
f0104b20:	ff 72 6c             	pushl  0x6c(%edx)
f0104b23:	50                   	push   %eax
f0104b24:	ff 72 60             	pushl  0x60(%edx)
f0104b27:	e8 9f c6 ff ff       	call   f01011cb <page_insert>
f0104b2c:	83 c4 20             	add    $0x20,%esp
f0104b2f:	85 c0                	test   %eax,%eax
f0104b31:	0f 88 82 00 00 00    	js     f0104bb9 <syscall+0x57f>
                return -E_NO_MEM; 
		}
	}
	env->env_ipc_recving = false;
f0104b37:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b3a:	c6 46 68 00          	movb   $0x0,0x68(%esi)
    env->env_ipc_from = curenv->env_id;
f0104b3e:	e8 3f 12 00 00       	call   f0105d82 <cpunum>
f0104b43:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b46:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104b4c:	8b 40 48             	mov    0x48(%eax),%eax
f0104b4f:	89 46 74             	mov    %eax,0x74(%esi)
    env->env_ipc_value = value;
f0104b52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b55:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0104b58:	89 58 70             	mov    %ebx,0x70(%eax)
    env->env_status = ENV_RUNNABLE;
f0104b5b:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
    env->env_tf.tf_regs.reg_eax = 0;
f0104b62:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f0104b69:	be 00 00 00 00       	mov    $0x0,%esi
f0104b6e:	e9 f9 00 00 00       	jmp    f0104c6c <syscall+0x632>
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	struct Env* env;
	if(envid2env(envid,&env,0)<0)return -E_BAD_ENV;
f0104b73:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f0104b78:	e9 ef 00 00 00       	jmp    f0104c6c <syscall+0x632>
	if(env->env_ipc_recving==0)return -E_IPC_NOT_RECV;
f0104b7d:	be f9 ff ff ff       	mov    $0xfffffff9,%esi
f0104b82:	e9 e5 00 00 00       	jmp    f0104c6c <syscall+0x632>
	env->env_ipc_perm = 0;
	unsigned flag= PTE_P | PTE_U;
	if((uintptr_t)srcva<UTOP){
		if(PGOFF(srcva))return -E_INVAL;
f0104b87:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104b8c:	e9 db 00 00 00       	jmp    f0104c6c <syscall+0x632>
		if ((perm & ~(PTE_SYSCALL)) || ((perm & flag) != flag))return -E_INVAL;
f0104b91:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104b96:	e9 d1 00 00 00       	jmp    f0104c6c <syscall+0x632>
f0104b9b:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104ba0:	e9 c7 00 00 00       	jmp    f0104c6c <syscall+0x632>
		if (user_mem_check(curenv, (const void *)srcva, PGSIZE, PTE_U) < 0)
            return -E_INVAL;
f0104ba5:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104baa:	e9 bd 00 00 00       	jmp    f0104c6c <syscall+0x632>
		if (perm& PTE_W&&user_mem_check(curenv, (const void *)srcva, PGSIZE, PTE_U |PTE_W) < 0)
            return -E_INVAL;
f0104baf:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104bb4:	e9 b3 00 00 00       	jmp    f0104c6c <syscall+0x632>
		if((uintptr_t)(env->env_ipc_dstva)<UTOP){
			env->env_ipc_perm=perm;
			struct PageInfo *pi = page_lookup(curenv->env_pgdir, srcva, 0);
			if (page_insert(env->env_pgdir, pi, env->env_ipc_dstva,  perm) < 0)
                return -E_NO_MEM; 
f0104bb9:	be fc ff ff ff       	mov    $0xfffffffc,%esi
       	case SYS_page_unmap:
           	return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1,(void *)a2);
		case SYS_ipc_try_send:                                                                                          
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);                               
f0104bbe:	e9 a9 00 00 00       	jmp    f0104c6c <syscall+0x632>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if((dstva < (void *)UTOP) && PGOFF(dstva))
f0104bc3:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104bca:	77 0d                	ja     f0104bd9 <syscall+0x59f>
f0104bcc:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104bd3:	0f 85 8e 00 00 00    	jne    f0104c67 <syscall+0x62d>
        return -E_INVAL;
	curenv->env_ipc_recving = true; 
f0104bd9:	e8 a4 11 00 00       	call   f0105d82 <cpunum>
f0104bde:	6b c0 74             	imul   $0x74,%eax,%eax
f0104be1:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104be7:	c6 40 68 01          	movb   $0x1,0x68(%eax)
    curenv->env_ipc_dstva = dstva;
f0104beb:	e8 92 11 00 00       	call   f0105d82 <cpunum>
f0104bf0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bf3:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104bf9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104bfc:	89 58 6c             	mov    %ebx,0x6c(%eax)
    curenv->env_status = ENV_NOT_RUNNABLE;
f0104bff:	e8 7e 11 00 00       	call   f0105d82 <cpunum>
f0104c04:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c07:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104c0d:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
    sched_yield();
f0104c14:	e8 41 f9 ff ff       	call   f010455a <sched_yield>
		case SYS_ipc_try_send:                                                                                          
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);                               
		case SYS_ipc_recv:                                                                                              
			return sys_ipc_recv((void *)a1);
        case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1,(struct Trapframe*)a2);
f0104c19:	8b 75 10             	mov    0x10(%ebp),%esi
{
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env *child;
	if((envid2env(envid,&child,1))<0){
f0104c1c:	83 ec 04             	sub    $0x4,%esp
f0104c1f:	6a 01                	push   $0x1
f0104c21:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104c24:	50                   	push   %eax
f0104c25:	ff 75 0c             	pushl  0xc(%ebp)
f0104c28:	e8 c7 e2 ff ff       	call   f0102ef4 <envid2env>
f0104c2d:	83 c4 10             	add    $0x10,%esp
f0104c30:	85 c0                	test   %eax,%eax
f0104c32:	78 25                	js     f0104c59 <syscall+0x61f>
		return -E_BAD_ENV;
	}
	child->env_tf=*tf;
f0104c34:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104c39:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104c3c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child->env_tf.tf_cs |= 0x3; 
f0104c3e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104c41:	66 83 4a 34 03       	orw    $0x3,0x34(%edx)
	child->env_tf.tf_eflags &=  (~FL_IOPL_MASK);
	child->env_tf.tf_eflags |= FL_IF;
f0104c46:	8b 42 38             	mov    0x38(%edx),%eax
f0104c49:	80 e4 cf             	and    $0xcf,%ah
f0104c4c:	80 cc 02             	or     $0x2,%ah
f0104c4f:	89 42 38             	mov    %eax,0x38(%edx)
	return 0;
f0104c52:	be 00 00 00 00       	mov    $0x0,%esi
f0104c57:	eb 13                	jmp    f0104c6c <syscall+0x632>
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env *child;
	if((envid2env(envid,&child,1))<0){
		return -E_BAD_ENV;
f0104c59:	be fe ff ff ff       	mov    $0xfffffffe,%esi
		case SYS_ipc_try_send:                                                                                          
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);                               
		case SYS_ipc_recv:                                                                                              
			return sys_ipc_recv((void *)a1);
        case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1,(struct Trapframe*)a2);
f0104c5e:	eb 0c                	jmp    f0104c6c <syscall+0x632>
		default:
            return -E_INVAL;
f0104c60:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104c65:	eb 05                	jmp    f0104c6c <syscall+0x632>
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1,(void *)a2);
		case SYS_ipc_try_send:                                                                                          
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);                               
		case SYS_ipc_recv:                                                                                              
			return sys_ipc_recv((void *)a1);
f0104c67:	be fd ff ff ff       	mov    $0xfffffffd,%esi
        case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1,(struct Trapframe*)a2);
		default:
            return -E_INVAL;
    }
}
f0104c6c:	89 f0                	mov    %esi,%eax
f0104c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104c71:	5b                   	pop    %ebx
f0104c72:	5e                   	pop    %esi
f0104c73:	5f                   	pop    %edi
f0104c74:	5d                   	pop    %ebp
f0104c75:	c3                   	ret    

f0104c76 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104c76:	55                   	push   %ebp
f0104c77:	89 e5                	mov    %esp,%ebp
f0104c79:	57                   	push   %edi
f0104c7a:	56                   	push   %esi
f0104c7b:	53                   	push   %ebx
f0104c7c:	83 ec 14             	sub    $0x14,%esp
f0104c7f:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104c82:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104c85:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104c88:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104c8b:	8b 1a                	mov    (%edx),%ebx
f0104c8d:	8b 01                	mov    (%ecx),%eax
f0104c8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c92:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104c99:	eb 7f                	jmp    f0104d1a <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104c9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104c9e:	01 d8                	add    %ebx,%eax
f0104ca0:	89 c6                	mov    %eax,%esi
f0104ca2:	c1 ee 1f             	shr    $0x1f,%esi
f0104ca5:	01 c6                	add    %eax,%esi
f0104ca7:	d1 fe                	sar    %esi
f0104ca9:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104cac:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104caf:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104cb2:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104cb4:	eb 03                	jmp    f0104cb9 <stab_binsearch+0x43>
			m--;
f0104cb6:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104cb9:	39 c3                	cmp    %eax,%ebx
f0104cbb:	7f 0d                	jg     f0104cca <stab_binsearch+0x54>
f0104cbd:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104cc1:	83 ea 0c             	sub    $0xc,%edx
f0104cc4:	39 f9                	cmp    %edi,%ecx
f0104cc6:	75 ee                	jne    f0104cb6 <stab_binsearch+0x40>
f0104cc8:	eb 05                	jmp    f0104ccf <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104cca:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104ccd:	eb 4b                	jmp    f0104d1a <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104ccf:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104cd2:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104cd5:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104cd9:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104cdc:	76 11                	jbe    f0104cef <stab_binsearch+0x79>
			*region_left = m;
f0104cde:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104ce1:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104ce3:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104ce6:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104ced:	eb 2b                	jmp    f0104d1a <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104cef:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104cf2:	73 14                	jae    f0104d08 <stab_binsearch+0x92>
			*region_right = m - 1;
f0104cf4:	83 e8 01             	sub    $0x1,%eax
f0104cf7:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104cfa:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104cfd:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104cff:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104d06:	eb 12                	jmp    f0104d1a <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104d08:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104d0b:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104d0d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104d11:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104d13:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104d1a:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104d1d:	0f 8e 78 ff ff ff    	jle    f0104c9b <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104d23:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104d27:	75 0f                	jne    f0104d38 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104d29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d2c:	8b 00                	mov    (%eax),%eax
f0104d2e:	83 e8 01             	sub    $0x1,%eax
f0104d31:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104d34:	89 06                	mov    %eax,(%esi)
f0104d36:	eb 2c                	jmp    f0104d64 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d38:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d3b:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104d3d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104d40:	8b 0e                	mov    (%esi),%ecx
f0104d42:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104d45:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104d48:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d4b:	eb 03                	jmp    f0104d50 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104d4d:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d50:	39 c8                	cmp    %ecx,%eax
f0104d52:	7e 0b                	jle    f0104d5f <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104d54:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104d58:	83 ea 0c             	sub    $0xc,%edx
f0104d5b:	39 df                	cmp    %ebx,%edi
f0104d5d:	75 ee                	jne    f0104d4d <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104d5f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104d62:	89 06                	mov    %eax,(%esi)
	}
}
f0104d64:	83 c4 14             	add    $0x14,%esp
f0104d67:	5b                   	pop    %ebx
f0104d68:	5e                   	pop    %esi
f0104d69:	5f                   	pop    %edi
f0104d6a:	5d                   	pop    %ebp
f0104d6b:	c3                   	ret    

f0104d6c <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104d6c:	55                   	push   %ebp
f0104d6d:	89 e5                	mov    %esp,%ebp
f0104d6f:	57                   	push   %edi
f0104d70:	56                   	push   %esi
f0104d71:	53                   	push   %ebx
f0104d72:	83 ec 2c             	sub    $0x2c,%esp
f0104d75:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104d78:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104d7b:	c7 06 04 7c 10 f0    	movl   $0xf0107c04,(%esi)
	info->eip_line = 0;
f0104d81:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0104d88:	c7 46 08 04 7c 10 f0 	movl   $0xf0107c04,0x8(%esi)
	info->eip_fn_namelen = 9;
f0104d8f:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0104d96:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0104d99:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104da0:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104da6:	77 21                	ja     f0104dc9 <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104da8:	a1 00 00 20 00       	mov    0x200000,%eax
f0104dad:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f0104db0:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104db5:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f0104dbb:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f0104dbe:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f0104dc4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0104dc7:	eb 1a                	jmp    f0104de3 <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104dc9:	c7 45 d0 27 5a 11 f0 	movl   $0xf0115a27,-0x30(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104dd0:	c7 45 cc 51 23 11 f0 	movl   $0xf0112351,-0x34(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104dd7:	b8 50 23 11 f0       	mov    $0xf0112350,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104ddc:	c7 45 d4 b0 81 10 f0 	movl   $0xf01081b0,-0x2c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104de3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104de6:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f0104de9:	0f 83 2b 01 00 00    	jae    f0104f1a <debuginfo_eip+0x1ae>
f0104def:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104df3:	0f 85 28 01 00 00    	jne    f0104f21 <debuginfo_eip+0x1b5>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104df9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104e00:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104e03:	29 d8                	sub    %ebx,%eax
f0104e05:	c1 f8 02             	sar    $0x2,%eax
f0104e08:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104e0e:	83 e8 01             	sub    $0x1,%eax
f0104e11:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104e14:	57                   	push   %edi
f0104e15:	6a 64                	push   $0x64
f0104e17:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104e1a:	89 c1                	mov    %eax,%ecx
f0104e1c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104e1f:	89 d8                	mov    %ebx,%eax
f0104e21:	e8 50 fe ff ff       	call   f0104c76 <stab_binsearch>
	if (lfile == 0)
f0104e26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e29:	83 c4 08             	add    $0x8,%esp
f0104e2c:	85 c0                	test   %eax,%eax
f0104e2e:	0f 84 f4 00 00 00    	je     f0104f28 <debuginfo_eip+0x1bc>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104e34:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104e37:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e3a:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104e3d:	57                   	push   %edi
f0104e3e:	6a 24                	push   $0x24
f0104e40:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0104e43:	89 c1                	mov    %eax,%ecx
f0104e45:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104e48:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0104e4b:	89 d8                	mov    %ebx,%eax
f0104e4d:	e8 24 fe ff ff       	call   f0104c76 <stab_binsearch>

	if (lfun <= rfun) {
f0104e52:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104e55:	83 c4 08             	add    $0x8,%esp
f0104e58:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0104e5b:	7f 24                	jg     f0104e81 <debuginfo_eip+0x115>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104e5d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104e60:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104e63:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104e66:	8b 02                	mov    (%edx),%eax
f0104e68:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104e6b:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104e6e:	29 f9                	sub    %edi,%ecx
f0104e70:	39 c8                	cmp    %ecx,%eax
f0104e72:	73 05                	jae    f0104e79 <debuginfo_eip+0x10d>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104e74:	01 f8                	add    %edi,%eax
f0104e76:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104e79:	8b 42 08             	mov    0x8(%edx),%eax
f0104e7c:	89 46 10             	mov    %eax,0x10(%esi)
f0104e7f:	eb 06                	jmp    f0104e87 <debuginfo_eip+0x11b>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104e81:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0104e84:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104e87:	83 ec 08             	sub    $0x8,%esp
f0104e8a:	6a 3a                	push   $0x3a
f0104e8c:	ff 76 08             	pushl  0x8(%esi)
f0104e8f:	e8 b2 08 00 00       	call   f0105746 <strfind>
f0104e94:	2b 46 08             	sub    0x8(%esi),%eax
f0104e97:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104e9a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104e9d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104ea0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104ea3:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0104ea6:	83 c4 10             	add    $0x10,%esp
f0104ea9:	eb 06                	jmp    f0104eb1 <debuginfo_eip+0x145>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104eab:	83 eb 01             	sub    $0x1,%ebx
f0104eae:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104eb1:	39 fb                	cmp    %edi,%ebx
f0104eb3:	7c 2d                	jl     f0104ee2 <debuginfo_eip+0x176>
	       && stabs[lline].n_type != N_SOL
f0104eb5:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0104eb9:	80 fa 84             	cmp    $0x84,%dl
f0104ebc:	74 0b                	je     f0104ec9 <debuginfo_eip+0x15d>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104ebe:	80 fa 64             	cmp    $0x64,%dl
f0104ec1:	75 e8                	jne    f0104eab <debuginfo_eip+0x13f>
f0104ec3:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0104ec7:	74 e2                	je     f0104eab <debuginfo_eip+0x13f>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104ec9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104ecc:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104ecf:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104ed2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104ed5:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104ed8:	29 f8                	sub    %edi,%eax
f0104eda:	39 c2                	cmp    %eax,%edx
f0104edc:	73 04                	jae    f0104ee2 <debuginfo_eip+0x176>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104ede:	01 fa                	add    %edi,%edx
f0104ee0:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104ee2:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104ee5:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104ee8:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104eed:	39 cb                	cmp    %ecx,%ebx
f0104eef:	7d 43                	jge    f0104f34 <debuginfo_eip+0x1c8>
		for (lline = lfun + 1;
f0104ef1:	8d 53 01             	lea    0x1(%ebx),%edx
f0104ef4:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104ef7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104efa:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0104efd:	eb 07                	jmp    f0104f06 <debuginfo_eip+0x19a>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104eff:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0104f03:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104f06:	39 ca                	cmp    %ecx,%edx
f0104f08:	74 25                	je     f0104f2f <debuginfo_eip+0x1c3>
f0104f0a:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104f0d:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0104f11:	74 ec                	je     f0104eff <debuginfo_eip+0x193>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f13:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f18:	eb 1a                	jmp    f0104f34 <debuginfo_eip+0x1c8>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104f1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f1f:	eb 13                	jmp    f0104f34 <debuginfo_eip+0x1c8>
f0104f21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f26:	eb 0c                	jmp    f0104f34 <debuginfo_eip+0x1c8>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104f28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f2d:	eb 05                	jmp    f0104f34 <debuginfo_eip+0x1c8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104f34:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f37:	5b                   	pop    %ebx
f0104f38:	5e                   	pop    %esi
f0104f39:	5f                   	pop    %edi
f0104f3a:	5d                   	pop    %ebp
f0104f3b:	c3                   	ret    

f0104f3c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104f3c:	55                   	push   %ebp
f0104f3d:	89 e5                	mov    %esp,%ebp
f0104f3f:	57                   	push   %edi
f0104f40:	56                   	push   %esi
f0104f41:	53                   	push   %ebx
f0104f42:	83 ec 1c             	sub    $0x1c,%esp
f0104f45:	89 c7                	mov    %eax,%edi
f0104f47:	89 d6                	mov    %edx,%esi
f0104f49:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f4c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104f4f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f52:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104f55:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104f58:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104f5d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104f60:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104f63:	39 d3                	cmp    %edx,%ebx
f0104f65:	72 05                	jb     f0104f6c <printnum+0x30>
f0104f67:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104f6a:	77 45                	ja     f0104fb1 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104f6c:	83 ec 0c             	sub    $0xc,%esp
f0104f6f:	ff 75 18             	pushl  0x18(%ebp)
f0104f72:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f75:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104f78:	53                   	push   %ebx
f0104f79:	ff 75 10             	pushl  0x10(%ebp)
f0104f7c:	83 ec 08             	sub    $0x8,%esp
f0104f7f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104f82:	ff 75 e0             	pushl  -0x20(%ebp)
f0104f85:	ff 75 dc             	pushl  -0x24(%ebp)
f0104f88:	ff 75 d8             	pushl  -0x28(%ebp)
f0104f8b:	e8 f0 11 00 00       	call   f0106180 <__udivdi3>
f0104f90:	83 c4 18             	add    $0x18,%esp
f0104f93:	52                   	push   %edx
f0104f94:	50                   	push   %eax
f0104f95:	89 f2                	mov    %esi,%edx
f0104f97:	89 f8                	mov    %edi,%eax
f0104f99:	e8 9e ff ff ff       	call   f0104f3c <printnum>
f0104f9e:	83 c4 20             	add    $0x20,%esp
f0104fa1:	eb 18                	jmp    f0104fbb <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104fa3:	83 ec 08             	sub    $0x8,%esp
f0104fa6:	56                   	push   %esi
f0104fa7:	ff 75 18             	pushl  0x18(%ebp)
f0104faa:	ff d7                	call   *%edi
f0104fac:	83 c4 10             	add    $0x10,%esp
f0104faf:	eb 03                	jmp    f0104fb4 <printnum+0x78>
f0104fb1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104fb4:	83 eb 01             	sub    $0x1,%ebx
f0104fb7:	85 db                	test   %ebx,%ebx
f0104fb9:	7f e8                	jg     f0104fa3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104fbb:	83 ec 08             	sub    $0x8,%esp
f0104fbe:	56                   	push   %esi
f0104fbf:	83 ec 04             	sub    $0x4,%esp
f0104fc2:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104fc5:	ff 75 e0             	pushl  -0x20(%ebp)
f0104fc8:	ff 75 dc             	pushl  -0x24(%ebp)
f0104fcb:	ff 75 d8             	pushl  -0x28(%ebp)
f0104fce:	e8 dd 12 00 00       	call   f01062b0 <__umoddi3>
f0104fd3:	83 c4 14             	add    $0x14,%esp
f0104fd6:	0f be 80 0e 7c 10 f0 	movsbl -0xfef83f2(%eax),%eax
f0104fdd:	50                   	push   %eax
f0104fde:	ff d7                	call   *%edi
}
f0104fe0:	83 c4 10             	add    $0x10,%esp
f0104fe3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104fe6:	5b                   	pop    %ebx
f0104fe7:	5e                   	pop    %esi
f0104fe8:	5f                   	pop    %edi
f0104fe9:	5d                   	pop    %ebp
f0104fea:	c3                   	ret    

f0104feb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104feb:	55                   	push   %ebp
f0104fec:	89 e5                	mov    %esp,%ebp
f0104fee:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104ff1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104ff5:	8b 10                	mov    (%eax),%edx
f0104ff7:	3b 50 04             	cmp    0x4(%eax),%edx
f0104ffa:	73 0a                	jae    f0105006 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104ffc:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104fff:	89 08                	mov    %ecx,(%eax)
f0105001:	8b 45 08             	mov    0x8(%ebp),%eax
f0105004:	88 02                	mov    %al,(%edx)
}
f0105006:	5d                   	pop    %ebp
f0105007:	c3                   	ret    

f0105008 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105008:	55                   	push   %ebp
f0105009:	89 e5                	mov    %esp,%ebp
f010500b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010500e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105011:	50                   	push   %eax
f0105012:	ff 75 10             	pushl  0x10(%ebp)
f0105015:	ff 75 0c             	pushl  0xc(%ebp)
f0105018:	ff 75 08             	pushl  0x8(%ebp)
f010501b:	e8 05 00 00 00       	call   f0105025 <vprintfmt>
	va_end(ap);
}
f0105020:	83 c4 10             	add    $0x10,%esp
f0105023:	c9                   	leave  
f0105024:	c3                   	ret    

f0105025 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105025:	55                   	push   %ebp
f0105026:	89 e5                	mov    %esp,%ebp
f0105028:	57                   	push   %edi
f0105029:	56                   	push   %esi
f010502a:	53                   	push   %ebx
f010502b:	83 ec 2c             	sub    $0x2c,%esp
f010502e:	8b 75 08             	mov    0x8(%ebp),%esi
f0105031:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105034:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105037:	eb 12                	jmp    f010504b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105039:	85 c0                	test   %eax,%eax
f010503b:	0f 84 42 04 00 00    	je     f0105483 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
f0105041:	83 ec 08             	sub    $0x8,%esp
f0105044:	53                   	push   %ebx
f0105045:	50                   	push   %eax
f0105046:	ff d6                	call   *%esi
f0105048:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010504b:	83 c7 01             	add    $0x1,%edi
f010504e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105052:	83 f8 25             	cmp    $0x25,%eax
f0105055:	75 e2                	jne    f0105039 <vprintfmt+0x14>
f0105057:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f010505b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0105062:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105069:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0105070:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105075:	eb 07                	jmp    f010507e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105077:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f010507a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010507e:	8d 47 01             	lea    0x1(%edi),%eax
f0105081:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105084:	0f b6 07             	movzbl (%edi),%eax
f0105087:	0f b6 d0             	movzbl %al,%edx
f010508a:	83 e8 23             	sub    $0x23,%eax
f010508d:	3c 55                	cmp    $0x55,%al
f010508f:	0f 87 d3 03 00 00    	ja     f0105468 <vprintfmt+0x443>
f0105095:	0f b6 c0             	movzbl %al,%eax
f0105098:	ff 24 85 60 7d 10 f0 	jmp    *-0xfef82a0(,%eax,4)
f010509f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01050a2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01050a6:	eb d6                	jmp    f010507e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01050ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01050b0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01050b3:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01050b6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f01050ba:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f01050bd:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01050c0:	83 f9 09             	cmp    $0x9,%ecx
f01050c3:	77 3f                	ja     f0105104 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01050c5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01050c8:	eb e9                	jmp    f01050b3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01050ca:	8b 45 14             	mov    0x14(%ebp),%eax
f01050cd:	8b 00                	mov    (%eax),%eax
f01050cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01050d2:	8b 45 14             	mov    0x14(%ebp),%eax
f01050d5:	8d 40 04             	lea    0x4(%eax),%eax
f01050d8:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01050de:	eb 2a                	jmp    f010510a <vprintfmt+0xe5>
f01050e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01050e3:	85 c0                	test   %eax,%eax
f01050e5:	ba 00 00 00 00       	mov    $0x0,%edx
f01050ea:	0f 49 d0             	cmovns %eax,%edx
f01050ed:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01050f3:	eb 89                	jmp    f010507e <vprintfmt+0x59>
f01050f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01050f8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01050ff:	e9 7a ff ff ff       	jmp    f010507e <vprintfmt+0x59>
f0105104:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105107:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f010510a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010510e:	0f 89 6a ff ff ff    	jns    f010507e <vprintfmt+0x59>
				width = precision, precision = -1;
f0105114:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105117:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010511a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105121:	e9 58 ff ff ff       	jmp    f010507e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105126:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105129:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010512c:	e9 4d ff ff ff       	jmp    f010507e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105131:	8b 45 14             	mov    0x14(%ebp),%eax
f0105134:	8d 78 04             	lea    0x4(%eax),%edi
f0105137:	83 ec 08             	sub    $0x8,%esp
f010513a:	53                   	push   %ebx
f010513b:	ff 30                	pushl  (%eax)
f010513d:	ff d6                	call   *%esi
			break;
f010513f:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105142:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105145:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105148:	e9 fe fe ff ff       	jmp    f010504b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010514d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105150:	8d 78 04             	lea    0x4(%eax),%edi
f0105153:	8b 00                	mov    (%eax),%eax
f0105155:	99                   	cltd   
f0105156:	31 d0                	xor    %edx,%eax
f0105158:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010515a:	83 f8 0f             	cmp    $0xf,%eax
f010515d:	7f 0b                	jg     f010516a <vprintfmt+0x145>
f010515f:	8b 14 85 c0 7e 10 f0 	mov    -0xfef8140(,%eax,4),%edx
f0105166:	85 d2                	test   %edx,%edx
f0105168:	75 1b                	jne    f0105185 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
f010516a:	50                   	push   %eax
f010516b:	68 26 7c 10 f0       	push   $0xf0107c26
f0105170:	53                   	push   %ebx
f0105171:	56                   	push   %esi
f0105172:	e8 91 fe ff ff       	call   f0105008 <printfmt>
f0105177:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f010517a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010517d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105180:	e9 c6 fe ff ff       	jmp    f010504b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0105185:	52                   	push   %edx
f0105186:	68 84 69 10 f0       	push   $0xf0106984
f010518b:	53                   	push   %ebx
f010518c:	56                   	push   %esi
f010518d:	e8 76 fe ff ff       	call   f0105008 <printfmt>
f0105192:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105195:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105198:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010519b:	e9 ab fe ff ff       	jmp    f010504b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01051a0:	8b 45 14             	mov    0x14(%ebp),%eax
f01051a3:	83 c0 04             	add    $0x4,%eax
f01051a6:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01051a9:	8b 45 14             	mov    0x14(%ebp),%eax
f01051ac:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01051ae:	85 ff                	test   %edi,%edi
f01051b0:	b8 1f 7c 10 f0       	mov    $0xf0107c1f,%eax
f01051b5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f01051b8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01051bc:	0f 8e 94 00 00 00    	jle    f0105256 <vprintfmt+0x231>
f01051c2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01051c6:	0f 84 98 00 00 00    	je     f0105264 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
f01051cc:	83 ec 08             	sub    $0x8,%esp
f01051cf:	ff 75 d0             	pushl  -0x30(%ebp)
f01051d2:	57                   	push   %edi
f01051d3:	e8 24 04 00 00       	call   f01055fc <strnlen>
f01051d8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01051db:	29 c1                	sub    %eax,%ecx
f01051dd:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f01051e0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f01051e3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01051e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01051ea:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01051ed:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01051ef:	eb 0f                	jmp    f0105200 <vprintfmt+0x1db>
					putch(padc, putdat);
f01051f1:	83 ec 08             	sub    $0x8,%esp
f01051f4:	53                   	push   %ebx
f01051f5:	ff 75 e0             	pushl  -0x20(%ebp)
f01051f8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01051fa:	83 ef 01             	sub    $0x1,%edi
f01051fd:	83 c4 10             	add    $0x10,%esp
f0105200:	85 ff                	test   %edi,%edi
f0105202:	7f ed                	jg     f01051f1 <vprintfmt+0x1cc>
f0105204:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105207:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010520a:	85 c9                	test   %ecx,%ecx
f010520c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105211:	0f 49 c1             	cmovns %ecx,%eax
f0105214:	29 c1                	sub    %eax,%ecx
f0105216:	89 75 08             	mov    %esi,0x8(%ebp)
f0105219:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010521c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010521f:	89 cb                	mov    %ecx,%ebx
f0105221:	eb 4d                	jmp    f0105270 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105223:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105227:	74 1b                	je     f0105244 <vprintfmt+0x21f>
f0105229:	0f be c0             	movsbl %al,%eax
f010522c:	83 e8 20             	sub    $0x20,%eax
f010522f:	83 f8 5e             	cmp    $0x5e,%eax
f0105232:	76 10                	jbe    f0105244 <vprintfmt+0x21f>
					putch('?', putdat);
f0105234:	83 ec 08             	sub    $0x8,%esp
f0105237:	ff 75 0c             	pushl  0xc(%ebp)
f010523a:	6a 3f                	push   $0x3f
f010523c:	ff 55 08             	call   *0x8(%ebp)
f010523f:	83 c4 10             	add    $0x10,%esp
f0105242:	eb 0d                	jmp    f0105251 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
f0105244:	83 ec 08             	sub    $0x8,%esp
f0105247:	ff 75 0c             	pushl  0xc(%ebp)
f010524a:	52                   	push   %edx
f010524b:	ff 55 08             	call   *0x8(%ebp)
f010524e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105251:	83 eb 01             	sub    $0x1,%ebx
f0105254:	eb 1a                	jmp    f0105270 <vprintfmt+0x24b>
f0105256:	89 75 08             	mov    %esi,0x8(%ebp)
f0105259:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010525c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010525f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105262:	eb 0c                	jmp    f0105270 <vprintfmt+0x24b>
f0105264:	89 75 08             	mov    %esi,0x8(%ebp)
f0105267:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010526a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010526d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105270:	83 c7 01             	add    $0x1,%edi
f0105273:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105277:	0f be d0             	movsbl %al,%edx
f010527a:	85 d2                	test   %edx,%edx
f010527c:	74 23                	je     f01052a1 <vprintfmt+0x27c>
f010527e:	85 f6                	test   %esi,%esi
f0105280:	78 a1                	js     f0105223 <vprintfmt+0x1fe>
f0105282:	83 ee 01             	sub    $0x1,%esi
f0105285:	79 9c                	jns    f0105223 <vprintfmt+0x1fe>
f0105287:	89 df                	mov    %ebx,%edi
f0105289:	8b 75 08             	mov    0x8(%ebp),%esi
f010528c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010528f:	eb 18                	jmp    f01052a9 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105291:	83 ec 08             	sub    $0x8,%esp
f0105294:	53                   	push   %ebx
f0105295:	6a 20                	push   $0x20
f0105297:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105299:	83 ef 01             	sub    $0x1,%edi
f010529c:	83 c4 10             	add    $0x10,%esp
f010529f:	eb 08                	jmp    f01052a9 <vprintfmt+0x284>
f01052a1:	89 df                	mov    %ebx,%edi
f01052a3:	8b 75 08             	mov    0x8(%ebp),%esi
f01052a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01052a9:	85 ff                	test   %edi,%edi
f01052ab:	7f e4                	jg     f0105291 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01052ad:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01052b0:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01052b6:	e9 90 fd ff ff       	jmp    f010504b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01052bb:	83 f9 01             	cmp    $0x1,%ecx
f01052be:	7e 19                	jle    f01052d9 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
f01052c0:	8b 45 14             	mov    0x14(%ebp),%eax
f01052c3:	8b 50 04             	mov    0x4(%eax),%edx
f01052c6:	8b 00                	mov    (%eax),%eax
f01052c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01052cb:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01052ce:	8b 45 14             	mov    0x14(%ebp),%eax
f01052d1:	8d 40 08             	lea    0x8(%eax),%eax
f01052d4:	89 45 14             	mov    %eax,0x14(%ebp)
f01052d7:	eb 38                	jmp    f0105311 <vprintfmt+0x2ec>
	else if (lflag)
f01052d9:	85 c9                	test   %ecx,%ecx
f01052db:	74 1b                	je     f01052f8 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
f01052dd:	8b 45 14             	mov    0x14(%ebp),%eax
f01052e0:	8b 00                	mov    (%eax),%eax
f01052e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01052e5:	89 c1                	mov    %eax,%ecx
f01052e7:	c1 f9 1f             	sar    $0x1f,%ecx
f01052ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01052ed:	8b 45 14             	mov    0x14(%ebp),%eax
f01052f0:	8d 40 04             	lea    0x4(%eax),%eax
f01052f3:	89 45 14             	mov    %eax,0x14(%ebp)
f01052f6:	eb 19                	jmp    f0105311 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f01052f8:	8b 45 14             	mov    0x14(%ebp),%eax
f01052fb:	8b 00                	mov    (%eax),%eax
f01052fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105300:	89 c1                	mov    %eax,%ecx
f0105302:	c1 f9 1f             	sar    $0x1f,%ecx
f0105305:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105308:	8b 45 14             	mov    0x14(%ebp),%eax
f010530b:	8d 40 04             	lea    0x4(%eax),%eax
f010530e:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105311:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105314:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105317:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010531c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105320:	0f 89 0e 01 00 00    	jns    f0105434 <vprintfmt+0x40f>
				putch('-', putdat);
f0105326:	83 ec 08             	sub    $0x8,%esp
f0105329:	53                   	push   %ebx
f010532a:	6a 2d                	push   $0x2d
f010532c:	ff d6                	call   *%esi
				num = -(long long) num;
f010532e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105331:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105334:	f7 da                	neg    %edx
f0105336:	83 d1 00             	adc    $0x0,%ecx
f0105339:	f7 d9                	neg    %ecx
f010533b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010533e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105343:	e9 ec 00 00 00       	jmp    f0105434 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105348:	83 f9 01             	cmp    $0x1,%ecx
f010534b:	7e 18                	jle    f0105365 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
f010534d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105350:	8b 10                	mov    (%eax),%edx
f0105352:	8b 48 04             	mov    0x4(%eax),%ecx
f0105355:	8d 40 08             	lea    0x8(%eax),%eax
f0105358:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f010535b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105360:	e9 cf 00 00 00       	jmp    f0105434 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0105365:	85 c9                	test   %ecx,%ecx
f0105367:	74 1a                	je     f0105383 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
f0105369:	8b 45 14             	mov    0x14(%ebp),%eax
f010536c:	8b 10                	mov    (%eax),%edx
f010536e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105373:	8d 40 04             	lea    0x4(%eax),%eax
f0105376:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0105379:	b8 0a 00 00 00       	mov    $0xa,%eax
f010537e:	e9 b1 00 00 00       	jmp    f0105434 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
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
f0105398:	e9 97 00 00 00       	jmp    f0105434 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f010539d:	83 ec 08             	sub    $0x8,%esp
f01053a0:	53                   	push   %ebx
f01053a1:	6a 58                	push   $0x58
f01053a3:	ff d6                	call   *%esi
			putch('X', putdat);
f01053a5:	83 c4 08             	add    $0x8,%esp
f01053a8:	53                   	push   %ebx
f01053a9:	6a 58                	push   $0x58
f01053ab:	ff d6                	call   *%esi
			putch('X', putdat);
f01053ad:	83 c4 08             	add    $0x8,%esp
f01053b0:	53                   	push   %ebx
f01053b1:	6a 58                	push   $0x58
f01053b3:	ff d6                	call   *%esi
			break;
f01053b5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01053b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f01053bb:	e9 8b fc ff ff       	jmp    f010504b <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
f01053c0:	83 ec 08             	sub    $0x8,%esp
f01053c3:	53                   	push   %ebx
f01053c4:	6a 30                	push   $0x30
f01053c6:	ff d6                	call   *%esi
			putch('x', putdat);
f01053c8:	83 c4 08             	add    $0x8,%esp
f01053cb:	53                   	push   %ebx
f01053cc:	6a 78                	push   $0x78
f01053ce:	ff d6                	call   *%esi
			num = (unsigned long long)
f01053d0:	8b 45 14             	mov    0x14(%ebp),%eax
f01053d3:	8b 10                	mov    (%eax),%edx
f01053d5:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01053da:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01053dd:	8d 40 04             	lea    0x4(%eax),%eax
f01053e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01053e3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01053e8:	eb 4a                	jmp    f0105434 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01053ea:	83 f9 01             	cmp    $0x1,%ecx
f01053ed:	7e 15                	jle    f0105404 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
f01053ef:	8b 45 14             	mov    0x14(%ebp),%eax
f01053f2:	8b 10                	mov    (%eax),%edx
f01053f4:	8b 48 04             	mov    0x4(%eax),%ecx
f01053f7:	8d 40 08             	lea    0x8(%eax),%eax
f01053fa:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01053fd:	b8 10 00 00 00       	mov    $0x10,%eax
f0105402:	eb 30                	jmp    f0105434 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0105404:	85 c9                	test   %ecx,%ecx
f0105406:	74 17                	je     f010541f <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
f0105408:	8b 45 14             	mov    0x14(%ebp),%eax
f010540b:	8b 10                	mov    (%eax),%edx
f010540d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105412:	8d 40 04             	lea    0x4(%eax),%eax
f0105415:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0105418:	b8 10 00 00 00       	mov    $0x10,%eax
f010541d:	eb 15                	jmp    f0105434 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f010541f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105422:	8b 10                	mov    (%eax),%edx
f0105424:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105429:	8d 40 04             	lea    0x4(%eax),%eax
f010542c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f010542f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105434:	83 ec 0c             	sub    $0xc,%esp
f0105437:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f010543b:	57                   	push   %edi
f010543c:	ff 75 e0             	pushl  -0x20(%ebp)
f010543f:	50                   	push   %eax
f0105440:	51                   	push   %ecx
f0105441:	52                   	push   %edx
f0105442:	89 da                	mov    %ebx,%edx
f0105444:	89 f0                	mov    %esi,%eax
f0105446:	e8 f1 fa ff ff       	call   f0104f3c <printnum>
			break;
f010544b:	83 c4 20             	add    $0x20,%esp
f010544e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105451:	e9 f5 fb ff ff       	jmp    f010504b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105456:	83 ec 08             	sub    $0x8,%esp
f0105459:	53                   	push   %ebx
f010545a:	52                   	push   %edx
f010545b:	ff d6                	call   *%esi
			break;
f010545d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105460:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105463:	e9 e3 fb ff ff       	jmp    f010504b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105468:	83 ec 08             	sub    $0x8,%esp
f010546b:	53                   	push   %ebx
f010546c:	6a 25                	push   $0x25
f010546e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105470:	83 c4 10             	add    $0x10,%esp
f0105473:	eb 03                	jmp    f0105478 <vprintfmt+0x453>
f0105475:	83 ef 01             	sub    $0x1,%edi
f0105478:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010547c:	75 f7                	jne    f0105475 <vprintfmt+0x450>
f010547e:	e9 c8 fb ff ff       	jmp    f010504b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0105483:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105486:	5b                   	pop    %ebx
f0105487:	5e                   	pop    %esi
f0105488:	5f                   	pop    %edi
f0105489:	5d                   	pop    %ebp
f010548a:	c3                   	ret    

f010548b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010548b:	55                   	push   %ebp
f010548c:	89 e5                	mov    %esp,%ebp
f010548e:	83 ec 18             	sub    $0x18,%esp
f0105491:	8b 45 08             	mov    0x8(%ebp),%eax
f0105494:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105497:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010549a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010549e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01054a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01054a8:	85 c0                	test   %eax,%eax
f01054aa:	74 26                	je     f01054d2 <vsnprintf+0x47>
f01054ac:	85 d2                	test   %edx,%edx
f01054ae:	7e 22                	jle    f01054d2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01054b0:	ff 75 14             	pushl  0x14(%ebp)
f01054b3:	ff 75 10             	pushl  0x10(%ebp)
f01054b6:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01054b9:	50                   	push   %eax
f01054ba:	68 eb 4f 10 f0       	push   $0xf0104feb
f01054bf:	e8 61 fb ff ff       	call   f0105025 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01054c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01054c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01054ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01054cd:	83 c4 10             	add    $0x10,%esp
f01054d0:	eb 05                	jmp    f01054d7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01054d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01054d7:	c9                   	leave  
f01054d8:	c3                   	ret    

f01054d9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01054d9:	55                   	push   %ebp
f01054da:	89 e5                	mov    %esp,%ebp
f01054dc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01054df:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01054e2:	50                   	push   %eax
f01054e3:	ff 75 10             	pushl  0x10(%ebp)
f01054e6:	ff 75 0c             	pushl  0xc(%ebp)
f01054e9:	ff 75 08             	pushl  0x8(%ebp)
f01054ec:	e8 9a ff ff ff       	call   f010548b <vsnprintf>
	va_end(ap);

	return rc;
}
f01054f1:	c9                   	leave  
f01054f2:	c3                   	ret    

f01054f3 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01054f3:	55                   	push   %ebp
f01054f4:	89 e5                	mov    %esp,%ebp
f01054f6:	57                   	push   %edi
f01054f7:	56                   	push   %esi
f01054f8:	53                   	push   %ebx
f01054f9:	83 ec 0c             	sub    $0xc,%esp
f01054fc:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f01054ff:	85 c0                	test   %eax,%eax
f0105501:	74 11                	je     f0105514 <readline+0x21>
		cprintf("%s", prompt);
f0105503:	83 ec 08             	sub    $0x8,%esp
f0105506:	50                   	push   %eax
f0105507:	68 84 69 10 f0       	push   $0xf0106984
f010550c:	e8 21 e2 ff ff       	call   f0103732 <cprintf>
f0105511:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105514:	83 ec 0c             	sub    $0xc,%esp
f0105517:	6a 00                	push   $0x0
f0105519:	e8 85 b2 ff ff       	call   f01007a3 <iscons>
f010551e:	89 c7                	mov    %eax,%edi
f0105520:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0105523:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105528:	e8 65 b2 ff ff       	call   f0100792 <getchar>
f010552d:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010552f:	85 c0                	test   %eax,%eax
f0105531:	79 29                	jns    f010555c <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105533:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f0105538:	83 fb f8             	cmp    $0xfffffff8,%ebx
f010553b:	0f 84 9b 00 00 00    	je     f01055dc <readline+0xe9>
				cprintf("read error: %e\n", c);
f0105541:	83 ec 08             	sub    $0x8,%esp
f0105544:	53                   	push   %ebx
f0105545:	68 1f 7f 10 f0       	push   $0xf0107f1f
f010554a:	e8 e3 e1 ff ff       	call   f0103732 <cprintf>
f010554f:	83 c4 10             	add    $0x10,%esp
			return NULL;
f0105552:	b8 00 00 00 00       	mov    $0x0,%eax
f0105557:	e9 80 00 00 00       	jmp    f01055dc <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010555c:	83 f8 08             	cmp    $0x8,%eax
f010555f:	0f 94 c2             	sete   %dl
f0105562:	83 f8 7f             	cmp    $0x7f,%eax
f0105565:	0f 94 c0             	sete   %al
f0105568:	08 c2                	or     %al,%dl
f010556a:	74 1a                	je     f0105586 <readline+0x93>
f010556c:	85 f6                	test   %esi,%esi
f010556e:	7e 16                	jle    f0105586 <readline+0x93>
			if (echoing)
f0105570:	85 ff                	test   %edi,%edi
f0105572:	74 0d                	je     f0105581 <readline+0x8e>
				cputchar('\b');
f0105574:	83 ec 0c             	sub    $0xc,%esp
f0105577:	6a 08                	push   $0x8
f0105579:	e8 04 b2 ff ff       	call   f0100782 <cputchar>
f010557e:	83 c4 10             	add    $0x10,%esp
			i--;
f0105581:	83 ee 01             	sub    $0x1,%esi
f0105584:	eb a2                	jmp    f0105528 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105586:	83 fb 1f             	cmp    $0x1f,%ebx
f0105589:	7e 26                	jle    f01055b1 <readline+0xbe>
f010558b:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105591:	7f 1e                	jg     f01055b1 <readline+0xbe>
			if (echoing)
f0105593:	85 ff                	test   %edi,%edi
f0105595:	74 0c                	je     f01055a3 <readline+0xb0>
				cputchar(c);
f0105597:	83 ec 0c             	sub    $0xc,%esp
f010559a:	53                   	push   %ebx
f010559b:	e8 e2 b1 ff ff       	call   f0100782 <cputchar>
f01055a0:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01055a3:	88 9e 80 1a 21 f0    	mov    %bl,-0xfdee580(%esi)
f01055a9:	8d 76 01             	lea    0x1(%esi),%esi
f01055ac:	e9 77 ff ff ff       	jmp    f0105528 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01055b1:	83 fb 0a             	cmp    $0xa,%ebx
f01055b4:	74 09                	je     f01055bf <readline+0xcc>
f01055b6:	83 fb 0d             	cmp    $0xd,%ebx
f01055b9:	0f 85 69 ff ff ff    	jne    f0105528 <readline+0x35>
			if (echoing)
f01055bf:	85 ff                	test   %edi,%edi
f01055c1:	74 0d                	je     f01055d0 <readline+0xdd>
				cputchar('\n');
f01055c3:	83 ec 0c             	sub    $0xc,%esp
f01055c6:	6a 0a                	push   $0xa
f01055c8:	e8 b5 b1 ff ff       	call   f0100782 <cputchar>
f01055cd:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01055d0:	c6 86 80 1a 21 f0 00 	movb   $0x0,-0xfdee580(%esi)
			return buf;
f01055d7:	b8 80 1a 21 f0       	mov    $0xf0211a80,%eax
		}
	}
}
f01055dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01055df:	5b                   	pop    %ebx
f01055e0:	5e                   	pop    %esi
f01055e1:	5f                   	pop    %edi
f01055e2:	5d                   	pop    %ebp
f01055e3:	c3                   	ret    

f01055e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01055e4:	55                   	push   %ebp
f01055e5:	89 e5                	mov    %esp,%ebp
f01055e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01055ea:	b8 00 00 00 00       	mov    $0x0,%eax
f01055ef:	eb 03                	jmp    f01055f4 <strlen+0x10>
		n++;
f01055f1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01055f4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01055f8:	75 f7                	jne    f01055f1 <strlen+0xd>
		n++;
	return n;
}
f01055fa:	5d                   	pop    %ebp
f01055fb:	c3                   	ret    

f01055fc <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01055fc:	55                   	push   %ebp
f01055fd:	89 e5                	mov    %esp,%ebp
f01055ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105602:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105605:	ba 00 00 00 00       	mov    $0x0,%edx
f010560a:	eb 03                	jmp    f010560f <strnlen+0x13>
		n++;
f010560c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010560f:	39 c2                	cmp    %eax,%edx
f0105611:	74 08                	je     f010561b <strnlen+0x1f>
f0105613:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105617:	75 f3                	jne    f010560c <strnlen+0x10>
f0105619:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010561b:	5d                   	pop    %ebp
f010561c:	c3                   	ret    

f010561d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010561d:	55                   	push   %ebp
f010561e:	89 e5                	mov    %esp,%ebp
f0105620:	53                   	push   %ebx
f0105621:	8b 45 08             	mov    0x8(%ebp),%eax
f0105624:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105627:	89 c2                	mov    %eax,%edx
f0105629:	83 c2 01             	add    $0x1,%edx
f010562c:	83 c1 01             	add    $0x1,%ecx
f010562f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105633:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105636:	84 db                	test   %bl,%bl
f0105638:	75 ef                	jne    f0105629 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010563a:	5b                   	pop    %ebx
f010563b:	5d                   	pop    %ebp
f010563c:	c3                   	ret    

f010563d <strcat>:

char *
strcat(char *dst, const char *src)
{
f010563d:	55                   	push   %ebp
f010563e:	89 e5                	mov    %esp,%ebp
f0105640:	53                   	push   %ebx
f0105641:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105644:	53                   	push   %ebx
f0105645:	e8 9a ff ff ff       	call   f01055e4 <strlen>
f010564a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010564d:	ff 75 0c             	pushl  0xc(%ebp)
f0105650:	01 d8                	add    %ebx,%eax
f0105652:	50                   	push   %eax
f0105653:	e8 c5 ff ff ff       	call   f010561d <strcpy>
	return dst;
}
f0105658:	89 d8                	mov    %ebx,%eax
f010565a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010565d:	c9                   	leave  
f010565e:	c3                   	ret    

f010565f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010565f:	55                   	push   %ebp
f0105660:	89 e5                	mov    %esp,%ebp
f0105662:	56                   	push   %esi
f0105663:	53                   	push   %ebx
f0105664:	8b 75 08             	mov    0x8(%ebp),%esi
f0105667:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010566a:	89 f3                	mov    %esi,%ebx
f010566c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010566f:	89 f2                	mov    %esi,%edx
f0105671:	eb 0f                	jmp    f0105682 <strncpy+0x23>
		*dst++ = *src;
f0105673:	83 c2 01             	add    $0x1,%edx
f0105676:	0f b6 01             	movzbl (%ecx),%eax
f0105679:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010567c:	80 39 01             	cmpb   $0x1,(%ecx)
f010567f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105682:	39 da                	cmp    %ebx,%edx
f0105684:	75 ed                	jne    f0105673 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105686:	89 f0                	mov    %esi,%eax
f0105688:	5b                   	pop    %ebx
f0105689:	5e                   	pop    %esi
f010568a:	5d                   	pop    %ebp
f010568b:	c3                   	ret    

f010568c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010568c:	55                   	push   %ebp
f010568d:	89 e5                	mov    %esp,%ebp
f010568f:	56                   	push   %esi
f0105690:	53                   	push   %ebx
f0105691:	8b 75 08             	mov    0x8(%ebp),%esi
f0105694:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105697:	8b 55 10             	mov    0x10(%ebp),%edx
f010569a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010569c:	85 d2                	test   %edx,%edx
f010569e:	74 21                	je     f01056c1 <strlcpy+0x35>
f01056a0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01056a4:	89 f2                	mov    %esi,%edx
f01056a6:	eb 09                	jmp    f01056b1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01056a8:	83 c2 01             	add    $0x1,%edx
f01056ab:	83 c1 01             	add    $0x1,%ecx
f01056ae:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01056b1:	39 c2                	cmp    %eax,%edx
f01056b3:	74 09                	je     f01056be <strlcpy+0x32>
f01056b5:	0f b6 19             	movzbl (%ecx),%ebx
f01056b8:	84 db                	test   %bl,%bl
f01056ba:	75 ec                	jne    f01056a8 <strlcpy+0x1c>
f01056bc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01056be:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01056c1:	29 f0                	sub    %esi,%eax
}
f01056c3:	5b                   	pop    %ebx
f01056c4:	5e                   	pop    %esi
f01056c5:	5d                   	pop    %ebp
f01056c6:	c3                   	ret    

f01056c7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01056c7:	55                   	push   %ebp
f01056c8:	89 e5                	mov    %esp,%ebp
f01056ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01056cd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01056d0:	eb 06                	jmp    f01056d8 <strcmp+0x11>
		p++, q++;
f01056d2:	83 c1 01             	add    $0x1,%ecx
f01056d5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01056d8:	0f b6 01             	movzbl (%ecx),%eax
f01056db:	84 c0                	test   %al,%al
f01056dd:	74 04                	je     f01056e3 <strcmp+0x1c>
f01056df:	3a 02                	cmp    (%edx),%al
f01056e1:	74 ef                	je     f01056d2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01056e3:	0f b6 c0             	movzbl %al,%eax
f01056e6:	0f b6 12             	movzbl (%edx),%edx
f01056e9:	29 d0                	sub    %edx,%eax
}
f01056eb:	5d                   	pop    %ebp
f01056ec:	c3                   	ret    

f01056ed <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01056ed:	55                   	push   %ebp
f01056ee:	89 e5                	mov    %esp,%ebp
f01056f0:	53                   	push   %ebx
f01056f1:	8b 45 08             	mov    0x8(%ebp),%eax
f01056f4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01056f7:	89 c3                	mov    %eax,%ebx
f01056f9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01056fc:	eb 06                	jmp    f0105704 <strncmp+0x17>
		n--, p++, q++;
f01056fe:	83 c0 01             	add    $0x1,%eax
f0105701:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105704:	39 d8                	cmp    %ebx,%eax
f0105706:	74 15                	je     f010571d <strncmp+0x30>
f0105708:	0f b6 08             	movzbl (%eax),%ecx
f010570b:	84 c9                	test   %cl,%cl
f010570d:	74 04                	je     f0105713 <strncmp+0x26>
f010570f:	3a 0a                	cmp    (%edx),%cl
f0105711:	74 eb                	je     f01056fe <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105713:	0f b6 00             	movzbl (%eax),%eax
f0105716:	0f b6 12             	movzbl (%edx),%edx
f0105719:	29 d0                	sub    %edx,%eax
f010571b:	eb 05                	jmp    f0105722 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010571d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105722:	5b                   	pop    %ebx
f0105723:	5d                   	pop    %ebp
f0105724:	c3                   	ret    

f0105725 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105725:	55                   	push   %ebp
f0105726:	89 e5                	mov    %esp,%ebp
f0105728:	8b 45 08             	mov    0x8(%ebp),%eax
f010572b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010572f:	eb 07                	jmp    f0105738 <strchr+0x13>
		if (*s == c)
f0105731:	38 ca                	cmp    %cl,%dl
f0105733:	74 0f                	je     f0105744 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105735:	83 c0 01             	add    $0x1,%eax
f0105738:	0f b6 10             	movzbl (%eax),%edx
f010573b:	84 d2                	test   %dl,%dl
f010573d:	75 f2                	jne    f0105731 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f010573f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105744:	5d                   	pop    %ebp
f0105745:	c3                   	ret    

f0105746 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105746:	55                   	push   %ebp
f0105747:	89 e5                	mov    %esp,%ebp
f0105749:	8b 45 08             	mov    0x8(%ebp),%eax
f010574c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105750:	eb 03                	jmp    f0105755 <strfind+0xf>
f0105752:	83 c0 01             	add    $0x1,%eax
f0105755:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105758:	38 ca                	cmp    %cl,%dl
f010575a:	74 04                	je     f0105760 <strfind+0x1a>
f010575c:	84 d2                	test   %dl,%dl
f010575e:	75 f2                	jne    f0105752 <strfind+0xc>
			break;
	return (char *) s;
}
f0105760:	5d                   	pop    %ebp
f0105761:	c3                   	ret    

f0105762 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105762:	55                   	push   %ebp
f0105763:	89 e5                	mov    %esp,%ebp
f0105765:	57                   	push   %edi
f0105766:	56                   	push   %esi
f0105767:	53                   	push   %ebx
f0105768:	8b 7d 08             	mov    0x8(%ebp),%edi
f010576b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010576e:	85 c9                	test   %ecx,%ecx
f0105770:	74 36                	je     f01057a8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105772:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105778:	75 28                	jne    f01057a2 <memset+0x40>
f010577a:	f6 c1 03             	test   $0x3,%cl
f010577d:	75 23                	jne    f01057a2 <memset+0x40>
		c &= 0xFF;
f010577f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105783:	89 d3                	mov    %edx,%ebx
f0105785:	c1 e3 08             	shl    $0x8,%ebx
f0105788:	89 d6                	mov    %edx,%esi
f010578a:	c1 e6 18             	shl    $0x18,%esi
f010578d:	89 d0                	mov    %edx,%eax
f010578f:	c1 e0 10             	shl    $0x10,%eax
f0105792:	09 f0                	or     %esi,%eax
f0105794:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105796:	89 d8                	mov    %ebx,%eax
f0105798:	09 d0                	or     %edx,%eax
f010579a:	c1 e9 02             	shr    $0x2,%ecx
f010579d:	fc                   	cld    
f010579e:	f3 ab                	rep stos %eax,%es:(%edi)
f01057a0:	eb 06                	jmp    f01057a8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01057a2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01057a5:	fc                   	cld    
f01057a6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01057a8:	89 f8                	mov    %edi,%eax
f01057aa:	5b                   	pop    %ebx
f01057ab:	5e                   	pop    %esi
f01057ac:	5f                   	pop    %edi
f01057ad:	5d                   	pop    %ebp
f01057ae:	c3                   	ret    

f01057af <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01057af:	55                   	push   %ebp
f01057b0:	89 e5                	mov    %esp,%ebp
f01057b2:	57                   	push   %edi
f01057b3:	56                   	push   %esi
f01057b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01057b7:	8b 75 0c             	mov    0xc(%ebp),%esi
f01057ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01057bd:	39 c6                	cmp    %eax,%esi
f01057bf:	73 35                	jae    f01057f6 <memmove+0x47>
f01057c1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01057c4:	39 d0                	cmp    %edx,%eax
f01057c6:	73 2e                	jae    f01057f6 <memmove+0x47>
		s += n;
		d += n;
f01057c8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057cb:	89 d6                	mov    %edx,%esi
f01057cd:	09 fe                	or     %edi,%esi
f01057cf:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01057d5:	75 13                	jne    f01057ea <memmove+0x3b>
f01057d7:	f6 c1 03             	test   $0x3,%cl
f01057da:	75 0e                	jne    f01057ea <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01057dc:	83 ef 04             	sub    $0x4,%edi
f01057df:	8d 72 fc             	lea    -0x4(%edx),%esi
f01057e2:	c1 e9 02             	shr    $0x2,%ecx
f01057e5:	fd                   	std    
f01057e6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01057e8:	eb 09                	jmp    f01057f3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01057ea:	83 ef 01             	sub    $0x1,%edi
f01057ed:	8d 72 ff             	lea    -0x1(%edx),%esi
f01057f0:	fd                   	std    
f01057f1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01057f3:	fc                   	cld    
f01057f4:	eb 1d                	jmp    f0105813 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057f6:	89 f2                	mov    %esi,%edx
f01057f8:	09 c2                	or     %eax,%edx
f01057fa:	f6 c2 03             	test   $0x3,%dl
f01057fd:	75 0f                	jne    f010580e <memmove+0x5f>
f01057ff:	f6 c1 03             	test   $0x3,%cl
f0105802:	75 0a                	jne    f010580e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105804:	c1 e9 02             	shr    $0x2,%ecx
f0105807:	89 c7                	mov    %eax,%edi
f0105809:	fc                   	cld    
f010580a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010580c:	eb 05                	jmp    f0105813 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010580e:	89 c7                	mov    %eax,%edi
f0105810:	fc                   	cld    
f0105811:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105813:	5e                   	pop    %esi
f0105814:	5f                   	pop    %edi
f0105815:	5d                   	pop    %ebp
f0105816:	c3                   	ret    

f0105817 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105817:	55                   	push   %ebp
f0105818:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010581a:	ff 75 10             	pushl  0x10(%ebp)
f010581d:	ff 75 0c             	pushl  0xc(%ebp)
f0105820:	ff 75 08             	pushl  0x8(%ebp)
f0105823:	e8 87 ff ff ff       	call   f01057af <memmove>
}
f0105828:	c9                   	leave  
f0105829:	c3                   	ret    

f010582a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010582a:	55                   	push   %ebp
f010582b:	89 e5                	mov    %esp,%ebp
f010582d:	56                   	push   %esi
f010582e:	53                   	push   %ebx
f010582f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105832:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105835:	89 c6                	mov    %eax,%esi
f0105837:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010583a:	eb 1a                	jmp    f0105856 <memcmp+0x2c>
		if (*s1 != *s2)
f010583c:	0f b6 08             	movzbl (%eax),%ecx
f010583f:	0f b6 1a             	movzbl (%edx),%ebx
f0105842:	38 d9                	cmp    %bl,%cl
f0105844:	74 0a                	je     f0105850 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105846:	0f b6 c1             	movzbl %cl,%eax
f0105849:	0f b6 db             	movzbl %bl,%ebx
f010584c:	29 d8                	sub    %ebx,%eax
f010584e:	eb 0f                	jmp    f010585f <memcmp+0x35>
		s1++, s2++;
f0105850:	83 c0 01             	add    $0x1,%eax
f0105853:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105856:	39 f0                	cmp    %esi,%eax
f0105858:	75 e2                	jne    f010583c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010585a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010585f:	5b                   	pop    %ebx
f0105860:	5e                   	pop    %esi
f0105861:	5d                   	pop    %ebp
f0105862:	c3                   	ret    

f0105863 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105863:	55                   	push   %ebp
f0105864:	89 e5                	mov    %esp,%ebp
f0105866:	53                   	push   %ebx
f0105867:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010586a:	89 c1                	mov    %eax,%ecx
f010586c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f010586f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105873:	eb 0a                	jmp    f010587f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105875:	0f b6 10             	movzbl (%eax),%edx
f0105878:	39 da                	cmp    %ebx,%edx
f010587a:	74 07                	je     f0105883 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010587c:	83 c0 01             	add    $0x1,%eax
f010587f:	39 c8                	cmp    %ecx,%eax
f0105881:	72 f2                	jb     f0105875 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105883:	5b                   	pop    %ebx
f0105884:	5d                   	pop    %ebp
f0105885:	c3                   	ret    

f0105886 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105886:	55                   	push   %ebp
f0105887:	89 e5                	mov    %esp,%ebp
f0105889:	57                   	push   %edi
f010588a:	56                   	push   %esi
f010588b:	53                   	push   %ebx
f010588c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010588f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105892:	eb 03                	jmp    f0105897 <strtol+0x11>
		s++;
f0105894:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105897:	0f b6 01             	movzbl (%ecx),%eax
f010589a:	3c 20                	cmp    $0x20,%al
f010589c:	74 f6                	je     f0105894 <strtol+0xe>
f010589e:	3c 09                	cmp    $0x9,%al
f01058a0:	74 f2                	je     f0105894 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01058a2:	3c 2b                	cmp    $0x2b,%al
f01058a4:	75 0a                	jne    f01058b0 <strtol+0x2a>
		s++;
f01058a6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01058a9:	bf 00 00 00 00       	mov    $0x0,%edi
f01058ae:	eb 11                	jmp    f01058c1 <strtol+0x3b>
f01058b0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01058b5:	3c 2d                	cmp    $0x2d,%al
f01058b7:	75 08                	jne    f01058c1 <strtol+0x3b>
		s++, neg = 1;
f01058b9:	83 c1 01             	add    $0x1,%ecx
f01058bc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01058c1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01058c7:	75 15                	jne    f01058de <strtol+0x58>
f01058c9:	80 39 30             	cmpb   $0x30,(%ecx)
f01058cc:	75 10                	jne    f01058de <strtol+0x58>
f01058ce:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01058d2:	75 7c                	jne    f0105950 <strtol+0xca>
		s += 2, base = 16;
f01058d4:	83 c1 02             	add    $0x2,%ecx
f01058d7:	bb 10 00 00 00       	mov    $0x10,%ebx
f01058dc:	eb 16                	jmp    f01058f4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01058de:	85 db                	test   %ebx,%ebx
f01058e0:	75 12                	jne    f01058f4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01058e2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01058e7:	80 39 30             	cmpb   $0x30,(%ecx)
f01058ea:	75 08                	jne    f01058f4 <strtol+0x6e>
		s++, base = 8;
f01058ec:	83 c1 01             	add    $0x1,%ecx
f01058ef:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01058f4:	b8 00 00 00 00       	mov    $0x0,%eax
f01058f9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01058fc:	0f b6 11             	movzbl (%ecx),%edx
f01058ff:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105902:	89 f3                	mov    %esi,%ebx
f0105904:	80 fb 09             	cmp    $0x9,%bl
f0105907:	77 08                	ja     f0105911 <strtol+0x8b>
			dig = *s - '0';
f0105909:	0f be d2             	movsbl %dl,%edx
f010590c:	83 ea 30             	sub    $0x30,%edx
f010590f:	eb 22                	jmp    f0105933 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105911:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105914:	89 f3                	mov    %esi,%ebx
f0105916:	80 fb 19             	cmp    $0x19,%bl
f0105919:	77 08                	ja     f0105923 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010591b:	0f be d2             	movsbl %dl,%edx
f010591e:	83 ea 57             	sub    $0x57,%edx
f0105921:	eb 10                	jmp    f0105933 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0105923:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105926:	89 f3                	mov    %esi,%ebx
f0105928:	80 fb 19             	cmp    $0x19,%bl
f010592b:	77 16                	ja     f0105943 <strtol+0xbd>
			dig = *s - 'A' + 10;
f010592d:	0f be d2             	movsbl %dl,%edx
f0105930:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105933:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105936:	7d 0b                	jge    f0105943 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0105938:	83 c1 01             	add    $0x1,%ecx
f010593b:	0f af 45 10          	imul   0x10(%ebp),%eax
f010593f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105941:	eb b9                	jmp    f01058fc <strtol+0x76>

	if (endptr)
f0105943:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105947:	74 0d                	je     f0105956 <strtol+0xd0>
		*endptr = (char *) s;
f0105949:	8b 75 0c             	mov    0xc(%ebp),%esi
f010594c:	89 0e                	mov    %ecx,(%esi)
f010594e:	eb 06                	jmp    f0105956 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105950:	85 db                	test   %ebx,%ebx
f0105952:	74 98                	je     f01058ec <strtol+0x66>
f0105954:	eb 9e                	jmp    f01058f4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105956:	89 c2                	mov    %eax,%edx
f0105958:	f7 da                	neg    %edx
f010595a:	85 ff                	test   %edi,%edi
f010595c:	0f 45 c2             	cmovne %edx,%eax
}
f010595f:	5b                   	pop    %ebx
f0105960:	5e                   	pop    %esi
f0105961:	5f                   	pop    %edi
f0105962:	5d                   	pop    %ebp
f0105963:	c3                   	ret    

f0105964 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105964:	fa                   	cli    

	xorw    %ax, %ax
f0105965:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105967:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105969:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010596b:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f010596d:	0f 01 16             	lgdtl  (%esi)
f0105970:	74 70                	je     f01059e2 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105972:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105975:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105979:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f010597c:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105982:	08 00                	or     %al,(%eax)

f0105984 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105984:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105988:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010598a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010598c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010598e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105992:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105994:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105996:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f010599b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010599e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01059a1:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01059a6:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01059a9:	8b 25 84 1e 21 f0    	mov    0xf0211e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01059af:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01059b4:	b8 b0 01 10 f0       	mov    $0xf01001b0,%eax
	call    *%eax
f01059b9:	ff d0                	call   *%eax

f01059bb <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01059bb:	eb fe                	jmp    f01059bb <spin>
f01059bd:	8d 76 00             	lea    0x0(%esi),%esi

f01059c0 <gdt>:
	...
f01059c8:	ff                   	(bad)  
f01059c9:	ff 00                	incl   (%eax)
f01059cb:	00 00                	add    %al,(%eax)
f01059cd:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01059d4:	00                   	.byte 0x0
f01059d5:	92                   	xchg   %eax,%edx
f01059d6:	cf                   	iret   
	...

f01059d8 <gdtdesc>:
f01059d8:	17                   	pop    %ss
f01059d9:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01059de <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01059de:	90                   	nop

f01059df <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01059df:	55                   	push   %ebp
f01059e0:	89 e5                	mov    %esp,%ebp
f01059e2:	57                   	push   %edi
f01059e3:	56                   	push   %esi
f01059e4:	53                   	push   %ebx
f01059e5:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01059e8:	8b 0d 88 1e 21 f0    	mov    0xf0211e88,%ecx
f01059ee:	89 c3                	mov    %eax,%ebx
f01059f0:	c1 eb 0c             	shr    $0xc,%ebx
f01059f3:	39 cb                	cmp    %ecx,%ebx
f01059f5:	72 12                	jb     f0105a09 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01059f7:	50                   	push   %eax
f01059f8:	68 44 64 10 f0       	push   $0xf0106444
f01059fd:	6a 5d                	push   $0x5d
f01059ff:	68 bd 80 10 f0       	push   $0xf01080bd
f0105a04:	e8 37 a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105a09:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105a0f:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a11:	89 c2                	mov    %eax,%edx
f0105a13:	c1 ea 0c             	shr    $0xc,%edx
f0105a16:	39 ca                	cmp    %ecx,%edx
f0105a18:	72 12                	jb     f0105a2c <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a1a:	50                   	push   %eax
f0105a1b:	68 44 64 10 f0       	push   $0xf0106444
f0105a20:	6a 5d                	push   $0x5d
f0105a22:	68 bd 80 10 f0       	push   $0xf01080bd
f0105a27:	e8 14 a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105a2c:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105a32:	eb 2f                	jmp    f0105a63 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105a34:	83 ec 04             	sub    $0x4,%esp
f0105a37:	6a 04                	push   $0x4
f0105a39:	68 cd 80 10 f0       	push   $0xf01080cd
f0105a3e:	53                   	push   %ebx
f0105a3f:	e8 e6 fd ff ff       	call   f010582a <memcmp>
f0105a44:	83 c4 10             	add    $0x10,%esp
f0105a47:	85 c0                	test   %eax,%eax
f0105a49:	75 15                	jne    f0105a60 <mpsearch1+0x81>
f0105a4b:	89 da                	mov    %ebx,%edx
f0105a4d:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105a50:	0f b6 0a             	movzbl (%edx),%ecx
f0105a53:	01 c8                	add    %ecx,%eax
f0105a55:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a58:	39 d7                	cmp    %edx,%edi
f0105a5a:	75 f4                	jne    f0105a50 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105a5c:	84 c0                	test   %al,%al
f0105a5e:	74 0e                	je     f0105a6e <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105a60:	83 c3 10             	add    $0x10,%ebx
f0105a63:	39 f3                	cmp    %esi,%ebx
f0105a65:	72 cd                	jb     f0105a34 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105a67:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a6c:	eb 02                	jmp    f0105a70 <mpsearch1+0x91>
f0105a6e:	89 d8                	mov    %ebx,%eax
}
f0105a70:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105a73:	5b                   	pop    %ebx
f0105a74:	5e                   	pop    %esi
f0105a75:	5f                   	pop    %edi
f0105a76:	5d                   	pop    %ebp
f0105a77:	c3                   	ret    

f0105a78 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105a78:	55                   	push   %ebp
f0105a79:	89 e5                	mov    %esp,%ebp
f0105a7b:	57                   	push   %edi
f0105a7c:	56                   	push   %esi
f0105a7d:	53                   	push   %ebx
f0105a7e:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105a81:	c7 05 c0 23 21 f0 20 	movl   $0xf0212020,0xf02123c0
f0105a88:	20 21 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a8b:	83 3d 88 1e 21 f0 00 	cmpl   $0x0,0xf0211e88
f0105a92:	75 16                	jne    f0105aaa <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a94:	68 00 04 00 00       	push   $0x400
f0105a99:	68 44 64 10 f0       	push   $0xf0106444
f0105a9e:	6a 75                	push   $0x75
f0105aa0:	68 bd 80 10 f0       	push   $0xf01080bd
f0105aa5:	e8 96 a5 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105aaa:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105ab1:	85 c0                	test   %eax,%eax
f0105ab3:	74 16                	je     f0105acb <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105ab5:	c1 e0 04             	shl    $0x4,%eax
f0105ab8:	ba 00 04 00 00       	mov    $0x400,%edx
f0105abd:	e8 1d ff ff ff       	call   f01059df <mpsearch1>
f0105ac2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105ac5:	85 c0                	test   %eax,%eax
f0105ac7:	75 3c                	jne    f0105b05 <mp_init+0x8d>
f0105ac9:	eb 20                	jmp    f0105aeb <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105acb:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105ad2:	c1 e0 0a             	shl    $0xa,%eax
f0105ad5:	2d 00 04 00 00       	sub    $0x400,%eax
f0105ada:	ba 00 04 00 00       	mov    $0x400,%edx
f0105adf:	e8 fb fe ff ff       	call   f01059df <mpsearch1>
f0105ae4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105ae7:	85 c0                	test   %eax,%eax
f0105ae9:	75 1a                	jne    f0105b05 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105aeb:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105af0:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105af5:	e8 e5 fe ff ff       	call   f01059df <mpsearch1>
f0105afa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105afd:	85 c0                	test   %eax,%eax
f0105aff:	0f 84 5d 02 00 00    	je     f0105d62 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105b05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b08:	8b 70 04             	mov    0x4(%eax),%esi
f0105b0b:	85 f6                	test   %esi,%esi
f0105b0d:	74 06                	je     f0105b15 <mp_init+0x9d>
f0105b0f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105b13:	74 15                	je     f0105b2a <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105b15:	83 ec 0c             	sub    $0xc,%esp
f0105b18:	68 30 7f 10 f0       	push   $0xf0107f30
f0105b1d:	e8 10 dc ff ff       	call   f0103732 <cprintf>
f0105b22:	83 c4 10             	add    $0x10,%esp
f0105b25:	e9 38 02 00 00       	jmp    f0105d62 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105b2a:	89 f0                	mov    %esi,%eax
f0105b2c:	c1 e8 0c             	shr    $0xc,%eax
f0105b2f:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f0105b35:	72 15                	jb     f0105b4c <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b37:	56                   	push   %esi
f0105b38:	68 44 64 10 f0       	push   $0xf0106444
f0105b3d:	68 96 00 00 00       	push   $0x96
f0105b42:	68 bd 80 10 f0       	push   $0xf01080bd
f0105b47:	e8 f4 a4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105b4c:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105b52:	83 ec 04             	sub    $0x4,%esp
f0105b55:	6a 04                	push   $0x4
f0105b57:	68 d2 80 10 f0       	push   $0xf01080d2
f0105b5c:	53                   	push   %ebx
f0105b5d:	e8 c8 fc ff ff       	call   f010582a <memcmp>
f0105b62:	83 c4 10             	add    $0x10,%esp
f0105b65:	85 c0                	test   %eax,%eax
f0105b67:	74 15                	je     f0105b7e <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105b69:	83 ec 0c             	sub    $0xc,%esp
f0105b6c:	68 60 7f 10 f0       	push   $0xf0107f60
f0105b71:	e8 bc db ff ff       	call   f0103732 <cprintf>
f0105b76:	83 c4 10             	add    $0x10,%esp
f0105b79:	e9 e4 01 00 00       	jmp    f0105d62 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105b7e:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105b82:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105b86:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105b89:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105b8e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b93:	eb 0d                	jmp    f0105ba2 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105b95:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105b9c:	f0 
f0105b9d:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105b9f:	83 c0 01             	add    $0x1,%eax
f0105ba2:	39 c7                	cmp    %eax,%edi
f0105ba4:	75 ef                	jne    f0105b95 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105ba6:	84 d2                	test   %dl,%dl
f0105ba8:	74 15                	je     f0105bbf <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105baa:	83 ec 0c             	sub    $0xc,%esp
f0105bad:	68 94 7f 10 f0       	push   $0xf0107f94
f0105bb2:	e8 7b db ff ff       	call   f0103732 <cprintf>
f0105bb7:	83 c4 10             	add    $0x10,%esp
f0105bba:	e9 a3 01 00 00       	jmp    f0105d62 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105bbf:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105bc3:	3c 01                	cmp    $0x1,%al
f0105bc5:	74 1d                	je     f0105be4 <mp_init+0x16c>
f0105bc7:	3c 04                	cmp    $0x4,%al
f0105bc9:	74 19                	je     f0105be4 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105bcb:	83 ec 08             	sub    $0x8,%esp
f0105bce:	0f b6 c0             	movzbl %al,%eax
f0105bd1:	50                   	push   %eax
f0105bd2:	68 b8 7f 10 f0       	push   $0xf0107fb8
f0105bd7:	e8 56 db ff ff       	call   f0103732 <cprintf>
f0105bdc:	83 c4 10             	add    $0x10,%esp
f0105bdf:	e9 7e 01 00 00       	jmp    f0105d62 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105be4:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105be8:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105bec:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105bf1:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105bf6:	01 ce                	add    %ecx,%esi
f0105bf8:	eb 0d                	jmp    f0105c07 <mp_init+0x18f>
f0105bfa:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105c01:	f0 
f0105c02:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105c04:	83 c0 01             	add    $0x1,%eax
f0105c07:	39 c7                	cmp    %eax,%edi
f0105c09:	75 ef                	jne    f0105bfa <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105c0b:	89 d0                	mov    %edx,%eax
f0105c0d:	02 43 2a             	add    0x2a(%ebx),%al
f0105c10:	74 15                	je     f0105c27 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105c12:	83 ec 0c             	sub    $0xc,%esp
f0105c15:	68 d8 7f 10 f0       	push   $0xf0107fd8
f0105c1a:	e8 13 db ff ff       	call   f0103732 <cprintf>
f0105c1f:	83 c4 10             	add    $0x10,%esp
f0105c22:	e9 3b 01 00 00       	jmp    f0105d62 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105c27:	85 db                	test   %ebx,%ebx
f0105c29:	0f 84 33 01 00 00    	je     f0105d62 <mp_init+0x2ea>
		return;
	ismp = 1;
f0105c2f:	c7 05 00 20 21 f0 01 	movl   $0x1,0xf0212000
f0105c36:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105c39:	8b 43 24             	mov    0x24(%ebx),%eax
f0105c3c:	a3 00 30 25 f0       	mov    %eax,0xf0253000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105c41:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105c44:	be 00 00 00 00       	mov    $0x0,%esi
f0105c49:	e9 85 00 00 00       	jmp    f0105cd3 <mp_init+0x25b>
		switch (*p) {
f0105c4e:	0f b6 07             	movzbl (%edi),%eax
f0105c51:	84 c0                	test   %al,%al
f0105c53:	74 06                	je     f0105c5b <mp_init+0x1e3>
f0105c55:	3c 04                	cmp    $0x4,%al
f0105c57:	77 55                	ja     f0105cae <mp_init+0x236>
f0105c59:	eb 4e                	jmp    f0105ca9 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105c5b:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105c5f:	74 11                	je     f0105c72 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105c61:	6b 05 c4 23 21 f0 74 	imul   $0x74,0xf02123c4,%eax
f0105c68:	05 20 20 21 f0       	add    $0xf0212020,%eax
f0105c6d:	a3 c0 23 21 f0       	mov    %eax,0xf02123c0
			if (ncpu < NCPU) {
f0105c72:	a1 c4 23 21 f0       	mov    0xf02123c4,%eax
f0105c77:	83 f8 07             	cmp    $0x7,%eax
f0105c7a:	7f 13                	jg     f0105c8f <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105c7c:	6b d0 74             	imul   $0x74,%eax,%edx
f0105c7f:	88 82 20 20 21 f0    	mov    %al,-0xfdedfe0(%edx)
				ncpu++;
f0105c85:	83 c0 01             	add    $0x1,%eax
f0105c88:	a3 c4 23 21 f0       	mov    %eax,0xf02123c4
f0105c8d:	eb 15                	jmp    f0105ca4 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105c8f:	83 ec 08             	sub    $0x8,%esp
f0105c92:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105c96:	50                   	push   %eax
f0105c97:	68 08 80 10 f0       	push   $0xf0108008
f0105c9c:	e8 91 da ff ff       	call   f0103732 <cprintf>
f0105ca1:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105ca4:	83 c7 14             	add    $0x14,%edi
			continue;
f0105ca7:	eb 27                	jmp    f0105cd0 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105ca9:	83 c7 08             	add    $0x8,%edi
			continue;
f0105cac:	eb 22                	jmp    f0105cd0 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105cae:	83 ec 08             	sub    $0x8,%esp
f0105cb1:	0f b6 c0             	movzbl %al,%eax
f0105cb4:	50                   	push   %eax
f0105cb5:	68 30 80 10 f0       	push   $0xf0108030
f0105cba:	e8 73 da ff ff       	call   f0103732 <cprintf>
			ismp = 0;
f0105cbf:	c7 05 00 20 21 f0 00 	movl   $0x0,0xf0212000
f0105cc6:	00 00 00 
			i = conf->entry;
f0105cc9:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105ccd:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105cd0:	83 c6 01             	add    $0x1,%esi
f0105cd3:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105cd7:	39 c6                	cmp    %eax,%esi
f0105cd9:	0f 82 6f ff ff ff    	jb     f0105c4e <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105cdf:	a1 c0 23 21 f0       	mov    0xf02123c0,%eax
f0105ce4:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105ceb:	83 3d 00 20 21 f0 00 	cmpl   $0x0,0xf0212000
f0105cf2:	75 26                	jne    f0105d1a <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105cf4:	c7 05 c4 23 21 f0 01 	movl   $0x1,0xf02123c4
f0105cfb:	00 00 00 
		lapicaddr = 0;
f0105cfe:	c7 05 00 30 25 f0 00 	movl   $0x0,0xf0253000
f0105d05:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105d08:	83 ec 0c             	sub    $0xc,%esp
f0105d0b:	68 50 80 10 f0       	push   $0xf0108050
f0105d10:	e8 1d da ff ff       	call   f0103732 <cprintf>
		return;
f0105d15:	83 c4 10             	add    $0x10,%esp
f0105d18:	eb 48                	jmp    f0105d62 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105d1a:	83 ec 04             	sub    $0x4,%esp
f0105d1d:	ff 35 c4 23 21 f0    	pushl  0xf02123c4
f0105d23:	0f b6 00             	movzbl (%eax),%eax
f0105d26:	50                   	push   %eax
f0105d27:	68 d7 80 10 f0       	push   $0xf01080d7
f0105d2c:	e8 01 da ff ff       	call   f0103732 <cprintf>

	if (mp->imcrp) {
f0105d31:	83 c4 10             	add    $0x10,%esp
f0105d34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d37:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105d3b:	74 25                	je     f0105d62 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105d3d:	83 ec 0c             	sub    $0xc,%esp
f0105d40:	68 7c 80 10 f0       	push   $0xf010807c
f0105d45:	e8 e8 d9 ff ff       	call   f0103732 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105d4a:	ba 22 00 00 00       	mov    $0x22,%edx
f0105d4f:	b8 70 00 00 00       	mov    $0x70,%eax
f0105d54:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105d55:	ba 23 00 00 00       	mov    $0x23,%edx
f0105d5a:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105d5b:	83 c8 01             	or     $0x1,%eax
f0105d5e:	ee                   	out    %al,(%dx)
f0105d5f:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105d62:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105d65:	5b                   	pop    %ebx
f0105d66:	5e                   	pop    %esi
f0105d67:	5f                   	pop    %edi
f0105d68:	5d                   	pop    %ebp
f0105d69:	c3                   	ret    

f0105d6a <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105d6a:	55                   	push   %ebp
f0105d6b:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105d6d:	8b 0d 04 30 25 f0    	mov    0xf0253004,%ecx
f0105d73:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105d76:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105d78:	a1 04 30 25 f0       	mov    0xf0253004,%eax
f0105d7d:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105d80:	5d                   	pop    %ebp
f0105d81:	c3                   	ret    

f0105d82 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105d82:	55                   	push   %ebp
f0105d83:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105d85:	a1 04 30 25 f0       	mov    0xf0253004,%eax
f0105d8a:	85 c0                	test   %eax,%eax
f0105d8c:	74 08                	je     f0105d96 <cpunum+0x14>
		return lapic[ID] >> 24;
f0105d8e:	8b 40 20             	mov    0x20(%eax),%eax
f0105d91:	c1 e8 18             	shr    $0x18,%eax
f0105d94:	eb 05                	jmp    f0105d9b <cpunum+0x19>
	return 0;
f0105d96:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105d9b:	5d                   	pop    %ebp
f0105d9c:	c3                   	ret    

f0105d9d <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105d9d:	a1 00 30 25 f0       	mov    0xf0253000,%eax
f0105da2:	85 c0                	test   %eax,%eax
f0105da4:	0f 84 21 01 00 00    	je     f0105ecb <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105daa:	55                   	push   %ebp
f0105dab:	89 e5                	mov    %esp,%ebp
f0105dad:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105db0:	68 00 10 00 00       	push   $0x1000
f0105db5:	50                   	push   %eax
f0105db6:	e8 76 b4 ff ff       	call   f0101231 <mmio_map_region>
f0105dbb:	a3 04 30 25 f0       	mov    %eax,0xf0253004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105dc0:	ba 27 01 00 00       	mov    $0x127,%edx
f0105dc5:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105dca:	e8 9b ff ff ff       	call   f0105d6a <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105dcf:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105dd4:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105dd9:	e8 8c ff ff ff       	call   f0105d6a <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105dde:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105de3:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105de8:	e8 7d ff ff ff       	call   f0105d6a <lapicw>
	lapicw(TICR, 10000000); 
f0105ded:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105df2:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105df7:	e8 6e ff ff ff       	call   f0105d6a <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105dfc:	e8 81 ff ff ff       	call   f0105d82 <cpunum>
f0105e01:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e04:	05 20 20 21 f0       	add    $0xf0212020,%eax
f0105e09:	83 c4 10             	add    $0x10,%esp
f0105e0c:	39 05 c0 23 21 f0    	cmp    %eax,0xf02123c0
f0105e12:	74 0f                	je     f0105e23 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105e14:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e19:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105e1e:	e8 47 ff ff ff       	call   f0105d6a <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105e23:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e28:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105e2d:	e8 38 ff ff ff       	call   f0105d6a <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105e32:	a1 04 30 25 f0       	mov    0xf0253004,%eax
f0105e37:	8b 40 30             	mov    0x30(%eax),%eax
f0105e3a:	c1 e8 10             	shr    $0x10,%eax
f0105e3d:	3c 03                	cmp    $0x3,%al
f0105e3f:	76 0f                	jbe    f0105e50 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105e41:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e46:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105e4b:	e8 1a ff ff ff       	call   f0105d6a <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105e50:	ba 33 00 00 00       	mov    $0x33,%edx
f0105e55:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105e5a:	e8 0b ff ff ff       	call   f0105d6a <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105e5f:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e64:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105e69:	e8 fc fe ff ff       	call   f0105d6a <lapicw>
	lapicw(ESR, 0);
f0105e6e:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e73:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105e78:	e8 ed fe ff ff       	call   f0105d6a <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105e7d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e82:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105e87:	e8 de fe ff ff       	call   f0105d6a <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105e8c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e91:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105e96:	e8 cf fe ff ff       	call   f0105d6a <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105e9b:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105ea0:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ea5:	e8 c0 fe ff ff       	call   f0105d6a <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105eaa:	8b 15 04 30 25 f0    	mov    0xf0253004,%edx
f0105eb0:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105eb6:	f6 c4 10             	test   $0x10,%ah
f0105eb9:	75 f5                	jne    f0105eb0 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105ebb:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ec0:	b8 20 00 00 00       	mov    $0x20,%eax
f0105ec5:	e8 a0 fe ff ff       	call   f0105d6a <lapicw>
}
f0105eca:	c9                   	leave  
f0105ecb:	f3 c3                	repz ret 

f0105ecd <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105ecd:	83 3d 04 30 25 f0 00 	cmpl   $0x0,0xf0253004
f0105ed4:	74 13                	je     f0105ee9 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105ed6:	55                   	push   %ebp
f0105ed7:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105ed9:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ede:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105ee3:	e8 82 fe ff ff       	call   f0105d6a <lapicw>
}
f0105ee8:	5d                   	pop    %ebp
f0105ee9:	f3 c3                	repz ret 

f0105eeb <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105eeb:	55                   	push   %ebp
f0105eec:	89 e5                	mov    %esp,%ebp
f0105eee:	56                   	push   %esi
f0105eef:	53                   	push   %ebx
f0105ef0:	8b 75 08             	mov    0x8(%ebp),%esi
f0105ef3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105ef6:	ba 70 00 00 00       	mov    $0x70,%edx
f0105efb:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105f00:	ee                   	out    %al,(%dx)
f0105f01:	ba 71 00 00 00       	mov    $0x71,%edx
f0105f06:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105f0b:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105f0c:	83 3d 88 1e 21 f0 00 	cmpl   $0x0,0xf0211e88
f0105f13:	75 19                	jne    f0105f2e <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f15:	68 67 04 00 00       	push   $0x467
f0105f1a:	68 44 64 10 f0       	push   $0xf0106444
f0105f1f:	68 9b 00 00 00       	push   $0x9b
f0105f24:	68 f4 80 10 f0       	push   $0xf01080f4
f0105f29:	e8 12 a1 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105f2e:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105f35:	00 00 
	wrv[1] = addr >> 4;
f0105f37:	89 d8                	mov    %ebx,%eax
f0105f39:	c1 e8 04             	shr    $0x4,%eax
f0105f3c:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105f42:	c1 e6 18             	shl    $0x18,%esi
f0105f45:	89 f2                	mov    %esi,%edx
f0105f47:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f4c:	e8 19 fe ff ff       	call   f0105d6a <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105f51:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105f56:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f5b:	e8 0a fe ff ff       	call   f0105d6a <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105f60:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105f65:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f6a:	e8 fb fd ff ff       	call   f0105d6a <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f6f:	c1 eb 0c             	shr    $0xc,%ebx
f0105f72:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105f75:	89 f2                	mov    %esi,%edx
f0105f77:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f7c:	e8 e9 fd ff ff       	call   f0105d6a <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f81:	89 da                	mov    %ebx,%edx
f0105f83:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f88:	e8 dd fd ff ff       	call   f0105d6a <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105f8d:	89 f2                	mov    %esi,%edx
f0105f8f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f94:	e8 d1 fd ff ff       	call   f0105d6a <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f99:	89 da                	mov    %ebx,%edx
f0105f9b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fa0:	e8 c5 fd ff ff       	call   f0105d6a <lapicw>
		microdelay(200);
	}
}
f0105fa5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105fa8:	5b                   	pop    %ebx
f0105fa9:	5e                   	pop    %esi
f0105faa:	5d                   	pop    %ebp
f0105fab:	c3                   	ret    

f0105fac <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105fac:	55                   	push   %ebp
f0105fad:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105faf:	8b 55 08             	mov    0x8(%ebp),%edx
f0105fb2:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105fb8:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fbd:	e8 a8 fd ff ff       	call   f0105d6a <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105fc2:	8b 15 04 30 25 f0    	mov    0xf0253004,%edx
f0105fc8:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105fce:	f6 c4 10             	test   $0x10,%ah
f0105fd1:	75 f5                	jne    f0105fc8 <lapic_ipi+0x1c>
		;
}
f0105fd3:	5d                   	pop    %ebp
f0105fd4:	c3                   	ret    

f0105fd5 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105fd5:	55                   	push   %ebp
f0105fd6:	89 e5                	mov    %esp,%ebp
f0105fd8:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105fdb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105fe1:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105fe4:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105fe7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105fee:	5d                   	pop    %ebp
f0105fef:	c3                   	ret    

f0105ff0 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105ff0:	55                   	push   %ebp
f0105ff1:	89 e5                	mov    %esp,%ebp
f0105ff3:	56                   	push   %esi
f0105ff4:	53                   	push   %ebx
f0105ff5:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105ff8:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105ffb:	74 14                	je     f0106011 <spin_lock+0x21>
f0105ffd:	8b 73 08             	mov    0x8(%ebx),%esi
f0106000:	e8 7d fd ff ff       	call   f0105d82 <cpunum>
f0106005:	6b c0 74             	imul   $0x74,%eax,%eax
f0106008:	05 20 20 21 f0       	add    $0xf0212020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f010600d:	39 c6                	cmp    %eax,%esi
f010600f:	74 07                	je     f0106018 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106011:	ba 01 00 00 00       	mov    $0x1,%edx
f0106016:	eb 20                	jmp    f0106038 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106018:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010601b:	e8 62 fd ff ff       	call   f0105d82 <cpunum>
f0106020:	83 ec 0c             	sub    $0xc,%esp
f0106023:	53                   	push   %ebx
f0106024:	50                   	push   %eax
f0106025:	68 04 81 10 f0       	push   $0xf0108104
f010602a:	6a 41                	push   $0x41
f010602c:	68 68 81 10 f0       	push   $0xf0108168
f0106031:	e8 0a a0 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106036:	f3 90                	pause  
f0106038:	89 d0                	mov    %edx,%eax
f010603a:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f010603d:	85 c0                	test   %eax,%eax
f010603f:	75 f5                	jne    f0106036 <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106041:	e8 3c fd ff ff       	call   f0105d82 <cpunum>
f0106046:	6b c0 74             	imul   $0x74,%eax,%eax
f0106049:	05 20 20 21 f0       	add    $0xf0212020,%eax
f010604e:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106051:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0106054:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106056:	b8 00 00 00 00       	mov    $0x0,%eax
f010605b:	eb 0b                	jmp    f0106068 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f010605d:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106060:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106063:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106065:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106068:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f010606e:	76 11                	jbe    f0106081 <spin_lock+0x91>
f0106070:	83 f8 09             	cmp    $0x9,%eax
f0106073:	7e e8                	jle    f010605d <spin_lock+0x6d>
f0106075:	eb 0a                	jmp    f0106081 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106077:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f010607e:	83 c0 01             	add    $0x1,%eax
f0106081:	83 f8 09             	cmp    $0x9,%eax
f0106084:	7e f1                	jle    f0106077 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106086:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106089:	5b                   	pop    %ebx
f010608a:	5e                   	pop    %esi
f010608b:	5d                   	pop    %ebp
f010608c:	c3                   	ret    

f010608d <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f010608d:	55                   	push   %ebp
f010608e:	89 e5                	mov    %esp,%ebp
f0106090:	57                   	push   %edi
f0106091:	56                   	push   %esi
f0106092:	53                   	push   %ebx
f0106093:	83 ec 4c             	sub    $0x4c,%esp
f0106096:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106099:	83 3e 00             	cmpl   $0x0,(%esi)
f010609c:	74 18                	je     f01060b6 <spin_unlock+0x29>
f010609e:	8b 5e 08             	mov    0x8(%esi),%ebx
f01060a1:	e8 dc fc ff ff       	call   f0105d82 <cpunum>
f01060a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01060a9:	05 20 20 21 f0       	add    $0xf0212020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01060ae:	39 c3                	cmp    %eax,%ebx
f01060b0:	0f 84 a5 00 00 00    	je     f010615b <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01060b6:	83 ec 04             	sub    $0x4,%esp
f01060b9:	6a 28                	push   $0x28
f01060bb:	8d 46 0c             	lea    0xc(%esi),%eax
f01060be:	50                   	push   %eax
f01060bf:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01060c2:	53                   	push   %ebx
f01060c3:	e8 e7 f6 ff ff       	call   f01057af <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01060c8:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01060cb:	0f b6 38             	movzbl (%eax),%edi
f01060ce:	8b 76 04             	mov    0x4(%esi),%esi
f01060d1:	e8 ac fc ff ff       	call   f0105d82 <cpunum>
f01060d6:	57                   	push   %edi
f01060d7:	56                   	push   %esi
f01060d8:	50                   	push   %eax
f01060d9:	68 30 81 10 f0       	push   $0xf0108130
f01060de:	e8 4f d6 ff ff       	call   f0103732 <cprintf>
f01060e3:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01060e6:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01060e9:	eb 54                	jmp    f010613f <spin_unlock+0xb2>
f01060eb:	83 ec 08             	sub    $0x8,%esp
f01060ee:	57                   	push   %edi
f01060ef:	50                   	push   %eax
f01060f0:	e8 77 ec ff ff       	call   f0104d6c <debuginfo_eip>
f01060f5:	83 c4 10             	add    $0x10,%esp
f01060f8:	85 c0                	test   %eax,%eax
f01060fa:	78 27                	js     f0106123 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01060fc:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01060fe:	83 ec 04             	sub    $0x4,%esp
f0106101:	89 c2                	mov    %eax,%edx
f0106103:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106106:	52                   	push   %edx
f0106107:	ff 75 b0             	pushl  -0x50(%ebp)
f010610a:	ff 75 b4             	pushl  -0x4c(%ebp)
f010610d:	ff 75 ac             	pushl  -0x54(%ebp)
f0106110:	ff 75 a8             	pushl  -0x58(%ebp)
f0106113:	50                   	push   %eax
f0106114:	68 78 81 10 f0       	push   $0xf0108178
f0106119:	e8 14 d6 ff ff       	call   f0103732 <cprintf>
f010611e:	83 c4 20             	add    $0x20,%esp
f0106121:	eb 12                	jmp    f0106135 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106123:	83 ec 08             	sub    $0x8,%esp
f0106126:	ff 36                	pushl  (%esi)
f0106128:	68 8f 81 10 f0       	push   $0xf010818f
f010612d:	e8 00 d6 ff ff       	call   f0103732 <cprintf>
f0106132:	83 c4 10             	add    $0x10,%esp
f0106135:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106138:	8d 45 e8             	lea    -0x18(%ebp),%eax
f010613b:	39 c3                	cmp    %eax,%ebx
f010613d:	74 08                	je     f0106147 <spin_unlock+0xba>
f010613f:	89 de                	mov    %ebx,%esi
f0106141:	8b 03                	mov    (%ebx),%eax
f0106143:	85 c0                	test   %eax,%eax
f0106145:	75 a4                	jne    f01060eb <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106147:	83 ec 04             	sub    $0x4,%esp
f010614a:	68 97 81 10 f0       	push   $0xf0108197
f010614f:	6a 67                	push   $0x67
f0106151:	68 68 81 10 f0       	push   $0xf0108168
f0106156:	e8 e5 9e ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f010615b:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106162:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106169:	b8 00 00 00 00       	mov    $0x0,%eax
f010616e:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106171:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106174:	5b                   	pop    %ebx
f0106175:	5e                   	pop    %esi
f0106176:	5f                   	pop    %edi
f0106177:	5d                   	pop    %ebp
f0106178:	c3                   	ret    
f0106179:	66 90                	xchg   %ax,%ax
f010617b:	66 90                	xchg   %ax,%ax
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
