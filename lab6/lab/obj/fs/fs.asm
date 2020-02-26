
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
  80002c:	e8 17 1a 00 00       	call   801a48 <libmain>
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
  8000b2:	68 60 3d 80 00       	push   $0x803d60
  8000b7:	e8 c5 1a 00 00       	call   801b81 <cprintf>
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
  8000d4:	68 77 3d 80 00       	push   $0x803d77
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 87 3d 80 00       	push   $0x803d87
  8000e0:	e8 c3 19 00 00       	call   801aa8 <_panic>
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
  800106:	68 90 3d 80 00       	push   $0x803d90
  80010b:	68 9d 3d 80 00       	push   $0x803d9d
  800110:	6a 44                	push   $0x44
  800112:	68 87 3d 80 00       	push   $0x803d87
  800117:	e8 8c 19 00 00       	call   801aa8 <_panic>

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
  8001ca:	68 90 3d 80 00       	push   $0x803d90
  8001cf:	68 9d 3d 80 00       	push   $0x803d9d
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 87 3d 80 00       	push   $0x803d87
  8001db:	e8 c8 18 00 00       	call   801aa8 <_panic>

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
  80029a:	68 b4 3d 80 00       	push   $0x803db4
  80029f:	6a 27                	push   $0x27
  8002a1:	68 70 3e 80 00       	push   $0x803e70
  8002a6:	e8 fd 17 00 00       	call   801aa8 <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002ab:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8002b0:	85 c0                	test   %eax,%eax
  8002b2:	74 17                	je     8002cb <bc_pgfault+0x57>
  8002b4:	3b 70 04             	cmp    0x4(%eax),%esi
  8002b7:	72 12                	jb     8002cb <bc_pgfault+0x57>
		panic("reading non-existent block %08x\n", blockno);
  8002b9:	56                   	push   %esi
  8002ba:	68 e4 3d 80 00       	push   $0x803de4
  8002bf:	6a 2b                	push   $0x2b
  8002c1:	68 70 3e 80 00       	push   $0x803e70
  8002c6:	e8 dd 17 00 00       	call   801aa8 <_panic>
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
  8002dc:	e8 a7 22 00 00       	call   802588 <sys_page_alloc>
  8002e1:	83 c4 10             	add    $0x10,%esp
  8002e4:	85 c0                	test   %eax,%eax
  8002e6:	79 14                	jns    8002fc <bc_pgfault+0x88>
  8002e8:	83 ec 04             	sub    $0x4,%esp
  8002eb:	68 78 3e 80 00       	push   $0x803e78
  8002f0:	6a 34                	push   $0x34
  8002f2:	68 70 3e 80 00       	push   $0x803e70
  8002f7:	e8 ac 17 00 00       	call   801aa8 <_panic>
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
  800329:	e8 9d 22 00 00       	call   8025cb <sys_page_map>
  80032e:	83 c4 20             	add    $0x20,%esp
  800331:	85 c0                	test   %eax,%eax
  800333:	79 12                	jns    800347 <bc_pgfault+0xd3>
		panic("in bc_pgfault, sys_page_map: %e", r);
  800335:	50                   	push   %eax
  800336:	68 08 3e 80 00       	push   $0x803e08
  80033b:	6a 3a                	push   $0x3a
  80033d:	68 70 3e 80 00       	push   $0x803e70
  800342:	e8 61 17 00 00       	call   801aa8 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  800347:	83 3d 08 a0 80 00 00 	cmpl   $0x0,0x80a008
  80034e:	74 22                	je     800372 <bc_pgfault+0xfe>
  800350:	83 ec 0c             	sub    $0xc,%esp
  800353:	56                   	push   %esi
  800354:	e8 51 04 00 00       	call   8007aa <block_is_free>
  800359:	83 c4 10             	add    $0x10,%esp
  80035c:	84 c0                	test   %al,%al
  80035e:	74 12                	je     800372 <bc_pgfault+0xfe>
		panic("reading free block %08x\n", blockno);
  800360:	56                   	push   %esi
  800361:	68 89 3e 80 00       	push   $0x803e89
  800366:	6a 40                	push   $0x40
  800368:	68 70 3e 80 00       	push   $0x803e70
  80036d:	e8 36 17 00 00       	call   801aa8 <_panic>
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
  800386:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  80038c:	85 d2                	test   %edx,%edx
  80038e:	74 17                	je     8003a7 <diskaddr+0x2e>
  800390:	3b 42 04             	cmp    0x4(%edx),%eax
  800393:	72 12                	jb     8003a7 <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  800395:	50                   	push   %eax
  800396:	68 28 3e 80 00       	push   $0x803e28
  80039b:	6a 09                	push   $0x9
  80039d:	68 70 3e 80 00       	push   $0x803e70
  8003a2:	e8 01 17 00 00       	call   801aa8 <_panic>
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
  80040d:	68 a2 3e 80 00       	push   $0x803ea2
  800412:	6a 50                	push   $0x50
  800414:	68 70 3e 80 00       	push   $0x803e70
  800419:	e8 8a 16 00 00       	call   801aa8 <_panic>

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
  80046b:	e8 5b 21 00 00       	call   8025cb <sys_page_map>
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
  800489:	e8 2a 23 00 00       	call   8027b8 <set_pgfault_handler>
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
  8004aa:	e8 68 1e 00 00       	call   802317 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  8004af:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004b6:	e8 be fe ff ff       	call   800379 <diskaddr>
  8004bb:	83 c4 08             	add    $0x8,%esp
  8004be:	68 bd 3e 80 00       	push   $0x803ebd
  8004c3:	50                   	push   %eax
  8004c4:	e8 bc 1c 00 00       	call   802185 <strcpy>
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
  8004f8:	68 df 3e 80 00       	push   $0x803edf
  8004fd:	68 9d 3d 80 00       	push   $0x803d9d
  800502:	6a 67                	push   $0x67
  800504:	68 70 3e 80 00       	push   $0x803e70
  800509:	e8 9a 15 00 00       	call   801aa8 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  80050e:	83 ec 0c             	sub    $0xc,%esp
  800511:	6a 01                	push   $0x1
  800513:	e8 61 fe ff ff       	call   800379 <diskaddr>
  800518:	89 04 24             	mov    %eax,(%esp)
  80051b:	e8 bf fe ff ff       	call   8003df <va_is_dirty>
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	84 c0                	test   %al,%al
  800525:	74 16                	je     80053d <bc_init+0xc3>
  800527:	68 c4 3e 80 00       	push   $0x803ec4
  80052c:	68 9d 3d 80 00       	push   $0x803d9d
  800531:	6a 68                	push   $0x68
  800533:	68 70 3e 80 00       	push   $0x803e70
  800538:	e8 6b 15 00 00       	call   801aa8 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  80053d:	83 ec 0c             	sub    $0xc,%esp
  800540:	6a 01                	push   $0x1
  800542:	e8 32 fe ff ff       	call   800379 <diskaddr>
  800547:	83 c4 08             	add    $0x8,%esp
  80054a:	50                   	push   %eax
  80054b:	6a 00                	push   $0x0
  80054d:	e8 bb 20 00 00       	call   80260d <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800552:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800559:	e8 1b fe ff ff       	call   800379 <diskaddr>
  80055e:	89 04 24             	mov    %eax,(%esp)
  800561:	e8 4b fe ff ff       	call   8003b1 <va_is_mapped>
  800566:	83 c4 10             	add    $0x10,%esp
  800569:	84 c0                	test   %al,%al
  80056b:	74 16                	je     800583 <bc_init+0x109>
  80056d:	68 de 3e 80 00       	push   $0x803ede
  800572:	68 9d 3d 80 00       	push   $0x803d9d
  800577:	6a 6c                	push   $0x6c
  800579:	68 70 3e 80 00       	push   $0x803e70
  80057e:	e8 25 15 00 00       	call   801aa8 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800583:	83 ec 0c             	sub    $0xc,%esp
  800586:	6a 01                	push   $0x1
  800588:	e8 ec fd ff ff       	call   800379 <diskaddr>
  80058d:	83 c4 08             	add    $0x8,%esp
  800590:	68 bd 3e 80 00       	push   $0x803ebd
  800595:	50                   	push   %eax
  800596:	e8 94 1c 00 00       	call   80222f <strcmp>
  80059b:	83 c4 10             	add    $0x10,%esp
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	74 16                	je     8005b8 <bc_init+0x13e>
  8005a2:	68 4c 3e 80 00       	push   $0x803e4c
  8005a7:	68 9d 3d 80 00       	push   $0x803d9d
  8005ac:	6a 6f                	push   $0x6f
  8005ae:	68 70 3e 80 00       	push   $0x803e70
  8005b3:	e8 f0 14 00 00       	call   801aa8 <_panic>

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
  8005d2:	e8 40 1d 00 00       	call   802317 <memmove>
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
  800601:	e8 11 1d 00 00       	call   802317 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800606:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80060d:	e8 67 fd ff ff       	call   800379 <diskaddr>
  800612:	83 c4 08             	add    $0x8,%esp
  800615:	68 bd 3e 80 00       	push   $0x803ebd
  80061a:	50                   	push   %eax
  80061b:	e8 65 1b 00 00       	call   802185 <strcpy>

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
  800652:	68 df 3e 80 00       	push   $0x803edf
  800657:	68 9d 3d 80 00       	push   $0x803d9d
  80065c:	68 80 00 00 00       	push   $0x80
  800661:	68 70 3e 80 00       	push   $0x803e70
  800666:	e8 3d 14 00 00       	call   801aa8 <_panic>
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
  80067b:	e8 8d 1f 00 00       	call   80260d <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800680:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800687:	e8 ed fc ff ff       	call   800379 <diskaddr>
  80068c:	89 04 24             	mov    %eax,(%esp)
  80068f:	e8 1d fd ff ff       	call   8003b1 <va_is_mapped>
  800694:	83 c4 10             	add    $0x10,%esp
  800697:	84 c0                	test   %al,%al
  800699:	74 19                	je     8006b4 <bc_init+0x23a>
  80069b:	68 de 3e 80 00       	push   $0x803ede
  8006a0:	68 9d 3d 80 00       	push   $0x803d9d
  8006a5:	68 88 00 00 00       	push   $0x88
  8006aa:	68 70 3e 80 00       	push   $0x803e70
  8006af:	e8 f4 13 00 00       	call   801aa8 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8006b4:	83 ec 0c             	sub    $0xc,%esp
  8006b7:	6a 01                	push   $0x1
  8006b9:	e8 bb fc ff ff       	call   800379 <diskaddr>
  8006be:	83 c4 08             	add    $0x8,%esp
  8006c1:	68 bd 3e 80 00       	push   $0x803ebd
  8006c6:	50                   	push   %eax
  8006c7:	e8 63 1b 00 00       	call   80222f <strcmp>
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	74 19                	je     8006ec <bc_init+0x272>
  8006d3:	68 4c 3e 80 00       	push   $0x803e4c
  8006d8:	68 9d 3d 80 00       	push   $0x803d9d
  8006dd:	68 8b 00 00 00       	push   $0x8b
  8006e2:	68 70 3e 80 00       	push   $0x803e70
  8006e7:	e8 bc 13 00 00       	call   801aa8 <_panic>

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
  800706:	e8 0c 1c 00 00       	call   802317 <memmove>
	flush_block(diskaddr(1));
  80070b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800712:	e8 62 fc ff ff       	call   800379 <diskaddr>
  800717:	89 04 24             	mov    %eax,(%esp)
  80071a:	e8 d8 fc ff ff       	call   8003f7 <flush_block>

	cprintf("block cache is good\n");
  80071f:	c7 04 24 f9 3e 80 00 	movl   $0x803ef9,(%esp)
  800726:	e8 56 14 00 00       	call   801b81 <cprintf>
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
  800747:	e8 cb 1b 00 00       	call   802317 <memmove>
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
  80075a:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80075f:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800765:	74 14                	je     80077b <check_super+0x27>
		panic("bad file system magic number");
  800767:	83 ec 04             	sub    $0x4,%esp
  80076a:	68 0e 3f 80 00       	push   $0x803f0e
  80076f:	6a 0f                	push   $0xf
  800771:	68 2b 3f 80 00       	push   $0x803f2b
  800776:	e8 2d 13 00 00       	call   801aa8 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  80077b:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  800782:	76 14                	jbe    800798 <check_super+0x44>
		panic("file system is too large");
  800784:	83 ec 04             	sub    $0x4,%esp
  800787:	68 33 3f 80 00       	push   $0x803f33
  80078c:	6a 12                	push   $0x12
  80078e:	68 2b 3f 80 00       	push   $0x803f2b
  800793:	e8 10 13 00 00       	call   801aa8 <_panic>

	cprintf("superblock is good\n");
  800798:	83 ec 0c             	sub    $0xc,%esp
  80079b:	68 4c 3f 80 00       	push   $0x803f4c
  8007a0:	e8 dc 13 00 00       	call   801b81 <cprintf>
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
  8007b1:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
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
  8007d1:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
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
  8007f8:	68 60 3f 80 00       	push   $0x803f60
  8007fd:	6a 2d                	push   $0x2d
  8007ff:	68 2b 3f 80 00       	push   $0x803f2b
  800804:	e8 9f 12 00 00       	call   801aa8 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800809:	89 cb                	mov    %ecx,%ebx
  80080b:	c1 eb 05             	shr    $0x5,%ebx
  80080e:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
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
  80082c:	a1 0c a0 80 00       	mov    0x80a00c,%eax
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
  800853:	8b 35 08 a0 80 00    	mov    0x80a008,%esi
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
	   if((f->f_indirect)==0){
  8008e0:	83 b8 b0 00 00 00 00 	cmpl   $0x0,0xb0(%eax)
  8008e7:	75 45                	jne    80092e <file_block_walk+0x8d>
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
  800910:	e8 b5 19 00 00       	call   8022ca <memset>
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
	   if((f->f_indirect)==0){
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
  80097f:	a1 0c a0 80 00       	mov    0x80a00c,%eax
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
  80099e:	68 7b 3f 80 00       	push   $0x803f7b
  8009a3:	68 9d 3d 80 00       	push   $0x803d9d
  8009a8:	6a 57                	push   $0x57
  8009aa:	68 2b 3f 80 00       	push   $0x803f2b
  8009af:	e8 f4 10 00 00       	call   801aa8 <_panic>
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
  8009d1:	68 8f 3f 80 00       	push   $0x803f8f
  8009d6:	68 9d 3d 80 00       	push   $0x803d9d
  8009db:	6a 5a                	push   $0x5a
  8009dd:	68 2b 3f 80 00       	push   $0x803f2b
  8009e2:	e8 c1 10 00 00       	call   801aa8 <_panic>
	assert(!block_is_free(1));
  8009e7:	83 ec 0c             	sub    $0xc,%esp
  8009ea:	6a 01                	push   $0x1
  8009ec:	e8 b9 fd ff ff       	call   8007aa <block_is_free>
  8009f1:	83 c4 10             	add    $0x10,%esp
  8009f4:	84 c0                	test   %al,%al
  8009f6:	74 16                	je     800a0e <check_bitmap+0x94>
  8009f8:	68 a1 3f 80 00       	push   $0x803fa1
  8009fd:	68 9d 3d 80 00       	push   $0x803d9d
  800a02:	6a 5b                	push   $0x5b
  800a04:	68 2b 3f 80 00       	push   $0x803f2b
  800a09:	e8 9a 10 00 00       	call   801aa8 <_panic>

	cprintf("bitmap is good\n");
  800a0e:	83 ec 0c             	sub    $0xc,%esp
  800a11:	68 b3 3f 80 00       	push   $0x803fb3
  800a16:	e8 66 11 00 00       	call   801b81 <cprintf>
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
  800a5f:	a3 0c a0 80 00       	mov    %eax,0x80a00c
	check_super();
  800a64:	e8 eb fc ff ff       	call   800754 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  800a69:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800a70:	e8 04 f9 ff ff       	call   800379 <diskaddr>
  800a75:	a3 08 a0 80 00       	mov    %eax,0x80a008
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
  800b1c:	8b 0d 0c a0 80 00    	mov    0x80a00c,%ecx
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
  800b84:	e8 8e 17 00 00       	call   802317 <memmove>
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
  800bbe:	68 c3 3f 80 00       	push   $0x803fc3
  800bc3:	68 9d 3d 80 00       	push   $0x803d9d
  800bc8:	68 d2 00 00 00       	push   $0xd2
  800bcd:	68 2b 3f 80 00       	push   $0x803f2b
  800bd2:	e8 d1 0e 00 00       	call   801aa8 <_panic>
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
  800c3a:	e8 f0 15 00 00       	call   80222f <strcmp>
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
  800ca2:	e8 de 14 00 00       	call   802185 <strcpy>
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
  800dc9:	e8 49 15 00 00       	call   802317 <memmove>
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
  800e9a:	68 e0 3f 80 00       	push   $0x803fe0
  800e9f:	e8 dd 0c 00 00       	call   801b81 <cprintf>
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
  800f50:	e8 c2 13 00 00       	call   802317 <memmove>
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
  801061:	68 c3 3f 80 00       	push   $0x803fc3
  801066:	68 9d 3d 80 00       	push   $0x803d9d
  80106b:	68 eb 00 00 00       	push   $0xeb
  801070:	68 2b 3f 80 00       	push   $0x803f2b
  801075:	e8 2e 0a 00 00       	call   801aa8 <_panic>
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
  80112c:	e8 54 10 00 00       	call   802185 <strcpy>
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
  80117f:	a1 0c a0 80 00       	mov    0x80a00c,%eax
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
  8011e7:	e8 54 1f 00 00       	call   803140 <pageref>
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
  80120c:	e8 77 13 00 00       	call   802588 <sys_page_alloc>
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
  80123d:	e8 88 10 00 00       	call   8022ca <memset>
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
  801287:	e8 b4 1e 00 00       	call   803140 <pageref>
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

	// Lab 5: Your code here:
	int r=0;

	struct OpenFile *o;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801314:	85 c0                	test   %eax,%eax
  801316:	78 2b                	js     801343 <serve_read+0x4c>
		return r;
	r=file_read(o->o_file,ret,req->req_n,o->o_fd->fd_offset);
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
  8013c9:	e8 b7 0d 00 00       	call   802185 <strcpy>
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
  801453:	e8 bf 0e 00 00       	call   802317 <memmove>
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
  80158a:	e8 b0 12 00 00       	call   80283f <ipc_recv>
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
  80159e:	68 00 40 80 00       	push   $0x804000
  8015a3:	e8 d9 05 00 00       	call   801b81 <cprintf>
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
  8015fb:	68 30 40 80 00       	push   $0x804030
  801600:	e8 7c 05 00 00       	call   801b81 <cprintf>
  801605:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  801608:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  80160d:	ff 75 f0             	pushl  -0x10(%ebp)
  801610:	ff 75 ec             	pushl  -0x14(%ebp)
  801613:	50                   	push   %eax
  801614:	ff 75 f4             	pushl  -0xc(%ebp)
  801617:	e8 8c 12 00 00       	call   8028a8 <ipc_send>
		sys_page_unmap(0, fsreq);
  80161c:	83 c4 08             	add    $0x8,%esp
  80161f:	ff 35 44 50 80 00    	pushl  0x805044
  801625:	6a 00                	push   $0x0
  801627:	e8 e1 0f 00 00       	call   80260d <sys_page_unmap>
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
  80163a:	c7 05 60 90 80 00 53 	movl   $0x804053,0x809060
  801641:	40 80 00 
	cprintf("FS is running\n");
  801644:	68 56 40 80 00       	push   $0x804056
  801649:	e8 33 05 00 00       	call   801b81 <cprintf>
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
  80165a:	c7 04 24 65 40 80 00 	movl   $0x804065,(%esp)
  801661:	e8 1b 05 00 00       	call   801b81 <cprintf>

	serve_init();
  801666:	e8 35 fb ff ff       	call   8011a0 <serve_init>
	fs_init();
  80166b:	e8 b5 f3 ff ff       	call   800a25 <fs_init>
	serve();
  801670:	e8 f5 fe ff ff       	call   80156a <serve>

00801675 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	53                   	push   %ebx
  801679:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  80167c:	6a 07                	push   $0x7
  80167e:	68 00 10 00 00       	push   $0x1000
  801683:	6a 00                	push   $0x0
  801685:	e8 fe 0e 00 00       	call   802588 <sys_page_alloc>
  80168a:	83 c4 10             	add    $0x10,%esp
  80168d:	85 c0                	test   %eax,%eax
  80168f:	79 12                	jns    8016a3 <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  801691:	50                   	push   %eax
  801692:	68 74 40 80 00       	push   $0x804074
  801697:	6a 12                	push   $0x12
  801699:	68 87 40 80 00       	push   $0x804087
  80169e:	e8 05 04 00 00       	call   801aa8 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  8016a3:	83 ec 04             	sub    $0x4,%esp
  8016a6:	68 00 10 00 00       	push   $0x1000
  8016ab:	ff 35 08 a0 80 00    	pushl  0x80a008
  8016b1:	68 00 10 00 00       	push   $0x1000
  8016b6:	e8 5c 0c 00 00       	call   802317 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8016bb:	e8 63 f1 ff ff       	call   800823 <alloc_block>
  8016c0:	83 c4 10             	add    $0x10,%esp
  8016c3:	85 c0                	test   %eax,%eax
  8016c5:	79 12                	jns    8016d9 <fs_test+0x64>
		panic("alloc_block: %e", r);
  8016c7:	50                   	push   %eax
  8016c8:	68 91 40 80 00       	push   $0x804091
  8016cd:	6a 17                	push   $0x17
  8016cf:	68 87 40 80 00       	push   $0x804087
  8016d4:	e8 cf 03 00 00       	call   801aa8 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8016d9:	8d 50 1f             	lea    0x1f(%eax),%edx
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	0f 49 d0             	cmovns %eax,%edx
  8016e1:	c1 fa 05             	sar    $0x5,%edx
  8016e4:	89 c3                	mov    %eax,%ebx
  8016e6:	c1 fb 1f             	sar    $0x1f,%ebx
  8016e9:	c1 eb 1b             	shr    $0x1b,%ebx
  8016ec:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  8016ef:	83 e1 1f             	and    $0x1f,%ecx
  8016f2:	29 d9                	sub    %ebx,%ecx
  8016f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8016f9:	d3 e0                	shl    %cl,%eax
  8016fb:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  801702:	75 16                	jne    80171a <fs_test+0xa5>
  801704:	68 a1 40 80 00       	push   $0x8040a1
  801709:	68 9d 3d 80 00       	push   $0x803d9d
  80170e:	6a 19                	push   $0x19
  801710:	68 87 40 80 00       	push   $0x804087
  801715:	e8 8e 03 00 00       	call   801aa8 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  80171a:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  801720:	85 04 91             	test   %eax,(%ecx,%edx,4)
  801723:	74 16                	je     80173b <fs_test+0xc6>
  801725:	68 1c 42 80 00       	push   $0x80421c
  80172a:	68 9d 3d 80 00       	push   $0x803d9d
  80172f:	6a 1b                	push   $0x1b
  801731:	68 87 40 80 00       	push   $0x804087
  801736:	e8 6d 03 00 00       	call   801aa8 <_panic>
	cprintf("alloc_block is good\n");
  80173b:	83 ec 0c             	sub    $0xc,%esp
  80173e:	68 bc 40 80 00       	push   $0x8040bc
  801743:	e8 39 04 00 00       	call   801b81 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801748:	83 c4 08             	add    $0x8,%esp
  80174b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80174e:	50                   	push   %eax
  80174f:	68 d1 40 80 00       	push   $0x8040d1
  801754:	e8 cf f5 ff ff       	call   800d28 <file_open>
  801759:	83 c4 10             	add    $0x10,%esp
  80175c:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80175f:	74 1b                	je     80177c <fs_test+0x107>
  801761:	89 c2                	mov    %eax,%edx
  801763:	c1 ea 1f             	shr    $0x1f,%edx
  801766:	84 d2                	test   %dl,%dl
  801768:	74 12                	je     80177c <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  80176a:	50                   	push   %eax
  80176b:	68 dc 40 80 00       	push   $0x8040dc
  801770:	6a 1f                	push   $0x1f
  801772:	68 87 40 80 00       	push   $0x804087
  801777:	e8 2c 03 00 00       	call   801aa8 <_panic>
	else if (r == 0)
  80177c:	85 c0                	test   %eax,%eax
  80177e:	75 14                	jne    801794 <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  801780:	83 ec 04             	sub    $0x4,%esp
  801783:	68 3c 42 80 00       	push   $0x80423c
  801788:	6a 21                	push   $0x21
  80178a:	68 87 40 80 00       	push   $0x804087
  80178f:	e8 14 03 00 00       	call   801aa8 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801794:	83 ec 08             	sub    $0x8,%esp
  801797:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80179a:	50                   	push   %eax
  80179b:	68 f5 40 80 00       	push   $0x8040f5
  8017a0:	e8 83 f5 ff ff       	call   800d28 <file_open>
  8017a5:	83 c4 10             	add    $0x10,%esp
  8017a8:	85 c0                	test   %eax,%eax
  8017aa:	79 12                	jns    8017be <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  8017ac:	50                   	push   %eax
  8017ad:	68 fe 40 80 00       	push   $0x8040fe
  8017b2:	6a 23                	push   $0x23
  8017b4:	68 87 40 80 00       	push   $0x804087
  8017b9:	e8 ea 02 00 00       	call   801aa8 <_panic>
	cprintf("file_open is good\n");
  8017be:	83 ec 0c             	sub    $0xc,%esp
  8017c1:	68 15 41 80 00       	push   $0x804115
  8017c6:	e8 b6 03 00 00       	call   801b81 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8017cb:	83 c4 0c             	add    $0xc,%esp
  8017ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d1:	50                   	push   %eax
  8017d2:	6a 00                	push   $0x0
  8017d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8017d7:	e8 a8 f2 ff ff       	call   800a84 <file_get_block>
  8017dc:	83 c4 10             	add    $0x10,%esp
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	79 12                	jns    8017f5 <fs_test+0x180>
		panic("file_get_block: %e", r);
  8017e3:	50                   	push   %eax
  8017e4:	68 28 41 80 00       	push   $0x804128
  8017e9:	6a 27                	push   $0x27
  8017eb:	68 87 40 80 00       	push   $0x804087
  8017f0:	e8 b3 02 00 00       	call   801aa8 <_panic>
	if (strcmp(blk, msg) != 0)
  8017f5:	83 ec 08             	sub    $0x8,%esp
  8017f8:	68 5c 42 80 00       	push   $0x80425c
  8017fd:	ff 75 f0             	pushl  -0x10(%ebp)
  801800:	e8 2a 0a 00 00       	call   80222f <strcmp>
  801805:	83 c4 10             	add    $0x10,%esp
  801808:	85 c0                	test   %eax,%eax
  80180a:	74 14                	je     801820 <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  80180c:	83 ec 04             	sub    $0x4,%esp
  80180f:	68 84 42 80 00       	push   $0x804284
  801814:	6a 29                	push   $0x29
  801816:	68 87 40 80 00       	push   $0x804087
  80181b:	e8 88 02 00 00       	call   801aa8 <_panic>
	cprintf("file_get_block is good\n");
  801820:	83 ec 0c             	sub    $0xc,%esp
  801823:	68 3b 41 80 00       	push   $0x80413b
  801828:	e8 54 03 00 00       	call   801b81 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  80182d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801830:	0f b6 10             	movzbl (%eax),%edx
  801833:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801835:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801838:	c1 e8 0c             	shr    $0xc,%eax
  80183b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801842:	83 c4 10             	add    $0x10,%esp
  801845:	a8 40                	test   $0x40,%al
  801847:	75 16                	jne    80185f <fs_test+0x1ea>
  801849:	68 54 41 80 00       	push   $0x804154
  80184e:	68 9d 3d 80 00       	push   $0x803d9d
  801853:	6a 2d                	push   $0x2d
  801855:	68 87 40 80 00       	push   $0x804087
  80185a:	e8 49 02 00 00       	call   801aa8 <_panic>
	file_flush(f);
  80185f:	83 ec 0c             	sub    $0xc,%esp
  801862:	ff 75 f4             	pushl  -0xc(%ebp)
  801865:	e8 04 f7 ff ff       	call   800f6e <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  80186a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80186d:	c1 e8 0c             	shr    $0xc,%eax
  801870:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	a8 40                	test   $0x40,%al
  80187c:	74 16                	je     801894 <fs_test+0x21f>
  80187e:	68 53 41 80 00       	push   $0x804153
  801883:	68 9d 3d 80 00       	push   $0x803d9d
  801888:	6a 2f                	push   $0x2f
  80188a:	68 87 40 80 00       	push   $0x804087
  80188f:	e8 14 02 00 00       	call   801aa8 <_panic>
	cprintf("file_flush is good\n");
  801894:	83 ec 0c             	sub    $0xc,%esp
  801897:	68 6f 41 80 00       	push   $0x80416f
  80189c:	e8 e0 02 00 00       	call   801b81 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  8018a1:	83 c4 08             	add    $0x8,%esp
  8018a4:	6a 00                	push   $0x0
  8018a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a9:	e8 39 f5 ff ff       	call   800de7 <file_set_size>
  8018ae:	83 c4 10             	add    $0x10,%esp
  8018b1:	85 c0                	test   %eax,%eax
  8018b3:	79 12                	jns    8018c7 <fs_test+0x252>
		panic("file_set_size: %e", r);
  8018b5:	50                   	push   %eax
  8018b6:	68 83 41 80 00       	push   $0x804183
  8018bb:	6a 33                	push   $0x33
  8018bd:	68 87 40 80 00       	push   $0x804087
  8018c2:	e8 e1 01 00 00       	call   801aa8 <_panic>
	assert(f->f_direct[0] == 0);
  8018c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ca:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8018d1:	74 16                	je     8018e9 <fs_test+0x274>
  8018d3:	68 95 41 80 00       	push   $0x804195
  8018d8:	68 9d 3d 80 00       	push   $0x803d9d
  8018dd:	6a 34                	push   $0x34
  8018df:	68 87 40 80 00       	push   $0x804087
  8018e4:	e8 bf 01 00 00       	call   801aa8 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8018e9:	c1 e8 0c             	shr    $0xc,%eax
  8018ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018f3:	a8 40                	test   $0x40,%al
  8018f5:	74 16                	je     80190d <fs_test+0x298>
  8018f7:	68 a9 41 80 00       	push   $0x8041a9
  8018fc:	68 9d 3d 80 00       	push   $0x803d9d
  801901:	6a 35                	push   $0x35
  801903:	68 87 40 80 00       	push   $0x804087
  801908:	e8 9b 01 00 00       	call   801aa8 <_panic>
	cprintf("file_truncate is good\n");
  80190d:	83 ec 0c             	sub    $0xc,%esp
  801910:	68 c3 41 80 00       	push   $0x8041c3
  801915:	e8 67 02 00 00       	call   801b81 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  80191a:	c7 04 24 5c 42 80 00 	movl   $0x80425c,(%esp)
  801921:	e8 26 08 00 00       	call   80214c <strlen>
  801926:	83 c4 08             	add    $0x8,%esp
  801929:	50                   	push   %eax
  80192a:	ff 75 f4             	pushl  -0xc(%ebp)
  80192d:	e8 b5 f4 ff ff       	call   800de7 <file_set_size>
  801932:	83 c4 10             	add    $0x10,%esp
  801935:	85 c0                	test   %eax,%eax
  801937:	79 12                	jns    80194b <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  801939:	50                   	push   %eax
  80193a:	68 da 41 80 00       	push   $0x8041da
  80193f:	6a 39                	push   $0x39
  801941:	68 87 40 80 00       	push   $0x804087
  801946:	e8 5d 01 00 00       	call   801aa8 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  80194b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194e:	89 c2                	mov    %eax,%edx
  801950:	c1 ea 0c             	shr    $0xc,%edx
  801953:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80195a:	f6 c2 40             	test   $0x40,%dl
  80195d:	74 16                	je     801975 <fs_test+0x300>
  80195f:	68 a9 41 80 00       	push   $0x8041a9
  801964:	68 9d 3d 80 00       	push   $0x803d9d
  801969:	6a 3a                	push   $0x3a
  80196b:	68 87 40 80 00       	push   $0x804087
  801970:	e8 33 01 00 00       	call   801aa8 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801975:	83 ec 04             	sub    $0x4,%esp
  801978:	8d 55 f0             	lea    -0x10(%ebp),%edx
  80197b:	52                   	push   %edx
  80197c:	6a 00                	push   $0x0
  80197e:	50                   	push   %eax
  80197f:	e8 00 f1 ff ff       	call   800a84 <file_get_block>
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	85 c0                	test   %eax,%eax
  801989:	79 12                	jns    80199d <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  80198b:	50                   	push   %eax
  80198c:	68 ee 41 80 00       	push   $0x8041ee
  801991:	6a 3c                	push   $0x3c
  801993:	68 87 40 80 00       	push   $0x804087
  801998:	e8 0b 01 00 00       	call   801aa8 <_panic>
	strcpy(blk, msg);
  80199d:	83 ec 08             	sub    $0x8,%esp
  8019a0:	68 5c 42 80 00       	push   $0x80425c
  8019a5:	ff 75 f0             	pushl  -0x10(%ebp)
  8019a8:	e8 d8 07 00 00       	call   802185 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8019ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019b0:	c1 e8 0c             	shr    $0xc,%eax
  8019b3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019ba:	83 c4 10             	add    $0x10,%esp
  8019bd:	a8 40                	test   $0x40,%al
  8019bf:	75 16                	jne    8019d7 <fs_test+0x362>
  8019c1:	68 54 41 80 00       	push   $0x804154
  8019c6:	68 9d 3d 80 00       	push   $0x803d9d
  8019cb:	6a 3e                	push   $0x3e
  8019cd:	68 87 40 80 00       	push   $0x804087
  8019d2:	e8 d1 00 00 00       	call   801aa8 <_panic>
	file_flush(f);
  8019d7:	83 ec 0c             	sub    $0xc,%esp
  8019da:	ff 75 f4             	pushl  -0xc(%ebp)
  8019dd:	e8 8c f5 ff ff       	call   800f6e <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8019e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019e5:	c1 e8 0c             	shr    $0xc,%eax
  8019e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019ef:	83 c4 10             	add    $0x10,%esp
  8019f2:	a8 40                	test   $0x40,%al
  8019f4:	74 16                	je     801a0c <fs_test+0x397>
  8019f6:	68 53 41 80 00       	push   $0x804153
  8019fb:	68 9d 3d 80 00       	push   $0x803d9d
  801a00:	6a 40                	push   $0x40
  801a02:	68 87 40 80 00       	push   $0x804087
  801a07:	e8 9c 00 00 00       	call   801aa8 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0f:	c1 e8 0c             	shr    $0xc,%eax
  801a12:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a19:	a8 40                	test   $0x40,%al
  801a1b:	74 16                	je     801a33 <fs_test+0x3be>
  801a1d:	68 a9 41 80 00       	push   $0x8041a9
  801a22:	68 9d 3d 80 00       	push   $0x803d9d
  801a27:	6a 41                	push   $0x41
  801a29:	68 87 40 80 00       	push   $0x804087
  801a2e:	e8 75 00 00 00       	call   801aa8 <_panic>
	cprintf("file rewrite is good\n");
  801a33:	83 ec 0c             	sub    $0xc,%esp
  801a36:	68 03 42 80 00       	push   $0x804203
  801a3b:	e8 41 01 00 00       	call   801b81 <cprintf>
}
  801a40:	83 c4 10             	add    $0x10,%esp
  801a43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a46:	c9                   	leave  
  801a47:	c3                   	ret    

00801a48 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	56                   	push   %esi
  801a4c:	53                   	push   %ebx
  801a4d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a50:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  801a53:	e8 f2 0a 00 00       	call   80254a <sys_getenvid>
  801a58:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a5d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a60:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a65:	a3 10 a0 80 00       	mov    %eax,0x80a010

    // save the name of the program so that panic() can use it
    if (argc > 0)
  801a6a:	85 db                	test   %ebx,%ebx
  801a6c:	7e 07                	jle    801a75 <libmain+0x2d>
        binaryname = argv[0];
  801a6e:	8b 06                	mov    (%esi),%eax
  801a70:	a3 60 90 80 00       	mov    %eax,0x809060

    // call user main routine
    umain(argc, argv);
  801a75:	83 ec 08             	sub    $0x8,%esp
  801a78:	56                   	push   %esi
  801a79:	53                   	push   %ebx
  801a7a:	e8 b5 fb ff ff       	call   801634 <umain>

    // exit gracefully
    exit();
  801a7f:	e8 0a 00 00 00       	call   801a8e <exit>
}
  801a84:	83 c4 10             	add    $0x10,%esp
  801a87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8a:	5b                   	pop    %ebx
  801a8b:	5e                   	pop    %esi
  801a8c:	5d                   	pop    %ebp
  801a8d:	c3                   	ret    

