
obj/user/dumbfork.debug：     文件格式 elf32-i386


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
  80002c:	e8 aa 01 00 00       	call   8001db <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 d1 0c 00 00       	call   800d1b <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 60 24 80 00       	push   $0x802460
  800057:	6a 20                	push   $0x20
  800059:	68 73 24 80 00       	push   $0x802473
  80005e:	e8 d8 01 00 00       	call   80023b <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 e8 0c 00 00       	call   800d5e <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 83 24 80 00       	push   $0x802483
  800083:	6a 22                	push   $0x22
  800085:	68 73 24 80 00       	push   $0x802473
  80008a:	e8 ac 01 00 00       	call   80023b <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 08 0a 00 00       	call   800aaa <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 ef 0c 00 00       	call   800da0 <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 94 24 80 00       	push   $0x802494
  8000be:	6a 25                	push   $0x25
  8000c0:	68 73 24 80 00       	push   $0x802473
  8000c5:	e8 71 01 00 00       	call   80023b <_panic>
}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8000d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	79 12                	jns    8000f8 <dumbfork+0x27>
		panic("sys_exofork: %e", envid);
  8000e6:	50                   	push   %eax
  8000e7:	68 a7 24 80 00       	push   $0x8024a7
  8000ec:	6a 37                	push   $0x37
  8000ee:	68 73 24 80 00       	push   $0x802473
  8000f3:	e8 43 01 00 00       	call   80023b <_panic>
  8000f8:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1e                	jne    80011c <dumbfork+0x4b>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 da 0b 00 00       	call   800cdd <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800110:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800115:	b8 00 00 00 00       	mov    $0x0,%eax
  80011a:	eb 60                	jmp    80017c <dumbfork+0xab>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80011c:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800123:	eb 14                	jmp    800139 <dumbfork+0x68>
		duppage(envid, addr);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	52                   	push   %edx
  800129:	56                   	push   %esi
  80012a:	e8 04 ff ff ff       	call   800033 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80012f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80013c:	81 fa 00 70 80 00    	cmp    $0x807000,%edx
  800142:	72 e1                	jb     800125 <dumbfork+0x54>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80014f:	50                   	push   %eax
  800150:	53                   	push   %ebx
  800151:	e8 dd fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	6a 02                	push   $0x2
  80015b:	53                   	push   %ebx
  80015c:	e8 81 0c 00 00       	call   800de2 <sys_env_set_status>
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	85 c0                	test   %eax,%eax
  800166:	79 12                	jns    80017a <dumbfork+0xa9>
		panic("sys_env_set_status: %e", r);
  800168:	50                   	push   %eax
  800169:	68 b7 24 80 00       	push   $0x8024b7
  80016e:	6a 4c                	push   $0x4c
  800170:	68 73 24 80 00       	push   $0x802473
  800175:	e8 c1 00 00 00       	call   80023b <_panic>

	return envid;
  80017a:	89 d8                	mov    %ebx,%eax
}
  80017c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	57                   	push   %edi
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	83 ec 0c             	sub    $0xc,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  80018c:	e8 40 ff ff ff       	call   8000d1 <dumbfork>
  800191:	89 c7                	mov    %eax,%edi
  800193:	85 c0                	test   %eax,%eax
  800195:	be d5 24 80 00       	mov    $0x8024d5,%esi
  80019a:	b8 ce 24 80 00       	mov    $0x8024ce,%eax
  80019f:	0f 45 f0             	cmovne %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a7:	eb 1a                	jmp    8001c3 <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001a9:	83 ec 04             	sub    $0x4,%esp
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	68 db 24 80 00       	push   $0x8024db
  8001b3:	e8 5c 01 00 00       	call   800314 <cprintf>
		sys_yield();
  8001b8:	e8 3f 0b 00 00       	call   800cfc <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001bd:	83 c3 01             	add    $0x1,%ebx
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 ff                	test   %edi,%edi
  8001c5:	74 07                	je     8001ce <umain+0x4b>
  8001c7:	83 fb 09             	cmp    $0x9,%ebx
  8001ca:	7e dd                	jle    8001a9 <umain+0x26>
  8001cc:	eb 05                	jmp    8001d3 <umain+0x50>
  8001ce:	83 fb 13             	cmp    $0x13,%ebx
  8001d1:	7e d6                	jle    8001a9 <umain+0x26>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001e3:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8001e6:	e8 f2 0a 00 00       	call   800cdd <sys_getenvid>
  8001eb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001f3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f8:	a3 08 40 80 00       	mov    %eax,0x804008

    // save the name of the program so that panic() can use it
    if (argc > 0)
  8001fd:	85 db                	test   %ebx,%ebx
  8001ff:	7e 07                	jle    800208 <libmain+0x2d>
        binaryname = argv[0];
  800201:	8b 06                	mov    (%esi),%eax
  800203:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	53                   	push   %ebx
  80020d:	e8 71 ff ff ff       	call   800183 <umain>

    // exit gracefully
    exit();
  800212:	e8 0a 00 00 00       	call   800221 <exit>
}
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800227:	e8 ea 0e 00 00       	call   801116 <close_all>
	sys_env_destroy(0);
  80022c:	83 ec 0c             	sub    $0xc,%esp
  80022f:	6a 00                	push   $0x0
  800231:	e8 66 0a 00 00       	call   800c9c <sys_env_destroy>
}
  800236:	83 c4 10             	add    $0x10,%esp
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800240:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800243:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800249:	e8 8f 0a 00 00       	call   800cdd <sys_getenvid>
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	ff 75 0c             	pushl  0xc(%ebp)
  800254:	ff 75 08             	pushl  0x8(%ebp)
  800257:	56                   	push   %esi
  800258:	50                   	push   %eax
  800259:	68 f8 24 80 00       	push   $0x8024f8
  80025e:	e8 b1 00 00 00       	call   800314 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800263:	83 c4 18             	add    $0x18,%esp
  800266:	53                   	push   %ebx
  800267:	ff 75 10             	pushl  0x10(%ebp)
  80026a:	e8 54 00 00 00       	call   8002c3 <vcprintf>
	cprintf("\n");
  80026f:	c7 04 24 eb 24 80 00 	movl   $0x8024eb,(%esp)
  800276:	e8 99 00 00 00       	call   800314 <cprintf>
  80027b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80027e:	cc                   	int3   
  80027f:	eb fd                	jmp    80027e <_panic+0x43>

00800281 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	53                   	push   %ebx
  800285:	83 ec 04             	sub    $0x4,%esp
  800288:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80028b:	8b 13                	mov    (%ebx),%edx
  80028d:	8d 42 01             	lea    0x1(%edx),%eax
  800290:	89 03                	mov    %eax,(%ebx)
  800292:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800295:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800299:	3d ff 00 00 00       	cmp    $0xff,%eax
  80029e:	75 1a                	jne    8002ba <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a0:	83 ec 08             	sub    $0x8,%esp
  8002a3:	68 ff 00 00 00       	push   $0xff
  8002a8:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ab:	50                   	push   %eax
  8002ac:	e8 ae 09 00 00       	call   800c5f <sys_cputs>
		b->idx = 0;
  8002b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002ba:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002c1:	c9                   	leave  
  8002c2:	c3                   	ret    

008002c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d3:	00 00 00 
	b.cnt = 0;
  8002d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e0:	ff 75 0c             	pushl  0xc(%ebp)
  8002e3:	ff 75 08             	pushl  0x8(%ebp)
  8002e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ec:	50                   	push   %eax
  8002ed:	68 81 02 80 00       	push   $0x800281
  8002f2:	e8 1a 01 00 00       	call   800411 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f7:	83 c4 08             	add    $0x8,%esp
  8002fa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800300:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800306:	50                   	push   %eax
  800307:	e8 53 09 00 00       	call   800c5f <sys_cputs>

	return b.cnt;
}
  80030c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80031a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80031d:	50                   	push   %eax
  80031e:	ff 75 08             	pushl  0x8(%ebp)
  800321:	e8 9d ff ff ff       	call   8002c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
  80032e:	83 ec 1c             	sub    $0x1c,%esp
  800331:	89 c7                	mov    %eax,%edi
  800333:	89 d6                	mov    %edx,%esi
  800335:	8b 45 08             	mov    0x8(%ebp),%eax
  800338:	8b 55 0c             	mov    0xc(%ebp),%edx
  80033b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800341:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800344:	bb 00 00 00 00       	mov    $0x0,%ebx
  800349:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80034c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034f:	39 d3                	cmp    %edx,%ebx
  800351:	72 05                	jb     800358 <printnum+0x30>
  800353:	39 45 10             	cmp    %eax,0x10(%ebp)
  800356:	77 45                	ja     80039d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800358:	83 ec 0c             	sub    $0xc,%esp
  80035b:	ff 75 18             	pushl  0x18(%ebp)
  80035e:	8b 45 14             	mov    0x14(%ebp),%eax
  800361:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800364:	53                   	push   %ebx
  800365:	ff 75 10             	pushl  0x10(%ebp)
  800368:	83 ec 08             	sub    $0x8,%esp
  80036b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80036e:	ff 75 e0             	pushl  -0x20(%ebp)
  800371:	ff 75 dc             	pushl  -0x24(%ebp)
  800374:	ff 75 d8             	pushl  -0x28(%ebp)
  800377:	e8 54 1e 00 00       	call   8021d0 <__udivdi3>
  80037c:	83 c4 18             	add    $0x18,%esp
  80037f:	52                   	push   %edx
  800380:	50                   	push   %eax
  800381:	89 f2                	mov    %esi,%edx
  800383:	89 f8                	mov    %edi,%eax
  800385:	e8 9e ff ff ff       	call   800328 <printnum>
  80038a:	83 c4 20             	add    $0x20,%esp
  80038d:	eb 18                	jmp    8003a7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038f:	83 ec 08             	sub    $0x8,%esp
  800392:	56                   	push   %esi
  800393:	ff 75 18             	pushl  0x18(%ebp)
  800396:	ff d7                	call   *%edi
  800398:	83 c4 10             	add    $0x10,%esp
  80039b:	eb 03                	jmp    8003a0 <printnum+0x78>
  80039d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a0:	83 eb 01             	sub    $0x1,%ebx
  8003a3:	85 db                	test   %ebx,%ebx
  8003a5:	7f e8                	jg     80038f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a7:	83 ec 08             	sub    $0x8,%esp
  8003aa:	56                   	push   %esi
  8003ab:	83 ec 04             	sub    $0x4,%esp
  8003ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ba:	e8 41 1f 00 00       	call   802300 <__umoddi3>
  8003bf:	83 c4 14             	add    $0x14,%esp
  8003c2:	0f be 80 1b 25 80 00 	movsbl 0x80251b(%eax),%eax
  8003c9:	50                   	push   %eax
  8003ca:	ff d7                	call   *%edi
}
  8003cc:	83 c4 10             	add    $0x10,%esp
  8003cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d2:	5b                   	pop    %ebx
  8003d3:	5e                   	pop    %esi
  8003d4:	5f                   	pop    %edi
  8003d5:	5d                   	pop    %ebp
  8003d6:	c3                   	ret    

008003d7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
  8003da:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003dd:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003e1:	8b 10                	mov    (%eax),%edx
  8003e3:	3b 50 04             	cmp    0x4(%eax),%edx
  8003e6:	73 0a                	jae    8003f2 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003e8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003eb:	89 08                	mov    %ecx,(%eax)
  8003ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f0:	88 02                	mov    %al,(%edx)
}
  8003f2:	5d                   	pop    %ebp
  8003f3:	c3                   	ret    

