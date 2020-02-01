
obj/user/primes.debug：     文件格式 elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 7c 10 00 00       	call   8010c8 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 40 80 00       	mov    0x804004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 00 22 80 00       	push   $0x802200
  800060:	e8 cc 01 00 00       	call   800231 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 b1 0e 00 00       	call   800f1b <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 0c 22 80 00       	push   $0x80220c
  800079:	6a 1a                	push   $0x1a
  80007b:	68 15 22 80 00       	push   $0x802215
  800080:	e8 d3 00 00 00       	call   800158 <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b6                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 00                	push   $0x0
  800091:	6a 00                	push   $0x0
  800093:	56                   	push   %esi
  800094:	e8 2f 10 00 00       	call   8010c8 <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e7                	je     80008c <primeproc+0x59>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	57                   	push   %edi
  8000ab:	e8 81 10 00 00       	call   801131 <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d7                	jmp    80008c <primeproc+0x59>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 5c 0e 00 00       	call   800f1b <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 0c 22 80 00       	push   $0x80220c
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 15 22 80 00       	push   $0x802215
  8000d2:	e8 81 00 00 00       	call   800158 <_panic>
  8000d7:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	75 05                	jne    8000e5 <umain+0x30>
		primeproc();
  8000e0:	e8 4e ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	53                   	push   %ebx
  8000ea:	56                   	push   %esi
  8000eb:	e8 41 10 00 00       	call   801131 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f0:	83 c3 01             	add    $0x1,%ebx
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	eb ed                	jmp    8000e5 <umain+0x30>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800103:	e8 f2 0a 00 00       	call   800bfa <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800115:	a3 04 40 80 00       	mov    %eax,0x804004

    // save the name of the program so that panic() can use it
    if (argc > 0)
  80011a:	85 db                	test   %ebx,%ebx
  80011c:	7e 07                	jle    800125 <libmain+0x2d>
        binaryname = argv[0];
  80011e:	8b 06                	mov    (%esi),%eax
  800120:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	e8 86 ff ff ff       	call   8000b5 <umain>

    // exit gracefully
    exit();
  80012f:	e8 0a 00 00 00       	call   80013e <exit>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800144:	e8 40 12 00 00       	call   801389 <close_all>
	sys_env_destroy(0);
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	6a 00                	push   $0x0
  80014e:	e8 66 0a 00 00       	call   800bb9 <sys_env_destroy>
}
  800153:	83 c4 10             	add    $0x10,%esp
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800160:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800166:	e8 8f 0a 00 00       	call   800bfa <sys_getenvid>
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	56                   	push   %esi
  800175:	50                   	push   %eax
  800176:	68 30 22 80 00       	push   $0x802230
  80017b:	e8 b1 00 00 00       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 54 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 2b 27 80 00 	movl   $0x80272b,(%esp)
  800193:	e8 99 00 00 00       	call   800231 <cprintf>
  800198:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x43>

0080019e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	53                   	push   %ebx
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a8:	8b 13                	mov    (%ebx),%edx
  8001aa:	8d 42 01             	lea    0x1(%edx),%eax
  8001ad:	89 03                	mov    %eax,(%ebx)
  8001af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bb:	75 1a                	jne    8001d7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001bd:	83 ec 08             	sub    $0x8,%esp
  8001c0:	68 ff 00 00 00       	push   $0xff
  8001c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c8:	50                   	push   %eax
  8001c9:	e8 ae 09 00 00       	call   800b7c <sys_cputs>
		b->idx = 0;
  8001ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f0:	00 00 00 
	b.cnt = 0;
  8001f3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fd:	ff 75 0c             	pushl  0xc(%ebp)
  800200:	ff 75 08             	pushl  0x8(%ebp)
  800203:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800209:	50                   	push   %eax
  80020a:	68 9e 01 80 00       	push   $0x80019e
  80020f:	e8 1a 01 00 00       	call   80032e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800214:	83 c4 08             	add    $0x8,%esp
  800217:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800223:	50                   	push   %eax
  800224:	e8 53 09 00 00       	call   800b7c <sys_cputs>

	return b.cnt;
}
  800229:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800237:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023a:	50                   	push   %eax
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	e8 9d ff ff ff       	call   8001e0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	57                   	push   %edi
  800249:	56                   	push   %esi
  80024a:	53                   	push   %ebx
  80024b:	83 ec 1c             	sub    $0x1c,%esp
  80024e:	89 c7                	mov    %eax,%edi
  800250:	89 d6                	mov    %edx,%esi
  800252:	8b 45 08             	mov    0x8(%ebp),%eax
  800255:	8b 55 0c             	mov    0xc(%ebp),%edx
  800258:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800261:	bb 00 00 00 00       	mov    $0x0,%ebx
  800266:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800269:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026c:	39 d3                	cmp    %edx,%ebx
  80026e:	72 05                	jb     800275 <printnum+0x30>
  800270:	39 45 10             	cmp    %eax,0x10(%ebp)
  800273:	77 45                	ja     8002ba <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800275:	83 ec 0c             	sub    $0xc,%esp
  800278:	ff 75 18             	pushl  0x18(%ebp)
  80027b:	8b 45 14             	mov    0x14(%ebp),%eax
  80027e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800281:	53                   	push   %ebx
  800282:	ff 75 10             	pushl  0x10(%ebp)
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 d7 1c 00 00       	call   801f70 <__udivdi3>
  800299:	83 c4 18             	add    $0x18,%esp
  80029c:	52                   	push   %edx
  80029d:	50                   	push   %eax
  80029e:	89 f2                	mov    %esi,%edx
  8002a0:	89 f8                	mov    %edi,%eax
  8002a2:	e8 9e ff ff ff       	call   800245 <printnum>
  8002a7:	83 c4 20             	add    $0x20,%esp
  8002aa:	eb 18                	jmp    8002c4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	ff 75 18             	pushl  0x18(%ebp)
  8002b3:	ff d7                	call   *%edi
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	eb 03                	jmp    8002bd <printnum+0x78>
  8002ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bd:	83 eb 01             	sub    $0x1,%ebx
  8002c0:	85 db                	test   %ebx,%ebx
  8002c2:	7f e8                	jg     8002ac <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c4:	83 ec 08             	sub    $0x8,%esp
  8002c7:	56                   	push   %esi
  8002c8:	83 ec 04             	sub    $0x4,%esp
  8002cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d7:	e8 c4 1d 00 00       	call   8020a0 <__umoddi3>
  8002dc:	83 c4 14             	add    $0x14,%esp
  8002df:	0f be 80 53 22 80 00 	movsbl 0x802253(%eax),%eax
  8002e6:	50                   	push   %eax
  8002e7:	ff d7                	call   *%edi
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ef:	5b                   	pop    %ebx
  8002f0:	5e                   	pop    %esi
  8002f1:	5f                   	pop    %edi
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fa:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002fe:	8b 10                	mov    (%eax),%edx
  800300:	3b 50 04             	cmp    0x4(%eax),%edx
  800303:	73 0a                	jae    80030f <sprintputch+0x1b>
		*b->buf++ = ch;
  800305:	8d 4a 01             	lea    0x1(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 45 08             	mov    0x8(%ebp),%eax
  80030d:	88 02                	mov    %al,(%edx)
}
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800317:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031a:	50                   	push   %eax
  80031b:	ff 75 10             	pushl  0x10(%ebp)
  80031e:	ff 75 0c             	pushl  0xc(%ebp)
  800321:	ff 75 08             	pushl  0x8(%ebp)
  800324:	e8 05 00 00 00       	call   80032e <vprintfmt>
	va_end(ap);
}
  800329:	83 c4 10             	add    $0x10,%esp
  80032c:	c9                   	leave  
  80032d:	c3                   	ret    

0080032e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	57                   	push   %edi
  800332:	56                   	push   %esi
  800333:	53                   	push   %ebx
  800334:	83 ec 2c             	sub    $0x2c,%esp
  800337:	8b 75 08             	mov    0x8(%ebp),%esi
  80033a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80033d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800340:	eb 12                	jmp    800354 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800342:	85 c0                	test   %eax,%eax
  800344:	0f 84 42 04 00 00    	je     80078c <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80034a:	83 ec 08             	sub    $0x8,%esp
  80034d:	53                   	push   %ebx
  80034e:	50                   	push   %eax
  80034f:	ff d6                	call   *%esi
  800351:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800354:	83 c7 01             	add    $0x1,%edi
  800357:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80035b:	83 f8 25             	cmp    $0x25,%eax
  80035e:	75 e2                	jne    800342 <vprintfmt+0x14>
  800360:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800364:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80036b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800372:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800379:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037e:	eb 07                	jmp    800387 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800383:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800387:	8d 47 01             	lea    0x1(%edi),%eax
  80038a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038d:	0f b6 07             	movzbl (%edi),%eax
  800390:	0f b6 d0             	movzbl %al,%edx
  800393:	83 e8 23             	sub    $0x23,%eax
  800396:	3c 55                	cmp    $0x55,%al
  800398:	0f 87 d3 03 00 00    	ja     800771 <vprintfmt+0x443>
  80039e:	0f b6 c0             	movzbl %al,%eax
  8003a1:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ab:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003af:	eb d6                	jmp    800387 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003bc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003bf:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003c3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003c6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003c9:	83 f9 09             	cmp    $0x9,%ecx
  8003cc:	77 3f                	ja     80040d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ce:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d1:	eb e9                	jmp    8003bc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d6:	8b 00                	mov    (%eax),%eax
  8003d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003db:	8b 45 14             	mov    0x14(%ebp),%eax
  8003de:	8d 40 04             	lea    0x4(%eax),%eax
  8003e1:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e7:	eb 2a                	jmp    800413 <vprintfmt+0xe5>
  8003e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ec:	85 c0                	test   %eax,%eax
  8003ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f3:	0f 49 d0             	cmovns %eax,%edx
  8003f6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003fc:	eb 89                	jmp    800387 <vprintfmt+0x59>
  8003fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800401:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800408:	e9 7a ff ff ff       	jmp    800387 <vprintfmt+0x59>
  80040d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800410:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800413:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800417:	0f 89 6a ff ff ff    	jns    800387 <vprintfmt+0x59>
				width = precision, precision = -1;
  80041d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800420:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800423:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80042a:	e9 58 ff ff ff       	jmp    800387 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80042f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800435:	e9 4d ff ff ff       	jmp    800387 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8d 78 04             	lea    0x4(%eax),%edi
  800440:	83 ec 08             	sub    $0x8,%esp
  800443:	53                   	push   %ebx
  800444:	ff 30                	pushl  (%eax)
  800446:	ff d6                	call   *%esi
			break;
  800448:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80044b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800451:	e9 fe fe ff ff       	jmp    800354 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800456:	8b 45 14             	mov    0x14(%ebp),%eax
  800459:	8d 78 04             	lea    0x4(%eax),%edi
  80045c:	8b 00                	mov    (%eax),%eax
  80045e:	99                   	cltd   
  80045f:	31 d0                	xor    %edx,%eax
  800461:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800463:	83 f8 0f             	cmp    $0xf,%eax
  800466:	7f 0b                	jg     800473 <vprintfmt+0x145>
  800468:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  80046f:	85 d2                	test   %edx,%edx
  800471:	75 1b                	jne    80048e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800473:	50                   	push   %eax
  800474:	68 6b 22 80 00       	push   $0x80226b
  800479:	53                   	push   %ebx
  80047a:	56                   	push   %esi
  80047b:	e8 91 fe ff ff       	call   800311 <printfmt>
  800480:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800483:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800489:	e9 c6 fe ff ff       	jmp    800354 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80048e:	52                   	push   %edx
  80048f:	68 f9 26 80 00       	push   $0x8026f9
  800494:	53                   	push   %ebx
  800495:	56                   	push   %esi
  800496:	e8 76 fe ff ff       	call   800311 <printfmt>
  80049b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80049e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a4:	e9 ab fe ff ff       	jmp    800354 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	83 c0 04             	add    $0x4,%eax
  8004af:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004b7:	85 ff                	test   %edi,%edi
  8004b9:	b8 64 22 80 00       	mov    $0x802264,%eax
  8004be:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c5:	0f 8e 94 00 00 00    	jle    80055f <vprintfmt+0x231>
  8004cb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004cf:	0f 84 98 00 00 00    	je     80056d <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	ff 75 d0             	pushl  -0x30(%ebp)
  8004db:	57                   	push   %edi
  8004dc:	e8 33 03 00 00       	call   800814 <strnlen>
  8004e1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e4:	29 c1                	sub    %eax,%ecx
  8004e6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004e9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ec:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	eb 0f                	jmp    800509 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	53                   	push   %ebx
  8004fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800501:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	83 ef 01             	sub    $0x1,%edi
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	85 ff                	test   %edi,%edi
  80050b:	7f ed                	jg     8004fa <vprintfmt+0x1cc>
  80050d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800510:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800513:	85 c9                	test   %ecx,%ecx
  800515:	b8 00 00 00 00       	mov    $0x0,%eax
  80051a:	0f 49 c1             	cmovns %ecx,%eax
  80051d:	29 c1                	sub    %eax,%ecx
  80051f:	89 75 08             	mov    %esi,0x8(%ebp)
  800522:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800525:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800528:	89 cb                	mov    %ecx,%ebx
  80052a:	eb 4d                	jmp    800579 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80052c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800530:	74 1b                	je     80054d <vprintfmt+0x21f>
  800532:	0f be c0             	movsbl %al,%eax
  800535:	83 e8 20             	sub    $0x20,%eax
  800538:	83 f8 5e             	cmp    $0x5e,%eax
  80053b:	76 10                	jbe    80054d <vprintfmt+0x21f>
					putch('?', putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	ff 75 0c             	pushl  0xc(%ebp)
  800543:	6a 3f                	push   $0x3f
  800545:	ff 55 08             	call   *0x8(%ebp)
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	eb 0d                	jmp    80055a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	ff 75 0c             	pushl  0xc(%ebp)
  800553:	52                   	push   %edx
  800554:	ff 55 08             	call   *0x8(%ebp)
  800557:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055a:	83 eb 01             	sub    $0x1,%ebx
  80055d:	eb 1a                	jmp    800579 <vprintfmt+0x24b>
  80055f:	89 75 08             	mov    %esi,0x8(%ebp)
  800562:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800565:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800568:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056b:	eb 0c                	jmp    800579 <vprintfmt+0x24b>
  80056d:	89 75 08             	mov    %esi,0x8(%ebp)
  800570:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800573:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800576:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800579:	83 c7 01             	add    $0x1,%edi
  80057c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800580:	0f be d0             	movsbl %al,%edx
  800583:	85 d2                	test   %edx,%edx
  800585:	74 23                	je     8005aa <vprintfmt+0x27c>
  800587:	85 f6                	test   %esi,%esi
  800589:	78 a1                	js     80052c <vprintfmt+0x1fe>
  80058b:	83 ee 01             	sub    $0x1,%esi
  80058e:	79 9c                	jns    80052c <vprintfmt+0x1fe>
  800590:	89 df                	mov    %ebx,%edi
  800592:	8b 75 08             	mov    0x8(%ebp),%esi
  800595:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800598:	eb 18                	jmp    8005b2 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	53                   	push   %ebx
  80059e:	6a 20                	push   $0x20
  8005a0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a2:	83 ef 01             	sub    $0x1,%edi
  8005a5:	83 c4 10             	add    $0x10,%esp
  8005a8:	eb 08                	jmp    8005b2 <vprintfmt+0x284>
  8005aa:	89 df                	mov    %ebx,%edi
  8005ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8005af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b2:	85 ff                	test   %edi,%edi
  8005b4:	7f e4                	jg     80059a <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005b9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005bf:	e9 90 fd ff ff       	jmp    800354 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c4:	83 f9 01             	cmp    $0x1,%ecx
  8005c7:	7e 19                	jle    8005e2 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8b 50 04             	mov    0x4(%eax),%edx
  8005cf:	8b 00                	mov    (%eax),%eax
  8005d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8d 40 08             	lea    0x8(%eax),%eax
  8005dd:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e0:	eb 38                	jmp    80061a <vprintfmt+0x2ec>
	else if (lflag)
  8005e2:	85 c9                	test   %ecx,%ecx
  8005e4:	74 1b                	je     800601 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8b 00                	mov    (%eax),%eax
  8005eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ee:	89 c1                	mov    %eax,%ecx
  8005f0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8d 40 04             	lea    0x4(%eax),%eax
  8005fc:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ff:	eb 19                	jmp    80061a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8b 00                	mov    (%eax),%eax
  800606:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800609:	89 c1                	mov    %eax,%ecx
  80060b:	c1 f9 1f             	sar    $0x1f,%ecx
  80060e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8d 40 04             	lea    0x4(%eax),%eax
  800617:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80061d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800620:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800625:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800629:	0f 89 0e 01 00 00    	jns    80073d <vprintfmt+0x40f>
				putch('-', putdat);
  80062f:	83 ec 08             	sub    $0x8,%esp
  800632:	53                   	push   %ebx
  800633:	6a 2d                	push   $0x2d
  800635:	ff d6                	call   *%esi
				num = -(long long) num;
  800637:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80063a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80063d:	f7 da                	neg    %edx
  80063f:	83 d1 00             	adc    $0x0,%ecx
  800642:	f7 d9                	neg    %ecx
  800644:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800647:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064c:	e9 ec 00 00 00       	jmp    80073d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800651:	83 f9 01             	cmp    $0x1,%ecx
  800654:	7e 18                	jle    80066e <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8b 10                	mov    (%eax),%edx
  80065b:	8b 48 04             	mov    0x4(%eax),%ecx
  80065e:	8d 40 08             	lea    0x8(%eax),%eax
  800661:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800664:	b8 0a 00 00 00       	mov    $0xa,%eax
  800669:	e9 cf 00 00 00       	jmp    80073d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80066e:	85 c9                	test   %ecx,%ecx
  800670:	74 1a                	je     80068c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8b 10                	mov    (%eax),%edx
  800677:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067c:	8d 40 04             	lea    0x4(%eax),%eax
  80067f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800682:	b8 0a 00 00 00       	mov    $0xa,%eax
  800687:	e9 b1 00 00 00       	jmp    80073d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8b 10                	mov    (%eax),%edx
  800691:	b9 00 00 00 00       	mov    $0x0,%ecx
  800696:	8d 40 04             	lea    0x4(%eax),%eax
  800699:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80069c:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a1:	e9 97 00 00 00       	jmp    80073d <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006a6:	83 ec 08             	sub    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	6a 58                	push   $0x58
  8006ac:	ff d6                	call   *%esi
			putch('X', putdat);
  8006ae:	83 c4 08             	add    $0x8,%esp
  8006b1:	53                   	push   %ebx
  8006b2:	6a 58                	push   $0x58
  8006b4:	ff d6                	call   *%esi
			putch('X', putdat);
  8006b6:	83 c4 08             	add    $0x8,%esp
  8006b9:	53                   	push   %ebx
  8006ba:	6a 58                	push   $0x58
  8006bc:	ff d6                	call   *%esi
			break;
  8006be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006c4:	e9 8b fc ff ff       	jmp    800354 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	53                   	push   %ebx
  8006cd:	6a 30                	push   $0x30
  8006cf:	ff d6                	call   *%esi
			putch('x', putdat);
  8006d1:	83 c4 08             	add    $0x8,%esp
  8006d4:	53                   	push   %ebx
  8006d5:	6a 78                	push   $0x78
  8006d7:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8b 10                	mov    (%eax),%edx
  8006de:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006e3:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006e6:	8d 40 04             	lea    0x4(%eax),%eax
  8006e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ec:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006f1:	eb 4a                	jmp    80073d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006f3:	83 f9 01             	cmp    $0x1,%ecx
  8006f6:	7e 15                	jle    80070d <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8b 10                	mov    (%eax),%edx
  8006fd:	8b 48 04             	mov    0x4(%eax),%ecx
  800700:	8d 40 08             	lea    0x8(%eax),%eax
  800703:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800706:	b8 10 00 00 00       	mov    $0x10,%eax
  80070b:	eb 30                	jmp    80073d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80070d:	85 c9                	test   %ecx,%ecx
  80070f:	74 17                	je     800728 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800711:	8b 45 14             	mov    0x14(%ebp),%eax
  800714:	8b 10                	mov    (%eax),%edx
  800716:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071b:	8d 40 04             	lea    0x4(%eax),%eax
  80071e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800721:	b8 10 00 00 00       	mov    $0x10,%eax
  800726:	eb 15                	jmp    80073d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800728:	8b 45 14             	mov    0x14(%ebp),%eax
  80072b:	8b 10                	mov    (%eax),%edx
  80072d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800732:	8d 40 04             	lea    0x4(%eax),%eax
  800735:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800738:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80073d:	83 ec 0c             	sub    $0xc,%esp
  800740:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800744:	57                   	push   %edi
  800745:	ff 75 e0             	pushl  -0x20(%ebp)
  800748:	50                   	push   %eax
  800749:	51                   	push   %ecx
  80074a:	52                   	push   %edx
  80074b:	89 da                	mov    %ebx,%edx
  80074d:	89 f0                	mov    %esi,%eax
  80074f:	e8 f1 fa ff ff       	call   800245 <printnum>
			break;
  800754:	83 c4 20             	add    $0x20,%esp
  800757:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075a:	e9 f5 fb ff ff       	jmp    800354 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80075f:	83 ec 08             	sub    $0x8,%esp
  800762:	53                   	push   %ebx
  800763:	52                   	push   %edx
  800764:	ff d6                	call   *%esi
			break;
  800766:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800769:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80076c:	e9 e3 fb ff ff       	jmp    800354 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800771:	83 ec 08             	sub    $0x8,%esp
  800774:	53                   	push   %ebx
  800775:	6a 25                	push   $0x25
  800777:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800779:	83 c4 10             	add    $0x10,%esp
  80077c:	eb 03                	jmp    800781 <vprintfmt+0x453>
  80077e:	83 ef 01             	sub    $0x1,%edi
  800781:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800785:	75 f7                	jne    80077e <vprintfmt+0x450>
  800787:	e9 c8 fb ff ff       	jmp    800354 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80078c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078f:	5b                   	pop    %ebx
  800790:	5e                   	pop    %esi
  800791:	5f                   	pop    %edi
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	83 ec 18             	sub    $0x18,%esp
  80079a:	8b 45 08             	mov    0x8(%ebp),%eax
  80079d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b1:	85 c0                	test   %eax,%eax
  8007b3:	74 26                	je     8007db <vsnprintf+0x47>
  8007b5:	85 d2                	test   %edx,%edx
  8007b7:	7e 22                	jle    8007db <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b9:	ff 75 14             	pushl  0x14(%ebp)
  8007bc:	ff 75 10             	pushl  0x10(%ebp)
  8007bf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c2:	50                   	push   %eax
  8007c3:	68 f4 02 80 00       	push   $0x8002f4
  8007c8:	e8 61 fb ff ff       	call   80032e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d6:	83 c4 10             	add    $0x10,%esp
  8007d9:	eb 05                	jmp    8007e0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007e0:	c9                   	leave  
  8007e1:	c3                   	ret    

008007e2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007e8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007eb:	50                   	push   %eax
  8007ec:	ff 75 10             	pushl  0x10(%ebp)
  8007ef:	ff 75 0c             	pushl  0xc(%ebp)
  8007f2:	ff 75 08             	pushl  0x8(%ebp)
  8007f5:	e8 9a ff ff ff       	call   800794 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fa:	c9                   	leave  
  8007fb:	c3                   	ret    

008007fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800802:	b8 00 00 00 00       	mov    $0x0,%eax
  800807:	eb 03                	jmp    80080c <strlen+0x10>
		n++;
  800809:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80080c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800810:	75 f7                	jne    800809 <strlen+0xd>
		n++;
	return n;
}
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081d:	ba 00 00 00 00       	mov    $0x0,%edx
  800822:	eb 03                	jmp    800827 <strnlen+0x13>
		n++;
  800824:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800827:	39 c2                	cmp    %eax,%edx
  800829:	74 08                	je     800833 <strnlen+0x1f>
  80082b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80082f:	75 f3                	jne    800824 <strnlen+0x10>
  800831:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	53                   	push   %ebx
  800839:	8b 45 08             	mov    0x8(%ebp),%eax
  80083c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80083f:	89 c2                	mov    %eax,%edx
  800841:	83 c2 01             	add    $0x1,%edx
  800844:	83 c1 01             	add    $0x1,%ecx
  800847:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80084b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80084e:	84 db                	test   %bl,%bl
  800850:	75 ef                	jne    800841 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800852:	5b                   	pop    %ebx
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	53                   	push   %ebx
  800859:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085c:	53                   	push   %ebx
  80085d:	e8 9a ff ff ff       	call   8007fc <strlen>
  800862:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800865:	ff 75 0c             	pushl  0xc(%ebp)
  800868:	01 d8                	add    %ebx,%eax
  80086a:	50                   	push   %eax
  80086b:	e8 c5 ff ff ff       	call   800835 <strcpy>
	return dst;
}
  800870:	89 d8                	mov    %ebx,%eax
  800872:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800875:	c9                   	leave  
  800876:	c3                   	ret    

