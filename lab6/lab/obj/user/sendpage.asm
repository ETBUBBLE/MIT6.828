
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
  800039:	e8 77 0f 00 00       	call   800fb5 <fork>
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
  800057:	e8 06 11 00 00       	call   801162 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 60 27 80 00       	push   $0x802760
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
  80009d:	68 74 27 80 00       	push   $0x802774
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
  8000db:	e8 eb 10 00 00       	call   8011cb <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 08 40 80 00       	mov    0x804008,%eax
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
  800131:	e8 95 10 00 00       	call   8011cb <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 19 10 00 00       	call   801162 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 60 27 80 00       	push   $0x802760
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
  80018a:	68 94 27 80 00       	push   $0x802794
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
  8001b6:	a3 08 40 80 00       	mov    %eax,0x804008

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
  8001e5:	e8 39 12 00 00       	call   801423 <close_all>
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
  8002ef:	e8 cc 21 00 00       	call   8024c0 <__udivdi3>
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
  800332:	e8 b9 22 00 00       	call   8025f0 <__umoddi3>
  800337:	83 c4 14             	add    $0x14,%esp
  80033a:	0f be 80 0c 28 80 00 	movsbl 0x80280c(%eax),%eax
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
  8003fc:	ff 24 85 40 29 80 00 	jmp    *0x802940(,%eax,4)
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
  8004c3:	8b 14 85 a0 2a 80 00 	mov    0x802aa0(,%eax,4),%edx
  8004ca:	85 d2                	test   %edx,%edx
  8004cc:	75 1b                	jne    8004e9 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8004ce:	50                   	push   %eax
  8004cf:	68 24 28 80 00       	push   $0x802824
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
  8004ea:	68 99 2c 80 00       	push   $0x802c99
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
  800514:	b8 1d 28 80 00       	mov    $0x80281d,%eax
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
  800c3c:	68 ff 2a 80 00       	push   $0x802aff
  800c41:	6a 23                	push   $0x23
  800c43:	68 1c 2b 80 00       	push   $0x802b1c
  800c48:	e8 5c 17 00 00       	call   8023a9 <_panic>

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
  800cbd:	68 ff 2a 80 00       	push   $0x802aff
  800cc2:	6a 23                	push   $0x23
  800cc4:	68 1c 2b 80 00       	push   $0x802b1c
  800cc9:	e8 db 16 00 00       	call   8023a9 <_panic>

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
  800cff:	68 ff 2a 80 00       	push   $0x802aff
  800d04:	6a 23                	push   $0x23
  800d06:	68 1c 2b 80 00       	push   $0x802b1c
  800d0b:	e8 99 16 00 00       	call   8023a9 <_panic>

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
  800d41:	68 ff 2a 80 00       	push   $0x802aff
  800d46:	6a 23                	push   $0x23
  800d48:	68 1c 2b 80 00       	push   $0x802b1c
  800d4d:	e8 57 16 00 00       	call   8023a9 <_panic>

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
  800d83:	68 ff 2a 80 00       	push   $0x802aff
  800d88:	6a 23                	push   $0x23
  800d8a:	68 1c 2b 80 00       	push   $0x802b1c
  800d8f:	e8 15 16 00 00       	call   8023a9 <_panic>

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
  800dc5:	68 ff 2a 80 00       	push   $0x802aff
  800dca:	6a 23                	push   $0x23
  800dcc:	68 1c 2b 80 00       	push   $0x802b1c
  800dd1:	e8 d3 15 00 00       	call   8023a9 <_panic>

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
  800e07:	68 ff 2a 80 00       	push   $0x802aff
  800e0c:	6a 23                	push   $0x23
  800e0e:	68 1c 2b 80 00       	push   $0x802b1c
  800e13:	e8 91 15 00 00       	call   8023a9 <_panic>

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
  800e6b:	68 ff 2a 80 00       	push   $0x802aff
  800e70:	6a 23                	push   $0x23
  800e72:	68 1c 2b 80 00       	push   $0x802b1c
  800e77:	e8 2d 15 00 00       	call   8023a9 <_panic>

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