00801a8e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801a8e:	55                   	push   %ebp
  801a8f:	89 e5                	mov    %esp,%ebp
  801a91:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801a94:	e8 67 10 00 00       	call   802b00 <close_all>
	sys_env_destroy(0);
  801a99:	83 ec 0c             	sub    $0xc,%esp
  801a9c:	6a 00                	push   $0x0
  801a9e:	e8 66 0a 00 00       	call   802509 <sys_env_destroy>
}
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	c9                   	leave  
  801aa7:	c3                   	ret    

00801aa8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	56                   	push   %esi
  801aac:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801aad:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ab0:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801ab6:	e8 8f 0a 00 00       	call   80254a <sys_getenvid>
  801abb:	83 ec 0c             	sub    $0xc,%esp
  801abe:	ff 75 0c             	pushl  0xc(%ebp)
  801ac1:	ff 75 08             	pushl  0x8(%ebp)
  801ac4:	56                   	push   %esi
  801ac5:	50                   	push   %eax
  801ac6:	68 b4 42 80 00       	push   $0x8042b4
  801acb:	e8 b1 00 00 00       	call   801b81 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ad0:	83 c4 18             	add    $0x18,%esp
  801ad3:	53                   	push   %ebx
  801ad4:	ff 75 10             	pushl  0x10(%ebp)
  801ad7:	e8 54 00 00 00       	call   801b30 <vcprintf>
	cprintf("\n");
  801adc:	c7 04 24 c2 3e 80 00 	movl   $0x803ec2,(%esp)
  801ae3:	e8 99 00 00 00       	call   801b81 <cprintf>
  801ae8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801aeb:	cc                   	int3   
  801aec:	eb fd                	jmp    801aeb <_panic+0x43>

00801aee <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	53                   	push   %ebx
  801af2:	83 ec 04             	sub    $0x4,%esp
  801af5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801af8:	8b 13                	mov    (%ebx),%edx
  801afa:	8d 42 01             	lea    0x1(%edx),%eax
  801afd:	89 03                	mov    %eax,(%ebx)
  801aff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b02:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801b06:	3d ff 00 00 00       	cmp    $0xff,%eax
  801b0b:	75 1a                	jne    801b27 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801b0d:	83 ec 08             	sub    $0x8,%esp
  801b10:	68 ff 00 00 00       	push   $0xff
  801b15:	8d 43 08             	lea    0x8(%ebx),%eax
  801b18:	50                   	push   %eax
  801b19:	e8 ae 09 00 00       	call   8024cc <sys_cputs>
		b->idx = 0;
  801b1e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b24:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801b27:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801b2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b2e:	c9                   	leave  
  801b2f:	c3                   	ret    

00801b30 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801b39:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b40:	00 00 00 
	b.cnt = 0;
  801b43:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801b4a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801b4d:	ff 75 0c             	pushl  0xc(%ebp)
  801b50:	ff 75 08             	pushl  0x8(%ebp)
  801b53:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801b59:	50                   	push   %eax
  801b5a:	68 ee 1a 80 00       	push   $0x801aee
  801b5f:	e8 1a 01 00 00       	call   801c7e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801b64:	83 c4 08             	add    $0x8,%esp
  801b67:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801b6d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801b73:	50                   	push   %eax
  801b74:	e8 53 09 00 00       	call   8024cc <sys_cputs>

	return b.cnt;
}
  801b79:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801b7f:	c9                   	leave  
  801b80:	c3                   	ret    

00801b81 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b87:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801b8a:	50                   	push   %eax
  801b8b:	ff 75 08             	pushl  0x8(%ebp)
  801b8e:	e8 9d ff ff ff       	call   801b30 <vcprintf>
	va_end(ap);

	return cnt;
}
  801b93:	c9                   	leave  
  801b94:	c3                   	ret    

00801b95 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	57                   	push   %edi
  801b99:	56                   	push   %esi
  801b9a:	53                   	push   %ebx
  801b9b:	83 ec 1c             	sub    $0x1c,%esp
  801b9e:	89 c7                	mov    %eax,%edi
  801ba0:	89 d6                	mov    %edx,%esi
  801ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ba8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801bab:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801bae:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801bb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bb6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801bb9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801bbc:	39 d3                	cmp    %edx,%ebx
  801bbe:	72 05                	jb     801bc5 <printnum+0x30>
  801bc0:	39 45 10             	cmp    %eax,0x10(%ebp)
  801bc3:	77 45                	ja     801c0a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801bc5:	83 ec 0c             	sub    $0xc,%esp
  801bc8:	ff 75 18             	pushl  0x18(%ebp)
  801bcb:	8b 45 14             	mov    0x14(%ebp),%eax
  801bce:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801bd1:	53                   	push   %ebx
  801bd2:	ff 75 10             	pushl  0x10(%ebp)
  801bd5:	83 ec 08             	sub    $0x8,%esp
  801bd8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bdb:	ff 75 e0             	pushl  -0x20(%ebp)
  801bde:	ff 75 dc             	pushl  -0x24(%ebp)
  801be1:	ff 75 d8             	pushl  -0x28(%ebp)
  801be4:	e8 e7 1e 00 00       	call   803ad0 <__udivdi3>
  801be9:	83 c4 18             	add    $0x18,%esp
  801bec:	52                   	push   %edx
  801bed:	50                   	push   %eax
  801bee:	89 f2                	mov    %esi,%edx
  801bf0:	89 f8                	mov    %edi,%eax
  801bf2:	e8 9e ff ff ff       	call   801b95 <printnum>
  801bf7:	83 c4 20             	add    $0x20,%esp
  801bfa:	eb 18                	jmp    801c14 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801bfc:	83 ec 08             	sub    $0x8,%esp
  801bff:	56                   	push   %esi
  801c00:	ff 75 18             	pushl  0x18(%ebp)
  801c03:	ff d7                	call   *%edi
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	eb 03                	jmp    801c0d <printnum+0x78>
  801c0a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801c0d:	83 eb 01             	sub    $0x1,%ebx
  801c10:	85 db                	test   %ebx,%ebx
  801c12:	7f e8                	jg     801bfc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801c14:	83 ec 08             	sub    $0x8,%esp
  801c17:	56                   	push   %esi
  801c18:	83 ec 04             	sub    $0x4,%esp
  801c1b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c1e:	ff 75 e0             	pushl  -0x20(%ebp)
  801c21:	ff 75 dc             	pushl  -0x24(%ebp)
  801c24:	ff 75 d8             	pushl  -0x28(%ebp)
  801c27:	e8 d4 1f 00 00       	call   803c00 <__umoddi3>
  801c2c:	83 c4 14             	add    $0x14,%esp
  801c2f:	0f be 80 d7 42 80 00 	movsbl 0x8042d7(%eax),%eax
  801c36:	50                   	push   %eax
  801c37:	ff d7                	call   *%edi
}
  801c39:	83 c4 10             	add    $0x10,%esp
  801c3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c3f:	5b                   	pop    %ebx
  801c40:	5e                   	pop    %esi
  801c41:	5f                   	pop    %edi
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    

00801c44 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
  801c47:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801c4a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801c4e:	8b 10                	mov    (%eax),%edx
  801c50:	3b 50 04             	cmp    0x4(%eax),%edx
  801c53:	73 0a                	jae    801c5f <sprintputch+0x1b>
		*b->buf++ = ch;
  801c55:	8d 4a 01             	lea    0x1(%edx),%ecx
  801c58:	89 08                	mov    %ecx,(%eax)
  801c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5d:	88 02                	mov    %al,(%edx)
}
  801c5f:	5d                   	pop    %ebp
  801c60:	c3                   	ret    

00801c61 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801c61:	55                   	push   %ebp
  801c62:	89 e5                	mov    %esp,%ebp
  801c64:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801c67:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801c6a:	50                   	push   %eax
  801c6b:	ff 75 10             	pushl  0x10(%ebp)
  801c6e:	ff 75 0c             	pushl  0xc(%ebp)
  801c71:	ff 75 08             	pushl  0x8(%ebp)
  801c74:	e8 05 00 00 00       	call   801c7e <vprintfmt>
	va_end(ap);
}
  801c79:	83 c4 10             	add    $0x10,%esp
  801c7c:	c9                   	leave  
  801c7d:	c3                   	ret    

