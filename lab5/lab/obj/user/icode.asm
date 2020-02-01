
obj/user/icode.debug：     文件格式 elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003e:	c7 05 00 30 80 00 00 	movl   $0x802500,0x803000
  800045:	25 80 00 

	cprintf("icode startup\n");
  800048:	68 06 25 80 00       	push   $0x802506
  80004d:	e8 1b 02 00 00       	call   80026d <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 15 25 80 00 	movl   $0x802515,(%esp)
  800059:	e8 0f 02 00 00       	call   80026d <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 28 25 80 00       	push   $0x802528
  800068:	e8 5f 15 00 00       	call   8015cc <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 2e 25 80 00       	push   $0x80252e
  80007c:	6a 0f                	push   $0xf
  80007e:	68 44 25 80 00       	push   $0x802544
  800083:	e8 0c 01 00 00       	call   800194 <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 51 25 80 00       	push   $0x802551
  800090:	e8 d8 01 00 00       	call   80026d <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80009e:	eb 0d                	jmp    8000ad <umain+0x7a>
		sys_cputs(buf, n);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	50                   	push   %eax
  8000a4:	53                   	push   %ebx
  8000a5:	e8 0e 0b 00 00       	call   800bb8 <sys_cputs>
  8000aa:	83 c4 10             	add    $0x10,%esp
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000ad:	83 ec 04             	sub    $0x4,%esp
  8000b0:	68 00 02 00 00       	push   $0x200
  8000b5:	53                   	push   %ebx
  8000b6:	56                   	push   %esi
  8000b7:	e8 85 10 00 00       	call   801141 <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 64 25 80 00       	push   $0x802564
  8000cb:	e8 9d 01 00 00       	call   80026d <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 2d 0f 00 00       	call   801005 <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 78 25 80 00 	movl   $0x802578,(%esp)
  8000df:	e8 89 01 00 00       	call   80026d <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 8c 25 80 00       	push   $0x80258c
  8000f0:	68 95 25 80 00       	push   $0x802595
  8000f5:	68 9f 25 80 00       	push   $0x80259f
  8000fa:	68 9e 25 80 00       	push   $0x80259e
  8000ff:	e8 d4 1a 00 00       	call   801bd8 <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 a4 25 80 00       	push   $0x8025a4
  800111:	6a 1a                	push   $0x1a
  800113:	68 44 25 80 00       	push   $0x802544
  800118:	e8 77 00 00 00       	call   800194 <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 bb 25 80 00       	push   $0x8025bb
  800125:	e8 43 01 00 00       	call   80026d <cprintf>
}
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5d                   	pop    %ebp
  800133:	c3                   	ret    

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013c:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  80013f:	e8 f2 0a 00 00       	call   800c36 <sys_getenvid>
  800144:	25 ff 03 00 00       	and    $0x3ff,%eax
  800149:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800151:	a3 04 40 80 00       	mov    %eax,0x804004

    // save the name of the program so that panic() can use it
    if (argc > 0)
  800156:	85 db                	test   %ebx,%ebx
  800158:	7e 07                	jle    800161 <libmain+0x2d>
        binaryname = argv[0];
  80015a:	8b 06                	mov    (%esi),%eax
  80015c:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	e8 c8 fe ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  80016b:	e8 0a 00 00 00       	call   80017a <exit>
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800180:	e8 ab 0e 00 00       	call   801030 <close_all>
	sys_env_destroy(0);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	6a 00                	push   $0x0
  80018a:	e8 66 0a 00 00       	call   800bf5 <sys_env_destroy>
}
  80018f:	83 c4 10             	add    $0x10,%esp
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800199:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a2:	e8 8f 0a 00 00       	call   800c36 <sys_getenvid>
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	ff 75 0c             	pushl  0xc(%ebp)
  8001ad:	ff 75 08             	pushl  0x8(%ebp)
  8001b0:	56                   	push   %esi
  8001b1:	50                   	push   %eax
  8001b2:	68 d8 25 80 00       	push   $0x8025d8
  8001b7:	e8 b1 00 00 00       	call   80026d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	53                   	push   %ebx
  8001c0:	ff 75 10             	pushl  0x10(%ebp)
  8001c3:	e8 54 00 00 00       	call   80021c <vcprintf>
	cprintf("\n");
  8001c8:	c7 04 24 b8 2a 80 00 	movl   $0x802ab8,(%esp)
  8001cf:	e8 99 00 00 00       	call   80026d <cprintf>
  8001d4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d7:	cc                   	int3   
  8001d8:	eb fd                	jmp    8001d7 <_panic+0x43>

008001da <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	53                   	push   %ebx
  8001de:	83 ec 04             	sub    $0x4,%esp
  8001e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e4:	8b 13                	mov    (%ebx),%edx
  8001e6:	8d 42 01             	lea    0x1(%edx),%eax
  8001e9:	89 03                	mov    %eax,(%ebx)
  8001eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f7:	75 1a                	jne    800213 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	68 ff 00 00 00       	push   $0xff
  800201:	8d 43 08             	lea    0x8(%ebx),%eax
  800204:	50                   	push   %eax
  800205:	e8 ae 09 00 00       	call   800bb8 <sys_cputs>
		b->idx = 0;
  80020a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800210:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800213:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800217:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800225:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022c:	00 00 00 
	b.cnt = 0;
  80022f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800236:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800239:	ff 75 0c             	pushl  0xc(%ebp)
  80023c:	ff 75 08             	pushl  0x8(%ebp)
  80023f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800245:	50                   	push   %eax
  800246:	68 da 01 80 00       	push   $0x8001da
  80024b:	e8 1a 01 00 00       	call   80036a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800250:	83 c4 08             	add    $0x8,%esp
  800253:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800259:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025f:	50                   	push   %eax
  800260:	e8 53 09 00 00       	call   800bb8 <sys_cputs>

	return b.cnt;
}
  800265:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800273:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800276:	50                   	push   %eax
  800277:	ff 75 08             	pushl  0x8(%ebp)
  80027a:	e8 9d ff ff ff       	call   80021c <vcprintf>
	va_end(ap);

	return cnt;
}
  80027f:	c9                   	leave  
  800280:	c3                   	ret    

00800281 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	57                   	push   %edi
  800285:	56                   	push   %esi
  800286:	53                   	push   %ebx
  800287:	83 ec 1c             	sub    $0x1c,%esp
  80028a:	89 c7                	mov    %eax,%edi
  80028c:	89 d6                	mov    %edx,%esi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	8b 55 0c             	mov    0xc(%ebp),%edx
  800294:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800297:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002a5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002a8:	39 d3                	cmp    %edx,%ebx
  8002aa:	72 05                	jb     8002b1 <printnum+0x30>
  8002ac:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002af:	77 45                	ja     8002f6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b1:	83 ec 0c             	sub    $0xc,%esp
  8002b4:	ff 75 18             	pushl  0x18(%ebp)
  8002b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ba:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002bd:	53                   	push   %ebx
  8002be:	ff 75 10             	pushl  0x10(%ebp)
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ca:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d0:	e8 8b 1f 00 00       	call   802260 <__udivdi3>
  8002d5:	83 c4 18             	add    $0x18,%esp
  8002d8:	52                   	push   %edx
  8002d9:	50                   	push   %eax
  8002da:	89 f2                	mov    %esi,%edx
  8002dc:	89 f8                	mov    %edi,%eax
  8002de:	e8 9e ff ff ff       	call   800281 <printnum>
  8002e3:	83 c4 20             	add    $0x20,%esp
  8002e6:	eb 18                	jmp    800300 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	56                   	push   %esi
  8002ec:	ff 75 18             	pushl  0x18(%ebp)
  8002ef:	ff d7                	call   *%edi
  8002f1:	83 c4 10             	add    $0x10,%esp
  8002f4:	eb 03                	jmp    8002f9 <printnum+0x78>
  8002f6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f9:	83 eb 01             	sub    $0x1,%ebx
  8002fc:	85 db                	test   %ebx,%ebx
  8002fe:	7f e8                	jg     8002e8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800300:	83 ec 08             	sub    $0x8,%esp
  800303:	56                   	push   %esi
  800304:	83 ec 04             	sub    $0x4,%esp
  800307:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030a:	ff 75 e0             	pushl  -0x20(%ebp)
  80030d:	ff 75 dc             	pushl  -0x24(%ebp)
  800310:	ff 75 d8             	pushl  -0x28(%ebp)
  800313:	e8 78 20 00 00       	call   802390 <__umoddi3>
  800318:	83 c4 14             	add    $0x14,%esp
  80031b:	0f be 80 fb 25 80 00 	movsbl 0x8025fb(%eax),%eax
  800322:	50                   	push   %eax
  800323:	ff d7                	call   *%edi
}
  800325:	83 c4 10             	add    $0x10,%esp
  800328:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032b:	5b                   	pop    %ebx
  80032c:	5e                   	pop    %esi
  80032d:	5f                   	pop    %edi
  80032e:	5d                   	pop    %ebp
  80032f:	c3                   	ret    

00800330 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800336:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80033a:	8b 10                	mov    (%eax),%edx
  80033c:	3b 50 04             	cmp    0x4(%eax),%edx
  80033f:	73 0a                	jae    80034b <sprintputch+0x1b>
		*b->buf++ = ch;
  800341:	8d 4a 01             	lea    0x1(%edx),%ecx
  800344:	89 08                	mov    %ecx,(%eax)
  800346:	8b 45 08             	mov    0x8(%ebp),%eax
  800349:	88 02                	mov    %al,(%edx)
}
  80034b:	5d                   	pop    %ebp
  80034c:	c3                   	ret    

0080034d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
  800350:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800353:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800356:	50                   	push   %eax
  800357:	ff 75 10             	pushl  0x10(%ebp)
  80035a:	ff 75 0c             	pushl  0xc(%ebp)
  80035d:	ff 75 08             	pushl  0x8(%ebp)
  800360:	e8 05 00 00 00       	call   80036a <vprintfmt>
	va_end(ap);
}
  800365:	83 c4 10             	add    $0x10,%esp
  800368:	c9                   	leave  
  800369:	c3                   	ret    

