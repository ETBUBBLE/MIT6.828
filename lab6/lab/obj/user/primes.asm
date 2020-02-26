
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
  800047:	e8 bb 10 00 00       	call   801107 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 08 40 80 00       	mov    0x804008,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 a0 26 80 00       	push   $0x8026a0
  800060:	e8 cc 01 00 00       	call   800231 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 f0 0e 00 00       	call   800f5a <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 ac 26 80 00       	push   $0x8026ac
  800079:	6a 1a                	push   $0x1a
  80007b:	68 b5 26 80 00       	push   $0x8026b5
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
  800094:	e8 6e 10 00 00       	call   801107 <ipc_recv>
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
  8000ab:	e8 c0 10 00 00       	call   801170 <ipc_send>
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
  8000ba:	e8 9b 0e 00 00       	call   800f5a <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 ac 26 80 00       	push   $0x8026ac
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 b5 26 80 00       	push   $0x8026b5
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
  8000eb:	e8 80 10 00 00       	call   801170 <ipc_send>
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
  800115:	a3 08 40 80 00       	mov    %eax,0x804008

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
  800144:	e8 7f 12 00 00       	call   8013c8 <close_all>
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
  800176:	68 d0 26 80 00       	push   $0x8026d0
  80017b:	e8 b1 00 00 00       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 54 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 08 2c 80 00 	movl   $0x802c08,(%esp)
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
  800294:	e8 77 21 00 00       	call   802410 <__udivdi3>
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
  8002d7:	e8 64 22 00 00       	call   802540 <__umoddi3>
  8002dc:	83 c4 14             	add    $0x14,%esp
  8002df:	0f be 80 f3 26 80 00 	movsbl 0x8026f3(%eax),%eax
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
  8003a1:	ff 24 85 40 28 80 00 	jmp    *0x802840(,%eax,4)
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
  800468:	8b 14 85 a0 29 80 00 	mov    0x8029a0(,%eax,4),%edx
  80046f:	85 d2                	test   %edx,%edx
  800471:	75 1b                	jne    80048e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800473:	50                   	push   %eax
  800474:	68 0b 27 80 00       	push   $0x80270b
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
  80048f:	68 9d 2b 80 00       	push   $0x802b9d
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
  8004b9:	b8 04 27 80 00       	mov    $0x802704,%eax
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
  800be1:	68 ff 29 80 00       	push   $0x8029ff
  800be6:	6a 23                	push   $0x23
  800be8:	68 1c 2a 80 00       	push   $0x802a1c
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
  800c62:	68 ff 29 80 00       	push   $0x8029ff
  800c67:	6a 23                	push   $0x23
  800c69:	68 1c 2a 80 00       	push   $0x802a1c
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
  800ca4:	68 ff 29 80 00       	push   $0x8029ff
  800ca9:	6a 23                	push   $0x23
  800cab:	68 1c 2a 80 00       	push   $0x802a1c
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
  800ce6:	68 ff 29 80 00       	push   $0x8029ff
  800ceb:	6a 23                	push   $0x23
  800ced:	68 1c 2a 80 00       	push   $0x802a1c
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
  800d28:	68 ff 29 80 00       	push   $0x8029ff
  800d2d:	6a 23                	push   $0x23
  800d2f:	68 1c 2a 80 00       	push   $0x802a1c
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
  800d6a:	68 ff 29 80 00       	push   $0x8029ff
  800d6f:	6a 23                	push   $0x23
  800d71:	68 1c 2a 80 00       	push   $0x802a1c
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
  800dac:	68 ff 29 80 00       	push   $0x8029ff
  800db1:	6a 23                	push   $0x23
  800db3:	68 1c 2a 80 00       	push   $0x802a1c
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
  800e10:	68 ff 29 80 00       	push   $0x8029ff
  800e15:	6a 23                	push   $0x23
  800e17:	68 1c 2a 80 00       	push   $0x802a1c
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

00800e29 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e34:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e39:	89 d1                	mov    %edx,%ecx
  800e3b:	89 d3                	mov    %edx,%ebx
  800e3d:	89 d7                	mov    %edx,%edi
  800e3f:	89 d6                	mov    %edx,%esi
  800e41:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	57                   	push   %edi
  800e4c:	56                   	push   %esi
  800e4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e53:	b8 10 00 00 00       	mov    $0x10,%eax
  800e58:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5b:	89 cb                	mov    %ecx,%ebx
  800e5d:	89 cf                	mov    %ecx,%edi
  800e5f:	89 ce                	mov    %ecx,%esi
  800e61:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5f                   	pop    %edi
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    