00800e84 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
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
  800e8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e94:	89 d1                	mov    %edx,%ecx
  800e96:	89 d3                	mov    %edx,%ebx
  800e98:	89 d7                	mov    %edx,%edi
  800e9a:	89 d6                	mov    %edx,%esi
  800e9c:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eae:	b8 10 00 00 00       	mov    $0x10,%eax
  800eb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb6:	89 cb                	mov    %ecx,%ebx
  800eb8:	89 cf                	mov    %ecx,%edi
  800eba:	89 ce                	mov    %ecx,%esi
  800ebc:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	53                   	push   %ebx
  800ec7:	83 ec 04             	sub    $0x4,%esp
  800eca:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ecd:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800ecf:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ed3:	74 2d                	je     800f02 <pgfault+0x3f>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800ed5:	89 d8                	mov    %ebx,%eax
  800ed7:	c1 e8 16             	shr    $0x16,%eax
  800eda:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ee1:	a8 01                	test   $0x1,%al
  800ee3:	74 1d                	je     800f02 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800ee5:	89 d8                	mov    %ebx,%eax
  800ee7:	c1 e8 0c             	shr    $0xc,%eax
  800eea:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800ef1:	f6 c2 01             	test   $0x1,%dl
  800ef4:	74 0c                	je     800f02 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800ef6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800efd:	f6 c4 08             	test   $0x8,%ah
  800f00:	75 14                	jne    800f16 <pgfault+0x53>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
	)) panic("Neither the fault is a write nor copy-on-write page.\n");
  800f02:	83 ec 04             	sub    $0x4,%esp
  800f05:	68 2c 2b 80 00       	push   $0x802b2c
  800f0a:	6a 1f                	push   $0x1f
  800f0c:	68 62 2b 80 00       	push   $0x802b62
  800f11:	e8 93 14 00 00       	call   8023a9 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if((r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W)) < 0){
  800f16:	83 ec 04             	sub    $0x4,%esp
  800f19:	6a 07                	push   $0x7
  800f1b:	68 00 f0 7f 00       	push   $0x7ff000
  800f20:	6a 00                	push   $0x0
  800f22:	e8 6c fd ff ff       	call   800c93 <sys_page_alloc>
  800f27:	83 c4 10             	add    $0x10,%esp
  800f2a:	85 c0                	test   %eax,%eax
  800f2c:	79 12                	jns    800f40 <pgfault+0x7d>
		 panic("sys_page_alloc: %e\n", r);
  800f2e:	50                   	push   %eax
  800f2f:	68 6d 2b 80 00       	push   $0x802b6d
  800f34:	6a 29                	push   $0x29
  800f36:	68 62 2b 80 00       	push   $0x802b62
  800f3b:	e8 69 14 00 00       	call   8023a9 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f40:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800f46:	83 ec 04             	sub    $0x4,%esp
  800f49:	68 00 10 00 00       	push   $0x1000
  800f4e:	53                   	push   %ebx
  800f4f:	68 00 f0 7f 00       	push   $0x7ff000
  800f54:	e8 31 fb ff ff       	call   800a8a <memcpy>
	if ((r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  800f59:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f60:	53                   	push   %ebx
  800f61:	6a 00                	push   $0x0
  800f63:	68 00 f0 7f 00       	push   $0x7ff000
  800f68:	6a 00                	push   $0x0
  800f6a:	e8 67 fd ff ff       	call   800cd6 <sys_page_map>
  800f6f:	83 c4 20             	add    $0x20,%esp
  800f72:	85 c0                	test   %eax,%eax
  800f74:	79 12                	jns    800f88 <pgfault+0xc5>
        panic("sys_page_map: %e\n", r);
  800f76:	50                   	push   %eax
  800f77:	68 81 2b 80 00       	push   $0x802b81
  800f7c:	6a 2e                	push   $0x2e
  800f7e:	68 62 2b 80 00       	push   $0x802b62
  800f83:	e8 21 14 00 00       	call   8023a9 <_panic>
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  800f88:	83 ec 08             	sub    $0x8,%esp
  800f8b:	68 00 f0 7f 00       	push   $0x7ff000
  800f90:	6a 00                	push   $0x0
  800f92:	e8 81 fd ff ff       	call   800d18 <sys_page_unmap>
  800f97:	83 c4 10             	add    $0x10,%esp
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	79 12                	jns    800fb0 <pgfault+0xed>
        panic("sys_page_unmap: %e\n", r);
  800f9e:	50                   	push   %eax
  800f9f:	68 93 2b 80 00       	push   $0x802b93
  800fa4:	6a 30                	push   $0x30
  800fa6:	68 62 2b 80 00       	push   $0x802b62
  800fab:	e8 f9 13 00 00       	call   8023a9 <_panic>
	//panic("pgfault not implemented");
}
  800fb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb3:	c9                   	leave  
  800fb4:	c3                   	ret    

00800fb5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	57                   	push   %edi
  800fb9:	56                   	push   %esi
  800fba:	53                   	push   %ebx
  800fbb:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	envid_t cenvid;
    unsigned pn;
    int r;
	set_pgfault_handler(pgfault);
  800fbe:	68 c3 0e 80 00       	push   $0x800ec3
  800fc3:	e8 27 14 00 00       	call   8023ef <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fc8:	b8 07 00 00 00       	mov    $0x7,%eax
  800fcd:	cd 30                	int    $0x30
  800fcf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((cenvid = sys_exofork()) < 0){
  800fd2:	83 c4 10             	add    $0x10,%esp
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	79 14                	jns    800fed <fork+0x38>
		panic("sys_exofork failed");
  800fd9:	83 ec 04             	sub    $0x4,%esp
  800fdc:	68 a7 2b 80 00       	push   $0x802ba7
  800fe1:	6a 6f                	push   $0x6f
  800fe3:	68 62 2b 80 00       	push   $0x802b62
  800fe8:	e8 bc 13 00 00       	call   8023a9 <_panic>
  800fed:	89 c7                	mov    %eax,%edi
		return cenvid;
	}
	if(cenvid>0){
  800fef:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ff3:	0f 8e 2b 01 00 00    	jle    801124 <fork+0x16f>
  800ff9:	bb 00 08 00 00       	mov    $0x800,%ebx
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
  800ffe:	89 d8                	mov    %ebx,%eax
  801000:	c1 e8 0a             	shr    $0xa,%eax
  801003:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80100a:	a8 01                	test   $0x1,%al
  80100c:	0f 84 bf 00 00 00    	je     8010d1 <fork+0x11c>
  801012:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801019:	a8 01                	test   $0x1,%al
  80101b:	0f 84 b0 00 00 00    	je     8010d1 <fork+0x11c>
  801021:	89 de                	mov    %ebx,%esi
  801023:	c1 e6 0c             	shl    $0xc,%esi
{
	int r;

	// LAB 4: Your code here.
	void* vaddr=(void*)(pn*PGSIZE);
	if(uvpt[pn]&PTE_SHARE){
  801026:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80102d:	f6 c4 04             	test   $0x4,%ah
  801030:	74 29                	je     80105b <fork+0xa6>
		if((r=sys_page_map(0,vaddr,envid,vaddr,uvpt[pn]&PTE_SYSCALL))<0)return r;
  801032:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801039:	83 ec 0c             	sub    $0xc,%esp
  80103c:	25 07 0e 00 00       	and    $0xe07,%eax
  801041:	50                   	push   %eax
  801042:	56                   	push   %esi
  801043:	57                   	push   %edi
  801044:	56                   	push   %esi
  801045:	6a 00                	push   $0x0
  801047:	e8 8a fc ff ff       	call   800cd6 <sys_page_map>
  80104c:	83 c4 20             	add    $0x20,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	ba 00 00 00 00       	mov    $0x0,%edx
  801056:	0f 4f c2             	cmovg  %edx,%eax
  801059:	eb 72                	jmp    8010cd <fork+0x118>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  80105b:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801062:	a8 02                	test   $0x2,%al
  801064:	75 0c                	jne    801072 <fork+0xbd>
  801066:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80106d:	f6 c4 08             	test   $0x8,%ah
  801070:	74 3f                	je     8010b1 <fork+0xfc>
		if ((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  801072:	83 ec 0c             	sub    $0xc,%esp
  801075:	68 05 08 00 00       	push   $0x805
  80107a:	56                   	push   %esi
  80107b:	57                   	push   %edi
  80107c:	56                   	push   %esi
  80107d:	6a 00                	push   $0x0
  80107f:	e8 52 fc ff ff       	call   800cd6 <sys_page_map>
  801084:	83 c4 20             	add    $0x20,%esp
  801087:	85 c0                	test   %eax,%eax
  801089:	0f 88 b1 00 00 00    	js     801140 <fork+0x18b>
            return r;
        if ((r = sys_page_map(0, vaddr, 0, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  80108f:	83 ec 0c             	sub    $0xc,%esp
  801092:	68 05 08 00 00       	push   $0x805
  801097:	56                   	push   %esi
  801098:	6a 00                	push   $0x0
  80109a:	56                   	push   %esi
  80109b:	6a 00                	push   $0x0
  80109d:	e8 34 fc ff ff       	call   800cd6 <sys_page_map>
  8010a2:	83 c4 20             	add    $0x20,%esp
  8010a5:	85 c0                	test   %eax,%eax
  8010a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010ac:	0f 4f c1             	cmovg  %ecx,%eax
  8010af:	eb 1c                	jmp    8010cd <fork+0x118>
            return r;
	}
	else if((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U)) < 0) {
  8010b1:	83 ec 0c             	sub    $0xc,%esp
  8010b4:	6a 05                	push   $0x5
  8010b6:	56                   	push   %esi
  8010b7:	57                   	push   %edi
  8010b8:	56                   	push   %esi
  8010b9:	6a 00                	push   $0x0
  8010bb:	e8 16 fc ff ff       	call   800cd6 <sys_page_map>
  8010c0:	83 c4 20             	add    $0x20,%esp
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010ca:	0f 4f c1             	cmovg  %ecx,%eax
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
  8010cd:	85 c0                	test   %eax,%eax
  8010cf:	78 6f                	js     801140 <fork+0x18b>
	if ((cenvid = sys_exofork()) < 0){
		panic("sys_exofork failed");
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  8010d1:	83 c3 01             	add    $0x1,%ebx
  8010d4:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  8010da:	0f 85 1e ff ff ff    	jne    800ffe <fork+0x49>
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
                    return r;
		}
		if ((r = sys_page_alloc(cenvid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  8010e0:	83 ec 04             	sub    $0x4,%esp
  8010e3:	6a 07                	push   $0x7
  8010e5:	68 00 f0 bf ee       	push   $0xeebff000
  8010ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010ed:	57                   	push   %edi
  8010ee:	e8 a0 fb ff ff       	call   800c93 <sys_page_alloc>
  8010f3:	83 c4 10             	add    $0x10,%esp
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	78 46                	js     801140 <fork+0x18b>
            return r;
		extern void _pgfault_upcall(void);
		if ((r = sys_env_set_pgfault_upcall(cenvid, _pgfault_upcall)) < 0)
  8010fa:	83 ec 08             	sub    $0x8,%esp
  8010fd:	68 52 24 80 00       	push   $0x802452
  801102:	57                   	push   %edi
  801103:	e8 d6 fc ff ff       	call   800dde <sys_env_set_pgfault_upcall>
  801108:	83 c4 10             	add    $0x10,%esp
  80110b:	85 c0                	test   %eax,%eax
  80110d:	78 31                	js     801140 <fork+0x18b>
            return r;
		if ((r = sys_env_set_status(cenvid, ENV_RUNNABLE)) < 0)
  80110f:	83 ec 08             	sub    $0x8,%esp
  801112:	6a 02                	push   $0x2
  801114:	57                   	push   %edi
  801115:	e8 40 fc ff ff       	call   800d5a <sys_env_set_status>
  80111a:	83 c4 10             	add    $0x10,%esp
            return r;
        return cenvid;
  80111d:	85 c0                	test   %eax,%eax
  80111f:	0f 49 c7             	cmovns %edi,%eax
  801122:	eb 1c                	jmp    801140 <fork+0x18b>
	}
	else {
		thisenv = &envs[ENVX(sys_getenvid())];
  801124:	e8 2c fb ff ff       	call   800c55 <sys_getenvid>
  801129:	25 ff 03 00 00       	and    $0x3ff,%eax
  80112e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801131:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801136:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  80113b:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//panic("fork not implemented");
	
}
  801140:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801143:	5b                   	pop    %ebx
  801144:	5e                   	pop    %esi
  801145:	5f                   	pop    %edi
  801146:	5d                   	pop    %ebp
  801147:	c3                   	ret    

00801148 <sfork>:

// Challenge!
int
sfork(void)
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80114e:	68 ba 2b 80 00       	push   $0x802bba
  801153:	68 8d 00 00 00       	push   $0x8d
  801158:	68 62 2b 80 00       	push   $0x802b62
  80115d:	e8 47 12 00 00       	call   8023a9 <_panic>

00801162 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801162:	55                   	push   %ebp
  801163:	89 e5                	mov    %esp,%ebp
  801165:	56                   	push   %esi
  801166:	53                   	push   %ebx
  801167:	8b 75 08             	mov    0x8(%ebp),%esi
  80116a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80116d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801170:	85 c0                	test   %eax,%eax
  801172:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801177:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  80117a:	83 ec 0c             	sub    $0xc,%esp
  80117d:	50                   	push   %eax
  80117e:	e8 c0 fc ff ff       	call   800e43 <sys_ipc_recv>
  801183:	83 c4 10             	add    $0x10,%esp
  801186:	85 c0                	test   %eax,%eax
  801188:	79 16                	jns    8011a0 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  80118a:	85 f6                	test   %esi,%esi
  80118c:	74 06                	je     801194 <ipc_recv+0x32>
            *from_env_store = 0;
  80118e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801194:	85 db                	test   %ebx,%ebx
  801196:	74 2c                	je     8011c4 <ipc_recv+0x62>
            *perm_store = 0;
  801198:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80119e:	eb 24                	jmp    8011c4 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  8011a0:	85 f6                	test   %esi,%esi
  8011a2:	74 0a                	je     8011ae <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  8011a4:	a1 08 40 80 00       	mov    0x804008,%eax
  8011a9:	8b 40 74             	mov    0x74(%eax),%eax
  8011ac:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  8011ae:	85 db                	test   %ebx,%ebx
  8011b0:	74 0a                	je     8011bc <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  8011b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8011b7:	8b 40 78             	mov    0x78(%eax),%eax
  8011ba:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  8011bc:	a1 08 40 80 00       	mov    0x804008,%eax
  8011c1:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  8011c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011c7:	5b                   	pop    %ebx
  8011c8:	5e                   	pop    %esi
  8011c9:	5d                   	pop    %ebp
  8011ca:	c3                   	ret    

008011cb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	57                   	push   %edi
  8011cf:	56                   	push   %esi
  8011d0:	53                   	push   %ebx
  8011d1:	83 ec 0c             	sub    $0xc,%esp
  8011d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011d7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011da:	8b 45 10             	mov    0x10(%ebp),%eax
  8011dd:	85 c0                	test   %eax,%eax
  8011df:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8011e4:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  8011e7:	eb 1c                	jmp    801205 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  8011e9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011ec:	74 12                	je     801200 <ipc_send+0x35>
  8011ee:	50                   	push   %eax
  8011ef:	68 d0 2b 80 00       	push   $0x802bd0
  8011f4:	6a 3b                	push   $0x3b
  8011f6:	68 e6 2b 80 00       	push   $0x802be6
  8011fb:	e8 a9 11 00 00       	call   8023a9 <_panic>
		sys_yield();
  801200:	e8 6f fa ff ff       	call   800c74 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801205:	ff 75 14             	pushl  0x14(%ebp)
  801208:	53                   	push   %ebx
  801209:	56                   	push   %esi
  80120a:	57                   	push   %edi
  80120b:	e8 10 fc ff ff       	call   800e20 <sys_ipc_try_send>
  801210:	83 c4 10             	add    $0x10,%esp
  801213:	85 c0                	test   %eax,%eax
  801215:	78 d2                	js     8011e9 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801217:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121a:	5b                   	pop    %ebx
  80121b:	5e                   	pop    %esi
  80121c:	5f                   	pop    %edi
  80121d:	5d                   	pop    %ebp
  80121e:	c3                   	ret    

0080121f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801225:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80122a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80122d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801233:	8b 52 50             	mov    0x50(%edx),%edx
  801236:	39 ca                	cmp    %ecx,%edx
  801238:	75 0d                	jne    801247 <ipc_find_env+0x28>
			return envs[i].env_id;
  80123a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80123d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801242:	8b 40 48             	mov    0x48(%eax),%eax
  801245:	eb 0f                	jmp    801256 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801247:	83 c0 01             	add    $0x1,%eax
  80124a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80124f:	75 d9                	jne    80122a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801251:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    

00801258 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80125b:	8b 45 08             	mov    0x8(%ebp),%eax
  80125e:	05 00 00 00 30       	add    $0x30000000,%eax
  801263:	c1 e8 0c             	shr    $0xc,%eax
}
  801266:	5d                   	pop    %ebp
  801267:	c3                   	ret    

00801268 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80126b:	8b 45 08             	mov    0x8(%ebp),%eax
  80126e:	05 00 00 00 30       	add    $0x30000000,%eax
  801273:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801278:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80127d:	5d                   	pop    %ebp
  80127e:	c3                   	ret    

0080127f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
  801282:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801285:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80128a:	89 c2                	mov    %eax,%edx
  80128c:	c1 ea 16             	shr    $0x16,%edx
  80128f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801296:	f6 c2 01             	test   $0x1,%dl
  801299:	74 11                	je     8012ac <fd_alloc+0x2d>
  80129b:	89 c2                	mov    %eax,%edx
  80129d:	c1 ea 0c             	shr    $0xc,%edx
  8012a0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012a7:	f6 c2 01             	test   $0x1,%dl
  8012aa:	75 09                	jne    8012b5 <fd_alloc+0x36>
			*fd_store = fd;
  8012ac:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b3:	eb 17                	jmp    8012cc <fd_alloc+0x4d>
  8012b5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012ba:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012bf:	75 c9                	jne    80128a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012c1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012c7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012cc:	5d                   	pop    %ebp
  8012cd:	c3                   	ret    

008012ce <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012d4:	83 f8 1f             	cmp    $0x1f,%eax
  8012d7:	77 36                	ja     80130f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012d9:	c1 e0 0c             	shl    $0xc,%eax
  8012dc:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012e1:	89 c2                	mov    %eax,%edx
  8012e3:	c1 ea 16             	shr    $0x16,%edx
  8012e6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ed:	f6 c2 01             	test   $0x1,%dl
  8012f0:	74 24                	je     801316 <fd_lookup+0x48>
  8012f2:	89 c2                	mov    %eax,%edx
  8012f4:	c1 ea 0c             	shr    $0xc,%edx
  8012f7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012fe:	f6 c2 01             	test   $0x1,%dl
  801301:	74 1a                	je     80131d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801303:	8b 55 0c             	mov    0xc(%ebp),%edx
  801306:	89 02                	mov    %eax,(%edx)
	return 0;
  801308:	b8 00 00 00 00       	mov    $0x0,%eax
  80130d:	eb 13                	jmp    801322 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80130f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801314:	eb 0c                	jmp    801322 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801316:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131b:	eb 05                	jmp    801322 <fd_lookup+0x54>
  80131d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801322:	5d                   	pop    %ebp
  801323:	c3                   	ret    

00801324 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	83 ec 08             	sub    $0x8,%esp
  80132a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80132d:	ba 6c 2c 80 00       	mov    $0x802c6c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801332:	eb 13                	jmp    801347 <dev_lookup+0x23>
  801334:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801337:	39 08                	cmp    %ecx,(%eax)
  801339:	75 0c                	jne    801347 <dev_lookup+0x23>
			*dev = devtab[i];
  80133b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80133e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801340:	b8 00 00 00 00       	mov    $0x0,%eax
  801345:	eb 2e                	jmp    801375 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801347:	8b 02                	mov    (%edx),%eax
  801349:	85 c0                	test   %eax,%eax
  80134b:	75 e7                	jne    801334 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80134d:	a1 08 40 80 00       	mov    0x804008,%eax
  801352:	8b 40 48             	mov    0x48(%eax),%eax
  801355:	83 ec 04             	sub    $0x4,%esp
  801358:	51                   	push   %ecx
  801359:	50                   	push   %eax
  80135a:	68 f0 2b 80 00       	push   $0x802bf0
  80135f:	e8 28 ef ff ff       	call   80028c <cprintf>
	*dev = 0;
  801364:	8b 45 0c             	mov    0xc(%ebp),%eax
  801367:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80136d:	83 c4 10             	add    $0x10,%esp
  801370:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801375:	c9                   	leave  
  801376:	c3                   	ret    

00801377 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	56                   	push   %esi
  80137b:	53                   	push   %ebx
  80137c:	83 ec 10             	sub    $0x10,%esp
  80137f:	8b 75 08             	mov    0x8(%ebp),%esi
  801382:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801385:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801388:	50                   	push   %eax
  801389:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80138f:	c1 e8 0c             	shr    $0xc,%eax
  801392:	50                   	push   %eax
  801393:	e8 36 ff ff ff       	call   8012ce <fd_lookup>
  801398:	83 c4 08             	add    $0x8,%esp
  80139b:	85 c0                	test   %eax,%eax
  80139d:	78 05                	js     8013a4 <fd_close+0x2d>
	    || fd != fd2)
  80139f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013a2:	74 0c                	je     8013b0 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013a4:	84 db                	test   %bl,%bl
  8013a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ab:	0f 44 c2             	cmove  %edx,%eax
  8013ae:	eb 41                	jmp    8013f1 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013b0:	83 ec 08             	sub    $0x8,%esp
  8013b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b6:	50                   	push   %eax
  8013b7:	ff 36                	pushl  (%esi)
  8013b9:	e8 66 ff ff ff       	call   801324 <dev_lookup>
  8013be:	89 c3                	mov    %eax,%ebx
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	78 1a                	js     8013e1 <fd_close+0x6a>
		if (dev->dev_close)
  8013c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ca:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013cd:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	74 0b                	je     8013e1 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013d6:	83 ec 0c             	sub    $0xc,%esp
  8013d9:	56                   	push   %esi
  8013da:	ff d0                	call   *%eax
  8013dc:	89 c3                	mov    %eax,%ebx
  8013de:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013e1:	83 ec 08             	sub    $0x8,%esp
  8013e4:	56                   	push   %esi
  8013e5:	6a 00                	push   $0x0
  8013e7:	e8 2c f9 ff ff       	call   800d18 <sys_page_unmap>
	return r;
  8013ec:	83 c4 10             	add    $0x10,%esp
  8013ef:	89 d8                	mov    %ebx,%eax
}
  8013f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f4:	5b                   	pop    %ebx
  8013f5:	5e                   	pop    %esi
  8013f6:	5d                   	pop    %ebp
  8013f7:	c3                   	ret    

008013f8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801401:	50                   	push   %eax
  801402:	ff 75 08             	pushl  0x8(%ebp)
  801405:	e8 c4 fe ff ff       	call   8012ce <fd_lookup>
  80140a:	83 c4 08             	add    $0x8,%esp
  80140d:	85 c0                	test   %eax,%eax
  80140f:	78 10                	js     801421 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801411:	83 ec 08             	sub    $0x8,%esp
  801414:	6a 01                	push   $0x1
  801416:	ff 75 f4             	pushl  -0xc(%ebp)
  801419:	e8 59 ff ff ff       	call   801377 <fd_close>
  80141e:	83 c4 10             	add    $0x10,%esp
}
  801421:	c9                   	leave  
  801422:	c3                   	ret    

00801423 <close_all>:

void
close_all(void)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	53                   	push   %ebx
  801427:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80142a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80142f:	83 ec 0c             	sub    $0xc,%esp
  801432:	53                   	push   %ebx
  801433:	e8 c0 ff ff ff       	call   8013f8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801438:	83 c3 01             	add    $0x1,%ebx
  80143b:	83 c4 10             	add    $0x10,%esp
  80143e:	83 fb 20             	cmp    $0x20,%ebx
  801441:	75 ec                	jne    80142f <close_all+0xc>
		close(i);
}
  801443:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801446:	c9                   	leave  
  801447:	c3                   	ret    

00801448 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	57                   	push   %edi
  80144c:	56                   	push   %esi
  80144d:	53                   	push   %ebx
  80144e:	83 ec 2c             	sub    $0x2c,%esp
  801451:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801454:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801457:	50                   	push   %eax
  801458:	ff 75 08             	pushl  0x8(%ebp)
  80145b:	e8 6e fe ff ff       	call   8012ce <fd_lookup>
  801460:	83 c4 08             	add    $0x8,%esp
  801463:	85 c0                	test   %eax,%eax
  801465:	0f 88 c1 00 00 00    	js     80152c <dup+0xe4>
		return r;
	close(newfdnum);
  80146b:	83 ec 0c             	sub    $0xc,%esp
  80146e:	56                   	push   %esi
  80146f:	e8 84 ff ff ff       	call   8013f8 <close>

	newfd = INDEX2FD(newfdnum);
  801474:	89 f3                	mov    %esi,%ebx
  801476:	c1 e3 0c             	shl    $0xc,%ebx
  801479:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80147f:	83 c4 04             	add    $0x4,%esp
  801482:	ff 75 e4             	pushl  -0x1c(%ebp)
  801485:	e8 de fd ff ff       	call   801268 <fd2data>
  80148a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80148c:	89 1c 24             	mov    %ebx,(%esp)
  80148f:	e8 d4 fd ff ff       	call   801268 <fd2data>
  801494:	83 c4 10             	add    $0x10,%esp
  801497:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80149a:	89 f8                	mov    %edi,%eax
  80149c:	c1 e8 16             	shr    $0x16,%eax
  80149f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014a6:	a8 01                	test   $0x1,%al
  8014a8:	74 37                	je     8014e1 <dup+0x99>
  8014aa:	89 f8                	mov    %edi,%eax
  8014ac:	c1 e8 0c             	shr    $0xc,%eax
  8014af:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014b6:	f6 c2 01             	test   $0x1,%dl
  8014b9:	74 26                	je     8014e1 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014bb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014c2:	83 ec 0c             	sub    $0xc,%esp
  8014c5:	25 07 0e 00 00       	and    $0xe07,%eax
  8014ca:	50                   	push   %eax
  8014cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014ce:	6a 00                	push   $0x0
  8014d0:	57                   	push   %edi
  8014d1:	6a 00                	push   $0x0
  8014d3:	e8 fe f7 ff ff       	call   800cd6 <sys_page_map>
  8014d8:	89 c7                	mov    %eax,%edi
  8014da:	83 c4 20             	add    $0x20,%esp
  8014dd:	85 c0                	test   %eax,%eax
  8014df:	78 2e                	js     80150f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014e4:	89 d0                	mov    %edx,%eax
  8014e6:	c1 e8 0c             	shr    $0xc,%eax
  8014e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014f0:	83 ec 0c             	sub    $0xc,%esp
  8014f3:	25 07 0e 00 00       	and    $0xe07,%eax
  8014f8:	50                   	push   %eax
  8014f9:	53                   	push   %ebx
  8014fa:	6a 00                	push   $0x0
  8014fc:	52                   	push   %edx
  8014fd:	6a 00                	push   $0x0
  8014ff:	e8 d2 f7 ff ff       	call   800cd6 <sys_page_map>
  801504:	89 c7                	mov    %eax,%edi
  801506:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801509:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80150b:	85 ff                	test   %edi,%edi
  80150d:	79 1d                	jns    80152c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80150f:	83 ec 08             	sub    $0x8,%esp
  801512:	53                   	push   %ebx
  801513:	6a 00                	push   $0x0
  801515:	e8 fe f7 ff ff       	call   800d18 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80151a:	83 c4 08             	add    $0x8,%esp
  80151d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801520:	6a 00                	push   $0x0
  801522:	e8 f1 f7 ff ff       	call   800d18 <sys_page_unmap>
	return r;
  801527:	83 c4 10             	add    $0x10,%esp
  80152a:	89 f8                	mov    %edi,%eax
}
  80152c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152f:	5b                   	pop    %ebx
  801530:	5e                   	pop    %esi
  801531:	5f                   	pop    %edi
  801532:	5d                   	pop    %ebp
  801533:	c3                   	ret    

00801534 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	53                   	push   %ebx
  801538:	83 ec 14             	sub    $0x14,%esp
  80153b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801541:	50                   	push   %eax
  801542:	53                   	push   %ebx
  801543:	e8 86 fd ff ff       	call   8012ce <fd_lookup>
  801548:	83 c4 08             	add    $0x8,%esp
  80154b:	89 c2                	mov    %eax,%edx
  80154d:	85 c0                	test   %eax,%eax
  80154f:	78 6d                	js     8015be <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801551:	83 ec 08             	sub    $0x8,%esp
  801554:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801557:	50                   	push   %eax
  801558:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155b:	ff 30                	pushl  (%eax)
  80155d:	e8 c2 fd ff ff       	call   801324 <dev_lookup>
  801562:	83 c4 10             	add    $0x10,%esp
  801565:	85 c0                	test   %eax,%eax
  801567:	78 4c                	js     8015b5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801569:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80156c:	8b 42 08             	mov    0x8(%edx),%eax
  80156f:	83 e0 03             	and    $0x3,%eax
  801572:	83 f8 01             	cmp    $0x1,%eax
  801575:	75 21                	jne    801598 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801577:	a1 08 40 80 00       	mov    0x804008,%eax
  80157c:	8b 40 48             	mov    0x48(%eax),%eax
  80157f:	83 ec 04             	sub    $0x4,%esp
  801582:	53                   	push   %ebx
  801583:	50                   	push   %eax
  801584:	68 31 2c 80 00       	push   $0x802c31
  801589:	e8 fe ec ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  80158e:	83 c4 10             	add    $0x10,%esp
  801591:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801596:	eb 26                	jmp    8015be <read+0x8a>
	}
	if (!dev->dev_read)
  801598:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159b:	8b 40 08             	mov    0x8(%eax),%eax
  80159e:	85 c0                	test   %eax,%eax
  8015a0:	74 17                	je     8015b9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015a2:	83 ec 04             	sub    $0x4,%esp
  8015a5:	ff 75 10             	pushl  0x10(%ebp)
  8015a8:	ff 75 0c             	pushl  0xc(%ebp)
  8015ab:	52                   	push   %edx
  8015ac:	ff d0                	call   *%eax
  8015ae:	89 c2                	mov    %eax,%edx
  8015b0:	83 c4 10             	add    $0x10,%esp
  8015b3:	eb 09                	jmp    8015be <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b5:	89 c2                	mov    %eax,%edx
  8015b7:	eb 05                	jmp    8015be <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015b9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015be:	89 d0                	mov    %edx,%eax
  8015c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c3:	c9                   	leave  
  8015c4:	c3                   	ret    

008015c5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015c5:	55                   	push   %ebp
  8015c6:	89 e5                	mov    %esp,%ebp
  8015c8:	57                   	push   %edi
  8015c9:	56                   	push   %esi
  8015ca:	53                   	push   %ebx
  8015cb:	83 ec 0c             	sub    $0xc,%esp
  8015ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015d1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015d9:	eb 21                	jmp    8015fc <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015db:	83 ec 04             	sub    $0x4,%esp
  8015de:	89 f0                	mov    %esi,%eax
  8015e0:	29 d8                	sub    %ebx,%eax
  8015e2:	50                   	push   %eax
  8015e3:	89 d8                	mov    %ebx,%eax
  8015e5:	03 45 0c             	add    0xc(%ebp),%eax
  8015e8:	50                   	push   %eax
  8015e9:	57                   	push   %edi
  8015ea:	e8 45 ff ff ff       	call   801534 <read>
		if (m < 0)
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	78 10                	js     801606 <readn+0x41>
			return m;
		if (m == 0)
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	74 0a                	je     801604 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015fa:	01 c3                	add    %eax,%ebx
  8015fc:	39 f3                	cmp    %esi,%ebx
  8015fe:	72 db                	jb     8015db <readn+0x16>
  801600:	89 d8                	mov    %ebx,%eax
  801602:	eb 02                	jmp    801606 <readn+0x41>
  801604:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801606:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801609:	5b                   	pop    %ebx
  80160a:	5e                   	pop    %esi
  80160b:	5f                   	pop    %edi
  80160c:	5d                   	pop    %ebp
  80160d:	c3                   	ret    

0080160e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	53                   	push   %ebx
  801612:	83 ec 14             	sub    $0x14,%esp
  801615:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801618:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80161b:	50                   	push   %eax
  80161c:	53                   	push   %ebx
  80161d:	e8 ac fc ff ff       	call   8012ce <fd_lookup>
  801622:	83 c4 08             	add    $0x8,%esp
  801625:	89 c2                	mov    %eax,%edx
  801627:	85 c0                	test   %eax,%eax
  801629:	78 68                	js     801693 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162b:	83 ec 08             	sub    $0x8,%esp
  80162e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801631:	50                   	push   %eax
  801632:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801635:	ff 30                	pushl  (%eax)
  801637:	e8 e8 fc ff ff       	call   801324 <dev_lookup>
  80163c:	83 c4 10             	add    $0x10,%esp
  80163f:	85 c0                	test   %eax,%eax
  801641:	78 47                	js     80168a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801643:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801646:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80164a:	75 21                	jne    80166d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80164c:	a1 08 40 80 00       	mov    0x804008,%eax
  801651:	8b 40 48             	mov    0x48(%eax),%eax
  801654:	83 ec 04             	sub    $0x4,%esp
  801657:	53                   	push   %ebx
  801658:	50                   	push   %eax
  801659:	68 4d 2c 80 00       	push   $0x802c4d
  80165e:	e8 29 ec ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80166b:	eb 26                	jmp    801693 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80166d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801670:	8b 52 0c             	mov    0xc(%edx),%edx
  801673:	85 d2                	test   %edx,%edx
  801675:	74 17                	je     80168e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801677:	83 ec 04             	sub    $0x4,%esp
  80167a:	ff 75 10             	pushl  0x10(%ebp)
  80167d:	ff 75 0c             	pushl  0xc(%ebp)
  801680:	50                   	push   %eax
  801681:	ff d2                	call   *%edx
  801683:	89 c2                	mov    %eax,%edx
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	eb 09                	jmp    801693 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168a:	89 c2                	mov    %eax,%edx
  80168c:	eb 05                	jmp    801693 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80168e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801693:	89 d0                	mov    %edx,%eax
  801695:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801698:	c9                   	leave  
  801699:	c3                   	ret    

0080169a <seek>:

int
seek(int fdnum, off_t offset)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016a0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016a3:	50                   	push   %eax
  8016a4:	ff 75 08             	pushl  0x8(%ebp)
  8016a7:	e8 22 fc ff ff       	call   8012ce <fd_lookup>
  8016ac:	83 c4 08             	add    $0x8,%esp
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	78 0e                	js     8016c1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016c1:	c9                   	leave  
  8016c2:	c3                   	ret    

008016c3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	53                   	push   %ebx
  8016c7:	83 ec 14             	sub    $0x14,%esp
  8016ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d0:	50                   	push   %eax
  8016d1:	53                   	push   %ebx
  8016d2:	e8 f7 fb ff ff       	call   8012ce <fd_lookup>
  8016d7:	83 c4 08             	add    $0x8,%esp
  8016da:	89 c2                	mov    %eax,%edx
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	78 65                	js     801745 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e0:	83 ec 08             	sub    $0x8,%esp
  8016e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e6:	50                   	push   %eax
  8016e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ea:	ff 30                	pushl  (%eax)
  8016ec:	e8 33 fc ff ff       	call   801324 <dev_lookup>
  8016f1:	83 c4 10             	add    $0x10,%esp
  8016f4:	85 c0                	test   %eax,%eax
  8016f6:	78 44                	js     80173c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016ff:	75 21                	jne    801722 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801701:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801706:	8b 40 48             	mov    0x48(%eax),%eax
  801709:	83 ec 04             	sub    $0x4,%esp
  80170c:	53                   	push   %ebx
  80170d:	50                   	push   %eax
  80170e:	68 10 2c 80 00       	push   $0x802c10
  801713:	e8 74 eb ff ff       	call   80028c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801718:	83 c4 10             	add    $0x10,%esp
  80171b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801720:	eb 23                	jmp    801745 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801722:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801725:	8b 52 18             	mov    0x18(%edx),%edx
  801728:	85 d2                	test   %edx,%edx
  80172a:	74 14                	je     801740 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80172c:	83 ec 08             	sub    $0x8,%esp
  80172f:	ff 75 0c             	pushl  0xc(%ebp)
  801732:	50                   	push   %eax
  801733:	ff d2                	call   *%edx
  801735:	89 c2                	mov    %eax,%edx
  801737:	83 c4 10             	add    $0x10,%esp
  80173a:	eb 09                	jmp    801745 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173c:	89 c2                	mov    %eax,%edx
  80173e:	eb 05                	jmp    801745 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801740:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801745:	89 d0                	mov    %edx,%eax
  801747:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174a:	c9                   	leave  
  80174b:	c3                   	ret    

0080174c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	53                   	push   %ebx
  801750:	83 ec 14             	sub    $0x14,%esp
  801753:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801756:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801759:	50                   	push   %eax
  80175a:	ff 75 08             	pushl  0x8(%ebp)
  80175d:	e8 6c fb ff ff       	call   8012ce <fd_lookup>
  801762:	83 c4 08             	add    $0x8,%esp
  801765:	89 c2                	mov    %eax,%edx
  801767:	85 c0                	test   %eax,%eax
  801769:	78 58                	js     8017c3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176b:	83 ec 08             	sub    $0x8,%esp
  80176e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801771:	50                   	push   %eax
  801772:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801775:	ff 30                	pushl  (%eax)
  801777:	e8 a8 fb ff ff       	call   801324 <dev_lookup>
  80177c:	83 c4 10             	add    $0x10,%esp
  80177f:	85 c0                	test   %eax,%eax
  801781:	78 37                	js     8017ba <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801783:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801786:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80178a:	74 32                	je     8017be <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80178c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80178f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801796:	00 00 00 
	stat->st_isdir = 0;
  801799:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017a0:	00 00 00 
	stat->st_dev = dev;
  8017a3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017a9:	83 ec 08             	sub    $0x8,%esp
  8017ac:	53                   	push   %ebx
  8017ad:	ff 75 f0             	pushl  -0x10(%ebp)
  8017b0:	ff 50 14             	call   *0x14(%eax)
  8017b3:	89 c2                	mov    %eax,%edx
  8017b5:	83 c4 10             	add    $0x10,%esp
  8017b8:	eb 09                	jmp    8017c3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ba:	89 c2                	mov    %eax,%edx
  8017bc:	eb 05                	jmp    8017c3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017c3:	89 d0                	mov    %edx,%eax
  8017c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c8:	c9                   	leave  
  8017c9:	c3                   	ret    

008017ca <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017ca:	55                   	push   %ebp
  8017cb:	89 e5                	mov    %esp,%ebp
  8017cd:	56                   	push   %esi
  8017ce:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017cf:	83 ec 08             	sub    $0x8,%esp
  8017d2:	6a 00                	push   $0x0
  8017d4:	ff 75 08             	pushl  0x8(%ebp)
  8017d7:	e8 e3 01 00 00       	call   8019bf <open>
  8017dc:	89 c3                	mov    %eax,%ebx
  8017de:	83 c4 10             	add    $0x10,%esp
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	78 1b                	js     801800 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017e5:	83 ec 08             	sub    $0x8,%esp
  8017e8:	ff 75 0c             	pushl  0xc(%ebp)
  8017eb:	50                   	push   %eax
  8017ec:	e8 5b ff ff ff       	call   80174c <fstat>
  8017f1:	89 c6                	mov    %eax,%esi
	close(fd);
  8017f3:	89 1c 24             	mov    %ebx,(%esp)
  8017f6:	e8 fd fb ff ff       	call   8013f8 <close>
	return r;
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	89 f0                	mov    %esi,%eax
}
  801800:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801803:	5b                   	pop    %ebx
  801804:	5e                   	pop    %esi
  801805:	5d                   	pop    %ebp
  801806:	c3                   	ret    

00801807 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	56                   	push   %esi
  80180b:	53                   	push   %ebx
  80180c:	89 c6                	mov    %eax,%esi
  80180e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801810:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801817:	75 12                	jne    80182b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801819:	83 ec 0c             	sub    $0xc,%esp
  80181c:	6a 01                	push   $0x1
  80181e:	e8 fc f9 ff ff       	call   80121f <ipc_find_env>
  801823:	a3 00 40 80 00       	mov    %eax,0x804000
  801828:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80182b:	6a 07                	push   $0x7
  80182d:	68 00 50 80 00       	push   $0x805000
  801832:	56                   	push   %esi
  801833:	ff 35 00 40 80 00    	pushl  0x804000
  801839:	e8 8d f9 ff ff       	call   8011cb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80183e:	83 c4 0c             	add    $0xc,%esp
  801841:	6a 00                	push   $0x0
  801843:	53                   	push   %ebx
  801844:	6a 00                	push   $0x0
  801846:	e8 17 f9 ff ff       	call   801162 <ipc_recv>
}
  80184b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184e:	5b                   	pop    %ebx
  80184f:	5e                   	pop    %esi
  801850:	5d                   	pop    %ebp
  801851:	c3                   	ret    

00801852 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801852:	55                   	push   %ebp
  801853:	89 e5                	mov    %esp,%ebp
  801855:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801858:	8b 45 08             	mov    0x8(%ebp),%eax
  80185b:	8b 40 0c             	mov    0xc(%eax),%eax
  80185e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801863:	8b 45 0c             	mov    0xc(%ebp),%eax
  801866:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80186b:	ba 00 00 00 00       	mov    $0x0,%edx
  801870:	b8 02 00 00 00       	mov    $0x2,%eax
  801875:	e8 8d ff ff ff       	call   801807 <fsipc>
}
  80187a:	c9                   	leave  
  80187b:	c3                   	ret    

0080187c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801882:	8b 45 08             	mov    0x8(%ebp),%eax
  801885:	8b 40 0c             	mov    0xc(%eax),%eax
  801888:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80188d:	ba 00 00 00 00       	mov    $0x0,%edx
  801892:	b8 06 00 00 00       	mov    $0x6,%eax
  801897:	e8 6b ff ff ff       	call   801807 <fsipc>
}
  80189c:	c9                   	leave  
  80189d:	c3                   	ret    

