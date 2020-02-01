
obj/user/testpteshare.debug：     文件格式 elf32-i386


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
  80002c:	e8 47 01 00 00       	call   800178 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 30 80 00    	pushl  0x803000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 6c 08 00 00       	call   8008b5 <strcpy>
	exit();
  800049:	e8 70 01 00 00       	call   8001be <exit>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	74 05                	je     800065 <umain+0x12>
		childofspawn();
  800060:	e8 ce ff ff ff       	call   800033 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800065:	83 ec 04             	sub    $0x4,%esp
  800068:	68 07 04 00 00       	push   $0x407
  80006d:	68 00 00 00 a0       	push   $0xa0000000
  800072:	6a 00                	push   $0x0
  800074:	e8 3f 0c 00 00       	call   800cb8 <sys_page_alloc>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 12                	jns    800092 <umain+0x3f>
		panic("sys_page_alloc: %e", r);
  800080:	50                   	push   %eax
  800081:	68 cc 28 80 00       	push   $0x8028cc
  800086:	6a 13                	push   $0x13
  800088:	68 df 28 80 00       	push   $0x8028df
  80008d:	e8 46 01 00 00       	call   8001d8 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 04 0f 00 00       	call   800f9b <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 f3 28 80 00       	push   $0x8028f3
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 df 28 80 00       	push   $0x8028df
  8000aa:	e8 29 01 00 00       	call   8001d8 <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 30 80 00    	pushl  0x803004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 ef 07 00 00       	call   8008b5 <strcpy>
		exit();
  8000c6:	e8 f3 00 00 00       	call   8001be <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 b3 21 00 00       	call   80228a <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 30 80 00    	pushl  0x803004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 75 08 00 00       	call   80095f <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba c6 28 80 00       	mov    $0x8028c6,%edx
  8000f4:	b8 c0 28 80 00       	mov    $0x8028c0,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 fc 28 80 00       	push   $0x8028fc
  800102:	e8 aa 01 00 00       	call   8002b1 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 17 29 80 00       	push   $0x802917
  80010e:	68 1c 29 80 00       	push   $0x80291c
  800113:	68 1b 29 80 00       	push   $0x80291b
  800118:	e8 9e 1d 00 00       	call   801ebb <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 29 29 80 00       	push   $0x802929
  80012a:	6a 21                	push   $0x21
  80012c:	68 df 28 80 00       	push   $0x8028df
  800131:	e8 a2 00 00 00       	call   8001d8 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 4b 21 00 00       	call   80228a <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 30 80 00    	pushl  0x803000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 0d 08 00 00       	call   80095f <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba c6 28 80 00       	mov    $0x8028c6,%edx
  80015c:	b8 c0 28 80 00       	mov    $0x8028c0,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 33 29 80 00       	push   $0x802933
  80016a:	e8 42 01 00 00       	call   8002b1 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  80016f:	cc                   	int3   

	breakpoint();
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800180:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800183:	e8 f2 0a 00 00       	call   800c7a <sys_getenvid>
  800188:	25 ff 03 00 00       	and    $0x3ff,%eax
  80018d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800190:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800195:	a3 04 40 80 00       	mov    %eax,0x804004

    // save the name of the program so that panic() can use it
    if (argc > 0)
  80019a:	85 db                	test   %ebx,%ebx
  80019c:	7e 07                	jle    8001a5 <libmain+0x2d>
        binaryname = argv[0];
  80019e:	8b 06                	mov    (%esi),%eax
  8001a0:	a3 08 30 80 00       	mov    %eax,0x803008

    // call user main routine
    umain(argc, argv);
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
  8001aa:	e8 a4 fe ff ff       	call   800053 <umain>

    // exit gracefully
    exit();
  8001af:	e8 0a 00 00 00       	call   8001be <exit>
}
  8001b4:	83 c4 10             	add    $0x10,%esp
  8001b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5e                   	pop    %esi
  8001bc:	5d                   	pop    %ebp
  8001bd:	c3                   	ret    

008001be <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001c4:	e8 4a 11 00 00       	call   801313 <close_all>
	sys_env_destroy(0);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	6a 00                	push   $0x0
  8001ce:	e8 66 0a 00 00       	call   800c39 <sys_env_destroy>
}
  8001d3:	83 c4 10             	add    $0x10,%esp
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001dd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001e0:	8b 35 08 30 80 00    	mov    0x803008,%esi
  8001e6:	e8 8f 0a 00 00       	call   800c7a <sys_getenvid>
  8001eb:	83 ec 0c             	sub    $0xc,%esp
  8001ee:	ff 75 0c             	pushl  0xc(%ebp)
  8001f1:	ff 75 08             	pushl  0x8(%ebp)
  8001f4:	56                   	push   %esi
  8001f5:	50                   	push   %eax
  8001f6:	68 78 29 80 00       	push   $0x802978
  8001fb:	e8 b1 00 00 00       	call   8002b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	83 c4 18             	add    $0x18,%esp
  800203:	53                   	push   %ebx
  800204:	ff 75 10             	pushl  0x10(%ebp)
  800207:	e8 54 00 00 00       	call   800260 <vcprintf>
	cprintf("\n");
  80020c:	c7 04 24 fc 2e 80 00 	movl   $0x802efc,(%esp)
  800213:	e8 99 00 00 00       	call   8002b1 <cprintf>
  800218:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021b:	cc                   	int3   
  80021c:	eb fd                	jmp    80021b <_panic+0x43>

0080021e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	53                   	push   %ebx
  800222:	83 ec 04             	sub    $0x4,%esp
  800225:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800228:	8b 13                	mov    (%ebx),%edx
  80022a:	8d 42 01             	lea    0x1(%edx),%eax
  80022d:	89 03                	mov    %eax,(%ebx)
  80022f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800232:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800236:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023b:	75 1a                	jne    800257 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80023d:	83 ec 08             	sub    $0x8,%esp
  800240:	68 ff 00 00 00       	push   $0xff
  800245:	8d 43 08             	lea    0x8(%ebx),%eax
  800248:	50                   	push   %eax
  800249:	e8 ae 09 00 00       	call   800bfc <sys_cputs>
		b->idx = 0;
  80024e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800254:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800257:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800269:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800270:	00 00 00 
	b.cnt = 0;
  800273:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80027a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80027d:	ff 75 0c             	pushl  0xc(%ebp)
  800280:	ff 75 08             	pushl  0x8(%ebp)
  800283:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800289:	50                   	push   %eax
  80028a:	68 1e 02 80 00       	push   $0x80021e
  80028f:	e8 1a 01 00 00       	call   8003ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800294:	83 c4 08             	add    $0x8,%esp
  800297:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80029d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a3:	50                   	push   %eax
  8002a4:	e8 53 09 00 00       	call   800bfc <sys_cputs>

	return b.cnt;
}
  8002a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    

008002b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ba:	50                   	push   %eax
  8002bb:	ff 75 08             	pushl  0x8(%ebp)
  8002be:	e8 9d ff ff ff       	call   800260 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c3:	c9                   	leave  
  8002c4:	c3                   	ret    

008002c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	57                   	push   %edi
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 1c             	sub    $0x1c,%esp
  8002ce:	89 c7                	mov    %eax,%edi
  8002d0:	89 d6                	mov    %edx,%esi
  8002d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002ec:	39 d3                	cmp    %edx,%ebx
  8002ee:	72 05                	jb     8002f5 <printnum+0x30>
  8002f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f3:	77 45                	ja     80033a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f5:	83 ec 0c             	sub    $0xc,%esp
  8002f8:	ff 75 18             	pushl  0x18(%ebp)
  8002fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800301:	53                   	push   %ebx
  800302:	ff 75 10             	pushl  0x10(%ebp)
  800305:	83 ec 08             	sub    $0x8,%esp
  800308:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030b:	ff 75 e0             	pushl  -0x20(%ebp)
  80030e:	ff 75 dc             	pushl  -0x24(%ebp)
  800311:	ff 75 d8             	pushl  -0x28(%ebp)
  800314:	e8 07 23 00 00       	call   802620 <__udivdi3>
  800319:	83 c4 18             	add    $0x18,%esp
  80031c:	52                   	push   %edx
  80031d:	50                   	push   %eax
  80031e:	89 f2                	mov    %esi,%edx
  800320:	89 f8                	mov    %edi,%eax
  800322:	e8 9e ff ff ff       	call   8002c5 <printnum>
  800327:	83 c4 20             	add    $0x20,%esp
  80032a:	eb 18                	jmp    800344 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032c:	83 ec 08             	sub    $0x8,%esp
  80032f:	56                   	push   %esi
  800330:	ff 75 18             	pushl  0x18(%ebp)
  800333:	ff d7                	call   *%edi
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	eb 03                	jmp    80033d <printnum+0x78>
  80033a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033d:	83 eb 01             	sub    $0x1,%ebx
  800340:	85 db                	test   %ebx,%ebx
  800342:	7f e8                	jg     80032c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	56                   	push   %esi
  800348:	83 ec 04             	sub    $0x4,%esp
  80034b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034e:	ff 75 e0             	pushl  -0x20(%ebp)
  800351:	ff 75 dc             	pushl  -0x24(%ebp)
  800354:	ff 75 d8             	pushl  -0x28(%ebp)
  800357:	e8 f4 23 00 00       	call   802750 <__umoddi3>
  80035c:	83 c4 14             	add    $0x14,%esp
  80035f:	0f be 80 9b 29 80 00 	movsbl 0x80299b(%eax),%eax
  800366:	50                   	push   %eax
  800367:	ff d7                	call   *%edi
}
  800369:	83 c4 10             	add    $0x10,%esp
  80036c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036f:	5b                   	pop    %ebx
  800370:	5e                   	pop    %esi
  800371:	5f                   	pop    %edi
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80037a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80037e:	8b 10                	mov    (%eax),%edx
  800380:	3b 50 04             	cmp    0x4(%eax),%edx
  800383:	73 0a                	jae    80038f <sprintputch+0x1b>
		*b->buf++ = ch;
  800385:	8d 4a 01             	lea    0x1(%edx),%ecx
  800388:	89 08                	mov    %ecx,(%eax)
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
  80038d:	88 02                	mov    %al,(%edx)
}
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800397:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80039a:	50                   	push   %eax
  80039b:	ff 75 10             	pushl  0x10(%ebp)
  80039e:	ff 75 0c             	pushl  0xc(%ebp)
  8003a1:	ff 75 08             	pushl  0x8(%ebp)
  8003a4:	e8 05 00 00 00       	call   8003ae <vprintfmt>
	va_end(ap);
}
  8003a9:	83 c4 10             	add    $0x10,%esp
  8003ac:	c9                   	leave  
  8003ad:	c3                   	ret    

008003ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	57                   	push   %edi
  8003b2:	56                   	push   %esi
  8003b3:	53                   	push   %ebx
  8003b4:	83 ec 2c             	sub    $0x2c,%esp
  8003b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003bd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003c0:	eb 12                	jmp    8003d4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003c2:	85 c0                	test   %eax,%eax
  8003c4:	0f 84 42 04 00 00    	je     80080c <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8003ca:	83 ec 08             	sub    $0x8,%esp
  8003cd:	53                   	push   %ebx
  8003ce:	50                   	push   %eax
  8003cf:	ff d6                	call   *%esi
  8003d1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d4:	83 c7 01             	add    $0x1,%edi
  8003d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003db:	83 f8 25             	cmp    $0x25,%eax
  8003de:	75 e2                	jne    8003c2 <vprintfmt+0x14>
  8003e0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003e4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003eb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003f2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fe:	eb 07                	jmp    800407 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800403:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800407:	8d 47 01             	lea    0x1(%edi),%eax
  80040a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040d:	0f b6 07             	movzbl (%edi),%eax
  800410:	0f b6 d0             	movzbl %al,%edx
  800413:	83 e8 23             	sub    $0x23,%eax
  800416:	3c 55                	cmp    $0x55,%al
  800418:	0f 87 d3 03 00 00    	ja     8007f1 <vprintfmt+0x443>
  80041e:	0f b6 c0             	movzbl %al,%eax
  800421:	ff 24 85 e0 2a 80 00 	jmp    *0x802ae0(,%eax,4)
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80042b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80042f:	eb d6                	jmp    800407 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800434:	b8 00 00 00 00       	mov    $0x0,%eax
  800439:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80043c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80043f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800443:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800446:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800449:	83 f9 09             	cmp    $0x9,%ecx
  80044c:	77 3f                	ja     80048d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80044e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800451:	eb e9                	jmp    80043c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800453:	8b 45 14             	mov    0x14(%ebp),%eax
  800456:	8b 00                	mov    (%eax),%eax
  800458:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80045b:	8b 45 14             	mov    0x14(%ebp),%eax
  80045e:	8d 40 04             	lea    0x4(%eax),%eax
  800461:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800467:	eb 2a                	jmp    800493 <vprintfmt+0xe5>
  800469:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80046c:	85 c0                	test   %eax,%eax
  80046e:	ba 00 00 00 00       	mov    $0x0,%edx
  800473:	0f 49 d0             	cmovns %eax,%edx
  800476:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800479:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047c:	eb 89                	jmp    800407 <vprintfmt+0x59>
  80047e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800481:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800488:	e9 7a ff ff ff       	jmp    800407 <vprintfmt+0x59>
  80048d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800490:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800493:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800497:	0f 89 6a ff ff ff    	jns    800407 <vprintfmt+0x59>
				width = precision, precision = -1;
  80049d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004aa:	e9 58 ff ff ff       	jmp    800407 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004af:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004b5:	e9 4d ff ff ff       	jmp    800407 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bd:	8d 78 04             	lea    0x4(%eax),%edi
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	53                   	push   %ebx
  8004c4:	ff 30                	pushl  (%eax)
  8004c6:	ff d6                	call   *%esi
			break;
  8004c8:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004cb:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004d1:	e9 fe fe ff ff       	jmp    8003d4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d9:	8d 78 04             	lea    0x4(%eax),%edi
  8004dc:	8b 00                	mov    (%eax),%eax
  8004de:	99                   	cltd   
  8004df:	31 d0                	xor    %edx,%eax
  8004e1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e3:	83 f8 0f             	cmp    $0xf,%eax
  8004e6:	7f 0b                	jg     8004f3 <vprintfmt+0x145>
  8004e8:	8b 14 85 40 2c 80 00 	mov    0x802c40(,%eax,4),%edx
  8004ef:	85 d2                	test   %edx,%edx
  8004f1:	75 1b                	jne    80050e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8004f3:	50                   	push   %eax
  8004f4:	68 b3 29 80 00       	push   $0x8029b3
  8004f9:	53                   	push   %ebx
  8004fa:	56                   	push   %esi
  8004fb:	e8 91 fe ff ff       	call   800391 <printfmt>
  800500:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800503:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800506:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800509:	e9 c6 fe ff ff       	jmp    8003d4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80050e:	52                   	push   %edx
  80050f:	68 15 2e 80 00       	push   $0x802e15
  800514:	53                   	push   %ebx
  800515:	56                   	push   %esi
  800516:	e8 76 fe ff ff       	call   800391 <printfmt>
  80051b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80051e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800521:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800524:	e9 ab fe ff ff       	jmp    8003d4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800529:	8b 45 14             	mov    0x14(%ebp),%eax
  80052c:	83 c0 04             	add    $0x4,%eax
  80052f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800532:	8b 45 14             	mov    0x14(%ebp),%eax
  800535:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800537:	85 ff                	test   %edi,%edi
  800539:	b8 ac 29 80 00       	mov    $0x8029ac,%eax
  80053e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800541:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800545:	0f 8e 94 00 00 00    	jle    8005df <vprintfmt+0x231>
  80054b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80054f:	0f 84 98 00 00 00    	je     8005ed <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	ff 75 d0             	pushl  -0x30(%ebp)
  80055b:	57                   	push   %edi
  80055c:	e8 33 03 00 00       	call   800894 <strnlen>
  800561:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800564:	29 c1                	sub    %eax,%ecx
  800566:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800569:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80056c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800570:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800573:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800576:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800578:	eb 0f                	jmp    800589 <vprintfmt+0x1db>
					putch(padc, putdat);
  80057a:	83 ec 08             	sub    $0x8,%esp
  80057d:	53                   	push   %ebx
  80057e:	ff 75 e0             	pushl  -0x20(%ebp)
  800581:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800583:	83 ef 01             	sub    $0x1,%edi
  800586:	83 c4 10             	add    $0x10,%esp
  800589:	85 ff                	test   %edi,%edi
  80058b:	7f ed                	jg     80057a <vprintfmt+0x1cc>
  80058d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800590:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800593:	85 c9                	test   %ecx,%ecx
  800595:	b8 00 00 00 00       	mov    $0x0,%eax
  80059a:	0f 49 c1             	cmovns %ecx,%eax
  80059d:	29 c1                	sub    %eax,%ecx
  80059f:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a8:	89 cb                	mov    %ecx,%ebx
  8005aa:	eb 4d                	jmp    8005f9 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b0:	74 1b                	je     8005cd <vprintfmt+0x21f>
  8005b2:	0f be c0             	movsbl %al,%eax
  8005b5:	83 e8 20             	sub    $0x20,%eax
  8005b8:	83 f8 5e             	cmp    $0x5e,%eax
  8005bb:	76 10                	jbe    8005cd <vprintfmt+0x21f>
					putch('?', putdat);
  8005bd:	83 ec 08             	sub    $0x8,%esp
  8005c0:	ff 75 0c             	pushl  0xc(%ebp)
  8005c3:	6a 3f                	push   $0x3f
  8005c5:	ff 55 08             	call   *0x8(%ebp)
  8005c8:	83 c4 10             	add    $0x10,%esp
  8005cb:	eb 0d                	jmp    8005da <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	ff 75 0c             	pushl  0xc(%ebp)
  8005d3:	52                   	push   %edx
  8005d4:	ff 55 08             	call   *0x8(%ebp)
  8005d7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005da:	83 eb 01             	sub    $0x1,%ebx
  8005dd:	eb 1a                	jmp    8005f9 <vprintfmt+0x24b>
  8005df:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005eb:	eb 0c                	jmp    8005f9 <vprintfmt+0x24b>
  8005ed:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f9:	83 c7 01             	add    $0x1,%edi
  8005fc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800600:	0f be d0             	movsbl %al,%edx
  800603:	85 d2                	test   %edx,%edx
  800605:	74 23                	je     80062a <vprintfmt+0x27c>
  800607:	85 f6                	test   %esi,%esi
  800609:	78 a1                	js     8005ac <vprintfmt+0x1fe>
  80060b:	83 ee 01             	sub    $0x1,%esi
  80060e:	79 9c                	jns    8005ac <vprintfmt+0x1fe>
  800610:	89 df                	mov    %ebx,%edi
  800612:	8b 75 08             	mov    0x8(%ebp),%esi
  800615:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800618:	eb 18                	jmp    800632 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80061a:	83 ec 08             	sub    $0x8,%esp
  80061d:	53                   	push   %ebx
  80061e:	6a 20                	push   $0x20
  800620:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800622:	83 ef 01             	sub    $0x1,%edi
  800625:	83 c4 10             	add    $0x10,%esp
  800628:	eb 08                	jmp    800632 <vprintfmt+0x284>
  80062a:	89 df                	mov    %ebx,%edi
  80062c:	8b 75 08             	mov    0x8(%ebp),%esi
  80062f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800632:	85 ff                	test   %edi,%edi
  800634:	7f e4                	jg     80061a <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800636:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800639:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063f:	e9 90 fd ff ff       	jmp    8003d4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800644:	83 f9 01             	cmp    $0x1,%ecx
  800647:	7e 19                	jle    800662 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8b 50 04             	mov    0x4(%eax),%edx
  80064f:	8b 00                	mov    (%eax),%eax
  800651:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800654:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 40 08             	lea    0x8(%eax),%eax
  80065d:	89 45 14             	mov    %eax,0x14(%ebp)
  800660:	eb 38                	jmp    80069a <vprintfmt+0x2ec>
	else if (lflag)
  800662:	85 c9                	test   %ecx,%ecx
  800664:	74 1b                	je     800681 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8b 00                	mov    (%eax),%eax
  80066b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066e:	89 c1                	mov    %eax,%ecx
  800670:	c1 f9 1f             	sar    $0x1f,%ecx
  800673:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800676:	8b 45 14             	mov    0x14(%ebp),%eax
  800679:	8d 40 04             	lea    0x4(%eax),%eax
  80067c:	89 45 14             	mov    %eax,0x14(%ebp)
  80067f:	eb 19                	jmp    80069a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8b 00                	mov    (%eax),%eax
  800686:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800689:	89 c1                	mov    %eax,%ecx
  80068b:	c1 f9 1f             	sar    $0x1f,%ecx
  80068e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8d 40 04             	lea    0x4(%eax),%eax
  800697:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80069a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80069d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006a0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006a5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a9:	0f 89 0e 01 00 00    	jns    8007bd <vprintfmt+0x40f>
				putch('-', putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	6a 2d                	push   $0x2d
  8006b5:	ff d6                	call   *%esi
				num = -(long long) num;
  8006b7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006bd:	f7 da                	neg    %edx
  8006bf:	83 d1 00             	adc    $0x0,%ecx
  8006c2:	f7 d9                	neg    %ecx
  8006c4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006cc:	e9 ec 00 00 00       	jmp    8007bd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d1:	83 f9 01             	cmp    $0x1,%ecx
  8006d4:	7e 18                	jle    8006ee <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8b 10                	mov    (%eax),%edx
  8006db:	8b 48 04             	mov    0x4(%eax),%ecx
  8006de:	8d 40 08             	lea    0x8(%eax),%eax
  8006e1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006e4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e9:	e9 cf 00 00 00       	jmp    8007bd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006ee:	85 c9                	test   %ecx,%ecx
  8006f0:	74 1a                	je     80070c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8b 10                	mov    (%eax),%edx
  8006f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fc:	8d 40 04             	lea    0x4(%eax),%eax
  8006ff:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800702:	b8 0a 00 00 00       	mov    $0xa,%eax
  800707:	e9 b1 00 00 00       	jmp    8007bd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80070c:	8b 45 14             	mov    0x14(%ebp),%eax
  80070f:	8b 10                	mov    (%eax),%edx
  800711:	b9 00 00 00 00       	mov    $0x0,%ecx
  800716:	8d 40 04             	lea    0x4(%eax),%eax
  800719:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80071c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800721:	e9 97 00 00 00       	jmp    8007bd <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800726:	83 ec 08             	sub    $0x8,%esp
  800729:	53                   	push   %ebx
  80072a:	6a 58                	push   $0x58
  80072c:	ff d6                	call   *%esi
			putch('X', putdat);
  80072e:	83 c4 08             	add    $0x8,%esp
  800731:	53                   	push   %ebx
  800732:	6a 58                	push   $0x58
  800734:	ff d6                	call   *%esi
			putch('X', putdat);
  800736:	83 c4 08             	add    $0x8,%esp
  800739:	53                   	push   %ebx
  80073a:	6a 58                	push   $0x58
  80073c:	ff d6                	call   *%esi
			break;
  80073e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800741:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800744:	e9 8b fc ff ff       	jmp    8003d4 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800749:	83 ec 08             	sub    $0x8,%esp
  80074c:	53                   	push   %ebx
  80074d:	6a 30                	push   $0x30
  80074f:	ff d6                	call   *%esi
			putch('x', putdat);
  800751:	83 c4 08             	add    $0x8,%esp
  800754:	53                   	push   %ebx
  800755:	6a 78                	push   $0x78
  800757:	ff d6                	call   *%esi
			num = (unsigned long long)
  800759:	8b 45 14             	mov    0x14(%ebp),%eax
  80075c:	8b 10                	mov    (%eax),%edx
  80075e:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800763:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800766:	8d 40 04             	lea    0x4(%eax),%eax
  800769:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80076c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800771:	eb 4a                	jmp    8007bd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800773:	83 f9 01             	cmp    $0x1,%ecx
  800776:	7e 15                	jle    80078d <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800778:	8b 45 14             	mov    0x14(%ebp),%eax
  80077b:	8b 10                	mov    (%eax),%edx
  80077d:	8b 48 04             	mov    0x4(%eax),%ecx
  800780:	8d 40 08             	lea    0x8(%eax),%eax
  800783:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800786:	b8 10 00 00 00       	mov    $0x10,%eax
  80078b:	eb 30                	jmp    8007bd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80078d:	85 c9                	test   %ecx,%ecx
  80078f:	74 17                	je     8007a8 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8b 10                	mov    (%eax),%edx
  800796:	b9 00 00 00 00       	mov    $0x0,%ecx
  80079b:	8d 40 04             	lea    0x4(%eax),%eax
  80079e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007a1:	b8 10 00 00 00       	mov    $0x10,%eax
  8007a6:	eb 15                	jmp    8007bd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8007a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ab:	8b 10                	mov    (%eax),%edx
  8007ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b2:	8d 40 04             	lea    0x4(%eax),%eax
  8007b5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007b8:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007bd:	83 ec 0c             	sub    $0xc,%esp
  8007c0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007c4:	57                   	push   %edi
  8007c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8007c8:	50                   	push   %eax
  8007c9:	51                   	push   %ecx
  8007ca:	52                   	push   %edx
  8007cb:	89 da                	mov    %ebx,%edx
  8007cd:	89 f0                	mov    %esi,%eax
  8007cf:	e8 f1 fa ff ff       	call   8002c5 <printnum>
			break;
  8007d4:	83 c4 20             	add    $0x20,%esp
  8007d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007da:	e9 f5 fb ff ff       	jmp    8003d4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	53                   	push   %ebx
  8007e3:	52                   	push   %edx
  8007e4:	ff d6                	call   *%esi
			break;
  8007e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ec:	e9 e3 fb ff ff       	jmp    8003d4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f1:	83 ec 08             	sub    $0x8,%esp
  8007f4:	53                   	push   %ebx
  8007f5:	6a 25                	push   $0x25
  8007f7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f9:	83 c4 10             	add    $0x10,%esp
  8007fc:	eb 03                	jmp    800801 <vprintfmt+0x453>
  8007fe:	83 ef 01             	sub    $0x1,%edi
  800801:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800805:	75 f7                	jne    8007fe <vprintfmt+0x450>
  800807:	e9 c8 fb ff ff       	jmp    8003d4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80080c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80080f:	5b                   	pop    %ebx
  800810:	5e                   	pop    %esi
  800811:	5f                   	pop    %edi
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	83 ec 18             	sub    $0x18,%esp
  80081a:	8b 45 08             	mov    0x8(%ebp),%eax
  80081d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800820:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800823:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800827:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80082a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800831:	85 c0                	test   %eax,%eax
  800833:	74 26                	je     80085b <vsnprintf+0x47>
  800835:	85 d2                	test   %edx,%edx
  800837:	7e 22                	jle    80085b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800839:	ff 75 14             	pushl  0x14(%ebp)
  80083c:	ff 75 10             	pushl  0x10(%ebp)
  80083f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800842:	50                   	push   %eax
  800843:	68 74 03 80 00       	push   $0x800374
  800848:	e8 61 fb ff ff       	call   8003ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80084d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800850:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800853:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800856:	83 c4 10             	add    $0x10,%esp
  800859:	eb 05                	jmp    800860 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80085b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800860:	c9                   	leave  
  800861:	c3                   	ret    

00800862 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800868:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80086b:	50                   	push   %eax
  80086c:	ff 75 10             	pushl  0x10(%ebp)
  80086f:	ff 75 0c             	pushl  0xc(%ebp)
  800872:	ff 75 08             	pushl  0x8(%ebp)
  800875:	e8 9a ff ff ff       	call   800814 <vsnprintf>
	va_end(ap);

	return rc;
}
  80087a:	c9                   	leave  
  80087b:	c3                   	ret    