00800e68 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	53                   	push   %ebx
  800e6c:	83 ec 04             	sub    $0x4,%esp
  800e6f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e72:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800e74:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e78:	74 2d                	je     800ea7 <pgfault+0x3f>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800e7a:	89 d8                	mov    %ebx,%eax
  800e7c:	c1 e8 16             	shr    $0x16,%eax
  800e7f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e86:	a8 01                	test   $0x1,%al
  800e88:	74 1d                	je     800ea7 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e8a:	89 d8                	mov    %ebx,%eax
  800e8c:	c1 e8 0c             	shr    $0xc,%eax
  800e8f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800e96:	f6 c2 01             	test   $0x1,%dl
  800e99:	74 0c                	je     800ea7 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e9b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800ea2:	f6 c4 08             	test   $0x8,%ah
  800ea5:	75 14                	jne    800ebb <pgfault+0x53>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
	)) panic("Neither the fault is a write nor copy-on-write page.\n");
  800ea7:	83 ec 04             	sub    $0x4,%esp
  800eaa:	68 2c 2a 80 00       	push   $0x802a2c
  800eaf:	6a 1f                	push   $0x1f
  800eb1:	68 62 2a 80 00       	push   $0x802a62
  800eb6:	e8 9d f2 ff ff       	call   800158 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if((r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W)) < 0){
  800ebb:	83 ec 04             	sub    $0x4,%esp
  800ebe:	6a 07                	push   $0x7
  800ec0:	68 00 f0 7f 00       	push   $0x7ff000
  800ec5:	6a 00                	push   $0x0
  800ec7:	e8 6c fd ff ff       	call   800c38 <sys_page_alloc>
  800ecc:	83 c4 10             	add    $0x10,%esp
  800ecf:	85 c0                	test   %eax,%eax
  800ed1:	79 12                	jns    800ee5 <pgfault+0x7d>
		 panic("sys_page_alloc: %e\n", r);
  800ed3:	50                   	push   %eax
  800ed4:	68 6d 2a 80 00       	push   $0x802a6d
  800ed9:	6a 29                	push   $0x29
  800edb:	68 62 2a 80 00       	push   $0x802a62
  800ee0:	e8 73 f2 ff ff       	call   800158 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800ee5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800eeb:	83 ec 04             	sub    $0x4,%esp
  800eee:	68 00 10 00 00       	push   $0x1000
  800ef3:	53                   	push   %ebx
  800ef4:	68 00 f0 7f 00       	push   $0x7ff000
  800ef9:	e8 31 fb ff ff       	call   800a2f <memcpy>
	if ((r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  800efe:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f05:	53                   	push   %ebx
  800f06:	6a 00                	push   $0x0
  800f08:	68 00 f0 7f 00       	push   $0x7ff000
  800f0d:	6a 00                	push   $0x0
  800f0f:	e8 67 fd ff ff       	call   800c7b <sys_page_map>
  800f14:	83 c4 20             	add    $0x20,%esp
  800f17:	85 c0                	test   %eax,%eax
  800f19:	79 12                	jns    800f2d <pgfault+0xc5>
        panic("sys_page_map: %e\n", r);
  800f1b:	50                   	push   %eax
  800f1c:	68 81 2a 80 00       	push   $0x802a81
  800f21:	6a 2e                	push   $0x2e
  800f23:	68 62 2a 80 00       	push   $0x802a62
  800f28:	e8 2b f2 ff ff       	call   800158 <_panic>
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  800f2d:	83 ec 08             	sub    $0x8,%esp
  800f30:	68 00 f0 7f 00       	push   $0x7ff000
  800f35:	6a 00                	push   $0x0
  800f37:	e8 81 fd ff ff       	call   800cbd <sys_page_unmap>
  800f3c:	83 c4 10             	add    $0x10,%esp
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	79 12                	jns    800f55 <pgfault+0xed>
        panic("sys_page_unmap: %e\n", r);
  800f43:	50                   	push   %eax
  800f44:	68 93 2a 80 00       	push   $0x802a93
  800f49:	6a 30                	push   $0x30
  800f4b:	68 62 2a 80 00       	push   $0x802a62
  800f50:	e8 03 f2 ff ff       	call   800158 <_panic>
	//panic("pgfault not implemented");
}
  800f55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f58:	c9                   	leave  
  800f59:	c3                   	ret    

00800f5a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	57                   	push   %edi
  800f5e:	56                   	push   %esi
  800f5f:	53                   	push   %ebx
  800f60:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	envid_t cenvid;
    unsigned pn;
    int r;
	set_pgfault_handler(pgfault);
  800f63:	68 68 0e 80 00       	push   $0x800e68
  800f68:	e8 e1 13 00 00       	call   80234e <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f6d:	b8 07 00 00 00       	mov    $0x7,%eax
  800f72:	cd 30                	int    $0x30
  800f74:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((cenvid = sys_exofork()) < 0){
  800f77:	83 c4 10             	add    $0x10,%esp
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	79 14                	jns    800f92 <fork+0x38>
		panic("sys_exofork failed");
  800f7e:	83 ec 04             	sub    $0x4,%esp
  800f81:	68 a7 2a 80 00       	push   $0x802aa7
  800f86:	6a 6f                	push   $0x6f
  800f88:	68 62 2a 80 00       	push   $0x802a62
  800f8d:	e8 c6 f1 ff ff       	call   800158 <_panic>
  800f92:	89 c7                	mov    %eax,%edi
		return cenvid;
	}
	if(cenvid>0){
  800f94:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f98:	0f 8e 2b 01 00 00    	jle    8010c9 <fork+0x16f>
  800f9e:	bb 00 08 00 00       	mov    $0x800,%ebx
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
  800fa3:	89 d8                	mov    %ebx,%eax
  800fa5:	c1 e8 0a             	shr    $0xa,%eax
  800fa8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800faf:	a8 01                	test   $0x1,%al
  800fb1:	0f 84 bf 00 00 00    	je     801076 <fork+0x11c>
  800fb7:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fbe:	a8 01                	test   $0x1,%al
  800fc0:	0f 84 b0 00 00 00    	je     801076 <fork+0x11c>
  800fc6:	89 de                	mov    %ebx,%esi
  800fc8:	c1 e6 0c             	shl    $0xc,%esi
{
	int r;

	// LAB 4: Your code here.
	void* vaddr=(void*)(pn*PGSIZE);
	if(uvpt[pn]&PTE_SHARE){
  800fcb:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fd2:	f6 c4 04             	test   $0x4,%ah
  800fd5:	74 29                	je     801000 <fork+0xa6>
		if((r=sys_page_map(0,vaddr,envid,vaddr,uvpt[pn]&PTE_SYSCALL))<0)return r;
  800fd7:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fde:	83 ec 0c             	sub    $0xc,%esp
  800fe1:	25 07 0e 00 00       	and    $0xe07,%eax
  800fe6:	50                   	push   %eax
  800fe7:	56                   	push   %esi
  800fe8:	57                   	push   %edi
  800fe9:	56                   	push   %esi
  800fea:	6a 00                	push   $0x0
  800fec:	e8 8a fc ff ff       	call   800c7b <sys_page_map>
  800ff1:	83 c4 20             	add    $0x20,%esp
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	ba 00 00 00 00       	mov    $0x0,%edx
  800ffb:	0f 4f c2             	cmovg  %edx,%eax
  800ffe:	eb 72                	jmp    801072 <fork+0x118>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  801000:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801007:	a8 02                	test   $0x2,%al
  801009:	75 0c                	jne    801017 <fork+0xbd>
  80100b:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801012:	f6 c4 08             	test   $0x8,%ah
  801015:	74 3f                	je     801056 <fork+0xfc>
		if ((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  801017:	83 ec 0c             	sub    $0xc,%esp
  80101a:	68 05 08 00 00       	push   $0x805
  80101f:	56                   	push   %esi
  801020:	57                   	push   %edi
  801021:	56                   	push   %esi
  801022:	6a 00                	push   $0x0
  801024:	e8 52 fc ff ff       	call   800c7b <sys_page_map>
  801029:	83 c4 20             	add    $0x20,%esp
  80102c:	85 c0                	test   %eax,%eax
  80102e:	0f 88 b1 00 00 00    	js     8010e5 <fork+0x18b>
            return r;
        if ((r = sys_page_map(0, vaddr, 0, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  801034:	83 ec 0c             	sub    $0xc,%esp
  801037:	68 05 08 00 00       	push   $0x805
  80103c:	56                   	push   %esi
  80103d:	6a 00                	push   $0x0
  80103f:	56                   	push   %esi
  801040:	6a 00                	push   $0x0
  801042:	e8 34 fc ff ff       	call   800c7b <sys_page_map>
  801047:	83 c4 20             	add    $0x20,%esp
  80104a:	85 c0                	test   %eax,%eax
  80104c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801051:	0f 4f c1             	cmovg  %ecx,%eax
  801054:	eb 1c                	jmp    801072 <fork+0x118>
            return r;
	}
	else if((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U)) < 0) {
  801056:	83 ec 0c             	sub    $0xc,%esp
  801059:	6a 05                	push   $0x5
  80105b:	56                   	push   %esi
  80105c:	57                   	push   %edi
  80105d:	56                   	push   %esi
  80105e:	6a 00                	push   $0x0
  801060:	e8 16 fc ff ff       	call   800c7b <sys_page_map>
  801065:	83 c4 20             	add    $0x20,%esp
  801068:	85 c0                	test   %eax,%eax
  80106a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80106f:	0f 4f c1             	cmovg  %ecx,%eax
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
  801072:	85 c0                	test   %eax,%eax
  801074:	78 6f                	js     8010e5 <fork+0x18b>
	if ((cenvid = sys_exofork()) < 0){
		panic("sys_exofork failed");
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  801076:	83 c3 01             	add    $0x1,%ebx
  801079:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  80107f:	0f 85 1e ff ff ff    	jne    800fa3 <fork+0x49>
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
                    return r;
		}
		if ((r = sys_page_alloc(cenvid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  801085:	83 ec 04             	sub    $0x4,%esp
  801088:	6a 07                	push   $0x7
  80108a:	68 00 f0 bf ee       	push   $0xeebff000
  80108f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801092:	57                   	push   %edi
  801093:	e8 a0 fb ff ff       	call   800c38 <sys_page_alloc>
  801098:	83 c4 10             	add    $0x10,%esp
  80109b:	85 c0                	test   %eax,%eax
  80109d:	78 46                	js     8010e5 <fork+0x18b>
            return r;
		extern void _pgfault_upcall(void);
		if ((r = sys_env_set_pgfault_upcall(cenvid, _pgfault_upcall)) < 0)
  80109f:	83 ec 08             	sub    $0x8,%esp
  8010a2:	68 b1 23 80 00       	push   $0x8023b1
  8010a7:	57                   	push   %edi
  8010a8:	e8 d6 fc ff ff       	call   800d83 <sys_env_set_pgfault_upcall>
  8010ad:	83 c4 10             	add    $0x10,%esp
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	78 31                	js     8010e5 <fork+0x18b>
            return r;
		if ((r = sys_env_set_status(cenvid, ENV_RUNNABLE)) < 0)
  8010b4:	83 ec 08             	sub    $0x8,%esp
  8010b7:	6a 02                	push   $0x2
  8010b9:	57                   	push   %edi
  8010ba:	e8 40 fc ff ff       	call   800cff <sys_env_set_status>
  8010bf:	83 c4 10             	add    $0x10,%esp
            return r;
        return cenvid;
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	0f 49 c7             	cmovns %edi,%eax
  8010c7:	eb 1c                	jmp    8010e5 <fork+0x18b>
	}
	else {
		thisenv = &envs[ENVX(sys_getenvid())];
  8010c9:	e8 2c fb ff ff       	call   800bfa <sys_getenvid>
  8010ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010db:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  8010e0:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//panic("fork not implemented");
	
}
  8010e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e8:	5b                   	pop    %ebx
  8010e9:	5e                   	pop    %esi
  8010ea:	5f                   	pop    %edi
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <sfork>:

// Challenge!
int
sfork(void)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010f3:	68 ba 2a 80 00       	push   $0x802aba
  8010f8:	68 8d 00 00 00       	push   $0x8d
  8010fd:	68 62 2a 80 00       	push   $0x802a62
  801102:	e8 51 f0 ff ff       	call   800158 <_panic>

00801107 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	56                   	push   %esi
  80110b:	53                   	push   %ebx
  80110c:	8b 75 08             	mov    0x8(%ebp),%esi
  80110f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801112:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801115:	85 c0                	test   %eax,%eax
  801117:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80111c:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  80111f:	83 ec 0c             	sub    $0xc,%esp
  801122:	50                   	push   %eax
  801123:	e8 c0 fc ff ff       	call   800de8 <sys_ipc_recv>
  801128:	83 c4 10             	add    $0x10,%esp
  80112b:	85 c0                	test   %eax,%eax
  80112d:	79 16                	jns    801145 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  80112f:	85 f6                	test   %esi,%esi
  801131:	74 06                	je     801139 <ipc_recv+0x32>
            *from_env_store = 0;
  801133:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801139:	85 db                	test   %ebx,%ebx
  80113b:	74 2c                	je     801169 <ipc_recv+0x62>
            *perm_store = 0;
  80113d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801143:	eb 24                	jmp    801169 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801145:	85 f6                	test   %esi,%esi
  801147:	74 0a                	je     801153 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801149:	a1 08 40 80 00       	mov    0x804008,%eax
  80114e:	8b 40 74             	mov    0x74(%eax),%eax
  801151:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801153:	85 db                	test   %ebx,%ebx
  801155:	74 0a                	je     801161 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801157:	a1 08 40 80 00       	mov    0x804008,%eax
  80115c:	8b 40 78             	mov    0x78(%eax),%eax
  80115f:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801161:	a1 08 40 80 00       	mov    0x804008,%eax
  801166:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801169:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80116c:	5b                   	pop    %ebx
  80116d:	5e                   	pop    %esi
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    

00801170 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	57                   	push   %edi
  801174:	56                   	push   %esi
  801175:	53                   	push   %ebx
  801176:	83 ec 0c             	sub    $0xc,%esp
  801179:	8b 7d 08             	mov    0x8(%ebp),%edi
  80117c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80117f:	8b 45 10             	mov    0x10(%ebp),%eax
  801182:	85 c0                	test   %eax,%eax
  801184:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801189:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80118c:	eb 1c                	jmp    8011aa <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  80118e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801191:	74 12                	je     8011a5 <ipc_send+0x35>
  801193:	50                   	push   %eax
  801194:	68 d0 2a 80 00       	push   $0x802ad0
  801199:	6a 3b                	push   $0x3b
  80119b:	68 e6 2a 80 00       	push   $0x802ae6
  8011a0:	e8 b3 ef ff ff       	call   800158 <_panic>
		sys_yield();
  8011a5:	e8 6f fa ff ff       	call   800c19 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  8011aa:	ff 75 14             	pushl  0x14(%ebp)
  8011ad:	53                   	push   %ebx
  8011ae:	56                   	push   %esi
  8011af:	57                   	push   %edi
  8011b0:	e8 10 fc ff ff       	call   800dc5 <sys_ipc_try_send>
  8011b5:	83 c4 10             	add    $0x10,%esp
  8011b8:	85 c0                	test   %eax,%eax
  8011ba:	78 d2                	js     80118e <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  8011bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bf:	5b                   	pop    %ebx
  8011c0:	5e                   	pop    %esi
  8011c1:	5f                   	pop    %edi
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    

008011c4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011ca:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011cf:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011d2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011d8:	8b 52 50             	mov    0x50(%edx),%edx
  8011db:	39 ca                	cmp    %ecx,%edx
  8011dd:	75 0d                	jne    8011ec <ipc_find_env+0x28>
			return envs[i].env_id;
  8011df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011e7:	8b 40 48             	mov    0x48(%eax),%eax
  8011ea:	eb 0f                	jmp    8011fb <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011ec:	83 c0 01             	add    $0x1,%eax
  8011ef:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011f4:	75 d9                	jne    8011cf <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011fb:	5d                   	pop    %ebp
  8011fc:	c3                   	ret    

008011fd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801200:	8b 45 08             	mov    0x8(%ebp),%eax
  801203:	05 00 00 00 30       	add    $0x30000000,%eax
  801208:	c1 e8 0c             	shr    $0xc,%eax
}
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    

0080120d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801210:	8b 45 08             	mov    0x8(%ebp),%eax
  801213:	05 00 00 00 30       	add    $0x30000000,%eax
  801218:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80121d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801222:	5d                   	pop    %ebp
  801223:	c3                   	ret    

00801224 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80122a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80122f:	89 c2                	mov    %eax,%edx
  801231:	c1 ea 16             	shr    $0x16,%edx
  801234:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80123b:	f6 c2 01             	test   $0x1,%dl
  80123e:	74 11                	je     801251 <fd_alloc+0x2d>
  801240:	89 c2                	mov    %eax,%edx
  801242:	c1 ea 0c             	shr    $0xc,%edx
  801245:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80124c:	f6 c2 01             	test   $0x1,%dl
  80124f:	75 09                	jne    80125a <fd_alloc+0x36>
			*fd_store = fd;
  801251:	89 01                	mov    %eax,(%ecx)
			return 0;
  801253:	b8 00 00 00 00       	mov    $0x0,%eax
  801258:	eb 17                	jmp    801271 <fd_alloc+0x4d>
  80125a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80125f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801264:	75 c9                	jne    80122f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801266:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80126c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    

00801273 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801279:	83 f8 1f             	cmp    $0x1f,%eax
  80127c:	77 36                	ja     8012b4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80127e:	c1 e0 0c             	shl    $0xc,%eax
  801281:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801286:	89 c2                	mov    %eax,%edx
  801288:	c1 ea 16             	shr    $0x16,%edx
  80128b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801292:	f6 c2 01             	test   $0x1,%dl
  801295:	74 24                	je     8012bb <fd_lookup+0x48>
  801297:	89 c2                	mov    %eax,%edx
  801299:	c1 ea 0c             	shr    $0xc,%edx
  80129c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012a3:	f6 c2 01             	test   $0x1,%dl
  8012a6:	74 1a                	je     8012c2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ab:	89 02                	mov    %eax,(%edx)
	return 0;
  8012ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b2:	eb 13                	jmp    8012c7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b9:	eb 0c                	jmp    8012c7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c0:	eb 05                	jmp    8012c7 <fd_lookup+0x54>
  8012c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012c7:	5d                   	pop    %ebp
  8012c8:	c3                   	ret    

008012c9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	83 ec 08             	sub    $0x8,%esp
  8012cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d2:	ba 70 2b 80 00       	mov    $0x802b70,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012d7:	eb 13                	jmp    8012ec <dev_lookup+0x23>
  8012d9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012dc:	39 08                	cmp    %ecx,(%eax)
  8012de:	75 0c                	jne    8012ec <dev_lookup+0x23>
			*dev = devtab[i];
  8012e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ea:	eb 2e                	jmp    80131a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012ec:	8b 02                	mov    (%edx),%eax
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	75 e7                	jne    8012d9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012f2:	a1 08 40 80 00       	mov    0x804008,%eax
  8012f7:	8b 40 48             	mov    0x48(%eax),%eax
  8012fa:	83 ec 04             	sub    $0x4,%esp
  8012fd:	51                   	push   %ecx
  8012fe:	50                   	push   %eax
  8012ff:	68 f0 2a 80 00       	push   $0x802af0
  801304:	e8 28 ef ff ff       	call   800231 <cprintf>
	*dev = 0;
  801309:	8b 45 0c             	mov    0xc(%ebp),%eax
  80130c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801312:	83 c4 10             	add    $0x10,%esp
  801315:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80131a:	c9                   	leave  
  80131b:	c3                   	ret    

0080131c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	56                   	push   %esi
  801320:	53                   	push   %ebx
  801321:	83 ec 10             	sub    $0x10,%esp
  801324:	8b 75 08             	mov    0x8(%ebp),%esi
  801327:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80132a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132d:	50                   	push   %eax
  80132e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801334:	c1 e8 0c             	shr    $0xc,%eax
  801337:	50                   	push   %eax
  801338:	e8 36 ff ff ff       	call   801273 <fd_lookup>
  80133d:	83 c4 08             	add    $0x8,%esp
  801340:	85 c0                	test   %eax,%eax
  801342:	78 05                	js     801349 <fd_close+0x2d>
	    || fd != fd2)
  801344:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801347:	74 0c                	je     801355 <fd_close+0x39>
		return (must_exist ? r : 0);
  801349:	84 db                	test   %bl,%bl
  80134b:	ba 00 00 00 00       	mov    $0x0,%edx
  801350:	0f 44 c2             	cmove  %edx,%eax
  801353:	eb 41                	jmp    801396 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801355:	83 ec 08             	sub    $0x8,%esp
  801358:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80135b:	50                   	push   %eax
  80135c:	ff 36                	pushl  (%esi)
  80135e:	e8 66 ff ff ff       	call   8012c9 <dev_lookup>
  801363:	89 c3                	mov    %eax,%ebx
  801365:	83 c4 10             	add    $0x10,%esp
  801368:	85 c0                	test   %eax,%eax
  80136a:	78 1a                	js     801386 <fd_close+0x6a>
		if (dev->dev_close)
  80136c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801372:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801377:	85 c0                	test   %eax,%eax
  801379:	74 0b                	je     801386 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80137b:	83 ec 0c             	sub    $0xc,%esp
  80137e:	56                   	push   %esi
  80137f:	ff d0                	call   *%eax
  801381:	89 c3                	mov    %eax,%ebx
  801383:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801386:	83 ec 08             	sub    $0x8,%esp
  801389:	56                   	push   %esi
  80138a:	6a 00                	push   $0x0
  80138c:	e8 2c f9 ff ff       	call   800cbd <sys_page_unmap>
	return r;
  801391:	83 c4 10             	add    $0x10,%esp
  801394:	89 d8                	mov    %ebx,%eax
}
  801396:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801399:	5b                   	pop    %ebx
  80139a:	5e                   	pop    %esi
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    

0080139d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a6:	50                   	push   %eax
  8013a7:	ff 75 08             	pushl  0x8(%ebp)
  8013aa:	e8 c4 fe ff ff       	call   801273 <fd_lookup>
  8013af:	83 c4 08             	add    $0x8,%esp
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	78 10                	js     8013c6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013b6:	83 ec 08             	sub    $0x8,%esp
  8013b9:	6a 01                	push   $0x1
  8013bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8013be:	e8 59 ff ff ff       	call   80131c <fd_close>
  8013c3:	83 c4 10             	add    $0x10,%esp
}
  8013c6:	c9                   	leave  
  8013c7:	c3                   	ret    

008013c8 <close_all>:

void
close_all(void)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	53                   	push   %ebx
  8013cc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013cf:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013d4:	83 ec 0c             	sub    $0xc,%esp
  8013d7:	53                   	push   %ebx
  8013d8:	e8 c0 ff ff ff       	call   80139d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013dd:	83 c3 01             	add    $0x1,%ebx
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	83 fb 20             	cmp    $0x20,%ebx
  8013e6:	75 ec                	jne    8013d4 <close_all+0xc>
		close(i);
}
  8013e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013eb:	c9                   	leave  
  8013ec:	c3                   	ret    

008013ed <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	57                   	push   %edi
  8013f1:	56                   	push   %esi
  8013f2:	53                   	push   %ebx
  8013f3:	83 ec 2c             	sub    $0x2c,%esp
  8013f6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013f9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013fc:	50                   	push   %eax
  8013fd:	ff 75 08             	pushl  0x8(%ebp)
  801400:	e8 6e fe ff ff       	call   801273 <fd_lookup>
  801405:	83 c4 08             	add    $0x8,%esp
  801408:	85 c0                	test   %eax,%eax
  80140a:	0f 88 c1 00 00 00    	js     8014d1 <dup+0xe4>
		return r;
	close(newfdnum);
  801410:	83 ec 0c             	sub    $0xc,%esp
  801413:	56                   	push   %esi
  801414:	e8 84 ff ff ff       	call   80139d <close>

	newfd = INDEX2FD(newfdnum);
  801419:	89 f3                	mov    %esi,%ebx
  80141b:	c1 e3 0c             	shl    $0xc,%ebx
  80141e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801424:	83 c4 04             	add    $0x4,%esp
  801427:	ff 75 e4             	pushl  -0x1c(%ebp)
  80142a:	e8 de fd ff ff       	call   80120d <fd2data>
  80142f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801431:	89 1c 24             	mov    %ebx,(%esp)
  801434:	e8 d4 fd ff ff       	call   80120d <fd2data>
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80143f:	89 f8                	mov    %edi,%eax
  801441:	c1 e8 16             	shr    $0x16,%eax
  801444:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80144b:	a8 01                	test   $0x1,%al
  80144d:	74 37                	je     801486 <dup+0x99>
  80144f:	89 f8                	mov    %edi,%eax
  801451:	c1 e8 0c             	shr    $0xc,%eax
  801454:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80145b:	f6 c2 01             	test   $0x1,%dl
  80145e:	74 26                	je     801486 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801460:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801467:	83 ec 0c             	sub    $0xc,%esp
  80146a:	25 07 0e 00 00       	and    $0xe07,%eax
  80146f:	50                   	push   %eax
  801470:	ff 75 d4             	pushl  -0x2c(%ebp)
  801473:	6a 00                	push   $0x0
  801475:	57                   	push   %edi
  801476:	6a 00                	push   $0x0
  801478:	e8 fe f7 ff ff       	call   800c7b <sys_page_map>
  80147d:	89 c7                	mov    %eax,%edi
  80147f:	83 c4 20             	add    $0x20,%esp
  801482:	85 c0                	test   %eax,%eax
  801484:	78 2e                	js     8014b4 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801486:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801489:	89 d0                	mov    %edx,%eax
  80148b:	c1 e8 0c             	shr    $0xc,%eax
  80148e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801495:	83 ec 0c             	sub    $0xc,%esp
  801498:	25 07 0e 00 00       	and    $0xe07,%eax
  80149d:	50                   	push   %eax
  80149e:	53                   	push   %ebx
  80149f:	6a 00                	push   $0x0
  8014a1:	52                   	push   %edx
  8014a2:	6a 00                	push   $0x0
  8014a4:	e8 d2 f7 ff ff       	call   800c7b <sys_page_map>
  8014a9:	89 c7                	mov    %eax,%edi
  8014ab:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014ae:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014b0:	85 ff                	test   %edi,%edi
  8014b2:	79 1d                	jns    8014d1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014b4:	83 ec 08             	sub    $0x8,%esp
  8014b7:	53                   	push   %ebx
  8014b8:	6a 00                	push   $0x0
  8014ba:	e8 fe f7 ff ff       	call   800cbd <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014bf:	83 c4 08             	add    $0x8,%esp
  8014c2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014c5:	6a 00                	push   $0x0
  8014c7:	e8 f1 f7 ff ff       	call   800cbd <sys_page_unmap>
	return r;
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	89 f8                	mov    %edi,%eax
}
  8014d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014d4:	5b                   	pop    %ebx
  8014d5:	5e                   	pop    %esi
  8014d6:	5f                   	pop    %edi
  8014d7:	5d                   	pop    %ebp
  8014d8:	c3                   	ret    

008014d9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014d9:	55                   	push   %ebp
  8014da:	89 e5                	mov    %esp,%ebp
  8014dc:	53                   	push   %ebx
  8014dd:	83 ec 14             	sub    $0x14,%esp
  8014e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e6:	50                   	push   %eax
  8014e7:	53                   	push   %ebx
  8014e8:	e8 86 fd ff ff       	call   801273 <fd_lookup>
  8014ed:	83 c4 08             	add    $0x8,%esp
  8014f0:	89 c2                	mov    %eax,%edx
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	78 6d                	js     801563 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f6:	83 ec 08             	sub    $0x8,%esp
  8014f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fc:	50                   	push   %eax
  8014fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801500:	ff 30                	pushl  (%eax)
  801502:	e8 c2 fd ff ff       	call   8012c9 <dev_lookup>
  801507:	83 c4 10             	add    $0x10,%esp
  80150a:	85 c0                	test   %eax,%eax
  80150c:	78 4c                	js     80155a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80150e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801511:	8b 42 08             	mov    0x8(%edx),%eax
  801514:	83 e0 03             	and    $0x3,%eax
  801517:	83 f8 01             	cmp    $0x1,%eax
  80151a:	75 21                	jne    80153d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80151c:	a1 08 40 80 00       	mov    0x804008,%eax
  801521:	8b 40 48             	mov    0x48(%eax),%eax
  801524:	83 ec 04             	sub    $0x4,%esp
  801527:	53                   	push   %ebx
  801528:	50                   	push   %eax
  801529:	68 34 2b 80 00       	push   $0x802b34
  80152e:	e8 fe ec ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80153b:	eb 26                	jmp    801563 <read+0x8a>
	}
	if (!dev->dev_read)
  80153d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801540:	8b 40 08             	mov    0x8(%eax),%eax
  801543:	85 c0                	test   %eax,%eax
  801545:	74 17                	je     80155e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801547:	83 ec 04             	sub    $0x4,%esp
  80154a:	ff 75 10             	pushl  0x10(%ebp)
  80154d:	ff 75 0c             	pushl  0xc(%ebp)
  801550:	52                   	push   %edx
  801551:	ff d0                	call   *%eax
  801553:	89 c2                	mov    %eax,%edx
  801555:	83 c4 10             	add    $0x10,%esp
  801558:	eb 09                	jmp    801563 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155a:	89 c2                	mov    %eax,%edx
  80155c:	eb 05                	jmp    801563 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80155e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801563:	89 d0                	mov    %edx,%eax
  801565:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801568:	c9                   	leave  
  801569:	c3                   	ret    

0080156a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	57                   	push   %edi
  80156e:	56                   	push   %esi
  80156f:	53                   	push   %ebx
  801570:	83 ec 0c             	sub    $0xc,%esp
  801573:	8b 7d 08             	mov    0x8(%ebp),%edi
  801576:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801579:	bb 00 00 00 00       	mov    $0x0,%ebx
  80157e:	eb 21                	jmp    8015a1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801580:	83 ec 04             	sub    $0x4,%esp
  801583:	89 f0                	mov    %esi,%eax
  801585:	29 d8                	sub    %ebx,%eax
  801587:	50                   	push   %eax
  801588:	89 d8                	mov    %ebx,%eax
  80158a:	03 45 0c             	add    0xc(%ebp),%eax
  80158d:	50                   	push   %eax
  80158e:	57                   	push   %edi
  80158f:	e8 45 ff ff ff       	call   8014d9 <read>
		if (m < 0)
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	85 c0                	test   %eax,%eax
  801599:	78 10                	js     8015ab <readn+0x41>
			return m;
		if (m == 0)
  80159b:	85 c0                	test   %eax,%eax
  80159d:	74 0a                	je     8015a9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80159f:	01 c3                	add    %eax,%ebx
  8015a1:	39 f3                	cmp    %esi,%ebx
  8015a3:	72 db                	jb     801580 <readn+0x16>
  8015a5:	89 d8                	mov    %ebx,%eax
  8015a7:	eb 02                	jmp    8015ab <readn+0x41>
  8015a9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ae:	5b                   	pop    %ebx
  8015af:	5e                   	pop    %esi
  8015b0:	5f                   	pop    %edi
  8015b1:	5d                   	pop    %ebp
  8015b2:	c3                   	ret    

008015b3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
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
  8015c2:	e8 ac fc ff ff       	call   801273 <fd_lookup>
  8015c7:	83 c4 08             	add    $0x8,%esp
  8015ca:	89 c2                	mov    %eax,%edx
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	78 68                	js     801638 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d0:	83 ec 08             	sub    $0x8,%esp
  8015d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d6:	50                   	push   %eax
  8015d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015da:	ff 30                	pushl  (%eax)
  8015dc:	e8 e8 fc ff ff       	call   8012c9 <dev_lookup>
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 47                	js     80162f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015eb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ef:	75 21                	jne    801612 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f1:	a1 08 40 80 00       	mov    0x804008,%eax
  8015f6:	8b 40 48             	mov    0x48(%eax),%eax
  8015f9:	83 ec 04             	sub    $0x4,%esp
  8015fc:	53                   	push   %ebx
  8015fd:	50                   	push   %eax
  8015fe:	68 50 2b 80 00       	push   $0x802b50
  801603:	e8 29 ec ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801610:	eb 26                	jmp    801638 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801612:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801615:	8b 52 0c             	mov    0xc(%edx),%edx
  801618:	85 d2                	test   %edx,%edx
  80161a:	74 17                	je     801633 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80161c:	83 ec 04             	sub    $0x4,%esp
  80161f:	ff 75 10             	pushl  0x10(%ebp)
  801622:	ff 75 0c             	pushl  0xc(%ebp)
  801625:	50                   	push   %eax
  801626:	ff d2                	call   *%edx
  801628:	89 c2                	mov    %eax,%edx
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	eb 09                	jmp    801638 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162f:	89 c2                	mov    %eax,%edx
  801631:	eb 05                	jmp    801638 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801633:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801638:	89 d0                	mov    %edx,%eax
  80163a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163d:	c9                   	leave  
  80163e:	c3                   	ret    

0080163f <seek>:

int
seek(int fdnum, off_t offset)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801645:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801648:	50                   	push   %eax
  801649:	ff 75 08             	pushl  0x8(%ebp)
  80164c:	e8 22 fc ff ff       	call   801273 <fd_lookup>
  801651:	83 c4 08             	add    $0x8,%esp
  801654:	85 c0                	test   %eax,%eax
  801656:	78 0e                	js     801666 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801658:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80165b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80165e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801661:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801666:	c9                   	leave  
  801667:	c3                   	ret    

00801668 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801668:	55                   	push   %ebp
  801669:	89 e5                	mov    %esp,%ebp
  80166b:	53                   	push   %ebx
  80166c:	83 ec 14             	sub    $0x14,%esp
  80166f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801672:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801675:	50                   	push   %eax
  801676:	53                   	push   %ebx
  801677:	e8 f7 fb ff ff       	call   801273 <fd_lookup>
  80167c:	83 c4 08             	add    $0x8,%esp
  80167f:	89 c2                	mov    %eax,%edx
  801681:	85 c0                	test   %eax,%eax
  801683:	78 65                	js     8016ea <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801685:	83 ec 08             	sub    $0x8,%esp
  801688:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80168b:	50                   	push   %eax
  80168c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168f:	ff 30                	pushl  (%eax)
  801691:	e8 33 fc ff ff       	call   8012c9 <dev_lookup>
  801696:	83 c4 10             	add    $0x10,%esp
  801699:	85 c0                	test   %eax,%eax
  80169b:	78 44                	js     8016e1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80169d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016a4:	75 21                	jne    8016c7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016a6:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016ab:	8b 40 48             	mov    0x48(%eax),%eax
  8016ae:	83 ec 04             	sub    $0x4,%esp
  8016b1:	53                   	push   %ebx
  8016b2:	50                   	push   %eax
  8016b3:	68 10 2b 80 00       	push   $0x802b10
  8016b8:	e8 74 eb ff ff       	call   800231 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016c5:	eb 23                	jmp    8016ea <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ca:	8b 52 18             	mov    0x18(%edx),%edx
  8016cd:	85 d2                	test   %edx,%edx
  8016cf:	74 14                	je     8016e5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016d1:	83 ec 08             	sub    $0x8,%esp
  8016d4:	ff 75 0c             	pushl  0xc(%ebp)
  8016d7:	50                   	push   %eax
  8016d8:	ff d2                	call   *%edx
  8016da:	89 c2                	mov    %eax,%edx
  8016dc:	83 c4 10             	add    $0x10,%esp
  8016df:	eb 09                	jmp    8016ea <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e1:	89 c2                	mov    %eax,%edx
  8016e3:	eb 05                	jmp    8016ea <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016e5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016ea:	89 d0                	mov    %edx,%eax
  8016ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ef:	c9                   	leave  
  8016f0:	c3                   	ret    

008016f1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	53                   	push   %ebx
  8016f5:	83 ec 14             	sub    $0x14,%esp
  8016f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016fe:	50                   	push   %eax
  8016ff:	ff 75 08             	pushl  0x8(%ebp)
  801702:	e8 6c fb ff ff       	call   801273 <fd_lookup>
  801707:	83 c4 08             	add    $0x8,%esp
  80170a:	89 c2                	mov    %eax,%edx
  80170c:	85 c0                	test   %eax,%eax
  80170e:	78 58                	js     801768 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801710:	83 ec 08             	sub    $0x8,%esp
  801713:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801716:	50                   	push   %eax
  801717:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171a:	ff 30                	pushl  (%eax)
  80171c:	e8 a8 fb ff ff       	call   8012c9 <dev_lookup>
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	85 c0                	test   %eax,%eax
  801726:	78 37                	js     80175f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801728:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80172b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80172f:	74 32                	je     801763 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801731:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801734:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80173b:	00 00 00 
	stat->st_isdir = 0;
  80173e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801745:	00 00 00 
	stat->st_dev = dev;
  801748:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80174e:	83 ec 08             	sub    $0x8,%esp
  801751:	53                   	push   %ebx
  801752:	ff 75 f0             	pushl  -0x10(%ebp)
  801755:	ff 50 14             	call   *0x14(%eax)
  801758:	89 c2                	mov    %eax,%edx
  80175a:	83 c4 10             	add    $0x10,%esp
  80175d:	eb 09                	jmp    801768 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175f:	89 c2                	mov    %eax,%edx
  801761:	eb 05                	jmp    801768 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801763:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801768:	89 d0                	mov    %edx,%eax
  80176a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176d:	c9                   	leave  
  80176e:	c3                   	ret    

0080176f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	56                   	push   %esi
  801773:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801774:	83 ec 08             	sub    $0x8,%esp
  801777:	6a 00                	push   $0x0
  801779:	ff 75 08             	pushl  0x8(%ebp)
  80177c:	e8 e3 01 00 00       	call   801964 <open>
  801781:	89 c3                	mov    %eax,%ebx
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	85 c0                	test   %eax,%eax
  801788:	78 1b                	js     8017a5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80178a:	83 ec 08             	sub    $0x8,%esp
  80178d:	ff 75 0c             	pushl  0xc(%ebp)
  801790:	50                   	push   %eax
  801791:	e8 5b ff ff ff       	call   8016f1 <fstat>
  801796:	89 c6                	mov    %eax,%esi
	close(fd);
  801798:	89 1c 24             	mov    %ebx,(%esp)
  80179b:	e8 fd fb ff ff       	call   80139d <close>
	return r;
  8017a0:	83 c4 10             	add    $0x10,%esp
  8017a3:	89 f0                	mov    %esi,%eax
}
  8017a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a8:	5b                   	pop    %ebx
  8017a9:	5e                   	pop    %esi
  8017aa:	5d                   	pop    %ebp
  8017ab:	c3                   	ret    

008017ac <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	56                   	push   %esi
  8017b0:	53                   	push   %ebx
  8017b1:	89 c6                	mov    %eax,%esi
  8017b3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017b5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017bc:	75 12                	jne    8017d0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017be:	83 ec 0c             	sub    $0xc,%esp
  8017c1:	6a 01                	push   $0x1
  8017c3:	e8 fc f9 ff ff       	call   8011c4 <ipc_find_env>
  8017c8:	a3 00 40 80 00       	mov    %eax,0x804000
  8017cd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017d0:	6a 07                	push   $0x7
  8017d2:	68 00 50 80 00       	push   $0x805000
  8017d7:	56                   	push   %esi
  8017d8:	ff 35 00 40 80 00    	pushl  0x804000
  8017de:	e8 8d f9 ff ff       	call   801170 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017e3:	83 c4 0c             	add    $0xc,%esp
  8017e6:	6a 00                	push   $0x0
  8017e8:	53                   	push   %ebx
  8017e9:	6a 00                	push   $0x0
  8017eb:	e8 17 f9 ff ff       	call   801107 <ipc_recv>
}
  8017f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f3:	5b                   	pop    %ebx
  8017f4:	5e                   	pop    %esi
  8017f5:	5d                   	pop    %ebp
  8017f6:	c3                   	ret    

008017f7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801800:	8b 40 0c             	mov    0xc(%eax),%eax
  801803:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801808:	8b 45 0c             	mov    0xc(%ebp),%eax
  80180b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801810:	ba 00 00 00 00       	mov    $0x0,%edx
  801815:	b8 02 00 00 00       	mov    $0x2,%eax
  80181a:	e8 8d ff ff ff       	call   8017ac <fsipc>
}
  80181f:	c9                   	leave  
  801820:	c3                   	ret    

00801821 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801827:	8b 45 08             	mov    0x8(%ebp),%eax
  80182a:	8b 40 0c             	mov    0xc(%eax),%eax
  80182d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801832:	ba 00 00 00 00       	mov    $0x0,%edx
  801837:	b8 06 00 00 00       	mov    $0x6,%eax
  80183c:	e8 6b ff ff ff       	call   8017ac <fsipc>
}
  801841:	c9                   	leave  
  801842:	c3                   	ret    