008003f4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003fa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003fd:	50                   	push   %eax
  8003fe:	ff 75 10             	pushl  0x10(%ebp)
  800401:	ff 75 0c             	pushl  0xc(%ebp)
  800404:	ff 75 08             	pushl  0x8(%ebp)
  800407:	e8 05 00 00 00       	call   800411 <vprintfmt>
	va_end(ap);
}
  80040c:	83 c4 10             	add    $0x10,%esp
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	57                   	push   %edi
  800415:	56                   	push   %esi
  800416:	53                   	push   %ebx
  800417:	83 ec 2c             	sub    $0x2c,%esp
  80041a:	8b 75 08             	mov    0x8(%ebp),%esi
  80041d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800420:	8b 7d 10             	mov    0x10(%ebp),%edi
  800423:	eb 12                	jmp    800437 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800425:	85 c0                	test   %eax,%eax
  800427:	0f 84 42 04 00 00    	je     80086f <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	53                   	push   %ebx
  800431:	50                   	push   %eax
  800432:	ff d6                	call   *%esi
  800434:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800437:	83 c7 01             	add    $0x1,%edi
  80043a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80043e:	83 f8 25             	cmp    $0x25,%eax
  800441:	75 e2                	jne    800425 <vprintfmt+0x14>
  800443:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800447:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80044e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800455:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80045c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800461:	eb 07                	jmp    80046a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800463:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800466:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8d 47 01             	lea    0x1(%edi),%eax
  80046d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800470:	0f b6 07             	movzbl (%edi),%eax
  800473:	0f b6 d0             	movzbl %al,%edx
  800476:	83 e8 23             	sub    $0x23,%eax
  800479:	3c 55                	cmp    $0x55,%al
  80047b:	0f 87 d3 03 00 00    	ja     800854 <vprintfmt+0x443>
  800481:	0f b6 c0             	movzbl %al,%eax
  800484:	ff 24 85 60 26 80 00 	jmp    *0x802660(,%eax,4)
  80048b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80048e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800492:	eb d6                	jmp    80046a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800494:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800497:	b8 00 00 00 00       	mov    $0x0,%eax
  80049c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80049f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004a2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004a6:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004a9:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004ac:	83 f9 09             	cmp    $0x9,%ecx
  8004af:	77 3f                	ja     8004f0 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004b4:	eb e9                	jmp    80049f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b9:	8b 00                	mov    (%eax),%eax
  8004bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004be:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c1:	8d 40 04             	lea    0x4(%eax),%eax
  8004c4:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ca:	eb 2a                	jmp    8004f6 <vprintfmt+0xe5>
  8004cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004cf:	85 c0                	test   %eax,%eax
  8004d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d6:	0f 49 d0             	cmovns %eax,%edx
  8004d9:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004df:	eb 89                	jmp    80046a <vprintfmt+0x59>
  8004e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004e4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004eb:	e9 7a ff ff ff       	jmp    80046a <vprintfmt+0x59>
  8004f0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004f3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004f6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004fa:	0f 89 6a ff ff ff    	jns    80046a <vprintfmt+0x59>
				width = precision, precision = -1;
  800500:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800503:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800506:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80050d:	e9 58 ff ff ff       	jmp    80046a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800512:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800515:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800518:	e9 4d ff ff ff       	jmp    80046a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80051d:	8b 45 14             	mov    0x14(%ebp),%eax
  800520:	8d 78 04             	lea    0x4(%eax),%edi
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	53                   	push   %ebx
  800527:	ff 30                	pushl  (%eax)
  800529:	ff d6                	call   *%esi
			break;
  80052b:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80052e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800531:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800534:	e9 fe fe ff ff       	jmp    800437 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8d 78 04             	lea    0x4(%eax),%edi
  80053f:	8b 00                	mov    (%eax),%eax
  800541:	99                   	cltd   
  800542:	31 d0                	xor    %edx,%eax
  800544:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800546:	83 f8 0f             	cmp    $0xf,%eax
  800549:	7f 0b                	jg     800556 <vprintfmt+0x145>
  80054b:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  800552:	85 d2                	test   %edx,%edx
  800554:	75 1b                	jne    800571 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800556:	50                   	push   %eax
  800557:	68 33 25 80 00       	push   $0x802533
  80055c:	53                   	push   %ebx
  80055d:	56                   	push   %esi
  80055e:	e8 91 fe ff ff       	call   8003f4 <printfmt>
  800563:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800566:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800569:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80056c:	e9 c6 fe ff ff       	jmp    800437 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800571:	52                   	push   %edx
  800572:	68 f9 28 80 00       	push   $0x8028f9
  800577:	53                   	push   %ebx
  800578:	56                   	push   %esi
  800579:	e8 76 fe ff ff       	call   8003f4 <printfmt>
  80057e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800581:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800584:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800587:	e9 ab fe ff ff       	jmp    800437 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	83 c0 04             	add    $0x4,%eax
  800592:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80059a:	85 ff                	test   %edi,%edi
  80059c:	b8 2c 25 80 00       	mov    $0x80252c,%eax
  8005a1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a8:	0f 8e 94 00 00 00    	jle    800642 <vprintfmt+0x231>
  8005ae:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005b2:	0f 84 98 00 00 00    	je     800650 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b8:	83 ec 08             	sub    $0x8,%esp
  8005bb:	ff 75 d0             	pushl  -0x30(%ebp)
  8005be:	57                   	push   %edi
  8005bf:	e8 33 03 00 00       	call   8008f7 <strnlen>
  8005c4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005c7:	29 c1                	sub    %eax,%ecx
  8005c9:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005cc:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005cf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005d9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005db:	eb 0f                	jmp    8005ec <vprintfmt+0x1db>
					putch(padc, putdat);
  8005dd:	83 ec 08             	sub    $0x8,%esp
  8005e0:	53                   	push   %ebx
  8005e1:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e6:	83 ef 01             	sub    $0x1,%edi
  8005e9:	83 c4 10             	add    $0x10,%esp
  8005ec:	85 ff                	test   %edi,%edi
  8005ee:	7f ed                	jg     8005dd <vprintfmt+0x1cc>
  8005f0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005f3:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005f6:	85 c9                	test   %ecx,%ecx
  8005f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005fd:	0f 49 c1             	cmovns %ecx,%eax
  800600:	29 c1                	sub    %eax,%ecx
  800602:	89 75 08             	mov    %esi,0x8(%ebp)
  800605:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800608:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80060b:	89 cb                	mov    %ecx,%ebx
  80060d:	eb 4d                	jmp    80065c <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80060f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800613:	74 1b                	je     800630 <vprintfmt+0x21f>
  800615:	0f be c0             	movsbl %al,%eax
  800618:	83 e8 20             	sub    $0x20,%eax
  80061b:	83 f8 5e             	cmp    $0x5e,%eax
  80061e:	76 10                	jbe    800630 <vprintfmt+0x21f>
					putch('?', putdat);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	ff 75 0c             	pushl  0xc(%ebp)
  800626:	6a 3f                	push   $0x3f
  800628:	ff 55 08             	call   *0x8(%ebp)
  80062b:	83 c4 10             	add    $0x10,%esp
  80062e:	eb 0d                	jmp    80063d <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	ff 75 0c             	pushl  0xc(%ebp)
  800636:	52                   	push   %edx
  800637:	ff 55 08             	call   *0x8(%ebp)
  80063a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80063d:	83 eb 01             	sub    $0x1,%ebx
  800640:	eb 1a                	jmp    80065c <vprintfmt+0x24b>
  800642:	89 75 08             	mov    %esi,0x8(%ebp)
  800645:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800648:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80064b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80064e:	eb 0c                	jmp    80065c <vprintfmt+0x24b>
  800650:	89 75 08             	mov    %esi,0x8(%ebp)
  800653:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800656:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800659:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80065c:	83 c7 01             	add    $0x1,%edi
  80065f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800663:	0f be d0             	movsbl %al,%edx
  800666:	85 d2                	test   %edx,%edx
  800668:	74 23                	je     80068d <vprintfmt+0x27c>
  80066a:	85 f6                	test   %esi,%esi
  80066c:	78 a1                	js     80060f <vprintfmt+0x1fe>
  80066e:	83 ee 01             	sub    $0x1,%esi
  800671:	79 9c                	jns    80060f <vprintfmt+0x1fe>
  800673:	89 df                	mov    %ebx,%edi
  800675:	8b 75 08             	mov    0x8(%ebp),%esi
  800678:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80067b:	eb 18                	jmp    800695 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80067d:	83 ec 08             	sub    $0x8,%esp
  800680:	53                   	push   %ebx
  800681:	6a 20                	push   $0x20
  800683:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800685:	83 ef 01             	sub    $0x1,%edi
  800688:	83 c4 10             	add    $0x10,%esp
  80068b:	eb 08                	jmp    800695 <vprintfmt+0x284>
  80068d:	89 df                	mov    %ebx,%edi
  80068f:	8b 75 08             	mov    0x8(%ebp),%esi
  800692:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800695:	85 ff                	test   %edi,%edi
  800697:	7f e4                	jg     80067d <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800699:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80069c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a2:	e9 90 fd ff ff       	jmp    800437 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006a7:	83 f9 01             	cmp    $0x1,%ecx
  8006aa:	7e 19                	jle    8006c5 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8b 50 04             	mov    0x4(%eax),%edx
  8006b2:	8b 00                	mov    (%eax),%eax
  8006b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8d 40 08             	lea    0x8(%eax),%eax
  8006c0:	89 45 14             	mov    %eax,0x14(%ebp)
  8006c3:	eb 38                	jmp    8006fd <vprintfmt+0x2ec>
	else if (lflag)
  8006c5:	85 c9                	test   %ecx,%ecx
  8006c7:	74 1b                	je     8006e4 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8b 00                	mov    (%eax),%eax
  8006ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d1:	89 c1                	mov    %eax,%ecx
  8006d3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006d6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8d 40 04             	lea    0x4(%eax),%eax
  8006df:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e2:	eb 19                	jmp    8006fd <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8b 00                	mov    (%eax),%eax
  8006e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ec:	89 c1                	mov    %eax,%ecx
  8006ee:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8d 40 04             	lea    0x4(%eax),%eax
  8006fa:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006fd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800700:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800703:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800708:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80070c:	0f 89 0e 01 00 00    	jns    800820 <vprintfmt+0x40f>
				putch('-', putdat);
  800712:	83 ec 08             	sub    $0x8,%esp
  800715:	53                   	push   %ebx
  800716:	6a 2d                	push   $0x2d
  800718:	ff d6                	call   *%esi
				num = -(long long) num;
  80071a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80071d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800720:	f7 da                	neg    %edx
  800722:	83 d1 00             	adc    $0x0,%ecx
  800725:	f7 d9                	neg    %ecx
  800727:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80072a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072f:	e9 ec 00 00 00       	jmp    800820 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800734:	83 f9 01             	cmp    $0x1,%ecx
  800737:	7e 18                	jle    800751 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800739:	8b 45 14             	mov    0x14(%ebp),%eax
  80073c:	8b 10                	mov    (%eax),%edx
  80073e:	8b 48 04             	mov    0x4(%eax),%ecx
  800741:	8d 40 08             	lea    0x8(%eax),%eax
  800744:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800747:	b8 0a 00 00 00       	mov    $0xa,%eax
  80074c:	e9 cf 00 00 00       	jmp    800820 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800751:	85 c9                	test   %ecx,%ecx
  800753:	74 1a                	je     80076f <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800755:	8b 45 14             	mov    0x14(%ebp),%eax
  800758:	8b 10                	mov    (%eax),%edx
  80075a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075f:	8d 40 04             	lea    0x4(%eax),%eax
  800762:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800765:	b8 0a 00 00 00       	mov    $0xa,%eax
  80076a:	e9 b1 00 00 00       	jmp    800820 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80076f:	8b 45 14             	mov    0x14(%ebp),%eax
  800772:	8b 10                	mov    (%eax),%edx
  800774:	b9 00 00 00 00       	mov    $0x0,%ecx
  800779:	8d 40 04             	lea    0x4(%eax),%eax
  80077c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80077f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800784:	e9 97 00 00 00       	jmp    800820 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800789:	83 ec 08             	sub    $0x8,%esp
  80078c:	53                   	push   %ebx
  80078d:	6a 58                	push   $0x58
  80078f:	ff d6                	call   *%esi
			putch('X', putdat);
  800791:	83 c4 08             	add    $0x8,%esp
  800794:	53                   	push   %ebx
  800795:	6a 58                	push   $0x58
  800797:	ff d6                	call   *%esi
			putch('X', putdat);
  800799:	83 c4 08             	add    $0x8,%esp
  80079c:	53                   	push   %ebx
  80079d:	6a 58                	push   $0x58
  80079f:	ff d6                	call   *%esi
			break;
  8007a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8007a7:	e9 8b fc ff ff       	jmp    800437 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8007ac:	83 ec 08             	sub    $0x8,%esp
  8007af:	53                   	push   %ebx
  8007b0:	6a 30                	push   $0x30
  8007b2:	ff d6                	call   *%esi
			putch('x', putdat);
  8007b4:	83 c4 08             	add    $0x8,%esp
  8007b7:	53                   	push   %ebx
  8007b8:	6a 78                	push   $0x78
  8007ba:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bf:	8b 10                	mov    (%eax),%edx
  8007c1:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007c6:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007c9:	8d 40 04             	lea    0x4(%eax),%eax
  8007cc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007cf:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007d4:	eb 4a                	jmp    800820 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007d6:	83 f9 01             	cmp    $0x1,%ecx
  8007d9:	7e 15                	jle    8007f0 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8007db:	8b 45 14             	mov    0x14(%ebp),%eax
  8007de:	8b 10                	mov    (%eax),%edx
  8007e0:	8b 48 04             	mov    0x4(%eax),%ecx
  8007e3:	8d 40 08             	lea    0x8(%eax),%eax
  8007e6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007e9:	b8 10 00 00 00       	mov    $0x10,%eax
  8007ee:	eb 30                	jmp    800820 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007f0:	85 c9                	test   %ecx,%ecx
  8007f2:	74 17                	je     80080b <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8007f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f7:	8b 10                	mov    (%eax),%edx
  8007f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007fe:	8d 40 04             	lea    0x4(%eax),%eax
  800801:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800804:	b8 10 00 00 00       	mov    $0x10,%eax
  800809:	eb 15                	jmp    800820 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80080b:	8b 45 14             	mov    0x14(%ebp),%eax
  80080e:	8b 10                	mov    (%eax),%edx
  800810:	b9 00 00 00 00       	mov    $0x0,%ecx
  800815:	8d 40 04             	lea    0x4(%eax),%eax
  800818:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80081b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800820:	83 ec 0c             	sub    $0xc,%esp
  800823:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800827:	57                   	push   %edi
  800828:	ff 75 e0             	pushl  -0x20(%ebp)
  80082b:	50                   	push   %eax
  80082c:	51                   	push   %ecx
  80082d:	52                   	push   %edx
  80082e:	89 da                	mov    %ebx,%edx
  800830:	89 f0                	mov    %esi,%eax
  800832:	e8 f1 fa ff ff       	call   800328 <printnum>
			break;
  800837:	83 c4 20             	add    $0x20,%esp
  80083a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80083d:	e9 f5 fb ff ff       	jmp    800437 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800842:	83 ec 08             	sub    $0x8,%esp
  800845:	53                   	push   %ebx
  800846:	52                   	push   %edx
  800847:	ff d6                	call   *%esi
			break;
  800849:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80084f:	e9 e3 fb ff ff       	jmp    800437 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800854:	83 ec 08             	sub    $0x8,%esp
  800857:	53                   	push   %ebx
  800858:	6a 25                	push   $0x25
  80085a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80085c:	83 c4 10             	add    $0x10,%esp
  80085f:	eb 03                	jmp    800864 <vprintfmt+0x453>
  800861:	83 ef 01             	sub    $0x1,%edi
  800864:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800868:	75 f7                	jne    800861 <vprintfmt+0x450>
  80086a:	e9 c8 fb ff ff       	jmp    800437 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80086f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5f                   	pop    %edi
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	83 ec 18             	sub    $0x18,%esp
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800883:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800886:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80088a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80088d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800894:	85 c0                	test   %eax,%eax
  800896:	74 26                	je     8008be <vsnprintf+0x47>
  800898:	85 d2                	test   %edx,%edx
  80089a:	7e 22                	jle    8008be <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80089c:	ff 75 14             	pushl  0x14(%ebp)
  80089f:	ff 75 10             	pushl  0x10(%ebp)
  8008a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a5:	50                   	push   %eax
  8008a6:	68 d7 03 80 00       	push   $0x8003d7
  8008ab:	e8 61 fb ff ff       	call   800411 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008b3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b9:	83 c4 10             	add    $0x10,%esp
  8008bc:	eb 05                	jmp    8008c3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008c3:	c9                   	leave  
  8008c4:	c3                   	ret    

008008c5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008cb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ce:	50                   	push   %eax
  8008cf:	ff 75 10             	pushl  0x10(%ebp)
  8008d2:	ff 75 0c             	pushl  0xc(%ebp)
  8008d5:	ff 75 08             	pushl  0x8(%ebp)
  8008d8:	e8 9a ff ff ff       	call   800877 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008dd:	c9                   	leave  
  8008de:	c3                   	ret    

008008df <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ea:	eb 03                	jmp    8008ef <strlen+0x10>
		n++;
  8008ec:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ef:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008f3:	75 f7                	jne    8008ec <strlen+0xd>
		n++;
	return n;
}
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800900:	ba 00 00 00 00       	mov    $0x0,%edx
  800905:	eb 03                	jmp    80090a <strnlen+0x13>
		n++;
  800907:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80090a:	39 c2                	cmp    %eax,%edx
  80090c:	74 08                	je     800916 <strnlen+0x1f>
  80090e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800912:	75 f3                	jne    800907 <strnlen+0x10>
  800914:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	53                   	push   %ebx
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800922:	89 c2                	mov    %eax,%edx
  800924:	83 c2 01             	add    $0x1,%edx
  800927:	83 c1 01             	add    $0x1,%ecx
  80092a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80092e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800931:	84 db                	test   %bl,%bl
  800933:	75 ef                	jne    800924 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800935:	5b                   	pop    %ebx
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	53                   	push   %ebx
  80093c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80093f:	53                   	push   %ebx
  800940:	e8 9a ff ff ff       	call   8008df <strlen>
  800945:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800948:	ff 75 0c             	pushl  0xc(%ebp)
  80094b:	01 d8                	add    %ebx,%eax
  80094d:	50                   	push   %eax
  80094e:	e8 c5 ff ff ff       	call   800918 <strcpy>
	return dst;
}
  800953:	89 d8                	mov    %ebx,%eax
  800955:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800958:	c9                   	leave  
  800959:	c3                   	ret    

0080095a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	56                   	push   %esi
  80095e:	53                   	push   %ebx
  80095f:	8b 75 08             	mov    0x8(%ebp),%esi
  800962:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800965:	89 f3                	mov    %esi,%ebx
  800967:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80096a:	89 f2                	mov    %esi,%edx
  80096c:	eb 0f                	jmp    80097d <strncpy+0x23>
		*dst++ = *src;
  80096e:	83 c2 01             	add    $0x1,%edx
  800971:	0f b6 01             	movzbl (%ecx),%eax
  800974:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800977:	80 39 01             	cmpb   $0x1,(%ecx)
  80097a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80097d:	39 da                	cmp    %ebx,%edx
  80097f:	75 ed                	jne    80096e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800981:	89 f0                	mov    %esi,%eax
  800983:	5b                   	pop    %ebx
  800984:	5e                   	pop    %esi
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	56                   	push   %esi
  80098b:	53                   	push   %ebx
  80098c:	8b 75 08             	mov    0x8(%ebp),%esi
  80098f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800992:	8b 55 10             	mov    0x10(%ebp),%edx
  800995:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800997:	85 d2                	test   %edx,%edx
  800999:	74 21                	je     8009bc <strlcpy+0x35>
  80099b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80099f:	89 f2                	mov    %esi,%edx
  8009a1:	eb 09                	jmp    8009ac <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009a3:	83 c2 01             	add    $0x1,%edx
  8009a6:	83 c1 01             	add    $0x1,%ecx
  8009a9:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009ac:	39 c2                	cmp    %eax,%edx
  8009ae:	74 09                	je     8009b9 <strlcpy+0x32>
  8009b0:	0f b6 19             	movzbl (%ecx),%ebx
  8009b3:	84 db                	test   %bl,%bl
  8009b5:	75 ec                	jne    8009a3 <strlcpy+0x1c>
  8009b7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009b9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009bc:	29 f0                	sub    %esi,%eax
}
  8009be:	5b                   	pop    %ebx
  8009bf:	5e                   	pop    %esi
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009cb:	eb 06                	jmp    8009d3 <strcmp+0x11>
		p++, q++;
  8009cd:	83 c1 01             	add    $0x1,%ecx
  8009d0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009d3:	0f b6 01             	movzbl (%ecx),%eax
  8009d6:	84 c0                	test   %al,%al
  8009d8:	74 04                	je     8009de <strcmp+0x1c>
  8009da:	3a 02                	cmp    (%edx),%al
  8009dc:	74 ef                	je     8009cd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009de:	0f b6 c0             	movzbl %al,%eax
  8009e1:	0f b6 12             	movzbl (%edx),%edx
  8009e4:	29 d0                	sub    %edx,%eax
}
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	53                   	push   %ebx
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f2:	89 c3                	mov    %eax,%ebx
  8009f4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009f7:	eb 06                	jmp    8009ff <strncmp+0x17>
		n--, p++, q++;
  8009f9:	83 c0 01             	add    $0x1,%eax
  8009fc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009ff:	39 d8                	cmp    %ebx,%eax
  800a01:	74 15                	je     800a18 <strncmp+0x30>
  800a03:	0f b6 08             	movzbl (%eax),%ecx
  800a06:	84 c9                	test   %cl,%cl
  800a08:	74 04                	je     800a0e <strncmp+0x26>
  800a0a:	3a 0a                	cmp    (%edx),%cl
  800a0c:	74 eb                	je     8009f9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0e:	0f b6 00             	movzbl (%eax),%eax
  800a11:	0f b6 12             	movzbl (%edx),%edx
  800a14:	29 d0                	sub    %edx,%eax
  800a16:	eb 05                	jmp    800a1d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a18:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a1d:	5b                   	pop    %ebx
  800a1e:	5d                   	pop    %ebp
  800a1f:	c3                   	ret    

