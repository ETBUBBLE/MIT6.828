
obj/fs/fs：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 1c 1a 00 00       	call   801a4d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
		return -1;
	return 0;
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800085:	eb 0b                	jmp    800092 <ide_probe_disk1+0x33>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800087:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008a:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800090:	74 05                	je     800097 <ide_probe_disk1+0x38>
  800092:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800093:	a8 a1                	test   $0xa1,%al
  800095:	75 f0                	jne    800087 <ide_probe_disk1+0x28>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800097:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009c:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  8000a1:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a2:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a8:	0f 9e c3             	setle  %bl
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	0f b6 c3             	movzbl %bl,%eax
  8000b1:	50                   	push   %eax
  8000b2:	68 c0 38 80 00       	push   $0x8038c0
  8000b7:	e8 ca 1a 00 00       	call   801b86 <cprintf>
	return (x < 1000);
}
  8000bc:	89 d8                	mov    %ebx,%eax
  8000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	83 ec 08             	sub    $0x8,%esp
  8000c9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000cc:	83 f8 01             	cmp    $0x1,%eax
  8000cf:	76 14                	jbe    8000e5 <ide_set_disk+0x22>
		panic("bad disk number");
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	68 d7 38 80 00       	push   $0x8038d7
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 e7 38 80 00       	push   $0x8038e7
  8000e0:	e8 c8 19 00 00       	call   801aad <_panic>
	diskno = d;
  8000e5:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fe:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800104:	76 16                	jbe    80011c <ide_read+0x30>
  800106:	68 f0 38 80 00       	push   $0x8038f0
  80010b:	68 fd 38 80 00       	push   $0x8038fd
  800110:	6a 44                	push   $0x44
  800112:	68 e7 38 80 00       	push   $0x8038e7
  800117:	e8 91 19 00 00       	call   801aad <_panic>

	ide_wait_ready(0);
  80011c:	b8 00 00 00 00       	mov    $0x0,%eax
  800121:	e8 0d ff ff ff       	call   800033 <ide_wait_ready>
  800126:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80012b:	89 f0                	mov    %esi,%eax
  80012d:	ee                   	out    %al,(%dx)
  80012e:	ba f3 01 00 00       	mov    $0x1f3,%edx
  800133:	89 f8                	mov    %edi,%eax
  800135:	ee                   	out    %al,(%dx)
  800136:	89 f8                	mov    %edi,%eax
  800138:	c1 e8 08             	shr    $0x8,%eax
  80013b:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800140:	ee                   	out    %al,(%dx)
  800141:	89 f8                	mov    %edi,%eax
  800143:	c1 e8 10             	shr    $0x10,%eax
  800146:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80014b:	ee                   	out    %al,(%dx)
  80014c:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800153:	83 e0 01             	and    $0x1,%eax
  800156:	c1 e0 04             	shl    $0x4,%eax
  800159:	83 c8 e0             	or     $0xffffffe0,%eax
  80015c:	c1 ef 18             	shr    $0x18,%edi
  80015f:	83 e7 0f             	and    $0xf,%edi
  800162:	09 f8                	or     %edi,%eax
  800164:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800169:	ee                   	out    %al,(%dx)
  80016a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80016f:	b8 20 00 00 00       	mov    $0x20,%eax
  800174:	ee                   	out    %al,(%dx)
  800175:	c1 e6 09             	shl    $0x9,%esi
  800178:	01 de                	add    %ebx,%esi
  80017a:	eb 23                	jmp    80019f <ide_read+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80017c:	b8 01 00 00 00       	mov    $0x1,%eax
  800181:	e8 ad fe ff ff       	call   800033 <ide_wait_ready>
  800186:	85 c0                	test   %eax,%eax
  800188:	78 1e                	js     8001a8 <ide_read+0xbc>
}

static inline void
insl(int port, void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\tinsl"
  80018a:	89 df                	mov    %ebx,%edi
  80018c:	b9 80 00 00 00       	mov    $0x80,%ecx
  800191:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800196:	fc                   	cld    
  800197:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800199:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80019f:	39 f3                	cmp    %esi,%ebx
  8001a1:	75 d9                	jne    80017c <ide_read+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001bf:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c2:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001c8:	76 16                	jbe    8001e0 <ide_write+0x30>
  8001ca:	68 f0 38 80 00       	push   $0x8038f0
  8001cf:	68 fd 38 80 00       	push   $0x8038fd
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 e7 38 80 00       	push   $0x8038e7
  8001db:	e8 cd 18 00 00       	call   801aad <_panic>

	ide_wait_ready(0);
  8001e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e5:	e8 49 fe ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ea:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001ef:	89 f8                	mov    %edi,%eax
  8001f1:	ee                   	out    %al,(%dx)
  8001f2:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001f7:	89 f0                	mov    %esi,%eax
  8001f9:	ee                   	out    %al,(%dx)
  8001fa:	89 f0                	mov    %esi,%eax
  8001fc:	c1 e8 08             	shr    $0x8,%eax
  8001ff:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800204:	ee                   	out    %al,(%dx)
  800205:	89 f0                	mov    %esi,%eax
  800207:	c1 e8 10             	shr    $0x10,%eax
  80020a:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80020f:	ee                   	out    %al,(%dx)
  800210:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800217:	83 e0 01             	and    $0x1,%eax
  80021a:	c1 e0 04             	shl    $0x4,%eax
  80021d:	83 c8 e0             	or     $0xffffffe0,%eax
  800220:	c1 ee 18             	shr    $0x18,%esi
  800223:	83 e6 0f             	and    $0xf,%esi
  800226:	09 f0                	or     %esi,%eax
  800228:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80022d:	ee                   	out    %al,(%dx)
  80022e:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800233:	b8 30 00 00 00       	mov    $0x30,%eax
  800238:	ee                   	out    %al,(%dx)
  800239:	c1 e7 09             	shl    $0x9,%edi
  80023c:	01 df                	add    %ebx,%edi
  80023e:	eb 23                	jmp    800263 <ide_write+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800240:	b8 01 00 00 00       	mov    $0x1,%eax
  800245:	e8 e9 fd ff ff       	call   800033 <ide_wait_ready>
  80024a:	85 c0                	test   %eax,%eax
  80024c:	78 1e                	js     80026c <ide_write+0xbc>
}

static inline void
outsl(int port, const void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\toutsl"
  80024e:	89 de                	mov    %ebx,%esi
  800250:	b9 80 00 00 00       	mov    $0x80,%ecx
  800255:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80025a:	fc                   	cld    
  80025b:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80025d:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800263:	39 fb                	cmp    %edi,%ebx
  800265:	75 d9                	jne    800240 <ide_write+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  80027c:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  80027e:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800284:	89 c6                	mov    %eax,%esi
  800286:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800289:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80028e:	76 1b                	jbe    8002ab <bc_pgfault+0x37>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	ff 72 04             	pushl  0x4(%edx)
  800296:	53                   	push   %ebx
  800297:	ff 72 28             	pushl  0x28(%edx)
  80029a:	68 14 39 80 00       	push   $0x803914
  80029f:	6a 27                	push   $0x27
  8002a1:	68 d0 39 80 00       	push   $0x8039d0
  8002a6:	e8 02 18 00 00       	call   801aad <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002ab:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8002b0:	85 c0                	test   %eax,%eax
  8002b2:	74 17                	je     8002cb <bc_pgfault+0x57>
  8002b4:	3b 70 04             	cmp    0x4(%eax),%esi
  8002b7:	72 12                	jb     8002cb <bc_pgfault+0x57>
		panic("reading non-existent block %08x\n", blockno);
  8002b9:	56                   	push   %esi
  8002ba:	68 44 39 80 00       	push   $0x803944
  8002bf:	6a 2b                	push   $0x2b
  8002c1:	68 d0 39 80 00       	push   $0x8039d0
  8002c6:	e8 e2 17 00 00       	call   801aad <_panic>
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
	addr=ROUNDDOWN(addr,PGSIZE);
  8002cb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(sys_page_alloc(0,addr,PTE_SYSCALL)<0)panic("error page alloc");
  8002d1:	83 ec 04             	sub    $0x4,%esp
  8002d4:	68 07 0e 00 00       	push   $0xe07
  8002d9:	53                   	push   %ebx
  8002da:	6a 00                	push   $0x0
  8002dc:	e8 ac 22 00 00       	call   80258d <sys_page_alloc>
  8002e1:	83 c4 10             	add    $0x10,%esp
  8002e4:	85 c0                	test   %eax,%eax
  8002e6:	79 14                	jns    8002fc <bc_pgfault+0x88>
  8002e8:	83 ec 04             	sub    $0x4,%esp
  8002eb:	68 d8 39 80 00       	push   $0x8039d8
  8002f0:	6a 34                	push   $0x34
  8002f2:	68 d0 39 80 00       	push   $0x8039d0
  8002f7:	e8 b1 17 00 00       	call   801aad <_panic>
	ide_read(blockno*8,addr,8);
  8002fc:	83 ec 04             	sub    $0x4,%esp
  8002ff:	6a 08                	push   $0x8
  800301:	53                   	push   %ebx
  800302:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  800309:	50                   	push   %eax
  80030a:	e8 dd fd ff ff       	call   8000ec <ide_read>

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  80030f:	89 d8                	mov    %ebx,%eax
  800311:	c1 e8 0c             	shr    $0xc,%eax
  800314:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80031b:	25 07 0e 00 00       	and    $0xe07,%eax
  800320:	89 04 24             	mov    %eax,(%esp)
  800323:	53                   	push   %ebx
  800324:	6a 00                	push   $0x0
  800326:	53                   	push   %ebx
  800327:	6a 00                	push   $0x0
  800329:	e8 a2 22 00 00       	call   8025d0 <sys_page_map>
  80032e:	83 c4 20             	add    $0x20,%esp
  800331:	85 c0                	test   %eax,%eax
  800333:	79 12                	jns    800347 <bc_pgfault+0xd3>
		panic("in bc_pgfault, sys_page_map: %e", r);
  800335:	50                   	push   %eax
  800336:	68 68 39 80 00       	push   $0x803968
  80033b:	6a 3a                	push   $0x3a
  80033d:	68 d0 39 80 00       	push   $0x8039d0
  800342:	e8 66 17 00 00       	call   801aad <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  800347:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  80034e:	74 22                	je     800372 <bc_pgfault+0xfe>
  800350:	83 ec 0c             	sub    $0xc,%esp
  800353:	56                   	push   %esi
  800354:	e8 51 04 00 00       	call   8007aa <block_is_free>
  800359:	83 c4 10             	add    $0x10,%esp
  80035c:	84 c0                	test   %al,%al
  80035e:	74 12                	je     800372 <bc_pgfault+0xfe>
		panic("reading free block %08x\n", blockno);
  800360:	56                   	push   %esi
  800361:	68 e9 39 80 00       	push   $0x8039e9
  800366:	6a 40                	push   $0x40
  800368:	68 d0 39 80 00       	push   $0x8039d0
  80036d:	e8 3b 17 00 00       	call   801aad <_panic>
}
  800372:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5d                   	pop    %ebp
  800378:	c3                   	ret    

00800379 <diskaddr>:
#include "fs.h"
// 基于用户级页错误处理机制的块缓存。
// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  800379:	55                   	push   %ebp
  80037a:	89 e5                	mov    %esp,%ebp
  80037c:	83 ec 08             	sub    $0x8,%esp
  80037f:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  800382:	85 c0                	test   %eax,%eax
  800384:	74 0f                	je     800395 <diskaddr+0x1c>
  800386:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  80038c:	85 d2                	test   %edx,%edx
  80038e:	74 17                	je     8003a7 <diskaddr+0x2e>
  800390:	3b 42 04             	cmp    0x4(%edx),%eax
  800393:	72 12                	jb     8003a7 <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  800395:	50                   	push   %eax
  800396:	68 88 39 80 00       	push   $0x803988
  80039b:	6a 09                	push   $0x9
  80039d:	68 d0 39 80 00       	push   $0x8039d0
  8003a2:	e8 06 17 00 00       	call   801aad <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003a7:	05 00 00 01 00       	add    $0x10000,%eax
  8003ac:	c1 e0 0c             	shl    $0xc,%eax
}
  8003af:	c9                   	leave  
  8003b0:	c3                   	ret    

008003b1 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  8003b1:	55                   	push   %ebp
  8003b2:	89 e5                	mov    %esp,%ebp
  8003b4:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003b7:	89 d0                	mov    %edx,%eax
  8003b9:	c1 e8 16             	shr    $0x16,%eax
  8003bc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c8:	f6 c1 01             	test   $0x1,%cl
  8003cb:	74 0d                	je     8003da <va_is_mapped+0x29>
  8003cd:	c1 ea 0c             	shr    $0xc,%edx
  8003d0:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8003d7:	83 e0 01             	and    $0x1,%eax
  8003da:	83 e0 01             	and    $0x1,%eax
}
  8003dd:	5d                   	pop    %ebp
  8003de:	c3                   	ret    

008003df <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e5:	c1 e8 0c             	shr    $0xc,%eax
  8003e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003ef:	c1 e8 06             	shr    $0x6,%eax
  8003f2:	83 e0 01             	and    $0x1,%eax
}
  8003f5:	5d                   	pop    %ebp
  8003f6:	c3                   	ret    

008003f7 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  8003f7:	55                   	push   %ebp
  8003f8:	89 e5                	mov    %esp,%ebp
  8003fa:	56                   	push   %esi
  8003fb:	53                   	push   %ebx
  8003fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  8003ff:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800405:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80040a:	76 12                	jbe    80041e <flush_block+0x27>
		panic("flush_block of bad va %08x", addr);
  80040c:	53                   	push   %ebx
  80040d:	68 02 3a 80 00       	push   $0x803a02
  800412:	6a 50                	push   $0x50
  800414:	68 d0 39 80 00       	push   $0x8039d0
  800419:	e8 8f 16 00 00       	call   801aad <_panic>

	// LAB 5: Your code here.
	addr=ROUNDDOWN(addr,PGSIZE);
  80041e:	89 de                	mov    %ebx,%esi
  800420:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if(!va_is_mapped(addr)||!va_is_dirty(addr))return ;
  800426:	83 ec 0c             	sub    $0xc,%esp
  800429:	56                   	push   %esi
  80042a:	e8 82 ff ff ff       	call   8003b1 <va_is_mapped>
  80042f:	83 c4 10             	add    $0x10,%esp
  800432:	84 c0                	test   %al,%al
  800434:	74 3d                	je     800473 <flush_block+0x7c>
  800436:	83 ec 0c             	sub    $0xc,%esp
  800439:	56                   	push   %esi
  80043a:	e8 a0 ff ff ff       	call   8003df <va_is_dirty>
  80043f:	83 c4 10             	add    $0x10,%esp
  800442:	84 c0                	test   %al,%al
  800444:	74 2d                	je     800473 <flush_block+0x7c>
	ide_write(blockno*8,addr,8);
  800446:	83 ec 04             	sub    $0x4,%esp
  800449:	6a 08                	push   $0x8
  80044b:	56                   	push   %esi
  80044c:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
  800452:	c1 eb 0c             	shr    $0xc,%ebx
  800455:	c1 e3 03             	shl    $0x3,%ebx
  800458:	53                   	push   %ebx
  800459:	e8 52 fd ff ff       	call   8001b0 <ide_write>
	sys_page_map(0,addr,0,addr,PTE_SYSCALL);
  80045e:	c7 04 24 07 0e 00 00 	movl   $0xe07,(%esp)
  800465:	56                   	push   %esi
  800466:	6a 00                	push   $0x0
  800468:	56                   	push   %esi
  800469:	6a 00                	push   $0x0
  80046b:	e8 60 21 00 00       	call   8025d0 <sys_page_map>
  800470:	83 c4 20             	add    $0x20,%esp
	//panic("flush_block not implemented");
}
  800473:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800476:	5b                   	pop    %ebx
  800477:	5e                   	pop    %esi
  800478:	5d                   	pop    %ebp
  800479:	c3                   	ret    

0080047a <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	53                   	push   %ebx
  80047e:	81 ec 20 02 00 00    	sub    $0x220,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  800484:	68 74 02 80 00       	push   $0x800274
  800489:	e8 f0 22 00 00       	call   80277e <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  80048e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800495:	e8 df fe ff ff       	call   800379 <diskaddr>
  80049a:	83 c4 0c             	add    $0xc,%esp
  80049d:	68 08 01 00 00       	push   $0x108
  8004a2:	50                   	push   %eax
  8004a3:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8004a9:	50                   	push   %eax
  8004aa:	e8 6d 1e 00 00       	call   80231c <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  8004af:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004b6:	e8 be fe ff ff       	call   800379 <diskaddr>
  8004bb:	83 c4 08             	add    $0x8,%esp
  8004be:	68 1d 3a 80 00       	push   $0x803a1d
  8004c3:	50                   	push   %eax
  8004c4:	e8 c1 1c 00 00       	call   80218a <strcpy>
	flush_block(diskaddr(1));
  8004c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004d0:	e8 a4 fe ff ff       	call   800379 <diskaddr>
  8004d5:	89 04 24             	mov    %eax,(%esp)
  8004d8:	e8 1a ff ff ff       	call   8003f7 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  8004dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004e4:	e8 90 fe ff ff       	call   800379 <diskaddr>
  8004e9:	89 04 24             	mov    %eax,(%esp)
  8004ec:	e8 c0 fe ff ff       	call   8003b1 <va_is_mapped>
  8004f1:	83 c4 10             	add    $0x10,%esp
  8004f4:	84 c0                	test   %al,%al
  8004f6:	75 16                	jne    80050e <bc_init+0x94>
  8004f8:	68 3f 3a 80 00       	push   $0x803a3f
  8004fd:	68 fd 38 80 00       	push   $0x8038fd
  800502:	6a 67                	push   $0x67
  800504:	68 d0 39 80 00       	push   $0x8039d0
  800509:	e8 9f 15 00 00       	call   801aad <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  80050e:	83 ec 0c             	sub    $0xc,%esp
  800511:	6a 01                	push   $0x1
  800513:	e8 61 fe ff ff       	call   800379 <diskaddr>
  800518:	89 04 24             	mov    %eax,(%esp)
  80051b:	e8 bf fe ff ff       	call   8003df <va_is_dirty>
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	84 c0                	test   %al,%al
  800525:	74 16                	je     80053d <bc_init+0xc3>
  800527:	68 24 3a 80 00       	push   $0x803a24
  80052c:	68 fd 38 80 00       	push   $0x8038fd
  800531:	6a 68                	push   $0x68
  800533:	68 d0 39 80 00       	push   $0x8039d0
  800538:	e8 70 15 00 00       	call   801aad <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  80053d:	83 ec 0c             	sub    $0xc,%esp
  800540:	6a 01                	push   $0x1
  800542:	e8 32 fe ff ff       	call   800379 <diskaddr>
  800547:	83 c4 08             	add    $0x8,%esp
  80054a:	50                   	push   %eax
  80054b:	6a 00                	push   $0x0
  80054d:	e8 c0 20 00 00       	call   802612 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800552:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800559:	e8 1b fe ff ff       	call   800379 <diskaddr>
  80055e:	89 04 24             	mov    %eax,(%esp)
  800561:	e8 4b fe ff ff       	call   8003b1 <va_is_mapped>
  800566:	83 c4 10             	add    $0x10,%esp
  800569:	84 c0                	test   %al,%al
  80056b:	74 16                	je     800583 <bc_init+0x109>
  80056d:	68 3e 3a 80 00       	push   $0x803a3e
  800572:	68 fd 38 80 00       	push   $0x8038fd
  800577:	6a 6c                	push   $0x6c
  800579:	68 d0 39 80 00       	push   $0x8039d0
  80057e:	e8 2a 15 00 00       	call   801aad <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800583:	83 ec 0c             	sub    $0xc,%esp
  800586:	6a 01                	push   $0x1
  800588:	e8 ec fd ff ff       	call   800379 <diskaddr>
  80058d:	83 c4 08             	add    $0x8,%esp
  800590:	68 1d 3a 80 00       	push   $0x803a1d
  800595:	50                   	push   %eax
  800596:	e8 99 1c 00 00       	call   802234 <strcmp>
  80059b:	83 c4 10             	add    $0x10,%esp
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	74 16                	je     8005b8 <bc_init+0x13e>
  8005a2:	68 ac 39 80 00       	push   $0x8039ac
  8005a7:	68 fd 38 80 00       	push   $0x8038fd
  8005ac:	6a 6f                	push   $0x6f
  8005ae:	68 d0 39 80 00       	push   $0x8039d0
  8005b3:	e8 f5 14 00 00       	call   801aad <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  8005b8:	83 ec 0c             	sub    $0xc,%esp
  8005bb:	6a 01                	push   $0x1
  8005bd:	e8 b7 fd ff ff       	call   800379 <diskaddr>
  8005c2:	83 c4 0c             	add    $0xc,%esp
  8005c5:	68 08 01 00 00       	push   $0x108
  8005ca:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
  8005d0:	53                   	push   %ebx
  8005d1:	50                   	push   %eax
  8005d2:	e8 45 1d 00 00       	call   80231c <memmove>
	flush_block(diskaddr(1));
  8005d7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005de:	e8 96 fd ff ff       	call   800379 <diskaddr>
  8005e3:	89 04 24             	mov    %eax,(%esp)
  8005e6:	e8 0c fe ff ff       	call   8003f7 <flush_block>

	// Now repeat the same experiment, but pass an unaligned address to
	// flush_block.

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8005eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005f2:	e8 82 fd ff ff       	call   800379 <diskaddr>
  8005f7:	83 c4 0c             	add    $0xc,%esp
  8005fa:	68 08 01 00 00       	push   $0x108
  8005ff:	50                   	push   %eax
  800600:	53                   	push   %ebx
  800601:	e8 16 1d 00 00       	call   80231c <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800606:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80060d:	e8 67 fd ff ff       	call   800379 <diskaddr>
  800612:	83 c4 08             	add    $0x8,%esp
  800615:	68 1d 3a 80 00       	push   $0x803a1d
  80061a:	50                   	push   %eax
  80061b:	e8 6a 1b 00 00       	call   80218a <strcpy>

	// Pass an unaligned address to flush_block.
	flush_block(diskaddr(1) + 20);
  800620:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800627:	e8 4d fd ff ff       	call   800379 <diskaddr>
  80062c:	83 c0 14             	add    $0x14,%eax
  80062f:	89 04 24             	mov    %eax,(%esp)
  800632:	e8 c0 fd ff ff       	call   8003f7 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800637:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80063e:	e8 36 fd ff ff       	call   800379 <diskaddr>
  800643:	89 04 24             	mov    %eax,(%esp)
  800646:	e8 66 fd ff ff       	call   8003b1 <va_is_mapped>
  80064b:	83 c4 10             	add    $0x10,%esp
  80064e:	84 c0                	test   %al,%al
  800650:	75 19                	jne    80066b <bc_init+0x1f1>
  800652:	68 3f 3a 80 00       	push   $0x803a3f
  800657:	68 fd 38 80 00       	push   $0x8038fd
  80065c:	68 80 00 00 00       	push   $0x80
  800661:	68 d0 39 80 00       	push   $0x8039d0
  800666:	e8 42 14 00 00       	call   801aad <_panic>
	// Skip the !va_is_dirty() check because it makes the bug somewhat
	// obscure and hence harder to debug.
	//assert(!va_is_dirty(diskaddr(1)));

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  80066b:	83 ec 0c             	sub    $0xc,%esp
  80066e:	6a 01                	push   $0x1
  800670:	e8 04 fd ff ff       	call   800379 <diskaddr>
  800675:	83 c4 08             	add    $0x8,%esp
  800678:	50                   	push   %eax
  800679:	6a 00                	push   $0x0
  80067b:	e8 92 1f 00 00       	call   802612 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800680:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800687:	e8 ed fc ff ff       	call   800379 <diskaddr>
  80068c:	89 04 24             	mov    %eax,(%esp)
  80068f:	e8 1d fd ff ff       	call   8003b1 <va_is_mapped>
  800694:	83 c4 10             	add    $0x10,%esp
  800697:	84 c0                	test   %al,%al
  800699:	74 19                	je     8006b4 <bc_init+0x23a>
  80069b:	68 3e 3a 80 00       	push   $0x803a3e
  8006a0:	68 fd 38 80 00       	push   $0x8038fd
  8006a5:	68 88 00 00 00       	push   $0x88
  8006aa:	68 d0 39 80 00       	push   $0x8039d0
  8006af:	e8 f9 13 00 00       	call   801aad <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8006b4:	83 ec 0c             	sub    $0xc,%esp
  8006b7:	6a 01                	push   $0x1
  8006b9:	e8 bb fc ff ff       	call   800379 <diskaddr>
  8006be:	83 c4 08             	add    $0x8,%esp
  8006c1:	68 1d 3a 80 00       	push   $0x803a1d
  8006c6:	50                   	push   %eax
  8006c7:	e8 68 1b 00 00       	call   802234 <strcmp>
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	74 19                	je     8006ec <bc_init+0x272>
  8006d3:	68 ac 39 80 00       	push   $0x8039ac
  8006d8:	68 fd 38 80 00       	push   $0x8038fd
  8006dd:	68 8b 00 00 00       	push   $0x8b
  8006e2:	68 d0 39 80 00       	push   $0x8039d0
  8006e7:	e8 c1 13 00 00       	call   801aad <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  8006ec:	83 ec 0c             	sub    $0xc,%esp
  8006ef:	6a 01                	push   $0x1
  8006f1:	e8 83 fc ff ff       	call   800379 <diskaddr>
  8006f6:	83 c4 0c             	add    $0xc,%esp
  8006f9:	68 08 01 00 00       	push   $0x108
  8006fe:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  800704:	52                   	push   %edx
  800705:	50                   	push   %eax
  800706:	e8 11 1c 00 00       	call   80231c <memmove>
	flush_block(diskaddr(1));
  80070b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800712:	e8 62 fc ff ff       	call   800379 <diskaddr>
  800717:	89 04 24             	mov    %eax,(%esp)
  80071a:	e8 d8 fc ff ff       	call   8003f7 <flush_block>

	cprintf("block cache is good\n");
  80071f:	c7 04 24 59 3a 80 00 	movl   $0x803a59,(%esp)
  800726:	e8 5b 14 00 00       	call   801b86 <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  80072b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800732:	e8 42 fc ff ff       	call   800379 <diskaddr>
  800737:	83 c4 0c             	add    $0xc,%esp
  80073a:	68 08 01 00 00       	push   $0x108
  80073f:	50                   	push   %eax
  800740:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800746:	50                   	push   %eax
  800747:	e8 d0 1b 00 00       	call   80231c <memmove>
}
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  80075a:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80075f:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800765:	74 14                	je     80077b <check_super+0x27>
		panic("bad file system magic number");
  800767:	83 ec 04             	sub    $0x4,%esp
  80076a:	68 6e 3a 80 00       	push   $0x803a6e
  80076f:	6a 0f                	push   $0xf
  800771:	68 8b 3a 80 00       	push   $0x803a8b
  800776:	e8 32 13 00 00       	call   801aad <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  80077b:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  800782:	76 14                	jbe    800798 <check_super+0x44>
		panic("file system is too large");
  800784:	83 ec 04             	sub    $0x4,%esp
  800787:	68 93 3a 80 00       	push   $0x803a93
  80078c:	6a 12                	push   $0x12
  80078e:	68 8b 3a 80 00       	push   $0x803a8b
  800793:	e8 15 13 00 00       	call   801aad <_panic>

	cprintf("superblock is good\n");
  800798:	83 ec 0c             	sub    $0xc,%esp
  80079b:	68 ac 3a 80 00       	push   $0x803aac
  8007a0:	e8 e1 13 00 00       	call   801b86 <cprintf>
}
  8007a5:	83 c4 10             	add    $0x10,%esp
  8007a8:	c9                   	leave  
  8007a9:	c3                   	ret    

008007aa <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	53                   	push   %ebx
  8007ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  8007b1:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8007b7:	85 d2                	test   %edx,%edx
  8007b9:	74 24                	je     8007df <block_is_free+0x35>
		return 0;
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  8007c0:	39 4a 04             	cmp    %ecx,0x4(%edx)
  8007c3:	76 1f                	jbe    8007e4 <block_is_free+0x3a>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  8007c5:	89 cb                	mov    %ecx,%ebx
  8007c7:	c1 eb 05             	shr    $0x5,%ebx
  8007ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8007cf:	d3 e0                	shl    %cl,%eax
  8007d1:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  8007d7:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  8007da:	0f 95 c0             	setne  %al
  8007dd:	eb 05                	jmp    8007e4 <block_is_free+0x3a>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  8007df:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  8007e4:	5b                   	pop    %ebx
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	53                   	push   %ebx
  8007eb:	83 ec 04             	sub    $0x4,%esp
  8007ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  8007f1:	85 c9                	test   %ecx,%ecx
  8007f3:	75 14                	jne    800809 <free_block+0x22>
		panic("attempt to free zero block");
  8007f5:	83 ec 04             	sub    $0x4,%esp
  8007f8:	68 c0 3a 80 00       	push   $0x803ac0
  8007fd:	6a 2d                	push   $0x2d
  8007ff:	68 8b 3a 80 00       	push   $0x803a8b
  800804:	e8 a4 12 00 00       	call   801aad <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800809:	89 cb                	mov    %ecx,%ebx
  80080b:	c1 eb 05             	shr    $0x5,%ebx
  80080e:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  800814:	b8 01 00 00 00       	mov    $0x1,%eax
  800819:	d3 e0                	shl    %cl,%eax
  80081b:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  80081e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800821:	c9                   	leave  
  800822:	c3                   	ret    