0080036a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	57                   	push   %edi
  80036e:	56                   	push   %esi
  80036f:	53                   	push   %ebx
  800370:	83 ec 2c             	sub    $0x2c,%esp
  800373:	8b 75 08             	mov    0x8(%ebp),%esi
  800376:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800379:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037c:	eb 12                	jmp    800390 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037e:	85 c0                	test   %eax,%eax
  800380:	0f 84 42 04 00 00    	je     8007c8 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800386:	83 ec 08             	sub    $0x8,%esp
  800389:	53                   	push   %ebx
  80038a:	50                   	push   %eax
  80038b:	ff d6                	call   *%esi
  80038d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800390:	83 c7 01             	add    $0x1,%edi
  800393:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800397:	83 f8 25             	cmp    $0x25,%eax
  80039a:	75 e2                	jne    80037e <vprintfmt+0x14>
  80039c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003a0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ae:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ba:	eb 07                	jmp    8003c3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003bf:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c3:	8d 47 01             	lea    0x1(%edi),%eax
  8003c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c9:	0f b6 07             	movzbl (%edi),%eax
  8003cc:	0f b6 d0             	movzbl %al,%edx
  8003cf:	83 e8 23             	sub    $0x23,%eax
  8003d2:	3c 55                	cmp    $0x55,%al
  8003d4:	0f 87 d3 03 00 00    	ja     8007ad <vprintfmt+0x443>
  8003da:	0f b6 c0             	movzbl %al,%eax
  8003dd:	ff 24 85 40 27 80 00 	jmp    *0x802740(,%eax,4)
  8003e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003eb:	eb d6                	jmp    8003c3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003fb:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003ff:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800402:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800405:	83 f9 09             	cmp    $0x9,%ecx
  800408:	77 3f                	ja     800449 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80040a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040d:	eb e9                	jmp    8003f8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040f:	8b 45 14             	mov    0x14(%ebp),%eax
  800412:	8b 00                	mov    (%eax),%eax
  800414:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800417:	8b 45 14             	mov    0x14(%ebp),%eax
  80041a:	8d 40 04             	lea    0x4(%eax),%eax
  80041d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800423:	eb 2a                	jmp    80044f <vprintfmt+0xe5>
  800425:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800428:	85 c0                	test   %eax,%eax
  80042a:	ba 00 00 00 00       	mov    $0x0,%edx
  80042f:	0f 49 d0             	cmovns %eax,%edx
  800432:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800438:	eb 89                	jmp    8003c3 <vprintfmt+0x59>
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80043d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800444:	e9 7a ff ff ff       	jmp    8003c3 <vprintfmt+0x59>
  800449:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80044c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80044f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800453:	0f 89 6a ff ff ff    	jns    8003c3 <vprintfmt+0x59>
				width = precision, precision = -1;
  800459:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80045c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800466:	e9 58 ff ff ff       	jmp    8003c3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800471:	e9 4d ff ff ff       	jmp    8003c3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800476:	8b 45 14             	mov    0x14(%ebp),%eax
  800479:	8d 78 04             	lea    0x4(%eax),%edi
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	53                   	push   %ebx
  800480:	ff 30                	pushl  (%eax)
  800482:	ff d6                	call   *%esi
			break;
  800484:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800487:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80048d:	e9 fe fe ff ff       	jmp    800390 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800492:	8b 45 14             	mov    0x14(%ebp),%eax
  800495:	8d 78 04             	lea    0x4(%eax),%edi
  800498:	8b 00                	mov    (%eax),%eax
  80049a:	99                   	cltd   
  80049b:	31 d0                	xor    %edx,%eax
  80049d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049f:	83 f8 0f             	cmp    $0xf,%eax
  8004a2:	7f 0b                	jg     8004af <vprintfmt+0x145>
  8004a4:	8b 14 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%edx
  8004ab:	85 d2                	test   %edx,%edx
  8004ad:	75 1b                	jne    8004ca <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8004af:	50                   	push   %eax
  8004b0:	68 13 26 80 00       	push   $0x802613
  8004b5:	53                   	push   %ebx
  8004b6:	56                   	push   %esi
  8004b7:	e8 91 fe ff ff       	call   80034d <printfmt>
  8004bc:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004bf:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c5:	e9 c6 fe ff ff       	jmp    800390 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004ca:	52                   	push   %edx
  8004cb:	68 d1 29 80 00       	push   $0x8029d1
  8004d0:	53                   	push   %ebx
  8004d1:	56                   	push   %esi
  8004d2:	e8 76 fe ff ff       	call   80034d <printfmt>
  8004d7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004da:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e0:	e9 ab fe ff ff       	jmp    800390 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e8:	83 c0 04             	add    $0x4,%eax
  8004eb:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004f3:	85 ff                	test   %edi,%edi
  8004f5:	b8 0c 26 80 00       	mov    $0x80260c,%eax
  8004fa:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004fd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800501:	0f 8e 94 00 00 00    	jle    80059b <vprintfmt+0x231>
  800507:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80050b:	0f 84 98 00 00 00    	je     8005a9 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	ff 75 d0             	pushl  -0x30(%ebp)
  800517:	57                   	push   %edi
  800518:	e8 33 03 00 00       	call   800850 <strnlen>
  80051d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800520:	29 c1                	sub    %eax,%ecx
  800522:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800525:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800528:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80052c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800532:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800534:	eb 0f                	jmp    800545 <vprintfmt+0x1db>
					putch(padc, putdat);
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	53                   	push   %ebx
  80053a:	ff 75 e0             	pushl  -0x20(%ebp)
  80053d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80053f:	83 ef 01             	sub    $0x1,%edi
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	85 ff                	test   %edi,%edi
  800547:	7f ed                	jg     800536 <vprintfmt+0x1cc>
  800549:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80054c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80054f:	85 c9                	test   %ecx,%ecx
  800551:	b8 00 00 00 00       	mov    $0x0,%eax
  800556:	0f 49 c1             	cmovns %ecx,%eax
  800559:	29 c1                	sub    %eax,%ecx
  80055b:	89 75 08             	mov    %esi,0x8(%ebp)
  80055e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800561:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800564:	89 cb                	mov    %ecx,%ebx
  800566:	eb 4d                	jmp    8005b5 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800568:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80056c:	74 1b                	je     800589 <vprintfmt+0x21f>
  80056e:	0f be c0             	movsbl %al,%eax
  800571:	83 e8 20             	sub    $0x20,%eax
  800574:	83 f8 5e             	cmp    $0x5e,%eax
  800577:	76 10                	jbe    800589 <vprintfmt+0x21f>
					putch('?', putdat);
  800579:	83 ec 08             	sub    $0x8,%esp
  80057c:	ff 75 0c             	pushl  0xc(%ebp)
  80057f:	6a 3f                	push   $0x3f
  800581:	ff 55 08             	call   *0x8(%ebp)
  800584:	83 c4 10             	add    $0x10,%esp
  800587:	eb 0d                	jmp    800596 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800589:	83 ec 08             	sub    $0x8,%esp
  80058c:	ff 75 0c             	pushl  0xc(%ebp)
  80058f:	52                   	push   %edx
  800590:	ff 55 08             	call   *0x8(%ebp)
  800593:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800596:	83 eb 01             	sub    $0x1,%ebx
  800599:	eb 1a                	jmp    8005b5 <vprintfmt+0x24b>
  80059b:	89 75 08             	mov    %esi,0x8(%ebp)
  80059e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a7:	eb 0c                	jmp    8005b5 <vprintfmt+0x24b>
  8005a9:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ac:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005af:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005b5:	83 c7 01             	add    $0x1,%edi
  8005b8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005bc:	0f be d0             	movsbl %al,%edx
  8005bf:	85 d2                	test   %edx,%edx
  8005c1:	74 23                	je     8005e6 <vprintfmt+0x27c>
  8005c3:	85 f6                	test   %esi,%esi
  8005c5:	78 a1                	js     800568 <vprintfmt+0x1fe>
  8005c7:	83 ee 01             	sub    $0x1,%esi
  8005ca:	79 9c                	jns    800568 <vprintfmt+0x1fe>
  8005cc:	89 df                	mov    %ebx,%edi
  8005ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d4:	eb 18                	jmp    8005ee <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d6:	83 ec 08             	sub    $0x8,%esp
  8005d9:	53                   	push   %ebx
  8005da:	6a 20                	push   $0x20
  8005dc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005de:	83 ef 01             	sub    $0x1,%edi
  8005e1:	83 c4 10             	add    $0x10,%esp
  8005e4:	eb 08                	jmp    8005ee <vprintfmt+0x284>
  8005e6:	89 df                	mov    %ebx,%edi
  8005e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8005eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ee:	85 ff                	test   %edi,%edi
  8005f0:	7f e4                	jg     8005d6 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005f2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005f5:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005fb:	e9 90 fd ff ff       	jmp    800390 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800600:	83 f9 01             	cmp    $0x1,%ecx
  800603:	7e 19                	jle    80061e <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8b 50 04             	mov    0x4(%eax),%edx
  80060b:	8b 00                	mov    (%eax),%eax
  80060d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800610:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8d 40 08             	lea    0x8(%eax),%eax
  800619:	89 45 14             	mov    %eax,0x14(%ebp)
  80061c:	eb 38                	jmp    800656 <vprintfmt+0x2ec>
	else if (lflag)
  80061e:	85 c9                	test   %ecx,%ecx
  800620:	74 1b                	je     80063d <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8b 00                	mov    (%eax),%eax
  800627:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062a:	89 c1                	mov    %eax,%ecx
  80062c:	c1 f9 1f             	sar    $0x1f,%ecx
  80062f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 40 04             	lea    0x4(%eax),%eax
  800638:	89 45 14             	mov    %eax,0x14(%ebp)
  80063b:	eb 19                	jmp    800656 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8b 00                	mov    (%eax),%eax
  800642:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800645:	89 c1                	mov    %eax,%ecx
  800647:	c1 f9 1f             	sar    $0x1f,%ecx
  80064a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8d 40 04             	lea    0x4(%eax),%eax
  800653:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800656:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800659:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80065c:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800661:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800665:	0f 89 0e 01 00 00    	jns    800779 <vprintfmt+0x40f>
				putch('-', putdat);
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	53                   	push   %ebx
  80066f:	6a 2d                	push   $0x2d
  800671:	ff d6                	call   *%esi
				num = -(long long) num;
  800673:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800676:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800679:	f7 da                	neg    %edx
  80067b:	83 d1 00             	adc    $0x0,%ecx
  80067e:	f7 d9                	neg    %ecx
  800680:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800683:	b8 0a 00 00 00       	mov    $0xa,%eax
  800688:	e9 ec 00 00 00       	jmp    800779 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80068d:	83 f9 01             	cmp    $0x1,%ecx
  800690:	7e 18                	jle    8006aa <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8b 10                	mov    (%eax),%edx
  800697:	8b 48 04             	mov    0x4(%eax),%ecx
  80069a:	8d 40 08             	lea    0x8(%eax),%eax
  80069d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006a0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a5:	e9 cf 00 00 00       	jmp    800779 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006aa:	85 c9                	test   %ecx,%ecx
  8006ac:	74 1a                	je     8006c8 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8b 10                	mov    (%eax),%edx
  8006b3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b8:	8d 40 04             	lea    0x4(%eax),%eax
  8006bb:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c3:	e9 b1 00 00 00       	jmp    800779 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8b 10                	mov    (%eax),%edx
  8006cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d2:	8d 40 04             	lea    0x4(%eax),%eax
  8006d5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006d8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006dd:	e9 97 00 00 00       	jmp    800779 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	6a 58                	push   $0x58
  8006e8:	ff d6                	call   *%esi
			putch('X', putdat);
  8006ea:	83 c4 08             	add    $0x8,%esp
  8006ed:	53                   	push   %ebx
  8006ee:	6a 58                	push   $0x58
  8006f0:	ff d6                	call   *%esi
			putch('X', putdat);
  8006f2:	83 c4 08             	add    $0x8,%esp
  8006f5:	53                   	push   %ebx
  8006f6:	6a 58                	push   $0x58
  8006f8:	ff d6                	call   *%esi
			break;
  8006fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800700:	e9 8b fc ff ff       	jmp    800390 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800705:	83 ec 08             	sub    $0x8,%esp
  800708:	53                   	push   %ebx
  800709:	6a 30                	push   $0x30
  80070b:	ff d6                	call   *%esi
			putch('x', putdat);
  80070d:	83 c4 08             	add    $0x8,%esp
  800710:	53                   	push   %ebx
  800711:	6a 78                	push   $0x78
  800713:	ff d6                	call   *%esi
			num = (unsigned long long)
  800715:	8b 45 14             	mov    0x14(%ebp),%eax
  800718:	8b 10                	mov    (%eax),%edx
  80071a:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80071f:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800722:	8d 40 04             	lea    0x4(%eax),%eax
  800725:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800728:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80072d:	eb 4a                	jmp    800779 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80072f:	83 f9 01             	cmp    $0x1,%ecx
  800732:	7e 15                	jle    800749 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8b 10                	mov    (%eax),%edx
  800739:	8b 48 04             	mov    0x4(%eax),%ecx
  80073c:	8d 40 08             	lea    0x8(%eax),%eax
  80073f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800742:	b8 10 00 00 00       	mov    $0x10,%eax
  800747:	eb 30                	jmp    800779 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800749:	85 c9                	test   %ecx,%ecx
  80074b:	74 17                	je     800764 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  80074d:	8b 45 14             	mov    0x14(%ebp),%eax
  800750:	8b 10                	mov    (%eax),%edx
  800752:	b9 00 00 00 00       	mov    $0x0,%ecx
  800757:	8d 40 04             	lea    0x4(%eax),%eax
  80075a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80075d:	b8 10 00 00 00       	mov    $0x10,%eax
  800762:	eb 15                	jmp    800779 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800764:	8b 45 14             	mov    0x14(%ebp),%eax
  800767:	8b 10                	mov    (%eax),%edx
  800769:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076e:	8d 40 04             	lea    0x4(%eax),%eax
  800771:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800774:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800779:	83 ec 0c             	sub    $0xc,%esp
  80077c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800780:	57                   	push   %edi
  800781:	ff 75 e0             	pushl  -0x20(%ebp)
  800784:	50                   	push   %eax
  800785:	51                   	push   %ecx
  800786:	52                   	push   %edx
  800787:	89 da                	mov    %ebx,%edx
  800789:	89 f0                	mov    %esi,%eax
  80078b:	e8 f1 fa ff ff       	call   800281 <printnum>
			break;
  800790:	83 c4 20             	add    $0x20,%esp
  800793:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800796:	e9 f5 fb ff ff       	jmp    800390 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80079b:	83 ec 08             	sub    $0x8,%esp
  80079e:	53                   	push   %ebx
  80079f:	52                   	push   %edx
  8007a0:	ff d6                	call   *%esi
			break;
  8007a2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007a8:	e9 e3 fb ff ff       	jmp    800390 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007ad:	83 ec 08             	sub    $0x8,%esp
  8007b0:	53                   	push   %ebx
  8007b1:	6a 25                	push   $0x25
  8007b3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007b5:	83 c4 10             	add    $0x10,%esp
  8007b8:	eb 03                	jmp    8007bd <vprintfmt+0x453>
  8007ba:	83 ef 01             	sub    $0x1,%edi
  8007bd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007c1:	75 f7                	jne    8007ba <vprintfmt+0x450>
  8007c3:	e9 c8 fb ff ff       	jmp    800390 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007cb:	5b                   	pop    %ebx
  8007cc:	5e                   	pop    %esi
  8007cd:	5f                   	pop    %edi
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	83 ec 18             	sub    $0x18,%esp
  8007d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007df:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ed:	85 c0                	test   %eax,%eax
  8007ef:	74 26                	je     800817 <vsnprintf+0x47>
  8007f1:	85 d2                	test   %edx,%edx
  8007f3:	7e 22                	jle    800817 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007f5:	ff 75 14             	pushl  0x14(%ebp)
  8007f8:	ff 75 10             	pushl  0x10(%ebp)
  8007fb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007fe:	50                   	push   %eax
  8007ff:	68 30 03 80 00       	push   $0x800330
  800804:	e8 61 fb ff ff       	call   80036a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800809:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80080c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800812:	83 c4 10             	add    $0x10,%esp
  800815:	eb 05                	jmp    80081c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800817:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80081c:	c9                   	leave  
  80081d:	c3                   	ret    

0080081e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800824:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800827:	50                   	push   %eax
  800828:	ff 75 10             	pushl  0x10(%ebp)
  80082b:	ff 75 0c             	pushl  0xc(%ebp)
  80082e:	ff 75 08             	pushl  0x8(%ebp)
  800831:	e8 9a ff ff ff       	call   8007d0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800836:	c9                   	leave  
  800837:	c3                   	ret    

00800838 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80083e:	b8 00 00 00 00       	mov    $0x0,%eax
  800843:	eb 03                	jmp    800848 <strlen+0x10>
		n++;
  800845:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800848:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80084c:	75 f7                	jne    800845 <strlen+0xd>
		n++;
	return n;
}
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800856:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800859:	ba 00 00 00 00       	mov    $0x0,%edx
  80085e:	eb 03                	jmp    800863 <strnlen+0x13>
		n++;
  800860:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800863:	39 c2                	cmp    %eax,%edx
  800865:	74 08                	je     80086f <strnlen+0x1f>
  800867:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80086b:	75 f3                	jne    800860 <strnlen+0x10>
  80086d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	53                   	push   %ebx
  800875:	8b 45 08             	mov    0x8(%ebp),%eax
  800878:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80087b:	89 c2                	mov    %eax,%edx
  80087d:	83 c2 01             	add    $0x1,%edx
  800880:	83 c1 01             	add    $0x1,%ecx
  800883:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800887:	88 5a ff             	mov    %bl,-0x1(%edx)
  80088a:	84 db                	test   %bl,%bl
  80088c:	75 ef                	jne    80087d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80088e:	5b                   	pop    %ebx
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	53                   	push   %ebx
  800895:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800898:	53                   	push   %ebx
  800899:	e8 9a ff ff ff       	call   800838 <strlen>
  80089e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008a1:	ff 75 0c             	pushl  0xc(%ebp)
  8008a4:	01 d8                	add    %ebx,%eax
  8008a6:	50                   	push   %eax
  8008a7:	e8 c5 ff ff ff       	call   800871 <strcpy>
	return dst;
}
  8008ac:	89 d8                	mov    %ebx,%eax
  8008ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b1:	c9                   	leave  
  8008b2:	c3                   	ret    

008008b3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	56                   	push   %esi
  8008b7:	53                   	push   %ebx
  8008b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8008bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008be:	89 f3                	mov    %esi,%ebx
  8008c0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c3:	89 f2                	mov    %esi,%edx
  8008c5:	eb 0f                	jmp    8008d6 <strncpy+0x23>
		*dst++ = *src;
  8008c7:	83 c2 01             	add    $0x1,%edx
  8008ca:	0f b6 01             	movzbl (%ecx),%eax
  8008cd:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d0:	80 39 01             	cmpb   $0x1,(%ecx)
  8008d3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d6:	39 da                	cmp    %ebx,%edx
  8008d8:	75 ed                	jne    8008c7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008da:	89 f0                	mov    %esi,%eax
  8008dc:	5b                   	pop    %ebx
  8008dd:	5e                   	pop    %esi
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	56                   	push   %esi
  8008e4:	53                   	push   %ebx
  8008e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008eb:	8b 55 10             	mov    0x10(%ebp),%edx
  8008ee:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f0:	85 d2                	test   %edx,%edx
  8008f2:	74 21                	je     800915 <strlcpy+0x35>
  8008f4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008f8:	89 f2                	mov    %esi,%edx
  8008fa:	eb 09                	jmp    800905 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008fc:	83 c2 01             	add    $0x1,%edx
  8008ff:	83 c1 01             	add    $0x1,%ecx
  800902:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800905:	39 c2                	cmp    %eax,%edx
  800907:	74 09                	je     800912 <strlcpy+0x32>
  800909:	0f b6 19             	movzbl (%ecx),%ebx
  80090c:	84 db                	test   %bl,%bl
  80090e:	75 ec                	jne    8008fc <strlcpy+0x1c>
  800910:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800912:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800915:	29 f0                	sub    %esi,%eax
}
  800917:	5b                   	pop    %ebx
  800918:	5e                   	pop    %esi
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800921:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800924:	eb 06                	jmp    80092c <strcmp+0x11>
		p++, q++;
  800926:	83 c1 01             	add    $0x1,%ecx
  800929:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80092c:	0f b6 01             	movzbl (%ecx),%eax
  80092f:	84 c0                	test   %al,%al
  800931:	74 04                	je     800937 <strcmp+0x1c>
  800933:	3a 02                	cmp    (%edx),%al
  800935:	74 ef                	je     800926 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800937:	0f b6 c0             	movzbl %al,%eax
  80093a:	0f b6 12             	movzbl (%edx),%edx
  80093d:	29 d0                	sub    %edx,%eax
}
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	53                   	push   %ebx
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
  800948:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094b:	89 c3                	mov    %eax,%ebx
  80094d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800950:	eb 06                	jmp    800958 <strncmp+0x17>
		n--, p++, q++;
  800952:	83 c0 01             	add    $0x1,%eax
  800955:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800958:	39 d8                	cmp    %ebx,%eax
  80095a:	74 15                	je     800971 <strncmp+0x30>
  80095c:	0f b6 08             	movzbl (%eax),%ecx
  80095f:	84 c9                	test   %cl,%cl
  800961:	74 04                	je     800967 <strncmp+0x26>
  800963:	3a 0a                	cmp    (%edx),%cl
  800965:	74 eb                	je     800952 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800967:	0f b6 00             	movzbl (%eax),%eax
  80096a:	0f b6 12             	movzbl (%edx),%edx
  80096d:	29 d0                	sub    %edx,%eax
  80096f:	eb 05                	jmp    800976 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800971:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800976:	5b                   	pop    %ebx
  800977:	5d                   	pop    %ebp
  800978:	c3                   	ret    

00800979 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800983:	eb 07                	jmp    80098c <strchr+0x13>
		if (*s == c)
  800985:	38 ca                	cmp    %cl,%dl
  800987:	74 0f                	je     800998 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800989:	83 c0 01             	add    $0x1,%eax
  80098c:	0f b6 10             	movzbl (%eax),%edx
  80098f:	84 d2                	test   %dl,%dl
  800991:	75 f2                	jne    800985 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800993:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a4:	eb 03                	jmp    8009a9 <strfind+0xf>
  8009a6:	83 c0 01             	add    $0x1,%eax
  8009a9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009ac:	38 ca                	cmp    %cl,%dl
  8009ae:	74 04                	je     8009b4 <strfind+0x1a>
  8009b0:	84 d2                	test   %dl,%dl
  8009b2:	75 f2                	jne    8009a6 <strfind+0xc>
			break;
	return (char *) s;
}
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	57                   	push   %edi
  8009ba:	56                   	push   %esi
  8009bb:	53                   	push   %ebx
  8009bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c2:	85 c9                	test   %ecx,%ecx
  8009c4:	74 36                	je     8009fc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009cc:	75 28                	jne    8009f6 <memset+0x40>
  8009ce:	f6 c1 03             	test   $0x3,%cl
  8009d1:	75 23                	jne    8009f6 <memset+0x40>
		c &= 0xFF;
  8009d3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d7:	89 d3                	mov    %edx,%ebx
  8009d9:	c1 e3 08             	shl    $0x8,%ebx
  8009dc:	89 d6                	mov    %edx,%esi
  8009de:	c1 e6 18             	shl    $0x18,%esi
  8009e1:	89 d0                	mov    %edx,%eax
  8009e3:	c1 e0 10             	shl    $0x10,%eax
  8009e6:	09 f0                	or     %esi,%eax
  8009e8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009ea:	89 d8                	mov    %ebx,%eax
  8009ec:	09 d0                	or     %edx,%eax
  8009ee:	c1 e9 02             	shr    $0x2,%ecx
  8009f1:	fc                   	cld    
  8009f2:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f4:	eb 06                	jmp    8009fc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f9:	fc                   	cld    
  8009fa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009fc:	89 f8                	mov    %edi,%eax
  8009fe:	5b                   	pop    %ebx
  8009ff:	5e                   	pop    %esi
  800a00:	5f                   	pop    %edi
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	57                   	push   %edi
  800a07:	56                   	push   %esi
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a11:	39 c6                	cmp    %eax,%esi
  800a13:	73 35                	jae    800a4a <memmove+0x47>
  800a15:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a18:	39 d0                	cmp    %edx,%eax
  800a1a:	73 2e                	jae    800a4a <memmove+0x47>
		s += n;
		d += n;
  800a1c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1f:	89 d6                	mov    %edx,%esi
  800a21:	09 fe                	or     %edi,%esi
  800a23:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a29:	75 13                	jne    800a3e <memmove+0x3b>
  800a2b:	f6 c1 03             	test   $0x3,%cl
  800a2e:	75 0e                	jne    800a3e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a30:	83 ef 04             	sub    $0x4,%edi
  800a33:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a36:	c1 e9 02             	shr    $0x2,%ecx
  800a39:	fd                   	std    
  800a3a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3c:	eb 09                	jmp    800a47 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a3e:	83 ef 01             	sub    $0x1,%edi
  800a41:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a44:	fd                   	std    
  800a45:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a47:	fc                   	cld    
  800a48:	eb 1d                	jmp    800a67 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4a:	89 f2                	mov    %esi,%edx
  800a4c:	09 c2                	or     %eax,%edx
  800a4e:	f6 c2 03             	test   $0x3,%dl
  800a51:	75 0f                	jne    800a62 <memmove+0x5f>
  800a53:	f6 c1 03             	test   $0x3,%cl
  800a56:	75 0a                	jne    800a62 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a58:	c1 e9 02             	shr    $0x2,%ecx
  800a5b:	89 c7                	mov    %eax,%edi
  800a5d:	fc                   	cld    
  800a5e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a60:	eb 05                	jmp    800a67 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a62:	89 c7                	mov    %eax,%edi
  800a64:	fc                   	cld    
  800a65:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a67:	5e                   	pop    %esi
  800a68:	5f                   	pop    %edi
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a6e:	ff 75 10             	pushl  0x10(%ebp)
  800a71:	ff 75 0c             	pushl  0xc(%ebp)
  800a74:	ff 75 08             	pushl  0x8(%ebp)
  800a77:	e8 87 ff ff ff       	call   800a03 <memmove>
}
  800a7c:	c9                   	leave  
  800a7d:	c3                   	ret    

