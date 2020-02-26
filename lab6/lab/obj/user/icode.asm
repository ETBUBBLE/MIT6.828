
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
  80003e:	c7 05 00 30 80 00 a0 	movl   $0x8029a0,0x803000
  800045:	29 80 00 

	cprintf("icode startup\n");
  800048:	68 a6 29 80 00       	push   $0x8029a6
  80004d:	e8 1b 02 00 00       	call   80026d <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 b5 29 80 00 	movl   $0x8029b5,(%esp)
  800059:	e8 0f 02 00 00       	call   80026d <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 c8 29 80 00       	push   $0x8029c8
  800068:	e8 9e 15 00 00       	call   80160b <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 ce 29 80 00       	push   $0x8029ce
  80007c:	6a 0f                	push   $0xf
  80007e:	68 e4 29 80 00       	push   $0x8029e4
  800083:	e8 0c 01 00 00       	call   800194 <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 f1 29 80 00       	push   $0x8029f1
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
  8000b7:	e8 c4 10 00 00       	call   801180 <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);
	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 04 2a 80 00       	push   $0x802a04
  8000cb:	e8 9d 01 00 00       	call   80026d <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 6c 0f 00 00       	call   801044 <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 18 2a 80 00 	movl   $0x802a18,(%esp)
  8000df:	e8 89 01 00 00       	call   80026d <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 2c 2a 80 00       	push   $0x802a2c
  8000f0:	68 35 2a 80 00       	push   $0x802a35
  8000f5:	68 3f 2a 80 00       	push   $0x802a3f
  8000fa:	68 3e 2a 80 00       	push   $0x802a3e
  8000ff:	e8 13 1b 00 00       	call   801c17 <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 44 2a 80 00       	push   $0x802a44
  800111:	6a 19                	push   $0x19
  800113:	68 e4 29 80 00       	push   $0x8029e4
  800118:	e8 77 00 00 00       	call   800194 <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 5b 2a 80 00       	push   $0x802a5b
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
  800151:	a3 08 40 80 00       	mov    %eax,0x804008

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
  800180:	e8 ea 0e 00 00       	call   80106f <close_all>
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
  8001b2:	68 78 2a 80 00       	push   $0x802a78
  8001b7:	e8 b1 00 00 00       	call   80026d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	53                   	push   %ebx
  8001c0:	ff 75 10             	pushl  0x10(%ebp)
  8001c3:	e8 54 00 00 00       	call   80021c <vcprintf>
	cprintf("\n");
  8001c8:	c7 04 24 95 2f 80 00 	movl   $0x802f95,(%esp)
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
  8002d0:	e8 3b 24 00 00       	call   802710 <__udivdi3>
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
  800313:	e8 28 25 00 00       	call   802840 <__umoddi3>
  800318:	83 c4 14             	add    $0x14,%esp
  80031b:	0f be 80 9b 2a 80 00 	movsbl 0x802a9b(%eax),%eax
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
  8003dd:	ff 24 85 e0 2b 80 00 	jmp    *0x802be0(,%eax,4)
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
  8004a4:	8b 14 85 40 2d 80 00 	mov    0x802d40(,%eax,4),%edx
  8004ab:	85 d2                	test   %edx,%edx
  8004ad:	75 1b                	jne    8004ca <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8004af:	50                   	push   %eax
  8004b0:	68 b3 2a 80 00       	push   $0x802ab3
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
  8004cb:	68 75 2e 80 00       	push   $0x802e75
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
  8004f5:	b8 ac 2a 80 00       	mov    $0x802aac,%eax
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
  800c1d:	68 9f 2d 80 00       	push   $0x802d9f
  800c22:	6a 23                	push   $0x23
  800c24:	68 bc 2d 80 00       	push   $0x802dbc
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
  800c9e:	68 9f 2d 80 00       	push   $0x802d9f
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 bc 2d 80 00       	push   $0x802dbc
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
  800ce0:	68 9f 2d 80 00       	push   $0x802d9f
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 bc 2d 80 00       	push   $0x802dbc
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
  800d22:	68 9f 2d 80 00       	push   $0x802d9f
  800d27:	6a 23                	push   $0x23
  800d29:	68 bc 2d 80 00       	push   $0x802dbc
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
  800d64:	68 9f 2d 80 00       	push   $0x802d9f
  800d69:	6a 23                	push   $0x23
  800d6b:	68 bc 2d 80 00       	push   $0x802dbc
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
  800da6:	68 9f 2d 80 00       	push   $0x802d9f
  800dab:	6a 23                	push   $0x23
  800dad:	68 bc 2d 80 00       	push   $0x802dbc
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
  800de8:	68 9f 2d 80 00       	push   $0x802d9f
  800ded:	6a 23                	push   $0x23
  800def:	68 bc 2d 80 00       	push   $0x802dbc
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
  800e4c:	68 9f 2d 80 00       	push   $0x802d9f
  800e51:	6a 23                	push   $0x23
  800e53:	68 bc 2d 80 00       	push   $0x802dbc
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

00800e65 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	57                   	push   %edi
  800e69:	56                   	push   %esi
  800e6a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e70:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e75:	89 d1                	mov    %edx,%ecx
  800e77:	89 d3                	mov    %edx,%ebx
  800e79:	89 d7                	mov    %edx,%edi
  800e7b:	89 d6                	mov    %edx,%esi
  800e7d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5f                   	pop    %edi
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	57                   	push   %edi
  800e88:	56                   	push   %esi
  800e89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e8f:	b8 10 00 00 00       	mov    $0x10,%eax
  800e94:	8b 55 08             	mov    0x8(%ebp),%edx
  800e97:	89 cb                	mov    %ecx,%ebx
  800e99:	89 cf                	mov    %ecx,%edi
  800e9b:	89 ce                	mov    %ecx,%esi
  800e9d:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800e9f:	5b                   	pop    %ebx
  800ea0:	5e                   	pop    %esi
  800ea1:	5f                   	pop    %edi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ea7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eaa:	05 00 00 00 30       	add    $0x30000000,%eax
  800eaf:	c1 e8 0c             	shr    $0xc,%eax
}
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eba:	05 00 00 00 30       	add    $0x30000000,%eax
  800ebf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ec4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ed6:	89 c2                	mov    %eax,%edx
  800ed8:	c1 ea 16             	shr    $0x16,%edx
  800edb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ee2:	f6 c2 01             	test   $0x1,%dl
  800ee5:	74 11                	je     800ef8 <fd_alloc+0x2d>
  800ee7:	89 c2                	mov    %eax,%edx
  800ee9:	c1 ea 0c             	shr    $0xc,%edx
  800eec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef3:	f6 c2 01             	test   $0x1,%dl
  800ef6:	75 09                	jne    800f01 <fd_alloc+0x36>
			*fd_store = fd;
  800ef8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800efa:	b8 00 00 00 00       	mov    $0x0,%eax
  800eff:	eb 17                	jmp    800f18 <fd_alloc+0x4d>
  800f01:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f06:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f0b:	75 c9                	jne    800ed6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f0d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f13:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f20:	83 f8 1f             	cmp    $0x1f,%eax
  800f23:	77 36                	ja     800f5b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f25:	c1 e0 0c             	shl    $0xc,%eax
  800f28:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f2d:	89 c2                	mov    %eax,%edx
  800f2f:	c1 ea 16             	shr    $0x16,%edx
  800f32:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f39:	f6 c2 01             	test   $0x1,%dl
  800f3c:	74 24                	je     800f62 <fd_lookup+0x48>
  800f3e:	89 c2                	mov    %eax,%edx
  800f40:	c1 ea 0c             	shr    $0xc,%edx
  800f43:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f4a:	f6 c2 01             	test   $0x1,%dl
  800f4d:	74 1a                	je     800f69 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f4f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f52:	89 02                	mov    %eax,(%edx)
	return 0;
  800f54:	b8 00 00 00 00       	mov    $0x0,%eax
  800f59:	eb 13                	jmp    800f6e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f5b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f60:	eb 0c                	jmp    800f6e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f62:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f67:	eb 05                	jmp    800f6e <fd_lookup+0x54>
  800f69:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f6e:	5d                   	pop    %ebp
  800f6f:	c3                   	ret    

00800f70 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	83 ec 08             	sub    $0x8,%esp
  800f76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f79:	ba 48 2e 80 00       	mov    $0x802e48,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f7e:	eb 13                	jmp    800f93 <dev_lookup+0x23>
  800f80:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f83:	39 08                	cmp    %ecx,(%eax)
  800f85:	75 0c                	jne    800f93 <dev_lookup+0x23>
			*dev = devtab[i];
  800f87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f8a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f91:	eb 2e                	jmp    800fc1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f93:	8b 02                	mov    (%edx),%eax
  800f95:	85 c0                	test   %eax,%eax
  800f97:	75 e7                	jne    800f80 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f99:	a1 08 40 80 00       	mov    0x804008,%eax
  800f9e:	8b 40 48             	mov    0x48(%eax),%eax
  800fa1:	83 ec 04             	sub    $0x4,%esp
  800fa4:	51                   	push   %ecx
  800fa5:	50                   	push   %eax
  800fa6:	68 cc 2d 80 00       	push   $0x802dcc
  800fab:	e8 bd f2 ff ff       	call   80026d <cprintf>
	*dev = 0;
  800fb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fb9:	83 c4 10             	add    $0x10,%esp
  800fbc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fc1:	c9                   	leave  
  800fc2:	c3                   	ret    

00800fc3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fc3:	55                   	push   %ebp
  800fc4:	89 e5                	mov    %esp,%ebp
  800fc6:	56                   	push   %esi
  800fc7:	53                   	push   %ebx
  800fc8:	83 ec 10             	sub    $0x10,%esp
  800fcb:	8b 75 08             	mov    0x8(%ebp),%esi
  800fce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fd1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd4:	50                   	push   %eax
  800fd5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fdb:	c1 e8 0c             	shr    $0xc,%eax
  800fde:	50                   	push   %eax
  800fdf:	e8 36 ff ff ff       	call   800f1a <fd_lookup>
  800fe4:	83 c4 08             	add    $0x8,%esp
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	78 05                	js     800ff0 <fd_close+0x2d>
	    || fd != fd2)
  800feb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fee:	74 0c                	je     800ffc <fd_close+0x39>
		return (must_exist ? r : 0);
  800ff0:	84 db                	test   %bl,%bl
  800ff2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff7:	0f 44 c2             	cmove  %edx,%eax
  800ffa:	eb 41                	jmp    80103d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ffc:	83 ec 08             	sub    $0x8,%esp
  800fff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801002:	50                   	push   %eax
  801003:	ff 36                	pushl  (%esi)
  801005:	e8 66 ff ff ff       	call   800f70 <dev_lookup>
  80100a:	89 c3                	mov    %eax,%ebx
  80100c:	83 c4 10             	add    $0x10,%esp
  80100f:	85 c0                	test   %eax,%eax
  801011:	78 1a                	js     80102d <fd_close+0x6a>
		if (dev->dev_close)
  801013:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801016:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801019:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80101e:	85 c0                	test   %eax,%eax
  801020:	74 0b                	je     80102d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801022:	83 ec 0c             	sub    $0xc,%esp
  801025:	56                   	push   %esi
  801026:	ff d0                	call   *%eax
  801028:	89 c3                	mov    %eax,%ebx
  80102a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80102d:	83 ec 08             	sub    $0x8,%esp
  801030:	56                   	push   %esi
  801031:	6a 00                	push   $0x0
  801033:	e8 c1 fc ff ff       	call   800cf9 <sys_page_unmap>
	return r;
  801038:	83 c4 10             	add    $0x10,%esp
  80103b:	89 d8                	mov    %ebx,%eax
}
  80103d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801040:	5b                   	pop    %ebx
  801041:	5e                   	pop    %esi
  801042:	5d                   	pop    %ebp
  801043:	c3                   	ret    

00801044 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80104a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80104d:	50                   	push   %eax
  80104e:	ff 75 08             	pushl  0x8(%ebp)
  801051:	e8 c4 fe ff ff       	call   800f1a <fd_lookup>
  801056:	83 c4 08             	add    $0x8,%esp
  801059:	85 c0                	test   %eax,%eax
  80105b:	78 10                	js     80106d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80105d:	83 ec 08             	sub    $0x8,%esp
  801060:	6a 01                	push   $0x1
  801062:	ff 75 f4             	pushl  -0xc(%ebp)
  801065:	e8 59 ff ff ff       	call   800fc3 <fd_close>
  80106a:	83 c4 10             	add    $0x10,%esp
}
  80106d:	c9                   	leave  
  80106e:	c3                   	ret    

0080106f <close_all>:

void
close_all(void)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	53                   	push   %ebx
  801073:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801076:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80107b:	83 ec 0c             	sub    $0xc,%esp
  80107e:	53                   	push   %ebx
  80107f:	e8 c0 ff ff ff       	call   801044 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801084:	83 c3 01             	add    $0x1,%ebx
  801087:	83 c4 10             	add    $0x10,%esp
  80108a:	83 fb 20             	cmp    $0x20,%ebx
  80108d:	75 ec                	jne    80107b <close_all+0xc>
		close(i);
}
  80108f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801092:	c9                   	leave  
  801093:	c3                   	ret    