00800823 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	57                   	push   %edi
  800827:	56                   	push   %esi
  800828:	53                   	push   %ebx
  800829:	83 ec 0c             	sub    $0xc,%esp
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	for(int i=0;i<super->s_nblocks;i++){
  80082c:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800831:	8b 70 04             	mov    0x4(%eax),%esi
  800834:	bb 00 00 00 00       	mov    $0x0,%ebx
  800839:	eb 53                	jmp    80088e <alloc_block+0x6b>
		if(block_is_free(i)){
  80083b:	53                   	push   %ebx
  80083c:	e8 69 ff ff ff       	call   8007aa <block_is_free>
  800841:	83 c4 04             	add    $0x4,%esp
  800844:	84 c0                	test   %al,%al
  800846:	74 43                	je     80088b <alloc_block+0x68>
			bitmap[i/32] ^= (1<<(i%32));
  800848:	8d 43 1f             	lea    0x1f(%ebx),%eax
  80084b:	85 db                	test   %ebx,%ebx
  80084d:	0f 49 c3             	cmovns %ebx,%eax
  800850:	c1 f8 05             	sar    $0x5,%eax
  800853:	8b 35 04 a0 80 00    	mov    0x80a004,%esi
  800859:	89 da                	mov    %ebx,%edx
  80085b:	c1 fa 1f             	sar    $0x1f,%edx
  80085e:	c1 ea 1b             	shr    $0x1b,%edx
  800861:	8d 0c 13             	lea    (%ebx,%edx,1),%ecx
  800864:	83 e1 1f             	and    $0x1f,%ecx
  800867:	29 d1                	sub    %edx,%ecx
  800869:	ba 01 00 00 00       	mov    $0x1,%edx
  80086e:	d3 e2                	shl    %cl,%edx
  800870:	31 14 86             	xor    %edx,(%esi,%eax,4)
			flush_block(diskaddr(i));
  800873:	83 ec 0c             	sub    $0xc,%esp
  800876:	57                   	push   %edi
  800877:	e8 fd fa ff ff       	call   800379 <diskaddr>
  80087c:	89 04 24             	mov    %eax,(%esp)
  80087f:	e8 73 fb ff ff       	call   8003f7 <flush_block>
			return i;
  800884:	83 c4 10             	add    $0x10,%esp
  800887:	89 d8                	mov    %ebx,%eax
  800889:	eb 0e                	jmp    800899 <alloc_block+0x76>
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	for(int i=0;i<super->s_nblocks;i++){
  80088b:	83 c3 01             	add    $0x1,%ebx
  80088e:	89 df                	mov    %ebx,%edi
  800890:	39 f3                	cmp    %esi,%ebx
  800892:	75 a7                	jne    80083b <alloc_block+0x18>
			flush_block(diskaddr(i));
			return i;
		}
	}
	//panic("alloc_block not implemented");
	return -E_NO_DISK;
  800894:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  800899:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80089c:	5b                   	pop    %ebx
  80089d:	5e                   	pop    %esi
  80089e:	5f                   	pop    %edi
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	57                   	push   %edi
  8008a5:	56                   	push   %esi
  8008a6:	53                   	push   %ebx
  8008a7:	83 ec 1c             	sub    $0x1c,%esp
  8008aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
       // LAB 5: Your code here.
	   if(filebno>=NDIRECT+NINDIRECT)return -E_INVAL;
  8008ad:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  8008b3:	0f 87 9f 00 00 00    	ja     800958 <file_block_walk+0xb7>
	   if(filebno<NDIRECT){
  8008b9:	83 fa 09             	cmp    $0x9,%edx
  8008bc:	77 1b                	ja     8008d9 <file_block_walk+0x38>
		   if(ppdiskbno){
  8008be:	85 c9                	test   %ecx,%ecx
  8008c0:	0f 84 99 00 00 00    	je     80095f <file_block_walk+0xbe>
			   *ppdiskbno=&f->f_direct[filebno];
  8008c6:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  8008cd:	89 01                	mov    %eax,(%ecx)
		   }
		   return 0;
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d4:	e9 99 00 00 00       	jmp    800972 <file_block_walk+0xd1>
  8008d9:	89 ce                	mov    %ecx,%esi
  8008db:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008de:	89 c7                	mov    %eax,%edi
	   }
	   if((f->f_indirect)<=1){
  8008e0:	83 b8 b0 00 00 00 01 	cmpl   $0x1,0xb0(%eax)
  8008e7:	77 45                	ja     80092e <file_block_walk+0x8d>
		   if(alloc==0)return -E_NOT_FOUND;
  8008e9:	84 db                	test   %bl,%bl
  8008eb:	74 79                	je     800966 <file_block_walk+0xc5>
		   int r=alloc_block();
  8008ed:	e8 31 ff ff ff       	call   800823 <alloc_block>
		   if(r<=0)return -E_NO_DISK;
  8008f2:	85 c0                	test   %eax,%eax
  8008f4:	7e 77                	jle    80096d <file_block_walk+0xcc>
		   f->f_indirect=r;
  8008f6:	89 87 b0 00 00 00    	mov    %eax,0xb0(%edi)
		   memset(diskaddr(f->f_indirect), 0, BLKSIZE);
  8008fc:	83 ec 0c             	sub    $0xc,%esp
  8008ff:	50                   	push   %eax
  800900:	e8 74 fa ff ff       	call   800379 <diskaddr>
  800905:	83 c4 0c             	add    $0xc,%esp
  800908:	68 00 10 00 00       	push   $0x1000
  80090d:	6a 00                	push   $0x0
  80090f:	50                   	push   %eax
  800910:	e8 ba 19 00 00       	call   8022cf <memset>
		   flush_block(diskaddr(f->f_indirect));
  800915:	83 c4 04             	add    $0x4,%esp
  800918:	ff b7 b0 00 00 00    	pushl  0xb0(%edi)
  80091e:	e8 56 fa ff ff       	call   800379 <diskaddr>
  800923:	89 04 24             	mov    %eax,(%esp)
  800926:	e8 cc fa ff ff       	call   8003f7 <flush_block>
  80092b:	83 c4 10             	add    $0x10,%esp
	   }
		if (ppdiskbno)
            *ppdiskbno = &((uint32_t *)diskaddr(f->f_indirect))[filebno-NDIRECT];
	   return 0;
  80092e:	b8 00 00 00 00       	mov    $0x0,%eax
		   if(r<=0)return -E_NO_DISK;
		   f->f_indirect=r;
		   memset(diskaddr(f->f_indirect), 0, BLKSIZE);
		   flush_block(diskaddr(f->f_indirect));
	   }
		if (ppdiskbno)
  800933:	85 f6                	test   %esi,%esi
  800935:	74 3b                	je     800972 <file_block_walk+0xd1>
            *ppdiskbno = &((uint32_t *)diskaddr(f->f_indirect))[filebno-NDIRECT];
  800937:	83 ec 0c             	sub    $0xc,%esp
  80093a:	ff b7 b0 00 00 00    	pushl  0xb0(%edi)
  800940:	e8 34 fa ff ff       	call   800379 <diskaddr>
  800945:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800948:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  80094c:	89 06                	mov    %eax,(%esi)
  80094e:	83 c4 10             	add    $0x10,%esp
	   return 0;
  800951:	b8 00 00 00 00       	mov    $0x0,%eax
  800956:	eb 1a                	jmp    800972 <file_block_walk+0xd1>
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
       // LAB 5: Your code here.
	   if(filebno>=NDIRECT+NINDIRECT)return -E_INVAL;
  800958:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80095d:	eb 13                	jmp    800972 <file_block_walk+0xd1>
	   if(filebno<NDIRECT){
		   if(ppdiskbno){
			   *ppdiskbno=&f->f_direct[filebno];
		   }
		   return 0;
  80095f:	b8 00 00 00 00       	mov    $0x0,%eax
  800964:	eb 0c                	jmp    800972 <file_block_walk+0xd1>
	   }
	   if((f->f_indirect)<=1){
		   if(alloc==0)return -E_NOT_FOUND;
  800966:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  80096b:	eb 05                	jmp    800972 <file_block_walk+0xd1>
		   int r=alloc_block();
		   if(r<=0)return -E_NO_DISK;
  80096d:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
	   }
		if (ppdiskbno)
            *ppdiskbno = &((uint32_t *)diskaddr(f->f_indirect))[filebno-NDIRECT];
	   return 0;
       //panic("file_block_walk not implemented");
}
  800972:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800975:	5b                   	pop    %ebx
  800976:	5e                   	pop    %esi
  800977:	5f                   	pop    %edi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	56                   	push   %esi
  80097e:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  80097f:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800984:	8b 70 04             	mov    0x4(%eax),%esi
  800987:	bb 00 00 00 00       	mov    $0x0,%ebx
  80098c:	eb 29                	jmp    8009b7 <check_bitmap+0x3d>
		assert(!block_is_free(2+i));
  80098e:	8d 43 02             	lea    0x2(%ebx),%eax
  800991:	50                   	push   %eax
  800992:	e8 13 fe ff ff       	call   8007aa <block_is_free>
  800997:	83 c4 04             	add    $0x4,%esp
  80099a:	84 c0                	test   %al,%al
  80099c:	74 16                	je     8009b4 <check_bitmap+0x3a>
  80099e:	68 db 3a 80 00       	push   $0x803adb
  8009a3:	68 fd 38 80 00       	push   $0x8038fd
  8009a8:	6a 57                	push   $0x57
  8009aa:	68 8b 3a 80 00       	push   $0x803a8b
  8009af:	e8 f9 10 00 00       	call   801aad <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8009b4:	83 c3 01             	add    $0x1,%ebx
  8009b7:	89 d8                	mov    %ebx,%eax
  8009b9:	c1 e0 0f             	shl    $0xf,%eax
  8009bc:	39 f0                	cmp    %esi,%eax
  8009be:	72 ce                	jb     80098e <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  8009c0:	83 ec 0c             	sub    $0xc,%esp
  8009c3:	6a 00                	push   $0x0
  8009c5:	e8 e0 fd ff ff       	call   8007aa <block_is_free>
  8009ca:	83 c4 10             	add    $0x10,%esp
  8009cd:	84 c0                	test   %al,%al
  8009cf:	74 16                	je     8009e7 <check_bitmap+0x6d>
  8009d1:	68 ef 3a 80 00       	push   $0x803aef
  8009d6:	68 fd 38 80 00       	push   $0x8038fd
  8009db:	6a 5a                	push   $0x5a
  8009dd:	68 8b 3a 80 00       	push   $0x803a8b
  8009e2:	e8 c6 10 00 00       	call   801aad <_panic>
	assert(!block_is_free(1));
  8009e7:	83 ec 0c             	sub    $0xc,%esp
  8009ea:	6a 01                	push   $0x1
  8009ec:	e8 b9 fd ff ff       	call   8007aa <block_is_free>
  8009f1:	83 c4 10             	add    $0x10,%esp
  8009f4:	84 c0                	test   %al,%al
  8009f6:	74 16                	je     800a0e <check_bitmap+0x94>
  8009f8:	68 01 3b 80 00       	push   $0x803b01
  8009fd:	68 fd 38 80 00       	push   $0x8038fd
  800a02:	6a 5b                	push   $0x5b
  800a04:	68 8b 3a 80 00       	push   $0x803a8b
  800a09:	e8 9f 10 00 00       	call   801aad <_panic>

	cprintf("bitmap is good\n");
  800a0e:	83 ec 0c             	sub    $0xc,%esp
  800a11:	68 13 3b 80 00       	push   $0x803b13
  800a16:	e8 6b 11 00 00       	call   801b86 <cprintf>
}
  800a1b:	83 c4 10             	add    $0x10,%esp
  800a1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a21:	5b                   	pop    %ebx
  800a22:	5e                   	pop    %esi
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available
	if (ide_probe_disk1())
  800a2b:	e8 2f f6 ff ff       	call   80005f <ide_probe_disk1>
  800a30:	84 c0                	test   %al,%al
  800a32:	74 0f                	je     800a43 <fs_init+0x1e>
		ide_set_disk(1);
  800a34:	83 ec 0c             	sub    $0xc,%esp
  800a37:	6a 01                	push   $0x1
  800a39:	e8 85 f6 ff ff       	call   8000c3 <ide_set_disk>
  800a3e:	83 c4 10             	add    $0x10,%esp
  800a41:	eb 0d                	jmp    800a50 <fs_init+0x2b>
	else
		ide_set_disk(0);
  800a43:	83 ec 0c             	sub    $0xc,%esp
  800a46:	6a 00                	push   $0x0
  800a48:	e8 76 f6 ff ff       	call   8000c3 <ide_set_disk>
  800a4d:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800a50:	e8 25 fa ff ff       	call   80047a <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800a55:	83 ec 0c             	sub    $0xc,%esp
  800a58:	6a 01                	push   $0x1
  800a5a:	e8 1a f9 ff ff       	call   800379 <diskaddr>
  800a5f:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  800a64:	e8 eb fc ff ff       	call   800754 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  800a69:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800a70:	e8 04 f9 ff ff       	call   800379 <diskaddr>
  800a75:	a3 04 a0 80 00       	mov    %eax,0x80a004
	check_bitmap();
  800a7a:	e8 fb fe ff ff       	call   80097a <check_bitmap>
	
}
  800a7f:	83 c4 10             	add    $0x10,%esp
  800a82:	c9                   	leave  
  800a83:	c3                   	ret    

00800a84 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	53                   	push   %ebx
  800a88:	83 ec 20             	sub    $0x20,%esp
  800a8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
       // LAB 5: Your code here.
       	uint32_t *ppdiskbno,blockno;
	   	int r=0;
		if ((r = file_block_walk(f, filebno, &ppdiskbno, true)) < 0)
  800a8e:	6a 01                	push   $0x1
  800a90:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800a93:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a96:	8b 45 08             	mov    0x8(%ebp),%eax
  800a99:	e8 03 fe ff ff       	call   8008a1 <file_block_walk>
  800a9e:	83 c4 10             	add    $0x10,%esp
  800aa1:	85 c0                	test   %eax,%eax
  800aa3:	78 50                	js     800af5 <file_get_block+0x71>
        	return r;
        if ((*ppdiskbno)==0) {
  800aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800aa8:	83 38 00             	cmpl   $0x0,(%eax)
  800aab:	75 28                	jne    800ad5 <file_get_block+0x51>
        	if ((r = alloc_block()) < 0)
  800aad:	e8 71 fd ff ff       	call   800823 <alloc_block>
  800ab2:	89 c2                	mov    %eax,%edx
  800ab4:	85 c0                	test   %eax,%eax
  800ab6:	78 3d                	js     800af5 <file_get_block+0x71>
            	return r;
            blockno = r;
            *ppdiskbno = blockno;
  800ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800abb:	89 10                	mov    %edx,(%eax)
            flush_block(diskaddr(*ppdiskbno));
  800abd:	83 ec 0c             	sub    $0xc,%esp
  800ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ac3:	ff 30                	pushl  (%eax)
  800ac5:	e8 af f8 ff ff       	call   800379 <diskaddr>
  800aca:	89 04 24             	mov    %eax,(%esp)
  800acd:	e8 25 f9 ff ff       	call   8003f7 <flush_block>
  800ad2:	83 c4 10             	add    $0x10,%esp
        }
        if (blk)
        	*blk = (char *)diskaddr(*ppdiskbno);
		return 0;
  800ad5:	b8 00 00 00 00       	mov    $0x0,%eax
            	return r;
            blockno = r;
            *ppdiskbno = blockno;
            flush_block(diskaddr(*ppdiskbno));
        }
        if (blk)
  800ada:	85 db                	test   %ebx,%ebx
  800adc:	74 17                	je     800af5 <file_get_block+0x71>
        	*blk = (char *)diskaddr(*ppdiskbno);
  800ade:	83 ec 0c             	sub    $0xc,%esp
  800ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ae4:	ff 30                	pushl  (%eax)
  800ae6:	e8 8e f8 ff ff       	call   800379 <diskaddr>
  800aeb:	89 03                	mov    %eax,(%ebx)
  800aed:	83 c4 10             	add    $0x10,%esp
		return 0;
  800af0:	b8 00 00 00 00       	mov    $0x0,%eax
	   //panic("file_get_block not implemented");
}
  800af5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800af8:	c9                   	leave  
  800af9:	c3                   	ret    

00800afa <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
  800b00:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  800b06:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  800b0c:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  800b12:	eb 03                	jmp    800b17 <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800b14:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800b17:	80 38 2f             	cmpb   $0x2f,(%eax)
  800b1a:	74 f8                	je     800b14 <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800b1c:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  800b22:	83 c1 08             	add    $0x8,%ecx
  800b25:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  800b2b:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800b32:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  800b38:	85 c9                	test   %ecx,%ecx
  800b3a:	74 06                	je     800b42 <walk_path+0x48>
		*pdir = 0;
  800b3c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  800b42:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800b48:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  800b4e:	ba 00 00 00 00       	mov    $0x0,%edx
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800b53:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800b59:	e9 5f 01 00 00       	jmp    800cbd <walk_path+0x1c3>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800b5e:	83 c7 01             	add    $0x1,%edi
  800b61:	eb 02                	jmp    800b65 <walk_path+0x6b>
  800b63:	89 c7                	mov    %eax,%edi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800b65:	0f b6 17             	movzbl (%edi),%edx
  800b68:	80 fa 2f             	cmp    $0x2f,%dl
  800b6b:	74 04                	je     800b71 <walk_path+0x77>
  800b6d:	84 d2                	test   %dl,%dl
  800b6f:	75 ed                	jne    800b5e <walk_path+0x64>
			path++;
		if (path - p >= MAXNAMELEN)
  800b71:	89 fb                	mov    %edi,%ebx
  800b73:	29 c3                	sub    %eax,%ebx
  800b75:	83 fb 7f             	cmp    $0x7f,%ebx
  800b78:	0f 8f 69 01 00 00    	jg     800ce7 <walk_path+0x1ed>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800b7e:	83 ec 04             	sub    $0x4,%esp
  800b81:	53                   	push   %ebx
  800b82:	50                   	push   %eax
  800b83:	56                   	push   %esi
  800b84:	e8 93 17 00 00       	call   80231c <memmove>
		name[path - p] = '\0';
  800b89:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800b90:	00 
  800b91:	83 c4 10             	add    $0x10,%esp
  800b94:	eb 03                	jmp    800b99 <walk_path+0x9f>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800b96:	83 c7 01             	add    $0x1,%edi

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800b99:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800b9c:	74 f8                	je     800b96 <walk_path+0x9c>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800b9e:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800ba4:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800bab:	0f 85 3d 01 00 00    	jne    800cee <walk_path+0x1f4>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800bb1:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800bb7:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800bbc:	74 19                	je     800bd7 <walk_path+0xdd>
  800bbe:	68 23 3b 80 00       	push   $0x803b23
  800bc3:	68 fd 38 80 00       	push   $0x8038fd
  800bc8:	68 d2 00 00 00       	push   $0xd2
  800bcd:	68 8b 3a 80 00       	push   $0x803a8b
  800bd2:	e8 d6 0e 00 00       	call   801aad <_panic>
	nblock = dir->f_size / BLKSIZE;
  800bd7:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800bdd:	85 c0                	test   %eax,%eax
  800bdf:	0f 48 c2             	cmovs  %edx,%eax
  800be2:	c1 f8 0c             	sar    $0xc,%eax
  800be5:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800beb:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800bf2:	00 00 00 
  800bf5:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
  800bfb:	eb 5e                	jmp    800c5b <walk_path+0x161>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800bfd:	83 ec 04             	sub    $0x4,%esp
  800c00:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800c06:	50                   	push   %eax
  800c07:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800c0d:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800c13:	e8 6c fe ff ff       	call   800a84 <file_get_block>
  800c18:	83 c4 10             	add    $0x10,%esp
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	0f 88 ee 00 00 00    	js     800d11 <walk_path+0x217>
			return r;
		f = (struct File*) blk;
  800c23:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800c29:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800c2f:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800c35:	83 ec 08             	sub    $0x8,%esp
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
  800c3a:	e8 f5 15 00 00       	call   802234 <strcmp>
  800c3f:	83 c4 10             	add    $0x10,%esp
  800c42:	85 c0                	test   %eax,%eax
  800c44:	0f 84 ab 00 00 00    	je     800cf5 <walk_path+0x1fb>
  800c4a:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800c50:	39 fb                	cmp    %edi,%ebx
  800c52:	75 db                	jne    800c2f <walk_path+0x135>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800c54:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800c5b:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800c61:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800c67:	75 94                	jne    800bfd <walk_path+0x103>
  800c69:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800c6f:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800c74:	80 3f 00             	cmpb   $0x0,(%edi)
  800c77:	0f 85 a3 00 00 00    	jne    800d20 <walk_path+0x226>
				if (pdir)
  800c7d:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800c83:	85 c0                	test   %eax,%eax
  800c85:	74 08                	je     800c8f <walk_path+0x195>
					*pdir = dir;
  800c87:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800c8d:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800c8f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800c93:	74 15                	je     800caa <walk_path+0x1b0>
					strcpy(lastelem, name);
  800c95:	83 ec 08             	sub    $0x8,%esp
  800c98:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800c9e:	50                   	push   %eax
  800c9f:	ff 75 08             	pushl  0x8(%ebp)
  800ca2:	e8 e3 14 00 00       	call   80218a <strcpy>
  800ca7:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800caa:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800cb0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800cb6:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800cbb:	eb 63                	jmp    800d20 <walk_path+0x226>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800cbd:	80 38 00             	cmpb   $0x0,(%eax)
  800cc0:	0f 85 9d fe ff ff    	jne    800b63 <walk_path+0x69>
			}
			return r;
		}
	}

	if (pdir)
  800cc6:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	74 02                	je     800cd2 <walk_path+0x1d8>
		*pdir = dir;
  800cd0:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800cd2:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800cd8:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800cde:	89 08                	mov    %ecx,(%eax)
	return 0;
  800ce0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce5:	eb 39                	jmp    800d20 <walk_path+0x226>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800ce7:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800cec:	eb 32                	jmp    800d20 <walk_path+0x226>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800cee:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800cf3:	eb 2b                	jmp    800d20 <walk_path+0x226>
  800cf5:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800cfb:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800d01:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800d07:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  800d0d:	89 f8                	mov    %edi,%eax
  800d0f:	eb ac                	jmp    800cbd <walk_path+0x1c3>
  800d11:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800d17:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800d1a:	0f 84 4f ff ff ff    	je     800c6f <walk_path+0x175>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800d20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800d2e:	6a 00                	push   $0x0
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	ba 00 00 00 00       	mov    $0x0,%edx
  800d38:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3b:	e8 ba fd ff ff       	call   800afa <walk_path>
}
  800d40:	c9                   	leave  
  800d41:	c3                   	ret    

00800d42 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	57                   	push   %edi
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	83 ec 2c             	sub    $0x2c,%esp
  800d4b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d4e:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800d51:	8b 45 08             	mov    0x8(%ebp),%eax
  800d54:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800d5a:	b8 00 00 00 00       	mov    $0x0,%eax
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800d5f:	39 ca                	cmp    %ecx,%edx
  800d61:	7e 7c                	jle    800ddf <file_read+0x9d>
		return 0;

	count = MIN(count, f->f_size - offset);
  800d63:	29 ca                	sub    %ecx,%edx
  800d65:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d68:	0f 47 55 10          	cmova  0x10(%ebp),%edx
  800d6c:	89 55 d0             	mov    %edx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800d6f:	89 ce                	mov    %ecx,%esi
  800d71:	01 d1                	add    %edx,%ecx
  800d73:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800d76:	eb 5d                	jmp    800dd5 <file_read+0x93>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800d78:	83 ec 04             	sub    $0x4,%esp
  800d7b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800d7e:	50                   	push   %eax
  800d7f:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800d85:	85 f6                	test   %esi,%esi
  800d87:	0f 49 c6             	cmovns %esi,%eax
  800d8a:	c1 f8 0c             	sar    $0xc,%eax
  800d8d:	50                   	push   %eax
  800d8e:	ff 75 08             	pushl  0x8(%ebp)
  800d91:	e8 ee fc ff ff       	call   800a84 <file_get_block>
  800d96:	83 c4 10             	add    $0x10,%esp
  800d99:	85 c0                	test   %eax,%eax
  800d9b:	78 42                	js     800ddf <file_read+0x9d>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800d9d:	89 f2                	mov    %esi,%edx
  800d9f:	c1 fa 1f             	sar    $0x1f,%edx
  800da2:	c1 ea 14             	shr    $0x14,%edx
  800da5:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800da8:	25 ff 0f 00 00       	and    $0xfff,%eax
  800dad:	29 d0                	sub    %edx,%eax
  800daf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800db2:	29 da                	sub    %ebx,%edx
  800db4:	bb 00 10 00 00       	mov    $0x1000,%ebx
  800db9:	29 c3                	sub    %eax,%ebx
  800dbb:	39 da                	cmp    %ebx,%edx
  800dbd:	0f 46 da             	cmovbe %edx,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800dc0:	83 ec 04             	sub    $0x4,%esp
  800dc3:	53                   	push   %ebx
  800dc4:	03 45 e4             	add    -0x1c(%ebp),%eax
  800dc7:	50                   	push   %eax
  800dc8:	57                   	push   %edi
  800dc9:	e8 4e 15 00 00       	call   80231c <memmove>
		pos += bn;
  800dce:	01 de                	add    %ebx,%esi
		buf += bn;
  800dd0:	01 df                	add    %ebx,%edi
  800dd2:	83 c4 10             	add    $0x10,%esp
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800dd5:	89 f3                	mov    %esi,%ebx
  800dd7:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800dda:	77 9c                	ja     800d78 <file_read+0x36>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800ddc:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800ddf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	57                   	push   %edi
  800deb:	56                   	push   %esi
  800dec:	53                   	push   %ebx
  800ded:	83 ec 2c             	sub    $0x2c,%esp
  800df0:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800df3:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800df9:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800dfc:	0f 8e a7 00 00 00    	jle    800ea9 <file_set_size+0xc2>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800e02:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800e08:	05 ff 0f 00 00       	add    $0xfff,%eax
  800e0d:	0f 49 f8             	cmovns %eax,%edi
  800e10:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800e13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e16:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800e1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e1e:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800e24:	0f 49 c2             	cmovns %edx,%eax
  800e27:	c1 f8 0c             	sar    $0xc,%eax
  800e2a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800e2d:	89 c3                	mov    %eax,%ebx
  800e2f:	eb 39                	jmp    800e6a <file_set_size+0x83>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800e31:	83 ec 0c             	sub    $0xc,%esp
  800e34:	6a 00                	push   $0x0
  800e36:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800e39:	89 da                	mov    %ebx,%edx
  800e3b:	89 f0                	mov    %esi,%eax
  800e3d:	e8 5f fa ff ff       	call   8008a1 <file_block_walk>
  800e42:	83 c4 10             	add    $0x10,%esp
  800e45:	85 c0                	test   %eax,%eax
  800e47:	78 4d                	js     800e96 <file_set_size+0xaf>
		return r;
	if (*ptr) {
  800e49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e4c:	8b 00                	mov    (%eax),%eax
  800e4e:	85 c0                	test   %eax,%eax
  800e50:	74 15                	je     800e67 <file_set_size+0x80>
		free_block(*ptr);
  800e52:	83 ec 0c             	sub    $0xc,%esp
  800e55:	50                   	push   %eax
  800e56:	e8 8c f9 ff ff       	call   8007e7 <free_block>
		*ptr = 0;
  800e5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e5e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800e64:	83 c4 10             	add    $0x10,%esp
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800e67:	83 c3 01             	add    $0x1,%ebx
  800e6a:	39 df                	cmp    %ebx,%edi
  800e6c:	77 c3                	ja     800e31 <file_set_size+0x4a>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800e6e:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800e72:	77 35                	ja     800ea9 <file_set_size+0xc2>
  800e74:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800e7a:	85 c0                	test   %eax,%eax
  800e7c:	74 2b                	je     800ea9 <file_set_size+0xc2>
		free_block(f->f_indirect);
  800e7e:	83 ec 0c             	sub    $0xc,%esp
  800e81:	50                   	push   %eax
  800e82:	e8 60 f9 ff ff       	call   8007e7 <free_block>
		f->f_indirect = 0;
  800e87:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800e8e:	00 00 00 
  800e91:	83 c4 10             	add    $0x10,%esp
  800e94:	eb 13                	jmp    800ea9 <file_set_size+0xc2>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800e96:	83 ec 08             	sub    $0x8,%esp
  800e99:	50                   	push   %eax
  800e9a:	68 40 3b 80 00       	push   $0x803b40
  800e9f:	e8 e2 0c 00 00       	call   801b86 <cprintf>
  800ea4:	83 c4 10             	add    $0x10,%esp
  800ea7:	eb be                	jmp    800e67 <file_set_size+0x80>
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800ea9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eac:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800eb2:	83 ec 0c             	sub    $0xc,%esp
  800eb5:	56                   	push   %esi
  800eb6:	e8 3c f5 ff ff       	call   8003f7 <flush_block>
	return 0;
}
  800ebb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec3:	5b                   	pop    %ebx
  800ec4:	5e                   	pop    %esi
  800ec5:	5f                   	pop    %edi
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    

00800ec8 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	57                   	push   %edi
  800ecc:	56                   	push   %esi
  800ecd:	53                   	push   %ebx
  800ece:	83 ec 2c             	sub    $0x2c,%esp
  800ed1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ed4:	8b 75 14             	mov    0x14(%ebp),%esi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800ed7:	89 f0                	mov    %esi,%eax
  800ed9:	03 45 10             	add    0x10(%ebp),%eax
  800edc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800edf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee2:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800ee8:	76 72                	jbe    800f5c <file_write+0x94>
		if ((r = file_set_size(f, offset + count)) < 0)
  800eea:	83 ec 08             	sub    $0x8,%esp
  800eed:	50                   	push   %eax
  800eee:	51                   	push   %ecx
  800eef:	e8 f3 fe ff ff       	call   800de7 <file_set_size>
  800ef4:	83 c4 10             	add    $0x10,%esp
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	79 61                	jns    800f5c <file_write+0x94>
  800efb:	eb 69                	jmp    800f66 <file_write+0x9e>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800efd:	83 ec 04             	sub    $0x4,%esp
  800f00:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f03:	50                   	push   %eax
  800f04:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800f0a:	85 f6                	test   %esi,%esi
  800f0c:	0f 49 c6             	cmovns %esi,%eax
  800f0f:	c1 f8 0c             	sar    $0xc,%eax
  800f12:	50                   	push   %eax
  800f13:	ff 75 08             	pushl  0x8(%ebp)
  800f16:	e8 69 fb ff ff       	call   800a84 <file_get_block>
  800f1b:	83 c4 10             	add    $0x10,%esp
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	78 44                	js     800f66 <file_write+0x9e>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800f22:	89 f2                	mov    %esi,%edx
  800f24:	c1 fa 1f             	sar    $0x1f,%edx
  800f27:	c1 ea 14             	shr    $0x14,%edx
  800f2a:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800f2d:	25 ff 0f 00 00       	and    $0xfff,%eax
  800f32:	29 d0                	sub    %edx,%eax
  800f34:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800f37:	29 d9                	sub    %ebx,%ecx
  800f39:	89 cb                	mov    %ecx,%ebx
  800f3b:	ba 00 10 00 00       	mov    $0x1000,%edx
  800f40:	29 c2                	sub    %eax,%edx
  800f42:	39 d1                	cmp    %edx,%ecx
  800f44:	0f 47 da             	cmova  %edx,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  800f47:	83 ec 04             	sub    $0x4,%esp
  800f4a:	53                   	push   %ebx
  800f4b:	57                   	push   %edi
  800f4c:	03 45 e4             	add    -0x1c(%ebp),%eax
  800f4f:	50                   	push   %eax
  800f50:	e8 c7 13 00 00       	call   80231c <memmove>
		pos += bn;
  800f55:	01 de                	add    %ebx,%esi
		buf += bn;
  800f57:	01 df                	add    %ebx,%edi
  800f59:	83 c4 10             	add    $0x10,%esp
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800f5c:	89 f3                	mov    %esi,%ebx
  800f5e:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800f61:	77 9a                	ja     800efd <file_write+0x35>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800f63:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800f66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f69:	5b                   	pop    %ebx
  800f6a:	5e                   	pop    %esi
  800f6b:	5f                   	pop    %edi
  800f6c:	5d                   	pop    %ebp
  800f6d:	c3                   	ret    