00800a20 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a2a:	eb 07                	jmp    800a33 <strchr+0x13>
		if (*s == c)
  800a2c:	38 ca                	cmp    %cl,%dl
  800a2e:	74 0f                	je     800a3f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a30:	83 c0 01             	add    $0x1,%eax
  800a33:	0f b6 10             	movzbl (%eax),%edx
  800a36:	84 d2                	test   %dl,%dl
  800a38:	75 f2                	jne    800a2c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a4b:	eb 03                	jmp    800a50 <strfind+0xf>
  800a4d:	83 c0 01             	add    $0x1,%eax
  800a50:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a53:	38 ca                	cmp    %cl,%dl
  800a55:	74 04                	je     800a5b <strfind+0x1a>
  800a57:	84 d2                	test   %dl,%dl
  800a59:	75 f2                	jne    800a4d <strfind+0xc>
			break;
	return (char *) s;
}
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	57                   	push   %edi
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
  800a63:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a66:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a69:	85 c9                	test   %ecx,%ecx
  800a6b:	74 36                	je     800aa3 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a6d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a73:	75 28                	jne    800a9d <memset+0x40>
  800a75:	f6 c1 03             	test   $0x3,%cl
  800a78:	75 23                	jne    800a9d <memset+0x40>
		c &= 0xFF;
  800a7a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a7e:	89 d3                	mov    %edx,%ebx
  800a80:	c1 e3 08             	shl    $0x8,%ebx
  800a83:	89 d6                	mov    %edx,%esi
  800a85:	c1 e6 18             	shl    $0x18,%esi
  800a88:	89 d0                	mov    %edx,%eax
  800a8a:	c1 e0 10             	shl    $0x10,%eax
  800a8d:	09 f0                	or     %esi,%eax
  800a8f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a91:	89 d8                	mov    %ebx,%eax
  800a93:	09 d0                	or     %edx,%eax
  800a95:	c1 e9 02             	shr    $0x2,%ecx
  800a98:	fc                   	cld    
  800a99:	f3 ab                	rep stos %eax,%es:(%edi)
  800a9b:	eb 06                	jmp    800aa3 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa0:	fc                   	cld    
  800aa1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aa3:	89 f8                	mov    %edi,%eax
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5f                   	pop    %edi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	57                   	push   %edi
  800aae:	56                   	push   %esi
  800aaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab8:	39 c6                	cmp    %eax,%esi
  800aba:	73 35                	jae    800af1 <memmove+0x47>
  800abc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800abf:	39 d0                	cmp    %edx,%eax
  800ac1:	73 2e                	jae    800af1 <memmove+0x47>
		s += n;
		d += n;
  800ac3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac6:	89 d6                	mov    %edx,%esi
  800ac8:	09 fe                	or     %edi,%esi
  800aca:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ad0:	75 13                	jne    800ae5 <memmove+0x3b>
  800ad2:	f6 c1 03             	test   $0x3,%cl
  800ad5:	75 0e                	jne    800ae5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ad7:	83 ef 04             	sub    $0x4,%edi
  800ada:	8d 72 fc             	lea    -0x4(%edx),%esi
  800add:	c1 e9 02             	shr    $0x2,%ecx
  800ae0:	fd                   	std    
  800ae1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae3:	eb 09                	jmp    800aee <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ae5:	83 ef 01             	sub    $0x1,%edi
  800ae8:	8d 72 ff             	lea    -0x1(%edx),%esi
  800aeb:	fd                   	std    
  800aec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aee:	fc                   	cld    
  800aef:	eb 1d                	jmp    800b0e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af1:	89 f2                	mov    %esi,%edx
  800af3:	09 c2                	or     %eax,%edx
  800af5:	f6 c2 03             	test   $0x3,%dl
  800af8:	75 0f                	jne    800b09 <memmove+0x5f>
  800afa:	f6 c1 03             	test   $0x3,%cl
  800afd:	75 0a                	jne    800b09 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800aff:	c1 e9 02             	shr    $0x2,%ecx
  800b02:	89 c7                	mov    %eax,%edi
  800b04:	fc                   	cld    
  800b05:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b07:	eb 05                	jmp    800b0e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b09:	89 c7                	mov    %eax,%edi
  800b0b:	fc                   	cld    
  800b0c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b15:	ff 75 10             	pushl  0x10(%ebp)
  800b18:	ff 75 0c             	pushl  0xc(%ebp)
  800b1b:	ff 75 08             	pushl  0x8(%ebp)
  800b1e:	e8 87 ff ff ff       	call   800aaa <memmove>
}
  800b23:	c9                   	leave  
  800b24:	c3                   	ret    

00800b25 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
  800b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b30:	89 c6                	mov    %eax,%esi
  800b32:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b35:	eb 1a                	jmp    800b51 <memcmp+0x2c>
		if (*s1 != *s2)
  800b37:	0f b6 08             	movzbl (%eax),%ecx
  800b3a:	0f b6 1a             	movzbl (%edx),%ebx
  800b3d:	38 d9                	cmp    %bl,%cl
  800b3f:	74 0a                	je     800b4b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b41:	0f b6 c1             	movzbl %cl,%eax
  800b44:	0f b6 db             	movzbl %bl,%ebx
  800b47:	29 d8                	sub    %ebx,%eax
  800b49:	eb 0f                	jmp    800b5a <memcmp+0x35>
		s1++, s2++;
  800b4b:	83 c0 01             	add    $0x1,%eax
  800b4e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b51:	39 f0                	cmp    %esi,%eax
  800b53:	75 e2                	jne    800b37 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b55:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	53                   	push   %ebx
  800b62:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b65:	89 c1                	mov    %eax,%ecx
  800b67:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b6a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b6e:	eb 0a                	jmp    800b7a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b70:	0f b6 10             	movzbl (%eax),%edx
  800b73:	39 da                	cmp    %ebx,%edx
  800b75:	74 07                	je     800b7e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b77:	83 c0 01             	add    $0x1,%eax
  800b7a:	39 c8                	cmp    %ecx,%eax
  800b7c:	72 f2                	jb     800b70 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b7e:	5b                   	pop    %ebx
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	57                   	push   %edi
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
  800b87:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8d:	eb 03                	jmp    800b92 <strtol+0x11>
		s++;
  800b8f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b92:	0f b6 01             	movzbl (%ecx),%eax
  800b95:	3c 20                	cmp    $0x20,%al
  800b97:	74 f6                	je     800b8f <strtol+0xe>
  800b99:	3c 09                	cmp    $0x9,%al
  800b9b:	74 f2                	je     800b8f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b9d:	3c 2b                	cmp    $0x2b,%al
  800b9f:	75 0a                	jne    800bab <strtol+0x2a>
		s++;
  800ba1:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ba4:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba9:	eb 11                	jmp    800bbc <strtol+0x3b>
  800bab:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bb0:	3c 2d                	cmp    $0x2d,%al
  800bb2:	75 08                	jne    800bbc <strtol+0x3b>
		s++, neg = 1;
  800bb4:	83 c1 01             	add    $0x1,%ecx
  800bb7:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bbc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bc2:	75 15                	jne    800bd9 <strtol+0x58>
  800bc4:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc7:	75 10                	jne    800bd9 <strtol+0x58>
  800bc9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bcd:	75 7c                	jne    800c4b <strtol+0xca>
		s += 2, base = 16;
  800bcf:	83 c1 02             	add    $0x2,%ecx
  800bd2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bd7:	eb 16                	jmp    800bef <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bd9:	85 db                	test   %ebx,%ebx
  800bdb:	75 12                	jne    800bef <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bdd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800be2:	80 39 30             	cmpb   $0x30,(%ecx)
  800be5:	75 08                	jne    800bef <strtol+0x6e>
		s++, base = 8;
  800be7:	83 c1 01             	add    $0x1,%ecx
  800bea:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bef:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bf7:	0f b6 11             	movzbl (%ecx),%edx
  800bfa:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bfd:	89 f3                	mov    %esi,%ebx
  800bff:	80 fb 09             	cmp    $0x9,%bl
  800c02:	77 08                	ja     800c0c <strtol+0x8b>
			dig = *s - '0';
  800c04:	0f be d2             	movsbl %dl,%edx
  800c07:	83 ea 30             	sub    $0x30,%edx
  800c0a:	eb 22                	jmp    800c2e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c0c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c0f:	89 f3                	mov    %esi,%ebx
  800c11:	80 fb 19             	cmp    $0x19,%bl
  800c14:	77 08                	ja     800c1e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c16:	0f be d2             	movsbl %dl,%edx
  800c19:	83 ea 57             	sub    $0x57,%edx
  800c1c:	eb 10                	jmp    800c2e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c1e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c21:	89 f3                	mov    %esi,%ebx
  800c23:	80 fb 19             	cmp    $0x19,%bl
  800c26:	77 16                	ja     800c3e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c28:	0f be d2             	movsbl %dl,%edx
  800c2b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c2e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c31:	7d 0b                	jge    800c3e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c33:	83 c1 01             	add    $0x1,%ecx
  800c36:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c3a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c3c:	eb b9                	jmp    800bf7 <strtol+0x76>

	if (endptr)
  800c3e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c42:	74 0d                	je     800c51 <strtol+0xd0>
		*endptr = (char *) s;
  800c44:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c47:	89 0e                	mov    %ecx,(%esi)
  800c49:	eb 06                	jmp    800c51 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c4b:	85 db                	test   %ebx,%ebx
  800c4d:	74 98                	je     800be7 <strtol+0x66>
  800c4f:	eb 9e                	jmp    800bef <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c51:	89 c2                	mov    %eax,%edx
  800c53:	f7 da                	neg    %edx
  800c55:	85 ff                	test   %edi,%edi
  800c57:	0f 45 c2             	cmovne %edx,%eax
}
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c65:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c70:	89 c3                	mov    %eax,%ebx
  800c72:	89 c7                	mov    %eax,%edi
  800c74:	89 c6                	mov    %eax,%esi
  800c76:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <sys_cgetc>:

int
sys_cgetc(void)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	ba 00 00 00 00       	mov    $0x0,%edx
  800c88:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8d:	89 d1                	mov    %edx,%ecx
  800c8f:	89 d3                	mov    %edx,%ebx
  800c91:	89 d7                	mov    %edx,%edi
  800c93:	89 d6                	mov    %edx,%esi
  800c95:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800caa:	b8 03 00 00 00       	mov    $0x3,%eax
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	89 cb                	mov    %ecx,%ebx
  800cb4:	89 cf                	mov    %ecx,%edi
  800cb6:	89 ce                	mov    %ecx,%esi
  800cb8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cba:	85 c0                	test   %eax,%eax
  800cbc:	7e 17                	jle    800cd5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbe:	83 ec 0c             	sub    $0xc,%esp
  800cc1:	50                   	push   %eax
  800cc2:	6a 03                	push   $0x3
  800cc4:	68 1f 28 80 00       	push   $0x80281f
  800cc9:	6a 23                	push   $0x23
  800ccb:	68 3c 28 80 00       	push   $0x80283c
  800cd0:	e8 66 f5 ff ff       	call   80023b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd8:	5b                   	pop    %ebx
  800cd9:	5e                   	pop    %esi
  800cda:	5f                   	pop    %edi
  800cdb:	5d                   	pop    %ebp
  800cdc:	c3                   	ret    

00800cdd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	57                   	push   %edi
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce8:	b8 02 00 00 00       	mov    $0x2,%eax
  800ced:	89 d1                	mov    %edx,%ecx
  800cef:	89 d3                	mov    %edx,%ebx
  800cf1:	89 d7                	mov    %edx,%edi
  800cf3:	89 d6                	mov    %edx,%esi
  800cf5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <sys_yield>:

void
sys_yield(void)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	57                   	push   %edi
  800d00:	56                   	push   %esi
  800d01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	ba 00 00 00 00       	mov    $0x0,%edx
  800d07:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d0c:	89 d1                	mov    %edx,%ecx
  800d0e:	89 d3                	mov    %edx,%ebx
  800d10:	89 d7                	mov    %edx,%edi
  800d12:	89 d6                	mov    %edx,%esi
  800d14:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
  800d21:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d24:	be 00 00 00 00       	mov    $0x0,%esi
  800d29:	b8 04 00 00 00       	mov    $0x4,%eax
  800d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d31:	8b 55 08             	mov    0x8(%ebp),%edx
  800d34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d37:	89 f7                	mov    %esi,%edi
  800d39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	7e 17                	jle    800d56 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	50                   	push   %eax
  800d43:	6a 04                	push   $0x4
  800d45:	68 1f 28 80 00       	push   $0x80281f
  800d4a:	6a 23                	push   $0x23
  800d4c:	68 3c 28 80 00       	push   $0x80283c
  800d51:	e8 e5 f4 ff ff       	call   80023b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d67:	b8 05 00 00 00       	mov    $0x5,%eax
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d75:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d78:	8b 75 18             	mov    0x18(%ebp),%esi
  800d7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7e 17                	jle    800d98 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	50                   	push   %eax
  800d85:	6a 05                	push   $0x5
  800d87:	68 1f 28 80 00       	push   $0x80281f
  800d8c:	6a 23                	push   $0x23
  800d8e:	68 3c 28 80 00       	push   $0x80283c
  800d93:	e8 a3 f4 ff ff       	call   80023b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dae:	b8 06 00 00 00       	mov    $0x6,%eax
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	89 df                	mov    %ebx,%edi
  800dbb:	89 de                	mov    %ebx,%esi
  800dbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7e 17                	jle    800dda <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	83 ec 0c             	sub    $0xc,%esp
  800dc6:	50                   	push   %eax
  800dc7:	6a 06                	push   $0x6
  800dc9:	68 1f 28 80 00       	push   $0x80281f
  800dce:	6a 23                	push   $0x23
  800dd0:	68 3c 28 80 00       	push   $0x80283c
  800dd5:	e8 61 f4 ff ff       	call   80023b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800deb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df0:	b8 08 00 00 00       	mov    $0x8,%eax
  800df5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfb:	89 df                	mov    %ebx,%edi
  800dfd:	89 de                	mov    %ebx,%esi
  800dff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e01:	85 c0                	test   %eax,%eax
  800e03:	7e 17                	jle    800e1c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e05:	83 ec 0c             	sub    $0xc,%esp
  800e08:	50                   	push   %eax
  800e09:	6a 08                	push   $0x8
  800e0b:	68 1f 28 80 00       	push   $0x80281f
  800e10:	6a 23                	push   $0x23
  800e12:	68 3c 28 80 00       	push   $0x80283c
  800e17:	e8 1f f4 ff ff       	call   80023b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	57                   	push   %edi
  800e28:	56                   	push   %esi
  800e29:	53                   	push   %ebx
  800e2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e32:	b8 09 00 00 00       	mov    $0x9,%eax
  800e37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3d:	89 df                	mov    %ebx,%edi
  800e3f:	89 de                	mov    %ebx,%esi
  800e41:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e43:	85 c0                	test   %eax,%eax
  800e45:	7e 17                	jle    800e5e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e47:	83 ec 0c             	sub    $0xc,%esp
  800e4a:	50                   	push   %eax
  800e4b:	6a 09                	push   $0x9
  800e4d:	68 1f 28 80 00       	push   $0x80281f
  800e52:	6a 23                	push   $0x23
  800e54:	68 3c 28 80 00       	push   $0x80283c
  800e59:	e8 dd f3 ff ff       	call   80023b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e61:	5b                   	pop    %ebx
  800e62:	5e                   	pop    %esi
  800e63:	5f                   	pop    %edi
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    

00800e66 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	57                   	push   %edi
  800e6a:	56                   	push   %esi
  800e6b:	53                   	push   %ebx
  800e6c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e74:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7f:	89 df                	mov    %ebx,%edi
  800e81:	89 de                	mov    %ebx,%esi
  800e83:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e85:	85 c0                	test   %eax,%eax
  800e87:	7e 17                	jle    800ea0 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e89:	83 ec 0c             	sub    $0xc,%esp
  800e8c:	50                   	push   %eax
  800e8d:	6a 0a                	push   $0xa
  800e8f:	68 1f 28 80 00       	push   $0x80281f
  800e94:	6a 23                	push   $0x23
  800e96:	68 3c 28 80 00       	push   $0x80283c
  800e9b:	e8 9b f3 ff ff       	call   80023b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ea0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    

00800ea8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	57                   	push   %edi
  800eac:	56                   	push   %esi
  800ead:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eae:	be 00 00 00 00       	mov    $0x0,%esi
  800eb3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ec6:	5b                   	pop    %ebx
  800ec7:	5e                   	pop    %esi
  800ec8:	5f                   	pop    %edi
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	57                   	push   %edi
  800ecf:	56                   	push   %esi
  800ed0:	53                   	push   %ebx
  800ed1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ede:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee1:	89 cb                	mov    %ecx,%ebx
  800ee3:	89 cf                	mov    %ecx,%edi
  800ee5:	89 ce                	mov    %ecx,%esi
  800ee7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee9:	85 c0                	test   %eax,%eax
  800eeb:	7e 17                	jle    800f04 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eed:	83 ec 0c             	sub    $0xc,%esp
  800ef0:	50                   	push   %eax
  800ef1:	6a 0d                	push   $0xd
  800ef3:	68 1f 28 80 00       	push   $0x80281f
  800ef8:	6a 23                	push   $0x23
  800efa:	68 3c 28 80 00       	push   $0x80283c
  800eff:	e8 37 f3 ff ff       	call   80023b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f07:	5b                   	pop    %ebx
  800f08:	5e                   	pop    %esi
  800f09:	5f                   	pop    %edi
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	57                   	push   %edi
  800f10:	56                   	push   %esi
  800f11:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f12:	ba 00 00 00 00       	mov    $0x0,%edx
  800f17:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f1c:	89 d1                	mov    %edx,%ecx
  800f1e:	89 d3                	mov    %edx,%ebx
  800f20:	89 d7                	mov    %edx,%edi
  800f22:	89 d6                	mov    %edx,%esi
  800f24:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f26:	5b                   	pop    %ebx
  800f27:	5e                   	pop    %esi
  800f28:	5f                   	pop    %edi
  800f29:	5d                   	pop    %ebp
  800f2a:	c3                   	ret    

00800f2b <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	57                   	push   %edi
  800f2f:	56                   	push   %esi
  800f30:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f31:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f36:	b8 10 00 00 00       	mov    $0x10,%eax
  800f3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3e:	89 cb                	mov    %ecx,%ebx
  800f40:	89 cf                	mov    %ecx,%edi
  800f42:	89 ce                	mov    %ecx,%esi
  800f44:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800f46:	5b                   	pop    %ebx
  800f47:	5e                   	pop    %esi
  800f48:	5f                   	pop    %edi
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    

00800f4b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f51:	05 00 00 00 30       	add    $0x30000000,%eax
  800f56:	c1 e8 0c             	shr    $0xc,%eax
}
  800f59:	5d                   	pop    %ebp
  800f5a:	c3                   	ret    

00800f5b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f61:	05 00 00 00 30       	add    $0x30000000,%eax
  800f66:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f6b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f70:	5d                   	pop    %ebp
  800f71:	c3                   	ret    

00800f72 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f78:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f7d:	89 c2                	mov    %eax,%edx
  800f7f:	c1 ea 16             	shr    $0x16,%edx
  800f82:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f89:	f6 c2 01             	test   $0x1,%dl
  800f8c:	74 11                	je     800f9f <fd_alloc+0x2d>
  800f8e:	89 c2                	mov    %eax,%edx
  800f90:	c1 ea 0c             	shr    $0xc,%edx
  800f93:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f9a:	f6 c2 01             	test   $0x1,%dl
  800f9d:	75 09                	jne    800fa8 <fd_alloc+0x36>
			*fd_store = fd;
  800f9f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fa1:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa6:	eb 17                	jmp    800fbf <fd_alloc+0x4d>
  800fa8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800fad:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fb2:	75 c9                	jne    800f7d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800fb4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800fba:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fbf:	5d                   	pop    %ebp
  800fc0:	c3                   	ret    