00800877 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	56                   	push   %esi
  80087b:	53                   	push   %ebx
  80087c:	8b 75 08             	mov    0x8(%ebp),%esi
  80087f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800882:	89 f3                	mov    %esi,%ebx
  800884:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800887:	89 f2                	mov    %esi,%edx
  800889:	eb 0f                	jmp    80089a <strncpy+0x23>
		*dst++ = *src;
  80088b:	83 c2 01             	add    $0x1,%edx
  80088e:	0f b6 01             	movzbl (%ecx),%eax
  800891:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800894:	80 39 01             	cmpb   $0x1,(%ecx)
  800897:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089a:	39 da                	cmp    %ebx,%edx
  80089c:	75 ed                	jne    80088b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80089e:	89 f0                	mov    %esi,%eax
  8008a0:	5b                   	pop    %ebx
  8008a1:	5e                   	pop    %esi
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	56                   	push   %esi
  8008a8:	53                   	push   %ebx
  8008a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008af:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b4:	85 d2                	test   %edx,%edx
  8008b6:	74 21                	je     8008d9 <strlcpy+0x35>
  8008b8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008bc:	89 f2                	mov    %esi,%edx
  8008be:	eb 09                	jmp    8008c9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c0:	83 c2 01             	add    $0x1,%edx
  8008c3:	83 c1 01             	add    $0x1,%ecx
  8008c6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008c9:	39 c2                	cmp    %eax,%edx
  8008cb:	74 09                	je     8008d6 <strlcpy+0x32>
  8008cd:	0f b6 19             	movzbl (%ecx),%ebx
  8008d0:	84 db                	test   %bl,%bl
  8008d2:	75 ec                	jne    8008c0 <strlcpy+0x1c>
  8008d4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008d6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008d9:	29 f0                	sub    %esi,%eax
}
  8008db:	5b                   	pop    %ebx
  8008dc:	5e                   	pop    %esi
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e8:	eb 06                	jmp    8008f0 <strcmp+0x11>
		p++, q++;
  8008ea:	83 c1 01             	add    $0x1,%ecx
  8008ed:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008f0:	0f b6 01             	movzbl (%ecx),%eax
  8008f3:	84 c0                	test   %al,%al
  8008f5:	74 04                	je     8008fb <strcmp+0x1c>
  8008f7:	3a 02                	cmp    (%edx),%al
  8008f9:	74 ef                	je     8008ea <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fb:	0f b6 c0             	movzbl %al,%eax
  8008fe:	0f b6 12             	movzbl (%edx),%edx
  800901:	29 d0                	sub    %edx,%eax
}
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	53                   	push   %ebx
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090f:	89 c3                	mov    %eax,%ebx
  800911:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800914:	eb 06                	jmp    80091c <strncmp+0x17>
		n--, p++, q++;
  800916:	83 c0 01             	add    $0x1,%eax
  800919:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80091c:	39 d8                	cmp    %ebx,%eax
  80091e:	74 15                	je     800935 <strncmp+0x30>
  800920:	0f b6 08             	movzbl (%eax),%ecx
  800923:	84 c9                	test   %cl,%cl
  800925:	74 04                	je     80092b <strncmp+0x26>
  800927:	3a 0a                	cmp    (%edx),%cl
  800929:	74 eb                	je     800916 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092b:	0f b6 00             	movzbl (%eax),%eax
  80092e:	0f b6 12             	movzbl (%edx),%edx
  800931:	29 d0                	sub    %edx,%eax
  800933:	eb 05                	jmp    80093a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80093a:	5b                   	pop    %ebx
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800947:	eb 07                	jmp    800950 <strchr+0x13>
		if (*s == c)
  800949:	38 ca                	cmp    %cl,%dl
  80094b:	74 0f                	je     80095c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80094d:	83 c0 01             	add    $0x1,%eax
  800950:	0f b6 10             	movzbl (%eax),%edx
  800953:	84 d2                	test   %dl,%dl
  800955:	75 f2                	jne    800949 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800957:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800968:	eb 03                	jmp    80096d <strfind+0xf>
  80096a:	83 c0 01             	add    $0x1,%eax
  80096d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800970:	38 ca                	cmp    %cl,%dl
  800972:	74 04                	je     800978 <strfind+0x1a>
  800974:	84 d2                	test   %dl,%dl
  800976:	75 f2                	jne    80096a <strfind+0xc>
			break;
	return (char *) s;
}
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	57                   	push   %edi
  80097e:	56                   	push   %esi
  80097f:	53                   	push   %ebx
  800980:	8b 7d 08             	mov    0x8(%ebp),%edi
  800983:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800986:	85 c9                	test   %ecx,%ecx
  800988:	74 36                	je     8009c0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800990:	75 28                	jne    8009ba <memset+0x40>
  800992:	f6 c1 03             	test   $0x3,%cl
  800995:	75 23                	jne    8009ba <memset+0x40>
		c &= 0xFF;
  800997:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80099b:	89 d3                	mov    %edx,%ebx
  80099d:	c1 e3 08             	shl    $0x8,%ebx
  8009a0:	89 d6                	mov    %edx,%esi
  8009a2:	c1 e6 18             	shl    $0x18,%esi
  8009a5:	89 d0                	mov    %edx,%eax
  8009a7:	c1 e0 10             	shl    $0x10,%eax
  8009aa:	09 f0                	or     %esi,%eax
  8009ac:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009ae:	89 d8                	mov    %ebx,%eax
  8009b0:	09 d0                	or     %edx,%eax
  8009b2:	c1 e9 02             	shr    $0x2,%ecx
  8009b5:	fc                   	cld    
  8009b6:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b8:	eb 06                	jmp    8009c0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bd:	fc                   	cld    
  8009be:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c0:	89 f8                	mov    %edi,%eax
  8009c2:	5b                   	pop    %ebx
  8009c3:	5e                   	pop    %esi
  8009c4:	5f                   	pop    %edi
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	57                   	push   %edi
  8009cb:	56                   	push   %esi
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d5:	39 c6                	cmp    %eax,%esi
  8009d7:	73 35                	jae    800a0e <memmove+0x47>
  8009d9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009dc:	39 d0                	cmp    %edx,%eax
  8009de:	73 2e                	jae    800a0e <memmove+0x47>
		s += n;
		d += n;
  8009e0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e3:	89 d6                	mov    %edx,%esi
  8009e5:	09 fe                	or     %edi,%esi
  8009e7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ed:	75 13                	jne    800a02 <memmove+0x3b>
  8009ef:	f6 c1 03             	test   $0x3,%cl
  8009f2:	75 0e                	jne    800a02 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009f4:	83 ef 04             	sub    $0x4,%edi
  8009f7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009fa:	c1 e9 02             	shr    $0x2,%ecx
  8009fd:	fd                   	std    
  8009fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a00:	eb 09                	jmp    800a0b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a02:	83 ef 01             	sub    $0x1,%edi
  800a05:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a08:	fd                   	std    
  800a09:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a0b:	fc                   	cld    
  800a0c:	eb 1d                	jmp    800a2b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0e:	89 f2                	mov    %esi,%edx
  800a10:	09 c2                	or     %eax,%edx
  800a12:	f6 c2 03             	test   $0x3,%dl
  800a15:	75 0f                	jne    800a26 <memmove+0x5f>
  800a17:	f6 c1 03             	test   $0x3,%cl
  800a1a:	75 0a                	jne    800a26 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a1c:	c1 e9 02             	shr    $0x2,%ecx
  800a1f:	89 c7                	mov    %eax,%edi
  800a21:	fc                   	cld    
  800a22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a24:	eb 05                	jmp    800a2b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a26:	89 c7                	mov    %eax,%edi
  800a28:	fc                   	cld    
  800a29:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a2b:	5e                   	pop    %esi
  800a2c:	5f                   	pop    %edi
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a32:	ff 75 10             	pushl  0x10(%ebp)
  800a35:	ff 75 0c             	pushl  0xc(%ebp)
  800a38:	ff 75 08             	pushl  0x8(%ebp)
  800a3b:	e8 87 ff ff ff       	call   8009c7 <memmove>
}
  800a40:	c9                   	leave  
  800a41:	c3                   	ret    

