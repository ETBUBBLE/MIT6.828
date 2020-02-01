
obj/user/testfdsharing.debug：     文件格式 elf32-i386


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
  80002c:	e8 87 01 00 00       	call   8001b8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 20 23 80 00       	push   $0x802320
  800043:	e8 a7 18 00 00       	call   8018ef <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 25 23 80 00       	push   $0x802325
  800057:	6a 0c                	push   $0xc
  800059:	68 33 23 80 00       	push   $0x802333
  80005e:	e8 b5 01 00 00       	call   800218 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 5c 15 00 00       	call   8015ca <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 74 14 00 00       	call   8014f5 <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 48 23 80 00       	push   $0x802348
  800090:	6a 0f                	push   $0xf
  800092:	68 33 23 80 00       	push   $0x802333
  800097:	e8 7c 01 00 00       	call   800218 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 3a 0f 00 00       	call   800fdb <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 52 23 80 00       	push   $0x802352
  8000ad:	6a 12                	push   $0x12
  8000af:	68 33 23 80 00       	push   $0x802333
  8000b4:	e8 5f 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 fe 14 00 00       	call   8015ca <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 90 23 80 00 	movl   $0x802390,(%esp)
  8000d3:	e8 19 02 00 00       	call   8002f1 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 0a 14 00 00       	call   8014f5 <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 d4 23 80 00       	push   $0x8023d4
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 33 23 80 00       	push   $0x802333
  800103:	e8 10 01 00 00       	call   800218 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	56                   	push   %esi
  80010c:	68 20 40 80 00       	push   $0x804020
  800111:	68 20 42 80 00       	push   $0x804220
  800116:	e8 e7 09 00 00       	call   800b02 <memcmp>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 14                	je     800136 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	68 00 24 80 00       	push   $0x802400
  80012a:	6a 19                	push   $0x19
  80012c:	68 33 23 80 00       	push   $0x802333
  800131:	e8 e2 00 00 00       	call   800218 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 5b 23 80 00       	push   $0x80235b
  80013e:	e8 ae 01 00 00       	call   8002f1 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 7c 14 00 00       	call   8015ca <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 d2 11 00 00       	call   801328 <close>
		exit();
  800156:	e8 a3 00 00 00       	call   8001fe <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 88 1b 00 00       	call   801cef <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 7b 13 00 00       	call   8014f5 <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 38 24 80 00       	push   $0x802438
  80018b:	6a 21                	push   $0x21
  80018d:	68 33 23 80 00       	push   $0x802333
  800192:	e8 81 00 00 00       	call   800218 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 74 23 80 00       	push   $0x802374
  80019f:	e8 4d 01 00 00       	call   8002f1 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 7c 11 00 00       	call   801328 <close>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8001ac:	cc                   	int3   

	breakpoint();
}
  8001ad:	83 c4 10             	add    $0x10,%esp
  8001b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c0:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8001c3:	e8 f2 0a 00 00       	call   800cba <sys_getenvid>
  8001c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d5:	a3 20 44 80 00       	mov    %eax,0x804420

    // save the name of the program so that panic() can use it
    if (argc > 0)
  8001da:	85 db                	test   %ebx,%ebx
  8001dc:	7e 07                	jle    8001e5 <libmain+0x2d>
        binaryname = argv[0];
  8001de:	8b 06                	mov    (%esi),%eax
  8001e0:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	e8 44 fe ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  8001ef:	e8 0a 00 00 00       	call   8001fe <exit>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800204:	e8 4a 11 00 00       	call   801353 <close_all>
	sys_env_destroy(0);
  800209:	83 ec 0c             	sub    $0xc,%esp
  80020c:	6a 00                	push   $0x0
  80020e:	e8 66 0a 00 00       	call   800c79 <sys_env_destroy>
}
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80021d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800220:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800226:	e8 8f 0a 00 00       	call   800cba <sys_getenvid>
  80022b:	83 ec 0c             	sub    $0xc,%esp
  80022e:	ff 75 0c             	pushl  0xc(%ebp)
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	56                   	push   %esi
  800235:	50                   	push   %eax
  800236:	68 68 24 80 00       	push   $0x802468
  80023b:	e8 b1 00 00 00       	call   8002f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	53                   	push   %ebx
  800244:	ff 75 10             	pushl  0x10(%ebp)
  800247:	e8 54 00 00 00       	call   8002a0 <vcprintf>
	cprintf("\n");
  80024c:	c7 04 24 72 23 80 00 	movl   $0x802372,(%esp)
  800253:	e8 99 00 00 00       	call   8002f1 <cprintf>
  800258:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80025b:	cc                   	int3   
  80025c:	eb fd                	jmp    80025b <_panic+0x43>

0080025e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	53                   	push   %ebx
  800262:	83 ec 04             	sub    $0x4,%esp
  800265:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800268:	8b 13                	mov    (%ebx),%edx
  80026a:	8d 42 01             	lea    0x1(%edx),%eax
  80026d:	89 03                	mov    %eax,(%ebx)
  80026f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800272:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800276:	3d ff 00 00 00       	cmp    $0xff,%eax
  80027b:	75 1a                	jne    800297 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	68 ff 00 00 00       	push   $0xff
  800285:	8d 43 08             	lea    0x8(%ebx),%eax
  800288:	50                   	push   %eax
  800289:	e8 ae 09 00 00       	call   800c3c <sys_cputs>
		b->idx = 0;
  80028e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800294:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800297:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80029b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002b0:	00 00 00 
	b.cnt = 0;
  8002b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002bd:	ff 75 0c             	pushl  0xc(%ebp)
  8002c0:	ff 75 08             	pushl  0x8(%ebp)
  8002c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c9:	50                   	push   %eax
  8002ca:	68 5e 02 80 00       	push   $0x80025e
  8002cf:	e8 1a 01 00 00       	call   8003ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d4:	83 c4 08             	add    $0x8,%esp
  8002d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 53 09 00 00       	call   800c3c <sys_cputs>

	return b.cnt;
}
  8002e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ef:	c9                   	leave  
  8002f0:	c3                   	ret    

008002f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002fa:	50                   	push   %eax
  8002fb:	ff 75 08             	pushl  0x8(%ebp)
  8002fe:	e8 9d ff ff ff       	call   8002a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800303:	c9                   	leave  
  800304:	c3                   	ret    

00800305 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 1c             	sub    $0x1c,%esp
  80030e:	89 c7                	mov    %eax,%edi
  800310:	89 d6                	mov    %edx,%esi
  800312:	8b 45 08             	mov    0x8(%ebp),%eax
  800315:	8b 55 0c             	mov    0xc(%ebp),%edx
  800318:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80031b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80031e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800321:	bb 00 00 00 00       	mov    $0x0,%ebx
  800326:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800329:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80032c:	39 d3                	cmp    %edx,%ebx
  80032e:	72 05                	jb     800335 <printnum+0x30>
  800330:	39 45 10             	cmp    %eax,0x10(%ebp)
  800333:	77 45                	ja     80037a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	ff 75 18             	pushl  0x18(%ebp)
  80033b:	8b 45 14             	mov    0x14(%ebp),%eax
  80033e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800341:	53                   	push   %ebx
  800342:	ff 75 10             	pushl  0x10(%ebp)
  800345:	83 ec 08             	sub    $0x8,%esp
  800348:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034b:	ff 75 e0             	pushl  -0x20(%ebp)
  80034e:	ff 75 dc             	pushl  -0x24(%ebp)
  800351:	ff 75 d8             	pushl  -0x28(%ebp)
  800354:	e8 27 1d 00 00       	call   802080 <__udivdi3>
  800359:	83 c4 18             	add    $0x18,%esp
  80035c:	52                   	push   %edx
  80035d:	50                   	push   %eax
  80035e:	89 f2                	mov    %esi,%edx
  800360:	89 f8                	mov    %edi,%eax
  800362:	e8 9e ff ff ff       	call   800305 <printnum>
  800367:	83 c4 20             	add    $0x20,%esp
  80036a:	eb 18                	jmp    800384 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80036c:	83 ec 08             	sub    $0x8,%esp
  80036f:	56                   	push   %esi
  800370:	ff 75 18             	pushl  0x18(%ebp)
  800373:	ff d7                	call   *%edi
  800375:	83 c4 10             	add    $0x10,%esp
  800378:	eb 03                	jmp    80037d <printnum+0x78>
  80037a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80037d:	83 eb 01             	sub    $0x1,%ebx
  800380:	85 db                	test   %ebx,%ebx
  800382:	7f e8                	jg     80036c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	56                   	push   %esi
  800388:	83 ec 04             	sub    $0x4,%esp
  80038b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80038e:	ff 75 e0             	pushl  -0x20(%ebp)
  800391:	ff 75 dc             	pushl  -0x24(%ebp)
  800394:	ff 75 d8             	pushl  -0x28(%ebp)
  800397:	e8 14 1e 00 00       	call   8021b0 <__umoddi3>
  80039c:	83 c4 14             	add    $0x14,%esp
  80039f:	0f be 80 8b 24 80 00 	movsbl 0x80248b(%eax),%eax
  8003a6:	50                   	push   %eax
  8003a7:	ff d7                	call   *%edi
}
  8003a9:	83 c4 10             	add    $0x10,%esp
  8003ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003af:	5b                   	pop    %ebx
  8003b0:	5e                   	pop    %esi
  8003b1:	5f                   	pop    %edi
  8003b2:	5d                   	pop    %ebp
  8003b3:	c3                   	ret    

008003b4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ba:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003be:	8b 10                	mov    (%eax),%edx
  8003c0:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c3:	73 0a                	jae    8003cf <sprintputch+0x1b>
		*b->buf++ = ch;
  8003c5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c8:	89 08                	mov    %ecx,(%eax)
  8003ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cd:	88 02                	mov    %al,(%edx)
}
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003da:	50                   	push   %eax
  8003db:	ff 75 10             	pushl  0x10(%ebp)
  8003de:	ff 75 0c             	pushl  0xc(%ebp)
  8003e1:	ff 75 08             	pushl  0x8(%ebp)
  8003e4:	e8 05 00 00 00       	call   8003ee <vprintfmt>
	va_end(ap);
}
  8003e9:	83 c4 10             	add    $0x10,%esp
  8003ec:	c9                   	leave  
  8003ed:	c3                   	ret    