00800a7e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	56                   	push   %esi
  800a82:	53                   	push   %ebx
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a89:	89 c6                	mov    %eax,%esi
  800a8b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8e:	eb 1a                	jmp    800aaa <memcmp+0x2c>
		if (*s1 != *s2)
  800a90:	0f b6 08             	movzbl (%eax),%ecx
  800a93:	0f b6 1a             	movzbl (%edx),%ebx
  800a96:	38 d9                	cmp    %bl,%cl
  800a98:	74 0a                	je     800aa4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a9a:	0f b6 c1             	movzbl %cl,%eax
  800a9d:	0f b6 db             	movzbl %bl,%ebx
  800aa0:	29 d8                	sub    %ebx,%eax
  800aa2:	eb 0f                	jmp    800ab3 <memcmp+0x35>
		s1++, s2++;
  800aa4:	83 c0 01             	add    $0x1,%eax
  800aa7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aaa:	39 f0                	cmp    %esi,%eax
  800aac:	75 e2                	jne    800a90 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab3:	5b                   	pop    %ebx
  800ab4:	5e                   	pop    %esi
  800ab5:	5d                   	pop    %ebp
  800ab6:	c3                   	ret    

00800ab7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	53                   	push   %ebx
  800abb:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800abe:	89 c1                	mov    %eax,%ecx
  800ac0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ac7:	eb 0a                	jmp    800ad3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac9:	0f b6 10             	movzbl (%eax),%edx
  800acc:	39 da                	cmp    %ebx,%edx
  800ace:	74 07                	je     800ad7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad0:	83 c0 01             	add    $0x1,%eax
  800ad3:	39 c8                	cmp    %ecx,%eax
  800ad5:	72 f2                	jb     800ac9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	57                   	push   %edi
  800ade:	56                   	push   %esi
  800adf:	53                   	push   %ebx
  800ae0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae6:	eb 03                	jmp    800aeb <strtol+0x11>
		s++;
  800ae8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aeb:	0f b6 01             	movzbl (%ecx),%eax
  800aee:	3c 20                	cmp    $0x20,%al
  800af0:	74 f6                	je     800ae8 <strtol+0xe>
  800af2:	3c 09                	cmp    $0x9,%al
  800af4:	74 f2                	je     800ae8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800af6:	3c 2b                	cmp    $0x2b,%al
  800af8:	75 0a                	jne    800b04 <strtol+0x2a>
		s++;
  800afa:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800afd:	bf 00 00 00 00       	mov    $0x0,%edi
  800b02:	eb 11                	jmp    800b15 <strtol+0x3b>
  800b04:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b09:	3c 2d                	cmp    $0x2d,%al
  800b0b:	75 08                	jne    800b15 <strtol+0x3b>
		s++, neg = 1;
  800b0d:	83 c1 01             	add    $0x1,%ecx
  800b10:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b15:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b1b:	75 15                	jne    800b32 <strtol+0x58>
  800b1d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b20:	75 10                	jne    800b32 <strtol+0x58>
  800b22:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b26:	75 7c                	jne    800ba4 <strtol+0xca>
		s += 2, base = 16;
  800b28:	83 c1 02             	add    $0x2,%ecx
  800b2b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b30:	eb 16                	jmp    800b48 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b32:	85 db                	test   %ebx,%ebx
  800b34:	75 12                	jne    800b48 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b36:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b3b:	80 39 30             	cmpb   $0x30,(%ecx)
  800b3e:	75 08                	jne    800b48 <strtol+0x6e>
		s++, base = 8;
  800b40:	83 c1 01             	add    $0x1,%ecx
  800b43:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b48:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b50:	0f b6 11             	movzbl (%ecx),%edx
  800b53:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b56:	89 f3                	mov    %esi,%ebx
  800b58:	80 fb 09             	cmp    $0x9,%bl
  800b5b:	77 08                	ja     800b65 <strtol+0x8b>
			dig = *s - '0';
  800b5d:	0f be d2             	movsbl %dl,%edx
  800b60:	83 ea 30             	sub    $0x30,%edx
  800b63:	eb 22                	jmp    800b87 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b65:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b68:	89 f3                	mov    %esi,%ebx
  800b6a:	80 fb 19             	cmp    $0x19,%bl
  800b6d:	77 08                	ja     800b77 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b6f:	0f be d2             	movsbl %dl,%edx
  800b72:	83 ea 57             	sub    $0x57,%edx
  800b75:	eb 10                	jmp    800b87 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b77:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b7a:	89 f3                	mov    %esi,%ebx
  800b7c:	80 fb 19             	cmp    $0x19,%bl
  800b7f:	77 16                	ja     800b97 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b81:	0f be d2             	movsbl %dl,%edx
  800b84:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b87:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b8a:	7d 0b                	jge    800b97 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b8c:	83 c1 01             	add    $0x1,%ecx
  800b8f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b93:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b95:	eb b9                	jmp    800b50 <strtol+0x76>

	if (endptr)
  800b97:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b9b:	74 0d                	je     800baa <strtol+0xd0>
		*endptr = (char *) s;
  800b9d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba0:	89 0e                	mov    %ecx,(%esi)
  800ba2:	eb 06                	jmp    800baa <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ba4:	85 db                	test   %ebx,%ebx
  800ba6:	74 98                	je     800b40 <strtol+0x66>
  800ba8:	eb 9e                	jmp    800b48 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800baa:	89 c2                	mov    %eax,%edx
  800bac:	f7 da                	neg    %edx
  800bae:	85 ff                	test   %edi,%edi
  800bb0:	0f 45 c2             	cmovne %edx,%eax
}
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc9:	89 c3                	mov    %eax,%ebx
  800bcb:	89 c7                	mov    %eax,%edi
  800bcd:	89 c6                	mov    %eax,%esi
  800bcf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 01 00 00 00       	mov    $0x1,%eax
  800be6:	89 d1                	mov    %edx,%ecx
  800be8:	89 d3                	mov    %edx,%ebx
  800bea:	89 d7                	mov    %edx,%edi
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c03:	b8 03 00 00 00       	mov    $0x3,%eax
  800c08:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0b:	89 cb                	mov    %ecx,%ebx
  800c0d:	89 cf                	mov    %ecx,%edi
  800c0f:	89 ce                	mov    %ecx,%esi
  800c11:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c13:	85 c0                	test   %eax,%eax
  800c15:	7e 17                	jle    800c2e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c17:	83 ec 0c             	sub    $0xc,%esp
  800c1a:	50                   	push   %eax
  800c1b:	6a 03                	push   $0x3
  800c1d:	68 ff 28 80 00       	push   $0x8028ff
  800c22:	6a 23                	push   $0x23
  800c24:	68 1c 29 80 00       	push   $0x80291c
  800c29:	e8 66 f5 ff ff       	call   800194 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c41:	b8 02 00 00 00       	mov    $0x2,%eax
  800c46:	89 d1                	mov    %edx,%ecx
  800c48:	89 d3                	mov    %edx,%ebx
  800c4a:	89 d7                	mov    %edx,%edi
  800c4c:	89 d6                	mov    %edx,%esi
  800c4e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_yield>:

void
sys_yield(void)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c60:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c65:	89 d1                	mov    %edx,%ecx
  800c67:	89 d3                	mov    %edx,%ebx
  800c69:	89 d7                	mov    %edx,%edi
  800c6b:	89 d6                	mov    %edx,%esi
  800c6d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
  800c7a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7d:	be 00 00 00 00       	mov    $0x0,%esi
  800c82:	b8 04 00 00 00       	mov    $0x4,%eax
  800c87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c90:	89 f7                	mov    %esi,%edi
  800c92:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7e 17                	jle    800caf <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c98:	83 ec 0c             	sub    $0xc,%esp
  800c9b:	50                   	push   %eax
  800c9c:	6a 04                	push   $0x4
  800c9e:	68 ff 28 80 00       	push   $0x8028ff
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 1c 29 80 00       	push   $0x80291c
  800caa:	e8 e5 f4 ff ff       	call   800194 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	b8 05 00 00 00       	mov    $0x5,%eax
  800cc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cce:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd1:	8b 75 18             	mov    0x18(%ebp),%esi
  800cd4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7e 17                	jle    800cf1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cda:	83 ec 0c             	sub    $0xc,%esp
  800cdd:	50                   	push   %eax
  800cde:	6a 05                	push   $0x5
  800ce0:	68 ff 28 80 00       	push   $0x8028ff
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 1c 29 80 00       	push   $0x80291c
  800cec:	e8 a3 f4 ff ff       	call   800194 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d07:	b8 06 00 00 00       	mov    $0x6,%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	89 df                	mov    %ebx,%edi
  800d14:	89 de                	mov    %ebx,%esi
  800d16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7e 17                	jle    800d33 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1c:	83 ec 0c             	sub    $0xc,%esp
  800d1f:	50                   	push   %eax
  800d20:	6a 06                	push   $0x6
  800d22:	68 ff 28 80 00       	push   $0x8028ff
  800d27:	6a 23                	push   $0x23
  800d29:	68 1c 29 80 00       	push   $0x80291c
  800d2e:	e8 61 f4 ff ff       	call   800194 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800d44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d49:	b8 08 00 00 00       	mov    $0x8,%eax
  800d4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d51:	8b 55 08             	mov    0x8(%ebp),%edx
  800d54:	89 df                	mov    %ebx,%edi
  800d56:	89 de                	mov    %ebx,%esi
  800d58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	7e 17                	jle    800d75 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5e:	83 ec 0c             	sub    $0xc,%esp
  800d61:	50                   	push   %eax
  800d62:	6a 08                	push   $0x8
  800d64:	68 ff 28 80 00       	push   $0x8028ff
  800d69:	6a 23                	push   $0x23
  800d6b:	68 1c 29 80 00       	push   $0x80291c
  800d70:	e8 1f f4 ff ff       	call   800194 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800d8b:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800d9e:	7e 17                	jle    800db7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da0:	83 ec 0c             	sub    $0xc,%esp
  800da3:	50                   	push   %eax
  800da4:	6a 09                	push   $0x9
  800da6:	68 ff 28 80 00       	push   $0x8028ff
  800dab:	6a 23                	push   $0x23
  800dad:	68 1c 29 80 00       	push   $0x80291c
  800db2:	e8 dd f3 ff ff       	call   800194 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800db7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dba:	5b                   	pop    %ebx
  800dbb:	5e                   	pop    %esi
  800dbc:	5f                   	pop    %edi
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800dcd:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800de0:	7e 17                	jle    800df9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de2:	83 ec 0c             	sub    $0xc,%esp
  800de5:	50                   	push   %eax
  800de6:	6a 0a                	push   $0xa
  800de8:	68 ff 28 80 00       	push   $0x8028ff
  800ded:	6a 23                	push   $0x23
  800def:	68 1c 29 80 00       	push   $0x80291c
  800df4:	e8 9b f3 ff ff       	call   800194 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800df9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfc:	5b                   	pop    %ebx
  800dfd:	5e                   	pop    %esi
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e07:	be 00 00 00 00       	mov    $0x0,%esi
  800e0c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e14:	8b 55 08             	mov    0x8(%ebp),%edx
  800e17:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e1d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800e2d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e32:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e37:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3a:	89 cb                	mov    %ecx,%ebx
  800e3c:	89 cf                	mov    %ecx,%edi
  800e3e:	89 ce                	mov    %ecx,%esi
  800e40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e42:	85 c0                	test   %eax,%eax
  800e44:	7e 17                	jle    800e5d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e46:	83 ec 0c             	sub    $0xc,%esp
  800e49:	50                   	push   %eax
  800e4a:	6a 0d                	push   $0xd
  800e4c:	68 ff 28 80 00       	push   $0x8028ff
  800e51:	6a 23                	push   $0x23
  800e53:	68 1c 29 80 00       	push   $0x80291c
  800e58:	e8 37 f3 ff ff       	call   800194 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e68:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6b:	05 00 00 00 30       	add    $0x30000000,%eax
  800e70:	c1 e8 0c             	shr    $0xc,%eax
}
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e78:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7b:	05 00 00 00 30       	add    $0x30000000,%eax
  800e80:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e85:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e92:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e97:	89 c2                	mov    %eax,%edx
  800e99:	c1 ea 16             	shr    $0x16,%edx
  800e9c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea3:	f6 c2 01             	test   $0x1,%dl
  800ea6:	74 11                	je     800eb9 <fd_alloc+0x2d>
  800ea8:	89 c2                	mov    %eax,%edx
  800eaa:	c1 ea 0c             	shr    $0xc,%edx
  800ead:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb4:	f6 c2 01             	test   $0x1,%dl
  800eb7:	75 09                	jne    800ec2 <fd_alloc+0x36>
			*fd_store = fd;
  800eb9:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ebb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec0:	eb 17                	jmp    800ed9 <fd_alloc+0x4d>
  800ec2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ec7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ecc:	75 c9                	jne    800e97 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ece:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ed4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ed9:	5d                   	pop    %ebp
  800eda:	c3                   	ret    

00800edb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ee1:	83 f8 1f             	cmp    $0x1f,%eax
  800ee4:	77 36                	ja     800f1c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ee6:	c1 e0 0c             	shl    $0xc,%eax
  800ee9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eee:	89 c2                	mov    %eax,%edx
  800ef0:	c1 ea 16             	shr    $0x16,%edx
  800ef3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800efa:	f6 c2 01             	test   $0x1,%dl
  800efd:	74 24                	je     800f23 <fd_lookup+0x48>
  800eff:	89 c2                	mov    %eax,%edx
  800f01:	c1 ea 0c             	shr    $0xc,%edx
  800f04:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f0b:	f6 c2 01             	test   $0x1,%dl
  800f0e:	74 1a                	je     800f2a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f10:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f13:	89 02                	mov    %eax,(%edx)
	return 0;
  800f15:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1a:	eb 13                	jmp    800f2f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f1c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f21:	eb 0c                	jmp    800f2f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f28:	eb 05                	jmp    800f2f <fd_lookup+0x54>
  800f2a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f2f:	5d                   	pop    %ebp
  800f30:	c3                   	ret    

00800f31 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	83 ec 08             	sub    $0x8,%esp
  800f37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f3a:	ba a8 29 80 00       	mov    $0x8029a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f3f:	eb 13                	jmp    800f54 <dev_lookup+0x23>
  800f41:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f44:	39 08                	cmp    %ecx,(%eax)
  800f46:	75 0c                	jne    800f54 <dev_lookup+0x23>
			*dev = devtab[i];
  800f48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f52:	eb 2e                	jmp    800f82 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f54:	8b 02                	mov    (%edx),%eax
  800f56:	85 c0                	test   %eax,%eax
  800f58:	75 e7                	jne    800f41 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f5a:	a1 04 40 80 00       	mov    0x804004,%eax
  800f5f:	8b 40 48             	mov    0x48(%eax),%eax
  800f62:	83 ec 04             	sub    $0x4,%esp
  800f65:	51                   	push   %ecx
  800f66:	50                   	push   %eax
  800f67:	68 2c 29 80 00       	push   $0x80292c
  800f6c:	e8 fc f2 ff ff       	call   80026d <cprintf>
	*dev = 0;
  800f71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f74:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f82:	c9                   	leave  
  800f83:	c3                   	ret    