00800f6e <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	56                   	push   %esi
  800f72:	53                   	push   %ebx
  800f73:	83 ec 10             	sub    $0x10,%esp
  800f76:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800f79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7e:	eb 3c                	jmp    800fbc <file_flush+0x4e>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800f80:	83 ec 0c             	sub    $0xc,%esp
  800f83:	6a 00                	push   $0x0
  800f85:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800f88:	89 da                	mov    %ebx,%edx
  800f8a:	89 f0                	mov    %esi,%eax
  800f8c:	e8 10 f9 ff ff       	call   8008a1 <file_block_walk>
  800f91:	83 c4 10             	add    $0x10,%esp
  800f94:	85 c0                	test   %eax,%eax
  800f96:	78 21                	js     800fb9 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	74 1a                	je     800fb9 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800f9f:	8b 00                	mov    (%eax),%eax
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	74 14                	je     800fb9 <file_flush+0x4b>
			continue;
		flush_block(diskaddr(*pdiskbno));
  800fa5:	83 ec 0c             	sub    $0xc,%esp
  800fa8:	50                   	push   %eax
  800fa9:	e8 cb f3 ff ff       	call   800379 <diskaddr>
  800fae:	89 04 24             	mov    %eax,(%esp)
  800fb1:	e8 41 f4 ff ff       	call   8003f7 <flush_block>
  800fb6:	83 c4 10             	add    $0x10,%esp
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800fb9:	83 c3 01             	add    $0x1,%ebx
  800fbc:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  800fc2:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  800fc8:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  800fce:	85 c9                	test   %ecx,%ecx
  800fd0:	0f 49 c1             	cmovns %ecx,%eax
  800fd3:	c1 f8 0c             	sar    $0xc,%eax
  800fd6:	39 c3                	cmp    %eax,%ebx
  800fd8:	7c a6                	jl     800f80 <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800fda:	83 ec 0c             	sub    $0xc,%esp
  800fdd:	56                   	push   %esi
  800fde:	e8 14 f4 ff ff       	call   8003f7 <flush_block>
	if (f->f_indirect)
  800fe3:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800fe9:	83 c4 10             	add    $0x10,%esp
  800fec:	85 c0                	test   %eax,%eax
  800fee:	74 14                	je     801004 <file_flush+0x96>
		flush_block(diskaddr(f->f_indirect));
  800ff0:	83 ec 0c             	sub    $0xc,%esp
  800ff3:	50                   	push   %eax
  800ff4:	e8 80 f3 ff ff       	call   800379 <diskaddr>
  800ff9:	89 04 24             	mov    %eax,(%esp)
  800ffc:	e8 f6 f3 ff ff       	call   8003f7 <flush_block>
  801001:	83 c4 10             	add    $0x10,%esp
}
  801004:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801007:	5b                   	pop    %ebx
  801008:	5e                   	pop    %esi
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    

0080100b <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	57                   	push   %edi
  80100f:	56                   	push   %esi
  801010:	53                   	push   %ebx
  801011:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  801017:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80101d:	50                   	push   %eax
  80101e:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  801024:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  80102a:	8b 45 08             	mov    0x8(%ebp),%eax
  80102d:	e8 c8 fa ff ff       	call   800afa <walk_path>
  801032:	83 c4 10             	add    $0x10,%esp
  801035:	85 c0                	test   %eax,%eax
  801037:	0f 84 d1 00 00 00    	je     80110e <file_create+0x103>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  80103d:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801040:	0f 85 0c 01 00 00    	jne    801152 <file_create+0x147>
  801046:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  80104c:	85 f6                	test   %esi,%esi
  80104e:	0f 84 c1 00 00 00    	je     801115 <file_create+0x10a>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  801054:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  80105a:	a9 ff 0f 00 00       	test   $0xfff,%eax
  80105f:	74 19                	je     80107a <file_create+0x6f>
  801061:	68 23 3b 80 00       	push   $0x803b23
  801066:	68 fd 38 80 00       	push   $0x8038fd
  80106b:	68 eb 00 00 00       	push   $0xeb
  801070:	68 8b 3a 80 00       	push   $0x803a8b
  801075:	e8 33 0a 00 00       	call   801aad <_panic>
	nblock = dir->f_size / BLKSIZE;
  80107a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  801080:	85 c0                	test   %eax,%eax
  801082:	0f 48 c2             	cmovs  %edx,%eax
  801085:	c1 f8 0c             	sar    $0xc,%eax
  801088:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  80108e:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((r = file_get_block(dir, i, &blk)) < 0)
  801093:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  801099:	eb 3b                	jmp    8010d6 <file_create+0xcb>
  80109b:	83 ec 04             	sub    $0x4,%esp
  80109e:	57                   	push   %edi
  80109f:	53                   	push   %ebx
  8010a0:	56                   	push   %esi
  8010a1:	e8 de f9 ff ff       	call   800a84 <file_get_block>
  8010a6:	83 c4 10             	add    $0x10,%esp
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	0f 88 a1 00 00 00    	js     801152 <file_create+0x147>
			return r;
		f = (struct File*) blk;
  8010b1:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  8010b7:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  8010bd:	80 38 00             	cmpb   $0x0,(%eax)
  8010c0:	75 08                	jne    8010ca <file_create+0xbf>
				*file = &f[j];
  8010c2:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  8010c8:	eb 52                	jmp    80111c <file_create+0x111>
  8010ca:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  8010cf:	39 d0                	cmp    %edx,%eax
  8010d1:	75 ea                	jne    8010bd <file_create+0xb2>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  8010d3:	83 c3 01             	add    $0x1,%ebx
  8010d6:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  8010dc:	75 bd                	jne    80109b <file_create+0x90>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  8010de:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  8010e5:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  8010e8:	83 ec 04             	sub    $0x4,%esp
  8010eb:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  8010f1:	50                   	push   %eax
  8010f2:	53                   	push   %ebx
  8010f3:	56                   	push   %esi
  8010f4:	e8 8b f9 ff ff       	call   800a84 <file_get_block>
  8010f9:	83 c4 10             	add    $0x10,%esp
  8010fc:	85 c0                	test   %eax,%eax
  8010fe:	78 52                	js     801152 <file_create+0x147>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  801100:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801106:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  80110c:	eb 0e                	jmp    80111c <file_create+0x111>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  80110e:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  801113:	eb 3d                	jmp    801152 <file_create+0x147>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  801115:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  80111a:	eb 36                	jmp    801152 <file_create+0x147>
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  80111c:	83 ec 08             	sub    $0x8,%esp
  80111f:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801125:	50                   	push   %eax
  801126:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  80112c:	e8 59 10 00 00       	call   80218a <strcpy>
	*pf = f;
  801131:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  801137:	8b 45 0c             	mov    0xc(%ebp),%eax
  80113a:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  80113c:	83 c4 04             	add    $0x4,%esp
  80113f:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  801145:	e8 24 fe ff ff       	call   800f6e <file_flush>
	return 0;
  80114a:	83 c4 10             	add    $0x10,%esp
  80114d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801152:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801155:	5b                   	pop    %ebx
  801156:	5e                   	pop    %esi
  801157:	5f                   	pop    %edi
  801158:	5d                   	pop    %ebp
  801159:	c3                   	ret    

0080115a <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
  80115d:	53                   	push   %ebx
  80115e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801161:	bb 01 00 00 00       	mov    $0x1,%ebx
  801166:	eb 17                	jmp    80117f <fs_sync+0x25>
		flush_block(diskaddr(i));
  801168:	83 ec 0c             	sub    $0xc,%esp
  80116b:	53                   	push   %ebx
  80116c:	e8 08 f2 ff ff       	call   800379 <diskaddr>
  801171:	89 04 24             	mov    %eax,(%esp)
  801174:	e8 7e f2 ff ff       	call   8003f7 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801179:	83 c3 01             	add    $0x1,%ebx
  80117c:	83 c4 10             	add    $0x10,%esp
  80117f:	a1 08 a0 80 00       	mov    0x80a008,%eax
  801184:	39 58 04             	cmp    %ebx,0x4(%eax)
  801187:	77 df                	ja     801168 <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  801189:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80118c:	c9                   	leave  
  80118d:	c3                   	ret    

0080118e <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  80118e:	55                   	push   %ebp
  80118f:	89 e5                	mov    %esp,%ebp
  801191:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  801194:	e8 c1 ff ff ff       	call   80115a <fs_sync>
	return 0;
}
  801199:	b8 00 00 00 00       	mov    $0x0,%eax
  80119e:	c9                   	leave  
  80119f:	c3                   	ret    

008011a0 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	ba 60 50 80 00       	mov    $0x805060,%edx
	int i;
	uintptr_t va = FILEVA;
  8011a8:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  8011ad:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  8011b2:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  8011b4:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  8011b7:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  8011bd:	83 c0 01             	add    $0x1,%eax
  8011c0:	83 c2 10             	add    $0x10,%edx
  8011c3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011c8:	75 e8                	jne    8011b2 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  8011ca:	5d                   	pop    %ebp
  8011cb:	c3                   	ret    

008011cc <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	56                   	push   %esi
  8011d0:	53                   	push   %ebx
  8011d1:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8011d4:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  8011d9:	83 ec 0c             	sub    $0xc,%esp
  8011dc:	89 d8                	mov    %ebx,%eax
  8011de:	c1 e0 04             	shl    $0x4,%eax
  8011e1:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  8011e7:	e8 1a 1f 00 00       	call   803106 <pageref>
  8011ec:	83 c4 10             	add    $0x10,%esp
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	74 07                	je     8011fa <openfile_alloc+0x2e>
  8011f3:	83 f8 01             	cmp    $0x1,%eax
  8011f6:	74 20                	je     801218 <openfile_alloc+0x4c>
  8011f8:	eb 51                	jmp    80124b <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  8011fa:	83 ec 04             	sub    $0x4,%esp
  8011fd:	6a 07                	push   $0x7
  8011ff:	89 d8                	mov    %ebx,%eax
  801201:	c1 e0 04             	shl    $0x4,%eax
  801204:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  80120a:	6a 00                	push   $0x0
  80120c:	e8 7c 13 00 00       	call   80258d <sys_page_alloc>
  801211:	83 c4 10             	add    $0x10,%esp
  801214:	85 c0                	test   %eax,%eax
  801216:	78 43                	js     80125b <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  801218:	c1 e3 04             	shl    $0x4,%ebx
  80121b:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  801221:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  801228:	04 00 00 
			*o = &opentab[i];
  80122b:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  80122d:	83 ec 04             	sub    $0x4,%esp
  801230:	68 00 10 00 00       	push   $0x1000
  801235:	6a 00                	push   $0x0
  801237:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  80123d:	e8 8d 10 00 00       	call   8022cf <memset>
			return (*o)->o_fileid;
  801242:	8b 06                	mov    (%esi),%eax
  801244:	8b 00                	mov    (%eax),%eax
  801246:	83 c4 10             	add    $0x10,%esp
  801249:	eb 10                	jmp    80125b <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  80124b:	83 c3 01             	add    $0x1,%ebx
  80124e:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801254:	75 83                	jne    8011d9 <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  801256:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80125b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80125e:	5b                   	pop    %ebx
  80125f:	5e                   	pop    %esi
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    

00801262 <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	57                   	push   %edi
  801266:	56                   	push   %esi
  801267:	53                   	push   %ebx
  801268:	83 ec 18             	sub    $0x18,%esp
  80126b:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  80126e:	89 fb                	mov    %edi,%ebx
  801270:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801276:	89 de                	mov    %ebx,%esi
  801278:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  80127b:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801281:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801287:	e8 7a 1e 00 00       	call   803106 <pageref>
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	83 f8 01             	cmp    $0x1,%eax
  801292:	7e 17                	jle    8012ab <openfile_lookup+0x49>
  801294:	c1 e3 04             	shl    $0x4,%ebx
  801297:	3b bb 60 50 80 00    	cmp    0x805060(%ebx),%edi
  80129d:	75 13                	jne    8012b2 <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  80129f:	8b 45 10             	mov    0x10(%ebp),%eax
  8012a2:	89 30                	mov    %esi,(%eax)
	return 0;
  8012a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a9:	eb 0c                	jmp    8012b7 <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  8012ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b0:	eb 05                	jmp    8012b7 <openfile_lookup+0x55>
  8012b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  8012b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ba:	5b                   	pop    %ebx
  8012bb:	5e                   	pop    %esi
  8012bc:	5f                   	pop    %edi
  8012bd:	5d                   	pop    %ebp
  8012be:	c3                   	ret    

008012bf <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
  8012c2:	53                   	push   %ebx
  8012c3:	83 ec 18             	sub    $0x18,%esp
  8012c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8012c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012cc:	50                   	push   %eax
  8012cd:	ff 33                	pushl  (%ebx)
  8012cf:	ff 75 08             	pushl  0x8(%ebp)
  8012d2:	e8 8b ff ff ff       	call   801262 <openfile_lookup>
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	78 14                	js     8012f2 <serve_set_size+0x33>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  8012de:	83 ec 08             	sub    $0x8,%esp
  8012e1:	ff 73 04             	pushl  0x4(%ebx)
  8012e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e7:	ff 70 04             	pushl  0x4(%eax)
  8012ea:	e8 f8 fa ff ff       	call   800de7 <file_set_size>
  8012ef:	83 c4 10             	add    $0x10,%esp
}
  8012f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f5:	c9                   	leave  
  8012f6:	c3                   	ret    

008012f7 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8012f7:	55                   	push   %ebp
  8012f8:	89 e5                	mov    %esp,%ebp
  8012fa:	53                   	push   %ebx
  8012fb:	83 ec 18             	sub    $0x18,%esp
  8012fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
	int r=0;
	struct OpenFile *o;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801301:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801304:	50                   	push   %eax
  801305:	ff 33                	pushl  (%ebx)
  801307:	ff 75 08             	pushl  0x8(%ebp)
  80130a:	e8 53 ff ff ff       	call   801262 <openfile_lookup>
  80130f:	83 c4 10             	add    $0x10,%esp
		return r;
  801312:	89 c2                	mov    %eax,%edx
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
	int r=0;
	struct OpenFile *o;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801314:	85 c0                	test   %eax,%eax
  801316:	78 2b                	js     801343 <serve_read+0x4c>
		return r;
	r=file_read(o->o_file,ipc->readRet.ret_buf,ipc->read.req_n,o->o_fd->fd_offset);
  801318:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80131b:	8b 50 0c             	mov    0xc(%eax),%edx
  80131e:	ff 72 04             	pushl  0x4(%edx)
  801321:	ff 73 04             	pushl  0x4(%ebx)
  801324:	53                   	push   %ebx
  801325:	ff 70 04             	pushl  0x4(%eax)
  801328:	e8 15 fa ff ff       	call   800d42 <file_read>
	if(r>=0)o->o_fd->fd_offset+=r;
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	85 c0                	test   %eax,%eax
  801332:	78 0d                	js     801341 <serve_read+0x4a>
  801334:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801337:	8b 52 0c             	mov    0xc(%edx),%edx
  80133a:	01 42 04             	add    %eax,0x4(%edx)
	return r;
  80133d:	89 c2                	mov    %eax,%edx
  80133f:	eb 02                	jmp    801343 <serve_read+0x4c>
  801341:	89 c2                	mov    %eax,%edx
}
  801343:	89 d0                	mov    %edx,%eax
  801345:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801348:	c9                   	leave  
  801349:	c3                   	ret    

0080134a <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	53                   	push   %ebx
  80134e:	83 ec 18             	sub    $0x18,%esp
  801351:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
	int r=0;
	struct OpenFile *o;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801354:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801357:	50                   	push   %eax
  801358:	ff 33                	pushl  (%ebx)
  80135a:	ff 75 08             	pushl  0x8(%ebp)
  80135d:	e8 00 ff ff ff       	call   801262 <openfile_lookup>
  801362:	83 c4 10             	add    $0x10,%esp
		return r;
  801365:	89 c2                	mov    %eax,%edx
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
	int r=0;
	struct OpenFile *o;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801367:	85 c0                	test   %eax,%eax
  801369:	78 2e                	js     801399 <serve_write+0x4f>
		return r;
	r=file_write(o->o_file,req->req_buf,req->req_n,o->o_fd->fd_offset);
  80136b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136e:	8b 50 0c             	mov    0xc(%eax),%edx
  801371:	ff 72 04             	pushl  0x4(%edx)
  801374:	ff 73 04             	pushl  0x4(%ebx)
  801377:	83 c3 08             	add    $0x8,%ebx
  80137a:	53                   	push   %ebx
  80137b:	ff 70 04             	pushl  0x4(%eax)
  80137e:	e8 45 fb ff ff       	call   800ec8 <file_write>
	if(r>=0)o->o_fd->fd_offset+=r;
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	85 c0                	test   %eax,%eax
  801388:	78 0d                	js     801397 <serve_write+0x4d>
  80138a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80138d:	8b 52 0c             	mov    0xc(%edx),%edx
  801390:	01 42 04             	add    %eax,0x4(%edx)
	return r;
  801393:	89 c2                	mov    %eax,%edx
  801395:	eb 02                	jmp    801399 <serve_write+0x4f>
  801397:	89 c2                	mov    %eax,%edx
	//panic("serve_write not implemented");
}
  801399:	89 d0                	mov    %edx,%eax
  80139b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139e:	c9                   	leave  
  80139f:	c3                   	ret    

008013a0 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
  8013a3:	53                   	push   %ebx
  8013a4:	83 ec 18             	sub    $0x18,%esp
  8013a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ad:	50                   	push   %eax
  8013ae:	ff 33                	pushl  (%ebx)
  8013b0:	ff 75 08             	pushl  0x8(%ebp)
  8013b3:	e8 aa fe ff ff       	call   801262 <openfile_lookup>
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	78 3f                	js     8013fe <serve_stat+0x5e>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  8013bf:	83 ec 08             	sub    $0x8,%esp
  8013c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c5:	ff 70 04             	pushl  0x4(%eax)
  8013c8:	53                   	push   %ebx
  8013c9:	e8 bc 0d 00 00       	call   80218a <strcpy>
	ret->ret_size = o->o_file->f_size;
  8013ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d1:	8b 50 04             	mov    0x4(%eax),%edx
  8013d4:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  8013da:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8013e0:	8b 40 04             	mov    0x4(%eax),%eax
  8013e3:	83 c4 10             	add    $0x10,%esp
  8013e6:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8013ed:	0f 94 c0             	sete   %al
  8013f0:	0f b6 c0             	movzbl %al,%eax
  8013f3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801401:	c9                   	leave  
  801402:	c3                   	ret    

00801403 <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  801403:	55                   	push   %ebp
  801404:	89 e5                	mov    %esp,%ebp
  801406:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801409:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140c:	50                   	push   %eax
  80140d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801410:	ff 30                	pushl  (%eax)
  801412:	ff 75 08             	pushl  0x8(%ebp)
  801415:	e8 48 fe ff ff       	call   801262 <openfile_lookup>
  80141a:	83 c4 10             	add    $0x10,%esp
  80141d:	85 c0                	test   %eax,%eax
  80141f:	78 16                	js     801437 <serve_flush+0x34>
		return r;
	file_flush(o->o_file);
  801421:	83 ec 0c             	sub    $0xc,%esp
  801424:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801427:	ff 70 04             	pushl  0x4(%eax)
  80142a:	e8 3f fb ff ff       	call   800f6e <file_flush>
	return 0;
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801437:	c9                   	leave  
  801438:	c3                   	ret    

00801439 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
  80143c:	53                   	push   %ebx
  80143d:	81 ec 18 04 00 00    	sub    $0x418,%esp
  801443:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801446:	68 00 04 00 00       	push   $0x400
  80144b:	53                   	push   %ebx
  80144c:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801452:	50                   	push   %eax
  801453:	e8 c4 0e 00 00       	call   80231c <memmove>
	path[MAXPATHLEN-1] = 0;
  801458:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  80145c:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801462:	89 04 24             	mov    %eax,(%esp)
  801465:	e8 62 fd ff ff       	call   8011cc <openfile_alloc>
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	85 c0                	test   %eax,%eax
  80146f:	0f 88 f0 00 00 00    	js     801565 <serve_open+0x12c>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  801475:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  80147c:	74 33                	je     8014b1 <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  80147e:	83 ec 08             	sub    $0x8,%esp
  801481:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801487:	50                   	push   %eax
  801488:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80148e:	50                   	push   %eax
  80148f:	e8 77 fb ff ff       	call   80100b <file_create>
  801494:	83 c4 10             	add    $0x10,%esp
  801497:	85 c0                	test   %eax,%eax
  801499:	79 37                	jns    8014d2 <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  80149b:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  8014a2:	0f 85 bd 00 00 00    	jne    801565 <serve_open+0x12c>
  8014a8:	83 f8 f3             	cmp    $0xfffffff3,%eax
  8014ab:	0f 85 b4 00 00 00    	jne    801565 <serve_open+0x12c>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  8014b1:	83 ec 08             	sub    $0x8,%esp
  8014b4:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8014ba:	50                   	push   %eax
  8014bb:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8014c1:	50                   	push   %eax
  8014c2:	e8 61 f8 ff ff       	call   800d28 <file_open>
  8014c7:	83 c4 10             	add    $0x10,%esp
  8014ca:	85 c0                	test   %eax,%eax
  8014cc:	0f 88 93 00 00 00    	js     801565 <serve_open+0x12c>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  8014d2:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8014d9:	74 17                	je     8014f2 <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  8014db:	83 ec 08             	sub    $0x8,%esp
  8014de:	6a 00                	push   $0x0
  8014e0:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  8014e6:	e8 fc f8 ff ff       	call   800de7 <file_set_size>
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	78 73                	js     801565 <serve_open+0x12c>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  8014f2:	83 ec 08             	sub    $0x8,%esp
  8014f5:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8014fb:	50                   	push   %eax
  8014fc:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801502:	50                   	push   %eax
  801503:	e8 20 f8 ff ff       	call   800d28 <file_open>
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	85 c0                	test   %eax,%eax
  80150d:	78 56                	js     801565 <serve_open+0x12c>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  80150f:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801515:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  80151b:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  80151e:	8b 50 0c             	mov    0xc(%eax),%edx
  801521:	8b 08                	mov    (%eax),%ecx
  801523:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  801526:	8b 48 0c             	mov    0xc(%eax),%ecx
  801529:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80152f:	83 e2 03             	and    $0x3,%edx
  801532:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801535:	8b 40 0c             	mov    0xc(%eax),%eax
  801538:	8b 15 64 90 80 00    	mov    0x809064,%edx
  80153e:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  801540:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801546:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80154c:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  80154f:	8b 50 0c             	mov    0xc(%eax),%edx
  801552:	8b 45 10             	mov    0x10(%ebp),%eax
  801555:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  801557:	8b 45 14             	mov    0x14(%ebp),%eax
  80155a:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  801560:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801565:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801568:	c9                   	leave  
  801569:	c3                   	ret    

0080156a <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	56                   	push   %esi
  80156e:	53                   	push   %ebx
  80156f:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801572:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  801575:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  801578:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80157f:	83 ec 04             	sub    $0x4,%esp
  801582:	53                   	push   %ebx
  801583:	ff 35 44 50 80 00    	pushl  0x805044
  801589:	56                   	push   %esi
  80158a:	e8 76 12 00 00       	call   802805 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  80158f:	83 c4 10             	add    $0x10,%esp
  801592:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  801596:	75 15                	jne    8015ad <serve+0x43>
			cprintf("Invalid request from %08x: no argument page\n",
  801598:	83 ec 08             	sub    $0x8,%esp
  80159b:	ff 75 f4             	pushl  -0xc(%ebp)
  80159e:	68 60 3b 80 00       	push   $0x803b60
  8015a3:	e8 de 05 00 00       	call   801b86 <cprintf>
				whom);
			continue; // just leave it hanging...
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	eb cb                	jmp    801578 <serve+0xe>
		}

		pg = NULL;
  8015ad:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  8015b4:	83 f8 01             	cmp    $0x1,%eax
  8015b7:	75 18                	jne    8015d1 <serve+0x67>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  8015b9:	53                   	push   %ebx
  8015ba:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015bd:	50                   	push   %eax
  8015be:	ff 35 44 50 80 00    	pushl  0x805044
  8015c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8015c7:	e8 6d fe ff ff       	call   801439 <serve_open>
  8015cc:	83 c4 10             	add    $0x10,%esp
  8015cf:	eb 3c                	jmp    80160d <serve+0xa3>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  8015d1:	83 f8 08             	cmp    $0x8,%eax
  8015d4:	77 1e                	ja     8015f4 <serve+0x8a>
  8015d6:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  8015dd:	85 d2                	test   %edx,%edx
  8015df:	74 13                	je     8015f4 <serve+0x8a>
			r = handlers[req](whom, fsreq);
  8015e1:	83 ec 08             	sub    $0x8,%esp
  8015e4:	ff 35 44 50 80 00    	pushl  0x805044
  8015ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ed:	ff d2                	call   *%edx
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	eb 19                	jmp    80160d <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  8015f4:	83 ec 04             	sub    $0x4,%esp
  8015f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8015fa:	50                   	push   %eax
  8015fb:	68 90 3b 80 00       	push   $0x803b90
  801600:	e8 81 05 00 00       	call   801b86 <cprintf>
  801605:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  801608:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  80160d:	ff 75 f0             	pushl  -0x10(%ebp)
  801610:	ff 75 ec             	pushl  -0x14(%ebp)
  801613:	50                   	push   %eax
  801614:	ff 75 f4             	pushl  -0xc(%ebp)
  801617:	e8 52 12 00 00       	call   80286e <ipc_send>
		sys_page_unmap(0, fsreq);
  80161c:	83 c4 08             	add    $0x8,%esp
  80161f:	ff 35 44 50 80 00    	pushl  0x805044
  801625:	6a 00                	push   $0x0
  801627:	e8 e6 0f 00 00       	call   802612 <sys_page_unmap>
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	e9 44 ff ff ff       	jmp    801578 <serve+0xe>

00801634 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  80163a:	c7 05 60 90 80 00 b3 	movl   $0x803bb3,0x809060
  801641:	3b 80 00 
	cprintf("FS is running\n");
  801644:	68 b6 3b 80 00       	push   $0x803bb6
  801649:	e8 38 05 00 00       	call   801b86 <cprintf>
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  80164e:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801653:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801658:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  80165a:	c7 04 24 c5 3b 80 00 	movl   $0x803bc5,(%esp)
  801661:	e8 20 05 00 00       	call   801b86 <cprintf>

	serve_init();
  801666:	e8 35 fb ff ff       	call   8011a0 <serve_init>
	fs_init();
  80166b:	e8 b5 f3 ff ff       	call   800a25 <fs_init>
        fs_test();
  801670:	e8 05 00 00 00       	call   80167a <fs_test>
	serve();
  801675:	e8 f0 fe ff ff       	call   80156a <serve>