008003ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	57                   	push   %edi
  8003f2:	56                   	push   %esi
  8003f3:	53                   	push   %ebx
  8003f4:	83 ec 2c             	sub    $0x2c,%esp
  8003f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8003fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003fd:	8b 7d 10             	mov    0x10(%ebp),%edi
  800400:	eb 12                	jmp    800414 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800402:	85 c0                	test   %eax,%eax
  800404:	0f 84 42 04 00 00    	je     80084c <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80040a:	83 ec 08             	sub    $0x8,%esp
  80040d:	53                   	push   %ebx
  80040e:	50                   	push   %eax
  80040f:	ff d6                	call   *%esi
  800411:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800414:	83 c7 01             	add    $0x1,%edi
  800417:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80041b:	83 f8 25             	cmp    $0x25,%eax
  80041e:	75 e2                	jne    800402 <vprintfmt+0x14>
  800420:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800424:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80042b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800432:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800439:	b9 00 00 00 00       	mov    $0x0,%ecx
  80043e:	eb 07                	jmp    800447 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800440:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800443:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8d 47 01             	lea    0x1(%edi),%eax
  80044a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044d:	0f b6 07             	movzbl (%edi),%eax
  800450:	0f b6 d0             	movzbl %al,%edx
  800453:	83 e8 23             	sub    $0x23,%eax
  800456:	3c 55                	cmp    $0x55,%al
  800458:	0f 87 d3 03 00 00    	ja     800831 <vprintfmt+0x443>
  80045e:	0f b6 c0             	movzbl %al,%eax
  800461:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  800468:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80046b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80046f:	eb d6                	jmp    800447 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800471:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800474:	b8 00 00 00 00       	mov    $0x0,%eax
  800479:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80047c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80047f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800483:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800486:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800489:	83 f9 09             	cmp    $0x9,%ecx
  80048c:	77 3f                	ja     8004cd <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80048e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800491:	eb e9                	jmp    80047c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800493:	8b 45 14             	mov    0x14(%ebp),%eax
  800496:	8b 00                	mov    (%eax),%eax
  800498:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80049b:	8b 45 14             	mov    0x14(%ebp),%eax
  80049e:	8d 40 04             	lea    0x4(%eax),%eax
  8004a1:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004a7:	eb 2a                	jmp    8004d3 <vprintfmt+0xe5>
  8004a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ac:	85 c0                	test   %eax,%eax
  8004ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b3:	0f 49 d0             	cmovns %eax,%edx
  8004b6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004bc:	eb 89                	jmp    800447 <vprintfmt+0x59>
  8004be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004c8:	e9 7a ff ff ff       	jmp    800447 <vprintfmt+0x59>
  8004cd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004d0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d7:	0f 89 6a ff ff ff    	jns    800447 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004ea:	e9 58 ff ff ff       	jmp    800447 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004ef:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004f5:	e9 4d ff ff ff       	jmp    800447 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	8d 78 04             	lea    0x4(%eax),%edi
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	53                   	push   %ebx
  800504:	ff 30                	pushl  (%eax)
  800506:	ff d6                	call   *%esi
			break;
  800508:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80050b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800511:	e9 fe fe ff ff       	jmp    800414 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 78 04             	lea    0x4(%eax),%edi
  80051c:	8b 00                	mov    (%eax),%eax
  80051e:	99                   	cltd   
  80051f:	31 d0                	xor    %edx,%eax
  800521:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800523:	83 f8 0f             	cmp    $0xf,%eax
  800526:	7f 0b                	jg     800533 <vprintfmt+0x145>
  800528:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  80052f:	85 d2                	test   %edx,%edx
  800531:	75 1b                	jne    80054e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800533:	50                   	push   %eax
  800534:	68 a3 24 80 00       	push   $0x8024a3
  800539:	53                   	push   %ebx
  80053a:	56                   	push   %esi
  80053b:	e8 91 fe ff ff       	call   8003d1 <printfmt>
  800540:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800543:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800546:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800549:	e9 c6 fe ff ff       	jmp    800414 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80054e:	52                   	push   %edx
  80054f:	68 f9 28 80 00       	push   $0x8028f9
  800554:	53                   	push   %ebx
  800555:	56                   	push   %esi
  800556:	e8 76 fe ff ff       	call   8003d1 <printfmt>
  80055b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80055e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800561:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800564:	e9 ab fe ff ff       	jmp    800414 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	83 c0 04             	add    $0x4,%eax
  80056f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800577:	85 ff                	test   %edi,%edi
  800579:	b8 9c 24 80 00       	mov    $0x80249c,%eax
  80057e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800581:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800585:	0f 8e 94 00 00 00    	jle    80061f <vprintfmt+0x231>
  80058b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80058f:	0f 84 98 00 00 00    	je     80062d <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800595:	83 ec 08             	sub    $0x8,%esp
  800598:	ff 75 d0             	pushl  -0x30(%ebp)
  80059b:	57                   	push   %edi
  80059c:	e8 33 03 00 00       	call   8008d4 <strnlen>
  8005a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005a4:	29 c1                	sub    %eax,%ecx
  8005a6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005a9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005ac:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005b6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b8:	eb 0f                	jmp    8005c9 <vprintfmt+0x1db>
					putch(padc, putdat);
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	53                   	push   %ebx
  8005be:	ff 75 e0             	pushl  -0x20(%ebp)
  8005c1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	83 ef 01             	sub    $0x1,%edi
  8005c6:	83 c4 10             	add    $0x10,%esp
  8005c9:	85 ff                	test   %edi,%edi
  8005cb:	7f ed                	jg     8005ba <vprintfmt+0x1cc>
  8005cd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005d0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005d3:	85 c9                	test   %ecx,%ecx
  8005d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8005da:	0f 49 c1             	cmovns %ecx,%eax
  8005dd:	29 c1                	sub    %eax,%ecx
  8005df:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e8:	89 cb                	mov    %ecx,%ebx
  8005ea:	eb 4d                	jmp    800639 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ec:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005f0:	74 1b                	je     80060d <vprintfmt+0x21f>
  8005f2:	0f be c0             	movsbl %al,%eax
  8005f5:	83 e8 20             	sub    $0x20,%eax
  8005f8:	83 f8 5e             	cmp    $0x5e,%eax
  8005fb:	76 10                	jbe    80060d <vprintfmt+0x21f>
					putch('?', putdat);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	ff 75 0c             	pushl  0xc(%ebp)
  800603:	6a 3f                	push   $0x3f
  800605:	ff 55 08             	call   *0x8(%ebp)
  800608:	83 c4 10             	add    $0x10,%esp
  80060b:	eb 0d                	jmp    80061a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	ff 75 0c             	pushl  0xc(%ebp)
  800613:	52                   	push   %edx
  800614:	ff 55 08             	call   *0x8(%ebp)
  800617:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061a:	83 eb 01             	sub    $0x1,%ebx
  80061d:	eb 1a                	jmp    800639 <vprintfmt+0x24b>
  80061f:	89 75 08             	mov    %esi,0x8(%ebp)
  800622:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800625:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800628:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80062b:	eb 0c                	jmp    800639 <vprintfmt+0x24b>
  80062d:	89 75 08             	mov    %esi,0x8(%ebp)
  800630:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800633:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800636:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800639:	83 c7 01             	add    $0x1,%edi
  80063c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800640:	0f be d0             	movsbl %al,%edx
  800643:	85 d2                	test   %edx,%edx
  800645:	74 23                	je     80066a <vprintfmt+0x27c>
  800647:	85 f6                	test   %esi,%esi
  800649:	78 a1                	js     8005ec <vprintfmt+0x1fe>
  80064b:	83 ee 01             	sub    $0x1,%esi
  80064e:	79 9c                	jns    8005ec <vprintfmt+0x1fe>
  800650:	89 df                	mov    %ebx,%edi
  800652:	8b 75 08             	mov    0x8(%ebp),%esi
  800655:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800658:	eb 18                	jmp    800672 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	53                   	push   %ebx
  80065e:	6a 20                	push   $0x20
  800660:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800662:	83 ef 01             	sub    $0x1,%edi
  800665:	83 c4 10             	add    $0x10,%esp
  800668:	eb 08                	jmp    800672 <vprintfmt+0x284>
  80066a:	89 df                	mov    %ebx,%edi
  80066c:	8b 75 08             	mov    0x8(%ebp),%esi
  80066f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800672:	85 ff                	test   %edi,%edi
  800674:	7f e4                	jg     80065a <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800676:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800679:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067f:	e9 90 fd ff ff       	jmp    800414 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800684:	83 f9 01             	cmp    $0x1,%ecx
  800687:	7e 19                	jle    8006a2 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800689:	8b 45 14             	mov    0x14(%ebp),%eax
  80068c:	8b 50 04             	mov    0x4(%eax),%edx
  80068f:	8b 00                	mov    (%eax),%eax
  800691:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800694:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 40 08             	lea    0x8(%eax),%eax
  80069d:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a0:	eb 38                	jmp    8006da <vprintfmt+0x2ec>
	else if (lflag)
  8006a2:	85 c9                	test   %ecx,%ecx
  8006a4:	74 1b                	je     8006c1 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8b 00                	mov    (%eax),%eax
  8006ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ae:	89 c1                	mov    %eax,%ecx
  8006b0:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b9:	8d 40 04             	lea    0x4(%eax),%eax
  8006bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8006bf:	eb 19                	jmp    8006da <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8b 00                	mov    (%eax),%eax
  8006c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c9:	89 c1                	mov    %eax,%ecx
  8006cb:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ce:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8d 40 04             	lea    0x4(%eax),%eax
  8006d7:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006da:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006dd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006e0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006e5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006e9:	0f 89 0e 01 00 00    	jns    8007fd <vprintfmt+0x40f>
				putch('-', putdat);
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	53                   	push   %ebx
  8006f3:	6a 2d                	push   $0x2d
  8006f5:	ff d6                	call   *%esi
				num = -(long long) num;
  8006f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006fa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006fd:	f7 da                	neg    %edx
  8006ff:	83 d1 00             	adc    $0x0,%ecx
  800702:	f7 d9                	neg    %ecx
  800704:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800707:	b8 0a 00 00 00       	mov    $0xa,%eax
  80070c:	e9 ec 00 00 00       	jmp    8007fd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800711:	83 f9 01             	cmp    $0x1,%ecx
  800714:	7e 18                	jle    80072e <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800716:	8b 45 14             	mov    0x14(%ebp),%eax
  800719:	8b 10                	mov    (%eax),%edx
  80071b:	8b 48 04             	mov    0x4(%eax),%ecx
  80071e:	8d 40 08             	lea    0x8(%eax),%eax
  800721:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800724:	b8 0a 00 00 00       	mov    $0xa,%eax
  800729:	e9 cf 00 00 00       	jmp    8007fd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80072e:	85 c9                	test   %ecx,%ecx
  800730:	74 1a                	je     80074c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	8b 10                	mov    (%eax),%edx
  800737:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073c:	8d 40 04             	lea    0x4(%eax),%eax
  80073f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800742:	b8 0a 00 00 00       	mov    $0xa,%eax
  800747:	e9 b1 00 00 00       	jmp    8007fd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80074c:	8b 45 14             	mov    0x14(%ebp),%eax
  80074f:	8b 10                	mov    (%eax),%edx
  800751:	b9 00 00 00 00       	mov    $0x0,%ecx
  800756:	8d 40 04             	lea    0x4(%eax),%eax
  800759:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80075c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800761:	e9 97 00 00 00       	jmp    8007fd <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	53                   	push   %ebx
  80076a:	6a 58                	push   $0x58
  80076c:	ff d6                	call   *%esi
			putch('X', putdat);
  80076e:	83 c4 08             	add    $0x8,%esp
  800771:	53                   	push   %ebx
  800772:	6a 58                	push   $0x58
  800774:	ff d6                	call   *%esi
			putch('X', putdat);
  800776:	83 c4 08             	add    $0x8,%esp
  800779:	53                   	push   %ebx
  80077a:	6a 58                	push   $0x58
  80077c:	ff d6                	call   *%esi
			break;
  80077e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800781:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800784:	e9 8b fc ff ff       	jmp    800414 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800789:	83 ec 08             	sub    $0x8,%esp
  80078c:	53                   	push   %ebx
  80078d:	6a 30                	push   $0x30
  80078f:	ff d6                	call   *%esi
			putch('x', putdat);
  800791:	83 c4 08             	add    $0x8,%esp
  800794:	53                   	push   %ebx
  800795:	6a 78                	push   $0x78
  800797:	ff d6                	call   *%esi
			num = (unsigned long long)
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
  80079c:	8b 10                	mov    (%eax),%edx
  80079e:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007a3:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007a6:	8d 40 04             	lea    0x4(%eax),%eax
  8007a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ac:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007b1:	eb 4a                	jmp    8007fd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007b3:	83 f9 01             	cmp    $0x1,%ecx
  8007b6:	7e 15                	jle    8007cd <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8007b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bb:	8b 10                	mov    (%eax),%edx
  8007bd:	8b 48 04             	mov    0x4(%eax),%ecx
  8007c0:	8d 40 08             	lea    0x8(%eax),%eax
  8007c3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007c6:	b8 10 00 00 00       	mov    $0x10,%eax
  8007cb:	eb 30                	jmp    8007fd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007cd:	85 c9                	test   %ecx,%ecx
  8007cf:	74 17                	je     8007e8 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8007d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d4:	8b 10                	mov    (%eax),%edx
  8007d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007db:	8d 40 04             	lea    0x4(%eax),%eax
  8007de:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007e1:	b8 10 00 00 00       	mov    $0x10,%eax
  8007e6:	eb 15                	jmp    8007fd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8b 10                	mov    (%eax),%edx
  8007ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f2:	8d 40 04             	lea    0x4(%eax),%eax
  8007f5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007f8:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007fd:	83 ec 0c             	sub    $0xc,%esp
  800800:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800804:	57                   	push   %edi
  800805:	ff 75 e0             	pushl  -0x20(%ebp)
  800808:	50                   	push   %eax
  800809:	51                   	push   %ecx
  80080a:	52                   	push   %edx
  80080b:	89 da                	mov    %ebx,%edx
  80080d:	89 f0                	mov    %esi,%eax
  80080f:	e8 f1 fa ff ff       	call   800305 <printnum>
			break;
  800814:	83 c4 20             	add    $0x20,%esp
  800817:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80081a:	e9 f5 fb ff ff       	jmp    800414 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	53                   	push   %ebx
  800823:	52                   	push   %edx
  800824:	ff d6                	call   *%esi
			break;
  800826:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800829:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80082c:	e9 e3 fb ff ff       	jmp    800414 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800831:	83 ec 08             	sub    $0x8,%esp
  800834:	53                   	push   %ebx
  800835:	6a 25                	push   $0x25
  800837:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800839:	83 c4 10             	add    $0x10,%esp
  80083c:	eb 03                	jmp    800841 <vprintfmt+0x453>
  80083e:	83 ef 01             	sub    $0x1,%edi
  800841:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800845:	75 f7                	jne    80083e <vprintfmt+0x450>
  800847:	e9 c8 fb ff ff       	jmp    800414 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80084c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80084f:	5b                   	pop    %ebx
  800850:	5e                   	pop    %esi
  800851:	5f                   	pop    %edi
  800852:	5d                   	pop    %ebp
  800853:	c3                   	ret    

00800854 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	83 ec 18             	sub    $0x18,%esp
  80085a:	8b 45 08             	mov    0x8(%ebp),%eax
  80085d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800860:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800863:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800867:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80086a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800871:	85 c0                	test   %eax,%eax
  800873:	74 26                	je     80089b <vsnprintf+0x47>
  800875:	85 d2                	test   %edx,%edx
  800877:	7e 22                	jle    80089b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800879:	ff 75 14             	pushl  0x14(%ebp)
  80087c:	ff 75 10             	pushl  0x10(%ebp)
  80087f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800882:	50                   	push   %eax
  800883:	68 b4 03 80 00       	push   $0x8003b4
  800888:	e8 61 fb ff ff       	call   8003ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80088d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800890:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800893:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800896:	83 c4 10             	add    $0x10,%esp
  800899:	eb 05                	jmp    8008a0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80089b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008a0:	c9                   	leave  
  8008a1:	c3                   	ret    

008008a2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ab:	50                   	push   %eax
  8008ac:	ff 75 10             	pushl  0x10(%ebp)
  8008af:	ff 75 0c             	pushl  0xc(%ebp)
  8008b2:	ff 75 08             	pushl  0x8(%ebp)
  8008b5:	e8 9a ff ff ff       	call   800854 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ba:	c9                   	leave  
  8008bb:	c3                   	ret    

008008bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c7:	eb 03                	jmp    8008cc <strlen+0x10>
		n++;
  8008c9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008cc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d0:	75 f7                	jne    8008c9 <strlen+0xd>
		n++;
	return n;
}
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008da:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e2:	eb 03                	jmp    8008e7 <strnlen+0x13>
		n++;
  8008e4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e7:	39 c2                	cmp    %eax,%edx
  8008e9:	74 08                	je     8008f3 <strnlen+0x1f>
  8008eb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008ef:	75 f3                	jne    8008e4 <strnlen+0x10>
  8008f1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	53                   	push   %ebx
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ff:	89 c2                	mov    %eax,%edx
  800901:	83 c2 01             	add    $0x1,%edx
  800904:	83 c1 01             	add    $0x1,%ecx
  800907:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80090b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80090e:	84 db                	test   %bl,%bl
  800910:	75 ef                	jne    800901 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800912:	5b                   	pop    %ebx
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	53                   	push   %ebx
  800919:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80091c:	53                   	push   %ebx
  80091d:	e8 9a ff ff ff       	call   8008bc <strlen>
  800922:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800925:	ff 75 0c             	pushl  0xc(%ebp)
  800928:	01 d8                	add    %ebx,%eax
  80092a:	50                   	push   %eax
  80092b:	e8 c5 ff ff ff       	call   8008f5 <strcpy>
	return dst;
}
  800930:	89 d8                	mov    %ebx,%eax
  800932:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800935:	c9                   	leave  
  800936:	c3                   	ret    

00800937 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	56                   	push   %esi
  80093b:	53                   	push   %ebx
  80093c:	8b 75 08             	mov    0x8(%ebp),%esi
  80093f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800942:	89 f3                	mov    %esi,%ebx
  800944:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800947:	89 f2                	mov    %esi,%edx
  800949:	eb 0f                	jmp    80095a <strncpy+0x23>
		*dst++ = *src;
  80094b:	83 c2 01             	add    $0x1,%edx
  80094e:	0f b6 01             	movzbl (%ecx),%eax
  800951:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800954:	80 39 01             	cmpb   $0x1,(%ecx)
  800957:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80095a:	39 da                	cmp    %ebx,%edx
  80095c:	75 ed                	jne    80094b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80095e:	89 f0                	mov    %esi,%eax
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	56                   	push   %esi
  800968:	53                   	push   %ebx
  800969:	8b 75 08             	mov    0x8(%ebp),%esi
  80096c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096f:	8b 55 10             	mov    0x10(%ebp),%edx
  800972:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800974:	85 d2                	test   %edx,%edx
  800976:	74 21                	je     800999 <strlcpy+0x35>
  800978:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80097c:	89 f2                	mov    %esi,%edx
  80097e:	eb 09                	jmp    800989 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800980:	83 c2 01             	add    $0x1,%edx
  800983:	83 c1 01             	add    $0x1,%ecx
  800986:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800989:	39 c2                	cmp    %eax,%edx
  80098b:	74 09                	je     800996 <strlcpy+0x32>
  80098d:	0f b6 19             	movzbl (%ecx),%ebx
  800990:	84 db                	test   %bl,%bl
  800992:	75 ec                	jne    800980 <strlcpy+0x1c>
  800994:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800996:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800999:	29 f0                	sub    %esi,%eax
}
  80099b:	5b                   	pop    %ebx
  80099c:	5e                   	pop    %esi
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a8:	eb 06                	jmp    8009b0 <strcmp+0x11>
		p++, q++;
  8009aa:	83 c1 01             	add    $0x1,%ecx
  8009ad:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009b0:	0f b6 01             	movzbl (%ecx),%eax
  8009b3:	84 c0                	test   %al,%al
  8009b5:	74 04                	je     8009bb <strcmp+0x1c>
  8009b7:	3a 02                	cmp    (%edx),%al
  8009b9:	74 ef                	je     8009aa <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009bb:	0f b6 c0             	movzbl %al,%eax
  8009be:	0f b6 12             	movzbl (%edx),%edx
  8009c1:	29 d0                	sub    %edx,%eax
}
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	53                   	push   %ebx
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cf:	89 c3                	mov    %eax,%ebx
  8009d1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009d4:	eb 06                	jmp    8009dc <strncmp+0x17>
		n--, p++, q++;
  8009d6:	83 c0 01             	add    $0x1,%eax
  8009d9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009dc:	39 d8                	cmp    %ebx,%eax
  8009de:	74 15                	je     8009f5 <strncmp+0x30>
  8009e0:	0f b6 08             	movzbl (%eax),%ecx
  8009e3:	84 c9                	test   %cl,%cl
  8009e5:	74 04                	je     8009eb <strncmp+0x26>
  8009e7:	3a 0a                	cmp    (%edx),%cl
  8009e9:	74 eb                	je     8009d6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009eb:	0f b6 00             	movzbl (%eax),%eax
  8009ee:	0f b6 12             	movzbl (%edx),%edx
  8009f1:	29 d0                	sub    %edx,%eax
  8009f3:	eb 05                	jmp    8009fa <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009f5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009fa:	5b                   	pop    %ebx
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a07:	eb 07                	jmp    800a10 <strchr+0x13>
		if (*s == c)
  800a09:	38 ca                	cmp    %cl,%dl
  800a0b:	74 0f                	je     800a1c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a0d:	83 c0 01             	add    $0x1,%eax
  800a10:	0f b6 10             	movzbl (%eax),%edx
  800a13:	84 d2                	test   %dl,%dl
  800a15:	75 f2                	jne    800a09 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a28:	eb 03                	jmp    800a2d <strfind+0xf>
  800a2a:	83 c0 01             	add    $0x1,%eax
  800a2d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a30:	38 ca                	cmp    %cl,%dl
  800a32:	74 04                	je     800a38 <strfind+0x1a>
  800a34:	84 d2                	test   %dl,%dl
  800a36:	75 f2                	jne    800a2a <strfind+0xc>
			break;
	return (char *) s;
}
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	57                   	push   %edi
  800a3e:	56                   	push   %esi
  800a3f:	53                   	push   %ebx
  800a40:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a43:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a46:	85 c9                	test   %ecx,%ecx
  800a48:	74 36                	je     800a80 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a50:	75 28                	jne    800a7a <memset+0x40>
  800a52:	f6 c1 03             	test   $0x3,%cl
  800a55:	75 23                	jne    800a7a <memset+0x40>
		c &= 0xFF;
  800a57:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a5b:	89 d3                	mov    %edx,%ebx
  800a5d:	c1 e3 08             	shl    $0x8,%ebx
  800a60:	89 d6                	mov    %edx,%esi
  800a62:	c1 e6 18             	shl    $0x18,%esi
  800a65:	89 d0                	mov    %edx,%eax
  800a67:	c1 e0 10             	shl    $0x10,%eax
  800a6a:	09 f0                	or     %esi,%eax
  800a6c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a6e:	89 d8                	mov    %ebx,%eax
  800a70:	09 d0                	or     %edx,%eax
  800a72:	c1 e9 02             	shr    $0x2,%ecx
  800a75:	fc                   	cld    
  800a76:	f3 ab                	rep stos %eax,%es:(%edi)
  800a78:	eb 06                	jmp    800a80 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7d:	fc                   	cld    
  800a7e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a80:	89 f8                	mov    %edi,%eax
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5f                   	pop    %edi
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	57                   	push   %edi
  800a8b:	56                   	push   %esi
  800a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a92:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a95:	39 c6                	cmp    %eax,%esi
  800a97:	73 35                	jae    800ace <memmove+0x47>
  800a99:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a9c:	39 d0                	cmp    %edx,%eax
  800a9e:	73 2e                	jae    800ace <memmove+0x47>
		s += n;
		d += n;
  800aa0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa3:	89 d6                	mov    %edx,%esi
  800aa5:	09 fe                	or     %edi,%esi
  800aa7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aad:	75 13                	jne    800ac2 <memmove+0x3b>
  800aaf:	f6 c1 03             	test   $0x3,%cl
  800ab2:	75 0e                	jne    800ac2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ab4:	83 ef 04             	sub    $0x4,%edi
  800ab7:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aba:	c1 e9 02             	shr    $0x2,%ecx
  800abd:	fd                   	std    
  800abe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac0:	eb 09                	jmp    800acb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ac2:	83 ef 01             	sub    $0x1,%edi
  800ac5:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ac8:	fd                   	std    
  800ac9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800acb:	fc                   	cld    
  800acc:	eb 1d                	jmp    800aeb <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ace:	89 f2                	mov    %esi,%edx
  800ad0:	09 c2                	or     %eax,%edx
  800ad2:	f6 c2 03             	test   $0x3,%dl
  800ad5:	75 0f                	jne    800ae6 <memmove+0x5f>
  800ad7:	f6 c1 03             	test   $0x3,%cl
  800ada:	75 0a                	jne    800ae6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800adc:	c1 e9 02             	shr    $0x2,%ecx
  800adf:	89 c7                	mov    %eax,%edi
  800ae1:	fc                   	cld    
  800ae2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae4:	eb 05                	jmp    800aeb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ae6:	89 c7                	mov    %eax,%edi
  800ae8:	fc                   	cld    
  800ae9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aeb:	5e                   	pop    %esi
  800aec:	5f                   	pop    %edi
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800af2:	ff 75 10             	pushl  0x10(%ebp)
  800af5:	ff 75 0c             	pushl  0xc(%ebp)
  800af8:	ff 75 08             	pushl  0x8(%ebp)
  800afb:	e8 87 ff ff ff       	call   800a87 <memmove>
}
  800b00:	c9                   	leave  
  800b01:	c3                   	ret    