00801094 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	57                   	push   %edi
  801098:	56                   	push   %esi
  801099:	53                   	push   %ebx
  80109a:	83 ec 2c             	sub    $0x2c,%esp
  80109d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010a0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010a3:	50                   	push   %eax
  8010a4:	ff 75 08             	pushl  0x8(%ebp)
  8010a7:	e8 6e fe ff ff       	call   800f1a <fd_lookup>
  8010ac:	83 c4 08             	add    $0x8,%esp
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	0f 88 c1 00 00 00    	js     801178 <dup+0xe4>
		return r;
	close(newfdnum);
  8010b7:	83 ec 0c             	sub    $0xc,%esp
  8010ba:	56                   	push   %esi
  8010bb:	e8 84 ff ff ff       	call   801044 <close>

	newfd = INDEX2FD(newfdnum);
  8010c0:	89 f3                	mov    %esi,%ebx
  8010c2:	c1 e3 0c             	shl    $0xc,%ebx
  8010c5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010cb:	83 c4 04             	add    $0x4,%esp
  8010ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d1:	e8 de fd ff ff       	call   800eb4 <fd2data>
  8010d6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010d8:	89 1c 24             	mov    %ebx,(%esp)
  8010db:	e8 d4 fd ff ff       	call   800eb4 <fd2data>
  8010e0:	83 c4 10             	add    $0x10,%esp
  8010e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010e6:	89 f8                	mov    %edi,%eax
  8010e8:	c1 e8 16             	shr    $0x16,%eax
  8010eb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010f2:	a8 01                	test   $0x1,%al
  8010f4:	74 37                	je     80112d <dup+0x99>
  8010f6:	89 f8                	mov    %edi,%eax
  8010f8:	c1 e8 0c             	shr    $0xc,%eax
  8010fb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801102:	f6 c2 01             	test   $0x1,%dl
  801105:	74 26                	je     80112d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801107:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80110e:	83 ec 0c             	sub    $0xc,%esp
  801111:	25 07 0e 00 00       	and    $0xe07,%eax
  801116:	50                   	push   %eax
  801117:	ff 75 d4             	pushl  -0x2c(%ebp)
  80111a:	6a 00                	push   $0x0
  80111c:	57                   	push   %edi
  80111d:	6a 00                	push   $0x0
  80111f:	e8 93 fb ff ff       	call   800cb7 <sys_page_map>
  801124:	89 c7                	mov    %eax,%edi
  801126:	83 c4 20             	add    $0x20,%esp
  801129:	85 c0                	test   %eax,%eax
  80112b:	78 2e                	js     80115b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80112d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801130:	89 d0                	mov    %edx,%eax
  801132:	c1 e8 0c             	shr    $0xc,%eax
  801135:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80113c:	83 ec 0c             	sub    $0xc,%esp
  80113f:	25 07 0e 00 00       	and    $0xe07,%eax
  801144:	50                   	push   %eax
  801145:	53                   	push   %ebx
  801146:	6a 00                	push   $0x0
  801148:	52                   	push   %edx
  801149:	6a 00                	push   $0x0
  80114b:	e8 67 fb ff ff       	call   800cb7 <sys_page_map>
  801150:	89 c7                	mov    %eax,%edi
  801152:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801155:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801157:	85 ff                	test   %edi,%edi
  801159:	79 1d                	jns    801178 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80115b:	83 ec 08             	sub    $0x8,%esp
  80115e:	53                   	push   %ebx
  80115f:	6a 00                	push   $0x0
  801161:	e8 93 fb ff ff       	call   800cf9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801166:	83 c4 08             	add    $0x8,%esp
  801169:	ff 75 d4             	pushl  -0x2c(%ebp)
  80116c:	6a 00                	push   $0x0
  80116e:	e8 86 fb ff ff       	call   800cf9 <sys_page_unmap>
	return r;
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	89 f8                	mov    %edi,%eax
}
  801178:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117b:	5b                   	pop    %ebx
  80117c:	5e                   	pop    %esi
  80117d:	5f                   	pop    %edi
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    

00801180 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	53                   	push   %ebx
  801184:	83 ec 14             	sub    $0x14,%esp
  801187:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80118a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80118d:	50                   	push   %eax
  80118e:	53                   	push   %ebx
  80118f:	e8 86 fd ff ff       	call   800f1a <fd_lookup>
  801194:	83 c4 08             	add    $0x8,%esp
  801197:	89 c2                	mov    %eax,%edx
  801199:	85 c0                	test   %eax,%eax
  80119b:	78 6d                	js     80120a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119d:	83 ec 08             	sub    $0x8,%esp
  8011a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a3:	50                   	push   %eax
  8011a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a7:	ff 30                	pushl  (%eax)
  8011a9:	e8 c2 fd ff ff       	call   800f70 <dev_lookup>
  8011ae:	83 c4 10             	add    $0x10,%esp
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	78 4c                	js     801201 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011b5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011b8:	8b 42 08             	mov    0x8(%edx),%eax
  8011bb:	83 e0 03             	and    $0x3,%eax
  8011be:	83 f8 01             	cmp    $0x1,%eax
  8011c1:	75 21                	jne    8011e4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011c3:	a1 08 40 80 00       	mov    0x804008,%eax
  8011c8:	8b 40 48             	mov    0x48(%eax),%eax
  8011cb:	83 ec 04             	sub    $0x4,%esp
  8011ce:	53                   	push   %ebx
  8011cf:	50                   	push   %eax
  8011d0:	68 0d 2e 80 00       	push   $0x802e0d
  8011d5:	e8 93 f0 ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  8011da:	83 c4 10             	add    $0x10,%esp
  8011dd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011e2:	eb 26                	jmp    80120a <read+0x8a>
	}
	if (!dev->dev_read)
  8011e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e7:	8b 40 08             	mov    0x8(%eax),%eax
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	74 17                	je     801205 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011ee:	83 ec 04             	sub    $0x4,%esp
  8011f1:	ff 75 10             	pushl  0x10(%ebp)
  8011f4:	ff 75 0c             	pushl  0xc(%ebp)
  8011f7:	52                   	push   %edx
  8011f8:	ff d0                	call   *%eax
  8011fa:	89 c2                	mov    %eax,%edx
  8011fc:	83 c4 10             	add    $0x10,%esp
  8011ff:	eb 09                	jmp    80120a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801201:	89 c2                	mov    %eax,%edx
  801203:	eb 05                	jmp    80120a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801205:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80120a:	89 d0                	mov    %edx,%eax
  80120c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80120f:	c9                   	leave  
  801210:	c3                   	ret    

00801211 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	57                   	push   %edi
  801215:	56                   	push   %esi
  801216:	53                   	push   %ebx
  801217:	83 ec 0c             	sub    $0xc,%esp
  80121a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80121d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801220:	bb 00 00 00 00       	mov    $0x0,%ebx
  801225:	eb 21                	jmp    801248 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801227:	83 ec 04             	sub    $0x4,%esp
  80122a:	89 f0                	mov    %esi,%eax
  80122c:	29 d8                	sub    %ebx,%eax
  80122e:	50                   	push   %eax
  80122f:	89 d8                	mov    %ebx,%eax
  801231:	03 45 0c             	add    0xc(%ebp),%eax
  801234:	50                   	push   %eax
  801235:	57                   	push   %edi
  801236:	e8 45 ff ff ff       	call   801180 <read>
		if (m < 0)
  80123b:	83 c4 10             	add    $0x10,%esp
  80123e:	85 c0                	test   %eax,%eax
  801240:	78 10                	js     801252 <readn+0x41>
			return m;
		if (m == 0)
  801242:	85 c0                	test   %eax,%eax
  801244:	74 0a                	je     801250 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801246:	01 c3                	add    %eax,%ebx
  801248:	39 f3                	cmp    %esi,%ebx
  80124a:	72 db                	jb     801227 <readn+0x16>
  80124c:	89 d8                	mov    %ebx,%eax
  80124e:	eb 02                	jmp    801252 <readn+0x41>
  801250:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801252:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801255:	5b                   	pop    %ebx
  801256:	5e                   	pop    %esi
  801257:	5f                   	pop    %edi
  801258:	5d                   	pop    %ebp
  801259:	c3                   	ret    

0080125a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	53                   	push   %ebx
  80125e:	83 ec 14             	sub    $0x14,%esp
  801261:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801264:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801267:	50                   	push   %eax
  801268:	53                   	push   %ebx
  801269:	e8 ac fc ff ff       	call   800f1a <fd_lookup>
  80126e:	83 c4 08             	add    $0x8,%esp
  801271:	89 c2                	mov    %eax,%edx
  801273:	85 c0                	test   %eax,%eax
  801275:	78 68                	js     8012df <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801277:	83 ec 08             	sub    $0x8,%esp
  80127a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127d:	50                   	push   %eax
  80127e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801281:	ff 30                	pushl  (%eax)
  801283:	e8 e8 fc ff ff       	call   800f70 <dev_lookup>
  801288:	83 c4 10             	add    $0x10,%esp
  80128b:	85 c0                	test   %eax,%eax
  80128d:	78 47                	js     8012d6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80128f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801292:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801296:	75 21                	jne    8012b9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801298:	a1 08 40 80 00       	mov    0x804008,%eax
  80129d:	8b 40 48             	mov    0x48(%eax),%eax
  8012a0:	83 ec 04             	sub    $0x4,%esp
  8012a3:	53                   	push   %ebx
  8012a4:	50                   	push   %eax
  8012a5:	68 29 2e 80 00       	push   $0x802e29
  8012aa:	e8 be ef ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  8012af:	83 c4 10             	add    $0x10,%esp
  8012b2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012b7:	eb 26                	jmp    8012df <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012bc:	8b 52 0c             	mov    0xc(%edx),%edx
  8012bf:	85 d2                	test   %edx,%edx
  8012c1:	74 17                	je     8012da <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012c3:	83 ec 04             	sub    $0x4,%esp
  8012c6:	ff 75 10             	pushl  0x10(%ebp)
  8012c9:	ff 75 0c             	pushl  0xc(%ebp)
  8012cc:	50                   	push   %eax
  8012cd:	ff d2                	call   *%edx
  8012cf:	89 c2                	mov    %eax,%edx
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	eb 09                	jmp    8012df <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d6:	89 c2                	mov    %eax,%edx
  8012d8:	eb 05                	jmp    8012df <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012da:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012df:	89 d0                	mov    %edx,%eax
  8012e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e4:	c9                   	leave  
  8012e5:	c3                   	ret    

008012e6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ec:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012ef:	50                   	push   %eax
  8012f0:	ff 75 08             	pushl  0x8(%ebp)
  8012f3:	e8 22 fc ff ff       	call   800f1a <fd_lookup>
  8012f8:	83 c4 08             	add    $0x8,%esp
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	78 0e                	js     80130d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801302:	8b 55 0c             	mov    0xc(%ebp),%edx
  801305:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801308:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80130d:	c9                   	leave  
  80130e:	c3                   	ret    

0080130f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	53                   	push   %ebx
  801313:	83 ec 14             	sub    $0x14,%esp
  801316:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801319:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80131c:	50                   	push   %eax
  80131d:	53                   	push   %ebx
  80131e:	e8 f7 fb ff ff       	call   800f1a <fd_lookup>
  801323:	83 c4 08             	add    $0x8,%esp
  801326:	89 c2                	mov    %eax,%edx
  801328:	85 c0                	test   %eax,%eax
  80132a:	78 65                	js     801391 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132c:	83 ec 08             	sub    $0x8,%esp
  80132f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801332:	50                   	push   %eax
  801333:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801336:	ff 30                	pushl  (%eax)
  801338:	e8 33 fc ff ff       	call   800f70 <dev_lookup>
  80133d:	83 c4 10             	add    $0x10,%esp
  801340:	85 c0                	test   %eax,%eax
  801342:	78 44                	js     801388 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801344:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801347:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80134b:	75 21                	jne    80136e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80134d:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801352:	8b 40 48             	mov    0x48(%eax),%eax
  801355:	83 ec 04             	sub    $0x4,%esp
  801358:	53                   	push   %ebx
  801359:	50                   	push   %eax
  80135a:	68 ec 2d 80 00       	push   $0x802dec
  80135f:	e8 09 ef ff ff       	call   80026d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801364:	83 c4 10             	add    $0x10,%esp
  801367:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80136c:	eb 23                	jmp    801391 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80136e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801371:	8b 52 18             	mov    0x18(%edx),%edx
  801374:	85 d2                	test   %edx,%edx
  801376:	74 14                	je     80138c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801378:	83 ec 08             	sub    $0x8,%esp
  80137b:	ff 75 0c             	pushl  0xc(%ebp)
  80137e:	50                   	push   %eax
  80137f:	ff d2                	call   *%edx
  801381:	89 c2                	mov    %eax,%edx
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	eb 09                	jmp    801391 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801388:	89 c2                	mov    %eax,%edx
  80138a:	eb 05                	jmp    801391 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80138c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801391:	89 d0                	mov    %edx,%eax
  801393:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801396:	c9                   	leave  
  801397:	c3                   	ret    

00801398 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	53                   	push   %ebx
  80139c:	83 ec 14             	sub    $0x14,%esp
  80139f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a5:	50                   	push   %eax
  8013a6:	ff 75 08             	pushl  0x8(%ebp)
  8013a9:	e8 6c fb ff ff       	call   800f1a <fd_lookup>
  8013ae:	83 c4 08             	add    $0x8,%esp
  8013b1:	89 c2                	mov    %eax,%edx
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	78 58                	js     80140f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b7:	83 ec 08             	sub    $0x8,%esp
  8013ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bd:	50                   	push   %eax
  8013be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c1:	ff 30                	pushl  (%eax)
  8013c3:	e8 a8 fb ff ff       	call   800f70 <dev_lookup>
  8013c8:	83 c4 10             	add    $0x10,%esp
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	78 37                	js     801406 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013d6:	74 32                	je     80140a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013d8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013db:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013e2:	00 00 00 
	stat->st_isdir = 0;
  8013e5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013ec:	00 00 00 
	stat->st_dev = dev;
  8013ef:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013f5:	83 ec 08             	sub    $0x8,%esp
  8013f8:	53                   	push   %ebx
  8013f9:	ff 75 f0             	pushl  -0x10(%ebp)
  8013fc:	ff 50 14             	call   *0x14(%eax)
  8013ff:	89 c2                	mov    %eax,%edx
  801401:	83 c4 10             	add    $0x10,%esp
  801404:	eb 09                	jmp    80140f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801406:	89 c2                	mov    %eax,%edx
  801408:	eb 05                	jmp    80140f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80140a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80140f:	89 d0                	mov    %edx,%eax
  801411:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801414:	c9                   	leave  
  801415:	c3                   	ret    

00801416 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	56                   	push   %esi
  80141a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80141b:	83 ec 08             	sub    $0x8,%esp
  80141e:	6a 00                	push   $0x0
  801420:	ff 75 08             	pushl  0x8(%ebp)
  801423:	e8 e3 01 00 00       	call   80160b <open>
  801428:	89 c3                	mov    %eax,%ebx
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	85 c0                	test   %eax,%eax
  80142f:	78 1b                	js     80144c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801431:	83 ec 08             	sub    $0x8,%esp
  801434:	ff 75 0c             	pushl  0xc(%ebp)
  801437:	50                   	push   %eax
  801438:	e8 5b ff ff ff       	call   801398 <fstat>
  80143d:	89 c6                	mov    %eax,%esi
	close(fd);
  80143f:	89 1c 24             	mov    %ebx,(%esp)
  801442:	e8 fd fb ff ff       	call   801044 <close>
	return r;
  801447:	83 c4 10             	add    $0x10,%esp
  80144a:	89 f0                	mov    %esi,%eax
}
  80144c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80144f:	5b                   	pop    %ebx
  801450:	5e                   	pop    %esi
  801451:	5d                   	pop    %ebp
  801452:	c3                   	ret    