0080189e <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	53                   	push   %ebx
  8018a2:	83 ec 04             	sub    $0x4,%esp
  8018a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ae:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b8:	b8 05 00 00 00       	mov    $0x5,%eax
  8018bd:	e8 45 ff ff ff       	call   801807 <fsipc>
  8018c2:	85 c0                	test   %eax,%eax
  8018c4:	78 2c                	js     8018f2 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018c6:	83 ec 08             	sub    $0x8,%esp
  8018c9:	68 00 50 80 00       	push   $0x805000
  8018ce:	53                   	push   %ebx
  8018cf:	e8 bc ef ff ff       	call   800890 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018d4:	a1 80 50 80 00       	mov    0x805080,%eax
  8018d9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018df:	a1 84 50 80 00       	mov    0x805084,%eax
  8018e4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018ea:	83 c4 10             	add    $0x10,%esp
  8018ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f5:	c9                   	leave  
  8018f6:	c3                   	ret    

008018f7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	83 ec 0c             	sub    $0xc,%esp
  8018fd:	8b 45 10             	mov    0x10(%ebp),%eax
  801900:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801905:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80190a:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80190d:	8b 55 08             	mov    0x8(%ebp),%edx
  801910:	8b 52 0c             	mov    0xc(%edx),%edx
  801913:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801919:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80191e:	50                   	push   %eax
  80191f:	ff 75 0c             	pushl  0xc(%ebp)
  801922:	68 08 50 80 00       	push   $0x805008
  801927:	e8 f6 f0 ff ff       	call   800a22 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80192c:	ba 00 00 00 00       	mov    $0x0,%edx
  801931:	b8 04 00 00 00       	mov    $0x4,%eax
  801936:	e8 cc fe ff ff       	call   801807 <fsipc>
	//panic("devfile_write not implemented");
}
  80193b:	c9                   	leave  
  80193c:	c3                   	ret    