00800f84 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	56                   	push   %esi
  800f88:	53                   	push   %ebx
  800f89:	83 ec 10             	sub    $0x10,%esp
  800f8c:	8b 75 08             	mov    0x8(%ebp),%esi
  800f8f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f95:	50                   	push   %eax
  800f96:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f9c:	c1 e8 0c             	shr    $0xc,%eax
  800f9f:	50                   	push   %eax
  800fa0:	e8 36 ff ff ff       	call   800edb <fd_lookup>
  800fa5:	83 c4 08             	add    $0x8,%esp
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	78 05                	js     800fb1 <fd_close+0x2d>
	    || fd != fd2)
  800fac:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800faf:	74 0c                	je     800fbd <fd_close+0x39>
		return (must_exist ? r : 0);
  800fb1:	84 db                	test   %bl,%bl
  800fb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb8:	0f 44 c2             	cmove  %edx,%eax
  800fbb:	eb 41                	jmp    800ffe <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fbd:	83 ec 08             	sub    $0x8,%esp
  800fc0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fc3:	50                   	push   %eax
  800fc4:	ff 36                	pushl  (%esi)
  800fc6:	e8 66 ff ff ff       	call   800f31 <dev_lookup>
  800fcb:	89 c3                	mov    %eax,%ebx
  800fcd:	83 c4 10             	add    $0x10,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	78 1a                	js     800fee <fd_close+0x6a>
		if (dev->dev_close)
  800fd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fd7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fda:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fdf:	85 c0                	test   %eax,%eax
  800fe1:	74 0b                	je     800fee <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fe3:	83 ec 0c             	sub    $0xc,%esp
  800fe6:	56                   	push   %esi
  800fe7:	ff d0                	call   *%eax
  800fe9:	89 c3                	mov    %eax,%ebx
  800feb:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fee:	83 ec 08             	sub    $0x8,%esp
  800ff1:	56                   	push   %esi
  800ff2:	6a 00                	push   $0x0
  800ff4:	e8 00 fd ff ff       	call   800cf9 <sys_page_unmap>
	return r;
  800ff9:	83 c4 10             	add    $0x10,%esp
  800ffc:	89 d8                	mov    %ebx,%eax
}
  800ffe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801001:	5b                   	pop    %ebx
  801002:	5e                   	pop    %esi
  801003:	5d                   	pop    %ebp
  801004:	c3                   	ret    

00801005 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801005:	55                   	push   %ebp
  801006:	89 e5                	mov    %esp,%ebp
  801008:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80100b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100e:	50                   	push   %eax
  80100f:	ff 75 08             	pushl  0x8(%ebp)
  801012:	e8 c4 fe ff ff       	call   800edb <fd_lookup>
  801017:	83 c4 08             	add    $0x8,%esp
  80101a:	85 c0                	test   %eax,%eax
  80101c:	78 10                	js     80102e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80101e:	83 ec 08             	sub    $0x8,%esp
  801021:	6a 01                	push   $0x1
  801023:	ff 75 f4             	pushl  -0xc(%ebp)
  801026:	e8 59 ff ff ff       	call   800f84 <fd_close>
  80102b:	83 c4 10             	add    $0x10,%esp
}
  80102e:	c9                   	leave  
  80102f:	c3                   	ret    

00801030 <close_all>:

void
close_all(void)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	53                   	push   %ebx
  801034:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801037:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80103c:	83 ec 0c             	sub    $0xc,%esp
  80103f:	53                   	push   %ebx
  801040:	e8 c0 ff ff ff       	call   801005 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801045:	83 c3 01             	add    $0x1,%ebx
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	83 fb 20             	cmp    $0x20,%ebx
  80104e:	75 ec                	jne    80103c <close_all+0xc>
		close(i);
}
  801050:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801053:	c9                   	leave  
  801054:	c3                   	ret    

00801055 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	57                   	push   %edi
  801059:	56                   	push   %esi
  80105a:	53                   	push   %ebx
  80105b:	83 ec 2c             	sub    $0x2c,%esp
  80105e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801061:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801064:	50                   	push   %eax
  801065:	ff 75 08             	pushl  0x8(%ebp)
  801068:	e8 6e fe ff ff       	call   800edb <fd_lookup>
  80106d:	83 c4 08             	add    $0x8,%esp
  801070:	85 c0                	test   %eax,%eax
  801072:	0f 88 c1 00 00 00    	js     801139 <dup+0xe4>
		return r;
	close(newfdnum);
  801078:	83 ec 0c             	sub    $0xc,%esp
  80107b:	56                   	push   %esi
  80107c:	e8 84 ff ff ff       	call   801005 <close>

	newfd = INDEX2FD(newfdnum);
  801081:	89 f3                	mov    %esi,%ebx
  801083:	c1 e3 0c             	shl    $0xc,%ebx
  801086:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80108c:	83 c4 04             	add    $0x4,%esp
  80108f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801092:	e8 de fd ff ff       	call   800e75 <fd2data>
  801097:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801099:	89 1c 24             	mov    %ebx,(%esp)
  80109c:	e8 d4 fd ff ff       	call   800e75 <fd2data>
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010a7:	89 f8                	mov    %edi,%eax
  8010a9:	c1 e8 16             	shr    $0x16,%eax
  8010ac:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010b3:	a8 01                	test   $0x1,%al
  8010b5:	74 37                	je     8010ee <dup+0x99>
  8010b7:	89 f8                	mov    %edi,%eax
  8010b9:	c1 e8 0c             	shr    $0xc,%eax
  8010bc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010c3:	f6 c2 01             	test   $0x1,%dl
  8010c6:	74 26                	je     8010ee <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010cf:	83 ec 0c             	sub    $0xc,%esp
  8010d2:	25 07 0e 00 00       	and    $0xe07,%eax
  8010d7:	50                   	push   %eax
  8010d8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010db:	6a 00                	push   $0x0
  8010dd:	57                   	push   %edi
  8010de:	6a 00                	push   $0x0
  8010e0:	e8 d2 fb ff ff       	call   800cb7 <sys_page_map>
  8010e5:	89 c7                	mov    %eax,%edi
  8010e7:	83 c4 20             	add    $0x20,%esp
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	78 2e                	js     80111c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010f1:	89 d0                	mov    %edx,%eax
  8010f3:	c1 e8 0c             	shr    $0xc,%eax
  8010f6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010fd:	83 ec 0c             	sub    $0xc,%esp
  801100:	25 07 0e 00 00       	and    $0xe07,%eax
  801105:	50                   	push   %eax
  801106:	53                   	push   %ebx
  801107:	6a 00                	push   $0x0
  801109:	52                   	push   %edx
  80110a:	6a 00                	push   $0x0
  80110c:	e8 a6 fb ff ff       	call   800cb7 <sys_page_map>
  801111:	89 c7                	mov    %eax,%edi
  801113:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801116:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801118:	85 ff                	test   %edi,%edi
  80111a:	79 1d                	jns    801139 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80111c:	83 ec 08             	sub    $0x8,%esp
  80111f:	53                   	push   %ebx
  801120:	6a 00                	push   $0x0
  801122:	e8 d2 fb ff ff       	call   800cf9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801127:	83 c4 08             	add    $0x8,%esp
  80112a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80112d:	6a 00                	push   $0x0
  80112f:	e8 c5 fb ff ff       	call   800cf9 <sys_page_unmap>
	return r;
  801134:	83 c4 10             	add    $0x10,%esp
  801137:	89 f8                	mov    %edi,%eax
}
  801139:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113c:	5b                   	pop    %ebx
  80113d:	5e                   	pop    %esi
  80113e:	5f                   	pop    %edi
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    

00801141 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	53                   	push   %ebx
  801145:	83 ec 14             	sub    $0x14,%esp
  801148:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80114b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80114e:	50                   	push   %eax
  80114f:	53                   	push   %ebx
  801150:	e8 86 fd ff ff       	call   800edb <fd_lookup>
  801155:	83 c4 08             	add    $0x8,%esp
  801158:	89 c2                	mov    %eax,%edx
  80115a:	85 c0                	test   %eax,%eax
  80115c:	78 6d                	js     8011cb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115e:	83 ec 08             	sub    $0x8,%esp
  801161:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801164:	50                   	push   %eax
  801165:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801168:	ff 30                	pushl  (%eax)
  80116a:	e8 c2 fd ff ff       	call   800f31 <dev_lookup>
  80116f:	83 c4 10             	add    $0x10,%esp
  801172:	85 c0                	test   %eax,%eax
  801174:	78 4c                	js     8011c2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801176:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801179:	8b 42 08             	mov    0x8(%edx),%eax
  80117c:	83 e0 03             	and    $0x3,%eax
  80117f:	83 f8 01             	cmp    $0x1,%eax
  801182:	75 21                	jne    8011a5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801184:	a1 04 40 80 00       	mov    0x804004,%eax
  801189:	8b 40 48             	mov    0x48(%eax),%eax
  80118c:	83 ec 04             	sub    $0x4,%esp
  80118f:	53                   	push   %ebx
  801190:	50                   	push   %eax
  801191:	68 6d 29 80 00       	push   $0x80296d
  801196:	e8 d2 f0 ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  80119b:	83 c4 10             	add    $0x10,%esp
  80119e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011a3:	eb 26                	jmp    8011cb <read+0x8a>
	}
	if (!dev->dev_read)
  8011a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a8:	8b 40 08             	mov    0x8(%eax),%eax
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	74 17                	je     8011c6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011af:	83 ec 04             	sub    $0x4,%esp
  8011b2:	ff 75 10             	pushl  0x10(%ebp)
  8011b5:	ff 75 0c             	pushl  0xc(%ebp)
  8011b8:	52                   	push   %edx
  8011b9:	ff d0                	call   *%eax
  8011bb:	89 c2                	mov    %eax,%edx
  8011bd:	83 c4 10             	add    $0x10,%esp
  8011c0:	eb 09                	jmp    8011cb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c2:	89 c2                	mov    %eax,%edx
  8011c4:	eb 05                	jmp    8011cb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011c6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011cb:	89 d0                	mov    %edx,%eax
  8011cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d0:	c9                   	leave  
  8011d1:	c3                   	ret    

008011d2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	57                   	push   %edi
  8011d6:	56                   	push   %esi
  8011d7:	53                   	push   %ebx
  8011d8:	83 ec 0c             	sub    $0xc,%esp
  8011db:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011de:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e6:	eb 21                	jmp    801209 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011e8:	83 ec 04             	sub    $0x4,%esp
  8011eb:	89 f0                	mov    %esi,%eax
  8011ed:	29 d8                	sub    %ebx,%eax
  8011ef:	50                   	push   %eax
  8011f0:	89 d8                	mov    %ebx,%eax
  8011f2:	03 45 0c             	add    0xc(%ebp),%eax
  8011f5:	50                   	push   %eax
  8011f6:	57                   	push   %edi
  8011f7:	e8 45 ff ff ff       	call   801141 <read>
		if (m < 0)
  8011fc:	83 c4 10             	add    $0x10,%esp
  8011ff:	85 c0                	test   %eax,%eax
  801201:	78 10                	js     801213 <readn+0x41>
			return m;
		if (m == 0)
  801203:	85 c0                	test   %eax,%eax
  801205:	74 0a                	je     801211 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801207:	01 c3                	add    %eax,%ebx
  801209:	39 f3                	cmp    %esi,%ebx
  80120b:	72 db                	jb     8011e8 <readn+0x16>
  80120d:	89 d8                	mov    %ebx,%eax
  80120f:	eb 02                	jmp    801213 <readn+0x41>
  801211:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801213:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801216:	5b                   	pop    %ebx
  801217:	5e                   	pop    %esi
  801218:	5f                   	pop    %edi
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    

0080121b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	53                   	push   %ebx
  80121f:	83 ec 14             	sub    $0x14,%esp
  801222:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801225:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801228:	50                   	push   %eax
  801229:	53                   	push   %ebx
  80122a:	e8 ac fc ff ff       	call   800edb <fd_lookup>
  80122f:	83 c4 08             	add    $0x8,%esp
  801232:	89 c2                	mov    %eax,%edx
  801234:	85 c0                	test   %eax,%eax
  801236:	78 68                	js     8012a0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801238:	83 ec 08             	sub    $0x8,%esp
  80123b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123e:	50                   	push   %eax
  80123f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801242:	ff 30                	pushl  (%eax)
  801244:	e8 e8 fc ff ff       	call   800f31 <dev_lookup>
  801249:	83 c4 10             	add    $0x10,%esp
  80124c:	85 c0                	test   %eax,%eax
  80124e:	78 47                	js     801297 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801250:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801253:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801257:	75 21                	jne    80127a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801259:	a1 04 40 80 00       	mov    0x804004,%eax
  80125e:	8b 40 48             	mov    0x48(%eax),%eax
  801261:	83 ec 04             	sub    $0x4,%esp
  801264:	53                   	push   %ebx
  801265:	50                   	push   %eax
  801266:	68 89 29 80 00       	push   $0x802989
  80126b:	e8 fd ef ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  801270:	83 c4 10             	add    $0x10,%esp
  801273:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801278:	eb 26                	jmp    8012a0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80127a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80127d:	8b 52 0c             	mov    0xc(%edx),%edx
  801280:	85 d2                	test   %edx,%edx
  801282:	74 17                	je     80129b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801284:	83 ec 04             	sub    $0x4,%esp
  801287:	ff 75 10             	pushl  0x10(%ebp)
  80128a:	ff 75 0c             	pushl  0xc(%ebp)
  80128d:	50                   	push   %eax
  80128e:	ff d2                	call   *%edx
  801290:	89 c2                	mov    %eax,%edx
  801292:	83 c4 10             	add    $0x10,%esp
  801295:	eb 09                	jmp    8012a0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801297:	89 c2                	mov    %eax,%edx
  801299:	eb 05                	jmp    8012a0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80129b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012a0:	89 d0                	mov    %edx,%eax
  8012a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a5:	c9                   	leave  
  8012a6:	c3                   	ret    

008012a7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ad:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012b0:	50                   	push   %eax
  8012b1:	ff 75 08             	pushl  0x8(%ebp)
  8012b4:	e8 22 fc ff ff       	call   800edb <fd_lookup>
  8012b9:	83 c4 08             	add    $0x8,%esp
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	78 0e                	js     8012ce <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ce:	c9                   	leave  
  8012cf:	c3                   	ret    

008012d0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012d0:	55                   	push   %ebp
  8012d1:	89 e5                	mov    %esp,%ebp
  8012d3:	53                   	push   %ebx
  8012d4:	83 ec 14             	sub    $0x14,%esp
  8012d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012dd:	50                   	push   %eax
  8012de:	53                   	push   %ebx
  8012df:	e8 f7 fb ff ff       	call   800edb <fd_lookup>
  8012e4:	83 c4 08             	add    $0x8,%esp
  8012e7:	89 c2                	mov    %eax,%edx
  8012e9:	85 c0                	test   %eax,%eax
  8012eb:	78 65                	js     801352 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ed:	83 ec 08             	sub    $0x8,%esp
  8012f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f3:	50                   	push   %eax
  8012f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f7:	ff 30                	pushl  (%eax)
  8012f9:	e8 33 fc ff ff       	call   800f31 <dev_lookup>
  8012fe:	83 c4 10             	add    $0x10,%esp
  801301:	85 c0                	test   %eax,%eax
  801303:	78 44                	js     801349 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801305:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801308:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80130c:	75 21                	jne    80132f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80130e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801313:	8b 40 48             	mov    0x48(%eax),%eax
  801316:	83 ec 04             	sub    $0x4,%esp
  801319:	53                   	push   %ebx
  80131a:	50                   	push   %eax
  80131b:	68 4c 29 80 00       	push   $0x80294c
  801320:	e8 48 ef ff ff       	call   80026d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801325:	83 c4 10             	add    $0x10,%esp
  801328:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80132d:	eb 23                	jmp    801352 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80132f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801332:	8b 52 18             	mov    0x18(%edx),%edx
  801335:	85 d2                	test   %edx,%edx
  801337:	74 14                	je     80134d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801339:	83 ec 08             	sub    $0x8,%esp
  80133c:	ff 75 0c             	pushl  0xc(%ebp)
  80133f:	50                   	push   %eax
  801340:	ff d2                	call   *%edx
  801342:	89 c2                	mov    %eax,%edx
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	eb 09                	jmp    801352 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801349:	89 c2                	mov    %eax,%edx
  80134b:	eb 05                	jmp    801352 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80134d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801352:	89 d0                	mov    %edx,%eax
  801354:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801357:	c9                   	leave  
  801358:	c3                   	ret    

00801359 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801359:	55                   	push   %ebp
  80135a:	89 e5                	mov    %esp,%ebp
  80135c:	53                   	push   %ebx
  80135d:	83 ec 14             	sub    $0x14,%esp
  801360:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801363:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801366:	50                   	push   %eax
  801367:	ff 75 08             	pushl  0x8(%ebp)
  80136a:	e8 6c fb ff ff       	call   800edb <fd_lookup>
  80136f:	83 c4 08             	add    $0x8,%esp
  801372:	89 c2                	mov    %eax,%edx
  801374:	85 c0                	test   %eax,%eax
  801376:	78 58                	js     8013d0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801378:	83 ec 08             	sub    $0x8,%esp
  80137b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137e:	50                   	push   %eax
  80137f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801382:	ff 30                	pushl  (%eax)
  801384:	e8 a8 fb ff ff       	call   800f31 <dev_lookup>
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	85 c0                	test   %eax,%eax
  80138e:	78 37                	js     8013c7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801390:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801393:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801397:	74 32                	je     8013cb <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801399:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80139c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013a3:	00 00 00 
	stat->st_isdir = 0;
  8013a6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013ad:	00 00 00 
	stat->st_dev = dev;
  8013b0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013b6:	83 ec 08             	sub    $0x8,%esp
  8013b9:	53                   	push   %ebx
  8013ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8013bd:	ff 50 14             	call   *0x14(%eax)
  8013c0:	89 c2                	mov    %eax,%edx
  8013c2:	83 c4 10             	add    $0x10,%esp
  8013c5:	eb 09                	jmp    8013d0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c7:	89 c2                	mov    %eax,%edx
  8013c9:	eb 05                	jmp    8013d0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013cb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013d0:	89 d0                	mov    %edx,%eax
  8013d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d5:	c9                   	leave  
  8013d6:	c3                   	ret    