0080087c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800882:	b8 00 00 00 00       	mov    $0x0,%eax
  800887:	eb 03                	jmp    80088c <strlen+0x10>
		n++;
  800889:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80088c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800890:	75 f7                	jne    800889 <strlen+0xd>
		n++;
	return n;
}
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089d:	ba 00 00 00 00       	mov    $0x0,%edx
  8008a2:	eb 03                	jmp    8008a7 <strnlen+0x13>
		n++;
  8008a4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a7:	39 c2                	cmp    %eax,%edx
  8008a9:	74 08                	je     8008b3 <strnlen+0x1f>
  8008ab:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008af:	75 f3                	jne    8008a4 <strnlen+0x10>
  8008b1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	53                   	push   %ebx
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008bf:	89 c2                	mov    %eax,%edx
  8008c1:	83 c2 01             	add    $0x1,%edx
  8008c4:	83 c1 01             	add    $0x1,%ecx
  8008c7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008cb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008ce:	84 db                	test   %bl,%bl
  8008d0:	75 ef                	jne    8008c1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008d2:	5b                   	pop    %ebx
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	53                   	push   %ebx
  8008d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008dc:	53                   	push   %ebx
  8008dd:	e8 9a ff ff ff       	call   80087c <strlen>
  8008e2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008e5:	ff 75 0c             	pushl  0xc(%ebp)
  8008e8:	01 d8                	add    %ebx,%eax
  8008ea:	50                   	push   %eax
  8008eb:	e8 c5 ff ff ff       	call   8008b5 <strcpy>
	return dst;
}
  8008f0:	89 d8                	mov    %ebx,%eax
  8008f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f5:	c9                   	leave  
  8008f6:	c3                   	ret    

008008f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	56                   	push   %esi
  8008fb:	53                   	push   %ebx
  8008fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800902:	89 f3                	mov    %esi,%ebx
  800904:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800907:	89 f2                	mov    %esi,%edx
  800909:	eb 0f                	jmp    80091a <strncpy+0x23>
		*dst++ = *src;
  80090b:	83 c2 01             	add    $0x1,%edx
  80090e:	0f b6 01             	movzbl (%ecx),%eax
  800911:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800914:	80 39 01             	cmpb   $0x1,(%ecx)
  800917:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80091a:	39 da                	cmp    %ebx,%edx
  80091c:	75 ed                	jne    80090b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80091e:	89 f0                	mov    %esi,%eax
  800920:	5b                   	pop    %ebx
  800921:	5e                   	pop    %esi
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	56                   	push   %esi
  800928:	53                   	push   %ebx
  800929:	8b 75 08             	mov    0x8(%ebp),%esi
  80092c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092f:	8b 55 10             	mov    0x10(%ebp),%edx
  800932:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800934:	85 d2                	test   %edx,%edx
  800936:	74 21                	je     800959 <strlcpy+0x35>
  800938:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80093c:	89 f2                	mov    %esi,%edx
  80093e:	eb 09                	jmp    800949 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800940:	83 c2 01             	add    $0x1,%edx
  800943:	83 c1 01             	add    $0x1,%ecx
  800946:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800949:	39 c2                	cmp    %eax,%edx
  80094b:	74 09                	je     800956 <strlcpy+0x32>
  80094d:	0f b6 19             	movzbl (%ecx),%ebx
  800950:	84 db                	test   %bl,%bl
  800952:	75 ec                	jne    800940 <strlcpy+0x1c>
  800954:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800956:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800959:	29 f0                	sub    %esi,%eax
}
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800965:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800968:	eb 06                	jmp    800970 <strcmp+0x11>
		p++, q++;
  80096a:	83 c1 01             	add    $0x1,%ecx
  80096d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800970:	0f b6 01             	movzbl (%ecx),%eax
  800973:	84 c0                	test   %al,%al
  800975:	74 04                	je     80097b <strcmp+0x1c>
  800977:	3a 02                	cmp    (%edx),%al
  800979:	74 ef                	je     80096a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80097b:	0f b6 c0             	movzbl %al,%eax
  80097e:	0f b6 12             	movzbl (%edx),%edx
  800981:	29 d0                	sub    %edx,%eax
}
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	53                   	push   %ebx
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098f:	89 c3                	mov    %eax,%ebx
  800991:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800994:	eb 06                	jmp    80099c <strncmp+0x17>
		n--, p++, q++;
  800996:	83 c0 01             	add    $0x1,%eax
  800999:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80099c:	39 d8                	cmp    %ebx,%eax
  80099e:	74 15                	je     8009b5 <strncmp+0x30>
  8009a0:	0f b6 08             	movzbl (%eax),%ecx
  8009a3:	84 c9                	test   %cl,%cl
  8009a5:	74 04                	je     8009ab <strncmp+0x26>
  8009a7:	3a 0a                	cmp    (%edx),%cl
  8009a9:	74 eb                	je     800996 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ab:	0f b6 00             	movzbl (%eax),%eax
  8009ae:	0f b6 12             	movzbl (%edx),%edx
  8009b1:	29 d0                	sub    %edx,%eax
  8009b3:	eb 05                	jmp    8009ba <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009b5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009ba:	5b                   	pop    %ebx
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c7:	eb 07                	jmp    8009d0 <strchr+0x13>
		if (*s == c)
  8009c9:	38 ca                	cmp    %cl,%dl
  8009cb:	74 0f                	je     8009dc <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009cd:	83 c0 01             	add    $0x1,%eax
  8009d0:	0f b6 10             	movzbl (%eax),%edx
  8009d3:	84 d2                	test   %dl,%dl
  8009d5:	75 f2                	jne    8009c9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e8:	eb 03                	jmp    8009ed <strfind+0xf>
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009f0:	38 ca                	cmp    %cl,%dl
  8009f2:	74 04                	je     8009f8 <strfind+0x1a>
  8009f4:	84 d2                	test   %dl,%dl
  8009f6:	75 f2                	jne    8009ea <strfind+0xc>
			break;
	return (char *) s;
}
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	57                   	push   %edi
  8009fe:	56                   	push   %esi
  8009ff:	53                   	push   %ebx
  800a00:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a03:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a06:	85 c9                	test   %ecx,%ecx
  800a08:	74 36                	je     800a40 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a0a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a10:	75 28                	jne    800a3a <memset+0x40>
  800a12:	f6 c1 03             	test   $0x3,%cl
  800a15:	75 23                	jne    800a3a <memset+0x40>
		c &= 0xFF;
  800a17:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a1b:	89 d3                	mov    %edx,%ebx
  800a1d:	c1 e3 08             	shl    $0x8,%ebx
  800a20:	89 d6                	mov    %edx,%esi
  800a22:	c1 e6 18             	shl    $0x18,%esi
  800a25:	89 d0                	mov    %edx,%eax
  800a27:	c1 e0 10             	shl    $0x10,%eax
  800a2a:	09 f0                	or     %esi,%eax
  800a2c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a2e:	89 d8                	mov    %ebx,%eax
  800a30:	09 d0                	or     %edx,%eax
  800a32:	c1 e9 02             	shr    $0x2,%ecx
  800a35:	fc                   	cld    
  800a36:	f3 ab                	rep stos %eax,%es:(%edi)
  800a38:	eb 06                	jmp    800a40 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3d:	fc                   	cld    
  800a3e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a40:	89 f8                	mov    %edi,%eax
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	57                   	push   %edi
  800a4b:	56                   	push   %esi
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a52:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a55:	39 c6                	cmp    %eax,%esi
  800a57:	73 35                	jae    800a8e <memmove+0x47>
  800a59:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a5c:	39 d0                	cmp    %edx,%eax
  800a5e:	73 2e                	jae    800a8e <memmove+0x47>
		s += n;
		d += n;
  800a60:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a63:	89 d6                	mov    %edx,%esi
  800a65:	09 fe                	or     %edi,%esi
  800a67:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a6d:	75 13                	jne    800a82 <memmove+0x3b>
  800a6f:	f6 c1 03             	test   $0x3,%cl
  800a72:	75 0e                	jne    800a82 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a74:	83 ef 04             	sub    $0x4,%edi
  800a77:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a7a:	c1 e9 02             	shr    $0x2,%ecx
  800a7d:	fd                   	std    
  800a7e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a80:	eb 09                	jmp    800a8b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a82:	83 ef 01             	sub    $0x1,%edi
  800a85:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a88:	fd                   	std    
  800a89:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8b:	fc                   	cld    
  800a8c:	eb 1d                	jmp    800aab <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8e:	89 f2                	mov    %esi,%edx
  800a90:	09 c2                	or     %eax,%edx
  800a92:	f6 c2 03             	test   $0x3,%dl
  800a95:	75 0f                	jne    800aa6 <memmove+0x5f>
  800a97:	f6 c1 03             	test   $0x3,%cl
  800a9a:	75 0a                	jne    800aa6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a9c:	c1 e9 02             	shr    $0x2,%ecx
  800a9f:	89 c7                	mov    %eax,%edi
  800aa1:	fc                   	cld    
  800aa2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa4:	eb 05                	jmp    800aab <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa6:	89 c7                	mov    %eax,%edi
  800aa8:	fc                   	cld    
  800aa9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aab:	5e                   	pop    %esi
  800aac:	5f                   	pop    %edi
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ab2:	ff 75 10             	pushl  0x10(%ebp)
  800ab5:	ff 75 0c             	pushl  0xc(%ebp)
  800ab8:	ff 75 08             	pushl  0x8(%ebp)
  800abb:	e8 87 ff ff ff       	call   800a47 <memmove>
}
  800ac0:	c9                   	leave  
  800ac1:	c3                   	ret    