00800fc1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fc1:	55                   	push   %ebp
  800fc2:	89 e5                	mov    %esp,%ebp
  800fc4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fc7:	83 f8 1f             	cmp    $0x1f,%eax
  800fca:	77 36                	ja     801002 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fcc:	c1 e0 0c             	shl    $0xc,%eax
  800fcf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fd4:	89 c2                	mov    %eax,%edx
  800fd6:	c1 ea 16             	shr    $0x16,%edx
  800fd9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fe0:	f6 c2 01             	test   $0x1,%dl
  800fe3:	74 24                	je     801009 <fd_lookup+0x48>
  800fe5:	89 c2                	mov    %eax,%edx
  800fe7:	c1 ea 0c             	shr    $0xc,%edx
  800fea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ff1:	f6 c2 01             	test   $0x1,%dl
  800ff4:	74 1a                	je     801010 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ff6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ff9:	89 02                	mov    %eax,(%edx)
	return 0;
  800ffb:	b8 00 00 00 00       	mov    $0x0,%eax
  801000:	eb 13                	jmp    801015 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801002:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801007:	eb 0c                	jmp    801015 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801009:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80100e:	eb 05                	jmp    801015 <fd_lookup+0x54>
  801010:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801015:	5d                   	pop    %ebp
  801016:	c3                   	ret    

00801017 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	83 ec 08             	sub    $0x8,%esp
  80101d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801020:	ba cc 28 80 00       	mov    $0x8028cc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801025:	eb 13                	jmp    80103a <dev_lookup+0x23>
  801027:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80102a:	39 08                	cmp    %ecx,(%eax)
  80102c:	75 0c                	jne    80103a <dev_lookup+0x23>
			*dev = devtab[i];
  80102e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801031:	89 01                	mov    %eax,(%ecx)
			return 0;
  801033:	b8 00 00 00 00       	mov    $0x0,%eax
  801038:	eb 2e                	jmp    801068 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80103a:	8b 02                	mov    (%edx),%eax
  80103c:	85 c0                	test   %eax,%eax
  80103e:	75 e7                	jne    801027 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801040:	a1 08 40 80 00       	mov    0x804008,%eax
  801045:	8b 40 48             	mov    0x48(%eax),%eax
  801048:	83 ec 04             	sub    $0x4,%esp
  80104b:	51                   	push   %ecx
  80104c:	50                   	push   %eax
  80104d:	68 4c 28 80 00       	push   $0x80284c
  801052:	e8 bd f2 ff ff       	call   800314 <cprintf>
	*dev = 0;
  801057:	8b 45 0c             	mov    0xc(%ebp),%eax
  80105a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801060:	83 c4 10             	add    $0x10,%esp
  801063:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801068:	c9                   	leave  
  801069:	c3                   	ret    

0080106a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	56                   	push   %esi
  80106e:	53                   	push   %ebx
  80106f:	83 ec 10             	sub    $0x10,%esp
  801072:	8b 75 08             	mov    0x8(%ebp),%esi
  801075:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801078:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80107b:	50                   	push   %eax
  80107c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801082:	c1 e8 0c             	shr    $0xc,%eax
  801085:	50                   	push   %eax
  801086:	e8 36 ff ff ff       	call   800fc1 <fd_lookup>
  80108b:	83 c4 08             	add    $0x8,%esp
  80108e:	85 c0                	test   %eax,%eax
  801090:	78 05                	js     801097 <fd_close+0x2d>
	    || fd != fd2)
  801092:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801095:	74 0c                	je     8010a3 <fd_close+0x39>
		return (must_exist ? r : 0);
  801097:	84 db                	test   %bl,%bl
  801099:	ba 00 00 00 00       	mov    $0x0,%edx
  80109e:	0f 44 c2             	cmove  %edx,%eax
  8010a1:	eb 41                	jmp    8010e4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010a3:	83 ec 08             	sub    $0x8,%esp
  8010a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010a9:	50                   	push   %eax
  8010aa:	ff 36                	pushl  (%esi)
  8010ac:	e8 66 ff ff ff       	call   801017 <dev_lookup>
  8010b1:	89 c3                	mov    %eax,%ebx
  8010b3:	83 c4 10             	add    $0x10,%esp
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	78 1a                	js     8010d4 <fd_close+0x6a>
		if (dev->dev_close)
  8010ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010bd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8010c0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	74 0b                	je     8010d4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010c9:	83 ec 0c             	sub    $0xc,%esp
  8010cc:	56                   	push   %esi
  8010cd:	ff d0                	call   *%eax
  8010cf:	89 c3                	mov    %eax,%ebx
  8010d1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010d4:	83 ec 08             	sub    $0x8,%esp
  8010d7:	56                   	push   %esi
  8010d8:	6a 00                	push   $0x0
  8010da:	e8 c1 fc ff ff       	call   800da0 <sys_page_unmap>
	return r;
  8010df:	83 c4 10             	add    $0x10,%esp
  8010e2:	89 d8                	mov    %ebx,%eax
}
  8010e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010e7:	5b                   	pop    %ebx
  8010e8:	5e                   	pop    %esi
  8010e9:	5d                   	pop    %ebp
  8010ea:	c3                   	ret    

008010eb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f4:	50                   	push   %eax
  8010f5:	ff 75 08             	pushl  0x8(%ebp)
  8010f8:	e8 c4 fe ff ff       	call   800fc1 <fd_lookup>
  8010fd:	83 c4 08             	add    $0x8,%esp
  801100:	85 c0                	test   %eax,%eax
  801102:	78 10                	js     801114 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801104:	83 ec 08             	sub    $0x8,%esp
  801107:	6a 01                	push   $0x1
  801109:	ff 75 f4             	pushl  -0xc(%ebp)
  80110c:	e8 59 ff ff ff       	call   80106a <fd_close>
  801111:	83 c4 10             	add    $0x10,%esp
}
  801114:	c9                   	leave  
  801115:	c3                   	ret    

00801116 <close_all>:

void
close_all(void)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	53                   	push   %ebx
  80111a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80111d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801122:	83 ec 0c             	sub    $0xc,%esp
  801125:	53                   	push   %ebx
  801126:	e8 c0 ff ff ff       	call   8010eb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80112b:	83 c3 01             	add    $0x1,%ebx
  80112e:	83 c4 10             	add    $0x10,%esp
  801131:	83 fb 20             	cmp    $0x20,%ebx
  801134:	75 ec                	jne    801122 <close_all+0xc>
		close(i);
}
  801136:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801139:	c9                   	leave  
  80113a:	c3                   	ret    

0080113b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	57                   	push   %edi
  80113f:	56                   	push   %esi
  801140:	53                   	push   %ebx
  801141:	83 ec 2c             	sub    $0x2c,%esp
  801144:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801147:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80114a:	50                   	push   %eax
  80114b:	ff 75 08             	pushl  0x8(%ebp)
  80114e:	e8 6e fe ff ff       	call   800fc1 <fd_lookup>
  801153:	83 c4 08             	add    $0x8,%esp
  801156:	85 c0                	test   %eax,%eax
  801158:	0f 88 c1 00 00 00    	js     80121f <dup+0xe4>
		return r;
	close(newfdnum);
  80115e:	83 ec 0c             	sub    $0xc,%esp
  801161:	56                   	push   %esi
  801162:	e8 84 ff ff ff       	call   8010eb <close>

	newfd = INDEX2FD(newfdnum);
  801167:	89 f3                	mov    %esi,%ebx
  801169:	c1 e3 0c             	shl    $0xc,%ebx
  80116c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801172:	83 c4 04             	add    $0x4,%esp
  801175:	ff 75 e4             	pushl  -0x1c(%ebp)
  801178:	e8 de fd ff ff       	call   800f5b <fd2data>
  80117d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80117f:	89 1c 24             	mov    %ebx,(%esp)
  801182:	e8 d4 fd ff ff       	call   800f5b <fd2data>
  801187:	83 c4 10             	add    $0x10,%esp
  80118a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80118d:	89 f8                	mov    %edi,%eax
  80118f:	c1 e8 16             	shr    $0x16,%eax
  801192:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801199:	a8 01                	test   $0x1,%al
  80119b:	74 37                	je     8011d4 <dup+0x99>
  80119d:	89 f8                	mov    %edi,%eax
  80119f:	c1 e8 0c             	shr    $0xc,%eax
  8011a2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011a9:	f6 c2 01             	test   $0x1,%dl
  8011ac:	74 26                	je     8011d4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b5:	83 ec 0c             	sub    $0xc,%esp
  8011b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8011bd:	50                   	push   %eax
  8011be:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011c1:	6a 00                	push   $0x0
  8011c3:	57                   	push   %edi
  8011c4:	6a 00                	push   $0x0
  8011c6:	e8 93 fb ff ff       	call   800d5e <sys_page_map>
  8011cb:	89 c7                	mov    %eax,%edi
  8011cd:	83 c4 20             	add    $0x20,%esp
  8011d0:	85 c0                	test   %eax,%eax
  8011d2:	78 2e                	js     801202 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011d7:	89 d0                	mov    %edx,%eax
  8011d9:	c1 e8 0c             	shr    $0xc,%eax
  8011dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011e3:	83 ec 0c             	sub    $0xc,%esp
  8011e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8011eb:	50                   	push   %eax
  8011ec:	53                   	push   %ebx
  8011ed:	6a 00                	push   $0x0
  8011ef:	52                   	push   %edx
  8011f0:	6a 00                	push   $0x0
  8011f2:	e8 67 fb ff ff       	call   800d5e <sys_page_map>
  8011f7:	89 c7                	mov    %eax,%edi
  8011f9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8011fc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011fe:	85 ff                	test   %edi,%edi
  801200:	79 1d                	jns    80121f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801202:	83 ec 08             	sub    $0x8,%esp
  801205:	53                   	push   %ebx
  801206:	6a 00                	push   $0x0
  801208:	e8 93 fb ff ff       	call   800da0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80120d:	83 c4 08             	add    $0x8,%esp
  801210:	ff 75 d4             	pushl  -0x2c(%ebp)
  801213:	6a 00                	push   $0x0
  801215:	e8 86 fb ff ff       	call   800da0 <sys_page_unmap>
	return r;
  80121a:	83 c4 10             	add    $0x10,%esp
  80121d:	89 f8                	mov    %edi,%eax
}
  80121f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801222:	5b                   	pop    %ebx
  801223:	5e                   	pop    %esi
  801224:	5f                   	pop    %edi
  801225:	5d                   	pop    %ebp
  801226:	c3                   	ret    

00801227 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801227:	55                   	push   %ebp
  801228:	89 e5                	mov    %esp,%ebp
  80122a:	53                   	push   %ebx
  80122b:	83 ec 14             	sub    $0x14,%esp
  80122e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801231:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801234:	50                   	push   %eax
  801235:	53                   	push   %ebx
  801236:	e8 86 fd ff ff       	call   800fc1 <fd_lookup>
  80123b:	83 c4 08             	add    $0x8,%esp
  80123e:	89 c2                	mov    %eax,%edx
  801240:	85 c0                	test   %eax,%eax
  801242:	78 6d                	js     8012b1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801244:	83 ec 08             	sub    $0x8,%esp
  801247:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124a:	50                   	push   %eax
  80124b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124e:	ff 30                	pushl  (%eax)
  801250:	e8 c2 fd ff ff       	call   801017 <dev_lookup>
  801255:	83 c4 10             	add    $0x10,%esp
  801258:	85 c0                	test   %eax,%eax
  80125a:	78 4c                	js     8012a8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80125c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80125f:	8b 42 08             	mov    0x8(%edx),%eax
  801262:	83 e0 03             	and    $0x3,%eax
  801265:	83 f8 01             	cmp    $0x1,%eax
  801268:	75 21                	jne    80128b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80126a:	a1 08 40 80 00       	mov    0x804008,%eax
  80126f:	8b 40 48             	mov    0x48(%eax),%eax
  801272:	83 ec 04             	sub    $0x4,%esp
  801275:	53                   	push   %ebx
  801276:	50                   	push   %eax
  801277:	68 90 28 80 00       	push   $0x802890
  80127c:	e8 93 f0 ff ff       	call   800314 <cprintf>
		return -E_INVAL;
  801281:	83 c4 10             	add    $0x10,%esp
  801284:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801289:	eb 26                	jmp    8012b1 <read+0x8a>
	}
	if (!dev->dev_read)
  80128b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128e:	8b 40 08             	mov    0x8(%eax),%eax
  801291:	85 c0                	test   %eax,%eax
  801293:	74 17                	je     8012ac <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801295:	83 ec 04             	sub    $0x4,%esp
  801298:	ff 75 10             	pushl  0x10(%ebp)
  80129b:	ff 75 0c             	pushl  0xc(%ebp)
  80129e:	52                   	push   %edx
  80129f:	ff d0                	call   *%eax
  8012a1:	89 c2                	mov    %eax,%edx
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	eb 09                	jmp    8012b1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a8:	89 c2                	mov    %eax,%edx
  8012aa:	eb 05                	jmp    8012b1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8012b1:	89 d0                	mov    %edx,%eax
  8012b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b6:	c9                   	leave  
  8012b7:	c3                   	ret    

008012b8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	57                   	push   %edi
  8012bc:	56                   	push   %esi
  8012bd:	53                   	push   %ebx
  8012be:	83 ec 0c             	sub    $0xc,%esp
  8012c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012c4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012cc:	eb 21                	jmp    8012ef <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012ce:	83 ec 04             	sub    $0x4,%esp
  8012d1:	89 f0                	mov    %esi,%eax
  8012d3:	29 d8                	sub    %ebx,%eax
  8012d5:	50                   	push   %eax
  8012d6:	89 d8                	mov    %ebx,%eax
  8012d8:	03 45 0c             	add    0xc(%ebp),%eax
  8012db:	50                   	push   %eax
  8012dc:	57                   	push   %edi
  8012dd:	e8 45 ff ff ff       	call   801227 <read>
		if (m < 0)
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	78 10                	js     8012f9 <readn+0x41>
			return m;
		if (m == 0)
  8012e9:	85 c0                	test   %eax,%eax
  8012eb:	74 0a                	je     8012f7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012ed:	01 c3                	add    %eax,%ebx
  8012ef:	39 f3                	cmp    %esi,%ebx
  8012f1:	72 db                	jb     8012ce <readn+0x16>
  8012f3:	89 d8                	mov    %ebx,%eax
  8012f5:	eb 02                	jmp    8012f9 <readn+0x41>
  8012f7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012fc:	5b                   	pop    %ebx
  8012fd:	5e                   	pop    %esi
  8012fe:	5f                   	pop    %edi
  8012ff:	5d                   	pop    %ebp
  801300:	c3                   	ret    

00801301 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801301:	55                   	push   %ebp
  801302:	89 e5                	mov    %esp,%ebp
  801304:	53                   	push   %ebx
  801305:	83 ec 14             	sub    $0x14,%esp
  801308:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130e:	50                   	push   %eax
  80130f:	53                   	push   %ebx
  801310:	e8 ac fc ff ff       	call   800fc1 <fd_lookup>
  801315:	83 c4 08             	add    $0x8,%esp
  801318:	89 c2                	mov    %eax,%edx
  80131a:	85 c0                	test   %eax,%eax
  80131c:	78 68                	js     801386 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131e:	83 ec 08             	sub    $0x8,%esp
  801321:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801324:	50                   	push   %eax
  801325:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801328:	ff 30                	pushl  (%eax)
  80132a:	e8 e8 fc ff ff       	call   801017 <dev_lookup>
  80132f:	83 c4 10             	add    $0x10,%esp
  801332:	85 c0                	test   %eax,%eax
  801334:	78 47                	js     80137d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801336:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801339:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80133d:	75 21                	jne    801360 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80133f:	a1 08 40 80 00       	mov    0x804008,%eax
  801344:	8b 40 48             	mov    0x48(%eax),%eax
  801347:	83 ec 04             	sub    $0x4,%esp
  80134a:	53                   	push   %ebx
  80134b:	50                   	push   %eax
  80134c:	68 ac 28 80 00       	push   $0x8028ac
  801351:	e8 be ef ff ff       	call   800314 <cprintf>
		return -E_INVAL;
  801356:	83 c4 10             	add    $0x10,%esp
  801359:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80135e:	eb 26                	jmp    801386 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801360:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801363:	8b 52 0c             	mov    0xc(%edx),%edx
  801366:	85 d2                	test   %edx,%edx
  801368:	74 17                	je     801381 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80136a:	83 ec 04             	sub    $0x4,%esp
  80136d:	ff 75 10             	pushl  0x10(%ebp)
  801370:	ff 75 0c             	pushl  0xc(%ebp)
  801373:	50                   	push   %eax
  801374:	ff d2                	call   *%edx
  801376:	89 c2                	mov    %eax,%edx
  801378:	83 c4 10             	add    $0x10,%esp
  80137b:	eb 09                	jmp    801386 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80137d:	89 c2                	mov    %eax,%edx
  80137f:	eb 05                	jmp    801386 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801381:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801386:	89 d0                	mov    %edx,%eax
  801388:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138b:	c9                   	leave  
  80138c:	c3                   	ret    

0080138d <seek>:

int
seek(int fdnum, off_t offset)
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801393:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801396:	50                   	push   %eax
  801397:	ff 75 08             	pushl  0x8(%ebp)
  80139a:	e8 22 fc ff ff       	call   800fc1 <fd_lookup>
  80139f:	83 c4 08             	add    $0x8,%esp
  8013a2:	85 c0                	test   %eax,%eax
  8013a4:	78 0e                	js     8013b4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8013a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ac:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013b4:	c9                   	leave  
  8013b5:	c3                   	ret    