008013d7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	56                   	push   %esi
  8013db:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013dc:	83 ec 08             	sub    $0x8,%esp
  8013df:	6a 00                	push   $0x0
  8013e1:	ff 75 08             	pushl  0x8(%ebp)
  8013e4:	e8 e3 01 00 00       	call   8015cc <open>
  8013e9:	89 c3                	mov    %eax,%ebx
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	78 1b                	js     80140d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013f2:	83 ec 08             	sub    $0x8,%esp
  8013f5:	ff 75 0c             	pushl  0xc(%ebp)
  8013f8:	50                   	push   %eax
  8013f9:	e8 5b ff ff ff       	call   801359 <fstat>
  8013fe:	89 c6                	mov    %eax,%esi
	close(fd);
  801400:	89 1c 24             	mov    %ebx,(%esp)
  801403:	e8 fd fb ff ff       	call   801005 <close>
	return r;
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	89 f0                	mov    %esi,%eax
}
  80140d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801410:	5b                   	pop    %ebx
  801411:	5e                   	pop    %esi
  801412:	5d                   	pop    %ebp
  801413:	c3                   	ret    

00801414 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	56                   	push   %esi
  801418:	53                   	push   %ebx
  801419:	89 c6                	mov    %eax,%esi
  80141b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80141d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801424:	75 12                	jne    801438 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801426:	83 ec 0c             	sub    $0xc,%esp
  801429:	6a 01                	push   $0x1
  80142b:	e8 b7 0d 00 00       	call   8021e7 <ipc_find_env>
  801430:	a3 00 40 80 00       	mov    %eax,0x804000
  801435:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801438:	6a 07                	push   $0x7
  80143a:	68 00 50 80 00       	push   $0x805000
  80143f:	56                   	push   %esi
  801440:	ff 35 00 40 80 00    	pushl  0x804000
  801446:	e8 48 0d 00 00       	call   802193 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80144b:	83 c4 0c             	add    $0xc,%esp
  80144e:	6a 00                	push   $0x0
  801450:	53                   	push   %ebx
  801451:	6a 00                	push   $0x0
  801453:	e8 d2 0c 00 00       	call   80212a <ipc_recv>
}
  801458:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80145b:	5b                   	pop    %ebx
  80145c:	5e                   	pop    %esi
  80145d:	5d                   	pop    %ebp
  80145e:	c3                   	ret    

0080145f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80145f:	55                   	push   %ebp
  801460:	89 e5                	mov    %esp,%ebp
  801462:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801465:	8b 45 08             	mov    0x8(%ebp),%eax
  801468:	8b 40 0c             	mov    0xc(%eax),%eax
  80146b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801470:	8b 45 0c             	mov    0xc(%ebp),%eax
  801473:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801478:	ba 00 00 00 00       	mov    $0x0,%edx
  80147d:	b8 02 00 00 00       	mov    $0x2,%eax
  801482:	e8 8d ff ff ff       	call   801414 <fsipc>
}
  801487:	c9                   	leave  
  801488:	c3                   	ret    

00801489 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
  80148c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80148f:	8b 45 08             	mov    0x8(%ebp),%eax
  801492:	8b 40 0c             	mov    0xc(%eax),%eax
  801495:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80149a:	ba 00 00 00 00       	mov    $0x0,%edx
  80149f:	b8 06 00 00 00       	mov    $0x6,%eax
  8014a4:	e8 6b ff ff ff       	call   801414 <fsipc>
}
  8014a9:	c9                   	leave  
  8014aa:	c3                   	ret    

008014ab <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014ab:	55                   	push   %ebp
  8014ac:	89 e5                	mov    %esp,%ebp
  8014ae:	53                   	push   %ebx
  8014af:	83 ec 04             	sub    $0x4,%esp
  8014b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014bb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c5:	b8 05 00 00 00       	mov    $0x5,%eax
  8014ca:	e8 45 ff ff ff       	call   801414 <fsipc>
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	78 2c                	js     8014ff <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014d3:	83 ec 08             	sub    $0x8,%esp
  8014d6:	68 00 50 80 00       	push   $0x805000
  8014db:	53                   	push   %ebx
  8014dc:	e8 90 f3 ff ff       	call   800871 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014e1:	a1 80 50 80 00       	mov    0x805080,%eax
  8014e6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014ec:	a1 84 50 80 00       	mov    0x805084,%eax
  8014f1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014f7:	83 c4 10             	add    $0x10,%esp
  8014fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801502:	c9                   	leave  
  801503:	c3                   	ret    

00801504 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	83 ec 0c             	sub    $0xc,%esp
  80150a:	8b 45 10             	mov    0x10(%ebp),%eax
  80150d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801512:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801517:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80151a:	8b 55 08             	mov    0x8(%ebp),%edx
  80151d:	8b 52 0c             	mov    0xc(%edx),%edx
  801520:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801526:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80152b:	50                   	push   %eax
  80152c:	ff 75 0c             	pushl  0xc(%ebp)
  80152f:	68 08 50 80 00       	push   $0x805008
  801534:	e8 ca f4 ff ff       	call   800a03 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801539:	ba 00 00 00 00       	mov    $0x0,%edx
  80153e:	b8 04 00 00 00       	mov    $0x4,%eax
  801543:	e8 cc fe ff ff       	call   801414 <fsipc>
	//panic("devfile_write not implemented");
}
  801548:	c9                   	leave  
  801549:	c3                   	ret    

0080154a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	56                   	push   %esi
  80154e:	53                   	push   %ebx
  80154f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801552:	8b 45 08             	mov    0x8(%ebp),%eax
  801555:	8b 40 0c             	mov    0xc(%eax),%eax
  801558:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80155d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801563:	ba 00 00 00 00       	mov    $0x0,%edx
  801568:	b8 03 00 00 00       	mov    $0x3,%eax
  80156d:	e8 a2 fe ff ff       	call   801414 <fsipc>
  801572:	89 c3                	mov    %eax,%ebx
  801574:	85 c0                	test   %eax,%eax
  801576:	78 4b                	js     8015c3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801578:	39 c6                	cmp    %eax,%esi
  80157a:	73 16                	jae    801592 <devfile_read+0x48>
  80157c:	68 b8 29 80 00       	push   $0x8029b8
  801581:	68 bf 29 80 00       	push   $0x8029bf
  801586:	6a 7c                	push   $0x7c
  801588:	68 d4 29 80 00       	push   $0x8029d4
  80158d:	e8 02 ec ff ff       	call   800194 <_panic>
	assert(r <= PGSIZE);
  801592:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801597:	7e 16                	jle    8015af <devfile_read+0x65>
  801599:	68 df 29 80 00       	push   $0x8029df
  80159e:	68 bf 29 80 00       	push   $0x8029bf
  8015a3:	6a 7d                	push   $0x7d
  8015a5:	68 d4 29 80 00       	push   $0x8029d4
  8015aa:	e8 e5 eb ff ff       	call   800194 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015af:	83 ec 04             	sub    $0x4,%esp
  8015b2:	50                   	push   %eax
  8015b3:	68 00 50 80 00       	push   $0x805000
  8015b8:	ff 75 0c             	pushl  0xc(%ebp)
  8015bb:	e8 43 f4 ff ff       	call   800a03 <memmove>
	return r;
  8015c0:	83 c4 10             	add    $0x10,%esp
}
  8015c3:	89 d8                	mov    %ebx,%eax
  8015c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c8:	5b                   	pop    %ebx
  8015c9:	5e                   	pop    %esi
  8015ca:	5d                   	pop    %ebp
  8015cb:	c3                   	ret    

008015cc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	53                   	push   %ebx
  8015d0:	83 ec 20             	sub    $0x20,%esp
  8015d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015d6:	53                   	push   %ebx
  8015d7:	e8 5c f2 ff ff       	call   800838 <strlen>
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015e4:	7f 67                	jg     80164d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015e6:	83 ec 0c             	sub    $0xc,%esp
  8015e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ec:	50                   	push   %eax
  8015ed:	e8 9a f8 ff ff       	call   800e8c <fd_alloc>
  8015f2:	83 c4 10             	add    $0x10,%esp
		return r;
  8015f5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	78 57                	js     801652 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015fb:	83 ec 08             	sub    $0x8,%esp
  8015fe:	53                   	push   %ebx
  8015ff:	68 00 50 80 00       	push   $0x805000
  801604:	e8 68 f2 ff ff       	call   800871 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801609:	8b 45 0c             	mov    0xc(%ebp),%eax
  80160c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801611:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801614:	b8 01 00 00 00       	mov    $0x1,%eax
  801619:	e8 f6 fd ff ff       	call   801414 <fsipc>
  80161e:	89 c3                	mov    %eax,%ebx
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	85 c0                	test   %eax,%eax
  801625:	79 14                	jns    80163b <open+0x6f>
		fd_close(fd, 0);
  801627:	83 ec 08             	sub    $0x8,%esp
  80162a:	6a 00                	push   $0x0
  80162c:	ff 75 f4             	pushl  -0xc(%ebp)
  80162f:	e8 50 f9 ff ff       	call   800f84 <fd_close>
		return r;
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	89 da                	mov    %ebx,%edx
  801639:	eb 17                	jmp    801652 <open+0x86>
	}

	return fd2num(fd);
  80163b:	83 ec 0c             	sub    $0xc,%esp
  80163e:	ff 75 f4             	pushl  -0xc(%ebp)
  801641:	e8 1f f8 ff ff       	call   800e65 <fd2num>
  801646:	89 c2                	mov    %eax,%edx
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	eb 05                	jmp    801652 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80164d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801652:	89 d0                	mov    %edx,%eax
  801654:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801657:	c9                   	leave  
  801658:	c3                   	ret    

00801659 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80165f:	ba 00 00 00 00       	mov    $0x0,%edx
  801664:	b8 08 00 00 00       	mov    $0x8,%eax
  801669:	e8 a6 fd ff ff       	call   801414 <fsipc>
}
  80166e:	c9                   	leave  
  80166f:	c3                   	ret    