0080193d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
  801940:	56                   	push   %esi
  801941:	53                   	push   %ebx
  801942:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801945:	8b 45 08             	mov    0x8(%ebp),%eax
  801948:	8b 40 0c             	mov    0xc(%eax),%eax
  80194b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801950:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801956:	ba 00 00 00 00       	mov    $0x0,%edx
  80195b:	b8 03 00 00 00       	mov    $0x3,%eax
  801960:	e8 a2 fe ff ff       	call   801807 <fsipc>
  801965:	89 c3                	mov    %eax,%ebx
  801967:	85 c0                	test   %eax,%eax
  801969:	78 4b                	js     8019b6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80196b:	39 c6                	cmp    %eax,%esi
  80196d:	73 16                	jae    801985 <devfile_read+0x48>
  80196f:	68 80 2c 80 00       	push   $0x802c80
  801974:	68 87 2c 80 00       	push   $0x802c87
  801979:	6a 7c                	push   $0x7c
  80197b:	68 9c 2c 80 00       	push   $0x802c9c
  801980:	e8 24 0a 00 00       	call   8023a9 <_panic>
	assert(r <= PGSIZE);
  801985:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80198a:	7e 16                	jle    8019a2 <devfile_read+0x65>
  80198c:	68 a7 2c 80 00       	push   $0x802ca7
  801991:	68 87 2c 80 00       	push   $0x802c87
  801996:	6a 7d                	push   $0x7d
  801998:	68 9c 2c 80 00       	push   $0x802c9c
  80199d:	e8 07 0a 00 00       	call   8023a9 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019a2:	83 ec 04             	sub    $0x4,%esp
  8019a5:	50                   	push   %eax
  8019a6:	68 00 50 80 00       	push   $0x805000
  8019ab:	ff 75 0c             	pushl  0xc(%ebp)
  8019ae:	e8 6f f0 ff ff       	call   800a22 <memmove>
	return r;
  8019b3:	83 c4 10             	add    $0x10,%esp
}
  8019b6:	89 d8                	mov    %ebx,%eax
  8019b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019bb:	5b                   	pop    %ebx
  8019bc:	5e                   	pop    %esi
  8019bd:	5d                   	pop    %ebp
  8019be:	c3                   	ret    

008019bf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	53                   	push   %ebx
  8019c3:	83 ec 20             	sub    $0x20,%esp
  8019c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019c9:	53                   	push   %ebx
  8019ca:	e8 88 ee ff ff       	call   800857 <strlen>
  8019cf:	83 c4 10             	add    $0x10,%esp
  8019d2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019d7:	7f 67                	jg     801a40 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019d9:	83 ec 0c             	sub    $0xc,%esp
  8019dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019df:	50                   	push   %eax
  8019e0:	e8 9a f8 ff ff       	call   80127f <fd_alloc>
  8019e5:	83 c4 10             	add    $0x10,%esp
		return r;
  8019e8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	78 57                	js     801a45 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019ee:	83 ec 08             	sub    $0x8,%esp
  8019f1:	53                   	push   %ebx
  8019f2:	68 00 50 80 00       	push   $0x805000
  8019f7:	e8 94 ee ff ff       	call   800890 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ff:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a04:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a07:	b8 01 00 00 00       	mov    $0x1,%eax
  801a0c:	e8 f6 fd ff ff       	call   801807 <fsipc>
  801a11:	89 c3                	mov    %eax,%ebx
  801a13:	83 c4 10             	add    $0x10,%esp
  801a16:	85 c0                	test   %eax,%eax
  801a18:	79 14                	jns    801a2e <open+0x6f>
		fd_close(fd, 0);
  801a1a:	83 ec 08             	sub    $0x8,%esp
  801a1d:	6a 00                	push   $0x0
  801a1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a22:	e8 50 f9 ff ff       	call   801377 <fd_close>
		return r;
  801a27:	83 c4 10             	add    $0x10,%esp
  801a2a:	89 da                	mov    %ebx,%edx
  801a2c:	eb 17                	jmp    801a45 <open+0x86>
	}

	return fd2num(fd);
  801a2e:	83 ec 0c             	sub    $0xc,%esp
  801a31:	ff 75 f4             	pushl  -0xc(%ebp)
  801a34:	e8 1f f8 ff ff       	call   801258 <fd2num>
  801a39:	89 c2                	mov    %eax,%edx
  801a3b:	83 c4 10             	add    $0x10,%esp
  801a3e:	eb 05                	jmp    801a45 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a40:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a45:	89 d0                	mov    %edx,%eax
  801a47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a4a:	c9                   	leave  
  801a4b:	c3                   	ret    

00801a4c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a52:	ba 00 00 00 00       	mov    $0x0,%edx
  801a57:	b8 08 00 00 00       	mov    $0x8,%eax
  801a5c:	e8 a6 fd ff ff       	call   801807 <fsipc>
}
  801a61:	c9                   	leave  
  801a62:	c3                   	ret    

00801a63 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
  801a66:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a69:	68 b3 2c 80 00       	push   $0x802cb3
  801a6e:	ff 75 0c             	pushl  0xc(%ebp)
  801a71:	e8 1a ee ff ff       	call   800890 <strcpy>
	return 0;
}
  801a76:	b8 00 00 00 00       	mov    $0x0,%eax
  801a7b:	c9                   	leave  
  801a7c:	c3                   	ret    

00801a7d <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a7d:	55                   	push   %ebp
  801a7e:	89 e5                	mov    %esp,%ebp
  801a80:	53                   	push   %ebx
  801a81:	83 ec 10             	sub    $0x10,%esp
  801a84:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a87:	53                   	push   %ebx
  801a88:	e8 e9 09 00 00       	call   802476 <pageref>
  801a8d:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a90:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a95:	83 f8 01             	cmp    $0x1,%eax
  801a98:	75 10                	jne    801aaa <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a9a:	83 ec 0c             	sub    $0xc,%esp
  801a9d:	ff 73 0c             	pushl  0xc(%ebx)
  801aa0:	e8 c0 02 00 00       	call   801d65 <nsipc_close>
  801aa5:	89 c2                	mov    %eax,%edx
  801aa7:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801aaa:	89 d0                	mov    %edx,%eax
  801aac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aaf:	c9                   	leave  
  801ab0:	c3                   	ret    

00801ab1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ab7:	6a 00                	push   $0x0
  801ab9:	ff 75 10             	pushl  0x10(%ebp)
  801abc:	ff 75 0c             	pushl  0xc(%ebp)
  801abf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac2:	ff 70 0c             	pushl  0xc(%eax)
  801ac5:	e8 78 03 00 00       	call   801e42 <nsipc_send>
}
  801aca:	c9                   	leave  
  801acb:	c3                   	ret    

00801acc <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ad2:	6a 00                	push   $0x0
  801ad4:	ff 75 10             	pushl  0x10(%ebp)
  801ad7:	ff 75 0c             	pushl  0xc(%ebp)
  801ada:	8b 45 08             	mov    0x8(%ebp),%eax
  801add:	ff 70 0c             	pushl  0xc(%eax)
  801ae0:	e8 f1 02 00 00       	call   801dd6 <nsipc_recv>
}
  801ae5:	c9                   	leave  
  801ae6:	c3                   	ret    