00800a42 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	56                   	push   %esi
  800a46:	53                   	push   %ebx
  800a47:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4d:	89 c6                	mov    %eax,%esi
  800a4f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a52:	eb 1a                	jmp    800a6e <memcmp+0x2c>
		if (*s1 != *s2)
  800a54:	0f b6 08             	movzbl (%eax),%ecx
  800a57:	0f b6 1a             	movzbl (%edx),%ebx
  800a5a:	38 d9                	cmp    %bl,%cl
  800a5c:	74 0a                	je     800a68 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a5e:	0f b6 c1             	movzbl %cl,%eax
  800a61:	0f b6 db             	movzbl %bl,%ebx
  800a64:	29 d8                	sub    %ebx,%eax
  800a66:	eb 0f                	jmp    800a77 <memcmp+0x35>
		s1++, s2++;
  800a68:	83 c0 01             	add    $0x1,%eax
  800a6b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6e:	39 f0                	cmp    %esi,%eax
  800a70:	75 e2                	jne    800a54 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	53                   	push   %ebx
  800a7f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a82:	89 c1                	mov    %eax,%ecx
  800a84:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a87:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a8b:	eb 0a                	jmp    800a97 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8d:	0f b6 10             	movzbl (%eax),%edx
  800a90:	39 da                	cmp    %ebx,%edx
  800a92:	74 07                	je     800a9b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a94:	83 c0 01             	add    $0x1,%eax
  800a97:	39 c8                	cmp    %ecx,%eax
  800a99:	72 f2                	jb     800a8d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a9b:	5b                   	pop    %ebx
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	57                   	push   %edi
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aaa:	eb 03                	jmp    800aaf <strtol+0x11>
		s++;
  800aac:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aaf:	0f b6 01             	movzbl (%ecx),%eax
  800ab2:	3c 20                	cmp    $0x20,%al
  800ab4:	74 f6                	je     800aac <strtol+0xe>
  800ab6:	3c 09                	cmp    $0x9,%al
  800ab8:	74 f2                	je     800aac <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aba:	3c 2b                	cmp    $0x2b,%al
  800abc:	75 0a                	jne    800ac8 <strtol+0x2a>
		s++;
  800abe:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac1:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac6:	eb 11                	jmp    800ad9 <strtol+0x3b>
  800ac8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800acd:	3c 2d                	cmp    $0x2d,%al
  800acf:	75 08                	jne    800ad9 <strtol+0x3b>
		s++, neg = 1;
  800ad1:	83 c1 01             	add    $0x1,%ecx
  800ad4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800adf:	75 15                	jne    800af6 <strtol+0x58>
  800ae1:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae4:	75 10                	jne    800af6 <strtol+0x58>
  800ae6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aea:	75 7c                	jne    800b68 <strtol+0xca>
		s += 2, base = 16;
  800aec:	83 c1 02             	add    $0x2,%ecx
  800aef:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af4:	eb 16                	jmp    800b0c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800af6:	85 db                	test   %ebx,%ebx
  800af8:	75 12                	jne    800b0c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800afa:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aff:	80 39 30             	cmpb   $0x30,(%ecx)
  800b02:	75 08                	jne    800b0c <strtol+0x6e>
		s++, base = 8;
  800b04:	83 c1 01             	add    $0x1,%ecx
  800b07:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b11:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b14:	0f b6 11             	movzbl (%ecx),%edx
  800b17:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b1a:	89 f3                	mov    %esi,%ebx
  800b1c:	80 fb 09             	cmp    $0x9,%bl
  800b1f:	77 08                	ja     800b29 <strtol+0x8b>
			dig = *s - '0';
  800b21:	0f be d2             	movsbl %dl,%edx
  800b24:	83 ea 30             	sub    $0x30,%edx
  800b27:	eb 22                	jmp    800b4b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b29:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b2c:	89 f3                	mov    %esi,%ebx
  800b2e:	80 fb 19             	cmp    $0x19,%bl
  800b31:	77 08                	ja     800b3b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b33:	0f be d2             	movsbl %dl,%edx
  800b36:	83 ea 57             	sub    $0x57,%edx
  800b39:	eb 10                	jmp    800b4b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b3b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b3e:	89 f3                	mov    %esi,%ebx
  800b40:	80 fb 19             	cmp    $0x19,%bl
  800b43:	77 16                	ja     800b5b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b45:	0f be d2             	movsbl %dl,%edx
  800b48:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b4b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b4e:	7d 0b                	jge    800b5b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b50:	83 c1 01             	add    $0x1,%ecx
  800b53:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b57:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b59:	eb b9                	jmp    800b14 <strtol+0x76>

	if (endptr)
  800b5b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b5f:	74 0d                	je     800b6e <strtol+0xd0>
		*endptr = (char *) s;
  800b61:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b64:	89 0e                	mov    %ecx,(%esi)
  800b66:	eb 06                	jmp    800b6e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b68:	85 db                	test   %ebx,%ebx
  800b6a:	74 98                	je     800b04 <strtol+0x66>
  800b6c:	eb 9e                	jmp    800b0c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b6e:	89 c2                	mov    %eax,%edx
  800b70:	f7 da                	neg    %edx
  800b72:	85 ff                	test   %edi,%edi
  800b74:	0f 45 c2             	cmovne %edx,%eax
}
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	b8 00 00 00 00       	mov    $0x0,%eax
  800b87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8d:	89 c3                	mov    %eax,%ebx
  800b8f:	89 c7                	mov    %eax,%edi
  800b91:	89 c6                	mov    %eax,%esi
  800b93:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba5:	b8 01 00 00 00       	mov    $0x1,%eax
  800baa:	89 d1                	mov    %edx,%ecx
  800bac:	89 d3                	mov    %edx,%ebx
  800bae:	89 d7                	mov    %edx,%edi
  800bb0:	89 d6                	mov    %edx,%esi
  800bb2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	53                   	push   %ebx
  800bbf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc7:	b8 03 00 00 00       	mov    $0x3,%eax
  800bcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcf:	89 cb                	mov    %ecx,%ebx
  800bd1:	89 cf                	mov    %ecx,%edi
  800bd3:	89 ce                	mov    %ecx,%esi
  800bd5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd7:	85 c0                	test   %eax,%eax
  800bd9:	7e 17                	jle    800bf2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdb:	83 ec 0c             	sub    $0xc,%esp
  800bde:	50                   	push   %eax
  800bdf:	6a 03                	push   $0x3
  800be1:	68 5f 25 80 00       	push   $0x80255f
  800be6:	6a 23                	push   $0x23
  800be8:	68 7c 25 80 00       	push   $0x80257c
  800bed:	e8 66 f5 ff ff       	call   800158 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c00:	ba 00 00 00 00       	mov    $0x0,%edx
  800c05:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0a:	89 d1                	mov    %edx,%ecx
  800c0c:	89 d3                	mov    %edx,%ebx
  800c0e:	89 d7                	mov    %edx,%edi
  800c10:	89 d6                	mov    %edx,%esi
  800c12:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <sys_yield>:

void
sys_yield(void)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c24:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c29:	89 d1                	mov    %edx,%ecx
  800c2b:	89 d3                	mov    %edx,%ebx
  800c2d:	89 d7                	mov    %edx,%edi
  800c2f:	89 d6                	mov    %edx,%esi
  800c31:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	57                   	push   %edi
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
  800c3e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	be 00 00 00 00       	mov    $0x0,%esi
  800c46:	b8 04 00 00 00       	mov    $0x4,%eax
  800c4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c54:	89 f7                	mov    %esi,%edi
  800c56:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c58:	85 c0                	test   %eax,%eax
  800c5a:	7e 17                	jle    800c73 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5c:	83 ec 0c             	sub    $0xc,%esp
  800c5f:	50                   	push   %eax
  800c60:	6a 04                	push   $0x4
  800c62:	68 5f 25 80 00       	push   $0x80255f
  800c67:	6a 23                	push   $0x23
  800c69:	68 7c 25 80 00       	push   $0x80257c
  800c6e:	e8 e5 f4 ff ff       	call   800158 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
  800c81:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c84:	b8 05 00 00 00       	mov    $0x5,%eax
  800c89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c92:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c95:	8b 75 18             	mov    0x18(%ebp),%esi
  800c98:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	7e 17                	jle    800cb5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9e:	83 ec 0c             	sub    $0xc,%esp
  800ca1:	50                   	push   %eax
  800ca2:	6a 05                	push   $0x5
  800ca4:	68 5f 25 80 00       	push   $0x80255f
  800ca9:	6a 23                	push   $0x23
  800cab:	68 7c 25 80 00       	push   $0x80257c
  800cb0:	e8 a3 f4 ff ff       	call   800158 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
  800cc3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccb:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd6:	89 df                	mov    %ebx,%edi
  800cd8:	89 de                	mov    %ebx,%esi
  800cda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdc:	85 c0                	test   %eax,%eax
  800cde:	7e 17                	jle    800cf7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce0:	83 ec 0c             	sub    $0xc,%esp
  800ce3:	50                   	push   %eax
  800ce4:	6a 06                	push   $0x6
  800ce6:	68 5f 25 80 00       	push   $0x80255f
  800ceb:	6a 23                	push   $0x23
  800ced:	68 7c 25 80 00       	push   $0x80257c
  800cf2:	e8 61 f4 ff ff       	call   800158 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfa:	5b                   	pop    %ebx
  800cfb:	5e                   	pop    %esi
  800cfc:	5f                   	pop    %edi
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	57                   	push   %edi
  800d03:	56                   	push   %esi
  800d04:	53                   	push   %ebx
  800d05:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d15:	8b 55 08             	mov    0x8(%ebp),%edx
  800d18:	89 df                	mov    %ebx,%edi
  800d1a:	89 de                	mov    %ebx,%esi
  800d1c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1e:	85 c0                	test   %eax,%eax
  800d20:	7e 17                	jle    800d39 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d22:	83 ec 0c             	sub    $0xc,%esp
  800d25:	50                   	push   %eax
  800d26:	6a 08                	push   $0x8
  800d28:	68 5f 25 80 00       	push   $0x80255f
  800d2d:	6a 23                	push   $0x23
  800d2f:	68 7c 25 80 00       	push   $0x80257c
  800d34:	e8 1f f4 ff ff       	call   800158 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	57                   	push   %edi
  800d45:	56                   	push   %esi
  800d46:	53                   	push   %ebx
  800d47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4f:	b8 09 00 00 00       	mov    $0x9,%eax
  800d54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d57:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5a:	89 df                	mov    %ebx,%edi
  800d5c:	89 de                	mov    %ebx,%esi
  800d5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d60:	85 c0                	test   %eax,%eax
  800d62:	7e 17                	jle    800d7b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d64:	83 ec 0c             	sub    $0xc,%esp
  800d67:	50                   	push   %eax
  800d68:	6a 09                	push   $0x9
  800d6a:	68 5f 25 80 00       	push   $0x80255f
  800d6f:	6a 23                	push   $0x23
  800d71:	68 7c 25 80 00       	push   $0x80257c
  800d76:	e8 dd f3 ff ff       	call   800158 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	57                   	push   %edi
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
  800d89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d91:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	89 df                	mov    %ebx,%edi
  800d9e:	89 de                	mov    %ebx,%esi
  800da0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da2:	85 c0                	test   %eax,%eax
  800da4:	7e 17                	jle    800dbd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da6:	83 ec 0c             	sub    $0xc,%esp
  800da9:	50                   	push   %eax
  800daa:	6a 0a                	push   $0xa
  800dac:	68 5f 25 80 00       	push   $0x80255f
  800db1:	6a 23                	push   $0x23
  800db3:	68 7c 25 80 00       	push   $0x80257c
  800db8:	e8 9b f3 ff ff       	call   800158 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	57                   	push   %edi
  800dc9:	56                   	push   %esi
  800dca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcb:	be 00 00 00 00       	mov    $0x0,%esi
  800dd0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dde:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	57                   	push   %edi
  800dec:	56                   	push   %esi
  800ded:	53                   	push   %ebx
  800dee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfe:	89 cb                	mov    %ecx,%ebx
  800e00:	89 cf                	mov    %ecx,%edi
  800e02:	89 ce                	mov    %ecx,%esi
  800e04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e06:	85 c0                	test   %eax,%eax
  800e08:	7e 17                	jle    800e21 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0a:	83 ec 0c             	sub    $0xc,%esp
  800e0d:	50                   	push   %eax
  800e0e:	6a 0d                	push   $0xd
  800e10:	68 5f 25 80 00       	push   $0x80255f
  800e15:	6a 23                	push   $0x23
  800e17:	68 7c 25 80 00       	push   $0x80257c
  800e1c:	e8 37 f3 ff ff       	call   800158 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	53                   	push   %ebx
  800e2d:	83 ec 04             	sub    $0x4,%esp
  800e30:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e33:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800e35:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e39:	74 2d                	je     800e68 <pgfault+0x3f>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800e3b:	89 d8                	mov    %ebx,%eax
  800e3d:	c1 e8 16             	shr    $0x16,%eax
  800e40:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e47:	a8 01                	test   $0x1,%al
  800e49:	74 1d                	je     800e68 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e4b:	89 d8                	mov    %ebx,%eax
  800e4d:	c1 e8 0c             	shr    $0xc,%eax
  800e50:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800e57:	f6 c2 01             	test   $0x1,%dl
  800e5a:	74 0c                	je     800e68 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e5c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800e63:	f6 c4 08             	test   $0x8,%ah
  800e66:	75 14                	jne    800e7c <pgfault+0x53>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
	)) panic("Neither the fault is a write nor copy-on-write page.\n");
  800e68:	83 ec 04             	sub    $0x4,%esp
  800e6b:	68 8c 25 80 00       	push   $0x80258c
  800e70:	6a 1f                	push   $0x1f
  800e72:	68 c2 25 80 00       	push   $0x8025c2
  800e77:	e8 dc f2 ff ff       	call   800158 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if((r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W)) < 0){
  800e7c:	83 ec 04             	sub    $0x4,%esp
  800e7f:	6a 07                	push   $0x7
  800e81:	68 00 f0 7f 00       	push   $0x7ff000
  800e86:	6a 00                	push   $0x0
  800e88:	e8 ab fd ff ff       	call   800c38 <sys_page_alloc>
  800e8d:	83 c4 10             	add    $0x10,%esp
  800e90:	85 c0                	test   %eax,%eax
  800e92:	79 12                	jns    800ea6 <pgfault+0x7d>
		 panic("sys_page_alloc: %e\n", r);
  800e94:	50                   	push   %eax
  800e95:	68 cd 25 80 00       	push   $0x8025cd
  800e9a:	6a 29                	push   $0x29
  800e9c:	68 c2 25 80 00       	push   $0x8025c2
  800ea1:	e8 b2 f2 ff ff       	call   800158 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800ea6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800eac:	83 ec 04             	sub    $0x4,%esp
  800eaf:	68 00 10 00 00       	push   $0x1000
  800eb4:	53                   	push   %ebx
  800eb5:	68 00 f0 7f 00       	push   $0x7ff000
  800eba:	e8 70 fb ff ff       	call   800a2f <memcpy>
	if ((r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  800ebf:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ec6:	53                   	push   %ebx
  800ec7:	6a 00                	push   $0x0
  800ec9:	68 00 f0 7f 00       	push   $0x7ff000
  800ece:	6a 00                	push   $0x0
  800ed0:	e8 a6 fd ff ff       	call   800c7b <sys_page_map>
  800ed5:	83 c4 20             	add    $0x20,%esp
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	79 12                	jns    800eee <pgfault+0xc5>
        panic("sys_page_map: %e\n", r);
  800edc:	50                   	push   %eax
  800edd:	68 e1 25 80 00       	push   $0x8025e1
  800ee2:	6a 2e                	push   $0x2e
  800ee4:	68 c2 25 80 00       	push   $0x8025c2
  800ee9:	e8 6a f2 ff ff       	call   800158 <_panic>
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  800eee:	83 ec 08             	sub    $0x8,%esp
  800ef1:	68 00 f0 7f 00       	push   $0x7ff000
  800ef6:	6a 00                	push   $0x0
  800ef8:	e8 c0 fd ff ff       	call   800cbd <sys_page_unmap>
  800efd:	83 c4 10             	add    $0x10,%esp
  800f00:	85 c0                	test   %eax,%eax
  800f02:	79 12                	jns    800f16 <pgfault+0xed>
        panic("sys_page_unmap: %e\n", r);
  800f04:	50                   	push   %eax
  800f05:	68 f3 25 80 00       	push   $0x8025f3
  800f0a:	6a 30                	push   $0x30
  800f0c:	68 c2 25 80 00       	push   $0x8025c2
  800f11:	e8 42 f2 ff ff       	call   800158 <_panic>
	//panic("pgfault not implemented");
}
  800f16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f19:	c9                   	leave  
  800f1a:	c3                   	ret    

00800f1b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	57                   	push   %edi
  800f1f:	56                   	push   %esi
  800f20:	53                   	push   %ebx
  800f21:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	envid_t cenvid;
    unsigned pn;
    int r;
	set_pgfault_handler(pgfault);
  800f24:	68 29 0e 80 00       	push   $0x800e29
  800f29:	e8 7a 0f 00 00       	call   801ea8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f2e:	b8 07 00 00 00       	mov    $0x7,%eax
  800f33:	cd 30                	int    $0x30
  800f35:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((cenvid = sys_exofork()) < 0){
  800f38:	83 c4 10             	add    $0x10,%esp
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	79 14                	jns    800f53 <fork+0x38>
		panic("sys_exofork failed");
  800f3f:	83 ec 04             	sub    $0x4,%esp
  800f42:	68 07 26 80 00       	push   $0x802607
  800f47:	6a 6f                	push   $0x6f
  800f49:	68 c2 25 80 00       	push   $0x8025c2
  800f4e:	e8 05 f2 ff ff       	call   800158 <_panic>
  800f53:	89 c7                	mov    %eax,%edi
		return cenvid;
	}
	if(cenvid>0){
  800f55:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f59:	0f 8e 2b 01 00 00    	jle    80108a <fork+0x16f>
  800f5f:	bb 00 08 00 00       	mov    $0x800,%ebx
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
  800f64:	89 d8                	mov    %ebx,%eax
  800f66:	c1 e8 0a             	shr    $0xa,%eax
  800f69:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f70:	a8 01                	test   $0x1,%al
  800f72:	0f 84 bf 00 00 00    	je     801037 <fork+0x11c>
  800f78:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f7f:	a8 01                	test   $0x1,%al
  800f81:	0f 84 b0 00 00 00    	je     801037 <fork+0x11c>
  800f87:	89 de                	mov    %ebx,%esi
  800f89:	c1 e6 0c             	shl    $0xc,%esi
{
	int r;

	// LAB 4: Your code here.
	void* vaddr=(void*)(pn*PGSIZE);
	if(uvpt[pn]&PTE_SHARE){
  800f8c:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f93:	f6 c4 04             	test   $0x4,%ah
  800f96:	74 29                	je     800fc1 <fork+0xa6>
		if((r=sys_page_map(0,vaddr,envid,vaddr,uvpt[pn]&PTE_SYSCALL))<0)return r;
  800f98:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f9f:	83 ec 0c             	sub    $0xc,%esp
  800fa2:	25 07 0e 00 00       	and    $0xe07,%eax
  800fa7:	50                   	push   %eax
  800fa8:	56                   	push   %esi
  800fa9:	57                   	push   %edi
  800faa:	56                   	push   %esi
  800fab:	6a 00                	push   $0x0
  800fad:	e8 c9 fc ff ff       	call   800c7b <sys_page_map>
  800fb2:	83 c4 20             	add    $0x20,%esp
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	ba 00 00 00 00       	mov    $0x0,%edx
  800fbc:	0f 4f c2             	cmovg  %edx,%eax
  800fbf:	eb 72                	jmp    801033 <fork+0x118>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  800fc1:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fc8:	a8 02                	test   $0x2,%al
  800fca:	75 0c                	jne    800fd8 <fork+0xbd>
  800fcc:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fd3:	f6 c4 08             	test   $0x8,%ah
  800fd6:	74 3f                	je     801017 <fork+0xfc>
		if ((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  800fd8:	83 ec 0c             	sub    $0xc,%esp
  800fdb:	68 05 08 00 00       	push   $0x805
  800fe0:	56                   	push   %esi
  800fe1:	57                   	push   %edi
  800fe2:	56                   	push   %esi
  800fe3:	6a 00                	push   $0x0
  800fe5:	e8 91 fc ff ff       	call   800c7b <sys_page_map>
  800fea:	83 c4 20             	add    $0x20,%esp
  800fed:	85 c0                	test   %eax,%eax
  800fef:	0f 88 b1 00 00 00    	js     8010a6 <fork+0x18b>
            return r;
        if ((r = sys_page_map(0, vaddr, 0, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  800ff5:	83 ec 0c             	sub    $0xc,%esp
  800ff8:	68 05 08 00 00       	push   $0x805
  800ffd:	56                   	push   %esi
  800ffe:	6a 00                	push   $0x0
  801000:	56                   	push   %esi
  801001:	6a 00                	push   $0x0
  801003:	e8 73 fc ff ff       	call   800c7b <sys_page_map>
  801008:	83 c4 20             	add    $0x20,%esp
  80100b:	85 c0                	test   %eax,%eax
  80100d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801012:	0f 4f c1             	cmovg  %ecx,%eax
  801015:	eb 1c                	jmp    801033 <fork+0x118>
            return r;
	}
	else if((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U)) < 0) {
  801017:	83 ec 0c             	sub    $0xc,%esp
  80101a:	6a 05                	push   $0x5
  80101c:	56                   	push   %esi
  80101d:	57                   	push   %edi
  80101e:	56                   	push   %esi
  80101f:	6a 00                	push   $0x0
  801021:	e8 55 fc ff ff       	call   800c7b <sys_page_map>
  801026:	83 c4 20             	add    $0x20,%esp
  801029:	85 c0                	test   %eax,%eax
  80102b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801030:	0f 4f c1             	cmovg  %ecx,%eax
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
  801033:	85 c0                	test   %eax,%eax
  801035:	78 6f                	js     8010a6 <fork+0x18b>
	if ((cenvid = sys_exofork()) < 0){
		panic("sys_exofork failed");
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  801037:	83 c3 01             	add    $0x1,%ebx
  80103a:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801040:	0f 85 1e ff ff ff    	jne    800f64 <fork+0x49>
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
                    return r;
		}
		if ((r = sys_page_alloc(cenvid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  801046:	83 ec 04             	sub    $0x4,%esp
  801049:	6a 07                	push   $0x7
  80104b:	68 00 f0 bf ee       	push   $0xeebff000
  801050:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801053:	57                   	push   %edi
  801054:	e8 df fb ff ff       	call   800c38 <sys_page_alloc>
  801059:	83 c4 10             	add    $0x10,%esp
  80105c:	85 c0                	test   %eax,%eax
  80105e:	78 46                	js     8010a6 <fork+0x18b>
            return r;
		extern void _pgfault_upcall(void);
		if ((r = sys_env_set_pgfault_upcall(cenvid, _pgfault_upcall)) < 0)
  801060:	83 ec 08             	sub    $0x8,%esp
  801063:	68 0b 1f 80 00       	push   $0x801f0b
  801068:	57                   	push   %edi
  801069:	e8 15 fd ff ff       	call   800d83 <sys_env_set_pgfault_upcall>
  80106e:	83 c4 10             	add    $0x10,%esp
  801071:	85 c0                	test   %eax,%eax
  801073:	78 31                	js     8010a6 <fork+0x18b>
            return r;
		if ((r = sys_env_set_status(cenvid, ENV_RUNNABLE)) < 0)
  801075:	83 ec 08             	sub    $0x8,%esp
  801078:	6a 02                	push   $0x2
  80107a:	57                   	push   %edi
  80107b:	e8 7f fc ff ff       	call   800cff <sys_env_set_status>
  801080:	83 c4 10             	add    $0x10,%esp
            return r;
        return cenvid;
  801083:	85 c0                	test   %eax,%eax
  801085:	0f 49 c7             	cmovns %edi,%eax
  801088:	eb 1c                	jmp    8010a6 <fork+0x18b>
	}
	else {
		thisenv = &envs[ENVX(sys_getenvid())];
  80108a:	e8 6b fb ff ff       	call   800bfa <sys_getenvid>
  80108f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801094:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801097:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80109c:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8010a1:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//panic("fork not implemented");
	
}
  8010a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a9:	5b                   	pop    %ebx
  8010aa:	5e                   	pop    %esi
  8010ab:	5f                   	pop    %edi
  8010ac:	5d                   	pop    %ebp
  8010ad:	c3                   	ret    

008010ae <sfork>:

// Challenge!
int
sfork(void)
{
  8010ae:	55                   	push   %ebp
  8010af:	89 e5                	mov    %esp,%ebp
  8010b1:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010b4:	68 1a 26 80 00       	push   $0x80261a
  8010b9:	68 8d 00 00 00       	push   $0x8d
  8010be:	68 c2 25 80 00       	push   $0x8025c2
  8010c3:	e8 90 f0 ff ff       	call   800158 <_panic>

008010c8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	56                   	push   %esi
  8010cc:	53                   	push   %ebx
  8010cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8010d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  8010d6:	85 c0                	test   %eax,%eax
  8010d8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8010dd:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  8010e0:	83 ec 0c             	sub    $0xc,%esp
  8010e3:	50                   	push   %eax
  8010e4:	e8 ff fc ff ff       	call   800de8 <sys_ipc_recv>
  8010e9:	83 c4 10             	add    $0x10,%esp
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	79 16                	jns    801106 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  8010f0:	85 f6                	test   %esi,%esi
  8010f2:	74 06                	je     8010fa <ipc_recv+0x32>
            *from_env_store = 0;
  8010f4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  8010fa:	85 db                	test   %ebx,%ebx
  8010fc:	74 2c                	je     80112a <ipc_recv+0x62>
            *perm_store = 0;
  8010fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801104:	eb 24                	jmp    80112a <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801106:	85 f6                	test   %esi,%esi
  801108:	74 0a                	je     801114 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  80110a:	a1 04 40 80 00       	mov    0x804004,%eax
  80110f:	8b 40 74             	mov    0x74(%eax),%eax
  801112:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801114:	85 db                	test   %ebx,%ebx
  801116:	74 0a                	je     801122 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801118:	a1 04 40 80 00       	mov    0x804004,%eax
  80111d:	8b 40 78             	mov    0x78(%eax),%eax
  801120:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801122:	a1 04 40 80 00       	mov    0x804004,%eax
  801127:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  80112a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80112d:	5b                   	pop    %ebx
  80112e:	5e                   	pop    %esi
  80112f:	5d                   	pop    %ebp
  801130:	c3                   	ret    

00801131 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	57                   	push   %edi
  801135:	56                   	push   %esi
  801136:	53                   	push   %ebx
  801137:	83 ec 0c             	sub    $0xc,%esp
  80113a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80113d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801140:	8b 45 10             	mov    0x10(%ebp),%eax
  801143:	85 c0                	test   %eax,%eax
  801145:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80114a:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80114d:	eb 1c                	jmp    80116b <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  80114f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801152:	74 12                	je     801166 <ipc_send+0x35>
  801154:	50                   	push   %eax
  801155:	68 30 26 80 00       	push   $0x802630
  80115a:	6a 3a                	push   $0x3a
  80115c:	68 46 26 80 00       	push   $0x802646
  801161:	e8 f2 ef ff ff       	call   800158 <_panic>
		sys_yield();
  801166:	e8 ae fa ff ff       	call   800c19 <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80116b:	ff 75 14             	pushl  0x14(%ebp)
  80116e:	53                   	push   %ebx
  80116f:	56                   	push   %esi
  801170:	57                   	push   %edi
  801171:	e8 4f fc ff ff       	call   800dc5 <sys_ipc_try_send>
  801176:	83 c4 10             	add    $0x10,%esp
  801179:	85 c0                	test   %eax,%eax
  80117b:	78 d2                	js     80114f <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  80117d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801180:	5b                   	pop    %ebx
  801181:	5e                   	pop    %esi
  801182:	5f                   	pop    %edi
  801183:	5d                   	pop    %ebp
  801184:	c3                   	ret    

00801185 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
  801188:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80118b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801190:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801193:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801199:	8b 52 50             	mov    0x50(%edx),%edx
  80119c:	39 ca                	cmp    %ecx,%edx
  80119e:	75 0d                	jne    8011ad <ipc_find_env+0x28>
			return envs[i].env_id;
  8011a0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011a3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011a8:	8b 40 48             	mov    0x48(%eax),%eax
  8011ab:	eb 0f                	jmp    8011bc <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011ad:	83 c0 01             	add    $0x1,%eax
  8011b0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011b5:	75 d9                	jne    801190 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011bc:	5d                   	pop    %ebp
  8011bd:	c3                   	ret    

008011be <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c4:	05 00 00 00 30       	add    $0x30000000,%eax
  8011c9:	c1 e8 0c             	shr    $0xc,%eax
}
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    

008011ce <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d4:	05 00 00 00 30       	add    $0x30000000,%eax
  8011d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011de:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011eb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011f0:	89 c2                	mov    %eax,%edx
  8011f2:	c1 ea 16             	shr    $0x16,%edx
  8011f5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011fc:	f6 c2 01             	test   $0x1,%dl
  8011ff:	74 11                	je     801212 <fd_alloc+0x2d>
  801201:	89 c2                	mov    %eax,%edx
  801203:	c1 ea 0c             	shr    $0xc,%edx
  801206:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80120d:	f6 c2 01             	test   $0x1,%dl
  801210:	75 09                	jne    80121b <fd_alloc+0x36>
			*fd_store = fd;
  801212:	89 01                	mov    %eax,(%ecx)
			return 0;
  801214:	b8 00 00 00 00       	mov    $0x0,%eax
  801219:	eb 17                	jmp    801232 <fd_alloc+0x4d>
  80121b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801220:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801225:	75 c9                	jne    8011f0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801227:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80122d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801232:	5d                   	pop    %ebp
  801233:	c3                   	ret    

00801234 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80123a:	83 f8 1f             	cmp    $0x1f,%eax
  80123d:	77 36                	ja     801275 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80123f:	c1 e0 0c             	shl    $0xc,%eax
  801242:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801247:	89 c2                	mov    %eax,%edx
  801249:	c1 ea 16             	shr    $0x16,%edx
  80124c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801253:	f6 c2 01             	test   $0x1,%dl
  801256:	74 24                	je     80127c <fd_lookup+0x48>
  801258:	89 c2                	mov    %eax,%edx
  80125a:	c1 ea 0c             	shr    $0xc,%edx
  80125d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801264:	f6 c2 01             	test   $0x1,%dl
  801267:	74 1a                	je     801283 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801269:	8b 55 0c             	mov    0xc(%ebp),%edx
  80126c:	89 02                	mov    %eax,(%edx)
	return 0;
  80126e:	b8 00 00 00 00       	mov    $0x0,%eax
  801273:	eb 13                	jmp    801288 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801275:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80127a:	eb 0c                	jmp    801288 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80127c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801281:	eb 05                	jmp    801288 <fd_lookup+0x54>
  801283:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801288:	5d                   	pop    %ebp
  801289:	c3                   	ret    

0080128a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	83 ec 08             	sub    $0x8,%esp
  801290:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801293:	ba d0 26 80 00       	mov    $0x8026d0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801298:	eb 13                	jmp    8012ad <dev_lookup+0x23>
  80129a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80129d:	39 08                	cmp    %ecx,(%eax)
  80129f:	75 0c                	jne    8012ad <dev_lookup+0x23>
			*dev = devtab[i];
  8012a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ab:	eb 2e                	jmp    8012db <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012ad:	8b 02                	mov    (%edx),%eax
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	75 e7                	jne    80129a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012b3:	a1 04 40 80 00       	mov    0x804004,%eax
  8012b8:	8b 40 48             	mov    0x48(%eax),%eax
  8012bb:	83 ec 04             	sub    $0x4,%esp
  8012be:	51                   	push   %ecx
  8012bf:	50                   	push   %eax
  8012c0:	68 50 26 80 00       	push   $0x802650
  8012c5:	e8 67 ef ff ff       	call   800231 <cprintf>
	*dev = 0;
  8012ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012cd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012d3:	83 c4 10             	add    $0x10,%esp
  8012d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012db:	c9                   	leave  
  8012dc:	c3                   	ret    

008012dd <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012dd:	55                   	push   %ebp
  8012de:	89 e5                	mov    %esp,%ebp
  8012e0:	56                   	push   %esi
  8012e1:	53                   	push   %ebx
  8012e2:	83 ec 10             	sub    $0x10,%esp
  8012e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8012e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ee:	50                   	push   %eax
  8012ef:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012f5:	c1 e8 0c             	shr    $0xc,%eax
  8012f8:	50                   	push   %eax
  8012f9:	e8 36 ff ff ff       	call   801234 <fd_lookup>
  8012fe:	83 c4 08             	add    $0x8,%esp
  801301:	85 c0                	test   %eax,%eax
  801303:	78 05                	js     80130a <fd_close+0x2d>
	    || fd != fd2)
  801305:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801308:	74 0c                	je     801316 <fd_close+0x39>
		return (must_exist ? r : 0);
  80130a:	84 db                	test   %bl,%bl
  80130c:	ba 00 00 00 00       	mov    $0x0,%edx
  801311:	0f 44 c2             	cmove  %edx,%eax
  801314:	eb 41                	jmp    801357 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801316:	83 ec 08             	sub    $0x8,%esp
  801319:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80131c:	50                   	push   %eax
  80131d:	ff 36                	pushl  (%esi)
  80131f:	e8 66 ff ff ff       	call   80128a <dev_lookup>
  801324:	89 c3                	mov    %eax,%ebx
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	85 c0                	test   %eax,%eax
  80132b:	78 1a                	js     801347 <fd_close+0x6a>
		if (dev->dev_close)
  80132d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801330:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801333:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801338:	85 c0                	test   %eax,%eax
  80133a:	74 0b                	je     801347 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80133c:	83 ec 0c             	sub    $0xc,%esp
  80133f:	56                   	push   %esi
  801340:	ff d0                	call   *%eax
  801342:	89 c3                	mov    %eax,%ebx
  801344:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801347:	83 ec 08             	sub    $0x8,%esp
  80134a:	56                   	push   %esi
  80134b:	6a 00                	push   $0x0
  80134d:	e8 6b f9 ff ff       	call   800cbd <sys_page_unmap>
	return r;
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	89 d8                	mov    %ebx,%eax
}
  801357:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80135a:	5b                   	pop    %ebx
  80135b:	5e                   	pop    %esi
  80135c:	5d                   	pop    %ebp
  80135d:	c3                   	ret    

0080135e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
  801361:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801364:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801367:	50                   	push   %eax
  801368:	ff 75 08             	pushl  0x8(%ebp)
  80136b:	e8 c4 fe ff ff       	call   801234 <fd_lookup>
  801370:	83 c4 08             	add    $0x8,%esp
  801373:	85 c0                	test   %eax,%eax
  801375:	78 10                	js     801387 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801377:	83 ec 08             	sub    $0x8,%esp
  80137a:	6a 01                	push   $0x1
  80137c:	ff 75 f4             	pushl  -0xc(%ebp)
  80137f:	e8 59 ff ff ff       	call   8012dd <fd_close>
  801384:	83 c4 10             	add    $0x10,%esp
}
  801387:	c9                   	leave  
  801388:	c3                   	ret    

00801389 <close_all>:

void
close_all(void)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	53                   	push   %ebx
  80138d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801390:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801395:	83 ec 0c             	sub    $0xc,%esp
  801398:	53                   	push   %ebx
  801399:	e8 c0 ff ff ff       	call   80135e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80139e:	83 c3 01             	add    $0x1,%ebx
  8013a1:	83 c4 10             	add    $0x10,%esp
  8013a4:	83 fb 20             	cmp    $0x20,%ebx
  8013a7:	75 ec                	jne    801395 <close_all+0xc>
		close(i);
}
  8013a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ac:	c9                   	leave  
  8013ad:	c3                   	ret    

008013ae <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	57                   	push   %edi
  8013b2:	56                   	push   %esi
  8013b3:	53                   	push   %ebx
  8013b4:	83 ec 2c             	sub    $0x2c,%esp
  8013b7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013ba:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013bd:	50                   	push   %eax
  8013be:	ff 75 08             	pushl  0x8(%ebp)
  8013c1:	e8 6e fe ff ff       	call   801234 <fd_lookup>
  8013c6:	83 c4 08             	add    $0x8,%esp
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	0f 88 c1 00 00 00    	js     801492 <dup+0xe4>
		return r;
	close(newfdnum);
  8013d1:	83 ec 0c             	sub    $0xc,%esp
  8013d4:	56                   	push   %esi
  8013d5:	e8 84 ff ff ff       	call   80135e <close>

	newfd = INDEX2FD(newfdnum);
  8013da:	89 f3                	mov    %esi,%ebx
  8013dc:	c1 e3 0c             	shl    $0xc,%ebx
  8013df:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013e5:	83 c4 04             	add    $0x4,%esp
  8013e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013eb:	e8 de fd ff ff       	call   8011ce <fd2data>
  8013f0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013f2:	89 1c 24             	mov    %ebx,(%esp)
  8013f5:	e8 d4 fd ff ff       	call   8011ce <fd2data>
  8013fa:	83 c4 10             	add    $0x10,%esp
  8013fd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801400:	89 f8                	mov    %edi,%eax
  801402:	c1 e8 16             	shr    $0x16,%eax
  801405:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80140c:	a8 01                	test   $0x1,%al
  80140e:	74 37                	je     801447 <dup+0x99>
  801410:	89 f8                	mov    %edi,%eax
  801412:	c1 e8 0c             	shr    $0xc,%eax
  801415:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80141c:	f6 c2 01             	test   $0x1,%dl
  80141f:	74 26                	je     801447 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801421:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801428:	83 ec 0c             	sub    $0xc,%esp
  80142b:	25 07 0e 00 00       	and    $0xe07,%eax
  801430:	50                   	push   %eax
  801431:	ff 75 d4             	pushl  -0x2c(%ebp)
  801434:	6a 00                	push   $0x0
  801436:	57                   	push   %edi
  801437:	6a 00                	push   $0x0
  801439:	e8 3d f8 ff ff       	call   800c7b <sys_page_map>
  80143e:	89 c7                	mov    %eax,%edi
  801440:	83 c4 20             	add    $0x20,%esp
  801443:	85 c0                	test   %eax,%eax
  801445:	78 2e                	js     801475 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801447:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80144a:	89 d0                	mov    %edx,%eax
  80144c:	c1 e8 0c             	shr    $0xc,%eax
  80144f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801456:	83 ec 0c             	sub    $0xc,%esp
  801459:	25 07 0e 00 00       	and    $0xe07,%eax
  80145e:	50                   	push   %eax
  80145f:	53                   	push   %ebx
  801460:	6a 00                	push   $0x0
  801462:	52                   	push   %edx
  801463:	6a 00                	push   $0x0
  801465:	e8 11 f8 ff ff       	call   800c7b <sys_page_map>
  80146a:	89 c7                	mov    %eax,%edi
  80146c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80146f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801471:	85 ff                	test   %edi,%edi
  801473:	79 1d                	jns    801492 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801475:	83 ec 08             	sub    $0x8,%esp
  801478:	53                   	push   %ebx
  801479:	6a 00                	push   $0x0
  80147b:	e8 3d f8 ff ff       	call   800cbd <sys_page_unmap>
	sys_page_unmap(0, nva);
  801480:	83 c4 08             	add    $0x8,%esp
  801483:	ff 75 d4             	pushl  -0x2c(%ebp)
  801486:	6a 00                	push   $0x0
  801488:	e8 30 f8 ff ff       	call   800cbd <sys_page_unmap>
	return r;
  80148d:	83 c4 10             	add    $0x10,%esp
  801490:	89 f8                	mov    %edi,%eax
}
  801492:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801495:	5b                   	pop    %ebx
  801496:	5e                   	pop    %esi
  801497:	5f                   	pop    %edi
  801498:	5d                   	pop    %ebp
  801499:	c3                   	ret    

0080149a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	53                   	push   %ebx
  80149e:	83 ec 14             	sub    $0x14,%esp
  8014a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a7:	50                   	push   %eax
  8014a8:	53                   	push   %ebx
  8014a9:	e8 86 fd ff ff       	call   801234 <fd_lookup>
  8014ae:	83 c4 08             	add    $0x8,%esp
  8014b1:	89 c2                	mov    %eax,%edx
  8014b3:	85 c0                	test   %eax,%eax
  8014b5:	78 6d                	js     801524 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b7:	83 ec 08             	sub    $0x8,%esp
  8014ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bd:	50                   	push   %eax
  8014be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c1:	ff 30                	pushl  (%eax)
  8014c3:	e8 c2 fd ff ff       	call   80128a <dev_lookup>
  8014c8:	83 c4 10             	add    $0x10,%esp
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	78 4c                	js     80151b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014d2:	8b 42 08             	mov    0x8(%edx),%eax
  8014d5:	83 e0 03             	and    $0x3,%eax
  8014d8:	83 f8 01             	cmp    $0x1,%eax
  8014db:	75 21                	jne    8014fe <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014dd:	a1 04 40 80 00       	mov    0x804004,%eax
  8014e2:	8b 40 48             	mov    0x48(%eax),%eax
  8014e5:	83 ec 04             	sub    $0x4,%esp
  8014e8:	53                   	push   %ebx
  8014e9:	50                   	push   %eax
  8014ea:	68 94 26 80 00       	push   $0x802694
  8014ef:	e8 3d ed ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014fc:	eb 26                	jmp    801524 <read+0x8a>
	}
	if (!dev->dev_read)
  8014fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801501:	8b 40 08             	mov    0x8(%eax),%eax
  801504:	85 c0                	test   %eax,%eax
  801506:	74 17                	je     80151f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801508:	83 ec 04             	sub    $0x4,%esp
  80150b:	ff 75 10             	pushl  0x10(%ebp)
  80150e:	ff 75 0c             	pushl  0xc(%ebp)
  801511:	52                   	push   %edx
  801512:	ff d0                	call   *%eax
  801514:	89 c2                	mov    %eax,%edx
  801516:	83 c4 10             	add    $0x10,%esp
  801519:	eb 09                	jmp    801524 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151b:	89 c2                	mov    %eax,%edx
  80151d:	eb 05                	jmp    801524 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80151f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801524:	89 d0                	mov    %edx,%eax
  801526:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801529:	c9                   	leave  
  80152a:	c3                   	ret    

0080152b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	57                   	push   %edi
  80152f:	56                   	push   %esi
  801530:	53                   	push   %ebx
  801531:	83 ec 0c             	sub    $0xc,%esp
  801534:	8b 7d 08             	mov    0x8(%ebp),%edi
  801537:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80153a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80153f:	eb 21                	jmp    801562 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801541:	83 ec 04             	sub    $0x4,%esp
  801544:	89 f0                	mov    %esi,%eax
  801546:	29 d8                	sub    %ebx,%eax
  801548:	50                   	push   %eax
  801549:	89 d8                	mov    %ebx,%eax
  80154b:	03 45 0c             	add    0xc(%ebp),%eax
  80154e:	50                   	push   %eax
  80154f:	57                   	push   %edi
  801550:	e8 45 ff ff ff       	call   80149a <read>
		if (m < 0)
  801555:	83 c4 10             	add    $0x10,%esp
  801558:	85 c0                	test   %eax,%eax
  80155a:	78 10                	js     80156c <readn+0x41>
			return m;
		if (m == 0)
  80155c:	85 c0                	test   %eax,%eax
  80155e:	74 0a                	je     80156a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801560:	01 c3                	add    %eax,%ebx
  801562:	39 f3                	cmp    %esi,%ebx
  801564:	72 db                	jb     801541 <readn+0x16>
  801566:	89 d8                	mov    %ebx,%eax
  801568:	eb 02                	jmp    80156c <readn+0x41>
  80156a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80156c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80156f:	5b                   	pop    %ebx
  801570:	5e                   	pop    %esi
  801571:	5f                   	pop    %edi
  801572:	5d                   	pop    %ebp
  801573:	c3                   	ret    

00801574 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
  801577:	53                   	push   %ebx
  801578:	83 ec 14             	sub    $0x14,%esp
  80157b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80157e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801581:	50                   	push   %eax
  801582:	53                   	push   %ebx
  801583:	e8 ac fc ff ff       	call   801234 <fd_lookup>
  801588:	83 c4 08             	add    $0x8,%esp
  80158b:	89 c2                	mov    %eax,%edx
  80158d:	85 c0                	test   %eax,%eax
  80158f:	78 68                	js     8015f9 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801591:	83 ec 08             	sub    $0x8,%esp
  801594:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801597:	50                   	push   %eax
  801598:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159b:	ff 30                	pushl  (%eax)
  80159d:	e8 e8 fc ff ff       	call   80128a <dev_lookup>
  8015a2:	83 c4 10             	add    $0x10,%esp
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	78 47                	js     8015f0 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ac:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015b0:	75 21                	jne    8015d3 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8015b7:	8b 40 48             	mov    0x48(%eax),%eax
  8015ba:	83 ec 04             	sub    $0x4,%esp
  8015bd:	53                   	push   %ebx
  8015be:	50                   	push   %eax
  8015bf:	68 b0 26 80 00       	push   $0x8026b0
  8015c4:	e8 68 ec ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  8015c9:	83 c4 10             	add    $0x10,%esp
  8015cc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015d1:	eb 26                	jmp    8015f9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d6:	8b 52 0c             	mov    0xc(%edx),%edx
  8015d9:	85 d2                	test   %edx,%edx
  8015db:	74 17                	je     8015f4 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015dd:	83 ec 04             	sub    $0x4,%esp
  8015e0:	ff 75 10             	pushl  0x10(%ebp)
  8015e3:	ff 75 0c             	pushl  0xc(%ebp)
  8015e6:	50                   	push   %eax
  8015e7:	ff d2                	call   *%edx
  8015e9:	89 c2                	mov    %eax,%edx
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	eb 09                	jmp    8015f9 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f0:	89 c2                	mov    %eax,%edx
  8015f2:	eb 05                	jmp    8015f9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015f4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015f9:	89 d0                	mov    %edx,%eax
  8015fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fe:	c9                   	leave  
  8015ff:	c3                   	ret    

00801600 <seek>:

int
seek(int fdnum, off_t offset)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801606:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801609:	50                   	push   %eax
  80160a:	ff 75 08             	pushl  0x8(%ebp)
  80160d:	e8 22 fc ff ff       	call   801234 <fd_lookup>
  801612:	83 c4 08             	add    $0x8,%esp
  801615:	85 c0                	test   %eax,%eax
  801617:	78 0e                	js     801627 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801619:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80161c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80161f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801622:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801627:	c9                   	leave  
  801628:	c3                   	ret    

00801629 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801629:	55                   	push   %ebp
  80162a:	89 e5                	mov    %esp,%ebp
  80162c:	53                   	push   %ebx
  80162d:	83 ec 14             	sub    $0x14,%esp
  801630:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801633:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801636:	50                   	push   %eax
  801637:	53                   	push   %ebx
  801638:	e8 f7 fb ff ff       	call   801234 <fd_lookup>
  80163d:	83 c4 08             	add    $0x8,%esp
  801640:	89 c2                	mov    %eax,%edx
  801642:	85 c0                	test   %eax,%eax
  801644:	78 65                	js     8016ab <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801646:	83 ec 08             	sub    $0x8,%esp
  801649:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164c:	50                   	push   %eax
  80164d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801650:	ff 30                	pushl  (%eax)
  801652:	e8 33 fc ff ff       	call   80128a <dev_lookup>
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	85 c0                	test   %eax,%eax
  80165c:	78 44                	js     8016a2 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80165e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801661:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801665:	75 21                	jne    801688 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801667:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80166c:	8b 40 48             	mov    0x48(%eax),%eax
  80166f:	83 ec 04             	sub    $0x4,%esp
  801672:	53                   	push   %ebx
  801673:	50                   	push   %eax
  801674:	68 70 26 80 00       	push   $0x802670
  801679:	e8 b3 eb ff ff       	call   800231 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80167e:	83 c4 10             	add    $0x10,%esp
  801681:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801686:	eb 23                	jmp    8016ab <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801688:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80168b:	8b 52 18             	mov    0x18(%edx),%edx
  80168e:	85 d2                	test   %edx,%edx
  801690:	74 14                	je     8016a6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801692:	83 ec 08             	sub    $0x8,%esp
  801695:	ff 75 0c             	pushl  0xc(%ebp)
  801698:	50                   	push   %eax
  801699:	ff d2                	call   *%edx
  80169b:	89 c2                	mov    %eax,%edx
  80169d:	83 c4 10             	add    $0x10,%esp
  8016a0:	eb 09                	jmp    8016ab <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a2:	89 c2                	mov    %eax,%edx
  8016a4:	eb 05                	jmp    8016ab <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016a6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016ab:	89 d0                	mov    %edx,%eax
  8016ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b0:	c9                   	leave  
  8016b1:	c3                   	ret    

008016b2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	53                   	push   %ebx
  8016b6:	83 ec 14             	sub    $0x14,%esp
  8016b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016bf:	50                   	push   %eax
  8016c0:	ff 75 08             	pushl  0x8(%ebp)
  8016c3:	e8 6c fb ff ff       	call   801234 <fd_lookup>
  8016c8:	83 c4 08             	add    $0x8,%esp
  8016cb:	89 c2                	mov    %eax,%edx
  8016cd:	85 c0                	test   %eax,%eax
  8016cf:	78 58                	js     801729 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d1:	83 ec 08             	sub    $0x8,%esp
  8016d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d7:	50                   	push   %eax
  8016d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016db:	ff 30                	pushl  (%eax)
  8016dd:	e8 a8 fb ff ff       	call   80128a <dev_lookup>
  8016e2:	83 c4 10             	add    $0x10,%esp
  8016e5:	85 c0                	test   %eax,%eax
  8016e7:	78 37                	js     801720 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ec:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016f0:	74 32                	je     801724 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016f2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016f5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016fc:	00 00 00 
	stat->st_isdir = 0;
  8016ff:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801706:	00 00 00 
	stat->st_dev = dev;
  801709:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80170f:	83 ec 08             	sub    $0x8,%esp
  801712:	53                   	push   %ebx
  801713:	ff 75 f0             	pushl  -0x10(%ebp)
  801716:	ff 50 14             	call   *0x14(%eax)
  801719:	89 c2                	mov    %eax,%edx
  80171b:	83 c4 10             	add    $0x10,%esp
  80171e:	eb 09                	jmp    801729 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801720:	89 c2                	mov    %eax,%edx
  801722:	eb 05                	jmp    801729 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801724:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801729:	89 d0                	mov    %edx,%eax
  80172b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172e:	c9                   	leave  
  80172f:	c3                   	ret    

00801730 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	56                   	push   %esi
  801734:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801735:	83 ec 08             	sub    $0x8,%esp
  801738:	6a 00                	push   $0x0
  80173a:	ff 75 08             	pushl  0x8(%ebp)
  80173d:	e8 e3 01 00 00       	call   801925 <open>
  801742:	89 c3                	mov    %eax,%ebx
  801744:	83 c4 10             	add    $0x10,%esp
  801747:	85 c0                	test   %eax,%eax
  801749:	78 1b                	js     801766 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80174b:	83 ec 08             	sub    $0x8,%esp
  80174e:	ff 75 0c             	pushl  0xc(%ebp)
  801751:	50                   	push   %eax
  801752:	e8 5b ff ff ff       	call   8016b2 <fstat>
  801757:	89 c6                	mov    %eax,%esi
	close(fd);
  801759:	89 1c 24             	mov    %ebx,(%esp)
  80175c:	e8 fd fb ff ff       	call   80135e <close>
	return r;
  801761:	83 c4 10             	add    $0x10,%esp
  801764:	89 f0                	mov    %esi,%eax
}
  801766:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801769:	5b                   	pop    %ebx
  80176a:	5e                   	pop    %esi
  80176b:	5d                   	pop    %ebp
  80176c:	c3                   	ret    

0080176d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80176d:	55                   	push   %ebp
  80176e:	89 e5                	mov    %esp,%ebp
  801770:	56                   	push   %esi
  801771:	53                   	push   %ebx
  801772:	89 c6                	mov    %eax,%esi
  801774:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801776:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80177d:	75 12                	jne    801791 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80177f:	83 ec 0c             	sub    $0xc,%esp
  801782:	6a 01                	push   $0x1
  801784:	e8 fc f9 ff ff       	call   801185 <ipc_find_env>
  801789:	a3 00 40 80 00       	mov    %eax,0x804000
  80178e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801791:	6a 07                	push   $0x7
  801793:	68 00 50 80 00       	push   $0x805000
  801798:	56                   	push   %esi
  801799:	ff 35 00 40 80 00    	pushl  0x804000
  80179f:	e8 8d f9 ff ff       	call   801131 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017a4:	83 c4 0c             	add    $0xc,%esp
  8017a7:	6a 00                	push   $0x0
  8017a9:	53                   	push   %ebx
  8017aa:	6a 00                	push   $0x0
  8017ac:	e8 17 f9 ff ff       	call   8010c8 <ipc_recv>
}
  8017b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b4:	5b                   	pop    %ebx
  8017b5:	5e                   	pop    %esi
  8017b6:	5d                   	pop    %ebp
  8017b7:	c3                   	ret    

008017b8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017be:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017cc:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d6:	b8 02 00 00 00       	mov    $0x2,%eax
  8017db:	e8 8d ff ff ff       	call   80176d <fsipc>
}
  8017e0:	c9                   	leave  
  8017e1:	c3                   	ret    

008017e2 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017e2:	55                   	push   %ebp
  8017e3:	89 e5                	mov    %esp,%ebp
  8017e5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ee:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f8:	b8 06 00 00 00       	mov    $0x6,%eax
  8017fd:	e8 6b ff ff ff       	call   80176d <fsipc>
}
  801802:	c9                   	leave  
  801803:	c3                   	ret    

00801804 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	53                   	push   %ebx
  801808:	83 ec 04             	sub    $0x4,%esp
  80180b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80180e:	8b 45 08             	mov    0x8(%ebp),%eax
  801811:	8b 40 0c             	mov    0xc(%eax),%eax
  801814:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801819:	ba 00 00 00 00       	mov    $0x0,%edx
  80181e:	b8 05 00 00 00       	mov    $0x5,%eax
  801823:	e8 45 ff ff ff       	call   80176d <fsipc>
  801828:	85 c0                	test   %eax,%eax
  80182a:	78 2c                	js     801858 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80182c:	83 ec 08             	sub    $0x8,%esp
  80182f:	68 00 50 80 00       	push   $0x805000
  801834:	53                   	push   %ebx
  801835:	e8 fb ef ff ff       	call   800835 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80183a:	a1 80 50 80 00       	mov    0x805080,%eax
  80183f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801845:	a1 84 50 80 00       	mov    0x805084,%eax
  80184a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801850:	83 c4 10             	add    $0x10,%esp
  801853:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801858:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185b:	c9                   	leave  
  80185c:	c3                   	ret    

0080185d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80185d:	55                   	push   %ebp
  80185e:	89 e5                	mov    %esp,%ebp
  801860:	83 ec 0c             	sub    $0xc,%esp
  801863:	8b 45 10             	mov    0x10(%ebp),%eax
  801866:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80186b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801870:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801873:	8b 55 08             	mov    0x8(%ebp),%edx
  801876:	8b 52 0c             	mov    0xc(%edx),%edx
  801879:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80187f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801884:	50                   	push   %eax
  801885:	ff 75 0c             	pushl  0xc(%ebp)
  801888:	68 08 50 80 00       	push   $0x805008
  80188d:	e8 35 f1 ff ff       	call   8009c7 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801892:	ba 00 00 00 00       	mov    $0x0,%edx
  801897:	b8 04 00 00 00       	mov    $0x4,%eax
  80189c:	e8 cc fe ff ff       	call   80176d <fsipc>
	//panic("devfile_write not implemented");
}
  8018a1:	c9                   	leave  
  8018a2:	c3                   	ret    