00801843 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	53                   	push   %ebx
  801847:	83 ec 04             	sub    $0x4,%esp
  80184a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80184d:	8b 45 08             	mov    0x8(%ebp),%eax
  801850:	8b 40 0c             	mov    0xc(%eax),%eax
  801853:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801858:	ba 00 00 00 00       	mov    $0x0,%edx
  80185d:	b8 05 00 00 00       	mov    $0x5,%eax
  801862:	e8 45 ff ff ff       	call   8017ac <fsipc>
  801867:	85 c0                	test   %eax,%eax
  801869:	78 2c                	js     801897 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80186b:	83 ec 08             	sub    $0x8,%esp
  80186e:	68 00 50 80 00       	push   $0x805000
  801873:	53                   	push   %ebx
  801874:	e8 bc ef ff ff       	call   800835 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801879:	a1 80 50 80 00       	mov    0x805080,%eax
  80187e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801884:	a1 84 50 80 00       	mov    0x805084,%eax
  801889:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80188f:	83 c4 10             	add    $0x10,%esp
  801892:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801897:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80189a:	c9                   	leave  
  80189b:	c3                   	ret    

0080189c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	83 ec 0c             	sub    $0xc,%esp
  8018a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8018a5:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018aa:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018af:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8018b5:	8b 52 0c             	mov    0xc(%edx),%edx
  8018b8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018be:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018c3:	50                   	push   %eax
  8018c4:	ff 75 0c             	pushl  0xc(%ebp)
  8018c7:	68 08 50 80 00       	push   $0x805008
  8018cc:	e8 f6 f0 ff ff       	call   8009c7 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d6:	b8 04 00 00 00       	mov    $0x4,%eax
  8018db:	e8 cc fe ff ff       	call   8017ac <fsipc>
	//panic("devfile_write not implemented");
}
  8018e0:	c9                   	leave  
  8018e1:	c3                   	ret    