00800b02 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0d:	89 c6                	mov    %eax,%esi
  800b0f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b12:	eb 1a                	jmp    800b2e <memcmp+0x2c>
		if (*s1 != *s2)
  800b14:	0f b6 08             	movzbl (%eax),%ecx
  800b17:	0f b6 1a             	movzbl (%edx),%ebx
  800b1a:	38 d9                	cmp    %bl,%cl
  800b1c:	74 0a                	je     800b28 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b1e:	0f b6 c1             	movzbl %cl,%eax
  800b21:	0f b6 db             	movzbl %bl,%ebx
  800b24:	29 d8                	sub    %ebx,%eax
  800b26:	eb 0f                	jmp    800b37 <memcmp+0x35>
		s1++, s2++;
  800b28:	83 c0 01             	add    $0x1,%eax
  800b2b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2e:	39 f0                	cmp    %esi,%eax
  800b30:	75 e2                	jne    800b14 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b32:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	53                   	push   %ebx
  800b3f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b42:	89 c1                	mov    %eax,%ecx
  800b44:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b47:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b4b:	eb 0a                	jmp    800b57 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b4d:	0f b6 10             	movzbl (%eax),%edx
  800b50:	39 da                	cmp    %ebx,%edx
  800b52:	74 07                	je     800b5b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b54:	83 c0 01             	add    $0x1,%eax
  800b57:	39 c8                	cmp    %ecx,%eax
  800b59:	72 f2                	jb     800b4d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b5b:	5b                   	pop    %ebx
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6a:	eb 03                	jmp    800b6f <strtol+0x11>
		s++;
  800b6c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6f:	0f b6 01             	movzbl (%ecx),%eax
  800b72:	3c 20                	cmp    $0x20,%al
  800b74:	74 f6                	je     800b6c <strtol+0xe>
  800b76:	3c 09                	cmp    $0x9,%al
  800b78:	74 f2                	je     800b6c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b7a:	3c 2b                	cmp    $0x2b,%al
  800b7c:	75 0a                	jne    800b88 <strtol+0x2a>
		s++;
  800b7e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b81:	bf 00 00 00 00       	mov    $0x0,%edi
  800b86:	eb 11                	jmp    800b99 <strtol+0x3b>
  800b88:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b8d:	3c 2d                	cmp    $0x2d,%al
  800b8f:	75 08                	jne    800b99 <strtol+0x3b>
		s++, neg = 1;
  800b91:	83 c1 01             	add    $0x1,%ecx
  800b94:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b99:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b9f:	75 15                	jne    800bb6 <strtol+0x58>
  800ba1:	80 39 30             	cmpb   $0x30,(%ecx)
  800ba4:	75 10                	jne    800bb6 <strtol+0x58>
  800ba6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800baa:	75 7c                	jne    800c28 <strtol+0xca>
		s += 2, base = 16;
  800bac:	83 c1 02             	add    $0x2,%ecx
  800baf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bb4:	eb 16                	jmp    800bcc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bb6:	85 db                	test   %ebx,%ebx
  800bb8:	75 12                	jne    800bcc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bba:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bbf:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc2:	75 08                	jne    800bcc <strtol+0x6e>
		s++, base = 8;
  800bc4:	83 c1 01             	add    $0x1,%ecx
  800bc7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bd4:	0f b6 11             	movzbl (%ecx),%edx
  800bd7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bda:	89 f3                	mov    %esi,%ebx
  800bdc:	80 fb 09             	cmp    $0x9,%bl
  800bdf:	77 08                	ja     800be9 <strtol+0x8b>
			dig = *s - '0';
  800be1:	0f be d2             	movsbl %dl,%edx
  800be4:	83 ea 30             	sub    $0x30,%edx
  800be7:	eb 22                	jmp    800c0b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800be9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bec:	89 f3                	mov    %esi,%ebx
  800bee:	80 fb 19             	cmp    $0x19,%bl
  800bf1:	77 08                	ja     800bfb <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bf3:	0f be d2             	movsbl %dl,%edx
  800bf6:	83 ea 57             	sub    $0x57,%edx
  800bf9:	eb 10                	jmp    800c0b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bfb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bfe:	89 f3                	mov    %esi,%ebx
  800c00:	80 fb 19             	cmp    $0x19,%bl
  800c03:	77 16                	ja     800c1b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c05:	0f be d2             	movsbl %dl,%edx
  800c08:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c0b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c0e:	7d 0b                	jge    800c1b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c10:	83 c1 01             	add    $0x1,%ecx
  800c13:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c17:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c19:	eb b9                	jmp    800bd4 <strtol+0x76>

	if (endptr)
  800c1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c1f:	74 0d                	je     800c2e <strtol+0xd0>
		*endptr = (char *) s;
  800c21:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c24:	89 0e                	mov    %ecx,(%esi)
  800c26:	eb 06                	jmp    800c2e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c28:	85 db                	test   %ebx,%ebx
  800c2a:	74 98                	je     800bc4 <strtol+0x66>
  800c2c:	eb 9e                	jmp    800bcc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c2e:	89 c2                	mov    %eax,%edx
  800c30:	f7 da                	neg    %edx
  800c32:	85 ff                	test   %edi,%edi
  800c34:	0f 45 c2             	cmovne %edx,%eax
}
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	57                   	push   %edi
  800c40:	56                   	push   %esi
  800c41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c42:	b8 00 00 00 00       	mov    $0x0,%eax
  800c47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4d:	89 c3                	mov    %eax,%ebx
  800c4f:	89 c7                	mov    %eax,%edi
  800c51:	89 c6                	mov    %eax,%esi
  800c53:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_cgetc>:

int
sys_cgetc(void)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	ba 00 00 00 00       	mov    $0x0,%edx
  800c65:	b8 01 00 00 00       	mov    $0x1,%eax
  800c6a:	89 d1                	mov    %edx,%ecx
  800c6c:	89 d3                	mov    %edx,%ebx
  800c6e:	89 d7                	mov    %edx,%edi
  800c70:	89 d6                	mov    %edx,%esi
  800c72:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
  800c7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c87:	b8 03 00 00 00       	mov    $0x3,%eax
  800c8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8f:	89 cb                	mov    %ecx,%ebx
  800c91:	89 cf                	mov    %ecx,%edi
  800c93:	89 ce                	mov    %ecx,%esi
  800c95:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c97:	85 c0                	test   %eax,%eax
  800c99:	7e 17                	jle    800cb2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9b:	83 ec 0c             	sub    $0xc,%esp
  800c9e:	50                   	push   %eax
  800c9f:	6a 03                	push   $0x3
  800ca1:	68 7f 27 80 00       	push   $0x80277f
  800ca6:	6a 23                	push   $0x23
  800ca8:	68 9c 27 80 00       	push   $0x80279c
  800cad:	e8 66 f5 ff ff       	call   800218 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc5:	b8 02 00 00 00       	mov    $0x2,%eax
  800cca:	89 d1                	mov    %edx,%ecx
  800ccc:	89 d3                	mov    %edx,%ebx
  800cce:	89 d7                	mov    %edx,%edi
  800cd0:	89 d6                	mov    %edx,%esi
  800cd2:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <sys_yield>:

void
sys_yield(void)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ce9:	89 d1                	mov    %edx,%ecx
  800ceb:	89 d3                	mov    %edx,%ebx
  800ced:	89 d7                	mov    %edx,%edi
  800cef:	89 d6                	mov    %edx,%esi
  800cf1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	57                   	push   %edi
  800cfc:	56                   	push   %esi
  800cfd:	53                   	push   %ebx
  800cfe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d01:	be 00 00 00 00       	mov    $0x0,%esi
  800d06:	b8 04 00 00 00       	mov    $0x4,%eax
  800d0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d11:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d14:	89 f7                	mov    %esi,%edi
  800d16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7e 17                	jle    800d33 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1c:	83 ec 0c             	sub    $0xc,%esp
  800d1f:	50                   	push   %eax
  800d20:	6a 04                	push   $0x4
  800d22:	68 7f 27 80 00       	push   $0x80277f
  800d27:	6a 23                	push   $0x23
  800d29:	68 9c 27 80 00       	push   $0x80279c
  800d2e:	e8 e5 f4 ff ff       	call   800218 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d44:	b8 05 00 00 00       	mov    $0x5,%eax
  800d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d55:	8b 75 18             	mov    0x18(%ebp),%esi
  800d58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	7e 17                	jle    800d75 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5e:	83 ec 0c             	sub    $0xc,%esp
  800d61:	50                   	push   %eax
  800d62:	6a 05                	push   $0x5
  800d64:	68 7f 27 80 00       	push   $0x80277f
  800d69:	6a 23                	push   $0x23
  800d6b:	68 9c 27 80 00       	push   $0x80279c
  800d70:	e8 a3 f4 ff ff       	call   800218 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
  800d83:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8b:	b8 06 00 00 00       	mov    $0x6,%eax
  800d90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d93:	8b 55 08             	mov    0x8(%ebp),%edx
  800d96:	89 df                	mov    %ebx,%edi
  800d98:	89 de                	mov    %ebx,%esi
  800d9a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	7e 17                	jle    800db7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da0:	83 ec 0c             	sub    $0xc,%esp
  800da3:	50                   	push   %eax
  800da4:	6a 06                	push   $0x6
  800da6:	68 7f 27 80 00       	push   $0x80277f
  800dab:	6a 23                	push   $0x23
  800dad:	68 9c 27 80 00       	push   $0x80279c
  800db2:	e8 61 f4 ff ff       	call   800218 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800db7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dba:	5b                   	pop    %ebx
  800dbb:	5e                   	pop    %esi
  800dbc:	5f                   	pop    %edi
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
  800dc5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcd:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd8:	89 df                	mov    %ebx,%edi
  800dda:	89 de                	mov    %ebx,%esi
  800ddc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dde:	85 c0                	test   %eax,%eax
  800de0:	7e 17                	jle    800df9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de2:	83 ec 0c             	sub    $0xc,%esp
  800de5:	50                   	push   %eax
  800de6:	6a 08                	push   $0x8
  800de8:	68 7f 27 80 00       	push   $0x80277f
  800ded:	6a 23                	push   $0x23
  800def:	68 9c 27 80 00       	push   $0x80279c
  800df4:	e8 1f f4 ff ff       	call   800218 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800df9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfc:	5b                   	pop    %ebx
  800dfd:	5e                   	pop    %esi
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
  800e07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0f:	b8 09 00 00 00       	mov    $0x9,%eax
  800e14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e17:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1a:	89 df                	mov    %ebx,%edi
  800e1c:	89 de                	mov    %ebx,%esi
  800e1e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e20:	85 c0                	test   %eax,%eax
  800e22:	7e 17                	jle    800e3b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e24:	83 ec 0c             	sub    $0xc,%esp
  800e27:	50                   	push   %eax
  800e28:	6a 09                	push   $0x9
  800e2a:	68 7f 27 80 00       	push   $0x80277f
  800e2f:	6a 23                	push   $0x23
  800e31:	68 9c 27 80 00       	push   $0x80279c
  800e36:	e8 dd f3 ff ff       	call   800218 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3e:	5b                   	pop    %ebx
  800e3f:	5e                   	pop    %esi
  800e40:	5f                   	pop    %edi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	57                   	push   %edi
  800e47:	56                   	push   %esi
  800e48:	53                   	push   %ebx
  800e49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e51:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e59:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5c:	89 df                	mov    %ebx,%edi
  800e5e:	89 de                	mov    %ebx,%esi
  800e60:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e62:	85 c0                	test   %eax,%eax
  800e64:	7e 17                	jle    800e7d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e66:	83 ec 0c             	sub    $0xc,%esp
  800e69:	50                   	push   %eax
  800e6a:	6a 0a                	push   $0xa
  800e6c:	68 7f 27 80 00       	push   $0x80277f
  800e71:	6a 23                	push   $0x23
  800e73:	68 9c 27 80 00       	push   $0x80279c
  800e78:	e8 9b f3 ff ff       	call   800218 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	57                   	push   %edi
  800e89:	56                   	push   %esi
  800e8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8b:	be 00 00 00 00       	mov    $0x0,%esi
  800e90:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e98:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ea1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    

00800ea8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	57                   	push   %edi
  800eac:	56                   	push   %esi
  800ead:	53                   	push   %ebx
  800eae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ebb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebe:	89 cb                	mov    %ecx,%ebx
  800ec0:	89 cf                	mov    %ecx,%edi
  800ec2:	89 ce                	mov    %ecx,%esi
  800ec4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	7e 17                	jle    800ee1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eca:	83 ec 0c             	sub    $0xc,%esp
  800ecd:	50                   	push   %eax
  800ece:	6a 0d                	push   $0xd
  800ed0:	68 7f 27 80 00       	push   $0x80277f
  800ed5:	6a 23                	push   $0x23
  800ed7:	68 9c 27 80 00       	push   $0x80279c
  800edc:	e8 37 f3 ff ff       	call   800218 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ee1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee4:	5b                   	pop    %ebx
  800ee5:	5e                   	pop    %esi
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    