008018a3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	56                   	push   %esi
  8018a7:	53                   	push   %ebx
  8018a8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018b6:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c1:	b8 03 00 00 00       	mov    $0x3,%eax
  8018c6:	e8 a2 fe ff ff       	call   80176d <fsipc>
  8018cb:	89 c3                	mov    %eax,%ebx
  8018cd:	85 c0                	test   %eax,%eax
  8018cf:	78 4b                	js     80191c <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018d1:	39 c6                	cmp    %eax,%esi
  8018d3:	73 16                	jae    8018eb <devfile_read+0x48>
  8018d5:	68 e0 26 80 00       	push   $0x8026e0
  8018da:	68 e7 26 80 00       	push   $0x8026e7
  8018df:	6a 7c                	push   $0x7c
  8018e1:	68 fc 26 80 00       	push   $0x8026fc
  8018e6:	e8 6d e8 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  8018eb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018f0:	7e 16                	jle    801908 <devfile_read+0x65>
  8018f2:	68 07 27 80 00       	push   $0x802707
  8018f7:	68 e7 26 80 00       	push   $0x8026e7
  8018fc:	6a 7d                	push   $0x7d
  8018fe:	68 fc 26 80 00       	push   $0x8026fc
  801903:	e8 50 e8 ff ff       	call   800158 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801908:	83 ec 04             	sub    $0x4,%esp
  80190b:	50                   	push   %eax
  80190c:	68 00 50 80 00       	push   $0x805000
  801911:	ff 75 0c             	pushl  0xc(%ebp)
  801914:	e8 ae f0 ff ff       	call   8009c7 <memmove>
	return r;
  801919:	83 c4 10             	add    $0x10,%esp
}
  80191c:	89 d8                	mov    %ebx,%eax
  80191e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801921:	5b                   	pop    %ebx
  801922:	5e                   	pop    %esi
  801923:	5d                   	pop    %ebp
  801924:	c3                   	ret    