00801c7e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	83 ec 2c             	sub    $0x2c,%esp
  801c87:	8b 75 08             	mov    0x8(%ebp),%esi
  801c8a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c8d:	8b 7d 10             	mov    0x10(%ebp),%edi
  801c90:	eb 12                	jmp    801ca4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801c92:	85 c0                	test   %eax,%eax
  801c94:	0f 84 42 04 00 00    	je     8020dc <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  801c9a:	83 ec 08             	sub    $0x8,%esp
  801c9d:	53                   	push   %ebx
  801c9e:	50                   	push   %eax
  801c9f:	ff d6                	call   *%esi
  801ca1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801ca4:	83 c7 01             	add    $0x1,%edi
  801ca7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801cab:	83 f8 25             	cmp    $0x25,%eax
  801cae:	75 e2                	jne    801c92 <vprintfmt+0x14>
  801cb0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801cb4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801cbb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801cc2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801cc9:	b9 00 00 00 00       	mov    $0x0,%ecx
  801cce:	eb 07                	jmp    801cd7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cd0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801cd3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cd7:	8d 47 01             	lea    0x1(%edi),%eax
  801cda:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801cdd:	0f b6 07             	movzbl (%edi),%eax
  801ce0:	0f b6 d0             	movzbl %al,%edx
  801ce3:	83 e8 23             	sub    $0x23,%eax
  801ce6:	3c 55                	cmp    $0x55,%al
  801ce8:	0f 87 d3 03 00 00    	ja     8020c1 <vprintfmt+0x443>
  801cee:	0f b6 c0             	movzbl %al,%eax
  801cf1:	ff 24 85 20 44 80 00 	jmp    *0x804420(,%eax,4)
  801cf8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801cfb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801cff:	eb d6                	jmp    801cd7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d01:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d04:	b8 00 00 00 00       	mov    $0x0,%eax
  801d09:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801d0c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801d0f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801d13:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801d16:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801d19:	83 f9 09             	cmp    $0x9,%ecx
  801d1c:	77 3f                	ja     801d5d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801d1e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801d21:	eb e9                	jmp    801d0c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801d23:	8b 45 14             	mov    0x14(%ebp),%eax
  801d26:	8b 00                	mov    (%eax),%eax
  801d28:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801d2b:	8b 45 14             	mov    0x14(%ebp),%eax
  801d2e:	8d 40 04             	lea    0x4(%eax),%eax
  801d31:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d34:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801d37:	eb 2a                	jmp    801d63 <vprintfmt+0xe5>
  801d39:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d3c:	85 c0                	test   %eax,%eax
  801d3e:	ba 00 00 00 00       	mov    $0x0,%edx
  801d43:	0f 49 d0             	cmovns %eax,%edx
  801d46:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d49:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d4c:	eb 89                	jmp    801cd7 <vprintfmt+0x59>
  801d4e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801d51:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801d58:	e9 7a ff ff ff       	jmp    801cd7 <vprintfmt+0x59>
  801d5d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801d60:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801d63:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801d67:	0f 89 6a ff ff ff    	jns    801cd7 <vprintfmt+0x59>
				width = precision, precision = -1;
  801d6d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801d70:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d73:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801d7a:	e9 58 ff ff ff       	jmp    801cd7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801d7f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d82:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801d85:	e9 4d ff ff ff       	jmp    801cd7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801d8a:	8b 45 14             	mov    0x14(%ebp),%eax
  801d8d:	8d 78 04             	lea    0x4(%eax),%edi
  801d90:	83 ec 08             	sub    $0x8,%esp
  801d93:	53                   	push   %ebx
  801d94:	ff 30                	pushl  (%eax)
  801d96:	ff d6                	call   *%esi
			break;
  801d98:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801d9b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d9e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801da1:	e9 fe fe ff ff       	jmp    801ca4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801da6:	8b 45 14             	mov    0x14(%ebp),%eax
  801da9:	8d 78 04             	lea    0x4(%eax),%edi
  801dac:	8b 00                	mov    (%eax),%eax
  801dae:	99                   	cltd   
  801daf:	31 d0                	xor    %edx,%eax
  801db1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801db3:	83 f8 0f             	cmp    $0xf,%eax
  801db6:	7f 0b                	jg     801dc3 <vprintfmt+0x145>
  801db8:	8b 14 85 80 45 80 00 	mov    0x804580(,%eax,4),%edx
  801dbf:	85 d2                	test   %edx,%edx
  801dc1:	75 1b                	jne    801dde <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  801dc3:	50                   	push   %eax
  801dc4:	68 ef 42 80 00       	push   $0x8042ef
  801dc9:	53                   	push   %ebx
  801dca:	56                   	push   %esi
  801dcb:	e8 91 fe ff ff       	call   801c61 <printfmt>
  801dd0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801dd3:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801dd6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801dd9:	e9 c6 fe ff ff       	jmp    801ca4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801dde:	52                   	push   %edx
  801ddf:	68 af 3d 80 00       	push   $0x803daf
  801de4:	53                   	push   %ebx
  801de5:	56                   	push   %esi
  801de6:	e8 76 fe ff ff       	call   801c61 <printfmt>
  801deb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801dee:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801df1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801df4:	e9 ab fe ff ff       	jmp    801ca4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801df9:	8b 45 14             	mov    0x14(%ebp),%eax
  801dfc:	83 c0 04             	add    $0x4,%eax
  801dff:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801e02:	8b 45 14             	mov    0x14(%ebp),%eax
  801e05:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801e07:	85 ff                	test   %edi,%edi
  801e09:	b8 e8 42 80 00       	mov    $0x8042e8,%eax
  801e0e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801e11:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801e15:	0f 8e 94 00 00 00    	jle    801eaf <vprintfmt+0x231>
  801e1b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801e1f:	0f 84 98 00 00 00    	je     801ebd <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  801e25:	83 ec 08             	sub    $0x8,%esp
  801e28:	ff 75 d0             	pushl  -0x30(%ebp)
  801e2b:	57                   	push   %edi
  801e2c:	e8 33 03 00 00       	call   802164 <strnlen>
  801e31:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801e34:	29 c1                	sub    %eax,%ecx
  801e36:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801e39:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801e3c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801e40:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e43:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801e46:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801e48:	eb 0f                	jmp    801e59 <vprintfmt+0x1db>
					putch(padc, putdat);
  801e4a:	83 ec 08             	sub    $0x8,%esp
  801e4d:	53                   	push   %ebx
  801e4e:	ff 75 e0             	pushl  -0x20(%ebp)
  801e51:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801e53:	83 ef 01             	sub    $0x1,%edi
  801e56:	83 c4 10             	add    $0x10,%esp
  801e59:	85 ff                	test   %edi,%edi
  801e5b:	7f ed                	jg     801e4a <vprintfmt+0x1cc>
  801e5d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801e60:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801e63:	85 c9                	test   %ecx,%ecx
  801e65:	b8 00 00 00 00       	mov    $0x0,%eax
  801e6a:	0f 49 c1             	cmovns %ecx,%eax
  801e6d:	29 c1                	sub    %eax,%ecx
  801e6f:	89 75 08             	mov    %esi,0x8(%ebp)
  801e72:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801e75:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801e78:	89 cb                	mov    %ecx,%ebx
  801e7a:	eb 4d                	jmp    801ec9 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801e7c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801e80:	74 1b                	je     801e9d <vprintfmt+0x21f>
  801e82:	0f be c0             	movsbl %al,%eax
  801e85:	83 e8 20             	sub    $0x20,%eax
  801e88:	83 f8 5e             	cmp    $0x5e,%eax
  801e8b:	76 10                	jbe    801e9d <vprintfmt+0x21f>
					putch('?', putdat);
  801e8d:	83 ec 08             	sub    $0x8,%esp
  801e90:	ff 75 0c             	pushl  0xc(%ebp)
  801e93:	6a 3f                	push   $0x3f
  801e95:	ff 55 08             	call   *0x8(%ebp)
  801e98:	83 c4 10             	add    $0x10,%esp
  801e9b:	eb 0d                	jmp    801eaa <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  801e9d:	83 ec 08             	sub    $0x8,%esp
  801ea0:	ff 75 0c             	pushl  0xc(%ebp)
  801ea3:	52                   	push   %edx
  801ea4:	ff 55 08             	call   *0x8(%ebp)
  801ea7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801eaa:	83 eb 01             	sub    $0x1,%ebx
  801ead:	eb 1a                	jmp    801ec9 <vprintfmt+0x24b>
  801eaf:	89 75 08             	mov    %esi,0x8(%ebp)
  801eb2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801eb5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801eb8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801ebb:	eb 0c                	jmp    801ec9 <vprintfmt+0x24b>
  801ebd:	89 75 08             	mov    %esi,0x8(%ebp)
  801ec0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801ec3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ec6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801ec9:	83 c7 01             	add    $0x1,%edi
  801ecc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ed0:	0f be d0             	movsbl %al,%edx
  801ed3:	85 d2                	test   %edx,%edx
  801ed5:	74 23                	je     801efa <vprintfmt+0x27c>
  801ed7:	85 f6                	test   %esi,%esi
  801ed9:	78 a1                	js     801e7c <vprintfmt+0x1fe>
  801edb:	83 ee 01             	sub    $0x1,%esi
  801ede:	79 9c                	jns    801e7c <vprintfmt+0x1fe>
  801ee0:	89 df                	mov    %ebx,%edi
  801ee2:	8b 75 08             	mov    0x8(%ebp),%esi
  801ee5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ee8:	eb 18                	jmp    801f02 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801eea:	83 ec 08             	sub    $0x8,%esp
  801eed:	53                   	push   %ebx
  801eee:	6a 20                	push   $0x20
  801ef0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801ef2:	83 ef 01             	sub    $0x1,%edi
  801ef5:	83 c4 10             	add    $0x10,%esp
  801ef8:	eb 08                	jmp    801f02 <vprintfmt+0x284>
  801efa:	89 df                	mov    %ebx,%edi
  801efc:	8b 75 08             	mov    0x8(%ebp),%esi
  801eff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f02:	85 ff                	test   %edi,%edi
  801f04:	7f e4                	jg     801eea <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801f06:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801f09:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f0c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f0f:	e9 90 fd ff ff       	jmp    801ca4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801f14:	83 f9 01             	cmp    $0x1,%ecx
  801f17:	7e 19                	jle    801f32 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  801f19:	8b 45 14             	mov    0x14(%ebp),%eax
  801f1c:	8b 50 04             	mov    0x4(%eax),%edx
  801f1f:	8b 00                	mov    (%eax),%eax
  801f21:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f24:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801f27:	8b 45 14             	mov    0x14(%ebp),%eax
  801f2a:	8d 40 08             	lea    0x8(%eax),%eax
  801f2d:	89 45 14             	mov    %eax,0x14(%ebp)
  801f30:	eb 38                	jmp    801f6a <vprintfmt+0x2ec>
	else if (lflag)
  801f32:	85 c9                	test   %ecx,%ecx
  801f34:	74 1b                	je     801f51 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  801f36:	8b 45 14             	mov    0x14(%ebp),%eax
  801f39:	8b 00                	mov    (%eax),%eax
  801f3b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f3e:	89 c1                	mov    %eax,%ecx
  801f40:	c1 f9 1f             	sar    $0x1f,%ecx
  801f43:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801f46:	8b 45 14             	mov    0x14(%ebp),%eax
  801f49:	8d 40 04             	lea    0x4(%eax),%eax
  801f4c:	89 45 14             	mov    %eax,0x14(%ebp)
  801f4f:	eb 19                	jmp    801f6a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  801f51:	8b 45 14             	mov    0x14(%ebp),%eax
  801f54:	8b 00                	mov    (%eax),%eax
  801f56:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f59:	89 c1                	mov    %eax,%ecx
  801f5b:	c1 f9 1f             	sar    $0x1f,%ecx
  801f5e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801f61:	8b 45 14             	mov    0x14(%ebp),%eax
  801f64:	8d 40 04             	lea    0x4(%eax),%eax
  801f67:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801f6a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801f6d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801f70:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801f75:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801f79:	0f 89 0e 01 00 00    	jns    80208d <vprintfmt+0x40f>
				putch('-', putdat);
  801f7f:	83 ec 08             	sub    $0x8,%esp
  801f82:	53                   	push   %ebx
  801f83:	6a 2d                	push   $0x2d
  801f85:	ff d6                	call   *%esi
				num = -(long long) num;
  801f87:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801f8a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801f8d:	f7 da                	neg    %edx
  801f8f:	83 d1 00             	adc    $0x0,%ecx
  801f92:	f7 d9                	neg    %ecx
  801f94:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801f97:	b8 0a 00 00 00       	mov    $0xa,%eax
  801f9c:	e9 ec 00 00 00       	jmp    80208d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801fa1:	83 f9 01             	cmp    $0x1,%ecx
  801fa4:	7e 18                	jle    801fbe <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801fa6:	8b 45 14             	mov    0x14(%ebp),%eax
  801fa9:	8b 10                	mov    (%eax),%edx
  801fab:	8b 48 04             	mov    0x4(%eax),%ecx
  801fae:	8d 40 08             	lea    0x8(%eax),%eax
  801fb1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801fb4:	b8 0a 00 00 00       	mov    $0xa,%eax
  801fb9:	e9 cf 00 00 00       	jmp    80208d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801fbe:	85 c9                	test   %ecx,%ecx
  801fc0:	74 1a                	je     801fdc <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  801fc2:	8b 45 14             	mov    0x14(%ebp),%eax
  801fc5:	8b 10                	mov    (%eax),%edx
  801fc7:	b9 00 00 00 00       	mov    $0x0,%ecx
  801fcc:	8d 40 04             	lea    0x4(%eax),%eax
  801fcf:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801fd2:	b8 0a 00 00 00       	mov    $0xa,%eax
  801fd7:	e9 b1 00 00 00       	jmp    80208d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801fdc:	8b 45 14             	mov    0x14(%ebp),%eax
  801fdf:	8b 10                	mov    (%eax),%edx
  801fe1:	b9 00 00 00 00       	mov    $0x0,%ecx
  801fe6:	8d 40 04             	lea    0x4(%eax),%eax
  801fe9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801fec:	b8 0a 00 00 00       	mov    $0xa,%eax
  801ff1:	e9 97 00 00 00       	jmp    80208d <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801ff6:	83 ec 08             	sub    $0x8,%esp
  801ff9:	53                   	push   %ebx
  801ffa:	6a 58                	push   $0x58
  801ffc:	ff d6                	call   *%esi
			putch('X', putdat);
  801ffe:	83 c4 08             	add    $0x8,%esp
  802001:	53                   	push   %ebx
  802002:	6a 58                	push   $0x58
  802004:	ff d6                	call   *%esi
			putch('X', putdat);
  802006:	83 c4 08             	add    $0x8,%esp
  802009:	53                   	push   %ebx
  80200a:	6a 58                	push   $0x58
  80200c:	ff d6                	call   *%esi
			break;
  80200e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802011:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  802014:	e9 8b fc ff ff       	jmp    801ca4 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  802019:	83 ec 08             	sub    $0x8,%esp
  80201c:	53                   	push   %ebx
  80201d:	6a 30                	push   $0x30
  80201f:	ff d6                	call   *%esi
			putch('x', putdat);
  802021:	83 c4 08             	add    $0x8,%esp
  802024:	53                   	push   %ebx
  802025:	6a 78                	push   $0x78
  802027:	ff d6                	call   *%esi
			num = (unsigned long long)
  802029:	8b 45 14             	mov    0x14(%ebp),%eax
  80202c:	8b 10                	mov    (%eax),%edx
  80202e:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  802033:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  802036:	8d 40 04             	lea    0x4(%eax),%eax
  802039:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80203c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  802041:	eb 4a                	jmp    80208d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  802043:	83 f9 01             	cmp    $0x1,%ecx
  802046:	7e 15                	jle    80205d <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  802048:	8b 45 14             	mov    0x14(%ebp),%eax
  80204b:	8b 10                	mov    (%eax),%edx
  80204d:	8b 48 04             	mov    0x4(%eax),%ecx
  802050:	8d 40 08             	lea    0x8(%eax),%eax
  802053:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  802056:	b8 10 00 00 00       	mov    $0x10,%eax
  80205b:	eb 30                	jmp    80208d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80205d:	85 c9                	test   %ecx,%ecx
  80205f:	74 17                	je     802078 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  802061:	8b 45 14             	mov    0x14(%ebp),%eax
  802064:	8b 10                	mov    (%eax),%edx
  802066:	b9 00 00 00 00       	mov    $0x0,%ecx
  80206b:	8d 40 04             	lea    0x4(%eax),%eax
  80206e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  802071:	b8 10 00 00 00       	mov    $0x10,%eax
  802076:	eb 15                	jmp    80208d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  802078:	8b 45 14             	mov    0x14(%ebp),%eax
  80207b:	8b 10                	mov    (%eax),%edx
  80207d:	b9 00 00 00 00       	mov    $0x0,%ecx
  802082:	8d 40 04             	lea    0x4(%eax),%eax
  802085:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  802088:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80208d:	83 ec 0c             	sub    $0xc,%esp
  802090:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  802094:	57                   	push   %edi
  802095:	ff 75 e0             	pushl  -0x20(%ebp)
  802098:	50                   	push   %eax
  802099:	51                   	push   %ecx
  80209a:	52                   	push   %edx
  80209b:	89 da                	mov    %ebx,%edx
  80209d:	89 f0                	mov    %esi,%eax
  80209f:	e8 f1 fa ff ff       	call   801b95 <printnum>
			break;
  8020a4:	83 c4 20             	add    $0x20,%esp
  8020a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8020aa:	e9 f5 fb ff ff       	jmp    801ca4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8020af:	83 ec 08             	sub    $0x8,%esp
  8020b2:	53                   	push   %ebx
  8020b3:	52                   	push   %edx
  8020b4:	ff d6                	call   *%esi
			break;
  8020b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8020b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8020bc:	e9 e3 fb ff ff       	jmp    801ca4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8020c1:	83 ec 08             	sub    $0x8,%esp
  8020c4:	53                   	push   %ebx
  8020c5:	6a 25                	push   $0x25
  8020c7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8020c9:	83 c4 10             	add    $0x10,%esp
  8020cc:	eb 03                	jmp    8020d1 <vprintfmt+0x453>
  8020ce:	83 ef 01             	sub    $0x1,%edi
  8020d1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8020d5:	75 f7                	jne    8020ce <vprintfmt+0x450>
  8020d7:	e9 c8 fb ff ff       	jmp    801ca4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8020dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020df:	5b                   	pop    %ebx
  8020e0:	5e                   	pop    %esi
  8020e1:	5f                   	pop    %edi
  8020e2:	5d                   	pop    %ebp
  8020e3:	c3                   	ret    

008020e4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8020e4:	55                   	push   %ebp
  8020e5:	89 e5                	mov    %esp,%ebp
  8020e7:	83 ec 18             	sub    $0x18,%esp
  8020ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ed:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8020f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020f3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8020f7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8020fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  802101:	85 c0                	test   %eax,%eax
  802103:	74 26                	je     80212b <vsnprintf+0x47>
  802105:	85 d2                	test   %edx,%edx
  802107:	7e 22                	jle    80212b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  802109:	ff 75 14             	pushl  0x14(%ebp)
  80210c:	ff 75 10             	pushl  0x10(%ebp)
  80210f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802112:	50                   	push   %eax
  802113:	68 44 1c 80 00       	push   $0x801c44
  802118:	e8 61 fb ff ff       	call   801c7e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80211d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802120:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  802123:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802126:	83 c4 10             	add    $0x10,%esp
  802129:	eb 05                	jmp    802130 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80212b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  802130:	c9                   	leave  
  802131:	c3                   	ret    

00802132 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  802132:	55                   	push   %ebp
  802133:	89 e5                	mov    %esp,%ebp
  802135:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  802138:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80213b:	50                   	push   %eax
  80213c:	ff 75 10             	pushl  0x10(%ebp)
  80213f:	ff 75 0c             	pushl  0xc(%ebp)
  802142:	ff 75 08             	pushl  0x8(%ebp)
  802145:	e8 9a ff ff ff       	call   8020e4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80214a:	c9                   	leave  
  80214b:	c3                   	ret    

0080214c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80214c:	55                   	push   %ebp
  80214d:	89 e5                	mov    %esp,%ebp
  80214f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  802152:	b8 00 00 00 00       	mov    $0x0,%eax
  802157:	eb 03                	jmp    80215c <strlen+0x10>
		n++;
  802159:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80215c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  802160:	75 f7                	jne    802159 <strlen+0xd>
		n++;
	return n;
}
  802162:	5d                   	pop    %ebp
  802163:	c3                   	ret    

00802164 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  802164:	55                   	push   %ebp
  802165:	89 e5                	mov    %esp,%ebp
  802167:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80216a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80216d:	ba 00 00 00 00       	mov    $0x0,%edx
  802172:	eb 03                	jmp    802177 <strnlen+0x13>
		n++;
  802174:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802177:	39 c2                	cmp    %eax,%edx
  802179:	74 08                	je     802183 <strnlen+0x1f>
  80217b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80217f:	75 f3                	jne    802174 <strnlen+0x10>
  802181:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  802183:	5d                   	pop    %ebp
  802184:	c3                   	ret    

00802185 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802185:	55                   	push   %ebp
  802186:	89 e5                	mov    %esp,%ebp
  802188:	53                   	push   %ebx
  802189:	8b 45 08             	mov    0x8(%ebp),%eax
  80218c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80218f:	89 c2                	mov    %eax,%edx
  802191:	83 c2 01             	add    $0x1,%edx
  802194:	83 c1 01             	add    $0x1,%ecx
  802197:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80219b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80219e:	84 db                	test   %bl,%bl
  8021a0:	75 ef                	jne    802191 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8021a2:	5b                   	pop    %ebx
  8021a3:	5d                   	pop    %ebp
  8021a4:	c3                   	ret    

008021a5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8021a5:	55                   	push   %ebp
  8021a6:	89 e5                	mov    %esp,%ebp
  8021a8:	53                   	push   %ebx
  8021a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8021ac:	53                   	push   %ebx
  8021ad:	e8 9a ff ff ff       	call   80214c <strlen>
  8021b2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8021b5:	ff 75 0c             	pushl  0xc(%ebp)
  8021b8:	01 d8                	add    %ebx,%eax
  8021ba:	50                   	push   %eax
  8021bb:	e8 c5 ff ff ff       	call   802185 <strcpy>
	return dst;
}
  8021c0:	89 d8                	mov    %ebx,%eax
  8021c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021c5:	c9                   	leave  
  8021c6:	c3                   	ret    

008021c7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8021c7:	55                   	push   %ebp
  8021c8:	89 e5                	mov    %esp,%ebp
  8021ca:	56                   	push   %esi
  8021cb:	53                   	push   %ebx
  8021cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8021cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021d2:	89 f3                	mov    %esi,%ebx
  8021d4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8021d7:	89 f2                	mov    %esi,%edx
  8021d9:	eb 0f                	jmp    8021ea <strncpy+0x23>
		*dst++ = *src;
  8021db:	83 c2 01             	add    $0x1,%edx
  8021de:	0f b6 01             	movzbl (%ecx),%eax
  8021e1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8021e4:	80 39 01             	cmpb   $0x1,(%ecx)
  8021e7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8021ea:	39 da                	cmp    %ebx,%edx
  8021ec:	75 ed                	jne    8021db <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8021ee:	89 f0                	mov    %esi,%eax
  8021f0:	5b                   	pop    %ebx
  8021f1:	5e                   	pop    %esi
  8021f2:	5d                   	pop    %ebp
  8021f3:	c3                   	ret    

008021f4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8021f4:	55                   	push   %ebp
  8021f5:	89 e5                	mov    %esp,%ebp
  8021f7:	56                   	push   %esi
  8021f8:	53                   	push   %ebx
  8021f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8021fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021ff:	8b 55 10             	mov    0x10(%ebp),%edx
  802202:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802204:	85 d2                	test   %edx,%edx
  802206:	74 21                	je     802229 <strlcpy+0x35>
  802208:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80220c:	89 f2                	mov    %esi,%edx
  80220e:	eb 09                	jmp    802219 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  802210:	83 c2 01             	add    $0x1,%edx
  802213:	83 c1 01             	add    $0x1,%ecx
  802216:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802219:	39 c2                	cmp    %eax,%edx
  80221b:	74 09                	je     802226 <strlcpy+0x32>
  80221d:	0f b6 19             	movzbl (%ecx),%ebx
  802220:	84 db                	test   %bl,%bl
  802222:	75 ec                	jne    802210 <strlcpy+0x1c>
  802224:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  802226:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  802229:	29 f0                	sub    %esi,%eax
}
  80222b:	5b                   	pop    %ebx
  80222c:	5e                   	pop    %esi
  80222d:	5d                   	pop    %ebp
  80222e:	c3                   	ret    

0080222f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80222f:	55                   	push   %ebp
  802230:	89 e5                	mov    %esp,%ebp
  802232:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802235:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  802238:	eb 06                	jmp    802240 <strcmp+0x11>
		p++, q++;
  80223a:	83 c1 01             	add    $0x1,%ecx
  80223d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  802240:	0f b6 01             	movzbl (%ecx),%eax
  802243:	84 c0                	test   %al,%al
  802245:	74 04                	je     80224b <strcmp+0x1c>
  802247:	3a 02                	cmp    (%edx),%al
  802249:	74 ef                	je     80223a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80224b:	0f b6 c0             	movzbl %al,%eax
  80224e:	0f b6 12             	movzbl (%edx),%edx
  802251:	29 d0                	sub    %edx,%eax
}
  802253:	5d                   	pop    %ebp
  802254:	c3                   	ret    

00802255 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  802255:	55                   	push   %ebp
  802256:	89 e5                	mov    %esp,%ebp
  802258:	53                   	push   %ebx
  802259:	8b 45 08             	mov    0x8(%ebp),%eax
  80225c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80225f:	89 c3                	mov    %eax,%ebx
  802261:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  802264:	eb 06                	jmp    80226c <strncmp+0x17>
		n--, p++, q++;
  802266:	83 c0 01             	add    $0x1,%eax
  802269:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80226c:	39 d8                	cmp    %ebx,%eax
  80226e:	74 15                	je     802285 <strncmp+0x30>
  802270:	0f b6 08             	movzbl (%eax),%ecx
  802273:	84 c9                	test   %cl,%cl
  802275:	74 04                	je     80227b <strncmp+0x26>
  802277:	3a 0a                	cmp    (%edx),%cl
  802279:	74 eb                	je     802266 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80227b:	0f b6 00             	movzbl (%eax),%eax
  80227e:	0f b6 12             	movzbl (%edx),%edx
  802281:	29 d0                	sub    %edx,%eax
  802283:	eb 05                	jmp    80228a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  802285:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80228a:	5b                   	pop    %ebx
  80228b:	5d                   	pop    %ebp
  80228c:	c3                   	ret    

0080228d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80228d:	55                   	push   %ebp
  80228e:	89 e5                	mov    %esp,%ebp
  802290:	8b 45 08             	mov    0x8(%ebp),%eax
  802293:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802297:	eb 07                	jmp    8022a0 <strchr+0x13>
		if (*s == c)
  802299:	38 ca                	cmp    %cl,%dl
  80229b:	74 0f                	je     8022ac <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80229d:	83 c0 01             	add    $0x1,%eax
  8022a0:	0f b6 10             	movzbl (%eax),%edx
  8022a3:	84 d2                	test   %dl,%dl
  8022a5:	75 f2                	jne    802299 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8022a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022ac:	5d                   	pop    %ebp
  8022ad:	c3                   	ret    

008022ae <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8022ae:	55                   	push   %ebp
  8022af:	89 e5                	mov    %esp,%ebp
  8022b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8022b8:	eb 03                	jmp    8022bd <strfind+0xf>
  8022ba:	83 c0 01             	add    $0x1,%eax
  8022bd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8022c0:	38 ca                	cmp    %cl,%dl
  8022c2:	74 04                	je     8022c8 <strfind+0x1a>
  8022c4:	84 d2                	test   %dl,%dl
  8022c6:	75 f2                	jne    8022ba <strfind+0xc>
			break;
	return (char *) s;
}
  8022c8:	5d                   	pop    %ebp
  8022c9:	c3                   	ret    

008022ca <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8022ca:	55                   	push   %ebp
  8022cb:	89 e5                	mov    %esp,%ebp
  8022cd:	57                   	push   %edi
  8022ce:	56                   	push   %esi
  8022cf:	53                   	push   %ebx
  8022d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8022d6:	85 c9                	test   %ecx,%ecx
  8022d8:	74 36                	je     802310 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8022da:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8022e0:	75 28                	jne    80230a <memset+0x40>
  8022e2:	f6 c1 03             	test   $0x3,%cl
  8022e5:	75 23                	jne    80230a <memset+0x40>
		c &= 0xFF;
  8022e7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8022eb:	89 d3                	mov    %edx,%ebx
  8022ed:	c1 e3 08             	shl    $0x8,%ebx
  8022f0:	89 d6                	mov    %edx,%esi
  8022f2:	c1 e6 18             	shl    $0x18,%esi
  8022f5:	89 d0                	mov    %edx,%eax
  8022f7:	c1 e0 10             	shl    $0x10,%eax
  8022fa:	09 f0                	or     %esi,%eax
  8022fc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8022fe:	89 d8                	mov    %ebx,%eax
  802300:	09 d0                	or     %edx,%eax
  802302:	c1 e9 02             	shr    $0x2,%ecx
  802305:	fc                   	cld    
  802306:	f3 ab                	rep stos %eax,%es:(%edi)
  802308:	eb 06                	jmp    802310 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80230a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80230d:	fc                   	cld    
  80230e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802310:	89 f8                	mov    %edi,%eax
  802312:	5b                   	pop    %ebx
  802313:	5e                   	pop    %esi
  802314:	5f                   	pop    %edi
  802315:	5d                   	pop    %ebp
  802316:	c3                   	ret    

