
obj/user/sendpage.debug：     文件格式 elf32-i386


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
  80002c:	e8 68 01 00 00       	call   800199 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 38 0f 00 00       	call   800f76 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 9f 00 00 00    	jne    8000e8 <umain+0xb5>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	68 00 00 b0 00       	push   $0xb00000
  800053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 c7 10 00 00       	call   801123 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 a0 22 80 00       	push   $0x8022a0
  80006c:	e8 1b 02 00 00       	call   80028c <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 30 80 00    	pushl  0x803004
  80007a:	e8 d8 07 00 00       	call   800857 <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 30 80 00    	pushl  0x803004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 cd 08 00 00       	call   800960 <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 b4 22 80 00       	push   $0x8022b4
  8000a2:	e8 e5 01 00 00       	call   80028c <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 30 80 00    	pushl  0x803000
  8000b3:	e8 9f 07 00 00       	call   800857 <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 30 80 00    	pushl  0x803000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 bb 09 00 00       	call   800a8a <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 ac 10 00 00       	call   80118c <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ed:	8b 40 48             	mov    0x48(%eax),%eax
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	6a 07                	push   $0x7
  8000f5:	68 00 00 a0 00       	push   $0xa00000
  8000fa:	50                   	push   %eax
  8000fb:	e8 93 0b 00 00       	call   800c93 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800100:	83 c4 04             	add    $0x4,%esp
  800103:	ff 35 04 30 80 00    	pushl  0x803004
  800109:	e8 49 07 00 00       	call   800857 <strlen>
  80010e:	83 c4 0c             	add    $0xc,%esp
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	50                   	push   %eax
  800115:	ff 35 04 30 80 00    	pushl  0x803004
  80011b:	68 00 00 a0 00       	push   $0xa00000
  800120:	e8 65 09 00 00       	call   800a8a <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800125:	6a 07                	push   $0x7
  800127:	68 00 00 a0 00       	push   $0xa00000
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 f4             	pushl  -0xc(%ebp)
  800131:	e8 56 10 00 00       	call   80118c <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 da 0f 00 00       	call   801123 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 a0 22 80 00       	push   $0x8022a0
  800159:	e8 2e 01 00 00       	call   80028c <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 35 00 30 80 00    	pushl  0x803000
  800167:	e8 eb 06 00 00       	call   800857 <strlen>
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	ff 35 00 30 80 00    	pushl  0x803000
  800176:	68 00 00 a0 00       	push   $0xa00000
  80017b:	e8 e0 07 00 00       	call   800960 <strncmp>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	75 10                	jne    800197 <umain+0x164>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 d4 22 80 00       	push   $0x8022d4
  80018f:	e8 f8 00 00 00       	call   80028c <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp
	return;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a1:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8001a4:	e8 ac 0a 00 00       	call   800c55 <sys_getenvid>
  8001a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001b1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001b6:	a3 04 40 80 00       	mov    %eax,0x804004

    // save the name of the program so that panic() can use it
    if (argc > 0)
  8001bb:	85 db                	test   %ebx,%ebx
  8001bd:	7e 07                	jle    8001c6 <libmain+0x2d>
        binaryname = argv[0];
  8001bf:	8b 06                	mov    (%esi),%eax
  8001c1:	a3 08 30 80 00       	mov    %eax,0x803008

    // call user main routine
    umain(argc, argv);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	e8 63 fe ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  8001d0:	e8 0a 00 00 00       	call   8001df <exit>
}
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001e5:	e8 fa 11 00 00       	call   8013e4 <close_all>
	sys_env_destroy(0);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	6a 00                	push   $0x0
  8001ef:	e8 20 0a 00 00       	call   800c14 <sys_env_destroy>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	c9                   	leave  
  8001f8:	c3                   	ret    

008001f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	53                   	push   %ebx
  8001fd:	83 ec 04             	sub    $0x4,%esp
  800200:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800203:	8b 13                	mov    (%ebx),%edx
  800205:	8d 42 01             	lea    0x1(%edx),%eax
  800208:	89 03                	mov    %eax,(%ebx)
  80020a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800211:	3d ff 00 00 00       	cmp    $0xff,%eax
  800216:	75 1a                	jne    800232 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800218:	83 ec 08             	sub    $0x8,%esp
  80021b:	68 ff 00 00 00       	push   $0xff
  800220:	8d 43 08             	lea    0x8(%ebx),%eax
  800223:	50                   	push   %eax
  800224:	e8 ae 09 00 00       	call   800bd7 <sys_cputs>
		b->idx = 0;
  800229:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80022f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800232:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800236:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800244:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024b:	00 00 00 
	b.cnt = 0;
  80024e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800255:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800258:	ff 75 0c             	pushl  0xc(%ebp)
  80025b:	ff 75 08             	pushl  0x8(%ebp)
  80025e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800264:	50                   	push   %eax
  800265:	68 f9 01 80 00       	push   $0x8001f9
  80026a:	e8 1a 01 00 00       	call   800389 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026f:	83 c4 08             	add    $0x8,%esp
  800272:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800278:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027e:	50                   	push   %eax
  80027f:	e8 53 09 00 00       	call   800bd7 <sys_cputs>

	return b.cnt;
}
  800284:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800292:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800295:	50                   	push   %eax
  800296:	ff 75 08             	pushl  0x8(%ebp)
  800299:	e8 9d ff ff ff       	call   80023b <vcprintf>
	va_end(ap);

	return cnt;
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 1c             	sub    $0x1c,%esp
  8002a9:	89 c7                	mov    %eax,%edi
  8002ab:	89 d6                	mov    %edx,%esi
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002c4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002c7:	39 d3                	cmp    %edx,%ebx
  8002c9:	72 05                	jb     8002d0 <printnum+0x30>
  8002cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ce:	77 45                	ja     800315 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	ff 75 18             	pushl  0x18(%ebp)
  8002d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002dc:	53                   	push   %ebx
  8002dd:	ff 75 10             	pushl  0x10(%ebp)
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ef:	e8 1c 1d 00 00       	call   802010 <__udivdi3>
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	52                   	push   %edx
  8002f8:	50                   	push   %eax
  8002f9:	89 f2                	mov    %esi,%edx
  8002fb:	89 f8                	mov    %edi,%eax
  8002fd:	e8 9e ff ff ff       	call   8002a0 <printnum>
  800302:	83 c4 20             	add    $0x20,%esp
  800305:	eb 18                	jmp    80031f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	56                   	push   %esi
  80030b:	ff 75 18             	pushl  0x18(%ebp)
  80030e:	ff d7                	call   *%edi
  800310:	83 c4 10             	add    $0x10,%esp
  800313:	eb 03                	jmp    800318 <printnum+0x78>
  800315:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800318:	83 eb 01             	sub    $0x1,%ebx
  80031b:	85 db                	test   %ebx,%ebx
  80031d:	7f e8                	jg     800307 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031f:	83 ec 08             	sub    $0x8,%esp
  800322:	56                   	push   %esi
  800323:	83 ec 04             	sub    $0x4,%esp
  800326:	ff 75 e4             	pushl  -0x1c(%ebp)
  800329:	ff 75 e0             	pushl  -0x20(%ebp)
  80032c:	ff 75 dc             	pushl  -0x24(%ebp)
  80032f:	ff 75 d8             	pushl  -0x28(%ebp)
  800332:	e8 09 1e 00 00       	call   802140 <__umoddi3>
  800337:	83 c4 14             	add    $0x14,%esp
  80033a:	0f be 80 4c 23 80 00 	movsbl 0x80234c(%eax),%eax
  800341:	50                   	push   %eax
  800342:	ff d7                	call   *%edi
}
  800344:	83 c4 10             	add    $0x10,%esp
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800355:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	3b 50 04             	cmp    0x4(%eax),%edx
  80035e:	73 0a                	jae    80036a <sprintputch+0x1b>
		*b->buf++ = ch;
  800360:	8d 4a 01             	lea    0x1(%edx),%ecx
  800363:	89 08                	mov    %ecx,(%eax)
  800365:	8b 45 08             	mov    0x8(%ebp),%eax
  800368:	88 02                	mov    %al,(%edx)
}
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800372:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800375:	50                   	push   %eax
  800376:	ff 75 10             	pushl  0x10(%ebp)
  800379:	ff 75 0c             	pushl  0xc(%ebp)
  80037c:	ff 75 08             	pushl  0x8(%ebp)
  80037f:	e8 05 00 00 00       	call   800389 <vprintfmt>
	va_end(ap);
}
  800384:	83 c4 10             	add    $0x10,%esp
  800387:	c9                   	leave  
  800388:	c3                   	ret    

00800389 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	57                   	push   %edi
  80038d:	56                   	push   %esi
  80038e:	53                   	push   %ebx
  80038f:	83 ec 2c             	sub    $0x2c,%esp
  800392:	8b 75 08             	mov    0x8(%ebp),%esi
  800395:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800398:	8b 7d 10             	mov    0x10(%ebp),%edi
  80039b:	eb 12                	jmp    8003af <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80039d:	85 c0                	test   %eax,%eax
  80039f:	0f 84 42 04 00 00    	je     8007e7 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8003a5:	83 ec 08             	sub    $0x8,%esp
  8003a8:	53                   	push   %ebx
  8003a9:	50                   	push   %eax
  8003aa:	ff d6                	call   *%esi
  8003ac:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003af:	83 c7 01             	add    $0x1,%edi
  8003b2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003b6:	83 f8 25             	cmp    $0x25,%eax
  8003b9:	75 e2                	jne    80039d <vprintfmt+0x14>
  8003bb:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003bf:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003c6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003cd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d9:	eb 07                	jmp    8003e2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003de:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8d 47 01             	lea    0x1(%edi),%eax
  8003e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e8:	0f b6 07             	movzbl (%edi),%eax
  8003eb:	0f b6 d0             	movzbl %al,%edx
  8003ee:	83 e8 23             	sub    $0x23,%eax
  8003f1:	3c 55                	cmp    $0x55,%al
  8003f3:	0f 87 d3 03 00 00    	ja     8007cc <vprintfmt+0x443>
  8003f9:	0f b6 c0             	movzbl %al,%eax
  8003fc:	ff 24 85 80 24 80 00 	jmp    *0x802480(,%eax,4)
  800403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800406:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80040a:	eb d6                	jmp    8003e2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040f:	b8 00 00 00 00       	mov    $0x0,%eax
  800414:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800417:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80041a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80041e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800421:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800424:	83 f9 09             	cmp    $0x9,%ecx
  800427:	77 3f                	ja     800468 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800429:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80042c:	eb e9                	jmp    800417 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8b 00                	mov    (%eax),%eax
  800433:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 40 04             	lea    0x4(%eax),%eax
  80043c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800442:	eb 2a                	jmp    80046e <vprintfmt+0xe5>
  800444:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800447:	85 c0                	test   %eax,%eax
  800449:	ba 00 00 00 00       	mov    $0x0,%edx
  80044e:	0f 49 d0             	cmovns %eax,%edx
  800451:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800457:	eb 89                	jmp    8003e2 <vprintfmt+0x59>
  800459:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80045c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800463:	e9 7a ff ff ff       	jmp    8003e2 <vprintfmt+0x59>
  800468:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80046b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80046e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800472:	0f 89 6a ff ff ff    	jns    8003e2 <vprintfmt+0x59>
				width = precision, precision = -1;
  800478:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80047b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800485:	e9 58 ff ff ff       	jmp    8003e2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048a:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800490:	e9 4d ff ff ff       	jmp    8003e2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	8d 78 04             	lea    0x4(%eax),%edi
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	53                   	push   %ebx
  80049f:	ff 30                	pushl  (%eax)
  8004a1:	ff d6                	call   *%esi
			break;
  8004a3:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a6:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004ac:	e9 fe fe ff ff       	jmp    8003af <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b4:	8d 78 04             	lea    0x4(%eax),%edi
  8004b7:	8b 00                	mov    (%eax),%eax
  8004b9:	99                   	cltd   
  8004ba:	31 d0                	xor    %edx,%eax
  8004bc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004be:	83 f8 0f             	cmp    $0xf,%eax
  8004c1:	7f 0b                	jg     8004ce <vprintfmt+0x145>
  8004c3:	8b 14 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%edx
  8004ca:	85 d2                	test   %edx,%edx
  8004cc:	75 1b                	jne    8004e9 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8004ce:	50                   	push   %eax
  8004cf:	68 64 23 80 00       	push   $0x802364
  8004d4:	53                   	push   %ebx
  8004d5:	56                   	push   %esi
  8004d6:	e8 91 fe ff ff       	call   80036c <printfmt>
  8004db:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004de:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004e4:	e9 c6 fe ff ff       	jmp    8003af <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004e9:	52                   	push   %edx
  8004ea:	68 d5 27 80 00       	push   $0x8027d5
  8004ef:	53                   	push   %ebx
  8004f0:	56                   	push   %esi
  8004f1:	e8 76 fe ff ff       	call   80036c <printfmt>
  8004f6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004f9:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ff:	e9 ab fe ff ff       	jmp    8003af <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	83 c0 04             	add    $0x4,%eax
  80050a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800512:	85 ff                	test   %edi,%edi
  800514:	b8 5d 23 80 00       	mov    $0x80235d,%eax
  800519:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80051c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800520:	0f 8e 94 00 00 00    	jle    8005ba <vprintfmt+0x231>
  800526:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80052a:	0f 84 98 00 00 00    	je     8005c8 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	ff 75 d0             	pushl  -0x30(%ebp)
  800536:	57                   	push   %edi
  800537:	e8 33 03 00 00       	call   80086f <strnlen>
  80053c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80053f:	29 c1                	sub    %eax,%ecx
  800541:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800544:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800547:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80054b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80054e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800551:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800553:	eb 0f                	jmp    800564 <vprintfmt+0x1db>
					putch(padc, putdat);
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	53                   	push   %ebx
  800559:	ff 75 e0             	pushl  -0x20(%ebp)
  80055c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055e:	83 ef 01             	sub    $0x1,%edi
  800561:	83 c4 10             	add    $0x10,%esp
  800564:	85 ff                	test   %edi,%edi
  800566:	7f ed                	jg     800555 <vprintfmt+0x1cc>
  800568:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80056b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80056e:	85 c9                	test   %ecx,%ecx
  800570:	b8 00 00 00 00       	mov    $0x0,%eax
  800575:	0f 49 c1             	cmovns %ecx,%eax
  800578:	29 c1                	sub    %eax,%ecx
  80057a:	89 75 08             	mov    %esi,0x8(%ebp)
  80057d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800580:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800583:	89 cb                	mov    %ecx,%ebx
  800585:	eb 4d                	jmp    8005d4 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800587:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80058b:	74 1b                	je     8005a8 <vprintfmt+0x21f>
  80058d:	0f be c0             	movsbl %al,%eax
  800590:	83 e8 20             	sub    $0x20,%eax
  800593:	83 f8 5e             	cmp    $0x5e,%eax
  800596:	76 10                	jbe    8005a8 <vprintfmt+0x21f>
					putch('?', putdat);
  800598:	83 ec 08             	sub    $0x8,%esp
  80059b:	ff 75 0c             	pushl  0xc(%ebp)
  80059e:	6a 3f                	push   $0x3f
  8005a0:	ff 55 08             	call   *0x8(%ebp)
  8005a3:	83 c4 10             	add    $0x10,%esp
  8005a6:	eb 0d                	jmp    8005b5 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	ff 75 0c             	pushl  0xc(%ebp)
  8005ae:	52                   	push   %edx
  8005af:	ff 55 08             	call   *0x8(%ebp)
  8005b2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b5:	83 eb 01             	sub    $0x1,%ebx
  8005b8:	eb 1a                	jmp    8005d4 <vprintfmt+0x24b>
  8005ba:	89 75 08             	mov    %esi,0x8(%ebp)
  8005bd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005c3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005c6:	eb 0c                	jmp    8005d4 <vprintfmt+0x24b>
  8005c8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005cb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ce:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d4:	83 c7 01             	add    $0x1,%edi
  8005d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005db:	0f be d0             	movsbl %al,%edx
  8005de:	85 d2                	test   %edx,%edx
  8005e0:	74 23                	je     800605 <vprintfmt+0x27c>
  8005e2:	85 f6                	test   %esi,%esi
  8005e4:	78 a1                	js     800587 <vprintfmt+0x1fe>
  8005e6:	83 ee 01             	sub    $0x1,%esi
  8005e9:	79 9c                	jns    800587 <vprintfmt+0x1fe>
  8005eb:	89 df                	mov    %ebx,%edi
  8005ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f3:	eb 18                	jmp    80060d <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	53                   	push   %ebx
  8005f9:	6a 20                	push   $0x20
  8005fb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005fd:	83 ef 01             	sub    $0x1,%edi
  800600:	83 c4 10             	add    $0x10,%esp
  800603:	eb 08                	jmp    80060d <vprintfmt+0x284>
  800605:	89 df                	mov    %ebx,%edi
  800607:	8b 75 08             	mov    0x8(%ebp),%esi
  80060a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80060d:	85 ff                	test   %edi,%edi
  80060f:	7f e4                	jg     8005f5 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800611:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800614:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800617:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061a:	e9 90 fd ff ff       	jmp    8003af <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061f:	83 f9 01             	cmp    $0x1,%ecx
  800622:	7e 19                	jle    80063d <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8b 50 04             	mov    0x4(%eax),%edx
  80062a:	8b 00                	mov    (%eax),%eax
  80062c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 40 08             	lea    0x8(%eax),%eax
  800638:	89 45 14             	mov    %eax,0x14(%ebp)
  80063b:	eb 38                	jmp    800675 <vprintfmt+0x2ec>
	else if (lflag)
  80063d:	85 c9                	test   %ecx,%ecx
  80063f:	74 1b                	je     80065c <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8b 00                	mov    (%eax),%eax
  800646:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800649:	89 c1                	mov    %eax,%ecx
  80064b:	c1 f9 1f             	sar    $0x1f,%ecx
  80064e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8d 40 04             	lea    0x4(%eax),%eax
  800657:	89 45 14             	mov    %eax,0x14(%ebp)
  80065a:	eb 19                	jmp    800675 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800664:	89 c1                	mov    %eax,%ecx
  800666:	c1 f9 1f             	sar    $0x1f,%ecx
  800669:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8d 40 04             	lea    0x4(%eax),%eax
  800672:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800675:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800678:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80067b:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800680:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800684:	0f 89 0e 01 00 00    	jns    800798 <vprintfmt+0x40f>
				putch('-', putdat);
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	53                   	push   %ebx
  80068e:	6a 2d                	push   $0x2d
  800690:	ff d6                	call   *%esi
				num = -(long long) num;
  800692:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800695:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800698:	f7 da                	neg    %edx
  80069a:	83 d1 00             	adc    $0x0,%ecx
  80069d:	f7 d9                	neg    %ecx
  80069f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006a2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a7:	e9 ec 00 00 00       	jmp    800798 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ac:	83 f9 01             	cmp    $0x1,%ecx
  8006af:	7e 18                	jle    8006c9 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8b 10                	mov    (%eax),%edx
  8006b6:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b9:	8d 40 08             	lea    0x8(%eax),%eax
  8006bc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c4:	e9 cf 00 00 00       	jmp    800798 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006c9:	85 c9                	test   %ecx,%ecx
  8006cb:	74 1a                	je     8006e7 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8b 10                	mov    (%eax),%edx
  8006d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d7:	8d 40 04             	lea    0x4(%eax),%eax
  8006da:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006dd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e2:	e9 b1 00 00 00       	jmp    800798 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8b 10                	mov    (%eax),%edx
  8006ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f1:	8d 40 04             	lea    0x4(%eax),%eax
  8006f4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006fc:	e9 97 00 00 00       	jmp    800798 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800701:	83 ec 08             	sub    $0x8,%esp
  800704:	53                   	push   %ebx
  800705:	6a 58                	push   $0x58
  800707:	ff d6                	call   *%esi
			putch('X', putdat);
  800709:	83 c4 08             	add    $0x8,%esp
  80070c:	53                   	push   %ebx
  80070d:	6a 58                	push   $0x58
  80070f:	ff d6                	call   *%esi
			putch('X', putdat);
  800711:	83 c4 08             	add    $0x8,%esp
  800714:	53                   	push   %ebx
  800715:	6a 58                	push   $0x58
  800717:	ff d6                	call   *%esi
			break;
  800719:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80071f:	e9 8b fc ff ff       	jmp    8003af <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	53                   	push   %ebx
  800728:	6a 30                	push   $0x30
  80072a:	ff d6                	call   *%esi
			putch('x', putdat);
  80072c:	83 c4 08             	add    $0x8,%esp
  80072f:	53                   	push   %ebx
  800730:	6a 78                	push   $0x78
  800732:	ff d6                	call   *%esi
			num = (unsigned long long)
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8b 10                	mov    (%eax),%edx
  800739:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80073e:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800741:	8d 40 04             	lea    0x4(%eax),%eax
  800744:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800747:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80074c:	eb 4a                	jmp    800798 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80074e:	83 f9 01             	cmp    $0x1,%ecx
  800751:	7e 15                	jle    800768 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800753:	8b 45 14             	mov    0x14(%ebp),%eax
  800756:	8b 10                	mov    (%eax),%edx
  800758:	8b 48 04             	mov    0x4(%eax),%ecx
  80075b:	8d 40 08             	lea    0x8(%eax),%eax
  80075e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800761:	b8 10 00 00 00       	mov    $0x10,%eax
  800766:	eb 30                	jmp    800798 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800768:	85 c9                	test   %ecx,%ecx
  80076a:	74 17                	je     800783 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8b 10                	mov    (%eax),%edx
  800771:	b9 00 00 00 00       	mov    $0x0,%ecx
  800776:	8d 40 04             	lea    0x4(%eax),%eax
  800779:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80077c:	b8 10 00 00 00       	mov    $0x10,%eax
  800781:	eb 15                	jmp    800798 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8b 10                	mov    (%eax),%edx
  800788:	b9 00 00 00 00       	mov    $0x0,%ecx
  80078d:	8d 40 04             	lea    0x4(%eax),%eax
  800790:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800793:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800798:	83 ec 0c             	sub    $0xc,%esp
  80079b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80079f:	57                   	push   %edi
  8007a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a3:	50                   	push   %eax
  8007a4:	51                   	push   %ecx
  8007a5:	52                   	push   %edx
  8007a6:	89 da                	mov    %ebx,%edx
  8007a8:	89 f0                	mov    %esi,%eax
  8007aa:	e8 f1 fa ff ff       	call   8002a0 <printnum>
			break;
  8007af:	83 c4 20             	add    $0x20,%esp
  8007b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b5:	e9 f5 fb ff ff       	jmp    8003af <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ba:	83 ec 08             	sub    $0x8,%esp
  8007bd:	53                   	push   %ebx
  8007be:	52                   	push   %edx
  8007bf:	ff d6                	call   *%esi
			break;
  8007c1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007c7:	e9 e3 fb ff ff       	jmp    8003af <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	53                   	push   %ebx
  8007d0:	6a 25                	push   $0x25
  8007d2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d4:	83 c4 10             	add    $0x10,%esp
  8007d7:	eb 03                	jmp    8007dc <vprintfmt+0x453>
  8007d9:	83 ef 01             	sub    $0x1,%edi
  8007dc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e0:	75 f7                	jne    8007d9 <vprintfmt+0x450>
  8007e2:	e9 c8 fb ff ff       	jmp    8003af <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ea:	5b                   	pop    %ebx
  8007eb:	5e                   	pop    %esi
  8007ec:	5f                   	pop    %edi
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	83 ec 18             	sub    $0x18,%esp
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007fe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800802:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800805:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80080c:	85 c0                	test   %eax,%eax
  80080e:	74 26                	je     800836 <vsnprintf+0x47>
  800810:	85 d2                	test   %edx,%edx
  800812:	7e 22                	jle    800836 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800814:	ff 75 14             	pushl  0x14(%ebp)
  800817:	ff 75 10             	pushl  0x10(%ebp)
  80081a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80081d:	50                   	push   %eax
  80081e:	68 4f 03 80 00       	push   $0x80034f
  800823:	e8 61 fb ff ff       	call   800389 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800828:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80082e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800831:	83 c4 10             	add    $0x10,%esp
  800834:	eb 05                	jmp    80083b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800836:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80083b:	c9                   	leave  
  80083c:	c3                   	ret    