00800ac2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	56                   	push   %esi
  800ac6:	53                   	push   %ebx
  800ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aca:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acd:	89 c6                	mov    %eax,%esi
  800acf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad2:	eb 1a                	jmp    800aee <memcmp+0x2c>
		if (*s1 != *s2)
  800ad4:	0f b6 08             	movzbl (%eax),%ecx
  800ad7:	0f b6 1a             	movzbl (%edx),%ebx
  800ada:	38 d9                	cmp    %bl,%cl
  800adc:	74 0a                	je     800ae8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ade:	0f b6 c1             	movzbl %cl,%eax
  800ae1:	0f b6 db             	movzbl %bl,%ebx
  800ae4:	29 d8                	sub    %ebx,%eax
  800ae6:	eb 0f                	jmp    800af7 <memcmp+0x35>
		s1++, s2++;
  800ae8:	83 c0 01             	add    $0x1,%eax
  800aeb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aee:	39 f0                	cmp    %esi,%eax
  800af0:	75 e2                	jne    800ad4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800af2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	53                   	push   %ebx
  800aff:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b02:	89 c1                	mov    %eax,%ecx
  800b04:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b07:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b0b:	eb 0a                	jmp    800b17 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b0d:	0f b6 10             	movzbl (%eax),%edx
  800b10:	39 da                	cmp    %ebx,%edx
  800b12:	74 07                	je     800b1b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b14:	83 c0 01             	add    $0x1,%eax
  800b17:	39 c8                	cmp    %ecx,%eax
  800b19:	72 f2                	jb     800b0d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b1b:	5b                   	pop    %ebx
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
  800b24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2a:	eb 03                	jmp    800b2f <strtol+0x11>
		s++;
  800b2c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2f:	0f b6 01             	movzbl (%ecx),%eax
  800b32:	3c 20                	cmp    $0x20,%al
  800b34:	74 f6                	je     800b2c <strtol+0xe>
  800b36:	3c 09                	cmp    $0x9,%al
  800b38:	74 f2                	je     800b2c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b3a:	3c 2b                	cmp    $0x2b,%al
  800b3c:	75 0a                	jne    800b48 <strtol+0x2a>
		s++;
  800b3e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b41:	bf 00 00 00 00       	mov    $0x0,%edi
  800b46:	eb 11                	jmp    800b59 <strtol+0x3b>
  800b48:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b4d:	3c 2d                	cmp    $0x2d,%al
  800b4f:	75 08                	jne    800b59 <strtol+0x3b>
		s++, neg = 1;
  800b51:	83 c1 01             	add    $0x1,%ecx
  800b54:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b59:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b5f:	75 15                	jne    800b76 <strtol+0x58>
  800b61:	80 39 30             	cmpb   $0x30,(%ecx)
  800b64:	75 10                	jne    800b76 <strtol+0x58>
  800b66:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b6a:	75 7c                	jne    800be8 <strtol+0xca>
		s += 2, base = 16;
  800b6c:	83 c1 02             	add    $0x2,%ecx
  800b6f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b74:	eb 16                	jmp    800b8c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b76:	85 db                	test   %ebx,%ebx
  800b78:	75 12                	jne    800b8c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b7a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b7f:	80 39 30             	cmpb   $0x30,(%ecx)
  800b82:	75 08                	jne    800b8c <strtol+0x6e>
		s++, base = 8;
  800b84:	83 c1 01             	add    $0x1,%ecx
  800b87:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b91:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b94:	0f b6 11             	movzbl (%ecx),%edx
  800b97:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b9a:	89 f3                	mov    %esi,%ebx
  800b9c:	80 fb 09             	cmp    $0x9,%bl
  800b9f:	77 08                	ja     800ba9 <strtol+0x8b>
			dig = *s - '0';
  800ba1:	0f be d2             	movsbl %dl,%edx
  800ba4:	83 ea 30             	sub    $0x30,%edx
  800ba7:	eb 22                	jmp    800bcb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ba9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bac:	89 f3                	mov    %esi,%ebx
  800bae:	80 fb 19             	cmp    $0x19,%bl
  800bb1:	77 08                	ja     800bbb <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bb3:	0f be d2             	movsbl %dl,%edx
  800bb6:	83 ea 57             	sub    $0x57,%edx
  800bb9:	eb 10                	jmp    800bcb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bbb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bbe:	89 f3                	mov    %esi,%ebx
  800bc0:	80 fb 19             	cmp    $0x19,%bl
  800bc3:	77 16                	ja     800bdb <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bc5:	0f be d2             	movsbl %dl,%edx
  800bc8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bcb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bce:	7d 0b                	jge    800bdb <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bd0:	83 c1 01             	add    $0x1,%ecx
  800bd3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bd7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bd9:	eb b9                	jmp    800b94 <strtol+0x76>

	if (endptr)
  800bdb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bdf:	74 0d                	je     800bee <strtol+0xd0>
		*endptr = (char *) s;
  800be1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be4:	89 0e                	mov    %ecx,(%esi)
  800be6:	eb 06                	jmp    800bee <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800be8:	85 db                	test   %ebx,%ebx
  800bea:	74 98                	je     800b84 <strtol+0x66>
  800bec:	eb 9e                	jmp    800b8c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bee:	89 c2                	mov    %eax,%edx
  800bf0:	f7 da                	neg    %edx
  800bf2:	85 ff                	test   %edi,%edi
  800bf4:	0f 45 c2             	cmovne %edx,%eax
}
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c02:	b8 00 00 00 00       	mov    $0x0,%eax
  800c07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0d:	89 c3                	mov    %eax,%ebx
  800c0f:	89 c7                	mov    %eax,%edi
  800c11:	89 c6                	mov    %eax,%esi
  800c13:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <sys_cgetc>:

int
sys_cgetc(void)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c20:	ba 00 00 00 00       	mov    $0x0,%edx
  800c25:	b8 01 00 00 00       	mov    $0x1,%eax
  800c2a:	89 d1                	mov    %edx,%ecx
  800c2c:	89 d3                	mov    %edx,%ebx
  800c2e:	89 d7                	mov    %edx,%edi
  800c30:	89 d6                	mov    %edx,%esi
  800c32:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c47:	b8 03 00 00 00       	mov    $0x3,%eax
  800c4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4f:	89 cb                	mov    %ecx,%ebx
  800c51:	89 cf                	mov    %ecx,%edi
  800c53:	89 ce                	mov    %ecx,%esi
  800c55:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c57:	85 c0                	test   %eax,%eax
  800c59:	7e 17                	jle    800c72 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5b:	83 ec 0c             	sub    $0xc,%esp
  800c5e:	50                   	push   %eax
  800c5f:	6a 03                	push   $0x3
  800c61:	68 9f 2c 80 00       	push   $0x802c9f
  800c66:	6a 23                	push   $0x23
  800c68:	68 bc 2c 80 00       	push   $0x802cbc
  800c6d:	e8 66 f5 ff ff       	call   8001d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c80:	ba 00 00 00 00       	mov    $0x0,%edx
  800c85:	b8 02 00 00 00       	mov    $0x2,%eax
  800c8a:	89 d1                	mov    %edx,%ecx
  800c8c:	89 d3                	mov    %edx,%ebx
  800c8e:	89 d7                	mov    %edx,%edi
  800c90:	89 d6                	mov    %edx,%esi
  800c92:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_yield>:

void
sys_yield(void)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca9:	89 d1                	mov    %edx,%ecx
  800cab:	89 d3                	mov    %edx,%ebx
  800cad:	89 d7                	mov    %edx,%edi
  800caf:	89 d6                	mov    %edx,%esi
  800cb1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    

00800cb8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	57                   	push   %edi
  800cbc:	56                   	push   %esi
  800cbd:	53                   	push   %ebx
  800cbe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc1:	be 00 00 00 00       	mov    $0x0,%esi
  800cc6:	b8 04 00 00 00       	mov    $0x4,%eax
  800ccb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd4:	89 f7                	mov    %esi,%edi
  800cd6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd8:	85 c0                	test   %eax,%eax
  800cda:	7e 17                	jle    800cf3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdc:	83 ec 0c             	sub    $0xc,%esp
  800cdf:	50                   	push   %eax
  800ce0:	6a 04                	push   $0x4
  800ce2:	68 9f 2c 80 00       	push   $0x802c9f
  800ce7:	6a 23                	push   $0x23
  800ce9:	68 bc 2c 80 00       	push   $0x802cbc
  800cee:	e8 e5 f4 ff ff       	call   8001d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d04:	b8 05 00 00 00       	mov    $0x5,%eax
  800d09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d12:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d15:	8b 75 18             	mov    0x18(%ebp),%esi
  800d18:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	7e 17                	jle    800d35 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1e:	83 ec 0c             	sub    $0xc,%esp
  800d21:	50                   	push   %eax
  800d22:	6a 05                	push   $0x5
  800d24:	68 9f 2c 80 00       	push   $0x802c9f
  800d29:	6a 23                	push   $0x23
  800d2b:	68 bc 2c 80 00       	push   $0x802cbc
  800d30:	e8 a3 f4 ff ff       	call   8001d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
  800d43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4b:	b8 06 00 00 00       	mov    $0x6,%eax
  800d50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
  800d56:	89 df                	mov    %ebx,%edi
  800d58:	89 de                	mov    %ebx,%esi
  800d5a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	7e 17                	jle    800d77 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d60:	83 ec 0c             	sub    $0xc,%esp
  800d63:	50                   	push   %eax
  800d64:	6a 06                	push   $0x6
  800d66:	68 9f 2c 80 00       	push   $0x802c9f
  800d6b:	6a 23                	push   $0x23
  800d6d:	68 bc 2c 80 00       	push   $0x802cbc
  800d72:	e8 61 f4 ff ff       	call   8001d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	57                   	push   %edi
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
  800d85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	8b 55 08             	mov    0x8(%ebp),%edx
  800d98:	89 df                	mov    %ebx,%edi
  800d9a:	89 de                	mov    %ebx,%esi
  800d9c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d9e:	85 c0                	test   %eax,%eax
  800da0:	7e 17                	jle    800db9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da2:	83 ec 0c             	sub    $0xc,%esp
  800da5:	50                   	push   %eax
  800da6:	6a 08                	push   $0x8
  800da8:	68 9f 2c 80 00       	push   $0x802c9f
  800dad:	6a 23                	push   $0x23
  800daf:	68 bc 2c 80 00       	push   $0x802cbc
  800db4:	e8 1f f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800db9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbc:	5b                   	pop    %ebx
  800dbd:	5e                   	pop    %esi
  800dbe:	5f                   	pop    %edi
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    

00800dc1 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	57                   	push   %edi
  800dc5:	56                   	push   %esi
  800dc6:	53                   	push   %ebx
  800dc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcf:	b8 09 00 00 00       	mov    $0x9,%eax
  800dd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dda:	89 df                	mov    %ebx,%edi
  800ddc:	89 de                	mov    %ebx,%esi
  800dde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de0:	85 c0                	test   %eax,%eax
  800de2:	7e 17                	jle    800dfb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de4:	83 ec 0c             	sub    $0xc,%esp
  800de7:	50                   	push   %eax
  800de8:	6a 09                	push   $0x9
  800dea:	68 9f 2c 80 00       	push   $0x802c9f
  800def:	6a 23                	push   $0x23
  800df1:	68 bc 2c 80 00       	push   $0x802cbc
  800df6:	e8 dd f3 ff ff       	call   8001d8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfe:	5b                   	pop    %ebx
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    

00800e03 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	57                   	push   %edi
  800e07:	56                   	push   %esi
  800e08:	53                   	push   %ebx
  800e09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e11:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e19:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1c:	89 df                	mov    %ebx,%edi
  800e1e:	89 de                	mov    %ebx,%esi
  800e20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e22:	85 c0                	test   %eax,%eax
  800e24:	7e 17                	jle    800e3d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e26:	83 ec 0c             	sub    $0xc,%esp
  800e29:	50                   	push   %eax
  800e2a:	6a 0a                	push   $0xa
  800e2c:	68 9f 2c 80 00       	push   $0x802c9f
  800e31:	6a 23                	push   $0x23
  800e33:	68 bc 2c 80 00       	push   $0x802cbc
  800e38:	e8 9b f3 ff ff       	call   8001d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    

00800e45 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	57                   	push   %edi
  800e49:	56                   	push   %esi
  800e4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4b:	be 00 00 00 00       	mov    $0x0,%esi
  800e50:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e58:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e61:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5f                   	pop    %edi
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    