0080167a <fs_test>:
/*文件系统服务端代码，客户端用户环境通过IPC与之交互*/
static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	53                   	push   %ebx
  80167e:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  801681:	6a 07                	push   $0x7
  801683:	68 00 10 00 00       	push   $0x1000
  801688:	6a 00                	push   $0x0
  80168a:	e8 fe 0e 00 00       	call   80258d <sys_page_alloc>
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	85 c0                	test   %eax,%eax
  801694:	79 12                	jns    8016a8 <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  801696:	50                   	push   %eax
  801697:	68 d4 3b 80 00       	push   $0x803bd4
  80169c:	6a 12                	push   $0x12
  80169e:	68 e7 3b 80 00       	push   $0x803be7
  8016a3:	e8 05 04 00 00       	call   801aad <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  8016a8:	83 ec 04             	sub    $0x4,%esp
  8016ab:	68 00 10 00 00       	push   $0x1000
  8016b0:	ff 35 04 a0 80 00    	pushl  0x80a004
  8016b6:	68 00 10 00 00       	push   $0x1000
  8016bb:	e8 5c 0c 00 00       	call   80231c <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8016c0:	e8 5e f1 ff ff       	call   800823 <alloc_block>
  8016c5:	83 c4 10             	add    $0x10,%esp
  8016c8:	85 c0                	test   %eax,%eax
  8016ca:	79 12                	jns    8016de <fs_test+0x64>
		panic("alloc_block: %e", r);
  8016cc:	50                   	push   %eax
  8016cd:	68 f1 3b 80 00       	push   $0x803bf1
  8016d2:	6a 17                	push   $0x17
  8016d4:	68 e7 3b 80 00       	push   $0x803be7
  8016d9:	e8 cf 03 00 00       	call   801aad <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8016de:	8d 50 1f             	lea    0x1f(%eax),%edx
  8016e1:	85 c0                	test   %eax,%eax
  8016e3:	0f 49 d0             	cmovns %eax,%edx
  8016e6:	c1 fa 05             	sar    $0x5,%edx
  8016e9:	89 c3                	mov    %eax,%ebx
  8016eb:	c1 fb 1f             	sar    $0x1f,%ebx
  8016ee:	c1 eb 1b             	shr    $0x1b,%ebx
  8016f1:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  8016f4:	83 e1 1f             	and    $0x1f,%ecx
  8016f7:	29 d9                	sub    %ebx,%ecx
  8016f9:	b8 01 00 00 00       	mov    $0x1,%eax
  8016fe:	d3 e0                	shl    %cl,%eax
  801700:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  801707:	75 16                	jne    80171f <fs_test+0xa5>
  801709:	68 01 3c 80 00       	push   $0x803c01
  80170e:	68 fd 38 80 00       	push   $0x8038fd
  801713:	6a 19                	push   $0x19
  801715:	68 e7 3b 80 00       	push   $0x803be7
  80171a:	e8 8e 03 00 00       	call   801aad <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  80171f:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  801725:	85 04 91             	test   %eax,(%ecx,%edx,4)
  801728:	74 16                	je     801740 <fs_test+0xc6>
  80172a:	68 7c 3d 80 00       	push   $0x803d7c
  80172f:	68 fd 38 80 00       	push   $0x8038fd
  801734:	6a 1b                	push   $0x1b
  801736:	68 e7 3b 80 00       	push   $0x803be7
  80173b:	e8 6d 03 00 00       	call   801aad <_panic>
	cprintf("alloc_block is good\n");
  801740:	83 ec 0c             	sub    $0xc,%esp
  801743:	68 1c 3c 80 00       	push   $0x803c1c
  801748:	e8 39 04 00 00       	call   801b86 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  80174d:	83 c4 08             	add    $0x8,%esp
  801750:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801753:	50                   	push   %eax
  801754:	68 31 3c 80 00       	push   $0x803c31
  801759:	e8 ca f5 ff ff       	call   800d28 <file_open>
  80175e:	83 c4 10             	add    $0x10,%esp
  801761:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801764:	74 1b                	je     801781 <fs_test+0x107>
  801766:	89 c2                	mov    %eax,%edx
  801768:	c1 ea 1f             	shr    $0x1f,%edx
  80176b:	84 d2                	test   %dl,%dl
  80176d:	74 12                	je     801781 <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  80176f:	50                   	push   %eax
  801770:	68 3c 3c 80 00       	push   $0x803c3c
  801775:	6a 1f                	push   $0x1f
  801777:	68 e7 3b 80 00       	push   $0x803be7
  80177c:	e8 2c 03 00 00       	call   801aad <_panic>
	else if (r == 0)
  801781:	85 c0                	test   %eax,%eax
  801783:	75 14                	jne    801799 <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  801785:	83 ec 04             	sub    $0x4,%esp
  801788:	68 9c 3d 80 00       	push   $0x803d9c
  80178d:	6a 21                	push   $0x21
  80178f:	68 e7 3b 80 00       	push   $0x803be7
  801794:	e8 14 03 00 00       	call   801aad <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801799:	83 ec 08             	sub    $0x8,%esp
  80179c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80179f:	50                   	push   %eax
  8017a0:	68 55 3c 80 00       	push   $0x803c55
  8017a5:	e8 7e f5 ff ff       	call   800d28 <file_open>
  8017aa:	83 c4 10             	add    $0x10,%esp
  8017ad:	85 c0                	test   %eax,%eax
  8017af:	79 12                	jns    8017c3 <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  8017b1:	50                   	push   %eax
  8017b2:	68 5e 3c 80 00       	push   $0x803c5e
  8017b7:	6a 23                	push   $0x23
  8017b9:	68 e7 3b 80 00       	push   $0x803be7
  8017be:	e8 ea 02 00 00       	call   801aad <_panic>
	cprintf("file_open is good\n");
  8017c3:	83 ec 0c             	sub    $0xc,%esp
  8017c6:	68 75 3c 80 00       	push   $0x803c75
  8017cb:	e8 b6 03 00 00       	call   801b86 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8017d0:	83 c4 0c             	add    $0xc,%esp
  8017d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d6:	50                   	push   %eax
  8017d7:	6a 00                	push   $0x0
  8017d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8017dc:	e8 a3 f2 ff ff       	call   800a84 <file_get_block>
  8017e1:	83 c4 10             	add    $0x10,%esp
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	79 12                	jns    8017fa <fs_test+0x180>
		panic("file_get_block: %e", r);
  8017e8:	50                   	push   %eax
  8017e9:	68 88 3c 80 00       	push   $0x803c88
  8017ee:	6a 27                	push   $0x27
  8017f0:	68 e7 3b 80 00       	push   $0x803be7
  8017f5:	e8 b3 02 00 00       	call   801aad <_panic>
	if (strcmp(blk, msg) != 0)
  8017fa:	83 ec 08             	sub    $0x8,%esp
  8017fd:	68 bc 3d 80 00       	push   $0x803dbc
  801802:	ff 75 f0             	pushl  -0x10(%ebp)
  801805:	e8 2a 0a 00 00       	call   802234 <strcmp>
  80180a:	83 c4 10             	add    $0x10,%esp
  80180d:	85 c0                	test   %eax,%eax
  80180f:	74 14                	je     801825 <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  801811:	83 ec 04             	sub    $0x4,%esp
  801814:	68 e4 3d 80 00       	push   $0x803de4
  801819:	6a 29                	push   $0x29
  80181b:	68 e7 3b 80 00       	push   $0x803be7
  801820:	e8 88 02 00 00       	call   801aad <_panic>
	cprintf("file_get_block is good\n");
  801825:	83 ec 0c             	sub    $0xc,%esp
  801828:	68 9b 3c 80 00       	push   $0x803c9b
  80182d:	e8 54 03 00 00       	call   801b86 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801832:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801835:	0f b6 10             	movzbl (%eax),%edx
  801838:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  80183a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80183d:	c1 e8 0c             	shr    $0xc,%eax
  801840:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801847:	83 c4 10             	add    $0x10,%esp
  80184a:	a8 40                	test   $0x40,%al
  80184c:	75 16                	jne    801864 <fs_test+0x1ea>
  80184e:	68 b4 3c 80 00       	push   $0x803cb4
  801853:	68 fd 38 80 00       	push   $0x8038fd
  801858:	6a 2d                	push   $0x2d
  80185a:	68 e7 3b 80 00       	push   $0x803be7
  80185f:	e8 49 02 00 00       	call   801aad <_panic>
	file_flush(f);
  801864:	83 ec 0c             	sub    $0xc,%esp
  801867:	ff 75 f4             	pushl  -0xc(%ebp)
  80186a:	e8 ff f6 ff ff       	call   800f6e <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  80186f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801872:	c1 e8 0c             	shr    $0xc,%eax
  801875:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	a8 40                	test   $0x40,%al
  801881:	74 16                	je     801899 <fs_test+0x21f>
  801883:	68 b3 3c 80 00       	push   $0x803cb3
  801888:	68 fd 38 80 00       	push   $0x8038fd
  80188d:	6a 2f                	push   $0x2f
  80188f:	68 e7 3b 80 00       	push   $0x803be7
  801894:	e8 14 02 00 00       	call   801aad <_panic>
	cprintf("file_flush is good\n");
  801899:	83 ec 0c             	sub    $0xc,%esp
  80189c:	68 cf 3c 80 00       	push   $0x803ccf
  8018a1:	e8 e0 02 00 00       	call   801b86 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  8018a6:	83 c4 08             	add    $0x8,%esp
  8018a9:	6a 00                	push   $0x0
  8018ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ae:	e8 34 f5 ff ff       	call   800de7 <file_set_size>
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	85 c0                	test   %eax,%eax
  8018b8:	79 12                	jns    8018cc <fs_test+0x252>
		panic("file_set_size: %e", r);
  8018ba:	50                   	push   %eax
  8018bb:	68 e3 3c 80 00       	push   $0x803ce3
  8018c0:	6a 33                	push   $0x33
  8018c2:	68 e7 3b 80 00       	push   $0x803be7
  8018c7:	e8 e1 01 00 00       	call   801aad <_panic>
	assert(f->f_direct[0] == 0);
  8018cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018cf:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8018d6:	74 16                	je     8018ee <fs_test+0x274>
  8018d8:	68 f5 3c 80 00       	push   $0x803cf5
  8018dd:	68 fd 38 80 00       	push   $0x8038fd
  8018e2:	6a 34                	push   $0x34
  8018e4:	68 e7 3b 80 00       	push   $0x803be7
  8018e9:	e8 bf 01 00 00       	call   801aad <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8018ee:	c1 e8 0c             	shr    $0xc,%eax
  8018f1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018f8:	a8 40                	test   $0x40,%al
  8018fa:	74 16                	je     801912 <fs_test+0x298>
  8018fc:	68 09 3d 80 00       	push   $0x803d09
  801901:	68 fd 38 80 00       	push   $0x8038fd
  801906:	6a 35                	push   $0x35
  801908:	68 e7 3b 80 00       	push   $0x803be7
  80190d:	e8 9b 01 00 00       	call   801aad <_panic>
	cprintf("file_truncate is good\n");
  801912:	83 ec 0c             	sub    $0xc,%esp
  801915:	68 23 3d 80 00       	push   $0x803d23
  80191a:	e8 67 02 00 00       	call   801b86 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  80191f:	c7 04 24 bc 3d 80 00 	movl   $0x803dbc,(%esp)
  801926:	e8 26 08 00 00       	call   802151 <strlen>
  80192b:	83 c4 08             	add    $0x8,%esp
  80192e:	50                   	push   %eax
  80192f:	ff 75 f4             	pushl  -0xc(%ebp)
  801932:	e8 b0 f4 ff ff       	call   800de7 <file_set_size>
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	85 c0                	test   %eax,%eax
  80193c:	79 12                	jns    801950 <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  80193e:	50                   	push   %eax
  80193f:	68 3a 3d 80 00       	push   $0x803d3a
  801944:	6a 39                	push   $0x39
  801946:	68 e7 3b 80 00       	push   $0x803be7
  80194b:	e8 5d 01 00 00       	call   801aad <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801950:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801953:	89 c2                	mov    %eax,%edx
  801955:	c1 ea 0c             	shr    $0xc,%edx
  801958:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80195f:	f6 c2 40             	test   $0x40,%dl
  801962:	74 16                	je     80197a <fs_test+0x300>
  801964:	68 09 3d 80 00       	push   $0x803d09
  801969:	68 fd 38 80 00       	push   $0x8038fd
  80196e:	6a 3a                	push   $0x3a
  801970:	68 e7 3b 80 00       	push   $0x803be7
  801975:	e8 33 01 00 00       	call   801aad <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  80197a:	83 ec 04             	sub    $0x4,%esp
  80197d:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801980:	52                   	push   %edx
  801981:	6a 00                	push   $0x0
  801983:	50                   	push   %eax
  801984:	e8 fb f0 ff ff       	call   800a84 <file_get_block>
  801989:	83 c4 10             	add    $0x10,%esp
  80198c:	85 c0                	test   %eax,%eax
  80198e:	79 12                	jns    8019a2 <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  801990:	50                   	push   %eax
  801991:	68 4e 3d 80 00       	push   $0x803d4e
  801996:	6a 3c                	push   $0x3c
  801998:	68 e7 3b 80 00       	push   $0x803be7
  80199d:	e8 0b 01 00 00       	call   801aad <_panic>
	strcpy(blk, msg);
  8019a2:	83 ec 08             	sub    $0x8,%esp
  8019a5:	68 bc 3d 80 00       	push   $0x803dbc
  8019aa:	ff 75 f0             	pushl  -0x10(%ebp)
  8019ad:	e8 d8 07 00 00       	call   80218a <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8019b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019b5:	c1 e8 0c             	shr    $0xc,%eax
  8019b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019bf:	83 c4 10             	add    $0x10,%esp
  8019c2:	a8 40                	test   $0x40,%al
  8019c4:	75 16                	jne    8019dc <fs_test+0x362>
  8019c6:	68 b4 3c 80 00       	push   $0x803cb4
  8019cb:	68 fd 38 80 00       	push   $0x8038fd
  8019d0:	6a 3e                	push   $0x3e
  8019d2:	68 e7 3b 80 00       	push   $0x803be7
  8019d7:	e8 d1 00 00 00       	call   801aad <_panic>
	file_flush(f);
  8019dc:	83 ec 0c             	sub    $0xc,%esp
  8019df:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e2:	e8 87 f5 ff ff       	call   800f6e <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8019e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ea:	c1 e8 0c             	shr    $0xc,%eax
  8019ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019f4:	83 c4 10             	add    $0x10,%esp
  8019f7:	a8 40                	test   $0x40,%al
  8019f9:	74 16                	je     801a11 <fs_test+0x397>
  8019fb:	68 b3 3c 80 00       	push   $0x803cb3
  801a00:	68 fd 38 80 00       	push   $0x8038fd
  801a05:	6a 40                	push   $0x40
  801a07:	68 e7 3b 80 00       	push   $0x803be7
  801a0c:	e8 9c 00 00 00       	call   801aad <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a14:	c1 e8 0c             	shr    $0xc,%eax
  801a17:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a1e:	a8 40                	test   $0x40,%al
  801a20:	74 16                	je     801a38 <fs_test+0x3be>
  801a22:	68 09 3d 80 00       	push   $0x803d09
  801a27:	68 fd 38 80 00       	push   $0x8038fd
  801a2c:	6a 41                	push   $0x41
  801a2e:	68 e7 3b 80 00       	push   $0x803be7
  801a33:	e8 75 00 00 00       	call   801aad <_panic>
	cprintf("file rewrite is good\n");
  801a38:	83 ec 0c             	sub    $0xc,%esp
  801a3b:	68 63 3d 80 00       	push   $0x803d63
  801a40:	e8 41 01 00 00       	call   801b86 <cprintf>
}
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a4b:	c9                   	leave  
  801a4c:	c3                   	ret    

00801a4d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801a4d:	55                   	push   %ebp
  801a4e:	89 e5                	mov    %esp,%ebp
  801a50:	56                   	push   %esi
  801a51:	53                   	push   %ebx
  801a52:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a55:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  801a58:	e8 f2 0a 00 00       	call   80254f <sys_getenvid>
  801a5d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a62:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a65:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a6a:	a3 0c a0 80 00       	mov    %eax,0x80a00c

    // save the name of the program so that panic() can use it
    if (argc > 0)
  801a6f:	85 db                	test   %ebx,%ebx
  801a71:	7e 07                	jle    801a7a <libmain+0x2d>
        binaryname = argv[0];
  801a73:	8b 06                	mov    (%esi),%eax
  801a75:	a3 60 90 80 00       	mov    %eax,0x809060

    // call user main routine
    umain(argc, argv);
  801a7a:	83 ec 08             	sub    $0x8,%esp
  801a7d:	56                   	push   %esi
  801a7e:	53                   	push   %ebx
  801a7f:	e8 b0 fb ff ff       	call   801634 <umain>

    // exit gracefully
    exit();
  801a84:	e8 0a 00 00 00       	call   801a93 <exit>
}
  801a89:	83 c4 10             	add    $0x10,%esp
  801a8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8f:	5b                   	pop    %ebx
  801a90:	5e                   	pop    %esi
  801a91:	5d                   	pop    %ebp
  801a92:	c3                   	ret    

00801a93 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801a99:	e8 28 10 00 00       	call   802ac6 <close_all>
	sys_env_destroy(0);
  801a9e:	83 ec 0c             	sub    $0xc,%esp
  801aa1:	6a 00                	push   $0x0
  801aa3:	e8 66 0a 00 00       	call   80250e <sys_env_destroy>
}
  801aa8:	83 c4 10             	add    $0x10,%esp
  801aab:	c9                   	leave  
  801aac:	c3                   	ret    

00801aad <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	56                   	push   %esi
  801ab1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ab2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ab5:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801abb:	e8 8f 0a 00 00       	call   80254f <sys_getenvid>
  801ac0:	83 ec 0c             	sub    $0xc,%esp
  801ac3:	ff 75 0c             	pushl  0xc(%ebp)
  801ac6:	ff 75 08             	pushl  0x8(%ebp)
  801ac9:	56                   	push   %esi
  801aca:	50                   	push   %eax
  801acb:	68 14 3e 80 00       	push   $0x803e14
  801ad0:	e8 b1 00 00 00       	call   801b86 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ad5:	83 c4 18             	add    $0x18,%esp
  801ad8:	53                   	push   %ebx
  801ad9:	ff 75 10             	pushl  0x10(%ebp)
  801adc:	e8 54 00 00 00       	call   801b35 <vcprintf>
	cprintf("\n");
  801ae1:	c7 04 24 22 3a 80 00 	movl   $0x803a22,(%esp)
  801ae8:	e8 99 00 00 00       	call   801b86 <cprintf>
  801aed:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801af0:	cc                   	int3   
  801af1:	eb fd                	jmp    801af0 <_panic+0x43>

00801af3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	53                   	push   %ebx
  801af7:	83 ec 04             	sub    $0x4,%esp
  801afa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801afd:	8b 13                	mov    (%ebx),%edx
  801aff:	8d 42 01             	lea    0x1(%edx),%eax
  801b02:	89 03                	mov    %eax,(%ebx)
  801b04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b07:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801b0b:	3d ff 00 00 00       	cmp    $0xff,%eax
  801b10:	75 1a                	jne    801b2c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801b12:	83 ec 08             	sub    $0x8,%esp
  801b15:	68 ff 00 00 00       	push   $0xff
  801b1a:	8d 43 08             	lea    0x8(%ebx),%eax
  801b1d:	50                   	push   %eax
  801b1e:	e8 ae 09 00 00       	call   8024d1 <sys_cputs>
		b->idx = 0;
  801b23:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b29:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801b2c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801b30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b33:	c9                   	leave  
  801b34:	c3                   	ret    

00801b35 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801b3e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b45:	00 00 00 
	b.cnt = 0;
  801b48:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801b4f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801b52:	ff 75 0c             	pushl  0xc(%ebp)
  801b55:	ff 75 08             	pushl  0x8(%ebp)
  801b58:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801b5e:	50                   	push   %eax
  801b5f:	68 f3 1a 80 00       	push   $0x801af3
  801b64:	e8 1a 01 00 00       	call   801c83 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801b69:	83 c4 08             	add    $0x8,%esp
  801b6c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801b72:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801b78:	50                   	push   %eax
  801b79:	e8 53 09 00 00       	call   8024d1 <sys_cputs>

	return b.cnt;
}
  801b7e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801b84:	c9                   	leave  
  801b85:	c3                   	ret    

00801b86 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b8c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801b8f:	50                   	push   %eax
  801b90:	ff 75 08             	pushl  0x8(%ebp)
  801b93:	e8 9d ff ff ff       	call   801b35 <vcprintf>
	va_end(ap);

	return cnt;
}
  801b98:	c9                   	leave  
  801b99:	c3                   	ret    

00801b9a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	57                   	push   %edi
  801b9e:	56                   	push   %esi
  801b9f:	53                   	push   %ebx
  801ba0:	83 ec 1c             	sub    $0x1c,%esp
  801ba3:	89 c7                	mov    %eax,%edi
  801ba5:	89 d6                	mov    %edx,%esi
  801ba7:	8b 45 08             	mov    0x8(%ebp),%eax
  801baa:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801bb0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801bb3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801bb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bbb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801bbe:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801bc1:	39 d3                	cmp    %edx,%ebx
  801bc3:	72 05                	jb     801bca <printnum+0x30>
  801bc5:	39 45 10             	cmp    %eax,0x10(%ebp)
  801bc8:	77 45                	ja     801c0f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801bca:	83 ec 0c             	sub    $0xc,%esp
  801bcd:	ff 75 18             	pushl  0x18(%ebp)
  801bd0:	8b 45 14             	mov    0x14(%ebp),%eax
  801bd3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801bd6:	53                   	push   %ebx
  801bd7:	ff 75 10             	pushl  0x10(%ebp)
  801bda:	83 ec 08             	sub    $0x8,%esp
  801bdd:	ff 75 e4             	pushl  -0x1c(%ebp)
  801be0:	ff 75 e0             	pushl  -0x20(%ebp)
  801be3:	ff 75 dc             	pushl  -0x24(%ebp)
  801be6:	ff 75 d8             	pushl  -0x28(%ebp)
  801be9:	e8 32 1a 00 00       	call   803620 <__udivdi3>
  801bee:	83 c4 18             	add    $0x18,%esp
  801bf1:	52                   	push   %edx
  801bf2:	50                   	push   %eax
  801bf3:	89 f2                	mov    %esi,%edx
  801bf5:	89 f8                	mov    %edi,%eax
  801bf7:	e8 9e ff ff ff       	call   801b9a <printnum>
  801bfc:	83 c4 20             	add    $0x20,%esp
  801bff:	eb 18                	jmp    801c19 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801c01:	83 ec 08             	sub    $0x8,%esp
  801c04:	56                   	push   %esi
  801c05:	ff 75 18             	pushl  0x18(%ebp)
  801c08:	ff d7                	call   *%edi
  801c0a:	83 c4 10             	add    $0x10,%esp
  801c0d:	eb 03                	jmp    801c12 <printnum+0x78>
  801c0f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801c12:	83 eb 01             	sub    $0x1,%ebx
  801c15:	85 db                	test   %ebx,%ebx
  801c17:	7f e8                	jg     801c01 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801c19:	83 ec 08             	sub    $0x8,%esp
  801c1c:	56                   	push   %esi
  801c1d:	83 ec 04             	sub    $0x4,%esp
  801c20:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c23:	ff 75 e0             	pushl  -0x20(%ebp)
  801c26:	ff 75 dc             	pushl  -0x24(%ebp)
  801c29:	ff 75 d8             	pushl  -0x28(%ebp)
  801c2c:	e8 1f 1b 00 00       	call   803750 <__umoddi3>
  801c31:	83 c4 14             	add    $0x14,%esp
  801c34:	0f be 80 37 3e 80 00 	movsbl 0x803e37(%eax),%eax
  801c3b:	50                   	push   %eax
  801c3c:	ff d7                	call   *%edi
}
  801c3e:	83 c4 10             	add    $0x10,%esp
  801c41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c44:	5b                   	pop    %ebx
  801c45:	5e                   	pop    %esi
  801c46:	5f                   	pop    %edi
  801c47:	5d                   	pop    %ebp
  801c48:	c3                   	ret    

00801c49 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801c49:	55                   	push   %ebp
  801c4a:	89 e5                	mov    %esp,%ebp
  801c4c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801c4f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801c53:	8b 10                	mov    (%eax),%edx
  801c55:	3b 50 04             	cmp    0x4(%eax),%edx
  801c58:	73 0a                	jae    801c64 <sprintputch+0x1b>
		*b->buf++ = ch;
  801c5a:	8d 4a 01             	lea    0x1(%edx),%ecx
  801c5d:	89 08                	mov    %ecx,(%eax)
  801c5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c62:	88 02                	mov    %al,(%edx)
}
  801c64:	5d                   	pop    %ebp
  801c65:	c3                   	ret    

00801c66 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801c66:	55                   	push   %ebp
  801c67:	89 e5                	mov    %esp,%ebp
  801c69:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801c6c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801c6f:	50                   	push   %eax
  801c70:	ff 75 10             	pushl  0x10(%ebp)
  801c73:	ff 75 0c             	pushl  0xc(%ebp)
  801c76:	ff 75 08             	pushl  0x8(%ebp)
  801c79:	e8 05 00 00 00       	call   801c83 <vprintfmt>
	va_end(ap);
}
  801c7e:	83 c4 10             	add    $0x10,%esp
  801c81:	c9                   	leave  
  801c82:	c3                   	ret    