00800ee9 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	53                   	push   %ebx
  800eed:	83 ec 04             	sub    $0x4,%esp
  800ef0:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ef3:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800ef5:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ef9:	74 2d                	je     800f28 <pgfault+0x3f>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800efb:	89 d8                	mov    %ebx,%eax
  800efd:	c1 e8 16             	shr    $0x16,%eax
  800f00:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f07:	a8 01                	test   $0x1,%al
  800f09:	74 1d                	je     800f28 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800f0b:	89 d8                	mov    %ebx,%eax
  800f0d:	c1 e8 0c             	shr    $0xc,%eax
  800f10:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800f17:	f6 c2 01             	test   $0x1,%dl
  800f1a:	74 0c                	je     800f28 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800f1c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800f23:	f6 c4 08             	test   $0x8,%ah
  800f26:	75 14                	jne    800f3c <pgfault+0x53>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
	)) panic("Neither the fault is a write nor copy-on-write page.\n");
  800f28:	83 ec 04             	sub    $0x4,%esp
  800f2b:	68 ac 27 80 00       	push   $0x8027ac
  800f30:	6a 1f                	push   $0x1f
  800f32:	68 e2 27 80 00       	push   $0x8027e2
  800f37:	e8 dc f2 ff ff       	call   800218 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if((r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W)) < 0){
  800f3c:	83 ec 04             	sub    $0x4,%esp
  800f3f:	6a 07                	push   $0x7
  800f41:	68 00 f0 7f 00       	push   $0x7ff000
  800f46:	6a 00                	push   $0x0
  800f48:	e8 ab fd ff ff       	call   800cf8 <sys_page_alloc>
  800f4d:	83 c4 10             	add    $0x10,%esp
  800f50:	85 c0                	test   %eax,%eax
  800f52:	79 12                	jns    800f66 <pgfault+0x7d>
		 panic("sys_page_alloc: %e\n", r);
  800f54:	50                   	push   %eax
  800f55:	68 ed 27 80 00       	push   $0x8027ed
  800f5a:	6a 29                	push   $0x29
  800f5c:	68 e2 27 80 00       	push   $0x8027e2
  800f61:	e8 b2 f2 ff ff       	call   800218 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f66:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800f6c:	83 ec 04             	sub    $0x4,%esp
  800f6f:	68 00 10 00 00       	push   $0x1000
  800f74:	53                   	push   %ebx
  800f75:	68 00 f0 7f 00       	push   $0x7ff000
  800f7a:	e8 70 fb ff ff       	call   800aef <memcpy>
	if ((r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  800f7f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f86:	53                   	push   %ebx
  800f87:	6a 00                	push   $0x0
  800f89:	68 00 f0 7f 00       	push   $0x7ff000
  800f8e:	6a 00                	push   $0x0
  800f90:	e8 a6 fd ff ff       	call   800d3b <sys_page_map>
  800f95:	83 c4 20             	add    $0x20,%esp
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	79 12                	jns    800fae <pgfault+0xc5>
        panic("sys_page_map: %e\n", r);
  800f9c:	50                   	push   %eax
  800f9d:	68 01 28 80 00       	push   $0x802801
  800fa2:	6a 2e                	push   $0x2e
  800fa4:	68 e2 27 80 00       	push   $0x8027e2
  800fa9:	e8 6a f2 ff ff       	call   800218 <_panic>
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  800fae:	83 ec 08             	sub    $0x8,%esp
  800fb1:	68 00 f0 7f 00       	push   $0x7ff000
  800fb6:	6a 00                	push   $0x0
  800fb8:	e8 c0 fd ff ff       	call   800d7d <sys_page_unmap>
  800fbd:	83 c4 10             	add    $0x10,%esp
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	79 12                	jns    800fd6 <pgfault+0xed>
        panic("sys_page_unmap: %e\n", r);
  800fc4:	50                   	push   %eax
  800fc5:	68 13 28 80 00       	push   $0x802813
  800fca:	6a 30                	push   $0x30
  800fcc:	68 e2 27 80 00       	push   $0x8027e2
  800fd1:	e8 42 f2 ff ff       	call   800218 <_panic>
	//panic("pgfault not implemented");
}
  800fd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd9:	c9                   	leave  
  800fda:	c3                   	ret    

00800fdb <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	57                   	push   %edi
  800fdf:	56                   	push   %esi
  800fe0:	53                   	push   %ebx
  800fe1:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	envid_t cenvid;
    unsigned pn;
    int r;
	set_pgfault_handler(pgfault);
  800fe4:	68 e9 0e 80 00       	push   $0x800ee9
  800fe9:	e8 d3 0e 00 00       	call   801ec1 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fee:	b8 07 00 00 00       	mov    $0x7,%eax
  800ff3:	cd 30                	int    $0x30
  800ff5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((cenvid = sys_exofork()) < 0){
  800ff8:	83 c4 10             	add    $0x10,%esp
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	79 14                	jns    801013 <fork+0x38>
		panic("sys_exofork failed");
  800fff:	83 ec 04             	sub    $0x4,%esp
  801002:	68 27 28 80 00       	push   $0x802827
  801007:	6a 6f                	push   $0x6f
  801009:	68 e2 27 80 00       	push   $0x8027e2
  80100e:	e8 05 f2 ff ff       	call   800218 <_panic>
  801013:	89 c7                	mov    %eax,%edi
		return cenvid;
	}
	if(cenvid>0){
  801015:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801019:	0f 8e 2b 01 00 00    	jle    80114a <fork+0x16f>
  80101f:	bb 00 08 00 00       	mov    $0x800,%ebx
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
  801024:	89 d8                	mov    %ebx,%eax
  801026:	c1 e8 0a             	shr    $0xa,%eax
  801029:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801030:	a8 01                	test   $0x1,%al
  801032:	0f 84 bf 00 00 00    	je     8010f7 <fork+0x11c>
  801038:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80103f:	a8 01                	test   $0x1,%al
  801041:	0f 84 b0 00 00 00    	je     8010f7 <fork+0x11c>
  801047:	89 de                	mov    %ebx,%esi
  801049:	c1 e6 0c             	shl    $0xc,%esi
{
	int r;

	// LAB 4: Your code here.
	void* vaddr=(void*)(pn*PGSIZE);
	if(uvpt[pn]&PTE_SHARE){
  80104c:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801053:	f6 c4 04             	test   $0x4,%ah
  801056:	74 29                	je     801081 <fork+0xa6>
		if((r=sys_page_map(0,vaddr,envid,vaddr,uvpt[pn]&PTE_SYSCALL))<0)return r;
  801058:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80105f:	83 ec 0c             	sub    $0xc,%esp
  801062:	25 07 0e 00 00       	and    $0xe07,%eax
  801067:	50                   	push   %eax
  801068:	56                   	push   %esi
  801069:	57                   	push   %edi
  80106a:	56                   	push   %esi
  80106b:	6a 00                	push   $0x0
  80106d:	e8 c9 fc ff ff       	call   800d3b <sys_page_map>
  801072:	83 c4 20             	add    $0x20,%esp
  801075:	85 c0                	test   %eax,%eax
  801077:	ba 00 00 00 00       	mov    $0x0,%edx
  80107c:	0f 4f c2             	cmovg  %edx,%eax
  80107f:	eb 72                	jmp    8010f3 <fork+0x118>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  801081:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801088:	a8 02                	test   $0x2,%al
  80108a:	75 0c                	jne    801098 <fork+0xbd>
  80108c:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801093:	f6 c4 08             	test   $0x8,%ah
  801096:	74 3f                	je     8010d7 <fork+0xfc>
		if ((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  801098:	83 ec 0c             	sub    $0xc,%esp
  80109b:	68 05 08 00 00       	push   $0x805
  8010a0:	56                   	push   %esi
  8010a1:	57                   	push   %edi
  8010a2:	56                   	push   %esi
  8010a3:	6a 00                	push   $0x0
  8010a5:	e8 91 fc ff ff       	call   800d3b <sys_page_map>
  8010aa:	83 c4 20             	add    $0x20,%esp
  8010ad:	85 c0                	test   %eax,%eax
  8010af:	0f 88 b1 00 00 00    	js     801166 <fork+0x18b>
            return r;
        if ((r = sys_page_map(0, vaddr, 0, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  8010b5:	83 ec 0c             	sub    $0xc,%esp
  8010b8:	68 05 08 00 00       	push   $0x805
  8010bd:	56                   	push   %esi
  8010be:	6a 00                	push   $0x0
  8010c0:	56                   	push   %esi
  8010c1:	6a 00                	push   $0x0
  8010c3:	e8 73 fc ff ff       	call   800d3b <sys_page_map>
  8010c8:	83 c4 20             	add    $0x20,%esp
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010d2:	0f 4f c1             	cmovg  %ecx,%eax
  8010d5:	eb 1c                	jmp    8010f3 <fork+0x118>
            return r;
	}
	else if((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U)) < 0) {
  8010d7:	83 ec 0c             	sub    $0xc,%esp
  8010da:	6a 05                	push   $0x5
  8010dc:	56                   	push   %esi
  8010dd:	57                   	push   %edi
  8010de:	56                   	push   %esi
  8010df:	6a 00                	push   $0x0
  8010e1:	e8 55 fc ff ff       	call   800d3b <sys_page_map>
  8010e6:	83 c4 20             	add    $0x20,%esp
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010f0:	0f 4f c1             	cmovg  %ecx,%eax
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	78 6f                	js     801166 <fork+0x18b>
	if ((cenvid = sys_exofork()) < 0){
		panic("sys_exofork failed");
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  8010f7:	83 c3 01             	add    $0x1,%ebx
  8010fa:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801100:	0f 85 1e ff ff ff    	jne    801024 <fork+0x49>
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
                    return r;
		}
		if ((r = sys_page_alloc(cenvid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  801106:	83 ec 04             	sub    $0x4,%esp
  801109:	6a 07                	push   $0x7
  80110b:	68 00 f0 bf ee       	push   $0xeebff000
  801110:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801113:	57                   	push   %edi
  801114:	e8 df fb ff ff       	call   800cf8 <sys_page_alloc>
  801119:	83 c4 10             	add    $0x10,%esp
  80111c:	85 c0                	test   %eax,%eax
  80111e:	78 46                	js     801166 <fork+0x18b>
            return r;
		extern void _pgfault_upcall(void);
		if ((r = sys_env_set_pgfault_upcall(cenvid, _pgfault_upcall)) < 0)
  801120:	83 ec 08             	sub    $0x8,%esp
  801123:	68 24 1f 80 00       	push   $0x801f24
  801128:	57                   	push   %edi
  801129:	e8 15 fd ff ff       	call   800e43 <sys_env_set_pgfault_upcall>
  80112e:	83 c4 10             	add    $0x10,%esp
  801131:	85 c0                	test   %eax,%eax
  801133:	78 31                	js     801166 <fork+0x18b>
            return r;
		if ((r = sys_env_set_status(cenvid, ENV_RUNNABLE)) < 0)
  801135:	83 ec 08             	sub    $0x8,%esp
  801138:	6a 02                	push   $0x2
  80113a:	57                   	push   %edi
  80113b:	e8 7f fc ff ff       	call   800dbf <sys_env_set_status>
  801140:	83 c4 10             	add    $0x10,%esp
            return r;
        return cenvid;
  801143:	85 c0                	test   %eax,%eax
  801145:	0f 49 c7             	cmovns %edi,%eax
  801148:	eb 1c                	jmp    801166 <fork+0x18b>
	}
	else {
		thisenv = &envs[ENVX(sys_getenvid())];
  80114a:	e8 6b fb ff ff       	call   800cba <sys_getenvid>
  80114f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801154:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801157:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80115c:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  801161:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//panic("fork not implemented");
	
}
  801166:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801169:	5b                   	pop    %ebx
  80116a:	5e                   	pop    %esi
  80116b:	5f                   	pop    %edi
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    

0080116e <sfork>:

// Challenge!
int
sfork(void)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801174:	68 3a 28 80 00       	push   $0x80283a
  801179:	68 8d 00 00 00       	push   $0x8d
  80117e:	68 e2 27 80 00       	push   $0x8027e2
  801183:	e8 90 f0 ff ff       	call   800218 <_panic>

00801188 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80118b:	8b 45 08             	mov    0x8(%ebp),%eax
  80118e:	05 00 00 00 30       	add    $0x30000000,%eax
  801193:	c1 e8 0c             	shr    $0xc,%eax
}
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    

00801198 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80119b:	8b 45 08             	mov    0x8(%ebp),%eax
  80119e:	05 00 00 00 30       	add    $0x30000000,%eax
  8011a3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011a8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    

008011af <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011b5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011ba:	89 c2                	mov    %eax,%edx
  8011bc:	c1 ea 16             	shr    $0x16,%edx
  8011bf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011c6:	f6 c2 01             	test   $0x1,%dl
  8011c9:	74 11                	je     8011dc <fd_alloc+0x2d>
  8011cb:	89 c2                	mov    %eax,%edx
  8011cd:	c1 ea 0c             	shr    $0xc,%edx
  8011d0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011d7:	f6 c2 01             	test   $0x1,%dl
  8011da:	75 09                	jne    8011e5 <fd_alloc+0x36>
			*fd_store = fd;
  8011dc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011de:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e3:	eb 17                	jmp    8011fc <fd_alloc+0x4d>
  8011e5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011ea:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011ef:	75 c9                	jne    8011ba <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011f1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011f7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011fc:	5d                   	pop    %ebp
  8011fd:	c3                   	ret    

008011fe <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801204:	83 f8 1f             	cmp    $0x1f,%eax
  801207:	77 36                	ja     80123f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801209:	c1 e0 0c             	shl    $0xc,%eax
  80120c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801211:	89 c2                	mov    %eax,%edx
  801213:	c1 ea 16             	shr    $0x16,%edx
  801216:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80121d:	f6 c2 01             	test   $0x1,%dl
  801220:	74 24                	je     801246 <fd_lookup+0x48>
  801222:	89 c2                	mov    %eax,%edx
  801224:	c1 ea 0c             	shr    $0xc,%edx
  801227:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80122e:	f6 c2 01             	test   $0x1,%dl
  801231:	74 1a                	je     80124d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801233:	8b 55 0c             	mov    0xc(%ebp),%edx
  801236:	89 02                	mov    %eax,(%edx)
	return 0;
  801238:	b8 00 00 00 00       	mov    $0x0,%eax
  80123d:	eb 13                	jmp    801252 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80123f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801244:	eb 0c                	jmp    801252 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801246:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124b:	eb 05                	jmp    801252 <fd_lookup+0x54>
  80124d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801252:	5d                   	pop    %ebp
  801253:	c3                   	ret    

00801254 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	83 ec 08             	sub    $0x8,%esp
  80125a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80125d:	ba d0 28 80 00       	mov    $0x8028d0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801262:	eb 13                	jmp    801277 <dev_lookup+0x23>
  801264:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801267:	39 08                	cmp    %ecx,(%eax)
  801269:	75 0c                	jne    801277 <dev_lookup+0x23>
			*dev = devtab[i];
  80126b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80126e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801270:	b8 00 00 00 00       	mov    $0x0,%eax
  801275:	eb 2e                	jmp    8012a5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801277:	8b 02                	mov    (%edx),%eax
  801279:	85 c0                	test   %eax,%eax
  80127b:	75 e7                	jne    801264 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80127d:	a1 20 44 80 00       	mov    0x804420,%eax
  801282:	8b 40 48             	mov    0x48(%eax),%eax
  801285:	83 ec 04             	sub    $0x4,%esp
  801288:	51                   	push   %ecx
  801289:	50                   	push   %eax
  80128a:	68 50 28 80 00       	push   $0x802850
  80128f:	e8 5d f0 ff ff       	call   8002f1 <cprintf>
	*dev = 0;
  801294:	8b 45 0c             	mov    0xc(%ebp),%eax
  801297:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80129d:	83 c4 10             	add    $0x10,%esp
  8012a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012a5:	c9                   	leave  
  8012a6:	c3                   	ret    

008012a7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	56                   	push   %esi
  8012ab:	53                   	push   %ebx
  8012ac:	83 ec 10             	sub    $0x10,%esp
  8012af:	8b 75 08             	mov    0x8(%ebp),%esi
  8012b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b8:	50                   	push   %eax
  8012b9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012bf:	c1 e8 0c             	shr    $0xc,%eax
  8012c2:	50                   	push   %eax
  8012c3:	e8 36 ff ff ff       	call   8011fe <fd_lookup>
  8012c8:	83 c4 08             	add    $0x8,%esp
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	78 05                	js     8012d4 <fd_close+0x2d>
	    || fd != fd2)
  8012cf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012d2:	74 0c                	je     8012e0 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012d4:	84 db                	test   %bl,%bl
  8012d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8012db:	0f 44 c2             	cmove  %edx,%eax
  8012de:	eb 41                	jmp    801321 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012e0:	83 ec 08             	sub    $0x8,%esp
  8012e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e6:	50                   	push   %eax
  8012e7:	ff 36                	pushl  (%esi)
  8012e9:	e8 66 ff ff ff       	call   801254 <dev_lookup>
  8012ee:	89 c3                	mov    %eax,%ebx
  8012f0:	83 c4 10             	add    $0x10,%esp
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	78 1a                	js     801311 <fd_close+0x6a>
		if (dev->dev_close)
  8012f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fa:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012fd:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801302:	85 c0                	test   %eax,%eax
  801304:	74 0b                	je     801311 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801306:	83 ec 0c             	sub    $0xc,%esp
  801309:	56                   	push   %esi
  80130a:	ff d0                	call   *%eax
  80130c:	89 c3                	mov    %eax,%ebx
  80130e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801311:	83 ec 08             	sub    $0x8,%esp
  801314:	56                   	push   %esi
  801315:	6a 00                	push   $0x0
  801317:	e8 61 fa ff ff       	call   800d7d <sys_page_unmap>
	return r;
  80131c:	83 c4 10             	add    $0x10,%esp
  80131f:	89 d8                	mov    %ebx,%eax
}
  801321:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801324:	5b                   	pop    %ebx
  801325:	5e                   	pop    %esi
  801326:	5d                   	pop    %ebp
  801327:	c3                   	ret    

00801328 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801328:	55                   	push   %ebp
  801329:	89 e5                	mov    %esp,%ebp
  80132b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80132e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801331:	50                   	push   %eax
  801332:	ff 75 08             	pushl  0x8(%ebp)
  801335:	e8 c4 fe ff ff       	call   8011fe <fd_lookup>
  80133a:	83 c4 08             	add    $0x8,%esp
  80133d:	85 c0                	test   %eax,%eax
  80133f:	78 10                	js     801351 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801341:	83 ec 08             	sub    $0x8,%esp
  801344:	6a 01                	push   $0x1
  801346:	ff 75 f4             	pushl  -0xc(%ebp)
  801349:	e8 59 ff ff ff       	call   8012a7 <fd_close>
  80134e:	83 c4 10             	add    $0x10,%esp
}
  801351:	c9                   	leave  
  801352:	c3                   	ret    

00801353 <close_all>:

void
close_all(void)
{
  801353:	55                   	push   %ebp
  801354:	89 e5                	mov    %esp,%ebp
  801356:	53                   	push   %ebx
  801357:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80135a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80135f:	83 ec 0c             	sub    $0xc,%esp
  801362:	53                   	push   %ebx
  801363:	e8 c0 ff ff ff       	call   801328 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801368:	83 c3 01             	add    $0x1,%ebx
  80136b:	83 c4 10             	add    $0x10,%esp
  80136e:	83 fb 20             	cmp    $0x20,%ebx
  801371:	75 ec                	jne    80135f <close_all+0xc>
		close(i);
}
  801373:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801376:	c9                   	leave  
  801377:	c3                   	ret    

00801378 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	57                   	push   %edi
  80137c:	56                   	push   %esi
  80137d:	53                   	push   %ebx
  80137e:	83 ec 2c             	sub    $0x2c,%esp
  801381:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801384:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801387:	50                   	push   %eax
  801388:	ff 75 08             	pushl  0x8(%ebp)
  80138b:	e8 6e fe ff ff       	call   8011fe <fd_lookup>
  801390:	83 c4 08             	add    $0x8,%esp
  801393:	85 c0                	test   %eax,%eax
  801395:	0f 88 c1 00 00 00    	js     80145c <dup+0xe4>
		return r;
	close(newfdnum);
  80139b:	83 ec 0c             	sub    $0xc,%esp
  80139e:	56                   	push   %esi
  80139f:	e8 84 ff ff ff       	call   801328 <close>

	newfd = INDEX2FD(newfdnum);
  8013a4:	89 f3                	mov    %esi,%ebx
  8013a6:	c1 e3 0c             	shl    $0xc,%ebx
  8013a9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013af:	83 c4 04             	add    $0x4,%esp
  8013b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013b5:	e8 de fd ff ff       	call   801198 <fd2data>
  8013ba:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013bc:	89 1c 24             	mov    %ebx,(%esp)
  8013bf:	e8 d4 fd ff ff       	call   801198 <fd2data>
  8013c4:	83 c4 10             	add    $0x10,%esp
  8013c7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013ca:	89 f8                	mov    %edi,%eax
  8013cc:	c1 e8 16             	shr    $0x16,%eax
  8013cf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013d6:	a8 01                	test   $0x1,%al
  8013d8:	74 37                	je     801411 <dup+0x99>
  8013da:	89 f8                	mov    %edi,%eax
  8013dc:	c1 e8 0c             	shr    $0xc,%eax
  8013df:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013e6:	f6 c2 01             	test   $0x1,%dl
  8013e9:	74 26                	je     801411 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013eb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f2:	83 ec 0c             	sub    $0xc,%esp
  8013f5:	25 07 0e 00 00       	and    $0xe07,%eax
  8013fa:	50                   	push   %eax
  8013fb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013fe:	6a 00                	push   $0x0
  801400:	57                   	push   %edi
  801401:	6a 00                	push   $0x0
  801403:	e8 33 f9 ff ff       	call   800d3b <sys_page_map>
  801408:	89 c7                	mov    %eax,%edi
  80140a:	83 c4 20             	add    $0x20,%esp
  80140d:	85 c0                	test   %eax,%eax
  80140f:	78 2e                	js     80143f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801411:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801414:	89 d0                	mov    %edx,%eax
  801416:	c1 e8 0c             	shr    $0xc,%eax
  801419:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801420:	83 ec 0c             	sub    $0xc,%esp
  801423:	25 07 0e 00 00       	and    $0xe07,%eax
  801428:	50                   	push   %eax
  801429:	53                   	push   %ebx
  80142a:	6a 00                	push   $0x0
  80142c:	52                   	push   %edx
  80142d:	6a 00                	push   $0x0
  80142f:	e8 07 f9 ff ff       	call   800d3b <sys_page_map>
  801434:	89 c7                	mov    %eax,%edi
  801436:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801439:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80143b:	85 ff                	test   %edi,%edi
  80143d:	79 1d                	jns    80145c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80143f:	83 ec 08             	sub    $0x8,%esp
  801442:	53                   	push   %ebx
  801443:	6a 00                	push   $0x0
  801445:	e8 33 f9 ff ff       	call   800d7d <sys_page_unmap>
	sys_page_unmap(0, nva);
  80144a:	83 c4 08             	add    $0x8,%esp
  80144d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801450:	6a 00                	push   $0x0
  801452:	e8 26 f9 ff ff       	call   800d7d <sys_page_unmap>
	return r;
  801457:	83 c4 10             	add    $0x10,%esp
  80145a:	89 f8                	mov    %edi,%eax
}
  80145c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80145f:	5b                   	pop    %ebx
  801460:	5e                   	pop    %esi
  801461:	5f                   	pop    %edi
  801462:	5d                   	pop    %ebp
  801463:	c3                   	ret    

00801464 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	53                   	push   %ebx
  801468:	83 ec 14             	sub    $0x14,%esp
  80146b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80146e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801471:	50                   	push   %eax
  801472:	53                   	push   %ebx
  801473:	e8 86 fd ff ff       	call   8011fe <fd_lookup>
  801478:	83 c4 08             	add    $0x8,%esp
  80147b:	89 c2                	mov    %eax,%edx
  80147d:	85 c0                	test   %eax,%eax
  80147f:	78 6d                	js     8014ee <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801481:	83 ec 08             	sub    $0x8,%esp
  801484:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801487:	50                   	push   %eax
  801488:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148b:	ff 30                	pushl  (%eax)
  80148d:	e8 c2 fd ff ff       	call   801254 <dev_lookup>
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	85 c0                	test   %eax,%eax
  801497:	78 4c                	js     8014e5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801499:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80149c:	8b 42 08             	mov    0x8(%edx),%eax
  80149f:	83 e0 03             	and    $0x3,%eax
  8014a2:	83 f8 01             	cmp    $0x1,%eax
  8014a5:	75 21                	jne    8014c8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a7:	a1 20 44 80 00       	mov    0x804420,%eax
  8014ac:	8b 40 48             	mov    0x48(%eax),%eax
  8014af:	83 ec 04             	sub    $0x4,%esp
  8014b2:	53                   	push   %ebx
  8014b3:	50                   	push   %eax
  8014b4:	68 94 28 80 00       	push   $0x802894
  8014b9:	e8 33 ee ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014c6:	eb 26                	jmp    8014ee <read+0x8a>
	}
	if (!dev->dev_read)
  8014c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cb:	8b 40 08             	mov    0x8(%eax),%eax
  8014ce:	85 c0                	test   %eax,%eax
  8014d0:	74 17                	je     8014e9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014d2:	83 ec 04             	sub    $0x4,%esp
  8014d5:	ff 75 10             	pushl  0x10(%ebp)
  8014d8:	ff 75 0c             	pushl  0xc(%ebp)
  8014db:	52                   	push   %edx
  8014dc:	ff d0                	call   *%eax
  8014de:	89 c2                	mov    %eax,%edx
  8014e0:	83 c4 10             	add    $0x10,%esp
  8014e3:	eb 09                	jmp    8014ee <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e5:	89 c2                	mov    %eax,%edx
  8014e7:	eb 05                	jmp    8014ee <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014e9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014ee:	89 d0                	mov    %edx,%eax
  8014f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f3:	c9                   	leave  
  8014f4:	c3                   	ret    

008014f5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014f5:	55                   	push   %ebp
  8014f6:	89 e5                	mov    %esp,%ebp
  8014f8:	57                   	push   %edi
  8014f9:	56                   	push   %esi
  8014fa:	53                   	push   %ebx
  8014fb:	83 ec 0c             	sub    $0xc,%esp
  8014fe:	8b 7d 08             	mov    0x8(%ebp),%edi
  801501:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801504:	bb 00 00 00 00       	mov    $0x0,%ebx
  801509:	eb 21                	jmp    80152c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80150b:	83 ec 04             	sub    $0x4,%esp
  80150e:	89 f0                	mov    %esi,%eax
  801510:	29 d8                	sub    %ebx,%eax
  801512:	50                   	push   %eax
  801513:	89 d8                	mov    %ebx,%eax
  801515:	03 45 0c             	add    0xc(%ebp),%eax
  801518:	50                   	push   %eax
  801519:	57                   	push   %edi
  80151a:	e8 45 ff ff ff       	call   801464 <read>
		if (m < 0)
  80151f:	83 c4 10             	add    $0x10,%esp
  801522:	85 c0                	test   %eax,%eax
  801524:	78 10                	js     801536 <readn+0x41>
			return m;
		if (m == 0)
  801526:	85 c0                	test   %eax,%eax
  801528:	74 0a                	je     801534 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80152a:	01 c3                	add    %eax,%ebx
  80152c:	39 f3                	cmp    %esi,%ebx
  80152e:	72 db                	jb     80150b <readn+0x16>
  801530:	89 d8                	mov    %ebx,%eax
  801532:	eb 02                	jmp    801536 <readn+0x41>
  801534:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801536:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801539:	5b                   	pop    %ebx
  80153a:	5e                   	pop    %esi
  80153b:	5f                   	pop    %edi
  80153c:	5d                   	pop    %ebp
  80153d:	c3                   	ret    

0080153e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	53                   	push   %ebx
  801542:	83 ec 14             	sub    $0x14,%esp
  801545:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801548:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154b:	50                   	push   %eax
  80154c:	53                   	push   %ebx
  80154d:	e8 ac fc ff ff       	call   8011fe <fd_lookup>
  801552:	83 c4 08             	add    $0x8,%esp
  801555:	89 c2                	mov    %eax,%edx
  801557:	85 c0                	test   %eax,%eax
  801559:	78 68                	js     8015c3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155b:	83 ec 08             	sub    $0x8,%esp
  80155e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801561:	50                   	push   %eax
  801562:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801565:	ff 30                	pushl  (%eax)
  801567:	e8 e8 fc ff ff       	call   801254 <dev_lookup>
  80156c:	83 c4 10             	add    $0x10,%esp
  80156f:	85 c0                	test   %eax,%eax
  801571:	78 47                	js     8015ba <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801573:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801576:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80157a:	75 21                	jne    80159d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80157c:	a1 20 44 80 00       	mov    0x804420,%eax
  801581:	8b 40 48             	mov    0x48(%eax),%eax
  801584:	83 ec 04             	sub    $0x4,%esp
  801587:	53                   	push   %ebx
  801588:	50                   	push   %eax
  801589:	68 b0 28 80 00       	push   $0x8028b0
  80158e:	e8 5e ed ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  801593:	83 c4 10             	add    $0x10,%esp
  801596:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80159b:	eb 26                	jmp    8015c3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80159d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a0:	8b 52 0c             	mov    0xc(%edx),%edx
  8015a3:	85 d2                	test   %edx,%edx
  8015a5:	74 17                	je     8015be <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015a7:	83 ec 04             	sub    $0x4,%esp
  8015aa:	ff 75 10             	pushl  0x10(%ebp)
  8015ad:	ff 75 0c             	pushl  0xc(%ebp)
  8015b0:	50                   	push   %eax
  8015b1:	ff d2                	call   *%edx
  8015b3:	89 c2                	mov    %eax,%edx
  8015b5:	83 c4 10             	add    $0x10,%esp
  8015b8:	eb 09                	jmp    8015c3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ba:	89 c2                	mov    %eax,%edx
  8015bc:	eb 05                	jmp    8015c3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015c3:	89 d0                	mov    %edx,%eax
  8015c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c8:	c9                   	leave  
  8015c9:	c3                   	ret    

008015ca <seek>:

int
seek(int fdnum, off_t offset)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015d0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015d3:	50                   	push   %eax
  8015d4:	ff 75 08             	pushl  0x8(%ebp)
  8015d7:	e8 22 fc ff ff       	call   8011fe <fd_lookup>
  8015dc:	83 c4 08             	add    $0x8,%esp
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	78 0e                	js     8015f1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015e9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f1:	c9                   	leave  
  8015f2:	c3                   	ret    

008015f3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	53                   	push   %ebx
  8015f7:	83 ec 14             	sub    $0x14,%esp
  8015fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801600:	50                   	push   %eax
  801601:	53                   	push   %ebx
  801602:	e8 f7 fb ff ff       	call   8011fe <fd_lookup>
  801607:	83 c4 08             	add    $0x8,%esp
  80160a:	89 c2                	mov    %eax,%edx
  80160c:	85 c0                	test   %eax,%eax
  80160e:	78 65                	js     801675 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801610:	83 ec 08             	sub    $0x8,%esp
  801613:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801616:	50                   	push   %eax
  801617:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161a:	ff 30                	pushl  (%eax)
  80161c:	e8 33 fc ff ff       	call   801254 <dev_lookup>
  801621:	83 c4 10             	add    $0x10,%esp
  801624:	85 c0                	test   %eax,%eax
  801626:	78 44                	js     80166c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801628:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80162f:	75 21                	jne    801652 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801631:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801636:	8b 40 48             	mov    0x48(%eax),%eax
  801639:	83 ec 04             	sub    $0x4,%esp
  80163c:	53                   	push   %ebx
  80163d:	50                   	push   %eax
  80163e:	68 70 28 80 00       	push   $0x802870
  801643:	e8 a9 ec ff ff       	call   8002f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801650:	eb 23                	jmp    801675 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801652:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801655:	8b 52 18             	mov    0x18(%edx),%edx
  801658:	85 d2                	test   %edx,%edx
  80165a:	74 14                	je     801670 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80165c:	83 ec 08             	sub    $0x8,%esp
  80165f:	ff 75 0c             	pushl  0xc(%ebp)
  801662:	50                   	push   %eax
  801663:	ff d2                	call   *%edx
  801665:	89 c2                	mov    %eax,%edx
  801667:	83 c4 10             	add    $0x10,%esp
  80166a:	eb 09                	jmp    801675 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166c:	89 c2                	mov    %eax,%edx
  80166e:	eb 05                	jmp    801675 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801670:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801675:	89 d0                	mov    %edx,%eax
  801677:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167a:	c9                   	leave  
  80167b:	c3                   	ret    

0080167c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	53                   	push   %ebx
  801680:	83 ec 14             	sub    $0x14,%esp
  801683:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801686:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801689:	50                   	push   %eax
  80168a:	ff 75 08             	pushl  0x8(%ebp)
  80168d:	e8 6c fb ff ff       	call   8011fe <fd_lookup>
  801692:	83 c4 08             	add    $0x8,%esp
  801695:	89 c2                	mov    %eax,%edx
  801697:	85 c0                	test   %eax,%eax
  801699:	78 58                	js     8016f3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169b:	83 ec 08             	sub    $0x8,%esp
  80169e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a1:	50                   	push   %eax
  8016a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a5:	ff 30                	pushl  (%eax)
  8016a7:	e8 a8 fb ff ff       	call   801254 <dev_lookup>
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	78 37                	js     8016ea <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016ba:	74 32                	je     8016ee <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016bc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016bf:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016c6:	00 00 00 
	stat->st_isdir = 0;
  8016c9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016d0:	00 00 00 
	stat->st_dev = dev;
  8016d3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016d9:	83 ec 08             	sub    $0x8,%esp
  8016dc:	53                   	push   %ebx
  8016dd:	ff 75 f0             	pushl  -0x10(%ebp)
  8016e0:	ff 50 14             	call   *0x14(%eax)
  8016e3:	89 c2                	mov    %eax,%edx
  8016e5:	83 c4 10             	add    $0x10,%esp
  8016e8:	eb 09                	jmp    8016f3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ea:	89 c2                	mov    %eax,%edx
  8016ec:	eb 05                	jmp    8016f3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016ee:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016f3:	89 d0                	mov    %edx,%eax
  8016f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f8:	c9                   	leave  
  8016f9:	c3                   	ret    

008016fa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	56                   	push   %esi
  8016fe:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016ff:	83 ec 08             	sub    $0x8,%esp
  801702:	6a 00                	push   $0x0
  801704:	ff 75 08             	pushl  0x8(%ebp)
  801707:	e8 e3 01 00 00       	call   8018ef <open>
  80170c:	89 c3                	mov    %eax,%ebx
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	85 c0                	test   %eax,%eax
  801713:	78 1b                	js     801730 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801715:	83 ec 08             	sub    $0x8,%esp
  801718:	ff 75 0c             	pushl  0xc(%ebp)
  80171b:	50                   	push   %eax
  80171c:	e8 5b ff ff ff       	call   80167c <fstat>
  801721:	89 c6                	mov    %eax,%esi
	close(fd);
  801723:	89 1c 24             	mov    %ebx,(%esp)
  801726:	e8 fd fb ff ff       	call   801328 <close>
	return r;
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	89 f0                	mov    %esi,%eax
}
  801730:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801733:	5b                   	pop    %ebx
  801734:	5e                   	pop    %esi
  801735:	5d                   	pop    %ebp
  801736:	c3                   	ret    

00801737 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	56                   	push   %esi
  80173b:	53                   	push   %ebx
  80173c:	89 c6                	mov    %eax,%esi
  80173e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801740:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801747:	75 12                	jne    80175b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801749:	83 ec 0c             	sub    $0xc,%esp
  80174c:	6a 01                	push   $0x1
  80174e:	e8 b2 08 00 00       	call   802005 <ipc_find_env>
  801753:	a3 00 40 80 00       	mov    %eax,0x804000
  801758:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80175b:	6a 07                	push   $0x7
  80175d:	68 00 50 80 00       	push   $0x805000
  801762:	56                   	push   %esi
  801763:	ff 35 00 40 80 00    	pushl  0x804000
  801769:	e8 43 08 00 00       	call   801fb1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80176e:	83 c4 0c             	add    $0xc,%esp
  801771:	6a 00                	push   $0x0
  801773:	53                   	push   %ebx
  801774:	6a 00                	push   $0x0
  801776:	e8 cd 07 00 00       	call   801f48 <ipc_recv>
}
  80177b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80177e:	5b                   	pop    %ebx
  80177f:	5e                   	pop    %esi
  801780:	5d                   	pop    %ebp
  801781:	c3                   	ret    

00801782 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801782:	55                   	push   %ebp
  801783:	89 e5                	mov    %esp,%ebp
  801785:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801788:	8b 45 08             	mov    0x8(%ebp),%eax
  80178b:	8b 40 0c             	mov    0xc(%eax),%eax
  80178e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801793:	8b 45 0c             	mov    0xc(%ebp),%eax
  801796:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80179b:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a0:	b8 02 00 00 00       	mov    $0x2,%eax
  8017a5:	e8 8d ff ff ff       	call   801737 <fsipc>
}
  8017aa:	c9                   	leave  
  8017ab:	c3                   	ret    

008017ac <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c2:	b8 06 00 00 00       	mov    $0x6,%eax
  8017c7:	e8 6b ff ff ff       	call   801737 <fsipc>
}
  8017cc:	c9                   	leave  
  8017cd:	c3                   	ret    

008017ce <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	53                   	push   %ebx
  8017d2:	83 ec 04             	sub    $0x4,%esp
  8017d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017db:	8b 40 0c             	mov    0xc(%eax),%eax
  8017de:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e8:	b8 05 00 00 00       	mov    $0x5,%eax
  8017ed:	e8 45 ff ff ff       	call   801737 <fsipc>
  8017f2:	85 c0                	test   %eax,%eax
  8017f4:	78 2c                	js     801822 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017f6:	83 ec 08             	sub    $0x8,%esp
  8017f9:	68 00 50 80 00       	push   $0x805000
  8017fe:	53                   	push   %ebx
  8017ff:	e8 f1 f0 ff ff       	call   8008f5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801804:	a1 80 50 80 00       	mov    0x805080,%eax
  801809:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80180f:	a1 84 50 80 00       	mov    0x805084,%eax
  801814:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80181a:	83 c4 10             	add    $0x10,%esp
  80181d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801822:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801825:	c9                   	leave  
  801826:	c3                   	ret    

00801827 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	83 ec 0c             	sub    $0xc,%esp
  80182d:	8b 45 10             	mov    0x10(%ebp),%eax
  801830:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801835:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80183a:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80183d:	8b 55 08             	mov    0x8(%ebp),%edx
  801840:	8b 52 0c             	mov    0xc(%edx),%edx
  801843:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801849:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80184e:	50                   	push   %eax
  80184f:	ff 75 0c             	pushl  0xc(%ebp)
  801852:	68 08 50 80 00       	push   $0x805008
  801857:	e8 2b f2 ff ff       	call   800a87 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80185c:	ba 00 00 00 00       	mov    $0x0,%edx
  801861:	b8 04 00 00 00       	mov    $0x4,%eax
  801866:	e8 cc fe ff ff       	call   801737 <fsipc>
	//panic("devfile_write not implemented");
}
  80186b:	c9                   	leave  
  80186c:	c3                   	ret    