00801453 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	56                   	push   %esi
  801457:	53                   	push   %ebx
  801458:	89 c6                	mov    %eax,%esi
  80145a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80145c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801463:	75 12                	jne    801477 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801465:	83 ec 0c             	sub    $0xc,%esp
  801468:	6a 01                	push   $0x1
  80146a:	e8 1e 12 00 00       	call   80268d <ipc_find_env>
  80146f:	a3 00 40 80 00       	mov    %eax,0x804000
  801474:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801477:	6a 07                	push   $0x7
  801479:	68 00 50 80 00       	push   $0x805000
  80147e:	56                   	push   %esi
  80147f:	ff 35 00 40 80 00    	pushl  0x804000
  801485:	e8 af 11 00 00       	call   802639 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80148a:	83 c4 0c             	add    $0xc,%esp
  80148d:	6a 00                	push   $0x0
  80148f:	53                   	push   %ebx
  801490:	6a 00                	push   $0x0
  801492:	e8 39 11 00 00       	call   8025d0 <ipc_recv>
}
  801497:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80149a:	5b                   	pop    %ebx
  80149b:	5e                   	pop    %esi
  80149c:	5d                   	pop    %ebp
  80149d:	c3                   	ret    

0080149e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014aa:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014bc:	b8 02 00 00 00       	mov    $0x2,%eax
  8014c1:	e8 8d ff ff ff       	call   801453 <fsipc>
}
  8014c6:	c9                   	leave  
  8014c7:	c3                   	ret    

008014c8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014c8:	55                   	push   %ebp
  8014c9:	89 e5                	mov    %esp,%ebp
  8014cb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014de:	b8 06 00 00 00       	mov    $0x6,%eax
  8014e3:	e8 6b ff ff ff       	call   801453 <fsipc>
}
  8014e8:	c9                   	leave  
  8014e9:	c3                   	ret    

008014ea <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	53                   	push   %ebx
  8014ee:	83 ec 04             	sub    $0x4,%esp
  8014f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014fa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801504:	b8 05 00 00 00       	mov    $0x5,%eax
  801509:	e8 45 ff ff ff       	call   801453 <fsipc>
  80150e:	85 c0                	test   %eax,%eax
  801510:	78 2c                	js     80153e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801512:	83 ec 08             	sub    $0x8,%esp
  801515:	68 00 50 80 00       	push   $0x805000
  80151a:	53                   	push   %ebx
  80151b:	e8 51 f3 ff ff       	call   800871 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801520:	a1 80 50 80 00       	mov    0x805080,%eax
  801525:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80152b:	a1 84 50 80 00       	mov    0x805084,%eax
  801530:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80153e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801541:	c9                   	leave  
  801542:	c3                   	ret    

00801543 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	83 ec 0c             	sub    $0xc,%esp
  801549:	8b 45 10             	mov    0x10(%ebp),%eax
  80154c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801551:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801556:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801559:	8b 55 08             	mov    0x8(%ebp),%edx
  80155c:	8b 52 0c             	mov    0xc(%edx),%edx
  80155f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801565:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80156a:	50                   	push   %eax
  80156b:	ff 75 0c             	pushl  0xc(%ebp)
  80156e:	68 08 50 80 00       	push   $0x805008
  801573:	e8 8b f4 ff ff       	call   800a03 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801578:	ba 00 00 00 00       	mov    $0x0,%edx
  80157d:	b8 04 00 00 00       	mov    $0x4,%eax
  801582:	e8 cc fe ff ff       	call   801453 <fsipc>
	//panic("devfile_write not implemented");
}
  801587:	c9                   	leave  
  801588:	c3                   	ret    

00801589 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801589:	55                   	push   %ebp
  80158a:	89 e5                	mov    %esp,%ebp
  80158c:	56                   	push   %esi
  80158d:	53                   	push   %ebx
  80158e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801591:	8b 45 08             	mov    0x8(%ebp),%eax
  801594:	8b 40 0c             	mov    0xc(%eax),%eax
  801597:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80159c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a7:	b8 03 00 00 00       	mov    $0x3,%eax
  8015ac:	e8 a2 fe ff ff       	call   801453 <fsipc>
  8015b1:	89 c3                	mov    %eax,%ebx
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	78 4b                	js     801602 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015b7:	39 c6                	cmp    %eax,%esi
  8015b9:	73 16                	jae    8015d1 <devfile_read+0x48>
  8015bb:	68 5c 2e 80 00       	push   $0x802e5c
  8015c0:	68 63 2e 80 00       	push   $0x802e63
  8015c5:	6a 7c                	push   $0x7c
  8015c7:	68 78 2e 80 00       	push   $0x802e78
  8015cc:	e8 c3 eb ff ff       	call   800194 <_panic>
	assert(r <= PGSIZE);
  8015d1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015d6:	7e 16                	jle    8015ee <devfile_read+0x65>
  8015d8:	68 83 2e 80 00       	push   $0x802e83
  8015dd:	68 63 2e 80 00       	push   $0x802e63
  8015e2:	6a 7d                	push   $0x7d
  8015e4:	68 78 2e 80 00       	push   $0x802e78
  8015e9:	e8 a6 eb ff ff       	call   800194 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015ee:	83 ec 04             	sub    $0x4,%esp
  8015f1:	50                   	push   %eax
  8015f2:	68 00 50 80 00       	push   $0x805000
  8015f7:	ff 75 0c             	pushl  0xc(%ebp)
  8015fa:	e8 04 f4 ff ff       	call   800a03 <memmove>
	return r;
  8015ff:	83 c4 10             	add    $0x10,%esp
}
  801602:	89 d8                	mov    %ebx,%eax
  801604:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801607:	5b                   	pop    %ebx
  801608:	5e                   	pop    %esi
  801609:	5d                   	pop    %ebp
  80160a:	c3                   	ret    

0080160b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	53                   	push   %ebx
  80160f:	83 ec 20             	sub    $0x20,%esp
  801612:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801615:	53                   	push   %ebx
  801616:	e8 1d f2 ff ff       	call   800838 <strlen>
  80161b:	83 c4 10             	add    $0x10,%esp
  80161e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801623:	7f 67                	jg     80168c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801625:	83 ec 0c             	sub    $0xc,%esp
  801628:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162b:	50                   	push   %eax
  80162c:	e8 9a f8 ff ff       	call   800ecb <fd_alloc>
  801631:	83 c4 10             	add    $0x10,%esp
		return r;
  801634:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801636:	85 c0                	test   %eax,%eax
  801638:	78 57                	js     801691 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80163a:	83 ec 08             	sub    $0x8,%esp
  80163d:	53                   	push   %ebx
  80163e:	68 00 50 80 00       	push   $0x805000
  801643:	e8 29 f2 ff ff       	call   800871 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801648:	8b 45 0c             	mov    0xc(%ebp),%eax
  80164b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801650:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801653:	b8 01 00 00 00       	mov    $0x1,%eax
  801658:	e8 f6 fd ff ff       	call   801453 <fsipc>
  80165d:	89 c3                	mov    %eax,%ebx
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	85 c0                	test   %eax,%eax
  801664:	79 14                	jns    80167a <open+0x6f>
		fd_close(fd, 0);
  801666:	83 ec 08             	sub    $0x8,%esp
  801669:	6a 00                	push   $0x0
  80166b:	ff 75 f4             	pushl  -0xc(%ebp)
  80166e:	e8 50 f9 ff ff       	call   800fc3 <fd_close>
		return r;
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	89 da                	mov    %ebx,%edx
  801678:	eb 17                	jmp    801691 <open+0x86>
	}

	return fd2num(fd);
  80167a:	83 ec 0c             	sub    $0xc,%esp
  80167d:	ff 75 f4             	pushl  -0xc(%ebp)
  801680:	e8 1f f8 ff ff       	call   800ea4 <fd2num>
  801685:	89 c2                	mov    %eax,%edx
  801687:	83 c4 10             	add    $0x10,%esp
  80168a:	eb 05                	jmp    801691 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80168c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801691:	89 d0                	mov    %edx,%eax
  801693:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801696:	c9                   	leave  
  801697:	c3                   	ret    

00801698 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80169e:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a3:	b8 08 00 00 00       	mov    $0x8,%eax
  8016a8:	e8 a6 fd ff ff       	call   801453 <fsipc>
}
  8016ad:	c9                   	leave  
  8016ae:	c3                   	ret    