00800e68 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	57                   	push   %edi
  800e6c:	56                   	push   %esi
  800e6d:	53                   	push   %ebx
  800e6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e71:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e76:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7e:	89 cb                	mov    %ecx,%ebx
  800e80:	89 cf                	mov    %ecx,%edi
  800e82:	89 ce                	mov    %ecx,%esi
  800e84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e86:	85 c0                	test   %eax,%eax
  800e88:	7e 17                	jle    800ea1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8a:	83 ec 0c             	sub    $0xc,%esp
  800e8d:	50                   	push   %eax
  800e8e:	6a 0d                	push   $0xd
  800e90:	68 9f 2c 80 00       	push   $0x802c9f
  800e95:	6a 23                	push   $0x23
  800e97:	68 bc 2c 80 00       	push   $0x802cbc
  800e9c:	e8 37 f3 ff ff       	call   8001d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ea1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	53                   	push   %ebx
  800ead:	83 ec 04             	sub    $0x4,%esp
  800eb0:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eb3:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800eb5:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800eb9:	74 2d                	je     800ee8 <pgfault+0x3f>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800ebb:	89 d8                	mov    %ebx,%eax
  800ebd:	c1 e8 16             	shr    $0x16,%eax
  800ec0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ec7:	a8 01                	test   $0x1,%al
  800ec9:	74 1d                	je     800ee8 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800ecb:	89 d8                	mov    %ebx,%eax
  800ecd:	c1 e8 0c             	shr    $0xc,%eax
  800ed0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800ed7:	f6 c2 01             	test   $0x1,%dl
  800eda:	74 0c                	je     800ee8 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800edc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800ee3:	f6 c4 08             	test   $0x8,%ah
  800ee6:	75 14                	jne    800efc <pgfault+0x53>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
	)) panic("Neither the fault is a write nor copy-on-write page.\n");
  800ee8:	83 ec 04             	sub    $0x4,%esp
  800eeb:	68 cc 2c 80 00       	push   $0x802ccc
  800ef0:	6a 1f                	push   $0x1f
  800ef2:	68 02 2d 80 00       	push   $0x802d02
  800ef7:	e8 dc f2 ff ff       	call   8001d8 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if((r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W)) < 0){
  800efc:	83 ec 04             	sub    $0x4,%esp
  800eff:	6a 07                	push   $0x7
  800f01:	68 00 f0 7f 00       	push   $0x7ff000
  800f06:	6a 00                	push   $0x0
  800f08:	e8 ab fd ff ff       	call   800cb8 <sys_page_alloc>
  800f0d:	83 c4 10             	add    $0x10,%esp
  800f10:	85 c0                	test   %eax,%eax
  800f12:	79 12                	jns    800f26 <pgfault+0x7d>
		 panic("sys_page_alloc: %e\n", r);
  800f14:	50                   	push   %eax
  800f15:	68 0d 2d 80 00       	push   $0x802d0d
  800f1a:	6a 29                	push   $0x29
  800f1c:	68 02 2d 80 00       	push   $0x802d02
  800f21:	e8 b2 f2 ff ff       	call   8001d8 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f26:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800f2c:	83 ec 04             	sub    $0x4,%esp
  800f2f:	68 00 10 00 00       	push   $0x1000
  800f34:	53                   	push   %ebx
  800f35:	68 00 f0 7f 00       	push   $0x7ff000
  800f3a:	e8 70 fb ff ff       	call   800aaf <memcpy>
	if ((r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  800f3f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f46:	53                   	push   %ebx
  800f47:	6a 00                	push   $0x0
  800f49:	68 00 f0 7f 00       	push   $0x7ff000
  800f4e:	6a 00                	push   $0x0
  800f50:	e8 a6 fd ff ff       	call   800cfb <sys_page_map>
  800f55:	83 c4 20             	add    $0x20,%esp
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	79 12                	jns    800f6e <pgfault+0xc5>
        panic("sys_page_map: %e\n", r);
  800f5c:	50                   	push   %eax
  800f5d:	68 21 2d 80 00       	push   $0x802d21
  800f62:	6a 2e                	push   $0x2e
  800f64:	68 02 2d 80 00       	push   $0x802d02
  800f69:	e8 6a f2 ff ff       	call   8001d8 <_panic>
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  800f6e:	83 ec 08             	sub    $0x8,%esp
  800f71:	68 00 f0 7f 00       	push   $0x7ff000
  800f76:	6a 00                	push   $0x0
  800f78:	e8 c0 fd ff ff       	call   800d3d <sys_page_unmap>
  800f7d:	83 c4 10             	add    $0x10,%esp
  800f80:	85 c0                	test   %eax,%eax
  800f82:	79 12                	jns    800f96 <pgfault+0xed>
        panic("sys_page_unmap: %e\n", r);
  800f84:	50                   	push   %eax
  800f85:	68 33 2d 80 00       	push   $0x802d33
  800f8a:	6a 30                	push   $0x30
  800f8c:	68 02 2d 80 00       	push   $0x802d02
  800f91:	e8 42 f2 ff ff       	call   8001d8 <_panic>
	//panic("pgfault not implemented");
}
  800f96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f99:	c9                   	leave  
  800f9a:	c3                   	ret    

00800f9b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	57                   	push   %edi
  800f9f:	56                   	push   %esi
  800fa0:	53                   	push   %ebx
  800fa1:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	envid_t cenvid;
    unsigned pn;
    int r;
	set_pgfault_handler(pgfault);
  800fa4:	68 a9 0e 80 00       	push   $0x800ea9
  800fa9:	e8 ae 14 00 00       	call   80245c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fae:	b8 07 00 00 00       	mov    $0x7,%eax
  800fb3:	cd 30                	int    $0x30
  800fb5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((cenvid = sys_exofork()) < 0){
  800fb8:	83 c4 10             	add    $0x10,%esp
  800fbb:	85 c0                	test   %eax,%eax
  800fbd:	79 14                	jns    800fd3 <fork+0x38>
		panic("sys_exofork failed");
  800fbf:	83 ec 04             	sub    $0x4,%esp
  800fc2:	68 47 2d 80 00       	push   $0x802d47
  800fc7:	6a 6f                	push   $0x6f
  800fc9:	68 02 2d 80 00       	push   $0x802d02
  800fce:	e8 05 f2 ff ff       	call   8001d8 <_panic>
  800fd3:	89 c7                	mov    %eax,%edi
		return cenvid;
	}
	if(cenvid>0){
  800fd5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fd9:	0f 8e 2b 01 00 00    	jle    80110a <fork+0x16f>
  800fdf:	bb 00 08 00 00       	mov    $0x800,%ebx
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
  800fe4:	89 d8                	mov    %ebx,%eax
  800fe6:	c1 e8 0a             	shr    $0xa,%eax
  800fe9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff0:	a8 01                	test   $0x1,%al
  800ff2:	0f 84 bf 00 00 00    	je     8010b7 <fork+0x11c>
  800ff8:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fff:	a8 01                	test   $0x1,%al
  801001:	0f 84 b0 00 00 00    	je     8010b7 <fork+0x11c>
  801007:	89 de                	mov    %ebx,%esi
  801009:	c1 e6 0c             	shl    $0xc,%esi
{
	int r;

	// LAB 4: Your code here.
	void* vaddr=(void*)(pn*PGSIZE);
	if(uvpt[pn]&PTE_SHARE){
  80100c:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801013:	f6 c4 04             	test   $0x4,%ah
  801016:	74 29                	je     801041 <fork+0xa6>
		if((r=sys_page_map(0,vaddr,envid,vaddr,uvpt[pn]&PTE_SYSCALL))<0)return r;
  801018:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80101f:	83 ec 0c             	sub    $0xc,%esp
  801022:	25 07 0e 00 00       	and    $0xe07,%eax
  801027:	50                   	push   %eax
  801028:	56                   	push   %esi
  801029:	57                   	push   %edi
  80102a:	56                   	push   %esi
  80102b:	6a 00                	push   $0x0
  80102d:	e8 c9 fc ff ff       	call   800cfb <sys_page_map>
  801032:	83 c4 20             	add    $0x20,%esp
  801035:	85 c0                	test   %eax,%eax
  801037:	ba 00 00 00 00       	mov    $0x0,%edx
  80103c:	0f 4f c2             	cmovg  %edx,%eax
  80103f:	eb 72                	jmp    8010b3 <fork+0x118>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  801041:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801048:	a8 02                	test   $0x2,%al
  80104a:	75 0c                	jne    801058 <fork+0xbd>
  80104c:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801053:	f6 c4 08             	test   $0x8,%ah
  801056:	74 3f                	je     801097 <fork+0xfc>
		if ((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  801058:	83 ec 0c             	sub    $0xc,%esp
  80105b:	68 05 08 00 00       	push   $0x805
  801060:	56                   	push   %esi
  801061:	57                   	push   %edi
  801062:	56                   	push   %esi
  801063:	6a 00                	push   $0x0
  801065:	e8 91 fc ff ff       	call   800cfb <sys_page_map>
  80106a:	83 c4 20             	add    $0x20,%esp
  80106d:	85 c0                	test   %eax,%eax
  80106f:	0f 88 b1 00 00 00    	js     801126 <fork+0x18b>
            return r;
        if ((r = sys_page_map(0, vaddr, 0, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  801075:	83 ec 0c             	sub    $0xc,%esp
  801078:	68 05 08 00 00       	push   $0x805
  80107d:	56                   	push   %esi
  80107e:	6a 00                	push   $0x0
  801080:	56                   	push   %esi
  801081:	6a 00                	push   $0x0
  801083:	e8 73 fc ff ff       	call   800cfb <sys_page_map>
  801088:	83 c4 20             	add    $0x20,%esp
  80108b:	85 c0                	test   %eax,%eax
  80108d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801092:	0f 4f c1             	cmovg  %ecx,%eax
  801095:	eb 1c                	jmp    8010b3 <fork+0x118>
            return r;
	}
	else if((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U)) < 0) {
  801097:	83 ec 0c             	sub    $0xc,%esp
  80109a:	6a 05                	push   $0x5
  80109c:	56                   	push   %esi
  80109d:	57                   	push   %edi
  80109e:	56                   	push   %esi
  80109f:	6a 00                	push   $0x0
  8010a1:	e8 55 fc ff ff       	call   800cfb <sys_page_map>
  8010a6:	83 c4 20             	add    $0x20,%esp
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010b0:	0f 4f c1             	cmovg  %ecx,%eax
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	78 6f                	js     801126 <fork+0x18b>
	if ((cenvid = sys_exofork()) < 0){
		panic("sys_exofork failed");
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  8010b7:	83 c3 01             	add    $0x1,%ebx
  8010ba:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  8010c0:	0f 85 1e ff ff ff    	jne    800fe4 <fork+0x49>
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
                    return r;
		}
		if ((r = sys_page_alloc(cenvid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  8010c6:	83 ec 04             	sub    $0x4,%esp
  8010c9:	6a 07                	push   $0x7
  8010cb:	68 00 f0 bf ee       	push   $0xeebff000
  8010d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010d3:	57                   	push   %edi
  8010d4:	e8 df fb ff ff       	call   800cb8 <sys_page_alloc>
  8010d9:	83 c4 10             	add    $0x10,%esp
  8010dc:	85 c0                	test   %eax,%eax
  8010de:	78 46                	js     801126 <fork+0x18b>
            return r;
		extern void _pgfault_upcall(void);
		if ((r = sys_env_set_pgfault_upcall(cenvid, _pgfault_upcall)) < 0)
  8010e0:	83 ec 08             	sub    $0x8,%esp
  8010e3:	68 bf 24 80 00       	push   $0x8024bf
  8010e8:	57                   	push   %edi
  8010e9:	e8 15 fd ff ff       	call   800e03 <sys_env_set_pgfault_upcall>
  8010ee:	83 c4 10             	add    $0x10,%esp
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	78 31                	js     801126 <fork+0x18b>
            return r;
		if ((r = sys_env_set_status(cenvid, ENV_RUNNABLE)) < 0)
  8010f5:	83 ec 08             	sub    $0x8,%esp
  8010f8:	6a 02                	push   $0x2
  8010fa:	57                   	push   %edi
  8010fb:	e8 7f fc ff ff       	call   800d7f <sys_env_set_status>
  801100:	83 c4 10             	add    $0x10,%esp
            return r;
        return cenvid;
  801103:	85 c0                	test   %eax,%eax
  801105:	0f 49 c7             	cmovns %edi,%eax
  801108:	eb 1c                	jmp    801126 <fork+0x18b>
	}
	else {
		thisenv = &envs[ENVX(sys_getenvid())];
  80110a:	e8 6b fb ff ff       	call   800c7a <sys_getenvid>
  80110f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801114:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801117:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80111c:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801121:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//panic("fork not implemented");
	
}
  801126:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801129:	5b                   	pop    %ebx
  80112a:	5e                   	pop    %esi
  80112b:	5f                   	pop    %edi
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    

0080112e <sfork>:

// Challenge!
int
sfork(void)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801134:	68 5a 2d 80 00       	push   $0x802d5a
  801139:	68 8d 00 00 00       	push   $0x8d
  80113e:	68 02 2d 80 00       	push   $0x802d02
  801143:	e8 90 f0 ff ff       	call   8001d8 <_panic>

00801148 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80114b:	8b 45 08             	mov    0x8(%ebp),%eax
  80114e:	05 00 00 00 30       	add    $0x30000000,%eax
  801153:	c1 e8 0c             	shr    $0xc,%eax
}
  801156:	5d                   	pop    %ebp
  801157:	c3                   	ret    

00801158 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80115b:	8b 45 08             	mov    0x8(%ebp),%eax
  80115e:	05 00 00 00 30       	add    $0x30000000,%eax
  801163:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801168:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80116d:	5d                   	pop    %ebp
  80116e:	c3                   	ret    

0080116f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
  801172:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801175:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80117a:	89 c2                	mov    %eax,%edx
  80117c:	c1 ea 16             	shr    $0x16,%edx
  80117f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801186:	f6 c2 01             	test   $0x1,%dl
  801189:	74 11                	je     80119c <fd_alloc+0x2d>
  80118b:	89 c2                	mov    %eax,%edx
  80118d:	c1 ea 0c             	shr    $0xc,%edx
  801190:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801197:	f6 c2 01             	test   $0x1,%dl
  80119a:	75 09                	jne    8011a5 <fd_alloc+0x36>
			*fd_store = fd;
  80119c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80119e:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a3:	eb 17                	jmp    8011bc <fd_alloc+0x4d>
  8011a5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011aa:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011af:	75 c9                	jne    80117a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011b1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011b7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011bc:	5d                   	pop    %ebp
  8011bd:	c3                   	ret    

008011be <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011c4:	83 f8 1f             	cmp    $0x1f,%eax
  8011c7:	77 36                	ja     8011ff <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011c9:	c1 e0 0c             	shl    $0xc,%eax
  8011cc:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011d1:	89 c2                	mov    %eax,%edx
  8011d3:	c1 ea 16             	shr    $0x16,%edx
  8011d6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011dd:	f6 c2 01             	test   $0x1,%dl
  8011e0:	74 24                	je     801206 <fd_lookup+0x48>
  8011e2:	89 c2                	mov    %eax,%edx
  8011e4:	c1 ea 0c             	shr    $0xc,%edx
  8011e7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ee:	f6 c2 01             	test   $0x1,%dl
  8011f1:	74 1a                	je     80120d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011f6:	89 02                	mov    %eax,(%edx)
	return 0;
  8011f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011fd:	eb 13                	jmp    801212 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801204:	eb 0c                	jmp    801212 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801206:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80120b:	eb 05                	jmp    801212 <fd_lookup+0x54>
  80120d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801212:	5d                   	pop    %ebp
  801213:	c3                   	ret    

00801214 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	83 ec 08             	sub    $0x8,%esp
  80121a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80121d:	ba ec 2d 80 00       	mov    $0x802dec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801222:	eb 13                	jmp    801237 <dev_lookup+0x23>
  801224:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801227:	39 08                	cmp    %ecx,(%eax)
  801229:	75 0c                	jne    801237 <dev_lookup+0x23>
			*dev = devtab[i];
  80122b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80122e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801230:	b8 00 00 00 00       	mov    $0x0,%eax
  801235:	eb 2e                	jmp    801265 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801237:	8b 02                	mov    (%edx),%eax
  801239:	85 c0                	test   %eax,%eax
  80123b:	75 e7                	jne    801224 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80123d:	a1 04 40 80 00       	mov    0x804004,%eax
  801242:	8b 40 48             	mov    0x48(%eax),%eax
  801245:	83 ec 04             	sub    $0x4,%esp
  801248:	51                   	push   %ecx
  801249:	50                   	push   %eax
  80124a:	68 70 2d 80 00       	push   $0x802d70
  80124f:	e8 5d f0 ff ff       	call   8002b1 <cprintf>
	*dev = 0;
  801254:	8b 45 0c             	mov    0xc(%ebp),%eax
  801257:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801265:	c9                   	leave  
  801266:	c3                   	ret    

00801267 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801267:	55                   	push   %ebp
  801268:	89 e5                	mov    %esp,%ebp
  80126a:	56                   	push   %esi
  80126b:	53                   	push   %ebx
  80126c:	83 ec 10             	sub    $0x10,%esp
  80126f:	8b 75 08             	mov    0x8(%ebp),%esi
  801272:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801275:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801278:	50                   	push   %eax
  801279:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80127f:	c1 e8 0c             	shr    $0xc,%eax
  801282:	50                   	push   %eax
  801283:	e8 36 ff ff ff       	call   8011be <fd_lookup>
  801288:	83 c4 08             	add    $0x8,%esp
  80128b:	85 c0                	test   %eax,%eax
  80128d:	78 05                	js     801294 <fd_close+0x2d>
	    || fd != fd2)
  80128f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801292:	74 0c                	je     8012a0 <fd_close+0x39>
		return (must_exist ? r : 0);
  801294:	84 db                	test   %bl,%bl
  801296:	ba 00 00 00 00       	mov    $0x0,%edx
  80129b:	0f 44 c2             	cmove  %edx,%eax
  80129e:	eb 41                	jmp    8012e1 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012a0:	83 ec 08             	sub    $0x8,%esp
  8012a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a6:	50                   	push   %eax
  8012a7:	ff 36                	pushl  (%esi)
  8012a9:	e8 66 ff ff ff       	call   801214 <dev_lookup>
  8012ae:	89 c3                	mov    %eax,%ebx
  8012b0:	83 c4 10             	add    $0x10,%esp
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	78 1a                	js     8012d1 <fd_close+0x6a>
		if (dev->dev_close)
  8012b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ba:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012bd:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012c2:	85 c0                	test   %eax,%eax
  8012c4:	74 0b                	je     8012d1 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012c6:	83 ec 0c             	sub    $0xc,%esp
  8012c9:	56                   	push   %esi
  8012ca:	ff d0                	call   *%eax
  8012cc:	89 c3                	mov    %eax,%ebx
  8012ce:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012d1:	83 ec 08             	sub    $0x8,%esp
  8012d4:	56                   	push   %esi
  8012d5:	6a 00                	push   $0x0
  8012d7:	e8 61 fa ff ff       	call   800d3d <sys_page_unmap>
	return r;
  8012dc:	83 c4 10             	add    $0x10,%esp
  8012df:	89 d8                	mov    %ebx,%eax
}
  8012e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e4:	5b                   	pop    %ebx
  8012e5:	5e                   	pop    %esi
  8012e6:	5d                   	pop    %ebp
  8012e7:	c3                   	ret    

008012e8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012e8:	55                   	push   %ebp
  8012e9:	89 e5                	mov    %esp,%ebp
  8012eb:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f1:	50                   	push   %eax
  8012f2:	ff 75 08             	pushl  0x8(%ebp)
  8012f5:	e8 c4 fe ff ff       	call   8011be <fd_lookup>
  8012fa:	83 c4 08             	add    $0x8,%esp
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	78 10                	js     801311 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801301:	83 ec 08             	sub    $0x8,%esp
  801304:	6a 01                	push   $0x1
  801306:	ff 75 f4             	pushl  -0xc(%ebp)
  801309:	e8 59 ff ff ff       	call   801267 <fd_close>
  80130e:	83 c4 10             	add    $0x10,%esp
}
  801311:	c9                   	leave  
  801312:	c3                   	ret    

00801313 <close_all>:

void
close_all(void)
{
  801313:	55                   	push   %ebp
  801314:	89 e5                	mov    %esp,%ebp
  801316:	53                   	push   %ebx
  801317:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80131a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80131f:	83 ec 0c             	sub    $0xc,%esp
  801322:	53                   	push   %ebx
  801323:	e8 c0 ff ff ff       	call   8012e8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801328:	83 c3 01             	add    $0x1,%ebx
  80132b:	83 c4 10             	add    $0x10,%esp
  80132e:	83 fb 20             	cmp    $0x20,%ebx
  801331:	75 ec                	jne    80131f <close_all+0xc>
		close(i);
}
  801333:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801336:	c9                   	leave  
  801337:	c3                   	ret    

00801338 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	57                   	push   %edi
  80133c:	56                   	push   %esi
  80133d:	53                   	push   %ebx
  80133e:	83 ec 2c             	sub    $0x2c,%esp
  801341:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801344:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801347:	50                   	push   %eax
  801348:	ff 75 08             	pushl  0x8(%ebp)
  80134b:	e8 6e fe ff ff       	call   8011be <fd_lookup>
  801350:	83 c4 08             	add    $0x8,%esp
  801353:	85 c0                	test   %eax,%eax
  801355:	0f 88 c1 00 00 00    	js     80141c <dup+0xe4>
		return r;
	close(newfdnum);
  80135b:	83 ec 0c             	sub    $0xc,%esp
  80135e:	56                   	push   %esi
  80135f:	e8 84 ff ff ff       	call   8012e8 <close>

	newfd = INDEX2FD(newfdnum);
  801364:	89 f3                	mov    %esi,%ebx
  801366:	c1 e3 0c             	shl    $0xc,%ebx
  801369:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80136f:	83 c4 04             	add    $0x4,%esp
  801372:	ff 75 e4             	pushl  -0x1c(%ebp)
  801375:	e8 de fd ff ff       	call   801158 <fd2data>
  80137a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80137c:	89 1c 24             	mov    %ebx,(%esp)
  80137f:	e8 d4 fd ff ff       	call   801158 <fd2data>
  801384:	83 c4 10             	add    $0x10,%esp
  801387:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80138a:	89 f8                	mov    %edi,%eax
  80138c:	c1 e8 16             	shr    $0x16,%eax
  80138f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801396:	a8 01                	test   $0x1,%al
  801398:	74 37                	je     8013d1 <dup+0x99>
  80139a:	89 f8                	mov    %edi,%eax
  80139c:	c1 e8 0c             	shr    $0xc,%eax
  80139f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013a6:	f6 c2 01             	test   $0x1,%dl
  8013a9:	74 26                	je     8013d1 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013ab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013b2:	83 ec 0c             	sub    $0xc,%esp
  8013b5:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ba:	50                   	push   %eax
  8013bb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013be:	6a 00                	push   $0x0
  8013c0:	57                   	push   %edi
  8013c1:	6a 00                	push   $0x0
  8013c3:	e8 33 f9 ff ff       	call   800cfb <sys_page_map>
  8013c8:	89 c7                	mov    %eax,%edi
  8013ca:	83 c4 20             	add    $0x20,%esp
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	78 2e                	js     8013ff <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013d1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013d4:	89 d0                	mov    %edx,%eax
  8013d6:	c1 e8 0c             	shr    $0xc,%eax
  8013d9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e0:	83 ec 0c             	sub    $0xc,%esp
  8013e3:	25 07 0e 00 00       	and    $0xe07,%eax
  8013e8:	50                   	push   %eax
  8013e9:	53                   	push   %ebx
  8013ea:	6a 00                	push   $0x0
  8013ec:	52                   	push   %edx
  8013ed:	6a 00                	push   $0x0
  8013ef:	e8 07 f9 ff ff       	call   800cfb <sys_page_map>
  8013f4:	89 c7                	mov    %eax,%edi
  8013f6:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013f9:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013fb:	85 ff                	test   %edi,%edi
  8013fd:	79 1d                	jns    80141c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013ff:	83 ec 08             	sub    $0x8,%esp
  801402:	53                   	push   %ebx
  801403:	6a 00                	push   $0x0
  801405:	e8 33 f9 ff ff       	call   800d3d <sys_page_unmap>
	sys_page_unmap(0, nva);
  80140a:	83 c4 08             	add    $0x8,%esp
  80140d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801410:	6a 00                	push   $0x0
  801412:	e8 26 f9 ff ff       	call   800d3d <sys_page_unmap>
	return r;
  801417:	83 c4 10             	add    $0x10,%esp
  80141a:	89 f8                	mov    %edi,%eax
}
  80141c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80141f:	5b                   	pop    %ebx
  801420:	5e                   	pop    %esi
  801421:	5f                   	pop    %edi
  801422:	5d                   	pop    %ebp
  801423:	c3                   	ret    

00801424 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	53                   	push   %ebx
  801428:	83 ec 14             	sub    $0x14,%esp
  80142b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80142e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801431:	50                   	push   %eax
  801432:	53                   	push   %ebx
  801433:	e8 86 fd ff ff       	call   8011be <fd_lookup>
  801438:	83 c4 08             	add    $0x8,%esp
  80143b:	89 c2                	mov    %eax,%edx
  80143d:	85 c0                	test   %eax,%eax
  80143f:	78 6d                	js     8014ae <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801441:	83 ec 08             	sub    $0x8,%esp
  801444:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801447:	50                   	push   %eax
  801448:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144b:	ff 30                	pushl  (%eax)
  80144d:	e8 c2 fd ff ff       	call   801214 <dev_lookup>
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	85 c0                	test   %eax,%eax
  801457:	78 4c                	js     8014a5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801459:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80145c:	8b 42 08             	mov    0x8(%edx),%eax
  80145f:	83 e0 03             	and    $0x3,%eax
  801462:	83 f8 01             	cmp    $0x1,%eax
  801465:	75 21                	jne    801488 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801467:	a1 04 40 80 00       	mov    0x804004,%eax
  80146c:	8b 40 48             	mov    0x48(%eax),%eax
  80146f:	83 ec 04             	sub    $0x4,%esp
  801472:	53                   	push   %ebx
  801473:	50                   	push   %eax
  801474:	68 b1 2d 80 00       	push   $0x802db1
  801479:	e8 33 ee ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  80147e:	83 c4 10             	add    $0x10,%esp
  801481:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801486:	eb 26                	jmp    8014ae <read+0x8a>
	}
	if (!dev->dev_read)
  801488:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148b:	8b 40 08             	mov    0x8(%eax),%eax
  80148e:	85 c0                	test   %eax,%eax
  801490:	74 17                	je     8014a9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801492:	83 ec 04             	sub    $0x4,%esp
  801495:	ff 75 10             	pushl  0x10(%ebp)
  801498:	ff 75 0c             	pushl  0xc(%ebp)
  80149b:	52                   	push   %edx
  80149c:	ff d0                	call   *%eax
  80149e:	89 c2                	mov    %eax,%edx
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	eb 09                	jmp    8014ae <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a5:	89 c2                	mov    %eax,%edx
  8014a7:	eb 05                	jmp    8014ae <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014a9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014ae:	89 d0                	mov    %edx,%eax
  8014b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b3:	c9                   	leave  
  8014b4:	c3                   	ret    

008014b5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	57                   	push   %edi
  8014b9:	56                   	push   %esi
  8014ba:	53                   	push   %ebx
  8014bb:	83 ec 0c             	sub    $0xc,%esp
  8014be:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014c1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014c9:	eb 21                	jmp    8014ec <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014cb:	83 ec 04             	sub    $0x4,%esp
  8014ce:	89 f0                	mov    %esi,%eax
  8014d0:	29 d8                	sub    %ebx,%eax
  8014d2:	50                   	push   %eax
  8014d3:	89 d8                	mov    %ebx,%eax
  8014d5:	03 45 0c             	add    0xc(%ebp),%eax
  8014d8:	50                   	push   %eax
  8014d9:	57                   	push   %edi
  8014da:	e8 45 ff ff ff       	call   801424 <read>
		if (m < 0)
  8014df:	83 c4 10             	add    $0x10,%esp
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	78 10                	js     8014f6 <readn+0x41>
			return m;
		if (m == 0)
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	74 0a                	je     8014f4 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ea:	01 c3                	add    %eax,%ebx
  8014ec:	39 f3                	cmp    %esi,%ebx
  8014ee:	72 db                	jb     8014cb <readn+0x16>
  8014f0:	89 d8                	mov    %ebx,%eax
  8014f2:	eb 02                	jmp    8014f6 <readn+0x41>
  8014f4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f9:	5b                   	pop    %ebx
  8014fa:	5e                   	pop    %esi
  8014fb:	5f                   	pop    %edi
  8014fc:	5d                   	pop    %ebp
  8014fd:	c3                   	ret    

008014fe <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	53                   	push   %ebx
  801502:	83 ec 14             	sub    $0x14,%esp
  801505:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801508:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150b:	50                   	push   %eax
  80150c:	53                   	push   %ebx
  80150d:	e8 ac fc ff ff       	call   8011be <fd_lookup>
  801512:	83 c4 08             	add    $0x8,%esp
  801515:	89 c2                	mov    %eax,%edx
  801517:	85 c0                	test   %eax,%eax
  801519:	78 68                	js     801583 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151b:	83 ec 08             	sub    $0x8,%esp
  80151e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801521:	50                   	push   %eax
  801522:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801525:	ff 30                	pushl  (%eax)
  801527:	e8 e8 fc ff ff       	call   801214 <dev_lookup>
  80152c:	83 c4 10             	add    $0x10,%esp
  80152f:	85 c0                	test   %eax,%eax
  801531:	78 47                	js     80157a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801533:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801536:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80153a:	75 21                	jne    80155d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80153c:	a1 04 40 80 00       	mov    0x804004,%eax
  801541:	8b 40 48             	mov    0x48(%eax),%eax
  801544:	83 ec 04             	sub    $0x4,%esp
  801547:	53                   	push   %ebx
  801548:	50                   	push   %eax
  801549:	68 cd 2d 80 00       	push   $0x802dcd
  80154e:	e8 5e ed ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80155b:	eb 26                	jmp    801583 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80155d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801560:	8b 52 0c             	mov    0xc(%edx),%edx
  801563:	85 d2                	test   %edx,%edx
  801565:	74 17                	je     80157e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801567:	83 ec 04             	sub    $0x4,%esp
  80156a:	ff 75 10             	pushl  0x10(%ebp)
  80156d:	ff 75 0c             	pushl  0xc(%ebp)
  801570:	50                   	push   %eax
  801571:	ff d2                	call   *%edx
  801573:	89 c2                	mov    %eax,%edx
  801575:	83 c4 10             	add    $0x10,%esp
  801578:	eb 09                	jmp    801583 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157a:	89 c2                	mov    %eax,%edx
  80157c:	eb 05                	jmp    801583 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80157e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801583:	89 d0                	mov    %edx,%eax
  801585:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801588:	c9                   	leave  
  801589:	c3                   	ret    

0080158a <seek>:

int
seek(int fdnum, off_t offset)
{
  80158a:	55                   	push   %ebp
  80158b:	89 e5                	mov    %esp,%ebp
  80158d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801590:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801593:	50                   	push   %eax
  801594:	ff 75 08             	pushl  0x8(%ebp)
  801597:	e8 22 fc ff ff       	call   8011be <fd_lookup>
  80159c:	83 c4 08             	add    $0x8,%esp
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	78 0e                	js     8015b1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015a9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015b1:	c9                   	leave  
  8015b2:	c3                   	ret    

008015b3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	53                   	push   %ebx
  8015b7:	83 ec 14             	sub    $0x14,%esp
  8015ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c0:	50                   	push   %eax
  8015c1:	53                   	push   %ebx
  8015c2:	e8 f7 fb ff ff       	call   8011be <fd_lookup>
  8015c7:	83 c4 08             	add    $0x8,%esp
  8015ca:	89 c2                	mov    %eax,%edx
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	78 65                	js     801635 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d0:	83 ec 08             	sub    $0x8,%esp
  8015d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d6:	50                   	push   %eax
  8015d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015da:	ff 30                	pushl  (%eax)
  8015dc:	e8 33 fc ff ff       	call   801214 <dev_lookup>
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 44                	js     80162c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015eb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ef:	75 21                	jne    801612 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015f1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015f6:	8b 40 48             	mov    0x48(%eax),%eax
  8015f9:	83 ec 04             	sub    $0x4,%esp
  8015fc:	53                   	push   %ebx
  8015fd:	50                   	push   %eax
  8015fe:	68 90 2d 80 00       	push   $0x802d90
  801603:	e8 a9 ec ff ff       	call   8002b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801610:	eb 23                	jmp    801635 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801612:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801615:	8b 52 18             	mov    0x18(%edx),%edx
  801618:	85 d2                	test   %edx,%edx
  80161a:	74 14                	je     801630 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80161c:	83 ec 08             	sub    $0x8,%esp
  80161f:	ff 75 0c             	pushl  0xc(%ebp)
  801622:	50                   	push   %eax
  801623:	ff d2                	call   *%edx
  801625:	89 c2                	mov    %eax,%edx
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	eb 09                	jmp    801635 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162c:	89 c2                	mov    %eax,%edx
  80162e:	eb 05                	jmp    801635 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801630:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801635:	89 d0                	mov    %edx,%eax
  801637:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163a:	c9                   	leave  
  80163b:	c3                   	ret    

0080163c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	53                   	push   %ebx
  801640:	83 ec 14             	sub    $0x14,%esp
  801643:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801646:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801649:	50                   	push   %eax
  80164a:	ff 75 08             	pushl  0x8(%ebp)
  80164d:	e8 6c fb ff ff       	call   8011be <fd_lookup>
  801652:	83 c4 08             	add    $0x8,%esp
  801655:	89 c2                	mov    %eax,%edx
  801657:	85 c0                	test   %eax,%eax
  801659:	78 58                	js     8016b3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165b:	83 ec 08             	sub    $0x8,%esp
  80165e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801661:	50                   	push   %eax
  801662:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801665:	ff 30                	pushl  (%eax)
  801667:	e8 a8 fb ff ff       	call   801214 <dev_lookup>
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 37                	js     8016aa <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801673:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801676:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80167a:	74 32                	je     8016ae <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80167c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80167f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801686:	00 00 00 
	stat->st_isdir = 0;
  801689:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801690:	00 00 00 
	stat->st_dev = dev;
  801693:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801699:	83 ec 08             	sub    $0x8,%esp
  80169c:	53                   	push   %ebx
  80169d:	ff 75 f0             	pushl  -0x10(%ebp)
  8016a0:	ff 50 14             	call   *0x14(%eax)
  8016a3:	89 c2                	mov    %eax,%edx
  8016a5:	83 c4 10             	add    $0x10,%esp
  8016a8:	eb 09                	jmp    8016b3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016aa:	89 c2                	mov    %eax,%edx
  8016ac:	eb 05                	jmp    8016b3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016ae:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016b3:	89 d0                	mov    %edx,%eax
  8016b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b8:	c9                   	leave  
  8016b9:	c3                   	ret    

008016ba <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	56                   	push   %esi
  8016be:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016bf:	83 ec 08             	sub    $0x8,%esp
  8016c2:	6a 00                	push   $0x0
  8016c4:	ff 75 08             	pushl  0x8(%ebp)
  8016c7:	e8 e3 01 00 00       	call   8018af <open>
  8016cc:	89 c3                	mov    %eax,%ebx
  8016ce:	83 c4 10             	add    $0x10,%esp
  8016d1:	85 c0                	test   %eax,%eax
  8016d3:	78 1b                	js     8016f0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016d5:	83 ec 08             	sub    $0x8,%esp
  8016d8:	ff 75 0c             	pushl  0xc(%ebp)
  8016db:	50                   	push   %eax
  8016dc:	e8 5b ff ff ff       	call   80163c <fstat>
  8016e1:	89 c6                	mov    %eax,%esi
	close(fd);
  8016e3:	89 1c 24             	mov    %ebx,(%esp)
  8016e6:	e8 fd fb ff ff       	call   8012e8 <close>
	return r;
  8016eb:	83 c4 10             	add    $0x10,%esp
  8016ee:	89 f0                	mov    %esi,%eax
}
  8016f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f3:	5b                   	pop    %ebx
  8016f4:	5e                   	pop    %esi
  8016f5:	5d                   	pop    %ebp
  8016f6:	c3                   	ret    

008016f7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	56                   	push   %esi
  8016fb:	53                   	push   %ebx
  8016fc:	89 c6                	mov    %eax,%esi
  8016fe:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801700:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801707:	75 12                	jne    80171b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801709:	83 ec 0c             	sub    $0xc,%esp
  80170c:	6a 01                	push   $0x1
  80170e:	e8 8d 0e 00 00       	call   8025a0 <ipc_find_env>
  801713:	a3 00 40 80 00       	mov    %eax,0x804000
  801718:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80171b:	6a 07                	push   $0x7
  80171d:	68 00 50 80 00       	push   $0x805000
  801722:	56                   	push   %esi
  801723:	ff 35 00 40 80 00    	pushl  0x804000
  801729:	e8 1e 0e 00 00       	call   80254c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80172e:	83 c4 0c             	add    $0xc,%esp
  801731:	6a 00                	push   $0x0
  801733:	53                   	push   %ebx
  801734:	6a 00                	push   $0x0
  801736:	e8 a8 0d 00 00       	call   8024e3 <ipc_recv>
}
  80173b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80173e:	5b                   	pop    %ebx
  80173f:	5e                   	pop    %esi
  801740:	5d                   	pop    %ebp
  801741:	c3                   	ret    

00801742 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801748:	8b 45 08             	mov    0x8(%ebp),%eax
  80174b:	8b 40 0c             	mov    0xc(%eax),%eax
  80174e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801753:	8b 45 0c             	mov    0xc(%ebp),%eax
  801756:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80175b:	ba 00 00 00 00       	mov    $0x0,%edx
  801760:	b8 02 00 00 00       	mov    $0x2,%eax
  801765:	e8 8d ff ff ff       	call   8016f7 <fsipc>
}
  80176a:	c9                   	leave  
  80176b:	c3                   	ret    

0080176c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801772:	8b 45 08             	mov    0x8(%ebp),%eax
  801775:	8b 40 0c             	mov    0xc(%eax),%eax
  801778:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80177d:	ba 00 00 00 00       	mov    $0x0,%edx
  801782:	b8 06 00 00 00       	mov    $0x6,%eax
  801787:	e8 6b ff ff ff       	call   8016f7 <fsipc>
}
  80178c:	c9                   	leave  
  80178d:	c3                   	ret    

0080178e <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	53                   	push   %ebx
  801792:	83 ec 04             	sub    $0x4,%esp
  801795:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801798:	8b 45 08             	mov    0x8(%ebp),%eax
  80179b:	8b 40 0c             	mov    0xc(%eax),%eax
  80179e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a8:	b8 05 00 00 00       	mov    $0x5,%eax
  8017ad:	e8 45 ff ff ff       	call   8016f7 <fsipc>
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	78 2c                	js     8017e2 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017b6:	83 ec 08             	sub    $0x8,%esp
  8017b9:	68 00 50 80 00       	push   $0x805000
  8017be:	53                   	push   %ebx
  8017bf:	e8 f1 f0 ff ff       	call   8008b5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017c4:	a1 80 50 80 00       	mov    0x805080,%eax
  8017c9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017cf:	a1 84 50 80 00       	mov    0x805084,%eax
  8017d4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017da:	83 c4 10             	add    $0x10,%esp
  8017dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e5:	c9                   	leave  
  8017e6:	c3                   	ret    

008017e7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	83 ec 0c             	sub    $0xc,%esp
  8017ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8017f0:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017f5:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017fa:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017fd:	8b 55 08             	mov    0x8(%ebp),%edx
  801800:	8b 52 0c             	mov    0xc(%edx),%edx
  801803:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801809:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80180e:	50                   	push   %eax
  80180f:	ff 75 0c             	pushl  0xc(%ebp)
  801812:	68 08 50 80 00       	push   $0x805008
  801817:	e8 2b f2 ff ff       	call   800a47 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80181c:	ba 00 00 00 00       	mov    $0x0,%edx
  801821:	b8 04 00 00 00       	mov    $0x4,%eax
  801826:	e8 cc fe ff ff       	call   8016f7 <fsipc>
	//panic("devfile_write not implemented");
}
  80182b:	c9                   	leave  
  80182c:	c3                   	ret    

0080182d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80182d:	55                   	push   %ebp
  80182e:	89 e5                	mov    %esp,%ebp
  801830:	56                   	push   %esi
  801831:	53                   	push   %ebx
  801832:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801835:	8b 45 08             	mov    0x8(%ebp),%eax
  801838:	8b 40 0c             	mov    0xc(%eax),%eax
  80183b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801840:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801846:	ba 00 00 00 00       	mov    $0x0,%edx
  80184b:	b8 03 00 00 00       	mov    $0x3,%eax
  801850:	e8 a2 fe ff ff       	call   8016f7 <fsipc>
  801855:	89 c3                	mov    %eax,%ebx
  801857:	85 c0                	test   %eax,%eax
  801859:	78 4b                	js     8018a6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80185b:	39 c6                	cmp    %eax,%esi
  80185d:	73 16                	jae    801875 <devfile_read+0x48>
  80185f:	68 fc 2d 80 00       	push   $0x802dfc
  801864:	68 03 2e 80 00       	push   $0x802e03
  801869:	6a 7c                	push   $0x7c
  80186b:	68 18 2e 80 00       	push   $0x802e18
  801870:	e8 63 e9 ff ff       	call   8001d8 <_panic>
	assert(r <= PGSIZE);
  801875:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80187a:	7e 16                	jle    801892 <devfile_read+0x65>
  80187c:	68 23 2e 80 00       	push   $0x802e23
  801881:	68 03 2e 80 00       	push   $0x802e03
  801886:	6a 7d                	push   $0x7d
  801888:	68 18 2e 80 00       	push   $0x802e18
  80188d:	e8 46 e9 ff ff       	call   8001d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801892:	83 ec 04             	sub    $0x4,%esp
  801895:	50                   	push   %eax
  801896:	68 00 50 80 00       	push   $0x805000
  80189b:	ff 75 0c             	pushl  0xc(%ebp)
  80189e:	e8 a4 f1 ff ff       	call   800a47 <memmove>
	return r;
  8018a3:	83 c4 10             	add    $0x10,%esp
}
  8018a6:	89 d8                	mov    %ebx,%eax
  8018a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ab:	5b                   	pop    %ebx
  8018ac:	5e                   	pop    %esi
  8018ad:	5d                   	pop    %ebp
  8018ae:	c3                   	ret    