00801c83 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	57                   	push   %edi
  801c87:	56                   	push   %esi
  801c88:	53                   	push   %ebx
  801c89:	83 ec 2c             	sub    $0x2c,%esp
  801c8c:	8b 75 08             	mov    0x8(%ebp),%esi
  801c8f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c92:	8b 7d 10             	mov    0x10(%ebp),%edi
  801c95:	eb 12                	jmp    801ca9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801c97:	85 c0                	test   %eax,%eax
  801c99:	0f 84 42 04 00 00    	je     8020e1 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  801c9f:	83 ec 08             	sub    $0x8,%esp
  801ca2:	53                   	push   %ebx
  801ca3:	50                   	push   %eax
  801ca4:	ff d6                	call   *%esi
  801ca6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801ca9:	83 c7 01             	add    $0x1,%edi
  801cac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801cb0:	83 f8 25             	cmp    $0x25,%eax
  801cb3:	75 e2                	jne    801c97 <vprintfmt+0x14>
  801cb5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801cb9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801cc0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801cc7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801cce:	b9 00 00 00 00       	mov    $0x0,%ecx
  801cd3:	eb 07                	jmp    801cdc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cd5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801cd8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cdc:	8d 47 01             	lea    0x1(%edi),%eax
  801cdf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ce2:	0f b6 07             	movzbl (%edi),%eax
  801ce5:	0f b6 d0             	movzbl %al,%edx
  801ce8:	83 e8 23             	sub    $0x23,%eax
  801ceb:	3c 55                	cmp    $0x55,%al
  801ced:	0f 87 d3 03 00 00    	ja     8020c6 <vprintfmt+0x443>
  801cf3:	0f b6 c0             	movzbl %al,%eax
  801cf6:	ff 24 85 80 3f 80 00 	jmp    *0x803f80(,%eax,4)
  801cfd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801d00:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801d04:	eb d6                	jmp    801cdc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d09:	b8 00 00 00 00       	mov    $0x0,%eax
  801d0e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801d11:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801d14:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801d18:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801d1b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801d1e:	83 f9 09             	cmp    $0x9,%ecx
  801d21:	77 3f                	ja     801d62 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801d23:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801d26:	eb e9                	jmp    801d11 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801d28:	8b 45 14             	mov    0x14(%ebp),%eax
  801d2b:	8b 00                	mov    (%eax),%eax
  801d2d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801d30:	8b 45 14             	mov    0x14(%ebp),%eax
  801d33:	8d 40 04             	lea    0x4(%eax),%eax
  801d36:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d39:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801d3c:	eb 2a                	jmp    801d68 <vprintfmt+0xe5>
  801d3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d41:	85 c0                	test   %eax,%eax
  801d43:	ba 00 00 00 00       	mov    $0x0,%edx
  801d48:	0f 49 d0             	cmovns %eax,%edx
  801d4b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d4e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d51:	eb 89                	jmp    801cdc <vprintfmt+0x59>
  801d53:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801d56:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801d5d:	e9 7a ff ff ff       	jmp    801cdc <vprintfmt+0x59>
  801d62:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801d65:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801d68:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801d6c:	0f 89 6a ff ff ff    	jns    801cdc <vprintfmt+0x59>
				width = precision, precision = -1;
  801d72:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801d75:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d78:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801d7f:	e9 58 ff ff ff       	jmp    801cdc <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801d84:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d87:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801d8a:	e9 4d ff ff ff       	jmp    801cdc <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801d8f:	8b 45 14             	mov    0x14(%ebp),%eax
  801d92:	8d 78 04             	lea    0x4(%eax),%edi
  801d95:	83 ec 08             	sub    $0x8,%esp
  801d98:	53                   	push   %ebx
  801d99:	ff 30                	pushl  (%eax)
  801d9b:	ff d6                	call   *%esi
			break;
  801d9d:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801da0:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801da3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801da6:	e9 fe fe ff ff       	jmp    801ca9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801dab:	8b 45 14             	mov    0x14(%ebp),%eax
  801dae:	8d 78 04             	lea    0x4(%eax),%edi
  801db1:	8b 00                	mov    (%eax),%eax
  801db3:	99                   	cltd   
  801db4:	31 d0                	xor    %edx,%eax
  801db6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801db8:	83 f8 0f             	cmp    $0xf,%eax
  801dbb:	7f 0b                	jg     801dc8 <vprintfmt+0x145>
  801dbd:	8b 14 85 e0 40 80 00 	mov    0x8040e0(,%eax,4),%edx
  801dc4:	85 d2                	test   %edx,%edx
  801dc6:	75 1b                	jne    801de3 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  801dc8:	50                   	push   %eax
  801dc9:	68 4f 3e 80 00       	push   $0x803e4f
  801dce:	53                   	push   %ebx
  801dcf:	56                   	push   %esi
  801dd0:	e8 91 fe ff ff       	call   801c66 <printfmt>
  801dd5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801dd8:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ddb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801dde:	e9 c6 fe ff ff       	jmp    801ca9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801de3:	52                   	push   %edx
  801de4:	68 0f 39 80 00       	push   $0x80390f
  801de9:	53                   	push   %ebx
  801dea:	56                   	push   %esi
  801deb:	e8 76 fe ff ff       	call   801c66 <printfmt>
  801df0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801df3:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801df6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801df9:	e9 ab fe ff ff       	jmp    801ca9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801dfe:	8b 45 14             	mov    0x14(%ebp),%eax
  801e01:	83 c0 04             	add    $0x4,%eax
  801e04:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801e07:	8b 45 14             	mov    0x14(%ebp),%eax
  801e0a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801e0c:	85 ff                	test   %edi,%edi
  801e0e:	b8 48 3e 80 00       	mov    $0x803e48,%eax
  801e13:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801e16:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801e1a:	0f 8e 94 00 00 00    	jle    801eb4 <vprintfmt+0x231>
  801e20:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801e24:	0f 84 98 00 00 00    	je     801ec2 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  801e2a:	83 ec 08             	sub    $0x8,%esp
  801e2d:	ff 75 d0             	pushl  -0x30(%ebp)
  801e30:	57                   	push   %edi
  801e31:	e8 33 03 00 00       	call   802169 <strnlen>
  801e36:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801e39:	29 c1                	sub    %eax,%ecx
  801e3b:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801e3e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801e41:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801e45:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e48:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801e4b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801e4d:	eb 0f                	jmp    801e5e <vprintfmt+0x1db>
					putch(padc, putdat);
  801e4f:	83 ec 08             	sub    $0x8,%esp
  801e52:	53                   	push   %ebx
  801e53:	ff 75 e0             	pushl  -0x20(%ebp)
  801e56:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801e58:	83 ef 01             	sub    $0x1,%edi
  801e5b:	83 c4 10             	add    $0x10,%esp
  801e5e:	85 ff                	test   %edi,%edi
  801e60:	7f ed                	jg     801e4f <vprintfmt+0x1cc>
  801e62:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801e65:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801e68:	85 c9                	test   %ecx,%ecx
  801e6a:	b8 00 00 00 00       	mov    $0x0,%eax
  801e6f:	0f 49 c1             	cmovns %ecx,%eax
  801e72:	29 c1                	sub    %eax,%ecx
  801e74:	89 75 08             	mov    %esi,0x8(%ebp)
  801e77:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801e7a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801e7d:	89 cb                	mov    %ecx,%ebx
  801e7f:	eb 4d                	jmp    801ece <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801e81:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801e85:	74 1b                	je     801ea2 <vprintfmt+0x21f>
  801e87:	0f be c0             	movsbl %al,%eax
  801e8a:	83 e8 20             	sub    $0x20,%eax
  801e8d:	83 f8 5e             	cmp    $0x5e,%eax
  801e90:	76 10                	jbe    801ea2 <vprintfmt+0x21f>
					putch('?', putdat);
  801e92:	83 ec 08             	sub    $0x8,%esp
  801e95:	ff 75 0c             	pushl  0xc(%ebp)
  801e98:	6a 3f                	push   $0x3f
  801e9a:	ff 55 08             	call   *0x8(%ebp)
  801e9d:	83 c4 10             	add    $0x10,%esp
  801ea0:	eb 0d                	jmp    801eaf <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  801ea2:	83 ec 08             	sub    $0x8,%esp
  801ea5:	ff 75 0c             	pushl  0xc(%ebp)
  801ea8:	52                   	push   %edx
  801ea9:	ff 55 08             	call   *0x8(%ebp)
  801eac:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801eaf:	83 eb 01             	sub    $0x1,%ebx
  801eb2:	eb 1a                	jmp    801ece <vprintfmt+0x24b>
  801eb4:	89 75 08             	mov    %esi,0x8(%ebp)
  801eb7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801eba:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ebd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801ec0:	eb 0c                	jmp    801ece <vprintfmt+0x24b>
  801ec2:	89 75 08             	mov    %esi,0x8(%ebp)
  801ec5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801ec8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ecb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801ece:	83 c7 01             	add    $0x1,%edi
  801ed1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ed5:	0f be d0             	movsbl %al,%edx
  801ed8:	85 d2                	test   %edx,%edx
  801eda:	74 23                	je     801eff <vprintfmt+0x27c>
  801edc:	85 f6                	test   %esi,%esi
  801ede:	78 a1                	js     801e81 <vprintfmt+0x1fe>
  801ee0:	83 ee 01             	sub    $0x1,%esi
  801ee3:	79 9c                	jns    801e81 <vprintfmt+0x1fe>
  801ee5:	89 df                	mov    %ebx,%edi
  801ee7:	8b 75 08             	mov    0x8(%ebp),%esi
  801eea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801eed:	eb 18                	jmp    801f07 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801eef:	83 ec 08             	sub    $0x8,%esp
  801ef2:	53                   	push   %ebx
  801ef3:	6a 20                	push   $0x20
  801ef5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801ef7:	83 ef 01             	sub    $0x1,%edi
  801efa:	83 c4 10             	add    $0x10,%esp
  801efd:	eb 08                	jmp    801f07 <vprintfmt+0x284>
  801eff:	89 df                	mov    %ebx,%edi
  801f01:	8b 75 08             	mov    0x8(%ebp),%esi
  801f04:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f07:	85 ff                	test   %edi,%edi
  801f09:	7f e4                	jg     801eef <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801f0b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801f0e:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f11:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f14:	e9 90 fd ff ff       	jmp    801ca9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801f19:	83 f9 01             	cmp    $0x1,%ecx
  801f1c:	7e 19                	jle    801f37 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  801f1e:	8b 45 14             	mov    0x14(%ebp),%eax
  801f21:	8b 50 04             	mov    0x4(%eax),%edx
  801f24:	8b 00                	mov    (%eax),%eax
  801f26:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f29:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801f2c:	8b 45 14             	mov    0x14(%ebp),%eax
  801f2f:	8d 40 08             	lea    0x8(%eax),%eax
  801f32:	89 45 14             	mov    %eax,0x14(%ebp)
  801f35:	eb 38                	jmp    801f6f <vprintfmt+0x2ec>
	else if (lflag)
  801f37:	85 c9                	test   %ecx,%ecx
  801f39:	74 1b                	je     801f56 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  801f3b:	8b 45 14             	mov    0x14(%ebp),%eax
  801f3e:	8b 00                	mov    (%eax),%eax
  801f40:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f43:	89 c1                	mov    %eax,%ecx
  801f45:	c1 f9 1f             	sar    $0x1f,%ecx
  801f48:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801f4b:	8b 45 14             	mov    0x14(%ebp),%eax
  801f4e:	8d 40 04             	lea    0x4(%eax),%eax
  801f51:	89 45 14             	mov    %eax,0x14(%ebp)
  801f54:	eb 19                	jmp    801f6f <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  801f56:	8b 45 14             	mov    0x14(%ebp),%eax
  801f59:	8b 00                	mov    (%eax),%eax
  801f5b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f5e:	89 c1                	mov    %eax,%ecx
  801f60:	c1 f9 1f             	sar    $0x1f,%ecx
  801f63:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801f66:	8b 45 14             	mov    0x14(%ebp),%eax
  801f69:	8d 40 04             	lea    0x4(%eax),%eax
  801f6c:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801f6f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801f72:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801f75:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801f7a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801f7e:	0f 89 0e 01 00 00    	jns    802092 <vprintfmt+0x40f>
				putch('-', putdat);
  801f84:	83 ec 08             	sub    $0x8,%esp
  801f87:	53                   	push   %ebx
  801f88:	6a 2d                	push   $0x2d
  801f8a:	ff d6                	call   *%esi
				num = -(long long) num;
  801f8c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801f8f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801f92:	f7 da                	neg    %edx
  801f94:	83 d1 00             	adc    $0x0,%ecx
  801f97:	f7 d9                	neg    %ecx
  801f99:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801f9c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801fa1:	e9 ec 00 00 00       	jmp    802092 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801fa6:	83 f9 01             	cmp    $0x1,%ecx
  801fa9:	7e 18                	jle    801fc3 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801fab:	8b 45 14             	mov    0x14(%ebp),%eax
  801fae:	8b 10                	mov    (%eax),%edx
  801fb0:	8b 48 04             	mov    0x4(%eax),%ecx
  801fb3:	8d 40 08             	lea    0x8(%eax),%eax
  801fb6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801fb9:	b8 0a 00 00 00       	mov    $0xa,%eax
  801fbe:	e9 cf 00 00 00       	jmp    802092 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801fc3:	85 c9                	test   %ecx,%ecx
  801fc5:	74 1a                	je     801fe1 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  801fc7:	8b 45 14             	mov    0x14(%ebp),%eax
  801fca:	8b 10                	mov    (%eax),%edx
  801fcc:	b9 00 00 00 00       	mov    $0x0,%ecx
  801fd1:	8d 40 04             	lea    0x4(%eax),%eax
  801fd4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801fd7:	b8 0a 00 00 00       	mov    $0xa,%eax
  801fdc:	e9 b1 00 00 00       	jmp    802092 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801fe1:	8b 45 14             	mov    0x14(%ebp),%eax
  801fe4:	8b 10                	mov    (%eax),%edx
  801fe6:	b9 00 00 00 00       	mov    $0x0,%ecx
  801feb:	8d 40 04             	lea    0x4(%eax),%eax
  801fee:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801ff1:	b8 0a 00 00 00       	mov    $0xa,%eax
  801ff6:	e9 97 00 00 00       	jmp    802092 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801ffb:	83 ec 08             	sub    $0x8,%esp
  801ffe:	53                   	push   %ebx
  801fff:	6a 58                	push   $0x58
  802001:	ff d6                	call   *%esi
			putch('X', putdat);
  802003:	83 c4 08             	add    $0x8,%esp
  802006:	53                   	push   %ebx
  802007:	6a 58                	push   $0x58
  802009:	ff d6                	call   *%esi
			putch('X', putdat);
  80200b:	83 c4 08             	add    $0x8,%esp
  80200e:	53                   	push   %ebx
  80200f:	6a 58                	push   $0x58
  802011:	ff d6                	call   *%esi
			break;
  802013:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802016:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  802019:	e9 8b fc ff ff       	jmp    801ca9 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80201e:	83 ec 08             	sub    $0x8,%esp
  802021:	53                   	push   %ebx
  802022:	6a 30                	push   $0x30
  802024:	ff d6                	call   *%esi
			putch('x', putdat);
  802026:	83 c4 08             	add    $0x8,%esp
  802029:	53                   	push   %ebx
  80202a:	6a 78                	push   $0x78
  80202c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80202e:	8b 45 14             	mov    0x14(%ebp),%eax
  802031:	8b 10                	mov    (%eax),%edx
  802033:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  802038:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80203b:	8d 40 04             	lea    0x4(%eax),%eax
  80203e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  802041:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  802046:	eb 4a                	jmp    802092 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  802048:	83 f9 01             	cmp    $0x1,%ecx
  80204b:	7e 15                	jle    802062 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80204d:	8b 45 14             	mov    0x14(%ebp),%eax
  802050:	8b 10                	mov    (%eax),%edx
  802052:	8b 48 04             	mov    0x4(%eax),%ecx
  802055:	8d 40 08             	lea    0x8(%eax),%eax
  802058:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80205b:	b8 10 00 00 00       	mov    $0x10,%eax
  802060:	eb 30                	jmp    802092 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  802062:	85 c9                	test   %ecx,%ecx
  802064:	74 17                	je     80207d <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  802066:	8b 45 14             	mov    0x14(%ebp),%eax
  802069:	8b 10                	mov    (%eax),%edx
  80206b:	b9 00 00 00 00       	mov    $0x0,%ecx
  802070:	8d 40 04             	lea    0x4(%eax),%eax
  802073:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  802076:	b8 10 00 00 00       	mov    $0x10,%eax
  80207b:	eb 15                	jmp    802092 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80207d:	8b 45 14             	mov    0x14(%ebp),%eax
  802080:	8b 10                	mov    (%eax),%edx
  802082:	b9 00 00 00 00       	mov    $0x0,%ecx
  802087:	8d 40 04             	lea    0x4(%eax),%eax
  80208a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80208d:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  802092:	83 ec 0c             	sub    $0xc,%esp
  802095:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  802099:	57                   	push   %edi
  80209a:	ff 75 e0             	pushl  -0x20(%ebp)
  80209d:	50                   	push   %eax
  80209e:	51                   	push   %ecx
  80209f:	52                   	push   %edx
  8020a0:	89 da                	mov    %ebx,%edx
  8020a2:	89 f0                	mov    %esi,%eax
  8020a4:	e8 f1 fa ff ff       	call   801b9a <printnum>
			break;
  8020a9:	83 c4 20             	add    $0x20,%esp
  8020ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8020af:	e9 f5 fb ff ff       	jmp    801ca9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8020b4:	83 ec 08             	sub    $0x8,%esp
  8020b7:	53                   	push   %ebx
  8020b8:	52                   	push   %edx
  8020b9:	ff d6                	call   *%esi
			break;
  8020bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8020be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8020c1:	e9 e3 fb ff ff       	jmp    801ca9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8020c6:	83 ec 08             	sub    $0x8,%esp
  8020c9:	53                   	push   %ebx
  8020ca:	6a 25                	push   $0x25
  8020cc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8020ce:	83 c4 10             	add    $0x10,%esp
  8020d1:	eb 03                	jmp    8020d6 <vprintfmt+0x453>
  8020d3:	83 ef 01             	sub    $0x1,%edi
  8020d6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8020da:	75 f7                	jne    8020d3 <vprintfmt+0x450>
  8020dc:	e9 c8 fb ff ff       	jmp    801ca9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8020e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020e4:	5b                   	pop    %ebx
  8020e5:	5e                   	pop    %esi
  8020e6:	5f                   	pop    %edi
  8020e7:	5d                   	pop    %ebp
  8020e8:	c3                   	ret    

008020e9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8020e9:	55                   	push   %ebp
  8020ea:	89 e5                	mov    %esp,%ebp
  8020ec:	83 ec 18             	sub    $0x18,%esp
  8020ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8020f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020f8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8020fc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8020ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  802106:	85 c0                	test   %eax,%eax
  802108:	74 26                	je     802130 <vsnprintf+0x47>
  80210a:	85 d2                	test   %edx,%edx
  80210c:	7e 22                	jle    802130 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80210e:	ff 75 14             	pushl  0x14(%ebp)
  802111:	ff 75 10             	pushl  0x10(%ebp)
  802114:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802117:	50                   	push   %eax
  802118:	68 49 1c 80 00       	push   $0x801c49
  80211d:	e8 61 fb ff ff       	call   801c83 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  802122:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802125:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  802128:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212b:	83 c4 10             	add    $0x10,%esp
  80212e:	eb 05                	jmp    802135 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  802130:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  802135:	c9                   	leave  
  802136:	c3                   	ret    

00802137 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  802137:	55                   	push   %ebp
  802138:	89 e5                	mov    %esp,%ebp
  80213a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80213d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  802140:	50                   	push   %eax
  802141:	ff 75 10             	pushl  0x10(%ebp)
  802144:	ff 75 0c             	pushl  0xc(%ebp)
  802147:	ff 75 08             	pushl  0x8(%ebp)
  80214a:	e8 9a ff ff ff       	call   8020e9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80214f:	c9                   	leave  
  802150:	c3                   	ret    

00802151 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  802151:	55                   	push   %ebp
  802152:	89 e5                	mov    %esp,%ebp
  802154:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  802157:	b8 00 00 00 00       	mov    $0x0,%eax
  80215c:	eb 03                	jmp    802161 <strlen+0x10>
		n++;
  80215e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  802161:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  802165:	75 f7                	jne    80215e <strlen+0xd>
		n++;
	return n;
}
  802167:	5d                   	pop    %ebp
  802168:	c3                   	ret    

00802169 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  802169:	55                   	push   %ebp
  80216a:	89 e5                	mov    %esp,%ebp
  80216c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80216f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802172:	ba 00 00 00 00       	mov    $0x0,%edx
  802177:	eb 03                	jmp    80217c <strnlen+0x13>
		n++;
  802179:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80217c:	39 c2                	cmp    %eax,%edx
  80217e:	74 08                	je     802188 <strnlen+0x1f>
  802180:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  802184:	75 f3                	jne    802179 <strnlen+0x10>
  802186:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  802188:	5d                   	pop    %ebp
  802189:	c3                   	ret    

0080218a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80218a:	55                   	push   %ebp
  80218b:	89 e5                	mov    %esp,%ebp
  80218d:	53                   	push   %ebx
  80218e:	8b 45 08             	mov    0x8(%ebp),%eax
  802191:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  802194:	89 c2                	mov    %eax,%edx
  802196:	83 c2 01             	add    $0x1,%edx
  802199:	83 c1 01             	add    $0x1,%ecx
  80219c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8021a0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8021a3:	84 db                	test   %bl,%bl
  8021a5:	75 ef                	jne    802196 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8021a7:	5b                   	pop    %ebx
  8021a8:	5d                   	pop    %ebp
  8021a9:	c3                   	ret    

008021aa <strcat>:

char *
strcat(char *dst, const char *src)
{
  8021aa:	55                   	push   %ebp
  8021ab:	89 e5                	mov    %esp,%ebp
  8021ad:	53                   	push   %ebx
  8021ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8021b1:	53                   	push   %ebx
  8021b2:	e8 9a ff ff ff       	call   802151 <strlen>
  8021b7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8021ba:	ff 75 0c             	pushl  0xc(%ebp)
  8021bd:	01 d8                	add    %ebx,%eax
  8021bf:	50                   	push   %eax
  8021c0:	e8 c5 ff ff ff       	call   80218a <strcpy>
	return dst;
}
  8021c5:	89 d8                	mov    %ebx,%eax
  8021c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021ca:	c9                   	leave  
  8021cb:	c3                   	ret    

008021cc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8021cc:	55                   	push   %ebp
  8021cd:	89 e5                	mov    %esp,%ebp
  8021cf:	56                   	push   %esi
  8021d0:	53                   	push   %ebx
  8021d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8021d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021d7:	89 f3                	mov    %esi,%ebx
  8021d9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8021dc:	89 f2                	mov    %esi,%edx
  8021de:	eb 0f                	jmp    8021ef <strncpy+0x23>
		*dst++ = *src;
  8021e0:	83 c2 01             	add    $0x1,%edx
  8021e3:	0f b6 01             	movzbl (%ecx),%eax
  8021e6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8021e9:	80 39 01             	cmpb   $0x1,(%ecx)
  8021ec:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8021ef:	39 da                	cmp    %ebx,%edx
  8021f1:	75 ed                	jne    8021e0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8021f3:	89 f0                	mov    %esi,%eax
  8021f5:	5b                   	pop    %ebx
  8021f6:	5e                   	pop    %esi
  8021f7:	5d                   	pop    %ebp
  8021f8:	c3                   	ret    

008021f9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8021f9:	55                   	push   %ebp
  8021fa:	89 e5                	mov    %esp,%ebp
  8021fc:	56                   	push   %esi
  8021fd:	53                   	push   %ebx
  8021fe:	8b 75 08             	mov    0x8(%ebp),%esi
  802201:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802204:	8b 55 10             	mov    0x10(%ebp),%edx
  802207:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802209:	85 d2                	test   %edx,%edx
  80220b:	74 21                	je     80222e <strlcpy+0x35>
  80220d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  802211:	89 f2                	mov    %esi,%edx
  802213:	eb 09                	jmp    80221e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  802215:	83 c2 01             	add    $0x1,%edx
  802218:	83 c1 01             	add    $0x1,%ecx
  80221b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80221e:	39 c2                	cmp    %eax,%edx
  802220:	74 09                	je     80222b <strlcpy+0x32>
  802222:	0f b6 19             	movzbl (%ecx),%ebx
  802225:	84 db                	test   %bl,%bl
  802227:	75 ec                	jne    802215 <strlcpy+0x1c>
  802229:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80222b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80222e:	29 f0                	sub    %esi,%eax
}
  802230:	5b                   	pop    %ebx
  802231:	5e                   	pop    %esi
  802232:	5d                   	pop    %ebp
  802233:	c3                   	ret    

00802234 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  802234:	55                   	push   %ebp
  802235:	89 e5                	mov    %esp,%ebp
  802237:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80223a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80223d:	eb 06                	jmp    802245 <strcmp+0x11>
		p++, q++;
  80223f:	83 c1 01             	add    $0x1,%ecx
  802242:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  802245:	0f b6 01             	movzbl (%ecx),%eax
  802248:	84 c0                	test   %al,%al
  80224a:	74 04                	je     802250 <strcmp+0x1c>
  80224c:	3a 02                	cmp    (%edx),%al
  80224e:	74 ef                	je     80223f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  802250:	0f b6 c0             	movzbl %al,%eax
  802253:	0f b6 12             	movzbl (%edx),%edx
  802256:	29 d0                	sub    %edx,%eax
}
  802258:	5d                   	pop    %ebp
  802259:	c3                   	ret    

0080225a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80225a:	55                   	push   %ebp
  80225b:	89 e5                	mov    %esp,%ebp
  80225d:	53                   	push   %ebx
  80225e:	8b 45 08             	mov    0x8(%ebp),%eax
  802261:	8b 55 0c             	mov    0xc(%ebp),%edx
  802264:	89 c3                	mov    %eax,%ebx
  802266:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  802269:	eb 06                	jmp    802271 <strncmp+0x17>
		n--, p++, q++;
  80226b:	83 c0 01             	add    $0x1,%eax
  80226e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  802271:	39 d8                	cmp    %ebx,%eax
  802273:	74 15                	je     80228a <strncmp+0x30>
  802275:	0f b6 08             	movzbl (%eax),%ecx
  802278:	84 c9                	test   %cl,%cl
  80227a:	74 04                	je     802280 <strncmp+0x26>
  80227c:	3a 0a                	cmp    (%edx),%cl
  80227e:	74 eb                	je     80226b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  802280:	0f b6 00             	movzbl (%eax),%eax
  802283:	0f b6 12             	movzbl (%edx),%edx
  802286:	29 d0                	sub    %edx,%eax
  802288:	eb 05                	jmp    80228f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80228a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80228f:	5b                   	pop    %ebx
  802290:	5d                   	pop    %ebp
  802291:	c3                   	ret    

00802292 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  802292:	55                   	push   %ebp
  802293:	89 e5                	mov    %esp,%ebp
  802295:	8b 45 08             	mov    0x8(%ebp),%eax
  802298:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80229c:	eb 07                	jmp    8022a5 <strchr+0x13>
		if (*s == c)
  80229e:	38 ca                	cmp    %cl,%dl
  8022a0:	74 0f                	je     8022b1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8022a2:	83 c0 01             	add    $0x1,%eax
  8022a5:	0f b6 10             	movzbl (%eax),%edx
  8022a8:	84 d2                	test   %dl,%dl
  8022aa:	75 f2                	jne    80229e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8022ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022b1:	5d                   	pop    %ebp
  8022b2:	c3                   	ret    

008022b3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8022b3:	55                   	push   %ebp
  8022b4:	89 e5                	mov    %esp,%ebp
  8022b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8022bd:	eb 03                	jmp    8022c2 <strfind+0xf>
  8022bf:	83 c0 01             	add    $0x1,%eax
  8022c2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8022c5:	38 ca                	cmp    %cl,%dl
  8022c7:	74 04                	je     8022cd <strfind+0x1a>
  8022c9:	84 d2                	test   %dl,%dl
  8022cb:	75 f2                	jne    8022bf <strfind+0xc>
			break;
	return (char *) s;
}
  8022cd:	5d                   	pop    %ebp
  8022ce:	c3                   	ret    

008022cf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8022cf:	55                   	push   %ebp
  8022d0:	89 e5                	mov    %esp,%ebp
  8022d2:	57                   	push   %edi
  8022d3:	56                   	push   %esi
  8022d4:	53                   	push   %ebx
  8022d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8022db:	85 c9                	test   %ecx,%ecx
  8022dd:	74 36                	je     802315 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8022df:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8022e5:	75 28                	jne    80230f <memset+0x40>
  8022e7:	f6 c1 03             	test   $0x3,%cl
  8022ea:	75 23                	jne    80230f <memset+0x40>
		c &= 0xFF;
  8022ec:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8022f0:	89 d3                	mov    %edx,%ebx
  8022f2:	c1 e3 08             	shl    $0x8,%ebx
  8022f5:	89 d6                	mov    %edx,%esi
  8022f7:	c1 e6 18             	shl    $0x18,%esi
  8022fa:	89 d0                	mov    %edx,%eax
  8022fc:	c1 e0 10             	shl    $0x10,%eax
  8022ff:	09 f0                	or     %esi,%eax
  802301:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  802303:	89 d8                	mov    %ebx,%eax
  802305:	09 d0                	or     %edx,%eax
  802307:	c1 e9 02             	shr    $0x2,%ecx
  80230a:	fc                   	cld    
  80230b:	f3 ab                	rep stos %eax,%es:(%edi)
  80230d:	eb 06                	jmp    802315 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80230f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802312:	fc                   	cld    
  802313:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802315:	89 f8                	mov    %edi,%eax
  802317:	5b                   	pop    %ebx
  802318:	5e                   	pop    %esi
  802319:	5f                   	pop    %edi
  80231a:	5d                   	pop    %ebp
  80231b:	c3                   	ret    

0080231c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80231c:	55                   	push   %ebp
  80231d:	89 e5                	mov    %esp,%ebp
  80231f:	57                   	push   %edi
  802320:	56                   	push   %esi
  802321:	8b 45 08             	mov    0x8(%ebp),%eax
  802324:	8b 75 0c             	mov    0xc(%ebp),%esi
  802327:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80232a:	39 c6                	cmp    %eax,%esi
  80232c:	73 35                	jae    802363 <memmove+0x47>
  80232e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802331:	39 d0                	cmp    %edx,%eax
  802333:	73 2e                	jae    802363 <memmove+0x47>
		s += n;
		d += n;
  802335:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802338:	89 d6                	mov    %edx,%esi
  80233a:	09 fe                	or     %edi,%esi
  80233c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  802342:	75 13                	jne    802357 <memmove+0x3b>
  802344:	f6 c1 03             	test   $0x3,%cl
  802347:	75 0e                	jne    802357 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  802349:	83 ef 04             	sub    $0x4,%edi
  80234c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80234f:	c1 e9 02             	shr    $0x2,%ecx
  802352:	fd                   	std    
  802353:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802355:	eb 09                	jmp    802360 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  802357:	83 ef 01             	sub    $0x1,%edi
  80235a:	8d 72 ff             	lea    -0x1(%edx),%esi
  80235d:	fd                   	std    
  80235e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802360:	fc                   	cld    
  802361:	eb 1d                	jmp    802380 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802363:	89 f2                	mov    %esi,%edx
  802365:	09 c2                	or     %eax,%edx
  802367:	f6 c2 03             	test   $0x3,%dl
  80236a:	75 0f                	jne    80237b <memmove+0x5f>
  80236c:	f6 c1 03             	test   $0x3,%cl
  80236f:	75 0a                	jne    80237b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  802371:	c1 e9 02             	shr    $0x2,%ecx
  802374:	89 c7                	mov    %eax,%edi
  802376:	fc                   	cld    
  802377:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802379:	eb 05                	jmp    802380 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80237b:	89 c7                	mov    %eax,%edi
  80237d:	fc                   	cld    
  80237e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802380:	5e                   	pop    %esi
  802381:	5f                   	pop    %edi
  802382:	5d                   	pop    %ebp
  802383:	c3                   	ret    

00802384 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  802384:	55                   	push   %ebp
  802385:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  802387:	ff 75 10             	pushl  0x10(%ebp)
  80238a:	ff 75 0c             	pushl  0xc(%ebp)
  80238d:	ff 75 08             	pushl  0x8(%ebp)
  802390:	e8 87 ff ff ff       	call   80231c <memmove>
}
  802395:	c9                   	leave  
  802396:	c3                   	ret    

00802397 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802397:	55                   	push   %ebp
  802398:	89 e5                	mov    %esp,%ebp
  80239a:	56                   	push   %esi
  80239b:	53                   	push   %ebx
  80239c:	8b 45 08             	mov    0x8(%ebp),%eax
  80239f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023a2:	89 c6                	mov    %eax,%esi
  8023a4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8023a7:	eb 1a                	jmp    8023c3 <memcmp+0x2c>
		if (*s1 != *s2)
  8023a9:	0f b6 08             	movzbl (%eax),%ecx
  8023ac:	0f b6 1a             	movzbl (%edx),%ebx
  8023af:	38 d9                	cmp    %bl,%cl
  8023b1:	74 0a                	je     8023bd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8023b3:	0f b6 c1             	movzbl %cl,%eax
  8023b6:	0f b6 db             	movzbl %bl,%ebx
  8023b9:	29 d8                	sub    %ebx,%eax
  8023bb:	eb 0f                	jmp    8023cc <memcmp+0x35>
		s1++, s2++;
  8023bd:	83 c0 01             	add    $0x1,%eax
  8023c0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8023c3:	39 f0                	cmp    %esi,%eax
  8023c5:	75 e2                	jne    8023a9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8023c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023cc:	5b                   	pop    %ebx
  8023cd:	5e                   	pop    %esi
  8023ce:	5d                   	pop    %ebp
  8023cf:	c3                   	ret    

008023d0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8023d0:	55                   	push   %ebp
  8023d1:	89 e5                	mov    %esp,%ebp
  8023d3:	53                   	push   %ebx
  8023d4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8023d7:	89 c1                	mov    %eax,%ecx
  8023d9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8023dc:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8023e0:	eb 0a                	jmp    8023ec <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8023e2:	0f b6 10             	movzbl (%eax),%edx
  8023e5:	39 da                	cmp    %ebx,%edx
  8023e7:	74 07                	je     8023f0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8023e9:	83 c0 01             	add    $0x1,%eax
  8023ec:	39 c8                	cmp    %ecx,%eax
  8023ee:	72 f2                	jb     8023e2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8023f0:	5b                   	pop    %ebx
  8023f1:	5d                   	pop    %ebp
  8023f2:	c3                   	ret    

008023f3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8023f3:	55                   	push   %ebp
  8023f4:	89 e5                	mov    %esp,%ebp
  8023f6:	57                   	push   %edi
  8023f7:	56                   	push   %esi
  8023f8:	53                   	push   %ebx
  8023f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8023ff:	eb 03                	jmp    802404 <strtol+0x11>
		s++;
  802401:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802404:	0f b6 01             	movzbl (%ecx),%eax
  802407:	3c 20                	cmp    $0x20,%al
  802409:	74 f6                	je     802401 <strtol+0xe>
  80240b:	3c 09                	cmp    $0x9,%al
  80240d:	74 f2                	je     802401 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80240f:	3c 2b                	cmp    $0x2b,%al
  802411:	75 0a                	jne    80241d <strtol+0x2a>
		s++;
  802413:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802416:	bf 00 00 00 00       	mov    $0x0,%edi
  80241b:	eb 11                	jmp    80242e <strtol+0x3b>
  80241d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802422:	3c 2d                	cmp    $0x2d,%al
  802424:	75 08                	jne    80242e <strtol+0x3b>
		s++, neg = 1;
  802426:	83 c1 01             	add    $0x1,%ecx
  802429:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80242e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  802434:	75 15                	jne    80244b <strtol+0x58>
  802436:	80 39 30             	cmpb   $0x30,(%ecx)
  802439:	75 10                	jne    80244b <strtol+0x58>
  80243b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80243f:	75 7c                	jne    8024bd <strtol+0xca>
		s += 2, base = 16;
  802441:	83 c1 02             	add    $0x2,%ecx
  802444:	bb 10 00 00 00       	mov    $0x10,%ebx
  802449:	eb 16                	jmp    802461 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80244b:	85 db                	test   %ebx,%ebx
  80244d:	75 12                	jne    802461 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80244f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802454:	80 39 30             	cmpb   $0x30,(%ecx)
  802457:	75 08                	jne    802461 <strtol+0x6e>
		s++, base = 8;
  802459:	83 c1 01             	add    $0x1,%ecx
  80245c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  802461:	b8 00 00 00 00       	mov    $0x0,%eax
  802466:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802469:	0f b6 11             	movzbl (%ecx),%edx
  80246c:	8d 72 d0             	lea    -0x30(%edx),%esi
  80246f:	89 f3                	mov    %esi,%ebx
  802471:	80 fb 09             	cmp    $0x9,%bl
  802474:	77 08                	ja     80247e <strtol+0x8b>
			dig = *s - '0';
  802476:	0f be d2             	movsbl %dl,%edx
  802479:	83 ea 30             	sub    $0x30,%edx
  80247c:	eb 22                	jmp    8024a0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80247e:	8d 72 9f             	lea    -0x61(%edx),%esi
  802481:	89 f3                	mov    %esi,%ebx
  802483:	80 fb 19             	cmp    $0x19,%bl
  802486:	77 08                	ja     802490 <strtol+0x9d>
			dig = *s - 'a' + 10;
  802488:	0f be d2             	movsbl %dl,%edx
  80248b:	83 ea 57             	sub    $0x57,%edx
  80248e:	eb 10                	jmp    8024a0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  802490:	8d 72 bf             	lea    -0x41(%edx),%esi
  802493:	89 f3                	mov    %esi,%ebx
  802495:	80 fb 19             	cmp    $0x19,%bl
  802498:	77 16                	ja     8024b0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80249a:	0f be d2             	movsbl %dl,%edx
  80249d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8024a0:	3b 55 10             	cmp    0x10(%ebp),%edx
  8024a3:	7d 0b                	jge    8024b0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8024a5:	83 c1 01             	add    $0x1,%ecx
  8024a8:	0f af 45 10          	imul   0x10(%ebp),%eax
  8024ac:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8024ae:	eb b9                	jmp    802469 <strtol+0x76>

	if (endptr)
  8024b0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8024b4:	74 0d                	je     8024c3 <strtol+0xd0>
		*endptr = (char *) s;
  8024b6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024b9:	89 0e                	mov    %ecx,(%esi)
  8024bb:	eb 06                	jmp    8024c3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8024bd:	85 db                	test   %ebx,%ebx
  8024bf:	74 98                	je     802459 <strtol+0x66>
  8024c1:	eb 9e                	jmp    802461 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8024c3:	89 c2                	mov    %eax,%edx
  8024c5:	f7 da                	neg    %edx
  8024c7:	85 ff                	test   %edi,%edi
  8024c9:	0f 45 c2             	cmovne %edx,%eax
}
  8024cc:	5b                   	pop    %ebx
  8024cd:	5e                   	pop    %esi
  8024ce:	5f                   	pop    %edi
  8024cf:	5d                   	pop    %ebp
  8024d0:	c3                   	ret    