0080083d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800843:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800846:	50                   	push   %eax
  800847:	ff 75 10             	pushl  0x10(%ebp)
  80084a:	ff 75 0c             	pushl  0xc(%ebp)
  80084d:	ff 75 08             	pushl  0x8(%ebp)
  800850:	e8 9a ff ff ff       	call   8007ef <vsnprintf>
	va_end(ap);

	return rc;
}
  800855:	c9                   	leave  
  800856:	c3                   	ret    

00800857 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80085d:	b8 00 00 00 00       	mov    $0x0,%eax
  800862:	eb 03                	jmp    800867 <strlen+0x10>
		n++;
  800864:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800867:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80086b:	75 f7                	jne    800864 <strlen+0xd>
		n++;
	return n;
}
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800875:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800878:	ba 00 00 00 00       	mov    $0x0,%edx
  80087d:	eb 03                	jmp    800882 <strnlen+0x13>
		n++;
  80087f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800882:	39 c2                	cmp    %eax,%edx
  800884:	74 08                	je     80088e <strnlen+0x1f>
  800886:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80088a:	75 f3                	jne    80087f <strnlen+0x10>
  80088c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	53                   	push   %ebx
  800894:	8b 45 08             	mov    0x8(%ebp),%eax
  800897:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089a:	89 c2                	mov    %eax,%edx
  80089c:	83 c2 01             	add    $0x1,%edx
  80089f:	83 c1 01             	add    $0x1,%ecx
  8008a2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008a6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008a9:	84 db                	test   %bl,%bl
  8008ab:	75 ef                	jne    80089c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008ad:	5b                   	pop    %ebx
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	53                   	push   %ebx
  8008b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b7:	53                   	push   %ebx
  8008b8:	e8 9a ff ff ff       	call   800857 <strlen>
  8008bd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008c0:	ff 75 0c             	pushl  0xc(%ebp)
  8008c3:	01 d8                	add    %ebx,%eax
  8008c5:	50                   	push   %eax
  8008c6:	e8 c5 ff ff ff       	call   800890 <strcpy>
	return dst;
}
  8008cb:	89 d8                	mov    %ebx,%eax
  8008cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d0:	c9                   	leave  
  8008d1:	c3                   	ret    

008008d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	56                   	push   %esi
  8008d6:	53                   	push   %ebx
  8008d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008dd:	89 f3                	mov    %esi,%ebx
  8008df:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e2:	89 f2                	mov    %esi,%edx
  8008e4:	eb 0f                	jmp    8008f5 <strncpy+0x23>
		*dst++ = *src;
  8008e6:	83 c2 01             	add    $0x1,%edx
  8008e9:	0f b6 01             	movzbl (%ecx),%eax
  8008ec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ef:	80 39 01             	cmpb   $0x1,(%ecx)
  8008f2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f5:	39 da                	cmp    %ebx,%edx
  8008f7:	75 ed                	jne    8008e6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008f9:	89 f0                	mov    %esi,%eax
  8008fb:	5b                   	pop    %ebx
  8008fc:	5e                   	pop    %esi
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	56                   	push   %esi
  800903:	53                   	push   %ebx
  800904:	8b 75 08             	mov    0x8(%ebp),%esi
  800907:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090a:	8b 55 10             	mov    0x10(%ebp),%edx
  80090d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80090f:	85 d2                	test   %edx,%edx
  800911:	74 21                	je     800934 <strlcpy+0x35>
  800913:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800917:	89 f2                	mov    %esi,%edx
  800919:	eb 09                	jmp    800924 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80091b:	83 c2 01             	add    $0x1,%edx
  80091e:	83 c1 01             	add    $0x1,%ecx
  800921:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800924:	39 c2                	cmp    %eax,%edx
  800926:	74 09                	je     800931 <strlcpy+0x32>
  800928:	0f b6 19             	movzbl (%ecx),%ebx
  80092b:	84 db                	test   %bl,%bl
  80092d:	75 ec                	jne    80091b <strlcpy+0x1c>
  80092f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800931:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800934:	29 f0                	sub    %esi,%eax
}
  800936:	5b                   	pop    %ebx
  800937:	5e                   	pop    %esi
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800940:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800943:	eb 06                	jmp    80094b <strcmp+0x11>
		p++, q++;
  800945:	83 c1 01             	add    $0x1,%ecx
  800948:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80094b:	0f b6 01             	movzbl (%ecx),%eax
  80094e:	84 c0                	test   %al,%al
  800950:	74 04                	je     800956 <strcmp+0x1c>
  800952:	3a 02                	cmp    (%edx),%al
  800954:	74 ef                	je     800945 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800956:	0f b6 c0             	movzbl %al,%eax
  800959:	0f b6 12             	movzbl (%edx),%edx
  80095c:	29 d0                	sub    %edx,%eax
}
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	53                   	push   %ebx
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096a:	89 c3                	mov    %eax,%ebx
  80096c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80096f:	eb 06                	jmp    800977 <strncmp+0x17>
		n--, p++, q++;
  800971:	83 c0 01             	add    $0x1,%eax
  800974:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800977:	39 d8                	cmp    %ebx,%eax
  800979:	74 15                	je     800990 <strncmp+0x30>
  80097b:	0f b6 08             	movzbl (%eax),%ecx
  80097e:	84 c9                	test   %cl,%cl
  800980:	74 04                	je     800986 <strncmp+0x26>
  800982:	3a 0a                	cmp    (%edx),%cl
  800984:	74 eb                	je     800971 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800986:	0f b6 00             	movzbl (%eax),%eax
  800989:	0f b6 12             	movzbl (%edx),%edx
  80098c:	29 d0                	sub    %edx,%eax
  80098e:	eb 05                	jmp    800995 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800990:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800995:	5b                   	pop    %ebx
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a2:	eb 07                	jmp    8009ab <strchr+0x13>
		if (*s == c)
  8009a4:	38 ca                	cmp    %cl,%dl
  8009a6:	74 0f                	je     8009b7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009a8:	83 c0 01             	add    $0x1,%eax
  8009ab:	0f b6 10             	movzbl (%eax),%edx
  8009ae:	84 d2                	test   %dl,%dl
  8009b0:	75 f2                	jne    8009a4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c3:	eb 03                	jmp    8009c8 <strfind+0xf>
  8009c5:	83 c0 01             	add    $0x1,%eax
  8009c8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009cb:	38 ca                	cmp    %cl,%dl
  8009cd:	74 04                	je     8009d3 <strfind+0x1a>
  8009cf:	84 d2                	test   %dl,%dl
  8009d1:	75 f2                	jne    8009c5 <strfind+0xc>
			break;
	return (char *) s;
}
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	57                   	push   %edi
  8009d9:	56                   	push   %esi
  8009da:	53                   	push   %ebx
  8009db:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009de:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009e1:	85 c9                	test   %ecx,%ecx
  8009e3:	74 36                	je     800a1b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009eb:	75 28                	jne    800a15 <memset+0x40>
  8009ed:	f6 c1 03             	test   $0x3,%cl
  8009f0:	75 23                	jne    800a15 <memset+0x40>
		c &= 0xFF;
  8009f2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009f6:	89 d3                	mov    %edx,%ebx
  8009f8:	c1 e3 08             	shl    $0x8,%ebx
  8009fb:	89 d6                	mov    %edx,%esi
  8009fd:	c1 e6 18             	shl    $0x18,%esi
  800a00:	89 d0                	mov    %edx,%eax
  800a02:	c1 e0 10             	shl    $0x10,%eax
  800a05:	09 f0                	or     %esi,%eax
  800a07:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a09:	89 d8                	mov    %ebx,%eax
  800a0b:	09 d0                	or     %edx,%eax
  800a0d:	c1 e9 02             	shr    $0x2,%ecx
  800a10:	fc                   	cld    
  800a11:	f3 ab                	rep stos %eax,%es:(%edi)
  800a13:	eb 06                	jmp    800a1b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a18:	fc                   	cld    
  800a19:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a1b:	89 f8                	mov    %edi,%eax
  800a1d:	5b                   	pop    %ebx
  800a1e:	5e                   	pop    %esi
  800a1f:	5f                   	pop    %edi
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	57                   	push   %edi
  800a26:	56                   	push   %esi
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a2d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a30:	39 c6                	cmp    %eax,%esi
  800a32:	73 35                	jae    800a69 <memmove+0x47>
  800a34:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a37:	39 d0                	cmp    %edx,%eax
  800a39:	73 2e                	jae    800a69 <memmove+0x47>
		s += n;
		d += n;
  800a3b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3e:	89 d6                	mov    %edx,%esi
  800a40:	09 fe                	or     %edi,%esi
  800a42:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a48:	75 13                	jne    800a5d <memmove+0x3b>
  800a4a:	f6 c1 03             	test   $0x3,%cl
  800a4d:	75 0e                	jne    800a5d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a4f:	83 ef 04             	sub    $0x4,%edi
  800a52:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a55:	c1 e9 02             	shr    $0x2,%ecx
  800a58:	fd                   	std    
  800a59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5b:	eb 09                	jmp    800a66 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a5d:	83 ef 01             	sub    $0x1,%edi
  800a60:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a63:	fd                   	std    
  800a64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a66:	fc                   	cld    
  800a67:	eb 1d                	jmp    800a86 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a69:	89 f2                	mov    %esi,%edx
  800a6b:	09 c2                	or     %eax,%edx
  800a6d:	f6 c2 03             	test   $0x3,%dl
  800a70:	75 0f                	jne    800a81 <memmove+0x5f>
  800a72:	f6 c1 03             	test   $0x3,%cl
  800a75:	75 0a                	jne    800a81 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a77:	c1 e9 02             	shr    $0x2,%ecx
  800a7a:	89 c7                	mov    %eax,%edi
  800a7c:	fc                   	cld    
  800a7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7f:	eb 05                	jmp    800a86 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a81:	89 c7                	mov    %eax,%edi
  800a83:	fc                   	cld    
  800a84:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a86:	5e                   	pop    %esi
  800a87:	5f                   	pop    %edi
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a8d:	ff 75 10             	pushl  0x10(%ebp)
  800a90:	ff 75 0c             	pushl  0xc(%ebp)
  800a93:	ff 75 08             	pushl  0x8(%ebp)
  800a96:	e8 87 ff ff ff       	call   800a22 <memmove>
}
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
  800aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa8:	89 c6                	mov    %eax,%esi
  800aaa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aad:	eb 1a                	jmp    800ac9 <memcmp+0x2c>
		if (*s1 != *s2)
  800aaf:	0f b6 08             	movzbl (%eax),%ecx
  800ab2:	0f b6 1a             	movzbl (%edx),%ebx
  800ab5:	38 d9                	cmp    %bl,%cl
  800ab7:	74 0a                	je     800ac3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ab9:	0f b6 c1             	movzbl %cl,%eax
  800abc:	0f b6 db             	movzbl %bl,%ebx
  800abf:	29 d8                	sub    %ebx,%eax
  800ac1:	eb 0f                	jmp    800ad2 <memcmp+0x35>
		s1++, s2++;
  800ac3:	83 c0 01             	add    $0x1,%eax
  800ac6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac9:	39 f0                	cmp    %esi,%eax
  800acb:	75 e2                	jne    800aaf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	53                   	push   %ebx
  800ada:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800add:	89 c1                	mov    %eax,%ecx
  800adf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae6:	eb 0a                	jmp    800af2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae8:	0f b6 10             	movzbl (%eax),%edx
  800aeb:	39 da                	cmp    %ebx,%edx
  800aed:	74 07                	je     800af6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aef:	83 c0 01             	add    $0x1,%eax
  800af2:	39 c8                	cmp    %ecx,%eax
  800af4:	72 f2                	jb     800ae8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af6:	5b                   	pop    %ebx
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	57                   	push   %edi
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
  800aff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b05:	eb 03                	jmp    800b0a <strtol+0x11>
		s++;
  800b07:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0a:	0f b6 01             	movzbl (%ecx),%eax
  800b0d:	3c 20                	cmp    $0x20,%al
  800b0f:	74 f6                	je     800b07 <strtol+0xe>
  800b11:	3c 09                	cmp    $0x9,%al
  800b13:	74 f2                	je     800b07 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b15:	3c 2b                	cmp    $0x2b,%al
  800b17:	75 0a                	jne    800b23 <strtol+0x2a>
		s++;
  800b19:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b1c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b21:	eb 11                	jmp    800b34 <strtol+0x3b>
  800b23:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b28:	3c 2d                	cmp    $0x2d,%al
  800b2a:	75 08                	jne    800b34 <strtol+0x3b>
		s++, neg = 1;
  800b2c:	83 c1 01             	add    $0x1,%ecx
  800b2f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b34:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b3a:	75 15                	jne    800b51 <strtol+0x58>
  800b3c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b3f:	75 10                	jne    800b51 <strtol+0x58>
  800b41:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b45:	75 7c                	jne    800bc3 <strtol+0xca>
		s += 2, base = 16;
  800b47:	83 c1 02             	add    $0x2,%ecx
  800b4a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b4f:	eb 16                	jmp    800b67 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b51:	85 db                	test   %ebx,%ebx
  800b53:	75 12                	jne    800b67 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b55:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b5a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b5d:	75 08                	jne    800b67 <strtol+0x6e>
		s++, base = 8;
  800b5f:	83 c1 01             	add    $0x1,%ecx
  800b62:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b67:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b6f:	0f b6 11             	movzbl (%ecx),%edx
  800b72:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b75:	89 f3                	mov    %esi,%ebx
  800b77:	80 fb 09             	cmp    $0x9,%bl
  800b7a:	77 08                	ja     800b84 <strtol+0x8b>
			dig = *s - '0';
  800b7c:	0f be d2             	movsbl %dl,%edx
  800b7f:	83 ea 30             	sub    $0x30,%edx
  800b82:	eb 22                	jmp    800ba6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b84:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b87:	89 f3                	mov    %esi,%ebx
  800b89:	80 fb 19             	cmp    $0x19,%bl
  800b8c:	77 08                	ja     800b96 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b8e:	0f be d2             	movsbl %dl,%edx
  800b91:	83 ea 57             	sub    $0x57,%edx
  800b94:	eb 10                	jmp    800ba6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b96:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b99:	89 f3                	mov    %esi,%ebx
  800b9b:	80 fb 19             	cmp    $0x19,%bl
  800b9e:	77 16                	ja     800bb6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ba0:	0f be d2             	movsbl %dl,%edx
  800ba3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ba6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ba9:	7d 0b                	jge    800bb6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bab:	83 c1 01             	add    $0x1,%ecx
  800bae:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bb2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bb4:	eb b9                	jmp    800b6f <strtol+0x76>

	if (endptr)
  800bb6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bba:	74 0d                	je     800bc9 <strtol+0xd0>
		*endptr = (char *) s;
  800bbc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bbf:	89 0e                	mov    %ecx,(%esi)
  800bc1:	eb 06                	jmp    800bc9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc3:	85 db                	test   %ebx,%ebx
  800bc5:	74 98                	je     800b5f <strtol+0x66>
  800bc7:	eb 9e                	jmp    800b67 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bc9:	89 c2                	mov    %eax,%edx
  800bcb:	f7 da                	neg    %edx
  800bcd:	85 ff                	test   %edi,%edi
  800bcf:	0f 45 c2             	cmovne %edx,%eax
}
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdd:	b8 00 00 00 00       	mov    $0x0,%eax
  800be2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be5:	8b 55 08             	mov    0x8(%ebp),%edx
  800be8:	89 c3                	mov    %eax,%ebx
  800bea:	89 c7                	mov    %eax,%edi
  800bec:	89 c6                	mov    %eax,%esi
  800bee:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800c00:	b8 01 00 00 00       	mov    $0x1,%eax
  800c05:	89 d1                	mov    %edx,%ecx
  800c07:	89 d3                	mov    %edx,%ebx
  800c09:	89 d7                	mov    %edx,%edi
  800c0b:	89 d6                	mov    %edx,%esi
  800c0d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
  800c1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c22:	b8 03 00 00 00       	mov    $0x3,%eax
  800c27:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2a:	89 cb                	mov    %ecx,%ebx
  800c2c:	89 cf                	mov    %ecx,%edi
  800c2e:	89 ce                	mov    %ecx,%esi
  800c30:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c32:	85 c0                	test   %eax,%eax
  800c34:	7e 17                	jle    800c4d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c36:	83 ec 0c             	sub    $0xc,%esp
  800c39:	50                   	push   %eax
  800c3a:	6a 03                	push   $0x3
  800c3c:	68 3f 26 80 00       	push   $0x80263f
  800c41:	6a 23                	push   $0x23
  800c43:	68 5c 26 80 00       	push   $0x80265c
  800c48:	e8 b6 12 00 00       	call   801f03 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800c60:	b8 02 00 00 00       	mov    $0x2,%eax
  800c65:	89 d1                	mov    %edx,%ecx
  800c67:	89 d3                	mov    %edx,%ebx
  800c69:	89 d7                	mov    %edx,%edi
  800c6b:	89 d6                	mov    %edx,%esi
  800c6d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <sys_yield>:

void
sys_yield(void)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c84:	89 d1                	mov    %edx,%ecx
  800c86:	89 d3                	mov    %edx,%ebx
  800c88:	89 d7                	mov    %edx,%edi
  800c8a:	89 d6                	mov    %edx,%esi
  800c8c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9c:	be 00 00 00 00       	mov    $0x0,%esi
  800ca1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800caf:	89 f7                	mov    %esi,%edi
  800cb1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7e 17                	jle    800cce <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	83 ec 0c             	sub    $0xc,%esp
  800cba:	50                   	push   %eax
  800cbb:	6a 04                	push   $0x4
  800cbd:	68 3f 26 80 00       	push   $0x80263f
  800cc2:	6a 23                	push   $0x23
  800cc4:	68 5c 26 80 00       	push   $0x80265c
  800cc9:	e8 35 12 00 00       	call   801f03 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	53                   	push   %ebx
  800cdc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdf:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ced:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf0:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	7e 17                	jle    800d10 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf9:	83 ec 0c             	sub    $0xc,%esp
  800cfc:	50                   	push   %eax
  800cfd:	6a 05                	push   $0x5
  800cff:	68 3f 26 80 00       	push   $0x80263f
  800d04:	6a 23                	push   $0x23
  800d06:	68 5c 26 80 00       	push   $0x80265c
  800d0b:	e8 f3 11 00 00       	call   801f03 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d13:	5b                   	pop    %ebx
  800d14:	5e                   	pop    %esi
  800d15:	5f                   	pop    %edi
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    

00800d18 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	57                   	push   %edi
  800d1c:	56                   	push   %esi
  800d1d:	53                   	push   %ebx
  800d1e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d21:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d26:	b8 06 00 00 00       	mov    $0x6,%eax
  800d2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d31:	89 df                	mov    %ebx,%edi
  800d33:	89 de                	mov    %ebx,%esi
  800d35:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d37:	85 c0                	test   %eax,%eax
  800d39:	7e 17                	jle    800d52 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3b:	83 ec 0c             	sub    $0xc,%esp
  800d3e:	50                   	push   %eax
  800d3f:	6a 06                	push   $0x6
  800d41:	68 3f 26 80 00       	push   $0x80263f
  800d46:	6a 23                	push   $0x23
  800d48:	68 5c 26 80 00       	push   $0x80265c
  800d4d:	e8 b1 11 00 00       	call   801f03 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
  800d60:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d68:	b8 08 00 00 00       	mov    $0x8,%eax
  800d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d70:	8b 55 08             	mov    0x8(%ebp),%edx
  800d73:	89 df                	mov    %ebx,%edi
  800d75:	89 de                	mov    %ebx,%esi
  800d77:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7e 17                	jle    800d94 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7d:	83 ec 0c             	sub    $0xc,%esp
  800d80:	50                   	push   %eax
  800d81:	6a 08                	push   $0x8
  800d83:	68 3f 26 80 00       	push   $0x80263f
  800d88:	6a 23                	push   $0x23
  800d8a:	68 5c 26 80 00       	push   $0x80265c
  800d8f:	e8 6f 11 00 00       	call   801f03 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	57                   	push   %edi
  800da0:	56                   	push   %esi
  800da1:	53                   	push   %ebx
  800da2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800daa:	b8 09 00 00 00       	mov    $0x9,%eax
  800daf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	89 df                	mov    %ebx,%edi
  800db7:	89 de                	mov    %ebx,%esi
  800db9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	7e 17                	jle    800dd6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbf:	83 ec 0c             	sub    $0xc,%esp
  800dc2:	50                   	push   %eax
  800dc3:	6a 09                	push   $0x9
  800dc5:	68 3f 26 80 00       	push   $0x80263f
  800dca:	6a 23                	push   $0x23
  800dcc:	68 5c 26 80 00       	push   $0x80265c
  800dd1:	e8 2d 11 00 00       	call   801f03 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    

00800dde <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
  800de4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dec:	b8 0a 00 00 00       	mov    $0xa,%eax
  800df1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	89 df                	mov    %ebx,%edi
  800df9:	89 de                	mov    %ebx,%esi
  800dfb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	7e 17                	jle    800e18 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e01:	83 ec 0c             	sub    $0xc,%esp
  800e04:	50                   	push   %eax
  800e05:	6a 0a                	push   $0xa
  800e07:	68 3f 26 80 00       	push   $0x80263f
  800e0c:	6a 23                	push   $0x23
  800e0e:	68 5c 26 80 00       	push   $0x80265c
  800e13:	e8 eb 10 00 00       	call   801f03 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1b:	5b                   	pop    %ebx
  800e1c:	5e                   	pop    %esi
  800e1d:	5f                   	pop    %edi
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    