00802317 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802317:	55                   	push   %ebp
  802318:	89 e5                	mov    %esp,%ebp
  80231a:	57                   	push   %edi
  80231b:	56                   	push   %esi
  80231c:	8b 45 08             	mov    0x8(%ebp),%eax
  80231f:	8b 75 0c             	mov    0xc(%ebp),%esi
  802322:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802325:	39 c6                	cmp    %eax,%esi
  802327:	73 35                	jae    80235e <memmove+0x47>
  802329:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80232c:	39 d0                	cmp    %edx,%eax
  80232e:	73 2e                	jae    80235e <memmove+0x47>
		s += n;
		d += n;
  802330:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802333:	89 d6                	mov    %edx,%esi
  802335:	09 fe                	or     %edi,%esi
  802337:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80233d:	75 13                	jne    802352 <memmove+0x3b>
  80233f:	f6 c1 03             	test   $0x3,%cl
  802342:	75 0e                	jne    802352 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  802344:	83 ef 04             	sub    $0x4,%edi
  802347:	8d 72 fc             	lea    -0x4(%edx),%esi
  80234a:	c1 e9 02             	shr    $0x2,%ecx
  80234d:	fd                   	std    
  80234e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802350:	eb 09                	jmp    80235b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  802352:	83 ef 01             	sub    $0x1,%edi
  802355:	8d 72 ff             	lea    -0x1(%edx),%esi
  802358:	fd                   	std    
  802359:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80235b:	fc                   	cld    
  80235c:	eb 1d                	jmp    80237b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80235e:	89 f2                	mov    %esi,%edx
  802360:	09 c2                	or     %eax,%edx
  802362:	f6 c2 03             	test   $0x3,%dl
  802365:	75 0f                	jne    802376 <memmove+0x5f>
  802367:	f6 c1 03             	test   $0x3,%cl
  80236a:	75 0a                	jne    802376 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80236c:	c1 e9 02             	shr    $0x2,%ecx
  80236f:	89 c7                	mov    %eax,%edi
  802371:	fc                   	cld    
  802372:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802374:	eb 05                	jmp    80237b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  802376:	89 c7                	mov    %eax,%edi
  802378:	fc                   	cld    
  802379:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80237b:	5e                   	pop    %esi
  80237c:	5f                   	pop    %edi
  80237d:	5d                   	pop    %ebp
  80237e:	c3                   	ret    

0080237f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80237f:	55                   	push   %ebp
  802380:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  802382:	ff 75 10             	pushl  0x10(%ebp)
  802385:	ff 75 0c             	pushl  0xc(%ebp)
  802388:	ff 75 08             	pushl  0x8(%ebp)
  80238b:	e8 87 ff ff ff       	call   802317 <memmove>
}
  802390:	c9                   	leave  
  802391:	c3                   	ret    

00802392 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802392:	55                   	push   %ebp
  802393:	89 e5                	mov    %esp,%ebp
  802395:	56                   	push   %esi
  802396:	53                   	push   %ebx
  802397:	8b 45 08             	mov    0x8(%ebp),%eax
  80239a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80239d:	89 c6                	mov    %eax,%esi
  80239f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8023a2:	eb 1a                	jmp    8023be <memcmp+0x2c>
		if (*s1 != *s2)
  8023a4:	0f b6 08             	movzbl (%eax),%ecx
  8023a7:	0f b6 1a             	movzbl (%edx),%ebx
  8023aa:	38 d9                	cmp    %bl,%cl
  8023ac:	74 0a                	je     8023b8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8023ae:	0f b6 c1             	movzbl %cl,%eax
  8023b1:	0f b6 db             	movzbl %bl,%ebx
  8023b4:	29 d8                	sub    %ebx,%eax
  8023b6:	eb 0f                	jmp    8023c7 <memcmp+0x35>
		s1++, s2++;
  8023b8:	83 c0 01             	add    $0x1,%eax
  8023bb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8023be:	39 f0                	cmp    %esi,%eax
  8023c0:	75 e2                	jne    8023a4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8023c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023c7:	5b                   	pop    %ebx
  8023c8:	5e                   	pop    %esi
  8023c9:	5d                   	pop    %ebp
  8023ca:	c3                   	ret    

008023cb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8023cb:	55                   	push   %ebp
  8023cc:	89 e5                	mov    %esp,%ebp
  8023ce:	53                   	push   %ebx
  8023cf:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8023d2:	89 c1                	mov    %eax,%ecx
  8023d4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8023d7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8023db:	eb 0a                	jmp    8023e7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8023dd:	0f b6 10             	movzbl (%eax),%edx
  8023e0:	39 da                	cmp    %ebx,%edx
  8023e2:	74 07                	je     8023eb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8023e4:	83 c0 01             	add    $0x1,%eax
  8023e7:	39 c8                	cmp    %ecx,%eax
  8023e9:	72 f2                	jb     8023dd <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8023eb:	5b                   	pop    %ebx
  8023ec:	5d                   	pop    %ebp
  8023ed:	c3                   	ret    

008023ee <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8023ee:	55                   	push   %ebp
  8023ef:	89 e5                	mov    %esp,%ebp
  8023f1:	57                   	push   %edi
  8023f2:	56                   	push   %esi
  8023f3:	53                   	push   %ebx
  8023f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8023fa:	eb 03                	jmp    8023ff <strtol+0x11>
		s++;
  8023fc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8023ff:	0f b6 01             	movzbl (%ecx),%eax
  802402:	3c 20                	cmp    $0x20,%al
  802404:	74 f6                	je     8023fc <strtol+0xe>
  802406:	3c 09                	cmp    $0x9,%al
  802408:	74 f2                	je     8023fc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80240a:	3c 2b                	cmp    $0x2b,%al
  80240c:	75 0a                	jne    802418 <strtol+0x2a>
		s++;
  80240e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802411:	bf 00 00 00 00       	mov    $0x0,%edi
  802416:	eb 11                	jmp    802429 <strtol+0x3b>
  802418:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80241d:	3c 2d                	cmp    $0x2d,%al
  80241f:	75 08                	jne    802429 <strtol+0x3b>
		s++, neg = 1;
  802421:	83 c1 01             	add    $0x1,%ecx
  802424:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802429:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80242f:	75 15                	jne    802446 <strtol+0x58>
  802431:	80 39 30             	cmpb   $0x30,(%ecx)
  802434:	75 10                	jne    802446 <strtol+0x58>
  802436:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80243a:	75 7c                	jne    8024b8 <strtol+0xca>
		s += 2, base = 16;
  80243c:	83 c1 02             	add    $0x2,%ecx
  80243f:	bb 10 00 00 00       	mov    $0x10,%ebx
  802444:	eb 16                	jmp    80245c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  802446:	85 db                	test   %ebx,%ebx
  802448:	75 12                	jne    80245c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80244a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80244f:	80 39 30             	cmpb   $0x30,(%ecx)
  802452:	75 08                	jne    80245c <strtol+0x6e>
		s++, base = 8;
  802454:	83 c1 01             	add    $0x1,%ecx
  802457:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80245c:	b8 00 00 00 00       	mov    $0x0,%eax
  802461:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802464:	0f b6 11             	movzbl (%ecx),%edx
  802467:	8d 72 d0             	lea    -0x30(%edx),%esi
  80246a:	89 f3                	mov    %esi,%ebx
  80246c:	80 fb 09             	cmp    $0x9,%bl
  80246f:	77 08                	ja     802479 <strtol+0x8b>
			dig = *s - '0';
  802471:	0f be d2             	movsbl %dl,%edx
  802474:	83 ea 30             	sub    $0x30,%edx
  802477:	eb 22                	jmp    80249b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  802479:	8d 72 9f             	lea    -0x61(%edx),%esi
  80247c:	89 f3                	mov    %esi,%ebx
  80247e:	80 fb 19             	cmp    $0x19,%bl
  802481:	77 08                	ja     80248b <strtol+0x9d>
			dig = *s - 'a' + 10;
  802483:	0f be d2             	movsbl %dl,%edx
  802486:	83 ea 57             	sub    $0x57,%edx
  802489:	eb 10                	jmp    80249b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80248b:	8d 72 bf             	lea    -0x41(%edx),%esi
  80248e:	89 f3                	mov    %esi,%ebx
  802490:	80 fb 19             	cmp    $0x19,%bl
  802493:	77 16                	ja     8024ab <strtol+0xbd>
			dig = *s - 'A' + 10;
  802495:	0f be d2             	movsbl %dl,%edx
  802498:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80249b:	3b 55 10             	cmp    0x10(%ebp),%edx
  80249e:	7d 0b                	jge    8024ab <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8024a0:	83 c1 01             	add    $0x1,%ecx
  8024a3:	0f af 45 10          	imul   0x10(%ebp),%eax
  8024a7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8024a9:	eb b9                	jmp    802464 <strtol+0x76>

	if (endptr)
  8024ab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8024af:	74 0d                	je     8024be <strtol+0xd0>
		*endptr = (char *) s;
  8024b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024b4:	89 0e                	mov    %ecx,(%esi)
  8024b6:	eb 06                	jmp    8024be <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8024b8:	85 db                	test   %ebx,%ebx
  8024ba:	74 98                	je     802454 <strtol+0x66>
  8024bc:	eb 9e                	jmp    80245c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8024be:	89 c2                	mov    %eax,%edx
  8024c0:	f7 da                	neg    %edx
  8024c2:	85 ff                	test   %edi,%edi
  8024c4:	0f 45 c2             	cmovne %edx,%eax
}
  8024c7:	5b                   	pop    %ebx
  8024c8:	5e                   	pop    %esi
  8024c9:	5f                   	pop    %edi
  8024ca:	5d                   	pop    %ebp
  8024cb:	c3                   	ret    

008024cc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8024cc:	55                   	push   %ebp
  8024cd:	89 e5                	mov    %esp,%ebp
  8024cf:	57                   	push   %edi
  8024d0:	56                   	push   %esi
  8024d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8024d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024da:	8b 55 08             	mov    0x8(%ebp),%edx
  8024dd:	89 c3                	mov    %eax,%ebx
  8024df:	89 c7                	mov    %eax,%edi
  8024e1:	89 c6                	mov    %eax,%esi
  8024e3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8024e5:	5b                   	pop    %ebx
  8024e6:	5e                   	pop    %esi
  8024e7:	5f                   	pop    %edi
  8024e8:	5d                   	pop    %ebp
  8024e9:	c3                   	ret    

008024ea <sys_cgetc>:

int
sys_cgetc(void)
{
  8024ea:	55                   	push   %ebp
  8024eb:	89 e5                	mov    %esp,%ebp
  8024ed:	57                   	push   %edi
  8024ee:	56                   	push   %esi
  8024ef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8024f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8024fa:	89 d1                	mov    %edx,%ecx
  8024fc:	89 d3                	mov    %edx,%ebx
  8024fe:	89 d7                	mov    %edx,%edi
  802500:	89 d6                	mov    %edx,%esi
  802502:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802504:	5b                   	pop    %ebx
  802505:	5e                   	pop    %esi
  802506:	5f                   	pop    %edi
  802507:	5d                   	pop    %ebp
  802508:	c3                   	ret    

00802509 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802509:	55                   	push   %ebp
  80250a:	89 e5                	mov    %esp,%ebp
  80250c:	57                   	push   %edi
  80250d:	56                   	push   %esi
  80250e:	53                   	push   %ebx
  80250f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802512:	b9 00 00 00 00       	mov    $0x0,%ecx
  802517:	b8 03 00 00 00       	mov    $0x3,%eax
  80251c:	8b 55 08             	mov    0x8(%ebp),%edx
  80251f:	89 cb                	mov    %ecx,%ebx
  802521:	89 cf                	mov    %ecx,%edi
  802523:	89 ce                	mov    %ecx,%esi
  802525:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802527:	85 c0                	test   %eax,%eax
  802529:	7e 17                	jle    802542 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80252b:	83 ec 0c             	sub    $0xc,%esp
  80252e:	50                   	push   %eax
  80252f:	6a 03                	push   $0x3
  802531:	68 df 45 80 00       	push   $0x8045df
  802536:	6a 23                	push   $0x23
  802538:	68 fc 45 80 00       	push   $0x8045fc
  80253d:	e8 66 f5 ff ff       	call   801aa8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  802542:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802545:	5b                   	pop    %ebx
  802546:	5e                   	pop    %esi
  802547:	5f                   	pop    %edi
  802548:	5d                   	pop    %ebp
  802549:	c3                   	ret    

0080254a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80254a:	55                   	push   %ebp
  80254b:	89 e5                	mov    %esp,%ebp
  80254d:	57                   	push   %edi
  80254e:	56                   	push   %esi
  80254f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802550:	ba 00 00 00 00       	mov    $0x0,%edx
  802555:	b8 02 00 00 00       	mov    $0x2,%eax
  80255a:	89 d1                	mov    %edx,%ecx
  80255c:	89 d3                	mov    %edx,%ebx
  80255e:	89 d7                	mov    %edx,%edi
  802560:	89 d6                	mov    %edx,%esi
  802562:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  802564:	5b                   	pop    %ebx
  802565:	5e                   	pop    %esi
  802566:	5f                   	pop    %edi
  802567:	5d                   	pop    %ebp
  802568:	c3                   	ret    

00802569 <sys_yield>:

void
sys_yield(void)
{
  802569:	55                   	push   %ebp
  80256a:	89 e5                	mov    %esp,%ebp
  80256c:	57                   	push   %edi
  80256d:	56                   	push   %esi
  80256e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80256f:	ba 00 00 00 00       	mov    $0x0,%edx
  802574:	b8 0b 00 00 00       	mov    $0xb,%eax
  802579:	89 d1                	mov    %edx,%ecx
  80257b:	89 d3                	mov    %edx,%ebx
  80257d:	89 d7                	mov    %edx,%edi
  80257f:	89 d6                	mov    %edx,%esi
  802581:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  802583:	5b                   	pop    %ebx
  802584:	5e                   	pop    %esi
  802585:	5f                   	pop    %edi
  802586:	5d                   	pop    %ebp
  802587:	c3                   	ret    

00802588 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802588:	55                   	push   %ebp
  802589:	89 e5                	mov    %esp,%ebp
  80258b:	57                   	push   %edi
  80258c:	56                   	push   %esi
  80258d:	53                   	push   %ebx
  80258e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802591:	be 00 00 00 00       	mov    $0x0,%esi
  802596:	b8 04 00 00 00       	mov    $0x4,%eax
  80259b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80259e:	8b 55 08             	mov    0x8(%ebp),%edx
  8025a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025a4:	89 f7                	mov    %esi,%edi
  8025a6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8025a8:	85 c0                	test   %eax,%eax
  8025aa:	7e 17                	jle    8025c3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025ac:	83 ec 0c             	sub    $0xc,%esp
  8025af:	50                   	push   %eax
  8025b0:	6a 04                	push   $0x4
  8025b2:	68 df 45 80 00       	push   $0x8045df
  8025b7:	6a 23                	push   $0x23
  8025b9:	68 fc 45 80 00       	push   $0x8045fc
  8025be:	e8 e5 f4 ff ff       	call   801aa8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8025c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025c6:	5b                   	pop    %ebx
  8025c7:	5e                   	pop    %esi
  8025c8:	5f                   	pop    %edi
  8025c9:	5d                   	pop    %ebp
  8025ca:	c3                   	ret    

008025cb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8025cb:	55                   	push   %ebp
  8025cc:	89 e5                	mov    %esp,%ebp
  8025ce:	57                   	push   %edi
  8025cf:	56                   	push   %esi
  8025d0:	53                   	push   %ebx
  8025d1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025d4:	b8 05 00 00 00       	mov    $0x5,%eax
  8025d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8025df:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025e2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8025e5:	8b 75 18             	mov    0x18(%ebp),%esi
  8025e8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8025ea:	85 c0                	test   %eax,%eax
  8025ec:	7e 17                	jle    802605 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025ee:	83 ec 0c             	sub    $0xc,%esp
  8025f1:	50                   	push   %eax
  8025f2:	6a 05                	push   $0x5
  8025f4:	68 df 45 80 00       	push   $0x8045df
  8025f9:	6a 23                	push   $0x23
  8025fb:	68 fc 45 80 00       	push   $0x8045fc
  802600:	e8 a3 f4 ff ff       	call   801aa8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802605:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802608:	5b                   	pop    %ebx
  802609:	5e                   	pop    %esi
  80260a:	5f                   	pop    %edi
  80260b:	5d                   	pop    %ebp
  80260c:	c3                   	ret    

0080260d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80260d:	55                   	push   %ebp
  80260e:	89 e5                	mov    %esp,%ebp
  802610:	57                   	push   %edi
  802611:	56                   	push   %esi
  802612:	53                   	push   %ebx
  802613:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802616:	bb 00 00 00 00       	mov    $0x0,%ebx
  80261b:	b8 06 00 00 00       	mov    $0x6,%eax
  802620:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802623:	8b 55 08             	mov    0x8(%ebp),%edx
  802626:	89 df                	mov    %ebx,%edi
  802628:	89 de                	mov    %ebx,%esi
  80262a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80262c:	85 c0                	test   %eax,%eax
  80262e:	7e 17                	jle    802647 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802630:	83 ec 0c             	sub    $0xc,%esp
  802633:	50                   	push   %eax
  802634:	6a 06                	push   $0x6
  802636:	68 df 45 80 00       	push   $0x8045df
  80263b:	6a 23                	push   $0x23
  80263d:	68 fc 45 80 00       	push   $0x8045fc
  802642:	e8 61 f4 ff ff       	call   801aa8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  802647:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80264a:	5b                   	pop    %ebx
  80264b:	5e                   	pop    %esi
  80264c:	5f                   	pop    %edi
  80264d:	5d                   	pop    %ebp
  80264e:	c3                   	ret    

0080264f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80264f:	55                   	push   %ebp
  802650:	89 e5                	mov    %esp,%ebp
  802652:	57                   	push   %edi
  802653:	56                   	push   %esi
  802654:	53                   	push   %ebx
  802655:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802658:	bb 00 00 00 00       	mov    $0x0,%ebx
  80265d:	b8 08 00 00 00       	mov    $0x8,%eax
  802662:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802665:	8b 55 08             	mov    0x8(%ebp),%edx
  802668:	89 df                	mov    %ebx,%edi
  80266a:	89 de                	mov    %ebx,%esi
  80266c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80266e:	85 c0                	test   %eax,%eax
  802670:	7e 17                	jle    802689 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802672:	83 ec 0c             	sub    $0xc,%esp
  802675:	50                   	push   %eax
  802676:	6a 08                	push   $0x8
  802678:	68 df 45 80 00       	push   $0x8045df
  80267d:	6a 23                	push   $0x23
  80267f:	68 fc 45 80 00       	push   $0x8045fc
  802684:	e8 1f f4 ff ff       	call   801aa8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802689:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80268c:	5b                   	pop    %ebx
  80268d:	5e                   	pop    %esi
  80268e:	5f                   	pop    %edi
  80268f:	5d                   	pop    %ebp
  802690:	c3                   	ret    

00802691 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802691:	55                   	push   %ebp
  802692:	89 e5                	mov    %esp,%ebp
  802694:	57                   	push   %edi
  802695:	56                   	push   %esi
  802696:	53                   	push   %ebx
  802697:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80269a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80269f:	b8 09 00 00 00       	mov    $0x9,%eax
  8026a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8026aa:	89 df                	mov    %ebx,%edi
  8026ac:	89 de                	mov    %ebx,%esi
  8026ae:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8026b0:	85 c0                	test   %eax,%eax
  8026b2:	7e 17                	jle    8026cb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026b4:	83 ec 0c             	sub    $0xc,%esp
  8026b7:	50                   	push   %eax
  8026b8:	6a 09                	push   $0x9
  8026ba:	68 df 45 80 00       	push   $0x8045df
  8026bf:	6a 23                	push   $0x23
  8026c1:	68 fc 45 80 00       	push   $0x8045fc
  8026c6:	e8 dd f3 ff ff       	call   801aa8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8026cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026ce:	5b                   	pop    %ebx
  8026cf:	5e                   	pop    %esi
  8026d0:	5f                   	pop    %edi
  8026d1:	5d                   	pop    %ebp
  8026d2:	c3                   	ret    

008026d3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8026d3:	55                   	push   %ebp
  8026d4:	89 e5                	mov    %esp,%ebp
  8026d6:	57                   	push   %edi
  8026d7:	56                   	push   %esi
  8026d8:	53                   	push   %ebx
  8026d9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026e1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8026e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8026ec:	89 df                	mov    %ebx,%edi
  8026ee:	89 de                	mov    %ebx,%esi
  8026f0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8026f2:	85 c0                	test   %eax,%eax
  8026f4:	7e 17                	jle    80270d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026f6:	83 ec 0c             	sub    $0xc,%esp
  8026f9:	50                   	push   %eax
  8026fa:	6a 0a                	push   $0xa
  8026fc:	68 df 45 80 00       	push   $0x8045df
  802701:	6a 23                	push   $0x23
  802703:	68 fc 45 80 00       	push   $0x8045fc
  802708:	e8 9b f3 ff ff       	call   801aa8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80270d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802710:	5b                   	pop    %ebx
  802711:	5e                   	pop    %esi
  802712:	5f                   	pop    %edi
  802713:	5d                   	pop    %ebp
  802714:	c3                   	ret    

00802715 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802715:	55                   	push   %ebp
  802716:	89 e5                	mov    %esp,%ebp
  802718:	57                   	push   %edi
  802719:	56                   	push   %esi
  80271a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80271b:	be 00 00 00 00       	mov    $0x0,%esi
  802720:	b8 0c 00 00 00       	mov    $0xc,%eax
  802725:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802728:	8b 55 08             	mov    0x8(%ebp),%edx
  80272b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80272e:	8b 7d 14             	mov    0x14(%ebp),%edi
  802731:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  802733:	5b                   	pop    %ebx
  802734:	5e                   	pop    %esi
  802735:	5f                   	pop    %edi
  802736:	5d                   	pop    %ebp
  802737:	c3                   	ret    

00802738 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  802738:	55                   	push   %ebp
  802739:	89 e5                	mov    %esp,%ebp
  80273b:	57                   	push   %edi
  80273c:	56                   	push   %esi
  80273d:	53                   	push   %ebx
  80273e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802741:	b9 00 00 00 00       	mov    $0x0,%ecx
  802746:	b8 0d 00 00 00       	mov    $0xd,%eax
  80274b:	8b 55 08             	mov    0x8(%ebp),%edx
  80274e:	89 cb                	mov    %ecx,%ebx
  802750:	89 cf                	mov    %ecx,%edi
  802752:	89 ce                	mov    %ecx,%esi
  802754:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802756:	85 c0                	test   %eax,%eax
  802758:	7e 17                	jle    802771 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80275a:	83 ec 0c             	sub    $0xc,%esp
  80275d:	50                   	push   %eax
  80275e:	6a 0d                	push   $0xd
  802760:	68 df 45 80 00       	push   $0x8045df
  802765:	6a 23                	push   $0x23
  802767:	68 fc 45 80 00       	push   $0x8045fc
  80276c:	e8 37 f3 ff ff       	call   801aa8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802771:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802774:	5b                   	pop    %ebx
  802775:	5e                   	pop    %esi
  802776:	5f                   	pop    %edi
  802777:	5d                   	pop    %ebp
  802778:	c3                   	ret    

00802779 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  802779:	55                   	push   %ebp
  80277a:	89 e5                	mov    %esp,%ebp
  80277c:	57                   	push   %edi
  80277d:	56                   	push   %esi
  80277e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80277f:	ba 00 00 00 00       	mov    $0x0,%edx
  802784:	b8 0e 00 00 00       	mov    $0xe,%eax
  802789:	89 d1                	mov    %edx,%ecx
  80278b:	89 d3                	mov    %edx,%ebx
  80278d:	89 d7                	mov    %edx,%edi
  80278f:	89 d6                	mov    %edx,%esi
  802791:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  802793:	5b                   	pop    %ebx
  802794:	5e                   	pop    %esi
  802795:	5f                   	pop    %edi
  802796:	5d                   	pop    %ebp
  802797:	c3                   	ret    

00802798 <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  802798:	55                   	push   %ebp
  802799:	89 e5                	mov    %esp,%ebp
  80279b:	57                   	push   %edi
  80279c:	56                   	push   %esi
  80279d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80279e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8027a3:	b8 10 00 00 00       	mov    $0x10,%eax
  8027a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8027ab:	89 cb                	mov    %ecx,%ebx
  8027ad:	89 cf                	mov    %ecx,%edi
  8027af:	89 ce                	mov    %ecx,%esi
  8027b1:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  8027b3:	5b                   	pop    %ebx
  8027b4:	5e                   	pop    %esi
  8027b5:	5f                   	pop    %edi
  8027b6:	5d                   	pop    %ebp
  8027b7:	c3                   	ret    

008027b8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8027b8:	55                   	push   %ebp
  8027b9:	89 e5                	mov    %esp,%ebp
  8027bb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8027be:	83 3d 14 a0 80 00 00 	cmpl   $0x0,0x80a014
  8027c5:	75 4a                	jne    802811 <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  8027c7:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8027cc:	8b 40 48             	mov    0x48(%eax),%eax
  8027cf:	83 ec 04             	sub    $0x4,%esp
  8027d2:	6a 07                	push   $0x7
  8027d4:	68 00 f0 bf ee       	push   $0xeebff000
  8027d9:	50                   	push   %eax
  8027da:	e8 a9 fd ff ff       	call   802588 <sys_page_alloc>
  8027df:	83 c4 10             	add    $0x10,%esp
  8027e2:	85 c0                	test   %eax,%eax
  8027e4:	79 12                	jns    8027f8 <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  8027e6:	50                   	push   %eax
  8027e7:	68 0a 46 80 00       	push   $0x80460a
  8027ec:	6a 21                	push   $0x21
  8027ee:	68 22 46 80 00       	push   $0x804622
  8027f3:	e8 b0 f2 ff ff       	call   801aa8 <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8027f8:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8027fd:	8b 40 48             	mov    0x48(%eax),%eax
  802800:	83 ec 08             	sub    $0x8,%esp
  802803:	68 1b 28 80 00       	push   $0x80281b
  802808:	50                   	push   %eax
  802809:	e8 c5 fe ff ff       	call   8026d3 <sys_env_set_pgfault_upcall>
  80280e:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802811:	8b 45 08             	mov    0x8(%ebp),%eax
  802814:	a3 14 a0 80 00       	mov    %eax,0x80a014
  802819:	c9                   	leave  
  80281a:	c3                   	ret    

0080281b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80281b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80281c:	a1 14 a0 80 00       	mov    0x80a014,%eax
	call *%eax
  802821:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802823:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  802826:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  802829:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  80282d:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  802832:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  802836:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  802838:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  802839:	83 c4 04             	add    $0x4,%esp
	popfl
  80283c:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80283d:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  80283e:	c3                   	ret    

0080283f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80283f:	55                   	push   %ebp
  802840:	89 e5                	mov    %esp,%ebp
  802842:	56                   	push   %esi
  802843:	53                   	push   %ebx
  802844:	8b 75 08             	mov    0x8(%ebp),%esi
  802847:	8b 45 0c             	mov    0xc(%ebp),%eax
  80284a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  80284d:	85 c0                	test   %eax,%eax
  80284f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802854:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  802857:	83 ec 0c             	sub    $0xc,%esp
  80285a:	50                   	push   %eax
  80285b:	e8 d8 fe ff ff       	call   802738 <sys_ipc_recv>
  802860:	83 c4 10             	add    $0x10,%esp
  802863:	85 c0                	test   %eax,%eax
  802865:	79 16                	jns    80287d <ipc_recv+0x3e>
        if (from_env_store != NULL)
  802867:	85 f6                	test   %esi,%esi
  802869:	74 06                	je     802871 <ipc_recv+0x32>
            *from_env_store = 0;
  80286b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  802871:	85 db                	test   %ebx,%ebx
  802873:	74 2c                	je     8028a1 <ipc_recv+0x62>
            *perm_store = 0;
  802875:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80287b:	eb 24                	jmp    8028a1 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  80287d:	85 f6                	test   %esi,%esi
  80287f:	74 0a                	je     80288b <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  802881:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802886:	8b 40 74             	mov    0x74(%eax),%eax
  802889:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  80288b:	85 db                	test   %ebx,%ebx
  80288d:	74 0a                	je     802899 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  80288f:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802894:	8b 40 78             	mov    0x78(%eax),%eax
  802897:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  802899:	a1 10 a0 80 00       	mov    0x80a010,%eax
  80289e:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  8028a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8028a4:	5b                   	pop    %ebx
  8028a5:	5e                   	pop    %esi
  8028a6:	5d                   	pop    %ebp
  8028a7:	c3                   	ret    

008028a8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8028a8:	55                   	push   %ebp
  8028a9:	89 e5                	mov    %esp,%ebp
  8028ab:	57                   	push   %edi
  8028ac:	56                   	push   %esi
  8028ad:	53                   	push   %ebx
  8028ae:	83 ec 0c             	sub    $0xc,%esp
  8028b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8028b4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8028b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8028ba:	85 c0                	test   %eax,%eax
  8028bc:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8028c1:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  8028c4:	eb 1c                	jmp    8028e2 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  8028c6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8028c9:	74 12                	je     8028dd <ipc_send+0x35>
  8028cb:	50                   	push   %eax
  8028cc:	68 30 46 80 00       	push   $0x804630
  8028d1:	6a 3b                	push   $0x3b
  8028d3:	68 46 46 80 00       	push   $0x804646
  8028d8:	e8 cb f1 ff ff       	call   801aa8 <_panic>
		sys_yield();
  8028dd:	e8 87 fc ff ff       	call   802569 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  8028e2:	ff 75 14             	pushl  0x14(%ebp)
  8028e5:	53                   	push   %ebx
  8028e6:	56                   	push   %esi
  8028e7:	57                   	push   %edi
  8028e8:	e8 28 fe ff ff       	call   802715 <sys_ipc_try_send>
  8028ed:	83 c4 10             	add    $0x10,%esp
  8028f0:	85 c0                	test   %eax,%eax
  8028f2:	78 d2                	js     8028c6 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  8028f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8028f7:	5b                   	pop    %ebx
  8028f8:	5e                   	pop    %esi
  8028f9:	5f                   	pop    %edi
  8028fa:	5d                   	pop    %ebp
  8028fb:	c3                   	ret    

008028fc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8028fc:	55                   	push   %ebp
  8028fd:	89 e5                	mov    %esp,%ebp
  8028ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802902:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802907:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80290a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802910:	8b 52 50             	mov    0x50(%edx),%edx
  802913:	39 ca                	cmp    %ecx,%edx
  802915:	75 0d                	jne    802924 <ipc_find_env+0x28>
			return envs[i].env_id;
  802917:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80291a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80291f:	8b 40 48             	mov    0x48(%eax),%eax
  802922:	eb 0f                	jmp    802933 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802924:	83 c0 01             	add    $0x1,%eax
  802927:	3d 00 04 00 00       	cmp    $0x400,%eax
  80292c:	75 d9                	jne    802907 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80292e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802933:	5d                   	pop    %ebp
  802934:	c3                   	ret    

00802935 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802935:	55                   	push   %ebp
  802936:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802938:	8b 45 08             	mov    0x8(%ebp),%eax
  80293b:	05 00 00 00 30       	add    $0x30000000,%eax
  802940:	c1 e8 0c             	shr    $0xc,%eax
}
  802943:	5d                   	pop    %ebp
  802944:	c3                   	ret    

00802945 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802945:	55                   	push   %ebp
  802946:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  802948:	8b 45 08             	mov    0x8(%ebp),%eax
  80294b:	05 00 00 00 30       	add    $0x30000000,%eax
  802950:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802955:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80295a:	5d                   	pop    %ebp
  80295b:	c3                   	ret    

0080295c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80295c:	55                   	push   %ebp
  80295d:	89 e5                	mov    %esp,%ebp
  80295f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802962:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802967:	89 c2                	mov    %eax,%edx
  802969:	c1 ea 16             	shr    $0x16,%edx
  80296c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802973:	f6 c2 01             	test   $0x1,%dl
  802976:	74 11                	je     802989 <fd_alloc+0x2d>
  802978:	89 c2                	mov    %eax,%edx
  80297a:	c1 ea 0c             	shr    $0xc,%edx
  80297d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802984:	f6 c2 01             	test   $0x1,%dl
  802987:	75 09                	jne    802992 <fd_alloc+0x36>
			*fd_store = fd;
  802989:	89 01                	mov    %eax,(%ecx)
			return 0;
  80298b:	b8 00 00 00 00       	mov    $0x0,%eax
  802990:	eb 17                	jmp    8029a9 <fd_alloc+0x4d>
  802992:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802997:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80299c:	75 c9                	jne    802967 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80299e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8029a4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8029a9:	5d                   	pop    %ebp
  8029aa:	c3                   	ret    

008029ab <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8029ab:	55                   	push   %ebp
  8029ac:	89 e5                	mov    %esp,%ebp
  8029ae:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8029b1:	83 f8 1f             	cmp    $0x1f,%eax
  8029b4:	77 36                	ja     8029ec <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8029b6:	c1 e0 0c             	shl    $0xc,%eax
  8029b9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8029be:	89 c2                	mov    %eax,%edx
  8029c0:	c1 ea 16             	shr    $0x16,%edx
  8029c3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8029ca:	f6 c2 01             	test   $0x1,%dl
  8029cd:	74 24                	je     8029f3 <fd_lookup+0x48>
  8029cf:	89 c2                	mov    %eax,%edx
  8029d1:	c1 ea 0c             	shr    $0xc,%edx
  8029d4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8029db:	f6 c2 01             	test   $0x1,%dl
  8029de:	74 1a                	je     8029fa <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8029e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8029e3:	89 02                	mov    %eax,(%edx)
	return 0;
  8029e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8029ea:	eb 13                	jmp    8029ff <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8029ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8029f1:	eb 0c                	jmp    8029ff <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8029f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8029f8:	eb 05                	jmp    8029ff <fd_lookup+0x54>
  8029fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8029ff:	5d                   	pop    %ebp
  802a00:	c3                   	ret    

00802a01 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802a01:	55                   	push   %ebp
  802a02:	89 e5                	mov    %esp,%ebp
  802a04:	83 ec 08             	sub    $0x8,%esp
  802a07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802a0a:	ba d0 46 80 00       	mov    $0x8046d0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802a0f:	eb 13                	jmp    802a24 <dev_lookup+0x23>
  802a11:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  802a14:	39 08                	cmp    %ecx,(%eax)
  802a16:	75 0c                	jne    802a24 <dev_lookup+0x23>
			*dev = devtab[i];
  802a18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a1b:	89 01                	mov    %eax,(%ecx)
			return 0;
  802a1d:	b8 00 00 00 00       	mov    $0x0,%eax
  802a22:	eb 2e                	jmp    802a52 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802a24:	8b 02                	mov    (%edx),%eax
  802a26:	85 c0                	test   %eax,%eax
  802a28:	75 e7                	jne    802a11 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802a2a:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802a2f:	8b 40 48             	mov    0x48(%eax),%eax
  802a32:	83 ec 04             	sub    $0x4,%esp
  802a35:	51                   	push   %ecx
  802a36:	50                   	push   %eax
  802a37:	68 50 46 80 00       	push   $0x804650
  802a3c:	e8 40 f1 ff ff       	call   801b81 <cprintf>
	*dev = 0;
  802a41:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a44:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802a4a:	83 c4 10             	add    $0x10,%esp
  802a4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802a52:	c9                   	leave  
  802a53:	c3                   	ret    

00802a54 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802a54:	55                   	push   %ebp
  802a55:	89 e5                	mov    %esp,%ebp
  802a57:	56                   	push   %esi
  802a58:	53                   	push   %ebx
  802a59:	83 ec 10             	sub    $0x10,%esp
  802a5c:	8b 75 08             	mov    0x8(%ebp),%esi
  802a5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802a62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a65:	50                   	push   %eax
  802a66:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802a6c:	c1 e8 0c             	shr    $0xc,%eax
  802a6f:	50                   	push   %eax
  802a70:	e8 36 ff ff ff       	call   8029ab <fd_lookup>
  802a75:	83 c4 08             	add    $0x8,%esp
  802a78:	85 c0                	test   %eax,%eax
  802a7a:	78 05                	js     802a81 <fd_close+0x2d>
	    || fd != fd2)
  802a7c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802a7f:	74 0c                	je     802a8d <fd_close+0x39>
		return (must_exist ? r : 0);
  802a81:	84 db                	test   %bl,%bl
  802a83:	ba 00 00 00 00       	mov    $0x0,%edx
  802a88:	0f 44 c2             	cmove  %edx,%eax
  802a8b:	eb 41                	jmp    802ace <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802a8d:	83 ec 08             	sub    $0x8,%esp
  802a90:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802a93:	50                   	push   %eax
  802a94:	ff 36                	pushl  (%esi)
  802a96:	e8 66 ff ff ff       	call   802a01 <dev_lookup>
  802a9b:	89 c3                	mov    %eax,%ebx
  802a9d:	83 c4 10             	add    $0x10,%esp
  802aa0:	85 c0                	test   %eax,%eax
  802aa2:	78 1a                	js     802abe <fd_close+0x6a>
		if (dev->dev_close)
  802aa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802aa7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  802aaa:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802aaf:	85 c0                	test   %eax,%eax
  802ab1:	74 0b                	je     802abe <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802ab3:	83 ec 0c             	sub    $0xc,%esp
  802ab6:	56                   	push   %esi
  802ab7:	ff d0                	call   *%eax
  802ab9:	89 c3                	mov    %eax,%ebx
  802abb:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802abe:	83 ec 08             	sub    $0x8,%esp
  802ac1:	56                   	push   %esi
  802ac2:	6a 00                	push   $0x0
  802ac4:	e8 44 fb ff ff       	call   80260d <sys_page_unmap>
	return r;
  802ac9:	83 c4 10             	add    $0x10,%esp
  802acc:	89 d8                	mov    %ebx,%eax
}
  802ace:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ad1:	5b                   	pop    %ebx
  802ad2:	5e                   	pop    %esi
  802ad3:	5d                   	pop    %ebp
  802ad4:	c3                   	ret    