008024d1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8024d1:	55                   	push   %ebp
  8024d2:	89 e5                	mov    %esp,%ebp
  8024d4:	57                   	push   %edi
  8024d5:	56                   	push   %esi
  8024d6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8024dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024df:	8b 55 08             	mov    0x8(%ebp),%edx
  8024e2:	89 c3                	mov    %eax,%ebx
  8024e4:	89 c7                	mov    %eax,%edi
  8024e6:	89 c6                	mov    %eax,%esi
  8024e8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8024ea:	5b                   	pop    %ebx
  8024eb:	5e                   	pop    %esi
  8024ec:	5f                   	pop    %edi
  8024ed:	5d                   	pop    %ebp
  8024ee:	c3                   	ret    

008024ef <sys_cgetc>:

int
sys_cgetc(void)
{
  8024ef:	55                   	push   %ebp
  8024f0:	89 e5                	mov    %esp,%ebp
  8024f2:	57                   	push   %edi
  8024f3:	56                   	push   %esi
  8024f4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8024fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8024ff:	89 d1                	mov    %edx,%ecx
  802501:	89 d3                	mov    %edx,%ebx
  802503:	89 d7                	mov    %edx,%edi
  802505:	89 d6                	mov    %edx,%esi
  802507:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802509:	5b                   	pop    %ebx
  80250a:	5e                   	pop    %esi
  80250b:	5f                   	pop    %edi
  80250c:	5d                   	pop    %ebp
  80250d:	c3                   	ret    

0080250e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80250e:	55                   	push   %ebp
  80250f:	89 e5                	mov    %esp,%ebp
  802511:	57                   	push   %edi
  802512:	56                   	push   %esi
  802513:	53                   	push   %ebx
  802514:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802517:	b9 00 00 00 00       	mov    $0x0,%ecx
  80251c:	b8 03 00 00 00       	mov    $0x3,%eax
  802521:	8b 55 08             	mov    0x8(%ebp),%edx
  802524:	89 cb                	mov    %ecx,%ebx
  802526:	89 cf                	mov    %ecx,%edi
  802528:	89 ce                	mov    %ecx,%esi
  80252a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80252c:	85 c0                	test   %eax,%eax
  80252e:	7e 17                	jle    802547 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  802530:	83 ec 0c             	sub    $0xc,%esp
  802533:	50                   	push   %eax
  802534:	6a 03                	push   $0x3
  802536:	68 3f 41 80 00       	push   $0x80413f
  80253b:	6a 23                	push   $0x23
  80253d:	68 5c 41 80 00       	push   $0x80415c
  802542:	e8 66 f5 ff ff       	call   801aad <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  802547:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80254a:	5b                   	pop    %ebx
  80254b:	5e                   	pop    %esi
  80254c:	5f                   	pop    %edi
  80254d:	5d                   	pop    %ebp
  80254e:	c3                   	ret    

0080254f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80254f:	55                   	push   %ebp
  802550:	89 e5                	mov    %esp,%ebp
  802552:	57                   	push   %edi
  802553:	56                   	push   %esi
  802554:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802555:	ba 00 00 00 00       	mov    $0x0,%edx
  80255a:	b8 02 00 00 00       	mov    $0x2,%eax
  80255f:	89 d1                	mov    %edx,%ecx
  802561:	89 d3                	mov    %edx,%ebx
  802563:	89 d7                	mov    %edx,%edi
  802565:	89 d6                	mov    %edx,%esi
  802567:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  802569:	5b                   	pop    %ebx
  80256a:	5e                   	pop    %esi
  80256b:	5f                   	pop    %edi
  80256c:	5d                   	pop    %ebp
  80256d:	c3                   	ret    

0080256e <sys_yield>:

void
sys_yield(void)
{
  80256e:	55                   	push   %ebp
  80256f:	89 e5                	mov    %esp,%ebp
  802571:	57                   	push   %edi
  802572:	56                   	push   %esi
  802573:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802574:	ba 00 00 00 00       	mov    $0x0,%edx
  802579:	b8 0b 00 00 00       	mov    $0xb,%eax
  80257e:	89 d1                	mov    %edx,%ecx
  802580:	89 d3                	mov    %edx,%ebx
  802582:	89 d7                	mov    %edx,%edi
  802584:	89 d6                	mov    %edx,%esi
  802586:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  802588:	5b                   	pop    %ebx
  802589:	5e                   	pop    %esi
  80258a:	5f                   	pop    %edi
  80258b:	5d                   	pop    %ebp
  80258c:	c3                   	ret    

0080258d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80258d:	55                   	push   %ebp
  80258e:	89 e5                	mov    %esp,%ebp
  802590:	57                   	push   %edi
  802591:	56                   	push   %esi
  802592:	53                   	push   %ebx
  802593:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802596:	be 00 00 00 00       	mov    $0x0,%esi
  80259b:	b8 04 00 00 00       	mov    $0x4,%eax
  8025a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8025a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025a9:	89 f7                	mov    %esi,%edi
  8025ab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8025ad:	85 c0                	test   %eax,%eax
  8025af:	7e 17                	jle    8025c8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025b1:	83 ec 0c             	sub    $0xc,%esp
  8025b4:	50                   	push   %eax
  8025b5:	6a 04                	push   $0x4
  8025b7:	68 3f 41 80 00       	push   $0x80413f
  8025bc:	6a 23                	push   $0x23
  8025be:	68 5c 41 80 00       	push   $0x80415c
  8025c3:	e8 e5 f4 ff ff       	call   801aad <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8025c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025cb:	5b                   	pop    %ebx
  8025cc:	5e                   	pop    %esi
  8025cd:	5f                   	pop    %edi
  8025ce:	5d                   	pop    %ebp
  8025cf:	c3                   	ret    

008025d0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8025d0:	55                   	push   %ebp
  8025d1:	89 e5                	mov    %esp,%ebp
  8025d3:	57                   	push   %edi
  8025d4:	56                   	push   %esi
  8025d5:	53                   	push   %ebx
  8025d6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025d9:	b8 05 00 00 00       	mov    $0x5,%eax
  8025de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8025e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025e7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8025ea:	8b 75 18             	mov    0x18(%ebp),%esi
  8025ed:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8025ef:	85 c0                	test   %eax,%eax
  8025f1:	7e 17                	jle    80260a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025f3:	83 ec 0c             	sub    $0xc,%esp
  8025f6:	50                   	push   %eax
  8025f7:	6a 05                	push   $0x5
  8025f9:	68 3f 41 80 00       	push   $0x80413f
  8025fe:	6a 23                	push   $0x23
  802600:	68 5c 41 80 00       	push   $0x80415c
  802605:	e8 a3 f4 ff ff       	call   801aad <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80260a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80260d:	5b                   	pop    %ebx
  80260e:	5e                   	pop    %esi
  80260f:	5f                   	pop    %edi
  802610:	5d                   	pop    %ebp
  802611:	c3                   	ret    

00802612 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802612:	55                   	push   %ebp
  802613:	89 e5                	mov    %esp,%ebp
  802615:	57                   	push   %edi
  802616:	56                   	push   %esi
  802617:	53                   	push   %ebx
  802618:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80261b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802620:	b8 06 00 00 00       	mov    $0x6,%eax
  802625:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802628:	8b 55 08             	mov    0x8(%ebp),%edx
  80262b:	89 df                	mov    %ebx,%edi
  80262d:	89 de                	mov    %ebx,%esi
  80262f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802631:	85 c0                	test   %eax,%eax
  802633:	7e 17                	jle    80264c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802635:	83 ec 0c             	sub    $0xc,%esp
  802638:	50                   	push   %eax
  802639:	6a 06                	push   $0x6
  80263b:	68 3f 41 80 00       	push   $0x80413f
  802640:	6a 23                	push   $0x23
  802642:	68 5c 41 80 00       	push   $0x80415c
  802647:	e8 61 f4 ff ff       	call   801aad <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80264c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80264f:	5b                   	pop    %ebx
  802650:	5e                   	pop    %esi
  802651:	5f                   	pop    %edi
  802652:	5d                   	pop    %ebp
  802653:	c3                   	ret    

00802654 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  802654:	55                   	push   %ebp
  802655:	89 e5                	mov    %esp,%ebp
  802657:	57                   	push   %edi
  802658:	56                   	push   %esi
  802659:	53                   	push   %ebx
  80265a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80265d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802662:	b8 08 00 00 00       	mov    $0x8,%eax
  802667:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80266a:	8b 55 08             	mov    0x8(%ebp),%edx
  80266d:	89 df                	mov    %ebx,%edi
  80266f:	89 de                	mov    %ebx,%esi
  802671:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802673:	85 c0                	test   %eax,%eax
  802675:	7e 17                	jle    80268e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802677:	83 ec 0c             	sub    $0xc,%esp
  80267a:	50                   	push   %eax
  80267b:	6a 08                	push   $0x8
  80267d:	68 3f 41 80 00       	push   $0x80413f
  802682:	6a 23                	push   $0x23
  802684:	68 5c 41 80 00       	push   $0x80415c
  802689:	e8 1f f4 ff ff       	call   801aad <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80268e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802691:	5b                   	pop    %ebx
  802692:	5e                   	pop    %esi
  802693:	5f                   	pop    %edi
  802694:	5d                   	pop    %ebp
  802695:	c3                   	ret    

00802696 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802696:	55                   	push   %ebp
  802697:	89 e5                	mov    %esp,%ebp
  802699:	57                   	push   %edi
  80269a:	56                   	push   %esi
  80269b:	53                   	push   %ebx
  80269c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80269f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026a4:	b8 09 00 00 00       	mov    $0x9,%eax
  8026a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8026af:	89 df                	mov    %ebx,%edi
  8026b1:	89 de                	mov    %ebx,%esi
  8026b3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8026b5:	85 c0                	test   %eax,%eax
  8026b7:	7e 17                	jle    8026d0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026b9:	83 ec 0c             	sub    $0xc,%esp
  8026bc:	50                   	push   %eax
  8026bd:	6a 09                	push   $0x9
  8026bf:	68 3f 41 80 00       	push   $0x80413f
  8026c4:	6a 23                	push   $0x23
  8026c6:	68 5c 41 80 00       	push   $0x80415c
  8026cb:	e8 dd f3 ff ff       	call   801aad <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8026d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026d3:	5b                   	pop    %ebx
  8026d4:	5e                   	pop    %esi
  8026d5:	5f                   	pop    %edi
  8026d6:	5d                   	pop    %ebp
  8026d7:	c3                   	ret    

008026d8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8026d8:	55                   	push   %ebp
  8026d9:	89 e5                	mov    %esp,%ebp
  8026db:	57                   	push   %edi
  8026dc:	56                   	push   %esi
  8026dd:	53                   	push   %ebx
  8026de:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026e6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8026eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8026f1:	89 df                	mov    %ebx,%edi
  8026f3:	89 de                	mov    %ebx,%esi
  8026f5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8026f7:	85 c0                	test   %eax,%eax
  8026f9:	7e 17                	jle    802712 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026fb:	83 ec 0c             	sub    $0xc,%esp
  8026fe:	50                   	push   %eax
  8026ff:	6a 0a                	push   $0xa
  802701:	68 3f 41 80 00       	push   $0x80413f
  802706:	6a 23                	push   $0x23
  802708:	68 5c 41 80 00       	push   $0x80415c
  80270d:	e8 9b f3 ff ff       	call   801aad <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802712:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802715:	5b                   	pop    %ebx
  802716:	5e                   	pop    %esi
  802717:	5f                   	pop    %edi
  802718:	5d                   	pop    %ebp
  802719:	c3                   	ret    

0080271a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80271a:	55                   	push   %ebp
  80271b:	89 e5                	mov    %esp,%ebp
  80271d:	57                   	push   %edi
  80271e:	56                   	push   %esi
  80271f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802720:	be 00 00 00 00       	mov    $0x0,%esi
  802725:	b8 0c 00 00 00       	mov    $0xc,%eax
  80272a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80272d:	8b 55 08             	mov    0x8(%ebp),%edx
  802730:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802733:	8b 7d 14             	mov    0x14(%ebp),%edi
  802736:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  802738:	5b                   	pop    %ebx
  802739:	5e                   	pop    %esi
  80273a:	5f                   	pop    %edi
  80273b:	5d                   	pop    %ebp
  80273c:	c3                   	ret    

0080273d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80273d:	55                   	push   %ebp
  80273e:	89 e5                	mov    %esp,%ebp
  802740:	57                   	push   %edi
  802741:	56                   	push   %esi
  802742:	53                   	push   %ebx
  802743:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802746:	b9 00 00 00 00       	mov    $0x0,%ecx
  80274b:	b8 0d 00 00 00       	mov    $0xd,%eax
  802750:	8b 55 08             	mov    0x8(%ebp),%edx
  802753:	89 cb                	mov    %ecx,%ebx
  802755:	89 cf                	mov    %ecx,%edi
  802757:	89 ce                	mov    %ecx,%esi
  802759:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80275b:	85 c0                	test   %eax,%eax
  80275d:	7e 17                	jle    802776 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80275f:	83 ec 0c             	sub    $0xc,%esp
  802762:	50                   	push   %eax
  802763:	6a 0d                	push   $0xd
  802765:	68 3f 41 80 00       	push   $0x80413f
  80276a:	6a 23                	push   $0x23
  80276c:	68 5c 41 80 00       	push   $0x80415c
  802771:	e8 37 f3 ff ff       	call   801aad <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802776:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802779:	5b                   	pop    %ebx
  80277a:	5e                   	pop    %esi
  80277b:	5f                   	pop    %edi
  80277c:	5d                   	pop    %ebp
  80277d:	c3                   	ret    

0080277e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80277e:	55                   	push   %ebp
  80277f:	89 e5                	mov    %esp,%ebp
  802781:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802784:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  80278b:	75 4a                	jne    8027d7 <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  80278d:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802792:	8b 40 48             	mov    0x48(%eax),%eax
  802795:	83 ec 04             	sub    $0x4,%esp
  802798:	6a 07                	push   $0x7
  80279a:	68 00 f0 bf ee       	push   $0xeebff000
  80279f:	50                   	push   %eax
  8027a0:	e8 e8 fd ff ff       	call   80258d <sys_page_alloc>
  8027a5:	83 c4 10             	add    $0x10,%esp
  8027a8:	85 c0                	test   %eax,%eax
  8027aa:	79 12                	jns    8027be <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  8027ac:	50                   	push   %eax
  8027ad:	68 6a 41 80 00       	push   $0x80416a
  8027b2:	6a 21                	push   $0x21
  8027b4:	68 82 41 80 00       	push   $0x804182
  8027b9:	e8 ef f2 ff ff       	call   801aad <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8027be:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8027c3:	8b 40 48             	mov    0x48(%eax),%eax
  8027c6:	83 ec 08             	sub    $0x8,%esp
  8027c9:	68 e1 27 80 00       	push   $0x8027e1
  8027ce:	50                   	push   %eax
  8027cf:	e8 04 ff ff ff       	call   8026d8 <sys_env_set_pgfault_upcall>
  8027d4:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8027d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8027da:	a3 10 a0 80 00       	mov    %eax,0x80a010
  8027df:	c9                   	leave  
  8027e0:	c3                   	ret    

008027e1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8027e1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8027e2:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  8027e7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8027e9:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  8027ec:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  8027ef:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  8027f3:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  8027f8:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  8027fc:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8027fe:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  8027ff:	83 c4 04             	add    $0x4,%esp
	popfl
  802802:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802803:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  802804:	c3                   	ret    

00802805 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802805:	55                   	push   %ebp
  802806:	89 e5                	mov    %esp,%ebp
  802808:	56                   	push   %esi
  802809:	53                   	push   %ebx
  80280a:	8b 75 08             	mov    0x8(%ebp),%esi
  80280d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802810:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  802813:	85 c0                	test   %eax,%eax
  802815:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80281a:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  80281d:	83 ec 0c             	sub    $0xc,%esp
  802820:	50                   	push   %eax
  802821:	e8 17 ff ff ff       	call   80273d <sys_ipc_recv>
  802826:	83 c4 10             	add    $0x10,%esp
  802829:	85 c0                	test   %eax,%eax
  80282b:	79 16                	jns    802843 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  80282d:	85 f6                	test   %esi,%esi
  80282f:	74 06                	je     802837 <ipc_recv+0x32>
            *from_env_store = 0;
  802831:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  802837:	85 db                	test   %ebx,%ebx
  802839:	74 2c                	je     802867 <ipc_recv+0x62>
            *perm_store = 0;
  80283b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802841:	eb 24                	jmp    802867 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  802843:	85 f6                	test   %esi,%esi
  802845:	74 0a                	je     802851 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  802847:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80284c:	8b 40 74             	mov    0x74(%eax),%eax
  80284f:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  802851:	85 db                	test   %ebx,%ebx
  802853:	74 0a                	je     80285f <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  802855:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80285a:	8b 40 78             	mov    0x78(%eax),%eax
  80285d:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  80285f:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802864:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  802867:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80286a:	5b                   	pop    %ebx
  80286b:	5e                   	pop    %esi
  80286c:	5d                   	pop    %ebp
  80286d:	c3                   	ret    

0080286e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80286e:	55                   	push   %ebp
  80286f:	89 e5                	mov    %esp,%ebp
  802871:	57                   	push   %edi
  802872:	56                   	push   %esi
  802873:	53                   	push   %ebx
  802874:	83 ec 0c             	sub    $0xc,%esp
  802877:	8b 7d 08             	mov    0x8(%ebp),%edi
  80287a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80287d:	8b 45 10             	mov    0x10(%ebp),%eax
  802880:	85 c0                	test   %eax,%eax
  802882:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802887:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80288a:	eb 1c                	jmp    8028a8 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  80288c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80288f:	74 12                	je     8028a3 <ipc_send+0x35>
  802891:	50                   	push   %eax
  802892:	68 90 41 80 00       	push   $0x804190
  802897:	6a 3a                	push   $0x3a
  802899:	68 a6 41 80 00       	push   $0x8041a6
  80289e:	e8 0a f2 ff ff       	call   801aad <_panic>
		sys_yield();
  8028a3:	e8 c6 fc ff ff       	call   80256e <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  8028a8:	ff 75 14             	pushl  0x14(%ebp)
  8028ab:	53                   	push   %ebx
  8028ac:	56                   	push   %esi
  8028ad:	57                   	push   %edi
  8028ae:	e8 67 fe ff ff       	call   80271a <sys_ipc_try_send>
  8028b3:	83 c4 10             	add    $0x10,%esp
  8028b6:	85 c0                	test   %eax,%eax
  8028b8:	78 d2                	js     80288c <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  8028ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8028bd:	5b                   	pop    %ebx
  8028be:	5e                   	pop    %esi
  8028bf:	5f                   	pop    %edi
  8028c0:	5d                   	pop    %ebp
  8028c1:	c3                   	ret    

008028c2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8028c2:	55                   	push   %ebp
  8028c3:	89 e5                	mov    %esp,%ebp
  8028c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8028c8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8028cd:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8028d0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8028d6:	8b 52 50             	mov    0x50(%edx),%edx
  8028d9:	39 ca                	cmp    %ecx,%edx
  8028db:	75 0d                	jne    8028ea <ipc_find_env+0x28>
			return envs[i].env_id;
  8028dd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8028e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8028e5:	8b 40 48             	mov    0x48(%eax),%eax
  8028e8:	eb 0f                	jmp    8028f9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8028ea:	83 c0 01             	add    $0x1,%eax
  8028ed:	3d 00 04 00 00       	cmp    $0x400,%eax
  8028f2:	75 d9                	jne    8028cd <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8028f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8028f9:	5d                   	pop    %ebp
  8028fa:	c3                   	ret    

008028fb <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8028fb:	55                   	push   %ebp
  8028fc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8028fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802901:	05 00 00 00 30       	add    $0x30000000,%eax
  802906:	c1 e8 0c             	shr    $0xc,%eax
}
  802909:	5d                   	pop    %ebp
  80290a:	c3                   	ret    

0080290b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80290b:	55                   	push   %ebp
  80290c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80290e:	8b 45 08             	mov    0x8(%ebp),%eax
  802911:	05 00 00 00 30       	add    $0x30000000,%eax
  802916:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80291b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802920:	5d                   	pop    %ebp
  802921:	c3                   	ret    

00802922 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802922:	55                   	push   %ebp
  802923:	89 e5                	mov    %esp,%ebp
  802925:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802928:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80292d:	89 c2                	mov    %eax,%edx
  80292f:	c1 ea 16             	shr    $0x16,%edx
  802932:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802939:	f6 c2 01             	test   $0x1,%dl
  80293c:	74 11                	je     80294f <fd_alloc+0x2d>
  80293e:	89 c2                	mov    %eax,%edx
  802940:	c1 ea 0c             	shr    $0xc,%edx
  802943:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80294a:	f6 c2 01             	test   $0x1,%dl
  80294d:	75 09                	jne    802958 <fd_alloc+0x36>
			*fd_store = fd;
  80294f:	89 01                	mov    %eax,(%ecx)
			return 0;
  802951:	b8 00 00 00 00       	mov    $0x0,%eax
  802956:	eb 17                	jmp    80296f <fd_alloc+0x4d>
  802958:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80295d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802962:	75 c9                	jne    80292d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802964:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80296a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80296f:	5d                   	pop    %ebp
  802970:	c3                   	ret    

00802971 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802971:	55                   	push   %ebp
  802972:	89 e5                	mov    %esp,%ebp
  802974:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802977:	83 f8 1f             	cmp    $0x1f,%eax
  80297a:	77 36                	ja     8029b2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80297c:	c1 e0 0c             	shl    $0xc,%eax
  80297f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802984:	89 c2                	mov    %eax,%edx
  802986:	c1 ea 16             	shr    $0x16,%edx
  802989:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802990:	f6 c2 01             	test   $0x1,%dl
  802993:	74 24                	je     8029b9 <fd_lookup+0x48>
  802995:	89 c2                	mov    %eax,%edx
  802997:	c1 ea 0c             	shr    $0xc,%edx
  80299a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8029a1:	f6 c2 01             	test   $0x1,%dl
  8029a4:	74 1a                	je     8029c0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8029a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8029a9:	89 02                	mov    %eax,(%edx)
	return 0;
  8029ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8029b0:	eb 13                	jmp    8029c5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8029b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8029b7:	eb 0c                	jmp    8029c5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8029b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8029be:	eb 05                	jmp    8029c5 <fd_lookup+0x54>
  8029c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8029c5:	5d                   	pop    %ebp
  8029c6:	c3                   	ret    

008029c7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8029c7:	55                   	push   %ebp
  8029c8:	89 e5                	mov    %esp,%ebp
  8029ca:	83 ec 08             	sub    $0x8,%esp
  8029cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8029d0:	ba 30 42 80 00       	mov    $0x804230,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8029d5:	eb 13                	jmp    8029ea <dev_lookup+0x23>
  8029d7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8029da:	39 08                	cmp    %ecx,(%eax)
  8029dc:	75 0c                	jne    8029ea <dev_lookup+0x23>
			*dev = devtab[i];
  8029de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8029e1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8029e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8029e8:	eb 2e                	jmp    802a18 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8029ea:	8b 02                	mov    (%edx),%eax
  8029ec:	85 c0                	test   %eax,%eax
  8029ee:	75 e7                	jne    8029d7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8029f0:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8029f5:	8b 40 48             	mov    0x48(%eax),%eax
  8029f8:	83 ec 04             	sub    $0x4,%esp
  8029fb:	51                   	push   %ecx
  8029fc:	50                   	push   %eax
  8029fd:	68 b0 41 80 00       	push   $0x8041b0
  802a02:	e8 7f f1 ff ff       	call   801b86 <cprintf>
	*dev = 0;
  802a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a0a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802a10:	83 c4 10             	add    $0x10,%esp
  802a13:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802a18:	c9                   	leave  
  802a19:	c3                   	ret    

00802a1a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802a1a:	55                   	push   %ebp
  802a1b:	89 e5                	mov    %esp,%ebp
  802a1d:	56                   	push   %esi
  802a1e:	53                   	push   %ebx
  802a1f:	83 ec 10             	sub    $0x10,%esp
  802a22:	8b 75 08             	mov    0x8(%ebp),%esi
  802a25:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802a28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a2b:	50                   	push   %eax
  802a2c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802a32:	c1 e8 0c             	shr    $0xc,%eax
  802a35:	50                   	push   %eax
  802a36:	e8 36 ff ff ff       	call   802971 <fd_lookup>
  802a3b:	83 c4 08             	add    $0x8,%esp
  802a3e:	85 c0                	test   %eax,%eax
  802a40:	78 05                	js     802a47 <fd_close+0x2d>
	    || fd != fd2)
  802a42:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802a45:	74 0c                	je     802a53 <fd_close+0x39>
		return (must_exist ? r : 0);
  802a47:	84 db                	test   %bl,%bl
  802a49:	ba 00 00 00 00       	mov    $0x0,%edx
  802a4e:	0f 44 c2             	cmove  %edx,%eax
  802a51:	eb 41                	jmp    802a94 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802a53:	83 ec 08             	sub    $0x8,%esp
  802a56:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802a59:	50                   	push   %eax
  802a5a:	ff 36                	pushl  (%esi)
  802a5c:	e8 66 ff ff ff       	call   8029c7 <dev_lookup>
  802a61:	89 c3                	mov    %eax,%ebx
  802a63:	83 c4 10             	add    $0x10,%esp
  802a66:	85 c0                	test   %eax,%eax
  802a68:	78 1a                	js     802a84 <fd_close+0x6a>
		if (dev->dev_close)
  802a6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a6d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  802a70:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802a75:	85 c0                	test   %eax,%eax
  802a77:	74 0b                	je     802a84 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802a79:	83 ec 0c             	sub    $0xc,%esp
  802a7c:	56                   	push   %esi
  802a7d:	ff d0                	call   *%eax
  802a7f:	89 c3                	mov    %eax,%ebx
  802a81:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802a84:	83 ec 08             	sub    $0x8,%esp
  802a87:	56                   	push   %esi
  802a88:	6a 00                	push   $0x0
  802a8a:	e8 83 fb ff ff       	call   802612 <sys_page_unmap>
	return r;
  802a8f:	83 c4 10             	add    $0x10,%esp
  802a92:	89 d8                	mov    %ebx,%eax
}
  802a94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a97:	5b                   	pop    %ebx
  802a98:	5e                   	pop    %esi
  802a99:	5d                   	pop    %ebp
  802a9a:	c3                   	ret    

00802a9b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802a9b:	55                   	push   %ebp
  802a9c:	89 e5                	mov    %esp,%ebp
  802a9e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802aa1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802aa4:	50                   	push   %eax
  802aa5:	ff 75 08             	pushl  0x8(%ebp)
  802aa8:	e8 c4 fe ff ff       	call   802971 <fd_lookup>
  802aad:	83 c4 08             	add    $0x8,%esp
  802ab0:	85 c0                	test   %eax,%eax
  802ab2:	78 10                	js     802ac4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802ab4:	83 ec 08             	sub    $0x8,%esp
  802ab7:	6a 01                	push   $0x1
  802ab9:	ff 75 f4             	pushl  -0xc(%ebp)
  802abc:	e8 59 ff ff ff       	call   802a1a <fd_close>
  802ac1:	83 c4 10             	add    $0x10,%esp
}
  802ac4:	c9                   	leave  
  802ac5:	c3                   	ret    

00802ac6 <close_all>:

void
close_all(void)
{
  802ac6:	55                   	push   %ebp
  802ac7:	89 e5                	mov    %esp,%ebp
  802ac9:	53                   	push   %ebx
  802aca:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802acd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802ad2:	83 ec 0c             	sub    $0xc,%esp
  802ad5:	53                   	push   %ebx
  802ad6:	e8 c0 ff ff ff       	call   802a9b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802adb:	83 c3 01             	add    $0x1,%ebx
  802ade:	83 c4 10             	add    $0x10,%esp
  802ae1:	83 fb 20             	cmp    $0x20,%ebx
  802ae4:	75 ec                	jne    802ad2 <close_all+0xc>
		close(i);
}
  802ae6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ae9:	c9                   	leave  
  802aea:	c3                   	ret    

00802aeb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802aeb:	55                   	push   %ebp
  802aec:	89 e5                	mov    %esp,%ebp
  802aee:	57                   	push   %edi
  802aef:	56                   	push   %esi
  802af0:	53                   	push   %ebx
  802af1:	83 ec 2c             	sub    $0x2c,%esp
  802af4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802af7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802afa:	50                   	push   %eax
  802afb:	ff 75 08             	pushl  0x8(%ebp)
  802afe:	e8 6e fe ff ff       	call   802971 <fd_lookup>
  802b03:	83 c4 08             	add    $0x8,%esp
  802b06:	85 c0                	test   %eax,%eax
  802b08:	0f 88 c1 00 00 00    	js     802bcf <dup+0xe4>
		return r;
	close(newfdnum);
  802b0e:	83 ec 0c             	sub    $0xc,%esp
  802b11:	56                   	push   %esi
  802b12:	e8 84 ff ff ff       	call   802a9b <close>

	newfd = INDEX2FD(newfdnum);
  802b17:	89 f3                	mov    %esi,%ebx
  802b19:	c1 e3 0c             	shl    $0xc,%ebx
  802b1c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802b22:	83 c4 04             	add    $0x4,%esp
  802b25:	ff 75 e4             	pushl  -0x1c(%ebp)
  802b28:	e8 de fd ff ff       	call   80290b <fd2data>
  802b2d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802b2f:	89 1c 24             	mov    %ebx,(%esp)
  802b32:	e8 d4 fd ff ff       	call   80290b <fd2data>
  802b37:	83 c4 10             	add    $0x10,%esp
  802b3a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802b3d:	89 f8                	mov    %edi,%eax
  802b3f:	c1 e8 16             	shr    $0x16,%eax
  802b42:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802b49:	a8 01                	test   $0x1,%al
  802b4b:	74 37                	je     802b84 <dup+0x99>
  802b4d:	89 f8                	mov    %edi,%eax
  802b4f:	c1 e8 0c             	shr    $0xc,%eax
  802b52:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802b59:	f6 c2 01             	test   $0x1,%dl
  802b5c:	74 26                	je     802b84 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802b5e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802b65:	83 ec 0c             	sub    $0xc,%esp
  802b68:	25 07 0e 00 00       	and    $0xe07,%eax
  802b6d:	50                   	push   %eax
  802b6e:	ff 75 d4             	pushl  -0x2c(%ebp)
  802b71:	6a 00                	push   $0x0
  802b73:	57                   	push   %edi
  802b74:	6a 00                	push   $0x0
  802b76:	e8 55 fa ff ff       	call   8025d0 <sys_page_map>
  802b7b:	89 c7                	mov    %eax,%edi
  802b7d:	83 c4 20             	add    $0x20,%esp
  802b80:	85 c0                	test   %eax,%eax
  802b82:	78 2e                	js     802bb2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802b84:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802b87:	89 d0                	mov    %edx,%eax
  802b89:	c1 e8 0c             	shr    $0xc,%eax
  802b8c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802b93:	83 ec 0c             	sub    $0xc,%esp
  802b96:	25 07 0e 00 00       	and    $0xe07,%eax
  802b9b:	50                   	push   %eax
  802b9c:	53                   	push   %ebx
  802b9d:	6a 00                	push   $0x0
  802b9f:	52                   	push   %edx
  802ba0:	6a 00                	push   $0x0
  802ba2:	e8 29 fa ff ff       	call   8025d0 <sys_page_map>
  802ba7:	89 c7                	mov    %eax,%edi
  802ba9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802bac:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802bae:	85 ff                	test   %edi,%edi
  802bb0:	79 1d                	jns    802bcf <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802bb2:	83 ec 08             	sub    $0x8,%esp
  802bb5:	53                   	push   %ebx
  802bb6:	6a 00                	push   $0x0
  802bb8:	e8 55 fa ff ff       	call   802612 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802bbd:	83 c4 08             	add    $0x8,%esp
  802bc0:	ff 75 d4             	pushl  -0x2c(%ebp)
  802bc3:	6a 00                	push   $0x0
  802bc5:	e8 48 fa ff ff       	call   802612 <sys_page_unmap>
	return r;
  802bca:	83 c4 10             	add    $0x10,%esp
  802bcd:	89 f8                	mov    %edi,%eax
}
  802bcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802bd2:	5b                   	pop    %ebx
  802bd3:	5e                   	pop    %esi
  802bd4:	5f                   	pop    %edi
  802bd5:	5d                   	pop    %ebp
  802bd6:	c3                   	ret    