00800e20 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	57                   	push   %edi
  800e24:	56                   	push   %esi
  800e25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e26:	be 00 00 00 00       	mov    $0x0,%esi
  800e2b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e33:	8b 55 08             	mov    0x8(%ebp),%edx
  800e36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e39:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e3c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e3e:	5b                   	pop    %ebx
  800e3f:	5e                   	pop    %esi
  800e40:	5f                   	pop    %edi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800e4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e51:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e56:	8b 55 08             	mov    0x8(%ebp),%edx
  800e59:	89 cb                	mov    %ecx,%ebx
  800e5b:	89 cf                	mov    %ecx,%edi
  800e5d:	89 ce                	mov    %ecx,%esi
  800e5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e61:	85 c0                	test   %eax,%eax
  800e63:	7e 17                	jle    800e7c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e65:	83 ec 0c             	sub    $0xc,%esp
  800e68:	50                   	push   %eax
  800e69:	6a 0d                	push   $0xd
  800e6b:	68 3f 26 80 00       	push   $0x80263f
  800e70:	6a 23                	push   $0x23
  800e72:	68 5c 26 80 00       	push   $0x80265c
  800e77:	e8 87 10 00 00       	call   801f03 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5f                   	pop    %edi
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	53                   	push   %ebx
  800e88:	83 ec 04             	sub    $0x4,%esp
  800e8b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e8e:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800e90:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e94:	74 2d                	je     800ec3 <pgfault+0x3f>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800e96:	89 d8                	mov    %ebx,%eax
  800e98:	c1 e8 16             	shr    $0x16,%eax
  800e9b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ea2:	a8 01                	test   $0x1,%al
  800ea4:	74 1d                	je     800ec3 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800ea6:	89 d8                	mov    %ebx,%eax
  800ea8:	c1 e8 0c             	shr    $0xc,%eax
  800eab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800eb2:	f6 c2 01             	test   $0x1,%dl
  800eb5:	74 0c                	je     800ec3 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800eb7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800ebe:	f6 c4 08             	test   $0x8,%ah
  800ec1:	75 14                	jne    800ed7 <pgfault+0x53>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
	)) panic("Neither the fault is a write nor copy-on-write page.\n");
  800ec3:	83 ec 04             	sub    $0x4,%esp
  800ec6:	68 6c 26 80 00       	push   $0x80266c
  800ecb:	6a 1f                	push   $0x1f
  800ecd:	68 a2 26 80 00       	push   $0x8026a2
  800ed2:	e8 2c 10 00 00       	call   801f03 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if((r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W)) < 0){
  800ed7:	83 ec 04             	sub    $0x4,%esp
  800eda:	6a 07                	push   $0x7
  800edc:	68 00 f0 7f 00       	push   $0x7ff000
  800ee1:	6a 00                	push   $0x0
  800ee3:	e8 ab fd ff ff       	call   800c93 <sys_page_alloc>
  800ee8:	83 c4 10             	add    $0x10,%esp
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	79 12                	jns    800f01 <pgfault+0x7d>
		 panic("sys_page_alloc: %e\n", r);
  800eef:	50                   	push   %eax
  800ef0:	68 ad 26 80 00       	push   $0x8026ad
  800ef5:	6a 29                	push   $0x29
  800ef7:	68 a2 26 80 00       	push   $0x8026a2
  800efc:	e8 02 10 00 00       	call   801f03 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f01:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800f07:	83 ec 04             	sub    $0x4,%esp
  800f0a:	68 00 10 00 00       	push   $0x1000
  800f0f:	53                   	push   %ebx
  800f10:	68 00 f0 7f 00       	push   $0x7ff000
  800f15:	e8 70 fb ff ff       	call   800a8a <memcpy>
	if ((r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  800f1a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f21:	53                   	push   %ebx
  800f22:	6a 00                	push   $0x0
  800f24:	68 00 f0 7f 00       	push   $0x7ff000
  800f29:	6a 00                	push   $0x0
  800f2b:	e8 a6 fd ff ff       	call   800cd6 <sys_page_map>
  800f30:	83 c4 20             	add    $0x20,%esp
  800f33:	85 c0                	test   %eax,%eax
  800f35:	79 12                	jns    800f49 <pgfault+0xc5>
        panic("sys_page_map: %e\n", r);
  800f37:	50                   	push   %eax
  800f38:	68 c1 26 80 00       	push   $0x8026c1
  800f3d:	6a 2e                	push   $0x2e
  800f3f:	68 a2 26 80 00       	push   $0x8026a2
  800f44:	e8 ba 0f 00 00       	call   801f03 <_panic>
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  800f49:	83 ec 08             	sub    $0x8,%esp
  800f4c:	68 00 f0 7f 00       	push   $0x7ff000
  800f51:	6a 00                	push   $0x0
  800f53:	e8 c0 fd ff ff       	call   800d18 <sys_page_unmap>
  800f58:	83 c4 10             	add    $0x10,%esp
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	79 12                	jns    800f71 <pgfault+0xed>
        panic("sys_page_unmap: %e\n", r);
  800f5f:	50                   	push   %eax
  800f60:	68 d3 26 80 00       	push   $0x8026d3
  800f65:	6a 30                	push   $0x30
  800f67:	68 a2 26 80 00       	push   $0x8026a2
  800f6c:	e8 92 0f 00 00       	call   801f03 <_panic>
	//panic("pgfault not implemented");
}
  800f71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f74:	c9                   	leave  
  800f75:	c3                   	ret    

00800f76 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	57                   	push   %edi
  800f7a:	56                   	push   %esi
  800f7b:	53                   	push   %ebx
  800f7c:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	envid_t cenvid;
    unsigned pn;
    int r;
	set_pgfault_handler(pgfault);
  800f7f:	68 84 0e 80 00       	push   $0x800e84
  800f84:	e8 c0 0f 00 00       	call   801f49 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f89:	b8 07 00 00 00       	mov    $0x7,%eax
  800f8e:	cd 30                	int    $0x30
  800f90:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((cenvid = sys_exofork()) < 0){
  800f93:	83 c4 10             	add    $0x10,%esp
  800f96:	85 c0                	test   %eax,%eax
  800f98:	79 14                	jns    800fae <fork+0x38>
		panic("sys_exofork failed");
  800f9a:	83 ec 04             	sub    $0x4,%esp
  800f9d:	68 e7 26 80 00       	push   $0x8026e7
  800fa2:	6a 6f                	push   $0x6f
  800fa4:	68 a2 26 80 00       	push   $0x8026a2
  800fa9:	e8 55 0f 00 00       	call   801f03 <_panic>
  800fae:	89 c7                	mov    %eax,%edi
		return cenvid;
	}
	if(cenvid>0){
  800fb0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fb4:	0f 8e 2b 01 00 00    	jle    8010e5 <fork+0x16f>
  800fba:	bb 00 08 00 00       	mov    $0x800,%ebx
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
  800fbf:	89 d8                	mov    %ebx,%eax
  800fc1:	c1 e8 0a             	shr    $0xa,%eax
  800fc4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fcb:	a8 01                	test   $0x1,%al
  800fcd:	0f 84 bf 00 00 00    	je     801092 <fork+0x11c>
  800fd3:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fda:	a8 01                	test   $0x1,%al
  800fdc:	0f 84 b0 00 00 00    	je     801092 <fork+0x11c>
  800fe2:	89 de                	mov    %ebx,%esi
  800fe4:	c1 e6 0c             	shl    $0xc,%esi
{
	int r;

	// LAB 4: Your code here.
	void* vaddr=(void*)(pn*PGSIZE);
	if(uvpt[pn]&PTE_SHARE){
  800fe7:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fee:	f6 c4 04             	test   $0x4,%ah
  800ff1:	74 29                	je     80101c <fork+0xa6>
		if((r=sys_page_map(0,vaddr,envid,vaddr,uvpt[pn]&PTE_SYSCALL))<0)return r;
  800ff3:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ffa:	83 ec 0c             	sub    $0xc,%esp
  800ffd:	25 07 0e 00 00       	and    $0xe07,%eax
  801002:	50                   	push   %eax
  801003:	56                   	push   %esi
  801004:	57                   	push   %edi
  801005:	56                   	push   %esi
  801006:	6a 00                	push   $0x0
  801008:	e8 c9 fc ff ff       	call   800cd6 <sys_page_map>
  80100d:	83 c4 20             	add    $0x20,%esp
  801010:	85 c0                	test   %eax,%eax
  801012:	ba 00 00 00 00       	mov    $0x0,%edx
  801017:	0f 4f c2             	cmovg  %edx,%eax
  80101a:	eb 72                	jmp    80108e <fork+0x118>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  80101c:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801023:	a8 02                	test   $0x2,%al
  801025:	75 0c                	jne    801033 <fork+0xbd>
  801027:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80102e:	f6 c4 08             	test   $0x8,%ah
  801031:	74 3f                	je     801072 <fork+0xfc>
		if ((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  801033:	83 ec 0c             	sub    $0xc,%esp
  801036:	68 05 08 00 00       	push   $0x805
  80103b:	56                   	push   %esi
  80103c:	57                   	push   %edi
  80103d:	56                   	push   %esi
  80103e:	6a 00                	push   $0x0
  801040:	e8 91 fc ff ff       	call   800cd6 <sys_page_map>
  801045:	83 c4 20             	add    $0x20,%esp
  801048:	85 c0                	test   %eax,%eax
  80104a:	0f 88 b1 00 00 00    	js     801101 <fork+0x18b>
            return r;
        if ((r = sys_page_map(0, vaddr, 0, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  801050:	83 ec 0c             	sub    $0xc,%esp
  801053:	68 05 08 00 00       	push   $0x805
  801058:	56                   	push   %esi
  801059:	6a 00                	push   $0x0
  80105b:	56                   	push   %esi
  80105c:	6a 00                	push   $0x0
  80105e:	e8 73 fc ff ff       	call   800cd6 <sys_page_map>
  801063:	83 c4 20             	add    $0x20,%esp
  801066:	85 c0                	test   %eax,%eax
  801068:	b9 00 00 00 00       	mov    $0x0,%ecx
  80106d:	0f 4f c1             	cmovg  %ecx,%eax
  801070:	eb 1c                	jmp    80108e <fork+0x118>
            return r;
	}
	else if((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U)) < 0) {
  801072:	83 ec 0c             	sub    $0xc,%esp
  801075:	6a 05                	push   $0x5
  801077:	56                   	push   %esi
  801078:	57                   	push   %edi
  801079:	56                   	push   %esi
  80107a:	6a 00                	push   $0x0
  80107c:	e8 55 fc ff ff       	call   800cd6 <sys_page_map>
  801081:	83 c4 20             	add    $0x20,%esp
  801084:	85 c0                	test   %eax,%eax
  801086:	b9 00 00 00 00       	mov    $0x0,%ecx
  80108b:	0f 4f c1             	cmovg  %ecx,%eax
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
  80108e:	85 c0                	test   %eax,%eax
  801090:	78 6f                	js     801101 <fork+0x18b>
	if ((cenvid = sys_exofork()) < 0){
		panic("sys_exofork failed");
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  801092:	83 c3 01             	add    $0x1,%ebx
  801095:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  80109b:	0f 85 1e ff ff ff    	jne    800fbf <fork+0x49>
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
                    return r;
		}
		if ((r = sys_page_alloc(cenvid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  8010a1:	83 ec 04             	sub    $0x4,%esp
  8010a4:	6a 07                	push   $0x7
  8010a6:	68 00 f0 bf ee       	push   $0xeebff000
  8010ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010ae:	57                   	push   %edi
  8010af:	e8 df fb ff ff       	call   800c93 <sys_page_alloc>
  8010b4:	83 c4 10             	add    $0x10,%esp
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	78 46                	js     801101 <fork+0x18b>
            return r;
		extern void _pgfault_upcall(void);
		if ((r = sys_env_set_pgfault_upcall(cenvid, _pgfault_upcall)) < 0)
  8010bb:	83 ec 08             	sub    $0x8,%esp
  8010be:	68 ac 1f 80 00       	push   $0x801fac
  8010c3:	57                   	push   %edi
  8010c4:	e8 15 fd ff ff       	call   800dde <sys_env_set_pgfault_upcall>
  8010c9:	83 c4 10             	add    $0x10,%esp
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	78 31                	js     801101 <fork+0x18b>
            return r;
		if ((r = sys_env_set_status(cenvid, ENV_RUNNABLE)) < 0)
  8010d0:	83 ec 08             	sub    $0x8,%esp
  8010d3:	6a 02                	push   $0x2
  8010d5:	57                   	push   %edi
  8010d6:	e8 7f fc ff ff       	call   800d5a <sys_env_set_status>
  8010db:	83 c4 10             	add    $0x10,%esp
            return r;
        return cenvid;
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	0f 49 c7             	cmovns %edi,%eax
  8010e3:	eb 1c                	jmp    801101 <fork+0x18b>
	}
	else {
		thisenv = &envs[ENVX(sys_getenvid())];
  8010e5:	e8 6b fb ff ff       	call   800c55 <sys_getenvid>
  8010ea:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010ef:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010f2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010f7:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8010fc:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//panic("fork not implemented");
	
}
  801101:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801104:	5b                   	pop    %ebx
  801105:	5e                   	pop    %esi
  801106:	5f                   	pop    %edi
  801107:	5d                   	pop    %ebp
  801108:	c3                   	ret    

00801109 <sfork>:

// Challenge!
int
sfork(void)
{
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80110f:	68 fa 26 80 00       	push   $0x8026fa
  801114:	68 8d 00 00 00       	push   $0x8d
  801119:	68 a2 26 80 00       	push   $0x8026a2
  80111e:	e8 e0 0d 00 00       	call   801f03 <_panic>

00801123 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	56                   	push   %esi
  801127:	53                   	push   %ebx
  801128:	8b 75 08             	mov    0x8(%ebp),%esi
  80112b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80112e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801131:	85 c0                	test   %eax,%eax
  801133:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801138:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  80113b:	83 ec 0c             	sub    $0xc,%esp
  80113e:	50                   	push   %eax
  80113f:	e8 ff fc ff ff       	call   800e43 <sys_ipc_recv>
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	85 c0                	test   %eax,%eax
  801149:	79 16                	jns    801161 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  80114b:	85 f6                	test   %esi,%esi
  80114d:	74 06                	je     801155 <ipc_recv+0x32>
            *from_env_store = 0;
  80114f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801155:	85 db                	test   %ebx,%ebx
  801157:	74 2c                	je     801185 <ipc_recv+0x62>
            *perm_store = 0;
  801159:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80115f:	eb 24                	jmp    801185 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801161:	85 f6                	test   %esi,%esi
  801163:	74 0a                	je     80116f <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801165:	a1 04 40 80 00       	mov    0x804004,%eax
  80116a:	8b 40 74             	mov    0x74(%eax),%eax
  80116d:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  80116f:	85 db                	test   %ebx,%ebx
  801171:	74 0a                	je     80117d <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801173:	a1 04 40 80 00       	mov    0x804004,%eax
  801178:	8b 40 78             	mov    0x78(%eax),%eax
  80117b:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  80117d:	a1 04 40 80 00       	mov    0x804004,%eax
  801182:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801185:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801188:	5b                   	pop    %ebx
  801189:	5e                   	pop    %esi
  80118a:	5d                   	pop    %ebp
  80118b:	c3                   	ret    

0080118c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	57                   	push   %edi
  801190:	56                   	push   %esi
  801191:	53                   	push   %ebx
  801192:	83 ec 0c             	sub    $0xc,%esp
  801195:	8b 7d 08             	mov    0x8(%ebp),%edi
  801198:	8b 75 0c             	mov    0xc(%ebp),%esi
  80119b:	8b 45 10             	mov    0x10(%ebp),%eax
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8011a5:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  8011a8:	eb 1c                	jmp    8011c6 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  8011aa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011ad:	74 12                	je     8011c1 <ipc_send+0x35>
  8011af:	50                   	push   %eax
  8011b0:	68 10 27 80 00       	push   $0x802710
  8011b5:	6a 3a                	push   $0x3a
  8011b7:	68 26 27 80 00       	push   $0x802726
  8011bc:	e8 42 0d 00 00       	call   801f03 <_panic>
		sys_yield();
  8011c1:	e8 ae fa ff ff       	call   800c74 <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  8011c6:	ff 75 14             	pushl  0x14(%ebp)
  8011c9:	53                   	push   %ebx
  8011ca:	56                   	push   %esi
  8011cb:	57                   	push   %edi
  8011cc:	e8 4f fc ff ff       	call   800e20 <sys_ipc_try_send>
  8011d1:	83 c4 10             	add    $0x10,%esp
  8011d4:	85 c0                	test   %eax,%eax
  8011d6:	78 d2                	js     8011aa <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  8011d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011db:	5b                   	pop    %ebx
  8011dc:	5e                   	pop    %esi
  8011dd:	5f                   	pop    %edi
  8011de:	5d                   	pop    %ebp
  8011df:	c3                   	ret    

008011e0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011e6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011eb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011ee:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011f4:	8b 52 50             	mov    0x50(%edx),%edx
  8011f7:	39 ca                	cmp    %ecx,%edx
  8011f9:	75 0d                	jne    801208 <ipc_find_env+0x28>
			return envs[i].env_id;
  8011fb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011fe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801203:	8b 40 48             	mov    0x48(%eax),%eax
  801206:	eb 0f                	jmp    801217 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801208:	83 c0 01             	add    $0x1,%eax
  80120b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801210:	75 d9                	jne    8011eb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801212:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801217:	5d                   	pop    %ebp
  801218:	c3                   	ret    

00801219 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80121c:	8b 45 08             	mov    0x8(%ebp),%eax
  80121f:	05 00 00 00 30       	add    $0x30000000,%eax
  801224:	c1 e8 0c             	shr    $0xc,%eax
}
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    

00801229 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80122c:	8b 45 08             	mov    0x8(%ebp),%eax
  80122f:	05 00 00 00 30       	add    $0x30000000,%eax
  801234:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801239:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80123e:	5d                   	pop    %ebp
  80123f:	c3                   	ret    

00801240 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801246:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80124b:	89 c2                	mov    %eax,%edx
  80124d:	c1 ea 16             	shr    $0x16,%edx
  801250:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801257:	f6 c2 01             	test   $0x1,%dl
  80125a:	74 11                	je     80126d <fd_alloc+0x2d>
  80125c:	89 c2                	mov    %eax,%edx
  80125e:	c1 ea 0c             	shr    $0xc,%edx
  801261:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801268:	f6 c2 01             	test   $0x1,%dl
  80126b:	75 09                	jne    801276 <fd_alloc+0x36>
			*fd_store = fd;
  80126d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80126f:	b8 00 00 00 00       	mov    $0x0,%eax
  801274:	eb 17                	jmp    80128d <fd_alloc+0x4d>
  801276:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80127b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801280:	75 c9                	jne    80124b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801282:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801288:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    

0080128f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801295:	83 f8 1f             	cmp    $0x1f,%eax
  801298:	77 36                	ja     8012d0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80129a:	c1 e0 0c             	shl    $0xc,%eax
  80129d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012a2:	89 c2                	mov    %eax,%edx
  8012a4:	c1 ea 16             	shr    $0x16,%edx
  8012a7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ae:	f6 c2 01             	test   $0x1,%dl
  8012b1:	74 24                	je     8012d7 <fd_lookup+0x48>
  8012b3:	89 c2                	mov    %eax,%edx
  8012b5:	c1 ea 0c             	shr    $0xc,%edx
  8012b8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012bf:	f6 c2 01             	test   $0x1,%dl
  8012c2:	74 1a                	je     8012de <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c7:	89 02                	mov    %eax,(%edx)
	return 0;
  8012c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ce:	eb 13                	jmp    8012e3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d5:	eb 0c                	jmp    8012e3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012dc:	eb 05                	jmp    8012e3 <fd_lookup+0x54>
  8012de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012e3:	5d                   	pop    %ebp
  8012e4:	c3                   	ret    

008012e5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012e5:	55                   	push   %ebp
  8012e6:	89 e5                	mov    %esp,%ebp
  8012e8:	83 ec 08             	sub    $0x8,%esp
  8012eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ee:	ba ac 27 80 00       	mov    $0x8027ac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012f3:	eb 13                	jmp    801308 <dev_lookup+0x23>
  8012f5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012f8:	39 08                	cmp    %ecx,(%eax)
  8012fa:	75 0c                	jne    801308 <dev_lookup+0x23>
			*dev = devtab[i];
  8012fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ff:	89 01                	mov    %eax,(%ecx)
			return 0;
  801301:	b8 00 00 00 00       	mov    $0x0,%eax
  801306:	eb 2e                	jmp    801336 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801308:	8b 02                	mov    (%edx),%eax
  80130a:	85 c0                	test   %eax,%eax
  80130c:	75 e7                	jne    8012f5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80130e:	a1 04 40 80 00       	mov    0x804004,%eax
  801313:	8b 40 48             	mov    0x48(%eax),%eax
  801316:	83 ec 04             	sub    $0x4,%esp
  801319:	51                   	push   %ecx
  80131a:	50                   	push   %eax
  80131b:	68 30 27 80 00       	push   $0x802730
  801320:	e8 67 ef ff ff       	call   80028c <cprintf>
	*dev = 0;
  801325:	8b 45 0c             	mov    0xc(%ebp),%eax
  801328:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80132e:	83 c4 10             	add    $0x10,%esp
  801331:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801336:	c9                   	leave  
  801337:	c3                   	ret    

00801338 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	56                   	push   %esi
  80133c:	53                   	push   %ebx
  80133d:	83 ec 10             	sub    $0x10,%esp
  801340:	8b 75 08             	mov    0x8(%ebp),%esi
  801343:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801346:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801349:	50                   	push   %eax
  80134a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801350:	c1 e8 0c             	shr    $0xc,%eax
  801353:	50                   	push   %eax
  801354:	e8 36 ff ff ff       	call   80128f <fd_lookup>
  801359:	83 c4 08             	add    $0x8,%esp
  80135c:	85 c0                	test   %eax,%eax
  80135e:	78 05                	js     801365 <fd_close+0x2d>
	    || fd != fd2)
  801360:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801363:	74 0c                	je     801371 <fd_close+0x39>
		return (must_exist ? r : 0);
  801365:	84 db                	test   %bl,%bl
  801367:	ba 00 00 00 00       	mov    $0x0,%edx
  80136c:	0f 44 c2             	cmove  %edx,%eax
  80136f:	eb 41                	jmp    8013b2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801371:	83 ec 08             	sub    $0x8,%esp
  801374:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801377:	50                   	push   %eax
  801378:	ff 36                	pushl  (%esi)
  80137a:	e8 66 ff ff ff       	call   8012e5 <dev_lookup>
  80137f:	89 c3                	mov    %eax,%ebx
  801381:	83 c4 10             	add    $0x10,%esp
  801384:	85 c0                	test   %eax,%eax
  801386:	78 1a                	js     8013a2 <fd_close+0x6a>
		if (dev->dev_close)
  801388:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80138e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801393:	85 c0                	test   %eax,%eax
  801395:	74 0b                	je     8013a2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801397:	83 ec 0c             	sub    $0xc,%esp
  80139a:	56                   	push   %esi
  80139b:	ff d0                	call   *%eax
  80139d:	89 c3                	mov    %eax,%ebx
  80139f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013a2:	83 ec 08             	sub    $0x8,%esp
  8013a5:	56                   	push   %esi
  8013a6:	6a 00                	push   $0x0
  8013a8:	e8 6b f9 ff ff       	call   800d18 <sys_page_unmap>
	return r;
  8013ad:	83 c4 10             	add    $0x10,%esp
  8013b0:	89 d8                	mov    %ebx,%eax
}
  8013b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b5:	5b                   	pop    %ebx
  8013b6:	5e                   	pop    %esi
  8013b7:	5d                   	pop    %ebp
  8013b8:	c3                   	ret    

008013b9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013b9:	55                   	push   %ebp
  8013ba:	89 e5                	mov    %esp,%ebp
  8013bc:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c2:	50                   	push   %eax
  8013c3:	ff 75 08             	pushl  0x8(%ebp)
  8013c6:	e8 c4 fe ff ff       	call   80128f <fd_lookup>
  8013cb:	83 c4 08             	add    $0x8,%esp
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	78 10                	js     8013e2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013d2:	83 ec 08             	sub    $0x8,%esp
  8013d5:	6a 01                	push   $0x1
  8013d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8013da:	e8 59 ff ff ff       	call   801338 <fd_close>
  8013df:	83 c4 10             	add    $0x10,%esp
}
  8013e2:	c9                   	leave  
  8013e3:	c3                   	ret    

008013e4 <close_all>:

void
close_all(void)
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	53                   	push   %ebx
  8013e8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013eb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013f0:	83 ec 0c             	sub    $0xc,%esp
  8013f3:	53                   	push   %ebx
  8013f4:	e8 c0 ff ff ff       	call   8013b9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013f9:	83 c3 01             	add    $0x1,%ebx
  8013fc:	83 c4 10             	add    $0x10,%esp
  8013ff:	83 fb 20             	cmp    $0x20,%ebx
  801402:	75 ec                	jne    8013f0 <close_all+0xc>
		close(i);
}
  801404:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801407:	c9                   	leave  
  801408:	c3                   	ret    

00801409 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801409:	55                   	push   %ebp
  80140a:	89 e5                	mov    %esp,%ebp
  80140c:	57                   	push   %edi
  80140d:	56                   	push   %esi
  80140e:	53                   	push   %ebx
  80140f:	83 ec 2c             	sub    $0x2c,%esp
  801412:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801415:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801418:	50                   	push   %eax
  801419:	ff 75 08             	pushl  0x8(%ebp)
  80141c:	e8 6e fe ff ff       	call   80128f <fd_lookup>
  801421:	83 c4 08             	add    $0x8,%esp
  801424:	85 c0                	test   %eax,%eax
  801426:	0f 88 c1 00 00 00    	js     8014ed <dup+0xe4>
		return r;
	close(newfdnum);
  80142c:	83 ec 0c             	sub    $0xc,%esp
  80142f:	56                   	push   %esi
  801430:	e8 84 ff ff ff       	call   8013b9 <close>

	newfd = INDEX2FD(newfdnum);
  801435:	89 f3                	mov    %esi,%ebx
  801437:	c1 e3 0c             	shl    $0xc,%ebx
  80143a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801440:	83 c4 04             	add    $0x4,%esp
  801443:	ff 75 e4             	pushl  -0x1c(%ebp)
  801446:	e8 de fd ff ff       	call   801229 <fd2data>
  80144b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80144d:	89 1c 24             	mov    %ebx,(%esp)
  801450:	e8 d4 fd ff ff       	call   801229 <fd2data>
  801455:	83 c4 10             	add    $0x10,%esp
  801458:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80145b:	89 f8                	mov    %edi,%eax
  80145d:	c1 e8 16             	shr    $0x16,%eax
  801460:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801467:	a8 01                	test   $0x1,%al
  801469:	74 37                	je     8014a2 <dup+0x99>
  80146b:	89 f8                	mov    %edi,%eax
  80146d:	c1 e8 0c             	shr    $0xc,%eax
  801470:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801477:	f6 c2 01             	test   $0x1,%dl
  80147a:	74 26                	je     8014a2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80147c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801483:	83 ec 0c             	sub    $0xc,%esp
  801486:	25 07 0e 00 00       	and    $0xe07,%eax
  80148b:	50                   	push   %eax
  80148c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80148f:	6a 00                	push   $0x0
  801491:	57                   	push   %edi
  801492:	6a 00                	push   $0x0
  801494:	e8 3d f8 ff ff       	call   800cd6 <sys_page_map>
  801499:	89 c7                	mov    %eax,%edi
  80149b:	83 c4 20             	add    $0x20,%esp
  80149e:	85 c0                	test   %eax,%eax
  8014a0:	78 2e                	js     8014d0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014a2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014a5:	89 d0                	mov    %edx,%eax
  8014a7:	c1 e8 0c             	shr    $0xc,%eax
  8014aa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014b1:	83 ec 0c             	sub    $0xc,%esp
  8014b4:	25 07 0e 00 00       	and    $0xe07,%eax
  8014b9:	50                   	push   %eax
  8014ba:	53                   	push   %ebx
  8014bb:	6a 00                	push   $0x0
  8014bd:	52                   	push   %edx
  8014be:	6a 00                	push   $0x0
  8014c0:	e8 11 f8 ff ff       	call   800cd6 <sys_page_map>
  8014c5:	89 c7                	mov    %eax,%edi
  8014c7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014ca:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014cc:	85 ff                	test   %edi,%edi
  8014ce:	79 1d                	jns    8014ed <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014d0:	83 ec 08             	sub    $0x8,%esp
  8014d3:	53                   	push   %ebx
  8014d4:	6a 00                	push   $0x0
  8014d6:	e8 3d f8 ff ff       	call   800d18 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014db:	83 c4 08             	add    $0x8,%esp
  8014de:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014e1:	6a 00                	push   $0x0
  8014e3:	e8 30 f8 ff ff       	call   800d18 <sys_page_unmap>
	return r;
  8014e8:	83 c4 10             	add    $0x10,%esp
  8014eb:	89 f8                	mov    %edi,%eax
}
  8014ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f0:	5b                   	pop    %ebx
  8014f1:	5e                   	pop    %esi
  8014f2:	5f                   	pop    %edi
  8014f3:	5d                   	pop    %ebp
  8014f4:	c3                   	ret    

008014f5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014f5:	55                   	push   %ebp
  8014f6:	89 e5                	mov    %esp,%ebp
  8014f8:	53                   	push   %ebx
  8014f9:	83 ec 14             	sub    $0x14,%esp
  8014fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801502:	50                   	push   %eax
  801503:	53                   	push   %ebx
  801504:	e8 86 fd ff ff       	call   80128f <fd_lookup>
  801509:	83 c4 08             	add    $0x8,%esp
  80150c:	89 c2                	mov    %eax,%edx
  80150e:	85 c0                	test   %eax,%eax
  801510:	78 6d                	js     80157f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801512:	83 ec 08             	sub    $0x8,%esp
  801515:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801518:	50                   	push   %eax
  801519:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151c:	ff 30                	pushl  (%eax)
  80151e:	e8 c2 fd ff ff       	call   8012e5 <dev_lookup>
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	85 c0                	test   %eax,%eax
  801528:	78 4c                	js     801576 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80152a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80152d:	8b 42 08             	mov    0x8(%edx),%eax
  801530:	83 e0 03             	and    $0x3,%eax
  801533:	83 f8 01             	cmp    $0x1,%eax
  801536:	75 21                	jne    801559 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801538:	a1 04 40 80 00       	mov    0x804004,%eax
  80153d:	8b 40 48             	mov    0x48(%eax),%eax
  801540:	83 ec 04             	sub    $0x4,%esp
  801543:	53                   	push   %ebx
  801544:	50                   	push   %eax
  801545:	68 71 27 80 00       	push   $0x802771
  80154a:	e8 3d ed ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  80154f:	83 c4 10             	add    $0x10,%esp
  801552:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801557:	eb 26                	jmp    80157f <read+0x8a>
	}
	if (!dev->dev_read)
  801559:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155c:	8b 40 08             	mov    0x8(%eax),%eax
  80155f:	85 c0                	test   %eax,%eax
  801561:	74 17                	je     80157a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801563:	83 ec 04             	sub    $0x4,%esp
  801566:	ff 75 10             	pushl  0x10(%ebp)
  801569:	ff 75 0c             	pushl  0xc(%ebp)
  80156c:	52                   	push   %edx
  80156d:	ff d0                	call   *%eax
  80156f:	89 c2                	mov    %eax,%edx
  801571:	83 c4 10             	add    $0x10,%esp
  801574:	eb 09                	jmp    80157f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801576:	89 c2                	mov    %eax,%edx
  801578:	eb 05                	jmp    80157f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80157a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80157f:	89 d0                	mov    %edx,%eax
  801581:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801584:	c9                   	leave  
  801585:	c3                   	ret    

00801586 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801586:	55                   	push   %ebp
  801587:	89 e5                	mov    %esp,%ebp
  801589:	57                   	push   %edi
  80158a:	56                   	push   %esi
  80158b:	53                   	push   %ebx
  80158c:	83 ec 0c             	sub    $0xc,%esp
  80158f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801592:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801595:	bb 00 00 00 00       	mov    $0x0,%ebx
  80159a:	eb 21                	jmp    8015bd <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80159c:	83 ec 04             	sub    $0x4,%esp
  80159f:	89 f0                	mov    %esi,%eax
  8015a1:	29 d8                	sub    %ebx,%eax
  8015a3:	50                   	push   %eax
  8015a4:	89 d8                	mov    %ebx,%eax
  8015a6:	03 45 0c             	add    0xc(%ebp),%eax
  8015a9:	50                   	push   %eax
  8015aa:	57                   	push   %edi
  8015ab:	e8 45 ff ff ff       	call   8014f5 <read>
		if (m < 0)
  8015b0:	83 c4 10             	add    $0x10,%esp
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	78 10                	js     8015c7 <readn+0x41>
			return m;
		if (m == 0)
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	74 0a                	je     8015c5 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015bb:	01 c3                	add    %eax,%ebx
  8015bd:	39 f3                	cmp    %esi,%ebx
  8015bf:	72 db                	jb     80159c <readn+0x16>
  8015c1:	89 d8                	mov    %ebx,%eax
  8015c3:	eb 02                	jmp    8015c7 <readn+0x41>
  8015c5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ca:	5b                   	pop    %ebx
  8015cb:	5e                   	pop    %esi
  8015cc:	5f                   	pop    %edi
  8015cd:	5d                   	pop    %ebp
  8015ce:	c3                   	ret    

008015cf <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	53                   	push   %ebx
  8015d3:	83 ec 14             	sub    $0x14,%esp
  8015d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015dc:	50                   	push   %eax
  8015dd:	53                   	push   %ebx
  8015de:	e8 ac fc ff ff       	call   80128f <fd_lookup>
  8015e3:	83 c4 08             	add    $0x8,%esp
  8015e6:	89 c2                	mov    %eax,%edx
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	78 68                	js     801654 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ec:	83 ec 08             	sub    $0x8,%esp
  8015ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f2:	50                   	push   %eax
  8015f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f6:	ff 30                	pushl  (%eax)
  8015f8:	e8 e8 fc ff ff       	call   8012e5 <dev_lookup>
  8015fd:	83 c4 10             	add    $0x10,%esp
  801600:	85 c0                	test   %eax,%eax
  801602:	78 47                	js     80164b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801604:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801607:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80160b:	75 21                	jne    80162e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80160d:	a1 04 40 80 00       	mov    0x804004,%eax
  801612:	8b 40 48             	mov    0x48(%eax),%eax
  801615:	83 ec 04             	sub    $0x4,%esp
  801618:	53                   	push   %ebx
  801619:	50                   	push   %eax
  80161a:	68 8d 27 80 00       	push   $0x80278d
  80161f:	e8 68 ec ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80162c:	eb 26                	jmp    801654 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80162e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801631:	8b 52 0c             	mov    0xc(%edx),%edx
  801634:	85 d2                	test   %edx,%edx
  801636:	74 17                	je     80164f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801638:	83 ec 04             	sub    $0x4,%esp
  80163b:	ff 75 10             	pushl  0x10(%ebp)
  80163e:	ff 75 0c             	pushl  0xc(%ebp)
  801641:	50                   	push   %eax
  801642:	ff d2                	call   *%edx
  801644:	89 c2                	mov    %eax,%edx
  801646:	83 c4 10             	add    $0x10,%esp
  801649:	eb 09                	jmp    801654 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164b:	89 c2                	mov    %eax,%edx
  80164d:	eb 05                	jmp    801654 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80164f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801654:	89 d0                	mov    %edx,%eax
  801656:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801659:	c9                   	leave  
  80165a:	c3                   	ret    

0080165b <seek>:

int
seek(int fdnum, off_t offset)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801661:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801664:	50                   	push   %eax
  801665:	ff 75 08             	pushl  0x8(%ebp)
  801668:	e8 22 fc ff ff       	call   80128f <fd_lookup>
  80166d:	83 c4 08             	add    $0x8,%esp
  801670:	85 c0                	test   %eax,%eax
  801672:	78 0e                	js     801682 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801674:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801677:	8b 55 0c             	mov    0xc(%ebp),%edx
  80167a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80167d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801682:	c9                   	leave  
  801683:	c3                   	ret    

00801684 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	53                   	push   %ebx
  801688:	83 ec 14             	sub    $0x14,%esp
  80168b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801691:	50                   	push   %eax
  801692:	53                   	push   %ebx
  801693:	e8 f7 fb ff ff       	call   80128f <fd_lookup>
  801698:	83 c4 08             	add    $0x8,%esp
  80169b:	89 c2                	mov    %eax,%edx
  80169d:	85 c0                	test   %eax,%eax
  80169f:	78 65                	js     801706 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a1:	83 ec 08             	sub    $0x8,%esp
  8016a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a7:	50                   	push   %eax
  8016a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ab:	ff 30                	pushl  (%eax)
  8016ad:	e8 33 fc ff ff       	call   8012e5 <dev_lookup>
  8016b2:	83 c4 10             	add    $0x10,%esp
  8016b5:	85 c0                	test   %eax,%eax
  8016b7:	78 44                	js     8016fd <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016c0:	75 21                	jne    8016e3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016c2:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016c7:	8b 40 48             	mov    0x48(%eax),%eax
  8016ca:	83 ec 04             	sub    $0x4,%esp
  8016cd:	53                   	push   %ebx
  8016ce:	50                   	push   %eax
  8016cf:	68 50 27 80 00       	push   $0x802750
  8016d4:	e8 b3 eb ff ff       	call   80028c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016d9:	83 c4 10             	add    $0x10,%esp
  8016dc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016e1:	eb 23                	jmp    801706 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e6:	8b 52 18             	mov    0x18(%edx),%edx
  8016e9:	85 d2                	test   %edx,%edx
  8016eb:	74 14                	je     801701 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016ed:	83 ec 08             	sub    $0x8,%esp
  8016f0:	ff 75 0c             	pushl  0xc(%ebp)
  8016f3:	50                   	push   %eax
  8016f4:	ff d2                	call   *%edx
  8016f6:	89 c2                	mov    %eax,%edx
  8016f8:	83 c4 10             	add    $0x10,%esp
  8016fb:	eb 09                	jmp    801706 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fd:	89 c2                	mov    %eax,%edx
  8016ff:	eb 05                	jmp    801706 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801701:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801706:	89 d0                	mov    %edx,%eax
  801708:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170b:	c9                   	leave  
  80170c:	c3                   	ret    

0080170d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80170d:	55                   	push   %ebp
  80170e:	89 e5                	mov    %esp,%ebp
  801710:	53                   	push   %ebx
  801711:	83 ec 14             	sub    $0x14,%esp
  801714:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801717:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80171a:	50                   	push   %eax
  80171b:	ff 75 08             	pushl  0x8(%ebp)
  80171e:	e8 6c fb ff ff       	call   80128f <fd_lookup>
  801723:	83 c4 08             	add    $0x8,%esp
  801726:	89 c2                	mov    %eax,%edx
  801728:	85 c0                	test   %eax,%eax
  80172a:	78 58                	js     801784 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172c:	83 ec 08             	sub    $0x8,%esp
  80172f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801732:	50                   	push   %eax
  801733:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801736:	ff 30                	pushl  (%eax)
  801738:	e8 a8 fb ff ff       	call   8012e5 <dev_lookup>
  80173d:	83 c4 10             	add    $0x10,%esp
  801740:	85 c0                	test   %eax,%eax
  801742:	78 37                	js     80177b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801744:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801747:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80174b:	74 32                	je     80177f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80174d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801750:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801757:	00 00 00 
	stat->st_isdir = 0;
  80175a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801761:	00 00 00 
	stat->st_dev = dev;
  801764:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80176a:	83 ec 08             	sub    $0x8,%esp
  80176d:	53                   	push   %ebx
  80176e:	ff 75 f0             	pushl  -0x10(%ebp)
  801771:	ff 50 14             	call   *0x14(%eax)
  801774:	89 c2                	mov    %eax,%edx
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	eb 09                	jmp    801784 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177b:	89 c2                	mov    %eax,%edx
  80177d:	eb 05                	jmp    801784 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80177f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801784:	89 d0                	mov    %edx,%eax
  801786:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801789:	c9                   	leave  
  80178a:	c3                   	ret    

0080178b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	56                   	push   %esi
  80178f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801790:	83 ec 08             	sub    $0x8,%esp
  801793:	6a 00                	push   $0x0
  801795:	ff 75 08             	pushl  0x8(%ebp)
  801798:	e8 e3 01 00 00       	call   801980 <open>
  80179d:	89 c3                	mov    %eax,%ebx
  80179f:	83 c4 10             	add    $0x10,%esp
  8017a2:	85 c0                	test   %eax,%eax
  8017a4:	78 1b                	js     8017c1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017a6:	83 ec 08             	sub    $0x8,%esp
  8017a9:	ff 75 0c             	pushl  0xc(%ebp)
  8017ac:	50                   	push   %eax
  8017ad:	e8 5b ff ff ff       	call   80170d <fstat>
  8017b2:	89 c6                	mov    %eax,%esi
	close(fd);
  8017b4:	89 1c 24             	mov    %ebx,(%esp)
  8017b7:	e8 fd fb ff ff       	call   8013b9 <close>
	return r;
  8017bc:	83 c4 10             	add    $0x10,%esp
  8017bf:	89 f0                	mov    %esi,%eax
}
  8017c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c4:	5b                   	pop    %ebx
  8017c5:	5e                   	pop    %esi
  8017c6:	5d                   	pop    %ebp
  8017c7:	c3                   	ret    

008017c8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	56                   	push   %esi
  8017cc:	53                   	push   %ebx
  8017cd:	89 c6                	mov    %eax,%esi
  8017cf:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017d1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017d8:	75 12                	jne    8017ec <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017da:	83 ec 0c             	sub    $0xc,%esp
  8017dd:	6a 01                	push   $0x1
  8017df:	e8 fc f9 ff ff       	call   8011e0 <ipc_find_env>
  8017e4:	a3 00 40 80 00       	mov    %eax,0x804000
  8017e9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017ec:	6a 07                	push   $0x7
  8017ee:	68 00 50 80 00       	push   $0x805000
  8017f3:	56                   	push   %esi
  8017f4:	ff 35 00 40 80 00    	pushl  0x804000
  8017fa:	e8 8d f9 ff ff       	call   80118c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017ff:	83 c4 0c             	add    $0xc,%esp
  801802:	6a 00                	push   $0x0
  801804:	53                   	push   %ebx
  801805:	6a 00                	push   $0x0
  801807:	e8 17 f9 ff ff       	call   801123 <ipc_recv>
}
  80180c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80180f:	5b                   	pop    %ebx
  801810:	5e                   	pop    %esi
  801811:	5d                   	pop    %ebp
  801812:	c3                   	ret    

00801813 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801819:	8b 45 08             	mov    0x8(%ebp),%eax
  80181c:	8b 40 0c             	mov    0xc(%eax),%eax
  80181f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801824:	8b 45 0c             	mov    0xc(%ebp),%eax
  801827:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80182c:	ba 00 00 00 00       	mov    $0x0,%edx
  801831:	b8 02 00 00 00       	mov    $0x2,%eax
  801836:	e8 8d ff ff ff       	call   8017c8 <fsipc>
}
  80183b:	c9                   	leave  
  80183c:	c3                   	ret    

0080183d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80183d:	55                   	push   %ebp
  80183e:	89 e5                	mov    %esp,%ebp
  801840:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801843:	8b 45 08             	mov    0x8(%ebp),%eax
  801846:	8b 40 0c             	mov    0xc(%eax),%eax
  801849:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80184e:	ba 00 00 00 00       	mov    $0x0,%edx
  801853:	b8 06 00 00 00       	mov    $0x6,%eax
  801858:	e8 6b ff ff ff       	call   8017c8 <fsipc>
}
  80185d:	c9                   	leave  
  80185e:	c3                   	ret    

0080185f <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	53                   	push   %ebx
  801863:	83 ec 04             	sub    $0x4,%esp
  801866:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801869:	8b 45 08             	mov    0x8(%ebp),%eax
  80186c:	8b 40 0c             	mov    0xc(%eax),%eax
  80186f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801874:	ba 00 00 00 00       	mov    $0x0,%edx
  801879:	b8 05 00 00 00       	mov    $0x5,%eax
  80187e:	e8 45 ff ff ff       	call   8017c8 <fsipc>
  801883:	85 c0                	test   %eax,%eax
  801885:	78 2c                	js     8018b3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801887:	83 ec 08             	sub    $0x8,%esp
  80188a:	68 00 50 80 00       	push   $0x805000
  80188f:	53                   	push   %ebx
  801890:	e8 fb ef ff ff       	call   800890 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801895:	a1 80 50 80 00       	mov    0x805080,%eax
  80189a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018a0:	a1 84 50 80 00       	mov    0x805084,%eax
  8018a5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018ab:	83 c4 10             	add    $0x10,%esp
  8018ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b6:	c9                   	leave  
  8018b7:	c3                   	ret    

008018b8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	83 ec 0c             	sub    $0xc,%esp
  8018be:	8b 45 10             	mov    0x10(%ebp),%eax
  8018c1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018c6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018cb:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8018d1:	8b 52 0c             	mov    0xc(%edx),%edx
  8018d4:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018da:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018df:	50                   	push   %eax
  8018e0:	ff 75 0c             	pushl  0xc(%ebp)
  8018e3:	68 08 50 80 00       	push   $0x805008
  8018e8:	e8 35 f1 ff ff       	call   800a22 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f2:	b8 04 00 00 00       	mov    $0x4,%eax
  8018f7:	e8 cc fe ff ff       	call   8017c8 <fsipc>
	//panic("devfile_write not implemented");
}
  8018fc:	c9                   	leave  
  8018fd:	c3                   	ret    