00801925 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
  801928:	53                   	push   %ebx
  801929:	83 ec 20             	sub    $0x20,%esp
  80192c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80192f:	53                   	push   %ebx
  801930:	e8 c7 ee ff ff       	call   8007fc <strlen>
  801935:	83 c4 10             	add    $0x10,%esp
  801938:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80193d:	7f 67                	jg     8019a6 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80193f:	83 ec 0c             	sub    $0xc,%esp
  801942:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801945:	50                   	push   %eax
  801946:	e8 9a f8 ff ff       	call   8011e5 <fd_alloc>
  80194b:	83 c4 10             	add    $0x10,%esp
		return r;
  80194e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801950:	85 c0                	test   %eax,%eax
  801952:	78 57                	js     8019ab <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801954:	83 ec 08             	sub    $0x8,%esp
  801957:	53                   	push   %ebx
  801958:	68 00 50 80 00       	push   $0x805000
  80195d:	e8 d3 ee ff ff       	call   800835 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801962:	8b 45 0c             	mov    0xc(%ebp),%eax
  801965:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80196a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80196d:	b8 01 00 00 00       	mov    $0x1,%eax
  801972:	e8 f6 fd ff ff       	call   80176d <fsipc>
  801977:	89 c3                	mov    %eax,%ebx
  801979:	83 c4 10             	add    $0x10,%esp
  80197c:	85 c0                	test   %eax,%eax
  80197e:	79 14                	jns    801994 <open+0x6f>
		fd_close(fd, 0);
  801980:	83 ec 08             	sub    $0x8,%esp
  801983:	6a 00                	push   $0x0
  801985:	ff 75 f4             	pushl  -0xc(%ebp)
  801988:	e8 50 f9 ff ff       	call   8012dd <fd_close>
		return r;
  80198d:	83 c4 10             	add    $0x10,%esp
  801990:	89 da                	mov    %ebx,%edx
  801992:	eb 17                	jmp    8019ab <open+0x86>
	}

	return fd2num(fd);
  801994:	83 ec 0c             	sub    $0xc,%esp
  801997:	ff 75 f4             	pushl  -0xc(%ebp)
  80199a:	e8 1f f8 ff ff       	call   8011be <fd2num>
  80199f:	89 c2                	mov    %eax,%edx
  8019a1:	83 c4 10             	add    $0x10,%esp
  8019a4:	eb 05                	jmp    8019ab <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019a6:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019ab:	89 d0                	mov    %edx,%eax
  8019ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b0:	c9                   	leave  
  8019b1:	c3                   	ret    

008019b2 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019b2:	55                   	push   %ebp
  8019b3:	89 e5                	mov    %esp,%ebp
  8019b5:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8019bd:	b8 08 00 00 00       	mov    $0x8,%eax
  8019c2:	e8 a6 fd ff ff       	call   80176d <fsipc>
}
  8019c7:	c9                   	leave  
  8019c8:	c3                   	ret    

008019c9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	56                   	push   %esi
  8019cd:	53                   	push   %ebx
  8019ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019d1:	83 ec 0c             	sub    $0xc,%esp
  8019d4:	ff 75 08             	pushl  0x8(%ebp)
  8019d7:	e8 f2 f7 ff ff       	call   8011ce <fd2data>
  8019dc:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019de:	83 c4 08             	add    $0x8,%esp
  8019e1:	68 13 27 80 00       	push   $0x802713
  8019e6:	53                   	push   %ebx
  8019e7:	e8 49 ee ff ff       	call   800835 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019ec:	8b 46 04             	mov    0x4(%esi),%eax
  8019ef:	2b 06                	sub    (%esi),%eax
  8019f1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019f7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019fe:	00 00 00 
	stat->st_dev = &devpipe;
  801a01:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a08:	30 80 00 
	return 0;
}
  801a0b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a13:	5b                   	pop    %ebx
  801a14:	5e                   	pop    %esi
  801a15:	5d                   	pop    %ebp
  801a16:	c3                   	ret    

00801a17 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a17:	55                   	push   %ebp
  801a18:	89 e5                	mov    %esp,%ebp
  801a1a:	53                   	push   %ebx
  801a1b:	83 ec 0c             	sub    $0xc,%esp
  801a1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a21:	53                   	push   %ebx
  801a22:	6a 00                	push   $0x0
  801a24:	e8 94 f2 ff ff       	call   800cbd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a29:	89 1c 24             	mov    %ebx,(%esp)
  801a2c:	e8 9d f7 ff ff       	call   8011ce <fd2data>
  801a31:	83 c4 08             	add    $0x8,%esp
  801a34:	50                   	push   %eax
  801a35:	6a 00                	push   $0x0
  801a37:	e8 81 f2 ff ff       	call   800cbd <sys_page_unmap>
}
  801a3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3f:	c9                   	leave  
  801a40:	c3                   	ret    

00801a41 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	57                   	push   %edi
  801a45:	56                   	push   %esi
  801a46:	53                   	push   %ebx
  801a47:	83 ec 1c             	sub    $0x1c,%esp
  801a4a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a4d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a4f:	a1 04 40 80 00       	mov    0x804004,%eax
  801a54:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a57:	83 ec 0c             	sub    $0xc,%esp
  801a5a:	ff 75 e0             	pushl  -0x20(%ebp)
  801a5d:	e8 cd 04 00 00       	call   801f2f <pageref>
  801a62:	89 c3                	mov    %eax,%ebx
  801a64:	89 3c 24             	mov    %edi,(%esp)
  801a67:	e8 c3 04 00 00       	call   801f2f <pageref>
  801a6c:	83 c4 10             	add    $0x10,%esp
  801a6f:	39 c3                	cmp    %eax,%ebx
  801a71:	0f 94 c1             	sete   %cl
  801a74:	0f b6 c9             	movzbl %cl,%ecx
  801a77:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a7a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a80:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a83:	39 ce                	cmp    %ecx,%esi
  801a85:	74 1b                	je     801aa2 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a87:	39 c3                	cmp    %eax,%ebx
  801a89:	75 c4                	jne    801a4f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a8b:	8b 42 58             	mov    0x58(%edx),%eax
  801a8e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a91:	50                   	push   %eax
  801a92:	56                   	push   %esi
  801a93:	68 1a 27 80 00       	push   $0x80271a
  801a98:	e8 94 e7 ff ff       	call   800231 <cprintf>
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	eb ad                	jmp    801a4f <_pipeisclosed+0xe>
	}
}
  801aa2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aa5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa8:	5b                   	pop    %ebx
  801aa9:	5e                   	pop    %esi
  801aaa:	5f                   	pop    %edi
  801aab:	5d                   	pop    %ebp
  801aac:	c3                   	ret    