00802ad5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802ad5:	55                   	push   %ebp
  802ad6:	89 e5                	mov    %esp,%ebp
  802ad8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802adb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ade:	50                   	push   %eax
  802adf:	ff 75 08             	pushl  0x8(%ebp)
  802ae2:	e8 c4 fe ff ff       	call   8029ab <fd_lookup>
  802ae7:	83 c4 08             	add    $0x8,%esp
  802aea:	85 c0                	test   %eax,%eax
  802aec:	78 10                	js     802afe <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802aee:	83 ec 08             	sub    $0x8,%esp
  802af1:	6a 01                	push   $0x1
  802af3:	ff 75 f4             	pushl  -0xc(%ebp)
  802af6:	e8 59 ff ff ff       	call   802a54 <fd_close>
  802afb:	83 c4 10             	add    $0x10,%esp
}
  802afe:	c9                   	leave  
  802aff:	c3                   	ret    

00802b00 <close_all>:

void
close_all(void)
{
  802b00:	55                   	push   %ebp
  802b01:	89 e5                	mov    %esp,%ebp
  802b03:	53                   	push   %ebx
  802b04:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802b07:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802b0c:	83 ec 0c             	sub    $0xc,%esp
  802b0f:	53                   	push   %ebx
  802b10:	e8 c0 ff ff ff       	call   802ad5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802b15:	83 c3 01             	add    $0x1,%ebx
  802b18:	83 c4 10             	add    $0x10,%esp
  802b1b:	83 fb 20             	cmp    $0x20,%ebx
  802b1e:	75 ec                	jne    802b0c <close_all+0xc>
		close(i);
}
  802b20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b23:	c9                   	leave  
  802b24:	c3                   	ret    

00802b25 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802b25:	55                   	push   %ebp
  802b26:	89 e5                	mov    %esp,%ebp
  802b28:	57                   	push   %edi
  802b29:	56                   	push   %esi
  802b2a:	53                   	push   %ebx
  802b2b:	83 ec 2c             	sub    $0x2c,%esp
  802b2e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802b31:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802b34:	50                   	push   %eax
  802b35:	ff 75 08             	pushl  0x8(%ebp)
  802b38:	e8 6e fe ff ff       	call   8029ab <fd_lookup>
  802b3d:	83 c4 08             	add    $0x8,%esp
  802b40:	85 c0                	test   %eax,%eax
  802b42:	0f 88 c1 00 00 00    	js     802c09 <dup+0xe4>
		return r;
	close(newfdnum);
  802b48:	83 ec 0c             	sub    $0xc,%esp
  802b4b:	56                   	push   %esi
  802b4c:	e8 84 ff ff ff       	call   802ad5 <close>

	newfd = INDEX2FD(newfdnum);
  802b51:	89 f3                	mov    %esi,%ebx
  802b53:	c1 e3 0c             	shl    $0xc,%ebx
  802b56:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802b5c:	83 c4 04             	add    $0x4,%esp
  802b5f:	ff 75 e4             	pushl  -0x1c(%ebp)
  802b62:	e8 de fd ff ff       	call   802945 <fd2data>
  802b67:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802b69:	89 1c 24             	mov    %ebx,(%esp)
  802b6c:	e8 d4 fd ff ff       	call   802945 <fd2data>
  802b71:	83 c4 10             	add    $0x10,%esp
  802b74:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802b77:	89 f8                	mov    %edi,%eax
  802b79:	c1 e8 16             	shr    $0x16,%eax
  802b7c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802b83:	a8 01                	test   $0x1,%al
  802b85:	74 37                	je     802bbe <dup+0x99>
  802b87:	89 f8                	mov    %edi,%eax
  802b89:	c1 e8 0c             	shr    $0xc,%eax
  802b8c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802b93:	f6 c2 01             	test   $0x1,%dl
  802b96:	74 26                	je     802bbe <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802b98:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802b9f:	83 ec 0c             	sub    $0xc,%esp
  802ba2:	25 07 0e 00 00       	and    $0xe07,%eax
  802ba7:	50                   	push   %eax
  802ba8:	ff 75 d4             	pushl  -0x2c(%ebp)
  802bab:	6a 00                	push   $0x0
  802bad:	57                   	push   %edi
  802bae:	6a 00                	push   $0x0
  802bb0:	e8 16 fa ff ff       	call   8025cb <sys_page_map>
  802bb5:	89 c7                	mov    %eax,%edi
  802bb7:	83 c4 20             	add    $0x20,%esp
  802bba:	85 c0                	test   %eax,%eax
  802bbc:	78 2e                	js     802bec <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802bbe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802bc1:	89 d0                	mov    %edx,%eax
  802bc3:	c1 e8 0c             	shr    $0xc,%eax
  802bc6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802bcd:	83 ec 0c             	sub    $0xc,%esp
  802bd0:	25 07 0e 00 00       	and    $0xe07,%eax
  802bd5:	50                   	push   %eax
  802bd6:	53                   	push   %ebx
  802bd7:	6a 00                	push   $0x0
  802bd9:	52                   	push   %edx
  802bda:	6a 00                	push   $0x0
  802bdc:	e8 ea f9 ff ff       	call   8025cb <sys_page_map>
  802be1:	89 c7                	mov    %eax,%edi
  802be3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802be6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802be8:	85 ff                	test   %edi,%edi
  802bea:	79 1d                	jns    802c09 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802bec:	83 ec 08             	sub    $0x8,%esp
  802bef:	53                   	push   %ebx
  802bf0:	6a 00                	push   $0x0
  802bf2:	e8 16 fa ff ff       	call   80260d <sys_page_unmap>
	sys_page_unmap(0, nva);
  802bf7:	83 c4 08             	add    $0x8,%esp
  802bfa:	ff 75 d4             	pushl  -0x2c(%ebp)
  802bfd:	6a 00                	push   $0x0
  802bff:	e8 09 fa ff ff       	call   80260d <sys_page_unmap>
	return r;
  802c04:	83 c4 10             	add    $0x10,%esp
  802c07:	89 f8                	mov    %edi,%eax
}
  802c09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c0c:	5b                   	pop    %ebx
  802c0d:	5e                   	pop    %esi
  802c0e:	5f                   	pop    %edi
  802c0f:	5d                   	pop    %ebp
  802c10:	c3                   	ret    

00802c11 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802c11:	55                   	push   %ebp
  802c12:	89 e5                	mov    %esp,%ebp
  802c14:	53                   	push   %ebx
  802c15:	83 ec 14             	sub    $0x14,%esp
  802c18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c1b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c1e:	50                   	push   %eax
  802c1f:	53                   	push   %ebx
  802c20:	e8 86 fd ff ff       	call   8029ab <fd_lookup>
  802c25:	83 c4 08             	add    $0x8,%esp
  802c28:	89 c2                	mov    %eax,%edx
  802c2a:	85 c0                	test   %eax,%eax
  802c2c:	78 6d                	js     802c9b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c2e:	83 ec 08             	sub    $0x8,%esp
  802c31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c34:	50                   	push   %eax
  802c35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c38:	ff 30                	pushl  (%eax)
  802c3a:	e8 c2 fd ff ff       	call   802a01 <dev_lookup>
  802c3f:	83 c4 10             	add    $0x10,%esp
  802c42:	85 c0                	test   %eax,%eax
  802c44:	78 4c                	js     802c92 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802c46:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802c49:	8b 42 08             	mov    0x8(%edx),%eax
  802c4c:	83 e0 03             	and    $0x3,%eax
  802c4f:	83 f8 01             	cmp    $0x1,%eax
  802c52:	75 21                	jne    802c75 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802c54:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802c59:	8b 40 48             	mov    0x48(%eax),%eax
  802c5c:	83 ec 04             	sub    $0x4,%esp
  802c5f:	53                   	push   %ebx
  802c60:	50                   	push   %eax
  802c61:	68 94 46 80 00       	push   $0x804694
  802c66:	e8 16 ef ff ff       	call   801b81 <cprintf>
		return -E_INVAL;
  802c6b:	83 c4 10             	add    $0x10,%esp
  802c6e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802c73:	eb 26                	jmp    802c9b <read+0x8a>
	}
	if (!dev->dev_read)
  802c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c78:	8b 40 08             	mov    0x8(%eax),%eax
  802c7b:	85 c0                	test   %eax,%eax
  802c7d:	74 17                	je     802c96 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802c7f:	83 ec 04             	sub    $0x4,%esp
  802c82:	ff 75 10             	pushl  0x10(%ebp)
  802c85:	ff 75 0c             	pushl  0xc(%ebp)
  802c88:	52                   	push   %edx
  802c89:	ff d0                	call   *%eax
  802c8b:	89 c2                	mov    %eax,%edx
  802c8d:	83 c4 10             	add    $0x10,%esp
  802c90:	eb 09                	jmp    802c9b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c92:	89 c2                	mov    %eax,%edx
  802c94:	eb 05                	jmp    802c9b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802c96:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802c9b:	89 d0                	mov    %edx,%eax
  802c9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ca0:	c9                   	leave  
  802ca1:	c3                   	ret    

00802ca2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802ca2:	55                   	push   %ebp
  802ca3:	89 e5                	mov    %esp,%ebp
  802ca5:	57                   	push   %edi
  802ca6:	56                   	push   %esi
  802ca7:	53                   	push   %ebx
  802ca8:	83 ec 0c             	sub    $0xc,%esp
  802cab:	8b 7d 08             	mov    0x8(%ebp),%edi
  802cae:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802cb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  802cb6:	eb 21                	jmp    802cd9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802cb8:	83 ec 04             	sub    $0x4,%esp
  802cbb:	89 f0                	mov    %esi,%eax
  802cbd:	29 d8                	sub    %ebx,%eax
  802cbf:	50                   	push   %eax
  802cc0:	89 d8                	mov    %ebx,%eax
  802cc2:	03 45 0c             	add    0xc(%ebp),%eax
  802cc5:	50                   	push   %eax
  802cc6:	57                   	push   %edi
  802cc7:	e8 45 ff ff ff       	call   802c11 <read>
		if (m < 0)
  802ccc:	83 c4 10             	add    $0x10,%esp
  802ccf:	85 c0                	test   %eax,%eax
  802cd1:	78 10                	js     802ce3 <readn+0x41>
			return m;
		if (m == 0)
  802cd3:	85 c0                	test   %eax,%eax
  802cd5:	74 0a                	je     802ce1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802cd7:	01 c3                	add    %eax,%ebx
  802cd9:	39 f3                	cmp    %esi,%ebx
  802cdb:	72 db                	jb     802cb8 <readn+0x16>
  802cdd:	89 d8                	mov    %ebx,%eax
  802cdf:	eb 02                	jmp    802ce3 <readn+0x41>
  802ce1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802ce3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ce6:	5b                   	pop    %ebx
  802ce7:	5e                   	pop    %esi
  802ce8:	5f                   	pop    %edi
  802ce9:	5d                   	pop    %ebp
  802cea:	c3                   	ret    

00802ceb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802ceb:	55                   	push   %ebp
  802cec:	89 e5                	mov    %esp,%ebp
  802cee:	53                   	push   %ebx
  802cef:	83 ec 14             	sub    $0x14,%esp
  802cf2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802cf5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802cf8:	50                   	push   %eax
  802cf9:	53                   	push   %ebx
  802cfa:	e8 ac fc ff ff       	call   8029ab <fd_lookup>
  802cff:	83 c4 08             	add    $0x8,%esp
  802d02:	89 c2                	mov    %eax,%edx
  802d04:	85 c0                	test   %eax,%eax
  802d06:	78 68                	js     802d70 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d08:	83 ec 08             	sub    $0x8,%esp
  802d0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d0e:	50                   	push   %eax
  802d0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d12:	ff 30                	pushl  (%eax)
  802d14:	e8 e8 fc ff ff       	call   802a01 <dev_lookup>
  802d19:	83 c4 10             	add    $0x10,%esp
  802d1c:	85 c0                	test   %eax,%eax
  802d1e:	78 47                	js     802d67 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802d20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d23:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802d27:	75 21                	jne    802d4a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802d29:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802d2e:	8b 40 48             	mov    0x48(%eax),%eax
  802d31:	83 ec 04             	sub    $0x4,%esp
  802d34:	53                   	push   %ebx
  802d35:	50                   	push   %eax
  802d36:	68 b0 46 80 00       	push   $0x8046b0
  802d3b:	e8 41 ee ff ff       	call   801b81 <cprintf>
		return -E_INVAL;
  802d40:	83 c4 10             	add    $0x10,%esp
  802d43:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802d48:	eb 26                	jmp    802d70 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802d4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802d4d:	8b 52 0c             	mov    0xc(%edx),%edx
  802d50:	85 d2                	test   %edx,%edx
  802d52:	74 17                	je     802d6b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802d54:	83 ec 04             	sub    $0x4,%esp
  802d57:	ff 75 10             	pushl  0x10(%ebp)
  802d5a:	ff 75 0c             	pushl  0xc(%ebp)
  802d5d:	50                   	push   %eax
  802d5e:	ff d2                	call   *%edx
  802d60:	89 c2                	mov    %eax,%edx
  802d62:	83 c4 10             	add    $0x10,%esp
  802d65:	eb 09                	jmp    802d70 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d67:	89 c2                	mov    %eax,%edx
  802d69:	eb 05                	jmp    802d70 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802d6b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802d70:	89 d0                	mov    %edx,%eax
  802d72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d75:	c9                   	leave  
  802d76:	c3                   	ret    