008016af <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	57                   	push   %edi
  8016b3:	56                   	push   %esi
  8016b4:	53                   	push   %ebx
  8016b5:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8016bb:	6a 00                	push   $0x0
  8016bd:	ff 75 08             	pushl  0x8(%ebp)
  8016c0:	e8 46 ff ff ff       	call   80160b <open>
  8016c5:	89 c7                	mov    %eax,%edi
  8016c7:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	85 c0                	test   %eax,%eax
  8016d2:	0f 88 82 04 00 00    	js     801b5a <spawn+0x4ab>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8016d8:	83 ec 04             	sub    $0x4,%esp
  8016db:	68 00 02 00 00       	push   $0x200
  8016e0:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8016e6:	50                   	push   %eax
  8016e7:	57                   	push   %edi
  8016e8:	e8 24 fb ff ff       	call   801211 <readn>
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	3d 00 02 00 00       	cmp    $0x200,%eax
  8016f5:	75 0c                	jne    801703 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8016f7:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8016fe:	45 4c 46 
  801701:	74 33                	je     801736 <spawn+0x87>
		close(fd);
  801703:	83 ec 0c             	sub    $0xc,%esp
  801706:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80170c:	e8 33 f9 ff ff       	call   801044 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801711:	83 c4 0c             	add    $0xc,%esp
  801714:	68 7f 45 4c 46       	push   $0x464c457f
  801719:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80171f:	68 8f 2e 80 00       	push   $0x802e8f
  801724:	e8 44 eb ff ff       	call   80026d <cprintf>
		return -E_NOT_EXEC;
  801729:	83 c4 10             	add    $0x10,%esp
  80172c:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801731:	e9 d7 04 00 00       	jmp    801c0d <spawn+0x55e>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801736:	b8 07 00 00 00       	mov    $0x7,%eax
  80173b:	cd 30                	int    $0x30
  80173d:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801743:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801749:	85 c0                	test   %eax,%eax
  80174b:	0f 88 14 04 00 00    	js     801b65 <spawn+0x4b6>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801751:	89 c6                	mov    %eax,%esi
  801753:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801759:	6b f6 7c             	imul   $0x7c,%esi,%esi
  80175c:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801762:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801768:	b9 11 00 00 00       	mov    $0x11,%ecx
  80176d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80176f:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801775:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80177b:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801780:	be 00 00 00 00       	mov    $0x0,%esi
  801785:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801788:	eb 13                	jmp    80179d <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80178a:	83 ec 0c             	sub    $0xc,%esp
  80178d:	50                   	push   %eax
  80178e:	e8 a5 f0 ff ff       	call   800838 <strlen>
  801793:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801797:	83 c3 01             	add    $0x1,%ebx
  80179a:	83 c4 10             	add    $0x10,%esp
  80179d:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8017a4:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8017a7:	85 c0                	test   %eax,%eax
  8017a9:	75 df                	jne    80178a <spawn+0xdb>
  8017ab:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8017b1:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8017b7:	bf 00 10 40 00       	mov    $0x401000,%edi
  8017bc:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8017be:	89 fa                	mov    %edi,%edx
  8017c0:	83 e2 fc             	and    $0xfffffffc,%edx
  8017c3:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8017ca:	29 c2                	sub    %eax,%edx
  8017cc:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8017d2:	8d 42 f8             	lea    -0x8(%edx),%eax
  8017d5:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8017da:	0f 86 9b 03 00 00    	jbe    801b7b <spawn+0x4cc>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8017e0:	83 ec 04             	sub    $0x4,%esp
  8017e3:	6a 07                	push   $0x7
  8017e5:	68 00 00 40 00       	push   $0x400000
  8017ea:	6a 00                	push   $0x0
  8017ec:	e8 83 f4 ff ff       	call   800c74 <sys_page_alloc>
  8017f1:	83 c4 10             	add    $0x10,%esp
  8017f4:	85 c0                	test   %eax,%eax
  8017f6:	0f 88 89 03 00 00    	js     801b85 <spawn+0x4d6>
  8017fc:	be 00 00 00 00       	mov    $0x0,%esi
  801801:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801807:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80180a:	eb 30                	jmp    80183c <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80180c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801812:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801818:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  80181b:	83 ec 08             	sub    $0x8,%esp
  80181e:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801821:	57                   	push   %edi
  801822:	e8 4a f0 ff ff       	call   800871 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801827:	83 c4 04             	add    $0x4,%esp
  80182a:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80182d:	e8 06 f0 ff ff       	call   800838 <strlen>
  801832:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801836:	83 c6 01             	add    $0x1,%esi
  801839:	83 c4 10             	add    $0x10,%esp
  80183c:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801842:	7f c8                	jg     80180c <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801844:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80184a:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801850:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801857:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80185d:	74 19                	je     801878 <spawn+0x1c9>
  80185f:	68 1c 2f 80 00       	push   $0x802f1c
  801864:	68 63 2e 80 00       	push   $0x802e63
  801869:	68 f2 00 00 00       	push   $0xf2
  80186e:	68 a9 2e 80 00       	push   $0x802ea9
  801873:	e8 1c e9 ff ff       	call   800194 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801878:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  80187e:	89 f8                	mov    %edi,%eax
  801880:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801885:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801888:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80188e:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801891:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801897:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80189d:	83 ec 0c             	sub    $0xc,%esp
  8018a0:	6a 07                	push   $0x7
  8018a2:	68 00 d0 bf ee       	push   $0xeebfd000
  8018a7:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8018ad:	68 00 00 40 00       	push   $0x400000
  8018b2:	6a 00                	push   $0x0
  8018b4:	e8 fe f3 ff ff       	call   800cb7 <sys_page_map>
  8018b9:	89 c3                	mov    %eax,%ebx
  8018bb:	83 c4 20             	add    $0x20,%esp
  8018be:	85 c0                	test   %eax,%eax
  8018c0:	0f 88 35 03 00 00    	js     801bfb <spawn+0x54c>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8018c6:	83 ec 08             	sub    $0x8,%esp
  8018c9:	68 00 00 40 00       	push   $0x400000
  8018ce:	6a 00                	push   $0x0
  8018d0:	e8 24 f4 ff ff       	call   800cf9 <sys_page_unmap>
  8018d5:	89 c3                	mov    %eax,%ebx
  8018d7:	83 c4 10             	add    $0x10,%esp
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	0f 88 19 03 00 00    	js     801bfb <spawn+0x54c>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8018e2:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8018e8:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8018ef:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8018f5:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8018fc:	00 00 00 
  8018ff:	e9 88 01 00 00       	jmp    801a8c <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801904:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  80190a:	83 38 01             	cmpl   $0x1,(%eax)
  80190d:	0f 85 6b 01 00 00    	jne    801a7e <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801913:	89 c1                	mov    %eax,%ecx
  801915:	8b 40 18             	mov    0x18(%eax),%eax
  801918:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80191e:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801921:	83 f8 01             	cmp    $0x1,%eax
  801924:	19 c0                	sbb    %eax,%eax
  801926:	83 e0 fe             	and    $0xfffffffe,%eax
  801929:	83 c0 07             	add    $0x7,%eax
  80192c:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801932:	89 c8                	mov    %ecx,%eax
  801934:	8b 79 04             	mov    0x4(%ecx),%edi
  801937:	89 f9                	mov    %edi,%ecx
  801939:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  80193f:	8b 78 10             	mov    0x10(%eax),%edi
  801942:	8b 50 14             	mov    0x14(%eax),%edx
  801945:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  80194b:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80194e:	89 f0                	mov    %esi,%eax
  801950:	25 ff 0f 00 00       	and    $0xfff,%eax
  801955:	74 14                	je     80196b <spawn+0x2bc>
		va -= i;
  801957:	29 c6                	sub    %eax,%esi
		memsz += i;
  801959:	01 c2                	add    %eax,%edx
  80195b:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801961:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801963:	29 c1                	sub    %eax,%ecx
  801965:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80196b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801970:	e9 f7 00 00 00       	jmp    801a6c <spawn+0x3bd>
		if (i >= filesz) {
  801975:	39 fb                	cmp    %edi,%ebx
  801977:	72 27                	jb     8019a0 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801979:	83 ec 04             	sub    $0x4,%esp
  80197c:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801982:	56                   	push   %esi
  801983:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801989:	e8 e6 f2 ff ff       	call   800c74 <sys_page_alloc>
  80198e:	83 c4 10             	add    $0x10,%esp
  801991:	85 c0                	test   %eax,%eax
  801993:	0f 89 c7 00 00 00    	jns    801a60 <spawn+0x3b1>
  801999:	89 c3                	mov    %eax,%ebx
  80199b:	e9 f6 01 00 00       	jmp    801b96 <spawn+0x4e7>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019a0:	83 ec 04             	sub    $0x4,%esp
  8019a3:	6a 07                	push   $0x7
  8019a5:	68 00 00 40 00       	push   $0x400000
  8019aa:	6a 00                	push   $0x0
  8019ac:	e8 c3 f2 ff ff       	call   800c74 <sys_page_alloc>
  8019b1:	83 c4 10             	add    $0x10,%esp
  8019b4:	85 c0                	test   %eax,%eax
  8019b6:	0f 88 d0 01 00 00    	js     801b8c <spawn+0x4dd>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8019bc:	83 ec 08             	sub    $0x8,%esp
  8019bf:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8019c5:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  8019cb:	50                   	push   %eax
  8019cc:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019d2:	e8 0f f9 ff ff       	call   8012e6 <seek>
  8019d7:	83 c4 10             	add    $0x10,%esp
  8019da:	85 c0                	test   %eax,%eax
  8019dc:	0f 88 ae 01 00 00    	js     801b90 <spawn+0x4e1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8019e2:	83 ec 04             	sub    $0x4,%esp
  8019e5:	89 f8                	mov    %edi,%eax
  8019e7:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8019ed:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019f2:	b9 00 10 00 00       	mov    $0x1000,%ecx
  8019f7:	0f 47 c1             	cmova  %ecx,%eax
  8019fa:	50                   	push   %eax
  8019fb:	68 00 00 40 00       	push   $0x400000
  801a00:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a06:	e8 06 f8 ff ff       	call   801211 <readn>
  801a0b:	83 c4 10             	add    $0x10,%esp
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	0f 88 7e 01 00 00    	js     801b94 <spawn+0x4e5>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801a16:	83 ec 0c             	sub    $0xc,%esp
  801a19:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801a1f:	56                   	push   %esi
  801a20:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801a26:	68 00 00 40 00       	push   $0x400000
  801a2b:	6a 00                	push   $0x0
  801a2d:	e8 85 f2 ff ff       	call   800cb7 <sys_page_map>
  801a32:	83 c4 20             	add    $0x20,%esp
  801a35:	85 c0                	test   %eax,%eax
  801a37:	79 15                	jns    801a4e <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801a39:	50                   	push   %eax
  801a3a:	68 b5 2e 80 00       	push   $0x802eb5
  801a3f:	68 25 01 00 00       	push   $0x125
  801a44:	68 a9 2e 80 00       	push   $0x802ea9
  801a49:	e8 46 e7 ff ff       	call   800194 <_panic>
			sys_page_unmap(0, UTEMP);
  801a4e:	83 ec 08             	sub    $0x8,%esp
  801a51:	68 00 00 40 00       	push   $0x400000
  801a56:	6a 00                	push   $0x0
  801a58:	e8 9c f2 ff ff       	call   800cf9 <sys_page_unmap>
  801a5d:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801a60:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a66:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801a6c:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801a72:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801a78:	0f 82 f7 fe ff ff    	jb     801975 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a7e:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801a85:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801a8c:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801a93:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801a99:	0f 8c 65 fe ff ff    	jl     801904 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801a9f:	83 ec 0c             	sub    $0xc,%esp
  801aa2:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801aa8:	e8 97 f5 ff ff       	call   801044 <close>
  801aad:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r=0,pn=0;
	for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  801ab0:	bb 00 08 00 00       	mov    $0x800,%ebx
  801ab5:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
        if ((uvpd[pn >> 10] & PTE_P) &&uvpt[pn] & PTE_SHARE)
  801abb:	89 d8                	mov    %ebx,%eax
  801abd:	c1 f8 0a             	sar    $0xa,%eax
  801ac0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ac7:	a8 01                	test   $0x1,%al
  801ac9:	74 3e                	je     801b09 <spawn+0x45a>
  801acb:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801ad2:	f6 c4 04             	test   $0x4,%ah
  801ad5:	74 32                	je     801b09 <spawn+0x45a>
            if ( (r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), child, (void *)(pn*PGSIZE), uvpt[pn] & PTE_SYSCALL )) < 0)
  801ad7:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801ade:	89 da                	mov    %ebx,%edx
  801ae0:	c1 e2 0c             	shl    $0xc,%edx
  801ae3:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801ae9:	8b 49 48             	mov    0x48(%ecx),%ecx
  801aec:	83 ec 0c             	sub    $0xc,%esp
  801aef:	25 07 0e 00 00       	and    $0xe07,%eax
  801af4:	50                   	push   %eax
  801af5:	52                   	push   %edx
  801af6:	56                   	push   %esi
  801af7:	52                   	push   %edx
  801af8:	51                   	push   %ecx
  801af9:	e8 b9 f1 ff ff       	call   800cb7 <sys_page_map>
  801afe:	83 c4 20             	add    $0x20,%esp
  801b01:	85 c0                	test   %eax,%eax
  801b03:	0f 88 dd 00 00 00    	js     801be6 <spawn+0x537>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r=0,pn=0;
	for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  801b09:	83 c3 01             	add    $0x1,%ebx
  801b0c:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801b12:	75 a7                	jne    801abb <spawn+0x40c>
  801b14:	e9 9e 00 00 00       	jmp    801bb7 <spawn+0x508>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801b19:	50                   	push   %eax
  801b1a:	68 d2 2e 80 00       	push   $0x802ed2
  801b1f:	68 86 00 00 00       	push   $0x86
  801b24:	68 a9 2e 80 00       	push   $0x802ea9
  801b29:	e8 66 e6 ff ff       	call   800194 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801b2e:	83 ec 08             	sub    $0x8,%esp
  801b31:	6a 02                	push   $0x2
  801b33:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b39:	e8 fd f1 ff ff       	call   800d3b <sys_env_set_status>
  801b3e:	83 c4 10             	add    $0x10,%esp
  801b41:	85 c0                	test   %eax,%eax
  801b43:	79 2b                	jns    801b70 <spawn+0x4c1>
		panic("sys_env_set_status: %e", r);
  801b45:	50                   	push   %eax
  801b46:	68 ec 2e 80 00       	push   $0x802eec
  801b4b:	68 89 00 00 00       	push   $0x89
  801b50:	68 a9 2e 80 00       	push   $0x802ea9
  801b55:	e8 3a e6 ff ff       	call   800194 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801b5a:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801b60:	e9 a8 00 00 00       	jmp    801c0d <spawn+0x55e>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801b65:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b6b:	e9 9d 00 00 00       	jmp    801c0d <spawn+0x55e>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801b70:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b76:	e9 92 00 00 00       	jmp    801c0d <spawn+0x55e>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801b7b:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801b80:	e9 88 00 00 00       	jmp    801c0d <spawn+0x55e>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801b85:	89 c3                	mov    %eax,%ebx
  801b87:	e9 81 00 00 00       	jmp    801c0d <spawn+0x55e>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b8c:	89 c3                	mov    %eax,%ebx
  801b8e:	eb 06                	jmp    801b96 <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b90:	89 c3                	mov    %eax,%ebx
  801b92:	eb 02                	jmp    801b96 <spawn+0x4e7>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b94:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801b96:	83 ec 0c             	sub    $0xc,%esp
  801b99:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b9f:	e8 51 f0 ff ff       	call   800bf5 <sys_env_destroy>
	close(fd);
  801ba4:	83 c4 04             	add    $0x4,%esp
  801ba7:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bad:	e8 92 f4 ff ff       	call   801044 <close>
	return r;
  801bb2:	83 c4 10             	add    $0x10,%esp
  801bb5:	eb 56                	jmp    801c0d <spawn+0x55e>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801bb7:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801bbe:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801bc1:	83 ec 08             	sub    $0x8,%esp
  801bc4:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801bca:	50                   	push   %eax
  801bcb:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801bd1:	e8 a7 f1 ff ff       	call   800d7d <sys_env_set_trapframe>
  801bd6:	83 c4 10             	add    $0x10,%esp
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	0f 89 4d ff ff ff    	jns    801b2e <spawn+0x47f>
  801be1:	e9 33 ff ff ff       	jmp    801b19 <spawn+0x46a>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801be6:	50                   	push   %eax
  801be7:	68 03 2f 80 00       	push   $0x802f03
  801bec:	68 82 00 00 00       	push   $0x82
  801bf1:	68 a9 2e 80 00       	push   $0x802ea9
  801bf6:	e8 99 e5 ff ff       	call   800194 <_panic>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801bfb:	83 ec 08             	sub    $0x8,%esp
  801bfe:	68 00 00 40 00       	push   $0x400000
  801c03:	6a 00                	push   $0x0
  801c05:	e8 ef f0 ff ff       	call   800cf9 <sys_page_unmap>
  801c0a:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801c0d:	89 d8                	mov    %ebx,%eax
  801c0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c12:	5b                   	pop    %ebx
  801c13:	5e                   	pop    %esi
  801c14:	5f                   	pop    %edi
  801c15:	5d                   	pop    %ebp
  801c16:	c3                   	ret    

00801c17 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	56                   	push   %esi
  801c1b:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801c1c:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801c1f:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801c24:	eb 03                	jmp    801c29 <spawnl+0x12>
		argc++;
  801c26:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801c29:	83 c2 04             	add    $0x4,%edx
  801c2c:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801c30:	75 f4                	jne    801c26 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801c32:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801c39:	83 e2 f0             	and    $0xfffffff0,%edx
  801c3c:	29 d4                	sub    %edx,%esp
  801c3e:	8d 54 24 03          	lea    0x3(%esp),%edx
  801c42:	c1 ea 02             	shr    $0x2,%edx
  801c45:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801c4c:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801c4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c51:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801c58:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801c5f:	00 
  801c60:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801c62:	b8 00 00 00 00       	mov    $0x0,%eax
  801c67:	eb 0a                	jmp    801c73 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801c69:	83 c0 01             	add    $0x1,%eax
  801c6c:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801c70:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801c73:	39 d0                	cmp    %edx,%eax
  801c75:	75 f2                	jne    801c69 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801c77:	83 ec 08             	sub    $0x8,%esp
  801c7a:	56                   	push   %esi
  801c7b:	ff 75 08             	pushl  0x8(%ebp)
  801c7e:	e8 2c fa ff ff       	call   8016af <spawn>
}
  801c83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c86:	5b                   	pop    %ebx
  801c87:	5e                   	pop    %esi
  801c88:	5d                   	pop    %ebp
  801c89:	c3                   	ret    

00801c8a <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c8a:	55                   	push   %ebp
  801c8b:	89 e5                	mov    %esp,%ebp
  801c8d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801c90:	68 44 2f 80 00       	push   $0x802f44
  801c95:	ff 75 0c             	pushl  0xc(%ebp)
  801c98:	e8 d4 eb ff ff       	call   800871 <strcpy>
	return 0;
}
  801c9d:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca2:	c9                   	leave  
  801ca3:	c3                   	ret    

00801ca4 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ca4:	55                   	push   %ebp
  801ca5:	89 e5                	mov    %esp,%ebp
  801ca7:	53                   	push   %ebx
  801ca8:	83 ec 10             	sub    $0x10,%esp
  801cab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801cae:	53                   	push   %ebx
  801caf:	e8 12 0a 00 00       	call   8026c6 <pageref>
  801cb4:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801cb7:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801cbc:	83 f8 01             	cmp    $0x1,%eax
  801cbf:	75 10                	jne    801cd1 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801cc1:	83 ec 0c             	sub    $0xc,%esp
  801cc4:	ff 73 0c             	pushl  0xc(%ebx)
  801cc7:	e8 c0 02 00 00       	call   801f8c <nsipc_close>
  801ccc:	89 c2                	mov    %eax,%edx
  801cce:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801cd1:	89 d0                	mov    %edx,%eax
  801cd3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cd6:	c9                   	leave  
  801cd7:	c3                   	ret    

00801cd8 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801cde:	6a 00                	push   $0x0
  801ce0:	ff 75 10             	pushl  0x10(%ebp)
  801ce3:	ff 75 0c             	pushl  0xc(%ebp)
  801ce6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce9:	ff 70 0c             	pushl  0xc(%eax)
  801cec:	e8 78 03 00 00       	call   802069 <nsipc_send>
}
  801cf1:	c9                   	leave  
  801cf2:	c3                   	ret    

00801cf3 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801cf3:	55                   	push   %ebp
  801cf4:	89 e5                	mov    %esp,%ebp
  801cf6:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801cf9:	6a 00                	push   $0x0
  801cfb:	ff 75 10             	pushl  0x10(%ebp)
  801cfe:	ff 75 0c             	pushl  0xc(%ebp)
  801d01:	8b 45 08             	mov    0x8(%ebp),%eax
  801d04:	ff 70 0c             	pushl  0xc(%eax)
  801d07:	e8 f1 02 00 00       	call   801ffd <nsipc_recv>
}
  801d0c:	c9                   	leave  
  801d0d:	c3                   	ret    