00801aad <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	57                   	push   %edi
  801ab1:	56                   	push   %esi
  801ab2:	53                   	push   %ebx
  801ab3:	83 ec 28             	sub    $0x28,%esp
  801ab6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ab9:	56                   	push   %esi
  801aba:	e8 0f f7 ff ff       	call   8011ce <fd2data>
  801abf:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac1:	83 c4 10             	add    $0x10,%esp
  801ac4:	bf 00 00 00 00       	mov    $0x0,%edi
  801ac9:	eb 4b                	jmp    801b16 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801acb:	89 da                	mov    %ebx,%edx
  801acd:	89 f0                	mov    %esi,%eax
  801acf:	e8 6d ff ff ff       	call   801a41 <_pipeisclosed>
  801ad4:	85 c0                	test   %eax,%eax
  801ad6:	75 48                	jne    801b20 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ad8:	e8 3c f1 ff ff       	call   800c19 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801add:	8b 43 04             	mov    0x4(%ebx),%eax
  801ae0:	8b 0b                	mov    (%ebx),%ecx
  801ae2:	8d 51 20             	lea    0x20(%ecx),%edx
  801ae5:	39 d0                	cmp    %edx,%eax
  801ae7:	73 e2                	jae    801acb <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ae9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aec:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801af0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801af3:	89 c2                	mov    %eax,%edx
  801af5:	c1 fa 1f             	sar    $0x1f,%edx
  801af8:	89 d1                	mov    %edx,%ecx
  801afa:	c1 e9 1b             	shr    $0x1b,%ecx
  801afd:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b00:	83 e2 1f             	and    $0x1f,%edx
  801b03:	29 ca                	sub    %ecx,%edx
  801b05:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b09:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b0d:	83 c0 01             	add    $0x1,%eax
  801b10:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b13:	83 c7 01             	add    $0x1,%edi
  801b16:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b19:	75 c2                	jne    801add <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b1b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b1e:	eb 05                	jmp    801b25 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b20:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b28:	5b                   	pop    %ebx
  801b29:	5e                   	pop    %esi
  801b2a:	5f                   	pop    %edi
  801b2b:	5d                   	pop    %ebp
  801b2c:	c3                   	ret    

00801b2d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	57                   	push   %edi
  801b31:	56                   	push   %esi
  801b32:	53                   	push   %ebx
  801b33:	83 ec 18             	sub    $0x18,%esp
  801b36:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b39:	57                   	push   %edi
  801b3a:	e8 8f f6 ff ff       	call   8011ce <fd2data>
  801b3f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b41:	83 c4 10             	add    $0x10,%esp
  801b44:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b49:	eb 3d                	jmp    801b88 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b4b:	85 db                	test   %ebx,%ebx
  801b4d:	74 04                	je     801b53 <devpipe_read+0x26>
				return i;
  801b4f:	89 d8                	mov    %ebx,%eax
  801b51:	eb 44                	jmp    801b97 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b53:	89 f2                	mov    %esi,%edx
  801b55:	89 f8                	mov    %edi,%eax
  801b57:	e8 e5 fe ff ff       	call   801a41 <_pipeisclosed>
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	75 32                	jne    801b92 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b60:	e8 b4 f0 ff ff       	call   800c19 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b65:	8b 06                	mov    (%esi),%eax
  801b67:	3b 46 04             	cmp    0x4(%esi),%eax
  801b6a:	74 df                	je     801b4b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b6c:	99                   	cltd   
  801b6d:	c1 ea 1b             	shr    $0x1b,%edx
  801b70:	01 d0                	add    %edx,%eax
  801b72:	83 e0 1f             	and    $0x1f,%eax
  801b75:	29 d0                	sub    %edx,%eax
  801b77:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b7f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b82:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b85:	83 c3 01             	add    $0x1,%ebx
  801b88:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b8b:	75 d8                	jne    801b65 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b8d:	8b 45 10             	mov    0x10(%ebp),%eax
  801b90:	eb 05                	jmp    801b97 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b92:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b9a:	5b                   	pop    %ebx
  801b9b:	5e                   	pop    %esi
  801b9c:	5f                   	pop    %edi
  801b9d:	5d                   	pop    %ebp
  801b9e:	c3                   	ret    

00801b9f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b9f:	55                   	push   %ebp
  801ba0:	89 e5                	mov    %esp,%ebp
  801ba2:	56                   	push   %esi
  801ba3:	53                   	push   %ebx
  801ba4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ba7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801baa:	50                   	push   %eax
  801bab:	e8 35 f6 ff ff       	call   8011e5 <fd_alloc>
  801bb0:	83 c4 10             	add    $0x10,%esp
  801bb3:	89 c2                	mov    %eax,%edx
  801bb5:	85 c0                	test   %eax,%eax
  801bb7:	0f 88 2c 01 00 00    	js     801ce9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bbd:	83 ec 04             	sub    $0x4,%esp
  801bc0:	68 07 04 00 00       	push   $0x407
  801bc5:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc8:	6a 00                	push   $0x0
  801bca:	e8 69 f0 ff ff       	call   800c38 <sys_page_alloc>
  801bcf:	83 c4 10             	add    $0x10,%esp
  801bd2:	89 c2                	mov    %eax,%edx
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	0f 88 0d 01 00 00    	js     801ce9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bdc:	83 ec 0c             	sub    $0xc,%esp
  801bdf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801be2:	50                   	push   %eax
  801be3:	e8 fd f5 ff ff       	call   8011e5 <fd_alloc>
  801be8:	89 c3                	mov    %eax,%ebx
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	85 c0                	test   %eax,%eax
  801bef:	0f 88 e2 00 00 00    	js     801cd7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf5:	83 ec 04             	sub    $0x4,%esp
  801bf8:	68 07 04 00 00       	push   $0x407
  801bfd:	ff 75 f0             	pushl  -0x10(%ebp)
  801c00:	6a 00                	push   $0x0
  801c02:	e8 31 f0 ff ff       	call   800c38 <sys_page_alloc>
  801c07:	89 c3                	mov    %eax,%ebx
  801c09:	83 c4 10             	add    $0x10,%esp
  801c0c:	85 c0                	test   %eax,%eax
  801c0e:	0f 88 c3 00 00 00    	js     801cd7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c14:	83 ec 0c             	sub    $0xc,%esp
  801c17:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1a:	e8 af f5 ff ff       	call   8011ce <fd2data>
  801c1f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c21:	83 c4 0c             	add    $0xc,%esp
  801c24:	68 07 04 00 00       	push   $0x407
  801c29:	50                   	push   %eax
  801c2a:	6a 00                	push   $0x0
  801c2c:	e8 07 f0 ff ff       	call   800c38 <sys_page_alloc>
  801c31:	89 c3                	mov    %eax,%ebx
  801c33:	83 c4 10             	add    $0x10,%esp
  801c36:	85 c0                	test   %eax,%eax
  801c38:	0f 88 89 00 00 00    	js     801cc7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c3e:	83 ec 0c             	sub    $0xc,%esp
  801c41:	ff 75 f0             	pushl  -0x10(%ebp)
  801c44:	e8 85 f5 ff ff       	call   8011ce <fd2data>
  801c49:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c50:	50                   	push   %eax
  801c51:	6a 00                	push   $0x0
  801c53:	56                   	push   %esi
  801c54:	6a 00                	push   $0x0
  801c56:	e8 20 f0 ff ff       	call   800c7b <sys_page_map>
  801c5b:	89 c3                	mov    %eax,%ebx
  801c5d:	83 c4 20             	add    $0x20,%esp
  801c60:	85 c0                	test   %eax,%eax
  801c62:	78 55                	js     801cb9 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c64:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c72:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c79:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c82:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c84:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c87:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c8e:	83 ec 0c             	sub    $0xc,%esp
  801c91:	ff 75 f4             	pushl  -0xc(%ebp)
  801c94:	e8 25 f5 ff ff       	call   8011be <fd2num>
  801c99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c9c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c9e:	83 c4 04             	add    $0x4,%esp
  801ca1:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca4:	e8 15 f5 ff ff       	call   8011be <fd2num>
  801ca9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cac:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801caf:	83 c4 10             	add    $0x10,%esp
  801cb2:	ba 00 00 00 00       	mov    $0x0,%edx
  801cb7:	eb 30                	jmp    801ce9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cb9:	83 ec 08             	sub    $0x8,%esp
  801cbc:	56                   	push   %esi
  801cbd:	6a 00                	push   $0x0
  801cbf:	e8 f9 ef ff ff       	call   800cbd <sys_page_unmap>
  801cc4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cc7:	83 ec 08             	sub    $0x8,%esp
  801cca:	ff 75 f0             	pushl  -0x10(%ebp)
  801ccd:	6a 00                	push   $0x0
  801ccf:	e8 e9 ef ff ff       	call   800cbd <sys_page_unmap>
  801cd4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cd7:	83 ec 08             	sub    $0x8,%esp
  801cda:	ff 75 f4             	pushl  -0xc(%ebp)
  801cdd:	6a 00                	push   $0x0
  801cdf:	e8 d9 ef ff ff       	call   800cbd <sys_page_unmap>
  801ce4:	83 c4 10             	add    $0x10,%esp
  801ce7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ce9:	89 d0                	mov    %edx,%eax
  801ceb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cee:	5b                   	pop    %ebx
  801cef:	5e                   	pop    %esi
  801cf0:	5d                   	pop    %ebp
  801cf1:	c3                   	ret    

00801cf2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cf8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cfb:	50                   	push   %eax
  801cfc:	ff 75 08             	pushl  0x8(%ebp)
  801cff:	e8 30 f5 ff ff       	call   801234 <fd_lookup>
  801d04:	83 c4 10             	add    $0x10,%esp
  801d07:	85 c0                	test   %eax,%eax
  801d09:	78 18                	js     801d23 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d0b:	83 ec 0c             	sub    $0xc,%esp
  801d0e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d11:	e8 b8 f4 ff ff       	call   8011ce <fd2data>
	return _pipeisclosed(fd, p);
  801d16:	89 c2                	mov    %eax,%edx
  801d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1b:	e8 21 fd ff ff       	call   801a41 <_pipeisclosed>
  801d20:	83 c4 10             	add    $0x10,%esp
}
  801d23:	c9                   	leave  
  801d24:	c3                   	ret    

00801d25 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d28:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2d:	5d                   	pop    %ebp
  801d2e:	c3                   	ret    

00801d2f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d2f:	55                   	push   %ebp
  801d30:	89 e5                	mov    %esp,%ebp
  801d32:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d35:	68 32 27 80 00       	push   $0x802732
  801d3a:	ff 75 0c             	pushl  0xc(%ebp)
  801d3d:	e8 f3 ea ff ff       	call   800835 <strcpy>
	return 0;
}
  801d42:	b8 00 00 00 00       	mov    $0x0,%eax
  801d47:	c9                   	leave  
  801d48:	c3                   	ret    

00801d49 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d49:	55                   	push   %ebp
  801d4a:	89 e5                	mov    %esp,%ebp
  801d4c:	57                   	push   %edi
  801d4d:	56                   	push   %esi
  801d4e:	53                   	push   %ebx
  801d4f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d55:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d5a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d60:	eb 2d                	jmp    801d8f <devcons_write+0x46>
		m = n - tot;
  801d62:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d65:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d67:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d6a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d6f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d72:	83 ec 04             	sub    $0x4,%esp
  801d75:	53                   	push   %ebx
  801d76:	03 45 0c             	add    0xc(%ebp),%eax
  801d79:	50                   	push   %eax
  801d7a:	57                   	push   %edi
  801d7b:	e8 47 ec ff ff       	call   8009c7 <memmove>
		sys_cputs(buf, m);
  801d80:	83 c4 08             	add    $0x8,%esp
  801d83:	53                   	push   %ebx
  801d84:	57                   	push   %edi
  801d85:	e8 f2 ed ff ff       	call   800b7c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d8a:	01 de                	add    %ebx,%esi
  801d8c:	83 c4 10             	add    $0x10,%esp
  801d8f:	89 f0                	mov    %esi,%eax
  801d91:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d94:	72 cc                	jb     801d62 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d99:	5b                   	pop    %ebx
  801d9a:	5e                   	pop    %esi
  801d9b:	5f                   	pop    %edi
  801d9c:	5d                   	pop    %ebp
  801d9d:	c3                   	ret    

00801d9e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d9e:	55                   	push   %ebp
  801d9f:	89 e5                	mov    %esp,%ebp
  801da1:	83 ec 08             	sub    $0x8,%esp
  801da4:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801da9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dad:	74 2a                	je     801dd9 <devcons_read+0x3b>
  801daf:	eb 05                	jmp    801db6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801db1:	e8 63 ee ff ff       	call   800c19 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801db6:	e8 df ed ff ff       	call   800b9a <sys_cgetc>
  801dbb:	85 c0                	test   %eax,%eax
  801dbd:	74 f2                	je     801db1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dbf:	85 c0                	test   %eax,%eax
  801dc1:	78 16                	js     801dd9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dc3:	83 f8 04             	cmp    $0x4,%eax
  801dc6:	74 0c                	je     801dd4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dc8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dcb:	88 02                	mov    %al,(%edx)
	return 1;
  801dcd:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd2:	eb 05                	jmp    801dd9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dd4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dd9:	c9                   	leave  
  801dda:	c3                   	ret    

00801ddb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801ddb:	55                   	push   %ebp
  801ddc:	89 e5                	mov    %esp,%ebp
  801dde:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801de1:	8b 45 08             	mov    0x8(%ebp),%eax
  801de4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801de7:	6a 01                	push   $0x1
  801de9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dec:	50                   	push   %eax
  801ded:	e8 8a ed ff ff       	call   800b7c <sys_cputs>
}
  801df2:	83 c4 10             	add    $0x10,%esp
  801df5:	c9                   	leave  
  801df6:	c3                   	ret    

00801df7 <getchar>:

int
getchar(void)
{
  801df7:	55                   	push   %ebp
  801df8:	89 e5                	mov    %esp,%ebp
  801dfa:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dfd:	6a 01                	push   $0x1
  801dff:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e02:	50                   	push   %eax
  801e03:	6a 00                	push   $0x0
  801e05:	e8 90 f6 ff ff       	call   80149a <read>
	if (r < 0)
  801e0a:	83 c4 10             	add    $0x10,%esp
  801e0d:	85 c0                	test   %eax,%eax
  801e0f:	78 0f                	js     801e20 <getchar+0x29>
		return r;
	if (r < 1)
  801e11:	85 c0                	test   %eax,%eax
  801e13:	7e 06                	jle    801e1b <getchar+0x24>
		return -E_EOF;
	return c;
  801e15:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e19:	eb 05                	jmp    801e20 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e1b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e20:	c9                   	leave  
  801e21:	c3                   	ret    

00801e22 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e22:	55                   	push   %ebp
  801e23:	89 e5                	mov    %esp,%ebp
  801e25:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e2b:	50                   	push   %eax
  801e2c:	ff 75 08             	pushl  0x8(%ebp)
  801e2f:	e8 00 f4 ff ff       	call   801234 <fd_lookup>
  801e34:	83 c4 10             	add    $0x10,%esp
  801e37:	85 c0                	test   %eax,%eax
  801e39:	78 11                	js     801e4c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e44:	39 10                	cmp    %edx,(%eax)
  801e46:	0f 94 c0             	sete   %al
  801e49:	0f b6 c0             	movzbl %al,%eax
}
  801e4c:	c9                   	leave  
  801e4d:	c3                   	ret    

00801e4e <opencons>:

int
opencons(void)
{
  801e4e:	55                   	push   %ebp
  801e4f:	89 e5                	mov    %esp,%ebp
  801e51:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e57:	50                   	push   %eax
  801e58:	e8 88 f3 ff ff       	call   8011e5 <fd_alloc>
  801e5d:	83 c4 10             	add    $0x10,%esp
		return r;
  801e60:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e62:	85 c0                	test   %eax,%eax
  801e64:	78 3e                	js     801ea4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e66:	83 ec 04             	sub    $0x4,%esp
  801e69:	68 07 04 00 00       	push   $0x407
  801e6e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e71:	6a 00                	push   $0x0
  801e73:	e8 c0 ed ff ff       	call   800c38 <sys_page_alloc>
  801e78:	83 c4 10             	add    $0x10,%esp
		return r;
  801e7b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e7d:	85 c0                	test   %eax,%eax
  801e7f:	78 23                	js     801ea4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e81:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e96:	83 ec 0c             	sub    $0xc,%esp
  801e99:	50                   	push   %eax
  801e9a:	e8 1f f3 ff ff       	call   8011be <fd2num>
  801e9f:	89 c2                	mov    %eax,%edx
  801ea1:	83 c4 10             	add    $0x10,%esp
}
  801ea4:	89 d0                	mov    %edx,%eax
  801ea6:	c9                   	leave  
  801ea7:	c3                   	ret    