008018af <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	53                   	push   %ebx
  8018b3:	83 ec 20             	sub    $0x20,%esp
  8018b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018b9:	53                   	push   %ebx
  8018ba:	e8 bd ef ff ff       	call   80087c <strlen>
  8018bf:	83 c4 10             	add    $0x10,%esp
  8018c2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018c7:	7f 67                	jg     801930 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018c9:	83 ec 0c             	sub    $0xc,%esp
  8018cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018cf:	50                   	push   %eax
  8018d0:	e8 9a f8 ff ff       	call   80116f <fd_alloc>
  8018d5:	83 c4 10             	add    $0x10,%esp
		return r;
  8018d8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	78 57                	js     801935 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018de:	83 ec 08             	sub    $0x8,%esp
  8018e1:	53                   	push   %ebx
  8018e2:	68 00 50 80 00       	push   $0x805000
  8018e7:	e8 c9 ef ff ff       	call   8008b5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ef:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8018fc:	e8 f6 fd ff ff       	call   8016f7 <fsipc>
  801901:	89 c3                	mov    %eax,%ebx
  801903:	83 c4 10             	add    $0x10,%esp
  801906:	85 c0                	test   %eax,%eax
  801908:	79 14                	jns    80191e <open+0x6f>
		fd_close(fd, 0);
  80190a:	83 ec 08             	sub    $0x8,%esp
  80190d:	6a 00                	push   $0x0
  80190f:	ff 75 f4             	pushl  -0xc(%ebp)
  801912:	e8 50 f9 ff ff       	call   801267 <fd_close>
		return r;
  801917:	83 c4 10             	add    $0x10,%esp
  80191a:	89 da                	mov    %ebx,%edx
  80191c:	eb 17                	jmp    801935 <open+0x86>
	}

	return fd2num(fd);
  80191e:	83 ec 0c             	sub    $0xc,%esp
  801921:	ff 75 f4             	pushl  -0xc(%ebp)
  801924:	e8 1f f8 ff ff       	call   801148 <fd2num>
  801929:	89 c2                	mov    %eax,%edx
  80192b:	83 c4 10             	add    $0x10,%esp
  80192e:	eb 05                	jmp    801935 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801930:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801935:	89 d0                	mov    %edx,%eax
  801937:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80193a:	c9                   	leave  
  80193b:	c3                   	ret    

0080193c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80193c:	55                   	push   %ebp
  80193d:	89 e5                	mov    %esp,%ebp
  80193f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801942:	ba 00 00 00 00       	mov    $0x0,%edx
  801947:	b8 08 00 00 00       	mov    $0x8,%eax
  80194c:	e8 a6 fd ff ff       	call   8016f7 <fsipc>
}
  801951:	c9                   	leave  
  801952:	c3                   	ret    