00801d0e <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d14:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d17:	52                   	push   %edx
  801d18:	50                   	push   %eax
  801d19:	e8 fc f1 ff ff       	call   800f1a <fd_lookup>
  801d1e:	83 c4 10             	add    $0x10,%esp
  801d21:	85 c0                	test   %eax,%eax
  801d23:	78 17                	js     801d3c <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d28:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801d2e:	39 08                	cmp    %ecx,(%eax)
  801d30:	75 05                	jne    801d37 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d32:	8b 40 0c             	mov    0xc(%eax),%eax
  801d35:	eb 05                	jmp    801d3c <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d37:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d3c:	c9                   	leave  
  801d3d:	c3                   	ret    

00801d3e <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
  801d41:	56                   	push   %esi
  801d42:	53                   	push   %ebx
  801d43:	83 ec 1c             	sub    $0x1c,%esp
  801d46:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d4b:	50                   	push   %eax
  801d4c:	e8 7a f1 ff ff       	call   800ecb <fd_alloc>
  801d51:	89 c3                	mov    %eax,%ebx
  801d53:	83 c4 10             	add    $0x10,%esp
  801d56:	85 c0                	test   %eax,%eax
  801d58:	78 1b                	js     801d75 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d5a:	83 ec 04             	sub    $0x4,%esp
  801d5d:	68 07 04 00 00       	push   $0x407
  801d62:	ff 75 f4             	pushl  -0xc(%ebp)
  801d65:	6a 00                	push   $0x0
  801d67:	e8 08 ef ff ff       	call   800c74 <sys_page_alloc>
  801d6c:	89 c3                	mov    %eax,%ebx
  801d6e:	83 c4 10             	add    $0x10,%esp
  801d71:	85 c0                	test   %eax,%eax
  801d73:	79 10                	jns    801d85 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801d75:	83 ec 0c             	sub    $0xc,%esp
  801d78:	56                   	push   %esi
  801d79:	e8 0e 02 00 00       	call   801f8c <nsipc_close>
		return r;
  801d7e:	83 c4 10             	add    $0x10,%esp
  801d81:	89 d8                	mov    %ebx,%eax
  801d83:	eb 24                	jmp    801da9 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d85:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d8e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d93:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d9a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d9d:	83 ec 0c             	sub    $0xc,%esp
  801da0:	50                   	push   %eax
  801da1:	e8 fe f0 ff ff       	call   800ea4 <fd2num>
  801da6:	83 c4 10             	add    $0x10,%esp
}
  801da9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dac:	5b                   	pop    %ebx
  801dad:	5e                   	pop    %esi
  801dae:	5d                   	pop    %ebp
  801daf:	c3                   	ret    

00801db0 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801db0:	55                   	push   %ebp
  801db1:	89 e5                	mov    %esp,%ebp
  801db3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801db6:	8b 45 08             	mov    0x8(%ebp),%eax
  801db9:	e8 50 ff ff ff       	call   801d0e <fd2sockid>
		return r;
  801dbe:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dc0:	85 c0                	test   %eax,%eax
  801dc2:	78 1f                	js     801de3 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801dc4:	83 ec 04             	sub    $0x4,%esp
  801dc7:	ff 75 10             	pushl  0x10(%ebp)
  801dca:	ff 75 0c             	pushl  0xc(%ebp)
  801dcd:	50                   	push   %eax
  801dce:	e8 12 01 00 00       	call   801ee5 <nsipc_accept>
  801dd3:	83 c4 10             	add    $0x10,%esp
		return r;
  801dd6:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801dd8:	85 c0                	test   %eax,%eax
  801dda:	78 07                	js     801de3 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ddc:	e8 5d ff ff ff       	call   801d3e <alloc_sockfd>
  801de1:	89 c1                	mov    %eax,%ecx
}
  801de3:	89 c8                	mov    %ecx,%eax
  801de5:	c9                   	leave  
  801de6:	c3                   	ret    

00801de7 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ded:	8b 45 08             	mov    0x8(%ebp),%eax
  801df0:	e8 19 ff ff ff       	call   801d0e <fd2sockid>
  801df5:	85 c0                	test   %eax,%eax
  801df7:	78 12                	js     801e0b <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801df9:	83 ec 04             	sub    $0x4,%esp
  801dfc:	ff 75 10             	pushl  0x10(%ebp)
  801dff:	ff 75 0c             	pushl  0xc(%ebp)
  801e02:	50                   	push   %eax
  801e03:	e8 2d 01 00 00       	call   801f35 <nsipc_bind>
  801e08:	83 c4 10             	add    $0x10,%esp
}
  801e0b:	c9                   	leave  
  801e0c:	c3                   	ret    

00801e0d <shutdown>:

int
shutdown(int s, int how)
{
  801e0d:	55                   	push   %ebp
  801e0e:	89 e5                	mov    %esp,%ebp
  801e10:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e13:	8b 45 08             	mov    0x8(%ebp),%eax
  801e16:	e8 f3 fe ff ff       	call   801d0e <fd2sockid>
  801e1b:	85 c0                	test   %eax,%eax
  801e1d:	78 0f                	js     801e2e <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801e1f:	83 ec 08             	sub    $0x8,%esp
  801e22:	ff 75 0c             	pushl  0xc(%ebp)
  801e25:	50                   	push   %eax
  801e26:	e8 3f 01 00 00       	call   801f6a <nsipc_shutdown>
  801e2b:	83 c4 10             	add    $0x10,%esp
}
  801e2e:	c9                   	leave  
  801e2f:	c3                   	ret    

00801e30 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e30:	55                   	push   %ebp
  801e31:	89 e5                	mov    %esp,%ebp
  801e33:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e36:	8b 45 08             	mov    0x8(%ebp),%eax
  801e39:	e8 d0 fe ff ff       	call   801d0e <fd2sockid>
  801e3e:	85 c0                	test   %eax,%eax
  801e40:	78 12                	js     801e54 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801e42:	83 ec 04             	sub    $0x4,%esp
  801e45:	ff 75 10             	pushl  0x10(%ebp)
  801e48:	ff 75 0c             	pushl  0xc(%ebp)
  801e4b:	50                   	push   %eax
  801e4c:	e8 55 01 00 00       	call   801fa6 <nsipc_connect>
  801e51:	83 c4 10             	add    $0x10,%esp
}
  801e54:	c9                   	leave  
  801e55:	c3                   	ret    

00801e56 <listen>:

int
listen(int s, int backlog)
{
  801e56:	55                   	push   %ebp
  801e57:	89 e5                	mov    %esp,%ebp
  801e59:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5f:	e8 aa fe ff ff       	call   801d0e <fd2sockid>
  801e64:	85 c0                	test   %eax,%eax
  801e66:	78 0f                	js     801e77 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801e68:	83 ec 08             	sub    $0x8,%esp
  801e6b:	ff 75 0c             	pushl  0xc(%ebp)
  801e6e:	50                   	push   %eax
  801e6f:	e8 67 01 00 00       	call   801fdb <nsipc_listen>
  801e74:	83 c4 10             	add    $0x10,%esp
}
  801e77:	c9                   	leave  
  801e78:	c3                   	ret    

00801e79 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e7f:	ff 75 10             	pushl  0x10(%ebp)
  801e82:	ff 75 0c             	pushl  0xc(%ebp)
  801e85:	ff 75 08             	pushl  0x8(%ebp)
  801e88:	e8 3a 02 00 00       	call   8020c7 <nsipc_socket>
  801e8d:	83 c4 10             	add    $0x10,%esp
  801e90:	85 c0                	test   %eax,%eax
  801e92:	78 05                	js     801e99 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801e94:	e8 a5 fe ff ff       	call   801d3e <alloc_sockfd>
}
  801e99:	c9                   	leave  
  801e9a:	c3                   	ret    

00801e9b <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e9b:	55                   	push   %ebp
  801e9c:	89 e5                	mov    %esp,%ebp
  801e9e:	53                   	push   %ebx
  801e9f:	83 ec 04             	sub    $0x4,%esp
  801ea2:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ea4:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801eab:	75 12                	jne    801ebf <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ead:	83 ec 0c             	sub    $0xc,%esp
  801eb0:	6a 02                	push   $0x2
  801eb2:	e8 d6 07 00 00       	call   80268d <ipc_find_env>
  801eb7:	a3 04 40 80 00       	mov    %eax,0x804004
  801ebc:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ebf:	6a 07                	push   $0x7
  801ec1:	68 00 60 80 00       	push   $0x806000
  801ec6:	53                   	push   %ebx
  801ec7:	ff 35 04 40 80 00    	pushl  0x804004
  801ecd:	e8 67 07 00 00       	call   802639 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ed2:	83 c4 0c             	add    $0xc,%esp
  801ed5:	6a 00                	push   $0x0
  801ed7:	6a 00                	push   $0x0
  801ed9:	6a 00                	push   $0x0
  801edb:	e8 f0 06 00 00       	call   8025d0 <ipc_recv>
}
  801ee0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ee3:	c9                   	leave  
  801ee4:	c3                   	ret    

00801ee5 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ee5:	55                   	push   %ebp
  801ee6:	89 e5                	mov    %esp,%ebp
  801ee8:	56                   	push   %esi
  801ee9:	53                   	push   %ebx
  801eea:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801eed:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ef5:	8b 06                	mov    (%esi),%eax
  801ef7:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801efc:	b8 01 00 00 00       	mov    $0x1,%eax
  801f01:	e8 95 ff ff ff       	call   801e9b <nsipc>
  801f06:	89 c3                	mov    %eax,%ebx
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	78 20                	js     801f2c <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f0c:	83 ec 04             	sub    $0x4,%esp
  801f0f:	ff 35 10 60 80 00    	pushl  0x806010
  801f15:	68 00 60 80 00       	push   $0x806000
  801f1a:	ff 75 0c             	pushl  0xc(%ebp)
  801f1d:	e8 e1 ea ff ff       	call   800a03 <memmove>
		*addrlen = ret->ret_addrlen;
  801f22:	a1 10 60 80 00       	mov    0x806010,%eax
  801f27:	89 06                	mov    %eax,(%esi)
  801f29:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801f2c:	89 d8                	mov    %ebx,%eax
  801f2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f31:	5b                   	pop    %ebx
  801f32:	5e                   	pop    %esi
  801f33:	5d                   	pop    %ebp
  801f34:	c3                   	ret    

00801f35 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f35:	55                   	push   %ebp
  801f36:	89 e5                	mov    %esp,%ebp
  801f38:	53                   	push   %ebx
  801f39:	83 ec 08             	sub    $0x8,%esp
  801f3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f42:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f47:	53                   	push   %ebx
  801f48:	ff 75 0c             	pushl  0xc(%ebp)
  801f4b:	68 04 60 80 00       	push   $0x806004
  801f50:	e8 ae ea ff ff       	call   800a03 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f55:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f5b:	b8 02 00 00 00       	mov    $0x2,%eax
  801f60:	e8 36 ff ff ff       	call   801e9b <nsipc>
}
  801f65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f68:	c9                   	leave  
  801f69:	c3                   	ret    

00801f6a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f6a:	55                   	push   %ebp
  801f6b:	89 e5                	mov    %esp,%ebp
  801f6d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f70:	8b 45 08             	mov    0x8(%ebp),%eax
  801f73:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801f78:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f7b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801f80:	b8 03 00 00 00       	mov    $0x3,%eax
  801f85:	e8 11 ff ff ff       	call   801e9b <nsipc>
}
  801f8a:	c9                   	leave  
  801f8b:	c3                   	ret    

00801f8c <nsipc_close>:

int
nsipc_close(int s)
{
  801f8c:	55                   	push   %ebp
  801f8d:	89 e5                	mov    %esp,%ebp
  801f8f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f92:	8b 45 08             	mov    0x8(%ebp),%eax
  801f95:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801f9a:	b8 04 00 00 00       	mov    $0x4,%eax
  801f9f:	e8 f7 fe ff ff       	call   801e9b <nsipc>
}
  801fa4:	c9                   	leave  
  801fa5:	c3                   	ret    

00801fa6 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801fa6:	55                   	push   %ebp
  801fa7:	89 e5                	mov    %esp,%ebp
  801fa9:	53                   	push   %ebx
  801faa:	83 ec 08             	sub    $0x8,%esp
  801fad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801fb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb3:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801fb8:	53                   	push   %ebx
  801fb9:	ff 75 0c             	pushl  0xc(%ebp)
  801fbc:	68 04 60 80 00       	push   $0x806004
  801fc1:	e8 3d ea ff ff       	call   800a03 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fc6:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801fcc:	b8 05 00 00 00       	mov    $0x5,%eax
  801fd1:	e8 c5 fe ff ff       	call   801e9b <nsipc>
}
  801fd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fd9:	c9                   	leave  
  801fda:	c3                   	ret    

00801fdb <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801fdb:	55                   	push   %ebp
  801fdc:	89 e5                	mov    %esp,%ebp
  801fde:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801fe1:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801fe9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fec:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801ff1:	b8 06 00 00 00       	mov    $0x6,%eax
  801ff6:	e8 a0 fe ff ff       	call   801e9b <nsipc>
}
  801ffb:	c9                   	leave  
  801ffc:	c3                   	ret    

00801ffd <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ffd:	55                   	push   %ebp
  801ffe:	89 e5                	mov    %esp,%ebp
  802000:	56                   	push   %esi
  802001:	53                   	push   %ebx
  802002:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802005:	8b 45 08             	mov    0x8(%ebp),%eax
  802008:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80200d:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  802013:	8b 45 14             	mov    0x14(%ebp),%eax
  802016:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80201b:	b8 07 00 00 00       	mov    $0x7,%eax
  802020:	e8 76 fe ff ff       	call   801e9b <nsipc>
  802025:	89 c3                	mov    %eax,%ebx
  802027:	85 c0                	test   %eax,%eax
  802029:	78 35                	js     802060 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80202b:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802030:	7f 04                	jg     802036 <nsipc_recv+0x39>
  802032:	39 c6                	cmp    %eax,%esi
  802034:	7d 16                	jge    80204c <nsipc_recv+0x4f>
  802036:	68 50 2f 80 00       	push   $0x802f50
  80203b:	68 63 2e 80 00       	push   $0x802e63
  802040:	6a 62                	push   $0x62
  802042:	68 65 2f 80 00       	push   $0x802f65
  802047:	e8 48 e1 ff ff       	call   800194 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80204c:	83 ec 04             	sub    $0x4,%esp
  80204f:	50                   	push   %eax
  802050:	68 00 60 80 00       	push   $0x806000
  802055:	ff 75 0c             	pushl  0xc(%ebp)
  802058:	e8 a6 e9 ff ff       	call   800a03 <memmove>
  80205d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802060:	89 d8                	mov    %ebx,%eax
  802062:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802065:	5b                   	pop    %ebx
  802066:	5e                   	pop    %esi
  802067:	5d                   	pop    %ebp
  802068:	c3                   	ret    