00802d77 <seek>:

int
seek(int fdnum, off_t offset)
{
  802d77:	55                   	push   %ebp
  802d78:	89 e5                	mov    %esp,%ebp
  802d7a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802d7d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802d80:	50                   	push   %eax
  802d81:	ff 75 08             	pushl  0x8(%ebp)
  802d84:	e8 22 fc ff ff       	call   8029ab <fd_lookup>
  802d89:	83 c4 08             	add    $0x8,%esp
  802d8c:	85 c0                	test   %eax,%eax
  802d8e:	78 0e                	js     802d9e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802d90:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802d93:	8b 55 0c             	mov    0xc(%ebp),%edx
  802d96:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802d99:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802d9e:	c9                   	leave  
  802d9f:	c3                   	ret    

00802da0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802da0:	55                   	push   %ebp
  802da1:	89 e5                	mov    %esp,%ebp
  802da3:	53                   	push   %ebx
  802da4:	83 ec 14             	sub    $0x14,%esp
  802da7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802daa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802dad:	50                   	push   %eax
  802dae:	53                   	push   %ebx
  802daf:	e8 f7 fb ff ff       	call   8029ab <fd_lookup>
  802db4:	83 c4 08             	add    $0x8,%esp
  802db7:	89 c2                	mov    %eax,%edx
  802db9:	85 c0                	test   %eax,%eax
  802dbb:	78 65                	js     802e22 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802dbd:	83 ec 08             	sub    $0x8,%esp
  802dc0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802dc3:	50                   	push   %eax
  802dc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802dc7:	ff 30                	pushl  (%eax)
  802dc9:	e8 33 fc ff ff       	call   802a01 <dev_lookup>
  802dce:	83 c4 10             	add    $0x10,%esp
  802dd1:	85 c0                	test   %eax,%eax
  802dd3:	78 44                	js     802e19 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802dd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802dd8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802ddc:	75 21                	jne    802dff <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802dde:	a1 10 a0 80 00       	mov    0x80a010,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802de3:	8b 40 48             	mov    0x48(%eax),%eax
  802de6:	83 ec 04             	sub    $0x4,%esp
  802de9:	53                   	push   %ebx
  802dea:	50                   	push   %eax
  802deb:	68 70 46 80 00       	push   $0x804670
  802df0:	e8 8c ed ff ff       	call   801b81 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802df5:	83 c4 10             	add    $0x10,%esp
  802df8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802dfd:	eb 23                	jmp    802e22 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802dff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802e02:	8b 52 18             	mov    0x18(%edx),%edx
  802e05:	85 d2                	test   %edx,%edx
  802e07:	74 14                	je     802e1d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802e09:	83 ec 08             	sub    $0x8,%esp
  802e0c:	ff 75 0c             	pushl  0xc(%ebp)
  802e0f:	50                   	push   %eax
  802e10:	ff d2                	call   *%edx
  802e12:	89 c2                	mov    %eax,%edx
  802e14:	83 c4 10             	add    $0x10,%esp
  802e17:	eb 09                	jmp    802e22 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e19:	89 c2                	mov    %eax,%edx
  802e1b:	eb 05                	jmp    802e22 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802e1d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802e22:	89 d0                	mov    %edx,%eax
  802e24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e27:	c9                   	leave  
  802e28:	c3                   	ret    

00802e29 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802e29:	55                   	push   %ebp
  802e2a:	89 e5                	mov    %esp,%ebp
  802e2c:	53                   	push   %ebx
  802e2d:	83 ec 14             	sub    $0x14,%esp
  802e30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802e33:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802e36:	50                   	push   %eax
  802e37:	ff 75 08             	pushl  0x8(%ebp)
  802e3a:	e8 6c fb ff ff       	call   8029ab <fd_lookup>
  802e3f:	83 c4 08             	add    $0x8,%esp
  802e42:	89 c2                	mov    %eax,%edx
  802e44:	85 c0                	test   %eax,%eax
  802e46:	78 58                	js     802ea0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e48:	83 ec 08             	sub    $0x8,%esp
  802e4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e4e:	50                   	push   %eax
  802e4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e52:	ff 30                	pushl  (%eax)
  802e54:	e8 a8 fb ff ff       	call   802a01 <dev_lookup>
  802e59:	83 c4 10             	add    $0x10,%esp
  802e5c:	85 c0                	test   %eax,%eax
  802e5e:	78 37                	js     802e97 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e63:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802e67:	74 32                	je     802e9b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802e69:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802e6c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802e73:	00 00 00 
	stat->st_isdir = 0;
  802e76:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802e7d:	00 00 00 
	stat->st_dev = dev;
  802e80:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802e86:	83 ec 08             	sub    $0x8,%esp
  802e89:	53                   	push   %ebx
  802e8a:	ff 75 f0             	pushl  -0x10(%ebp)
  802e8d:	ff 50 14             	call   *0x14(%eax)
  802e90:	89 c2                	mov    %eax,%edx
  802e92:	83 c4 10             	add    $0x10,%esp
  802e95:	eb 09                	jmp    802ea0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e97:	89 c2                	mov    %eax,%edx
  802e99:	eb 05                	jmp    802ea0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802e9b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802ea0:	89 d0                	mov    %edx,%eax
  802ea2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ea5:	c9                   	leave  
  802ea6:	c3                   	ret    

00802ea7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802ea7:	55                   	push   %ebp
  802ea8:	89 e5                	mov    %esp,%ebp
  802eaa:	56                   	push   %esi
  802eab:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802eac:	83 ec 08             	sub    $0x8,%esp
  802eaf:	6a 00                	push   $0x0
  802eb1:	ff 75 08             	pushl  0x8(%ebp)
  802eb4:	e8 e3 01 00 00       	call   80309c <open>
  802eb9:	89 c3                	mov    %eax,%ebx
  802ebb:	83 c4 10             	add    $0x10,%esp
  802ebe:	85 c0                	test   %eax,%eax
  802ec0:	78 1b                	js     802edd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802ec2:	83 ec 08             	sub    $0x8,%esp
  802ec5:	ff 75 0c             	pushl  0xc(%ebp)
  802ec8:	50                   	push   %eax
  802ec9:	e8 5b ff ff ff       	call   802e29 <fstat>
  802ece:	89 c6                	mov    %eax,%esi
	close(fd);
  802ed0:	89 1c 24             	mov    %ebx,(%esp)
  802ed3:	e8 fd fb ff ff       	call   802ad5 <close>
	return r;
  802ed8:	83 c4 10             	add    $0x10,%esp
  802edb:	89 f0                	mov    %esi,%eax
}
  802edd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ee0:	5b                   	pop    %ebx
  802ee1:	5e                   	pop    %esi
  802ee2:	5d                   	pop    %ebp
  802ee3:	c3                   	ret    

00802ee4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802ee4:	55                   	push   %ebp
  802ee5:	89 e5                	mov    %esp,%ebp
  802ee7:	56                   	push   %esi
  802ee8:	53                   	push   %ebx
  802ee9:	89 c6                	mov    %eax,%esi
  802eeb:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802eed:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802ef4:	75 12                	jne    802f08 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802ef6:	83 ec 0c             	sub    $0xc,%esp
  802ef9:	6a 01                	push   $0x1
  802efb:	e8 fc f9 ff ff       	call   8028fc <ipc_find_env>
  802f00:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802f05:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802f08:	6a 07                	push   $0x7
  802f0a:	68 00 b0 80 00       	push   $0x80b000
  802f0f:	56                   	push   %esi
  802f10:	ff 35 00 a0 80 00    	pushl  0x80a000
  802f16:	e8 8d f9 ff ff       	call   8028a8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802f1b:	83 c4 0c             	add    $0xc,%esp
  802f1e:	6a 00                	push   $0x0
  802f20:	53                   	push   %ebx
  802f21:	6a 00                	push   $0x0
  802f23:	e8 17 f9 ff ff       	call   80283f <ipc_recv>
}
  802f28:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f2b:	5b                   	pop    %ebx
  802f2c:	5e                   	pop    %esi
  802f2d:	5d                   	pop    %ebp
  802f2e:	c3                   	ret    

00802f2f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802f2f:	55                   	push   %ebp
  802f30:	89 e5                	mov    %esp,%ebp
  802f32:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802f35:	8b 45 08             	mov    0x8(%ebp),%eax
  802f38:	8b 40 0c             	mov    0xc(%eax),%eax
  802f3b:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802f40:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f43:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802f48:	ba 00 00 00 00       	mov    $0x0,%edx
  802f4d:	b8 02 00 00 00       	mov    $0x2,%eax
  802f52:	e8 8d ff ff ff       	call   802ee4 <fsipc>
}
  802f57:	c9                   	leave  
  802f58:	c3                   	ret    

00802f59 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802f59:	55                   	push   %ebp
  802f5a:	89 e5                	mov    %esp,%ebp
  802f5c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802f5f:	8b 45 08             	mov    0x8(%ebp),%eax
  802f62:	8b 40 0c             	mov    0xc(%eax),%eax
  802f65:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802f6a:	ba 00 00 00 00       	mov    $0x0,%edx
  802f6f:	b8 06 00 00 00       	mov    $0x6,%eax
  802f74:	e8 6b ff ff ff       	call   802ee4 <fsipc>
}
  802f79:	c9                   	leave  
  802f7a:	c3                   	ret    

00802f7b <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802f7b:	55                   	push   %ebp
  802f7c:	89 e5                	mov    %esp,%ebp
  802f7e:	53                   	push   %ebx
  802f7f:	83 ec 04             	sub    $0x4,%esp
  802f82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802f85:	8b 45 08             	mov    0x8(%ebp),%eax
  802f88:	8b 40 0c             	mov    0xc(%eax),%eax
  802f8b:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802f90:	ba 00 00 00 00       	mov    $0x0,%edx
  802f95:	b8 05 00 00 00       	mov    $0x5,%eax
  802f9a:	e8 45 ff ff ff       	call   802ee4 <fsipc>
  802f9f:	85 c0                	test   %eax,%eax
  802fa1:	78 2c                	js     802fcf <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802fa3:	83 ec 08             	sub    $0x8,%esp
  802fa6:	68 00 b0 80 00       	push   $0x80b000
  802fab:	53                   	push   %ebx
  802fac:	e8 d4 f1 ff ff       	call   802185 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802fb1:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802fb6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802fbc:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802fc1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802fc7:	83 c4 10             	add    $0x10,%esp
  802fca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802fcf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802fd2:	c9                   	leave  
  802fd3:	c3                   	ret    

00802fd4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802fd4:	55                   	push   %ebp
  802fd5:	89 e5                	mov    %esp,%ebp
  802fd7:	83 ec 0c             	sub    $0xc,%esp
  802fda:	8b 45 10             	mov    0x10(%ebp),%eax
  802fdd:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802fe2:	ba f8 0f 00 00       	mov    $0xff8,%edx
  802fe7:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802fea:	8b 55 08             	mov    0x8(%ebp),%edx
  802fed:	8b 52 0c             	mov    0xc(%edx),%edx
  802ff0:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = n;
  802ff6:	a3 04 b0 80 00       	mov    %eax,0x80b004
	memmove(fsipcbuf.write.req_buf, buf, n);
  802ffb:	50                   	push   %eax
  802ffc:	ff 75 0c             	pushl  0xc(%ebp)
  802fff:	68 08 b0 80 00       	push   $0x80b008
  803004:	e8 0e f3 ff ff       	call   802317 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  803009:	ba 00 00 00 00       	mov    $0x0,%edx
  80300e:	b8 04 00 00 00       	mov    $0x4,%eax
  803013:	e8 cc fe ff ff       	call   802ee4 <fsipc>
	//panic("devfile_write not implemented");
}
  803018:	c9                   	leave  
  803019:	c3                   	ret    

0080301a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80301a:	55                   	push   %ebp
  80301b:	89 e5                	mov    %esp,%ebp
  80301d:	56                   	push   %esi
  80301e:	53                   	push   %ebx
  80301f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  803022:	8b 45 08             	mov    0x8(%ebp),%eax
  803025:	8b 40 0c             	mov    0xc(%eax),%eax
  803028:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  80302d:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  803033:	ba 00 00 00 00       	mov    $0x0,%edx
  803038:	b8 03 00 00 00       	mov    $0x3,%eax
  80303d:	e8 a2 fe ff ff       	call   802ee4 <fsipc>
  803042:	89 c3                	mov    %eax,%ebx
  803044:	85 c0                	test   %eax,%eax
  803046:	78 4b                	js     803093 <devfile_read+0x79>
		return r;
	assert(r <= n);
  803048:	39 c6                	cmp    %eax,%esi
  80304a:	73 16                	jae    803062 <devfile_read+0x48>
  80304c:	68 e4 46 80 00       	push   $0x8046e4
  803051:	68 9d 3d 80 00       	push   $0x803d9d
  803056:	6a 7c                	push   $0x7c
  803058:	68 eb 46 80 00       	push   $0x8046eb
  80305d:	e8 46 ea ff ff       	call   801aa8 <_panic>
	assert(r <= PGSIZE);
  803062:	3d 00 10 00 00       	cmp    $0x1000,%eax
  803067:	7e 16                	jle    80307f <devfile_read+0x65>
  803069:	68 f6 46 80 00       	push   $0x8046f6
  80306e:	68 9d 3d 80 00       	push   $0x803d9d
  803073:	6a 7d                	push   $0x7d
  803075:	68 eb 46 80 00       	push   $0x8046eb
  80307a:	e8 29 ea ff ff       	call   801aa8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80307f:	83 ec 04             	sub    $0x4,%esp
  803082:	50                   	push   %eax
  803083:	68 00 b0 80 00       	push   $0x80b000
  803088:	ff 75 0c             	pushl  0xc(%ebp)
  80308b:	e8 87 f2 ff ff       	call   802317 <memmove>
	return r;
  803090:	83 c4 10             	add    $0x10,%esp
}
  803093:	89 d8                	mov    %ebx,%eax
  803095:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803098:	5b                   	pop    %ebx
  803099:	5e                   	pop    %esi
  80309a:	5d                   	pop    %ebp
  80309b:	c3                   	ret    

0080309c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80309c:	55                   	push   %ebp
  80309d:	89 e5                	mov    %esp,%ebp
  80309f:	53                   	push   %ebx
  8030a0:	83 ec 20             	sub    $0x20,%esp
  8030a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8030a6:	53                   	push   %ebx
  8030a7:	e8 a0 f0 ff ff       	call   80214c <strlen>
  8030ac:	83 c4 10             	add    $0x10,%esp
  8030af:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8030b4:	7f 67                	jg     80311d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8030b6:	83 ec 0c             	sub    $0xc,%esp
  8030b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030bc:	50                   	push   %eax
  8030bd:	e8 9a f8 ff ff       	call   80295c <fd_alloc>
  8030c2:	83 c4 10             	add    $0x10,%esp
		return r;
  8030c5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8030c7:	85 c0                	test   %eax,%eax
  8030c9:	78 57                	js     803122 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8030cb:	83 ec 08             	sub    $0x8,%esp
  8030ce:	53                   	push   %ebx
  8030cf:	68 00 b0 80 00       	push   $0x80b000
  8030d4:	e8 ac f0 ff ff       	call   802185 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8030d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8030dc:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8030e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8030e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8030e9:	e8 f6 fd ff ff       	call   802ee4 <fsipc>
  8030ee:	89 c3                	mov    %eax,%ebx
  8030f0:	83 c4 10             	add    $0x10,%esp
  8030f3:	85 c0                	test   %eax,%eax
  8030f5:	79 14                	jns    80310b <open+0x6f>
		fd_close(fd, 0);
  8030f7:	83 ec 08             	sub    $0x8,%esp
  8030fa:	6a 00                	push   $0x0
  8030fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8030ff:	e8 50 f9 ff ff       	call   802a54 <fd_close>
		return r;
  803104:	83 c4 10             	add    $0x10,%esp
  803107:	89 da                	mov    %ebx,%edx
  803109:	eb 17                	jmp    803122 <open+0x86>
	}

	return fd2num(fd);
  80310b:	83 ec 0c             	sub    $0xc,%esp
  80310e:	ff 75 f4             	pushl  -0xc(%ebp)
  803111:	e8 1f f8 ff ff       	call   802935 <fd2num>
  803116:	89 c2                	mov    %eax,%edx
  803118:	83 c4 10             	add    $0x10,%esp
  80311b:	eb 05                	jmp    803122 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80311d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  803122:	89 d0                	mov    %edx,%eax
  803124:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803127:	c9                   	leave  
  803128:	c3                   	ret    

00803129 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  803129:	55                   	push   %ebp
  80312a:	89 e5                	mov    %esp,%ebp
  80312c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80312f:	ba 00 00 00 00       	mov    $0x0,%edx
  803134:	b8 08 00 00 00       	mov    $0x8,%eax
  803139:	e8 a6 fd ff ff       	call   802ee4 <fsipc>
}
  80313e:	c9                   	leave  
  80313f:	c3                   	ret    

00803140 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803140:	55                   	push   %ebp
  803141:	89 e5                	mov    %esp,%ebp
  803143:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803146:	89 d0                	mov    %edx,%eax
  803148:	c1 e8 16             	shr    $0x16,%eax
  80314b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  803152:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803157:	f6 c1 01             	test   $0x1,%cl
  80315a:	74 1d                	je     803179 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80315c:	c1 ea 0c             	shr    $0xc,%edx
  80315f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  803166:	f6 c2 01             	test   $0x1,%dl
  803169:	74 0e                	je     803179 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80316b:	c1 ea 0c             	shr    $0xc,%edx
  80316e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  803175:	ef 
  803176:	0f b7 c0             	movzwl %ax,%eax
}
  803179:	5d                   	pop    %ebp
  80317a:	c3                   	ret    

0080317b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80317b:	55                   	push   %ebp
  80317c:	89 e5                	mov    %esp,%ebp
  80317e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  803181:	68 02 47 80 00       	push   $0x804702
  803186:	ff 75 0c             	pushl  0xc(%ebp)
  803189:	e8 f7 ef ff ff       	call   802185 <strcpy>
	return 0;
}
  80318e:	b8 00 00 00 00       	mov    $0x0,%eax
  803193:	c9                   	leave  
  803194:	c3                   	ret    

00803195 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  803195:	55                   	push   %ebp
  803196:	89 e5                	mov    %esp,%ebp
  803198:	53                   	push   %ebx
  803199:	83 ec 10             	sub    $0x10,%esp
  80319c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80319f:	53                   	push   %ebx
  8031a0:	e8 9b ff ff ff       	call   803140 <pageref>
  8031a5:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8031a8:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8031ad:	83 f8 01             	cmp    $0x1,%eax
  8031b0:	75 10                	jne    8031c2 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8031b2:	83 ec 0c             	sub    $0xc,%esp
  8031b5:	ff 73 0c             	pushl  0xc(%ebx)
  8031b8:	e8 c0 02 00 00       	call   80347d <nsipc_close>
  8031bd:	89 c2                	mov    %eax,%edx
  8031bf:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8031c2:	89 d0                	mov    %edx,%eax
  8031c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8031c7:	c9                   	leave  
  8031c8:	c3                   	ret    

008031c9 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8031c9:	55                   	push   %ebp
  8031ca:	89 e5                	mov    %esp,%ebp
  8031cc:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8031cf:	6a 00                	push   $0x0
  8031d1:	ff 75 10             	pushl  0x10(%ebp)
  8031d4:	ff 75 0c             	pushl  0xc(%ebp)
  8031d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8031da:	ff 70 0c             	pushl  0xc(%eax)
  8031dd:	e8 78 03 00 00       	call   80355a <nsipc_send>
}
  8031e2:	c9                   	leave  
  8031e3:	c3                   	ret    

008031e4 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8031e4:	55                   	push   %ebp
  8031e5:	89 e5                	mov    %esp,%ebp
  8031e7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8031ea:	6a 00                	push   $0x0
  8031ec:	ff 75 10             	pushl  0x10(%ebp)
  8031ef:	ff 75 0c             	pushl  0xc(%ebp)
  8031f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8031f5:	ff 70 0c             	pushl  0xc(%eax)
  8031f8:	e8 f1 02 00 00       	call   8034ee <nsipc_recv>
}
  8031fd:	c9                   	leave  
  8031fe:	c3                   	ret    

008031ff <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8031ff:	55                   	push   %ebp
  803200:	89 e5                	mov    %esp,%ebp
  803202:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  803205:	8d 55 f4             	lea    -0xc(%ebp),%edx
  803208:	52                   	push   %edx
  803209:	50                   	push   %eax
  80320a:	e8 9c f7 ff ff       	call   8029ab <fd_lookup>
  80320f:	83 c4 10             	add    $0x10,%esp
  803212:	85 c0                	test   %eax,%eax
  803214:	78 17                	js     80322d <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  803216:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803219:	8b 0d 80 90 80 00    	mov    0x809080,%ecx
  80321f:	39 08                	cmp    %ecx,(%eax)
  803221:	75 05                	jne    803228 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  803223:	8b 40 0c             	mov    0xc(%eax),%eax
  803226:	eb 05                	jmp    80322d <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  803228:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80322d:	c9                   	leave  
  80322e:	c3                   	ret    

0080322f <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80322f:	55                   	push   %ebp
  803230:	89 e5                	mov    %esp,%ebp
  803232:	56                   	push   %esi
  803233:	53                   	push   %ebx
  803234:	83 ec 1c             	sub    $0x1c,%esp
  803237:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  803239:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80323c:	50                   	push   %eax
  80323d:	e8 1a f7 ff ff       	call   80295c <fd_alloc>
  803242:	89 c3                	mov    %eax,%ebx
  803244:	83 c4 10             	add    $0x10,%esp
  803247:	85 c0                	test   %eax,%eax
  803249:	78 1b                	js     803266 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80324b:	83 ec 04             	sub    $0x4,%esp
  80324e:	68 07 04 00 00       	push   $0x407
  803253:	ff 75 f4             	pushl  -0xc(%ebp)
  803256:	6a 00                	push   $0x0
  803258:	e8 2b f3 ff ff       	call   802588 <sys_page_alloc>
  80325d:	89 c3                	mov    %eax,%ebx
  80325f:	83 c4 10             	add    $0x10,%esp
  803262:	85 c0                	test   %eax,%eax
  803264:	79 10                	jns    803276 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  803266:	83 ec 0c             	sub    $0xc,%esp
  803269:	56                   	push   %esi
  80326a:	e8 0e 02 00 00       	call   80347d <nsipc_close>
		return r;
  80326f:	83 c4 10             	add    $0x10,%esp
  803272:	89 d8                	mov    %ebx,%eax
  803274:	eb 24                	jmp    80329a <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  803276:	8b 15 80 90 80 00    	mov    0x809080,%edx
  80327c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80327f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  803281:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803284:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80328b:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80328e:	83 ec 0c             	sub    $0xc,%esp
  803291:	50                   	push   %eax
  803292:	e8 9e f6 ff ff       	call   802935 <fd2num>
  803297:	83 c4 10             	add    $0x10,%esp
}
  80329a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80329d:	5b                   	pop    %ebx
  80329e:	5e                   	pop    %esi
  80329f:	5d                   	pop    %ebp
  8032a0:	c3                   	ret    

008032a1 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8032a1:	55                   	push   %ebp
  8032a2:	89 e5                	mov    %esp,%ebp
  8032a4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8032a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8032aa:	e8 50 ff ff ff       	call   8031ff <fd2sockid>
		return r;
  8032af:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8032b1:	85 c0                	test   %eax,%eax
  8032b3:	78 1f                	js     8032d4 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8032b5:	83 ec 04             	sub    $0x4,%esp
  8032b8:	ff 75 10             	pushl  0x10(%ebp)
  8032bb:	ff 75 0c             	pushl  0xc(%ebp)
  8032be:	50                   	push   %eax
  8032bf:	e8 12 01 00 00       	call   8033d6 <nsipc_accept>
  8032c4:	83 c4 10             	add    $0x10,%esp
		return r;
  8032c7:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8032c9:	85 c0                	test   %eax,%eax
  8032cb:	78 07                	js     8032d4 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8032cd:	e8 5d ff ff ff       	call   80322f <alloc_sockfd>
  8032d2:	89 c1                	mov    %eax,%ecx
}
  8032d4:	89 c8                	mov    %ecx,%eax
  8032d6:	c9                   	leave  
  8032d7:	c3                   	ret    

008032d8 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8032d8:	55                   	push   %ebp
  8032d9:	89 e5                	mov    %esp,%ebp
  8032db:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8032de:	8b 45 08             	mov    0x8(%ebp),%eax
  8032e1:	e8 19 ff ff ff       	call   8031ff <fd2sockid>
  8032e6:	85 c0                	test   %eax,%eax
  8032e8:	78 12                	js     8032fc <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8032ea:	83 ec 04             	sub    $0x4,%esp
  8032ed:	ff 75 10             	pushl  0x10(%ebp)
  8032f0:	ff 75 0c             	pushl  0xc(%ebp)
  8032f3:	50                   	push   %eax
  8032f4:	e8 2d 01 00 00       	call   803426 <nsipc_bind>
  8032f9:	83 c4 10             	add    $0x10,%esp
}
  8032fc:	c9                   	leave  
  8032fd:	c3                   	ret    