00801670 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	57                   	push   %edi
  801674:	56                   	push   %esi
  801675:	53                   	push   %ebx
  801676:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80167c:	6a 00                	push   $0x0
  80167e:	ff 75 08             	pushl  0x8(%ebp)
  801681:	e8 46 ff ff ff       	call   8015cc <open>
  801686:	89 c7                	mov    %eax,%edi
  801688:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80168e:	83 c4 10             	add    $0x10,%esp
  801691:	85 c0                	test   %eax,%eax
  801693:	0f 88 82 04 00 00    	js     801b1b <spawn+0x4ab>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801699:	83 ec 04             	sub    $0x4,%esp
  80169c:	68 00 02 00 00       	push   $0x200
  8016a1:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8016a7:	50                   	push   %eax
  8016a8:	57                   	push   %edi
  8016a9:	e8 24 fb ff ff       	call   8011d2 <readn>
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	3d 00 02 00 00       	cmp    $0x200,%eax
  8016b6:	75 0c                	jne    8016c4 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8016b8:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8016bf:	45 4c 46 
  8016c2:	74 33                	je     8016f7 <spawn+0x87>
		close(fd);
  8016c4:	83 ec 0c             	sub    $0xc,%esp
  8016c7:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8016cd:	e8 33 f9 ff ff       	call   801005 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8016d2:	83 c4 0c             	add    $0xc,%esp
  8016d5:	68 7f 45 4c 46       	push   $0x464c457f
  8016da:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8016e0:	68 eb 29 80 00       	push   $0x8029eb
  8016e5:	e8 83 eb ff ff       	call   80026d <cprintf>
		return -E_NOT_EXEC;
  8016ea:	83 c4 10             	add    $0x10,%esp
  8016ed:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8016f2:	e9 d7 04 00 00       	jmp    801bce <spawn+0x55e>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8016f7:	b8 07 00 00 00       	mov    $0x7,%eax
  8016fc:	cd 30                	int    $0x30
  8016fe:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801704:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80170a:	85 c0                	test   %eax,%eax
  80170c:	0f 88 14 04 00 00    	js     801b26 <spawn+0x4b6>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801712:	89 c6                	mov    %eax,%esi
  801714:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80171a:	6b f6 7c             	imul   $0x7c,%esi,%esi
  80171d:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801723:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801729:	b9 11 00 00 00       	mov    $0x11,%ecx
  80172e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801730:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801736:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80173c:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801741:	be 00 00 00 00       	mov    $0x0,%esi
  801746:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801749:	eb 13                	jmp    80175e <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80174b:	83 ec 0c             	sub    $0xc,%esp
  80174e:	50                   	push   %eax
  80174f:	e8 e4 f0 ff ff       	call   800838 <strlen>
  801754:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801758:	83 c3 01             	add    $0x1,%ebx
  80175b:	83 c4 10             	add    $0x10,%esp
  80175e:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801765:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801768:	85 c0                	test   %eax,%eax
  80176a:	75 df                	jne    80174b <spawn+0xdb>
  80176c:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801772:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801778:	bf 00 10 40 00       	mov    $0x401000,%edi
  80177d:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80177f:	89 fa                	mov    %edi,%edx
  801781:	83 e2 fc             	and    $0xfffffffc,%edx
  801784:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80178b:	29 c2                	sub    %eax,%edx
  80178d:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801793:	8d 42 f8             	lea    -0x8(%edx),%eax
  801796:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80179b:	0f 86 9b 03 00 00    	jbe    801b3c <spawn+0x4cc>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8017a1:	83 ec 04             	sub    $0x4,%esp
  8017a4:	6a 07                	push   $0x7
  8017a6:	68 00 00 40 00       	push   $0x400000
  8017ab:	6a 00                	push   $0x0
  8017ad:	e8 c2 f4 ff ff       	call   800c74 <sys_page_alloc>
  8017b2:	83 c4 10             	add    $0x10,%esp
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	0f 88 89 03 00 00    	js     801b46 <spawn+0x4d6>
  8017bd:	be 00 00 00 00       	mov    $0x0,%esi
  8017c2:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8017c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017cb:	eb 30                	jmp    8017fd <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8017cd:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8017d3:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8017d9:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8017dc:	83 ec 08             	sub    $0x8,%esp
  8017df:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017e2:	57                   	push   %edi
  8017e3:	e8 89 f0 ff ff       	call   800871 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8017e8:	83 c4 04             	add    $0x4,%esp
  8017eb:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017ee:	e8 45 f0 ff ff       	call   800838 <strlen>
  8017f3:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8017f7:	83 c6 01             	add    $0x1,%esi
  8017fa:	83 c4 10             	add    $0x10,%esp
  8017fd:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801803:	7f c8                	jg     8017cd <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801805:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80180b:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801811:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801818:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80181e:	74 19                	je     801839 <spawn+0x1c9>
  801820:	68 78 2a 80 00       	push   $0x802a78
  801825:	68 bf 29 80 00       	push   $0x8029bf
  80182a:	68 f2 00 00 00       	push   $0xf2
  80182f:	68 05 2a 80 00       	push   $0x802a05
  801834:	e8 5b e9 ff ff       	call   800194 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801839:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  80183f:	89 f8                	mov    %edi,%eax
  801841:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801846:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801849:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80184f:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801852:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801858:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80185e:	83 ec 0c             	sub    $0xc,%esp
  801861:	6a 07                	push   $0x7
  801863:	68 00 d0 bf ee       	push   $0xeebfd000
  801868:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80186e:	68 00 00 40 00       	push   $0x400000
  801873:	6a 00                	push   $0x0
  801875:	e8 3d f4 ff ff       	call   800cb7 <sys_page_map>
  80187a:	89 c3                	mov    %eax,%ebx
  80187c:	83 c4 20             	add    $0x20,%esp
  80187f:	85 c0                	test   %eax,%eax
  801881:	0f 88 35 03 00 00    	js     801bbc <spawn+0x54c>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801887:	83 ec 08             	sub    $0x8,%esp
  80188a:	68 00 00 40 00       	push   $0x400000
  80188f:	6a 00                	push   $0x0
  801891:	e8 63 f4 ff ff       	call   800cf9 <sys_page_unmap>
  801896:	89 c3                	mov    %eax,%ebx
  801898:	83 c4 10             	add    $0x10,%esp
  80189b:	85 c0                	test   %eax,%eax
  80189d:	0f 88 19 03 00 00    	js     801bbc <spawn+0x54c>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8018a3:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8018a9:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8018b0:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8018b6:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8018bd:	00 00 00 
  8018c0:	e9 88 01 00 00       	jmp    801a4d <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  8018c5:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8018cb:	83 38 01             	cmpl   $0x1,(%eax)
  8018ce:	0f 85 6b 01 00 00    	jne    801a3f <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8018d4:	89 c1                	mov    %eax,%ecx
  8018d6:	8b 40 18             	mov    0x18(%eax),%eax
  8018d9:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8018df:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8018e2:	83 f8 01             	cmp    $0x1,%eax
  8018e5:	19 c0                	sbb    %eax,%eax
  8018e7:	83 e0 fe             	and    $0xfffffffe,%eax
  8018ea:	83 c0 07             	add    $0x7,%eax
  8018ed:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8018f3:	89 c8                	mov    %ecx,%eax
  8018f5:	8b 79 04             	mov    0x4(%ecx),%edi
  8018f8:	89 f9                	mov    %edi,%ecx
  8018fa:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801900:	8b 78 10             	mov    0x10(%eax),%edi
  801903:	8b 50 14             	mov    0x14(%eax),%edx
  801906:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  80190c:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80190f:	89 f0                	mov    %esi,%eax
  801911:	25 ff 0f 00 00       	and    $0xfff,%eax
  801916:	74 14                	je     80192c <spawn+0x2bc>
		va -= i;
  801918:	29 c6                	sub    %eax,%esi
		memsz += i;
  80191a:	01 c2                	add    %eax,%edx
  80191c:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801922:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801924:	29 c1                	sub    %eax,%ecx
  801926:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80192c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801931:	e9 f7 00 00 00       	jmp    801a2d <spawn+0x3bd>
		if (i >= filesz) {
  801936:	39 fb                	cmp    %edi,%ebx
  801938:	72 27                	jb     801961 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80193a:	83 ec 04             	sub    $0x4,%esp
  80193d:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801943:	56                   	push   %esi
  801944:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80194a:	e8 25 f3 ff ff       	call   800c74 <sys_page_alloc>
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	85 c0                	test   %eax,%eax
  801954:	0f 89 c7 00 00 00    	jns    801a21 <spawn+0x3b1>
  80195a:	89 c3                	mov    %eax,%ebx
  80195c:	e9 f6 01 00 00       	jmp    801b57 <spawn+0x4e7>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801961:	83 ec 04             	sub    $0x4,%esp
  801964:	6a 07                	push   $0x7
  801966:	68 00 00 40 00       	push   $0x400000
  80196b:	6a 00                	push   $0x0
  80196d:	e8 02 f3 ff ff       	call   800c74 <sys_page_alloc>
  801972:	83 c4 10             	add    $0x10,%esp
  801975:	85 c0                	test   %eax,%eax
  801977:	0f 88 d0 01 00 00    	js     801b4d <spawn+0x4dd>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80197d:	83 ec 08             	sub    $0x8,%esp
  801980:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801986:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  80198c:	50                   	push   %eax
  80198d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801993:	e8 0f f9 ff ff       	call   8012a7 <seek>
  801998:	83 c4 10             	add    $0x10,%esp
  80199b:	85 c0                	test   %eax,%eax
  80199d:	0f 88 ae 01 00 00    	js     801b51 <spawn+0x4e1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8019a3:	83 ec 04             	sub    $0x4,%esp
  8019a6:	89 f8                	mov    %edi,%eax
  8019a8:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8019ae:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019b3:	b9 00 10 00 00       	mov    $0x1000,%ecx
  8019b8:	0f 47 c1             	cmova  %ecx,%eax
  8019bb:	50                   	push   %eax
  8019bc:	68 00 00 40 00       	push   $0x400000
  8019c1:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019c7:	e8 06 f8 ff ff       	call   8011d2 <readn>
  8019cc:	83 c4 10             	add    $0x10,%esp
  8019cf:	85 c0                	test   %eax,%eax
  8019d1:	0f 88 7e 01 00 00    	js     801b55 <spawn+0x4e5>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8019d7:	83 ec 0c             	sub    $0xc,%esp
  8019da:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8019e0:	56                   	push   %esi
  8019e1:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8019e7:	68 00 00 40 00       	push   $0x400000
  8019ec:	6a 00                	push   $0x0
  8019ee:	e8 c4 f2 ff ff       	call   800cb7 <sys_page_map>
  8019f3:	83 c4 20             	add    $0x20,%esp
  8019f6:	85 c0                	test   %eax,%eax
  8019f8:	79 15                	jns    801a0f <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  8019fa:	50                   	push   %eax
  8019fb:	68 11 2a 80 00       	push   $0x802a11
  801a00:	68 25 01 00 00       	push   $0x125
  801a05:	68 05 2a 80 00       	push   $0x802a05
  801a0a:	e8 85 e7 ff ff       	call   800194 <_panic>
			sys_page_unmap(0, UTEMP);
  801a0f:	83 ec 08             	sub    $0x8,%esp
  801a12:	68 00 00 40 00       	push   $0x400000
  801a17:	6a 00                	push   $0x0
  801a19:	e8 db f2 ff ff       	call   800cf9 <sys_page_unmap>
  801a1e:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801a21:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a27:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801a2d:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801a33:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801a39:	0f 82 f7 fe ff ff    	jb     801936 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a3f:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801a46:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801a4d:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801a54:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801a5a:	0f 8c 65 fe ff ff    	jl     8018c5 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801a60:	83 ec 0c             	sub    $0xc,%esp
  801a63:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a69:	e8 97 f5 ff ff       	call   801005 <close>
  801a6e:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r=0,pn=0;
	for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  801a71:	bb 00 08 00 00       	mov    $0x800,%ebx
  801a76:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
        if ((uvpd[pn >> 10] & PTE_P) &&uvpt[pn] & PTE_SHARE)
  801a7c:	89 d8                	mov    %ebx,%eax
  801a7e:	c1 f8 0a             	sar    $0xa,%eax
  801a81:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a88:	a8 01                	test   $0x1,%al
  801a8a:	74 3e                	je     801aca <spawn+0x45a>
  801a8c:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801a93:	f6 c4 04             	test   $0x4,%ah
  801a96:	74 32                	je     801aca <spawn+0x45a>
            if ( (r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), child, (void *)(pn*PGSIZE), uvpt[pn] & PTE_SYSCALL )) < 0)
  801a98:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801a9f:	89 da                	mov    %ebx,%edx
  801aa1:	c1 e2 0c             	shl    $0xc,%edx
  801aa4:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801aaa:	8b 49 48             	mov    0x48(%ecx),%ecx
  801aad:	83 ec 0c             	sub    $0xc,%esp
  801ab0:	25 07 0e 00 00       	and    $0xe07,%eax
  801ab5:	50                   	push   %eax
  801ab6:	52                   	push   %edx
  801ab7:	56                   	push   %esi
  801ab8:	52                   	push   %edx
  801ab9:	51                   	push   %ecx
  801aba:	e8 f8 f1 ff ff       	call   800cb7 <sys_page_map>
  801abf:	83 c4 20             	add    $0x20,%esp
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	0f 88 dd 00 00 00    	js     801ba7 <spawn+0x537>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r=0,pn=0;
	for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  801aca:	83 c3 01             	add    $0x1,%ebx
  801acd:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801ad3:	75 a7                	jne    801a7c <spawn+0x40c>
  801ad5:	e9 9e 00 00 00       	jmp    801b78 <spawn+0x508>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801ada:	50                   	push   %eax
  801adb:	68 2e 2a 80 00       	push   $0x802a2e
  801ae0:	68 86 00 00 00       	push   $0x86
  801ae5:	68 05 2a 80 00       	push   $0x802a05
  801aea:	e8 a5 e6 ff ff       	call   800194 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801aef:	83 ec 08             	sub    $0x8,%esp
  801af2:	6a 02                	push   $0x2
  801af4:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801afa:	e8 3c f2 ff ff       	call   800d3b <sys_env_set_status>
  801aff:	83 c4 10             	add    $0x10,%esp
  801b02:	85 c0                	test   %eax,%eax
  801b04:	79 2b                	jns    801b31 <spawn+0x4c1>
		panic("sys_env_set_status: %e", r);
  801b06:	50                   	push   %eax
  801b07:	68 48 2a 80 00       	push   $0x802a48
  801b0c:	68 89 00 00 00       	push   $0x89
  801b11:	68 05 2a 80 00       	push   $0x802a05
  801b16:	e8 79 e6 ff ff       	call   800194 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801b1b:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801b21:	e9 a8 00 00 00       	jmp    801bce <spawn+0x55e>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801b26:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b2c:	e9 9d 00 00 00       	jmp    801bce <spawn+0x55e>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801b31:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b37:	e9 92 00 00 00       	jmp    801bce <spawn+0x55e>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801b3c:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801b41:	e9 88 00 00 00       	jmp    801bce <spawn+0x55e>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801b46:	89 c3                	mov    %eax,%ebx
  801b48:	e9 81 00 00 00       	jmp    801bce <spawn+0x55e>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b4d:	89 c3                	mov    %eax,%ebx
  801b4f:	eb 06                	jmp    801b57 <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b51:	89 c3                	mov    %eax,%ebx
  801b53:	eb 02                	jmp    801b57 <spawn+0x4e7>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b55:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801b57:	83 ec 0c             	sub    $0xc,%esp
  801b5a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b60:	e8 90 f0 ff ff       	call   800bf5 <sys_env_destroy>
	close(fd);
  801b65:	83 c4 04             	add    $0x4,%esp
  801b68:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b6e:	e8 92 f4 ff ff       	call   801005 <close>
	return r;
  801b73:	83 c4 10             	add    $0x10,%esp
  801b76:	eb 56                	jmp    801bce <spawn+0x55e>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801b78:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801b7f:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801b82:	83 ec 08             	sub    $0x8,%esp
  801b85:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801b8b:	50                   	push   %eax
  801b8c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b92:	e8 e6 f1 ff ff       	call   800d7d <sys_env_set_trapframe>
  801b97:	83 c4 10             	add    $0x10,%esp
  801b9a:	85 c0                	test   %eax,%eax
  801b9c:	0f 89 4d ff ff ff    	jns    801aef <spawn+0x47f>
  801ba2:	e9 33 ff ff ff       	jmp    801ada <spawn+0x46a>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801ba7:	50                   	push   %eax
  801ba8:	68 5f 2a 80 00       	push   $0x802a5f
  801bad:	68 82 00 00 00       	push   $0x82
  801bb2:	68 05 2a 80 00       	push   $0x802a05
  801bb7:	e8 d8 e5 ff ff       	call   800194 <_panic>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801bbc:	83 ec 08             	sub    $0x8,%esp
  801bbf:	68 00 00 40 00       	push   $0x400000
  801bc4:	6a 00                	push   $0x0
  801bc6:	e8 2e f1 ff ff       	call   800cf9 <sys_page_unmap>
  801bcb:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801bce:	89 d8                	mov    %ebx,%eax
  801bd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd3:	5b                   	pop    %ebx
  801bd4:	5e                   	pop    %esi
  801bd5:	5f                   	pop    %edi
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    

00801bd8 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	56                   	push   %esi
  801bdc:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801bdd:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801be0:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801be5:	eb 03                	jmp    801bea <spawnl+0x12>
		argc++;
  801be7:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801bea:	83 c2 04             	add    $0x4,%edx
  801bed:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801bf1:	75 f4                	jne    801be7 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801bf3:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801bfa:	83 e2 f0             	and    $0xfffffff0,%edx
  801bfd:	29 d4                	sub    %edx,%esp
  801bff:	8d 54 24 03          	lea    0x3(%esp),%edx
  801c03:	c1 ea 02             	shr    $0x2,%edx
  801c06:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801c0d:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801c0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c12:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801c19:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801c20:	00 
  801c21:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801c23:	b8 00 00 00 00       	mov    $0x0,%eax
  801c28:	eb 0a                	jmp    801c34 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801c2a:	83 c0 01             	add    $0x1,%eax
  801c2d:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801c31:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801c34:	39 d0                	cmp    %edx,%eax
  801c36:	75 f2                	jne    801c2a <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801c38:	83 ec 08             	sub    $0x8,%esp
  801c3b:	56                   	push   %esi
  801c3c:	ff 75 08             	pushl  0x8(%ebp)
  801c3f:	e8 2c fa ff ff       	call   801670 <spawn>
}
  801c44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c47:	5b                   	pop    %ebx
  801c48:	5e                   	pop    %esi
  801c49:	5d                   	pop    %ebp
  801c4a:	c3                   	ret    

00801c4b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
  801c4e:	56                   	push   %esi
  801c4f:	53                   	push   %ebx
  801c50:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c53:	83 ec 0c             	sub    $0xc,%esp
  801c56:	ff 75 08             	pushl  0x8(%ebp)
  801c59:	e8 17 f2 ff ff       	call   800e75 <fd2data>
  801c5e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c60:	83 c4 08             	add    $0x8,%esp
  801c63:	68 a0 2a 80 00       	push   $0x802aa0
  801c68:	53                   	push   %ebx
  801c69:	e8 03 ec ff ff       	call   800871 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c6e:	8b 46 04             	mov    0x4(%esi),%eax
  801c71:	2b 06                	sub    (%esi),%eax
  801c73:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c79:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c80:	00 00 00 
	stat->st_dev = &devpipe;
  801c83:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c8a:	30 80 00 
	return 0;
}
  801c8d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c92:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c95:	5b                   	pop    %ebx
  801c96:	5e                   	pop    %esi
  801c97:	5d                   	pop    %ebp
  801c98:	c3                   	ret    

00801c99 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c99:	55                   	push   %ebp
  801c9a:	89 e5                	mov    %esp,%ebp
  801c9c:	53                   	push   %ebx
  801c9d:	83 ec 0c             	sub    $0xc,%esp
  801ca0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ca3:	53                   	push   %ebx
  801ca4:	6a 00                	push   $0x0
  801ca6:	e8 4e f0 ff ff       	call   800cf9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cab:	89 1c 24             	mov    %ebx,(%esp)
  801cae:	e8 c2 f1 ff ff       	call   800e75 <fd2data>
  801cb3:	83 c4 08             	add    $0x8,%esp
  801cb6:	50                   	push   %eax
  801cb7:	6a 00                	push   $0x0
  801cb9:	e8 3b f0 ff ff       	call   800cf9 <sys_page_unmap>
}
  801cbe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cc1:	c9                   	leave  
  801cc2:	c3                   	ret    

00801cc3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cc3:	55                   	push   %ebp
  801cc4:	89 e5                	mov    %esp,%ebp
  801cc6:	57                   	push   %edi
  801cc7:	56                   	push   %esi
  801cc8:	53                   	push   %ebx
  801cc9:	83 ec 1c             	sub    $0x1c,%esp
  801ccc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ccf:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cd1:	a1 04 40 80 00       	mov    0x804004,%eax
  801cd6:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801cd9:	83 ec 0c             	sub    $0xc,%esp
  801cdc:	ff 75 e0             	pushl  -0x20(%ebp)
  801cdf:	e8 3c 05 00 00       	call   802220 <pageref>
  801ce4:	89 c3                	mov    %eax,%ebx
  801ce6:	89 3c 24             	mov    %edi,(%esp)
  801ce9:	e8 32 05 00 00       	call   802220 <pageref>
  801cee:	83 c4 10             	add    $0x10,%esp
  801cf1:	39 c3                	cmp    %eax,%ebx
  801cf3:	0f 94 c1             	sete   %cl
  801cf6:	0f b6 c9             	movzbl %cl,%ecx
  801cf9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801cfc:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d02:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d05:	39 ce                	cmp    %ecx,%esi
  801d07:	74 1b                	je     801d24 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d09:	39 c3                	cmp    %eax,%ebx
  801d0b:	75 c4                	jne    801cd1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d0d:	8b 42 58             	mov    0x58(%edx),%eax
  801d10:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d13:	50                   	push   %eax
  801d14:	56                   	push   %esi
  801d15:	68 a7 2a 80 00       	push   $0x802aa7
  801d1a:	e8 4e e5 ff ff       	call   80026d <cprintf>
  801d1f:	83 c4 10             	add    $0x10,%esp
  801d22:	eb ad                	jmp    801cd1 <_pipeisclosed+0xe>
	}
}
  801d24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d2a:	5b                   	pop    %ebx
  801d2b:	5e                   	pop    %esi
  801d2c:	5f                   	pop    %edi
  801d2d:	5d                   	pop    %ebp
  801d2e:	c3                   	ret    

00801d2f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d2f:	55                   	push   %ebp
  801d30:	89 e5                	mov    %esp,%ebp
  801d32:	57                   	push   %edi
  801d33:	56                   	push   %esi
  801d34:	53                   	push   %ebx
  801d35:	83 ec 28             	sub    $0x28,%esp
  801d38:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d3b:	56                   	push   %esi
  801d3c:	e8 34 f1 ff ff       	call   800e75 <fd2data>
  801d41:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d43:	83 c4 10             	add    $0x10,%esp
  801d46:	bf 00 00 00 00       	mov    $0x0,%edi
  801d4b:	eb 4b                	jmp    801d98 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d4d:	89 da                	mov    %ebx,%edx
  801d4f:	89 f0                	mov    %esi,%eax
  801d51:	e8 6d ff ff ff       	call   801cc3 <_pipeisclosed>
  801d56:	85 c0                	test   %eax,%eax
  801d58:	75 48                	jne    801da2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d5a:	e8 f6 ee ff ff       	call   800c55 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d5f:	8b 43 04             	mov    0x4(%ebx),%eax
  801d62:	8b 0b                	mov    (%ebx),%ecx
  801d64:	8d 51 20             	lea    0x20(%ecx),%edx
  801d67:	39 d0                	cmp    %edx,%eax
  801d69:	73 e2                	jae    801d4d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d6e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d72:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d75:	89 c2                	mov    %eax,%edx
  801d77:	c1 fa 1f             	sar    $0x1f,%edx
  801d7a:	89 d1                	mov    %edx,%ecx
  801d7c:	c1 e9 1b             	shr    $0x1b,%ecx
  801d7f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d82:	83 e2 1f             	and    $0x1f,%edx
  801d85:	29 ca                	sub    %ecx,%edx
  801d87:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d8b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d8f:	83 c0 01             	add    $0x1,%eax
  801d92:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d95:	83 c7 01             	add    $0x1,%edi
  801d98:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d9b:	75 c2                	jne    801d5f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d9d:	8b 45 10             	mov    0x10(%ebp),%eax
  801da0:	eb 05                	jmp    801da7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801da2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801da7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801daa:	5b                   	pop    %ebx
  801dab:	5e                   	pop    %esi
  801dac:	5f                   	pop    %edi
  801dad:	5d                   	pop    %ebp
  801dae:	c3                   	ret    