00802069 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802069:	55                   	push   %ebp
  80206a:	89 e5                	mov    %esp,%ebp
  80206c:	53                   	push   %ebx
  80206d:	83 ec 04             	sub    $0x4,%esp
  802070:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802073:	8b 45 08             	mov    0x8(%ebp),%eax
  802076:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80207b:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802081:	7e 16                	jle    802099 <nsipc_send+0x30>
  802083:	68 71 2f 80 00       	push   $0x802f71
  802088:	68 63 2e 80 00       	push   $0x802e63
  80208d:	6a 6d                	push   $0x6d
  80208f:	68 65 2f 80 00       	push   $0x802f65
  802094:	e8 fb e0 ff ff       	call   800194 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802099:	83 ec 04             	sub    $0x4,%esp
  80209c:	53                   	push   %ebx
  80209d:	ff 75 0c             	pushl  0xc(%ebp)
  8020a0:	68 0c 60 80 00       	push   $0x80600c
  8020a5:	e8 59 e9 ff ff       	call   800a03 <memmove>
	nsipcbuf.send.req_size = size;
  8020aa:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8020b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8020b3:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8020b8:	b8 08 00 00 00       	mov    $0x8,%eax
  8020bd:	e8 d9 fd ff ff       	call   801e9b <nsipc>
}
  8020c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020c5:	c9                   	leave  
  8020c6:	c3                   	ret    

008020c7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8020c7:	55                   	push   %ebp
  8020c8:	89 e5                	mov    %esp,%ebp
  8020ca:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8020d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d8:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8020dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8020e0:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8020e5:	b8 09 00 00 00       	mov    $0x9,%eax
  8020ea:	e8 ac fd ff ff       	call   801e9b <nsipc>
}
  8020ef:	c9                   	leave  
  8020f0:	c3                   	ret    

008020f1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8020f1:	55                   	push   %ebp
  8020f2:	89 e5                	mov    %esp,%ebp
  8020f4:	56                   	push   %esi
  8020f5:	53                   	push   %ebx
  8020f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8020f9:	83 ec 0c             	sub    $0xc,%esp
  8020fc:	ff 75 08             	pushl  0x8(%ebp)
  8020ff:	e8 b0 ed ff ff       	call   800eb4 <fd2data>
  802104:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802106:	83 c4 08             	add    $0x8,%esp
  802109:	68 7d 2f 80 00       	push   $0x802f7d
  80210e:	53                   	push   %ebx
  80210f:	e8 5d e7 ff ff       	call   800871 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802114:	8b 46 04             	mov    0x4(%esi),%eax
  802117:	2b 06                	sub    (%esi),%eax
  802119:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80211f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802126:	00 00 00 
	stat->st_dev = &devpipe;
  802129:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  802130:	30 80 00 
	return 0;
}
  802133:	b8 00 00 00 00       	mov    $0x0,%eax
  802138:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80213b:	5b                   	pop    %ebx
  80213c:	5e                   	pop    %esi
  80213d:	5d                   	pop    %ebp
  80213e:	c3                   	ret    

0080213f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80213f:	55                   	push   %ebp
  802140:	89 e5                	mov    %esp,%ebp
  802142:	53                   	push   %ebx
  802143:	83 ec 0c             	sub    $0xc,%esp
  802146:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802149:	53                   	push   %ebx
  80214a:	6a 00                	push   $0x0
  80214c:	e8 a8 eb ff ff       	call   800cf9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802151:	89 1c 24             	mov    %ebx,(%esp)
  802154:	e8 5b ed ff ff       	call   800eb4 <fd2data>
  802159:	83 c4 08             	add    $0x8,%esp
  80215c:	50                   	push   %eax
  80215d:	6a 00                	push   $0x0
  80215f:	e8 95 eb ff ff       	call   800cf9 <sys_page_unmap>
}
  802164:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802167:	c9                   	leave  
  802168:	c3                   	ret    

00802169 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802169:	55                   	push   %ebp
  80216a:	89 e5                	mov    %esp,%ebp
  80216c:	57                   	push   %edi
  80216d:	56                   	push   %esi
  80216e:	53                   	push   %ebx
  80216f:	83 ec 1c             	sub    $0x1c,%esp
  802172:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802175:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802177:	a1 08 40 80 00       	mov    0x804008,%eax
  80217c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80217f:	83 ec 0c             	sub    $0xc,%esp
  802182:	ff 75 e0             	pushl  -0x20(%ebp)
  802185:	e8 3c 05 00 00       	call   8026c6 <pageref>
  80218a:	89 c3                	mov    %eax,%ebx
  80218c:	89 3c 24             	mov    %edi,(%esp)
  80218f:	e8 32 05 00 00       	call   8026c6 <pageref>
  802194:	83 c4 10             	add    $0x10,%esp
  802197:	39 c3                	cmp    %eax,%ebx
  802199:	0f 94 c1             	sete   %cl
  80219c:	0f b6 c9             	movzbl %cl,%ecx
  80219f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8021a2:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8021a8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8021ab:	39 ce                	cmp    %ecx,%esi
  8021ad:	74 1b                	je     8021ca <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8021af:	39 c3                	cmp    %eax,%ebx
  8021b1:	75 c4                	jne    802177 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8021b3:	8b 42 58             	mov    0x58(%edx),%eax
  8021b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8021b9:	50                   	push   %eax
  8021ba:	56                   	push   %esi
  8021bb:	68 84 2f 80 00       	push   $0x802f84
  8021c0:	e8 a8 e0 ff ff       	call   80026d <cprintf>
  8021c5:	83 c4 10             	add    $0x10,%esp
  8021c8:	eb ad                	jmp    802177 <_pipeisclosed+0xe>
	}
}
  8021ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021d0:	5b                   	pop    %ebx
  8021d1:	5e                   	pop    %esi
  8021d2:	5f                   	pop    %edi
  8021d3:	5d                   	pop    %ebp
  8021d4:	c3                   	ret    

008021d5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021d5:	55                   	push   %ebp
  8021d6:	89 e5                	mov    %esp,%ebp
  8021d8:	57                   	push   %edi
  8021d9:	56                   	push   %esi
  8021da:	53                   	push   %ebx
  8021db:	83 ec 28             	sub    $0x28,%esp
  8021de:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8021e1:	56                   	push   %esi
  8021e2:	e8 cd ec ff ff       	call   800eb4 <fd2data>
  8021e7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021e9:	83 c4 10             	add    $0x10,%esp
  8021ec:	bf 00 00 00 00       	mov    $0x0,%edi
  8021f1:	eb 4b                	jmp    80223e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8021f3:	89 da                	mov    %ebx,%edx
  8021f5:	89 f0                	mov    %esi,%eax
  8021f7:	e8 6d ff ff ff       	call   802169 <_pipeisclosed>
  8021fc:	85 c0                	test   %eax,%eax
  8021fe:	75 48                	jne    802248 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802200:	e8 50 ea ff ff       	call   800c55 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802205:	8b 43 04             	mov    0x4(%ebx),%eax
  802208:	8b 0b                	mov    (%ebx),%ecx
  80220a:	8d 51 20             	lea    0x20(%ecx),%edx
  80220d:	39 d0                	cmp    %edx,%eax
  80220f:	73 e2                	jae    8021f3 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802211:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802214:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802218:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80221b:	89 c2                	mov    %eax,%edx
  80221d:	c1 fa 1f             	sar    $0x1f,%edx
  802220:	89 d1                	mov    %edx,%ecx
  802222:	c1 e9 1b             	shr    $0x1b,%ecx
  802225:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802228:	83 e2 1f             	and    $0x1f,%edx
  80222b:	29 ca                	sub    %ecx,%edx
  80222d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802231:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802235:	83 c0 01             	add    $0x1,%eax
  802238:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80223b:	83 c7 01             	add    $0x1,%edi
  80223e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802241:	75 c2                	jne    802205 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802243:	8b 45 10             	mov    0x10(%ebp),%eax
  802246:	eb 05                	jmp    80224d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802248:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80224d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802250:	5b                   	pop    %ebx
  802251:	5e                   	pop    %esi
  802252:	5f                   	pop    %edi
  802253:	5d                   	pop    %ebp
  802254:	c3                   	ret    

00802255 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802255:	55                   	push   %ebp
  802256:	89 e5                	mov    %esp,%ebp
  802258:	57                   	push   %edi
  802259:	56                   	push   %esi
  80225a:	53                   	push   %ebx
  80225b:	83 ec 18             	sub    $0x18,%esp
  80225e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802261:	57                   	push   %edi
  802262:	e8 4d ec ff ff       	call   800eb4 <fd2data>
  802267:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802269:	83 c4 10             	add    $0x10,%esp
  80226c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802271:	eb 3d                	jmp    8022b0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802273:	85 db                	test   %ebx,%ebx
  802275:	74 04                	je     80227b <devpipe_read+0x26>
				return i;
  802277:	89 d8                	mov    %ebx,%eax
  802279:	eb 44                	jmp    8022bf <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80227b:	89 f2                	mov    %esi,%edx
  80227d:	89 f8                	mov    %edi,%eax
  80227f:	e8 e5 fe ff ff       	call   802169 <_pipeisclosed>
  802284:	85 c0                	test   %eax,%eax
  802286:	75 32                	jne    8022ba <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802288:	e8 c8 e9 ff ff       	call   800c55 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80228d:	8b 06                	mov    (%esi),%eax
  80228f:	3b 46 04             	cmp    0x4(%esi),%eax
  802292:	74 df                	je     802273 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802294:	99                   	cltd   
  802295:	c1 ea 1b             	shr    $0x1b,%edx
  802298:	01 d0                	add    %edx,%eax
  80229a:	83 e0 1f             	and    $0x1f,%eax
  80229d:	29 d0                	sub    %edx,%eax
  80229f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8022a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022a7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8022aa:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022ad:	83 c3 01             	add    $0x1,%ebx
  8022b0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8022b3:	75 d8                	jne    80228d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8022b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8022b8:	eb 05                	jmp    8022bf <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022ba:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8022bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022c2:	5b                   	pop    %ebx
  8022c3:	5e                   	pop    %esi
  8022c4:	5f                   	pop    %edi
  8022c5:	5d                   	pop    %ebp
  8022c6:	c3                   	ret    

008022c7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8022c7:	55                   	push   %ebp
  8022c8:	89 e5                	mov    %esp,%ebp
  8022ca:	56                   	push   %esi
  8022cb:	53                   	push   %ebx
  8022cc:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8022cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022d2:	50                   	push   %eax
  8022d3:	e8 f3 eb ff ff       	call   800ecb <fd_alloc>
  8022d8:	83 c4 10             	add    $0x10,%esp
  8022db:	89 c2                	mov    %eax,%edx
  8022dd:	85 c0                	test   %eax,%eax
  8022df:	0f 88 2c 01 00 00    	js     802411 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022e5:	83 ec 04             	sub    $0x4,%esp
  8022e8:	68 07 04 00 00       	push   $0x407
  8022ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8022f0:	6a 00                	push   $0x0
  8022f2:	e8 7d e9 ff ff       	call   800c74 <sys_page_alloc>
  8022f7:	83 c4 10             	add    $0x10,%esp
  8022fa:	89 c2                	mov    %eax,%edx
  8022fc:	85 c0                	test   %eax,%eax
  8022fe:	0f 88 0d 01 00 00    	js     802411 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802304:	83 ec 0c             	sub    $0xc,%esp
  802307:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80230a:	50                   	push   %eax
  80230b:	e8 bb eb ff ff       	call   800ecb <fd_alloc>
  802310:	89 c3                	mov    %eax,%ebx
  802312:	83 c4 10             	add    $0x10,%esp
  802315:	85 c0                	test   %eax,%eax
  802317:	0f 88 e2 00 00 00    	js     8023ff <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80231d:	83 ec 04             	sub    $0x4,%esp
  802320:	68 07 04 00 00       	push   $0x407
  802325:	ff 75 f0             	pushl  -0x10(%ebp)
  802328:	6a 00                	push   $0x0
  80232a:	e8 45 e9 ff ff       	call   800c74 <sys_page_alloc>
  80232f:	89 c3                	mov    %eax,%ebx
  802331:	83 c4 10             	add    $0x10,%esp
  802334:	85 c0                	test   %eax,%eax
  802336:	0f 88 c3 00 00 00    	js     8023ff <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80233c:	83 ec 0c             	sub    $0xc,%esp
  80233f:	ff 75 f4             	pushl  -0xc(%ebp)
  802342:	e8 6d eb ff ff       	call   800eb4 <fd2data>
  802347:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802349:	83 c4 0c             	add    $0xc,%esp
  80234c:	68 07 04 00 00       	push   $0x407
  802351:	50                   	push   %eax
  802352:	6a 00                	push   $0x0
  802354:	e8 1b e9 ff ff       	call   800c74 <sys_page_alloc>
  802359:	89 c3                	mov    %eax,%ebx
  80235b:	83 c4 10             	add    $0x10,%esp
  80235e:	85 c0                	test   %eax,%eax
  802360:	0f 88 89 00 00 00    	js     8023ef <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802366:	83 ec 0c             	sub    $0xc,%esp
  802369:	ff 75 f0             	pushl  -0x10(%ebp)
  80236c:	e8 43 eb ff ff       	call   800eb4 <fd2data>
  802371:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802378:	50                   	push   %eax
  802379:	6a 00                	push   $0x0
  80237b:	56                   	push   %esi
  80237c:	6a 00                	push   $0x0
  80237e:	e8 34 e9 ff ff       	call   800cb7 <sys_page_map>
  802383:	89 c3                	mov    %eax,%ebx
  802385:	83 c4 20             	add    $0x20,%esp
  802388:	85 c0                	test   %eax,%eax
  80238a:	78 55                	js     8023e1 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80238c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802392:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802395:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802397:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80239a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8023a1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8023a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023aa:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8023ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023af:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8023b6:	83 ec 0c             	sub    $0xc,%esp
  8023b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8023bc:	e8 e3 ea ff ff       	call   800ea4 <fd2num>
  8023c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023c4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8023c6:	83 c4 04             	add    $0x4,%esp
  8023c9:	ff 75 f0             	pushl  -0x10(%ebp)
  8023cc:	e8 d3 ea ff ff       	call   800ea4 <fd2num>
  8023d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023d4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8023d7:	83 c4 10             	add    $0x10,%esp
  8023da:	ba 00 00 00 00       	mov    $0x0,%edx
  8023df:	eb 30                	jmp    802411 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8023e1:	83 ec 08             	sub    $0x8,%esp
  8023e4:	56                   	push   %esi
  8023e5:	6a 00                	push   $0x0
  8023e7:	e8 0d e9 ff ff       	call   800cf9 <sys_page_unmap>
  8023ec:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8023ef:	83 ec 08             	sub    $0x8,%esp
  8023f2:	ff 75 f0             	pushl  -0x10(%ebp)
  8023f5:	6a 00                	push   $0x0
  8023f7:	e8 fd e8 ff ff       	call   800cf9 <sys_page_unmap>
  8023fc:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8023ff:	83 ec 08             	sub    $0x8,%esp
  802402:	ff 75 f4             	pushl  -0xc(%ebp)
  802405:	6a 00                	push   $0x0
  802407:	e8 ed e8 ff ff       	call   800cf9 <sys_page_unmap>
  80240c:	83 c4 10             	add    $0x10,%esp
  80240f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802411:	89 d0                	mov    %edx,%eax
  802413:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802416:	5b                   	pop    %ebx
  802417:	5e                   	pop    %esi
  802418:	5d                   	pop    %ebp
  802419:	c3                   	ret    