008013b6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013b6:	55                   	push   %ebp
  8013b7:	89 e5                	mov    %esp,%ebp
  8013b9:	53                   	push   %ebx
  8013ba:	83 ec 14             	sub    $0x14,%esp
  8013bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c3:	50                   	push   %eax
  8013c4:	53                   	push   %ebx
  8013c5:	e8 f7 fb ff ff       	call   800fc1 <fd_lookup>
  8013ca:	83 c4 08             	add    $0x8,%esp
  8013cd:	89 c2                	mov    %eax,%edx
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	78 65                	js     801438 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d3:	83 ec 08             	sub    $0x8,%esp
  8013d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d9:	50                   	push   %eax
  8013da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013dd:	ff 30                	pushl  (%eax)
  8013df:	e8 33 fc ff ff       	call   801017 <dev_lookup>
  8013e4:	83 c4 10             	add    $0x10,%esp
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	78 44                	js     80142f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ee:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013f2:	75 21                	jne    801415 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013f4:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013f9:	8b 40 48             	mov    0x48(%eax),%eax
  8013fc:	83 ec 04             	sub    $0x4,%esp
  8013ff:	53                   	push   %ebx
  801400:	50                   	push   %eax
  801401:	68 6c 28 80 00       	push   $0x80286c
  801406:	e8 09 ef ff ff       	call   800314 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80140b:	83 c4 10             	add    $0x10,%esp
  80140e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801413:	eb 23                	jmp    801438 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801415:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801418:	8b 52 18             	mov    0x18(%edx),%edx
  80141b:	85 d2                	test   %edx,%edx
  80141d:	74 14                	je     801433 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80141f:	83 ec 08             	sub    $0x8,%esp
  801422:	ff 75 0c             	pushl  0xc(%ebp)
  801425:	50                   	push   %eax
  801426:	ff d2                	call   *%edx
  801428:	89 c2                	mov    %eax,%edx
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	eb 09                	jmp    801438 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142f:	89 c2                	mov    %eax,%edx
  801431:	eb 05                	jmp    801438 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801433:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801438:	89 d0                	mov    %edx,%eax
  80143a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143d:	c9                   	leave  
  80143e:	c3                   	ret    

0080143f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	53                   	push   %ebx
  801443:	83 ec 14             	sub    $0x14,%esp
  801446:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801449:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80144c:	50                   	push   %eax
  80144d:	ff 75 08             	pushl  0x8(%ebp)
  801450:	e8 6c fb ff ff       	call   800fc1 <fd_lookup>
  801455:	83 c4 08             	add    $0x8,%esp
  801458:	89 c2                	mov    %eax,%edx
  80145a:	85 c0                	test   %eax,%eax
  80145c:	78 58                	js     8014b6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145e:	83 ec 08             	sub    $0x8,%esp
  801461:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801464:	50                   	push   %eax
  801465:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801468:	ff 30                	pushl  (%eax)
  80146a:	e8 a8 fb ff ff       	call   801017 <dev_lookup>
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	85 c0                	test   %eax,%eax
  801474:	78 37                	js     8014ad <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801476:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801479:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80147d:	74 32                	je     8014b1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80147f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801482:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801489:	00 00 00 
	stat->st_isdir = 0;
  80148c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801493:	00 00 00 
	stat->st_dev = dev;
  801496:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80149c:	83 ec 08             	sub    $0x8,%esp
  80149f:	53                   	push   %ebx
  8014a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8014a3:	ff 50 14             	call   *0x14(%eax)
  8014a6:	89 c2                	mov    %eax,%edx
  8014a8:	83 c4 10             	add    $0x10,%esp
  8014ab:	eb 09                	jmp    8014b6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ad:	89 c2                	mov    %eax,%edx
  8014af:	eb 05                	jmp    8014b6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014b6:	89 d0                	mov    %edx,%eax
  8014b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bb:	c9                   	leave  
  8014bc:	c3                   	ret    

008014bd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014bd:	55                   	push   %ebp
  8014be:	89 e5                	mov    %esp,%ebp
  8014c0:	56                   	push   %esi
  8014c1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014c2:	83 ec 08             	sub    $0x8,%esp
  8014c5:	6a 00                	push   $0x0
  8014c7:	ff 75 08             	pushl  0x8(%ebp)
  8014ca:	e8 e3 01 00 00       	call   8016b2 <open>
  8014cf:	89 c3                	mov    %eax,%ebx
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	78 1b                	js     8014f3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014d8:	83 ec 08             	sub    $0x8,%esp
  8014db:	ff 75 0c             	pushl  0xc(%ebp)
  8014de:	50                   	push   %eax
  8014df:	e8 5b ff ff ff       	call   80143f <fstat>
  8014e4:	89 c6                	mov    %eax,%esi
	close(fd);
  8014e6:	89 1c 24             	mov    %ebx,(%esp)
  8014e9:	e8 fd fb ff ff       	call   8010eb <close>
	return r;
  8014ee:	83 c4 10             	add    $0x10,%esp
  8014f1:	89 f0                	mov    %esi,%eax
}
  8014f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f6:	5b                   	pop    %ebx
  8014f7:	5e                   	pop    %esi
  8014f8:	5d                   	pop    %ebp
  8014f9:	c3                   	ret    

008014fa <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	56                   	push   %esi
  8014fe:	53                   	push   %ebx
  8014ff:	89 c6                	mov    %eax,%esi
  801501:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801503:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80150a:	75 12                	jne    80151e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80150c:	83 ec 0c             	sub    $0xc,%esp
  80150f:	6a 01                	push   $0x1
  801511:	e8 43 0c 00 00       	call   802159 <ipc_find_env>
  801516:	a3 00 40 80 00       	mov    %eax,0x804000
  80151b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80151e:	6a 07                	push   $0x7
  801520:	68 00 50 80 00       	push   $0x805000
  801525:	56                   	push   %esi
  801526:	ff 35 00 40 80 00    	pushl  0x804000
  80152c:	e8 d4 0b 00 00       	call   802105 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801531:	83 c4 0c             	add    $0xc,%esp
  801534:	6a 00                	push   $0x0
  801536:	53                   	push   %ebx
  801537:	6a 00                	push   $0x0
  801539:	e8 5e 0b 00 00       	call   80209c <ipc_recv>
}
  80153e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801541:	5b                   	pop    %ebx
  801542:	5e                   	pop    %esi
  801543:	5d                   	pop    %ebp
  801544:	c3                   	ret    

00801545 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80154b:	8b 45 08             	mov    0x8(%ebp),%eax
  80154e:	8b 40 0c             	mov    0xc(%eax),%eax
  801551:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801556:	8b 45 0c             	mov    0xc(%ebp),%eax
  801559:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80155e:	ba 00 00 00 00       	mov    $0x0,%edx
  801563:	b8 02 00 00 00       	mov    $0x2,%eax
  801568:	e8 8d ff ff ff       	call   8014fa <fsipc>
}
  80156d:	c9                   	leave  
  80156e:	c3                   	ret    

0080156f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80156f:	55                   	push   %ebp
  801570:	89 e5                	mov    %esp,%ebp
  801572:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801575:	8b 45 08             	mov    0x8(%ebp),%eax
  801578:	8b 40 0c             	mov    0xc(%eax),%eax
  80157b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801580:	ba 00 00 00 00       	mov    $0x0,%edx
  801585:	b8 06 00 00 00       	mov    $0x6,%eax
  80158a:	e8 6b ff ff ff       	call   8014fa <fsipc>
}
  80158f:	c9                   	leave  
  801590:	c3                   	ret    

00801591 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801591:	55                   	push   %ebp
  801592:	89 e5                	mov    %esp,%ebp
  801594:	53                   	push   %ebx
  801595:	83 ec 04             	sub    $0x4,%esp
  801598:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80159b:	8b 45 08             	mov    0x8(%ebp),%eax
  80159e:	8b 40 0c             	mov    0xc(%eax),%eax
  8015a1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ab:	b8 05 00 00 00       	mov    $0x5,%eax
  8015b0:	e8 45 ff ff ff       	call   8014fa <fsipc>
  8015b5:	85 c0                	test   %eax,%eax
  8015b7:	78 2c                	js     8015e5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015b9:	83 ec 08             	sub    $0x8,%esp
  8015bc:	68 00 50 80 00       	push   $0x805000
  8015c1:	53                   	push   %ebx
  8015c2:	e8 51 f3 ff ff       	call   800918 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015c7:	a1 80 50 80 00       	mov    0x805080,%eax
  8015cc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015d2:	a1 84 50 80 00       	mov    0x805084,%eax
  8015d7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015dd:	83 c4 10             	add    $0x10,%esp
  8015e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e8:	c9                   	leave  
  8015e9:	c3                   	ret    

008015ea <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	83 ec 0c             	sub    $0xc,%esp
  8015f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8015f3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015f8:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8015fd:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801600:	8b 55 08             	mov    0x8(%ebp),%edx
  801603:	8b 52 0c             	mov    0xc(%edx),%edx
  801606:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80160c:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801611:	50                   	push   %eax
  801612:	ff 75 0c             	pushl  0xc(%ebp)
  801615:	68 08 50 80 00       	push   $0x805008
  80161a:	e8 8b f4 ff ff       	call   800aaa <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80161f:	ba 00 00 00 00       	mov    $0x0,%edx
  801624:	b8 04 00 00 00       	mov    $0x4,%eax
  801629:	e8 cc fe ff ff       	call   8014fa <fsipc>
	//panic("devfile_write not implemented");
}
  80162e:	c9                   	leave  
  80162f:	c3                   	ret    

00801630 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	56                   	push   %esi
  801634:	53                   	push   %ebx
  801635:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801638:	8b 45 08             	mov    0x8(%ebp),%eax
  80163b:	8b 40 0c             	mov    0xc(%eax),%eax
  80163e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801643:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801649:	ba 00 00 00 00       	mov    $0x0,%edx
  80164e:	b8 03 00 00 00       	mov    $0x3,%eax
  801653:	e8 a2 fe ff ff       	call   8014fa <fsipc>
  801658:	89 c3                	mov    %eax,%ebx
  80165a:	85 c0                	test   %eax,%eax
  80165c:	78 4b                	js     8016a9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80165e:	39 c6                	cmp    %eax,%esi
  801660:	73 16                	jae    801678 <devfile_read+0x48>
  801662:	68 e0 28 80 00       	push   $0x8028e0
  801667:	68 e7 28 80 00       	push   $0x8028e7
  80166c:	6a 7c                	push   $0x7c
  80166e:	68 fc 28 80 00       	push   $0x8028fc
  801673:	e8 c3 eb ff ff       	call   80023b <_panic>
	assert(r <= PGSIZE);
  801678:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80167d:	7e 16                	jle    801695 <devfile_read+0x65>
  80167f:	68 07 29 80 00       	push   $0x802907
  801684:	68 e7 28 80 00       	push   $0x8028e7
  801689:	6a 7d                	push   $0x7d
  80168b:	68 fc 28 80 00       	push   $0x8028fc
  801690:	e8 a6 eb ff ff       	call   80023b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801695:	83 ec 04             	sub    $0x4,%esp
  801698:	50                   	push   %eax
  801699:	68 00 50 80 00       	push   $0x805000
  80169e:	ff 75 0c             	pushl  0xc(%ebp)
  8016a1:	e8 04 f4 ff ff       	call   800aaa <memmove>
	return r;
  8016a6:	83 c4 10             	add    $0x10,%esp
}
  8016a9:	89 d8                	mov    %ebx,%eax
  8016ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ae:	5b                   	pop    %ebx
  8016af:	5e                   	pop    %esi
  8016b0:	5d                   	pop    %ebp
  8016b1:	c3                   	ret    

008016b2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	53                   	push   %ebx
  8016b6:	83 ec 20             	sub    $0x20,%esp
  8016b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016bc:	53                   	push   %ebx
  8016bd:	e8 1d f2 ff ff       	call   8008df <strlen>
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016ca:	7f 67                	jg     801733 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016cc:	83 ec 0c             	sub    $0xc,%esp
  8016cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d2:	50                   	push   %eax
  8016d3:	e8 9a f8 ff ff       	call   800f72 <fd_alloc>
  8016d8:	83 c4 10             	add    $0x10,%esp
		return r;
  8016db:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	78 57                	js     801738 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016e1:	83 ec 08             	sub    $0x8,%esp
  8016e4:	53                   	push   %ebx
  8016e5:	68 00 50 80 00       	push   $0x805000
  8016ea:	e8 29 f2 ff ff       	call   800918 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016f2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8016ff:	e8 f6 fd ff ff       	call   8014fa <fsipc>
  801704:	89 c3                	mov    %eax,%ebx
  801706:	83 c4 10             	add    $0x10,%esp
  801709:	85 c0                	test   %eax,%eax
  80170b:	79 14                	jns    801721 <open+0x6f>
		fd_close(fd, 0);
  80170d:	83 ec 08             	sub    $0x8,%esp
  801710:	6a 00                	push   $0x0
  801712:	ff 75 f4             	pushl  -0xc(%ebp)
  801715:	e8 50 f9 ff ff       	call   80106a <fd_close>
		return r;
  80171a:	83 c4 10             	add    $0x10,%esp
  80171d:	89 da                	mov    %ebx,%edx
  80171f:	eb 17                	jmp    801738 <open+0x86>
	}

	return fd2num(fd);
  801721:	83 ec 0c             	sub    $0xc,%esp
  801724:	ff 75 f4             	pushl  -0xc(%ebp)
  801727:	e8 1f f8 ff ff       	call   800f4b <fd2num>
  80172c:	89 c2                	mov    %eax,%edx
  80172e:	83 c4 10             	add    $0x10,%esp
  801731:	eb 05                	jmp    801738 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801733:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801738:	89 d0                	mov    %edx,%eax
  80173a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173d:	c9                   	leave  
  80173e:	c3                   	ret    

0080173f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80173f:	55                   	push   %ebp
  801740:	89 e5                	mov    %esp,%ebp
  801742:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801745:	ba 00 00 00 00       	mov    $0x0,%edx
  80174a:	b8 08 00 00 00       	mov    $0x8,%eax
  80174f:	e8 a6 fd ff ff       	call   8014fa <fsipc>
}
  801754:	c9                   	leave  
  801755:	c3                   	ret    

00801756 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80175c:	68 13 29 80 00       	push   $0x802913
  801761:	ff 75 0c             	pushl  0xc(%ebp)
  801764:	e8 af f1 ff ff       	call   800918 <strcpy>
	return 0;
}
  801769:	b8 00 00 00 00       	mov    $0x0,%eax
  80176e:	c9                   	leave  
  80176f:	c3                   	ret    

00801770 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	53                   	push   %ebx
  801774:	83 ec 10             	sub    $0x10,%esp
  801777:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80177a:	53                   	push   %ebx
  80177b:	e8 12 0a 00 00       	call   802192 <pageref>
  801780:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801783:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801788:	83 f8 01             	cmp    $0x1,%eax
  80178b:	75 10                	jne    80179d <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80178d:	83 ec 0c             	sub    $0xc,%esp
  801790:	ff 73 0c             	pushl  0xc(%ebx)
  801793:	e8 c0 02 00 00       	call   801a58 <nsipc_close>
  801798:	89 c2                	mov    %eax,%edx
  80179a:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80179d:	89 d0                	mov    %edx,%eax
  80179f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a2:	c9                   	leave  
  8017a3:	c3                   	ret    

008017a4 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8017aa:	6a 00                	push   $0x0
  8017ac:	ff 75 10             	pushl  0x10(%ebp)
  8017af:	ff 75 0c             	pushl  0xc(%ebp)
  8017b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b5:	ff 70 0c             	pushl  0xc(%eax)
  8017b8:	e8 78 03 00 00       	call   801b35 <nsipc_send>
}
  8017bd:	c9                   	leave  
  8017be:	c3                   	ret    

008017bf <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8017c5:	6a 00                	push   $0x0
  8017c7:	ff 75 10             	pushl  0x10(%ebp)
  8017ca:	ff 75 0c             	pushl  0xc(%ebp)
  8017cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d0:	ff 70 0c             	pushl  0xc(%eax)
  8017d3:	e8 f1 02 00 00       	call   801ac9 <nsipc_recv>
}
  8017d8:	c9                   	leave  
  8017d9:	c3                   	ret    

008017da <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8017e0:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8017e3:	52                   	push   %edx
  8017e4:	50                   	push   %eax
  8017e5:	e8 d7 f7 ff ff       	call   800fc1 <fd_lookup>
  8017ea:	83 c4 10             	add    $0x10,%esp
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	78 17                	js     801808 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8017f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f4:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8017fa:	39 08                	cmp    %ecx,(%eax)
  8017fc:	75 05                	jne    801803 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8017fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801801:	eb 05                	jmp    801808 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801803:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801808:	c9                   	leave  
  801809:	c3                   	ret    

0080180a <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	56                   	push   %esi
  80180e:	53                   	push   %ebx
  80180f:	83 ec 1c             	sub    $0x1c,%esp
  801812:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801814:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801817:	50                   	push   %eax
  801818:	e8 55 f7 ff ff       	call   800f72 <fd_alloc>
  80181d:	89 c3                	mov    %eax,%ebx
  80181f:	83 c4 10             	add    $0x10,%esp
  801822:	85 c0                	test   %eax,%eax
  801824:	78 1b                	js     801841 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801826:	83 ec 04             	sub    $0x4,%esp
  801829:	68 07 04 00 00       	push   $0x407
  80182e:	ff 75 f4             	pushl  -0xc(%ebp)
  801831:	6a 00                	push   $0x0
  801833:	e8 e3 f4 ff ff       	call   800d1b <sys_page_alloc>
  801838:	89 c3                	mov    %eax,%ebx
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	85 c0                	test   %eax,%eax
  80183f:	79 10                	jns    801851 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801841:	83 ec 0c             	sub    $0xc,%esp
  801844:	56                   	push   %esi
  801845:	e8 0e 02 00 00       	call   801a58 <nsipc_close>
		return r;
  80184a:	83 c4 10             	add    $0x10,%esp
  80184d:	89 d8                	mov    %ebx,%eax
  80184f:	eb 24                	jmp    801875 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801851:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801857:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80185a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80185c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80185f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801866:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801869:	83 ec 0c             	sub    $0xc,%esp
  80186c:	50                   	push   %eax
  80186d:	e8 d9 f6 ff ff       	call   800f4b <fd2num>
  801872:	83 c4 10             	add    $0x10,%esp
}
  801875:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801878:	5b                   	pop    %ebx
  801879:	5e                   	pop    %esi
  80187a:	5d                   	pop    %ebp
  80187b:	c3                   	ret    