008032fe <shutdown>:

int
shutdown(int s, int how)
{
  8032fe:	55                   	push   %ebp
  8032ff:	89 e5                	mov    %esp,%ebp
  803301:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803304:	8b 45 08             	mov    0x8(%ebp),%eax
  803307:	e8 f3 fe ff ff       	call   8031ff <fd2sockid>
  80330c:	85 c0                	test   %eax,%eax
  80330e:	78 0f                	js     80331f <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  803310:	83 ec 08             	sub    $0x8,%esp
  803313:	ff 75 0c             	pushl  0xc(%ebp)
  803316:	50                   	push   %eax
  803317:	e8 3f 01 00 00       	call   80345b <nsipc_shutdown>
  80331c:	83 c4 10             	add    $0x10,%esp
}
  80331f:	c9                   	leave  
  803320:	c3                   	ret    

00803321 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  803321:	55                   	push   %ebp
  803322:	89 e5                	mov    %esp,%ebp
  803324:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803327:	8b 45 08             	mov    0x8(%ebp),%eax
  80332a:	e8 d0 fe ff ff       	call   8031ff <fd2sockid>
  80332f:	85 c0                	test   %eax,%eax
  803331:	78 12                	js     803345 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  803333:	83 ec 04             	sub    $0x4,%esp
  803336:	ff 75 10             	pushl  0x10(%ebp)
  803339:	ff 75 0c             	pushl  0xc(%ebp)
  80333c:	50                   	push   %eax
  80333d:	e8 55 01 00 00       	call   803497 <nsipc_connect>
  803342:	83 c4 10             	add    $0x10,%esp
}
  803345:	c9                   	leave  
  803346:	c3                   	ret    

00803347 <listen>:

int
listen(int s, int backlog)
{
  803347:	55                   	push   %ebp
  803348:	89 e5                	mov    %esp,%ebp
  80334a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80334d:	8b 45 08             	mov    0x8(%ebp),%eax
  803350:	e8 aa fe ff ff       	call   8031ff <fd2sockid>
  803355:	85 c0                	test   %eax,%eax
  803357:	78 0f                	js     803368 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  803359:	83 ec 08             	sub    $0x8,%esp
  80335c:	ff 75 0c             	pushl  0xc(%ebp)
  80335f:	50                   	push   %eax
  803360:	e8 67 01 00 00       	call   8034cc <nsipc_listen>
  803365:	83 c4 10             	add    $0x10,%esp
}
  803368:	c9                   	leave  
  803369:	c3                   	ret    

0080336a <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80336a:	55                   	push   %ebp
  80336b:	89 e5                	mov    %esp,%ebp
  80336d:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  803370:	ff 75 10             	pushl  0x10(%ebp)
  803373:	ff 75 0c             	pushl  0xc(%ebp)
  803376:	ff 75 08             	pushl  0x8(%ebp)
  803379:	e8 3a 02 00 00       	call   8035b8 <nsipc_socket>
  80337e:	83 c4 10             	add    $0x10,%esp
  803381:	85 c0                	test   %eax,%eax
  803383:	78 05                	js     80338a <socket+0x20>
		return r;
	return alloc_sockfd(r);
  803385:	e8 a5 fe ff ff       	call   80322f <alloc_sockfd>
}
  80338a:	c9                   	leave  
  80338b:	c3                   	ret    

0080338c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80338c:	55                   	push   %ebp
  80338d:	89 e5                	mov    %esp,%ebp
  80338f:	53                   	push   %ebx
  803390:	83 ec 04             	sub    $0x4,%esp
  803393:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  803395:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  80339c:	75 12                	jne    8033b0 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80339e:	83 ec 0c             	sub    $0xc,%esp
  8033a1:	6a 02                	push   $0x2
  8033a3:	e8 54 f5 ff ff       	call   8028fc <ipc_find_env>
  8033a8:	a3 04 a0 80 00       	mov    %eax,0x80a004
  8033ad:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8033b0:	6a 07                	push   $0x7
  8033b2:	68 00 c0 80 00       	push   $0x80c000
  8033b7:	53                   	push   %ebx
  8033b8:	ff 35 04 a0 80 00    	pushl  0x80a004
  8033be:	e8 e5 f4 ff ff       	call   8028a8 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8033c3:	83 c4 0c             	add    $0xc,%esp
  8033c6:	6a 00                	push   $0x0
  8033c8:	6a 00                	push   $0x0
  8033ca:	6a 00                	push   $0x0
  8033cc:	e8 6e f4 ff ff       	call   80283f <ipc_recv>
}
  8033d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8033d4:	c9                   	leave  
  8033d5:	c3                   	ret    

008033d6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8033d6:	55                   	push   %ebp
  8033d7:	89 e5                	mov    %esp,%ebp
  8033d9:	56                   	push   %esi
  8033da:	53                   	push   %ebx
  8033db:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8033de:	8b 45 08             	mov    0x8(%ebp),%eax
  8033e1:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8033e6:	8b 06                	mov    (%esi),%eax
  8033e8:	a3 04 c0 80 00       	mov    %eax,0x80c004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8033ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8033f2:	e8 95 ff ff ff       	call   80338c <nsipc>
  8033f7:	89 c3                	mov    %eax,%ebx
  8033f9:	85 c0                	test   %eax,%eax
  8033fb:	78 20                	js     80341d <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8033fd:	83 ec 04             	sub    $0x4,%esp
  803400:	ff 35 10 c0 80 00    	pushl  0x80c010
  803406:	68 00 c0 80 00       	push   $0x80c000
  80340b:	ff 75 0c             	pushl  0xc(%ebp)
  80340e:	e8 04 ef ff ff       	call   802317 <memmove>
		*addrlen = ret->ret_addrlen;
  803413:	a1 10 c0 80 00       	mov    0x80c010,%eax
  803418:	89 06                	mov    %eax,(%esi)
  80341a:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80341d:	89 d8                	mov    %ebx,%eax
  80341f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803422:	5b                   	pop    %ebx
  803423:	5e                   	pop    %esi
  803424:	5d                   	pop    %ebp
  803425:	c3                   	ret    

00803426 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  803426:	55                   	push   %ebp
  803427:	89 e5                	mov    %esp,%ebp
  803429:	53                   	push   %ebx
  80342a:	83 ec 08             	sub    $0x8,%esp
  80342d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  803430:	8b 45 08             	mov    0x8(%ebp),%eax
  803433:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  803438:	53                   	push   %ebx
  803439:	ff 75 0c             	pushl  0xc(%ebp)
  80343c:	68 04 c0 80 00       	push   $0x80c004
  803441:	e8 d1 ee ff ff       	call   802317 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  803446:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_BIND);
  80344c:	b8 02 00 00 00       	mov    $0x2,%eax
  803451:	e8 36 ff ff ff       	call   80338c <nsipc>
}
  803456:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803459:	c9                   	leave  
  80345a:	c3                   	ret    

0080345b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80345b:	55                   	push   %ebp
  80345c:	89 e5                	mov    %esp,%ebp
  80345e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  803461:	8b 45 08             	mov    0x8(%ebp),%eax
  803464:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.shutdown.req_how = how;
  803469:	8b 45 0c             	mov    0xc(%ebp),%eax
  80346c:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_SHUTDOWN);
  803471:	b8 03 00 00 00       	mov    $0x3,%eax
  803476:	e8 11 ff ff ff       	call   80338c <nsipc>
}
  80347b:	c9                   	leave  
  80347c:	c3                   	ret    

0080347d <nsipc_close>:

int
nsipc_close(int s)
{
  80347d:	55                   	push   %ebp
  80347e:	89 e5                	mov    %esp,%ebp
  803480:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  803483:	8b 45 08             	mov    0x8(%ebp),%eax
  803486:	a3 00 c0 80 00       	mov    %eax,0x80c000
	return nsipc(NSREQ_CLOSE);
  80348b:	b8 04 00 00 00       	mov    $0x4,%eax
  803490:	e8 f7 fe ff ff       	call   80338c <nsipc>
}
  803495:	c9                   	leave  
  803496:	c3                   	ret    

00803497 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  803497:	55                   	push   %ebp
  803498:	89 e5                	mov    %esp,%ebp
  80349a:	53                   	push   %ebx
  80349b:	83 ec 08             	sub    $0x8,%esp
  80349e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8034a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8034a4:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8034a9:	53                   	push   %ebx
  8034aa:	ff 75 0c             	pushl  0xc(%ebp)
  8034ad:	68 04 c0 80 00       	push   $0x80c004
  8034b2:	e8 60 ee ff ff       	call   802317 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8034b7:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_CONNECT);
  8034bd:	b8 05 00 00 00       	mov    $0x5,%eax
  8034c2:	e8 c5 fe ff ff       	call   80338c <nsipc>
}
  8034c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8034ca:	c9                   	leave  
  8034cb:	c3                   	ret    

008034cc <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8034cc:	55                   	push   %ebp
  8034cd:	89 e5                	mov    %esp,%ebp
  8034cf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8034d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8034d5:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.listen.req_backlog = backlog;
  8034da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8034dd:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_LISTEN);
  8034e2:	b8 06 00 00 00       	mov    $0x6,%eax
  8034e7:	e8 a0 fe ff ff       	call   80338c <nsipc>
}
  8034ec:	c9                   	leave  
  8034ed:	c3                   	ret    

008034ee <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8034ee:	55                   	push   %ebp
  8034ef:	89 e5                	mov    %esp,%ebp
  8034f1:	56                   	push   %esi
  8034f2:	53                   	push   %ebx
  8034f3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8034f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8034f9:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.recv.req_len = len;
  8034fe:	89 35 04 c0 80 00    	mov    %esi,0x80c004
	nsipcbuf.recv.req_flags = flags;
  803504:	8b 45 14             	mov    0x14(%ebp),%eax
  803507:	a3 08 c0 80 00       	mov    %eax,0x80c008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80350c:	b8 07 00 00 00       	mov    $0x7,%eax
  803511:	e8 76 fe ff ff       	call   80338c <nsipc>
  803516:	89 c3                	mov    %eax,%ebx
  803518:	85 c0                	test   %eax,%eax
  80351a:	78 35                	js     803551 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80351c:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  803521:	7f 04                	jg     803527 <nsipc_recv+0x39>
  803523:	39 c6                	cmp    %eax,%esi
  803525:	7d 16                	jge    80353d <nsipc_recv+0x4f>
  803527:	68 0e 47 80 00       	push   $0x80470e
  80352c:	68 9d 3d 80 00       	push   $0x803d9d
  803531:	6a 62                	push   $0x62
  803533:	68 23 47 80 00       	push   $0x804723
  803538:	e8 6b e5 ff ff       	call   801aa8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80353d:	83 ec 04             	sub    $0x4,%esp
  803540:	50                   	push   %eax
  803541:	68 00 c0 80 00       	push   $0x80c000
  803546:	ff 75 0c             	pushl  0xc(%ebp)
  803549:	e8 c9 ed ff ff       	call   802317 <memmove>
  80354e:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  803551:	89 d8                	mov    %ebx,%eax
  803553:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803556:	5b                   	pop    %ebx
  803557:	5e                   	pop    %esi
  803558:	5d                   	pop    %ebp
  803559:	c3                   	ret    

0080355a <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80355a:	55                   	push   %ebp
  80355b:	89 e5                	mov    %esp,%ebp
  80355d:	53                   	push   %ebx
  80355e:	83 ec 04             	sub    $0x4,%esp
  803561:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  803564:	8b 45 08             	mov    0x8(%ebp),%eax
  803567:	a3 00 c0 80 00       	mov    %eax,0x80c000
	assert(size < 1600);
  80356c:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  803572:	7e 16                	jle    80358a <nsipc_send+0x30>
  803574:	68 2f 47 80 00       	push   $0x80472f
  803579:	68 9d 3d 80 00       	push   $0x803d9d
  80357e:	6a 6d                	push   $0x6d
  803580:	68 23 47 80 00       	push   $0x804723
  803585:	e8 1e e5 ff ff       	call   801aa8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80358a:	83 ec 04             	sub    $0x4,%esp
  80358d:	53                   	push   %ebx
  80358e:	ff 75 0c             	pushl  0xc(%ebp)
  803591:	68 0c c0 80 00       	push   $0x80c00c
  803596:	e8 7c ed ff ff       	call   802317 <memmove>
	nsipcbuf.send.req_size = size;
  80359b:	89 1d 04 c0 80 00    	mov    %ebx,0x80c004
	nsipcbuf.send.req_flags = flags;
  8035a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8035a4:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SEND);
  8035a9:	b8 08 00 00 00       	mov    $0x8,%eax
  8035ae:	e8 d9 fd ff ff       	call   80338c <nsipc>
}
  8035b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8035b6:	c9                   	leave  
  8035b7:	c3                   	ret    

008035b8 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8035b8:	55                   	push   %ebp
  8035b9:	89 e5                	mov    %esp,%ebp
  8035bb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8035be:	8b 45 08             	mov    0x8(%ebp),%eax
  8035c1:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.socket.req_type = type;
  8035c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8035c9:	a3 04 c0 80 00       	mov    %eax,0x80c004
	nsipcbuf.socket.req_protocol = protocol;
  8035ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8035d1:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SOCKET);
  8035d6:	b8 09 00 00 00       	mov    $0x9,%eax
  8035db:	e8 ac fd ff ff       	call   80338c <nsipc>
}
  8035e0:	c9                   	leave  
  8035e1:	c3                   	ret    

008035e2 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8035e2:	55                   	push   %ebp
  8035e3:	89 e5                	mov    %esp,%ebp
  8035e5:	56                   	push   %esi
  8035e6:	53                   	push   %ebx
  8035e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8035ea:	83 ec 0c             	sub    $0xc,%esp
  8035ed:	ff 75 08             	pushl  0x8(%ebp)
  8035f0:	e8 50 f3 ff ff       	call   802945 <fd2data>
  8035f5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8035f7:	83 c4 08             	add    $0x8,%esp
  8035fa:	68 3b 47 80 00       	push   $0x80473b
  8035ff:	53                   	push   %ebx
  803600:	e8 80 eb ff ff       	call   802185 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803605:	8b 46 04             	mov    0x4(%esi),%eax
  803608:	2b 06                	sub    (%esi),%eax
  80360a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  803610:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803617:	00 00 00 
	stat->st_dev = &devpipe;
  80361a:	c7 83 88 00 00 00 9c 	movl   $0x80909c,0x88(%ebx)
  803621:	90 80 00 
	return 0;
}
  803624:	b8 00 00 00 00       	mov    $0x0,%eax
  803629:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80362c:	5b                   	pop    %ebx
  80362d:	5e                   	pop    %esi
  80362e:	5d                   	pop    %ebp
  80362f:	c3                   	ret    

00803630 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  803630:	55                   	push   %ebp
  803631:	89 e5                	mov    %esp,%ebp
  803633:	53                   	push   %ebx
  803634:	83 ec 0c             	sub    $0xc,%esp
  803637:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80363a:	53                   	push   %ebx
  80363b:	6a 00                	push   $0x0
  80363d:	e8 cb ef ff ff       	call   80260d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  803642:	89 1c 24             	mov    %ebx,(%esp)
  803645:	e8 fb f2 ff ff       	call   802945 <fd2data>
  80364a:	83 c4 08             	add    $0x8,%esp
  80364d:	50                   	push   %eax
  80364e:	6a 00                	push   $0x0
  803650:	e8 b8 ef ff ff       	call   80260d <sys_page_unmap>
}
  803655:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803658:	c9                   	leave  
  803659:	c3                   	ret    

0080365a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80365a:	55                   	push   %ebp
  80365b:	89 e5                	mov    %esp,%ebp
  80365d:	57                   	push   %edi
  80365e:	56                   	push   %esi
  80365f:	53                   	push   %ebx
  803660:	83 ec 1c             	sub    $0x1c,%esp
  803663:	89 45 e0             	mov    %eax,-0x20(%ebp)
  803666:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  803668:	a1 10 a0 80 00       	mov    0x80a010,%eax
  80366d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  803670:	83 ec 0c             	sub    $0xc,%esp
  803673:	ff 75 e0             	pushl  -0x20(%ebp)
  803676:	e8 c5 fa ff ff       	call   803140 <pageref>
  80367b:	89 c3                	mov    %eax,%ebx
  80367d:	89 3c 24             	mov    %edi,(%esp)
  803680:	e8 bb fa ff ff       	call   803140 <pageref>
  803685:	83 c4 10             	add    $0x10,%esp
  803688:	39 c3                	cmp    %eax,%ebx
  80368a:	0f 94 c1             	sete   %cl
  80368d:	0f b6 c9             	movzbl %cl,%ecx
  803690:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  803693:	8b 15 10 a0 80 00    	mov    0x80a010,%edx
  803699:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80369c:	39 ce                	cmp    %ecx,%esi
  80369e:	74 1b                	je     8036bb <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8036a0:	39 c3                	cmp    %eax,%ebx
  8036a2:	75 c4                	jne    803668 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8036a4:	8b 42 58             	mov    0x58(%edx),%eax
  8036a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8036aa:	50                   	push   %eax
  8036ab:	56                   	push   %esi
  8036ac:	68 42 47 80 00       	push   $0x804742
  8036b1:	e8 cb e4 ff ff       	call   801b81 <cprintf>
  8036b6:	83 c4 10             	add    $0x10,%esp
  8036b9:	eb ad                	jmp    803668 <_pipeisclosed+0xe>
	}
}
  8036bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8036be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8036c1:	5b                   	pop    %ebx
  8036c2:	5e                   	pop    %esi
  8036c3:	5f                   	pop    %edi
  8036c4:	5d                   	pop    %ebp
  8036c5:	c3                   	ret    

008036c6 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8036c6:	55                   	push   %ebp
  8036c7:	89 e5                	mov    %esp,%ebp
  8036c9:	57                   	push   %edi
  8036ca:	56                   	push   %esi
  8036cb:	53                   	push   %ebx
  8036cc:	83 ec 28             	sub    $0x28,%esp
  8036cf:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8036d2:	56                   	push   %esi
  8036d3:	e8 6d f2 ff ff       	call   802945 <fd2data>
  8036d8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8036da:	83 c4 10             	add    $0x10,%esp
  8036dd:	bf 00 00 00 00       	mov    $0x0,%edi
  8036e2:	eb 4b                	jmp    80372f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8036e4:	89 da                	mov    %ebx,%edx
  8036e6:	89 f0                	mov    %esi,%eax
  8036e8:	e8 6d ff ff ff       	call   80365a <_pipeisclosed>
  8036ed:	85 c0                	test   %eax,%eax
  8036ef:	75 48                	jne    803739 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8036f1:	e8 73 ee ff ff       	call   802569 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8036f6:	8b 43 04             	mov    0x4(%ebx),%eax
  8036f9:	8b 0b                	mov    (%ebx),%ecx
  8036fb:	8d 51 20             	lea    0x20(%ecx),%edx
  8036fe:	39 d0                	cmp    %edx,%eax
  803700:	73 e2                	jae    8036e4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803702:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803705:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803709:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80370c:	89 c2                	mov    %eax,%edx
  80370e:	c1 fa 1f             	sar    $0x1f,%edx
  803711:	89 d1                	mov    %edx,%ecx
  803713:	c1 e9 1b             	shr    $0x1b,%ecx
  803716:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803719:	83 e2 1f             	and    $0x1f,%edx
  80371c:	29 ca                	sub    %ecx,%edx
  80371e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  803722:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803726:	83 c0 01             	add    $0x1,%eax
  803729:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80372c:	83 c7 01             	add    $0x1,%edi
  80372f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803732:	75 c2                	jne    8036f6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803734:	8b 45 10             	mov    0x10(%ebp),%eax
  803737:	eb 05                	jmp    80373e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803739:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80373e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803741:	5b                   	pop    %ebx
  803742:	5e                   	pop    %esi
  803743:	5f                   	pop    %edi
  803744:	5d                   	pop    %ebp
  803745:	c3                   	ret    

00803746 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803746:	55                   	push   %ebp
  803747:	89 e5                	mov    %esp,%ebp
  803749:	57                   	push   %edi
  80374a:	56                   	push   %esi
  80374b:	53                   	push   %ebx
  80374c:	83 ec 18             	sub    $0x18,%esp
  80374f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  803752:	57                   	push   %edi
  803753:	e8 ed f1 ff ff       	call   802945 <fd2data>
  803758:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80375a:	83 c4 10             	add    $0x10,%esp
  80375d:	bb 00 00 00 00       	mov    $0x0,%ebx
  803762:	eb 3d                	jmp    8037a1 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  803764:	85 db                	test   %ebx,%ebx
  803766:	74 04                	je     80376c <devpipe_read+0x26>
				return i;
  803768:	89 d8                	mov    %ebx,%eax
  80376a:	eb 44                	jmp    8037b0 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80376c:	89 f2                	mov    %esi,%edx
  80376e:	89 f8                	mov    %edi,%eax
  803770:	e8 e5 fe ff ff       	call   80365a <_pipeisclosed>
  803775:	85 c0                	test   %eax,%eax
  803777:	75 32                	jne    8037ab <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  803779:	e8 eb ed ff ff       	call   802569 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80377e:	8b 06                	mov    (%esi),%eax
  803780:	3b 46 04             	cmp    0x4(%esi),%eax
  803783:	74 df                	je     803764 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803785:	99                   	cltd   
  803786:	c1 ea 1b             	shr    $0x1b,%edx
  803789:	01 d0                	add    %edx,%eax
  80378b:	83 e0 1f             	and    $0x1f,%eax
  80378e:	29 d0                	sub    %edx,%eax
  803790:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  803795:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803798:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80379b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80379e:	83 c3 01             	add    $0x1,%ebx
  8037a1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8037a4:	75 d8                	jne    80377e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8037a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8037a9:	eb 05                	jmp    8037b0 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8037ab:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8037b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8037b3:	5b                   	pop    %ebx
  8037b4:	5e                   	pop    %esi
  8037b5:	5f                   	pop    %edi
  8037b6:	5d                   	pop    %ebp
  8037b7:	c3                   	ret    

008037b8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8037b8:	55                   	push   %ebp
  8037b9:	89 e5                	mov    %esp,%ebp
  8037bb:	56                   	push   %esi
  8037bc:	53                   	push   %ebx
  8037bd:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8037c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8037c3:	50                   	push   %eax
  8037c4:	e8 93 f1 ff ff       	call   80295c <fd_alloc>
  8037c9:	83 c4 10             	add    $0x10,%esp
  8037cc:	89 c2                	mov    %eax,%edx
  8037ce:	85 c0                	test   %eax,%eax
  8037d0:	0f 88 2c 01 00 00    	js     803902 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8037d6:	83 ec 04             	sub    $0x4,%esp
  8037d9:	68 07 04 00 00       	push   $0x407
  8037de:	ff 75 f4             	pushl  -0xc(%ebp)
  8037e1:	6a 00                	push   $0x0
  8037e3:	e8 a0 ed ff ff       	call   802588 <sys_page_alloc>
  8037e8:	83 c4 10             	add    $0x10,%esp
  8037eb:	89 c2                	mov    %eax,%edx
  8037ed:	85 c0                	test   %eax,%eax
  8037ef:	0f 88 0d 01 00 00    	js     803902 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8037f5:	83 ec 0c             	sub    $0xc,%esp
  8037f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8037fb:	50                   	push   %eax
  8037fc:	e8 5b f1 ff ff       	call   80295c <fd_alloc>
  803801:	89 c3                	mov    %eax,%ebx
  803803:	83 c4 10             	add    $0x10,%esp
  803806:	85 c0                	test   %eax,%eax
  803808:	0f 88 e2 00 00 00    	js     8038f0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80380e:	83 ec 04             	sub    $0x4,%esp
  803811:	68 07 04 00 00       	push   $0x407
  803816:	ff 75 f0             	pushl  -0x10(%ebp)
  803819:	6a 00                	push   $0x0
  80381b:	e8 68 ed ff ff       	call   802588 <sys_page_alloc>
  803820:	89 c3                	mov    %eax,%ebx
  803822:	83 c4 10             	add    $0x10,%esp
  803825:	85 c0                	test   %eax,%eax
  803827:	0f 88 c3 00 00 00    	js     8038f0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80382d:	83 ec 0c             	sub    $0xc,%esp
  803830:	ff 75 f4             	pushl  -0xc(%ebp)
  803833:	e8 0d f1 ff ff       	call   802945 <fd2data>
  803838:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80383a:	83 c4 0c             	add    $0xc,%esp
  80383d:	68 07 04 00 00       	push   $0x407
  803842:	50                   	push   %eax
  803843:	6a 00                	push   $0x0
  803845:	e8 3e ed ff ff       	call   802588 <sys_page_alloc>
  80384a:	89 c3                	mov    %eax,%ebx
  80384c:	83 c4 10             	add    $0x10,%esp
  80384f:	85 c0                	test   %eax,%eax
  803851:	0f 88 89 00 00 00    	js     8038e0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803857:	83 ec 0c             	sub    $0xc,%esp
  80385a:	ff 75 f0             	pushl  -0x10(%ebp)
  80385d:	e8 e3 f0 ff ff       	call   802945 <fd2data>
  803862:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  803869:	50                   	push   %eax
  80386a:	6a 00                	push   $0x0
  80386c:	56                   	push   %esi
  80386d:	6a 00                	push   $0x0
  80386f:	e8 57 ed ff ff       	call   8025cb <sys_page_map>
  803874:	89 c3                	mov    %eax,%ebx
  803876:	83 c4 20             	add    $0x20,%esp
  803879:	85 c0                	test   %eax,%eax
  80387b:	78 55                	js     8038d2 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80387d:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803883:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803886:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803888:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80388b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803892:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803898:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80389b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80389d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8038a0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8038a7:	83 ec 0c             	sub    $0xc,%esp
  8038aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8038ad:	e8 83 f0 ff ff       	call   802935 <fd2num>
  8038b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8038b5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8038b7:	83 c4 04             	add    $0x4,%esp
  8038ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8038bd:	e8 73 f0 ff ff       	call   802935 <fd2num>
  8038c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8038c5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8038c8:	83 c4 10             	add    $0x10,%esp
  8038cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8038d0:	eb 30                	jmp    803902 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8038d2:	83 ec 08             	sub    $0x8,%esp
  8038d5:	56                   	push   %esi
  8038d6:	6a 00                	push   $0x0
  8038d8:	e8 30 ed ff ff       	call   80260d <sys_page_unmap>
  8038dd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8038e0:	83 ec 08             	sub    $0x8,%esp
  8038e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8038e6:	6a 00                	push   $0x0
  8038e8:	e8 20 ed ff ff       	call   80260d <sys_page_unmap>
  8038ed:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8038f0:	83 ec 08             	sub    $0x8,%esp
  8038f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8038f6:	6a 00                	push   $0x0
  8038f8:	e8 10 ed ff ff       	call   80260d <sys_page_unmap>
  8038fd:	83 c4 10             	add    $0x10,%esp
  803900:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  803902:	89 d0                	mov    %edx,%eax
  803904:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803907:	5b                   	pop    %ebx
  803908:	5e                   	pop    %esi
  803909:	5d                   	pop    %ebp
  80390a:	c3                   	ret    