00801953 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801953:	55                   	push   %ebp
  801954:	89 e5                	mov    %esp,%ebp
  801956:	57                   	push   %edi
  801957:	56                   	push   %esi
  801958:	53                   	push   %ebx
  801959:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80195f:	6a 00                	push   $0x0
  801961:	ff 75 08             	pushl  0x8(%ebp)
  801964:	e8 46 ff ff ff       	call   8018af <open>
  801969:	89 c7                	mov    %eax,%edi
  80196b:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801971:	83 c4 10             	add    $0x10,%esp
  801974:	85 c0                	test   %eax,%eax
  801976:	0f 88 82 04 00 00    	js     801dfe <spawn+0x4ab>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80197c:	83 ec 04             	sub    $0x4,%esp
  80197f:	68 00 02 00 00       	push   $0x200
  801984:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80198a:	50                   	push   %eax
  80198b:	57                   	push   %edi
  80198c:	e8 24 fb ff ff       	call   8014b5 <readn>
  801991:	83 c4 10             	add    $0x10,%esp
  801994:	3d 00 02 00 00       	cmp    $0x200,%eax
  801999:	75 0c                	jne    8019a7 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80199b:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8019a2:	45 4c 46 
  8019a5:	74 33                	je     8019da <spawn+0x87>
		close(fd);
  8019a7:	83 ec 0c             	sub    $0xc,%esp
  8019aa:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019b0:	e8 33 f9 ff ff       	call   8012e8 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8019b5:	83 c4 0c             	add    $0xc,%esp
  8019b8:	68 7f 45 4c 46       	push   $0x464c457f
  8019bd:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8019c3:	68 2f 2e 80 00       	push   $0x802e2f
  8019c8:	e8 e4 e8 ff ff       	call   8002b1 <cprintf>
		return -E_NOT_EXEC;
  8019cd:	83 c4 10             	add    $0x10,%esp
  8019d0:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8019d5:	e9 d7 04 00 00       	jmp    801eb1 <spawn+0x55e>
  8019da:	b8 07 00 00 00       	mov    $0x7,%eax
  8019df:	cd 30                	int    $0x30
  8019e1:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8019e7:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8019ed:	85 c0                	test   %eax,%eax
  8019ef:	0f 88 14 04 00 00    	js     801e09 <spawn+0x4b6>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8019f5:	89 c6                	mov    %eax,%esi
  8019f7:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8019fd:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801a00:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801a06:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801a0c:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a11:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801a13:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a19:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a1f:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a24:	be 00 00 00 00       	mov    $0x0,%esi
  801a29:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a2c:	eb 13                	jmp    801a41 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801a2e:	83 ec 0c             	sub    $0xc,%esp
  801a31:	50                   	push   %eax
  801a32:	e8 45 ee ff ff       	call   80087c <strlen>
  801a37:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a3b:	83 c3 01             	add    $0x1,%ebx
  801a3e:	83 c4 10             	add    $0x10,%esp
  801a41:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801a48:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a4b:	85 c0                	test   %eax,%eax
  801a4d:	75 df                	jne    801a2e <spawn+0xdb>
  801a4f:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801a55:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a5b:	bf 00 10 40 00       	mov    $0x401000,%edi
  801a60:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a62:	89 fa                	mov    %edi,%edx
  801a64:	83 e2 fc             	and    $0xfffffffc,%edx
  801a67:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801a6e:	29 c2                	sub    %eax,%edx
  801a70:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a76:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a79:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a7e:	0f 86 9b 03 00 00    	jbe    801e1f <spawn+0x4cc>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a84:	83 ec 04             	sub    $0x4,%esp
  801a87:	6a 07                	push   $0x7
  801a89:	68 00 00 40 00       	push   $0x400000
  801a8e:	6a 00                	push   $0x0
  801a90:	e8 23 f2 ff ff       	call   800cb8 <sys_page_alloc>
  801a95:	83 c4 10             	add    $0x10,%esp
  801a98:	85 c0                	test   %eax,%eax
  801a9a:	0f 88 89 03 00 00    	js     801e29 <spawn+0x4d6>
  801aa0:	be 00 00 00 00       	mov    $0x0,%esi
  801aa5:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801aab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801aae:	eb 30                	jmp    801ae0 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801ab0:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801ab6:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801abc:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801abf:	83 ec 08             	sub    $0x8,%esp
  801ac2:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ac5:	57                   	push   %edi
  801ac6:	e8 ea ed ff ff       	call   8008b5 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801acb:	83 c4 04             	add    $0x4,%esp
  801ace:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ad1:	e8 a6 ed ff ff       	call   80087c <strlen>
  801ad6:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801ada:	83 c6 01             	add    $0x1,%esi
  801add:	83 c4 10             	add    $0x10,%esp
  801ae0:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801ae6:	7f c8                	jg     801ab0 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801ae8:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801aee:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801af4:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801afb:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b01:	74 19                	je     801b1c <spawn+0x1c9>
  801b03:	68 bc 2e 80 00       	push   $0x802ebc
  801b08:	68 03 2e 80 00       	push   $0x802e03
  801b0d:	68 f2 00 00 00       	push   $0xf2
  801b12:	68 49 2e 80 00       	push   $0x802e49
  801b17:	e8 bc e6 ff ff       	call   8001d8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b1c:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801b22:	89 f8                	mov    %edi,%eax
  801b24:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801b29:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801b2c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b32:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b35:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801b3b:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b41:	83 ec 0c             	sub    $0xc,%esp
  801b44:	6a 07                	push   $0x7
  801b46:	68 00 d0 bf ee       	push   $0xeebfd000
  801b4b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b51:	68 00 00 40 00       	push   $0x400000
  801b56:	6a 00                	push   $0x0
  801b58:	e8 9e f1 ff ff       	call   800cfb <sys_page_map>
  801b5d:	89 c3                	mov    %eax,%ebx
  801b5f:	83 c4 20             	add    $0x20,%esp
  801b62:	85 c0                	test   %eax,%eax
  801b64:	0f 88 35 03 00 00    	js     801e9f <spawn+0x54c>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b6a:	83 ec 08             	sub    $0x8,%esp
  801b6d:	68 00 00 40 00       	push   $0x400000
  801b72:	6a 00                	push   $0x0
  801b74:	e8 c4 f1 ff ff       	call   800d3d <sys_page_unmap>
  801b79:	89 c3                	mov    %eax,%ebx
  801b7b:	83 c4 10             	add    $0x10,%esp
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	0f 88 19 03 00 00    	js     801e9f <spawn+0x54c>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b86:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b8c:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b93:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b99:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801ba0:	00 00 00 
  801ba3:	e9 88 01 00 00       	jmp    801d30 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801ba8:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801bae:	83 38 01             	cmpl   $0x1,(%eax)
  801bb1:	0f 85 6b 01 00 00    	jne    801d22 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801bb7:	89 c1                	mov    %eax,%ecx
  801bb9:	8b 40 18             	mov    0x18(%eax),%eax
  801bbc:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801bc2:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801bc5:	83 f8 01             	cmp    $0x1,%eax
  801bc8:	19 c0                	sbb    %eax,%eax
  801bca:	83 e0 fe             	and    $0xfffffffe,%eax
  801bcd:	83 c0 07             	add    $0x7,%eax
  801bd0:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801bd6:	89 c8                	mov    %ecx,%eax
  801bd8:	8b 79 04             	mov    0x4(%ecx),%edi
  801bdb:	89 f9                	mov    %edi,%ecx
  801bdd:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801be3:	8b 78 10             	mov    0x10(%eax),%edi
  801be6:	8b 50 14             	mov    0x14(%eax),%edx
  801be9:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801bef:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801bf2:	89 f0                	mov    %esi,%eax
  801bf4:	25 ff 0f 00 00       	and    $0xfff,%eax
  801bf9:	74 14                	je     801c0f <spawn+0x2bc>
		va -= i;
  801bfb:	29 c6                	sub    %eax,%esi
		memsz += i;
  801bfd:	01 c2                	add    %eax,%edx
  801bff:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801c05:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801c07:	29 c1                	sub    %eax,%ecx
  801c09:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c14:	e9 f7 00 00 00       	jmp    801d10 <spawn+0x3bd>
		if (i >= filesz) {
  801c19:	39 fb                	cmp    %edi,%ebx
  801c1b:	72 27                	jb     801c44 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c1d:	83 ec 04             	sub    $0x4,%esp
  801c20:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c26:	56                   	push   %esi
  801c27:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c2d:	e8 86 f0 ff ff       	call   800cb8 <sys_page_alloc>
  801c32:	83 c4 10             	add    $0x10,%esp
  801c35:	85 c0                	test   %eax,%eax
  801c37:	0f 89 c7 00 00 00    	jns    801d04 <spawn+0x3b1>
  801c3d:	89 c3                	mov    %eax,%ebx
  801c3f:	e9 f6 01 00 00       	jmp    801e3a <spawn+0x4e7>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c44:	83 ec 04             	sub    $0x4,%esp
  801c47:	6a 07                	push   $0x7
  801c49:	68 00 00 40 00       	push   $0x400000
  801c4e:	6a 00                	push   $0x0
  801c50:	e8 63 f0 ff ff       	call   800cb8 <sys_page_alloc>
  801c55:	83 c4 10             	add    $0x10,%esp
  801c58:	85 c0                	test   %eax,%eax
  801c5a:	0f 88 d0 01 00 00    	js     801e30 <spawn+0x4dd>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c60:	83 ec 08             	sub    $0x8,%esp
  801c63:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c69:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801c6f:	50                   	push   %eax
  801c70:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c76:	e8 0f f9 ff ff       	call   80158a <seek>
  801c7b:	83 c4 10             	add    $0x10,%esp
  801c7e:	85 c0                	test   %eax,%eax
  801c80:	0f 88 ae 01 00 00    	js     801e34 <spawn+0x4e1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c86:	83 ec 04             	sub    $0x4,%esp
  801c89:	89 f8                	mov    %edi,%eax
  801c8b:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801c91:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c96:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801c9b:	0f 47 c1             	cmova  %ecx,%eax
  801c9e:	50                   	push   %eax
  801c9f:	68 00 00 40 00       	push   $0x400000
  801ca4:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801caa:	e8 06 f8 ff ff       	call   8014b5 <readn>
  801caf:	83 c4 10             	add    $0x10,%esp
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	0f 88 7e 01 00 00    	js     801e38 <spawn+0x4e5>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801cba:	83 ec 0c             	sub    $0xc,%esp
  801cbd:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801cc3:	56                   	push   %esi
  801cc4:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801cca:	68 00 00 40 00       	push   $0x400000
  801ccf:	6a 00                	push   $0x0
  801cd1:	e8 25 f0 ff ff       	call   800cfb <sys_page_map>
  801cd6:	83 c4 20             	add    $0x20,%esp
  801cd9:	85 c0                	test   %eax,%eax
  801cdb:	79 15                	jns    801cf2 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801cdd:	50                   	push   %eax
  801cde:	68 55 2e 80 00       	push   $0x802e55
  801ce3:	68 25 01 00 00       	push   $0x125
  801ce8:	68 49 2e 80 00       	push   $0x802e49
  801ced:	e8 e6 e4 ff ff       	call   8001d8 <_panic>
			sys_page_unmap(0, UTEMP);
  801cf2:	83 ec 08             	sub    $0x8,%esp
  801cf5:	68 00 00 40 00       	push   $0x400000
  801cfa:	6a 00                	push   $0x0
  801cfc:	e8 3c f0 ff ff       	call   800d3d <sys_page_unmap>
  801d01:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d04:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d0a:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801d10:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801d16:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801d1c:	0f 82 f7 fe ff ff    	jb     801c19 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d22:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801d29:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801d30:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d37:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801d3d:	0f 8c 65 fe ff ff    	jl     801ba8 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d43:	83 ec 0c             	sub    $0xc,%esp
  801d46:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d4c:	e8 97 f5 ff ff       	call   8012e8 <close>
  801d51:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r=0,pn=0;
	for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  801d54:	bb 00 08 00 00       	mov    $0x800,%ebx
  801d59:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
        if ((uvpd[pn >> 10] & PTE_P) &&uvpt[pn] & PTE_SHARE)
  801d5f:	89 d8                	mov    %ebx,%eax
  801d61:	c1 f8 0a             	sar    $0xa,%eax
  801d64:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d6b:	a8 01                	test   $0x1,%al
  801d6d:	74 3e                	je     801dad <spawn+0x45a>
  801d6f:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801d76:	f6 c4 04             	test   $0x4,%ah
  801d79:	74 32                	je     801dad <spawn+0x45a>
            if ( (r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), child, (void *)(pn*PGSIZE), uvpt[pn] & PTE_SYSCALL )) < 0)
  801d7b:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801d82:	89 da                	mov    %ebx,%edx
  801d84:	c1 e2 0c             	shl    $0xc,%edx
  801d87:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801d8d:	8b 49 48             	mov    0x48(%ecx),%ecx
  801d90:	83 ec 0c             	sub    $0xc,%esp
  801d93:	25 07 0e 00 00       	and    $0xe07,%eax
  801d98:	50                   	push   %eax
  801d99:	52                   	push   %edx
  801d9a:	56                   	push   %esi
  801d9b:	52                   	push   %edx
  801d9c:	51                   	push   %ecx
  801d9d:	e8 59 ef ff ff       	call   800cfb <sys_page_map>
  801da2:	83 c4 20             	add    $0x20,%esp
  801da5:	85 c0                	test   %eax,%eax
  801da7:	0f 88 dd 00 00 00    	js     801e8a <spawn+0x537>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r=0,pn=0;
	for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  801dad:	83 c3 01             	add    $0x1,%ebx
  801db0:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801db6:	75 a7                	jne    801d5f <spawn+0x40c>
  801db8:	e9 9e 00 00 00       	jmp    801e5b <spawn+0x508>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801dbd:	50                   	push   %eax
  801dbe:	68 72 2e 80 00       	push   $0x802e72
  801dc3:	68 86 00 00 00       	push   $0x86
  801dc8:	68 49 2e 80 00       	push   $0x802e49
  801dcd:	e8 06 e4 ff ff       	call   8001d8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801dd2:	83 ec 08             	sub    $0x8,%esp
  801dd5:	6a 02                	push   $0x2
  801dd7:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ddd:	e8 9d ef ff ff       	call   800d7f <sys_env_set_status>
  801de2:	83 c4 10             	add    $0x10,%esp
  801de5:	85 c0                	test   %eax,%eax
  801de7:	79 2b                	jns    801e14 <spawn+0x4c1>
		panic("sys_env_set_status: %e", r);
  801de9:	50                   	push   %eax
  801dea:	68 8c 2e 80 00       	push   $0x802e8c
  801def:	68 89 00 00 00       	push   $0x89
  801df4:	68 49 2e 80 00       	push   $0x802e49
  801df9:	e8 da e3 ff ff       	call   8001d8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801dfe:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801e04:	e9 a8 00 00 00       	jmp    801eb1 <spawn+0x55e>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801e09:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e0f:	e9 9d 00 00 00       	jmp    801eb1 <spawn+0x55e>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801e14:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e1a:	e9 92 00 00 00       	jmp    801eb1 <spawn+0x55e>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801e1f:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801e24:	e9 88 00 00 00       	jmp    801eb1 <spawn+0x55e>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801e29:	89 c3                	mov    %eax,%ebx
  801e2b:	e9 81 00 00 00       	jmp    801eb1 <spawn+0x55e>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e30:	89 c3                	mov    %eax,%ebx
  801e32:	eb 06                	jmp    801e3a <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e34:	89 c3                	mov    %eax,%ebx
  801e36:	eb 02                	jmp    801e3a <spawn+0x4e7>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e38:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801e3a:	83 ec 0c             	sub    $0xc,%esp
  801e3d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e43:	e8 f1 ed ff ff       	call   800c39 <sys_env_destroy>
	close(fd);
  801e48:	83 c4 04             	add    $0x4,%esp
  801e4b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e51:	e8 92 f4 ff ff       	call   8012e8 <close>
	return r;
  801e56:	83 c4 10             	add    $0x10,%esp
  801e59:	eb 56                	jmp    801eb1 <spawn+0x55e>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801e5b:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801e62:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e65:	83 ec 08             	sub    $0x8,%esp
  801e68:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e6e:	50                   	push   %eax
  801e6f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e75:	e8 47 ef ff ff       	call   800dc1 <sys_env_set_trapframe>
  801e7a:	83 c4 10             	add    $0x10,%esp
  801e7d:	85 c0                	test   %eax,%eax
  801e7f:	0f 89 4d ff ff ff    	jns    801dd2 <spawn+0x47f>
  801e85:	e9 33 ff ff ff       	jmp    801dbd <spawn+0x46a>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801e8a:	50                   	push   %eax
  801e8b:	68 a3 2e 80 00       	push   $0x802ea3
  801e90:	68 82 00 00 00       	push   $0x82
  801e95:	68 49 2e 80 00       	push   $0x802e49
  801e9a:	e8 39 e3 ff ff       	call   8001d8 <_panic>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e9f:	83 ec 08             	sub    $0x8,%esp
  801ea2:	68 00 00 40 00       	push   $0x400000
  801ea7:	6a 00                	push   $0x0
  801ea9:	e8 8f ee ff ff       	call   800d3d <sys_page_unmap>
  801eae:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801eb1:	89 d8                	mov    %ebx,%eax
  801eb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb6:	5b                   	pop    %ebx
  801eb7:	5e                   	pop    %esi
  801eb8:	5f                   	pop    %edi
  801eb9:	5d                   	pop    %ebp
  801eba:	c3                   	ret    

00801ebb <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801ebb:	55                   	push   %ebp
  801ebc:	89 e5                	mov    %esp,%ebp
  801ebe:	56                   	push   %esi
  801ebf:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ec0:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801ec3:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ec8:	eb 03                	jmp    801ecd <spawnl+0x12>
		argc++;
  801eca:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ecd:	83 c2 04             	add    $0x4,%edx
  801ed0:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801ed4:	75 f4                	jne    801eca <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801ed6:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801edd:	83 e2 f0             	and    $0xfffffff0,%edx
  801ee0:	29 d4                	sub    %edx,%esp
  801ee2:	8d 54 24 03          	lea    0x3(%esp),%edx
  801ee6:	c1 ea 02             	shr    $0x2,%edx
  801ee9:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801ef0:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801ef2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ef5:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801efc:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801f03:	00 
  801f04:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f06:	b8 00 00 00 00       	mov    $0x0,%eax
  801f0b:	eb 0a                	jmp    801f17 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801f0d:	83 c0 01             	add    $0x1,%eax
  801f10:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801f14:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f17:	39 d0                	cmp    %edx,%eax
  801f19:	75 f2                	jne    801f0d <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801f1b:	83 ec 08             	sub    $0x8,%esp
  801f1e:	56                   	push   %esi
  801f1f:	ff 75 08             	pushl  0x8(%ebp)
  801f22:	e8 2c fa ff ff       	call   801953 <spawn>
}
  801f27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f2a:	5b                   	pop    %ebx
  801f2b:	5e                   	pop    %esi
  801f2c:	5d                   	pop    %ebp
  801f2d:	c3                   	ret    

00801f2e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	56                   	push   %esi
  801f32:	53                   	push   %ebx
  801f33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f36:	83 ec 0c             	sub    $0xc,%esp
  801f39:	ff 75 08             	pushl  0x8(%ebp)
  801f3c:	e8 17 f2 ff ff       	call   801158 <fd2data>
  801f41:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f43:	83 c4 08             	add    $0x8,%esp
  801f46:	68 e4 2e 80 00       	push   $0x802ee4
  801f4b:	53                   	push   %ebx
  801f4c:	e8 64 e9 ff ff       	call   8008b5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f51:	8b 46 04             	mov    0x4(%esi),%eax
  801f54:	2b 06                	sub    (%esi),%eax
  801f56:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f5c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f63:	00 00 00 
	stat->st_dev = &devpipe;
  801f66:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801f6d:	30 80 00 
	return 0;
}
  801f70:	b8 00 00 00 00       	mov    $0x0,%eax
  801f75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f78:	5b                   	pop    %ebx
  801f79:	5e                   	pop    %esi
  801f7a:	5d                   	pop    %ebp
  801f7b:	c3                   	ret    

00801f7c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f7c:	55                   	push   %ebp
  801f7d:	89 e5                	mov    %esp,%ebp
  801f7f:	53                   	push   %ebx
  801f80:	83 ec 0c             	sub    $0xc,%esp
  801f83:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f86:	53                   	push   %ebx
  801f87:	6a 00                	push   $0x0
  801f89:	e8 af ed ff ff       	call   800d3d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f8e:	89 1c 24             	mov    %ebx,(%esp)
  801f91:	e8 c2 f1 ff ff       	call   801158 <fd2data>
  801f96:	83 c4 08             	add    $0x8,%esp
  801f99:	50                   	push   %eax
  801f9a:	6a 00                	push   $0x0
  801f9c:	e8 9c ed ff ff       	call   800d3d <sys_page_unmap>
}
  801fa1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fa4:	c9                   	leave  
  801fa5:	c3                   	ret    

00801fa6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801fa6:	55                   	push   %ebp
  801fa7:	89 e5                	mov    %esp,%ebp
  801fa9:	57                   	push   %edi
  801faa:	56                   	push   %esi
  801fab:	53                   	push   %ebx
  801fac:	83 ec 1c             	sub    $0x1c,%esp
  801faf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801fb2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801fb4:	a1 04 40 80 00       	mov    0x804004,%eax
  801fb9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801fbc:	83 ec 0c             	sub    $0xc,%esp
  801fbf:	ff 75 e0             	pushl  -0x20(%ebp)
  801fc2:	e8 12 06 00 00       	call   8025d9 <pageref>
  801fc7:	89 c3                	mov    %eax,%ebx
  801fc9:	89 3c 24             	mov    %edi,(%esp)
  801fcc:	e8 08 06 00 00       	call   8025d9 <pageref>
  801fd1:	83 c4 10             	add    $0x10,%esp
  801fd4:	39 c3                	cmp    %eax,%ebx
  801fd6:	0f 94 c1             	sete   %cl
  801fd9:	0f b6 c9             	movzbl %cl,%ecx
  801fdc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801fdf:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801fe5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fe8:	39 ce                	cmp    %ecx,%esi
  801fea:	74 1b                	je     802007 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801fec:	39 c3                	cmp    %eax,%ebx
  801fee:	75 c4                	jne    801fb4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ff0:	8b 42 58             	mov    0x58(%edx),%eax
  801ff3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ff6:	50                   	push   %eax
  801ff7:	56                   	push   %esi
  801ff8:	68 eb 2e 80 00       	push   $0x802eeb
  801ffd:	e8 af e2 ff ff       	call   8002b1 <cprintf>
  802002:	83 c4 10             	add    $0x10,%esp
  802005:	eb ad                	jmp    801fb4 <_pipeisclosed+0xe>
	}
}
  802007:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80200a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80200d:	5b                   	pop    %ebx
  80200e:	5e                   	pop    %esi
  80200f:	5f                   	pop    %edi
  802010:	5d                   	pop    %ebp
  802011:	c3                   	ret    