008018e2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
  8018e5:	56                   	push   %esi
  8018e6:	53                   	push   %ebx
  8018e7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018f5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801900:	b8 03 00 00 00       	mov    $0x3,%eax
  801905:	e8 a2 fe ff ff       	call   8017ac <fsipc>
  80190a:	89 c3                	mov    %eax,%ebx
  80190c:	85 c0                	test   %eax,%eax
  80190e:	78 4b                	js     80195b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801910:	39 c6                	cmp    %eax,%esi
  801912:	73 16                	jae    80192a <devfile_read+0x48>
  801914:	68 84 2b 80 00       	push   $0x802b84
  801919:	68 8b 2b 80 00       	push   $0x802b8b
  80191e:	6a 7c                	push   $0x7c
  801920:	68 a0 2b 80 00       	push   $0x802ba0
  801925:	e8 2e e8 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  80192a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80192f:	7e 16                	jle    801947 <devfile_read+0x65>
  801931:	68 ab 2b 80 00       	push   $0x802bab
  801936:	68 8b 2b 80 00       	push   $0x802b8b
  80193b:	6a 7d                	push   $0x7d
  80193d:	68 a0 2b 80 00       	push   $0x802ba0
  801942:	e8 11 e8 ff ff       	call   800158 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801947:	83 ec 04             	sub    $0x4,%esp
  80194a:	50                   	push   %eax
  80194b:	68 00 50 80 00       	push   $0x805000
  801950:	ff 75 0c             	pushl  0xc(%ebp)
  801953:	e8 6f f0 ff ff       	call   8009c7 <memmove>
	return r;
  801958:	83 c4 10             	add    $0x10,%esp
}
  80195b:	89 d8                	mov    %ebx,%eax
  80195d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801960:	5b                   	pop    %ebx
  801961:	5e                   	pop    %esi
  801962:	5d                   	pop    %ebp
  801963:	c3                   	ret    

00801964 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	53                   	push   %ebx
  801968:	83 ec 20             	sub    $0x20,%esp
  80196b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80196e:	53                   	push   %ebx
  80196f:	e8 88 ee ff ff       	call   8007fc <strlen>
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80197c:	7f 67                	jg     8019e5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80197e:	83 ec 0c             	sub    $0xc,%esp
  801981:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801984:	50                   	push   %eax
  801985:	e8 9a f8 ff ff       	call   801224 <fd_alloc>
  80198a:	83 c4 10             	add    $0x10,%esp
		return r;
  80198d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80198f:	85 c0                	test   %eax,%eax
  801991:	78 57                	js     8019ea <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801993:	83 ec 08             	sub    $0x8,%esp
  801996:	53                   	push   %ebx
  801997:	68 00 50 80 00       	push   $0x805000
  80199c:	e8 94 ee ff ff       	call   800835 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a4:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8019b1:	e8 f6 fd ff ff       	call   8017ac <fsipc>
  8019b6:	89 c3                	mov    %eax,%ebx
  8019b8:	83 c4 10             	add    $0x10,%esp
  8019bb:	85 c0                	test   %eax,%eax
  8019bd:	79 14                	jns    8019d3 <open+0x6f>
		fd_close(fd, 0);
  8019bf:	83 ec 08             	sub    $0x8,%esp
  8019c2:	6a 00                	push   $0x0
  8019c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c7:	e8 50 f9 ff ff       	call   80131c <fd_close>
		return r;
  8019cc:	83 c4 10             	add    $0x10,%esp
  8019cf:	89 da                	mov    %ebx,%edx
  8019d1:	eb 17                	jmp    8019ea <open+0x86>
	}

	return fd2num(fd);
  8019d3:	83 ec 0c             	sub    $0xc,%esp
  8019d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d9:	e8 1f f8 ff ff       	call   8011fd <fd2num>
  8019de:	89 c2                	mov    %eax,%edx
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	eb 05                	jmp    8019ea <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019e5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019ea:	89 d0                	mov    %edx,%eax
  8019ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ef:	c9                   	leave  
  8019f0:	c3                   	ret    

008019f1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019fc:	b8 08 00 00 00       	mov    $0x8,%eax
  801a01:	e8 a6 fd ff ff       	call   8017ac <fsipc>
}
  801a06:	c9                   	leave  
  801a07:	c3                   	ret    

00801a08 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a0e:	68 b7 2b 80 00       	push   $0x802bb7
  801a13:	ff 75 0c             	pushl  0xc(%ebp)
  801a16:	e8 1a ee ff ff       	call   800835 <strcpy>
	return 0;
}
  801a1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a20:	c9                   	leave  
  801a21:	c3                   	ret    

00801a22 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	53                   	push   %ebx
  801a26:	83 ec 10             	sub    $0x10,%esp
  801a29:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a2c:	53                   	push   %ebx
  801a2d:	e8 a3 09 00 00       	call   8023d5 <pageref>
  801a32:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a35:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a3a:	83 f8 01             	cmp    $0x1,%eax
  801a3d:	75 10                	jne    801a4f <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a3f:	83 ec 0c             	sub    $0xc,%esp
  801a42:	ff 73 0c             	pushl  0xc(%ebx)
  801a45:	e8 c0 02 00 00       	call   801d0a <nsipc_close>
  801a4a:	89 c2                	mov    %eax,%edx
  801a4c:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a4f:	89 d0                	mov    %edx,%eax
  801a51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a54:	c9                   	leave  
  801a55:	c3                   	ret    

00801a56 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a5c:	6a 00                	push   $0x0
  801a5e:	ff 75 10             	pushl  0x10(%ebp)
  801a61:	ff 75 0c             	pushl  0xc(%ebp)
  801a64:	8b 45 08             	mov    0x8(%ebp),%eax
  801a67:	ff 70 0c             	pushl  0xc(%eax)
  801a6a:	e8 78 03 00 00       	call   801de7 <nsipc_send>
}
  801a6f:	c9                   	leave  
  801a70:	c3                   	ret    

00801a71 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a77:	6a 00                	push   $0x0
  801a79:	ff 75 10             	pushl  0x10(%ebp)
  801a7c:	ff 75 0c             	pushl  0xc(%ebp)
  801a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a82:	ff 70 0c             	pushl  0xc(%eax)
  801a85:	e8 f1 02 00 00       	call   801d7b <nsipc_recv>
}
  801a8a:	c9                   	leave  
  801a8b:	c3                   	ret    