00801daf <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801daf:	55                   	push   %ebp
  801db0:	89 e5                	mov    %esp,%ebp
  801db2:	57                   	push   %edi
  801db3:	56                   	push   %esi
  801db4:	53                   	push   %ebx
  801db5:	83 ec 18             	sub    $0x18,%esp
  801db8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801dbb:	57                   	push   %edi
  801dbc:	e8 b4 f0 ff ff       	call   800e75 <fd2data>
  801dc1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dc3:	83 c4 10             	add    $0x10,%esp
  801dc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801dcb:	eb 3d                	jmp    801e0a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801dcd:	85 db                	test   %ebx,%ebx
  801dcf:	74 04                	je     801dd5 <devpipe_read+0x26>
				return i;
  801dd1:	89 d8                	mov    %ebx,%eax
  801dd3:	eb 44                	jmp    801e19 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801dd5:	89 f2                	mov    %esi,%edx
  801dd7:	89 f8                	mov    %edi,%eax
  801dd9:	e8 e5 fe ff ff       	call   801cc3 <_pipeisclosed>
  801dde:	85 c0                	test   %eax,%eax
  801de0:	75 32                	jne    801e14 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801de2:	e8 6e ee ff ff       	call   800c55 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801de7:	8b 06                	mov    (%esi),%eax
  801de9:	3b 46 04             	cmp    0x4(%esi),%eax
  801dec:	74 df                	je     801dcd <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801dee:	99                   	cltd   
  801def:	c1 ea 1b             	shr    $0x1b,%edx
  801df2:	01 d0                	add    %edx,%eax
  801df4:	83 e0 1f             	and    $0x1f,%eax
  801df7:	29 d0                	sub    %edx,%eax
  801df9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801dfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e01:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e04:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e07:	83 c3 01             	add    $0x1,%ebx
  801e0a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e0d:	75 d8                	jne    801de7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e0f:	8b 45 10             	mov    0x10(%ebp),%eax
  801e12:	eb 05                	jmp    801e19 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e14:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e1c:	5b                   	pop    %ebx
  801e1d:	5e                   	pop    %esi
  801e1e:	5f                   	pop    %edi
  801e1f:	5d                   	pop    %ebp
  801e20:	c3                   	ret    

00801e21 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	56                   	push   %esi
  801e25:	53                   	push   %ebx
  801e26:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e29:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e2c:	50                   	push   %eax
  801e2d:	e8 5a f0 ff ff       	call   800e8c <fd_alloc>
  801e32:	83 c4 10             	add    $0x10,%esp
  801e35:	89 c2                	mov    %eax,%edx
  801e37:	85 c0                	test   %eax,%eax
  801e39:	0f 88 2c 01 00 00    	js     801f6b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e3f:	83 ec 04             	sub    $0x4,%esp
  801e42:	68 07 04 00 00       	push   $0x407
  801e47:	ff 75 f4             	pushl  -0xc(%ebp)
  801e4a:	6a 00                	push   $0x0
  801e4c:	e8 23 ee ff ff       	call   800c74 <sys_page_alloc>
  801e51:	83 c4 10             	add    $0x10,%esp
  801e54:	89 c2                	mov    %eax,%edx
  801e56:	85 c0                	test   %eax,%eax
  801e58:	0f 88 0d 01 00 00    	js     801f6b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e5e:	83 ec 0c             	sub    $0xc,%esp
  801e61:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e64:	50                   	push   %eax
  801e65:	e8 22 f0 ff ff       	call   800e8c <fd_alloc>
  801e6a:	89 c3                	mov    %eax,%ebx
  801e6c:	83 c4 10             	add    $0x10,%esp
  801e6f:	85 c0                	test   %eax,%eax
  801e71:	0f 88 e2 00 00 00    	js     801f59 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e77:	83 ec 04             	sub    $0x4,%esp
  801e7a:	68 07 04 00 00       	push   $0x407
  801e7f:	ff 75 f0             	pushl  -0x10(%ebp)
  801e82:	6a 00                	push   $0x0
  801e84:	e8 eb ed ff ff       	call   800c74 <sys_page_alloc>
  801e89:	89 c3                	mov    %eax,%ebx
  801e8b:	83 c4 10             	add    $0x10,%esp
  801e8e:	85 c0                	test   %eax,%eax
  801e90:	0f 88 c3 00 00 00    	js     801f59 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e96:	83 ec 0c             	sub    $0xc,%esp
  801e99:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9c:	e8 d4 ef ff ff       	call   800e75 <fd2data>
  801ea1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea3:	83 c4 0c             	add    $0xc,%esp
  801ea6:	68 07 04 00 00       	push   $0x407
  801eab:	50                   	push   %eax
  801eac:	6a 00                	push   $0x0
  801eae:	e8 c1 ed ff ff       	call   800c74 <sys_page_alloc>
  801eb3:	89 c3                	mov    %eax,%ebx
  801eb5:	83 c4 10             	add    $0x10,%esp
  801eb8:	85 c0                	test   %eax,%eax
  801eba:	0f 88 89 00 00 00    	js     801f49 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec0:	83 ec 0c             	sub    $0xc,%esp
  801ec3:	ff 75 f0             	pushl  -0x10(%ebp)
  801ec6:	e8 aa ef ff ff       	call   800e75 <fd2data>
  801ecb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ed2:	50                   	push   %eax
  801ed3:	6a 00                	push   $0x0
  801ed5:	56                   	push   %esi
  801ed6:	6a 00                	push   $0x0
  801ed8:	e8 da ed ff ff       	call   800cb7 <sys_page_map>
  801edd:	89 c3                	mov    %eax,%ebx
  801edf:	83 c4 20             	add    $0x20,%esp
  801ee2:	85 c0                	test   %eax,%eax
  801ee4:	78 55                	js     801f3b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ee6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801eec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eef:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801efb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f04:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f06:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f09:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f10:	83 ec 0c             	sub    $0xc,%esp
  801f13:	ff 75 f4             	pushl  -0xc(%ebp)
  801f16:	e8 4a ef ff ff       	call   800e65 <fd2num>
  801f1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f1e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f20:	83 c4 04             	add    $0x4,%esp
  801f23:	ff 75 f0             	pushl  -0x10(%ebp)
  801f26:	e8 3a ef ff ff       	call   800e65 <fd2num>
  801f2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f2e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f31:	83 c4 10             	add    $0x10,%esp
  801f34:	ba 00 00 00 00       	mov    $0x0,%edx
  801f39:	eb 30                	jmp    801f6b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f3b:	83 ec 08             	sub    $0x8,%esp
  801f3e:	56                   	push   %esi
  801f3f:	6a 00                	push   $0x0
  801f41:	e8 b3 ed ff ff       	call   800cf9 <sys_page_unmap>
  801f46:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f49:	83 ec 08             	sub    $0x8,%esp
  801f4c:	ff 75 f0             	pushl  -0x10(%ebp)
  801f4f:	6a 00                	push   $0x0
  801f51:	e8 a3 ed ff ff       	call   800cf9 <sys_page_unmap>
  801f56:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f59:	83 ec 08             	sub    $0x8,%esp
  801f5c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f5f:	6a 00                	push   $0x0
  801f61:	e8 93 ed ff ff       	call   800cf9 <sys_page_unmap>
  801f66:	83 c4 10             	add    $0x10,%esp
  801f69:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f6b:	89 d0                	mov    %edx,%eax
  801f6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f70:	5b                   	pop    %ebx
  801f71:	5e                   	pop    %esi
  801f72:	5d                   	pop    %ebp
  801f73:	c3                   	ret    

00801f74 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f74:	55                   	push   %ebp
  801f75:	89 e5                	mov    %esp,%ebp
  801f77:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f7d:	50                   	push   %eax
  801f7e:	ff 75 08             	pushl  0x8(%ebp)
  801f81:	e8 55 ef ff ff       	call   800edb <fd_lookup>
  801f86:	83 c4 10             	add    $0x10,%esp
  801f89:	85 c0                	test   %eax,%eax
  801f8b:	78 18                	js     801fa5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f8d:	83 ec 0c             	sub    $0xc,%esp
  801f90:	ff 75 f4             	pushl  -0xc(%ebp)
  801f93:	e8 dd ee ff ff       	call   800e75 <fd2data>
	return _pipeisclosed(fd, p);
  801f98:	89 c2                	mov    %eax,%edx
  801f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9d:	e8 21 fd ff ff       	call   801cc3 <_pipeisclosed>
  801fa2:	83 c4 10             	add    $0x10,%esp
}
  801fa5:	c9                   	leave  
  801fa6:	c3                   	ret    

00801fa7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fa7:	55                   	push   %ebp
  801fa8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801faa:	b8 00 00 00 00       	mov    $0x0,%eax
  801faf:	5d                   	pop    %ebp
  801fb0:	c3                   	ret    

00801fb1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fb1:	55                   	push   %ebp
  801fb2:	89 e5                	mov    %esp,%ebp
  801fb4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fb7:	68 bf 2a 80 00       	push   $0x802abf
  801fbc:	ff 75 0c             	pushl  0xc(%ebp)
  801fbf:	e8 ad e8 ff ff       	call   800871 <strcpy>
	return 0;
}
  801fc4:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc9:	c9                   	leave  
  801fca:	c3                   	ret    

00801fcb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fcb:	55                   	push   %ebp
  801fcc:	89 e5                	mov    %esp,%ebp
  801fce:	57                   	push   %edi
  801fcf:	56                   	push   %esi
  801fd0:	53                   	push   %ebx
  801fd1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fd7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fdc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fe2:	eb 2d                	jmp    802011 <devcons_write+0x46>
		m = n - tot;
  801fe4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fe7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801fe9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fec:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ff1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ff4:	83 ec 04             	sub    $0x4,%esp
  801ff7:	53                   	push   %ebx
  801ff8:	03 45 0c             	add    0xc(%ebp),%eax
  801ffb:	50                   	push   %eax
  801ffc:	57                   	push   %edi
  801ffd:	e8 01 ea ff ff       	call   800a03 <memmove>
		sys_cputs(buf, m);
  802002:	83 c4 08             	add    $0x8,%esp
  802005:	53                   	push   %ebx
  802006:	57                   	push   %edi
  802007:	e8 ac eb ff ff       	call   800bb8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80200c:	01 de                	add    %ebx,%esi
  80200e:	83 c4 10             	add    $0x10,%esp
  802011:	89 f0                	mov    %esi,%eax
  802013:	3b 75 10             	cmp    0x10(%ebp),%esi
  802016:	72 cc                	jb     801fe4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802018:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80201b:	5b                   	pop    %ebx
  80201c:	5e                   	pop    %esi
  80201d:	5f                   	pop    %edi
  80201e:	5d                   	pop    %ebp
  80201f:	c3                   	ret    

00802020 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	83 ec 08             	sub    $0x8,%esp
  802026:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80202b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80202f:	74 2a                	je     80205b <devcons_read+0x3b>
  802031:	eb 05                	jmp    802038 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802033:	e8 1d ec ff ff       	call   800c55 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802038:	e8 99 eb ff ff       	call   800bd6 <sys_cgetc>
  80203d:	85 c0                	test   %eax,%eax
  80203f:	74 f2                	je     802033 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802041:	85 c0                	test   %eax,%eax
  802043:	78 16                	js     80205b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802045:	83 f8 04             	cmp    $0x4,%eax
  802048:	74 0c                	je     802056 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80204a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80204d:	88 02                	mov    %al,(%edx)
	return 1;
  80204f:	b8 01 00 00 00       	mov    $0x1,%eax
  802054:	eb 05                	jmp    80205b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802056:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80205b:	c9                   	leave  
  80205c:	c3                   	ret    

0080205d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  80205d:	55                   	push   %ebp
  80205e:	89 e5                	mov    %esp,%ebp
  802060:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802063:	8b 45 08             	mov    0x8(%ebp),%eax
  802066:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802069:	6a 01                	push   $0x1
  80206b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80206e:	50                   	push   %eax
  80206f:	e8 44 eb ff ff       	call   800bb8 <sys_cputs>
}
  802074:	83 c4 10             	add    $0x10,%esp
  802077:	c9                   	leave  
  802078:	c3                   	ret    

00802079 <getchar>:

int
getchar(void)
{
  802079:	55                   	push   %ebp
  80207a:	89 e5                	mov    %esp,%ebp
  80207c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80207f:	6a 01                	push   $0x1
  802081:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802084:	50                   	push   %eax
  802085:	6a 00                	push   $0x0
  802087:	e8 b5 f0 ff ff       	call   801141 <read>
	if (r < 0)
  80208c:	83 c4 10             	add    $0x10,%esp
  80208f:	85 c0                	test   %eax,%eax
  802091:	78 0f                	js     8020a2 <getchar+0x29>
		return r;
	if (r < 1)
  802093:	85 c0                	test   %eax,%eax
  802095:	7e 06                	jle    80209d <getchar+0x24>
		return -E_EOF;
	return c;
  802097:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80209b:	eb 05                	jmp    8020a2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80209d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020a2:	c9                   	leave  
  8020a3:	c3                   	ret    

008020a4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020a4:	55                   	push   %ebp
  8020a5:	89 e5                	mov    %esp,%ebp
  8020a7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ad:	50                   	push   %eax
  8020ae:	ff 75 08             	pushl  0x8(%ebp)
  8020b1:	e8 25 ee ff ff       	call   800edb <fd_lookup>
  8020b6:	83 c4 10             	add    $0x10,%esp
  8020b9:	85 c0                	test   %eax,%eax
  8020bb:	78 11                	js     8020ce <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020c6:	39 10                	cmp    %edx,(%eax)
  8020c8:	0f 94 c0             	sete   %al
  8020cb:	0f b6 c0             	movzbl %al,%eax
}
  8020ce:	c9                   	leave  
  8020cf:	c3                   	ret    

008020d0 <opencons>:

int
opencons(void)
{
  8020d0:	55                   	push   %ebp
  8020d1:	89 e5                	mov    %esp,%ebp
  8020d3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d9:	50                   	push   %eax
  8020da:	e8 ad ed ff ff       	call   800e8c <fd_alloc>
  8020df:	83 c4 10             	add    $0x10,%esp
		return r;
  8020e2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020e4:	85 c0                	test   %eax,%eax
  8020e6:	78 3e                	js     802126 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020e8:	83 ec 04             	sub    $0x4,%esp
  8020eb:	68 07 04 00 00       	push   $0x407
  8020f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8020f3:	6a 00                	push   $0x0
  8020f5:	e8 7a eb ff ff       	call   800c74 <sys_page_alloc>
  8020fa:	83 c4 10             	add    $0x10,%esp
		return r;
  8020fd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020ff:	85 c0                	test   %eax,%eax
  802101:	78 23                	js     802126 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802103:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802109:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80210c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80210e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802111:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802118:	83 ec 0c             	sub    $0xc,%esp
  80211b:	50                   	push   %eax
  80211c:	e8 44 ed ff ff       	call   800e65 <fd2num>
  802121:	89 c2                	mov    %eax,%edx
  802123:	83 c4 10             	add    $0x10,%esp
}
  802126:	89 d0                	mov    %edx,%eax
  802128:	c9                   	leave  
  802129:	c3                   	ret    

0080212a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80212a:	55                   	push   %ebp
  80212b:	89 e5                	mov    %esp,%ebp
  80212d:	56                   	push   %esi
  80212e:	53                   	push   %ebx
  80212f:	8b 75 08             	mov    0x8(%ebp),%esi
  802132:	8b 45 0c             	mov    0xc(%ebp),%eax
  802135:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  802138:	85 c0                	test   %eax,%eax
  80213a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80213f:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  802142:	83 ec 0c             	sub    $0xc,%esp
  802145:	50                   	push   %eax
  802146:	e8 d9 ec ff ff       	call   800e24 <sys_ipc_recv>
  80214b:	83 c4 10             	add    $0x10,%esp
  80214e:	85 c0                	test   %eax,%eax
  802150:	79 16                	jns    802168 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  802152:	85 f6                	test   %esi,%esi
  802154:	74 06                	je     80215c <ipc_recv+0x32>
            *from_env_store = 0;
  802156:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  80215c:	85 db                	test   %ebx,%ebx
  80215e:	74 2c                	je     80218c <ipc_recv+0x62>
            *perm_store = 0;
  802160:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802166:	eb 24                	jmp    80218c <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  802168:	85 f6                	test   %esi,%esi
  80216a:	74 0a                	je     802176 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  80216c:	a1 04 40 80 00       	mov    0x804004,%eax
  802171:	8b 40 74             	mov    0x74(%eax),%eax
  802174:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  802176:	85 db                	test   %ebx,%ebx
  802178:	74 0a                	je     802184 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  80217a:	a1 04 40 80 00       	mov    0x804004,%eax
  80217f:	8b 40 78             	mov    0x78(%eax),%eax
  802182:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  802184:	a1 04 40 80 00       	mov    0x804004,%eax
  802189:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  80218c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80218f:	5b                   	pop    %ebx
  802190:	5e                   	pop    %esi
  802191:	5d                   	pop    %ebp
  802192:	c3                   	ret    