008018fe <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	56                   	push   %esi
  801902:	53                   	push   %ebx
  801903:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801906:	8b 45 08             	mov    0x8(%ebp),%eax
  801909:	8b 40 0c             	mov    0xc(%eax),%eax
  80190c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801911:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801917:	ba 00 00 00 00       	mov    $0x0,%edx
  80191c:	b8 03 00 00 00       	mov    $0x3,%eax
  801921:	e8 a2 fe ff ff       	call   8017c8 <fsipc>
  801926:	89 c3                	mov    %eax,%ebx
  801928:	85 c0                	test   %eax,%eax
  80192a:	78 4b                	js     801977 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80192c:	39 c6                	cmp    %eax,%esi
  80192e:	73 16                	jae    801946 <devfile_read+0x48>
  801930:	68 bc 27 80 00       	push   $0x8027bc
  801935:	68 c3 27 80 00       	push   $0x8027c3
  80193a:	6a 7c                	push   $0x7c
  80193c:	68 d8 27 80 00       	push   $0x8027d8
  801941:	e8 bd 05 00 00       	call   801f03 <_panic>
	assert(r <= PGSIZE);
  801946:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80194b:	7e 16                	jle    801963 <devfile_read+0x65>
  80194d:	68 e3 27 80 00       	push   $0x8027e3
  801952:	68 c3 27 80 00       	push   $0x8027c3
  801957:	6a 7d                	push   $0x7d
  801959:	68 d8 27 80 00       	push   $0x8027d8
  80195e:	e8 a0 05 00 00       	call   801f03 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801963:	83 ec 04             	sub    $0x4,%esp
  801966:	50                   	push   %eax
  801967:	68 00 50 80 00       	push   $0x805000
  80196c:	ff 75 0c             	pushl  0xc(%ebp)
  80196f:	e8 ae f0 ff ff       	call   800a22 <memmove>
	return r;
  801974:	83 c4 10             	add    $0x10,%esp
}
  801977:	89 d8                	mov    %ebx,%eax
  801979:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197c:	5b                   	pop    %ebx
  80197d:	5e                   	pop    %esi
  80197e:	5d                   	pop    %ebp
  80197f:	c3                   	ret    