00801ae7 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801aed:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801af0:	52                   	push   %edx
  801af1:	50                   	push   %eax
  801af2:	e8 d7 f7 ff ff       	call   8012ce <fd_lookup>
  801af7:	83 c4 10             	add    $0x10,%esp
  801afa:	85 c0                	test   %eax,%eax
  801afc:	78 17                	js     801b15 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b01:	8b 0d 28 30 80 00    	mov    0x803028,%ecx
  801b07:	39 08                	cmp    %ecx,(%eax)
  801b09:	75 05                	jne    801b10 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b0b:	8b 40 0c             	mov    0xc(%eax),%eax
  801b0e:	eb 05                	jmp    801b15 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b10:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b15:	c9                   	leave  
  801b16:	c3                   	ret    

00801b17 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b17:	55                   	push   %ebp
  801b18:	89 e5                	mov    %esp,%ebp
  801b1a:	56                   	push   %esi
  801b1b:	53                   	push   %ebx
  801b1c:	83 ec 1c             	sub    $0x1c,%esp
  801b1f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b24:	50                   	push   %eax
  801b25:	e8 55 f7 ff ff       	call   80127f <fd_alloc>
  801b2a:	89 c3                	mov    %eax,%ebx
  801b2c:	83 c4 10             	add    $0x10,%esp
  801b2f:	85 c0                	test   %eax,%eax
  801b31:	78 1b                	js     801b4e <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b33:	83 ec 04             	sub    $0x4,%esp
  801b36:	68 07 04 00 00       	push   $0x407
  801b3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3e:	6a 00                	push   $0x0
  801b40:	e8 4e f1 ff ff       	call   800c93 <sys_page_alloc>
  801b45:	89 c3                	mov    %eax,%ebx
  801b47:	83 c4 10             	add    $0x10,%esp
  801b4a:	85 c0                	test   %eax,%eax
  801b4c:	79 10                	jns    801b5e <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b4e:	83 ec 0c             	sub    $0xc,%esp
  801b51:	56                   	push   %esi
  801b52:	e8 0e 02 00 00       	call   801d65 <nsipc_close>
		return r;
  801b57:	83 c4 10             	add    $0x10,%esp
  801b5a:	89 d8                	mov    %ebx,%eax
  801b5c:	eb 24                	jmp    801b82 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b5e:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b67:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b73:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b76:	83 ec 0c             	sub    $0xc,%esp
  801b79:	50                   	push   %eax
  801b7a:	e8 d9 f6 ff ff       	call   801258 <fd2num>
  801b7f:	83 c4 10             	add    $0x10,%esp
}
  801b82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b85:	5b                   	pop    %ebx
  801b86:	5e                   	pop    %esi
  801b87:	5d                   	pop    %ebp
  801b88:	c3                   	ret    

00801b89 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b92:	e8 50 ff ff ff       	call   801ae7 <fd2sockid>
		return r;
  801b97:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	78 1f                	js     801bbc <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b9d:	83 ec 04             	sub    $0x4,%esp
  801ba0:	ff 75 10             	pushl  0x10(%ebp)
  801ba3:	ff 75 0c             	pushl  0xc(%ebp)
  801ba6:	50                   	push   %eax
  801ba7:	e8 12 01 00 00       	call   801cbe <nsipc_accept>
  801bac:	83 c4 10             	add    $0x10,%esp
		return r;
  801baf:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	78 07                	js     801bbc <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801bb5:	e8 5d ff ff ff       	call   801b17 <alloc_sockfd>
  801bba:	89 c1                	mov    %eax,%ecx
}
  801bbc:	89 c8                	mov    %ecx,%eax
  801bbe:	c9                   	leave  
  801bbf:	c3                   	ret    

00801bc0 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc9:	e8 19 ff ff ff       	call   801ae7 <fd2sockid>
  801bce:	85 c0                	test   %eax,%eax
  801bd0:	78 12                	js     801be4 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801bd2:	83 ec 04             	sub    $0x4,%esp
  801bd5:	ff 75 10             	pushl  0x10(%ebp)
  801bd8:	ff 75 0c             	pushl  0xc(%ebp)
  801bdb:	50                   	push   %eax
  801bdc:	e8 2d 01 00 00       	call   801d0e <nsipc_bind>
  801be1:	83 c4 10             	add    $0x10,%esp
}
  801be4:	c9                   	leave  
  801be5:	c3                   	ret    

00801be6 <shutdown>:

int
shutdown(int s, int how)
{
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bec:	8b 45 08             	mov    0x8(%ebp),%eax
  801bef:	e8 f3 fe ff ff       	call   801ae7 <fd2sockid>
  801bf4:	85 c0                	test   %eax,%eax
  801bf6:	78 0f                	js     801c07 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801bf8:	83 ec 08             	sub    $0x8,%esp
  801bfb:	ff 75 0c             	pushl  0xc(%ebp)
  801bfe:	50                   	push   %eax
  801bff:	e8 3f 01 00 00       	call   801d43 <nsipc_shutdown>
  801c04:	83 c4 10             	add    $0x10,%esp
}
  801c07:	c9                   	leave  
  801c08:	c3                   	ret    

00801c09 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c12:	e8 d0 fe ff ff       	call   801ae7 <fd2sockid>
  801c17:	85 c0                	test   %eax,%eax
  801c19:	78 12                	js     801c2d <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801c1b:	83 ec 04             	sub    $0x4,%esp
  801c1e:	ff 75 10             	pushl  0x10(%ebp)
  801c21:	ff 75 0c             	pushl  0xc(%ebp)
  801c24:	50                   	push   %eax
  801c25:	e8 55 01 00 00       	call   801d7f <nsipc_connect>
  801c2a:	83 c4 10             	add    $0x10,%esp
}
  801c2d:	c9                   	leave  
  801c2e:	c3                   	ret    

00801c2f <listen>:

int
listen(int s, int backlog)
{
  801c2f:	55                   	push   %ebp
  801c30:	89 e5                	mov    %esp,%ebp
  801c32:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c35:	8b 45 08             	mov    0x8(%ebp),%eax
  801c38:	e8 aa fe ff ff       	call   801ae7 <fd2sockid>
  801c3d:	85 c0                	test   %eax,%eax
  801c3f:	78 0f                	js     801c50 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c41:	83 ec 08             	sub    $0x8,%esp
  801c44:	ff 75 0c             	pushl  0xc(%ebp)
  801c47:	50                   	push   %eax
  801c48:	e8 67 01 00 00       	call   801db4 <nsipc_listen>
  801c4d:	83 c4 10             	add    $0x10,%esp
}
  801c50:	c9                   	leave  
  801c51:	c3                   	ret    

00801c52 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c58:	ff 75 10             	pushl  0x10(%ebp)
  801c5b:	ff 75 0c             	pushl  0xc(%ebp)
  801c5e:	ff 75 08             	pushl  0x8(%ebp)
  801c61:	e8 3a 02 00 00       	call   801ea0 <nsipc_socket>
  801c66:	83 c4 10             	add    $0x10,%esp
  801c69:	85 c0                	test   %eax,%eax
  801c6b:	78 05                	js     801c72 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c6d:	e8 a5 fe ff ff       	call   801b17 <alloc_sockfd>
}
  801c72:	c9                   	leave  
  801c73:	c3                   	ret    

00801c74 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	53                   	push   %ebx
  801c78:	83 ec 04             	sub    $0x4,%esp
  801c7b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c7d:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c84:	75 12                	jne    801c98 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c86:	83 ec 0c             	sub    $0xc,%esp
  801c89:	6a 02                	push   $0x2
  801c8b:	e8 8f f5 ff ff       	call   80121f <ipc_find_env>
  801c90:	a3 04 40 80 00       	mov    %eax,0x804004
  801c95:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c98:	6a 07                	push   $0x7
  801c9a:	68 00 60 80 00       	push   $0x806000
  801c9f:	53                   	push   %ebx
  801ca0:	ff 35 04 40 80 00    	pushl  0x804004
  801ca6:	e8 20 f5 ff ff       	call   8011cb <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801cab:	83 c4 0c             	add    $0xc,%esp
  801cae:	6a 00                	push   $0x0
  801cb0:	6a 00                	push   $0x0
  801cb2:	6a 00                	push   $0x0
  801cb4:	e8 a9 f4 ff ff       	call   801162 <ipc_recv>
}
  801cb9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cbc:	c9                   	leave  
  801cbd:	c3                   	ret    

00801cbe <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cbe:	55                   	push   %ebp
  801cbf:	89 e5                	mov    %esp,%ebp
  801cc1:	56                   	push   %esi
  801cc2:	53                   	push   %ebx
  801cc3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801cc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801cce:	8b 06                	mov    (%esi),%eax
  801cd0:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801cd5:	b8 01 00 00 00       	mov    $0x1,%eax
  801cda:	e8 95 ff ff ff       	call   801c74 <nsipc>
  801cdf:	89 c3                	mov    %eax,%ebx
  801ce1:	85 c0                	test   %eax,%eax
  801ce3:	78 20                	js     801d05 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ce5:	83 ec 04             	sub    $0x4,%esp
  801ce8:	ff 35 10 60 80 00    	pushl  0x806010
  801cee:	68 00 60 80 00       	push   $0x806000
  801cf3:	ff 75 0c             	pushl  0xc(%ebp)
  801cf6:	e8 27 ed ff ff       	call   800a22 <memmove>
		*addrlen = ret->ret_addrlen;
  801cfb:	a1 10 60 80 00       	mov    0x806010,%eax
  801d00:	89 06                	mov    %eax,(%esi)
  801d02:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d05:	89 d8                	mov    %ebx,%eax
  801d07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d0a:	5b                   	pop    %ebx
  801d0b:	5e                   	pop    %esi
  801d0c:	5d                   	pop    %ebp
  801d0d:	c3                   	ret    

00801d0e <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	53                   	push   %ebx
  801d12:	83 ec 08             	sub    $0x8,%esp
  801d15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d18:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d20:	53                   	push   %ebx
  801d21:	ff 75 0c             	pushl  0xc(%ebp)
  801d24:	68 04 60 80 00       	push   $0x806004
  801d29:	e8 f4 ec ff ff       	call   800a22 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d2e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d34:	b8 02 00 00 00       	mov    $0x2,%eax
  801d39:	e8 36 ff ff ff       	call   801c74 <nsipc>
}
  801d3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d41:	c9                   	leave  
  801d42:	c3                   	ret    

00801d43 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d43:	55                   	push   %ebp
  801d44:	89 e5                	mov    %esp,%ebp
  801d46:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d49:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d51:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d54:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d59:	b8 03 00 00 00       	mov    $0x3,%eax
  801d5e:	e8 11 ff ff ff       	call   801c74 <nsipc>
}
  801d63:	c9                   	leave  
  801d64:	c3                   	ret    

00801d65 <nsipc_close>:

int
nsipc_close(int s)
{
  801d65:	55                   	push   %ebp
  801d66:	89 e5                	mov    %esp,%ebp
  801d68:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d73:	b8 04 00 00 00       	mov    $0x4,%eax
  801d78:	e8 f7 fe ff ff       	call   801c74 <nsipc>
}
  801d7d:	c9                   	leave  
  801d7e:	c3                   	ret    

00801d7f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d7f:	55                   	push   %ebp
  801d80:	89 e5                	mov    %esp,%ebp
  801d82:	53                   	push   %ebx
  801d83:	83 ec 08             	sub    $0x8,%esp
  801d86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d89:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d91:	53                   	push   %ebx
  801d92:	ff 75 0c             	pushl  0xc(%ebp)
  801d95:	68 04 60 80 00       	push   $0x806004
  801d9a:	e8 83 ec ff ff       	call   800a22 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d9f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801da5:	b8 05 00 00 00       	mov    $0x5,%eax
  801daa:	e8 c5 fe ff ff       	call   801c74 <nsipc>
}
  801daf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801db2:	c9                   	leave  
  801db3:	c3                   	ret    

00801db4 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801dba:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc5:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801dca:	b8 06 00 00 00       	mov    $0x6,%eax
  801dcf:	e8 a0 fe ff ff       	call   801c74 <nsipc>
}
  801dd4:	c9                   	leave  
  801dd5:	c3                   	ret    

00801dd6 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	56                   	push   %esi
  801dda:	53                   	push   %ebx
  801ddb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801dde:	8b 45 08             	mov    0x8(%ebp),%eax
  801de1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801de6:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801dec:	8b 45 14             	mov    0x14(%ebp),%eax
  801def:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801df4:	b8 07 00 00 00       	mov    $0x7,%eax
  801df9:	e8 76 fe ff ff       	call   801c74 <nsipc>
  801dfe:	89 c3                	mov    %eax,%ebx
  801e00:	85 c0                	test   %eax,%eax
  801e02:	78 35                	js     801e39 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e04:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e09:	7f 04                	jg     801e0f <nsipc_recv+0x39>
  801e0b:	39 c6                	cmp    %eax,%esi
  801e0d:	7d 16                	jge    801e25 <nsipc_recv+0x4f>
  801e0f:	68 bf 2c 80 00       	push   $0x802cbf
  801e14:	68 87 2c 80 00       	push   $0x802c87
  801e19:	6a 62                	push   $0x62
  801e1b:	68 d4 2c 80 00       	push   $0x802cd4
  801e20:	e8 84 05 00 00       	call   8023a9 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e25:	83 ec 04             	sub    $0x4,%esp
  801e28:	50                   	push   %eax
  801e29:	68 00 60 80 00       	push   $0x806000
  801e2e:	ff 75 0c             	pushl  0xc(%ebp)
  801e31:	e8 ec eb ff ff       	call   800a22 <memmove>
  801e36:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e39:	89 d8                	mov    %ebx,%eax
  801e3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e3e:	5b                   	pop    %ebx
  801e3f:	5e                   	pop    %esi
  801e40:	5d                   	pop    %ebp
  801e41:	c3                   	ret    