0080186d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80186d:	55                   	push   %ebp
  80186e:	89 e5                	mov    %esp,%ebp
  801870:	56                   	push   %esi
  801871:	53                   	push   %ebx
  801872:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801875:	8b 45 08             	mov    0x8(%ebp),%eax
  801878:	8b 40 0c             	mov    0xc(%eax),%eax
  80187b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801880:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801886:	ba 00 00 00 00       	mov    $0x0,%edx
  80188b:	b8 03 00 00 00       	mov    $0x3,%eax
  801890:	e8 a2 fe ff ff       	call   801737 <fsipc>
  801895:	89 c3                	mov    %eax,%ebx
  801897:	85 c0                	test   %eax,%eax
  801899:	78 4b                	js     8018e6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80189b:	39 c6                	cmp    %eax,%esi
  80189d:	73 16                	jae    8018b5 <devfile_read+0x48>
  80189f:	68 e0 28 80 00       	push   $0x8028e0
  8018a4:	68 e7 28 80 00       	push   $0x8028e7
  8018a9:	6a 7c                	push   $0x7c
  8018ab:	68 fc 28 80 00       	push   $0x8028fc
  8018b0:	e8 63 e9 ff ff       	call   800218 <_panic>
	assert(r <= PGSIZE);
  8018b5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018ba:	7e 16                	jle    8018d2 <devfile_read+0x65>
  8018bc:	68 07 29 80 00       	push   $0x802907
  8018c1:	68 e7 28 80 00       	push   $0x8028e7
  8018c6:	6a 7d                	push   $0x7d
  8018c8:	68 fc 28 80 00       	push   $0x8028fc
  8018cd:	e8 46 e9 ff ff       	call   800218 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018d2:	83 ec 04             	sub    $0x4,%esp
  8018d5:	50                   	push   %eax
  8018d6:	68 00 50 80 00       	push   $0x805000
  8018db:	ff 75 0c             	pushl  0xc(%ebp)
  8018de:	e8 a4 f1 ff ff       	call   800a87 <memmove>
	return r;
  8018e3:	83 c4 10             	add    $0x10,%esp
}
  8018e6:	89 d8                	mov    %ebx,%eax
  8018e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018eb:	5b                   	pop    %ebx
  8018ec:	5e                   	pop    %esi
  8018ed:	5d                   	pop    %ebp
  8018ee:	c3                   	ret    