00802bd7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802bd7:	55                   	push   %ebp
  802bd8:	89 e5                	mov    %esp,%ebp
  802bda:	53                   	push   %ebx
  802bdb:	83 ec 14             	sub    $0x14,%esp
  802bde:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802be1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802be4:	50                   	push   %eax
  802be5:	53                   	push   %ebx
  802be6:	e8 86 fd ff ff       	call   802971 <fd_lookup>
  802beb:	83 c4 08             	add    $0x8,%esp
  802bee:	89 c2                	mov    %eax,%edx
  802bf0:	85 c0                	test   %eax,%eax
  802bf2:	78 6d                	js     802c61 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802bf4:	83 ec 08             	sub    $0x8,%esp
  802bf7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802bfa:	50                   	push   %eax
  802bfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bfe:	ff 30                	pushl  (%eax)
  802c00:	e8 c2 fd ff ff       	call   8029c7 <dev_lookup>
  802c05:	83 c4 10             	add    $0x10,%esp
  802c08:	85 c0                	test   %eax,%eax
  802c0a:	78 4c                	js     802c58 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802c0c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802c0f:	8b 42 08             	mov    0x8(%edx),%eax
  802c12:	83 e0 03             	and    $0x3,%eax
  802c15:	83 f8 01             	cmp    $0x1,%eax
  802c18:	75 21                	jne    802c3b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802c1a:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802c1f:	8b 40 48             	mov    0x48(%eax),%eax
  802c22:	83 ec 04             	sub    $0x4,%esp
  802c25:	53                   	push   %ebx
  802c26:	50                   	push   %eax
  802c27:	68 f4 41 80 00       	push   $0x8041f4
  802c2c:	e8 55 ef ff ff       	call   801b86 <cprintf>
		return -E_INVAL;
  802c31:	83 c4 10             	add    $0x10,%esp
  802c34:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802c39:	eb 26                	jmp    802c61 <read+0x8a>
	}
	if (!dev->dev_read)
  802c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c3e:	8b 40 08             	mov    0x8(%eax),%eax
  802c41:	85 c0                	test   %eax,%eax
  802c43:	74 17                	je     802c5c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802c45:	83 ec 04             	sub    $0x4,%esp
  802c48:	ff 75 10             	pushl  0x10(%ebp)
  802c4b:	ff 75 0c             	pushl  0xc(%ebp)
  802c4e:	52                   	push   %edx
  802c4f:	ff d0                	call   *%eax
  802c51:	89 c2                	mov    %eax,%edx
  802c53:	83 c4 10             	add    $0x10,%esp
  802c56:	eb 09                	jmp    802c61 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c58:	89 c2                	mov    %eax,%edx
  802c5a:	eb 05                	jmp    802c61 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802c5c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802c61:	89 d0                	mov    %edx,%eax
  802c63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c66:	c9                   	leave  
  802c67:	c3                   	ret    

00802c68 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802c68:	55                   	push   %ebp
  802c69:	89 e5                	mov    %esp,%ebp
  802c6b:	57                   	push   %edi
  802c6c:	56                   	push   %esi
  802c6d:	53                   	push   %ebx
  802c6e:	83 ec 0c             	sub    $0xc,%esp
  802c71:	8b 7d 08             	mov    0x8(%ebp),%edi
  802c74:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802c77:	bb 00 00 00 00       	mov    $0x0,%ebx
  802c7c:	eb 21                	jmp    802c9f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802c7e:	83 ec 04             	sub    $0x4,%esp
  802c81:	89 f0                	mov    %esi,%eax
  802c83:	29 d8                	sub    %ebx,%eax
  802c85:	50                   	push   %eax
  802c86:	89 d8                	mov    %ebx,%eax
  802c88:	03 45 0c             	add    0xc(%ebp),%eax
  802c8b:	50                   	push   %eax
  802c8c:	57                   	push   %edi
  802c8d:	e8 45 ff ff ff       	call   802bd7 <read>
		if (m < 0)
  802c92:	83 c4 10             	add    $0x10,%esp
  802c95:	85 c0                	test   %eax,%eax
  802c97:	78 10                	js     802ca9 <readn+0x41>
			return m;
		if (m == 0)
  802c99:	85 c0                	test   %eax,%eax
  802c9b:	74 0a                	je     802ca7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802c9d:	01 c3                	add    %eax,%ebx
  802c9f:	39 f3                	cmp    %esi,%ebx
  802ca1:	72 db                	jb     802c7e <readn+0x16>
  802ca3:	89 d8                	mov    %ebx,%eax
  802ca5:	eb 02                	jmp    802ca9 <readn+0x41>
  802ca7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802ca9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802cac:	5b                   	pop    %ebx
  802cad:	5e                   	pop    %esi
  802cae:	5f                   	pop    %edi
  802caf:	5d                   	pop    %ebp
  802cb0:	c3                   	ret    

00802cb1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802cb1:	55                   	push   %ebp
  802cb2:	89 e5                	mov    %esp,%ebp
  802cb4:	53                   	push   %ebx
  802cb5:	83 ec 14             	sub    $0x14,%esp
  802cb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802cbb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802cbe:	50                   	push   %eax
  802cbf:	53                   	push   %ebx
  802cc0:	e8 ac fc ff ff       	call   802971 <fd_lookup>
  802cc5:	83 c4 08             	add    $0x8,%esp
  802cc8:	89 c2                	mov    %eax,%edx
  802cca:	85 c0                	test   %eax,%eax
  802ccc:	78 68                	js     802d36 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802cce:	83 ec 08             	sub    $0x8,%esp
  802cd1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802cd4:	50                   	push   %eax
  802cd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cd8:	ff 30                	pushl  (%eax)
  802cda:	e8 e8 fc ff ff       	call   8029c7 <dev_lookup>
  802cdf:	83 c4 10             	add    $0x10,%esp
  802ce2:	85 c0                	test   %eax,%eax
  802ce4:	78 47                	js     802d2d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802ce6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ce9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802ced:	75 21                	jne    802d10 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802cef:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802cf4:	8b 40 48             	mov    0x48(%eax),%eax
  802cf7:	83 ec 04             	sub    $0x4,%esp
  802cfa:	53                   	push   %ebx
  802cfb:	50                   	push   %eax
  802cfc:	68 10 42 80 00       	push   $0x804210
  802d01:	e8 80 ee ff ff       	call   801b86 <cprintf>
		return -E_INVAL;
  802d06:	83 c4 10             	add    $0x10,%esp
  802d09:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802d0e:	eb 26                	jmp    802d36 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802d10:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802d13:	8b 52 0c             	mov    0xc(%edx),%edx
  802d16:	85 d2                	test   %edx,%edx
  802d18:	74 17                	je     802d31 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802d1a:	83 ec 04             	sub    $0x4,%esp
  802d1d:	ff 75 10             	pushl  0x10(%ebp)
  802d20:	ff 75 0c             	pushl  0xc(%ebp)
  802d23:	50                   	push   %eax
  802d24:	ff d2                	call   *%edx
  802d26:	89 c2                	mov    %eax,%edx
  802d28:	83 c4 10             	add    $0x10,%esp
  802d2b:	eb 09                	jmp    802d36 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d2d:	89 c2                	mov    %eax,%edx
  802d2f:	eb 05                	jmp    802d36 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802d31:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802d36:	89 d0                	mov    %edx,%eax
  802d38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d3b:	c9                   	leave  
  802d3c:	c3                   	ret    

00802d3d <seek>:

int
seek(int fdnum, off_t offset)
{
  802d3d:	55                   	push   %ebp
  802d3e:	89 e5                	mov    %esp,%ebp
  802d40:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802d43:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802d46:	50                   	push   %eax
  802d47:	ff 75 08             	pushl  0x8(%ebp)
  802d4a:	e8 22 fc ff ff       	call   802971 <fd_lookup>
  802d4f:	83 c4 08             	add    $0x8,%esp
  802d52:	85 c0                	test   %eax,%eax
  802d54:	78 0e                	js     802d64 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802d56:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802d59:	8b 55 0c             	mov    0xc(%ebp),%edx
  802d5c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802d5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802d64:	c9                   	leave  
  802d65:	c3                   	ret    

00802d66 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802d66:	55                   	push   %ebp
  802d67:	89 e5                	mov    %esp,%ebp
  802d69:	53                   	push   %ebx
  802d6a:	83 ec 14             	sub    $0x14,%esp
  802d6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d70:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d73:	50                   	push   %eax
  802d74:	53                   	push   %ebx
  802d75:	e8 f7 fb ff ff       	call   802971 <fd_lookup>
  802d7a:	83 c4 08             	add    $0x8,%esp
  802d7d:	89 c2                	mov    %eax,%edx
  802d7f:	85 c0                	test   %eax,%eax
  802d81:	78 65                	js     802de8 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d83:	83 ec 08             	sub    $0x8,%esp
  802d86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d89:	50                   	push   %eax
  802d8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d8d:	ff 30                	pushl  (%eax)
  802d8f:	e8 33 fc ff ff       	call   8029c7 <dev_lookup>
  802d94:	83 c4 10             	add    $0x10,%esp
  802d97:	85 c0                	test   %eax,%eax
  802d99:	78 44                	js     802ddf <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802d9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d9e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802da2:	75 21                	jne    802dc5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802da4:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802da9:	8b 40 48             	mov    0x48(%eax),%eax
  802dac:	83 ec 04             	sub    $0x4,%esp
  802daf:	53                   	push   %ebx
  802db0:	50                   	push   %eax
  802db1:	68 d0 41 80 00       	push   $0x8041d0
  802db6:	e8 cb ed ff ff       	call   801b86 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802dbb:	83 c4 10             	add    $0x10,%esp
  802dbe:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802dc3:	eb 23                	jmp    802de8 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802dc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802dc8:	8b 52 18             	mov    0x18(%edx),%edx
  802dcb:	85 d2                	test   %edx,%edx
  802dcd:	74 14                	je     802de3 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802dcf:	83 ec 08             	sub    $0x8,%esp
  802dd2:	ff 75 0c             	pushl  0xc(%ebp)
  802dd5:	50                   	push   %eax
  802dd6:	ff d2                	call   *%edx
  802dd8:	89 c2                	mov    %eax,%edx
  802dda:	83 c4 10             	add    $0x10,%esp
  802ddd:	eb 09                	jmp    802de8 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802ddf:	89 c2                	mov    %eax,%edx
  802de1:	eb 05                	jmp    802de8 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802de3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802de8:	89 d0                	mov    %edx,%eax
  802dea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ded:	c9                   	leave  
  802dee:	c3                   	ret    

00802def <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802def:	55                   	push   %ebp
  802df0:	89 e5                	mov    %esp,%ebp
  802df2:	53                   	push   %ebx
  802df3:	83 ec 14             	sub    $0x14,%esp
  802df6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802df9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802dfc:	50                   	push   %eax
  802dfd:	ff 75 08             	pushl  0x8(%ebp)
  802e00:	e8 6c fb ff ff       	call   802971 <fd_lookup>
  802e05:	83 c4 08             	add    $0x8,%esp
  802e08:	89 c2                	mov    %eax,%edx
  802e0a:	85 c0                	test   %eax,%eax
  802e0c:	78 58                	js     802e66 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e0e:	83 ec 08             	sub    $0x8,%esp
  802e11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e14:	50                   	push   %eax
  802e15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e18:	ff 30                	pushl  (%eax)
  802e1a:	e8 a8 fb ff ff       	call   8029c7 <dev_lookup>
  802e1f:	83 c4 10             	add    $0x10,%esp
  802e22:	85 c0                	test   %eax,%eax
  802e24:	78 37                	js     802e5d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e29:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802e2d:	74 32                	je     802e61 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802e2f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802e32:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802e39:	00 00 00 
	stat->st_isdir = 0;
  802e3c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802e43:	00 00 00 
	stat->st_dev = dev;
  802e46:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802e4c:	83 ec 08             	sub    $0x8,%esp
  802e4f:	53                   	push   %ebx
  802e50:	ff 75 f0             	pushl  -0x10(%ebp)
  802e53:	ff 50 14             	call   *0x14(%eax)
  802e56:	89 c2                	mov    %eax,%edx
  802e58:	83 c4 10             	add    $0x10,%esp
  802e5b:	eb 09                	jmp    802e66 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e5d:	89 c2                	mov    %eax,%edx
  802e5f:	eb 05                	jmp    802e66 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802e61:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802e66:	89 d0                	mov    %edx,%eax
  802e68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e6b:	c9                   	leave  
  802e6c:	c3                   	ret    

00802e6d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802e6d:	55                   	push   %ebp
  802e6e:	89 e5                	mov    %esp,%ebp
  802e70:	56                   	push   %esi
  802e71:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802e72:	83 ec 08             	sub    $0x8,%esp
  802e75:	6a 00                	push   $0x0
  802e77:	ff 75 08             	pushl  0x8(%ebp)
  802e7a:	e8 e3 01 00 00       	call   803062 <open>
  802e7f:	89 c3                	mov    %eax,%ebx
  802e81:	83 c4 10             	add    $0x10,%esp
  802e84:	85 c0                	test   %eax,%eax
  802e86:	78 1b                	js     802ea3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802e88:	83 ec 08             	sub    $0x8,%esp
  802e8b:	ff 75 0c             	pushl  0xc(%ebp)
  802e8e:	50                   	push   %eax
  802e8f:	e8 5b ff ff ff       	call   802def <fstat>
  802e94:	89 c6                	mov    %eax,%esi
	close(fd);
  802e96:	89 1c 24             	mov    %ebx,(%esp)
  802e99:	e8 fd fb ff ff       	call   802a9b <close>
	return r;
  802e9e:	83 c4 10             	add    $0x10,%esp
  802ea1:	89 f0                	mov    %esi,%eax
}
  802ea3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ea6:	5b                   	pop    %ebx
  802ea7:	5e                   	pop    %esi
  802ea8:	5d                   	pop    %ebp
  802ea9:	c3                   	ret    

00802eaa <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802eaa:	55                   	push   %ebp
  802eab:	89 e5                	mov    %esp,%ebp
  802ead:	56                   	push   %esi
  802eae:	53                   	push   %ebx
  802eaf:	89 c6                	mov    %eax,%esi
  802eb1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802eb3:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802eba:	75 12                	jne    802ece <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802ebc:	83 ec 0c             	sub    $0xc,%esp
  802ebf:	6a 01                	push   $0x1
  802ec1:	e8 fc f9 ff ff       	call   8028c2 <ipc_find_env>
  802ec6:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802ecb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802ece:	6a 07                	push   $0x7
  802ed0:	68 00 b0 80 00       	push   $0x80b000
  802ed5:	56                   	push   %esi
  802ed6:	ff 35 00 a0 80 00    	pushl  0x80a000
  802edc:	e8 8d f9 ff ff       	call   80286e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802ee1:	83 c4 0c             	add    $0xc,%esp
  802ee4:	6a 00                	push   $0x0
  802ee6:	53                   	push   %ebx
  802ee7:	6a 00                	push   $0x0
  802ee9:	e8 17 f9 ff ff       	call   802805 <ipc_recv>
}
  802eee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ef1:	5b                   	pop    %ebx
  802ef2:	5e                   	pop    %esi
  802ef3:	5d                   	pop    %ebp
  802ef4:	c3                   	ret    

00802ef5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802ef5:	55                   	push   %ebp
  802ef6:	89 e5                	mov    %esp,%ebp
  802ef8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802efb:	8b 45 08             	mov    0x8(%ebp),%eax
  802efe:	8b 40 0c             	mov    0xc(%eax),%eax
  802f01:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802f06:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f09:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802f0e:	ba 00 00 00 00       	mov    $0x0,%edx
  802f13:	b8 02 00 00 00       	mov    $0x2,%eax
  802f18:	e8 8d ff ff ff       	call   802eaa <fsipc>
}
  802f1d:	c9                   	leave  
  802f1e:	c3                   	ret    

00802f1f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802f1f:	55                   	push   %ebp
  802f20:	89 e5                	mov    %esp,%ebp
  802f22:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802f25:	8b 45 08             	mov    0x8(%ebp),%eax
  802f28:	8b 40 0c             	mov    0xc(%eax),%eax
  802f2b:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802f30:	ba 00 00 00 00       	mov    $0x0,%edx
  802f35:	b8 06 00 00 00       	mov    $0x6,%eax
  802f3a:	e8 6b ff ff ff       	call   802eaa <fsipc>
}
  802f3f:	c9                   	leave  
  802f40:	c3                   	ret    

00802f41 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802f41:	55                   	push   %ebp
  802f42:	89 e5                	mov    %esp,%ebp
  802f44:	53                   	push   %ebx
  802f45:	83 ec 04             	sub    $0x4,%esp
  802f48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  802f4e:	8b 40 0c             	mov    0xc(%eax),%eax
  802f51:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802f56:	ba 00 00 00 00       	mov    $0x0,%edx
  802f5b:	b8 05 00 00 00       	mov    $0x5,%eax
  802f60:	e8 45 ff ff ff       	call   802eaa <fsipc>
  802f65:	85 c0                	test   %eax,%eax
  802f67:	78 2c                	js     802f95 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802f69:	83 ec 08             	sub    $0x8,%esp
  802f6c:	68 00 b0 80 00       	push   $0x80b000
  802f71:	53                   	push   %ebx
  802f72:	e8 13 f2 ff ff       	call   80218a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802f77:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802f7c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802f82:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802f87:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802f8d:	83 c4 10             	add    $0x10,%esp
  802f90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802f95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f98:	c9                   	leave  
  802f99:	c3                   	ret    

00802f9a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802f9a:	55                   	push   %ebp
  802f9b:	89 e5                	mov    %esp,%ebp
  802f9d:	83 ec 0c             	sub    $0xc,%esp
  802fa0:	8b 45 10             	mov    0x10(%ebp),%eax
  802fa3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802fa8:	ba f8 0f 00 00       	mov    $0xff8,%edx
  802fad:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802fb0:	8b 55 08             	mov    0x8(%ebp),%edx
  802fb3:	8b 52 0c             	mov    0xc(%edx),%edx
  802fb6:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = n;
  802fbc:	a3 04 b0 80 00       	mov    %eax,0x80b004
	memmove(fsipcbuf.write.req_buf, buf, n);
  802fc1:	50                   	push   %eax
  802fc2:	ff 75 0c             	pushl  0xc(%ebp)
  802fc5:	68 08 b0 80 00       	push   $0x80b008
  802fca:	e8 4d f3 ff ff       	call   80231c <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  802fcf:	ba 00 00 00 00       	mov    $0x0,%edx
  802fd4:	b8 04 00 00 00       	mov    $0x4,%eax
  802fd9:	e8 cc fe ff ff       	call   802eaa <fsipc>
	//panic("devfile_write not implemented");
}
  802fde:	c9                   	leave  
  802fdf:	c3                   	ret    

00802fe0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802fe0:	55                   	push   %ebp
  802fe1:	89 e5                	mov    %esp,%ebp
  802fe3:	56                   	push   %esi
  802fe4:	53                   	push   %ebx
  802fe5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802fe8:	8b 45 08             	mov    0x8(%ebp),%eax
  802feb:	8b 40 0c             	mov    0xc(%eax),%eax
  802fee:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  802ff3:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802ff9:	ba 00 00 00 00       	mov    $0x0,%edx
  802ffe:	b8 03 00 00 00       	mov    $0x3,%eax
  803003:	e8 a2 fe ff ff       	call   802eaa <fsipc>
  803008:	89 c3                	mov    %eax,%ebx
  80300a:	85 c0                	test   %eax,%eax
  80300c:	78 4b                	js     803059 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80300e:	39 c6                	cmp    %eax,%esi
  803010:	73 16                	jae    803028 <devfile_read+0x48>
  803012:	68 40 42 80 00       	push   $0x804240
  803017:	68 fd 38 80 00       	push   $0x8038fd
  80301c:	6a 7c                	push   $0x7c
  80301e:	68 47 42 80 00       	push   $0x804247
  803023:	e8 85 ea ff ff       	call   801aad <_panic>
	assert(r <= PGSIZE);
  803028:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80302d:	7e 16                	jle    803045 <devfile_read+0x65>
  80302f:	68 52 42 80 00       	push   $0x804252
  803034:	68 fd 38 80 00       	push   $0x8038fd
  803039:	6a 7d                	push   $0x7d
  80303b:	68 47 42 80 00       	push   $0x804247
  803040:	e8 68 ea ff ff       	call   801aad <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  803045:	83 ec 04             	sub    $0x4,%esp
  803048:	50                   	push   %eax
  803049:	68 00 b0 80 00       	push   $0x80b000
  80304e:	ff 75 0c             	pushl  0xc(%ebp)
  803051:	e8 c6 f2 ff ff       	call   80231c <memmove>
	return r;
  803056:	83 c4 10             	add    $0x10,%esp
}
  803059:	89 d8                	mov    %ebx,%eax
  80305b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80305e:	5b                   	pop    %ebx
  80305f:	5e                   	pop    %esi
  803060:	5d                   	pop    %ebp
  803061:	c3                   	ret    

00803062 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  803062:	55                   	push   %ebp
  803063:	89 e5                	mov    %esp,%ebp
  803065:	53                   	push   %ebx
  803066:	83 ec 20             	sub    $0x20,%esp
  803069:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80306c:	53                   	push   %ebx
  80306d:	e8 df f0 ff ff       	call   802151 <strlen>
  803072:	83 c4 10             	add    $0x10,%esp
  803075:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80307a:	7f 67                	jg     8030e3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80307c:	83 ec 0c             	sub    $0xc,%esp
  80307f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803082:	50                   	push   %eax
  803083:	e8 9a f8 ff ff       	call   802922 <fd_alloc>
  803088:	83 c4 10             	add    $0x10,%esp
		return r;
  80308b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80308d:	85 c0                	test   %eax,%eax
  80308f:	78 57                	js     8030e8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  803091:	83 ec 08             	sub    $0x8,%esp
  803094:	53                   	push   %ebx
  803095:	68 00 b0 80 00       	push   $0x80b000
  80309a:	e8 eb f0 ff ff       	call   80218a <strcpy>
	fsipcbuf.open.req_omode = mode;
  80309f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8030a2:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8030a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8030aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8030af:	e8 f6 fd ff ff       	call   802eaa <fsipc>
  8030b4:	89 c3                	mov    %eax,%ebx
  8030b6:	83 c4 10             	add    $0x10,%esp
  8030b9:	85 c0                	test   %eax,%eax
  8030bb:	79 14                	jns    8030d1 <open+0x6f>
		fd_close(fd, 0);
  8030bd:	83 ec 08             	sub    $0x8,%esp
  8030c0:	6a 00                	push   $0x0
  8030c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8030c5:	e8 50 f9 ff ff       	call   802a1a <fd_close>
		return r;
  8030ca:	83 c4 10             	add    $0x10,%esp
  8030cd:	89 da                	mov    %ebx,%edx
  8030cf:	eb 17                	jmp    8030e8 <open+0x86>
	}

	return fd2num(fd);
  8030d1:	83 ec 0c             	sub    $0xc,%esp
  8030d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8030d7:	e8 1f f8 ff ff       	call   8028fb <fd2num>
  8030dc:	89 c2                	mov    %eax,%edx
  8030de:	83 c4 10             	add    $0x10,%esp
  8030e1:	eb 05                	jmp    8030e8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8030e3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8030e8:	89 d0                	mov    %edx,%eax
  8030ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8030ed:	c9                   	leave  
  8030ee:	c3                   	ret    

008030ef <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8030ef:	55                   	push   %ebp
  8030f0:	89 e5                	mov    %esp,%ebp
  8030f2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8030f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8030fa:	b8 08 00 00 00       	mov    $0x8,%eax
  8030ff:	e8 a6 fd ff ff       	call   802eaa <fsipc>
}
  803104:	c9                   	leave  
  803105:	c3                   	ret    

00803106 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803106:	55                   	push   %ebp
  803107:	89 e5                	mov    %esp,%ebp
  803109:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80310c:	89 d0                	mov    %edx,%eax
  80310e:	c1 e8 16             	shr    $0x16,%eax
  803111:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  803118:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80311d:	f6 c1 01             	test   $0x1,%cl
  803120:	74 1d                	je     80313f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803122:	c1 ea 0c             	shr    $0xc,%edx
  803125:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80312c:	f6 c2 01             	test   $0x1,%dl
  80312f:	74 0e                	je     80313f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803131:	c1 ea 0c             	shr    $0xc,%edx
  803134:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80313b:	ef 
  80313c:	0f b7 c0             	movzwl %ax,%eax
}
  80313f:	5d                   	pop    %ebp
  803140:	c3                   	ret    

00803141 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  803141:	55                   	push   %ebp
  803142:	89 e5                	mov    %esp,%ebp
  803144:	56                   	push   %esi
  803145:	53                   	push   %ebx
  803146:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  803149:	83 ec 0c             	sub    $0xc,%esp
  80314c:	ff 75 08             	pushl  0x8(%ebp)
  80314f:	e8 b7 f7 ff ff       	call   80290b <fd2data>
  803154:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  803156:	83 c4 08             	add    $0x8,%esp
  803159:	68 5e 42 80 00       	push   $0x80425e
  80315e:	53                   	push   %ebx
  80315f:	e8 26 f0 ff ff       	call   80218a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803164:	8b 46 04             	mov    0x4(%esi),%eax
  803167:	2b 06                	sub    (%esi),%eax
  803169:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80316f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803176:	00 00 00 
	stat->st_dev = &devpipe;
  803179:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  803180:	90 80 00 
	return 0;
}
  803183:	b8 00 00 00 00       	mov    $0x0,%eax
  803188:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80318b:	5b                   	pop    %ebx
  80318c:	5e                   	pop    %esi
  80318d:	5d                   	pop    %ebp
  80318e:	c3                   	ret    

0080318f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80318f:	55                   	push   %ebp
  803190:	89 e5                	mov    %esp,%ebp
  803192:	53                   	push   %ebx
  803193:	83 ec 0c             	sub    $0xc,%esp
  803196:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803199:	53                   	push   %ebx
  80319a:	6a 00                	push   $0x0
  80319c:	e8 71 f4 ff ff       	call   802612 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8031a1:	89 1c 24             	mov    %ebx,(%esp)
  8031a4:	e8 62 f7 ff ff       	call   80290b <fd2data>
  8031a9:	83 c4 08             	add    $0x8,%esp
  8031ac:	50                   	push   %eax
  8031ad:	6a 00                	push   $0x0
  8031af:	e8 5e f4 ff ff       	call   802612 <sys_page_unmap>
}
  8031b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8031b7:	c9                   	leave  
  8031b8:	c3                   	ret    

008031b9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8031b9:	55                   	push   %ebp
  8031ba:	89 e5                	mov    %esp,%ebp
  8031bc:	57                   	push   %edi
  8031bd:	56                   	push   %esi
  8031be:	53                   	push   %ebx
  8031bf:	83 ec 1c             	sub    $0x1c,%esp
  8031c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8031c5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8031c7:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8031cc:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8031cf:	83 ec 0c             	sub    $0xc,%esp
  8031d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8031d5:	e8 2c ff ff ff       	call   803106 <pageref>
  8031da:	89 c3                	mov    %eax,%ebx
  8031dc:	89 3c 24             	mov    %edi,(%esp)
  8031df:	e8 22 ff ff ff       	call   803106 <pageref>
  8031e4:	83 c4 10             	add    $0x10,%esp
  8031e7:	39 c3                	cmp    %eax,%ebx
  8031e9:	0f 94 c1             	sete   %cl
  8031ec:	0f b6 c9             	movzbl %cl,%ecx
  8031ef:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8031f2:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8031f8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8031fb:	39 ce                	cmp    %ecx,%esi
  8031fd:	74 1b                	je     80321a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8031ff:	39 c3                	cmp    %eax,%ebx
  803201:	75 c4                	jne    8031c7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803203:	8b 42 58             	mov    0x58(%edx),%eax
  803206:	ff 75 e4             	pushl  -0x1c(%ebp)
  803209:	50                   	push   %eax
  80320a:	56                   	push   %esi
  80320b:	68 65 42 80 00       	push   $0x804265
  803210:	e8 71 e9 ff ff       	call   801b86 <cprintf>
  803215:	83 c4 10             	add    $0x10,%esp
  803218:	eb ad                	jmp    8031c7 <_pipeisclosed+0xe>
	}
}
  80321a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80321d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803220:	5b                   	pop    %ebx
  803221:	5e                   	pop    %esi
  803222:	5f                   	pop    %edi
  803223:	5d                   	pop    %ebp
  803224:	c3                   	ret    