00801a8c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a92:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a95:	52                   	push   %edx
  801a96:	50                   	push   %eax
  801a97:	e8 d7 f7 ff ff       	call   801273 <fd_lookup>
  801a9c:	83 c4 10             	add    $0x10,%esp
  801a9f:	85 c0                	test   %eax,%eax
  801aa1:	78 17                	js     801aba <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa6:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801aac:	39 08                	cmp    %ecx,(%eax)
  801aae:	75 05                	jne    801ab5 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801ab0:	8b 40 0c             	mov    0xc(%eax),%eax
  801ab3:	eb 05                	jmp    801aba <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801ab5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801aba:	c9                   	leave  
  801abb:	c3                   	ret    

00801abc <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	56                   	push   %esi
  801ac0:	53                   	push   %ebx
  801ac1:	83 ec 1c             	sub    $0x1c,%esp
  801ac4:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ac6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac9:	50                   	push   %eax
  801aca:	e8 55 f7 ff ff       	call   801224 <fd_alloc>
  801acf:	89 c3                	mov    %eax,%ebx
  801ad1:	83 c4 10             	add    $0x10,%esp
  801ad4:	85 c0                	test   %eax,%eax
  801ad6:	78 1b                	js     801af3 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ad8:	83 ec 04             	sub    $0x4,%esp
  801adb:	68 07 04 00 00       	push   $0x407
  801ae0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae3:	6a 00                	push   $0x0
  801ae5:	e8 4e f1 ff ff       	call   800c38 <sys_page_alloc>
  801aea:	89 c3                	mov    %eax,%ebx
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	85 c0                	test   %eax,%eax
  801af1:	79 10                	jns    801b03 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801af3:	83 ec 0c             	sub    $0xc,%esp
  801af6:	56                   	push   %esi
  801af7:	e8 0e 02 00 00       	call   801d0a <nsipc_close>
		return r;
  801afc:	83 c4 10             	add    $0x10,%esp
  801aff:	89 d8                	mov    %ebx,%eax
  801b01:	eb 24                	jmp    801b27 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b03:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b11:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b18:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b1b:	83 ec 0c             	sub    $0xc,%esp
  801b1e:	50                   	push   %eax
  801b1f:	e8 d9 f6 ff ff       	call   8011fd <fd2num>
  801b24:	83 c4 10             	add    $0x10,%esp
}
  801b27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b2a:	5b                   	pop    %ebx
  801b2b:	5e                   	pop    %esi
  801b2c:	5d                   	pop    %ebp
  801b2d:	c3                   	ret    

00801b2e <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b34:	8b 45 08             	mov    0x8(%ebp),%eax
  801b37:	e8 50 ff ff ff       	call   801a8c <fd2sockid>
		return r;
  801b3c:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b3e:	85 c0                	test   %eax,%eax
  801b40:	78 1f                	js     801b61 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b42:	83 ec 04             	sub    $0x4,%esp
  801b45:	ff 75 10             	pushl  0x10(%ebp)
  801b48:	ff 75 0c             	pushl  0xc(%ebp)
  801b4b:	50                   	push   %eax
  801b4c:	e8 12 01 00 00       	call   801c63 <nsipc_accept>
  801b51:	83 c4 10             	add    $0x10,%esp
		return r;
  801b54:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b56:	85 c0                	test   %eax,%eax
  801b58:	78 07                	js     801b61 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b5a:	e8 5d ff ff ff       	call   801abc <alloc_sockfd>
  801b5f:	89 c1                	mov    %eax,%ecx
}
  801b61:	89 c8                	mov    %ecx,%eax
  801b63:	c9                   	leave  
  801b64:	c3                   	ret    

00801b65 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6e:	e8 19 ff ff ff       	call   801a8c <fd2sockid>
  801b73:	85 c0                	test   %eax,%eax
  801b75:	78 12                	js     801b89 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b77:	83 ec 04             	sub    $0x4,%esp
  801b7a:	ff 75 10             	pushl  0x10(%ebp)
  801b7d:	ff 75 0c             	pushl  0xc(%ebp)
  801b80:	50                   	push   %eax
  801b81:	e8 2d 01 00 00       	call   801cb3 <nsipc_bind>
  801b86:	83 c4 10             	add    $0x10,%esp
}
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    

00801b8b <shutdown>:

int
shutdown(int s, int how)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b91:	8b 45 08             	mov    0x8(%ebp),%eax
  801b94:	e8 f3 fe ff ff       	call   801a8c <fd2sockid>
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	78 0f                	js     801bac <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b9d:	83 ec 08             	sub    $0x8,%esp
  801ba0:	ff 75 0c             	pushl  0xc(%ebp)
  801ba3:	50                   	push   %eax
  801ba4:	e8 3f 01 00 00       	call   801ce8 <nsipc_shutdown>
  801ba9:	83 c4 10             	add    $0x10,%esp
}
  801bac:	c9                   	leave  
  801bad:	c3                   	ret    

00801bae <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bae:	55                   	push   %ebp
  801baf:	89 e5                	mov    %esp,%ebp
  801bb1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb7:	e8 d0 fe ff ff       	call   801a8c <fd2sockid>
  801bbc:	85 c0                	test   %eax,%eax
  801bbe:	78 12                	js     801bd2 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801bc0:	83 ec 04             	sub    $0x4,%esp
  801bc3:	ff 75 10             	pushl  0x10(%ebp)
  801bc6:	ff 75 0c             	pushl  0xc(%ebp)
  801bc9:	50                   	push   %eax
  801bca:	e8 55 01 00 00       	call   801d24 <nsipc_connect>
  801bcf:	83 c4 10             	add    $0x10,%esp
}
  801bd2:	c9                   	leave  
  801bd3:	c3                   	ret    

00801bd4 <listen>:

int
listen(int s, int backlog)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bda:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdd:	e8 aa fe ff ff       	call   801a8c <fd2sockid>
  801be2:	85 c0                	test   %eax,%eax
  801be4:	78 0f                	js     801bf5 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801be6:	83 ec 08             	sub    $0x8,%esp
  801be9:	ff 75 0c             	pushl  0xc(%ebp)
  801bec:	50                   	push   %eax
  801bed:	e8 67 01 00 00       	call   801d59 <nsipc_listen>
  801bf2:	83 c4 10             	add    $0x10,%esp
}
  801bf5:	c9                   	leave  
  801bf6:	c3                   	ret    

00801bf7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801bf7:	55                   	push   %ebp
  801bf8:	89 e5                	mov    %esp,%ebp
  801bfa:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bfd:	ff 75 10             	pushl  0x10(%ebp)
  801c00:	ff 75 0c             	pushl  0xc(%ebp)
  801c03:	ff 75 08             	pushl  0x8(%ebp)
  801c06:	e8 3a 02 00 00       	call   801e45 <nsipc_socket>
  801c0b:	83 c4 10             	add    $0x10,%esp
  801c0e:	85 c0                	test   %eax,%eax
  801c10:	78 05                	js     801c17 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c12:	e8 a5 fe ff ff       	call   801abc <alloc_sockfd>
}
  801c17:	c9                   	leave  
  801c18:	c3                   	ret    

00801c19 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c19:	55                   	push   %ebp
  801c1a:	89 e5                	mov    %esp,%ebp
  801c1c:	53                   	push   %ebx
  801c1d:	83 ec 04             	sub    $0x4,%esp
  801c20:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c22:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c29:	75 12                	jne    801c3d <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c2b:	83 ec 0c             	sub    $0xc,%esp
  801c2e:	6a 02                	push   $0x2
  801c30:	e8 8f f5 ff ff       	call   8011c4 <ipc_find_env>
  801c35:	a3 04 40 80 00       	mov    %eax,0x804004
  801c3a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c3d:	6a 07                	push   $0x7
  801c3f:	68 00 60 80 00       	push   $0x806000
  801c44:	53                   	push   %ebx
  801c45:	ff 35 04 40 80 00    	pushl  0x804004
  801c4b:	e8 20 f5 ff ff       	call   801170 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c50:	83 c4 0c             	add    $0xc,%esp
  801c53:	6a 00                	push   $0x0
  801c55:	6a 00                	push   $0x0
  801c57:	6a 00                	push   $0x0
  801c59:	e8 a9 f4 ff ff       	call   801107 <ipc_recv>
}
  801c5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c61:	c9                   	leave  
  801c62:	c3                   	ret    

00801c63 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	56                   	push   %esi
  801c67:	53                   	push   %ebx
  801c68:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c73:	8b 06                	mov    (%esi),%eax
  801c75:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c7a:	b8 01 00 00 00       	mov    $0x1,%eax
  801c7f:	e8 95 ff ff ff       	call   801c19 <nsipc>
  801c84:	89 c3                	mov    %eax,%ebx
  801c86:	85 c0                	test   %eax,%eax
  801c88:	78 20                	js     801caa <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c8a:	83 ec 04             	sub    $0x4,%esp
  801c8d:	ff 35 10 60 80 00    	pushl  0x806010
  801c93:	68 00 60 80 00       	push   $0x806000
  801c98:	ff 75 0c             	pushl  0xc(%ebp)
  801c9b:	e8 27 ed ff ff       	call   8009c7 <memmove>
		*addrlen = ret->ret_addrlen;
  801ca0:	a1 10 60 80 00       	mov    0x806010,%eax
  801ca5:	89 06                	mov    %eax,(%esi)
  801ca7:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801caa:	89 d8                	mov    %ebx,%eax
  801cac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801caf:	5b                   	pop    %ebx
  801cb0:	5e                   	pop    %esi
  801cb1:	5d                   	pop    %ebp
  801cb2:	c3                   	ret    

00801cb3 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cb3:	55                   	push   %ebp
  801cb4:	89 e5                	mov    %esp,%ebp
  801cb6:	53                   	push   %ebx
  801cb7:	83 ec 08             	sub    $0x8,%esp
  801cba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801cbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801cc5:	53                   	push   %ebx
  801cc6:	ff 75 0c             	pushl  0xc(%ebp)
  801cc9:	68 04 60 80 00       	push   $0x806004
  801cce:	e8 f4 ec ff ff       	call   8009c7 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801cd3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801cd9:	b8 02 00 00 00       	mov    $0x2,%eax
  801cde:	e8 36 ff ff ff       	call   801c19 <nsipc>
}
  801ce3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ce6:	c9                   	leave  
  801ce7:	c3                   	ret    

00801ce8 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801cee:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801cfe:	b8 03 00 00 00       	mov    $0x3,%eax
  801d03:	e8 11 ff ff ff       	call   801c19 <nsipc>
}
  801d08:	c9                   	leave  
  801d09:	c3                   	ret    

00801d0a <nsipc_close>:

int
nsipc_close(int s)
{
  801d0a:	55                   	push   %ebp
  801d0b:	89 e5                	mov    %esp,%ebp
  801d0d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d10:	8b 45 08             	mov    0x8(%ebp),%eax
  801d13:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d18:	b8 04 00 00 00       	mov    $0x4,%eax
  801d1d:	e8 f7 fe ff ff       	call   801c19 <nsipc>
}
  801d22:	c9                   	leave  
  801d23:	c3                   	ret    

00801d24 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d24:	55                   	push   %ebp
  801d25:	89 e5                	mov    %esp,%ebp
  801d27:	53                   	push   %ebx
  801d28:	83 ec 08             	sub    $0x8,%esp
  801d2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d31:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d36:	53                   	push   %ebx
  801d37:	ff 75 0c             	pushl  0xc(%ebp)
  801d3a:	68 04 60 80 00       	push   $0x806004
  801d3f:	e8 83 ec ff ff       	call   8009c7 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d44:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d4a:	b8 05 00 00 00       	mov    $0x5,%eax
  801d4f:	e8 c5 fe ff ff       	call   801c19 <nsipc>
}
  801d54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d57:	c9                   	leave  
  801d58:	c3                   	ret    

00801d59 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d59:	55                   	push   %ebp
  801d5a:	89 e5                	mov    %esp,%ebp
  801d5c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d62:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d67:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d6a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d6f:	b8 06 00 00 00       	mov    $0x6,%eax
  801d74:	e8 a0 fe ff ff       	call   801c19 <nsipc>
}
  801d79:	c9                   	leave  
  801d7a:	c3                   	ret    

00801d7b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d7b:	55                   	push   %ebp
  801d7c:	89 e5                	mov    %esp,%ebp
  801d7e:	56                   	push   %esi
  801d7f:	53                   	push   %ebx
  801d80:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d83:	8b 45 08             	mov    0x8(%ebp),%eax
  801d86:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d8b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d91:	8b 45 14             	mov    0x14(%ebp),%eax
  801d94:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d99:	b8 07 00 00 00       	mov    $0x7,%eax
  801d9e:	e8 76 fe ff ff       	call   801c19 <nsipc>
  801da3:	89 c3                	mov    %eax,%ebx
  801da5:	85 c0                	test   %eax,%eax
  801da7:	78 35                	js     801dde <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801da9:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801dae:	7f 04                	jg     801db4 <nsipc_recv+0x39>
  801db0:	39 c6                	cmp    %eax,%esi
  801db2:	7d 16                	jge    801dca <nsipc_recv+0x4f>
  801db4:	68 c3 2b 80 00       	push   $0x802bc3
  801db9:	68 8b 2b 80 00       	push   $0x802b8b
  801dbe:	6a 62                	push   $0x62
  801dc0:	68 d8 2b 80 00       	push   $0x802bd8
  801dc5:	e8 8e e3 ff ff       	call   800158 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801dca:	83 ec 04             	sub    $0x4,%esp
  801dcd:	50                   	push   %eax
  801dce:	68 00 60 80 00       	push   $0x806000
  801dd3:	ff 75 0c             	pushl  0xc(%ebp)
  801dd6:	e8 ec eb ff ff       	call   8009c7 <memmove>
  801ddb:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801dde:	89 d8                	mov    %ebx,%eax
  801de0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801de3:	5b                   	pop    %ebx
  801de4:	5e                   	pop    %esi
  801de5:	5d                   	pop    %ebp
  801de6:	c3                   	ret    