0080187c <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801882:	8b 45 08             	mov    0x8(%ebp),%eax
  801885:	e8 50 ff ff ff       	call   8017da <fd2sockid>
		return r;
  80188a:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80188c:	85 c0                	test   %eax,%eax
  80188e:	78 1f                	js     8018af <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801890:	83 ec 04             	sub    $0x4,%esp
  801893:	ff 75 10             	pushl  0x10(%ebp)
  801896:	ff 75 0c             	pushl  0xc(%ebp)
  801899:	50                   	push   %eax
  80189a:	e8 12 01 00 00       	call   8019b1 <nsipc_accept>
  80189f:	83 c4 10             	add    $0x10,%esp
		return r;
  8018a2:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8018a4:	85 c0                	test   %eax,%eax
  8018a6:	78 07                	js     8018af <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8018a8:	e8 5d ff ff ff       	call   80180a <alloc_sockfd>
  8018ad:	89 c1                	mov    %eax,%ecx
}
  8018af:	89 c8                	mov    %ecx,%eax
  8018b1:	c9                   	leave  
  8018b2:	c3                   	ret    

008018b3 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bc:	e8 19 ff ff ff       	call   8017da <fd2sockid>
  8018c1:	85 c0                	test   %eax,%eax
  8018c3:	78 12                	js     8018d7 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8018c5:	83 ec 04             	sub    $0x4,%esp
  8018c8:	ff 75 10             	pushl  0x10(%ebp)
  8018cb:	ff 75 0c             	pushl  0xc(%ebp)
  8018ce:	50                   	push   %eax
  8018cf:	e8 2d 01 00 00       	call   801a01 <nsipc_bind>
  8018d4:	83 c4 10             	add    $0x10,%esp
}
  8018d7:	c9                   	leave  
  8018d8:	c3                   	ret    

008018d9 <shutdown>:

int
shutdown(int s, int how)
{
  8018d9:	55                   	push   %ebp
  8018da:	89 e5                	mov    %esp,%ebp
  8018dc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018df:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e2:	e8 f3 fe ff ff       	call   8017da <fd2sockid>
  8018e7:	85 c0                	test   %eax,%eax
  8018e9:	78 0f                	js     8018fa <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8018eb:	83 ec 08             	sub    $0x8,%esp
  8018ee:	ff 75 0c             	pushl  0xc(%ebp)
  8018f1:	50                   	push   %eax
  8018f2:	e8 3f 01 00 00       	call   801a36 <nsipc_shutdown>
  8018f7:	83 c4 10             	add    $0x10,%esp
}
  8018fa:	c9                   	leave  
  8018fb:	c3                   	ret    

008018fc <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801902:	8b 45 08             	mov    0x8(%ebp),%eax
  801905:	e8 d0 fe ff ff       	call   8017da <fd2sockid>
  80190a:	85 c0                	test   %eax,%eax
  80190c:	78 12                	js     801920 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80190e:	83 ec 04             	sub    $0x4,%esp
  801911:	ff 75 10             	pushl  0x10(%ebp)
  801914:	ff 75 0c             	pushl  0xc(%ebp)
  801917:	50                   	push   %eax
  801918:	e8 55 01 00 00       	call   801a72 <nsipc_connect>
  80191d:	83 c4 10             	add    $0x10,%esp
}
  801920:	c9                   	leave  
  801921:	c3                   	ret    

00801922 <listen>:

int
listen(int s, int backlog)
{
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
  801925:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801928:	8b 45 08             	mov    0x8(%ebp),%eax
  80192b:	e8 aa fe ff ff       	call   8017da <fd2sockid>
  801930:	85 c0                	test   %eax,%eax
  801932:	78 0f                	js     801943 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801934:	83 ec 08             	sub    $0x8,%esp
  801937:	ff 75 0c             	pushl  0xc(%ebp)
  80193a:	50                   	push   %eax
  80193b:	e8 67 01 00 00       	call   801aa7 <nsipc_listen>
  801940:	83 c4 10             	add    $0x10,%esp
}
  801943:	c9                   	leave  
  801944:	c3                   	ret    

00801945 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801945:	55                   	push   %ebp
  801946:	89 e5                	mov    %esp,%ebp
  801948:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80194b:	ff 75 10             	pushl  0x10(%ebp)
  80194e:	ff 75 0c             	pushl  0xc(%ebp)
  801951:	ff 75 08             	pushl  0x8(%ebp)
  801954:	e8 3a 02 00 00       	call   801b93 <nsipc_socket>
  801959:	83 c4 10             	add    $0x10,%esp
  80195c:	85 c0                	test   %eax,%eax
  80195e:	78 05                	js     801965 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801960:	e8 a5 fe ff ff       	call   80180a <alloc_sockfd>
}
  801965:	c9                   	leave  
  801966:	c3                   	ret    

00801967 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	53                   	push   %ebx
  80196b:	83 ec 04             	sub    $0x4,%esp
  80196e:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801970:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801977:	75 12                	jne    80198b <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801979:	83 ec 0c             	sub    $0xc,%esp
  80197c:	6a 02                	push   $0x2
  80197e:	e8 d6 07 00 00       	call   802159 <ipc_find_env>
  801983:	a3 04 40 80 00       	mov    %eax,0x804004
  801988:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80198b:	6a 07                	push   $0x7
  80198d:	68 00 60 80 00       	push   $0x806000
  801992:	53                   	push   %ebx
  801993:	ff 35 04 40 80 00    	pushl  0x804004
  801999:	e8 67 07 00 00       	call   802105 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80199e:	83 c4 0c             	add    $0xc,%esp
  8019a1:	6a 00                	push   $0x0
  8019a3:	6a 00                	push   $0x0
  8019a5:	6a 00                	push   $0x0
  8019a7:	e8 f0 06 00 00       	call   80209c <ipc_recv>
}
  8019ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019af:	c9                   	leave  
  8019b0:	c3                   	ret    

008019b1 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019b1:	55                   	push   %ebp
  8019b2:	89 e5                	mov    %esp,%ebp
  8019b4:	56                   	push   %esi
  8019b5:	53                   	push   %ebx
  8019b6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8019b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8019c1:	8b 06                	mov    (%esi),%eax
  8019c3:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8019c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8019cd:	e8 95 ff ff ff       	call   801967 <nsipc>
  8019d2:	89 c3                	mov    %eax,%ebx
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	78 20                	js     8019f8 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8019d8:	83 ec 04             	sub    $0x4,%esp
  8019db:	ff 35 10 60 80 00    	pushl  0x806010
  8019e1:	68 00 60 80 00       	push   $0x806000
  8019e6:	ff 75 0c             	pushl  0xc(%ebp)
  8019e9:	e8 bc f0 ff ff       	call   800aaa <memmove>
		*addrlen = ret->ret_addrlen;
  8019ee:	a1 10 60 80 00       	mov    0x806010,%eax
  8019f3:	89 06                	mov    %eax,(%esi)
  8019f5:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8019f8:	89 d8                	mov    %ebx,%eax
  8019fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019fd:	5b                   	pop    %ebx
  8019fe:	5e                   	pop    %esi
  8019ff:	5d                   	pop    %ebp
  801a00:	c3                   	ret    

00801a01 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	53                   	push   %ebx
  801a05:	83 ec 08             	sub    $0x8,%esp
  801a08:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801a13:	53                   	push   %ebx
  801a14:	ff 75 0c             	pushl  0xc(%ebp)
  801a17:	68 04 60 80 00       	push   $0x806004
  801a1c:	e8 89 f0 ff ff       	call   800aaa <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801a21:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801a27:	b8 02 00 00 00       	mov    $0x2,%eax
  801a2c:	e8 36 ff ff ff       	call   801967 <nsipc>
}
  801a31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a34:	c9                   	leave  
  801a35:	c3                   	ret    

00801a36 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801a44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a47:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801a4c:	b8 03 00 00 00       	mov    $0x3,%eax
  801a51:	e8 11 ff ff ff       	call   801967 <nsipc>
}
  801a56:	c9                   	leave  
  801a57:	c3                   	ret    

00801a58 <nsipc_close>:

int
nsipc_close(int s)
{
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a61:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801a66:	b8 04 00 00 00       	mov    $0x4,%eax
  801a6b:	e8 f7 fe ff ff       	call   801967 <nsipc>
}
  801a70:	c9                   	leave  
  801a71:	c3                   	ret    

00801a72 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a72:	55                   	push   %ebp
  801a73:	89 e5                	mov    %esp,%ebp
  801a75:	53                   	push   %ebx
  801a76:	83 ec 08             	sub    $0x8,%esp
  801a79:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801a84:	53                   	push   %ebx
  801a85:	ff 75 0c             	pushl  0xc(%ebp)
  801a88:	68 04 60 80 00       	push   $0x806004
  801a8d:	e8 18 f0 ff ff       	call   800aaa <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801a92:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801a98:	b8 05 00 00 00       	mov    $0x5,%eax
  801a9d:	e8 c5 fe ff ff       	call   801967 <nsipc>
}
  801aa2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa5:	c9                   	leave  
  801aa6:	c3                   	ret    

00801aa7 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801aad:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801ab5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab8:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801abd:	b8 06 00 00 00       	mov    $0x6,%eax
  801ac2:	e8 a0 fe ff ff       	call   801967 <nsipc>
}
  801ac7:	c9                   	leave  
  801ac8:	c3                   	ret    

00801ac9 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	56                   	push   %esi
  801acd:	53                   	push   %ebx
  801ace:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801ad9:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801adf:	8b 45 14             	mov    0x14(%ebp),%eax
  801ae2:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ae7:	b8 07 00 00 00       	mov    $0x7,%eax
  801aec:	e8 76 fe ff ff       	call   801967 <nsipc>
  801af1:	89 c3                	mov    %eax,%ebx
  801af3:	85 c0                	test   %eax,%eax
  801af5:	78 35                	js     801b2c <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801af7:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801afc:	7f 04                	jg     801b02 <nsipc_recv+0x39>
  801afe:	39 c6                	cmp    %eax,%esi
  801b00:	7d 16                	jge    801b18 <nsipc_recv+0x4f>
  801b02:	68 1f 29 80 00       	push   $0x80291f
  801b07:	68 e7 28 80 00       	push   $0x8028e7
  801b0c:	6a 62                	push   $0x62
  801b0e:	68 34 29 80 00       	push   $0x802934
  801b13:	e8 23 e7 ff ff       	call   80023b <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801b18:	83 ec 04             	sub    $0x4,%esp
  801b1b:	50                   	push   %eax
  801b1c:	68 00 60 80 00       	push   $0x806000
  801b21:	ff 75 0c             	pushl  0xc(%ebp)
  801b24:	e8 81 ef ff ff       	call   800aaa <memmove>
  801b29:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801b2c:	89 d8                	mov    %ebx,%eax
  801b2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b31:	5b                   	pop    %ebx
  801b32:	5e                   	pop    %esi
  801b33:	5d                   	pop    %ebp
  801b34:	c3                   	ret    

00801b35 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	53                   	push   %ebx
  801b39:	83 ec 04             	sub    $0x4,%esp
  801b3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b42:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801b47:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801b4d:	7e 16                	jle    801b65 <nsipc_send+0x30>
  801b4f:	68 40 29 80 00       	push   $0x802940
  801b54:	68 e7 28 80 00       	push   $0x8028e7
  801b59:	6a 6d                	push   $0x6d
  801b5b:	68 34 29 80 00       	push   $0x802934
  801b60:	e8 d6 e6 ff ff       	call   80023b <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801b65:	83 ec 04             	sub    $0x4,%esp
  801b68:	53                   	push   %ebx
  801b69:	ff 75 0c             	pushl  0xc(%ebp)
  801b6c:	68 0c 60 80 00       	push   $0x80600c
  801b71:	e8 34 ef ff ff       	call   800aaa <memmove>
	nsipcbuf.send.req_size = size;
  801b76:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801b7c:	8b 45 14             	mov    0x14(%ebp),%eax
  801b7f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801b84:	b8 08 00 00 00       	mov    $0x8,%eax
  801b89:	e8 d9 fd ff ff       	call   801967 <nsipc>
}
  801b8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b91:	c9                   	leave  
  801b92:	c3                   	ret    

00801b93 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b99:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ba1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba4:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ba9:	8b 45 10             	mov    0x10(%ebp),%eax
  801bac:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801bb1:	b8 09 00 00 00       	mov    $0x9,%eax
  801bb6:	e8 ac fd ff ff       	call   801967 <nsipc>
}
  801bbb:	c9                   	leave  
  801bbc:	c3                   	ret    

00801bbd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	56                   	push   %esi
  801bc1:	53                   	push   %ebx
  801bc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bc5:	83 ec 0c             	sub    $0xc,%esp
  801bc8:	ff 75 08             	pushl  0x8(%ebp)
  801bcb:	e8 8b f3 ff ff       	call   800f5b <fd2data>
  801bd0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bd2:	83 c4 08             	add    $0x8,%esp
  801bd5:	68 4c 29 80 00       	push   $0x80294c
  801bda:	53                   	push   %ebx
  801bdb:	e8 38 ed ff ff       	call   800918 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801be0:	8b 46 04             	mov    0x4(%esi),%eax
  801be3:	2b 06                	sub    (%esi),%eax
  801be5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801beb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bf2:	00 00 00 
	stat->st_dev = &devpipe;
  801bf5:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801bfc:	30 80 00 
	return 0;
}
  801bff:	b8 00 00 00 00       	mov    $0x0,%eax
  801c04:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c07:	5b                   	pop    %ebx
  801c08:	5e                   	pop    %esi
  801c09:	5d                   	pop    %ebp
  801c0a:	c3                   	ret    

00801c0b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	53                   	push   %ebx
  801c0f:	83 ec 0c             	sub    $0xc,%esp
  801c12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c15:	53                   	push   %ebx
  801c16:	6a 00                	push   $0x0
  801c18:	e8 83 f1 ff ff       	call   800da0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c1d:	89 1c 24             	mov    %ebx,(%esp)
  801c20:	e8 36 f3 ff ff       	call   800f5b <fd2data>
  801c25:	83 c4 08             	add    $0x8,%esp
  801c28:	50                   	push   %eax
  801c29:	6a 00                	push   $0x0
  801c2b:	e8 70 f1 ff ff       	call   800da0 <sys_page_unmap>
}
  801c30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c33:	c9                   	leave  
  801c34:	c3                   	ret    

00801c35 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	57                   	push   %edi
  801c39:	56                   	push   %esi
  801c3a:	53                   	push   %ebx
  801c3b:	83 ec 1c             	sub    $0x1c,%esp
  801c3e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c41:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c43:	a1 08 40 80 00       	mov    0x804008,%eax
  801c48:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c4b:	83 ec 0c             	sub    $0xc,%esp
  801c4e:	ff 75 e0             	pushl  -0x20(%ebp)
  801c51:	e8 3c 05 00 00       	call   802192 <pageref>
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	89 3c 24             	mov    %edi,(%esp)
  801c5b:	e8 32 05 00 00       	call   802192 <pageref>
  801c60:	83 c4 10             	add    $0x10,%esp
  801c63:	39 c3                	cmp    %eax,%ebx
  801c65:	0f 94 c1             	sete   %cl
  801c68:	0f b6 c9             	movzbl %cl,%ecx
  801c6b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c6e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801c74:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c77:	39 ce                	cmp    %ecx,%esi
  801c79:	74 1b                	je     801c96 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c7b:	39 c3                	cmp    %eax,%ebx
  801c7d:	75 c4                	jne    801c43 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c7f:	8b 42 58             	mov    0x58(%edx),%eax
  801c82:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c85:	50                   	push   %eax
  801c86:	56                   	push   %esi
  801c87:	68 53 29 80 00       	push   $0x802953
  801c8c:	e8 83 e6 ff ff       	call   800314 <cprintf>
  801c91:	83 c4 10             	add    $0x10,%esp
  801c94:	eb ad                	jmp    801c43 <_pipeisclosed+0xe>
	}
}
  801c96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c9c:	5b                   	pop    %ebx
  801c9d:	5e                   	pop    %esi
  801c9e:	5f                   	pop    %edi
  801c9f:	5d                   	pop    %ebp
  801ca0:	c3                   	ret    