00801ea8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801eae:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801eb5:	75 4a                	jne    801f01 <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  801eb7:	a1 04 40 80 00       	mov    0x804004,%eax
  801ebc:	8b 40 48             	mov    0x48(%eax),%eax
  801ebf:	83 ec 04             	sub    $0x4,%esp
  801ec2:	6a 07                	push   $0x7
  801ec4:	68 00 f0 bf ee       	push   $0xeebff000
  801ec9:	50                   	push   %eax
  801eca:	e8 69 ed ff ff       	call   800c38 <sys_page_alloc>
  801ecf:	83 c4 10             	add    $0x10,%esp
  801ed2:	85 c0                	test   %eax,%eax
  801ed4:	79 12                	jns    801ee8 <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  801ed6:	50                   	push   %eax
  801ed7:	68 3e 27 80 00       	push   $0x80273e
  801edc:	6a 21                	push   $0x21
  801ede:	68 56 27 80 00       	push   $0x802756
  801ee3:	e8 70 e2 ff ff       	call   800158 <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801ee8:	a1 04 40 80 00       	mov    0x804004,%eax
  801eed:	8b 40 48             	mov    0x48(%eax),%eax
  801ef0:	83 ec 08             	sub    $0x8,%esp
  801ef3:	68 0b 1f 80 00       	push   $0x801f0b
  801ef8:	50                   	push   %eax
  801ef9:	e8 85 ee ff ff       	call   800d83 <sys_env_set_pgfault_upcall>
  801efe:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f01:	8b 45 08             	mov    0x8(%ebp),%eax
  801f04:	a3 00 60 80 00       	mov    %eax,0x806000
  801f09:	c9                   	leave  
  801f0a:	c3                   	ret    

00801f0b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f0b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f0c:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f11:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f13:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  801f16:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  801f19:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  801f1d:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  801f22:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  801f26:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801f28:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  801f29:	83 c4 04             	add    $0x4,%esp
	popfl
  801f2c:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f2d:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  801f2e:	c3                   	ret    

00801f2f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f2f:	55                   	push   %ebp
  801f30:	89 e5                	mov    %esp,%ebp
  801f32:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f35:	89 d0                	mov    %edx,%eax
  801f37:	c1 e8 16             	shr    $0x16,%eax
  801f3a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f41:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f46:	f6 c1 01             	test   $0x1,%cl
  801f49:	74 1d                	je     801f68 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f4b:	c1 ea 0c             	shr    $0xc,%edx
  801f4e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f55:	f6 c2 01             	test   $0x1,%dl
  801f58:	74 0e                	je     801f68 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f5a:	c1 ea 0c             	shr    $0xc,%edx
  801f5d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f64:	ef 
  801f65:	0f b7 c0             	movzwl %ax,%eax
}
  801f68:	5d                   	pop    %ebp
  801f69:	c3                   	ret    
  801f6a:	66 90                	xchg   %ax,%ax
  801f6c:	66 90                	xchg   %ax,%ax
  801f6e:	66 90                	xchg   %ax,%ax

00801f70 <__udivdi3>:
  801f70:	55                   	push   %ebp
  801f71:	57                   	push   %edi
  801f72:	56                   	push   %esi
  801f73:	53                   	push   %ebx
  801f74:	83 ec 1c             	sub    $0x1c,%esp
  801f77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f87:	85 f6                	test   %esi,%esi
  801f89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f8d:	89 ca                	mov    %ecx,%edx
  801f8f:	89 f8                	mov    %edi,%eax
  801f91:	75 3d                	jne    801fd0 <__udivdi3+0x60>
  801f93:	39 cf                	cmp    %ecx,%edi
  801f95:	0f 87 c5 00 00 00    	ja     802060 <__udivdi3+0xf0>
  801f9b:	85 ff                	test   %edi,%edi
  801f9d:	89 fd                	mov    %edi,%ebp
  801f9f:	75 0b                	jne    801fac <__udivdi3+0x3c>
  801fa1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa6:	31 d2                	xor    %edx,%edx
  801fa8:	f7 f7                	div    %edi
  801faa:	89 c5                	mov    %eax,%ebp
  801fac:	89 c8                	mov    %ecx,%eax
  801fae:	31 d2                	xor    %edx,%edx
  801fb0:	f7 f5                	div    %ebp
  801fb2:	89 c1                	mov    %eax,%ecx
  801fb4:	89 d8                	mov    %ebx,%eax
  801fb6:	89 cf                	mov    %ecx,%edi
  801fb8:	f7 f5                	div    %ebp
  801fba:	89 c3                	mov    %eax,%ebx
  801fbc:	89 d8                	mov    %ebx,%eax
  801fbe:	89 fa                	mov    %edi,%edx
  801fc0:	83 c4 1c             	add    $0x1c,%esp
  801fc3:	5b                   	pop    %ebx
  801fc4:	5e                   	pop    %esi
  801fc5:	5f                   	pop    %edi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    
  801fc8:	90                   	nop
  801fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fd0:	39 ce                	cmp    %ecx,%esi
  801fd2:	77 74                	ja     802048 <__udivdi3+0xd8>
  801fd4:	0f bd fe             	bsr    %esi,%edi
  801fd7:	83 f7 1f             	xor    $0x1f,%edi
  801fda:	0f 84 98 00 00 00    	je     802078 <__udivdi3+0x108>
  801fe0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fe5:	89 f9                	mov    %edi,%ecx
  801fe7:	89 c5                	mov    %eax,%ebp
  801fe9:	29 fb                	sub    %edi,%ebx
  801feb:	d3 e6                	shl    %cl,%esi
  801fed:	89 d9                	mov    %ebx,%ecx
  801fef:	d3 ed                	shr    %cl,%ebp
  801ff1:	89 f9                	mov    %edi,%ecx
  801ff3:	d3 e0                	shl    %cl,%eax
  801ff5:	09 ee                	or     %ebp,%esi
  801ff7:	89 d9                	mov    %ebx,%ecx
  801ff9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ffd:	89 d5                	mov    %edx,%ebp
  801fff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802003:	d3 ed                	shr    %cl,%ebp
  802005:	89 f9                	mov    %edi,%ecx
  802007:	d3 e2                	shl    %cl,%edx
  802009:	89 d9                	mov    %ebx,%ecx
  80200b:	d3 e8                	shr    %cl,%eax
  80200d:	09 c2                	or     %eax,%edx
  80200f:	89 d0                	mov    %edx,%eax
  802011:	89 ea                	mov    %ebp,%edx
  802013:	f7 f6                	div    %esi
  802015:	89 d5                	mov    %edx,%ebp
  802017:	89 c3                	mov    %eax,%ebx
  802019:	f7 64 24 0c          	mull   0xc(%esp)
  80201d:	39 d5                	cmp    %edx,%ebp
  80201f:	72 10                	jb     802031 <__udivdi3+0xc1>
  802021:	8b 74 24 08          	mov    0x8(%esp),%esi
  802025:	89 f9                	mov    %edi,%ecx
  802027:	d3 e6                	shl    %cl,%esi
  802029:	39 c6                	cmp    %eax,%esi
  80202b:	73 07                	jae    802034 <__udivdi3+0xc4>
  80202d:	39 d5                	cmp    %edx,%ebp
  80202f:	75 03                	jne    802034 <__udivdi3+0xc4>
  802031:	83 eb 01             	sub    $0x1,%ebx
  802034:	31 ff                	xor    %edi,%edi
  802036:	89 d8                	mov    %ebx,%eax
  802038:	89 fa                	mov    %edi,%edx
  80203a:	83 c4 1c             	add    $0x1c,%esp
  80203d:	5b                   	pop    %ebx
  80203e:	5e                   	pop    %esi
  80203f:	5f                   	pop    %edi
  802040:	5d                   	pop    %ebp
  802041:	c3                   	ret    
  802042:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802048:	31 ff                	xor    %edi,%edi
  80204a:	31 db                	xor    %ebx,%ebx
  80204c:	89 d8                	mov    %ebx,%eax
  80204e:	89 fa                	mov    %edi,%edx
  802050:	83 c4 1c             	add    $0x1c,%esp
  802053:	5b                   	pop    %ebx
  802054:	5e                   	pop    %esi
  802055:	5f                   	pop    %edi
  802056:	5d                   	pop    %ebp
  802057:	c3                   	ret    
  802058:	90                   	nop
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	89 d8                	mov    %ebx,%eax
  802062:	f7 f7                	div    %edi
  802064:	31 ff                	xor    %edi,%edi
  802066:	89 c3                	mov    %eax,%ebx
  802068:	89 d8                	mov    %ebx,%eax
  80206a:	89 fa                	mov    %edi,%edx
  80206c:	83 c4 1c             	add    $0x1c,%esp
  80206f:	5b                   	pop    %ebx
  802070:	5e                   	pop    %esi
  802071:	5f                   	pop    %edi
  802072:	5d                   	pop    %ebp
  802073:	c3                   	ret    
  802074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802078:	39 ce                	cmp    %ecx,%esi
  80207a:	72 0c                	jb     802088 <__udivdi3+0x118>
  80207c:	31 db                	xor    %ebx,%ebx
  80207e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802082:	0f 87 34 ff ff ff    	ja     801fbc <__udivdi3+0x4c>
  802088:	bb 01 00 00 00       	mov    $0x1,%ebx
  80208d:	e9 2a ff ff ff       	jmp    801fbc <__udivdi3+0x4c>
  802092:	66 90                	xchg   %ax,%ax
  802094:	66 90                	xchg   %ax,%ax
  802096:	66 90                	xchg   %ax,%ax
  802098:	66 90                	xchg   %ax,%ax
  80209a:	66 90                	xchg   %ax,%ax
  80209c:	66 90                	xchg   %ax,%ax
  80209e:	66 90                	xchg   %ax,%ax

008020a0 <__umoddi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	53                   	push   %ebx
  8020a4:	83 ec 1c             	sub    $0x1c,%esp
  8020a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020b7:	85 d2                	test   %edx,%edx
  8020b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020c1:	89 f3                	mov    %esi,%ebx
  8020c3:	89 3c 24             	mov    %edi,(%esp)
  8020c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ca:	75 1c                	jne    8020e8 <__umoddi3+0x48>
  8020cc:	39 f7                	cmp    %esi,%edi
  8020ce:	76 50                	jbe    802120 <__umoddi3+0x80>
  8020d0:	89 c8                	mov    %ecx,%eax
  8020d2:	89 f2                	mov    %esi,%edx
  8020d4:	f7 f7                	div    %edi
  8020d6:	89 d0                	mov    %edx,%eax
  8020d8:	31 d2                	xor    %edx,%edx
  8020da:	83 c4 1c             	add    $0x1c,%esp
  8020dd:	5b                   	pop    %ebx
  8020de:	5e                   	pop    %esi
  8020df:	5f                   	pop    %edi
  8020e0:	5d                   	pop    %ebp
  8020e1:	c3                   	ret    
  8020e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020e8:	39 f2                	cmp    %esi,%edx
  8020ea:	89 d0                	mov    %edx,%eax
  8020ec:	77 52                	ja     802140 <__umoddi3+0xa0>
  8020ee:	0f bd ea             	bsr    %edx,%ebp
  8020f1:	83 f5 1f             	xor    $0x1f,%ebp
  8020f4:	75 5a                	jne    802150 <__umoddi3+0xb0>
  8020f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020fa:	0f 82 e0 00 00 00    	jb     8021e0 <__umoddi3+0x140>
  802100:	39 0c 24             	cmp    %ecx,(%esp)
  802103:	0f 86 d7 00 00 00    	jbe    8021e0 <__umoddi3+0x140>
  802109:	8b 44 24 08          	mov    0x8(%esp),%eax
  80210d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802111:	83 c4 1c             	add    $0x1c,%esp
  802114:	5b                   	pop    %ebx
  802115:	5e                   	pop    %esi
  802116:	5f                   	pop    %edi
  802117:	5d                   	pop    %ebp
  802118:	c3                   	ret    
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	85 ff                	test   %edi,%edi
  802122:	89 fd                	mov    %edi,%ebp
  802124:	75 0b                	jne    802131 <__umoddi3+0x91>
  802126:	b8 01 00 00 00       	mov    $0x1,%eax
  80212b:	31 d2                	xor    %edx,%edx
  80212d:	f7 f7                	div    %edi
  80212f:	89 c5                	mov    %eax,%ebp
  802131:	89 f0                	mov    %esi,%eax
  802133:	31 d2                	xor    %edx,%edx
  802135:	f7 f5                	div    %ebp
  802137:	89 c8                	mov    %ecx,%eax
  802139:	f7 f5                	div    %ebp
  80213b:	89 d0                	mov    %edx,%eax
  80213d:	eb 99                	jmp    8020d8 <__umoddi3+0x38>
  80213f:	90                   	nop
  802140:	89 c8                	mov    %ecx,%eax
  802142:	89 f2                	mov    %esi,%edx
  802144:	83 c4 1c             	add    $0x1c,%esp
  802147:	5b                   	pop    %ebx
  802148:	5e                   	pop    %esi
  802149:	5f                   	pop    %edi
  80214a:	5d                   	pop    %ebp
  80214b:	c3                   	ret    
  80214c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802150:	8b 34 24             	mov    (%esp),%esi
  802153:	bf 20 00 00 00       	mov    $0x20,%edi
  802158:	89 e9                	mov    %ebp,%ecx
  80215a:	29 ef                	sub    %ebp,%edi
  80215c:	d3 e0                	shl    %cl,%eax
  80215e:	89 f9                	mov    %edi,%ecx
  802160:	89 f2                	mov    %esi,%edx
  802162:	d3 ea                	shr    %cl,%edx
  802164:	89 e9                	mov    %ebp,%ecx
  802166:	09 c2                	or     %eax,%edx
  802168:	89 d8                	mov    %ebx,%eax
  80216a:	89 14 24             	mov    %edx,(%esp)
  80216d:	89 f2                	mov    %esi,%edx
  80216f:	d3 e2                	shl    %cl,%edx
  802171:	89 f9                	mov    %edi,%ecx
  802173:	89 54 24 04          	mov    %edx,0x4(%esp)
  802177:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80217b:	d3 e8                	shr    %cl,%eax
  80217d:	89 e9                	mov    %ebp,%ecx
  80217f:	89 c6                	mov    %eax,%esi
  802181:	d3 e3                	shl    %cl,%ebx
  802183:	89 f9                	mov    %edi,%ecx
  802185:	89 d0                	mov    %edx,%eax
  802187:	d3 e8                	shr    %cl,%eax
  802189:	89 e9                	mov    %ebp,%ecx
  80218b:	09 d8                	or     %ebx,%eax
  80218d:	89 d3                	mov    %edx,%ebx
  80218f:	89 f2                	mov    %esi,%edx
  802191:	f7 34 24             	divl   (%esp)
  802194:	89 d6                	mov    %edx,%esi
  802196:	d3 e3                	shl    %cl,%ebx
  802198:	f7 64 24 04          	mull   0x4(%esp)
  80219c:	39 d6                	cmp    %edx,%esi
  80219e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021a2:	89 d1                	mov    %edx,%ecx
  8021a4:	89 c3                	mov    %eax,%ebx
  8021a6:	72 08                	jb     8021b0 <__umoddi3+0x110>
  8021a8:	75 11                	jne    8021bb <__umoddi3+0x11b>
  8021aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ae:	73 0b                	jae    8021bb <__umoddi3+0x11b>
  8021b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021b4:	1b 14 24             	sbb    (%esp),%edx
  8021b7:	89 d1                	mov    %edx,%ecx
  8021b9:	89 c3                	mov    %eax,%ebx
  8021bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021bf:	29 da                	sub    %ebx,%edx
  8021c1:	19 ce                	sbb    %ecx,%esi
  8021c3:	89 f9                	mov    %edi,%ecx
  8021c5:	89 f0                	mov    %esi,%eax
  8021c7:	d3 e0                	shl    %cl,%eax
  8021c9:	89 e9                	mov    %ebp,%ecx
  8021cb:	d3 ea                	shr    %cl,%edx
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	d3 ee                	shr    %cl,%esi
  8021d1:	09 d0                	or     %edx,%eax
  8021d3:	89 f2                	mov    %esi,%edx
  8021d5:	83 c4 1c             	add    $0x1c,%esp
  8021d8:	5b                   	pop    %ebx
  8021d9:	5e                   	pop    %esi
  8021da:	5f                   	pop    %edi
  8021db:	5d                   	pop    %ebp
  8021dc:	c3                   	ret    
  8021dd:	8d 76 00             	lea    0x0(%esi),%esi
  8021e0:	29 f9                	sub    %edi,%ecx
  8021e2:	19 d6                	sbb    %edx,%esi
  8021e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ec:	e9 18 ff ff ff       	jmp    802109 <__umoddi3+0x69>