00801de7 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	53                   	push   %ebx
  801deb:	83 ec 04             	sub    $0x4,%esp
  801dee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801df1:	8b 45 08             	mov    0x8(%ebp),%eax
  801df4:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801df9:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801dff:	7e 16                	jle    801e17 <nsipc_send+0x30>
  801e01:	68 e4 2b 80 00       	push   $0x802be4
  801e06:	68 8b 2b 80 00       	push   $0x802b8b
  801e0b:	6a 6d                	push   $0x6d
  801e0d:	68 d8 2b 80 00       	push   $0x802bd8
  801e12:	e8 41 e3 ff ff       	call   800158 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e17:	83 ec 04             	sub    $0x4,%esp
  801e1a:	53                   	push   %ebx
  801e1b:	ff 75 0c             	pushl  0xc(%ebp)
  801e1e:	68 0c 60 80 00       	push   $0x80600c
  801e23:	e8 9f eb ff ff       	call   8009c7 <memmove>
	nsipcbuf.send.req_size = size;
  801e28:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e2e:	8b 45 14             	mov    0x14(%ebp),%eax
  801e31:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e36:	b8 08 00 00 00       	mov    $0x8,%eax
  801e3b:	e8 d9 fd ff ff       	call   801c19 <nsipc>
}
  801e40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e43:	c9                   	leave  
  801e44:	c3                   	ret    

00801e45 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e45:	55                   	push   %ebp
  801e46:	89 e5                	mov    %esp,%ebp
  801e48:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e53:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e56:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e5b:	8b 45 10             	mov    0x10(%ebp),%eax
  801e5e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e63:	b8 09 00 00 00       	mov    $0x9,%eax
  801e68:	e8 ac fd ff ff       	call   801c19 <nsipc>
}
  801e6d:	c9                   	leave  
  801e6e:	c3                   	ret    

00801e6f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e6f:	55                   	push   %ebp
  801e70:	89 e5                	mov    %esp,%ebp
  801e72:	56                   	push   %esi
  801e73:	53                   	push   %ebx
  801e74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e77:	83 ec 0c             	sub    $0xc,%esp
  801e7a:	ff 75 08             	pushl  0x8(%ebp)
  801e7d:	e8 8b f3 ff ff       	call   80120d <fd2data>
  801e82:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e84:	83 c4 08             	add    $0x8,%esp
  801e87:	68 f0 2b 80 00       	push   $0x802bf0
  801e8c:	53                   	push   %ebx
  801e8d:	e8 a3 e9 ff ff       	call   800835 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e92:	8b 46 04             	mov    0x4(%esi),%eax
  801e95:	2b 06                	sub    (%esi),%eax
  801e97:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e9d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ea4:	00 00 00 
	stat->st_dev = &devpipe;
  801ea7:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801eae:	30 80 00 
	return 0;
}
  801eb1:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb9:	5b                   	pop    %ebx
  801eba:	5e                   	pop    %esi
  801ebb:	5d                   	pop    %ebp
  801ebc:	c3                   	ret    

00801ebd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ebd:	55                   	push   %ebp
  801ebe:	89 e5                	mov    %esp,%ebp
  801ec0:	53                   	push   %ebx
  801ec1:	83 ec 0c             	sub    $0xc,%esp
  801ec4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ec7:	53                   	push   %ebx
  801ec8:	6a 00                	push   $0x0
  801eca:	e8 ee ed ff ff       	call   800cbd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ecf:	89 1c 24             	mov    %ebx,(%esp)
  801ed2:	e8 36 f3 ff ff       	call   80120d <fd2data>
  801ed7:	83 c4 08             	add    $0x8,%esp
  801eda:	50                   	push   %eax
  801edb:	6a 00                	push   $0x0
  801edd:	e8 db ed ff ff       	call   800cbd <sys_page_unmap>
}
  801ee2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ee5:	c9                   	leave  
  801ee6:	c3                   	ret    

00801ee7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ee7:	55                   	push   %ebp
  801ee8:	89 e5                	mov    %esp,%ebp
  801eea:	57                   	push   %edi
  801eeb:	56                   	push   %esi
  801eec:	53                   	push   %ebx
  801eed:	83 ec 1c             	sub    $0x1c,%esp
  801ef0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ef3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ef5:	a1 08 40 80 00       	mov    0x804008,%eax
  801efa:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801efd:	83 ec 0c             	sub    $0xc,%esp
  801f00:	ff 75 e0             	pushl  -0x20(%ebp)
  801f03:	e8 cd 04 00 00       	call   8023d5 <pageref>
  801f08:	89 c3                	mov    %eax,%ebx
  801f0a:	89 3c 24             	mov    %edi,(%esp)
  801f0d:	e8 c3 04 00 00       	call   8023d5 <pageref>
  801f12:	83 c4 10             	add    $0x10,%esp
  801f15:	39 c3                	cmp    %eax,%ebx
  801f17:	0f 94 c1             	sete   %cl
  801f1a:	0f b6 c9             	movzbl %cl,%ecx
  801f1d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f20:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f26:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f29:	39 ce                	cmp    %ecx,%esi
  801f2b:	74 1b                	je     801f48 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f2d:	39 c3                	cmp    %eax,%ebx
  801f2f:	75 c4                	jne    801ef5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f31:	8b 42 58             	mov    0x58(%edx),%eax
  801f34:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f37:	50                   	push   %eax
  801f38:	56                   	push   %esi
  801f39:	68 f7 2b 80 00       	push   $0x802bf7
  801f3e:	e8 ee e2 ff ff       	call   800231 <cprintf>
  801f43:	83 c4 10             	add    $0x10,%esp
  801f46:	eb ad                	jmp    801ef5 <_pipeisclosed+0xe>
	}
}
  801f48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4e:	5b                   	pop    %ebx
  801f4f:	5e                   	pop    %esi
  801f50:	5f                   	pop    %edi
  801f51:	5d                   	pop    %ebp
  801f52:	c3                   	ret    

00801f53 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f53:	55                   	push   %ebp
  801f54:	89 e5                	mov    %esp,%ebp
  801f56:	57                   	push   %edi
  801f57:	56                   	push   %esi
  801f58:	53                   	push   %ebx
  801f59:	83 ec 28             	sub    $0x28,%esp
  801f5c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f5f:	56                   	push   %esi
  801f60:	e8 a8 f2 ff ff       	call   80120d <fd2data>
  801f65:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f67:	83 c4 10             	add    $0x10,%esp
  801f6a:	bf 00 00 00 00       	mov    $0x0,%edi
  801f6f:	eb 4b                	jmp    801fbc <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f71:	89 da                	mov    %ebx,%edx
  801f73:	89 f0                	mov    %esi,%eax
  801f75:	e8 6d ff ff ff       	call   801ee7 <_pipeisclosed>
  801f7a:	85 c0                	test   %eax,%eax
  801f7c:	75 48                	jne    801fc6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f7e:	e8 96 ec ff ff       	call   800c19 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f83:	8b 43 04             	mov    0x4(%ebx),%eax
  801f86:	8b 0b                	mov    (%ebx),%ecx
  801f88:	8d 51 20             	lea    0x20(%ecx),%edx
  801f8b:	39 d0                	cmp    %edx,%eax
  801f8d:	73 e2                	jae    801f71 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f92:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f96:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f99:	89 c2                	mov    %eax,%edx
  801f9b:	c1 fa 1f             	sar    $0x1f,%edx
  801f9e:	89 d1                	mov    %edx,%ecx
  801fa0:	c1 e9 1b             	shr    $0x1b,%ecx
  801fa3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fa6:	83 e2 1f             	and    $0x1f,%edx
  801fa9:	29 ca                	sub    %ecx,%edx
  801fab:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801faf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fb3:	83 c0 01             	add    $0x1,%eax
  801fb6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb9:	83 c7 01             	add    $0x1,%edi
  801fbc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fbf:	75 c2                	jne    801f83 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fc1:	8b 45 10             	mov    0x10(%ebp),%eax
  801fc4:	eb 05                	jmp    801fcb <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fc6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fce:	5b                   	pop    %ebx
  801fcf:	5e                   	pop    %esi
  801fd0:	5f                   	pop    %edi
  801fd1:	5d                   	pop    %ebp
  801fd2:	c3                   	ret    

00801fd3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fd3:	55                   	push   %ebp
  801fd4:	89 e5                	mov    %esp,%ebp
  801fd6:	57                   	push   %edi
  801fd7:	56                   	push   %esi
  801fd8:	53                   	push   %ebx
  801fd9:	83 ec 18             	sub    $0x18,%esp
  801fdc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fdf:	57                   	push   %edi
  801fe0:	e8 28 f2 ff ff       	call   80120d <fd2data>
  801fe5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fe7:	83 c4 10             	add    $0x10,%esp
  801fea:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fef:	eb 3d                	jmp    80202e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ff1:	85 db                	test   %ebx,%ebx
  801ff3:	74 04                	je     801ff9 <devpipe_read+0x26>
				return i;
  801ff5:	89 d8                	mov    %ebx,%eax
  801ff7:	eb 44                	jmp    80203d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ff9:	89 f2                	mov    %esi,%edx
  801ffb:	89 f8                	mov    %edi,%eax
  801ffd:	e8 e5 fe ff ff       	call   801ee7 <_pipeisclosed>
  802002:	85 c0                	test   %eax,%eax
  802004:	75 32                	jne    802038 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802006:	e8 0e ec ff ff       	call   800c19 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80200b:	8b 06                	mov    (%esi),%eax
  80200d:	3b 46 04             	cmp    0x4(%esi),%eax
  802010:	74 df                	je     801ff1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802012:	99                   	cltd   
  802013:	c1 ea 1b             	shr    $0x1b,%edx
  802016:	01 d0                	add    %edx,%eax
  802018:	83 e0 1f             	and    $0x1f,%eax
  80201b:	29 d0                	sub    %edx,%eax
  80201d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802022:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802025:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802028:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80202b:	83 c3 01             	add    $0x1,%ebx
  80202e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802031:	75 d8                	jne    80200b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802033:	8b 45 10             	mov    0x10(%ebp),%eax
  802036:	eb 05                	jmp    80203d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802038:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80203d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802040:	5b                   	pop    %ebx
  802041:	5e                   	pop    %esi
  802042:	5f                   	pop    %edi
  802043:	5d                   	pop    %ebp
  802044:	c3                   	ret    

00802045 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802045:	55                   	push   %ebp
  802046:	89 e5                	mov    %esp,%ebp
  802048:	56                   	push   %esi
  802049:	53                   	push   %ebx
  80204a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80204d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802050:	50                   	push   %eax
  802051:	e8 ce f1 ff ff       	call   801224 <fd_alloc>
  802056:	83 c4 10             	add    $0x10,%esp
  802059:	89 c2                	mov    %eax,%edx
  80205b:	85 c0                	test   %eax,%eax
  80205d:	0f 88 2c 01 00 00    	js     80218f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802063:	83 ec 04             	sub    $0x4,%esp
  802066:	68 07 04 00 00       	push   $0x407
  80206b:	ff 75 f4             	pushl  -0xc(%ebp)
  80206e:	6a 00                	push   $0x0
  802070:	e8 c3 eb ff ff       	call   800c38 <sys_page_alloc>
  802075:	83 c4 10             	add    $0x10,%esp
  802078:	89 c2                	mov    %eax,%edx
  80207a:	85 c0                	test   %eax,%eax
  80207c:	0f 88 0d 01 00 00    	js     80218f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802082:	83 ec 0c             	sub    $0xc,%esp
  802085:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802088:	50                   	push   %eax
  802089:	e8 96 f1 ff ff       	call   801224 <fd_alloc>
  80208e:	89 c3                	mov    %eax,%ebx
  802090:	83 c4 10             	add    $0x10,%esp
  802093:	85 c0                	test   %eax,%eax
  802095:	0f 88 e2 00 00 00    	js     80217d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80209b:	83 ec 04             	sub    $0x4,%esp
  80209e:	68 07 04 00 00       	push   $0x407
  8020a3:	ff 75 f0             	pushl  -0x10(%ebp)
  8020a6:	6a 00                	push   $0x0
  8020a8:	e8 8b eb ff ff       	call   800c38 <sys_page_alloc>
  8020ad:	89 c3                	mov    %eax,%ebx
  8020af:	83 c4 10             	add    $0x10,%esp
  8020b2:	85 c0                	test   %eax,%eax
  8020b4:	0f 88 c3 00 00 00    	js     80217d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020ba:	83 ec 0c             	sub    $0xc,%esp
  8020bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8020c0:	e8 48 f1 ff ff       	call   80120d <fd2data>
  8020c5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020c7:	83 c4 0c             	add    $0xc,%esp
  8020ca:	68 07 04 00 00       	push   $0x407
  8020cf:	50                   	push   %eax
  8020d0:	6a 00                	push   $0x0
  8020d2:	e8 61 eb ff ff       	call   800c38 <sys_page_alloc>
  8020d7:	89 c3                	mov    %eax,%ebx
  8020d9:	83 c4 10             	add    $0x10,%esp
  8020dc:	85 c0                	test   %eax,%eax
  8020de:	0f 88 89 00 00 00    	js     80216d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020e4:	83 ec 0c             	sub    $0xc,%esp
  8020e7:	ff 75 f0             	pushl  -0x10(%ebp)
  8020ea:	e8 1e f1 ff ff       	call   80120d <fd2data>
  8020ef:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020f6:	50                   	push   %eax
  8020f7:	6a 00                	push   $0x0
  8020f9:	56                   	push   %esi
  8020fa:	6a 00                	push   $0x0
  8020fc:	e8 7a eb ff ff       	call   800c7b <sys_page_map>
  802101:	89 c3                	mov    %eax,%ebx
  802103:	83 c4 20             	add    $0x20,%esp
  802106:	85 c0                	test   %eax,%eax
  802108:	78 55                	js     80215f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80210a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802110:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802113:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802115:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802118:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80211f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802125:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802128:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80212a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80212d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802134:	83 ec 0c             	sub    $0xc,%esp
  802137:	ff 75 f4             	pushl  -0xc(%ebp)
  80213a:	e8 be f0 ff ff       	call   8011fd <fd2num>
  80213f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802142:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802144:	83 c4 04             	add    $0x4,%esp
  802147:	ff 75 f0             	pushl  -0x10(%ebp)
  80214a:	e8 ae f0 ff ff       	call   8011fd <fd2num>
  80214f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802152:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802155:	83 c4 10             	add    $0x10,%esp
  802158:	ba 00 00 00 00       	mov    $0x0,%edx
  80215d:	eb 30                	jmp    80218f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80215f:	83 ec 08             	sub    $0x8,%esp
  802162:	56                   	push   %esi
  802163:	6a 00                	push   $0x0
  802165:	e8 53 eb ff ff       	call   800cbd <sys_page_unmap>
  80216a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80216d:	83 ec 08             	sub    $0x8,%esp
  802170:	ff 75 f0             	pushl  -0x10(%ebp)
  802173:	6a 00                	push   $0x0
  802175:	e8 43 eb ff ff       	call   800cbd <sys_page_unmap>
  80217a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80217d:	83 ec 08             	sub    $0x8,%esp
  802180:	ff 75 f4             	pushl  -0xc(%ebp)
  802183:	6a 00                	push   $0x0
  802185:	e8 33 eb ff ff       	call   800cbd <sys_page_unmap>
  80218a:	83 c4 10             	add    $0x10,%esp
  80218d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80218f:	89 d0                	mov    %edx,%eax
  802191:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    