00801ca1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	57                   	push   %edi
  801ca5:	56                   	push   %esi
  801ca6:	53                   	push   %ebx
  801ca7:	83 ec 28             	sub    $0x28,%esp
  801caa:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cad:	56                   	push   %esi
  801cae:	e8 a8 f2 ff ff       	call   800f5b <fd2data>
  801cb3:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cb5:	83 c4 10             	add    $0x10,%esp
  801cb8:	bf 00 00 00 00       	mov    $0x0,%edi
  801cbd:	eb 4b                	jmp    801d0a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cbf:	89 da                	mov    %ebx,%edx
  801cc1:	89 f0                	mov    %esi,%eax
  801cc3:	e8 6d ff ff ff       	call   801c35 <_pipeisclosed>
  801cc8:	85 c0                	test   %eax,%eax
  801cca:	75 48                	jne    801d14 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ccc:	e8 2b f0 ff ff       	call   800cfc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cd1:	8b 43 04             	mov    0x4(%ebx),%eax
  801cd4:	8b 0b                	mov    (%ebx),%ecx
  801cd6:	8d 51 20             	lea    0x20(%ecx),%edx
  801cd9:	39 d0                	cmp    %edx,%eax
  801cdb:	73 e2                	jae    801cbf <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ce0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ce4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ce7:	89 c2                	mov    %eax,%edx
  801ce9:	c1 fa 1f             	sar    $0x1f,%edx
  801cec:	89 d1                	mov    %edx,%ecx
  801cee:	c1 e9 1b             	shr    $0x1b,%ecx
  801cf1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cf4:	83 e2 1f             	and    $0x1f,%edx
  801cf7:	29 ca                	sub    %ecx,%edx
  801cf9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cfd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d01:	83 c0 01             	add    $0x1,%eax
  801d04:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d07:	83 c7 01             	add    $0x1,%edi
  801d0a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d0d:	75 c2                	jne    801cd1 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d0f:	8b 45 10             	mov    0x10(%ebp),%eax
  801d12:	eb 05                	jmp    801d19 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d14:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d1c:	5b                   	pop    %ebx
  801d1d:	5e                   	pop    %esi
  801d1e:	5f                   	pop    %edi
  801d1f:	5d                   	pop    %ebp
  801d20:	c3                   	ret    

00801d21 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d21:	55                   	push   %ebp
  801d22:	89 e5                	mov    %esp,%ebp
  801d24:	57                   	push   %edi
  801d25:	56                   	push   %esi
  801d26:	53                   	push   %ebx
  801d27:	83 ec 18             	sub    $0x18,%esp
  801d2a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d2d:	57                   	push   %edi
  801d2e:	e8 28 f2 ff ff       	call   800f5b <fd2data>
  801d33:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d35:	83 c4 10             	add    $0x10,%esp
  801d38:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d3d:	eb 3d                	jmp    801d7c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d3f:	85 db                	test   %ebx,%ebx
  801d41:	74 04                	je     801d47 <devpipe_read+0x26>
				return i;
  801d43:	89 d8                	mov    %ebx,%eax
  801d45:	eb 44                	jmp    801d8b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d47:	89 f2                	mov    %esi,%edx
  801d49:	89 f8                	mov    %edi,%eax
  801d4b:	e8 e5 fe ff ff       	call   801c35 <_pipeisclosed>
  801d50:	85 c0                	test   %eax,%eax
  801d52:	75 32                	jne    801d86 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d54:	e8 a3 ef ff ff       	call   800cfc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d59:	8b 06                	mov    (%esi),%eax
  801d5b:	3b 46 04             	cmp    0x4(%esi),%eax
  801d5e:	74 df                	je     801d3f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d60:	99                   	cltd   
  801d61:	c1 ea 1b             	shr    $0x1b,%edx
  801d64:	01 d0                	add    %edx,%eax
  801d66:	83 e0 1f             	and    $0x1f,%eax
  801d69:	29 d0                	sub    %edx,%eax
  801d6b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d73:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d76:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d79:	83 c3 01             	add    $0x1,%ebx
  801d7c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d7f:	75 d8                	jne    801d59 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d81:	8b 45 10             	mov    0x10(%ebp),%eax
  801d84:	eb 05                	jmp    801d8b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d86:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d8e:	5b                   	pop    %ebx
  801d8f:	5e                   	pop    %esi
  801d90:	5f                   	pop    %edi
  801d91:	5d                   	pop    %ebp
  801d92:	c3                   	ret    

00801d93 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
  801d96:	56                   	push   %esi
  801d97:	53                   	push   %ebx
  801d98:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d9e:	50                   	push   %eax
  801d9f:	e8 ce f1 ff ff       	call   800f72 <fd_alloc>
  801da4:	83 c4 10             	add    $0x10,%esp
  801da7:	89 c2                	mov    %eax,%edx
  801da9:	85 c0                	test   %eax,%eax
  801dab:	0f 88 2c 01 00 00    	js     801edd <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801db1:	83 ec 04             	sub    $0x4,%esp
  801db4:	68 07 04 00 00       	push   $0x407
  801db9:	ff 75 f4             	pushl  -0xc(%ebp)
  801dbc:	6a 00                	push   $0x0
  801dbe:	e8 58 ef ff ff       	call   800d1b <sys_page_alloc>
  801dc3:	83 c4 10             	add    $0x10,%esp
  801dc6:	89 c2                	mov    %eax,%edx
  801dc8:	85 c0                	test   %eax,%eax
  801dca:	0f 88 0d 01 00 00    	js     801edd <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801dd0:	83 ec 0c             	sub    $0xc,%esp
  801dd3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dd6:	50                   	push   %eax
  801dd7:	e8 96 f1 ff ff       	call   800f72 <fd_alloc>
  801ddc:	89 c3                	mov    %eax,%ebx
  801dde:	83 c4 10             	add    $0x10,%esp
  801de1:	85 c0                	test   %eax,%eax
  801de3:	0f 88 e2 00 00 00    	js     801ecb <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de9:	83 ec 04             	sub    $0x4,%esp
  801dec:	68 07 04 00 00       	push   $0x407
  801df1:	ff 75 f0             	pushl  -0x10(%ebp)
  801df4:	6a 00                	push   $0x0
  801df6:	e8 20 ef ff ff       	call   800d1b <sys_page_alloc>
  801dfb:	89 c3                	mov    %eax,%ebx
  801dfd:	83 c4 10             	add    $0x10,%esp
  801e00:	85 c0                	test   %eax,%eax
  801e02:	0f 88 c3 00 00 00    	js     801ecb <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e08:	83 ec 0c             	sub    $0xc,%esp
  801e0b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e0e:	e8 48 f1 ff ff       	call   800f5b <fd2data>
  801e13:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e15:	83 c4 0c             	add    $0xc,%esp
  801e18:	68 07 04 00 00       	push   $0x407
  801e1d:	50                   	push   %eax
  801e1e:	6a 00                	push   $0x0
  801e20:	e8 f6 ee ff ff       	call   800d1b <sys_page_alloc>
  801e25:	89 c3                	mov    %eax,%ebx
  801e27:	83 c4 10             	add    $0x10,%esp
  801e2a:	85 c0                	test   %eax,%eax
  801e2c:	0f 88 89 00 00 00    	js     801ebb <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e32:	83 ec 0c             	sub    $0xc,%esp
  801e35:	ff 75 f0             	pushl  -0x10(%ebp)
  801e38:	e8 1e f1 ff ff       	call   800f5b <fd2data>
  801e3d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e44:	50                   	push   %eax
  801e45:	6a 00                	push   $0x0
  801e47:	56                   	push   %esi
  801e48:	6a 00                	push   $0x0
  801e4a:	e8 0f ef ff ff       	call   800d5e <sys_page_map>
  801e4f:	89 c3                	mov    %eax,%ebx
  801e51:	83 c4 20             	add    $0x20,%esp
  801e54:	85 c0                	test   %eax,%eax
  801e56:	78 55                	js     801ead <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e58:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e61:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e66:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e6d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e76:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e7b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e82:	83 ec 0c             	sub    $0xc,%esp
  801e85:	ff 75 f4             	pushl  -0xc(%ebp)
  801e88:	e8 be f0 ff ff       	call   800f4b <fd2num>
  801e8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e90:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e92:	83 c4 04             	add    $0x4,%esp
  801e95:	ff 75 f0             	pushl  -0x10(%ebp)
  801e98:	e8 ae f0 ff ff       	call   800f4b <fd2num>
  801e9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ea0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ea3:	83 c4 10             	add    $0x10,%esp
  801ea6:	ba 00 00 00 00       	mov    $0x0,%edx
  801eab:	eb 30                	jmp    801edd <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ead:	83 ec 08             	sub    $0x8,%esp
  801eb0:	56                   	push   %esi
  801eb1:	6a 00                	push   $0x0
  801eb3:	e8 e8 ee ff ff       	call   800da0 <sys_page_unmap>
  801eb8:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ebb:	83 ec 08             	sub    $0x8,%esp
  801ebe:	ff 75 f0             	pushl  -0x10(%ebp)
  801ec1:	6a 00                	push   $0x0
  801ec3:	e8 d8 ee ff ff       	call   800da0 <sys_page_unmap>
  801ec8:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ecb:	83 ec 08             	sub    $0x8,%esp
  801ece:	ff 75 f4             	pushl  -0xc(%ebp)
  801ed1:	6a 00                	push   $0x0
  801ed3:	e8 c8 ee ff ff       	call   800da0 <sys_page_unmap>
  801ed8:	83 c4 10             	add    $0x10,%esp
  801edb:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801edd:	89 d0                	mov    %edx,%eax
  801edf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ee2:	5b                   	pop    %ebx
  801ee3:	5e                   	pop    %esi
  801ee4:	5d                   	pop    %ebp
  801ee5:	c3                   	ret    

00801ee6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ee6:	55                   	push   %ebp
  801ee7:	89 e5                	mov    %esp,%ebp
  801ee9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eef:	50                   	push   %eax
  801ef0:	ff 75 08             	pushl  0x8(%ebp)
  801ef3:	e8 c9 f0 ff ff       	call   800fc1 <fd_lookup>
  801ef8:	83 c4 10             	add    $0x10,%esp
  801efb:	85 c0                	test   %eax,%eax
  801efd:	78 18                	js     801f17 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801eff:	83 ec 0c             	sub    $0xc,%esp
  801f02:	ff 75 f4             	pushl  -0xc(%ebp)
  801f05:	e8 51 f0 ff ff       	call   800f5b <fd2data>
	return _pipeisclosed(fd, p);
  801f0a:	89 c2                	mov    %eax,%edx
  801f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0f:	e8 21 fd ff ff       	call   801c35 <_pipeisclosed>
  801f14:	83 c4 10             	add    $0x10,%esp
}
  801f17:	c9                   	leave  
  801f18:	c3                   	ret    

00801f19 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f19:	55                   	push   %ebp
  801f1a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f1c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f21:	5d                   	pop    %ebp
  801f22:	c3                   	ret    

00801f23 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f23:	55                   	push   %ebp
  801f24:	89 e5                	mov    %esp,%ebp
  801f26:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f29:	68 6b 29 80 00       	push   $0x80296b
  801f2e:	ff 75 0c             	pushl  0xc(%ebp)
  801f31:	e8 e2 e9 ff ff       	call   800918 <strcpy>
	return 0;
}
  801f36:	b8 00 00 00 00       	mov    $0x0,%eax
  801f3b:	c9                   	leave  
  801f3c:	c3                   	ret    

00801f3d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f3d:	55                   	push   %ebp
  801f3e:	89 e5                	mov    %esp,%ebp
  801f40:	57                   	push   %edi
  801f41:	56                   	push   %esi
  801f42:	53                   	push   %ebx
  801f43:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f49:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f4e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f54:	eb 2d                	jmp    801f83 <devcons_write+0x46>
		m = n - tot;
  801f56:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f59:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f5b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f5e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f63:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f66:	83 ec 04             	sub    $0x4,%esp
  801f69:	53                   	push   %ebx
  801f6a:	03 45 0c             	add    0xc(%ebp),%eax
  801f6d:	50                   	push   %eax
  801f6e:	57                   	push   %edi
  801f6f:	e8 36 eb ff ff       	call   800aaa <memmove>
		sys_cputs(buf, m);
  801f74:	83 c4 08             	add    $0x8,%esp
  801f77:	53                   	push   %ebx
  801f78:	57                   	push   %edi
  801f79:	e8 e1 ec ff ff       	call   800c5f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f7e:	01 de                	add    %ebx,%esi
  801f80:	83 c4 10             	add    $0x10,%esp
  801f83:	89 f0                	mov    %esi,%eax
  801f85:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f88:	72 cc                	jb     801f56 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f8d:	5b                   	pop    %ebx
  801f8e:	5e                   	pop    %esi
  801f8f:	5f                   	pop    %edi
  801f90:	5d                   	pop    %ebp
  801f91:	c3                   	ret    

00801f92 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	83 ec 08             	sub    $0x8,%esp
  801f98:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f9d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fa1:	74 2a                	je     801fcd <devcons_read+0x3b>
  801fa3:	eb 05                	jmp    801faa <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fa5:	e8 52 ed ff ff       	call   800cfc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801faa:	e8 ce ec ff ff       	call   800c7d <sys_cgetc>
  801faf:	85 c0                	test   %eax,%eax
  801fb1:	74 f2                	je     801fa5 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801fb3:	85 c0                	test   %eax,%eax
  801fb5:	78 16                	js     801fcd <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fb7:	83 f8 04             	cmp    $0x4,%eax
  801fba:	74 0c                	je     801fc8 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801fbc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fbf:	88 02                	mov    %al,(%edx)
	return 1;
  801fc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc6:	eb 05                	jmp    801fcd <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fc8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fcd:	c9                   	leave  
  801fce:	c3                   	ret    

00801fcf <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801fcf:	55                   	push   %ebp
  801fd0:	89 e5                	mov    %esp,%ebp
  801fd2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fdb:	6a 01                	push   $0x1
  801fdd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fe0:	50                   	push   %eax
  801fe1:	e8 79 ec ff ff       	call   800c5f <sys_cputs>
}
  801fe6:	83 c4 10             	add    $0x10,%esp
  801fe9:	c9                   	leave  
  801fea:	c3                   	ret    

00801feb <getchar>:

int
getchar(void)
{
  801feb:	55                   	push   %ebp
  801fec:	89 e5                	mov    %esp,%ebp
  801fee:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ff1:	6a 01                	push   $0x1
  801ff3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ff6:	50                   	push   %eax
  801ff7:	6a 00                	push   $0x0
  801ff9:	e8 29 f2 ff ff       	call   801227 <read>
	if (r < 0)
  801ffe:	83 c4 10             	add    $0x10,%esp
  802001:	85 c0                	test   %eax,%eax
  802003:	78 0f                	js     802014 <getchar+0x29>
		return r;
	if (r < 1)
  802005:	85 c0                	test   %eax,%eax
  802007:	7e 06                	jle    80200f <getchar+0x24>
		return -E_EOF;
	return c;
  802009:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80200d:	eb 05                	jmp    802014 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80200f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802014:	c9                   	leave  
  802015:	c3                   	ret    

00802016 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802016:	55                   	push   %ebp
  802017:	89 e5                	mov    %esp,%ebp
  802019:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80201c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80201f:	50                   	push   %eax
  802020:	ff 75 08             	pushl  0x8(%ebp)
  802023:	e8 99 ef ff ff       	call   800fc1 <fd_lookup>
  802028:	83 c4 10             	add    $0x10,%esp
  80202b:	85 c0                	test   %eax,%eax
  80202d:	78 11                	js     802040 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80202f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802032:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802038:	39 10                	cmp    %edx,(%eax)
  80203a:	0f 94 c0             	sete   %al
  80203d:	0f b6 c0             	movzbl %al,%eax
}
  802040:	c9                   	leave  
  802041:	c3                   	ret    

00802042 <opencons>:

int
opencons(void)
{
  802042:	55                   	push   %ebp
  802043:	89 e5                	mov    %esp,%ebp
  802045:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802048:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80204b:	50                   	push   %eax
  80204c:	e8 21 ef ff ff       	call   800f72 <fd_alloc>
  802051:	83 c4 10             	add    $0x10,%esp
		return r;
  802054:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802056:	85 c0                	test   %eax,%eax
  802058:	78 3e                	js     802098 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80205a:	83 ec 04             	sub    $0x4,%esp
  80205d:	68 07 04 00 00       	push   $0x407
  802062:	ff 75 f4             	pushl  -0xc(%ebp)
  802065:	6a 00                	push   $0x0
  802067:	e8 af ec ff ff       	call   800d1b <sys_page_alloc>
  80206c:	83 c4 10             	add    $0x10,%esp
		return r;
  80206f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802071:	85 c0                	test   %eax,%eax
  802073:	78 23                	js     802098 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802075:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80207b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80207e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802080:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802083:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80208a:	83 ec 0c             	sub    $0xc,%esp
  80208d:	50                   	push   %eax
  80208e:	e8 b8 ee ff ff       	call   800f4b <fd2num>
  802093:	89 c2                	mov    %eax,%edx
  802095:	83 c4 10             	add    $0x10,%esp
}
  802098:	89 d0                	mov    %edx,%eax
  80209a:	c9                   	leave  
  80209b:	c3                   	ret    

0080209c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80209c:	55                   	push   %ebp
  80209d:	89 e5                	mov    %esp,%ebp
  80209f:	56                   	push   %esi
  8020a0:	53                   	push   %ebx
  8020a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8020a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  8020aa:	85 c0                	test   %eax,%eax
  8020ac:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8020b1:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  8020b4:	83 ec 0c             	sub    $0xc,%esp
  8020b7:	50                   	push   %eax
  8020b8:	e8 0e ee ff ff       	call   800ecb <sys_ipc_recv>
  8020bd:	83 c4 10             	add    $0x10,%esp
  8020c0:	85 c0                	test   %eax,%eax
  8020c2:	79 16                	jns    8020da <ipc_recv+0x3e>
        if (from_env_store != NULL)
  8020c4:	85 f6                	test   %esi,%esi
  8020c6:	74 06                	je     8020ce <ipc_recv+0x32>
            *from_env_store = 0;
  8020c8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  8020ce:	85 db                	test   %ebx,%ebx
  8020d0:	74 2c                	je     8020fe <ipc_recv+0x62>
            *perm_store = 0;
  8020d2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8020d8:	eb 24                	jmp    8020fe <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  8020da:	85 f6                	test   %esi,%esi
  8020dc:	74 0a                	je     8020e8 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  8020de:	a1 08 40 80 00       	mov    0x804008,%eax
  8020e3:	8b 40 74             	mov    0x74(%eax),%eax
  8020e6:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  8020e8:	85 db                	test   %ebx,%ebx
  8020ea:	74 0a                	je     8020f6 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  8020ec:	a1 08 40 80 00       	mov    0x804008,%eax
  8020f1:	8b 40 78             	mov    0x78(%eax),%eax
  8020f4:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  8020f6:	a1 08 40 80 00       	mov    0x804008,%eax
  8020fb:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  8020fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802101:	5b                   	pop    %ebx
  802102:	5e                   	pop    %esi
  802103:	5d                   	pop    %ebp
  802104:	c3                   	ret    