008018ef <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	53                   	push   %ebx
  8018f3:	83 ec 20             	sub    $0x20,%esp
  8018f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018f9:	53                   	push   %ebx
  8018fa:	e8 bd ef ff ff       	call   8008bc <strlen>
  8018ff:	83 c4 10             	add    $0x10,%esp
  801902:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801907:	7f 67                	jg     801970 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801909:	83 ec 0c             	sub    $0xc,%esp
  80190c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190f:	50                   	push   %eax
  801910:	e8 9a f8 ff ff       	call   8011af <fd_alloc>
  801915:	83 c4 10             	add    $0x10,%esp
		return r;
  801918:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80191a:	85 c0                	test   %eax,%eax
  80191c:	78 57                	js     801975 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80191e:	83 ec 08             	sub    $0x8,%esp
  801921:	53                   	push   %ebx
  801922:	68 00 50 80 00       	push   $0x805000
  801927:	e8 c9 ef ff ff       	call   8008f5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80192c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801934:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801937:	b8 01 00 00 00       	mov    $0x1,%eax
  80193c:	e8 f6 fd ff ff       	call   801737 <fsipc>
  801941:	89 c3                	mov    %eax,%ebx
  801943:	83 c4 10             	add    $0x10,%esp
  801946:	85 c0                	test   %eax,%eax
  801948:	79 14                	jns    80195e <open+0x6f>
		fd_close(fd, 0);
  80194a:	83 ec 08             	sub    $0x8,%esp
  80194d:	6a 00                	push   $0x0
  80194f:	ff 75 f4             	pushl  -0xc(%ebp)
  801952:	e8 50 f9 ff ff       	call   8012a7 <fd_close>
		return r;
  801957:	83 c4 10             	add    $0x10,%esp
  80195a:	89 da                	mov    %ebx,%edx
  80195c:	eb 17                	jmp    801975 <open+0x86>
	}

	return fd2num(fd);
  80195e:	83 ec 0c             	sub    $0xc,%esp
  801961:	ff 75 f4             	pushl  -0xc(%ebp)
  801964:	e8 1f f8 ff ff       	call   801188 <fd2num>
  801969:	89 c2                	mov    %eax,%edx
  80196b:	83 c4 10             	add    $0x10,%esp
  80196e:	eb 05                	jmp    801975 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801970:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801975:	89 d0                	mov    %edx,%eax
  801977:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80197a:	c9                   	leave  
  80197b:	c3                   	ret    

0080197c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801982:	ba 00 00 00 00       	mov    $0x0,%edx
  801987:	b8 08 00 00 00       	mov    $0x8,%eax
  80198c:	e8 a6 fd ff ff       	call   801737 <fsipc>
}
  801991:	c9                   	leave  
  801992:	c3                   	ret    

00801993 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801993:	55                   	push   %ebp
  801994:	89 e5                	mov    %esp,%ebp
  801996:	56                   	push   %esi
  801997:	53                   	push   %ebx
  801998:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80199b:	83 ec 0c             	sub    $0xc,%esp
  80199e:	ff 75 08             	pushl  0x8(%ebp)
  8019a1:	e8 f2 f7 ff ff       	call   801198 <fd2data>
  8019a6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019a8:	83 c4 08             	add    $0x8,%esp
  8019ab:	68 13 29 80 00       	push   $0x802913
  8019b0:	53                   	push   %ebx
  8019b1:	e8 3f ef ff ff       	call   8008f5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019b6:	8b 46 04             	mov    0x4(%esi),%eax
  8019b9:	2b 06                	sub    (%esi),%eax
  8019bb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019c1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019c8:	00 00 00 
	stat->st_dev = &devpipe;
  8019cb:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019d2:	30 80 00 
	return 0;
}
  8019d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019dd:	5b                   	pop    %ebx
  8019de:	5e                   	pop    %esi
  8019df:	5d                   	pop    %ebp
  8019e0:	c3                   	ret    

008019e1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019e1:	55                   	push   %ebp
  8019e2:	89 e5                	mov    %esp,%ebp
  8019e4:	53                   	push   %ebx
  8019e5:	83 ec 0c             	sub    $0xc,%esp
  8019e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019eb:	53                   	push   %ebx
  8019ec:	6a 00                	push   $0x0
  8019ee:	e8 8a f3 ff ff       	call   800d7d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019f3:	89 1c 24             	mov    %ebx,(%esp)
  8019f6:	e8 9d f7 ff ff       	call   801198 <fd2data>
  8019fb:	83 c4 08             	add    $0x8,%esp
  8019fe:	50                   	push   %eax
  8019ff:	6a 00                	push   $0x0
  801a01:	e8 77 f3 ff ff       	call   800d7d <sys_page_unmap>
}
  801a06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a09:	c9                   	leave  
  801a0a:	c3                   	ret    

00801a0b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a0b:	55                   	push   %ebp
  801a0c:	89 e5                	mov    %esp,%ebp
  801a0e:	57                   	push   %edi
  801a0f:	56                   	push   %esi
  801a10:	53                   	push   %ebx
  801a11:	83 ec 1c             	sub    $0x1c,%esp
  801a14:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a17:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a19:	a1 20 44 80 00       	mov    0x804420,%eax
  801a1e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a21:	83 ec 0c             	sub    $0xc,%esp
  801a24:	ff 75 e0             	pushl  -0x20(%ebp)
  801a27:	e8 12 06 00 00       	call   80203e <pageref>
  801a2c:	89 c3                	mov    %eax,%ebx
  801a2e:	89 3c 24             	mov    %edi,(%esp)
  801a31:	e8 08 06 00 00       	call   80203e <pageref>
  801a36:	83 c4 10             	add    $0x10,%esp
  801a39:	39 c3                	cmp    %eax,%ebx
  801a3b:	0f 94 c1             	sete   %cl
  801a3e:	0f b6 c9             	movzbl %cl,%ecx
  801a41:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a44:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801a4a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a4d:	39 ce                	cmp    %ecx,%esi
  801a4f:	74 1b                	je     801a6c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a51:	39 c3                	cmp    %eax,%ebx
  801a53:	75 c4                	jne    801a19 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a55:	8b 42 58             	mov    0x58(%edx),%eax
  801a58:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a5b:	50                   	push   %eax
  801a5c:	56                   	push   %esi
  801a5d:	68 1a 29 80 00       	push   $0x80291a
  801a62:	e8 8a e8 ff ff       	call   8002f1 <cprintf>
  801a67:	83 c4 10             	add    $0x10,%esp
  801a6a:	eb ad                	jmp    801a19 <_pipeisclosed+0xe>
	}
}
  801a6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a72:	5b                   	pop    %ebx
  801a73:	5e                   	pop    %esi
  801a74:	5f                   	pop    %edi
  801a75:	5d                   	pop    %ebp
  801a76:	c3                   	ret    

00801a77 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a77:	55                   	push   %ebp
  801a78:	89 e5                	mov    %esp,%ebp
  801a7a:	57                   	push   %edi
  801a7b:	56                   	push   %esi
  801a7c:	53                   	push   %ebx
  801a7d:	83 ec 28             	sub    $0x28,%esp
  801a80:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a83:	56                   	push   %esi
  801a84:	e8 0f f7 ff ff       	call   801198 <fd2data>
  801a89:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	bf 00 00 00 00       	mov    $0x0,%edi
  801a93:	eb 4b                	jmp    801ae0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a95:	89 da                	mov    %ebx,%edx
  801a97:	89 f0                	mov    %esi,%eax
  801a99:	e8 6d ff ff ff       	call   801a0b <_pipeisclosed>
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	75 48                	jne    801aea <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801aa2:	e8 32 f2 ff ff       	call   800cd9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aa7:	8b 43 04             	mov    0x4(%ebx),%eax
  801aaa:	8b 0b                	mov    (%ebx),%ecx
  801aac:	8d 51 20             	lea    0x20(%ecx),%edx
  801aaf:	39 d0                	cmp    %edx,%eax
  801ab1:	73 e2                	jae    801a95 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ab3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ab6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801aba:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801abd:	89 c2                	mov    %eax,%edx
  801abf:	c1 fa 1f             	sar    $0x1f,%edx
  801ac2:	89 d1                	mov    %edx,%ecx
  801ac4:	c1 e9 1b             	shr    $0x1b,%ecx
  801ac7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801aca:	83 e2 1f             	and    $0x1f,%edx
  801acd:	29 ca                	sub    %ecx,%edx
  801acf:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ad3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ad7:	83 c0 01             	add    $0x1,%eax
  801ada:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801add:	83 c7 01             	add    $0x1,%edi
  801ae0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ae3:	75 c2                	jne    801aa7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ae5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ae8:	eb 05                	jmp    801aef <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aea:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801aef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af2:	5b                   	pop    %ebx
  801af3:	5e                   	pop    %esi
  801af4:	5f                   	pop    %edi
  801af5:	5d                   	pop    %ebp
  801af6:	c3                   	ret    

00801af7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	57                   	push   %edi
  801afb:	56                   	push   %esi
  801afc:	53                   	push   %ebx
  801afd:	83 ec 18             	sub    $0x18,%esp
  801b00:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b03:	57                   	push   %edi
  801b04:	e8 8f f6 ff ff       	call   801198 <fd2data>
  801b09:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b13:	eb 3d                	jmp    801b52 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b15:	85 db                	test   %ebx,%ebx
  801b17:	74 04                	je     801b1d <devpipe_read+0x26>
				return i;
  801b19:	89 d8                	mov    %ebx,%eax
  801b1b:	eb 44                	jmp    801b61 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b1d:	89 f2                	mov    %esi,%edx
  801b1f:	89 f8                	mov    %edi,%eax
  801b21:	e8 e5 fe ff ff       	call   801a0b <_pipeisclosed>
  801b26:	85 c0                	test   %eax,%eax
  801b28:	75 32                	jne    801b5c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b2a:	e8 aa f1 ff ff       	call   800cd9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b2f:	8b 06                	mov    (%esi),%eax
  801b31:	3b 46 04             	cmp    0x4(%esi),%eax
  801b34:	74 df                	je     801b15 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b36:	99                   	cltd   
  801b37:	c1 ea 1b             	shr    $0x1b,%edx
  801b3a:	01 d0                	add    %edx,%eax
  801b3c:	83 e0 1f             	and    $0x1f,%eax
  801b3f:	29 d0                	sub    %edx,%eax
  801b41:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b49:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b4c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b4f:	83 c3 01             	add    $0x1,%ebx
  801b52:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b55:	75 d8                	jne    801b2f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b57:	8b 45 10             	mov    0x10(%ebp),%eax
  801b5a:	eb 05                	jmp    801b61 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b5c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b64:	5b                   	pop    %ebx
  801b65:	5e                   	pop    %esi
  801b66:	5f                   	pop    %edi
  801b67:	5d                   	pop    %ebp
  801b68:	c3                   	ret    