00802198 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802198:	55                   	push   %ebp
  802199:	89 e5                	mov    %esp,%ebp
  80219b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80219e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021a1:	50                   	push   %eax
  8021a2:	ff 75 08             	pushl  0x8(%ebp)
  8021a5:	e8 c9 f0 ff ff       	call   801273 <fd_lookup>
  8021aa:	83 c4 10             	add    $0x10,%esp
  8021ad:	85 c0                	test   %eax,%eax
  8021af:	78 18                	js     8021c9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021b1:	83 ec 0c             	sub    $0xc,%esp
  8021b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8021b7:	e8 51 f0 ff ff       	call   80120d <fd2data>
	return _pipeisclosed(fd, p);
  8021bc:	89 c2                	mov    %eax,%edx
  8021be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c1:	e8 21 fd ff ff       	call   801ee7 <_pipeisclosed>
  8021c6:	83 c4 10             	add    $0x10,%esp
}
  8021c9:	c9                   	leave  
  8021ca:	c3                   	ret    

008021cb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021cb:	55                   	push   %ebp
  8021cc:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8021d3:	5d                   	pop    %ebp
  8021d4:	c3                   	ret    

008021d5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021d5:	55                   	push   %ebp
  8021d6:	89 e5                	mov    %esp,%ebp
  8021d8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021db:	68 0f 2c 80 00       	push   $0x802c0f
  8021e0:	ff 75 0c             	pushl  0xc(%ebp)
  8021e3:	e8 4d e6 ff ff       	call   800835 <strcpy>
	return 0;
}
  8021e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8021ed:	c9                   	leave  
  8021ee:	c3                   	ret    

008021ef <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021ef:	55                   	push   %ebp
  8021f0:	89 e5                	mov    %esp,%ebp
  8021f2:	57                   	push   %edi
  8021f3:	56                   	push   %esi
  8021f4:	53                   	push   %ebx
  8021f5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021fb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802200:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802206:	eb 2d                	jmp    802235 <devcons_write+0x46>
		m = n - tot;
  802208:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80220b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80220d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802210:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802215:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802218:	83 ec 04             	sub    $0x4,%esp
  80221b:	53                   	push   %ebx
  80221c:	03 45 0c             	add    0xc(%ebp),%eax
  80221f:	50                   	push   %eax
  802220:	57                   	push   %edi
  802221:	e8 a1 e7 ff ff       	call   8009c7 <memmove>
		sys_cputs(buf, m);
  802226:	83 c4 08             	add    $0x8,%esp
  802229:	53                   	push   %ebx
  80222a:	57                   	push   %edi
  80222b:	e8 4c e9 ff ff       	call   800b7c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802230:	01 de                	add    %ebx,%esi
  802232:	83 c4 10             	add    $0x10,%esp
  802235:	89 f0                	mov    %esi,%eax
  802237:	3b 75 10             	cmp    0x10(%ebp),%esi
  80223a:	72 cc                	jb     802208 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80223c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80223f:	5b                   	pop    %ebx
  802240:	5e                   	pop    %esi
  802241:	5f                   	pop    %edi
  802242:	5d                   	pop    %ebp
  802243:	c3                   	ret    

00802244 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802244:	55                   	push   %ebp
  802245:	89 e5                	mov    %esp,%ebp
  802247:	83 ec 08             	sub    $0x8,%esp
  80224a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80224f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802253:	74 2a                	je     80227f <devcons_read+0x3b>
  802255:	eb 05                	jmp    80225c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802257:	e8 bd e9 ff ff       	call   800c19 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80225c:	e8 39 e9 ff ff       	call   800b9a <sys_cgetc>
  802261:	85 c0                	test   %eax,%eax
  802263:	74 f2                	je     802257 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802265:	85 c0                	test   %eax,%eax
  802267:	78 16                	js     80227f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802269:	83 f8 04             	cmp    $0x4,%eax
  80226c:	74 0c                	je     80227a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80226e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802271:	88 02                	mov    %al,(%edx)
	return 1;
  802273:	b8 01 00 00 00       	mov    $0x1,%eax
  802278:	eb 05                	jmp    80227f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80227a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80227f:	c9                   	leave  
  802280:	c3                   	ret    

00802281 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  802281:	55                   	push   %ebp
  802282:	89 e5                	mov    %esp,%ebp
  802284:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802287:	8b 45 08             	mov    0x8(%ebp),%eax
  80228a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80228d:	6a 01                	push   $0x1
  80228f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802292:	50                   	push   %eax
  802293:	e8 e4 e8 ff ff       	call   800b7c <sys_cputs>
}
  802298:	83 c4 10             	add    $0x10,%esp
  80229b:	c9                   	leave  
  80229c:	c3                   	ret    

0080229d <getchar>:

int
getchar(void)
{
  80229d:	55                   	push   %ebp
  80229e:	89 e5                	mov    %esp,%ebp
  8022a0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022a3:	6a 01                	push   $0x1
  8022a5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022a8:	50                   	push   %eax
  8022a9:	6a 00                	push   $0x0
  8022ab:	e8 29 f2 ff ff       	call   8014d9 <read>
	if (r < 0)
  8022b0:	83 c4 10             	add    $0x10,%esp
  8022b3:	85 c0                	test   %eax,%eax
  8022b5:	78 0f                	js     8022c6 <getchar+0x29>
		return r;
	if (r < 1)
  8022b7:	85 c0                	test   %eax,%eax
  8022b9:	7e 06                	jle    8022c1 <getchar+0x24>
		return -E_EOF;
	return c;
  8022bb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022bf:	eb 05                	jmp    8022c6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022c1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022c6:	c9                   	leave  
  8022c7:	c3                   	ret    

008022c8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022c8:	55                   	push   %ebp
  8022c9:	89 e5                	mov    %esp,%ebp
  8022cb:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022d1:	50                   	push   %eax
  8022d2:	ff 75 08             	pushl  0x8(%ebp)
  8022d5:	e8 99 ef ff ff       	call   801273 <fd_lookup>
  8022da:	83 c4 10             	add    $0x10,%esp
  8022dd:	85 c0                	test   %eax,%eax
  8022df:	78 11                	js     8022f2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022ea:	39 10                	cmp    %edx,(%eax)
  8022ec:	0f 94 c0             	sete   %al
  8022ef:	0f b6 c0             	movzbl %al,%eax
}
  8022f2:	c9                   	leave  
  8022f3:	c3                   	ret    

008022f4 <opencons>:

int
opencons(void)
{
  8022f4:	55                   	push   %ebp
  8022f5:	89 e5                	mov    %esp,%ebp
  8022f7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022fd:	50                   	push   %eax
  8022fe:	e8 21 ef ff ff       	call   801224 <fd_alloc>
  802303:	83 c4 10             	add    $0x10,%esp
		return r;
  802306:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802308:	85 c0                	test   %eax,%eax
  80230a:	78 3e                	js     80234a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80230c:	83 ec 04             	sub    $0x4,%esp
  80230f:	68 07 04 00 00       	push   $0x407
  802314:	ff 75 f4             	pushl  -0xc(%ebp)
  802317:	6a 00                	push   $0x0
  802319:	e8 1a e9 ff ff       	call   800c38 <sys_page_alloc>
  80231e:	83 c4 10             	add    $0x10,%esp
		return r;
  802321:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802323:	85 c0                	test   %eax,%eax
  802325:	78 23                	js     80234a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802327:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80232d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802330:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802332:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802335:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80233c:	83 ec 0c             	sub    $0xc,%esp
  80233f:	50                   	push   %eax
  802340:	e8 b8 ee ff ff       	call   8011fd <fd2num>
  802345:	89 c2                	mov    %eax,%edx
  802347:	83 c4 10             	add    $0x10,%esp
}
  80234a:	89 d0                	mov    %edx,%eax
  80234c:	c9                   	leave  
  80234d:	c3                   	ret    

0080234e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80234e:	55                   	push   %ebp
  80234f:	89 e5                	mov    %esp,%ebp
  802351:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802354:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80235b:	75 4a                	jne    8023a7 <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  80235d:	a1 08 40 80 00       	mov    0x804008,%eax
  802362:	8b 40 48             	mov    0x48(%eax),%eax
  802365:	83 ec 04             	sub    $0x4,%esp
  802368:	6a 07                	push   $0x7
  80236a:	68 00 f0 bf ee       	push   $0xeebff000
  80236f:	50                   	push   %eax
  802370:	e8 c3 e8 ff ff       	call   800c38 <sys_page_alloc>
  802375:	83 c4 10             	add    $0x10,%esp
  802378:	85 c0                	test   %eax,%eax
  80237a:	79 12                	jns    80238e <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  80237c:	50                   	push   %eax
  80237d:	68 1b 2c 80 00       	push   $0x802c1b
  802382:	6a 21                	push   $0x21
  802384:	68 33 2c 80 00       	push   $0x802c33
  802389:	e8 ca dd ff ff       	call   800158 <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80238e:	a1 08 40 80 00       	mov    0x804008,%eax
  802393:	8b 40 48             	mov    0x48(%eax),%eax
  802396:	83 ec 08             	sub    $0x8,%esp
  802399:	68 b1 23 80 00       	push   $0x8023b1
  80239e:	50                   	push   %eax
  80239f:	e8 df e9 ff ff       	call   800d83 <sys_env_set_pgfault_upcall>
  8023a4:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8023aa:	a3 00 70 80 00       	mov    %eax,0x807000
  8023af:	c9                   	leave  
  8023b0:	c3                   	ret    

008023b1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023b1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023b2:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8023b7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023b9:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  8023bc:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  8023bf:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  8023c3:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  8023c8:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  8023cc:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8023ce:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  8023cf:	83 c4 04             	add    $0x4,%esp
	popfl
  8023d2:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8023d3:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  8023d4:	c3                   	ret    

008023d5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023d5:	55                   	push   %ebp
  8023d6:	89 e5                	mov    %esp,%ebp
  8023d8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023db:	89 d0                	mov    %edx,%eax
  8023dd:	c1 e8 16             	shr    $0x16,%eax
  8023e0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023e7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023ec:	f6 c1 01             	test   $0x1,%cl
  8023ef:	74 1d                	je     80240e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023f1:	c1 ea 0c             	shr    $0xc,%edx
  8023f4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023fb:	f6 c2 01             	test   $0x1,%dl
  8023fe:	74 0e                	je     80240e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802400:	c1 ea 0c             	shr    $0xc,%edx
  802403:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80240a:	ef 
  80240b:	0f b7 c0             	movzwl %ax,%eax
}
  80240e:	5d                   	pop    %ebp
  80240f:	c3                   	ret    