00802105 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802105:	55                   	push   %ebp
  802106:	89 e5                	mov    %esp,%ebp
  802108:	57                   	push   %edi
  802109:	56                   	push   %esi
  80210a:	53                   	push   %ebx
  80210b:	83 ec 0c             	sub    $0xc,%esp
  80210e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802111:	8b 75 0c             	mov    0xc(%ebp),%esi
  802114:	8b 45 10             	mov    0x10(%ebp),%eax
  802117:	85 c0                	test   %eax,%eax
  802119:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80211e:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  802121:	eb 1c                	jmp    80213f <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  802123:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802126:	74 12                	je     80213a <ipc_send+0x35>
  802128:	50                   	push   %eax
  802129:	68 77 29 80 00       	push   $0x802977
  80212e:	6a 3b                	push   $0x3b
  802130:	68 8d 29 80 00       	push   $0x80298d
  802135:	e8 01 e1 ff ff       	call   80023b <_panic>
		sys_yield();
  80213a:	e8 bd eb ff ff       	call   800cfc <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80213f:	ff 75 14             	pushl  0x14(%ebp)
  802142:	53                   	push   %ebx
  802143:	56                   	push   %esi
  802144:	57                   	push   %edi
  802145:	e8 5e ed ff ff       	call   800ea8 <sys_ipc_try_send>
  80214a:	83 c4 10             	add    $0x10,%esp
  80214d:	85 c0                	test   %eax,%eax
  80214f:	78 d2                	js     802123 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  802151:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802154:	5b                   	pop    %ebx
  802155:	5e                   	pop    %esi
  802156:	5f                   	pop    %edi
  802157:	5d                   	pop    %ebp
  802158:	c3                   	ret    

00802159 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802159:	55                   	push   %ebp
  80215a:	89 e5                	mov    %esp,%ebp
  80215c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80215f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802164:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802167:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80216d:	8b 52 50             	mov    0x50(%edx),%edx
  802170:	39 ca                	cmp    %ecx,%edx
  802172:	75 0d                	jne    802181 <ipc_find_env+0x28>
			return envs[i].env_id;
  802174:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802177:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80217c:	8b 40 48             	mov    0x48(%eax),%eax
  80217f:	eb 0f                	jmp    802190 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802181:	83 c0 01             	add    $0x1,%eax
  802184:	3d 00 04 00 00       	cmp    $0x400,%eax
  802189:	75 d9                	jne    802164 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80218b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    

00802192 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802192:	55                   	push   %ebp
  802193:	89 e5                	mov    %esp,%ebp
  802195:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802198:	89 d0                	mov    %edx,%eax
  80219a:	c1 e8 16             	shr    $0x16,%eax
  80219d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021a4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021a9:	f6 c1 01             	test   $0x1,%cl
  8021ac:	74 1d                	je     8021cb <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021ae:	c1 ea 0c             	shr    $0xc,%edx
  8021b1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021b8:	f6 c2 01             	test   $0x1,%dl
  8021bb:	74 0e                	je     8021cb <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021bd:	c1 ea 0c             	shr    $0xc,%edx
  8021c0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021c7:	ef 
  8021c8:	0f b7 c0             	movzwl %ax,%eax
}
  8021cb:	5d                   	pop    %ebp
  8021cc:	c3                   	ret    
  8021cd:	66 90                	xchg   %ax,%ax
  8021cf:	90                   	nop

008021d0 <__udivdi3>:
  8021d0:	55                   	push   %ebp
  8021d1:	57                   	push   %edi
  8021d2:	56                   	push   %esi
  8021d3:	53                   	push   %ebx
  8021d4:	83 ec 1c             	sub    $0x1c,%esp
  8021d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021e7:	85 f6                	test   %esi,%esi
  8021e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021ed:	89 ca                	mov    %ecx,%edx
  8021ef:	89 f8                	mov    %edi,%eax
  8021f1:	75 3d                	jne    802230 <__udivdi3+0x60>
  8021f3:	39 cf                	cmp    %ecx,%edi
  8021f5:	0f 87 c5 00 00 00    	ja     8022c0 <__udivdi3+0xf0>
  8021fb:	85 ff                	test   %edi,%edi
  8021fd:	89 fd                	mov    %edi,%ebp
  8021ff:	75 0b                	jne    80220c <__udivdi3+0x3c>
  802201:	b8 01 00 00 00       	mov    $0x1,%eax
  802206:	31 d2                	xor    %edx,%edx
  802208:	f7 f7                	div    %edi
  80220a:	89 c5                	mov    %eax,%ebp
  80220c:	89 c8                	mov    %ecx,%eax
  80220e:	31 d2                	xor    %edx,%edx
  802210:	f7 f5                	div    %ebp
  802212:	89 c1                	mov    %eax,%ecx
  802214:	89 d8                	mov    %ebx,%eax
  802216:	89 cf                	mov    %ecx,%edi
  802218:	f7 f5                	div    %ebp
  80221a:	89 c3                	mov    %eax,%ebx
  80221c:	89 d8                	mov    %ebx,%eax
  80221e:	89 fa                	mov    %edi,%edx
  802220:	83 c4 1c             	add    $0x1c,%esp
  802223:	5b                   	pop    %ebx
  802224:	5e                   	pop    %esi
  802225:	5f                   	pop    %edi
  802226:	5d                   	pop    %ebp
  802227:	c3                   	ret    
  802228:	90                   	nop
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	39 ce                	cmp    %ecx,%esi
  802232:	77 74                	ja     8022a8 <__udivdi3+0xd8>
  802234:	0f bd fe             	bsr    %esi,%edi
  802237:	83 f7 1f             	xor    $0x1f,%edi
  80223a:	0f 84 98 00 00 00    	je     8022d8 <__udivdi3+0x108>
  802240:	bb 20 00 00 00       	mov    $0x20,%ebx
  802245:	89 f9                	mov    %edi,%ecx
  802247:	89 c5                	mov    %eax,%ebp
  802249:	29 fb                	sub    %edi,%ebx
  80224b:	d3 e6                	shl    %cl,%esi
  80224d:	89 d9                	mov    %ebx,%ecx
  80224f:	d3 ed                	shr    %cl,%ebp
  802251:	89 f9                	mov    %edi,%ecx
  802253:	d3 e0                	shl    %cl,%eax
  802255:	09 ee                	or     %ebp,%esi
  802257:	89 d9                	mov    %ebx,%ecx
  802259:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80225d:	89 d5                	mov    %edx,%ebp
  80225f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802263:	d3 ed                	shr    %cl,%ebp
  802265:	89 f9                	mov    %edi,%ecx
  802267:	d3 e2                	shl    %cl,%edx
  802269:	89 d9                	mov    %ebx,%ecx
  80226b:	d3 e8                	shr    %cl,%eax
  80226d:	09 c2                	or     %eax,%edx
  80226f:	89 d0                	mov    %edx,%eax
  802271:	89 ea                	mov    %ebp,%edx
  802273:	f7 f6                	div    %esi
  802275:	89 d5                	mov    %edx,%ebp
  802277:	89 c3                	mov    %eax,%ebx
  802279:	f7 64 24 0c          	mull   0xc(%esp)
  80227d:	39 d5                	cmp    %edx,%ebp
  80227f:	72 10                	jb     802291 <__udivdi3+0xc1>
  802281:	8b 74 24 08          	mov    0x8(%esp),%esi
  802285:	89 f9                	mov    %edi,%ecx
  802287:	d3 e6                	shl    %cl,%esi
  802289:	39 c6                	cmp    %eax,%esi
  80228b:	73 07                	jae    802294 <__udivdi3+0xc4>
  80228d:	39 d5                	cmp    %edx,%ebp
  80228f:	75 03                	jne    802294 <__udivdi3+0xc4>
  802291:	83 eb 01             	sub    $0x1,%ebx
  802294:	31 ff                	xor    %edi,%edi
  802296:	89 d8                	mov    %ebx,%eax
  802298:	89 fa                	mov    %edi,%edx
  80229a:	83 c4 1c             	add    $0x1c,%esp
  80229d:	5b                   	pop    %ebx
  80229e:	5e                   	pop    %esi
  80229f:	5f                   	pop    %edi
  8022a0:	5d                   	pop    %ebp
  8022a1:	c3                   	ret    
  8022a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022a8:	31 ff                	xor    %edi,%edi
  8022aa:	31 db                	xor    %ebx,%ebx
  8022ac:	89 d8                	mov    %ebx,%eax
  8022ae:	89 fa                	mov    %edi,%edx
  8022b0:	83 c4 1c             	add    $0x1c,%esp
  8022b3:	5b                   	pop    %ebx
  8022b4:	5e                   	pop    %esi
  8022b5:	5f                   	pop    %edi
  8022b6:	5d                   	pop    %ebp
  8022b7:	c3                   	ret    
  8022b8:	90                   	nop
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	89 d8                	mov    %ebx,%eax
  8022c2:	f7 f7                	div    %edi
  8022c4:	31 ff                	xor    %edi,%edi
  8022c6:	89 c3                	mov    %eax,%ebx
  8022c8:	89 d8                	mov    %ebx,%eax
  8022ca:	89 fa                	mov    %edi,%edx
  8022cc:	83 c4 1c             	add    $0x1c,%esp
  8022cf:	5b                   	pop    %ebx
  8022d0:	5e                   	pop    %esi
  8022d1:	5f                   	pop    %edi
  8022d2:	5d                   	pop    %ebp
  8022d3:	c3                   	ret    
  8022d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d8:	39 ce                	cmp    %ecx,%esi
  8022da:	72 0c                	jb     8022e8 <__udivdi3+0x118>
  8022dc:	31 db                	xor    %ebx,%ebx
  8022de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022e2:	0f 87 34 ff ff ff    	ja     80221c <__udivdi3+0x4c>
  8022e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022ed:	e9 2a ff ff ff       	jmp    80221c <__udivdi3+0x4c>
  8022f2:	66 90                	xchg   %ax,%ax
  8022f4:	66 90                	xchg   %ax,%ax
  8022f6:	66 90                	xchg   %ax,%ax
  8022f8:	66 90                	xchg   %ax,%ax
  8022fa:	66 90                	xchg   %ax,%ax
  8022fc:	66 90                	xchg   %ax,%ax
  8022fe:	66 90                	xchg   %ax,%ax

00802300 <__umoddi3>:
  802300:	55                   	push   %ebp
  802301:	57                   	push   %edi
  802302:	56                   	push   %esi
  802303:	53                   	push   %ebx
  802304:	83 ec 1c             	sub    $0x1c,%esp
  802307:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80230b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80230f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802313:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802317:	85 d2                	test   %edx,%edx
  802319:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80231d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802321:	89 f3                	mov    %esi,%ebx
  802323:	89 3c 24             	mov    %edi,(%esp)
  802326:	89 74 24 04          	mov    %esi,0x4(%esp)
  80232a:	75 1c                	jne    802348 <__umoddi3+0x48>
  80232c:	39 f7                	cmp    %esi,%edi
  80232e:	76 50                	jbe    802380 <__umoddi3+0x80>
  802330:	89 c8                	mov    %ecx,%eax
  802332:	89 f2                	mov    %esi,%edx
  802334:	f7 f7                	div    %edi
  802336:	89 d0                	mov    %edx,%eax
  802338:	31 d2                	xor    %edx,%edx
  80233a:	83 c4 1c             	add    $0x1c,%esp
  80233d:	5b                   	pop    %ebx
  80233e:	5e                   	pop    %esi
  80233f:	5f                   	pop    %edi
  802340:	5d                   	pop    %ebp
  802341:	c3                   	ret    
  802342:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802348:	39 f2                	cmp    %esi,%edx
  80234a:	89 d0                	mov    %edx,%eax
  80234c:	77 52                	ja     8023a0 <__umoddi3+0xa0>
  80234e:	0f bd ea             	bsr    %edx,%ebp
  802351:	83 f5 1f             	xor    $0x1f,%ebp
  802354:	75 5a                	jne    8023b0 <__umoddi3+0xb0>
  802356:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80235a:	0f 82 e0 00 00 00    	jb     802440 <__umoddi3+0x140>
  802360:	39 0c 24             	cmp    %ecx,(%esp)
  802363:	0f 86 d7 00 00 00    	jbe    802440 <__umoddi3+0x140>
  802369:	8b 44 24 08          	mov    0x8(%esp),%eax
  80236d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802371:	83 c4 1c             	add    $0x1c,%esp
  802374:	5b                   	pop    %ebx
  802375:	5e                   	pop    %esi
  802376:	5f                   	pop    %edi
  802377:	5d                   	pop    %ebp
  802378:	c3                   	ret    
  802379:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802380:	85 ff                	test   %edi,%edi
  802382:	89 fd                	mov    %edi,%ebp
  802384:	75 0b                	jne    802391 <__umoddi3+0x91>
  802386:	b8 01 00 00 00       	mov    $0x1,%eax
  80238b:	31 d2                	xor    %edx,%edx
  80238d:	f7 f7                	div    %edi
  80238f:	89 c5                	mov    %eax,%ebp
  802391:	89 f0                	mov    %esi,%eax
  802393:	31 d2                	xor    %edx,%edx
  802395:	f7 f5                	div    %ebp
  802397:	89 c8                	mov    %ecx,%eax
  802399:	f7 f5                	div    %ebp
  80239b:	89 d0                	mov    %edx,%eax
  80239d:	eb 99                	jmp    802338 <__umoddi3+0x38>
  80239f:	90                   	nop
  8023a0:	89 c8                	mov    %ecx,%eax
  8023a2:	89 f2                	mov    %esi,%edx
  8023a4:	83 c4 1c             	add    $0x1c,%esp
  8023a7:	5b                   	pop    %ebx
  8023a8:	5e                   	pop    %esi
  8023a9:	5f                   	pop    %edi
  8023aa:	5d                   	pop    %ebp
  8023ab:	c3                   	ret    
  8023ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023b0:	8b 34 24             	mov    (%esp),%esi
  8023b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023b8:	89 e9                	mov    %ebp,%ecx
  8023ba:	29 ef                	sub    %ebp,%edi
  8023bc:	d3 e0                	shl    %cl,%eax
  8023be:	89 f9                	mov    %edi,%ecx
  8023c0:	89 f2                	mov    %esi,%edx
  8023c2:	d3 ea                	shr    %cl,%edx
  8023c4:	89 e9                	mov    %ebp,%ecx
  8023c6:	09 c2                	or     %eax,%edx
  8023c8:	89 d8                	mov    %ebx,%eax
  8023ca:	89 14 24             	mov    %edx,(%esp)
  8023cd:	89 f2                	mov    %esi,%edx
  8023cf:	d3 e2                	shl    %cl,%edx
  8023d1:	89 f9                	mov    %edi,%ecx
  8023d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023db:	d3 e8                	shr    %cl,%eax
  8023dd:	89 e9                	mov    %ebp,%ecx
  8023df:	89 c6                	mov    %eax,%esi
  8023e1:	d3 e3                	shl    %cl,%ebx
  8023e3:	89 f9                	mov    %edi,%ecx
  8023e5:	89 d0                	mov    %edx,%eax
  8023e7:	d3 e8                	shr    %cl,%eax
  8023e9:	89 e9                	mov    %ebp,%ecx
  8023eb:	09 d8                	or     %ebx,%eax
  8023ed:	89 d3                	mov    %edx,%ebx
  8023ef:	89 f2                	mov    %esi,%edx
  8023f1:	f7 34 24             	divl   (%esp)
  8023f4:	89 d6                	mov    %edx,%esi
  8023f6:	d3 e3                	shl    %cl,%ebx
  8023f8:	f7 64 24 04          	mull   0x4(%esp)
  8023fc:	39 d6                	cmp    %edx,%esi
  8023fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802402:	89 d1                	mov    %edx,%ecx
  802404:	89 c3                	mov    %eax,%ebx
  802406:	72 08                	jb     802410 <__umoddi3+0x110>
  802408:	75 11                	jne    80241b <__umoddi3+0x11b>
  80240a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80240e:	73 0b                	jae    80241b <__umoddi3+0x11b>
  802410:	2b 44 24 04          	sub    0x4(%esp),%eax
  802414:	1b 14 24             	sbb    (%esp),%edx
  802417:	89 d1                	mov    %edx,%ecx
  802419:	89 c3                	mov    %eax,%ebx
  80241b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80241f:	29 da                	sub    %ebx,%edx
  802421:	19 ce                	sbb    %ecx,%esi
  802423:	89 f9                	mov    %edi,%ecx
  802425:	89 f0                	mov    %esi,%eax
  802427:	d3 e0                	shl    %cl,%eax
  802429:	89 e9                	mov    %ebp,%ecx
  80242b:	d3 ea                	shr    %cl,%edx
  80242d:	89 e9                	mov    %ebp,%ecx
  80242f:	d3 ee                	shr    %cl,%esi
  802431:	09 d0                	or     %edx,%eax
  802433:	89 f2                	mov    %esi,%edx
  802435:	83 c4 1c             	add    $0x1c,%esp
  802438:	5b                   	pop    %ebx
  802439:	5e                   	pop    %esi
  80243a:	5f                   	pop    %edi
  80243b:	5d                   	pop    %ebp
  80243c:	c3                   	ret    
  80243d:	8d 76 00             	lea    0x0(%esi),%esi
  802440:	29 f9                	sub    %edi,%ecx
  802442:	19 d6                	sbb    %edx,%esi
  802444:	89 74 24 04          	mov    %esi,0x4(%esp)
  802448:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80244c:	e9 18 ff ff ff       	jmp    802369 <__umoddi3+0x69>