00801e42 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e42:	55                   	push   %ebp
  801e43:	89 e5                	mov    %esp,%ebp
  801e45:	53                   	push   %ebx
  801e46:	83 ec 04             	sub    $0x4,%esp
  801e49:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4f:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e54:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e5a:	7e 16                	jle    801e72 <nsipc_send+0x30>
  801e5c:	68 e0 2c 80 00       	push   $0x802ce0
  801e61:	68 87 2c 80 00       	push   $0x802c87
  801e66:	6a 6d                	push   $0x6d
  801e68:	68 d4 2c 80 00       	push   $0x802cd4
  801e6d:	e8 37 05 00 00       	call   8023a9 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e72:	83 ec 04             	sub    $0x4,%esp
  801e75:	53                   	push   %ebx
  801e76:	ff 75 0c             	pushl  0xc(%ebp)
  801e79:	68 0c 60 80 00       	push   $0x80600c
  801e7e:	e8 9f eb ff ff       	call   800a22 <memmove>
	nsipcbuf.send.req_size = size;
  801e83:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e89:	8b 45 14             	mov    0x14(%ebp),%eax
  801e8c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e91:	b8 08 00 00 00       	mov    $0x8,%eax
  801e96:	e8 d9 fd ff ff       	call   801c74 <nsipc>
}
  801e9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e9e:	c9                   	leave  
  801e9f:	c3                   	ret    

00801ea0 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
  801ea3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801eae:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb1:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801eb6:	8b 45 10             	mov    0x10(%ebp),%eax
  801eb9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ebe:	b8 09 00 00 00       	mov    $0x9,%eax
  801ec3:	e8 ac fd ff ff       	call   801c74 <nsipc>
}
  801ec8:	c9                   	leave  
  801ec9:	c3                   	ret    

00801eca <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801eca:	55                   	push   %ebp
  801ecb:	89 e5                	mov    %esp,%ebp
  801ecd:	56                   	push   %esi
  801ece:	53                   	push   %ebx
  801ecf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ed2:	83 ec 0c             	sub    $0xc,%esp
  801ed5:	ff 75 08             	pushl  0x8(%ebp)
  801ed8:	e8 8b f3 ff ff       	call   801268 <fd2data>
  801edd:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801edf:	83 c4 08             	add    $0x8,%esp
  801ee2:	68 ec 2c 80 00       	push   $0x802cec
  801ee7:	53                   	push   %ebx
  801ee8:	e8 a3 e9 ff ff       	call   800890 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801eed:	8b 46 04             	mov    0x4(%esi),%eax
  801ef0:	2b 06                	sub    (%esi),%eax
  801ef2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ef8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801eff:	00 00 00 
	stat->st_dev = &devpipe;
  801f02:	c7 83 88 00 00 00 44 	movl   $0x803044,0x88(%ebx)
  801f09:	30 80 00 
	return 0;
}
  801f0c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f14:	5b                   	pop    %ebx
  801f15:	5e                   	pop    %esi
  801f16:	5d                   	pop    %ebp
  801f17:	c3                   	ret    

00801f18 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f18:	55                   	push   %ebp
  801f19:	89 e5                	mov    %esp,%ebp
  801f1b:	53                   	push   %ebx
  801f1c:	83 ec 0c             	sub    $0xc,%esp
  801f1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f22:	53                   	push   %ebx
  801f23:	6a 00                	push   $0x0
  801f25:	e8 ee ed ff ff       	call   800d18 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f2a:	89 1c 24             	mov    %ebx,(%esp)
  801f2d:	e8 36 f3 ff ff       	call   801268 <fd2data>
  801f32:	83 c4 08             	add    $0x8,%esp
  801f35:	50                   	push   %eax
  801f36:	6a 00                	push   $0x0
  801f38:	e8 db ed ff ff       	call   800d18 <sys_page_unmap>
}
  801f3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f40:	c9                   	leave  
  801f41:	c3                   	ret    

00801f42 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f42:	55                   	push   %ebp
  801f43:	89 e5                	mov    %esp,%ebp
  801f45:	57                   	push   %edi
  801f46:	56                   	push   %esi
  801f47:	53                   	push   %ebx
  801f48:	83 ec 1c             	sub    $0x1c,%esp
  801f4b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f4e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f50:	a1 08 40 80 00       	mov    0x804008,%eax
  801f55:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f58:	83 ec 0c             	sub    $0xc,%esp
  801f5b:	ff 75 e0             	pushl  -0x20(%ebp)
  801f5e:	e8 13 05 00 00       	call   802476 <pageref>
  801f63:	89 c3                	mov    %eax,%ebx
  801f65:	89 3c 24             	mov    %edi,(%esp)
  801f68:	e8 09 05 00 00       	call   802476 <pageref>
  801f6d:	83 c4 10             	add    $0x10,%esp
  801f70:	39 c3                	cmp    %eax,%ebx
  801f72:	0f 94 c1             	sete   %cl
  801f75:	0f b6 c9             	movzbl %cl,%ecx
  801f78:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f7b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f81:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f84:	39 ce                	cmp    %ecx,%esi
  801f86:	74 1b                	je     801fa3 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f88:	39 c3                	cmp    %eax,%ebx
  801f8a:	75 c4                	jne    801f50 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f8c:	8b 42 58             	mov    0x58(%edx),%eax
  801f8f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f92:	50                   	push   %eax
  801f93:	56                   	push   %esi
  801f94:	68 f3 2c 80 00       	push   $0x802cf3
  801f99:	e8 ee e2 ff ff       	call   80028c <cprintf>
  801f9e:	83 c4 10             	add    $0x10,%esp
  801fa1:	eb ad                	jmp    801f50 <_pipeisclosed+0xe>
	}
}
  801fa3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fa6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa9:	5b                   	pop    %ebx
  801faa:	5e                   	pop    %esi
  801fab:	5f                   	pop    %edi
  801fac:	5d                   	pop    %ebp
  801fad:	c3                   	ret    

00801fae <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fae:	55                   	push   %ebp
  801faf:	89 e5                	mov    %esp,%ebp
  801fb1:	57                   	push   %edi
  801fb2:	56                   	push   %esi
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 28             	sub    $0x28,%esp
  801fb7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801fba:	56                   	push   %esi
  801fbb:	e8 a8 f2 ff ff       	call   801268 <fd2data>
  801fc0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fc2:	83 c4 10             	add    $0x10,%esp
  801fc5:	bf 00 00 00 00       	mov    $0x0,%edi
  801fca:	eb 4b                	jmp    802017 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801fcc:	89 da                	mov    %ebx,%edx
  801fce:	89 f0                	mov    %esi,%eax
  801fd0:	e8 6d ff ff ff       	call   801f42 <_pipeisclosed>
  801fd5:	85 c0                	test   %eax,%eax
  801fd7:	75 48                	jne    802021 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fd9:	e8 96 ec ff ff       	call   800c74 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fde:	8b 43 04             	mov    0x4(%ebx),%eax
  801fe1:	8b 0b                	mov    (%ebx),%ecx
  801fe3:	8d 51 20             	lea    0x20(%ecx),%edx
  801fe6:	39 d0                	cmp    %edx,%eax
  801fe8:	73 e2                	jae    801fcc <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fed:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ff1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ff4:	89 c2                	mov    %eax,%edx
  801ff6:	c1 fa 1f             	sar    $0x1f,%edx
  801ff9:	89 d1                	mov    %edx,%ecx
  801ffb:	c1 e9 1b             	shr    $0x1b,%ecx
  801ffe:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802001:	83 e2 1f             	and    $0x1f,%edx
  802004:	29 ca                	sub    %ecx,%edx
  802006:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80200a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80200e:	83 c0 01             	add    $0x1,%eax
  802011:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802014:	83 c7 01             	add    $0x1,%edi
  802017:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80201a:	75 c2                	jne    801fde <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80201c:	8b 45 10             	mov    0x10(%ebp),%eax
  80201f:	eb 05                	jmp    802026 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802021:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802026:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802029:	5b                   	pop    %ebx
  80202a:	5e                   	pop    %esi
  80202b:	5f                   	pop    %edi
  80202c:	5d                   	pop    %ebp
  80202d:	c3                   	ret    

0080202e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80202e:	55                   	push   %ebp
  80202f:	89 e5                	mov    %esp,%ebp
  802031:	57                   	push   %edi
  802032:	56                   	push   %esi
  802033:	53                   	push   %ebx
  802034:	83 ec 18             	sub    $0x18,%esp
  802037:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80203a:	57                   	push   %edi
  80203b:	e8 28 f2 ff ff       	call   801268 <fd2data>
  802040:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802042:	83 c4 10             	add    $0x10,%esp
  802045:	bb 00 00 00 00       	mov    $0x0,%ebx
  80204a:	eb 3d                	jmp    802089 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80204c:	85 db                	test   %ebx,%ebx
  80204e:	74 04                	je     802054 <devpipe_read+0x26>
				return i;
  802050:	89 d8                	mov    %ebx,%eax
  802052:	eb 44                	jmp    802098 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802054:	89 f2                	mov    %esi,%edx
  802056:	89 f8                	mov    %edi,%eax
  802058:	e8 e5 fe ff ff       	call   801f42 <_pipeisclosed>
  80205d:	85 c0                	test   %eax,%eax
  80205f:	75 32                	jne    802093 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802061:	e8 0e ec ff ff       	call   800c74 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802066:	8b 06                	mov    (%esi),%eax
  802068:	3b 46 04             	cmp    0x4(%esi),%eax
  80206b:	74 df                	je     80204c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80206d:	99                   	cltd   
  80206e:	c1 ea 1b             	shr    $0x1b,%edx
  802071:	01 d0                	add    %edx,%eax
  802073:	83 e0 1f             	and    $0x1f,%eax
  802076:	29 d0                	sub    %edx,%eax
  802078:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80207d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802080:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802083:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802086:	83 c3 01             	add    $0x1,%ebx
  802089:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80208c:	75 d8                	jne    802066 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80208e:	8b 45 10             	mov    0x10(%ebp),%eax
  802091:	eb 05                	jmp    802098 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802093:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802098:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80209b:	5b                   	pop    %ebx
  80209c:	5e                   	pop    %esi
  80209d:	5f                   	pop    %edi
  80209e:	5d                   	pop    %ebp
  80209f:	c3                   	ret    

008020a0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020a0:	55                   	push   %ebp
  8020a1:	89 e5                	mov    %esp,%ebp
  8020a3:	56                   	push   %esi
  8020a4:	53                   	push   %ebx
  8020a5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ab:	50                   	push   %eax
  8020ac:	e8 ce f1 ff ff       	call   80127f <fd_alloc>
  8020b1:	83 c4 10             	add    $0x10,%esp
  8020b4:	89 c2                	mov    %eax,%edx
  8020b6:	85 c0                	test   %eax,%eax
  8020b8:	0f 88 2c 01 00 00    	js     8021ea <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020be:	83 ec 04             	sub    $0x4,%esp
  8020c1:	68 07 04 00 00       	push   $0x407
  8020c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8020c9:	6a 00                	push   $0x0
  8020cb:	e8 c3 eb ff ff       	call   800c93 <sys_page_alloc>
  8020d0:	83 c4 10             	add    $0x10,%esp
  8020d3:	89 c2                	mov    %eax,%edx
  8020d5:	85 c0                	test   %eax,%eax
  8020d7:	0f 88 0d 01 00 00    	js     8021ea <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020dd:	83 ec 0c             	sub    $0xc,%esp
  8020e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020e3:	50                   	push   %eax
  8020e4:	e8 96 f1 ff ff       	call   80127f <fd_alloc>
  8020e9:	89 c3                	mov    %eax,%ebx
  8020eb:	83 c4 10             	add    $0x10,%esp
  8020ee:	85 c0                	test   %eax,%eax
  8020f0:	0f 88 e2 00 00 00    	js     8021d8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020f6:	83 ec 04             	sub    $0x4,%esp
  8020f9:	68 07 04 00 00       	push   $0x407
  8020fe:	ff 75 f0             	pushl  -0x10(%ebp)
  802101:	6a 00                	push   $0x0
  802103:	e8 8b eb ff ff       	call   800c93 <sys_page_alloc>
  802108:	89 c3                	mov    %eax,%ebx
  80210a:	83 c4 10             	add    $0x10,%esp
  80210d:	85 c0                	test   %eax,%eax
  80210f:	0f 88 c3 00 00 00    	js     8021d8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802115:	83 ec 0c             	sub    $0xc,%esp
  802118:	ff 75 f4             	pushl  -0xc(%ebp)
  80211b:	e8 48 f1 ff ff       	call   801268 <fd2data>
  802120:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802122:	83 c4 0c             	add    $0xc,%esp
  802125:	68 07 04 00 00       	push   $0x407
  80212a:	50                   	push   %eax
  80212b:	6a 00                	push   $0x0
  80212d:	e8 61 eb ff ff       	call   800c93 <sys_page_alloc>
  802132:	89 c3                	mov    %eax,%ebx
  802134:	83 c4 10             	add    $0x10,%esp
  802137:	85 c0                	test   %eax,%eax
  802139:	0f 88 89 00 00 00    	js     8021c8 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80213f:	83 ec 0c             	sub    $0xc,%esp
  802142:	ff 75 f0             	pushl  -0x10(%ebp)
  802145:	e8 1e f1 ff ff       	call   801268 <fd2data>
  80214a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802151:	50                   	push   %eax
  802152:	6a 00                	push   $0x0
  802154:	56                   	push   %esi
  802155:	6a 00                	push   $0x0
  802157:	e8 7a eb ff ff       	call   800cd6 <sys_page_map>
  80215c:	89 c3                	mov    %eax,%ebx
  80215e:	83 c4 20             	add    $0x20,%esp
  802161:	85 c0                	test   %eax,%eax
  802163:	78 55                	js     8021ba <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802165:	8b 15 44 30 80 00    	mov    0x803044,%edx
  80216b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80216e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802170:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802173:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80217a:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802180:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802183:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802185:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802188:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80218f:	83 ec 0c             	sub    $0xc,%esp
  802192:	ff 75 f4             	pushl  -0xc(%ebp)
  802195:	e8 be f0 ff ff       	call   801258 <fd2num>
  80219a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80219d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80219f:	83 c4 04             	add    $0x4,%esp
  8021a2:	ff 75 f0             	pushl  -0x10(%ebp)
  8021a5:	e8 ae f0 ff ff       	call   801258 <fd2num>
  8021aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021ad:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021b0:	83 c4 10             	add    $0x10,%esp
  8021b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8021b8:	eb 30                	jmp    8021ea <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8021ba:	83 ec 08             	sub    $0x8,%esp
  8021bd:	56                   	push   %esi
  8021be:	6a 00                	push   $0x0
  8021c0:	e8 53 eb ff ff       	call   800d18 <sys_page_unmap>
  8021c5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8021c8:	83 ec 08             	sub    $0x8,%esp
  8021cb:	ff 75 f0             	pushl  -0x10(%ebp)
  8021ce:	6a 00                	push   $0x0
  8021d0:	e8 43 eb ff ff       	call   800d18 <sys_page_unmap>
  8021d5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021d8:	83 ec 08             	sub    $0x8,%esp
  8021db:	ff 75 f4             	pushl  -0xc(%ebp)
  8021de:	6a 00                	push   $0x0
  8021e0:	e8 33 eb ff ff       	call   800d18 <sys_page_unmap>
  8021e5:	83 c4 10             	add    $0x10,%esp
  8021e8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8021ea:	89 d0                	mov    %edx,%eax
  8021ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021ef:	5b                   	pop    %ebx
  8021f0:	5e                   	pop    %esi
  8021f1:	5d                   	pop    %ebp
  8021f2:	c3                   	ret    