00803225 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803225:	55                   	push   %ebp
  803226:	89 e5                	mov    %esp,%ebp
  803228:	57                   	push   %edi
  803229:	56                   	push   %esi
  80322a:	53                   	push   %ebx
  80322b:	83 ec 28             	sub    $0x28,%esp
  80322e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  803231:	56                   	push   %esi
  803232:	e8 d4 f6 ff ff       	call   80290b <fd2data>
  803237:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803239:	83 c4 10             	add    $0x10,%esp
  80323c:	bf 00 00 00 00       	mov    $0x0,%edi
  803241:	eb 4b                	jmp    80328e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  803243:	89 da                	mov    %ebx,%edx
  803245:	89 f0                	mov    %esi,%eax
  803247:	e8 6d ff ff ff       	call   8031b9 <_pipeisclosed>
  80324c:	85 c0                	test   %eax,%eax
  80324e:	75 48                	jne    803298 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  803250:	e8 19 f3 ff ff       	call   80256e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803255:	8b 43 04             	mov    0x4(%ebx),%eax
  803258:	8b 0b                	mov    (%ebx),%ecx
  80325a:	8d 51 20             	lea    0x20(%ecx),%edx
  80325d:	39 d0                	cmp    %edx,%eax
  80325f:	73 e2                	jae    803243 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803261:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803264:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803268:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80326b:	89 c2                	mov    %eax,%edx
  80326d:	c1 fa 1f             	sar    $0x1f,%edx
  803270:	89 d1                	mov    %edx,%ecx
  803272:	c1 e9 1b             	shr    $0x1b,%ecx
  803275:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803278:	83 e2 1f             	and    $0x1f,%edx
  80327b:	29 ca                	sub    %ecx,%edx
  80327d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  803281:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803285:	83 c0 01             	add    $0x1,%eax
  803288:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80328b:	83 c7 01             	add    $0x1,%edi
  80328e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803291:	75 c2                	jne    803255 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803293:	8b 45 10             	mov    0x10(%ebp),%eax
  803296:	eb 05                	jmp    80329d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803298:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80329d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8032a0:	5b                   	pop    %ebx
  8032a1:	5e                   	pop    %esi
  8032a2:	5f                   	pop    %edi
  8032a3:	5d                   	pop    %ebp
  8032a4:	c3                   	ret    

008032a5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8032a5:	55                   	push   %ebp
  8032a6:	89 e5                	mov    %esp,%ebp
  8032a8:	57                   	push   %edi
  8032a9:	56                   	push   %esi
  8032aa:	53                   	push   %ebx
  8032ab:	83 ec 18             	sub    $0x18,%esp
  8032ae:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8032b1:	57                   	push   %edi
  8032b2:	e8 54 f6 ff ff       	call   80290b <fd2data>
  8032b7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8032b9:	83 c4 10             	add    $0x10,%esp
  8032bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8032c1:	eb 3d                	jmp    803300 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8032c3:	85 db                	test   %ebx,%ebx
  8032c5:	74 04                	je     8032cb <devpipe_read+0x26>
				return i;
  8032c7:	89 d8                	mov    %ebx,%eax
  8032c9:	eb 44                	jmp    80330f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8032cb:	89 f2                	mov    %esi,%edx
  8032cd:	89 f8                	mov    %edi,%eax
  8032cf:	e8 e5 fe ff ff       	call   8031b9 <_pipeisclosed>
  8032d4:	85 c0                	test   %eax,%eax
  8032d6:	75 32                	jne    80330a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8032d8:	e8 91 f2 ff ff       	call   80256e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8032dd:	8b 06                	mov    (%esi),%eax
  8032df:	3b 46 04             	cmp    0x4(%esi),%eax
  8032e2:	74 df                	je     8032c3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8032e4:	99                   	cltd   
  8032e5:	c1 ea 1b             	shr    $0x1b,%edx
  8032e8:	01 d0                	add    %edx,%eax
  8032ea:	83 e0 1f             	and    $0x1f,%eax
  8032ed:	29 d0                	sub    %edx,%eax
  8032ef:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8032f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8032f7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8032fa:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8032fd:	83 c3 01             	add    $0x1,%ebx
  803300:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803303:	75 d8                	jne    8032dd <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803305:	8b 45 10             	mov    0x10(%ebp),%eax
  803308:	eb 05                	jmp    80330f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80330a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80330f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803312:	5b                   	pop    %ebx
  803313:	5e                   	pop    %esi
  803314:	5f                   	pop    %edi
  803315:	5d                   	pop    %ebp
  803316:	c3                   	ret    

00803317 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803317:	55                   	push   %ebp
  803318:	89 e5                	mov    %esp,%ebp
  80331a:	56                   	push   %esi
  80331b:	53                   	push   %ebx
  80331c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80331f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803322:	50                   	push   %eax
  803323:	e8 fa f5 ff ff       	call   802922 <fd_alloc>
  803328:	83 c4 10             	add    $0x10,%esp
  80332b:	89 c2                	mov    %eax,%edx
  80332d:	85 c0                	test   %eax,%eax
  80332f:	0f 88 2c 01 00 00    	js     803461 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803335:	83 ec 04             	sub    $0x4,%esp
  803338:	68 07 04 00 00       	push   $0x407
  80333d:	ff 75 f4             	pushl  -0xc(%ebp)
  803340:	6a 00                	push   $0x0
  803342:	e8 46 f2 ff ff       	call   80258d <sys_page_alloc>
  803347:	83 c4 10             	add    $0x10,%esp
  80334a:	89 c2                	mov    %eax,%edx
  80334c:	85 c0                	test   %eax,%eax
  80334e:	0f 88 0d 01 00 00    	js     803461 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  803354:	83 ec 0c             	sub    $0xc,%esp
  803357:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80335a:	50                   	push   %eax
  80335b:	e8 c2 f5 ff ff       	call   802922 <fd_alloc>
  803360:	89 c3                	mov    %eax,%ebx
  803362:	83 c4 10             	add    $0x10,%esp
  803365:	85 c0                	test   %eax,%eax
  803367:	0f 88 e2 00 00 00    	js     80344f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80336d:	83 ec 04             	sub    $0x4,%esp
  803370:	68 07 04 00 00       	push   $0x407
  803375:	ff 75 f0             	pushl  -0x10(%ebp)
  803378:	6a 00                	push   $0x0
  80337a:	e8 0e f2 ff ff       	call   80258d <sys_page_alloc>
  80337f:	89 c3                	mov    %eax,%ebx
  803381:	83 c4 10             	add    $0x10,%esp
  803384:	85 c0                	test   %eax,%eax
  803386:	0f 88 c3 00 00 00    	js     80344f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80338c:	83 ec 0c             	sub    $0xc,%esp
  80338f:	ff 75 f4             	pushl  -0xc(%ebp)
  803392:	e8 74 f5 ff ff       	call   80290b <fd2data>
  803397:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803399:	83 c4 0c             	add    $0xc,%esp
  80339c:	68 07 04 00 00       	push   $0x407
  8033a1:	50                   	push   %eax
  8033a2:	6a 00                	push   $0x0
  8033a4:	e8 e4 f1 ff ff       	call   80258d <sys_page_alloc>
  8033a9:	89 c3                	mov    %eax,%ebx
  8033ab:	83 c4 10             	add    $0x10,%esp
  8033ae:	85 c0                	test   %eax,%eax
  8033b0:	0f 88 89 00 00 00    	js     80343f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8033b6:	83 ec 0c             	sub    $0xc,%esp
  8033b9:	ff 75 f0             	pushl  -0x10(%ebp)
  8033bc:	e8 4a f5 ff ff       	call   80290b <fd2data>
  8033c1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8033c8:	50                   	push   %eax
  8033c9:	6a 00                	push   $0x0
  8033cb:	56                   	push   %esi
  8033cc:	6a 00                	push   $0x0
  8033ce:	e8 fd f1 ff ff       	call   8025d0 <sys_page_map>
  8033d3:	89 c3                	mov    %eax,%ebx
  8033d5:	83 c4 20             	add    $0x20,%esp
  8033d8:	85 c0                	test   %eax,%eax
  8033da:	78 55                	js     803431 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8033dc:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8033e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033e5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8033e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033ea:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8033f1:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8033f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8033fa:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8033fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8033ff:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803406:	83 ec 0c             	sub    $0xc,%esp
  803409:	ff 75 f4             	pushl  -0xc(%ebp)
  80340c:	e8 ea f4 ff ff       	call   8028fb <fd2num>
  803411:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803414:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  803416:	83 c4 04             	add    $0x4,%esp
  803419:	ff 75 f0             	pushl  -0x10(%ebp)
  80341c:	e8 da f4 ff ff       	call   8028fb <fd2num>
  803421:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803424:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803427:	83 c4 10             	add    $0x10,%esp
  80342a:	ba 00 00 00 00       	mov    $0x0,%edx
  80342f:	eb 30                	jmp    803461 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  803431:	83 ec 08             	sub    $0x8,%esp
  803434:	56                   	push   %esi
  803435:	6a 00                	push   $0x0
  803437:	e8 d6 f1 ff ff       	call   802612 <sys_page_unmap>
  80343c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80343f:	83 ec 08             	sub    $0x8,%esp
  803442:	ff 75 f0             	pushl  -0x10(%ebp)
  803445:	6a 00                	push   $0x0
  803447:	e8 c6 f1 ff ff       	call   802612 <sys_page_unmap>
  80344c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80344f:	83 ec 08             	sub    $0x8,%esp
  803452:	ff 75 f4             	pushl  -0xc(%ebp)
  803455:	6a 00                	push   $0x0
  803457:	e8 b6 f1 ff ff       	call   802612 <sys_page_unmap>
  80345c:	83 c4 10             	add    $0x10,%esp
  80345f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  803461:	89 d0                	mov    %edx,%eax
  803463:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803466:	5b                   	pop    %ebx
  803467:	5e                   	pop    %esi
  803468:	5d                   	pop    %ebp
  803469:	c3                   	ret    

0080346a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80346a:	55                   	push   %ebp
  80346b:	89 e5                	mov    %esp,%ebp
  80346d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803470:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803473:	50                   	push   %eax
  803474:	ff 75 08             	pushl  0x8(%ebp)
  803477:	e8 f5 f4 ff ff       	call   802971 <fd_lookup>
  80347c:	83 c4 10             	add    $0x10,%esp
  80347f:	85 c0                	test   %eax,%eax
  803481:	78 18                	js     80349b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803483:	83 ec 0c             	sub    $0xc,%esp
  803486:	ff 75 f4             	pushl  -0xc(%ebp)
  803489:	e8 7d f4 ff ff       	call   80290b <fd2data>
	return _pipeisclosed(fd, p);
  80348e:	89 c2                	mov    %eax,%edx
  803490:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803493:	e8 21 fd ff ff       	call   8031b9 <_pipeisclosed>
  803498:	83 c4 10             	add    $0x10,%esp
}
  80349b:	c9                   	leave  
  80349c:	c3                   	ret    

0080349d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80349d:	55                   	push   %ebp
  80349e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8034a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8034a5:	5d                   	pop    %ebp
  8034a6:	c3                   	ret    

008034a7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8034a7:	55                   	push   %ebp
  8034a8:	89 e5                	mov    %esp,%ebp
  8034aa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8034ad:	68 7d 42 80 00       	push   $0x80427d
  8034b2:	ff 75 0c             	pushl  0xc(%ebp)
  8034b5:	e8 d0 ec ff ff       	call   80218a <strcpy>
	return 0;
}
  8034ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8034bf:	c9                   	leave  
  8034c0:	c3                   	ret    

008034c1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8034c1:	55                   	push   %ebp
  8034c2:	89 e5                	mov    %esp,%ebp
  8034c4:	57                   	push   %edi
  8034c5:	56                   	push   %esi
  8034c6:	53                   	push   %ebx
  8034c7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8034cd:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8034d2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8034d8:	eb 2d                	jmp    803507 <devcons_write+0x46>
		m = n - tot;
  8034da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8034dd:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8034df:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8034e2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8034e7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8034ea:	83 ec 04             	sub    $0x4,%esp
  8034ed:	53                   	push   %ebx
  8034ee:	03 45 0c             	add    0xc(%ebp),%eax
  8034f1:	50                   	push   %eax
  8034f2:	57                   	push   %edi
  8034f3:	e8 24 ee ff ff       	call   80231c <memmove>
		sys_cputs(buf, m);
  8034f8:	83 c4 08             	add    $0x8,%esp
  8034fb:	53                   	push   %ebx
  8034fc:	57                   	push   %edi
  8034fd:	e8 cf ef ff ff       	call   8024d1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803502:	01 de                	add    %ebx,%esi
  803504:	83 c4 10             	add    $0x10,%esp
  803507:	89 f0                	mov    %esi,%eax
  803509:	3b 75 10             	cmp    0x10(%ebp),%esi
  80350c:	72 cc                	jb     8034da <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80350e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803511:	5b                   	pop    %ebx
  803512:	5e                   	pop    %esi
  803513:	5f                   	pop    %edi
  803514:	5d                   	pop    %ebp
  803515:	c3                   	ret    

00803516 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  803516:	55                   	push   %ebp
  803517:	89 e5                	mov    %esp,%ebp
  803519:	83 ec 08             	sub    $0x8,%esp
  80351c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  803521:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803525:	74 2a                	je     803551 <devcons_read+0x3b>
  803527:	eb 05                	jmp    80352e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  803529:	e8 40 f0 ff ff       	call   80256e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80352e:	e8 bc ef ff ff       	call   8024ef <sys_cgetc>
  803533:	85 c0                	test   %eax,%eax
  803535:	74 f2                	je     803529 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  803537:	85 c0                	test   %eax,%eax
  803539:	78 16                	js     803551 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80353b:	83 f8 04             	cmp    $0x4,%eax
  80353e:	74 0c                	je     80354c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  803540:	8b 55 0c             	mov    0xc(%ebp),%edx
  803543:	88 02                	mov    %al,(%edx)
	return 1;
  803545:	b8 01 00 00 00       	mov    $0x1,%eax
  80354a:	eb 05                	jmp    803551 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80354c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  803551:	c9                   	leave  
  803552:	c3                   	ret    

00803553 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  803553:	55                   	push   %ebp
  803554:	89 e5                	mov    %esp,%ebp
  803556:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  803559:	8b 45 08             	mov    0x8(%ebp),%eax
  80355c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80355f:	6a 01                	push   $0x1
  803561:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803564:	50                   	push   %eax
  803565:	e8 67 ef ff ff       	call   8024d1 <sys_cputs>
}
  80356a:	83 c4 10             	add    $0x10,%esp
  80356d:	c9                   	leave  
  80356e:	c3                   	ret    

0080356f <getchar>:

int
getchar(void)
{
  80356f:	55                   	push   %ebp
  803570:	89 e5                	mov    %esp,%ebp
  803572:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803575:	6a 01                	push   $0x1
  803577:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80357a:	50                   	push   %eax
  80357b:	6a 00                	push   $0x0
  80357d:	e8 55 f6 ff ff       	call   802bd7 <read>
	if (r < 0)
  803582:	83 c4 10             	add    $0x10,%esp
  803585:	85 c0                	test   %eax,%eax
  803587:	78 0f                	js     803598 <getchar+0x29>
		return r;
	if (r < 1)
  803589:	85 c0                	test   %eax,%eax
  80358b:	7e 06                	jle    803593 <getchar+0x24>
		return -E_EOF;
	return c;
  80358d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  803591:	eb 05                	jmp    803598 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  803593:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  803598:	c9                   	leave  
  803599:	c3                   	ret    

0080359a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80359a:	55                   	push   %ebp
  80359b:	89 e5                	mov    %esp,%ebp
  80359d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8035a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8035a3:	50                   	push   %eax
  8035a4:	ff 75 08             	pushl  0x8(%ebp)
  8035a7:	e8 c5 f3 ff ff       	call   802971 <fd_lookup>
  8035ac:	83 c4 10             	add    $0x10,%esp
  8035af:	85 c0                	test   %eax,%eax
  8035b1:	78 11                	js     8035c4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8035b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035b6:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8035bc:	39 10                	cmp    %edx,(%eax)
  8035be:	0f 94 c0             	sete   %al
  8035c1:	0f b6 c0             	movzbl %al,%eax
}
  8035c4:	c9                   	leave  
  8035c5:	c3                   	ret    

008035c6 <opencons>:

int
opencons(void)
{
  8035c6:	55                   	push   %ebp
  8035c7:	89 e5                	mov    %esp,%ebp
  8035c9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8035cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8035cf:	50                   	push   %eax
  8035d0:	e8 4d f3 ff ff       	call   802922 <fd_alloc>
  8035d5:	83 c4 10             	add    $0x10,%esp
		return r;
  8035d8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8035da:	85 c0                	test   %eax,%eax
  8035dc:	78 3e                	js     80361c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8035de:	83 ec 04             	sub    $0x4,%esp
  8035e1:	68 07 04 00 00       	push   $0x407
  8035e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8035e9:	6a 00                	push   $0x0
  8035eb:	e8 9d ef ff ff       	call   80258d <sys_page_alloc>
  8035f0:	83 c4 10             	add    $0x10,%esp
		return r;
  8035f3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8035f5:	85 c0                	test   %eax,%eax
  8035f7:	78 23                	js     80361c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8035f9:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8035ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803602:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803604:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803607:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80360e:	83 ec 0c             	sub    $0xc,%esp
  803611:	50                   	push   %eax
  803612:	e8 e4 f2 ff ff       	call   8028fb <fd2num>
  803617:	89 c2                	mov    %eax,%edx
  803619:	83 c4 10             	add    $0x10,%esp
}
  80361c:	89 d0                	mov    %edx,%eax
  80361e:	c9                   	leave  
  80361f:	c3                   	ret    

00803620 <__udivdi3>:
  803620:	55                   	push   %ebp
  803621:	57                   	push   %edi
  803622:	56                   	push   %esi
  803623:	53                   	push   %ebx
  803624:	83 ec 1c             	sub    $0x1c,%esp
  803627:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80362b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80362f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803633:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803637:	85 f6                	test   %esi,%esi
  803639:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80363d:	89 ca                	mov    %ecx,%edx
  80363f:	89 f8                	mov    %edi,%eax
  803641:	75 3d                	jne    803680 <__udivdi3+0x60>
  803643:	39 cf                	cmp    %ecx,%edi
  803645:	0f 87 c5 00 00 00    	ja     803710 <__udivdi3+0xf0>
  80364b:	85 ff                	test   %edi,%edi
  80364d:	89 fd                	mov    %edi,%ebp
  80364f:	75 0b                	jne    80365c <__udivdi3+0x3c>
  803651:	b8 01 00 00 00       	mov    $0x1,%eax
  803656:	31 d2                	xor    %edx,%edx
  803658:	f7 f7                	div    %edi
  80365a:	89 c5                	mov    %eax,%ebp
  80365c:	89 c8                	mov    %ecx,%eax
  80365e:	31 d2                	xor    %edx,%edx
  803660:	f7 f5                	div    %ebp
  803662:	89 c1                	mov    %eax,%ecx
  803664:	89 d8                	mov    %ebx,%eax
  803666:	89 cf                	mov    %ecx,%edi
  803668:	f7 f5                	div    %ebp
  80366a:	89 c3                	mov    %eax,%ebx
  80366c:	89 d8                	mov    %ebx,%eax
  80366e:	89 fa                	mov    %edi,%edx
  803670:	83 c4 1c             	add    $0x1c,%esp
  803673:	5b                   	pop    %ebx
  803674:	5e                   	pop    %esi
  803675:	5f                   	pop    %edi
  803676:	5d                   	pop    %ebp
  803677:	c3                   	ret    
  803678:	90                   	nop
  803679:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803680:	39 ce                	cmp    %ecx,%esi
  803682:	77 74                	ja     8036f8 <__udivdi3+0xd8>
  803684:	0f bd fe             	bsr    %esi,%edi
  803687:	83 f7 1f             	xor    $0x1f,%edi
  80368a:	0f 84 98 00 00 00    	je     803728 <__udivdi3+0x108>
  803690:	bb 20 00 00 00       	mov    $0x20,%ebx
  803695:	89 f9                	mov    %edi,%ecx
  803697:	89 c5                	mov    %eax,%ebp
  803699:	29 fb                	sub    %edi,%ebx
  80369b:	d3 e6                	shl    %cl,%esi
  80369d:	89 d9                	mov    %ebx,%ecx
  80369f:	d3 ed                	shr    %cl,%ebp
  8036a1:	89 f9                	mov    %edi,%ecx
  8036a3:	d3 e0                	shl    %cl,%eax
  8036a5:	09 ee                	or     %ebp,%esi
  8036a7:	89 d9                	mov    %ebx,%ecx
  8036a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8036ad:	89 d5                	mov    %edx,%ebp
  8036af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8036b3:	d3 ed                	shr    %cl,%ebp
  8036b5:	89 f9                	mov    %edi,%ecx
  8036b7:	d3 e2                	shl    %cl,%edx
  8036b9:	89 d9                	mov    %ebx,%ecx
  8036bb:	d3 e8                	shr    %cl,%eax
  8036bd:	09 c2                	or     %eax,%edx
  8036bf:	89 d0                	mov    %edx,%eax
  8036c1:	89 ea                	mov    %ebp,%edx
  8036c3:	f7 f6                	div    %esi
  8036c5:	89 d5                	mov    %edx,%ebp
  8036c7:	89 c3                	mov    %eax,%ebx
  8036c9:	f7 64 24 0c          	mull   0xc(%esp)
  8036cd:	39 d5                	cmp    %edx,%ebp
  8036cf:	72 10                	jb     8036e1 <__udivdi3+0xc1>
  8036d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8036d5:	89 f9                	mov    %edi,%ecx
  8036d7:	d3 e6                	shl    %cl,%esi
  8036d9:	39 c6                	cmp    %eax,%esi
  8036db:	73 07                	jae    8036e4 <__udivdi3+0xc4>
  8036dd:	39 d5                	cmp    %edx,%ebp
  8036df:	75 03                	jne    8036e4 <__udivdi3+0xc4>
  8036e1:	83 eb 01             	sub    $0x1,%ebx
  8036e4:	31 ff                	xor    %edi,%edi
  8036e6:	89 d8                	mov    %ebx,%eax
  8036e8:	89 fa                	mov    %edi,%edx
  8036ea:	83 c4 1c             	add    $0x1c,%esp
  8036ed:	5b                   	pop    %ebx
  8036ee:	5e                   	pop    %esi
  8036ef:	5f                   	pop    %edi
  8036f0:	5d                   	pop    %ebp
  8036f1:	c3                   	ret    
  8036f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8036f8:	31 ff                	xor    %edi,%edi
  8036fa:	31 db                	xor    %ebx,%ebx
  8036fc:	89 d8                	mov    %ebx,%eax
  8036fe:	89 fa                	mov    %edi,%edx
  803700:	83 c4 1c             	add    $0x1c,%esp
  803703:	5b                   	pop    %ebx
  803704:	5e                   	pop    %esi
  803705:	5f                   	pop    %edi
  803706:	5d                   	pop    %ebp
  803707:	c3                   	ret    
  803708:	90                   	nop
  803709:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803710:	89 d8                	mov    %ebx,%eax
  803712:	f7 f7                	div    %edi
  803714:	31 ff                	xor    %edi,%edi
  803716:	89 c3                	mov    %eax,%ebx
  803718:	89 d8                	mov    %ebx,%eax
  80371a:	89 fa                	mov    %edi,%edx
  80371c:	83 c4 1c             	add    $0x1c,%esp
  80371f:	5b                   	pop    %ebx
  803720:	5e                   	pop    %esi
  803721:	5f                   	pop    %edi
  803722:	5d                   	pop    %ebp
  803723:	c3                   	ret    
  803724:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803728:	39 ce                	cmp    %ecx,%esi
  80372a:	72 0c                	jb     803738 <__udivdi3+0x118>
  80372c:	31 db                	xor    %ebx,%ebx
  80372e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803732:	0f 87 34 ff ff ff    	ja     80366c <__udivdi3+0x4c>
  803738:	bb 01 00 00 00       	mov    $0x1,%ebx
  80373d:	e9 2a ff ff ff       	jmp    80366c <__udivdi3+0x4c>
  803742:	66 90                	xchg   %ax,%ax
  803744:	66 90                	xchg   %ax,%ax
  803746:	66 90                	xchg   %ax,%ax
  803748:	66 90                	xchg   %ax,%ax
  80374a:	66 90                	xchg   %ax,%ax
  80374c:	66 90                	xchg   %ax,%ax
  80374e:	66 90                	xchg   %ax,%ax

00803750 <__umoddi3>:
  803750:	55                   	push   %ebp
  803751:	57                   	push   %edi
  803752:	56                   	push   %esi
  803753:	53                   	push   %ebx
  803754:	83 ec 1c             	sub    $0x1c,%esp
  803757:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80375b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80375f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803763:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803767:	85 d2                	test   %edx,%edx
  803769:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80376d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803771:	89 f3                	mov    %esi,%ebx
  803773:	89 3c 24             	mov    %edi,(%esp)
  803776:	89 74 24 04          	mov    %esi,0x4(%esp)
  80377a:	75 1c                	jne    803798 <__umoddi3+0x48>
  80377c:	39 f7                	cmp    %esi,%edi
  80377e:	76 50                	jbe    8037d0 <__umoddi3+0x80>
  803780:	89 c8                	mov    %ecx,%eax
  803782:	89 f2                	mov    %esi,%edx
  803784:	f7 f7                	div    %edi
  803786:	89 d0                	mov    %edx,%eax
  803788:	31 d2                	xor    %edx,%edx
  80378a:	83 c4 1c             	add    $0x1c,%esp
  80378d:	5b                   	pop    %ebx
  80378e:	5e                   	pop    %esi
  80378f:	5f                   	pop    %edi
  803790:	5d                   	pop    %ebp
  803791:	c3                   	ret    
  803792:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803798:	39 f2                	cmp    %esi,%edx
  80379a:	89 d0                	mov    %edx,%eax
  80379c:	77 52                	ja     8037f0 <__umoddi3+0xa0>
  80379e:	0f bd ea             	bsr    %edx,%ebp
  8037a1:	83 f5 1f             	xor    $0x1f,%ebp
  8037a4:	75 5a                	jne    803800 <__umoddi3+0xb0>
  8037a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8037aa:	0f 82 e0 00 00 00    	jb     803890 <__umoddi3+0x140>
  8037b0:	39 0c 24             	cmp    %ecx,(%esp)
  8037b3:	0f 86 d7 00 00 00    	jbe    803890 <__umoddi3+0x140>
  8037b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8037bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8037c1:	83 c4 1c             	add    $0x1c,%esp
  8037c4:	5b                   	pop    %ebx
  8037c5:	5e                   	pop    %esi
  8037c6:	5f                   	pop    %edi
  8037c7:	5d                   	pop    %ebp
  8037c8:	c3                   	ret    
  8037c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8037d0:	85 ff                	test   %edi,%edi
  8037d2:	89 fd                	mov    %edi,%ebp
  8037d4:	75 0b                	jne    8037e1 <__umoddi3+0x91>
  8037d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8037db:	31 d2                	xor    %edx,%edx
  8037dd:	f7 f7                	div    %edi
  8037df:	89 c5                	mov    %eax,%ebp
  8037e1:	89 f0                	mov    %esi,%eax
  8037e3:	31 d2                	xor    %edx,%edx
  8037e5:	f7 f5                	div    %ebp
  8037e7:	89 c8                	mov    %ecx,%eax
  8037e9:	f7 f5                	div    %ebp
  8037eb:	89 d0                	mov    %edx,%eax
  8037ed:	eb 99                	jmp    803788 <__umoddi3+0x38>
  8037ef:	90                   	nop
  8037f0:	89 c8                	mov    %ecx,%eax
  8037f2:	89 f2                	mov    %esi,%edx
  8037f4:	83 c4 1c             	add    $0x1c,%esp
  8037f7:	5b                   	pop    %ebx
  8037f8:	5e                   	pop    %esi
  8037f9:	5f                   	pop    %edi
  8037fa:	5d                   	pop    %ebp
  8037fb:	c3                   	ret    
  8037fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803800:	8b 34 24             	mov    (%esp),%esi
  803803:	bf 20 00 00 00       	mov    $0x20,%edi
  803808:	89 e9                	mov    %ebp,%ecx
  80380a:	29 ef                	sub    %ebp,%edi
  80380c:	d3 e0                	shl    %cl,%eax
  80380e:	89 f9                	mov    %edi,%ecx
  803810:	89 f2                	mov    %esi,%edx
  803812:	d3 ea                	shr    %cl,%edx
  803814:	89 e9                	mov    %ebp,%ecx
  803816:	09 c2                	or     %eax,%edx
  803818:	89 d8                	mov    %ebx,%eax
  80381a:	89 14 24             	mov    %edx,(%esp)
  80381d:	89 f2                	mov    %esi,%edx
  80381f:	d3 e2                	shl    %cl,%edx
  803821:	89 f9                	mov    %edi,%ecx
  803823:	89 54 24 04          	mov    %edx,0x4(%esp)
  803827:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80382b:	d3 e8                	shr    %cl,%eax
  80382d:	89 e9                	mov    %ebp,%ecx
  80382f:	89 c6                	mov    %eax,%esi
  803831:	d3 e3                	shl    %cl,%ebx
  803833:	89 f9                	mov    %edi,%ecx
  803835:	89 d0                	mov    %edx,%eax
  803837:	d3 e8                	shr    %cl,%eax
  803839:	89 e9                	mov    %ebp,%ecx
  80383b:	09 d8                	or     %ebx,%eax
  80383d:	89 d3                	mov    %edx,%ebx
  80383f:	89 f2                	mov    %esi,%edx
  803841:	f7 34 24             	divl   (%esp)
  803844:	89 d6                	mov    %edx,%esi
  803846:	d3 e3                	shl    %cl,%ebx
  803848:	f7 64 24 04          	mull   0x4(%esp)
  80384c:	39 d6                	cmp    %edx,%esi
  80384e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803852:	89 d1                	mov    %edx,%ecx
  803854:	89 c3                	mov    %eax,%ebx
  803856:	72 08                	jb     803860 <__umoddi3+0x110>
  803858:	75 11                	jne    80386b <__umoddi3+0x11b>
  80385a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80385e:	73 0b                	jae    80386b <__umoddi3+0x11b>
  803860:	2b 44 24 04          	sub    0x4(%esp),%eax
  803864:	1b 14 24             	sbb    (%esp),%edx
  803867:	89 d1                	mov    %edx,%ecx
  803869:	89 c3                	mov    %eax,%ebx
  80386b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80386f:	29 da                	sub    %ebx,%edx
  803871:	19 ce                	sbb    %ecx,%esi
  803873:	89 f9                	mov    %edi,%ecx
  803875:	89 f0                	mov    %esi,%eax
  803877:	d3 e0                	shl    %cl,%eax
  803879:	89 e9                	mov    %ebp,%ecx
  80387b:	d3 ea                	shr    %cl,%edx
  80387d:	89 e9                	mov    %ebp,%ecx
  80387f:	d3 ee                	shr    %cl,%esi
  803881:	09 d0                	or     %edx,%eax
  803883:	89 f2                	mov    %esi,%edx
  803885:	83 c4 1c             	add    $0x1c,%esp
  803888:	5b                   	pop    %ebx
  803889:	5e                   	pop    %esi
  80388a:	5f                   	pop    %edi
  80388b:	5d                   	pop    %ebp
  80388c:	c3                   	ret    
  80388d:	8d 76 00             	lea    0x0(%esi),%esi
  803890:	29 f9                	sub    %edi,%ecx
  803892:	19 d6                	sbb    %edx,%esi
  803894:	89 74 24 04          	mov    %esi,0x4(%esp)
  803898:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80389c:	e9 18 ff ff ff       	jmp    8037b9 <__umoddi3+0x69>