00801b69 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	56                   	push   %esi
  801b6d:	53                   	push   %ebx
  801b6e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b74:	50                   	push   %eax
  801b75:	e8 35 f6 ff ff       	call   8011af <fd_alloc>
  801b7a:	83 c4 10             	add    $0x10,%esp
  801b7d:	89 c2                	mov    %eax,%edx
  801b7f:	85 c0                	test   %eax,%eax
  801b81:	0f 88 2c 01 00 00    	js     801cb3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b87:	83 ec 04             	sub    $0x4,%esp
  801b8a:	68 07 04 00 00       	push   $0x407
  801b8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b92:	6a 00                	push   $0x0
  801b94:	e8 5f f1 ff ff       	call   800cf8 <sys_page_alloc>
  801b99:	83 c4 10             	add    $0x10,%esp
  801b9c:	89 c2                	mov    %eax,%edx
  801b9e:	85 c0                	test   %eax,%eax
  801ba0:	0f 88 0d 01 00 00    	js     801cb3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ba6:	83 ec 0c             	sub    $0xc,%esp
  801ba9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bac:	50                   	push   %eax
  801bad:	e8 fd f5 ff ff       	call   8011af <fd_alloc>
  801bb2:	89 c3                	mov    %eax,%ebx
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	0f 88 e2 00 00 00    	js     801ca1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bbf:	83 ec 04             	sub    $0x4,%esp
  801bc2:	68 07 04 00 00       	push   $0x407
  801bc7:	ff 75 f0             	pushl  -0x10(%ebp)
  801bca:	6a 00                	push   $0x0
  801bcc:	e8 27 f1 ff ff       	call   800cf8 <sys_page_alloc>
  801bd1:	89 c3                	mov    %eax,%ebx
  801bd3:	83 c4 10             	add    $0x10,%esp
  801bd6:	85 c0                	test   %eax,%eax
  801bd8:	0f 88 c3 00 00 00    	js     801ca1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bde:	83 ec 0c             	sub    $0xc,%esp
  801be1:	ff 75 f4             	pushl  -0xc(%ebp)
  801be4:	e8 af f5 ff ff       	call   801198 <fd2data>
  801be9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801beb:	83 c4 0c             	add    $0xc,%esp
  801bee:	68 07 04 00 00       	push   $0x407
  801bf3:	50                   	push   %eax
  801bf4:	6a 00                	push   $0x0
  801bf6:	e8 fd f0 ff ff       	call   800cf8 <sys_page_alloc>
  801bfb:	89 c3                	mov    %eax,%ebx
  801bfd:	83 c4 10             	add    $0x10,%esp
  801c00:	85 c0                	test   %eax,%eax
  801c02:	0f 88 89 00 00 00    	js     801c91 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c08:	83 ec 0c             	sub    $0xc,%esp
  801c0b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c0e:	e8 85 f5 ff ff       	call   801198 <fd2data>
  801c13:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c1a:	50                   	push   %eax
  801c1b:	6a 00                	push   $0x0
  801c1d:	56                   	push   %esi
  801c1e:	6a 00                	push   $0x0
  801c20:	e8 16 f1 ff ff       	call   800d3b <sys_page_map>
  801c25:	89 c3                	mov    %eax,%ebx
  801c27:	83 c4 20             	add    $0x20,%esp
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	78 55                	js     801c83 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c2e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c37:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c43:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c49:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c4c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c51:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c58:	83 ec 0c             	sub    $0xc,%esp
  801c5b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5e:	e8 25 f5 ff ff       	call   801188 <fd2num>
  801c63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c66:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c68:	83 c4 04             	add    $0x4,%esp
  801c6b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c6e:	e8 15 f5 ff ff       	call   801188 <fd2num>
  801c73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c76:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c79:	83 c4 10             	add    $0x10,%esp
  801c7c:	ba 00 00 00 00       	mov    $0x0,%edx
  801c81:	eb 30                	jmp    801cb3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c83:	83 ec 08             	sub    $0x8,%esp
  801c86:	56                   	push   %esi
  801c87:	6a 00                	push   $0x0
  801c89:	e8 ef f0 ff ff       	call   800d7d <sys_page_unmap>
  801c8e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c91:	83 ec 08             	sub    $0x8,%esp
  801c94:	ff 75 f0             	pushl  -0x10(%ebp)
  801c97:	6a 00                	push   $0x0
  801c99:	e8 df f0 ff ff       	call   800d7d <sys_page_unmap>
  801c9e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ca1:	83 ec 08             	sub    $0x8,%esp
  801ca4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca7:	6a 00                	push   $0x0
  801ca9:	e8 cf f0 ff ff       	call   800d7d <sys_page_unmap>
  801cae:	83 c4 10             	add    $0x10,%esp
  801cb1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cb3:	89 d0                	mov    %edx,%eax
  801cb5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb8:	5b                   	pop    %ebx
  801cb9:	5e                   	pop    %esi
  801cba:	5d                   	pop    %ebp
  801cbb:	c3                   	ret    

00801cbc <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc5:	50                   	push   %eax
  801cc6:	ff 75 08             	pushl  0x8(%ebp)
  801cc9:	e8 30 f5 ff ff       	call   8011fe <fd_lookup>
  801cce:	83 c4 10             	add    $0x10,%esp
  801cd1:	85 c0                	test   %eax,%eax
  801cd3:	78 18                	js     801ced <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cd5:	83 ec 0c             	sub    $0xc,%esp
  801cd8:	ff 75 f4             	pushl  -0xc(%ebp)
  801cdb:	e8 b8 f4 ff ff       	call   801198 <fd2data>
	return _pipeisclosed(fd, p);
  801ce0:	89 c2                	mov    %eax,%edx
  801ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce5:	e8 21 fd ff ff       	call   801a0b <_pipeisclosed>
  801cea:	83 c4 10             	add    $0x10,%esp
}
  801ced:	c9                   	leave  
  801cee:	c3                   	ret    

00801cef <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801cef:	55                   	push   %ebp
  801cf0:	89 e5                	mov    %esp,%ebp
  801cf2:	56                   	push   %esi
  801cf3:	53                   	push   %ebx
  801cf4:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801cf7:	85 f6                	test   %esi,%esi
  801cf9:	75 16                	jne    801d11 <wait+0x22>
  801cfb:	68 32 29 80 00       	push   $0x802932
  801d00:	68 e7 28 80 00       	push   $0x8028e7
  801d05:	6a 09                	push   $0x9
  801d07:	68 3d 29 80 00       	push   $0x80293d
  801d0c:	e8 07 e5 ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  801d11:	89 f3                	mov    %esi,%ebx
  801d13:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d19:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801d1c:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801d22:	eb 05                	jmp    801d29 <wait+0x3a>
		sys_yield();
  801d24:	e8 b0 ef ff ff       	call   800cd9 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d29:	8b 43 48             	mov    0x48(%ebx),%eax
  801d2c:	39 c6                	cmp    %eax,%esi
  801d2e:	75 07                	jne    801d37 <wait+0x48>
  801d30:	8b 43 54             	mov    0x54(%ebx),%eax
  801d33:	85 c0                	test   %eax,%eax
  801d35:	75 ed                	jne    801d24 <wait+0x35>
		sys_yield();
}
  801d37:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d3a:	5b                   	pop    %ebx
  801d3b:	5e                   	pop    %esi
  801d3c:	5d                   	pop    %ebp
  801d3d:	c3                   	ret    

00801d3e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d41:	b8 00 00 00 00       	mov    $0x0,%eax
  801d46:	5d                   	pop    %ebp
  801d47:	c3                   	ret    

00801d48 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
  801d4b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d4e:	68 48 29 80 00       	push   $0x802948
  801d53:	ff 75 0c             	pushl  0xc(%ebp)
  801d56:	e8 9a eb ff ff       	call   8008f5 <strcpy>
	return 0;
}
  801d5b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d60:	c9                   	leave  
  801d61:	c3                   	ret    

00801d62 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	57                   	push   %edi
  801d66:	56                   	push   %esi
  801d67:	53                   	push   %ebx
  801d68:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d6e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d73:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d79:	eb 2d                	jmp    801da8 <devcons_write+0x46>
		m = n - tot;
  801d7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d7e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d80:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d83:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d88:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d8b:	83 ec 04             	sub    $0x4,%esp
  801d8e:	53                   	push   %ebx
  801d8f:	03 45 0c             	add    0xc(%ebp),%eax
  801d92:	50                   	push   %eax
  801d93:	57                   	push   %edi
  801d94:	e8 ee ec ff ff       	call   800a87 <memmove>
		sys_cputs(buf, m);
  801d99:	83 c4 08             	add    $0x8,%esp
  801d9c:	53                   	push   %ebx
  801d9d:	57                   	push   %edi
  801d9e:	e8 99 ee ff ff       	call   800c3c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801da3:	01 de                	add    %ebx,%esi
  801da5:	83 c4 10             	add    $0x10,%esp
  801da8:	89 f0                	mov    %esi,%eax
  801daa:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dad:	72 cc                	jb     801d7b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801daf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db2:	5b                   	pop    %ebx
  801db3:	5e                   	pop    %esi
  801db4:	5f                   	pop    %edi
  801db5:	5d                   	pop    %ebp
  801db6:	c3                   	ret    

00801db7 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
  801dba:	83 ec 08             	sub    $0x8,%esp
  801dbd:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801dc2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dc6:	74 2a                	je     801df2 <devcons_read+0x3b>
  801dc8:	eb 05                	jmp    801dcf <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dca:	e8 0a ef ff ff       	call   800cd9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dcf:	e8 86 ee ff ff       	call   800c5a <sys_cgetc>
  801dd4:	85 c0                	test   %eax,%eax
  801dd6:	74 f2                	je     801dca <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dd8:	85 c0                	test   %eax,%eax
  801dda:	78 16                	js     801df2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ddc:	83 f8 04             	cmp    $0x4,%eax
  801ddf:	74 0c                	je     801ded <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801de1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801de4:	88 02                	mov    %al,(%edx)
	return 1;
  801de6:	b8 01 00 00 00       	mov    $0x1,%eax
  801deb:	eb 05                	jmp    801df2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ded:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801df2:	c9                   	leave  
  801df3:	c3                   	ret    

00801df4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801df4:	55                   	push   %ebp
  801df5:	89 e5                	mov    %esp,%ebp
  801df7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfd:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e00:	6a 01                	push   $0x1
  801e02:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e05:	50                   	push   %eax
  801e06:	e8 31 ee ff ff       	call   800c3c <sys_cputs>
}
  801e0b:	83 c4 10             	add    $0x10,%esp
  801e0e:	c9                   	leave  
  801e0f:	c3                   	ret    

00801e10 <getchar>:

int
getchar(void)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e16:	6a 01                	push   $0x1
  801e18:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e1b:	50                   	push   %eax
  801e1c:	6a 00                	push   $0x0
  801e1e:	e8 41 f6 ff ff       	call   801464 <read>
	if (r < 0)
  801e23:	83 c4 10             	add    $0x10,%esp
  801e26:	85 c0                	test   %eax,%eax
  801e28:	78 0f                	js     801e39 <getchar+0x29>
		return r;
	if (r < 1)
  801e2a:	85 c0                	test   %eax,%eax
  801e2c:	7e 06                	jle    801e34 <getchar+0x24>
		return -E_EOF;
	return c;
  801e2e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e32:	eb 05                	jmp    801e39 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e34:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e39:	c9                   	leave  
  801e3a:	c3                   	ret    

00801e3b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e3b:	55                   	push   %ebp
  801e3c:	89 e5                	mov    %esp,%ebp
  801e3e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e44:	50                   	push   %eax
  801e45:	ff 75 08             	pushl  0x8(%ebp)
  801e48:	e8 b1 f3 ff ff       	call   8011fe <fd_lookup>
  801e4d:	83 c4 10             	add    $0x10,%esp
  801e50:	85 c0                	test   %eax,%eax
  801e52:	78 11                	js     801e65 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e57:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e5d:	39 10                	cmp    %edx,(%eax)
  801e5f:	0f 94 c0             	sete   %al
  801e62:	0f b6 c0             	movzbl %al,%eax
}
  801e65:	c9                   	leave  
  801e66:	c3                   	ret    

00801e67 <opencons>:

int
opencons(void)
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e70:	50                   	push   %eax
  801e71:	e8 39 f3 ff ff       	call   8011af <fd_alloc>
  801e76:	83 c4 10             	add    $0x10,%esp
		return r;
  801e79:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e7b:	85 c0                	test   %eax,%eax
  801e7d:	78 3e                	js     801ebd <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e7f:	83 ec 04             	sub    $0x4,%esp
  801e82:	68 07 04 00 00       	push   $0x407
  801e87:	ff 75 f4             	pushl  -0xc(%ebp)
  801e8a:	6a 00                	push   $0x0
  801e8c:	e8 67 ee ff ff       	call   800cf8 <sys_page_alloc>
  801e91:	83 c4 10             	add    $0x10,%esp
		return r;
  801e94:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e96:	85 c0                	test   %eax,%eax
  801e98:	78 23                	js     801ebd <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e9a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801eaf:	83 ec 0c             	sub    $0xc,%esp
  801eb2:	50                   	push   %eax
  801eb3:	e8 d0 f2 ff ff       	call   801188 <fd2num>
  801eb8:	89 c2                	mov    %eax,%edx
  801eba:	83 c4 10             	add    $0x10,%esp
}
  801ebd:	89 d0                	mov    %edx,%eax
  801ebf:	c9                   	leave  
  801ec0:	c3                   	ret    

00801ec1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ec1:	55                   	push   %ebp
  801ec2:	89 e5                	mov    %esp,%ebp
  801ec4:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ec7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ece:	75 4a                	jne    801f1a <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  801ed0:	a1 20 44 80 00       	mov    0x804420,%eax
  801ed5:	8b 40 48             	mov    0x48(%eax),%eax
  801ed8:	83 ec 04             	sub    $0x4,%esp
  801edb:	6a 07                	push   $0x7
  801edd:	68 00 f0 bf ee       	push   $0xeebff000
  801ee2:	50                   	push   %eax
  801ee3:	e8 10 ee ff ff       	call   800cf8 <sys_page_alloc>
  801ee8:	83 c4 10             	add    $0x10,%esp
  801eeb:	85 c0                	test   %eax,%eax
  801eed:	79 12                	jns    801f01 <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  801eef:	50                   	push   %eax
  801ef0:	68 54 29 80 00       	push   $0x802954
  801ef5:	6a 21                	push   $0x21
  801ef7:	68 6c 29 80 00       	push   $0x80296c
  801efc:	e8 17 e3 ff ff       	call   800218 <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801f01:	a1 20 44 80 00       	mov    0x804420,%eax
  801f06:	8b 40 48             	mov    0x48(%eax),%eax
  801f09:	83 ec 08             	sub    $0x8,%esp
  801f0c:	68 24 1f 80 00       	push   $0x801f24
  801f11:	50                   	push   %eax
  801f12:	e8 2c ef ff ff       	call   800e43 <sys_env_set_pgfault_upcall>
  801f17:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1d:	a3 00 60 80 00       	mov    %eax,0x806000
  801f22:	c9                   	leave  
  801f23:	c3                   	ret    

00801f24 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f24:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f25:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f2a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f2c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  801f2f:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  801f32:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  801f36:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  801f3b:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  801f3f:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801f41:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  801f42:	83 c4 04             	add    $0x4,%esp
	popfl
  801f45:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f46:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  801f47:	c3                   	ret    

00801f48 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f48:	55                   	push   %ebp
  801f49:	89 e5                	mov    %esp,%ebp
  801f4b:	56                   	push   %esi
  801f4c:	53                   	push   %ebx
  801f4d:	8b 75 08             	mov    0x8(%ebp),%esi
  801f50:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801f56:	85 c0                	test   %eax,%eax
  801f58:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f5d:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801f60:	83 ec 0c             	sub    $0xc,%esp
  801f63:	50                   	push   %eax
  801f64:	e8 3f ef ff ff       	call   800ea8 <sys_ipc_recv>
  801f69:	83 c4 10             	add    $0x10,%esp
  801f6c:	85 c0                	test   %eax,%eax
  801f6e:	79 16                	jns    801f86 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801f70:	85 f6                	test   %esi,%esi
  801f72:	74 06                	je     801f7a <ipc_recv+0x32>
            *from_env_store = 0;
  801f74:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801f7a:	85 db                	test   %ebx,%ebx
  801f7c:	74 2c                	je     801faa <ipc_recv+0x62>
            *perm_store = 0;
  801f7e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f84:	eb 24                	jmp    801faa <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801f86:	85 f6                	test   %esi,%esi
  801f88:	74 0a                	je     801f94 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801f8a:	a1 20 44 80 00       	mov    0x804420,%eax
  801f8f:	8b 40 74             	mov    0x74(%eax),%eax
  801f92:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801f94:	85 db                	test   %ebx,%ebx
  801f96:	74 0a                	je     801fa2 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801f98:	a1 20 44 80 00       	mov    0x804420,%eax
  801f9d:	8b 40 78             	mov    0x78(%eax),%eax
  801fa0:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801fa2:	a1 20 44 80 00       	mov    0x804420,%eax
  801fa7:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801faa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fad:	5b                   	pop    %ebx
  801fae:	5e                   	pop    %esi
  801faf:	5d                   	pop    %ebp
  801fb0:	c3                   	ret    