00801980 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	53                   	push   %ebx
  801984:	83 ec 20             	sub    $0x20,%esp
  801987:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80198a:	53                   	push   %ebx
  80198b:	e8 c7 ee ff ff       	call   800857 <strlen>
  801990:	83 c4 10             	add    $0x10,%esp
  801993:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801998:	7f 67                	jg     801a01 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80199a:	83 ec 0c             	sub    $0xc,%esp
  80199d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a0:	50                   	push   %eax
  8019a1:	e8 9a f8 ff ff       	call   801240 <fd_alloc>
  8019a6:	83 c4 10             	add    $0x10,%esp
		return r;
  8019a9:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ab:	85 c0                	test   %eax,%eax
  8019ad:	78 57                	js     801a06 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019af:	83 ec 08             	sub    $0x8,%esp
  8019b2:	53                   	push   %ebx
  8019b3:	68 00 50 80 00       	push   $0x805000
  8019b8:	e8 d3 ee ff ff       	call   800890 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c0:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8019cd:	e8 f6 fd ff ff       	call   8017c8 <fsipc>
  8019d2:	89 c3                	mov    %eax,%ebx
  8019d4:	83 c4 10             	add    $0x10,%esp
  8019d7:	85 c0                	test   %eax,%eax
  8019d9:	79 14                	jns    8019ef <open+0x6f>
		fd_close(fd, 0);
  8019db:	83 ec 08             	sub    $0x8,%esp
  8019de:	6a 00                	push   $0x0
  8019e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e3:	e8 50 f9 ff ff       	call   801338 <fd_close>
		return r;
  8019e8:	83 c4 10             	add    $0x10,%esp
  8019eb:	89 da                	mov    %ebx,%edx
  8019ed:	eb 17                	jmp    801a06 <open+0x86>
	}

	return fd2num(fd);
  8019ef:	83 ec 0c             	sub    $0xc,%esp
  8019f2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f5:	e8 1f f8 ff ff       	call   801219 <fd2num>
  8019fa:	89 c2                	mov    %eax,%edx
  8019fc:	83 c4 10             	add    $0x10,%esp
  8019ff:	eb 05                	jmp    801a06 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a01:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a06:	89 d0                	mov    %edx,%eax
  801a08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a0b:	c9                   	leave  
  801a0c:	c3                   	ret    

00801a0d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a0d:	55                   	push   %ebp
  801a0e:	89 e5                	mov    %esp,%ebp
  801a10:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a13:	ba 00 00 00 00       	mov    $0x0,%edx
  801a18:	b8 08 00 00 00       	mov    $0x8,%eax
  801a1d:	e8 a6 fd ff ff       	call   8017c8 <fsipc>
}
  801a22:	c9                   	leave  
  801a23:	c3                   	ret    

00801a24 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	56                   	push   %esi
  801a28:	53                   	push   %ebx
  801a29:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a2c:	83 ec 0c             	sub    $0xc,%esp
  801a2f:	ff 75 08             	pushl  0x8(%ebp)
  801a32:	e8 f2 f7 ff ff       	call   801229 <fd2data>
  801a37:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a39:	83 c4 08             	add    $0x8,%esp
  801a3c:	68 ef 27 80 00       	push   $0x8027ef
  801a41:	53                   	push   %ebx
  801a42:	e8 49 ee ff ff       	call   800890 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a47:	8b 46 04             	mov    0x4(%esi),%eax
  801a4a:	2b 06                	sub    (%esi),%eax
  801a4c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a52:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a59:	00 00 00 
	stat->st_dev = &devpipe;
  801a5c:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801a63:	30 80 00 
	return 0;
}
  801a66:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6e:	5b                   	pop    %ebx
  801a6f:	5e                   	pop    %esi
  801a70:	5d                   	pop    %ebp
  801a71:	c3                   	ret    

00801a72 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a72:	55                   	push   %ebp
  801a73:	89 e5                	mov    %esp,%ebp
  801a75:	53                   	push   %ebx
  801a76:	83 ec 0c             	sub    $0xc,%esp
  801a79:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a7c:	53                   	push   %ebx
  801a7d:	6a 00                	push   $0x0
  801a7f:	e8 94 f2 ff ff       	call   800d18 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a84:	89 1c 24             	mov    %ebx,(%esp)
  801a87:	e8 9d f7 ff ff       	call   801229 <fd2data>
  801a8c:	83 c4 08             	add    $0x8,%esp
  801a8f:	50                   	push   %eax
  801a90:	6a 00                	push   $0x0
  801a92:	e8 81 f2 ff ff       	call   800d18 <sys_page_unmap>
}
  801a97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a9a:	c9                   	leave  
  801a9b:	c3                   	ret    

00801a9c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	57                   	push   %edi
  801aa0:	56                   	push   %esi
  801aa1:	53                   	push   %ebx
  801aa2:	83 ec 1c             	sub    $0x1c,%esp
  801aa5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801aa8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aaa:	a1 04 40 80 00       	mov    0x804004,%eax
  801aaf:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ab2:	83 ec 0c             	sub    $0xc,%esp
  801ab5:	ff 75 e0             	pushl  -0x20(%ebp)
  801ab8:	e8 13 05 00 00       	call   801fd0 <pageref>
  801abd:	89 c3                	mov    %eax,%ebx
  801abf:	89 3c 24             	mov    %edi,(%esp)
  801ac2:	e8 09 05 00 00       	call   801fd0 <pageref>
  801ac7:	83 c4 10             	add    $0x10,%esp
  801aca:	39 c3                	cmp    %eax,%ebx
  801acc:	0f 94 c1             	sete   %cl
  801acf:	0f b6 c9             	movzbl %cl,%ecx
  801ad2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ad5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801adb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ade:	39 ce                	cmp    %ecx,%esi
  801ae0:	74 1b                	je     801afd <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ae2:	39 c3                	cmp    %eax,%ebx
  801ae4:	75 c4                	jne    801aaa <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ae6:	8b 42 58             	mov    0x58(%edx),%eax
  801ae9:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aec:	50                   	push   %eax
  801aed:	56                   	push   %esi
  801aee:	68 f6 27 80 00       	push   $0x8027f6
  801af3:	e8 94 e7 ff ff       	call   80028c <cprintf>
  801af8:	83 c4 10             	add    $0x10,%esp
  801afb:	eb ad                	jmp    801aaa <_pipeisclosed+0xe>
	}
}
  801afd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b03:	5b                   	pop    %ebx
  801b04:	5e                   	pop    %esi
  801b05:	5f                   	pop    %edi
  801b06:	5d                   	pop    %ebp
  801b07:	c3                   	ret    

00801b08 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b08:	55                   	push   %ebp
  801b09:	89 e5                	mov    %esp,%ebp
  801b0b:	57                   	push   %edi
  801b0c:	56                   	push   %esi
  801b0d:	53                   	push   %ebx
  801b0e:	83 ec 28             	sub    $0x28,%esp
  801b11:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b14:	56                   	push   %esi
  801b15:	e8 0f f7 ff ff       	call   801229 <fd2data>
  801b1a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b1c:	83 c4 10             	add    $0x10,%esp
  801b1f:	bf 00 00 00 00       	mov    $0x0,%edi
  801b24:	eb 4b                	jmp    801b71 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b26:	89 da                	mov    %ebx,%edx
  801b28:	89 f0                	mov    %esi,%eax
  801b2a:	e8 6d ff ff ff       	call   801a9c <_pipeisclosed>
  801b2f:	85 c0                	test   %eax,%eax
  801b31:	75 48                	jne    801b7b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b33:	e8 3c f1 ff ff       	call   800c74 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b38:	8b 43 04             	mov    0x4(%ebx),%eax
  801b3b:	8b 0b                	mov    (%ebx),%ecx
  801b3d:	8d 51 20             	lea    0x20(%ecx),%edx
  801b40:	39 d0                	cmp    %edx,%eax
  801b42:	73 e2                	jae    801b26 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b47:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b4b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b4e:	89 c2                	mov    %eax,%edx
  801b50:	c1 fa 1f             	sar    $0x1f,%edx
  801b53:	89 d1                	mov    %edx,%ecx
  801b55:	c1 e9 1b             	shr    $0x1b,%ecx
  801b58:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b5b:	83 e2 1f             	and    $0x1f,%edx
  801b5e:	29 ca                	sub    %ecx,%edx
  801b60:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b64:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b68:	83 c0 01             	add    $0x1,%eax
  801b6b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b6e:	83 c7 01             	add    $0x1,%edi
  801b71:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b74:	75 c2                	jne    801b38 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b76:	8b 45 10             	mov    0x10(%ebp),%eax
  801b79:	eb 05                	jmp    801b80 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b7b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b83:	5b                   	pop    %ebx
  801b84:	5e                   	pop    %esi
  801b85:	5f                   	pop    %edi
  801b86:	5d                   	pop    %ebp
  801b87:	c3                   	ret    