0080390b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80390b:	55                   	push   %ebp
  80390c:	89 e5                	mov    %esp,%ebp
  80390e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803911:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803914:	50                   	push   %eax
  803915:	ff 75 08             	pushl  0x8(%ebp)
  803918:	e8 8e f0 ff ff       	call   8029ab <fd_lookup>
  80391d:	83 c4 10             	add    $0x10,%esp
  803920:	85 c0                	test   %eax,%eax
  803922:	78 18                	js     80393c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803924:	83 ec 0c             	sub    $0xc,%esp
  803927:	ff 75 f4             	pushl  -0xc(%ebp)
  80392a:	e8 16 f0 ff ff       	call   802945 <fd2data>
	return _pipeisclosed(fd, p);
  80392f:	89 c2                	mov    %eax,%edx
  803931:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803934:	e8 21 fd ff ff       	call   80365a <_pipeisclosed>
  803939:	83 c4 10             	add    $0x10,%esp
}
  80393c:	c9                   	leave  
  80393d:	c3                   	ret    

0080393e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80393e:	55                   	push   %ebp
  80393f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  803941:	b8 00 00 00 00       	mov    $0x0,%eax
  803946:	5d                   	pop    %ebp
  803947:	c3                   	ret    

00803948 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  803948:	55                   	push   %ebp
  803949:	89 e5                	mov    %esp,%ebp
  80394b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80394e:	68 5a 47 80 00       	push   $0x80475a
  803953:	ff 75 0c             	pushl  0xc(%ebp)
  803956:	e8 2a e8 ff ff       	call   802185 <strcpy>
	return 0;
}
  80395b:	b8 00 00 00 00       	mov    $0x0,%eax
  803960:	c9                   	leave  
  803961:	c3                   	ret    

00803962 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803962:	55                   	push   %ebp
  803963:	89 e5                	mov    %esp,%ebp
  803965:	57                   	push   %edi
  803966:	56                   	push   %esi
  803967:	53                   	push   %ebx
  803968:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80396e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803973:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803979:	eb 2d                	jmp    8039a8 <devcons_write+0x46>
		m = n - tot;
  80397b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80397e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  803980:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  803983:	ba 7f 00 00 00       	mov    $0x7f,%edx
  803988:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80398b:	83 ec 04             	sub    $0x4,%esp
  80398e:	53                   	push   %ebx
  80398f:	03 45 0c             	add    0xc(%ebp),%eax
  803992:	50                   	push   %eax
  803993:	57                   	push   %edi
  803994:	e8 7e e9 ff ff       	call   802317 <memmove>
		sys_cputs(buf, m);
  803999:	83 c4 08             	add    $0x8,%esp
  80399c:	53                   	push   %ebx
  80399d:	57                   	push   %edi
  80399e:	e8 29 eb ff ff       	call   8024cc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8039a3:	01 de                	add    %ebx,%esi
  8039a5:	83 c4 10             	add    $0x10,%esp
  8039a8:	89 f0                	mov    %esi,%eax
  8039aa:	3b 75 10             	cmp    0x10(%ebp),%esi
  8039ad:	72 cc                	jb     80397b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8039af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8039b2:	5b                   	pop    %ebx
  8039b3:	5e                   	pop    %esi
  8039b4:	5f                   	pop    %edi
  8039b5:	5d                   	pop    %ebp
  8039b6:	c3                   	ret    

008039b7 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8039b7:	55                   	push   %ebp
  8039b8:	89 e5                	mov    %esp,%ebp
  8039ba:	83 ec 08             	sub    $0x8,%esp
  8039bd:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8039c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8039c6:	74 2a                	je     8039f2 <devcons_read+0x3b>
  8039c8:	eb 05                	jmp    8039cf <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8039ca:	e8 9a eb ff ff       	call   802569 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8039cf:	e8 16 eb ff ff       	call   8024ea <sys_cgetc>
  8039d4:	85 c0                	test   %eax,%eax
  8039d6:	74 f2                	je     8039ca <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8039d8:	85 c0                	test   %eax,%eax
  8039da:	78 16                	js     8039f2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8039dc:	83 f8 04             	cmp    $0x4,%eax
  8039df:	74 0c                	je     8039ed <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8039e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8039e4:	88 02                	mov    %al,(%edx)
	return 1;
  8039e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8039eb:	eb 05                	jmp    8039f2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8039ed:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8039f2:	c9                   	leave  
  8039f3:	c3                   	ret    

008039f4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  8039f4:	55                   	push   %ebp
  8039f5:	89 e5                	mov    %esp,%ebp
  8039f7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8039fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8039fd:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  803a00:	6a 01                	push   $0x1
  803a02:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803a05:	50                   	push   %eax
  803a06:	e8 c1 ea ff ff       	call   8024cc <sys_cputs>
}
  803a0b:	83 c4 10             	add    $0x10,%esp
  803a0e:	c9                   	leave  
  803a0f:	c3                   	ret    

00803a10 <getchar>:

int
getchar(void)
{
  803a10:	55                   	push   %ebp
  803a11:	89 e5                	mov    %esp,%ebp
  803a13:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803a16:	6a 01                	push   $0x1
  803a18:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803a1b:	50                   	push   %eax
  803a1c:	6a 00                	push   $0x0
  803a1e:	e8 ee f1 ff ff       	call   802c11 <read>
	if (r < 0)
  803a23:	83 c4 10             	add    $0x10,%esp
  803a26:	85 c0                	test   %eax,%eax
  803a28:	78 0f                	js     803a39 <getchar+0x29>
		return r;
	if (r < 1)
  803a2a:	85 c0                	test   %eax,%eax
  803a2c:	7e 06                	jle    803a34 <getchar+0x24>
		return -E_EOF;
	return c;
  803a2e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  803a32:	eb 05                	jmp    803a39 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  803a34:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  803a39:	c9                   	leave  
  803a3a:	c3                   	ret    

00803a3b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  803a3b:	55                   	push   %ebp
  803a3c:	89 e5                	mov    %esp,%ebp
  803a3e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803a41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803a44:	50                   	push   %eax
  803a45:	ff 75 08             	pushl  0x8(%ebp)
  803a48:	e8 5e ef ff ff       	call   8029ab <fd_lookup>
  803a4d:	83 c4 10             	add    $0x10,%esp
  803a50:	85 c0                	test   %eax,%eax
  803a52:	78 11                	js     803a65 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  803a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803a57:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  803a5d:	39 10                	cmp    %edx,(%eax)
  803a5f:	0f 94 c0             	sete   %al
  803a62:	0f b6 c0             	movzbl %al,%eax
}
  803a65:	c9                   	leave  
  803a66:	c3                   	ret    

00803a67 <opencons>:

int
opencons(void)
{
  803a67:	55                   	push   %ebp
  803a68:	89 e5                	mov    %esp,%ebp
  803a6a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803a6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803a70:	50                   	push   %eax
  803a71:	e8 e6 ee ff ff       	call   80295c <fd_alloc>
  803a76:	83 c4 10             	add    $0x10,%esp
		return r;
  803a79:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803a7b:	85 c0                	test   %eax,%eax
  803a7d:	78 3e                	js     803abd <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803a7f:	83 ec 04             	sub    $0x4,%esp
  803a82:	68 07 04 00 00       	push   $0x407
  803a87:	ff 75 f4             	pushl  -0xc(%ebp)
  803a8a:	6a 00                	push   $0x0
  803a8c:	e8 f7 ea ff ff       	call   802588 <sys_page_alloc>
  803a91:	83 c4 10             	add    $0x10,%esp
		return r;
  803a94:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803a96:	85 c0                	test   %eax,%eax
  803a98:	78 23                	js     803abd <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  803a9a:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  803aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803aa3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803aa8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803aaf:	83 ec 0c             	sub    $0xc,%esp
  803ab2:	50                   	push   %eax
  803ab3:	e8 7d ee ff ff       	call   802935 <fd2num>
  803ab8:	89 c2                	mov    %eax,%edx
  803aba:	83 c4 10             	add    $0x10,%esp
}
  803abd:	89 d0                	mov    %edx,%eax
  803abf:	c9                   	leave  
  803ac0:	c3                   	ret    
  803ac1:	66 90                	xchg   %ax,%ax
  803ac3:	66 90                	xchg   %ax,%ax
  803ac5:	66 90                	xchg   %ax,%ax
  803ac7:	66 90                	xchg   %ax,%ax
  803ac9:	66 90                	xchg   %ax,%ax
  803acb:	66 90                	xchg   %ax,%ax
  803acd:	66 90                	xchg   %ax,%ax
  803acf:	90                   	nop

00803ad0 <__udivdi3>:
  803ad0:	55                   	push   %ebp
  803ad1:	57                   	push   %edi
  803ad2:	56                   	push   %esi
  803ad3:	53                   	push   %ebx
  803ad4:	83 ec 1c             	sub    $0x1c,%esp
  803ad7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  803adb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  803adf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803ae3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803ae7:	85 f6                	test   %esi,%esi
  803ae9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803aed:	89 ca                	mov    %ecx,%edx
  803aef:	89 f8                	mov    %edi,%eax
  803af1:	75 3d                	jne    803b30 <__udivdi3+0x60>
  803af3:	39 cf                	cmp    %ecx,%edi
  803af5:	0f 87 c5 00 00 00    	ja     803bc0 <__udivdi3+0xf0>
  803afb:	85 ff                	test   %edi,%edi
  803afd:	89 fd                	mov    %edi,%ebp
  803aff:	75 0b                	jne    803b0c <__udivdi3+0x3c>
  803b01:	b8 01 00 00 00       	mov    $0x1,%eax
  803b06:	31 d2                	xor    %edx,%edx
  803b08:	f7 f7                	div    %edi
  803b0a:	89 c5                	mov    %eax,%ebp
  803b0c:	89 c8                	mov    %ecx,%eax
  803b0e:	31 d2                	xor    %edx,%edx
  803b10:	f7 f5                	div    %ebp
  803b12:	89 c1                	mov    %eax,%ecx
  803b14:	89 d8                	mov    %ebx,%eax
  803b16:	89 cf                	mov    %ecx,%edi
  803b18:	f7 f5                	div    %ebp
  803b1a:	89 c3                	mov    %eax,%ebx
  803b1c:	89 d8                	mov    %ebx,%eax
  803b1e:	89 fa                	mov    %edi,%edx
  803b20:	83 c4 1c             	add    $0x1c,%esp
  803b23:	5b                   	pop    %ebx
  803b24:	5e                   	pop    %esi
  803b25:	5f                   	pop    %edi
  803b26:	5d                   	pop    %ebp
  803b27:	c3                   	ret    
  803b28:	90                   	nop
  803b29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803b30:	39 ce                	cmp    %ecx,%esi
  803b32:	77 74                	ja     803ba8 <__udivdi3+0xd8>
  803b34:	0f bd fe             	bsr    %esi,%edi
  803b37:	83 f7 1f             	xor    $0x1f,%edi
  803b3a:	0f 84 98 00 00 00    	je     803bd8 <__udivdi3+0x108>
  803b40:	bb 20 00 00 00       	mov    $0x20,%ebx
  803b45:	89 f9                	mov    %edi,%ecx
  803b47:	89 c5                	mov    %eax,%ebp
  803b49:	29 fb                	sub    %edi,%ebx
  803b4b:	d3 e6                	shl    %cl,%esi
  803b4d:	89 d9                	mov    %ebx,%ecx
  803b4f:	d3 ed                	shr    %cl,%ebp
  803b51:	89 f9                	mov    %edi,%ecx
  803b53:	d3 e0                	shl    %cl,%eax
  803b55:	09 ee                	or     %ebp,%esi
  803b57:	89 d9                	mov    %ebx,%ecx
  803b59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803b5d:	89 d5                	mov    %edx,%ebp
  803b5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803b63:	d3 ed                	shr    %cl,%ebp
  803b65:	89 f9                	mov    %edi,%ecx
  803b67:	d3 e2                	shl    %cl,%edx
  803b69:	89 d9                	mov    %ebx,%ecx
  803b6b:	d3 e8                	shr    %cl,%eax
  803b6d:	09 c2                	or     %eax,%edx
  803b6f:	89 d0                	mov    %edx,%eax
  803b71:	89 ea                	mov    %ebp,%edx
  803b73:	f7 f6                	div    %esi
  803b75:	89 d5                	mov    %edx,%ebp
  803b77:	89 c3                	mov    %eax,%ebx
  803b79:	f7 64 24 0c          	mull   0xc(%esp)
  803b7d:	39 d5                	cmp    %edx,%ebp
  803b7f:	72 10                	jb     803b91 <__udivdi3+0xc1>
  803b81:	8b 74 24 08          	mov    0x8(%esp),%esi
  803b85:	89 f9                	mov    %edi,%ecx
  803b87:	d3 e6                	shl    %cl,%esi
  803b89:	39 c6                	cmp    %eax,%esi
  803b8b:	73 07                	jae    803b94 <__udivdi3+0xc4>
  803b8d:	39 d5                	cmp    %edx,%ebp
  803b8f:	75 03                	jne    803b94 <__udivdi3+0xc4>
  803b91:	83 eb 01             	sub    $0x1,%ebx
  803b94:	31 ff                	xor    %edi,%edi
  803b96:	89 d8                	mov    %ebx,%eax
  803b98:	89 fa                	mov    %edi,%edx
  803b9a:	83 c4 1c             	add    $0x1c,%esp
  803b9d:	5b                   	pop    %ebx
  803b9e:	5e                   	pop    %esi
  803b9f:	5f                   	pop    %edi
  803ba0:	5d                   	pop    %ebp
  803ba1:	c3                   	ret    
  803ba2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803ba8:	31 ff                	xor    %edi,%edi
  803baa:	31 db                	xor    %ebx,%ebx
  803bac:	89 d8                	mov    %ebx,%eax
  803bae:	89 fa                	mov    %edi,%edx
  803bb0:	83 c4 1c             	add    $0x1c,%esp
  803bb3:	5b                   	pop    %ebx
  803bb4:	5e                   	pop    %esi
  803bb5:	5f                   	pop    %edi
  803bb6:	5d                   	pop    %ebp
  803bb7:	c3                   	ret    
  803bb8:	90                   	nop
  803bb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803bc0:	89 d8                	mov    %ebx,%eax
  803bc2:	f7 f7                	div    %edi
  803bc4:	31 ff                	xor    %edi,%edi
  803bc6:	89 c3                	mov    %eax,%ebx
  803bc8:	89 d8                	mov    %ebx,%eax
  803bca:	89 fa                	mov    %edi,%edx
  803bcc:	83 c4 1c             	add    $0x1c,%esp
  803bcf:	5b                   	pop    %ebx
  803bd0:	5e                   	pop    %esi
  803bd1:	5f                   	pop    %edi
  803bd2:	5d                   	pop    %ebp
  803bd3:	c3                   	ret    
  803bd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803bd8:	39 ce                	cmp    %ecx,%esi
  803bda:	72 0c                	jb     803be8 <__udivdi3+0x118>
  803bdc:	31 db                	xor    %ebx,%ebx
  803bde:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803be2:	0f 87 34 ff ff ff    	ja     803b1c <__udivdi3+0x4c>
  803be8:	bb 01 00 00 00       	mov    $0x1,%ebx
  803bed:	e9 2a ff ff ff       	jmp    803b1c <__udivdi3+0x4c>
  803bf2:	66 90                	xchg   %ax,%ax
  803bf4:	66 90                	xchg   %ax,%ax
  803bf6:	66 90                	xchg   %ax,%ax
  803bf8:	66 90                	xchg   %ax,%ax
  803bfa:	66 90                	xchg   %ax,%ax
  803bfc:	66 90                	xchg   %ax,%ax
  803bfe:	66 90                	xchg   %ax,%ax

00803c00 <__umoddi3>:
  803c00:	55                   	push   %ebp
  803c01:	57                   	push   %edi
  803c02:	56                   	push   %esi
  803c03:	53                   	push   %ebx
  803c04:	83 ec 1c             	sub    $0x1c,%esp
  803c07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  803c0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  803c0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803c13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803c17:	85 d2                	test   %edx,%edx
  803c19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  803c1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803c21:	89 f3                	mov    %esi,%ebx
  803c23:	89 3c 24             	mov    %edi,(%esp)
  803c26:	89 74 24 04          	mov    %esi,0x4(%esp)
  803c2a:	75 1c                	jne    803c48 <__umoddi3+0x48>
  803c2c:	39 f7                	cmp    %esi,%edi
  803c2e:	76 50                	jbe    803c80 <__umoddi3+0x80>
  803c30:	89 c8                	mov    %ecx,%eax
  803c32:	89 f2                	mov    %esi,%edx
  803c34:	f7 f7                	div    %edi
  803c36:	89 d0                	mov    %edx,%eax
  803c38:	31 d2                	xor    %edx,%edx
  803c3a:	83 c4 1c             	add    $0x1c,%esp
  803c3d:	5b                   	pop    %ebx
  803c3e:	5e                   	pop    %esi
  803c3f:	5f                   	pop    %edi
  803c40:	5d                   	pop    %ebp
  803c41:	c3                   	ret    
  803c42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803c48:	39 f2                	cmp    %esi,%edx
  803c4a:	89 d0                	mov    %edx,%eax
  803c4c:	77 52                	ja     803ca0 <__umoddi3+0xa0>
  803c4e:	0f bd ea             	bsr    %edx,%ebp
  803c51:	83 f5 1f             	xor    $0x1f,%ebp
  803c54:	75 5a                	jne    803cb0 <__umoddi3+0xb0>
  803c56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  803c5a:	0f 82 e0 00 00 00    	jb     803d40 <__umoddi3+0x140>
  803c60:	39 0c 24             	cmp    %ecx,(%esp)
  803c63:	0f 86 d7 00 00 00    	jbe    803d40 <__umoddi3+0x140>
  803c69:	8b 44 24 08          	mov    0x8(%esp),%eax
  803c6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803c71:	83 c4 1c             	add    $0x1c,%esp
  803c74:	5b                   	pop    %ebx
  803c75:	5e                   	pop    %esi
  803c76:	5f                   	pop    %edi
  803c77:	5d                   	pop    %ebp
  803c78:	c3                   	ret    
  803c79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803c80:	85 ff                	test   %edi,%edi
  803c82:	89 fd                	mov    %edi,%ebp
  803c84:	75 0b                	jne    803c91 <__umoddi3+0x91>
  803c86:	b8 01 00 00 00       	mov    $0x1,%eax
  803c8b:	31 d2                	xor    %edx,%edx
  803c8d:	f7 f7                	div    %edi
  803c8f:	89 c5                	mov    %eax,%ebp
  803c91:	89 f0                	mov    %esi,%eax
  803c93:	31 d2                	xor    %edx,%edx
  803c95:	f7 f5                	div    %ebp
  803c97:	89 c8                	mov    %ecx,%eax
  803c99:	f7 f5                	div    %ebp
  803c9b:	89 d0                	mov    %edx,%eax
  803c9d:	eb 99                	jmp    803c38 <__umoddi3+0x38>
  803c9f:	90                   	nop
  803ca0:	89 c8                	mov    %ecx,%eax
  803ca2:	89 f2                	mov    %esi,%edx
  803ca4:	83 c4 1c             	add    $0x1c,%esp
  803ca7:	5b                   	pop    %ebx
  803ca8:	5e                   	pop    %esi
  803ca9:	5f                   	pop    %edi
  803caa:	5d                   	pop    %ebp
  803cab:	c3                   	ret    
  803cac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803cb0:	8b 34 24             	mov    (%esp),%esi
  803cb3:	bf 20 00 00 00       	mov    $0x20,%edi
  803cb8:	89 e9                	mov    %ebp,%ecx
  803cba:	29 ef                	sub    %ebp,%edi
  803cbc:	d3 e0                	shl    %cl,%eax
  803cbe:	89 f9                	mov    %edi,%ecx
  803cc0:	89 f2                	mov    %esi,%edx
  803cc2:	d3 ea                	shr    %cl,%edx
  803cc4:	89 e9                	mov    %ebp,%ecx
  803cc6:	09 c2                	or     %eax,%edx
  803cc8:	89 d8                	mov    %ebx,%eax
  803cca:	89 14 24             	mov    %edx,(%esp)
  803ccd:	89 f2                	mov    %esi,%edx
  803ccf:	d3 e2                	shl    %cl,%edx
  803cd1:	89 f9                	mov    %edi,%ecx
  803cd3:	89 54 24 04          	mov    %edx,0x4(%esp)
  803cd7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  803cdb:	d3 e8                	shr    %cl,%eax
  803cdd:	89 e9                	mov    %ebp,%ecx
  803cdf:	89 c6                	mov    %eax,%esi
  803ce1:	d3 e3                	shl    %cl,%ebx
  803ce3:	89 f9                	mov    %edi,%ecx
  803ce5:	89 d0                	mov    %edx,%eax
  803ce7:	d3 e8                	shr    %cl,%eax
  803ce9:	89 e9                	mov    %ebp,%ecx
  803ceb:	09 d8                	or     %ebx,%eax
  803ced:	89 d3                	mov    %edx,%ebx
  803cef:	89 f2                	mov    %esi,%edx
  803cf1:	f7 34 24             	divl   (%esp)
  803cf4:	89 d6                	mov    %edx,%esi
  803cf6:	d3 e3                	shl    %cl,%ebx
  803cf8:	f7 64 24 04          	mull   0x4(%esp)
  803cfc:	39 d6                	cmp    %edx,%esi
  803cfe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803d02:	89 d1                	mov    %edx,%ecx
  803d04:	89 c3                	mov    %eax,%ebx
  803d06:	72 08                	jb     803d10 <__umoddi3+0x110>
  803d08:	75 11                	jne    803d1b <__umoddi3+0x11b>
  803d0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  803d0e:	73 0b                	jae    803d1b <__umoddi3+0x11b>
  803d10:	2b 44 24 04          	sub    0x4(%esp),%eax
  803d14:	1b 14 24             	sbb    (%esp),%edx
  803d17:	89 d1                	mov    %edx,%ecx
  803d19:	89 c3                	mov    %eax,%ebx
  803d1b:	8b 54 24 08          	mov    0x8(%esp),%edx
  803d1f:	29 da                	sub    %ebx,%edx
  803d21:	19 ce                	sbb    %ecx,%esi
  803d23:	89 f9                	mov    %edi,%ecx
  803d25:	89 f0                	mov    %esi,%eax
  803d27:	d3 e0                	shl    %cl,%eax
  803d29:	89 e9                	mov    %ebp,%ecx
  803d2b:	d3 ea                	shr    %cl,%edx
  803d2d:	89 e9                	mov    %ebp,%ecx
  803d2f:	d3 ee                	shr    %cl,%esi
  803d31:	09 d0                	or     %edx,%eax
  803d33:	89 f2                	mov    %esi,%edx
  803d35:	83 c4 1c             	add    $0x1c,%esp
  803d38:	5b                   	pop    %ebx
  803d39:	5e                   	pop    %esi
  803d3a:	5f                   	pop    %edi
  803d3b:	5d                   	pop    %ebp
  803d3c:	c3                   	ret    
  803d3d:	8d 76 00             	lea    0x0(%esi),%esi
  803d40:	29 f9                	sub    %edi,%ecx
  803d42:	19 d6                	sbb    %edx,%esi
  803d44:	89 74 24 04          	mov    %esi,0x4(%esp)
  803d48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803d4c:	e9 18 ff ff ff       	jmp    803c69 <__umoddi3+0x69>