008021f3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021f3:	55                   	push   %ebp
  8021f4:	89 e5                	mov    %esp,%ebp
  8021f6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021fc:	50                   	push   %eax
  8021fd:	ff 75 08             	pushl  0x8(%ebp)
  802200:	e8 c9 f0 ff ff       	call   8012ce <fd_lookup>
  802205:	83 c4 10             	add    $0x10,%esp
  802208:	85 c0                	test   %eax,%eax
  80220a:	78 18                	js     802224 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80220c:	83 ec 0c             	sub    $0xc,%esp
  80220f:	ff 75 f4             	pushl  -0xc(%ebp)
  802212:	e8 51 f0 ff ff       	call   801268 <fd2data>
	return _pipeisclosed(fd, p);
  802217:	89 c2                	mov    %eax,%edx
  802219:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80221c:	e8 21 fd ff ff       	call   801f42 <_pipeisclosed>
  802221:	83 c4 10             	add    $0x10,%esp
}
  802224:	c9                   	leave  
  802225:	c3                   	ret    

00802226 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802226:	55                   	push   %ebp
  802227:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802229:	b8 00 00 00 00       	mov    $0x0,%eax
  80222e:	5d                   	pop    %ebp
  80222f:	c3                   	ret    

00802230 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802230:	55                   	push   %ebp
  802231:	89 e5                	mov    %esp,%ebp
  802233:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802236:	68 0b 2d 80 00       	push   $0x802d0b
  80223b:	ff 75 0c             	pushl  0xc(%ebp)
  80223e:	e8 4d e6 ff ff       	call   800890 <strcpy>
	return 0;
}
  802243:	b8 00 00 00 00       	mov    $0x0,%eax
  802248:	c9                   	leave  
  802249:	c3                   	ret    

0080224a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80224a:	55                   	push   %ebp
  80224b:	89 e5                	mov    %esp,%ebp
  80224d:	57                   	push   %edi
  80224e:	56                   	push   %esi
  80224f:	53                   	push   %ebx
  802250:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802256:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80225b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802261:	eb 2d                	jmp    802290 <devcons_write+0x46>
		m = n - tot;
  802263:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802266:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802268:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80226b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802270:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802273:	83 ec 04             	sub    $0x4,%esp
  802276:	53                   	push   %ebx
  802277:	03 45 0c             	add    0xc(%ebp),%eax
  80227a:	50                   	push   %eax
  80227b:	57                   	push   %edi
  80227c:	e8 a1 e7 ff ff       	call   800a22 <memmove>
		sys_cputs(buf, m);
  802281:	83 c4 08             	add    $0x8,%esp
  802284:	53                   	push   %ebx
  802285:	57                   	push   %edi
  802286:	e8 4c e9 ff ff       	call   800bd7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80228b:	01 de                	add    %ebx,%esi
  80228d:	83 c4 10             	add    $0x10,%esp
  802290:	89 f0                	mov    %esi,%eax
  802292:	3b 75 10             	cmp    0x10(%ebp),%esi
  802295:	72 cc                	jb     802263 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802297:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80229a:	5b                   	pop    %ebx
  80229b:	5e                   	pop    %esi
  80229c:	5f                   	pop    %edi
  80229d:	5d                   	pop    %ebp
  80229e:	c3                   	ret    

0080229f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80229f:	55                   	push   %ebp
  8022a0:	89 e5                	mov    %esp,%ebp
  8022a2:	83 ec 08             	sub    $0x8,%esp
  8022a5:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8022aa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022ae:	74 2a                	je     8022da <devcons_read+0x3b>
  8022b0:	eb 05                	jmp    8022b7 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022b2:	e8 bd e9 ff ff       	call   800c74 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8022b7:	e8 39 e9 ff ff       	call   800bf5 <sys_cgetc>
  8022bc:	85 c0                	test   %eax,%eax
  8022be:	74 f2                	je     8022b2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8022c0:	85 c0                	test   %eax,%eax
  8022c2:	78 16                	js     8022da <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8022c4:	83 f8 04             	cmp    $0x4,%eax
  8022c7:	74 0c                	je     8022d5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8022c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022cc:	88 02                	mov    %al,(%edx)
	return 1;
  8022ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8022d3:	eb 05                	jmp    8022da <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022d5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022da:	c9                   	leave  
  8022db:	c3                   	ret    

008022dc <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  8022dc:	55                   	push   %ebp
  8022dd:	89 e5                	mov    %esp,%ebp
  8022df:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022e8:	6a 01                	push   $0x1
  8022ea:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022ed:	50                   	push   %eax
  8022ee:	e8 e4 e8 ff ff       	call   800bd7 <sys_cputs>
}
  8022f3:	83 c4 10             	add    $0x10,%esp
  8022f6:	c9                   	leave  
  8022f7:	c3                   	ret    

008022f8 <getchar>:

int
getchar(void)
{
  8022f8:	55                   	push   %ebp
  8022f9:	89 e5                	mov    %esp,%ebp
  8022fb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022fe:	6a 01                	push   $0x1
  802300:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802303:	50                   	push   %eax
  802304:	6a 00                	push   $0x0
  802306:	e8 29 f2 ff ff       	call   801534 <read>
	if (r < 0)
  80230b:	83 c4 10             	add    $0x10,%esp
  80230e:	85 c0                	test   %eax,%eax
  802310:	78 0f                	js     802321 <getchar+0x29>
		return r;
	if (r < 1)
  802312:	85 c0                	test   %eax,%eax
  802314:	7e 06                	jle    80231c <getchar+0x24>
		return -E_EOF;
	return c;
  802316:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80231a:	eb 05                	jmp    802321 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80231c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802321:	c9                   	leave  
  802322:	c3                   	ret    

00802323 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802323:	55                   	push   %ebp
  802324:	89 e5                	mov    %esp,%ebp
  802326:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802329:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80232c:	50                   	push   %eax
  80232d:	ff 75 08             	pushl  0x8(%ebp)
  802330:	e8 99 ef ff ff       	call   8012ce <fd_lookup>
  802335:	83 c4 10             	add    $0x10,%esp
  802338:	85 c0                	test   %eax,%eax
  80233a:	78 11                	js     80234d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80233c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80233f:	8b 15 60 30 80 00    	mov    0x803060,%edx
  802345:	39 10                	cmp    %edx,(%eax)
  802347:	0f 94 c0             	sete   %al
  80234a:	0f b6 c0             	movzbl %al,%eax
}
  80234d:	c9                   	leave  
  80234e:	c3                   	ret    

0080234f <opencons>:

int
opencons(void)
{
  80234f:	55                   	push   %ebp
  802350:	89 e5                	mov    %esp,%ebp
  802352:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802355:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802358:	50                   	push   %eax
  802359:	e8 21 ef ff ff       	call   80127f <fd_alloc>
  80235e:	83 c4 10             	add    $0x10,%esp
		return r;
  802361:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802363:	85 c0                	test   %eax,%eax
  802365:	78 3e                	js     8023a5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802367:	83 ec 04             	sub    $0x4,%esp
  80236a:	68 07 04 00 00       	push   $0x407
  80236f:	ff 75 f4             	pushl  -0xc(%ebp)
  802372:	6a 00                	push   $0x0
  802374:	e8 1a e9 ff ff       	call   800c93 <sys_page_alloc>
  802379:	83 c4 10             	add    $0x10,%esp
		return r;
  80237c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80237e:	85 c0                	test   %eax,%eax
  802380:	78 23                	js     8023a5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802382:	8b 15 60 30 80 00    	mov    0x803060,%edx
  802388:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80238b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80238d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802390:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802397:	83 ec 0c             	sub    $0xc,%esp
  80239a:	50                   	push   %eax
  80239b:	e8 b8 ee ff ff       	call   801258 <fd2num>
  8023a0:	89 c2                	mov    %eax,%edx
  8023a2:	83 c4 10             	add    $0x10,%esp
}
  8023a5:	89 d0                	mov    %edx,%eax
  8023a7:	c9                   	leave  
  8023a8:	c3                   	ret    

008023a9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8023a9:	55                   	push   %ebp
  8023aa:	89 e5                	mov    %esp,%ebp
  8023ac:	56                   	push   %esi
  8023ad:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8023ae:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8023b1:	8b 35 08 30 80 00    	mov    0x803008,%esi
  8023b7:	e8 99 e8 ff ff       	call   800c55 <sys_getenvid>
  8023bc:	83 ec 0c             	sub    $0xc,%esp
  8023bf:	ff 75 0c             	pushl  0xc(%ebp)
  8023c2:	ff 75 08             	pushl  0x8(%ebp)
  8023c5:	56                   	push   %esi
  8023c6:	50                   	push   %eax
  8023c7:	68 18 2d 80 00       	push   $0x802d18
  8023cc:	e8 bb de ff ff       	call   80028c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8023d1:	83 c4 18             	add    $0x18,%esp
  8023d4:	53                   	push   %ebx
  8023d5:	ff 75 10             	pushl  0x10(%ebp)
  8023d8:	e8 5e de ff ff       	call   80023b <vcprintf>
	cprintf("\n");
  8023dd:	c7 04 24 04 2d 80 00 	movl   $0x802d04,(%esp)
  8023e4:	e8 a3 de ff ff       	call   80028c <cprintf>
  8023e9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8023ec:	cc                   	int3   
  8023ed:	eb fd                	jmp    8023ec <_panic+0x43>

008023ef <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023ef:	55                   	push   %ebp
  8023f0:	89 e5                	mov    %esp,%ebp
  8023f2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023f5:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8023fc:	75 4a                	jne    802448 <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  8023fe:	a1 08 40 80 00       	mov    0x804008,%eax
  802403:	8b 40 48             	mov    0x48(%eax),%eax
  802406:	83 ec 04             	sub    $0x4,%esp
  802409:	6a 07                	push   $0x7
  80240b:	68 00 f0 bf ee       	push   $0xeebff000
  802410:	50                   	push   %eax
  802411:	e8 7d e8 ff ff       	call   800c93 <sys_page_alloc>
  802416:	83 c4 10             	add    $0x10,%esp
  802419:	85 c0                	test   %eax,%eax
  80241b:	79 12                	jns    80242f <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  80241d:	50                   	push   %eax
  80241e:	68 3c 2d 80 00       	push   $0x802d3c
  802423:	6a 21                	push   $0x21
  802425:	68 54 2d 80 00       	push   $0x802d54
  80242a:	e8 7a ff ff ff       	call   8023a9 <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80242f:	a1 08 40 80 00       	mov    0x804008,%eax
  802434:	8b 40 48             	mov    0x48(%eax),%eax
  802437:	83 ec 08             	sub    $0x8,%esp
  80243a:	68 52 24 80 00       	push   $0x802452
  80243f:	50                   	push   %eax
  802440:	e8 99 e9 ff ff       	call   800dde <sys_env_set_pgfault_upcall>
  802445:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802448:	8b 45 08             	mov    0x8(%ebp),%eax
  80244b:	a3 00 70 80 00       	mov    %eax,0x807000
  802450:	c9                   	leave  
  802451:	c3                   	ret    

00802452 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802452:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802453:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802458:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80245a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  80245d:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  802460:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  802464:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  802469:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  80246d:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  80246f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  802470:	83 c4 04             	add    $0x4,%esp
	popfl
  802473:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802474:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  802475:	c3                   	ret    

00802476 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802476:	55                   	push   %ebp
  802477:	89 e5                	mov    %esp,%ebp
  802479:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80247c:	89 d0                	mov    %edx,%eax
  80247e:	c1 e8 16             	shr    $0x16,%eax
  802481:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802488:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80248d:	f6 c1 01             	test   $0x1,%cl
  802490:	74 1d                	je     8024af <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802492:	c1 ea 0c             	shr    $0xc,%edx
  802495:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80249c:	f6 c2 01             	test   $0x1,%dl
  80249f:	74 0e                	je     8024af <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024a1:	c1 ea 0c             	shr    $0xc,%edx
  8024a4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8024ab:	ef 
  8024ac:	0f b7 c0             	movzwl %ax,%eax
}
  8024af:	5d                   	pop    %ebp
  8024b0:	c3                   	ret    
  8024b1:	66 90                	xchg   %ax,%ax
  8024b3:	66 90                	xchg   %ax,%ax
  8024b5:	66 90                	xchg   %ax,%ax
  8024b7:	66 90                	xchg   %ax,%ax
  8024b9:	66 90                	xchg   %ax,%ax
  8024bb:	66 90                	xchg   %ax,%ax
  8024bd:	66 90                	xchg   %ax,%ax
  8024bf:	90                   	nop