00801b88 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	57                   	push   %edi
  801b8c:	56                   	push   %esi
  801b8d:	53                   	push   %ebx
  801b8e:	83 ec 18             	sub    $0x18,%esp
  801b91:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b94:	57                   	push   %edi
  801b95:	e8 8f f6 ff ff       	call   801229 <fd2data>
  801b9a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b9c:	83 c4 10             	add    $0x10,%esp
  801b9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ba4:	eb 3d                	jmp    801be3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ba6:	85 db                	test   %ebx,%ebx
  801ba8:	74 04                	je     801bae <devpipe_read+0x26>
				return i;
  801baa:	89 d8                	mov    %ebx,%eax
  801bac:	eb 44                	jmp    801bf2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bae:	89 f2                	mov    %esi,%edx
  801bb0:	89 f8                	mov    %edi,%eax
  801bb2:	e8 e5 fe ff ff       	call   801a9c <_pipeisclosed>
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	75 32                	jne    801bed <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bbb:	e8 b4 f0 ff ff       	call   800c74 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bc0:	8b 06                	mov    (%esi),%eax
  801bc2:	3b 46 04             	cmp    0x4(%esi),%eax
  801bc5:	74 df                	je     801ba6 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bc7:	99                   	cltd   
  801bc8:	c1 ea 1b             	shr    $0x1b,%edx
  801bcb:	01 d0                	add    %edx,%eax
  801bcd:	83 e0 1f             	and    $0x1f,%eax
  801bd0:	29 d0                	sub    %edx,%eax
  801bd2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bda:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bdd:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be0:	83 c3 01             	add    $0x1,%ebx
  801be3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801be6:	75 d8                	jne    801bc0 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801be8:	8b 45 10             	mov    0x10(%ebp),%eax
  801beb:	eb 05                	jmp    801bf2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bed:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf5:	5b                   	pop    %ebx
  801bf6:	5e                   	pop    %esi
  801bf7:	5f                   	pop    %edi
  801bf8:	5d                   	pop    %ebp
  801bf9:	c3                   	ret    

00801bfa <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bfa:	55                   	push   %ebp
  801bfb:	89 e5                	mov    %esp,%ebp
  801bfd:	56                   	push   %esi
  801bfe:	53                   	push   %ebx
  801bff:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c05:	50                   	push   %eax
  801c06:	e8 35 f6 ff ff       	call   801240 <fd_alloc>
  801c0b:	83 c4 10             	add    $0x10,%esp
  801c0e:	89 c2                	mov    %eax,%edx
  801c10:	85 c0                	test   %eax,%eax
  801c12:	0f 88 2c 01 00 00    	js     801d44 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c18:	83 ec 04             	sub    $0x4,%esp
  801c1b:	68 07 04 00 00       	push   $0x407
  801c20:	ff 75 f4             	pushl  -0xc(%ebp)
  801c23:	6a 00                	push   $0x0
  801c25:	e8 69 f0 ff ff       	call   800c93 <sys_page_alloc>
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	89 c2                	mov    %eax,%edx
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	0f 88 0d 01 00 00    	js     801d44 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c37:	83 ec 0c             	sub    $0xc,%esp
  801c3a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c3d:	50                   	push   %eax
  801c3e:	e8 fd f5 ff ff       	call   801240 <fd_alloc>
  801c43:	89 c3                	mov    %eax,%ebx
  801c45:	83 c4 10             	add    $0x10,%esp
  801c48:	85 c0                	test   %eax,%eax
  801c4a:	0f 88 e2 00 00 00    	js     801d32 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c50:	83 ec 04             	sub    $0x4,%esp
  801c53:	68 07 04 00 00       	push   $0x407
  801c58:	ff 75 f0             	pushl  -0x10(%ebp)
  801c5b:	6a 00                	push   $0x0
  801c5d:	e8 31 f0 ff ff       	call   800c93 <sys_page_alloc>
  801c62:	89 c3                	mov    %eax,%ebx
  801c64:	83 c4 10             	add    $0x10,%esp
  801c67:	85 c0                	test   %eax,%eax
  801c69:	0f 88 c3 00 00 00    	js     801d32 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c6f:	83 ec 0c             	sub    $0xc,%esp
  801c72:	ff 75 f4             	pushl  -0xc(%ebp)
  801c75:	e8 af f5 ff ff       	call   801229 <fd2data>
  801c7a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c7c:	83 c4 0c             	add    $0xc,%esp
  801c7f:	68 07 04 00 00       	push   $0x407
  801c84:	50                   	push   %eax
  801c85:	6a 00                	push   $0x0
  801c87:	e8 07 f0 ff ff       	call   800c93 <sys_page_alloc>
  801c8c:	89 c3                	mov    %eax,%ebx
  801c8e:	83 c4 10             	add    $0x10,%esp
  801c91:	85 c0                	test   %eax,%eax
  801c93:	0f 88 89 00 00 00    	js     801d22 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c99:	83 ec 0c             	sub    $0xc,%esp
  801c9c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c9f:	e8 85 f5 ff ff       	call   801229 <fd2data>
  801ca4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cab:	50                   	push   %eax
  801cac:	6a 00                	push   $0x0
  801cae:	56                   	push   %esi
  801caf:	6a 00                	push   $0x0
  801cb1:	e8 20 f0 ff ff       	call   800cd6 <sys_page_map>
  801cb6:	89 c3                	mov    %eax,%ebx
  801cb8:	83 c4 20             	add    $0x20,%esp
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	78 55                	js     801d14 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cbf:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cd4:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801cda:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cdd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ce2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ce9:	83 ec 0c             	sub    $0xc,%esp
  801cec:	ff 75 f4             	pushl  -0xc(%ebp)
  801cef:	e8 25 f5 ff ff       	call   801219 <fd2num>
  801cf4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cf7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cf9:	83 c4 04             	add    $0x4,%esp
  801cfc:	ff 75 f0             	pushl  -0x10(%ebp)
  801cff:	e8 15 f5 ff ff       	call   801219 <fd2num>
  801d04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d07:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d0a:	83 c4 10             	add    $0x10,%esp
  801d0d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d12:	eb 30                	jmp    801d44 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d14:	83 ec 08             	sub    $0x8,%esp
  801d17:	56                   	push   %esi
  801d18:	6a 00                	push   $0x0
  801d1a:	e8 f9 ef ff ff       	call   800d18 <sys_page_unmap>
  801d1f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d22:	83 ec 08             	sub    $0x8,%esp
  801d25:	ff 75 f0             	pushl  -0x10(%ebp)
  801d28:	6a 00                	push   $0x0
  801d2a:	e8 e9 ef ff ff       	call   800d18 <sys_page_unmap>
  801d2f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d32:	83 ec 08             	sub    $0x8,%esp
  801d35:	ff 75 f4             	pushl  -0xc(%ebp)
  801d38:	6a 00                	push   $0x0
  801d3a:	e8 d9 ef ff ff       	call   800d18 <sys_page_unmap>
  801d3f:	83 c4 10             	add    $0x10,%esp
  801d42:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d44:	89 d0                	mov    %edx,%eax
  801d46:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d49:	5b                   	pop    %ebx
  801d4a:	5e                   	pop    %esi
  801d4b:	5d                   	pop    %ebp
  801d4c:	c3                   	ret    

00801d4d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d4d:	55                   	push   %ebp
  801d4e:	89 e5                	mov    %esp,%ebp
  801d50:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d56:	50                   	push   %eax
  801d57:	ff 75 08             	pushl  0x8(%ebp)
  801d5a:	e8 30 f5 ff ff       	call   80128f <fd_lookup>
  801d5f:	83 c4 10             	add    $0x10,%esp
  801d62:	85 c0                	test   %eax,%eax
  801d64:	78 18                	js     801d7e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d66:	83 ec 0c             	sub    $0xc,%esp
  801d69:	ff 75 f4             	pushl  -0xc(%ebp)
  801d6c:	e8 b8 f4 ff ff       	call   801229 <fd2data>
	return _pipeisclosed(fd, p);
  801d71:	89 c2                	mov    %eax,%edx
  801d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d76:	e8 21 fd ff ff       	call   801a9c <_pipeisclosed>
  801d7b:	83 c4 10             	add    $0x10,%esp
}
  801d7e:	c9                   	leave  
  801d7f:	c3                   	ret    

00801d80 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d83:	b8 00 00 00 00       	mov    $0x0,%eax
  801d88:	5d                   	pop    %ebp
  801d89:	c3                   	ret    

00801d8a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d8a:	55                   	push   %ebp
  801d8b:	89 e5                	mov    %esp,%ebp
  801d8d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d90:	68 0e 28 80 00       	push   $0x80280e
  801d95:	ff 75 0c             	pushl  0xc(%ebp)
  801d98:	e8 f3 ea ff ff       	call   800890 <strcpy>
	return 0;
}
  801d9d:	b8 00 00 00 00       	mov    $0x0,%eax
  801da2:	c9                   	leave  
  801da3:	c3                   	ret    

00801da4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	57                   	push   %edi
  801da8:	56                   	push   %esi
  801da9:	53                   	push   %ebx
  801daa:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801db0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801db5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dbb:	eb 2d                	jmp    801dea <devcons_write+0x46>
		m = n - tot;
  801dbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dc0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dc2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dc5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dca:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dcd:	83 ec 04             	sub    $0x4,%esp
  801dd0:	53                   	push   %ebx
  801dd1:	03 45 0c             	add    0xc(%ebp),%eax
  801dd4:	50                   	push   %eax
  801dd5:	57                   	push   %edi
  801dd6:	e8 47 ec ff ff       	call   800a22 <memmove>
		sys_cputs(buf, m);
  801ddb:	83 c4 08             	add    $0x8,%esp
  801dde:	53                   	push   %ebx
  801ddf:	57                   	push   %edi
  801de0:	e8 f2 ed ff ff       	call   800bd7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801de5:	01 de                	add    %ebx,%esi
  801de7:	83 c4 10             	add    $0x10,%esp
  801dea:	89 f0                	mov    %esi,%eax
  801dec:	3b 75 10             	cmp    0x10(%ebp),%esi
  801def:	72 cc                	jb     801dbd <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801df1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df4:	5b                   	pop    %ebx
  801df5:	5e                   	pop    %esi
  801df6:	5f                   	pop    %edi
  801df7:	5d                   	pop    %ebp
  801df8:	c3                   	ret    

00801df9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801df9:	55                   	push   %ebp
  801dfa:	89 e5                	mov    %esp,%ebp
  801dfc:	83 ec 08             	sub    $0x8,%esp
  801dff:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e04:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e08:	74 2a                	je     801e34 <devcons_read+0x3b>
  801e0a:	eb 05                	jmp    801e11 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e0c:	e8 63 ee ff ff       	call   800c74 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e11:	e8 df ed ff ff       	call   800bf5 <sys_cgetc>
  801e16:	85 c0                	test   %eax,%eax
  801e18:	74 f2                	je     801e0c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	78 16                	js     801e34 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e1e:	83 f8 04             	cmp    $0x4,%eax
  801e21:	74 0c                	je     801e2f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e23:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e26:	88 02                	mov    %al,(%edx)
	return 1;
  801e28:	b8 01 00 00 00       	mov    $0x1,%eax
  801e2d:	eb 05                	jmp    801e34 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e2f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e34:	c9                   	leave  
  801e35:	c3                   	ret    

00801e36 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801e36:	55                   	push   %ebp
  801e37:	89 e5                	mov    %esp,%ebp
  801e39:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e42:	6a 01                	push   $0x1
  801e44:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e47:	50                   	push   %eax
  801e48:	e8 8a ed ff ff       	call   800bd7 <sys_cputs>
}
  801e4d:	83 c4 10             	add    $0x10,%esp
  801e50:	c9                   	leave  
  801e51:	c3                   	ret    

00801e52 <getchar>:

int
getchar(void)
{
  801e52:	55                   	push   %ebp
  801e53:	89 e5                	mov    %esp,%ebp
  801e55:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e58:	6a 01                	push   $0x1
  801e5a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e5d:	50                   	push   %eax
  801e5e:	6a 00                	push   $0x0
  801e60:	e8 90 f6 ff ff       	call   8014f5 <read>
	if (r < 0)
  801e65:	83 c4 10             	add    $0x10,%esp
  801e68:	85 c0                	test   %eax,%eax
  801e6a:	78 0f                	js     801e7b <getchar+0x29>
		return r;
	if (r < 1)
  801e6c:	85 c0                	test   %eax,%eax
  801e6e:	7e 06                	jle    801e76 <getchar+0x24>
		return -E_EOF;
	return c;
  801e70:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e74:	eb 05                	jmp    801e7b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e76:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e7b:	c9                   	leave  
  801e7c:	c3                   	ret    

00801e7d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e7d:	55                   	push   %ebp
  801e7e:	89 e5                	mov    %esp,%ebp
  801e80:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e86:	50                   	push   %eax
  801e87:	ff 75 08             	pushl  0x8(%ebp)
  801e8a:	e8 00 f4 ff ff       	call   80128f <fd_lookup>
  801e8f:	83 c4 10             	add    $0x10,%esp
  801e92:	85 c0                	test   %eax,%eax
  801e94:	78 11                	js     801ea7 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e99:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801e9f:	39 10                	cmp    %edx,(%eax)
  801ea1:	0f 94 c0             	sete   %al
  801ea4:	0f b6 c0             	movzbl %al,%eax
}
  801ea7:	c9                   	leave  
  801ea8:	c3                   	ret    

00801ea9 <opencons>:

int
opencons(void)
{
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
  801eac:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eaf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb2:	50                   	push   %eax
  801eb3:	e8 88 f3 ff ff       	call   801240 <fd_alloc>
  801eb8:	83 c4 10             	add    $0x10,%esp
		return r;
  801ebb:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ebd:	85 c0                	test   %eax,%eax
  801ebf:	78 3e                	js     801eff <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ec1:	83 ec 04             	sub    $0x4,%esp
  801ec4:	68 07 04 00 00       	push   $0x407
  801ec9:	ff 75 f4             	pushl  -0xc(%ebp)
  801ecc:	6a 00                	push   $0x0
  801ece:	e8 c0 ed ff ff       	call   800c93 <sys_page_alloc>
  801ed3:	83 c4 10             	add    $0x10,%esp
		return r;
  801ed6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ed8:	85 c0                	test   %eax,%eax
  801eda:	78 23                	js     801eff <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801edc:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eea:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ef1:	83 ec 0c             	sub    $0xc,%esp
  801ef4:	50                   	push   %eax
  801ef5:	e8 1f f3 ff ff       	call   801219 <fd2num>
  801efa:	89 c2                	mov    %eax,%edx
  801efc:	83 c4 10             	add    $0x10,%esp
}
  801eff:	89 d0                	mov    %edx,%eax
  801f01:	c9                   	leave  
  801f02:	c3                   	ret    

00801f03 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f03:	55                   	push   %ebp
  801f04:	89 e5                	mov    %esp,%ebp
  801f06:	56                   	push   %esi
  801f07:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f08:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f0b:	8b 35 08 30 80 00    	mov    0x803008,%esi
  801f11:	e8 3f ed ff ff       	call   800c55 <sys_getenvid>
  801f16:	83 ec 0c             	sub    $0xc,%esp
  801f19:	ff 75 0c             	pushl  0xc(%ebp)
  801f1c:	ff 75 08             	pushl  0x8(%ebp)
  801f1f:	56                   	push   %esi
  801f20:	50                   	push   %eax
  801f21:	68 1c 28 80 00       	push   $0x80281c
  801f26:	e8 61 e3 ff ff       	call   80028c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f2b:	83 c4 18             	add    $0x18,%esp
  801f2e:	53                   	push   %ebx
  801f2f:	ff 75 10             	pushl  0x10(%ebp)
  801f32:	e8 04 e3 ff ff       	call   80023b <vcprintf>
	cprintf("\n");
  801f37:	c7 04 24 07 28 80 00 	movl   $0x802807,(%esp)
  801f3e:	e8 49 e3 ff ff       	call   80028c <cprintf>
  801f43:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f46:	cc                   	int3   
  801f47:	eb fd                	jmp    801f46 <_panic+0x43>