00801fb1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fb1:	55                   	push   %ebp
  801fb2:	89 e5                	mov    %esp,%ebp
  801fb4:	57                   	push   %edi
  801fb5:	56                   	push   %esi
  801fb6:	53                   	push   %ebx
  801fb7:	83 ec 0c             	sub    $0xc,%esp
  801fba:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fbd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fc0:	8b 45 10             	mov    0x10(%ebp),%eax
  801fc3:	85 c0                	test   %eax,%eax
  801fc5:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801fca:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801fcd:	eb 1c                	jmp    801feb <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801fcf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fd2:	74 12                	je     801fe6 <ipc_send+0x35>
  801fd4:	50                   	push   %eax
  801fd5:	68 7a 29 80 00       	push   $0x80297a
  801fda:	6a 3a                	push   $0x3a
  801fdc:	68 90 29 80 00       	push   $0x802990
  801fe1:	e8 32 e2 ff ff       	call   800218 <_panic>
		sys_yield();
  801fe6:	e8 ee ec ff ff       	call   800cd9 <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801feb:	ff 75 14             	pushl  0x14(%ebp)
  801fee:	53                   	push   %ebx
  801fef:	56                   	push   %esi
  801ff0:	57                   	push   %edi
  801ff1:	e8 8f ee ff ff       	call   800e85 <sys_ipc_try_send>
  801ff6:	83 c4 10             	add    $0x10,%esp
  801ff9:	85 c0                	test   %eax,%eax
  801ffb:	78 d2                	js     801fcf <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801ffd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802000:	5b                   	pop    %ebx
  802001:	5e                   	pop    %esi
  802002:	5f                   	pop    %edi
  802003:	5d                   	pop    %ebp
  802004:	c3                   	ret    

00802005 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802005:	55                   	push   %ebp
  802006:	89 e5                	mov    %esp,%ebp
  802008:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80200b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802010:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802013:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802019:	8b 52 50             	mov    0x50(%edx),%edx
  80201c:	39 ca                	cmp    %ecx,%edx
  80201e:	75 0d                	jne    80202d <ipc_find_env+0x28>
			return envs[i].env_id;
  802020:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802023:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802028:	8b 40 48             	mov    0x48(%eax),%eax
  80202b:	eb 0f                	jmp    80203c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80202d:	83 c0 01             	add    $0x1,%eax
  802030:	3d 00 04 00 00       	cmp    $0x400,%eax
  802035:	75 d9                	jne    802010 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802037:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80203c:	5d                   	pop    %ebp
  80203d:	c3                   	ret    

0080203e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80203e:	55                   	push   %ebp
  80203f:	89 e5                	mov    %esp,%ebp
  802041:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802044:	89 d0                	mov    %edx,%eax
  802046:	c1 e8 16             	shr    $0x16,%eax
  802049:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802050:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802055:	f6 c1 01             	test   $0x1,%cl
  802058:	74 1d                	je     802077 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80205a:	c1 ea 0c             	shr    $0xc,%edx
  80205d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802064:	f6 c2 01             	test   $0x1,%dl
  802067:	74 0e                	je     802077 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802069:	c1 ea 0c             	shr    $0xc,%edx
  80206c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802073:	ef 
  802074:	0f b7 c0             	movzwl %ax,%eax
}
  802077:	5d                   	pop    %ebp
  802078:	c3                   	ret    
  802079:	66 90                	xchg   %ax,%ax
  80207b:	66 90                	xchg   %ax,%ax
  80207d:	66 90                	xchg   %ax,%ax
  80207f:	90                   	nop

00802080 <__udivdi3>:
  802080:	55                   	push   %ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	53                   	push   %ebx
  802084:	83 ec 1c             	sub    $0x1c,%esp
  802087:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80208b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80208f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802093:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802097:	85 f6                	test   %esi,%esi
  802099:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80209d:	89 ca                	mov    %ecx,%edx
  80209f:	89 f8                	mov    %edi,%eax
  8020a1:	75 3d                	jne    8020e0 <__udivdi3+0x60>
  8020a3:	39 cf                	cmp    %ecx,%edi
  8020a5:	0f 87 c5 00 00 00    	ja     802170 <__udivdi3+0xf0>
  8020ab:	85 ff                	test   %edi,%edi
  8020ad:	89 fd                	mov    %edi,%ebp
  8020af:	75 0b                	jne    8020bc <__udivdi3+0x3c>
  8020b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b6:	31 d2                	xor    %edx,%edx
  8020b8:	f7 f7                	div    %edi
  8020ba:	89 c5                	mov    %eax,%ebp
  8020bc:	89 c8                	mov    %ecx,%eax
  8020be:	31 d2                	xor    %edx,%edx
  8020c0:	f7 f5                	div    %ebp
  8020c2:	89 c1                	mov    %eax,%ecx
  8020c4:	89 d8                	mov    %ebx,%eax
  8020c6:	89 cf                	mov    %ecx,%edi
  8020c8:	f7 f5                	div    %ebp
  8020ca:	89 c3                	mov    %eax,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	39 ce                	cmp    %ecx,%esi
  8020e2:	77 74                	ja     802158 <__udivdi3+0xd8>
  8020e4:	0f bd fe             	bsr    %esi,%edi
  8020e7:	83 f7 1f             	xor    $0x1f,%edi
  8020ea:	0f 84 98 00 00 00    	je     802188 <__udivdi3+0x108>
  8020f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	89 c5                	mov    %eax,%ebp
  8020f9:	29 fb                	sub    %edi,%ebx
  8020fb:	d3 e6                	shl    %cl,%esi
  8020fd:	89 d9                	mov    %ebx,%ecx
  8020ff:	d3 ed                	shr    %cl,%ebp
  802101:	89 f9                	mov    %edi,%ecx
  802103:	d3 e0                	shl    %cl,%eax
  802105:	09 ee                	or     %ebp,%esi
  802107:	89 d9                	mov    %ebx,%ecx
  802109:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80210d:	89 d5                	mov    %edx,%ebp
  80210f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802113:	d3 ed                	shr    %cl,%ebp
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 e2                	shl    %cl,%edx
  802119:	89 d9                	mov    %ebx,%ecx
  80211b:	d3 e8                	shr    %cl,%eax
  80211d:	09 c2                	or     %eax,%edx
  80211f:	89 d0                	mov    %edx,%eax
  802121:	89 ea                	mov    %ebp,%edx
  802123:	f7 f6                	div    %esi
  802125:	89 d5                	mov    %edx,%ebp
  802127:	89 c3                	mov    %eax,%ebx
  802129:	f7 64 24 0c          	mull   0xc(%esp)
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	72 10                	jb     802141 <__udivdi3+0xc1>
  802131:	8b 74 24 08          	mov    0x8(%esp),%esi
  802135:	89 f9                	mov    %edi,%ecx
  802137:	d3 e6                	shl    %cl,%esi
  802139:	39 c6                	cmp    %eax,%esi
  80213b:	73 07                	jae    802144 <__udivdi3+0xc4>
  80213d:	39 d5                	cmp    %edx,%ebp
  80213f:	75 03                	jne    802144 <__udivdi3+0xc4>
  802141:	83 eb 01             	sub    $0x1,%ebx
  802144:	31 ff                	xor    %edi,%edi
  802146:	89 d8                	mov    %ebx,%eax
  802148:	89 fa                	mov    %edi,%edx
  80214a:	83 c4 1c             	add    $0x1c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802158:	31 ff                	xor    %edi,%edi
  80215a:	31 db                	xor    %ebx,%ebx
  80215c:	89 d8                	mov    %ebx,%eax
  80215e:	89 fa                	mov    %edi,%edx
  802160:	83 c4 1c             	add    $0x1c,%esp
  802163:	5b                   	pop    %ebx
  802164:	5e                   	pop    %esi
  802165:	5f                   	pop    %edi
  802166:	5d                   	pop    %ebp
  802167:	c3                   	ret    
  802168:	90                   	nop
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	89 d8                	mov    %ebx,%eax
  802172:	f7 f7                	div    %edi
  802174:	31 ff                	xor    %edi,%edi
  802176:	89 c3                	mov    %eax,%ebx
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	89 fa                	mov    %edi,%edx
  80217c:	83 c4 1c             	add    $0x1c,%esp
  80217f:	5b                   	pop    %ebx
  802180:	5e                   	pop    %esi
  802181:	5f                   	pop    %edi
  802182:	5d                   	pop    %ebp
  802183:	c3                   	ret    
  802184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802188:	39 ce                	cmp    %ecx,%esi
  80218a:	72 0c                	jb     802198 <__udivdi3+0x118>
  80218c:	31 db                	xor    %ebx,%ebx
  80218e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802192:	0f 87 34 ff ff ff    	ja     8020cc <__udivdi3+0x4c>
  802198:	bb 01 00 00 00       	mov    $0x1,%ebx
  80219d:	e9 2a ff ff ff       	jmp    8020cc <__udivdi3+0x4c>
  8021a2:	66 90                	xchg   %ax,%ax
  8021a4:	66 90                	xchg   %ax,%ax
  8021a6:	66 90                	xchg   %ax,%ax
  8021a8:	66 90                	xchg   %ax,%ax
  8021aa:	66 90                	xchg   %ax,%ax
  8021ac:	66 90                	xchg   %ax,%ax
  8021ae:	66 90                	xchg   %ax,%ax

008021b0 <__umoddi3>:
  8021b0:	55                   	push   %ebp
  8021b1:	57                   	push   %edi
  8021b2:	56                   	push   %esi
  8021b3:	53                   	push   %ebx
  8021b4:	83 ec 1c             	sub    $0x1c,%esp
  8021b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021c7:	85 d2                	test   %edx,%edx
  8021c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021d1:	89 f3                	mov    %esi,%ebx
  8021d3:	89 3c 24             	mov    %edi,(%esp)
  8021d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021da:	75 1c                	jne    8021f8 <__umoddi3+0x48>
  8021dc:	39 f7                	cmp    %esi,%edi
  8021de:	76 50                	jbe    802230 <__umoddi3+0x80>
  8021e0:	89 c8                	mov    %ecx,%eax
  8021e2:	89 f2                	mov    %esi,%edx
  8021e4:	f7 f7                	div    %edi
  8021e6:	89 d0                	mov    %edx,%eax
  8021e8:	31 d2                	xor    %edx,%edx
  8021ea:	83 c4 1c             	add    $0x1c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
  8021f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f8:	39 f2                	cmp    %esi,%edx
  8021fa:	89 d0                	mov    %edx,%eax
  8021fc:	77 52                	ja     802250 <__umoddi3+0xa0>
  8021fe:	0f bd ea             	bsr    %edx,%ebp
  802201:	83 f5 1f             	xor    $0x1f,%ebp
  802204:	75 5a                	jne    802260 <__umoddi3+0xb0>
  802206:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80220a:	0f 82 e0 00 00 00    	jb     8022f0 <__umoddi3+0x140>
  802210:	39 0c 24             	cmp    %ecx,(%esp)
  802213:	0f 86 d7 00 00 00    	jbe    8022f0 <__umoddi3+0x140>
  802219:	8b 44 24 08          	mov    0x8(%esp),%eax
  80221d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802221:	83 c4 1c             	add    $0x1c,%esp
  802224:	5b                   	pop    %ebx
  802225:	5e                   	pop    %esi
  802226:	5f                   	pop    %edi
  802227:	5d                   	pop    %ebp
  802228:	c3                   	ret    
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	85 ff                	test   %edi,%edi
  802232:	89 fd                	mov    %edi,%ebp
  802234:	75 0b                	jne    802241 <__umoddi3+0x91>
  802236:	b8 01 00 00 00       	mov    $0x1,%eax
  80223b:	31 d2                	xor    %edx,%edx
  80223d:	f7 f7                	div    %edi
  80223f:	89 c5                	mov    %eax,%ebp
  802241:	89 f0                	mov    %esi,%eax
  802243:	31 d2                	xor    %edx,%edx
  802245:	f7 f5                	div    %ebp
  802247:	89 c8                	mov    %ecx,%eax
  802249:	f7 f5                	div    %ebp
  80224b:	89 d0                	mov    %edx,%eax
  80224d:	eb 99                	jmp    8021e8 <__umoddi3+0x38>
  80224f:	90                   	nop
  802250:	89 c8                	mov    %ecx,%eax
  802252:	89 f2                	mov    %esi,%edx
  802254:	83 c4 1c             	add    $0x1c,%esp
  802257:	5b                   	pop    %ebx
  802258:	5e                   	pop    %esi
  802259:	5f                   	pop    %edi
  80225a:	5d                   	pop    %ebp
  80225b:	c3                   	ret    
  80225c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802260:	8b 34 24             	mov    (%esp),%esi
  802263:	bf 20 00 00 00       	mov    $0x20,%edi
  802268:	89 e9                	mov    %ebp,%ecx
  80226a:	29 ef                	sub    %ebp,%edi
  80226c:	d3 e0                	shl    %cl,%eax
  80226e:	89 f9                	mov    %edi,%ecx
  802270:	89 f2                	mov    %esi,%edx
  802272:	d3 ea                	shr    %cl,%edx
  802274:	89 e9                	mov    %ebp,%ecx
  802276:	09 c2                	or     %eax,%edx
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	89 14 24             	mov    %edx,(%esp)
  80227d:	89 f2                	mov    %esi,%edx
  80227f:	d3 e2                	shl    %cl,%edx
  802281:	89 f9                	mov    %edi,%ecx
  802283:	89 54 24 04          	mov    %edx,0x4(%esp)
  802287:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80228b:	d3 e8                	shr    %cl,%eax
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	89 c6                	mov    %eax,%esi
  802291:	d3 e3                	shl    %cl,%ebx
  802293:	89 f9                	mov    %edi,%ecx
  802295:	89 d0                	mov    %edx,%eax
  802297:	d3 e8                	shr    %cl,%eax
  802299:	89 e9                	mov    %ebp,%ecx
  80229b:	09 d8                	or     %ebx,%eax
  80229d:	89 d3                	mov    %edx,%ebx
  80229f:	89 f2                	mov    %esi,%edx
  8022a1:	f7 34 24             	divl   (%esp)
  8022a4:	89 d6                	mov    %edx,%esi
  8022a6:	d3 e3                	shl    %cl,%ebx
  8022a8:	f7 64 24 04          	mull   0x4(%esp)
  8022ac:	39 d6                	cmp    %edx,%esi
  8022ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022b2:	89 d1                	mov    %edx,%ecx
  8022b4:	89 c3                	mov    %eax,%ebx
  8022b6:	72 08                	jb     8022c0 <__umoddi3+0x110>
  8022b8:	75 11                	jne    8022cb <__umoddi3+0x11b>
  8022ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022be:	73 0b                	jae    8022cb <__umoddi3+0x11b>
  8022c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022c4:	1b 14 24             	sbb    (%esp),%edx
  8022c7:	89 d1                	mov    %edx,%ecx
  8022c9:	89 c3                	mov    %eax,%ebx
  8022cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022cf:	29 da                	sub    %ebx,%edx
  8022d1:	19 ce                	sbb    %ecx,%esi
  8022d3:	89 f9                	mov    %edi,%ecx
  8022d5:	89 f0                	mov    %esi,%eax
  8022d7:	d3 e0                	shl    %cl,%eax
  8022d9:	89 e9                	mov    %ebp,%ecx
  8022db:	d3 ea                	shr    %cl,%edx
  8022dd:	89 e9                	mov    %ebp,%ecx
  8022df:	d3 ee                	shr    %cl,%esi
  8022e1:	09 d0                	or     %edx,%eax
  8022e3:	89 f2                	mov    %esi,%edx
  8022e5:	83 c4 1c             	add    $0x1c,%esp
  8022e8:	5b                   	pop    %ebx
  8022e9:	5e                   	pop    %esi
  8022ea:	5f                   	pop    %edi
  8022eb:	5d                   	pop    %ebp
  8022ec:	c3                   	ret    
  8022ed:	8d 76 00             	lea    0x0(%esi),%esi
  8022f0:	29 f9                	sub    %edi,%ecx
  8022f2:	19 d6                	sbb    %edx,%esi
  8022f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022fc:	e9 18 ff ff ff       	jmp    802219 <__umoddi3+0x69>