00802012 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802012:	55                   	push   %ebp
  802013:	89 e5                	mov    %esp,%ebp
  802015:	57                   	push   %edi
  802016:	56                   	push   %esi
  802017:	53                   	push   %ebx
  802018:	83 ec 28             	sub    $0x28,%esp
  80201b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80201e:	56                   	push   %esi
  80201f:	e8 34 f1 ff ff       	call   801158 <fd2data>
  802024:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802026:	83 c4 10             	add    $0x10,%esp
  802029:	bf 00 00 00 00       	mov    $0x0,%edi
  80202e:	eb 4b                	jmp    80207b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802030:	89 da                	mov    %ebx,%edx
  802032:	89 f0                	mov    %esi,%eax
  802034:	e8 6d ff ff ff       	call   801fa6 <_pipeisclosed>
  802039:	85 c0                	test   %eax,%eax
  80203b:	75 48                	jne    802085 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80203d:	e8 57 ec ff ff       	call   800c99 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802042:	8b 43 04             	mov    0x4(%ebx),%eax
  802045:	8b 0b                	mov    (%ebx),%ecx
  802047:	8d 51 20             	lea    0x20(%ecx),%edx
  80204a:	39 d0                	cmp    %edx,%eax
  80204c:	73 e2                	jae    802030 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80204e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802051:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802055:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802058:	89 c2                	mov    %eax,%edx
  80205a:	c1 fa 1f             	sar    $0x1f,%edx
  80205d:	89 d1                	mov    %edx,%ecx
  80205f:	c1 e9 1b             	shr    $0x1b,%ecx
  802062:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802065:	83 e2 1f             	and    $0x1f,%edx
  802068:	29 ca                	sub    %ecx,%edx
  80206a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80206e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802072:	83 c0 01             	add    $0x1,%eax
  802075:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802078:	83 c7 01             	add    $0x1,%edi
  80207b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80207e:	75 c2                	jne    802042 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802080:	8b 45 10             	mov    0x10(%ebp),%eax
  802083:	eb 05                	jmp    80208a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802085:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80208a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    

00802092 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802092:	55                   	push   %ebp
  802093:	89 e5                	mov    %esp,%ebp
  802095:	57                   	push   %edi
  802096:	56                   	push   %esi
  802097:	53                   	push   %ebx
  802098:	83 ec 18             	sub    $0x18,%esp
  80209b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80209e:	57                   	push   %edi
  80209f:	e8 b4 f0 ff ff       	call   801158 <fd2data>
  8020a4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020a6:	83 c4 10             	add    $0x10,%esp
  8020a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020ae:	eb 3d                	jmp    8020ed <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020b0:	85 db                	test   %ebx,%ebx
  8020b2:	74 04                	je     8020b8 <devpipe_read+0x26>
				return i;
  8020b4:	89 d8                	mov    %ebx,%eax
  8020b6:	eb 44                	jmp    8020fc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020b8:	89 f2                	mov    %esi,%edx
  8020ba:	89 f8                	mov    %edi,%eax
  8020bc:	e8 e5 fe ff ff       	call   801fa6 <_pipeisclosed>
  8020c1:	85 c0                	test   %eax,%eax
  8020c3:	75 32                	jne    8020f7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020c5:	e8 cf eb ff ff       	call   800c99 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020ca:	8b 06                	mov    (%esi),%eax
  8020cc:	3b 46 04             	cmp    0x4(%esi),%eax
  8020cf:	74 df                	je     8020b0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020d1:	99                   	cltd   
  8020d2:	c1 ea 1b             	shr    $0x1b,%edx
  8020d5:	01 d0                	add    %edx,%eax
  8020d7:	83 e0 1f             	and    $0x1f,%eax
  8020da:	29 d0                	sub    %edx,%eax
  8020dc:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8020e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020e4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8020e7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020ea:	83 c3 01             	add    $0x1,%ebx
  8020ed:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020f0:	75 d8                	jne    8020ca <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8020f5:	eb 05                	jmp    8020fc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020f7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ff:	5b                   	pop    %ebx
  802100:	5e                   	pop    %esi
  802101:	5f                   	pop    %edi
  802102:	5d                   	pop    %ebp
  802103:	c3                   	ret    

00802104 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802104:	55                   	push   %ebp
  802105:	89 e5                	mov    %esp,%ebp
  802107:	56                   	push   %esi
  802108:	53                   	push   %ebx
  802109:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80210c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80210f:	50                   	push   %eax
  802110:	e8 5a f0 ff ff       	call   80116f <fd_alloc>
  802115:	83 c4 10             	add    $0x10,%esp
  802118:	89 c2                	mov    %eax,%edx
  80211a:	85 c0                	test   %eax,%eax
  80211c:	0f 88 2c 01 00 00    	js     80224e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802122:	83 ec 04             	sub    $0x4,%esp
  802125:	68 07 04 00 00       	push   $0x407
  80212a:	ff 75 f4             	pushl  -0xc(%ebp)
  80212d:	6a 00                	push   $0x0
  80212f:	e8 84 eb ff ff       	call   800cb8 <sys_page_alloc>
  802134:	83 c4 10             	add    $0x10,%esp
  802137:	89 c2                	mov    %eax,%edx
  802139:	85 c0                	test   %eax,%eax
  80213b:	0f 88 0d 01 00 00    	js     80224e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802141:	83 ec 0c             	sub    $0xc,%esp
  802144:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802147:	50                   	push   %eax
  802148:	e8 22 f0 ff ff       	call   80116f <fd_alloc>
  80214d:	89 c3                	mov    %eax,%ebx
  80214f:	83 c4 10             	add    $0x10,%esp
  802152:	85 c0                	test   %eax,%eax
  802154:	0f 88 e2 00 00 00    	js     80223c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80215a:	83 ec 04             	sub    $0x4,%esp
  80215d:	68 07 04 00 00       	push   $0x407
  802162:	ff 75 f0             	pushl  -0x10(%ebp)
  802165:	6a 00                	push   $0x0
  802167:	e8 4c eb ff ff       	call   800cb8 <sys_page_alloc>
  80216c:	89 c3                	mov    %eax,%ebx
  80216e:	83 c4 10             	add    $0x10,%esp
  802171:	85 c0                	test   %eax,%eax
  802173:	0f 88 c3 00 00 00    	js     80223c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802179:	83 ec 0c             	sub    $0xc,%esp
  80217c:	ff 75 f4             	pushl  -0xc(%ebp)
  80217f:	e8 d4 ef ff ff       	call   801158 <fd2data>
  802184:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802186:	83 c4 0c             	add    $0xc,%esp
  802189:	68 07 04 00 00       	push   $0x407
  80218e:	50                   	push   %eax
  80218f:	6a 00                	push   $0x0
  802191:	e8 22 eb ff ff       	call   800cb8 <sys_page_alloc>
  802196:	89 c3                	mov    %eax,%ebx
  802198:	83 c4 10             	add    $0x10,%esp
  80219b:	85 c0                	test   %eax,%eax
  80219d:	0f 88 89 00 00 00    	js     80222c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021a3:	83 ec 0c             	sub    $0xc,%esp
  8021a6:	ff 75 f0             	pushl  -0x10(%ebp)
  8021a9:	e8 aa ef ff ff       	call   801158 <fd2data>
  8021ae:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021b5:	50                   	push   %eax
  8021b6:	6a 00                	push   $0x0
  8021b8:	56                   	push   %esi
  8021b9:	6a 00                	push   $0x0
  8021bb:	e8 3b eb ff ff       	call   800cfb <sys_page_map>
  8021c0:	89 c3                	mov    %eax,%ebx
  8021c2:	83 c4 20             	add    $0x20,%esp
  8021c5:	85 c0                	test   %eax,%eax
  8021c7:	78 55                	js     80221e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021c9:	8b 15 28 30 80 00    	mov    0x803028,%edx
  8021cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021de:	8b 15 28 30 80 00    	mov    0x803028,%edx
  8021e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021e7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021ec:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021f3:	83 ec 0c             	sub    $0xc,%esp
  8021f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8021f9:	e8 4a ef ff ff       	call   801148 <fd2num>
  8021fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802201:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802203:	83 c4 04             	add    $0x4,%esp
  802206:	ff 75 f0             	pushl  -0x10(%ebp)
  802209:	e8 3a ef ff ff       	call   801148 <fd2num>
  80220e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802211:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802214:	83 c4 10             	add    $0x10,%esp
  802217:	ba 00 00 00 00       	mov    $0x0,%edx
  80221c:	eb 30                	jmp    80224e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80221e:	83 ec 08             	sub    $0x8,%esp
  802221:	56                   	push   %esi
  802222:	6a 00                	push   $0x0
  802224:	e8 14 eb ff ff       	call   800d3d <sys_page_unmap>
  802229:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80222c:	83 ec 08             	sub    $0x8,%esp
  80222f:	ff 75 f0             	pushl  -0x10(%ebp)
  802232:	6a 00                	push   $0x0
  802234:	e8 04 eb ff ff       	call   800d3d <sys_page_unmap>
  802239:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80223c:	83 ec 08             	sub    $0x8,%esp
  80223f:	ff 75 f4             	pushl  -0xc(%ebp)
  802242:	6a 00                	push   $0x0
  802244:	e8 f4 ea ff ff       	call   800d3d <sys_page_unmap>
  802249:	83 c4 10             	add    $0x10,%esp
  80224c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80224e:	89 d0                	mov    %edx,%eax
  802250:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802253:	5b                   	pop    %ebx
  802254:	5e                   	pop    %esi
  802255:	5d                   	pop    %ebp
  802256:	c3                   	ret    

00802257 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802257:	55                   	push   %ebp
  802258:	89 e5                	mov    %esp,%ebp
  80225a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80225d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802260:	50                   	push   %eax
  802261:	ff 75 08             	pushl  0x8(%ebp)
  802264:	e8 55 ef ff ff       	call   8011be <fd_lookup>
  802269:	83 c4 10             	add    $0x10,%esp
  80226c:	85 c0                	test   %eax,%eax
  80226e:	78 18                	js     802288 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802270:	83 ec 0c             	sub    $0xc,%esp
  802273:	ff 75 f4             	pushl  -0xc(%ebp)
  802276:	e8 dd ee ff ff       	call   801158 <fd2data>
	return _pipeisclosed(fd, p);
  80227b:	89 c2                	mov    %eax,%edx
  80227d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802280:	e8 21 fd ff ff       	call   801fa6 <_pipeisclosed>
  802285:	83 c4 10             	add    $0x10,%esp
}
  802288:	c9                   	leave  
  802289:	c3                   	ret    

0080228a <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80228a:	55                   	push   %ebp
  80228b:	89 e5                	mov    %esp,%ebp
  80228d:	56                   	push   %esi
  80228e:	53                   	push   %ebx
  80228f:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802292:	85 f6                	test   %esi,%esi
  802294:	75 16                	jne    8022ac <wait+0x22>
  802296:	68 03 2f 80 00       	push   $0x802f03
  80229b:	68 03 2e 80 00       	push   $0x802e03
  8022a0:	6a 09                	push   $0x9
  8022a2:	68 0e 2f 80 00       	push   $0x802f0e
  8022a7:	e8 2c df ff ff       	call   8001d8 <_panic>
	e = &envs[ENVX(envid)];
  8022ac:	89 f3                	mov    %esi,%ebx
  8022ae:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8022b4:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8022b7:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8022bd:	eb 05                	jmp    8022c4 <wait+0x3a>
		sys_yield();
  8022bf:	e8 d5 e9 ff ff       	call   800c99 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8022c4:	8b 43 48             	mov    0x48(%ebx),%eax
  8022c7:	39 c6                	cmp    %eax,%esi
  8022c9:	75 07                	jne    8022d2 <wait+0x48>
  8022cb:	8b 43 54             	mov    0x54(%ebx),%eax
  8022ce:	85 c0                	test   %eax,%eax
  8022d0:	75 ed                	jne    8022bf <wait+0x35>
		sys_yield();
}
  8022d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022d5:	5b                   	pop    %ebx
  8022d6:	5e                   	pop    %esi
  8022d7:	5d                   	pop    %ebp
  8022d8:	c3                   	ret    

008022d9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022d9:	55                   	push   %ebp
  8022da:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8022e1:	5d                   	pop    %ebp
  8022e2:	c3                   	ret    

008022e3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022e3:	55                   	push   %ebp
  8022e4:	89 e5                	mov    %esp,%ebp
  8022e6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022e9:	68 19 2f 80 00       	push   $0x802f19
  8022ee:	ff 75 0c             	pushl  0xc(%ebp)
  8022f1:	e8 bf e5 ff ff       	call   8008b5 <strcpy>
	return 0;
}
  8022f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8022fb:	c9                   	leave  
  8022fc:	c3                   	ret    

008022fd <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022fd:	55                   	push   %ebp
  8022fe:	89 e5                	mov    %esp,%ebp
  802300:	57                   	push   %edi
  802301:	56                   	push   %esi
  802302:	53                   	push   %ebx
  802303:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802309:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80230e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802314:	eb 2d                	jmp    802343 <devcons_write+0x46>
		m = n - tot;
  802316:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802319:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80231b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80231e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802323:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802326:	83 ec 04             	sub    $0x4,%esp
  802329:	53                   	push   %ebx
  80232a:	03 45 0c             	add    0xc(%ebp),%eax
  80232d:	50                   	push   %eax
  80232e:	57                   	push   %edi
  80232f:	e8 13 e7 ff ff       	call   800a47 <memmove>
		sys_cputs(buf, m);
  802334:	83 c4 08             	add    $0x8,%esp
  802337:	53                   	push   %ebx
  802338:	57                   	push   %edi
  802339:	e8 be e8 ff ff       	call   800bfc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80233e:	01 de                	add    %ebx,%esi
  802340:	83 c4 10             	add    $0x10,%esp
  802343:	89 f0                	mov    %esi,%eax
  802345:	3b 75 10             	cmp    0x10(%ebp),%esi
  802348:	72 cc                	jb     802316 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80234a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80234d:	5b                   	pop    %ebx
  80234e:	5e                   	pop    %esi
  80234f:	5f                   	pop    %edi
  802350:	5d                   	pop    %ebp
  802351:	c3                   	ret    

00802352 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802352:	55                   	push   %ebp
  802353:	89 e5                	mov    %esp,%ebp
  802355:	83 ec 08             	sub    $0x8,%esp
  802358:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80235d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802361:	74 2a                	je     80238d <devcons_read+0x3b>
  802363:	eb 05                	jmp    80236a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802365:	e8 2f e9 ff ff       	call   800c99 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80236a:	e8 ab e8 ff ff       	call   800c1a <sys_cgetc>
  80236f:	85 c0                	test   %eax,%eax
  802371:	74 f2                	je     802365 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802373:	85 c0                	test   %eax,%eax
  802375:	78 16                	js     80238d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802377:	83 f8 04             	cmp    $0x4,%eax
  80237a:	74 0c                	je     802388 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80237c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80237f:	88 02                	mov    %al,(%edx)
	return 1;
  802381:	b8 01 00 00 00       	mov    $0x1,%eax
  802386:	eb 05                	jmp    80238d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802388:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80238d:	c9                   	leave  
  80238e:	c3                   	ret    

0080238f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  80238f:	55                   	push   %ebp
  802390:	89 e5                	mov    %esp,%ebp
  802392:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802395:	8b 45 08             	mov    0x8(%ebp),%eax
  802398:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80239b:	6a 01                	push   $0x1
  80239d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023a0:	50                   	push   %eax
  8023a1:	e8 56 e8 ff ff       	call   800bfc <sys_cputs>
}
  8023a6:	83 c4 10             	add    $0x10,%esp
  8023a9:	c9                   	leave  
  8023aa:	c3                   	ret    

008023ab <getchar>:

int
getchar(void)
{
  8023ab:	55                   	push   %ebp
  8023ac:	89 e5                	mov    %esp,%ebp
  8023ae:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023b1:	6a 01                	push   $0x1
  8023b3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023b6:	50                   	push   %eax
  8023b7:	6a 00                	push   $0x0
  8023b9:	e8 66 f0 ff ff       	call   801424 <read>
	if (r < 0)
  8023be:	83 c4 10             	add    $0x10,%esp
  8023c1:	85 c0                	test   %eax,%eax
  8023c3:	78 0f                	js     8023d4 <getchar+0x29>
		return r;
	if (r < 1)
  8023c5:	85 c0                	test   %eax,%eax
  8023c7:	7e 06                	jle    8023cf <getchar+0x24>
		return -E_EOF;
	return c;
  8023c9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023cd:	eb 05                	jmp    8023d4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023cf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023d4:	c9                   	leave  
  8023d5:	c3                   	ret    

008023d6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023d6:	55                   	push   %ebp
  8023d7:	89 e5                	mov    %esp,%ebp
  8023d9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023df:	50                   	push   %eax
  8023e0:	ff 75 08             	pushl  0x8(%ebp)
  8023e3:	e8 d6 ed ff ff       	call   8011be <fd_lookup>
  8023e8:	83 c4 10             	add    $0x10,%esp
  8023eb:	85 c0                	test   %eax,%eax
  8023ed:	78 11                	js     802400 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023f2:	8b 15 44 30 80 00    	mov    0x803044,%edx
  8023f8:	39 10                	cmp    %edx,(%eax)
  8023fa:	0f 94 c0             	sete   %al
  8023fd:	0f b6 c0             	movzbl %al,%eax
}
  802400:	c9                   	leave  
  802401:	c3                   	ret    

00802402 <opencons>:

int
opencons(void)
{
  802402:	55                   	push   %ebp
  802403:	89 e5                	mov    %esp,%ebp
  802405:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802408:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80240b:	50                   	push   %eax
  80240c:	e8 5e ed ff ff       	call   80116f <fd_alloc>
  802411:	83 c4 10             	add    $0x10,%esp
		return r;
  802414:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802416:	85 c0                	test   %eax,%eax
  802418:	78 3e                	js     802458 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80241a:	83 ec 04             	sub    $0x4,%esp
  80241d:	68 07 04 00 00       	push   $0x407
  802422:	ff 75 f4             	pushl  -0xc(%ebp)
  802425:	6a 00                	push   $0x0
  802427:	e8 8c e8 ff ff       	call   800cb8 <sys_page_alloc>
  80242c:	83 c4 10             	add    $0x10,%esp
		return r;
  80242f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802431:	85 c0                	test   %eax,%eax
  802433:	78 23                	js     802458 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802435:	8b 15 44 30 80 00    	mov    0x803044,%edx
  80243b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80243e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802440:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802443:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80244a:	83 ec 0c             	sub    $0xc,%esp
  80244d:	50                   	push   %eax
  80244e:	e8 f5 ec ff ff       	call   801148 <fd2num>
  802453:	89 c2                	mov    %eax,%edx
  802455:	83 c4 10             	add    $0x10,%esp
}
  802458:	89 d0                	mov    %edx,%eax
  80245a:	c9                   	leave  
  80245b:	c3                   	ret    

0080245c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80245c:	55                   	push   %ebp
  80245d:	89 e5                	mov    %esp,%ebp
  80245f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802462:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802469:	75 4a                	jne    8024b5 <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  80246b:	a1 04 40 80 00       	mov    0x804004,%eax
  802470:	8b 40 48             	mov    0x48(%eax),%eax
  802473:	83 ec 04             	sub    $0x4,%esp
  802476:	6a 07                	push   $0x7
  802478:	68 00 f0 bf ee       	push   $0xeebff000
  80247d:	50                   	push   %eax
  80247e:	e8 35 e8 ff ff       	call   800cb8 <sys_page_alloc>
  802483:	83 c4 10             	add    $0x10,%esp
  802486:	85 c0                	test   %eax,%eax
  802488:	79 12                	jns    80249c <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  80248a:	50                   	push   %eax
  80248b:	68 25 2f 80 00       	push   $0x802f25
  802490:	6a 21                	push   $0x21
  802492:	68 3d 2f 80 00       	push   $0x802f3d
  802497:	e8 3c dd ff ff       	call   8001d8 <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80249c:	a1 04 40 80 00       	mov    0x804004,%eax
  8024a1:	8b 40 48             	mov    0x48(%eax),%eax
  8024a4:	83 ec 08             	sub    $0x8,%esp
  8024a7:	68 bf 24 80 00       	push   $0x8024bf
  8024ac:	50                   	push   %eax
  8024ad:	e8 51 e9 ff ff       	call   800e03 <sys_env_set_pgfault_upcall>
  8024b2:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8024b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b8:	a3 00 60 80 00       	mov    %eax,0x806000
  8024bd:	c9                   	leave  
  8024be:	c3                   	ret    

008024bf <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8024bf:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8024c0:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8024c5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8024c7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  8024ca:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  8024cd:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  8024d1:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  8024d6:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  8024da:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8024dc:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  8024dd:	83 c4 04             	add    $0x4,%esp
	popfl
  8024e0:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8024e1:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  8024e2:	c3                   	ret    