008024c0 <__udivdi3>:
  8024c0:	55                   	push   %ebp
  8024c1:	57                   	push   %edi
  8024c2:	56                   	push   %esi
  8024c3:	53                   	push   %ebx
  8024c4:	83 ec 1c             	sub    $0x1c,%esp
  8024c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8024cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8024cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8024d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024d7:	85 f6                	test   %esi,%esi
  8024d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024dd:	89 ca                	mov    %ecx,%edx
  8024df:	89 f8                	mov    %edi,%eax
  8024e1:	75 3d                	jne    802520 <__udivdi3+0x60>
  8024e3:	39 cf                	cmp    %ecx,%edi
  8024e5:	0f 87 c5 00 00 00    	ja     8025b0 <__udivdi3+0xf0>
  8024eb:	85 ff                	test   %edi,%edi
  8024ed:	89 fd                	mov    %edi,%ebp
  8024ef:	75 0b                	jne    8024fc <__udivdi3+0x3c>
  8024f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024f6:	31 d2                	xor    %edx,%edx
  8024f8:	f7 f7                	div    %edi
  8024fa:	89 c5                	mov    %eax,%ebp
  8024fc:	89 c8                	mov    %ecx,%eax
  8024fe:	31 d2                	xor    %edx,%edx
  802500:	f7 f5                	div    %ebp
  802502:	89 c1                	mov    %eax,%ecx
  802504:	89 d8                	mov    %ebx,%eax
  802506:	89 cf                	mov    %ecx,%edi
  802508:	f7 f5                	div    %ebp
  80250a:	89 c3                	mov    %eax,%ebx
  80250c:	89 d8                	mov    %ebx,%eax
  80250e:	89 fa                	mov    %edi,%edx
  802510:	83 c4 1c             	add    $0x1c,%esp
  802513:	5b                   	pop    %ebx
  802514:	5e                   	pop    %esi
  802515:	5f                   	pop    %edi
  802516:	5d                   	pop    %ebp
  802517:	c3                   	ret    
  802518:	90                   	nop
  802519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802520:	39 ce                	cmp    %ecx,%esi
  802522:	77 74                	ja     802598 <__udivdi3+0xd8>
  802524:	0f bd fe             	bsr    %esi,%edi
  802527:	83 f7 1f             	xor    $0x1f,%edi
  80252a:	0f 84 98 00 00 00    	je     8025c8 <__udivdi3+0x108>
  802530:	bb 20 00 00 00       	mov    $0x20,%ebx
  802535:	89 f9                	mov    %edi,%ecx
  802537:	89 c5                	mov    %eax,%ebp
  802539:	29 fb                	sub    %edi,%ebx
  80253b:	d3 e6                	shl    %cl,%esi
  80253d:	89 d9                	mov    %ebx,%ecx
  80253f:	d3 ed                	shr    %cl,%ebp
  802541:	89 f9                	mov    %edi,%ecx
  802543:	d3 e0                	shl    %cl,%eax
  802545:	09 ee                	or     %ebp,%esi
  802547:	89 d9                	mov    %ebx,%ecx
  802549:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80254d:	89 d5                	mov    %edx,%ebp
  80254f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802553:	d3 ed                	shr    %cl,%ebp
  802555:	89 f9                	mov    %edi,%ecx
  802557:	d3 e2                	shl    %cl,%edx
  802559:	89 d9                	mov    %ebx,%ecx
  80255b:	d3 e8                	shr    %cl,%eax
  80255d:	09 c2                	or     %eax,%edx
  80255f:	89 d0                	mov    %edx,%eax
  802561:	89 ea                	mov    %ebp,%edx
  802563:	f7 f6                	div    %esi
  802565:	89 d5                	mov    %edx,%ebp
  802567:	89 c3                	mov    %eax,%ebx
  802569:	f7 64 24 0c          	mull   0xc(%esp)
  80256d:	39 d5                	cmp    %edx,%ebp
  80256f:	72 10                	jb     802581 <__udivdi3+0xc1>
  802571:	8b 74 24 08          	mov    0x8(%esp),%esi
  802575:	89 f9                	mov    %edi,%ecx
  802577:	d3 e6                	shl    %cl,%esi
  802579:	39 c6                	cmp    %eax,%esi
  80257b:	73 07                	jae    802584 <__udivdi3+0xc4>
  80257d:	39 d5                	cmp    %edx,%ebp
  80257f:	75 03                	jne    802584 <__udivdi3+0xc4>
  802581:	83 eb 01             	sub    $0x1,%ebx
  802584:	31 ff                	xor    %edi,%edi
  802586:	89 d8                	mov    %ebx,%eax
  802588:	89 fa                	mov    %edi,%edx
  80258a:	83 c4 1c             	add    $0x1c,%esp
  80258d:	5b                   	pop    %ebx
  80258e:	5e                   	pop    %esi
  80258f:	5f                   	pop    %edi
  802590:	5d                   	pop    %ebp
  802591:	c3                   	ret    
  802592:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802598:	31 ff                	xor    %edi,%edi
  80259a:	31 db                	xor    %ebx,%ebx
  80259c:	89 d8                	mov    %ebx,%eax
  80259e:	89 fa                	mov    %edi,%edx
  8025a0:	83 c4 1c             	add    $0x1c,%esp
  8025a3:	5b                   	pop    %ebx
  8025a4:	5e                   	pop    %esi
  8025a5:	5f                   	pop    %edi
  8025a6:	5d                   	pop    %ebp
  8025a7:	c3                   	ret    
  8025a8:	90                   	nop
  8025a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025b0:	89 d8                	mov    %ebx,%eax
  8025b2:	f7 f7                	div    %edi
  8025b4:	31 ff                	xor    %edi,%edi
  8025b6:	89 c3                	mov    %eax,%ebx
  8025b8:	89 d8                	mov    %ebx,%eax
  8025ba:	89 fa                	mov    %edi,%edx
  8025bc:	83 c4 1c             	add    $0x1c,%esp
  8025bf:	5b                   	pop    %ebx
  8025c0:	5e                   	pop    %esi
  8025c1:	5f                   	pop    %edi
  8025c2:	5d                   	pop    %ebp
  8025c3:	c3                   	ret    
  8025c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025c8:	39 ce                	cmp    %ecx,%esi
  8025ca:	72 0c                	jb     8025d8 <__udivdi3+0x118>
  8025cc:	31 db                	xor    %ebx,%ebx
  8025ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8025d2:	0f 87 34 ff ff ff    	ja     80250c <__udivdi3+0x4c>
  8025d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8025dd:	e9 2a ff ff ff       	jmp    80250c <__udivdi3+0x4c>
  8025e2:	66 90                	xchg   %ax,%ax
  8025e4:	66 90                	xchg   %ax,%ax
  8025e6:	66 90                	xchg   %ax,%ax
  8025e8:	66 90                	xchg   %ax,%ax
  8025ea:	66 90                	xchg   %ax,%ax
  8025ec:	66 90                	xchg   %ax,%ax
  8025ee:	66 90                	xchg   %ax,%ax

008025f0 <__umoddi3>:
  8025f0:	55                   	push   %ebp
  8025f1:	57                   	push   %edi
  8025f2:	56                   	push   %esi
  8025f3:	53                   	push   %ebx
  8025f4:	83 ec 1c             	sub    $0x1c,%esp
  8025f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802603:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802607:	85 d2                	test   %edx,%edx
  802609:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80260d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802611:	89 f3                	mov    %esi,%ebx
  802613:	89 3c 24             	mov    %edi,(%esp)
  802616:	89 74 24 04          	mov    %esi,0x4(%esp)
  80261a:	75 1c                	jne    802638 <__umoddi3+0x48>
  80261c:	39 f7                	cmp    %esi,%edi
  80261e:	76 50                	jbe    802670 <__umoddi3+0x80>
  802620:	89 c8                	mov    %ecx,%eax
  802622:	89 f2                	mov    %esi,%edx
  802624:	f7 f7                	div    %edi
  802626:	89 d0                	mov    %edx,%eax
  802628:	31 d2                	xor    %edx,%edx
  80262a:	83 c4 1c             	add    $0x1c,%esp
  80262d:	5b                   	pop    %ebx
  80262e:	5e                   	pop    %esi
  80262f:	5f                   	pop    %edi
  802630:	5d                   	pop    %ebp
  802631:	c3                   	ret    
  802632:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802638:	39 f2                	cmp    %esi,%edx
  80263a:	89 d0                	mov    %edx,%eax
  80263c:	77 52                	ja     802690 <__umoddi3+0xa0>
  80263e:	0f bd ea             	bsr    %edx,%ebp
  802641:	83 f5 1f             	xor    $0x1f,%ebp
  802644:	75 5a                	jne    8026a0 <__umoddi3+0xb0>
  802646:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80264a:	0f 82 e0 00 00 00    	jb     802730 <__umoddi3+0x140>
  802650:	39 0c 24             	cmp    %ecx,(%esp)
  802653:	0f 86 d7 00 00 00    	jbe    802730 <__umoddi3+0x140>
  802659:	8b 44 24 08          	mov    0x8(%esp),%eax
  80265d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802661:	83 c4 1c             	add    $0x1c,%esp
  802664:	5b                   	pop    %ebx
  802665:	5e                   	pop    %esi
  802666:	5f                   	pop    %edi
  802667:	5d                   	pop    %ebp
  802668:	c3                   	ret    
  802669:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802670:	85 ff                	test   %edi,%edi
  802672:	89 fd                	mov    %edi,%ebp
  802674:	75 0b                	jne    802681 <__umoddi3+0x91>
  802676:	b8 01 00 00 00       	mov    $0x1,%eax
  80267b:	31 d2                	xor    %edx,%edx
  80267d:	f7 f7                	div    %edi
  80267f:	89 c5                	mov    %eax,%ebp
  802681:	89 f0                	mov    %esi,%eax
  802683:	31 d2                	xor    %edx,%edx
  802685:	f7 f5                	div    %ebp
  802687:	89 c8                	mov    %ecx,%eax
  802689:	f7 f5                	div    %ebp
  80268b:	89 d0                	mov    %edx,%eax
  80268d:	eb 99                	jmp    802628 <__umoddi3+0x38>
  80268f:	90                   	nop
  802690:	89 c8                	mov    %ecx,%eax
  802692:	89 f2                	mov    %esi,%edx
  802694:	83 c4 1c             	add    $0x1c,%esp
  802697:	5b                   	pop    %ebx
  802698:	5e                   	pop    %esi
  802699:	5f                   	pop    %edi
  80269a:	5d                   	pop    %ebp
  80269b:	c3                   	ret    
  80269c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	8b 34 24             	mov    (%esp),%esi
  8026a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8026a8:	89 e9                	mov    %ebp,%ecx
  8026aa:	29 ef                	sub    %ebp,%edi
  8026ac:	d3 e0                	shl    %cl,%eax
  8026ae:	89 f9                	mov    %edi,%ecx
  8026b0:	89 f2                	mov    %esi,%edx
  8026b2:	d3 ea                	shr    %cl,%edx
  8026b4:	89 e9                	mov    %ebp,%ecx
  8026b6:	09 c2                	or     %eax,%edx
  8026b8:	89 d8                	mov    %ebx,%eax
  8026ba:	89 14 24             	mov    %edx,(%esp)
  8026bd:	89 f2                	mov    %esi,%edx
  8026bf:	d3 e2                	shl    %cl,%edx
  8026c1:	89 f9                	mov    %edi,%ecx
  8026c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8026cb:	d3 e8                	shr    %cl,%eax
  8026cd:	89 e9                	mov    %ebp,%ecx
  8026cf:	89 c6                	mov    %eax,%esi
  8026d1:	d3 e3                	shl    %cl,%ebx
  8026d3:	89 f9                	mov    %edi,%ecx
  8026d5:	89 d0                	mov    %edx,%eax
  8026d7:	d3 e8                	shr    %cl,%eax
  8026d9:	89 e9                	mov    %ebp,%ecx
  8026db:	09 d8                	or     %ebx,%eax
  8026dd:	89 d3                	mov    %edx,%ebx
  8026df:	89 f2                	mov    %esi,%edx
  8026e1:	f7 34 24             	divl   (%esp)
  8026e4:	89 d6                	mov    %edx,%esi
  8026e6:	d3 e3                	shl    %cl,%ebx
  8026e8:	f7 64 24 04          	mull   0x4(%esp)
  8026ec:	39 d6                	cmp    %edx,%esi
  8026ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026f2:	89 d1                	mov    %edx,%ecx
  8026f4:	89 c3                	mov    %eax,%ebx
  8026f6:	72 08                	jb     802700 <__umoddi3+0x110>
  8026f8:	75 11                	jne    80270b <__umoddi3+0x11b>
  8026fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8026fe:	73 0b                	jae    80270b <__umoddi3+0x11b>
  802700:	2b 44 24 04          	sub    0x4(%esp),%eax
  802704:	1b 14 24             	sbb    (%esp),%edx
  802707:	89 d1                	mov    %edx,%ecx
  802709:	89 c3                	mov    %eax,%ebx
  80270b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80270f:	29 da                	sub    %ebx,%edx
  802711:	19 ce                	sbb    %ecx,%esi
  802713:	89 f9                	mov    %edi,%ecx
  802715:	89 f0                	mov    %esi,%eax
  802717:	d3 e0                	shl    %cl,%eax
  802719:	89 e9                	mov    %ebp,%ecx
  80271b:	d3 ea                	shr    %cl,%edx
  80271d:	89 e9                	mov    %ebp,%ecx
  80271f:	d3 ee                	shr    %cl,%esi
  802721:	09 d0                	or     %edx,%eax
  802723:	89 f2                	mov    %esi,%edx
  802725:	83 c4 1c             	add    $0x1c,%esp
  802728:	5b                   	pop    %ebx
  802729:	5e                   	pop    %esi
  80272a:	5f                   	pop    %edi
  80272b:	5d                   	pop    %ebp
  80272c:	c3                   	ret    
  80272d:	8d 76 00             	lea    0x0(%esi),%esi
  802730:	29 f9                	sub    %edi,%ecx
  802732:	19 d6                	sbb    %edx,%esi
  802734:	89 74 24 04          	mov    %esi,0x4(%esp)
  802738:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80273c:	e9 18 ff ff ff       	jmp    802659 <__umoddi3+0x69>