00802193 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802193:	55                   	push   %ebp
  802194:	89 e5                	mov    %esp,%ebp
  802196:	57                   	push   %edi
  802197:	56                   	push   %esi
  802198:	53                   	push   %ebx
  802199:	83 ec 0c             	sub    $0xc,%esp
  80219c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80219f:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8021a5:	85 c0                	test   %eax,%eax
  8021a7:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8021ac:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  8021af:	eb 1c                	jmp    8021cd <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  8021b1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021b4:	74 12                	je     8021c8 <ipc_send+0x35>
  8021b6:	50                   	push   %eax
  8021b7:	68 cb 2a 80 00       	push   $0x802acb
  8021bc:	6a 3a                	push   $0x3a
  8021be:	68 e1 2a 80 00       	push   $0x802ae1
  8021c3:	e8 cc df ff ff       	call   800194 <_panic>
		sys_yield();
  8021c8:	e8 88 ea ff ff       	call   800c55 <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  8021cd:	ff 75 14             	pushl  0x14(%ebp)
  8021d0:	53                   	push   %ebx
  8021d1:	56                   	push   %esi
  8021d2:	57                   	push   %edi
  8021d3:	e8 29 ec ff ff       	call   800e01 <sys_ipc_try_send>
  8021d8:	83 c4 10             	add    $0x10,%esp
  8021db:	85 c0                	test   %eax,%eax
  8021dd:	78 d2                	js     8021b1 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  8021df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021e2:	5b                   	pop    %ebx
  8021e3:	5e                   	pop    %esi
  8021e4:	5f                   	pop    %edi
  8021e5:	5d                   	pop    %ebp
  8021e6:	c3                   	ret    

008021e7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021e7:	55                   	push   %ebp
  8021e8:	89 e5                	mov    %esp,%ebp
  8021ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021ed:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021f2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8021f5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021fb:	8b 52 50             	mov    0x50(%edx),%edx
  8021fe:	39 ca                	cmp    %ecx,%edx
  802200:	75 0d                	jne    80220f <ipc_find_env+0x28>
			return envs[i].env_id;
  802202:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802205:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80220a:	8b 40 48             	mov    0x48(%eax),%eax
  80220d:	eb 0f                	jmp    80221e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80220f:	83 c0 01             	add    $0x1,%eax
  802212:	3d 00 04 00 00       	cmp    $0x400,%eax
  802217:	75 d9                	jne    8021f2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802219:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80221e:	5d                   	pop    %ebp
  80221f:	c3                   	ret    

00802220 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802220:	55                   	push   %ebp
  802221:	89 e5                	mov    %esp,%ebp
  802223:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802226:	89 d0                	mov    %edx,%eax
  802228:	c1 e8 16             	shr    $0x16,%eax
  80222b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802232:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802237:	f6 c1 01             	test   $0x1,%cl
  80223a:	74 1d                	je     802259 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80223c:	c1 ea 0c             	shr    $0xc,%edx
  80223f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802246:	f6 c2 01             	test   $0x1,%dl
  802249:	74 0e                	je     802259 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80224b:	c1 ea 0c             	shr    $0xc,%edx
  80224e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802255:	ef 
  802256:	0f b7 c0             	movzwl %ax,%eax
}
  802259:	5d                   	pop    %ebp
  80225a:	c3                   	ret    
  80225b:	66 90                	xchg   %ax,%ax
  80225d:	66 90                	xchg   %ax,%ax
  80225f:	90                   	nop

00802260 <__udivdi3>:
  802260:	55                   	push   %ebp
  802261:	57                   	push   %edi
  802262:	56                   	push   %esi
  802263:	53                   	push   %ebx
  802264:	83 ec 1c             	sub    $0x1c,%esp
  802267:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80226b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80226f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802273:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802277:	85 f6                	test   %esi,%esi
  802279:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80227d:	89 ca                	mov    %ecx,%edx
  80227f:	89 f8                	mov    %edi,%eax
  802281:	75 3d                	jne    8022c0 <__udivdi3+0x60>
  802283:	39 cf                	cmp    %ecx,%edi
  802285:	0f 87 c5 00 00 00    	ja     802350 <__udivdi3+0xf0>
  80228b:	85 ff                	test   %edi,%edi
  80228d:	89 fd                	mov    %edi,%ebp
  80228f:	75 0b                	jne    80229c <__udivdi3+0x3c>
  802291:	b8 01 00 00 00       	mov    $0x1,%eax
  802296:	31 d2                	xor    %edx,%edx
  802298:	f7 f7                	div    %edi
  80229a:	89 c5                	mov    %eax,%ebp
  80229c:	89 c8                	mov    %ecx,%eax
  80229e:	31 d2                	xor    %edx,%edx
  8022a0:	f7 f5                	div    %ebp
  8022a2:	89 c1                	mov    %eax,%ecx
  8022a4:	89 d8                	mov    %ebx,%eax
  8022a6:	89 cf                	mov    %ecx,%edi
  8022a8:	f7 f5                	div    %ebp
  8022aa:	89 c3                	mov    %eax,%ebx
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
  8022c0:	39 ce                	cmp    %ecx,%esi
  8022c2:	77 74                	ja     802338 <__udivdi3+0xd8>
  8022c4:	0f bd fe             	bsr    %esi,%edi
  8022c7:	83 f7 1f             	xor    $0x1f,%edi
  8022ca:	0f 84 98 00 00 00    	je     802368 <__udivdi3+0x108>
  8022d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8022d5:	89 f9                	mov    %edi,%ecx
  8022d7:	89 c5                	mov    %eax,%ebp
  8022d9:	29 fb                	sub    %edi,%ebx
  8022db:	d3 e6                	shl    %cl,%esi
  8022dd:	89 d9                	mov    %ebx,%ecx
  8022df:	d3 ed                	shr    %cl,%ebp
  8022e1:	89 f9                	mov    %edi,%ecx
  8022e3:	d3 e0                	shl    %cl,%eax
  8022e5:	09 ee                	or     %ebp,%esi
  8022e7:	89 d9                	mov    %ebx,%ecx
  8022e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022ed:	89 d5                	mov    %edx,%ebp
  8022ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022f3:	d3 ed                	shr    %cl,%ebp
  8022f5:	89 f9                	mov    %edi,%ecx
  8022f7:	d3 e2                	shl    %cl,%edx
  8022f9:	89 d9                	mov    %ebx,%ecx
  8022fb:	d3 e8                	shr    %cl,%eax
  8022fd:	09 c2                	or     %eax,%edx
  8022ff:	89 d0                	mov    %edx,%eax
  802301:	89 ea                	mov    %ebp,%edx
  802303:	f7 f6                	div    %esi
  802305:	89 d5                	mov    %edx,%ebp
  802307:	89 c3                	mov    %eax,%ebx
  802309:	f7 64 24 0c          	mull   0xc(%esp)
  80230d:	39 d5                	cmp    %edx,%ebp
  80230f:	72 10                	jb     802321 <__udivdi3+0xc1>
  802311:	8b 74 24 08          	mov    0x8(%esp),%esi
  802315:	89 f9                	mov    %edi,%ecx
  802317:	d3 e6                	shl    %cl,%esi
  802319:	39 c6                	cmp    %eax,%esi
  80231b:	73 07                	jae    802324 <__udivdi3+0xc4>
  80231d:	39 d5                	cmp    %edx,%ebp
  80231f:	75 03                	jne    802324 <__udivdi3+0xc4>
  802321:	83 eb 01             	sub    $0x1,%ebx
  802324:	31 ff                	xor    %edi,%edi
  802326:	89 d8                	mov    %ebx,%eax
  802328:	89 fa                	mov    %edi,%edx
  80232a:	83 c4 1c             	add    $0x1c,%esp
  80232d:	5b                   	pop    %ebx
  80232e:	5e                   	pop    %esi
  80232f:	5f                   	pop    %edi
  802330:	5d                   	pop    %ebp
  802331:	c3                   	ret    
  802332:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802338:	31 ff                	xor    %edi,%edi
  80233a:	31 db                	xor    %ebx,%ebx
  80233c:	89 d8                	mov    %ebx,%eax
  80233e:	89 fa                	mov    %edi,%edx
  802340:	83 c4 1c             	add    $0x1c,%esp
  802343:	5b                   	pop    %ebx
  802344:	5e                   	pop    %esi
  802345:	5f                   	pop    %edi
  802346:	5d                   	pop    %ebp
  802347:	c3                   	ret    
  802348:	90                   	nop
  802349:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802350:	89 d8                	mov    %ebx,%eax
  802352:	f7 f7                	div    %edi
  802354:	31 ff                	xor    %edi,%edi
  802356:	89 c3                	mov    %eax,%ebx
  802358:	89 d8                	mov    %ebx,%eax
  80235a:	89 fa                	mov    %edi,%edx
  80235c:	83 c4 1c             	add    $0x1c,%esp
  80235f:	5b                   	pop    %ebx
  802360:	5e                   	pop    %esi
  802361:	5f                   	pop    %edi
  802362:	5d                   	pop    %ebp
  802363:	c3                   	ret    
  802364:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802368:	39 ce                	cmp    %ecx,%esi
  80236a:	72 0c                	jb     802378 <__udivdi3+0x118>
  80236c:	31 db                	xor    %ebx,%ebx
  80236e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802372:	0f 87 34 ff ff ff    	ja     8022ac <__udivdi3+0x4c>
  802378:	bb 01 00 00 00       	mov    $0x1,%ebx
  80237d:	e9 2a ff ff ff       	jmp    8022ac <__udivdi3+0x4c>
  802382:	66 90                	xchg   %ax,%ax
  802384:	66 90                	xchg   %ax,%ax
  802386:	66 90                	xchg   %ax,%ax
  802388:	66 90                	xchg   %ax,%ax
  80238a:	66 90                	xchg   %ax,%ax
  80238c:	66 90                	xchg   %ax,%ax
  80238e:	66 90                	xchg   %ax,%ax

00802390 <__umoddi3>:
  802390:	55                   	push   %ebp
  802391:	57                   	push   %edi
  802392:	56                   	push   %esi
  802393:	53                   	push   %ebx
  802394:	83 ec 1c             	sub    $0x1c,%esp
  802397:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80239b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80239f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023a7:	85 d2                	test   %edx,%edx
  8023a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023b1:	89 f3                	mov    %esi,%ebx
  8023b3:	89 3c 24             	mov    %edi,(%esp)
  8023b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023ba:	75 1c                	jne    8023d8 <__umoddi3+0x48>
  8023bc:	39 f7                	cmp    %esi,%edi
  8023be:	76 50                	jbe    802410 <__umoddi3+0x80>
  8023c0:	89 c8                	mov    %ecx,%eax
  8023c2:	89 f2                	mov    %esi,%edx
  8023c4:	f7 f7                	div    %edi
  8023c6:	89 d0                	mov    %edx,%eax
  8023c8:	31 d2                	xor    %edx,%edx
  8023ca:	83 c4 1c             	add    $0x1c,%esp
  8023cd:	5b                   	pop    %ebx
  8023ce:	5e                   	pop    %esi
  8023cf:	5f                   	pop    %edi
  8023d0:	5d                   	pop    %ebp
  8023d1:	c3                   	ret    
  8023d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023d8:	39 f2                	cmp    %esi,%edx
  8023da:	89 d0                	mov    %edx,%eax
  8023dc:	77 52                	ja     802430 <__umoddi3+0xa0>
  8023de:	0f bd ea             	bsr    %edx,%ebp
  8023e1:	83 f5 1f             	xor    $0x1f,%ebp
  8023e4:	75 5a                	jne    802440 <__umoddi3+0xb0>
  8023e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023ea:	0f 82 e0 00 00 00    	jb     8024d0 <__umoddi3+0x140>
  8023f0:	39 0c 24             	cmp    %ecx,(%esp)
  8023f3:	0f 86 d7 00 00 00    	jbe    8024d0 <__umoddi3+0x140>
  8023f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802401:	83 c4 1c             	add    $0x1c,%esp
  802404:	5b                   	pop    %ebx
  802405:	5e                   	pop    %esi
  802406:	5f                   	pop    %edi
  802407:	5d                   	pop    %ebp
  802408:	c3                   	ret    
  802409:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802410:	85 ff                	test   %edi,%edi
  802412:	89 fd                	mov    %edi,%ebp
  802414:	75 0b                	jne    802421 <__umoddi3+0x91>
  802416:	b8 01 00 00 00       	mov    $0x1,%eax
  80241b:	31 d2                	xor    %edx,%edx
  80241d:	f7 f7                	div    %edi
  80241f:	89 c5                	mov    %eax,%ebp
  802421:	89 f0                	mov    %esi,%eax
  802423:	31 d2                	xor    %edx,%edx
  802425:	f7 f5                	div    %ebp
  802427:	89 c8                	mov    %ecx,%eax
  802429:	f7 f5                	div    %ebp
  80242b:	89 d0                	mov    %edx,%eax
  80242d:	eb 99                	jmp    8023c8 <__umoddi3+0x38>
  80242f:	90                   	nop
  802430:	89 c8                	mov    %ecx,%eax
  802432:	89 f2                	mov    %esi,%edx
  802434:	83 c4 1c             	add    $0x1c,%esp
  802437:	5b                   	pop    %ebx
  802438:	5e                   	pop    %esi
  802439:	5f                   	pop    %edi
  80243a:	5d                   	pop    %ebp
  80243b:	c3                   	ret    
  80243c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802440:	8b 34 24             	mov    (%esp),%esi
  802443:	bf 20 00 00 00       	mov    $0x20,%edi
  802448:	89 e9                	mov    %ebp,%ecx
  80244a:	29 ef                	sub    %ebp,%edi
  80244c:	d3 e0                	shl    %cl,%eax
  80244e:	89 f9                	mov    %edi,%ecx
  802450:	89 f2                	mov    %esi,%edx
  802452:	d3 ea                	shr    %cl,%edx
  802454:	89 e9                	mov    %ebp,%ecx
  802456:	09 c2                	or     %eax,%edx
  802458:	89 d8                	mov    %ebx,%eax
  80245a:	89 14 24             	mov    %edx,(%esp)
  80245d:	89 f2                	mov    %esi,%edx
  80245f:	d3 e2                	shl    %cl,%edx
  802461:	89 f9                	mov    %edi,%ecx
  802463:	89 54 24 04          	mov    %edx,0x4(%esp)
  802467:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80246b:	d3 e8                	shr    %cl,%eax
  80246d:	89 e9                	mov    %ebp,%ecx
  80246f:	89 c6                	mov    %eax,%esi
  802471:	d3 e3                	shl    %cl,%ebx
  802473:	89 f9                	mov    %edi,%ecx
  802475:	89 d0                	mov    %edx,%eax
  802477:	d3 e8                	shr    %cl,%eax
  802479:	89 e9                	mov    %ebp,%ecx
  80247b:	09 d8                	or     %ebx,%eax
  80247d:	89 d3                	mov    %edx,%ebx
  80247f:	89 f2                	mov    %esi,%edx
  802481:	f7 34 24             	divl   (%esp)
  802484:	89 d6                	mov    %edx,%esi
  802486:	d3 e3                	shl    %cl,%ebx
  802488:	f7 64 24 04          	mull   0x4(%esp)
  80248c:	39 d6                	cmp    %edx,%esi
  80248e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802492:	89 d1                	mov    %edx,%ecx
  802494:	89 c3                	mov    %eax,%ebx
  802496:	72 08                	jb     8024a0 <__umoddi3+0x110>
  802498:	75 11                	jne    8024ab <__umoddi3+0x11b>
  80249a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80249e:	73 0b                	jae    8024ab <__umoddi3+0x11b>
  8024a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8024a4:	1b 14 24             	sbb    (%esp),%edx
  8024a7:	89 d1                	mov    %edx,%ecx
  8024a9:	89 c3                	mov    %eax,%ebx
  8024ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8024af:	29 da                	sub    %ebx,%edx
  8024b1:	19 ce                	sbb    %ecx,%esi
  8024b3:	89 f9                	mov    %edi,%ecx
  8024b5:	89 f0                	mov    %esi,%eax
  8024b7:	d3 e0                	shl    %cl,%eax
  8024b9:	89 e9                	mov    %ebp,%ecx
  8024bb:	d3 ea                	shr    %cl,%edx
  8024bd:	89 e9                	mov    %ebp,%ecx
  8024bf:	d3 ee                	shr    %cl,%esi
  8024c1:	09 d0                	or     %edx,%eax
  8024c3:	89 f2                	mov    %esi,%edx
  8024c5:	83 c4 1c             	add    $0x1c,%esp
  8024c8:	5b                   	pop    %ebx
  8024c9:	5e                   	pop    %esi
  8024ca:	5f                   	pop    %edi
  8024cb:	5d                   	pop    %ebp
  8024cc:	c3                   	ret    
  8024cd:	8d 76 00             	lea    0x0(%esi),%esi
  8024d0:	29 f9                	sub    %edi,%ecx
  8024d2:	19 d6                	sbb    %edx,%esi
  8024d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024dc:	e9 18 ff ff ff       	jmp    8023f9 <__umoddi3+0x69>