0080241a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80241a:	55                   	push   %ebp
  80241b:	89 e5                	mov    %esp,%ebp
  80241d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802420:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802423:	50                   	push   %eax
  802424:	ff 75 08             	pushl  0x8(%ebp)
  802427:	e8 ee ea ff ff       	call   800f1a <fd_lookup>
  80242c:	83 c4 10             	add    $0x10,%esp
  80242f:	85 c0                	test   %eax,%eax
  802431:	78 18                	js     80244b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802433:	83 ec 0c             	sub    $0xc,%esp
  802436:	ff 75 f4             	pushl  -0xc(%ebp)
  802439:	e8 76 ea ff ff       	call   800eb4 <fd2data>
	return _pipeisclosed(fd, p);
  80243e:	89 c2                	mov    %eax,%edx
  802440:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802443:	e8 21 fd ff ff       	call   802169 <_pipeisclosed>
  802448:	83 c4 10             	add    $0x10,%esp
}
  80244b:	c9                   	leave  
  80244c:	c3                   	ret    

0080244d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80244d:	55                   	push   %ebp
  80244e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802450:	b8 00 00 00 00       	mov    $0x0,%eax
  802455:	5d                   	pop    %ebp
  802456:	c3                   	ret    

00802457 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802457:	55                   	push   %ebp
  802458:	89 e5                	mov    %esp,%ebp
  80245a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80245d:	68 9c 2f 80 00       	push   $0x802f9c
  802462:	ff 75 0c             	pushl  0xc(%ebp)
  802465:	e8 07 e4 ff ff       	call   800871 <strcpy>
	return 0;
}
  80246a:	b8 00 00 00 00       	mov    $0x0,%eax
  80246f:	c9                   	leave  
  802470:	c3                   	ret    

00802471 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802471:	55                   	push   %ebp
  802472:	89 e5                	mov    %esp,%ebp
  802474:	57                   	push   %edi
  802475:	56                   	push   %esi
  802476:	53                   	push   %ebx
  802477:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80247d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802482:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802488:	eb 2d                	jmp    8024b7 <devcons_write+0x46>
		m = n - tot;
  80248a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80248d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80248f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802492:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802497:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80249a:	83 ec 04             	sub    $0x4,%esp
  80249d:	53                   	push   %ebx
  80249e:	03 45 0c             	add    0xc(%ebp),%eax
  8024a1:	50                   	push   %eax
  8024a2:	57                   	push   %edi
  8024a3:	e8 5b e5 ff ff       	call   800a03 <memmove>
		sys_cputs(buf, m);
  8024a8:	83 c4 08             	add    $0x8,%esp
  8024ab:	53                   	push   %ebx
  8024ac:	57                   	push   %edi
  8024ad:	e8 06 e7 ff ff       	call   800bb8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024b2:	01 de                	add    %ebx,%esi
  8024b4:	83 c4 10             	add    $0x10,%esp
  8024b7:	89 f0                	mov    %esi,%eax
  8024b9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8024bc:	72 cc                	jb     80248a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8024be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024c1:	5b                   	pop    %ebx
  8024c2:	5e                   	pop    %esi
  8024c3:	5f                   	pop    %edi
  8024c4:	5d                   	pop    %ebp
  8024c5:	c3                   	ret    

008024c6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8024c6:	55                   	push   %ebp
  8024c7:	89 e5                	mov    %esp,%ebp
  8024c9:	83 ec 08             	sub    $0x8,%esp
  8024cc:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8024d1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8024d5:	74 2a                	je     802501 <devcons_read+0x3b>
  8024d7:	eb 05                	jmp    8024de <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8024d9:	e8 77 e7 ff ff       	call   800c55 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8024de:	e8 f3 e6 ff ff       	call   800bd6 <sys_cgetc>
  8024e3:	85 c0                	test   %eax,%eax
  8024e5:	74 f2                	je     8024d9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8024e7:	85 c0                	test   %eax,%eax
  8024e9:	78 16                	js     802501 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8024eb:	83 f8 04             	cmp    $0x4,%eax
  8024ee:	74 0c                	je     8024fc <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8024f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024f3:	88 02                	mov    %al,(%edx)
	return 1;
  8024f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8024fa:	eb 05                	jmp    802501 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8024fc:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802501:	c9                   	leave  
  802502:	c3                   	ret    

00802503 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  802503:	55                   	push   %ebp
  802504:	89 e5                	mov    %esp,%ebp
  802506:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802509:	8b 45 08             	mov    0x8(%ebp),%eax
  80250c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80250f:	6a 01                	push   $0x1
  802511:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802514:	50                   	push   %eax
  802515:	e8 9e e6 ff ff       	call   800bb8 <sys_cputs>
}
  80251a:	83 c4 10             	add    $0x10,%esp
  80251d:	c9                   	leave  
  80251e:	c3                   	ret    

0080251f <getchar>:

int
getchar(void)
{
  80251f:	55                   	push   %ebp
  802520:	89 e5                	mov    %esp,%ebp
  802522:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802525:	6a 01                	push   $0x1
  802527:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80252a:	50                   	push   %eax
  80252b:	6a 00                	push   $0x0
  80252d:	e8 4e ec ff ff       	call   801180 <read>
	if (r < 0)
  802532:	83 c4 10             	add    $0x10,%esp
  802535:	85 c0                	test   %eax,%eax
  802537:	78 0f                	js     802548 <getchar+0x29>
		return r;
	if (r < 1)
  802539:	85 c0                	test   %eax,%eax
  80253b:	7e 06                	jle    802543 <getchar+0x24>
		return -E_EOF;
	return c;
  80253d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802541:	eb 05                	jmp    802548 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802543:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802548:	c9                   	leave  
  802549:	c3                   	ret    

0080254a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80254a:	55                   	push   %ebp
  80254b:	89 e5                	mov    %esp,%ebp
  80254d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802550:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802553:	50                   	push   %eax
  802554:	ff 75 08             	pushl  0x8(%ebp)
  802557:	e8 be e9 ff ff       	call   800f1a <fd_lookup>
  80255c:	83 c4 10             	add    $0x10,%esp
  80255f:	85 c0                	test   %eax,%eax
  802561:	78 11                	js     802574 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802563:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802566:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80256c:	39 10                	cmp    %edx,(%eax)
  80256e:	0f 94 c0             	sete   %al
  802571:	0f b6 c0             	movzbl %al,%eax
}
  802574:	c9                   	leave  
  802575:	c3                   	ret    

00802576 <opencons>:

int
opencons(void)
{
  802576:	55                   	push   %ebp
  802577:	89 e5                	mov    %esp,%ebp
  802579:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80257c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80257f:	50                   	push   %eax
  802580:	e8 46 e9 ff ff       	call   800ecb <fd_alloc>
  802585:	83 c4 10             	add    $0x10,%esp
		return r;
  802588:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80258a:	85 c0                	test   %eax,%eax
  80258c:	78 3e                	js     8025cc <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80258e:	83 ec 04             	sub    $0x4,%esp
  802591:	68 07 04 00 00       	push   $0x407
  802596:	ff 75 f4             	pushl  -0xc(%ebp)
  802599:	6a 00                	push   $0x0
  80259b:	e8 d4 e6 ff ff       	call   800c74 <sys_page_alloc>
  8025a0:	83 c4 10             	add    $0x10,%esp
		return r;
  8025a3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8025a5:	85 c0                	test   %eax,%eax
  8025a7:	78 23                	js     8025cc <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8025a9:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8025af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025b2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8025b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025b7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8025be:	83 ec 0c             	sub    $0xc,%esp
  8025c1:	50                   	push   %eax
  8025c2:	e8 dd e8 ff ff       	call   800ea4 <fd2num>
  8025c7:	89 c2                	mov    %eax,%edx
  8025c9:	83 c4 10             	add    $0x10,%esp
}
  8025cc:	89 d0                	mov    %edx,%eax
  8025ce:	c9                   	leave  
  8025cf:	c3                   	ret    

008025d0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8025d0:	55                   	push   %ebp
  8025d1:	89 e5                	mov    %esp,%ebp
  8025d3:	56                   	push   %esi
  8025d4:	53                   	push   %ebx
  8025d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8025d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025db:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  8025de:	85 c0                	test   %eax,%eax
  8025e0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8025e5:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  8025e8:	83 ec 0c             	sub    $0xc,%esp
  8025eb:	50                   	push   %eax
  8025ec:	e8 33 e8 ff ff       	call   800e24 <sys_ipc_recv>
  8025f1:	83 c4 10             	add    $0x10,%esp
  8025f4:	85 c0                	test   %eax,%eax
  8025f6:	79 16                	jns    80260e <ipc_recv+0x3e>
        if (from_env_store != NULL)
  8025f8:	85 f6                	test   %esi,%esi
  8025fa:	74 06                	je     802602 <ipc_recv+0x32>
            *from_env_store = 0;
  8025fc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  802602:	85 db                	test   %ebx,%ebx
  802604:	74 2c                	je     802632 <ipc_recv+0x62>
            *perm_store = 0;
  802606:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80260c:	eb 24                	jmp    802632 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  80260e:	85 f6                	test   %esi,%esi
  802610:	74 0a                	je     80261c <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  802612:	a1 08 40 80 00       	mov    0x804008,%eax
  802617:	8b 40 74             	mov    0x74(%eax),%eax
  80261a:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  80261c:	85 db                	test   %ebx,%ebx
  80261e:	74 0a                	je     80262a <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  802620:	a1 08 40 80 00       	mov    0x804008,%eax
  802625:	8b 40 78             	mov    0x78(%eax),%eax
  802628:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  80262a:	a1 08 40 80 00       	mov    0x804008,%eax
  80262f:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  802632:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802635:	5b                   	pop    %ebx
  802636:	5e                   	pop    %esi
  802637:	5d                   	pop    %ebp
  802638:	c3                   	ret    

00802639 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802639:	55                   	push   %ebp
  80263a:	89 e5                	mov    %esp,%ebp
  80263c:	57                   	push   %edi
  80263d:	56                   	push   %esi
  80263e:	53                   	push   %ebx
  80263f:	83 ec 0c             	sub    $0xc,%esp
  802642:	8b 7d 08             	mov    0x8(%ebp),%edi
  802645:	8b 75 0c             	mov    0xc(%ebp),%esi
  802648:	8b 45 10             	mov    0x10(%ebp),%eax
  80264b:	85 c0                	test   %eax,%eax
  80264d:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802652:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  802655:	eb 1c                	jmp    802673 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  802657:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80265a:	74 12                	je     80266e <ipc_send+0x35>
  80265c:	50                   	push   %eax
  80265d:	68 a8 2f 80 00       	push   $0x802fa8
  802662:	6a 3b                	push   $0x3b
  802664:	68 be 2f 80 00       	push   $0x802fbe
  802669:	e8 26 db ff ff       	call   800194 <_panic>
		sys_yield();
  80266e:	e8 e2 e5 ff ff       	call   800c55 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  802673:	ff 75 14             	pushl  0x14(%ebp)
  802676:	53                   	push   %ebx
  802677:	56                   	push   %esi
  802678:	57                   	push   %edi
  802679:	e8 83 e7 ff ff       	call   800e01 <sys_ipc_try_send>
  80267e:	83 c4 10             	add    $0x10,%esp
  802681:	85 c0                	test   %eax,%eax
  802683:	78 d2                	js     802657 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  802685:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802688:	5b                   	pop    %ebx
  802689:	5e                   	pop    %esi
  80268a:	5f                   	pop    %edi
  80268b:	5d                   	pop    %ebp
  80268c:	c3                   	ret    

0080268d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80268d:	55                   	push   %ebp
  80268e:	89 e5                	mov    %esp,%ebp
  802690:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802693:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802698:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80269b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8026a1:	8b 52 50             	mov    0x50(%edx),%edx
  8026a4:	39 ca                	cmp    %ecx,%edx
  8026a6:	75 0d                	jne    8026b5 <ipc_find_env+0x28>
			return envs[i].env_id;
  8026a8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8026ab:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8026b0:	8b 40 48             	mov    0x48(%eax),%eax
  8026b3:	eb 0f                	jmp    8026c4 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8026b5:	83 c0 01             	add    $0x1,%eax
  8026b8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8026bd:	75 d9                	jne    802698 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8026bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8026c4:	5d                   	pop    %ebp
  8026c5:	c3                   	ret    

008026c6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026c6:	55                   	push   %ebp
  8026c7:	89 e5                	mov    %esp,%ebp
  8026c9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026cc:	89 d0                	mov    %edx,%eax
  8026ce:	c1 e8 16             	shr    $0x16,%eax
  8026d1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8026d8:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026dd:	f6 c1 01             	test   $0x1,%cl
  8026e0:	74 1d                	je     8026ff <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8026e2:	c1 ea 0c             	shr    $0xc,%edx
  8026e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8026ec:	f6 c2 01             	test   $0x1,%dl
  8026ef:	74 0e                	je     8026ff <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8026f1:	c1 ea 0c             	shr    $0xc,%edx
  8026f4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8026fb:	ef 
  8026fc:	0f b7 c0             	movzwl %ax,%eax
}
  8026ff:	5d                   	pop    %ebp
  802700:	c3                   	ret    
  802701:	66 90                	xchg   %ax,%ax
  802703:	66 90                	xchg   %ax,%ax
  802705:	66 90                	xchg   %ax,%ax
  802707:	66 90                	xchg   %ax,%ax
  802709:	66 90                	xchg   %ax,%ax
  80270b:	66 90                	xchg   %ax,%ax
  80270d:	66 90                	xchg   %ax,%ax
  80270f:	90                   	nop