00801f49 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f49:	55                   	push   %ebp
  801f4a:	89 e5                	mov    %esp,%ebp
  801f4c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f4f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f56:	75 4a                	jne    801fa2 <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  801f58:	a1 04 40 80 00       	mov    0x804004,%eax
  801f5d:	8b 40 48             	mov    0x48(%eax),%eax
  801f60:	83 ec 04             	sub    $0x4,%esp
  801f63:	6a 07                	push   $0x7
  801f65:	68 00 f0 bf ee       	push   $0xeebff000
  801f6a:	50                   	push   %eax
  801f6b:	e8 23 ed ff ff       	call   800c93 <sys_page_alloc>
  801f70:	83 c4 10             	add    $0x10,%esp
  801f73:	85 c0                	test   %eax,%eax
  801f75:	79 12                	jns    801f89 <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  801f77:	50                   	push   %eax
  801f78:	68 40 28 80 00       	push   $0x802840
  801f7d:	6a 21                	push   $0x21
  801f7f:	68 58 28 80 00       	push   $0x802858
  801f84:	e8 7a ff ff ff       	call   801f03 <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801f89:	a1 04 40 80 00       	mov    0x804004,%eax
  801f8e:	8b 40 48             	mov    0x48(%eax),%eax
  801f91:	83 ec 08             	sub    $0x8,%esp
  801f94:	68 ac 1f 80 00       	push   $0x801fac
  801f99:	50                   	push   %eax
  801f9a:	e8 3f ee ff ff       	call   800dde <sys_env_set_pgfault_upcall>
  801f9f:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fa2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa5:	a3 00 60 80 00       	mov    %eax,0x806000
  801faa:	c9                   	leave  
  801fab:	c3                   	ret    

00801fac <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fac:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fad:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fb2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fb4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  801fb7:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  801fba:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  801fbe:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  801fc3:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  801fc7:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801fc9:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  801fca:	83 c4 04             	add    $0x4,%esp
	popfl
  801fcd:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801fce:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  801fcf:	c3                   	ret    

00801fd0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fd0:	55                   	push   %ebp
  801fd1:	89 e5                	mov    %esp,%ebp
  801fd3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fd6:	89 d0                	mov    %edx,%eax
  801fd8:	c1 e8 16             	shr    $0x16,%eax
  801fdb:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fe2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fe7:	f6 c1 01             	test   $0x1,%cl
  801fea:	74 1d                	je     802009 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fec:	c1 ea 0c             	shr    $0xc,%edx
  801fef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ff6:	f6 c2 01             	test   $0x1,%dl
  801ff9:	74 0e                	je     802009 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ffb:	c1 ea 0c             	shr    $0xc,%edx
  801ffe:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802005:	ef 
  802006:	0f b7 c0             	movzwl %ax,%eax
}
  802009:	5d                   	pop    %ebp
  80200a:	c3                   	ret    
  80200b:	66 90                	xchg   %ax,%ax
  80200d:	66 90                	xchg   %ax,%ax
  80200f:	90                   	nop

00802010 <__udivdi3>:
  802010:	55                   	push   %ebp
  802011:	57                   	push   %edi
  802012:	56                   	push   %esi
  802013:	53                   	push   %ebx
  802014:	83 ec 1c             	sub    $0x1c,%esp
  802017:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80201b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80201f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802023:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802027:	85 f6                	test   %esi,%esi
  802029:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80202d:	89 ca                	mov    %ecx,%edx
  80202f:	89 f8                	mov    %edi,%eax
  802031:	75 3d                	jne    802070 <__udivdi3+0x60>
  802033:	39 cf                	cmp    %ecx,%edi
  802035:	0f 87 c5 00 00 00    	ja     802100 <__udivdi3+0xf0>
  80203b:	85 ff                	test   %edi,%edi
  80203d:	89 fd                	mov    %edi,%ebp
  80203f:	75 0b                	jne    80204c <__udivdi3+0x3c>
  802041:	b8 01 00 00 00       	mov    $0x1,%eax
  802046:	31 d2                	xor    %edx,%edx
  802048:	f7 f7                	div    %edi
  80204a:	89 c5                	mov    %eax,%ebp
  80204c:	89 c8                	mov    %ecx,%eax
  80204e:	31 d2                	xor    %edx,%edx
  802050:	f7 f5                	div    %ebp
  802052:	89 c1                	mov    %eax,%ecx
  802054:	89 d8                	mov    %ebx,%eax
  802056:	89 cf                	mov    %ecx,%edi
  802058:	f7 f5                	div    %ebp
  80205a:	89 c3                	mov    %eax,%ebx
  80205c:	89 d8                	mov    %ebx,%eax
  80205e:	89 fa                	mov    %edi,%edx
  802060:	83 c4 1c             	add    $0x1c,%esp
  802063:	5b                   	pop    %ebx
  802064:	5e                   	pop    %esi
  802065:	5f                   	pop    %edi
  802066:	5d                   	pop    %ebp
  802067:	c3                   	ret    
  802068:	90                   	nop
  802069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802070:	39 ce                	cmp    %ecx,%esi
  802072:	77 74                	ja     8020e8 <__udivdi3+0xd8>
  802074:	0f bd fe             	bsr    %esi,%edi
  802077:	83 f7 1f             	xor    $0x1f,%edi
  80207a:	0f 84 98 00 00 00    	je     802118 <__udivdi3+0x108>
  802080:	bb 20 00 00 00       	mov    $0x20,%ebx
  802085:	89 f9                	mov    %edi,%ecx
  802087:	89 c5                	mov    %eax,%ebp
  802089:	29 fb                	sub    %edi,%ebx
  80208b:	d3 e6                	shl    %cl,%esi
  80208d:	89 d9                	mov    %ebx,%ecx
  80208f:	d3 ed                	shr    %cl,%ebp
  802091:	89 f9                	mov    %edi,%ecx
  802093:	d3 e0                	shl    %cl,%eax
  802095:	09 ee                	or     %ebp,%esi
  802097:	89 d9                	mov    %ebx,%ecx
  802099:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80209d:	89 d5                	mov    %edx,%ebp
  80209f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020a3:	d3 ed                	shr    %cl,%ebp
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	d3 e2                	shl    %cl,%edx
  8020a9:	89 d9                	mov    %ebx,%ecx
  8020ab:	d3 e8                	shr    %cl,%eax
  8020ad:	09 c2                	or     %eax,%edx
  8020af:	89 d0                	mov    %edx,%eax
  8020b1:	89 ea                	mov    %ebp,%edx
  8020b3:	f7 f6                	div    %esi
  8020b5:	89 d5                	mov    %edx,%ebp
  8020b7:	89 c3                	mov    %eax,%ebx
  8020b9:	f7 64 24 0c          	mull   0xc(%esp)
  8020bd:	39 d5                	cmp    %edx,%ebp
  8020bf:	72 10                	jb     8020d1 <__udivdi3+0xc1>
  8020c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020c5:	89 f9                	mov    %edi,%ecx
  8020c7:	d3 e6                	shl    %cl,%esi
  8020c9:	39 c6                	cmp    %eax,%esi
  8020cb:	73 07                	jae    8020d4 <__udivdi3+0xc4>
  8020cd:	39 d5                	cmp    %edx,%ebp
  8020cf:	75 03                	jne    8020d4 <__udivdi3+0xc4>
  8020d1:	83 eb 01             	sub    $0x1,%ebx
  8020d4:	31 ff                	xor    %edi,%edi
  8020d6:	89 d8                	mov    %ebx,%eax
  8020d8:	89 fa                	mov    %edi,%edx
  8020da:	83 c4 1c             	add    $0x1c,%esp
  8020dd:	5b                   	pop    %ebx
  8020de:	5e                   	pop    %esi
  8020df:	5f                   	pop    %edi
  8020e0:	5d                   	pop    %ebp
  8020e1:	c3                   	ret    
  8020e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020e8:	31 ff                	xor    %edi,%edi
  8020ea:	31 db                	xor    %ebx,%ebx
  8020ec:	89 d8                	mov    %ebx,%eax
  8020ee:	89 fa                	mov    %edi,%edx
  8020f0:	83 c4 1c             	add    $0x1c,%esp
  8020f3:	5b                   	pop    %ebx
  8020f4:	5e                   	pop    %esi
  8020f5:	5f                   	pop    %edi
  8020f6:	5d                   	pop    %ebp
  8020f7:	c3                   	ret    
  8020f8:	90                   	nop
  8020f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802100:	89 d8                	mov    %ebx,%eax
  802102:	f7 f7                	div    %edi
  802104:	31 ff                	xor    %edi,%edi
  802106:	89 c3                	mov    %eax,%ebx
  802108:	89 d8                	mov    %ebx,%eax
  80210a:	89 fa                	mov    %edi,%edx
  80210c:	83 c4 1c             	add    $0x1c,%esp
  80210f:	5b                   	pop    %ebx
  802110:	5e                   	pop    %esi
  802111:	5f                   	pop    %edi
  802112:	5d                   	pop    %ebp
  802113:	c3                   	ret    
  802114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802118:	39 ce                	cmp    %ecx,%esi
  80211a:	72 0c                	jb     802128 <__udivdi3+0x118>
  80211c:	31 db                	xor    %ebx,%ebx
  80211e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802122:	0f 87 34 ff ff ff    	ja     80205c <__udivdi3+0x4c>
  802128:	bb 01 00 00 00       	mov    $0x1,%ebx
  80212d:	e9 2a ff ff ff       	jmp    80205c <__udivdi3+0x4c>
  802132:	66 90                	xchg   %ax,%ax
  802134:	66 90                	xchg   %ax,%ax
  802136:	66 90                	xchg   %ax,%ax
  802138:	66 90                	xchg   %ax,%ax
  80213a:	66 90                	xchg   %ax,%ax
  80213c:	66 90                	xchg   %ax,%ax
  80213e:	66 90                	xchg   %ax,%ax

00802140 <__umoddi3>:
  802140:	55                   	push   %ebp
  802141:	57                   	push   %edi
  802142:	56                   	push   %esi
  802143:	53                   	push   %ebx
  802144:	83 ec 1c             	sub    $0x1c,%esp
  802147:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80214b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80214f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802153:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802157:	85 d2                	test   %edx,%edx
  802159:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80215d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802161:	89 f3                	mov    %esi,%ebx
  802163:	89 3c 24             	mov    %edi,(%esp)
  802166:	89 74 24 04          	mov    %esi,0x4(%esp)
  80216a:	75 1c                	jne    802188 <__umoddi3+0x48>
  80216c:	39 f7                	cmp    %esi,%edi
  80216e:	76 50                	jbe    8021c0 <__umoddi3+0x80>
  802170:	89 c8                	mov    %ecx,%eax
  802172:	89 f2                	mov    %esi,%edx
  802174:	f7 f7                	div    %edi
  802176:	89 d0                	mov    %edx,%eax
  802178:	31 d2                	xor    %edx,%edx
  80217a:	83 c4 1c             	add    $0x1c,%esp
  80217d:	5b                   	pop    %ebx
  80217e:	5e                   	pop    %esi
  80217f:	5f                   	pop    %edi
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    
  802182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802188:	39 f2                	cmp    %esi,%edx
  80218a:	89 d0                	mov    %edx,%eax
  80218c:	77 52                	ja     8021e0 <__umoddi3+0xa0>
  80218e:	0f bd ea             	bsr    %edx,%ebp
  802191:	83 f5 1f             	xor    $0x1f,%ebp
  802194:	75 5a                	jne    8021f0 <__umoddi3+0xb0>
  802196:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80219a:	0f 82 e0 00 00 00    	jb     802280 <__umoddi3+0x140>
  8021a0:	39 0c 24             	cmp    %ecx,(%esp)
  8021a3:	0f 86 d7 00 00 00    	jbe    802280 <__umoddi3+0x140>
  8021a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021b1:	83 c4 1c             	add    $0x1c,%esp
  8021b4:	5b                   	pop    %ebx
  8021b5:	5e                   	pop    %esi
  8021b6:	5f                   	pop    %edi
  8021b7:	5d                   	pop    %ebp
  8021b8:	c3                   	ret    
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	85 ff                	test   %edi,%edi
  8021c2:	89 fd                	mov    %edi,%ebp
  8021c4:	75 0b                	jne    8021d1 <__umoddi3+0x91>
  8021c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021cb:	31 d2                	xor    %edx,%edx
  8021cd:	f7 f7                	div    %edi
  8021cf:	89 c5                	mov    %eax,%ebp
  8021d1:	89 f0                	mov    %esi,%eax
  8021d3:	31 d2                	xor    %edx,%edx
  8021d5:	f7 f5                	div    %ebp
  8021d7:	89 c8                	mov    %ecx,%eax
  8021d9:	f7 f5                	div    %ebp
  8021db:	89 d0                	mov    %edx,%eax
  8021dd:	eb 99                	jmp    802178 <__umoddi3+0x38>
  8021df:	90                   	nop
  8021e0:	89 c8                	mov    %ecx,%eax
  8021e2:	89 f2                	mov    %esi,%edx
  8021e4:	83 c4 1c             	add    $0x1c,%esp
  8021e7:	5b                   	pop    %ebx
  8021e8:	5e                   	pop    %esi
  8021e9:	5f                   	pop    %edi
  8021ea:	5d                   	pop    %ebp
  8021eb:	c3                   	ret    
  8021ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	8b 34 24             	mov    (%esp),%esi
  8021f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021f8:	89 e9                	mov    %ebp,%ecx
  8021fa:	29 ef                	sub    %ebp,%edi
  8021fc:	d3 e0                	shl    %cl,%eax
  8021fe:	89 f9                	mov    %edi,%ecx
  802200:	89 f2                	mov    %esi,%edx
  802202:	d3 ea                	shr    %cl,%edx
  802204:	89 e9                	mov    %ebp,%ecx
  802206:	09 c2                	or     %eax,%edx
  802208:	89 d8                	mov    %ebx,%eax
  80220a:	89 14 24             	mov    %edx,(%esp)
  80220d:	89 f2                	mov    %esi,%edx
  80220f:	d3 e2                	shl    %cl,%edx
  802211:	89 f9                	mov    %edi,%ecx
  802213:	89 54 24 04          	mov    %edx,0x4(%esp)
  802217:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80221b:	d3 e8                	shr    %cl,%eax
  80221d:	89 e9                	mov    %ebp,%ecx
  80221f:	89 c6                	mov    %eax,%esi
  802221:	d3 e3                	shl    %cl,%ebx
  802223:	89 f9                	mov    %edi,%ecx
  802225:	89 d0                	mov    %edx,%eax
  802227:	d3 e8                	shr    %cl,%eax
  802229:	89 e9                	mov    %ebp,%ecx
  80222b:	09 d8                	or     %ebx,%eax
  80222d:	89 d3                	mov    %edx,%ebx
  80222f:	89 f2                	mov    %esi,%edx
  802231:	f7 34 24             	divl   (%esp)
  802234:	89 d6                	mov    %edx,%esi
  802236:	d3 e3                	shl    %cl,%ebx
  802238:	f7 64 24 04          	mull   0x4(%esp)
  80223c:	39 d6                	cmp    %edx,%esi
  80223e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802242:	89 d1                	mov    %edx,%ecx
  802244:	89 c3                	mov    %eax,%ebx
  802246:	72 08                	jb     802250 <__umoddi3+0x110>
  802248:	75 11                	jne    80225b <__umoddi3+0x11b>
  80224a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80224e:	73 0b                	jae    80225b <__umoddi3+0x11b>
  802250:	2b 44 24 04          	sub    0x4(%esp),%eax
  802254:	1b 14 24             	sbb    (%esp),%edx
  802257:	89 d1                	mov    %edx,%ecx
  802259:	89 c3                	mov    %eax,%ebx
  80225b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80225f:	29 da                	sub    %ebx,%edx
  802261:	19 ce                	sbb    %ecx,%esi
  802263:	89 f9                	mov    %edi,%ecx
  802265:	89 f0                	mov    %esi,%eax
  802267:	d3 e0                	shl    %cl,%eax
  802269:	89 e9                	mov    %ebp,%ecx
  80226b:	d3 ea                	shr    %cl,%edx
  80226d:	89 e9                	mov    %ebp,%ecx
  80226f:	d3 ee                	shr    %cl,%esi
  802271:	09 d0                	or     %edx,%eax
  802273:	89 f2                	mov    %esi,%edx
  802275:	83 c4 1c             	add    $0x1c,%esp
  802278:	5b                   	pop    %ebx
  802279:	5e                   	pop    %esi
  80227a:	5f                   	pop    %edi
  80227b:	5d                   	pop    %ebp
  80227c:	c3                   	ret    
  80227d:	8d 76 00             	lea    0x0(%esi),%esi
  802280:	29 f9                	sub    %edi,%ecx
  802282:	19 d6                	sbb    %edx,%esi
  802284:	89 74 24 04          	mov    %esi,0x4(%esp)
  802288:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80228c:	e9 18 ff ff ff       	jmp    8021a9 <__umoddi3+0x69>