008024e3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024e3:	55                   	push   %ebp
  8024e4:	89 e5                	mov    %esp,%ebp
  8024e6:	56                   	push   %esi
  8024e7:	53                   	push   %ebx
  8024e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8024eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  8024f1:	85 c0                	test   %eax,%eax
  8024f3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8024f8:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  8024fb:	83 ec 0c             	sub    $0xc,%esp
  8024fe:	50                   	push   %eax
  8024ff:	e8 64 e9 ff ff       	call   800e68 <sys_ipc_recv>
  802504:	83 c4 10             	add    $0x10,%esp
  802507:	85 c0                	test   %eax,%eax
  802509:	79 16                	jns    802521 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  80250b:	85 f6                	test   %esi,%esi
  80250d:	74 06                	je     802515 <ipc_recv+0x32>
            *from_env_store = 0;
  80250f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  802515:	85 db                	test   %ebx,%ebx
  802517:	74 2c                	je     802545 <ipc_recv+0x62>
            *perm_store = 0;
  802519:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80251f:	eb 24                	jmp    802545 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  802521:	85 f6                	test   %esi,%esi
  802523:	74 0a                	je     80252f <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  802525:	a1 04 40 80 00       	mov    0x804004,%eax
  80252a:	8b 40 74             	mov    0x74(%eax),%eax
  80252d:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  80252f:	85 db                	test   %ebx,%ebx
  802531:	74 0a                	je     80253d <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  802533:	a1 04 40 80 00       	mov    0x804004,%eax
  802538:	8b 40 78             	mov    0x78(%eax),%eax
  80253b:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  80253d:	a1 04 40 80 00       	mov    0x804004,%eax
  802542:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  802545:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802548:	5b                   	pop    %ebx
  802549:	5e                   	pop    %esi
  80254a:	5d                   	pop    %ebp
  80254b:	c3                   	ret    

0080254c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80254c:	55                   	push   %ebp
  80254d:	89 e5                	mov    %esp,%ebp
  80254f:	57                   	push   %edi
  802550:	56                   	push   %esi
  802551:	53                   	push   %ebx
  802552:	83 ec 0c             	sub    $0xc,%esp
  802555:	8b 7d 08             	mov    0x8(%ebp),%edi
  802558:	8b 75 0c             	mov    0xc(%ebp),%esi
  80255b:	8b 45 10             	mov    0x10(%ebp),%eax
  80255e:	85 c0                	test   %eax,%eax
  802560:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802565:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  802568:	eb 1c                	jmp    802586 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  80256a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80256d:	74 12                	je     802581 <ipc_send+0x35>
  80256f:	50                   	push   %eax
  802570:	68 4b 2f 80 00       	push   $0x802f4b
  802575:	6a 3a                	push   $0x3a
  802577:	68 61 2f 80 00       	push   $0x802f61
  80257c:	e8 57 dc ff ff       	call   8001d8 <_panic>
		sys_yield();
  802581:	e8 13 e7 ff ff       	call   800c99 <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  802586:	ff 75 14             	pushl  0x14(%ebp)
  802589:	53                   	push   %ebx
  80258a:	56                   	push   %esi
  80258b:	57                   	push   %edi
  80258c:	e8 b4 e8 ff ff       	call   800e45 <sys_ipc_try_send>
  802591:	83 c4 10             	add    $0x10,%esp
  802594:	85 c0                	test   %eax,%eax
  802596:	78 d2                	js     80256a <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  802598:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80259b:	5b                   	pop    %ebx
  80259c:	5e                   	pop    %esi
  80259d:	5f                   	pop    %edi
  80259e:	5d                   	pop    %ebp
  80259f:	c3                   	ret    

008025a0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025a0:	55                   	push   %ebp
  8025a1:	89 e5                	mov    %esp,%ebp
  8025a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8025a6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8025ab:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8025ae:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8025b4:	8b 52 50             	mov    0x50(%edx),%edx
  8025b7:	39 ca                	cmp    %ecx,%edx
  8025b9:	75 0d                	jne    8025c8 <ipc_find_env+0x28>
			return envs[i].env_id;
  8025bb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8025be:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025c3:	8b 40 48             	mov    0x48(%eax),%eax
  8025c6:	eb 0f                	jmp    8025d7 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025c8:	83 c0 01             	add    $0x1,%eax
  8025cb:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025d0:	75 d9                	jne    8025ab <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8025d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8025d7:	5d                   	pop    %ebp
  8025d8:	c3                   	ret    

008025d9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025d9:	55                   	push   %ebp
  8025da:	89 e5                	mov    %esp,%ebp
  8025dc:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025df:	89 d0                	mov    %edx,%eax
  8025e1:	c1 e8 16             	shr    $0x16,%eax
  8025e4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8025eb:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025f0:	f6 c1 01             	test   $0x1,%cl
  8025f3:	74 1d                	je     802612 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8025f5:	c1 ea 0c             	shr    $0xc,%edx
  8025f8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8025ff:	f6 c2 01             	test   $0x1,%dl
  802602:	74 0e                	je     802612 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802604:	c1 ea 0c             	shr    $0xc,%edx
  802607:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80260e:	ef 
  80260f:	0f b7 c0             	movzwl %ax,%eax
}
  802612:	5d                   	pop    %ebp
  802613:	c3                   	ret    
  802614:	66 90                	xchg   %ax,%ax
  802616:	66 90                	xchg   %ax,%ax
  802618:	66 90                	xchg   %ax,%ax
  80261a:	66 90                	xchg   %ax,%ax
  80261c:	66 90                	xchg   %ax,%ax
  80261e:	66 90                	xchg   %ax,%ax

00802620 <__udivdi3>:
  802620:	55                   	push   %ebp
  802621:	57                   	push   %edi
  802622:	56                   	push   %esi
  802623:	53                   	push   %ebx
  802624:	83 ec 1c             	sub    $0x1c,%esp
  802627:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80262b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80262f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802633:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802637:	85 f6                	test   %esi,%esi
  802639:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80263d:	89 ca                	mov    %ecx,%edx
  80263f:	89 f8                	mov    %edi,%eax
  802641:	75 3d                	jne    802680 <__udivdi3+0x60>
  802643:	39 cf                	cmp    %ecx,%edi
  802645:	0f 87 c5 00 00 00    	ja     802710 <__udivdi3+0xf0>
  80264b:	85 ff                	test   %edi,%edi
  80264d:	89 fd                	mov    %edi,%ebp
  80264f:	75 0b                	jne    80265c <__udivdi3+0x3c>
  802651:	b8 01 00 00 00       	mov    $0x1,%eax
  802656:	31 d2                	xor    %edx,%edx
  802658:	f7 f7                	div    %edi
  80265a:	89 c5                	mov    %eax,%ebp
  80265c:	89 c8                	mov    %ecx,%eax
  80265e:	31 d2                	xor    %edx,%edx
  802660:	f7 f5                	div    %ebp
  802662:	89 c1                	mov    %eax,%ecx
  802664:	89 d8                	mov    %ebx,%eax
  802666:	89 cf                	mov    %ecx,%edi
  802668:	f7 f5                	div    %ebp
  80266a:	89 c3                	mov    %eax,%ebx
  80266c:	89 d8                	mov    %ebx,%eax
  80266e:	89 fa                	mov    %edi,%edx
  802670:	83 c4 1c             	add    $0x1c,%esp
  802673:	5b                   	pop    %ebx
  802674:	5e                   	pop    %esi
  802675:	5f                   	pop    %edi
  802676:	5d                   	pop    %ebp
  802677:	c3                   	ret    
  802678:	90                   	nop
  802679:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802680:	39 ce                	cmp    %ecx,%esi
  802682:	77 74                	ja     8026f8 <__udivdi3+0xd8>
  802684:	0f bd fe             	bsr    %esi,%edi
  802687:	83 f7 1f             	xor    $0x1f,%edi
  80268a:	0f 84 98 00 00 00    	je     802728 <__udivdi3+0x108>
  802690:	bb 20 00 00 00       	mov    $0x20,%ebx
  802695:	89 f9                	mov    %edi,%ecx
  802697:	89 c5                	mov    %eax,%ebp
  802699:	29 fb                	sub    %edi,%ebx
  80269b:	d3 e6                	shl    %cl,%esi
  80269d:	89 d9                	mov    %ebx,%ecx
  80269f:	d3 ed                	shr    %cl,%ebp
  8026a1:	89 f9                	mov    %edi,%ecx
  8026a3:	d3 e0                	shl    %cl,%eax
  8026a5:	09 ee                	or     %ebp,%esi
  8026a7:	89 d9                	mov    %ebx,%ecx
  8026a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026ad:	89 d5                	mov    %edx,%ebp
  8026af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026b3:	d3 ed                	shr    %cl,%ebp
  8026b5:	89 f9                	mov    %edi,%ecx
  8026b7:	d3 e2                	shl    %cl,%edx
  8026b9:	89 d9                	mov    %ebx,%ecx
  8026bb:	d3 e8                	shr    %cl,%eax
  8026bd:	09 c2                	or     %eax,%edx
  8026bf:	89 d0                	mov    %edx,%eax
  8026c1:	89 ea                	mov    %ebp,%edx
  8026c3:	f7 f6                	div    %esi
  8026c5:	89 d5                	mov    %edx,%ebp
  8026c7:	89 c3                	mov    %eax,%ebx
  8026c9:	f7 64 24 0c          	mull   0xc(%esp)
  8026cd:	39 d5                	cmp    %edx,%ebp
  8026cf:	72 10                	jb     8026e1 <__udivdi3+0xc1>
  8026d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8026d5:	89 f9                	mov    %edi,%ecx
  8026d7:	d3 e6                	shl    %cl,%esi
  8026d9:	39 c6                	cmp    %eax,%esi
  8026db:	73 07                	jae    8026e4 <__udivdi3+0xc4>
  8026dd:	39 d5                	cmp    %edx,%ebp
  8026df:	75 03                	jne    8026e4 <__udivdi3+0xc4>
  8026e1:	83 eb 01             	sub    $0x1,%ebx
  8026e4:	31 ff                	xor    %edi,%edi
  8026e6:	89 d8                	mov    %ebx,%eax
  8026e8:	89 fa                	mov    %edi,%edx
  8026ea:	83 c4 1c             	add    $0x1c,%esp
  8026ed:	5b                   	pop    %ebx
  8026ee:	5e                   	pop    %esi
  8026ef:	5f                   	pop    %edi
  8026f0:	5d                   	pop    %ebp
  8026f1:	c3                   	ret    
  8026f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026f8:	31 ff                	xor    %edi,%edi
  8026fa:	31 db                	xor    %ebx,%ebx
  8026fc:	89 d8                	mov    %ebx,%eax
  8026fe:	89 fa                	mov    %edi,%edx
  802700:	83 c4 1c             	add    $0x1c,%esp
  802703:	5b                   	pop    %ebx
  802704:	5e                   	pop    %esi
  802705:	5f                   	pop    %edi
  802706:	5d                   	pop    %ebp
  802707:	c3                   	ret    
  802708:	90                   	nop
  802709:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802710:	89 d8                	mov    %ebx,%eax
  802712:	f7 f7                	div    %edi
  802714:	31 ff                	xor    %edi,%edi
  802716:	89 c3                	mov    %eax,%ebx
  802718:	89 d8                	mov    %ebx,%eax
  80271a:	89 fa                	mov    %edi,%edx
  80271c:	83 c4 1c             	add    $0x1c,%esp
  80271f:	5b                   	pop    %ebx
  802720:	5e                   	pop    %esi
  802721:	5f                   	pop    %edi
  802722:	5d                   	pop    %ebp
  802723:	c3                   	ret    
  802724:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802728:	39 ce                	cmp    %ecx,%esi
  80272a:	72 0c                	jb     802738 <__udivdi3+0x118>
  80272c:	31 db                	xor    %ebx,%ebx
  80272e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802732:	0f 87 34 ff ff ff    	ja     80266c <__udivdi3+0x4c>
  802738:	bb 01 00 00 00       	mov    $0x1,%ebx
  80273d:	e9 2a ff ff ff       	jmp    80266c <__udivdi3+0x4c>
  802742:	66 90                	xchg   %ax,%ax
  802744:	66 90                	xchg   %ax,%ax
  802746:	66 90                	xchg   %ax,%ax
  802748:	66 90                	xchg   %ax,%ax
  80274a:	66 90                	xchg   %ax,%ax
  80274c:	66 90                	xchg   %ax,%ax
  80274e:	66 90                	xchg   %ax,%ax

00802750 <__umoddi3>:
  802750:	55                   	push   %ebp
  802751:	57                   	push   %edi
  802752:	56                   	push   %esi
  802753:	53                   	push   %ebx
  802754:	83 ec 1c             	sub    $0x1c,%esp
  802757:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80275b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80275f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802763:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802767:	85 d2                	test   %edx,%edx
  802769:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80276d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802771:	89 f3                	mov    %esi,%ebx
  802773:	89 3c 24             	mov    %edi,(%esp)
  802776:	89 74 24 04          	mov    %esi,0x4(%esp)
  80277a:	75 1c                	jne    802798 <__umoddi3+0x48>
  80277c:	39 f7                	cmp    %esi,%edi
  80277e:	76 50                	jbe    8027d0 <__umoddi3+0x80>
  802780:	89 c8                	mov    %ecx,%eax
  802782:	89 f2                	mov    %esi,%edx
  802784:	f7 f7                	div    %edi
  802786:	89 d0                	mov    %edx,%eax
  802788:	31 d2                	xor    %edx,%edx
  80278a:	83 c4 1c             	add    $0x1c,%esp
  80278d:	5b                   	pop    %ebx
  80278e:	5e                   	pop    %esi
  80278f:	5f                   	pop    %edi
  802790:	5d                   	pop    %ebp
  802791:	c3                   	ret    
  802792:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802798:	39 f2                	cmp    %esi,%edx
  80279a:	89 d0                	mov    %edx,%eax
  80279c:	77 52                	ja     8027f0 <__umoddi3+0xa0>
  80279e:	0f bd ea             	bsr    %edx,%ebp
  8027a1:	83 f5 1f             	xor    $0x1f,%ebp
  8027a4:	75 5a                	jne    802800 <__umoddi3+0xb0>
  8027a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8027aa:	0f 82 e0 00 00 00    	jb     802890 <__umoddi3+0x140>
  8027b0:	39 0c 24             	cmp    %ecx,(%esp)
  8027b3:	0f 86 d7 00 00 00    	jbe    802890 <__umoddi3+0x140>
  8027b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8027c1:	83 c4 1c             	add    $0x1c,%esp
  8027c4:	5b                   	pop    %ebx
  8027c5:	5e                   	pop    %esi
  8027c6:	5f                   	pop    %edi
  8027c7:	5d                   	pop    %ebp
  8027c8:	c3                   	ret    
  8027c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027d0:	85 ff                	test   %edi,%edi
  8027d2:	89 fd                	mov    %edi,%ebp
  8027d4:	75 0b                	jne    8027e1 <__umoddi3+0x91>
  8027d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027db:	31 d2                	xor    %edx,%edx
  8027dd:	f7 f7                	div    %edi
  8027df:	89 c5                	mov    %eax,%ebp
  8027e1:	89 f0                	mov    %esi,%eax
  8027e3:	31 d2                	xor    %edx,%edx
  8027e5:	f7 f5                	div    %ebp
  8027e7:	89 c8                	mov    %ecx,%eax
  8027e9:	f7 f5                	div    %ebp
  8027eb:	89 d0                	mov    %edx,%eax
  8027ed:	eb 99                	jmp    802788 <__umoddi3+0x38>
  8027ef:	90                   	nop
  8027f0:	89 c8                	mov    %ecx,%eax
  8027f2:	89 f2                	mov    %esi,%edx
  8027f4:	83 c4 1c             	add    $0x1c,%esp
  8027f7:	5b                   	pop    %ebx
  8027f8:	5e                   	pop    %esi
  8027f9:	5f                   	pop    %edi
  8027fa:	5d                   	pop    %ebp
  8027fb:	c3                   	ret    
  8027fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802800:	8b 34 24             	mov    (%esp),%esi
  802803:	bf 20 00 00 00       	mov    $0x20,%edi
  802808:	89 e9                	mov    %ebp,%ecx
  80280a:	29 ef                	sub    %ebp,%edi
  80280c:	d3 e0                	shl    %cl,%eax
  80280e:	89 f9                	mov    %edi,%ecx
  802810:	89 f2                	mov    %esi,%edx
  802812:	d3 ea                	shr    %cl,%edx
  802814:	89 e9                	mov    %ebp,%ecx
  802816:	09 c2                	or     %eax,%edx
  802818:	89 d8                	mov    %ebx,%eax
  80281a:	89 14 24             	mov    %edx,(%esp)
  80281d:	89 f2                	mov    %esi,%edx
  80281f:	d3 e2                	shl    %cl,%edx
  802821:	89 f9                	mov    %edi,%ecx
  802823:	89 54 24 04          	mov    %edx,0x4(%esp)
  802827:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80282b:	d3 e8                	shr    %cl,%eax
  80282d:	89 e9                	mov    %ebp,%ecx
  80282f:	89 c6                	mov    %eax,%esi
  802831:	d3 e3                	shl    %cl,%ebx
  802833:	89 f9                	mov    %edi,%ecx
  802835:	89 d0                	mov    %edx,%eax
  802837:	d3 e8                	shr    %cl,%eax
  802839:	89 e9                	mov    %ebp,%ecx
  80283b:	09 d8                	or     %ebx,%eax
  80283d:	89 d3                	mov    %edx,%ebx
  80283f:	89 f2                	mov    %esi,%edx
  802841:	f7 34 24             	divl   (%esp)
  802844:	89 d6                	mov    %edx,%esi
  802846:	d3 e3                	shl    %cl,%ebx
  802848:	f7 64 24 04          	mull   0x4(%esp)
  80284c:	39 d6                	cmp    %edx,%esi
  80284e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802852:	89 d1                	mov    %edx,%ecx
  802854:	89 c3                	mov    %eax,%ebx
  802856:	72 08                	jb     802860 <__umoddi3+0x110>
  802858:	75 11                	jne    80286b <__umoddi3+0x11b>
  80285a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80285e:	73 0b                	jae    80286b <__umoddi3+0x11b>
  802860:	2b 44 24 04          	sub    0x4(%esp),%eax
  802864:	1b 14 24             	sbb    (%esp),%edx
  802867:	89 d1                	mov    %edx,%ecx
  802869:	89 c3                	mov    %eax,%ebx
  80286b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80286f:	29 da                	sub    %ebx,%edx
  802871:	19 ce                	sbb    %ecx,%esi
  802873:	89 f9                	mov    %edi,%ecx
  802875:	89 f0                	mov    %esi,%eax
  802877:	d3 e0                	shl    %cl,%eax
  802879:	89 e9                	mov    %ebp,%ecx
  80287b:	d3 ea                	shr    %cl,%edx
  80287d:	89 e9                	mov    %ebp,%ecx
  80287f:	d3 ee                	shr    %cl,%esi
  802881:	09 d0                	or     %edx,%eax
  802883:	89 f2                	mov    %esi,%edx
  802885:	83 c4 1c             	add    $0x1c,%esp
  802888:	5b                   	pop    %ebx
  802889:	5e                   	pop    %esi
  80288a:	5f                   	pop    %edi
  80288b:	5d                   	pop    %ebp
  80288c:	c3                   	ret    
  80288d:	8d 76 00             	lea    0x0(%esi),%esi
  802890:	29 f9                	sub    %edi,%ecx
  802892:	19 d6                	sbb    %edx,%esi
  802894:	89 74 24 04          	mov    %esi,0x4(%esp)
  802898:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80289c:	e9 18 ff ff ff       	jmp    8027b9 <__umoddi3+0x69>