00802710 <__udivdi3>:
  802710:	55                   	push   %ebp
  802711:	57                   	push   %edi
  802712:	56                   	push   %esi
  802713:	53                   	push   %ebx
  802714:	83 ec 1c             	sub    $0x1c,%esp
  802717:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80271b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80271f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802723:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802727:	85 f6                	test   %esi,%esi
  802729:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80272d:	89 ca                	mov    %ecx,%edx
  80272f:	89 f8                	mov    %edi,%eax
  802731:	75 3d                	jne    802770 <__udivdi3+0x60>
  802733:	39 cf                	cmp    %ecx,%edi
  802735:	0f 87 c5 00 00 00    	ja     802800 <__udivdi3+0xf0>
  80273b:	85 ff                	test   %edi,%edi
  80273d:	89 fd                	mov    %edi,%ebp
  80273f:	75 0b                	jne    80274c <__udivdi3+0x3c>
  802741:	b8 01 00 00 00       	mov    $0x1,%eax
  802746:	31 d2                	xor    %edx,%edx
  802748:	f7 f7                	div    %edi
  80274a:	89 c5                	mov    %eax,%ebp
  80274c:	89 c8                	mov    %ecx,%eax
  80274e:	31 d2                	xor    %edx,%edx
  802750:	f7 f5                	div    %ebp
  802752:	89 c1                	mov    %eax,%ecx
  802754:	89 d8                	mov    %ebx,%eax
  802756:	89 cf                	mov    %ecx,%edi
  802758:	f7 f5                	div    %ebp
  80275a:	89 c3                	mov    %eax,%ebx
  80275c:	89 d8                	mov    %ebx,%eax
  80275e:	89 fa                	mov    %edi,%edx
  802760:	83 c4 1c             	add    $0x1c,%esp
  802763:	5b                   	pop    %ebx
  802764:	5e                   	pop    %esi
  802765:	5f                   	pop    %edi
  802766:	5d                   	pop    %ebp
  802767:	c3                   	ret    
  802768:	90                   	nop
  802769:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802770:	39 ce                	cmp    %ecx,%esi
  802772:	77 74                	ja     8027e8 <__udivdi3+0xd8>
  802774:	0f bd fe             	bsr    %esi,%edi
  802777:	83 f7 1f             	xor    $0x1f,%edi
  80277a:	0f 84 98 00 00 00    	je     802818 <__udivdi3+0x108>
  802780:	bb 20 00 00 00       	mov    $0x20,%ebx
  802785:	89 f9                	mov    %edi,%ecx
  802787:	89 c5                	mov    %eax,%ebp
  802789:	29 fb                	sub    %edi,%ebx
  80278b:	d3 e6                	shl    %cl,%esi
  80278d:	89 d9                	mov    %ebx,%ecx
  80278f:	d3 ed                	shr    %cl,%ebp
  802791:	89 f9                	mov    %edi,%ecx
  802793:	d3 e0                	shl    %cl,%eax
  802795:	09 ee                	or     %ebp,%esi
  802797:	89 d9                	mov    %ebx,%ecx
  802799:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80279d:	89 d5                	mov    %edx,%ebp
  80279f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027a3:	d3 ed                	shr    %cl,%ebp
  8027a5:	89 f9                	mov    %edi,%ecx
  8027a7:	d3 e2                	shl    %cl,%edx
  8027a9:	89 d9                	mov    %ebx,%ecx
  8027ab:	d3 e8                	shr    %cl,%eax
  8027ad:	09 c2                	or     %eax,%edx
  8027af:	89 d0                	mov    %edx,%eax
  8027b1:	89 ea                	mov    %ebp,%edx
  8027b3:	f7 f6                	div    %esi
  8027b5:	89 d5                	mov    %edx,%ebp
  8027b7:	89 c3                	mov    %eax,%ebx
  8027b9:	f7 64 24 0c          	mull   0xc(%esp)
  8027bd:	39 d5                	cmp    %edx,%ebp
  8027bf:	72 10                	jb     8027d1 <__udivdi3+0xc1>
  8027c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8027c5:	89 f9                	mov    %edi,%ecx
  8027c7:	d3 e6                	shl    %cl,%esi
  8027c9:	39 c6                	cmp    %eax,%esi
  8027cb:	73 07                	jae    8027d4 <__udivdi3+0xc4>
  8027cd:	39 d5                	cmp    %edx,%ebp
  8027cf:	75 03                	jne    8027d4 <__udivdi3+0xc4>
  8027d1:	83 eb 01             	sub    $0x1,%ebx
  8027d4:	31 ff                	xor    %edi,%edi
  8027d6:	89 d8                	mov    %ebx,%eax
  8027d8:	89 fa                	mov    %edi,%edx
  8027da:	83 c4 1c             	add    $0x1c,%esp
  8027dd:	5b                   	pop    %ebx
  8027de:	5e                   	pop    %esi
  8027df:	5f                   	pop    %edi
  8027e0:	5d                   	pop    %ebp
  8027e1:	c3                   	ret    
  8027e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027e8:	31 ff                	xor    %edi,%edi
  8027ea:	31 db                	xor    %ebx,%ebx
  8027ec:	89 d8                	mov    %ebx,%eax
  8027ee:	89 fa                	mov    %edi,%edx
  8027f0:	83 c4 1c             	add    $0x1c,%esp
  8027f3:	5b                   	pop    %ebx
  8027f4:	5e                   	pop    %esi
  8027f5:	5f                   	pop    %edi
  8027f6:	5d                   	pop    %ebp
  8027f7:	c3                   	ret    
  8027f8:	90                   	nop
  8027f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802800:	89 d8                	mov    %ebx,%eax
  802802:	f7 f7                	div    %edi
  802804:	31 ff                	xor    %edi,%edi
  802806:	89 c3                	mov    %eax,%ebx
  802808:	89 d8                	mov    %ebx,%eax
  80280a:	89 fa                	mov    %edi,%edx
  80280c:	83 c4 1c             	add    $0x1c,%esp
  80280f:	5b                   	pop    %ebx
  802810:	5e                   	pop    %esi
  802811:	5f                   	pop    %edi
  802812:	5d                   	pop    %ebp
  802813:	c3                   	ret    
  802814:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802818:	39 ce                	cmp    %ecx,%esi
  80281a:	72 0c                	jb     802828 <__udivdi3+0x118>
  80281c:	31 db                	xor    %ebx,%ebx
  80281e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802822:	0f 87 34 ff ff ff    	ja     80275c <__udivdi3+0x4c>
  802828:	bb 01 00 00 00       	mov    $0x1,%ebx
  80282d:	e9 2a ff ff ff       	jmp    80275c <__udivdi3+0x4c>
  802832:	66 90                	xchg   %ax,%ax
  802834:	66 90                	xchg   %ax,%ax
  802836:	66 90                	xchg   %ax,%ax
  802838:	66 90                	xchg   %ax,%ax
  80283a:	66 90                	xchg   %ax,%ax
  80283c:	66 90                	xchg   %ax,%ax
  80283e:	66 90                	xchg   %ax,%ax

00802840 <__umoddi3>:
  802840:	55                   	push   %ebp
  802841:	57                   	push   %edi
  802842:	56                   	push   %esi
  802843:	53                   	push   %ebx
  802844:	83 ec 1c             	sub    $0x1c,%esp
  802847:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80284b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80284f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802853:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802857:	85 d2                	test   %edx,%edx
  802859:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80285d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802861:	89 f3                	mov    %esi,%ebx
  802863:	89 3c 24             	mov    %edi,(%esp)
  802866:	89 74 24 04          	mov    %esi,0x4(%esp)
  80286a:	75 1c                	jne    802888 <__umoddi3+0x48>
  80286c:	39 f7                	cmp    %esi,%edi
  80286e:	76 50                	jbe    8028c0 <__umoddi3+0x80>
  802870:	89 c8                	mov    %ecx,%eax
  802872:	89 f2                	mov    %esi,%edx
  802874:	f7 f7                	div    %edi
  802876:	89 d0                	mov    %edx,%eax
  802878:	31 d2                	xor    %edx,%edx
  80287a:	83 c4 1c             	add    $0x1c,%esp
  80287d:	5b                   	pop    %ebx
  80287e:	5e                   	pop    %esi
  80287f:	5f                   	pop    %edi
  802880:	5d                   	pop    %ebp
  802881:	c3                   	ret    
  802882:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802888:	39 f2                	cmp    %esi,%edx
  80288a:	89 d0                	mov    %edx,%eax
  80288c:	77 52                	ja     8028e0 <__umoddi3+0xa0>
  80288e:	0f bd ea             	bsr    %edx,%ebp
  802891:	83 f5 1f             	xor    $0x1f,%ebp
  802894:	75 5a                	jne    8028f0 <__umoddi3+0xb0>
  802896:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80289a:	0f 82 e0 00 00 00    	jb     802980 <__umoddi3+0x140>
  8028a0:	39 0c 24             	cmp    %ecx,(%esp)
  8028a3:	0f 86 d7 00 00 00    	jbe    802980 <__umoddi3+0x140>
  8028a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8028ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8028b1:	83 c4 1c             	add    $0x1c,%esp
  8028b4:	5b                   	pop    %ebx
  8028b5:	5e                   	pop    %esi
  8028b6:	5f                   	pop    %edi
  8028b7:	5d                   	pop    %ebp
  8028b8:	c3                   	ret    
  8028b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028c0:	85 ff                	test   %edi,%edi
  8028c2:	89 fd                	mov    %edi,%ebp
  8028c4:	75 0b                	jne    8028d1 <__umoddi3+0x91>
  8028c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8028cb:	31 d2                	xor    %edx,%edx
  8028cd:	f7 f7                	div    %edi
  8028cf:	89 c5                	mov    %eax,%ebp
  8028d1:	89 f0                	mov    %esi,%eax
  8028d3:	31 d2                	xor    %edx,%edx
  8028d5:	f7 f5                	div    %ebp
  8028d7:	89 c8                	mov    %ecx,%eax
  8028d9:	f7 f5                	div    %ebp
  8028db:	89 d0                	mov    %edx,%eax
  8028dd:	eb 99                	jmp    802878 <__umoddi3+0x38>
  8028df:	90                   	nop
  8028e0:	89 c8                	mov    %ecx,%eax
  8028e2:	89 f2                	mov    %esi,%edx
  8028e4:	83 c4 1c             	add    $0x1c,%esp
  8028e7:	5b                   	pop    %ebx
  8028e8:	5e                   	pop    %esi
  8028e9:	5f                   	pop    %edi
  8028ea:	5d                   	pop    %ebp
  8028eb:	c3                   	ret    
  8028ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028f0:	8b 34 24             	mov    (%esp),%esi
  8028f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8028f8:	89 e9                	mov    %ebp,%ecx
  8028fa:	29 ef                	sub    %ebp,%edi
  8028fc:	d3 e0                	shl    %cl,%eax
  8028fe:	89 f9                	mov    %edi,%ecx
  802900:	89 f2                	mov    %esi,%edx
  802902:	d3 ea                	shr    %cl,%edx
  802904:	89 e9                	mov    %ebp,%ecx
  802906:	09 c2                	or     %eax,%edx
  802908:	89 d8                	mov    %ebx,%eax
  80290a:	89 14 24             	mov    %edx,(%esp)
  80290d:	89 f2                	mov    %esi,%edx
  80290f:	d3 e2                	shl    %cl,%edx
  802911:	89 f9                	mov    %edi,%ecx
  802913:	89 54 24 04          	mov    %edx,0x4(%esp)
  802917:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80291b:	d3 e8                	shr    %cl,%eax
  80291d:	89 e9                	mov    %ebp,%ecx
  80291f:	89 c6                	mov    %eax,%esi
  802921:	d3 e3                	shl    %cl,%ebx
  802923:	89 f9                	mov    %edi,%ecx
  802925:	89 d0                	mov    %edx,%eax
  802927:	d3 e8                	shr    %cl,%eax
  802929:	89 e9                	mov    %ebp,%ecx
  80292b:	09 d8                	or     %ebx,%eax
  80292d:	89 d3                	mov    %edx,%ebx
  80292f:	89 f2                	mov    %esi,%edx
  802931:	f7 34 24             	divl   (%esp)
  802934:	89 d6                	mov    %edx,%esi
  802936:	d3 e3                	shl    %cl,%ebx
  802938:	f7 64 24 04          	mull   0x4(%esp)
  80293c:	39 d6                	cmp    %edx,%esi
  80293e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802942:	89 d1                	mov    %edx,%ecx
  802944:	89 c3                	mov    %eax,%ebx
  802946:	72 08                	jb     802950 <__umoddi3+0x110>
  802948:	75 11                	jne    80295b <__umoddi3+0x11b>
  80294a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80294e:	73 0b                	jae    80295b <__umoddi3+0x11b>
  802950:	2b 44 24 04          	sub    0x4(%esp),%eax
  802954:	1b 14 24             	sbb    (%esp),%edx
  802957:	89 d1                	mov    %edx,%ecx
  802959:	89 c3                	mov    %eax,%ebx
  80295b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80295f:	29 da                	sub    %ebx,%edx
  802961:	19 ce                	sbb    %ecx,%esi
  802963:	89 f9                	mov    %edi,%ecx
  802965:	89 f0                	mov    %esi,%eax
  802967:	d3 e0                	shl    %cl,%eax
  802969:	89 e9                	mov    %ebp,%ecx
  80296b:	d3 ea                	shr    %cl,%edx
  80296d:	89 e9                	mov    %ebp,%ecx
  80296f:	d3 ee                	shr    %cl,%esi
  802971:	09 d0                	or     %edx,%eax
  802973:	89 f2                	mov    %esi,%edx
  802975:	83 c4 1c             	add    $0x1c,%esp
  802978:	5b                   	pop    %ebx
  802979:	5e                   	pop    %esi
  80297a:	5f                   	pop    %edi
  80297b:	5d                   	pop    %ebp
  80297c:	c3                   	ret    
  80297d:	8d 76 00             	lea    0x0(%esi),%esi
  802980:	29 f9                	sub    %edi,%ecx
  802982:	19 d6                	sbb    %edx,%esi
  802984:	89 74 24 04          	mov    %esi,0x4(%esp)
  802988:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80298c:	e9 18 ff ff ff       	jmp    8028a9 <__umoddi3+0x69>