00802410 <__udivdi3>:
  802410:	55                   	push   %ebp
  802411:	57                   	push   %edi
  802412:	56                   	push   %esi
  802413:	53                   	push   %ebx
  802414:	83 ec 1c             	sub    $0x1c,%esp
  802417:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80241b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80241f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802423:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802427:	85 f6                	test   %esi,%esi
  802429:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80242d:	89 ca                	mov    %ecx,%edx
  80242f:	89 f8                	mov    %edi,%eax
  802431:	75 3d                	jne    802470 <__udivdi3+0x60>
  802433:	39 cf                	cmp    %ecx,%edi
  802435:	0f 87 c5 00 00 00    	ja     802500 <__udivdi3+0xf0>
  80243b:	85 ff                	test   %edi,%edi
  80243d:	89 fd                	mov    %edi,%ebp
  80243f:	75 0b                	jne    80244c <__udivdi3+0x3c>
  802441:	b8 01 00 00 00       	mov    $0x1,%eax
  802446:	31 d2                	xor    %edx,%edx
  802448:	f7 f7                	div    %edi
  80244a:	89 c5                	mov    %eax,%ebp
  80244c:	89 c8                	mov    %ecx,%eax
  80244e:	31 d2                	xor    %edx,%edx
  802450:	f7 f5                	div    %ebp
  802452:	89 c1                	mov    %eax,%ecx
  802454:	89 d8                	mov    %ebx,%eax
  802456:	89 cf                	mov    %ecx,%edi
  802458:	f7 f5                	div    %ebp
  80245a:	89 c3                	mov    %eax,%ebx
  80245c:	89 d8                	mov    %ebx,%eax
  80245e:	89 fa                	mov    %edi,%edx
  802460:	83 c4 1c             	add    $0x1c,%esp
  802463:	5b                   	pop    %ebx
  802464:	5e                   	pop    %esi
  802465:	5f                   	pop    %edi
  802466:	5d                   	pop    %ebp
  802467:	c3                   	ret    
  802468:	90                   	nop
  802469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802470:	39 ce                	cmp    %ecx,%esi
  802472:	77 74                	ja     8024e8 <__udivdi3+0xd8>
  802474:	0f bd fe             	bsr    %esi,%edi
  802477:	83 f7 1f             	xor    $0x1f,%edi
  80247a:	0f 84 98 00 00 00    	je     802518 <__udivdi3+0x108>
  802480:	bb 20 00 00 00       	mov    $0x20,%ebx
  802485:	89 f9                	mov    %edi,%ecx
  802487:	89 c5                	mov    %eax,%ebp
  802489:	29 fb                	sub    %edi,%ebx
  80248b:	d3 e6                	shl    %cl,%esi
  80248d:	89 d9                	mov    %ebx,%ecx
  80248f:	d3 ed                	shr    %cl,%ebp
  802491:	89 f9                	mov    %edi,%ecx
  802493:	d3 e0                	shl    %cl,%eax
  802495:	09 ee                	or     %ebp,%esi
  802497:	89 d9                	mov    %ebx,%ecx
  802499:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80249d:	89 d5                	mov    %edx,%ebp
  80249f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024a3:	d3 ed                	shr    %cl,%ebp
  8024a5:	89 f9                	mov    %edi,%ecx
  8024a7:	d3 e2                	shl    %cl,%edx
  8024a9:	89 d9                	mov    %ebx,%ecx
  8024ab:	d3 e8                	shr    %cl,%eax
  8024ad:	09 c2                	or     %eax,%edx
  8024af:	89 d0                	mov    %edx,%eax
  8024b1:	89 ea                	mov    %ebp,%edx
  8024b3:	f7 f6                	div    %esi
  8024b5:	89 d5                	mov    %edx,%ebp
  8024b7:	89 c3                	mov    %eax,%ebx
  8024b9:	f7 64 24 0c          	mull   0xc(%esp)
  8024bd:	39 d5                	cmp    %edx,%ebp
  8024bf:	72 10                	jb     8024d1 <__udivdi3+0xc1>
  8024c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024c5:	89 f9                	mov    %edi,%ecx
  8024c7:	d3 e6                	shl    %cl,%esi
  8024c9:	39 c6                	cmp    %eax,%esi
  8024cb:	73 07                	jae    8024d4 <__udivdi3+0xc4>
  8024cd:	39 d5                	cmp    %edx,%ebp
  8024cf:	75 03                	jne    8024d4 <__udivdi3+0xc4>
  8024d1:	83 eb 01             	sub    $0x1,%ebx
  8024d4:	31 ff                	xor    %edi,%edi
  8024d6:	89 d8                	mov    %ebx,%eax
  8024d8:	89 fa                	mov    %edi,%edx
  8024da:	83 c4 1c             	add    $0x1c,%esp
  8024dd:	5b                   	pop    %ebx
  8024de:	5e                   	pop    %esi
  8024df:	5f                   	pop    %edi
  8024e0:	5d                   	pop    %ebp
  8024e1:	c3                   	ret    
  8024e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024e8:	31 ff                	xor    %edi,%edi
  8024ea:	31 db                	xor    %ebx,%ebx
  8024ec:	89 d8                	mov    %ebx,%eax
  8024ee:	89 fa                	mov    %edi,%edx
  8024f0:	83 c4 1c             	add    $0x1c,%esp
  8024f3:	5b                   	pop    %ebx
  8024f4:	5e                   	pop    %esi
  8024f5:	5f                   	pop    %edi
  8024f6:	5d                   	pop    %ebp
  8024f7:	c3                   	ret    
  8024f8:	90                   	nop
  8024f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802500:	89 d8                	mov    %ebx,%eax
  802502:	f7 f7                	div    %edi
  802504:	31 ff                	xor    %edi,%edi
  802506:	89 c3                	mov    %eax,%ebx
  802508:	89 d8                	mov    %ebx,%eax
  80250a:	89 fa                	mov    %edi,%edx
  80250c:	83 c4 1c             	add    $0x1c,%esp
  80250f:	5b                   	pop    %ebx
  802510:	5e                   	pop    %esi
  802511:	5f                   	pop    %edi
  802512:	5d                   	pop    %ebp
  802513:	c3                   	ret    
  802514:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802518:	39 ce                	cmp    %ecx,%esi
  80251a:	72 0c                	jb     802528 <__udivdi3+0x118>
  80251c:	31 db                	xor    %ebx,%ebx
  80251e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802522:	0f 87 34 ff ff ff    	ja     80245c <__udivdi3+0x4c>
  802528:	bb 01 00 00 00       	mov    $0x1,%ebx
  80252d:	e9 2a ff ff ff       	jmp    80245c <__udivdi3+0x4c>
  802532:	66 90                	xchg   %ax,%ax
  802534:	66 90                	xchg   %ax,%ax
  802536:	66 90                	xchg   %ax,%ax
  802538:	66 90                	xchg   %ax,%ax
  80253a:	66 90                	xchg   %ax,%ax
  80253c:	66 90                	xchg   %ax,%ax
  80253e:	66 90                	xchg   %ax,%ax

00802540 <__umoddi3>:
  802540:	55                   	push   %ebp
  802541:	57                   	push   %edi
  802542:	56                   	push   %esi
  802543:	53                   	push   %ebx
  802544:	83 ec 1c             	sub    $0x1c,%esp
  802547:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80254b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80254f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802553:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802557:	85 d2                	test   %edx,%edx
  802559:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80255d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802561:	89 f3                	mov    %esi,%ebx
  802563:	89 3c 24             	mov    %edi,(%esp)
  802566:	89 74 24 04          	mov    %esi,0x4(%esp)
  80256a:	75 1c                	jne    802588 <__umoddi3+0x48>
  80256c:	39 f7                	cmp    %esi,%edi
  80256e:	76 50                	jbe    8025c0 <__umoddi3+0x80>
  802570:	89 c8                	mov    %ecx,%eax
  802572:	89 f2                	mov    %esi,%edx
  802574:	f7 f7                	div    %edi
  802576:	89 d0                	mov    %edx,%eax
  802578:	31 d2                	xor    %edx,%edx
  80257a:	83 c4 1c             	add    $0x1c,%esp
  80257d:	5b                   	pop    %ebx
  80257e:	5e                   	pop    %esi
  80257f:	5f                   	pop    %edi
  802580:	5d                   	pop    %ebp
  802581:	c3                   	ret    
  802582:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802588:	39 f2                	cmp    %esi,%edx
  80258a:	89 d0                	mov    %edx,%eax
  80258c:	77 52                	ja     8025e0 <__umoddi3+0xa0>
  80258e:	0f bd ea             	bsr    %edx,%ebp
  802591:	83 f5 1f             	xor    $0x1f,%ebp
  802594:	75 5a                	jne    8025f0 <__umoddi3+0xb0>
  802596:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80259a:	0f 82 e0 00 00 00    	jb     802680 <__umoddi3+0x140>
  8025a0:	39 0c 24             	cmp    %ecx,(%esp)
  8025a3:	0f 86 d7 00 00 00    	jbe    802680 <__umoddi3+0x140>
  8025a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025b1:	83 c4 1c             	add    $0x1c,%esp
  8025b4:	5b                   	pop    %ebx
  8025b5:	5e                   	pop    %esi
  8025b6:	5f                   	pop    %edi
  8025b7:	5d                   	pop    %ebp
  8025b8:	c3                   	ret    
  8025b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025c0:	85 ff                	test   %edi,%edi
  8025c2:	89 fd                	mov    %edi,%ebp
  8025c4:	75 0b                	jne    8025d1 <__umoddi3+0x91>
  8025c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025cb:	31 d2                	xor    %edx,%edx
  8025cd:	f7 f7                	div    %edi
  8025cf:	89 c5                	mov    %eax,%ebp
  8025d1:	89 f0                	mov    %esi,%eax
  8025d3:	31 d2                	xor    %edx,%edx
  8025d5:	f7 f5                	div    %ebp
  8025d7:	89 c8                	mov    %ecx,%eax
  8025d9:	f7 f5                	div    %ebp
  8025db:	89 d0                	mov    %edx,%eax
  8025dd:	eb 99                	jmp    802578 <__umoddi3+0x38>
  8025df:	90                   	nop
  8025e0:	89 c8                	mov    %ecx,%eax
  8025e2:	89 f2                	mov    %esi,%edx
  8025e4:	83 c4 1c             	add    $0x1c,%esp
  8025e7:	5b                   	pop    %ebx
  8025e8:	5e                   	pop    %esi
  8025e9:	5f                   	pop    %edi
  8025ea:	5d                   	pop    %ebp
  8025eb:	c3                   	ret    
  8025ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025f0:	8b 34 24             	mov    (%esp),%esi
  8025f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8025f8:	89 e9                	mov    %ebp,%ecx
  8025fa:	29 ef                	sub    %ebp,%edi
  8025fc:	d3 e0                	shl    %cl,%eax
  8025fe:	89 f9                	mov    %edi,%ecx
  802600:	89 f2                	mov    %esi,%edx
  802602:	d3 ea                	shr    %cl,%edx
  802604:	89 e9                	mov    %ebp,%ecx
  802606:	09 c2                	or     %eax,%edx
  802608:	89 d8                	mov    %ebx,%eax
  80260a:	89 14 24             	mov    %edx,(%esp)
  80260d:	89 f2                	mov    %esi,%edx
  80260f:	d3 e2                	shl    %cl,%edx
  802611:	89 f9                	mov    %edi,%ecx
  802613:	89 54 24 04          	mov    %edx,0x4(%esp)
  802617:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80261b:	d3 e8                	shr    %cl,%eax
  80261d:	89 e9                	mov    %ebp,%ecx
  80261f:	89 c6                	mov    %eax,%esi
  802621:	d3 e3                	shl    %cl,%ebx
  802623:	89 f9                	mov    %edi,%ecx
  802625:	89 d0                	mov    %edx,%eax
  802627:	d3 e8                	shr    %cl,%eax
  802629:	89 e9                	mov    %ebp,%ecx
  80262b:	09 d8                	or     %ebx,%eax
  80262d:	89 d3                	mov    %edx,%ebx
  80262f:	89 f2                	mov    %esi,%edx
  802631:	f7 34 24             	divl   (%esp)
  802634:	89 d6                	mov    %edx,%esi
  802636:	d3 e3                	shl    %cl,%ebx
  802638:	f7 64 24 04          	mull   0x4(%esp)
  80263c:	39 d6                	cmp    %edx,%esi
  80263e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802642:	89 d1                	mov    %edx,%ecx
  802644:	89 c3                	mov    %eax,%ebx
  802646:	72 08                	jb     802650 <__umoddi3+0x110>
  802648:	75 11                	jne    80265b <__umoddi3+0x11b>
  80264a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80264e:	73 0b                	jae    80265b <__umoddi3+0x11b>
  802650:	2b 44 24 04          	sub    0x4(%esp),%eax
  802654:	1b 14 24             	sbb    (%esp),%edx
  802657:	89 d1                	mov    %edx,%ecx
  802659:	89 c3                	mov    %eax,%ebx
  80265b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80265f:	29 da                	sub    %ebx,%edx
  802661:	19 ce                	sbb    %ecx,%esi
  802663:	89 f9                	mov    %edi,%ecx
  802665:	89 f0                	mov    %esi,%eax
  802667:	d3 e0                	shl    %cl,%eax
  802669:	89 e9                	mov    %ebp,%ecx
  80266b:	d3 ea                	shr    %cl,%edx
  80266d:	89 e9                	mov    %ebp,%ecx
  80266f:	d3 ee                	shr    %cl,%esi
  802671:	09 d0                	or     %edx,%eax
  802673:	89 f2                	mov    %esi,%edx
  802675:	83 c4 1c             	add    $0x1c,%esp
  802678:	5b                   	pop    %ebx
  802679:	5e                   	pop    %esi
  80267a:	5f                   	pop    %edi
  80267b:	5d                   	pop    %ebp
  80267c:	c3                   	ret    
  80267d:	8d 76 00             	lea    0x0(%esi),%esi
  802680:	29 f9                	sub    %edi,%ecx
  802682:	19 d6                	sbb    %edx,%esi
  802684:	89 74 24 04          	mov    %esi,0x4(%esp)
  802688:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80268c:	e9 18 ff ff ff       	jmp    8025a9 <__umoddi3+0x69>
