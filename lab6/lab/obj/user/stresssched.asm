
obj/user/stresssched.debug：     文件格式 elf32-i386


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
  80002c:	e8 bc 00 00 00       	call   8000ed <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 b2 0b 00 00       	call   800bef <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 06 0f 00 00       	call   800f4f <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0a                	je     800057 <umain+0x24>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
  800055:	eb 05                	jmp    80005c <umain+0x29>
		if (fork() == 0)
			break;
	if (i == 20) {
  800057:	83 fb 14             	cmp    $0x14,%ebx
  80005a:	75 0e                	jne    80006a <umain+0x37>
		sys_yield();
  80005c:	e8 ad 0b 00 00       	call   800c0e <sys_yield>
		return;
  800061:	e9 80 00 00 00       	jmp    8000e6 <umain+0xb3>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800066:	f3 90                	pause  
  800068:	eb 0f                	jmp    800079 <umain+0x46>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800070:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800073:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800079:	8b 42 54             	mov    0x54(%edx),%eax
  80007c:	85 c0                	test   %eax,%eax
  80007e:	75 e6                	jne    800066 <umain+0x33>
  800080:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800085:	e8 84 0b 00 00       	call   800c0e <sys_yield>
  80008a:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008f:	a1 08 40 80 00       	mov    0x804008,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 08 40 80 00       	mov    %eax,0x804008
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  80009c:	83 ea 01             	sub    $0x1,%edx
  80009f:	75 ee                	jne    80008f <umain+0x5c>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000a1:	83 eb 01             	sub    $0x1,%ebx
  8000a4:	75 df                	jne    800085 <umain+0x52>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000a6:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 a0 26 80 00       	push   $0x8026a0
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 c8 26 80 00       	push   $0x8026c8
  8000c4:	e8 84 00 00 00       	call   80014d <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 db 26 80 00       	push   $0x8026db
  8000de:	e8 43 01 00 00       	call   800226 <cprintf>
  8000e3:	83 c4 10             	add    $0x10,%esp

}
  8000e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f5:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8000f8:	e8 f2 0a 00 00       	call   800bef <sys_getenvid>
  8000fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800102:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 0c 40 80 00       	mov    %eax,0x80400c

    // save the name of the program so that panic() can use it
    if (argc > 0)
  80010f:	85 db                	test   %ebx,%ebx
  800111:	7e 07                	jle    80011a <libmain+0x2d>
        binaryname = argv[0];
  800113:	8b 06                	mov    (%esi),%eax
  800115:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
  80011f:	e8 0f ff ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  800124:	e8 0a 00 00 00       	call   800133 <exit>
}
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800139:	e8 89 11 00 00       	call   8012c7 <close_all>
	sys_env_destroy(0);
  80013e:	83 ec 0c             	sub    $0xc,%esp
  800141:	6a 00                	push   $0x0
  800143:	e8 66 0a 00 00       	call   800bae <sys_env_destroy>
}
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800152:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800155:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80015b:	e8 8f 0a 00 00       	call   800bef <sys_getenvid>
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 75 0c             	pushl  0xc(%ebp)
  800166:	ff 75 08             	pushl  0x8(%ebp)
  800169:	56                   	push   %esi
  80016a:	50                   	push   %eax
  80016b:	68 04 27 80 00       	push   $0x802704
  800170:	e8 b1 00 00 00       	call   800226 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800175:	83 c4 18             	add    $0x18,%esp
  800178:	53                   	push   %ebx
  800179:	ff 75 10             	pushl  0x10(%ebp)
  80017c:	e8 54 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  800181:	c7 04 24 f7 26 80 00 	movl   $0x8026f7,(%esp)
  800188:	e8 99 00 00 00       	call   800226 <cprintf>
  80018d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800190:	cc                   	int3   
  800191:	eb fd                	jmp    800190 <_panic+0x43>

00800193 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	53                   	push   %ebx
  800197:	83 ec 04             	sub    $0x4,%esp
  80019a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019d:	8b 13                	mov    (%ebx),%edx
  80019f:	8d 42 01             	lea    0x1(%edx),%eax
  8001a2:	89 03                	mov    %eax,(%ebx)
  8001a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ab:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b0:	75 1a                	jne    8001cc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	68 ff 00 00 00       	push   $0xff
  8001ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bd:	50                   	push   %eax
  8001be:	e8 ae 09 00 00       	call   800b71 <sys_cputs>
		b->idx = 0;
  8001c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d3:	c9                   	leave  
  8001d4:	c3                   	ret    

008001d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e5:	00 00 00 
	b.cnt = 0;
  8001e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f2:	ff 75 0c             	pushl  0xc(%ebp)
  8001f5:	ff 75 08             	pushl  0x8(%ebp)
  8001f8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fe:	50                   	push   %eax
  8001ff:	68 93 01 80 00       	push   $0x800193
  800204:	e8 1a 01 00 00       	call   800323 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800209:	83 c4 08             	add    $0x8,%esp
  80020c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800212:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800218:	50                   	push   %eax
  800219:	e8 53 09 00 00       	call   800b71 <sys_cputs>

	return b.cnt;
}
  80021e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022f:	50                   	push   %eax
  800230:	ff 75 08             	pushl  0x8(%ebp)
  800233:	e8 9d ff ff ff       	call   8001d5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	57                   	push   %edi
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
  800240:	83 ec 1c             	sub    $0x1c,%esp
  800243:	89 c7                	mov    %eax,%edi
  800245:	89 d6                	mov    %edx,%esi
  800247:	8b 45 08             	mov    0x8(%ebp),%eax
  80024a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800250:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800253:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800256:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800261:	39 d3                	cmp    %edx,%ebx
  800263:	72 05                	jb     80026a <printnum+0x30>
  800265:	39 45 10             	cmp    %eax,0x10(%ebp)
  800268:	77 45                	ja     8002af <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	8b 45 14             	mov    0x14(%ebp),%eax
  800273:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800276:	53                   	push   %ebx
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	83 ec 08             	sub    $0x8,%esp
  80027d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800280:	ff 75 e0             	pushl  -0x20(%ebp)
  800283:	ff 75 dc             	pushl  -0x24(%ebp)
  800286:	ff 75 d8             	pushl  -0x28(%ebp)
  800289:	e8 82 21 00 00       	call   802410 <__udivdi3>
  80028e:	83 c4 18             	add    $0x18,%esp
  800291:	52                   	push   %edx
  800292:	50                   	push   %eax
  800293:	89 f2                	mov    %esi,%edx
  800295:	89 f8                	mov    %edi,%eax
  800297:	e8 9e ff ff ff       	call   80023a <printnum>
  80029c:	83 c4 20             	add    $0x20,%esp
  80029f:	eb 18                	jmp    8002b9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	ff 75 18             	pushl  0x18(%ebp)
  8002a8:	ff d7                	call   *%edi
  8002aa:	83 c4 10             	add    $0x10,%esp
  8002ad:	eb 03                	jmp    8002b2 <printnum+0x78>
  8002af:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b2:	83 eb 01             	sub    $0x1,%ebx
  8002b5:	85 db                	test   %ebx,%ebx
  8002b7:	7f e8                	jg     8002a1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	56                   	push   %esi
  8002bd:	83 ec 04             	sub    $0x4,%esp
  8002c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cc:	e8 6f 22 00 00       	call   802540 <__umoddi3>
  8002d1:	83 c4 14             	add    $0x14,%esp
  8002d4:	0f be 80 27 27 80 00 	movsbl 0x802727(%eax),%eax
  8002db:	50                   	push   %eax
  8002dc:	ff d7                	call   *%edi
}
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e4:	5b                   	pop    %ebx
  8002e5:	5e                   	pop    %esi
  8002e6:	5f                   	pop    %edi
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f3:	8b 10                	mov    (%eax),%edx
  8002f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f8:	73 0a                	jae    800304 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fd:	89 08                	mov    %ecx,(%eax)
  8002ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800302:	88 02                	mov    %al,(%edx)
}
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80030c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030f:	50                   	push   %eax
  800310:	ff 75 10             	pushl  0x10(%ebp)
  800313:	ff 75 0c             	pushl  0xc(%ebp)
  800316:	ff 75 08             	pushl  0x8(%ebp)
  800319:	e8 05 00 00 00       	call   800323 <vprintfmt>
	va_end(ap);
}
  80031e:	83 c4 10             	add    $0x10,%esp
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 2c             	sub    $0x2c,%esp
  80032c:	8b 75 08             	mov    0x8(%ebp),%esi
  80032f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800332:	8b 7d 10             	mov    0x10(%ebp),%edi
  800335:	eb 12                	jmp    800349 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800337:	85 c0                	test   %eax,%eax
  800339:	0f 84 42 04 00 00    	je     800781 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80033f:	83 ec 08             	sub    $0x8,%esp
  800342:	53                   	push   %ebx
  800343:	50                   	push   %eax
  800344:	ff d6                	call   *%esi
  800346:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800349:	83 c7 01             	add    $0x1,%edi
  80034c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800350:	83 f8 25             	cmp    $0x25,%eax
  800353:	75 e2                	jne    800337 <vprintfmt+0x14>
  800355:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800359:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800360:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800367:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80036e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800373:	eb 07                	jmp    80037c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800378:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8d 47 01             	lea    0x1(%edi),%eax
  80037f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800382:	0f b6 07             	movzbl (%edi),%eax
  800385:	0f b6 d0             	movzbl %al,%edx
  800388:	83 e8 23             	sub    $0x23,%eax
  80038b:	3c 55                	cmp    $0x55,%al
  80038d:	0f 87 d3 03 00 00    	ja     800766 <vprintfmt+0x443>
  800393:	0f b6 c0             	movzbl %al,%eax
  800396:	ff 24 85 60 28 80 00 	jmp    *0x802860(,%eax,4)
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a4:	eb d6                	jmp    80037c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ae:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b4:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003b8:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003bb:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003be:	83 f9 09             	cmp    $0x9,%ecx
  8003c1:	77 3f                	ja     800402 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c6:	eb e9                	jmp    8003b1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cb:	8b 00                	mov    (%eax),%eax
  8003cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d3:	8d 40 04             	lea    0x4(%eax),%eax
  8003d6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003dc:	eb 2a                	jmp    800408 <vprintfmt+0xe5>
  8003de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e1:	85 c0                	test   %eax,%eax
  8003e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e8:	0f 49 d0             	cmovns %eax,%edx
  8003eb:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f1:	eb 89                	jmp    80037c <vprintfmt+0x59>
  8003f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003fd:	e9 7a ff ff ff       	jmp    80037c <vprintfmt+0x59>
  800402:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800405:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800408:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040c:	0f 89 6a ff ff ff    	jns    80037c <vprintfmt+0x59>
				width = precision, precision = -1;
  800412:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800415:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800418:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80041f:	e9 58 ff ff ff       	jmp    80037c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800424:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80042a:	e9 4d ff ff ff       	jmp    80037c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042f:	8b 45 14             	mov    0x14(%ebp),%eax
  800432:	8d 78 04             	lea    0x4(%eax),%edi
  800435:	83 ec 08             	sub    $0x8,%esp
  800438:	53                   	push   %ebx
  800439:	ff 30                	pushl  (%eax)
  80043b:	ff d6                	call   *%esi
			break;
  80043d:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800440:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800443:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800446:	e9 fe fe ff ff       	jmp    800349 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044b:	8b 45 14             	mov    0x14(%ebp),%eax
  80044e:	8d 78 04             	lea    0x4(%eax),%edi
  800451:	8b 00                	mov    (%eax),%eax
  800453:	99                   	cltd   
  800454:	31 d0                	xor    %edx,%eax
  800456:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800458:	83 f8 0f             	cmp    $0xf,%eax
  80045b:	7f 0b                	jg     800468 <vprintfmt+0x145>
  80045d:	8b 14 85 c0 29 80 00 	mov    0x8029c0(,%eax,4),%edx
  800464:	85 d2                	test   %edx,%edx
  800466:	75 1b                	jne    800483 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800468:	50                   	push   %eax
  800469:	68 3f 27 80 00       	push   $0x80273f
  80046e:	53                   	push   %ebx
  80046f:	56                   	push   %esi
  800470:	e8 91 fe ff ff       	call   800306 <printfmt>
  800475:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800478:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047e:	e9 c6 fe ff ff       	jmp    800349 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800483:	52                   	push   %edx
  800484:	68 9d 2b 80 00       	push   $0x802b9d
  800489:	53                   	push   %ebx
  80048a:	56                   	push   %esi
  80048b:	e8 76 fe ff ff       	call   800306 <printfmt>
  800490:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800493:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800496:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800499:	e9 ab fe ff ff       	jmp    800349 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049e:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a1:	83 c0 04             	add    $0x4,%eax
  8004a4:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004aa:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ac:	85 ff                	test   %edi,%edi
  8004ae:	b8 38 27 80 00       	mov    $0x802738,%eax
  8004b3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ba:	0f 8e 94 00 00 00    	jle    800554 <vprintfmt+0x231>
  8004c0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c4:	0f 84 98 00 00 00    	je     800562 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	ff 75 d0             	pushl  -0x30(%ebp)
  8004d0:	57                   	push   %edi
  8004d1:	e8 33 03 00 00       	call   800809 <strnlen>
  8004d6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d9:	29 c1                	sub    %eax,%ecx
  8004db:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004de:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004eb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ed:	eb 0f                	jmp    8004fe <vprintfmt+0x1db>
					putch(padc, putdat);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	53                   	push   %ebx
  8004f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	83 ef 01             	sub    $0x1,%edi
  8004fb:	83 c4 10             	add    $0x10,%esp
  8004fe:	85 ff                	test   %edi,%edi
  800500:	7f ed                	jg     8004ef <vprintfmt+0x1cc>
  800502:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800505:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800508:	85 c9                	test   %ecx,%ecx
  80050a:	b8 00 00 00 00       	mov    $0x0,%eax
  80050f:	0f 49 c1             	cmovns %ecx,%eax
  800512:	29 c1                	sub    %eax,%ecx
  800514:	89 75 08             	mov    %esi,0x8(%ebp)
  800517:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051d:	89 cb                	mov    %ecx,%ebx
  80051f:	eb 4d                	jmp    80056e <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800521:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800525:	74 1b                	je     800542 <vprintfmt+0x21f>
  800527:	0f be c0             	movsbl %al,%eax
  80052a:	83 e8 20             	sub    $0x20,%eax
  80052d:	83 f8 5e             	cmp    $0x5e,%eax
  800530:	76 10                	jbe    800542 <vprintfmt+0x21f>
					putch('?', putdat);
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	ff 75 0c             	pushl  0xc(%ebp)
  800538:	6a 3f                	push   $0x3f
  80053a:	ff 55 08             	call   *0x8(%ebp)
  80053d:	83 c4 10             	add    $0x10,%esp
  800540:	eb 0d                	jmp    80054f <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	ff 75 0c             	pushl  0xc(%ebp)
  800548:	52                   	push   %edx
  800549:	ff 55 08             	call   *0x8(%ebp)
  80054c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054f:	83 eb 01             	sub    $0x1,%ebx
  800552:	eb 1a                	jmp    80056e <vprintfmt+0x24b>
  800554:	89 75 08             	mov    %esi,0x8(%ebp)
  800557:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800560:	eb 0c                	jmp    80056e <vprintfmt+0x24b>
  800562:	89 75 08             	mov    %esi,0x8(%ebp)
  800565:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800568:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056e:	83 c7 01             	add    $0x1,%edi
  800571:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800575:	0f be d0             	movsbl %al,%edx
  800578:	85 d2                	test   %edx,%edx
  80057a:	74 23                	je     80059f <vprintfmt+0x27c>
  80057c:	85 f6                	test   %esi,%esi
  80057e:	78 a1                	js     800521 <vprintfmt+0x1fe>
  800580:	83 ee 01             	sub    $0x1,%esi
  800583:	79 9c                	jns    800521 <vprintfmt+0x1fe>
  800585:	89 df                	mov    %ebx,%edi
  800587:	8b 75 08             	mov    0x8(%ebp),%esi
  80058a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058d:	eb 18                	jmp    8005a7 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	53                   	push   %ebx
  800593:	6a 20                	push   $0x20
  800595:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800597:	83 ef 01             	sub    $0x1,%edi
  80059a:	83 c4 10             	add    $0x10,%esp
  80059d:	eb 08                	jmp    8005a7 <vprintfmt+0x284>
  80059f:	89 df                	mov    %ebx,%edi
  8005a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a7:	85 ff                	test   %edi,%edi
  8005a9:	7f e4                	jg     80058f <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005ab:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005ae:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b4:	e9 90 fd ff ff       	jmp    800349 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b9:	83 f9 01             	cmp    $0x1,%ecx
  8005bc:	7e 19                	jle    8005d7 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8b 50 04             	mov    0x4(%eax),%edx
  8005c4:	8b 00                	mov    (%eax),%eax
  8005c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 40 08             	lea    0x8(%eax),%eax
  8005d2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d5:	eb 38                	jmp    80060f <vprintfmt+0x2ec>
	else if (lflag)
  8005d7:	85 c9                	test   %ecx,%ecx
  8005d9:	74 1b                	je     8005f6 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8b 00                	mov    (%eax),%eax
  8005e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e3:	89 c1                	mov    %eax,%ecx
  8005e5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8d 40 04             	lea    0x4(%eax),%eax
  8005f1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f4:	eb 19                	jmp    80060f <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8b 00                	mov    (%eax),%eax
  8005fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fe:	89 c1                	mov    %eax,%ecx
  800600:	c1 f9 1f             	sar    $0x1f,%ecx
  800603:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 40 04             	lea    0x4(%eax),%eax
  80060c:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800612:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800615:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80061a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061e:	0f 89 0e 01 00 00    	jns    800732 <vprintfmt+0x40f>
				putch('-', putdat);
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	53                   	push   %ebx
  800628:	6a 2d                	push   $0x2d
  80062a:	ff d6                	call   *%esi
				num = -(long long) num;
  80062c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80062f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800632:	f7 da                	neg    %edx
  800634:	83 d1 00             	adc    $0x0,%ecx
  800637:	f7 d9                	neg    %ecx
  800639:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80063c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800641:	e9 ec 00 00 00       	jmp    800732 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800646:	83 f9 01             	cmp    $0x1,%ecx
  800649:	7e 18                	jle    800663 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8b 10                	mov    (%eax),%edx
  800650:	8b 48 04             	mov    0x4(%eax),%ecx
  800653:	8d 40 08             	lea    0x8(%eax),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800659:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065e:	e9 cf 00 00 00       	jmp    800732 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800663:	85 c9                	test   %ecx,%ecx
  800665:	74 1a                	je     800681 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	8b 10                	mov    (%eax),%edx
  80066c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800671:	8d 40 04             	lea    0x4(%eax),%eax
  800674:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800677:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067c:	e9 b1 00 00 00       	jmp    800732 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8b 10                	mov    (%eax),%edx
  800686:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068b:	8d 40 04             	lea    0x4(%eax),%eax
  80068e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800691:	b8 0a 00 00 00       	mov    $0xa,%eax
  800696:	e9 97 00 00 00       	jmp    800732 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	53                   	push   %ebx
  80069f:	6a 58                	push   $0x58
  8006a1:	ff d6                	call   *%esi
			putch('X', putdat);
  8006a3:	83 c4 08             	add    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	6a 58                	push   $0x58
  8006a9:	ff d6                	call   *%esi
			putch('X', putdat);
  8006ab:	83 c4 08             	add    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	6a 58                	push   $0x58
  8006b1:	ff d6                	call   *%esi
			break;
  8006b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006b9:	e9 8b fc ff ff       	jmp    800349 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	53                   	push   %ebx
  8006c2:	6a 30                	push   $0x30
  8006c4:	ff d6                	call   *%esi
			putch('x', putdat);
  8006c6:	83 c4 08             	add    $0x8,%esp
  8006c9:	53                   	push   %ebx
  8006ca:	6a 78                	push   $0x78
  8006cc:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8b 10                	mov    (%eax),%edx
  8006d3:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006d8:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006db:	8d 40 04             	lea    0x4(%eax),%eax
  8006de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e1:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006e6:	eb 4a                	jmp    800732 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006e8:	83 f9 01             	cmp    $0x1,%ecx
  8006eb:	7e 15                	jle    800702 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f0:	8b 10                	mov    (%eax),%edx
  8006f2:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f5:	8d 40 08             	lea    0x8(%eax),%eax
  8006f8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006fb:	b8 10 00 00 00       	mov    $0x10,%eax
  800700:	eb 30                	jmp    800732 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800702:	85 c9                	test   %ecx,%ecx
  800704:	74 17                	je     80071d <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8b 10                	mov    (%eax),%edx
  80070b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800710:	8d 40 04             	lea    0x4(%eax),%eax
  800713:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800716:	b8 10 00 00 00       	mov    $0x10,%eax
  80071b:	eb 15                	jmp    800732 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80071d:	8b 45 14             	mov    0x14(%ebp),%eax
  800720:	8b 10                	mov    (%eax),%edx
  800722:	b9 00 00 00 00       	mov    $0x0,%ecx
  800727:	8d 40 04             	lea    0x4(%eax),%eax
  80072a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80072d:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800732:	83 ec 0c             	sub    $0xc,%esp
  800735:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800739:	57                   	push   %edi
  80073a:	ff 75 e0             	pushl  -0x20(%ebp)
  80073d:	50                   	push   %eax
  80073e:	51                   	push   %ecx
  80073f:	52                   	push   %edx
  800740:	89 da                	mov    %ebx,%edx
  800742:	89 f0                	mov    %esi,%eax
  800744:	e8 f1 fa ff ff       	call   80023a <printnum>
			break;
  800749:	83 c4 20             	add    $0x20,%esp
  80074c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80074f:	e9 f5 fb ff ff       	jmp    800349 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800754:	83 ec 08             	sub    $0x8,%esp
  800757:	53                   	push   %ebx
  800758:	52                   	push   %edx
  800759:	ff d6                	call   *%esi
			break;
  80075b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800761:	e9 e3 fb ff ff       	jmp    800349 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	53                   	push   %ebx
  80076a:	6a 25                	push   $0x25
  80076c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80076e:	83 c4 10             	add    $0x10,%esp
  800771:	eb 03                	jmp    800776 <vprintfmt+0x453>
  800773:	83 ef 01             	sub    $0x1,%edi
  800776:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80077a:	75 f7                	jne    800773 <vprintfmt+0x450>
  80077c:	e9 c8 fb ff ff       	jmp    800349 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800781:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800784:	5b                   	pop    %ebx
  800785:	5e                   	pop    %esi
  800786:	5f                   	pop    %edi
  800787:	5d                   	pop    %ebp
  800788:	c3                   	ret    

00800789 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	83 ec 18             	sub    $0x18,%esp
  80078f:	8b 45 08             	mov    0x8(%ebp),%eax
  800792:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800795:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800798:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80079c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80079f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	74 26                	je     8007d0 <vsnprintf+0x47>
  8007aa:	85 d2                	test   %edx,%edx
  8007ac:	7e 22                	jle    8007d0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ae:	ff 75 14             	pushl  0x14(%ebp)
  8007b1:	ff 75 10             	pushl  0x10(%ebp)
  8007b4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b7:	50                   	push   %eax
  8007b8:	68 e9 02 80 00       	push   $0x8002e9
  8007bd:	e8 61 fb ff ff       	call   800323 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007cb:	83 c4 10             	add    $0x10,%esp
  8007ce:	eb 05                	jmp    8007d5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007d5:	c9                   	leave  
  8007d6:	c3                   	ret    

008007d7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007dd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007e0:	50                   	push   %eax
  8007e1:	ff 75 10             	pushl  0x10(%ebp)
  8007e4:	ff 75 0c             	pushl  0xc(%ebp)
  8007e7:	ff 75 08             	pushl  0x8(%ebp)
  8007ea:	e8 9a ff ff ff       	call   800789 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ef:	c9                   	leave  
  8007f0:	c3                   	ret    

008007f1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fc:	eb 03                	jmp    800801 <strlen+0x10>
		n++;
  8007fe:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800801:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800805:	75 f7                	jne    8007fe <strlen+0xd>
		n++;
	return n;
}
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800812:	ba 00 00 00 00       	mov    $0x0,%edx
  800817:	eb 03                	jmp    80081c <strnlen+0x13>
		n++;
  800819:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081c:	39 c2                	cmp    %eax,%edx
  80081e:	74 08                	je     800828 <strnlen+0x1f>
  800820:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800824:	75 f3                	jne    800819 <strnlen+0x10>
  800826:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	53                   	push   %ebx
  80082e:	8b 45 08             	mov    0x8(%ebp),%eax
  800831:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800834:	89 c2                	mov    %eax,%edx
  800836:	83 c2 01             	add    $0x1,%edx
  800839:	83 c1 01             	add    $0x1,%ecx
  80083c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800840:	88 5a ff             	mov    %bl,-0x1(%edx)
  800843:	84 db                	test   %bl,%bl
  800845:	75 ef                	jne    800836 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800847:	5b                   	pop    %ebx
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	53                   	push   %ebx
  80084e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800851:	53                   	push   %ebx
  800852:	e8 9a ff ff ff       	call   8007f1 <strlen>
  800857:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80085a:	ff 75 0c             	pushl  0xc(%ebp)
  80085d:	01 d8                	add    %ebx,%eax
  80085f:	50                   	push   %eax
  800860:	e8 c5 ff ff ff       	call   80082a <strcpy>
	return dst;
}
  800865:	89 d8                	mov    %ebx,%eax
  800867:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086a:	c9                   	leave  
  80086b:	c3                   	ret    

0080086c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	56                   	push   %esi
  800870:	53                   	push   %ebx
  800871:	8b 75 08             	mov    0x8(%ebp),%esi
  800874:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800877:	89 f3                	mov    %esi,%ebx
  800879:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087c:	89 f2                	mov    %esi,%edx
  80087e:	eb 0f                	jmp    80088f <strncpy+0x23>
		*dst++ = *src;
  800880:	83 c2 01             	add    $0x1,%edx
  800883:	0f b6 01             	movzbl (%ecx),%eax
  800886:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800889:	80 39 01             	cmpb   $0x1,(%ecx)
  80088c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80088f:	39 da                	cmp    %ebx,%edx
  800891:	75 ed                	jne    800880 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800893:	89 f0                	mov    %esi,%eax
  800895:	5b                   	pop    %ebx
  800896:	5e                   	pop    %esi
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	56                   	push   %esi
  80089d:	53                   	push   %ebx
  80089e:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a4:	8b 55 10             	mov    0x10(%ebp),%edx
  8008a7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a9:	85 d2                	test   %edx,%edx
  8008ab:	74 21                	je     8008ce <strlcpy+0x35>
  8008ad:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008b1:	89 f2                	mov    %esi,%edx
  8008b3:	eb 09                	jmp    8008be <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008b5:	83 c2 01             	add    $0x1,%edx
  8008b8:	83 c1 01             	add    $0x1,%ecx
  8008bb:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008be:	39 c2                	cmp    %eax,%edx
  8008c0:	74 09                	je     8008cb <strlcpy+0x32>
  8008c2:	0f b6 19             	movzbl (%ecx),%ebx
  8008c5:	84 db                	test   %bl,%bl
  8008c7:	75 ec                	jne    8008b5 <strlcpy+0x1c>
  8008c9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008cb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ce:	29 f0                	sub    %esi,%eax
}
  8008d0:	5b                   	pop    %ebx
  8008d1:	5e                   	pop    %esi
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008da:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008dd:	eb 06                	jmp    8008e5 <strcmp+0x11>
		p++, q++;
  8008df:	83 c1 01             	add    $0x1,%ecx
  8008e2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008e5:	0f b6 01             	movzbl (%ecx),%eax
  8008e8:	84 c0                	test   %al,%al
  8008ea:	74 04                	je     8008f0 <strcmp+0x1c>
  8008ec:	3a 02                	cmp    (%edx),%al
  8008ee:	74 ef                	je     8008df <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f0:	0f b6 c0             	movzbl %al,%eax
  8008f3:	0f b6 12             	movzbl (%edx),%edx
  8008f6:	29 d0                	sub    %edx,%eax
}
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	53                   	push   %ebx
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	8b 55 0c             	mov    0xc(%ebp),%edx
  800904:	89 c3                	mov    %eax,%ebx
  800906:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800909:	eb 06                	jmp    800911 <strncmp+0x17>
		n--, p++, q++;
  80090b:	83 c0 01             	add    $0x1,%eax
  80090e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800911:	39 d8                	cmp    %ebx,%eax
  800913:	74 15                	je     80092a <strncmp+0x30>
  800915:	0f b6 08             	movzbl (%eax),%ecx
  800918:	84 c9                	test   %cl,%cl
  80091a:	74 04                	je     800920 <strncmp+0x26>
  80091c:	3a 0a                	cmp    (%edx),%cl
  80091e:	74 eb                	je     80090b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800920:	0f b6 00             	movzbl (%eax),%eax
  800923:	0f b6 12             	movzbl (%edx),%edx
  800926:	29 d0                	sub    %edx,%eax
  800928:	eb 05                	jmp    80092f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80092a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80092f:	5b                   	pop    %ebx
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093c:	eb 07                	jmp    800945 <strchr+0x13>
		if (*s == c)
  80093e:	38 ca                	cmp    %cl,%dl
  800940:	74 0f                	je     800951 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800942:	83 c0 01             	add    $0x1,%eax
  800945:	0f b6 10             	movzbl (%eax),%edx
  800948:	84 d2                	test   %dl,%dl
  80094a:	75 f2                	jne    80093e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80094c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80095d:	eb 03                	jmp    800962 <strfind+0xf>
  80095f:	83 c0 01             	add    $0x1,%eax
  800962:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800965:	38 ca                	cmp    %cl,%dl
  800967:	74 04                	je     80096d <strfind+0x1a>
  800969:	84 d2                	test   %dl,%dl
  80096b:	75 f2                	jne    80095f <strfind+0xc>
			break;
	return (char *) s;
}
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	57                   	push   %edi
  800973:	56                   	push   %esi
  800974:	53                   	push   %ebx
  800975:	8b 7d 08             	mov    0x8(%ebp),%edi
  800978:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80097b:	85 c9                	test   %ecx,%ecx
  80097d:	74 36                	je     8009b5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80097f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800985:	75 28                	jne    8009af <memset+0x40>
  800987:	f6 c1 03             	test   $0x3,%cl
  80098a:	75 23                	jne    8009af <memset+0x40>
		c &= 0xFF;
  80098c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800990:	89 d3                	mov    %edx,%ebx
  800992:	c1 e3 08             	shl    $0x8,%ebx
  800995:	89 d6                	mov    %edx,%esi
  800997:	c1 e6 18             	shl    $0x18,%esi
  80099a:	89 d0                	mov    %edx,%eax
  80099c:	c1 e0 10             	shl    $0x10,%eax
  80099f:	09 f0                	or     %esi,%eax
  8009a1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009a3:	89 d8                	mov    %ebx,%eax
  8009a5:	09 d0                	or     %edx,%eax
  8009a7:	c1 e9 02             	shr    $0x2,%ecx
  8009aa:	fc                   	cld    
  8009ab:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ad:	eb 06                	jmp    8009b5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b2:	fc                   	cld    
  8009b3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009b5:	89 f8                	mov    %edi,%eax
  8009b7:	5b                   	pop    %ebx
  8009b8:	5e                   	pop    %esi
  8009b9:	5f                   	pop    %edi
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	57                   	push   %edi
  8009c0:	56                   	push   %esi
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ca:	39 c6                	cmp    %eax,%esi
  8009cc:	73 35                	jae    800a03 <memmove+0x47>
  8009ce:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009d1:	39 d0                	cmp    %edx,%eax
  8009d3:	73 2e                	jae    800a03 <memmove+0x47>
		s += n;
		d += n;
  8009d5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d8:	89 d6                	mov    %edx,%esi
  8009da:	09 fe                	or     %edi,%esi
  8009dc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e2:	75 13                	jne    8009f7 <memmove+0x3b>
  8009e4:	f6 c1 03             	test   $0x3,%cl
  8009e7:	75 0e                	jne    8009f7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009e9:	83 ef 04             	sub    $0x4,%edi
  8009ec:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ef:	c1 e9 02             	shr    $0x2,%ecx
  8009f2:	fd                   	std    
  8009f3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f5:	eb 09                	jmp    800a00 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009f7:	83 ef 01             	sub    $0x1,%edi
  8009fa:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009fd:	fd                   	std    
  8009fe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a00:	fc                   	cld    
  800a01:	eb 1d                	jmp    800a20 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a03:	89 f2                	mov    %esi,%edx
  800a05:	09 c2                	or     %eax,%edx
  800a07:	f6 c2 03             	test   $0x3,%dl
  800a0a:	75 0f                	jne    800a1b <memmove+0x5f>
  800a0c:	f6 c1 03             	test   $0x3,%cl
  800a0f:	75 0a                	jne    800a1b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a11:	c1 e9 02             	shr    $0x2,%ecx
  800a14:	89 c7                	mov    %eax,%edi
  800a16:	fc                   	cld    
  800a17:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a19:	eb 05                	jmp    800a20 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a1b:	89 c7                	mov    %eax,%edi
  800a1d:	fc                   	cld    
  800a1e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a20:	5e                   	pop    %esi
  800a21:	5f                   	pop    %edi
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    

00800a24 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a27:	ff 75 10             	pushl  0x10(%ebp)
  800a2a:	ff 75 0c             	pushl  0xc(%ebp)
  800a2d:	ff 75 08             	pushl  0x8(%ebp)
  800a30:	e8 87 ff ff ff       	call   8009bc <memmove>
}
  800a35:	c9                   	leave  
  800a36:	c3                   	ret    

00800a37 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	56                   	push   %esi
  800a3b:	53                   	push   %ebx
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a42:	89 c6                	mov    %eax,%esi
  800a44:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a47:	eb 1a                	jmp    800a63 <memcmp+0x2c>
		if (*s1 != *s2)
  800a49:	0f b6 08             	movzbl (%eax),%ecx
  800a4c:	0f b6 1a             	movzbl (%edx),%ebx
  800a4f:	38 d9                	cmp    %bl,%cl
  800a51:	74 0a                	je     800a5d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a53:	0f b6 c1             	movzbl %cl,%eax
  800a56:	0f b6 db             	movzbl %bl,%ebx
  800a59:	29 d8                	sub    %ebx,%eax
  800a5b:	eb 0f                	jmp    800a6c <memcmp+0x35>
		s1++, s2++;
  800a5d:	83 c0 01             	add    $0x1,%eax
  800a60:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a63:	39 f0                	cmp    %esi,%eax
  800a65:	75 e2                	jne    800a49 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6c:	5b                   	pop    %ebx
  800a6d:	5e                   	pop    %esi
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	53                   	push   %ebx
  800a74:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a77:	89 c1                	mov    %eax,%ecx
  800a79:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a7c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a80:	eb 0a                	jmp    800a8c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a82:	0f b6 10             	movzbl (%eax),%edx
  800a85:	39 da                	cmp    %ebx,%edx
  800a87:	74 07                	je     800a90 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a89:	83 c0 01             	add    $0x1,%eax
  800a8c:	39 c8                	cmp    %ecx,%eax
  800a8e:	72 f2                	jb     800a82 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a90:	5b                   	pop    %ebx
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	57                   	push   %edi
  800a97:	56                   	push   %esi
  800a98:	53                   	push   %ebx
  800a99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a9f:	eb 03                	jmp    800aa4 <strtol+0x11>
		s++;
  800aa1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa4:	0f b6 01             	movzbl (%ecx),%eax
  800aa7:	3c 20                	cmp    $0x20,%al
  800aa9:	74 f6                	je     800aa1 <strtol+0xe>
  800aab:	3c 09                	cmp    $0x9,%al
  800aad:	74 f2                	je     800aa1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aaf:	3c 2b                	cmp    $0x2b,%al
  800ab1:	75 0a                	jne    800abd <strtol+0x2a>
		s++;
  800ab3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ab6:	bf 00 00 00 00       	mov    $0x0,%edi
  800abb:	eb 11                	jmp    800ace <strtol+0x3b>
  800abd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ac2:	3c 2d                	cmp    $0x2d,%al
  800ac4:	75 08                	jne    800ace <strtol+0x3b>
		s++, neg = 1;
  800ac6:	83 c1 01             	add    $0x1,%ecx
  800ac9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ace:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ad4:	75 15                	jne    800aeb <strtol+0x58>
  800ad6:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad9:	75 10                	jne    800aeb <strtol+0x58>
  800adb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800adf:	75 7c                	jne    800b5d <strtol+0xca>
		s += 2, base = 16;
  800ae1:	83 c1 02             	add    $0x2,%ecx
  800ae4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae9:	eb 16                	jmp    800b01 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aeb:	85 db                	test   %ebx,%ebx
  800aed:	75 12                	jne    800b01 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aef:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af4:	80 39 30             	cmpb   $0x30,(%ecx)
  800af7:	75 08                	jne    800b01 <strtol+0x6e>
		s++, base = 8;
  800af9:	83 c1 01             	add    $0x1,%ecx
  800afc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b01:	b8 00 00 00 00       	mov    $0x0,%eax
  800b06:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b09:	0f b6 11             	movzbl (%ecx),%edx
  800b0c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b0f:	89 f3                	mov    %esi,%ebx
  800b11:	80 fb 09             	cmp    $0x9,%bl
  800b14:	77 08                	ja     800b1e <strtol+0x8b>
			dig = *s - '0';
  800b16:	0f be d2             	movsbl %dl,%edx
  800b19:	83 ea 30             	sub    $0x30,%edx
  800b1c:	eb 22                	jmp    800b40 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b1e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b21:	89 f3                	mov    %esi,%ebx
  800b23:	80 fb 19             	cmp    $0x19,%bl
  800b26:	77 08                	ja     800b30 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b28:	0f be d2             	movsbl %dl,%edx
  800b2b:	83 ea 57             	sub    $0x57,%edx
  800b2e:	eb 10                	jmp    800b40 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b30:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b33:	89 f3                	mov    %esi,%ebx
  800b35:	80 fb 19             	cmp    $0x19,%bl
  800b38:	77 16                	ja     800b50 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b3a:	0f be d2             	movsbl %dl,%edx
  800b3d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b40:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b43:	7d 0b                	jge    800b50 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b45:	83 c1 01             	add    $0x1,%ecx
  800b48:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b4c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b4e:	eb b9                	jmp    800b09 <strtol+0x76>

	if (endptr)
  800b50:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b54:	74 0d                	je     800b63 <strtol+0xd0>
		*endptr = (char *) s;
  800b56:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b59:	89 0e                	mov    %ecx,(%esi)
  800b5b:	eb 06                	jmp    800b63 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b5d:	85 db                	test   %ebx,%ebx
  800b5f:	74 98                	je     800af9 <strtol+0x66>
  800b61:	eb 9e                	jmp    800b01 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b63:	89 c2                	mov    %eax,%edx
  800b65:	f7 da                	neg    %edx
  800b67:	85 ff                	test   %edi,%edi
  800b69:	0f 45 c2             	cmovne %edx,%eax
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b77:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b82:	89 c3                	mov    %eax,%ebx
  800b84:	89 c7                	mov    %eax,%edi
  800b86:	89 c6                	mov    %eax,%esi
  800b88:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b9f:	89 d1                	mov    %edx,%ecx
  800ba1:	89 d3                	mov    %edx,%ebx
  800ba3:	89 d7                	mov    %edx,%edi
  800ba5:	89 d6                	mov    %edx,%esi
  800ba7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bbc:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc4:	89 cb                	mov    %ecx,%ebx
  800bc6:	89 cf                	mov    %ecx,%edi
  800bc8:	89 ce                	mov    %ecx,%esi
  800bca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bcc:	85 c0                	test   %eax,%eax
  800bce:	7e 17                	jle    800be7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd0:	83 ec 0c             	sub    $0xc,%esp
  800bd3:	50                   	push   %eax
  800bd4:	6a 03                	push   $0x3
  800bd6:	68 1f 2a 80 00       	push   $0x802a1f
  800bdb:	6a 23                	push   $0x23
  800bdd:	68 3c 2a 80 00       	push   $0x802a3c
  800be2:	e8 66 f5 ff ff       	call   80014d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800be7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfa:	b8 02 00 00 00       	mov    $0x2,%eax
  800bff:	89 d1                	mov    %edx,%ecx
  800c01:	89 d3                	mov    %edx,%ebx
  800c03:	89 d7                	mov    %edx,%edi
  800c05:	89 d6                	mov    %edx,%esi
  800c07:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <sys_yield>:

void
sys_yield(void)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c14:	ba 00 00 00 00       	mov    $0x0,%edx
  800c19:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c1e:	89 d1                	mov    %edx,%ecx
  800c20:	89 d3                	mov    %edx,%ebx
  800c22:	89 d7                	mov    %edx,%edi
  800c24:	89 d6                	mov    %edx,%esi
  800c26:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c36:	be 00 00 00 00       	mov    $0x0,%esi
  800c3b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c43:	8b 55 08             	mov    0x8(%ebp),%edx
  800c46:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c49:	89 f7                	mov    %esi,%edi
  800c4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4d:	85 c0                	test   %eax,%eax
  800c4f:	7e 17                	jle    800c68 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c51:	83 ec 0c             	sub    $0xc,%esp
  800c54:	50                   	push   %eax
  800c55:	6a 04                	push   $0x4
  800c57:	68 1f 2a 80 00       	push   $0x802a1f
  800c5c:	6a 23                	push   $0x23
  800c5e:	68 3c 2a 80 00       	push   $0x802a3c
  800c63:	e8 e5 f4 ff ff       	call   80014d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	53                   	push   %ebx
  800c76:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c79:	b8 05 00 00 00       	mov    $0x5,%eax
  800c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c81:	8b 55 08             	mov    0x8(%ebp),%edx
  800c84:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c87:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c8a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8f:	85 c0                	test   %eax,%eax
  800c91:	7e 17                	jle    800caa <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c93:	83 ec 0c             	sub    $0xc,%esp
  800c96:	50                   	push   %eax
  800c97:	6a 05                	push   $0x5
  800c99:	68 1f 2a 80 00       	push   $0x802a1f
  800c9e:	6a 23                	push   $0x23
  800ca0:	68 3c 2a 80 00       	push   $0x802a3c
  800ca5:	e8 a3 f4 ff ff       	call   80014d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800caa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    

00800cb2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	57                   	push   %edi
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
  800cb8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc0:	b8 06 00 00 00       	mov    $0x6,%eax
  800cc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccb:	89 df                	mov    %ebx,%edi
  800ccd:	89 de                	mov    %ebx,%esi
  800ccf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd1:	85 c0                	test   %eax,%eax
  800cd3:	7e 17                	jle    800cec <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd5:	83 ec 0c             	sub    $0xc,%esp
  800cd8:	50                   	push   %eax
  800cd9:	6a 06                	push   $0x6
  800cdb:	68 1f 2a 80 00       	push   $0x802a1f
  800ce0:	6a 23                	push   $0x23
  800ce2:	68 3c 2a 80 00       	push   $0x802a3c
  800ce7:	e8 61 f4 ff ff       	call   80014d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d02:	b8 08 00 00 00       	mov    $0x8,%eax
  800d07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0d:	89 df                	mov    %ebx,%edi
  800d0f:	89 de                	mov    %ebx,%esi
  800d11:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d13:	85 c0                	test   %eax,%eax
  800d15:	7e 17                	jle    800d2e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d17:	83 ec 0c             	sub    $0xc,%esp
  800d1a:	50                   	push   %eax
  800d1b:	6a 08                	push   $0x8
  800d1d:	68 1f 2a 80 00       	push   $0x802a1f
  800d22:	6a 23                	push   $0x23
  800d24:	68 3c 2a 80 00       	push   $0x802a3c
  800d29:	e8 1f f4 ff ff       	call   80014d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
  800d3c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d44:	b8 09 00 00 00       	mov    $0x9,%eax
  800d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4f:	89 df                	mov    %ebx,%edi
  800d51:	89 de                	mov    %ebx,%esi
  800d53:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d55:	85 c0                	test   %eax,%eax
  800d57:	7e 17                	jle    800d70 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d59:	83 ec 0c             	sub    $0xc,%esp
  800d5c:	50                   	push   %eax
  800d5d:	6a 09                	push   $0x9
  800d5f:	68 1f 2a 80 00       	push   $0x802a1f
  800d64:	6a 23                	push   $0x23
  800d66:	68 3c 2a 80 00       	push   $0x802a3c
  800d6b:	e8 dd f3 ff ff       	call   80014d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	57                   	push   %edi
  800d7c:	56                   	push   %esi
  800d7d:	53                   	push   %ebx
  800d7e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d81:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d86:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d91:	89 df                	mov    %ebx,%edi
  800d93:	89 de                	mov    %ebx,%esi
  800d95:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d97:	85 c0                	test   %eax,%eax
  800d99:	7e 17                	jle    800db2 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9b:	83 ec 0c             	sub    $0xc,%esp
  800d9e:	50                   	push   %eax
  800d9f:	6a 0a                	push   $0xa
  800da1:	68 1f 2a 80 00       	push   $0x802a1f
  800da6:	6a 23                	push   $0x23
  800da8:	68 3c 2a 80 00       	push   $0x802a3c
  800dad:	e8 9b f3 ff ff       	call   80014d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    

00800dba <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	57                   	push   %edi
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc0:	be 00 00 00 00       	mov    $0x0,%esi
  800dc5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5f                   	pop    %edi
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
  800de3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800deb:	b8 0d 00 00 00       	mov    $0xd,%eax
  800df0:	8b 55 08             	mov    0x8(%ebp),%edx
  800df3:	89 cb                	mov    %ecx,%ebx
  800df5:	89 cf                	mov    %ecx,%edi
  800df7:	89 ce                	mov    %ecx,%esi
  800df9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	7e 17                	jle    800e16 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dff:	83 ec 0c             	sub    $0xc,%esp
  800e02:	50                   	push   %eax
  800e03:	6a 0d                	push   $0xd
  800e05:	68 1f 2a 80 00       	push   $0x802a1f
  800e0a:	6a 23                	push   $0x23
  800e0c:	68 3c 2a 80 00       	push   $0x802a3c
  800e11:	e8 37 f3 ff ff       	call   80014d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e19:	5b                   	pop    %ebx
  800e1a:	5e                   	pop    %esi
  800e1b:	5f                   	pop    %edi
  800e1c:	5d                   	pop    %ebp
  800e1d:	c3                   	ret    

00800e1e <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
  800e21:	57                   	push   %edi
  800e22:	56                   	push   %esi
  800e23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e24:	ba 00 00 00 00       	mov    $0x0,%edx
  800e29:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e2e:	89 d1                	mov    %edx,%ecx
  800e30:	89 d3                	mov    %edx,%ebx
  800e32:	89 d7                	mov    %edx,%edi
  800e34:	89 d6                	mov    %edx,%esi
  800e36:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e38:	5b                   	pop    %ebx
  800e39:	5e                   	pop    %esi
  800e3a:	5f                   	pop    %edi
  800e3b:	5d                   	pop    %ebp
  800e3c:	c3                   	ret    

00800e3d <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
  800e40:	57                   	push   %edi
  800e41:	56                   	push   %esi
  800e42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e43:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e48:	b8 10 00 00 00       	mov    $0x10,%eax
  800e4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e50:	89 cb                	mov    %ecx,%ebx
  800e52:	89 cf                	mov    %ecx,%edi
  800e54:	89 ce                	mov    %ecx,%esi
  800e56:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	53                   	push   %ebx
  800e61:	83 ec 04             	sub    $0x4,%esp
  800e64:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e67:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800e69:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e6d:	74 2d                	je     800e9c <pgfault+0x3f>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800e6f:	89 d8                	mov    %ebx,%eax
  800e71:	c1 e8 16             	shr    $0x16,%eax
  800e74:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e7b:	a8 01                	test   $0x1,%al
  800e7d:	74 1d                	je     800e9c <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e7f:	89 d8                	mov    %ebx,%eax
  800e81:	c1 e8 0c             	shr    $0xc,%eax
  800e84:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800e8b:	f6 c2 01             	test   $0x1,%dl
  800e8e:	74 0c                	je     800e9c <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e90:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800e97:	f6 c4 08             	test   $0x8,%ah
  800e9a:	75 14                	jne    800eb0 <pgfault+0x53>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
	)) panic("Neither the fault is a write nor copy-on-write page.\n");
  800e9c:	83 ec 04             	sub    $0x4,%esp
  800e9f:	68 4c 2a 80 00       	push   $0x802a4c
  800ea4:	6a 1f                	push   $0x1f
  800ea6:	68 82 2a 80 00       	push   $0x802a82
  800eab:	e8 9d f2 ff ff       	call   80014d <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if((r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W)) < 0){
  800eb0:	83 ec 04             	sub    $0x4,%esp
  800eb3:	6a 07                	push   $0x7
  800eb5:	68 00 f0 7f 00       	push   $0x7ff000
  800eba:	6a 00                	push   $0x0
  800ebc:	e8 6c fd ff ff       	call   800c2d <sys_page_alloc>
  800ec1:	83 c4 10             	add    $0x10,%esp
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	79 12                	jns    800eda <pgfault+0x7d>
		 panic("sys_page_alloc: %e\n", r);
  800ec8:	50                   	push   %eax
  800ec9:	68 8d 2a 80 00       	push   $0x802a8d
  800ece:	6a 29                	push   $0x29
  800ed0:	68 82 2a 80 00       	push   $0x802a82
  800ed5:	e8 73 f2 ff ff       	call   80014d <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800eda:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800ee0:	83 ec 04             	sub    $0x4,%esp
  800ee3:	68 00 10 00 00       	push   $0x1000
  800ee8:	53                   	push   %ebx
  800ee9:	68 00 f0 7f 00       	push   $0x7ff000
  800eee:	e8 31 fb ff ff       	call   800a24 <memcpy>
	if ((r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  800ef3:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800efa:	53                   	push   %ebx
  800efb:	6a 00                	push   $0x0
  800efd:	68 00 f0 7f 00       	push   $0x7ff000
  800f02:	6a 00                	push   $0x0
  800f04:	e8 67 fd ff ff       	call   800c70 <sys_page_map>
  800f09:	83 c4 20             	add    $0x20,%esp
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	79 12                	jns    800f22 <pgfault+0xc5>
        panic("sys_page_map: %e\n", r);
  800f10:	50                   	push   %eax
  800f11:	68 a1 2a 80 00       	push   $0x802aa1
  800f16:	6a 2e                	push   $0x2e
  800f18:	68 82 2a 80 00       	push   $0x802a82
  800f1d:	e8 2b f2 ff ff       	call   80014d <_panic>
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  800f22:	83 ec 08             	sub    $0x8,%esp
  800f25:	68 00 f0 7f 00       	push   $0x7ff000
  800f2a:	6a 00                	push   $0x0
  800f2c:	e8 81 fd ff ff       	call   800cb2 <sys_page_unmap>
  800f31:	83 c4 10             	add    $0x10,%esp
  800f34:	85 c0                	test   %eax,%eax
  800f36:	79 12                	jns    800f4a <pgfault+0xed>
        panic("sys_page_unmap: %e\n", r);
  800f38:	50                   	push   %eax
  800f39:	68 b3 2a 80 00       	push   $0x802ab3
  800f3e:	6a 30                	push   $0x30
  800f40:	68 82 2a 80 00       	push   $0x802a82
  800f45:	e8 03 f2 ff ff       	call   80014d <_panic>
	//panic("pgfault not implemented");
}
  800f4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f4d:	c9                   	leave  
  800f4e:	c3                   	ret    

00800f4f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	57                   	push   %edi
  800f53:	56                   	push   %esi
  800f54:	53                   	push   %ebx
  800f55:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	envid_t cenvid;
    unsigned pn;
    int r;
	set_pgfault_handler(pgfault);
  800f58:	68 5d 0e 80 00       	push   $0x800e5d
  800f5d:	e8 eb 12 00 00       	call   80224d <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f62:	b8 07 00 00 00       	mov    $0x7,%eax
  800f67:	cd 30                	int    $0x30
  800f69:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((cenvid = sys_exofork()) < 0){
  800f6c:	83 c4 10             	add    $0x10,%esp
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	79 14                	jns    800f87 <fork+0x38>
		panic("sys_exofork failed");
  800f73:	83 ec 04             	sub    $0x4,%esp
  800f76:	68 c7 2a 80 00       	push   $0x802ac7
  800f7b:	6a 6f                	push   $0x6f
  800f7d:	68 82 2a 80 00       	push   $0x802a82
  800f82:	e8 c6 f1 ff ff       	call   80014d <_panic>
  800f87:	89 c7                	mov    %eax,%edi
		return cenvid;
	}
	if(cenvid>0){
  800f89:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f8d:	0f 8e 2b 01 00 00    	jle    8010be <fork+0x16f>
  800f93:	bb 00 08 00 00       	mov    $0x800,%ebx
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
  800f98:	89 d8                	mov    %ebx,%eax
  800f9a:	c1 e8 0a             	shr    $0xa,%eax
  800f9d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fa4:	a8 01                	test   $0x1,%al
  800fa6:	0f 84 bf 00 00 00    	je     80106b <fork+0x11c>
  800fac:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fb3:	a8 01                	test   $0x1,%al
  800fb5:	0f 84 b0 00 00 00    	je     80106b <fork+0x11c>
  800fbb:	89 de                	mov    %ebx,%esi
  800fbd:	c1 e6 0c             	shl    $0xc,%esi
{
	int r;

	// LAB 4: Your code here.
	void* vaddr=(void*)(pn*PGSIZE);
	if(uvpt[pn]&PTE_SHARE){
  800fc0:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fc7:	f6 c4 04             	test   $0x4,%ah
  800fca:	74 29                	je     800ff5 <fork+0xa6>
		if((r=sys_page_map(0,vaddr,envid,vaddr,uvpt[pn]&PTE_SYSCALL))<0)return r;
  800fcc:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fd3:	83 ec 0c             	sub    $0xc,%esp
  800fd6:	25 07 0e 00 00       	and    $0xe07,%eax
  800fdb:	50                   	push   %eax
  800fdc:	56                   	push   %esi
  800fdd:	57                   	push   %edi
  800fde:	56                   	push   %esi
  800fdf:	6a 00                	push   $0x0
  800fe1:	e8 8a fc ff ff       	call   800c70 <sys_page_map>
  800fe6:	83 c4 20             	add    $0x20,%esp
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff0:	0f 4f c2             	cmovg  %edx,%eax
  800ff3:	eb 72                	jmp    801067 <fork+0x118>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  800ff5:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ffc:	a8 02                	test   $0x2,%al
  800ffe:	75 0c                	jne    80100c <fork+0xbd>
  801000:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801007:	f6 c4 08             	test   $0x8,%ah
  80100a:	74 3f                	je     80104b <fork+0xfc>
		if ((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  80100c:	83 ec 0c             	sub    $0xc,%esp
  80100f:	68 05 08 00 00       	push   $0x805
  801014:	56                   	push   %esi
  801015:	57                   	push   %edi
  801016:	56                   	push   %esi
  801017:	6a 00                	push   $0x0
  801019:	e8 52 fc ff ff       	call   800c70 <sys_page_map>
  80101e:	83 c4 20             	add    $0x20,%esp
  801021:	85 c0                	test   %eax,%eax
  801023:	0f 88 b1 00 00 00    	js     8010da <fork+0x18b>
            return r;
        if ((r = sys_page_map(0, vaddr, 0, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  801029:	83 ec 0c             	sub    $0xc,%esp
  80102c:	68 05 08 00 00       	push   $0x805
  801031:	56                   	push   %esi
  801032:	6a 00                	push   $0x0
  801034:	56                   	push   %esi
  801035:	6a 00                	push   $0x0
  801037:	e8 34 fc ff ff       	call   800c70 <sys_page_map>
  80103c:	83 c4 20             	add    $0x20,%esp
  80103f:	85 c0                	test   %eax,%eax
  801041:	b9 00 00 00 00       	mov    $0x0,%ecx
  801046:	0f 4f c1             	cmovg  %ecx,%eax
  801049:	eb 1c                	jmp    801067 <fork+0x118>
            return r;
	}
	else if((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U)) < 0) {
  80104b:	83 ec 0c             	sub    $0xc,%esp
  80104e:	6a 05                	push   $0x5
  801050:	56                   	push   %esi
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	6a 00                	push   $0x0
  801055:	e8 16 fc ff ff       	call   800c70 <sys_page_map>
  80105a:	83 c4 20             	add    $0x20,%esp
  80105d:	85 c0                	test   %eax,%eax
  80105f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801064:	0f 4f c1             	cmovg  %ecx,%eax
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
  801067:	85 c0                	test   %eax,%eax
  801069:	78 6f                	js     8010da <fork+0x18b>
	if ((cenvid = sys_exofork()) < 0){
		panic("sys_exofork failed");
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  80106b:	83 c3 01             	add    $0x1,%ebx
  80106e:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801074:	0f 85 1e ff ff ff    	jne    800f98 <fork+0x49>
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
                    return r;
		}
		if ((r = sys_page_alloc(cenvid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  80107a:	83 ec 04             	sub    $0x4,%esp
  80107d:	6a 07                	push   $0x7
  80107f:	68 00 f0 bf ee       	push   $0xeebff000
  801084:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801087:	57                   	push   %edi
  801088:	e8 a0 fb ff ff       	call   800c2d <sys_page_alloc>
  80108d:	83 c4 10             	add    $0x10,%esp
  801090:	85 c0                	test   %eax,%eax
  801092:	78 46                	js     8010da <fork+0x18b>
            return r;
		extern void _pgfault_upcall(void);
		if ((r = sys_env_set_pgfault_upcall(cenvid, _pgfault_upcall)) < 0)
  801094:	83 ec 08             	sub    $0x8,%esp
  801097:	68 b0 22 80 00       	push   $0x8022b0
  80109c:	57                   	push   %edi
  80109d:	e8 d6 fc ff ff       	call   800d78 <sys_env_set_pgfault_upcall>
  8010a2:	83 c4 10             	add    $0x10,%esp
  8010a5:	85 c0                	test   %eax,%eax
  8010a7:	78 31                	js     8010da <fork+0x18b>
            return r;
		if ((r = sys_env_set_status(cenvid, ENV_RUNNABLE)) < 0)
  8010a9:	83 ec 08             	sub    $0x8,%esp
  8010ac:	6a 02                	push   $0x2
  8010ae:	57                   	push   %edi
  8010af:	e8 40 fc ff ff       	call   800cf4 <sys_env_set_status>
  8010b4:	83 c4 10             	add    $0x10,%esp
            return r;
        return cenvid;
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	0f 49 c7             	cmovns %edi,%eax
  8010bc:	eb 1c                	jmp    8010da <fork+0x18b>
	}
	else {
		thisenv = &envs[ENVX(sys_getenvid())];
  8010be:	e8 2c fb ff ff       	call   800bef <sys_getenvid>
  8010c3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010c8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010cb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010d0:	a3 0c 40 80 00       	mov    %eax,0x80400c
		return 0;
  8010d5:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//panic("fork not implemented");
	
}
  8010da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010dd:	5b                   	pop    %ebx
  8010de:	5e                   	pop    %esi
  8010df:	5f                   	pop    %edi
  8010e0:	5d                   	pop    %ebp
  8010e1:	c3                   	ret    

008010e2 <sfork>:

// Challenge!
int
sfork(void)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010e8:	68 da 2a 80 00       	push   $0x802ada
  8010ed:	68 8d 00 00 00       	push   $0x8d
  8010f2:	68 82 2a 80 00       	push   $0x802a82
  8010f7:	e8 51 f0 ff ff       	call   80014d <_panic>

008010fc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801102:	05 00 00 00 30       	add    $0x30000000,%eax
  801107:	c1 e8 0c             	shr    $0xc,%eax
}
  80110a:	5d                   	pop    %ebp
  80110b:	c3                   	ret    

0080110c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80110f:	8b 45 08             	mov    0x8(%ebp),%eax
  801112:	05 00 00 00 30       	add    $0x30000000,%eax
  801117:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80111c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801121:	5d                   	pop    %ebp
  801122:	c3                   	ret    

00801123 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801129:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80112e:	89 c2                	mov    %eax,%edx
  801130:	c1 ea 16             	shr    $0x16,%edx
  801133:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80113a:	f6 c2 01             	test   $0x1,%dl
  80113d:	74 11                	je     801150 <fd_alloc+0x2d>
  80113f:	89 c2                	mov    %eax,%edx
  801141:	c1 ea 0c             	shr    $0xc,%edx
  801144:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80114b:	f6 c2 01             	test   $0x1,%dl
  80114e:	75 09                	jne    801159 <fd_alloc+0x36>
			*fd_store = fd;
  801150:	89 01                	mov    %eax,(%ecx)
			return 0;
  801152:	b8 00 00 00 00       	mov    $0x0,%eax
  801157:	eb 17                	jmp    801170 <fd_alloc+0x4d>
  801159:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80115e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801163:	75 c9                	jne    80112e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801165:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80116b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801170:	5d                   	pop    %ebp
  801171:	c3                   	ret    

00801172 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
  801175:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801178:	83 f8 1f             	cmp    $0x1f,%eax
  80117b:	77 36                	ja     8011b3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80117d:	c1 e0 0c             	shl    $0xc,%eax
  801180:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801185:	89 c2                	mov    %eax,%edx
  801187:	c1 ea 16             	shr    $0x16,%edx
  80118a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801191:	f6 c2 01             	test   $0x1,%dl
  801194:	74 24                	je     8011ba <fd_lookup+0x48>
  801196:	89 c2                	mov    %eax,%edx
  801198:	c1 ea 0c             	shr    $0xc,%edx
  80119b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011a2:	f6 c2 01             	test   $0x1,%dl
  8011a5:	74 1a                	je     8011c1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011aa:	89 02                	mov    %eax,(%edx)
	return 0;
  8011ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b1:	eb 13                	jmp    8011c6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b8:	eb 0c                	jmp    8011c6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011bf:	eb 05                	jmp    8011c6 <fd_lookup+0x54>
  8011c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    

008011c8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	83 ec 08             	sub    $0x8,%esp
  8011ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d1:	ba 70 2b 80 00       	mov    $0x802b70,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011d6:	eb 13                	jmp    8011eb <dev_lookup+0x23>
  8011d8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011db:	39 08                	cmp    %ecx,(%eax)
  8011dd:	75 0c                	jne    8011eb <dev_lookup+0x23>
			*dev = devtab[i];
  8011df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e9:	eb 2e                	jmp    801219 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011eb:	8b 02                	mov    (%edx),%eax
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	75 e7                	jne    8011d8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011f1:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8011f6:	8b 40 48             	mov    0x48(%eax),%eax
  8011f9:	83 ec 04             	sub    $0x4,%esp
  8011fc:	51                   	push   %ecx
  8011fd:	50                   	push   %eax
  8011fe:	68 f0 2a 80 00       	push   $0x802af0
  801203:	e8 1e f0 ff ff       	call   800226 <cprintf>
	*dev = 0;
  801208:	8b 45 0c             	mov    0xc(%ebp),%eax
  80120b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801211:	83 c4 10             	add    $0x10,%esp
  801214:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801219:	c9                   	leave  
  80121a:	c3                   	ret    

0080121b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	56                   	push   %esi
  80121f:	53                   	push   %ebx
  801220:	83 ec 10             	sub    $0x10,%esp
  801223:	8b 75 08             	mov    0x8(%ebp),%esi
  801226:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801229:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122c:	50                   	push   %eax
  80122d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801233:	c1 e8 0c             	shr    $0xc,%eax
  801236:	50                   	push   %eax
  801237:	e8 36 ff ff ff       	call   801172 <fd_lookup>
  80123c:	83 c4 08             	add    $0x8,%esp
  80123f:	85 c0                	test   %eax,%eax
  801241:	78 05                	js     801248 <fd_close+0x2d>
	    || fd != fd2)
  801243:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801246:	74 0c                	je     801254 <fd_close+0x39>
		return (must_exist ? r : 0);
  801248:	84 db                	test   %bl,%bl
  80124a:	ba 00 00 00 00       	mov    $0x0,%edx
  80124f:	0f 44 c2             	cmove  %edx,%eax
  801252:	eb 41                	jmp    801295 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801254:	83 ec 08             	sub    $0x8,%esp
  801257:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125a:	50                   	push   %eax
  80125b:	ff 36                	pushl  (%esi)
  80125d:	e8 66 ff ff ff       	call   8011c8 <dev_lookup>
  801262:	89 c3                	mov    %eax,%ebx
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	85 c0                	test   %eax,%eax
  801269:	78 1a                	js     801285 <fd_close+0x6a>
		if (dev->dev_close)
  80126b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801271:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801276:	85 c0                	test   %eax,%eax
  801278:	74 0b                	je     801285 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80127a:	83 ec 0c             	sub    $0xc,%esp
  80127d:	56                   	push   %esi
  80127e:	ff d0                	call   *%eax
  801280:	89 c3                	mov    %eax,%ebx
  801282:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801285:	83 ec 08             	sub    $0x8,%esp
  801288:	56                   	push   %esi
  801289:	6a 00                	push   $0x0
  80128b:	e8 22 fa ff ff       	call   800cb2 <sys_page_unmap>
	return r;
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	89 d8                	mov    %ebx,%eax
}
  801295:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801298:	5b                   	pop    %ebx
  801299:	5e                   	pop    %esi
  80129a:	5d                   	pop    %ebp
  80129b:	c3                   	ret    

0080129c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a5:	50                   	push   %eax
  8012a6:	ff 75 08             	pushl  0x8(%ebp)
  8012a9:	e8 c4 fe ff ff       	call   801172 <fd_lookup>
  8012ae:	83 c4 08             	add    $0x8,%esp
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	78 10                	js     8012c5 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012b5:	83 ec 08             	sub    $0x8,%esp
  8012b8:	6a 01                	push   $0x1
  8012ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8012bd:	e8 59 ff ff ff       	call   80121b <fd_close>
  8012c2:	83 c4 10             	add    $0x10,%esp
}
  8012c5:	c9                   	leave  
  8012c6:	c3                   	ret    

008012c7 <close_all>:

void
close_all(void)
{
  8012c7:	55                   	push   %ebp
  8012c8:	89 e5                	mov    %esp,%ebp
  8012ca:	53                   	push   %ebx
  8012cb:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ce:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012d3:	83 ec 0c             	sub    $0xc,%esp
  8012d6:	53                   	push   %ebx
  8012d7:	e8 c0 ff ff ff       	call   80129c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012dc:	83 c3 01             	add    $0x1,%ebx
  8012df:	83 c4 10             	add    $0x10,%esp
  8012e2:	83 fb 20             	cmp    $0x20,%ebx
  8012e5:	75 ec                	jne    8012d3 <close_all+0xc>
		close(i);
}
  8012e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ea:	c9                   	leave  
  8012eb:	c3                   	ret    

008012ec <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012ec:	55                   	push   %ebp
  8012ed:	89 e5                	mov    %esp,%ebp
  8012ef:	57                   	push   %edi
  8012f0:	56                   	push   %esi
  8012f1:	53                   	push   %ebx
  8012f2:	83 ec 2c             	sub    $0x2c,%esp
  8012f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012f8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012fb:	50                   	push   %eax
  8012fc:	ff 75 08             	pushl  0x8(%ebp)
  8012ff:	e8 6e fe ff ff       	call   801172 <fd_lookup>
  801304:	83 c4 08             	add    $0x8,%esp
  801307:	85 c0                	test   %eax,%eax
  801309:	0f 88 c1 00 00 00    	js     8013d0 <dup+0xe4>
		return r;
	close(newfdnum);
  80130f:	83 ec 0c             	sub    $0xc,%esp
  801312:	56                   	push   %esi
  801313:	e8 84 ff ff ff       	call   80129c <close>

	newfd = INDEX2FD(newfdnum);
  801318:	89 f3                	mov    %esi,%ebx
  80131a:	c1 e3 0c             	shl    $0xc,%ebx
  80131d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801323:	83 c4 04             	add    $0x4,%esp
  801326:	ff 75 e4             	pushl  -0x1c(%ebp)
  801329:	e8 de fd ff ff       	call   80110c <fd2data>
  80132e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801330:	89 1c 24             	mov    %ebx,(%esp)
  801333:	e8 d4 fd ff ff       	call   80110c <fd2data>
  801338:	83 c4 10             	add    $0x10,%esp
  80133b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80133e:	89 f8                	mov    %edi,%eax
  801340:	c1 e8 16             	shr    $0x16,%eax
  801343:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80134a:	a8 01                	test   $0x1,%al
  80134c:	74 37                	je     801385 <dup+0x99>
  80134e:	89 f8                	mov    %edi,%eax
  801350:	c1 e8 0c             	shr    $0xc,%eax
  801353:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80135a:	f6 c2 01             	test   $0x1,%dl
  80135d:	74 26                	je     801385 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80135f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801366:	83 ec 0c             	sub    $0xc,%esp
  801369:	25 07 0e 00 00       	and    $0xe07,%eax
  80136e:	50                   	push   %eax
  80136f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801372:	6a 00                	push   $0x0
  801374:	57                   	push   %edi
  801375:	6a 00                	push   $0x0
  801377:	e8 f4 f8 ff ff       	call   800c70 <sys_page_map>
  80137c:	89 c7                	mov    %eax,%edi
  80137e:	83 c4 20             	add    $0x20,%esp
  801381:	85 c0                	test   %eax,%eax
  801383:	78 2e                	js     8013b3 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801385:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801388:	89 d0                	mov    %edx,%eax
  80138a:	c1 e8 0c             	shr    $0xc,%eax
  80138d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801394:	83 ec 0c             	sub    $0xc,%esp
  801397:	25 07 0e 00 00       	and    $0xe07,%eax
  80139c:	50                   	push   %eax
  80139d:	53                   	push   %ebx
  80139e:	6a 00                	push   $0x0
  8013a0:	52                   	push   %edx
  8013a1:	6a 00                	push   $0x0
  8013a3:	e8 c8 f8 ff ff       	call   800c70 <sys_page_map>
  8013a8:	89 c7                	mov    %eax,%edi
  8013aa:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013ad:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013af:	85 ff                	test   %edi,%edi
  8013b1:	79 1d                	jns    8013d0 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013b3:	83 ec 08             	sub    $0x8,%esp
  8013b6:	53                   	push   %ebx
  8013b7:	6a 00                	push   $0x0
  8013b9:	e8 f4 f8 ff ff       	call   800cb2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013be:	83 c4 08             	add    $0x8,%esp
  8013c1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c4:	6a 00                	push   $0x0
  8013c6:	e8 e7 f8 ff ff       	call   800cb2 <sys_page_unmap>
	return r;
  8013cb:	83 c4 10             	add    $0x10,%esp
  8013ce:	89 f8                	mov    %edi,%eax
}
  8013d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d3:	5b                   	pop    %ebx
  8013d4:	5e                   	pop    %esi
  8013d5:	5f                   	pop    %edi
  8013d6:	5d                   	pop    %ebp
  8013d7:	c3                   	ret    

008013d8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	53                   	push   %ebx
  8013dc:	83 ec 14             	sub    $0x14,%esp
  8013df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e5:	50                   	push   %eax
  8013e6:	53                   	push   %ebx
  8013e7:	e8 86 fd ff ff       	call   801172 <fd_lookup>
  8013ec:	83 c4 08             	add    $0x8,%esp
  8013ef:	89 c2                	mov    %eax,%edx
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	78 6d                	js     801462 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f5:	83 ec 08             	sub    $0x8,%esp
  8013f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fb:	50                   	push   %eax
  8013fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ff:	ff 30                	pushl  (%eax)
  801401:	e8 c2 fd ff ff       	call   8011c8 <dev_lookup>
  801406:	83 c4 10             	add    $0x10,%esp
  801409:	85 c0                	test   %eax,%eax
  80140b:	78 4c                	js     801459 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80140d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801410:	8b 42 08             	mov    0x8(%edx),%eax
  801413:	83 e0 03             	and    $0x3,%eax
  801416:	83 f8 01             	cmp    $0x1,%eax
  801419:	75 21                	jne    80143c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80141b:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801420:	8b 40 48             	mov    0x48(%eax),%eax
  801423:	83 ec 04             	sub    $0x4,%esp
  801426:	53                   	push   %ebx
  801427:	50                   	push   %eax
  801428:	68 34 2b 80 00       	push   $0x802b34
  80142d:	e8 f4 ed ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  801432:	83 c4 10             	add    $0x10,%esp
  801435:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80143a:	eb 26                	jmp    801462 <read+0x8a>
	}
	if (!dev->dev_read)
  80143c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143f:	8b 40 08             	mov    0x8(%eax),%eax
  801442:	85 c0                	test   %eax,%eax
  801444:	74 17                	je     80145d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801446:	83 ec 04             	sub    $0x4,%esp
  801449:	ff 75 10             	pushl  0x10(%ebp)
  80144c:	ff 75 0c             	pushl  0xc(%ebp)
  80144f:	52                   	push   %edx
  801450:	ff d0                	call   *%eax
  801452:	89 c2                	mov    %eax,%edx
  801454:	83 c4 10             	add    $0x10,%esp
  801457:	eb 09                	jmp    801462 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801459:	89 c2                	mov    %eax,%edx
  80145b:	eb 05                	jmp    801462 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80145d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801462:	89 d0                	mov    %edx,%eax
  801464:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801467:	c9                   	leave  
  801468:	c3                   	ret    

00801469 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
  80146c:	57                   	push   %edi
  80146d:	56                   	push   %esi
  80146e:	53                   	push   %ebx
  80146f:	83 ec 0c             	sub    $0xc,%esp
  801472:	8b 7d 08             	mov    0x8(%ebp),%edi
  801475:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801478:	bb 00 00 00 00       	mov    $0x0,%ebx
  80147d:	eb 21                	jmp    8014a0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80147f:	83 ec 04             	sub    $0x4,%esp
  801482:	89 f0                	mov    %esi,%eax
  801484:	29 d8                	sub    %ebx,%eax
  801486:	50                   	push   %eax
  801487:	89 d8                	mov    %ebx,%eax
  801489:	03 45 0c             	add    0xc(%ebp),%eax
  80148c:	50                   	push   %eax
  80148d:	57                   	push   %edi
  80148e:	e8 45 ff ff ff       	call   8013d8 <read>
		if (m < 0)
  801493:	83 c4 10             	add    $0x10,%esp
  801496:	85 c0                	test   %eax,%eax
  801498:	78 10                	js     8014aa <readn+0x41>
			return m;
		if (m == 0)
  80149a:	85 c0                	test   %eax,%eax
  80149c:	74 0a                	je     8014a8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80149e:	01 c3                	add    %eax,%ebx
  8014a0:	39 f3                	cmp    %esi,%ebx
  8014a2:	72 db                	jb     80147f <readn+0x16>
  8014a4:	89 d8                	mov    %ebx,%eax
  8014a6:	eb 02                	jmp    8014aa <readn+0x41>
  8014a8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ad:	5b                   	pop    %ebx
  8014ae:	5e                   	pop    %esi
  8014af:	5f                   	pop    %edi
  8014b0:	5d                   	pop    %ebp
  8014b1:	c3                   	ret    

008014b2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014b2:	55                   	push   %ebp
  8014b3:	89 e5                	mov    %esp,%ebp
  8014b5:	53                   	push   %ebx
  8014b6:	83 ec 14             	sub    $0x14,%esp
  8014b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014bf:	50                   	push   %eax
  8014c0:	53                   	push   %ebx
  8014c1:	e8 ac fc ff ff       	call   801172 <fd_lookup>
  8014c6:	83 c4 08             	add    $0x8,%esp
  8014c9:	89 c2                	mov    %eax,%edx
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	78 68                	js     801537 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cf:	83 ec 08             	sub    $0x8,%esp
  8014d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d5:	50                   	push   %eax
  8014d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d9:	ff 30                	pushl  (%eax)
  8014db:	e8 e8 fc ff ff       	call   8011c8 <dev_lookup>
  8014e0:	83 c4 10             	add    $0x10,%esp
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	78 47                	js     80152e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014ee:	75 21                	jne    801511 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f0:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8014f5:	8b 40 48             	mov    0x48(%eax),%eax
  8014f8:	83 ec 04             	sub    $0x4,%esp
  8014fb:	53                   	push   %ebx
  8014fc:	50                   	push   %eax
  8014fd:	68 50 2b 80 00       	push   $0x802b50
  801502:	e8 1f ed ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  801507:	83 c4 10             	add    $0x10,%esp
  80150a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80150f:	eb 26                	jmp    801537 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801511:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801514:	8b 52 0c             	mov    0xc(%edx),%edx
  801517:	85 d2                	test   %edx,%edx
  801519:	74 17                	je     801532 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80151b:	83 ec 04             	sub    $0x4,%esp
  80151e:	ff 75 10             	pushl  0x10(%ebp)
  801521:	ff 75 0c             	pushl  0xc(%ebp)
  801524:	50                   	push   %eax
  801525:	ff d2                	call   *%edx
  801527:	89 c2                	mov    %eax,%edx
  801529:	83 c4 10             	add    $0x10,%esp
  80152c:	eb 09                	jmp    801537 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152e:	89 c2                	mov    %eax,%edx
  801530:	eb 05                	jmp    801537 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801532:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801537:	89 d0                	mov    %edx,%eax
  801539:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153c:	c9                   	leave  
  80153d:	c3                   	ret    

0080153e <seek>:

int
seek(int fdnum, off_t offset)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801544:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801547:	50                   	push   %eax
  801548:	ff 75 08             	pushl  0x8(%ebp)
  80154b:	e8 22 fc ff ff       	call   801172 <fd_lookup>
  801550:	83 c4 08             	add    $0x8,%esp
  801553:	85 c0                	test   %eax,%eax
  801555:	78 0e                	js     801565 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801557:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80155a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80155d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801560:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801565:	c9                   	leave  
  801566:	c3                   	ret    

00801567 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801567:	55                   	push   %ebp
  801568:	89 e5                	mov    %esp,%ebp
  80156a:	53                   	push   %ebx
  80156b:	83 ec 14             	sub    $0x14,%esp
  80156e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801571:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801574:	50                   	push   %eax
  801575:	53                   	push   %ebx
  801576:	e8 f7 fb ff ff       	call   801172 <fd_lookup>
  80157b:	83 c4 08             	add    $0x8,%esp
  80157e:	89 c2                	mov    %eax,%edx
  801580:	85 c0                	test   %eax,%eax
  801582:	78 65                	js     8015e9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801584:	83 ec 08             	sub    $0x8,%esp
  801587:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158a:	50                   	push   %eax
  80158b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158e:	ff 30                	pushl  (%eax)
  801590:	e8 33 fc ff ff       	call   8011c8 <dev_lookup>
  801595:	83 c4 10             	add    $0x10,%esp
  801598:	85 c0                	test   %eax,%eax
  80159a:	78 44                	js     8015e0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80159c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015a3:	75 21                	jne    8015c6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015a5:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015aa:	8b 40 48             	mov    0x48(%eax),%eax
  8015ad:	83 ec 04             	sub    $0x4,%esp
  8015b0:	53                   	push   %ebx
  8015b1:	50                   	push   %eax
  8015b2:	68 10 2b 80 00       	push   $0x802b10
  8015b7:	e8 6a ec ff ff       	call   800226 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c4:	eb 23                	jmp    8015e9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c9:	8b 52 18             	mov    0x18(%edx),%edx
  8015cc:	85 d2                	test   %edx,%edx
  8015ce:	74 14                	je     8015e4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015d0:	83 ec 08             	sub    $0x8,%esp
  8015d3:	ff 75 0c             	pushl  0xc(%ebp)
  8015d6:	50                   	push   %eax
  8015d7:	ff d2                	call   *%edx
  8015d9:	89 c2                	mov    %eax,%edx
  8015db:	83 c4 10             	add    $0x10,%esp
  8015de:	eb 09                	jmp    8015e9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e0:	89 c2                	mov    %eax,%edx
  8015e2:	eb 05                	jmp    8015e9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015e4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015e9:	89 d0                	mov    %edx,%eax
  8015eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ee:	c9                   	leave  
  8015ef:	c3                   	ret    

008015f0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	53                   	push   %ebx
  8015f4:	83 ec 14             	sub    $0x14,%esp
  8015f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015fd:	50                   	push   %eax
  8015fe:	ff 75 08             	pushl  0x8(%ebp)
  801601:	e8 6c fb ff ff       	call   801172 <fd_lookup>
  801606:	83 c4 08             	add    $0x8,%esp
  801609:	89 c2                	mov    %eax,%edx
  80160b:	85 c0                	test   %eax,%eax
  80160d:	78 58                	js     801667 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160f:	83 ec 08             	sub    $0x8,%esp
  801612:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801615:	50                   	push   %eax
  801616:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801619:	ff 30                	pushl  (%eax)
  80161b:	e8 a8 fb ff ff       	call   8011c8 <dev_lookup>
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	85 c0                	test   %eax,%eax
  801625:	78 37                	js     80165e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801627:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80162e:	74 32                	je     801662 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801630:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801633:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80163a:	00 00 00 
	stat->st_isdir = 0;
  80163d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801644:	00 00 00 
	stat->st_dev = dev;
  801647:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80164d:	83 ec 08             	sub    $0x8,%esp
  801650:	53                   	push   %ebx
  801651:	ff 75 f0             	pushl  -0x10(%ebp)
  801654:	ff 50 14             	call   *0x14(%eax)
  801657:	89 c2                	mov    %eax,%edx
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	eb 09                	jmp    801667 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165e:	89 c2                	mov    %eax,%edx
  801660:	eb 05                	jmp    801667 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801662:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801667:	89 d0                	mov    %edx,%eax
  801669:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166c:	c9                   	leave  
  80166d:	c3                   	ret    

0080166e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	56                   	push   %esi
  801672:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801673:	83 ec 08             	sub    $0x8,%esp
  801676:	6a 00                	push   $0x0
  801678:	ff 75 08             	pushl  0x8(%ebp)
  80167b:	e8 e3 01 00 00       	call   801863 <open>
  801680:	89 c3                	mov    %eax,%ebx
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	85 c0                	test   %eax,%eax
  801687:	78 1b                	js     8016a4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801689:	83 ec 08             	sub    $0x8,%esp
  80168c:	ff 75 0c             	pushl  0xc(%ebp)
  80168f:	50                   	push   %eax
  801690:	e8 5b ff ff ff       	call   8015f0 <fstat>
  801695:	89 c6                	mov    %eax,%esi
	close(fd);
  801697:	89 1c 24             	mov    %ebx,(%esp)
  80169a:	e8 fd fb ff ff       	call   80129c <close>
	return r;
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	89 f0                	mov    %esi,%eax
}
  8016a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a7:	5b                   	pop    %ebx
  8016a8:	5e                   	pop    %esi
  8016a9:	5d                   	pop    %ebp
  8016aa:	c3                   	ret    

008016ab <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	56                   	push   %esi
  8016af:	53                   	push   %ebx
  8016b0:	89 c6                	mov    %eax,%esi
  8016b2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016b4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016bb:	75 12                	jne    8016cf <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016bd:	83 ec 0c             	sub    $0xc,%esp
  8016c0:	6a 01                	push   $0x1
  8016c2:	e8 ca 0c 00 00       	call   802391 <ipc_find_env>
  8016c7:	a3 00 40 80 00       	mov    %eax,0x804000
  8016cc:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016cf:	6a 07                	push   $0x7
  8016d1:	68 00 50 80 00       	push   $0x805000
  8016d6:	56                   	push   %esi
  8016d7:	ff 35 00 40 80 00    	pushl  0x804000
  8016dd:	e8 5b 0c 00 00       	call   80233d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016e2:	83 c4 0c             	add    $0xc,%esp
  8016e5:	6a 00                	push   $0x0
  8016e7:	53                   	push   %ebx
  8016e8:	6a 00                	push   $0x0
  8016ea:	e8 e5 0b 00 00       	call   8022d4 <ipc_recv>
}
  8016ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f2:	5b                   	pop    %ebx
  8016f3:	5e                   	pop    %esi
  8016f4:	5d                   	pop    %ebp
  8016f5:	c3                   	ret    

008016f6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801702:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801707:	8b 45 0c             	mov    0xc(%ebp),%eax
  80170a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80170f:	ba 00 00 00 00       	mov    $0x0,%edx
  801714:	b8 02 00 00 00       	mov    $0x2,%eax
  801719:	e8 8d ff ff ff       	call   8016ab <fsipc>
}
  80171e:	c9                   	leave  
  80171f:	c3                   	ret    

00801720 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801726:	8b 45 08             	mov    0x8(%ebp),%eax
  801729:	8b 40 0c             	mov    0xc(%eax),%eax
  80172c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801731:	ba 00 00 00 00       	mov    $0x0,%edx
  801736:	b8 06 00 00 00       	mov    $0x6,%eax
  80173b:	e8 6b ff ff ff       	call   8016ab <fsipc>
}
  801740:	c9                   	leave  
  801741:	c3                   	ret    

00801742 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	53                   	push   %ebx
  801746:	83 ec 04             	sub    $0x4,%esp
  801749:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80174c:	8b 45 08             	mov    0x8(%ebp),%eax
  80174f:	8b 40 0c             	mov    0xc(%eax),%eax
  801752:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801757:	ba 00 00 00 00       	mov    $0x0,%edx
  80175c:	b8 05 00 00 00       	mov    $0x5,%eax
  801761:	e8 45 ff ff ff       	call   8016ab <fsipc>
  801766:	85 c0                	test   %eax,%eax
  801768:	78 2c                	js     801796 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80176a:	83 ec 08             	sub    $0x8,%esp
  80176d:	68 00 50 80 00       	push   $0x805000
  801772:	53                   	push   %ebx
  801773:	e8 b2 f0 ff ff       	call   80082a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801778:	a1 80 50 80 00       	mov    0x805080,%eax
  80177d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801783:	a1 84 50 80 00       	mov    0x805084,%eax
  801788:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80178e:	83 c4 10             	add    $0x10,%esp
  801791:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801796:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801799:	c9                   	leave  
  80179a:	c3                   	ret    

0080179b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	83 ec 0c             	sub    $0xc,%esp
  8017a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017a9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017ae:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8017b4:	8b 52 0c             	mov    0xc(%edx),%edx
  8017b7:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017bd:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017c2:	50                   	push   %eax
  8017c3:	ff 75 0c             	pushl  0xc(%ebp)
  8017c6:	68 08 50 80 00       	push   $0x805008
  8017cb:	e8 ec f1 ff ff       	call   8009bc <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d5:	b8 04 00 00 00       	mov    $0x4,%eax
  8017da:	e8 cc fe ff ff       	call   8016ab <fsipc>
	//panic("devfile_write not implemented");
}
  8017df:	c9                   	leave  
  8017e0:	c3                   	ret    

008017e1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	56                   	push   %esi
  8017e5:	53                   	push   %ebx
  8017e6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ef:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017f4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ff:	b8 03 00 00 00       	mov    $0x3,%eax
  801804:	e8 a2 fe ff ff       	call   8016ab <fsipc>
  801809:	89 c3                	mov    %eax,%ebx
  80180b:	85 c0                	test   %eax,%eax
  80180d:	78 4b                	js     80185a <devfile_read+0x79>
		return r;
	assert(r <= n);
  80180f:	39 c6                	cmp    %eax,%esi
  801811:	73 16                	jae    801829 <devfile_read+0x48>
  801813:	68 84 2b 80 00       	push   $0x802b84
  801818:	68 8b 2b 80 00       	push   $0x802b8b
  80181d:	6a 7c                	push   $0x7c
  80181f:	68 a0 2b 80 00       	push   $0x802ba0
  801824:	e8 24 e9 ff ff       	call   80014d <_panic>
	assert(r <= PGSIZE);
  801829:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80182e:	7e 16                	jle    801846 <devfile_read+0x65>
  801830:	68 ab 2b 80 00       	push   $0x802bab
  801835:	68 8b 2b 80 00       	push   $0x802b8b
  80183a:	6a 7d                	push   $0x7d
  80183c:	68 a0 2b 80 00       	push   $0x802ba0
  801841:	e8 07 e9 ff ff       	call   80014d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801846:	83 ec 04             	sub    $0x4,%esp
  801849:	50                   	push   %eax
  80184a:	68 00 50 80 00       	push   $0x805000
  80184f:	ff 75 0c             	pushl  0xc(%ebp)
  801852:	e8 65 f1 ff ff       	call   8009bc <memmove>
	return r;
  801857:	83 c4 10             	add    $0x10,%esp
}
  80185a:	89 d8                	mov    %ebx,%eax
  80185c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80185f:	5b                   	pop    %ebx
  801860:	5e                   	pop    %esi
  801861:	5d                   	pop    %ebp
  801862:	c3                   	ret    

00801863 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	53                   	push   %ebx
  801867:	83 ec 20             	sub    $0x20,%esp
  80186a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80186d:	53                   	push   %ebx
  80186e:	e8 7e ef ff ff       	call   8007f1 <strlen>
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80187b:	7f 67                	jg     8018e4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80187d:	83 ec 0c             	sub    $0xc,%esp
  801880:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801883:	50                   	push   %eax
  801884:	e8 9a f8 ff ff       	call   801123 <fd_alloc>
  801889:	83 c4 10             	add    $0x10,%esp
		return r;
  80188c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80188e:	85 c0                	test   %eax,%eax
  801890:	78 57                	js     8018e9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801892:	83 ec 08             	sub    $0x8,%esp
  801895:	53                   	push   %ebx
  801896:	68 00 50 80 00       	push   $0x805000
  80189b:	e8 8a ef ff ff       	call   80082a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ab:	b8 01 00 00 00       	mov    $0x1,%eax
  8018b0:	e8 f6 fd ff ff       	call   8016ab <fsipc>
  8018b5:	89 c3                	mov    %eax,%ebx
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	79 14                	jns    8018d2 <open+0x6f>
		fd_close(fd, 0);
  8018be:	83 ec 08             	sub    $0x8,%esp
  8018c1:	6a 00                	push   $0x0
  8018c3:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c6:	e8 50 f9 ff ff       	call   80121b <fd_close>
		return r;
  8018cb:	83 c4 10             	add    $0x10,%esp
  8018ce:	89 da                	mov    %ebx,%edx
  8018d0:	eb 17                	jmp    8018e9 <open+0x86>
	}

	return fd2num(fd);
  8018d2:	83 ec 0c             	sub    $0xc,%esp
  8018d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d8:	e8 1f f8 ff ff       	call   8010fc <fd2num>
  8018dd:	89 c2                	mov    %eax,%edx
  8018df:	83 c4 10             	add    $0x10,%esp
  8018e2:	eb 05                	jmp    8018e9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018e4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018e9:	89 d0                	mov    %edx,%eax
  8018eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ee:	c9                   	leave  
  8018ef:	c3                   	ret    

008018f0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fb:	b8 08 00 00 00       	mov    $0x8,%eax
  801900:	e8 a6 fd ff ff       	call   8016ab <fsipc>
}
  801905:	c9                   	leave  
  801906:	c3                   	ret    

00801907 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80190d:	68 b7 2b 80 00       	push   $0x802bb7
  801912:	ff 75 0c             	pushl  0xc(%ebp)
  801915:	e8 10 ef ff ff       	call   80082a <strcpy>
	return 0;
}
  80191a:	b8 00 00 00 00       	mov    $0x0,%eax
  80191f:	c9                   	leave  
  801920:	c3                   	ret    

00801921 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	53                   	push   %ebx
  801925:	83 ec 10             	sub    $0x10,%esp
  801928:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80192b:	53                   	push   %ebx
  80192c:	e8 99 0a 00 00       	call   8023ca <pageref>
  801931:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801934:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801939:	83 f8 01             	cmp    $0x1,%eax
  80193c:	75 10                	jne    80194e <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80193e:	83 ec 0c             	sub    $0xc,%esp
  801941:	ff 73 0c             	pushl  0xc(%ebx)
  801944:	e8 c0 02 00 00       	call   801c09 <nsipc_close>
  801949:	89 c2                	mov    %eax,%edx
  80194b:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80194e:	89 d0                	mov    %edx,%eax
  801950:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801953:	c9                   	leave  
  801954:	c3                   	ret    

00801955 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80195b:	6a 00                	push   $0x0
  80195d:	ff 75 10             	pushl  0x10(%ebp)
  801960:	ff 75 0c             	pushl  0xc(%ebp)
  801963:	8b 45 08             	mov    0x8(%ebp),%eax
  801966:	ff 70 0c             	pushl  0xc(%eax)
  801969:	e8 78 03 00 00       	call   801ce6 <nsipc_send>
}
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    

00801970 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801976:	6a 00                	push   $0x0
  801978:	ff 75 10             	pushl  0x10(%ebp)
  80197b:	ff 75 0c             	pushl  0xc(%ebp)
  80197e:	8b 45 08             	mov    0x8(%ebp),%eax
  801981:	ff 70 0c             	pushl  0xc(%eax)
  801984:	e8 f1 02 00 00       	call   801c7a <nsipc_recv>
}
  801989:	c9                   	leave  
  80198a:	c3                   	ret    

0080198b <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80198b:	55                   	push   %ebp
  80198c:	89 e5                	mov    %esp,%ebp
  80198e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801991:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801994:	52                   	push   %edx
  801995:	50                   	push   %eax
  801996:	e8 d7 f7 ff ff       	call   801172 <fd_lookup>
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	78 17                	js     8019b9 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8019a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a5:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8019ab:	39 08                	cmp    %ecx,(%eax)
  8019ad:	75 05                	jne    8019b4 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8019af:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b2:	eb 05                	jmp    8019b9 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8019b4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8019b9:	c9                   	leave  
  8019ba:	c3                   	ret    

008019bb <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	56                   	push   %esi
  8019bf:	53                   	push   %ebx
  8019c0:	83 ec 1c             	sub    $0x1c,%esp
  8019c3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8019c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c8:	50                   	push   %eax
  8019c9:	e8 55 f7 ff ff       	call   801123 <fd_alloc>
  8019ce:	89 c3                	mov    %eax,%ebx
  8019d0:	83 c4 10             	add    $0x10,%esp
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	78 1b                	js     8019f2 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8019d7:	83 ec 04             	sub    $0x4,%esp
  8019da:	68 07 04 00 00       	push   $0x407
  8019df:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e2:	6a 00                	push   $0x0
  8019e4:	e8 44 f2 ff ff       	call   800c2d <sys_page_alloc>
  8019e9:	89 c3                	mov    %eax,%ebx
  8019eb:	83 c4 10             	add    $0x10,%esp
  8019ee:	85 c0                	test   %eax,%eax
  8019f0:	79 10                	jns    801a02 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8019f2:	83 ec 0c             	sub    $0xc,%esp
  8019f5:	56                   	push   %esi
  8019f6:	e8 0e 02 00 00       	call   801c09 <nsipc_close>
		return r;
  8019fb:	83 c4 10             	add    $0x10,%esp
  8019fe:	89 d8                	mov    %ebx,%eax
  801a00:	eb 24                	jmp    801a26 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a02:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a10:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a17:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a1a:	83 ec 0c             	sub    $0xc,%esp
  801a1d:	50                   	push   %eax
  801a1e:	e8 d9 f6 ff ff       	call   8010fc <fd2num>
  801a23:	83 c4 10             	add    $0x10,%esp
}
  801a26:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a29:	5b                   	pop    %ebx
  801a2a:	5e                   	pop    %esi
  801a2b:	5d                   	pop    %ebp
  801a2c:	c3                   	ret    

00801a2d <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a33:	8b 45 08             	mov    0x8(%ebp),%eax
  801a36:	e8 50 ff ff ff       	call   80198b <fd2sockid>
		return r;
  801a3b:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a3d:	85 c0                	test   %eax,%eax
  801a3f:	78 1f                	js     801a60 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a41:	83 ec 04             	sub    $0x4,%esp
  801a44:	ff 75 10             	pushl  0x10(%ebp)
  801a47:	ff 75 0c             	pushl  0xc(%ebp)
  801a4a:	50                   	push   %eax
  801a4b:	e8 12 01 00 00       	call   801b62 <nsipc_accept>
  801a50:	83 c4 10             	add    $0x10,%esp
		return r;
  801a53:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a55:	85 c0                	test   %eax,%eax
  801a57:	78 07                	js     801a60 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801a59:	e8 5d ff ff ff       	call   8019bb <alloc_sockfd>
  801a5e:	89 c1                	mov    %eax,%ecx
}
  801a60:	89 c8                	mov    %ecx,%eax
  801a62:	c9                   	leave  
  801a63:	c3                   	ret    

00801a64 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
  801a67:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6d:	e8 19 ff ff ff       	call   80198b <fd2sockid>
  801a72:	85 c0                	test   %eax,%eax
  801a74:	78 12                	js     801a88 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801a76:	83 ec 04             	sub    $0x4,%esp
  801a79:	ff 75 10             	pushl  0x10(%ebp)
  801a7c:	ff 75 0c             	pushl  0xc(%ebp)
  801a7f:	50                   	push   %eax
  801a80:	e8 2d 01 00 00       	call   801bb2 <nsipc_bind>
  801a85:	83 c4 10             	add    $0x10,%esp
}
  801a88:	c9                   	leave  
  801a89:	c3                   	ret    

00801a8a <shutdown>:

int
shutdown(int s, int how)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a90:	8b 45 08             	mov    0x8(%ebp),%eax
  801a93:	e8 f3 fe ff ff       	call   80198b <fd2sockid>
  801a98:	85 c0                	test   %eax,%eax
  801a9a:	78 0f                	js     801aab <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801a9c:	83 ec 08             	sub    $0x8,%esp
  801a9f:	ff 75 0c             	pushl  0xc(%ebp)
  801aa2:	50                   	push   %eax
  801aa3:	e8 3f 01 00 00       	call   801be7 <nsipc_shutdown>
  801aa8:	83 c4 10             	add    $0x10,%esp
}
  801aab:	c9                   	leave  
  801aac:	c3                   	ret    

00801aad <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab6:	e8 d0 fe ff ff       	call   80198b <fd2sockid>
  801abb:	85 c0                	test   %eax,%eax
  801abd:	78 12                	js     801ad1 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801abf:	83 ec 04             	sub    $0x4,%esp
  801ac2:	ff 75 10             	pushl  0x10(%ebp)
  801ac5:	ff 75 0c             	pushl  0xc(%ebp)
  801ac8:	50                   	push   %eax
  801ac9:	e8 55 01 00 00       	call   801c23 <nsipc_connect>
  801ace:	83 c4 10             	add    $0x10,%esp
}
  801ad1:	c9                   	leave  
  801ad2:	c3                   	ret    

00801ad3 <listen>:

int
listen(int s, int backlog)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  801adc:	e8 aa fe ff ff       	call   80198b <fd2sockid>
  801ae1:	85 c0                	test   %eax,%eax
  801ae3:	78 0f                	js     801af4 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801ae5:	83 ec 08             	sub    $0x8,%esp
  801ae8:	ff 75 0c             	pushl  0xc(%ebp)
  801aeb:	50                   	push   %eax
  801aec:	e8 67 01 00 00       	call   801c58 <nsipc_listen>
  801af1:	83 c4 10             	add    $0x10,%esp
}
  801af4:	c9                   	leave  
  801af5:	c3                   	ret    

00801af6 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801afc:	ff 75 10             	pushl  0x10(%ebp)
  801aff:	ff 75 0c             	pushl  0xc(%ebp)
  801b02:	ff 75 08             	pushl  0x8(%ebp)
  801b05:	e8 3a 02 00 00       	call   801d44 <nsipc_socket>
  801b0a:	83 c4 10             	add    $0x10,%esp
  801b0d:	85 c0                	test   %eax,%eax
  801b0f:	78 05                	js     801b16 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b11:	e8 a5 fe ff ff       	call   8019bb <alloc_sockfd>
}
  801b16:	c9                   	leave  
  801b17:	c3                   	ret    

00801b18 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	53                   	push   %ebx
  801b1c:	83 ec 04             	sub    $0x4,%esp
  801b1f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b21:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801b28:	75 12                	jne    801b3c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b2a:	83 ec 0c             	sub    $0xc,%esp
  801b2d:	6a 02                	push   $0x2
  801b2f:	e8 5d 08 00 00       	call   802391 <ipc_find_env>
  801b34:	a3 04 40 80 00       	mov    %eax,0x804004
  801b39:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b3c:	6a 07                	push   $0x7
  801b3e:	68 00 60 80 00       	push   $0x806000
  801b43:	53                   	push   %ebx
  801b44:	ff 35 04 40 80 00    	pushl  0x804004
  801b4a:	e8 ee 07 00 00       	call   80233d <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b4f:	83 c4 0c             	add    $0xc,%esp
  801b52:	6a 00                	push   $0x0
  801b54:	6a 00                	push   $0x0
  801b56:	6a 00                	push   $0x0
  801b58:	e8 77 07 00 00       	call   8022d4 <ipc_recv>
}
  801b5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b60:	c9                   	leave  
  801b61:	c3                   	ret    

00801b62 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	56                   	push   %esi
  801b66:	53                   	push   %ebx
  801b67:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b72:	8b 06                	mov    (%esi),%eax
  801b74:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801b79:	b8 01 00 00 00       	mov    $0x1,%eax
  801b7e:	e8 95 ff ff ff       	call   801b18 <nsipc>
  801b83:	89 c3                	mov    %eax,%ebx
  801b85:	85 c0                	test   %eax,%eax
  801b87:	78 20                	js     801ba9 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b89:	83 ec 04             	sub    $0x4,%esp
  801b8c:	ff 35 10 60 80 00    	pushl  0x806010
  801b92:	68 00 60 80 00       	push   $0x806000
  801b97:	ff 75 0c             	pushl  0xc(%ebp)
  801b9a:	e8 1d ee ff ff       	call   8009bc <memmove>
		*addrlen = ret->ret_addrlen;
  801b9f:	a1 10 60 80 00       	mov    0x806010,%eax
  801ba4:	89 06                	mov    %eax,(%esi)
  801ba6:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801ba9:	89 d8                	mov    %ebx,%eax
  801bab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bae:	5b                   	pop    %ebx
  801baf:	5e                   	pop    %esi
  801bb0:	5d                   	pop    %ebp
  801bb1:	c3                   	ret    

00801bb2 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	53                   	push   %ebx
  801bb6:	83 ec 08             	sub    $0x8,%esp
  801bb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbf:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801bc4:	53                   	push   %ebx
  801bc5:	ff 75 0c             	pushl  0xc(%ebp)
  801bc8:	68 04 60 80 00       	push   $0x806004
  801bcd:	e8 ea ed ff ff       	call   8009bc <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801bd2:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801bd8:	b8 02 00 00 00       	mov    $0x2,%eax
  801bdd:	e8 36 ff ff ff       	call   801b18 <nsipc>
}
  801be2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be5:	c9                   	leave  
  801be6:	c3                   	ret    

00801be7 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801bed:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801bf5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf8:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801bfd:	b8 03 00 00 00       	mov    $0x3,%eax
  801c02:	e8 11 ff ff ff       	call   801b18 <nsipc>
}
  801c07:	c9                   	leave  
  801c08:	c3                   	ret    

00801c09 <nsipc_close>:

int
nsipc_close(int s)
{
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c12:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c17:	b8 04 00 00 00       	mov    $0x4,%eax
  801c1c:	e8 f7 fe ff ff       	call   801b18 <nsipc>
}
  801c21:	c9                   	leave  
  801c22:	c3                   	ret    

00801c23 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
  801c26:	53                   	push   %ebx
  801c27:	83 ec 08             	sub    $0x8,%esp
  801c2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c30:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c35:	53                   	push   %ebx
  801c36:	ff 75 0c             	pushl  0xc(%ebp)
  801c39:	68 04 60 80 00       	push   $0x806004
  801c3e:	e8 79 ed ff ff       	call   8009bc <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c43:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801c49:	b8 05 00 00 00       	mov    $0x5,%eax
  801c4e:	e8 c5 fe ff ff       	call   801b18 <nsipc>
}
  801c53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c56:	c9                   	leave  
  801c57:	c3                   	ret    

00801c58 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c61:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801c66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c69:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801c6e:	b8 06 00 00 00       	mov    $0x6,%eax
  801c73:	e8 a0 fe ff ff       	call   801b18 <nsipc>
}
  801c78:	c9                   	leave  
  801c79:	c3                   	ret    

00801c7a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	56                   	push   %esi
  801c7e:	53                   	push   %ebx
  801c7f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801c82:	8b 45 08             	mov    0x8(%ebp),%eax
  801c85:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801c8a:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801c90:	8b 45 14             	mov    0x14(%ebp),%eax
  801c93:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c98:	b8 07 00 00 00       	mov    $0x7,%eax
  801c9d:	e8 76 fe ff ff       	call   801b18 <nsipc>
  801ca2:	89 c3                	mov    %eax,%ebx
  801ca4:	85 c0                	test   %eax,%eax
  801ca6:	78 35                	js     801cdd <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801ca8:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801cad:	7f 04                	jg     801cb3 <nsipc_recv+0x39>
  801caf:	39 c6                	cmp    %eax,%esi
  801cb1:	7d 16                	jge    801cc9 <nsipc_recv+0x4f>
  801cb3:	68 c3 2b 80 00       	push   $0x802bc3
  801cb8:	68 8b 2b 80 00       	push   $0x802b8b
  801cbd:	6a 62                	push   $0x62
  801cbf:	68 d8 2b 80 00       	push   $0x802bd8
  801cc4:	e8 84 e4 ff ff       	call   80014d <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801cc9:	83 ec 04             	sub    $0x4,%esp
  801ccc:	50                   	push   %eax
  801ccd:	68 00 60 80 00       	push   $0x806000
  801cd2:	ff 75 0c             	pushl  0xc(%ebp)
  801cd5:	e8 e2 ec ff ff       	call   8009bc <memmove>
  801cda:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801cdd:	89 d8                	mov    %ebx,%eax
  801cdf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce2:	5b                   	pop    %ebx
  801ce3:	5e                   	pop    %esi
  801ce4:	5d                   	pop    %ebp
  801ce5:	c3                   	ret    

00801ce6 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
  801ce9:	53                   	push   %ebx
  801cea:	83 ec 04             	sub    $0x4,%esp
  801ced:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf3:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801cf8:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801cfe:	7e 16                	jle    801d16 <nsipc_send+0x30>
  801d00:	68 e4 2b 80 00       	push   $0x802be4
  801d05:	68 8b 2b 80 00       	push   $0x802b8b
  801d0a:	6a 6d                	push   $0x6d
  801d0c:	68 d8 2b 80 00       	push   $0x802bd8
  801d11:	e8 37 e4 ff ff       	call   80014d <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d16:	83 ec 04             	sub    $0x4,%esp
  801d19:	53                   	push   %ebx
  801d1a:	ff 75 0c             	pushl  0xc(%ebp)
  801d1d:	68 0c 60 80 00       	push   $0x80600c
  801d22:	e8 95 ec ff ff       	call   8009bc <memmove>
	nsipcbuf.send.req_size = size;
  801d27:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d2d:	8b 45 14             	mov    0x14(%ebp),%eax
  801d30:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d35:	b8 08 00 00 00       	mov    $0x8,%eax
  801d3a:	e8 d9 fd ff ff       	call   801b18 <nsipc>
}
  801d3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d42:	c9                   	leave  
  801d43:	c3                   	ret    

00801d44 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
  801d47:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801d52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d55:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801d5a:	8b 45 10             	mov    0x10(%ebp),%eax
  801d5d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801d62:	b8 09 00 00 00       	mov    $0x9,%eax
  801d67:	e8 ac fd ff ff       	call   801b18 <nsipc>
}
  801d6c:	c9                   	leave  
  801d6d:	c3                   	ret    

00801d6e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d6e:	55                   	push   %ebp
  801d6f:	89 e5                	mov    %esp,%ebp
  801d71:	56                   	push   %esi
  801d72:	53                   	push   %ebx
  801d73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d76:	83 ec 0c             	sub    $0xc,%esp
  801d79:	ff 75 08             	pushl  0x8(%ebp)
  801d7c:	e8 8b f3 ff ff       	call   80110c <fd2data>
  801d81:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d83:	83 c4 08             	add    $0x8,%esp
  801d86:	68 f0 2b 80 00       	push   $0x802bf0
  801d8b:	53                   	push   %ebx
  801d8c:	e8 99 ea ff ff       	call   80082a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d91:	8b 46 04             	mov    0x4(%esi),%eax
  801d94:	2b 06                	sub    (%esi),%eax
  801d96:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d9c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801da3:	00 00 00 
	stat->st_dev = &devpipe;
  801da6:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801dad:	30 80 00 
	return 0;
}
  801db0:	b8 00 00 00 00       	mov    $0x0,%eax
  801db5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db8:	5b                   	pop    %ebx
  801db9:	5e                   	pop    %esi
  801dba:	5d                   	pop    %ebp
  801dbb:	c3                   	ret    

00801dbc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
  801dbf:	53                   	push   %ebx
  801dc0:	83 ec 0c             	sub    $0xc,%esp
  801dc3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801dc6:	53                   	push   %ebx
  801dc7:	6a 00                	push   $0x0
  801dc9:	e8 e4 ee ff ff       	call   800cb2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801dce:	89 1c 24             	mov    %ebx,(%esp)
  801dd1:	e8 36 f3 ff ff       	call   80110c <fd2data>
  801dd6:	83 c4 08             	add    $0x8,%esp
  801dd9:	50                   	push   %eax
  801dda:	6a 00                	push   $0x0
  801ddc:	e8 d1 ee ff ff       	call   800cb2 <sys_page_unmap>
}
  801de1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801de4:	c9                   	leave  
  801de5:	c3                   	ret    

00801de6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801de6:	55                   	push   %ebp
  801de7:	89 e5                	mov    %esp,%ebp
  801de9:	57                   	push   %edi
  801dea:	56                   	push   %esi
  801deb:	53                   	push   %ebx
  801dec:	83 ec 1c             	sub    $0x1c,%esp
  801def:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801df2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801df4:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801df9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801dfc:	83 ec 0c             	sub    $0xc,%esp
  801dff:	ff 75 e0             	pushl  -0x20(%ebp)
  801e02:	e8 c3 05 00 00       	call   8023ca <pageref>
  801e07:	89 c3                	mov    %eax,%ebx
  801e09:	89 3c 24             	mov    %edi,(%esp)
  801e0c:	e8 b9 05 00 00       	call   8023ca <pageref>
  801e11:	83 c4 10             	add    $0x10,%esp
  801e14:	39 c3                	cmp    %eax,%ebx
  801e16:	0f 94 c1             	sete   %cl
  801e19:	0f b6 c9             	movzbl %cl,%ecx
  801e1c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801e1f:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801e25:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e28:	39 ce                	cmp    %ecx,%esi
  801e2a:	74 1b                	je     801e47 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801e2c:	39 c3                	cmp    %eax,%ebx
  801e2e:	75 c4                	jne    801df4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e30:	8b 42 58             	mov    0x58(%edx),%eax
  801e33:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e36:	50                   	push   %eax
  801e37:	56                   	push   %esi
  801e38:	68 f7 2b 80 00       	push   $0x802bf7
  801e3d:	e8 e4 e3 ff ff       	call   800226 <cprintf>
  801e42:	83 c4 10             	add    $0x10,%esp
  801e45:	eb ad                	jmp    801df4 <_pipeisclosed+0xe>
	}
}
  801e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e4d:	5b                   	pop    %ebx
  801e4e:	5e                   	pop    %esi
  801e4f:	5f                   	pop    %edi
  801e50:	5d                   	pop    %ebp
  801e51:	c3                   	ret    

00801e52 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e52:	55                   	push   %ebp
  801e53:	89 e5                	mov    %esp,%ebp
  801e55:	57                   	push   %edi
  801e56:	56                   	push   %esi
  801e57:	53                   	push   %ebx
  801e58:	83 ec 28             	sub    $0x28,%esp
  801e5b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e5e:	56                   	push   %esi
  801e5f:	e8 a8 f2 ff ff       	call   80110c <fd2data>
  801e64:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e66:	83 c4 10             	add    $0x10,%esp
  801e69:	bf 00 00 00 00       	mov    $0x0,%edi
  801e6e:	eb 4b                	jmp    801ebb <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e70:	89 da                	mov    %ebx,%edx
  801e72:	89 f0                	mov    %esi,%eax
  801e74:	e8 6d ff ff ff       	call   801de6 <_pipeisclosed>
  801e79:	85 c0                	test   %eax,%eax
  801e7b:	75 48                	jne    801ec5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e7d:	e8 8c ed ff ff       	call   800c0e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e82:	8b 43 04             	mov    0x4(%ebx),%eax
  801e85:	8b 0b                	mov    (%ebx),%ecx
  801e87:	8d 51 20             	lea    0x20(%ecx),%edx
  801e8a:	39 d0                	cmp    %edx,%eax
  801e8c:	73 e2                	jae    801e70 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e91:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e95:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e98:	89 c2                	mov    %eax,%edx
  801e9a:	c1 fa 1f             	sar    $0x1f,%edx
  801e9d:	89 d1                	mov    %edx,%ecx
  801e9f:	c1 e9 1b             	shr    $0x1b,%ecx
  801ea2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ea5:	83 e2 1f             	and    $0x1f,%edx
  801ea8:	29 ca                	sub    %ecx,%edx
  801eaa:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801eae:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801eb2:	83 c0 01             	add    $0x1,%eax
  801eb5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eb8:	83 c7 01             	add    $0x1,%edi
  801ebb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ebe:	75 c2                	jne    801e82 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ec0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ec3:	eb 05                	jmp    801eca <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ec5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801eca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ecd:	5b                   	pop    %ebx
  801ece:	5e                   	pop    %esi
  801ecf:	5f                   	pop    %edi
  801ed0:	5d                   	pop    %ebp
  801ed1:	c3                   	ret    

00801ed2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	57                   	push   %edi
  801ed6:	56                   	push   %esi
  801ed7:	53                   	push   %ebx
  801ed8:	83 ec 18             	sub    $0x18,%esp
  801edb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ede:	57                   	push   %edi
  801edf:	e8 28 f2 ff ff       	call   80110c <fd2data>
  801ee4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ee6:	83 c4 10             	add    $0x10,%esp
  801ee9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801eee:	eb 3d                	jmp    801f2d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ef0:	85 db                	test   %ebx,%ebx
  801ef2:	74 04                	je     801ef8 <devpipe_read+0x26>
				return i;
  801ef4:	89 d8                	mov    %ebx,%eax
  801ef6:	eb 44                	jmp    801f3c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ef8:	89 f2                	mov    %esi,%edx
  801efa:	89 f8                	mov    %edi,%eax
  801efc:	e8 e5 fe ff ff       	call   801de6 <_pipeisclosed>
  801f01:	85 c0                	test   %eax,%eax
  801f03:	75 32                	jne    801f37 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f05:	e8 04 ed ff ff       	call   800c0e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f0a:	8b 06                	mov    (%esi),%eax
  801f0c:	3b 46 04             	cmp    0x4(%esi),%eax
  801f0f:	74 df                	je     801ef0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f11:	99                   	cltd   
  801f12:	c1 ea 1b             	shr    $0x1b,%edx
  801f15:	01 d0                	add    %edx,%eax
  801f17:	83 e0 1f             	and    $0x1f,%eax
  801f1a:	29 d0                	sub    %edx,%eax
  801f1c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801f21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f24:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801f27:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f2a:	83 c3 01             	add    $0x1,%ebx
  801f2d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f30:	75 d8                	jne    801f0a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f32:	8b 45 10             	mov    0x10(%ebp),%eax
  801f35:	eb 05                	jmp    801f3c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f37:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f3f:	5b                   	pop    %ebx
  801f40:	5e                   	pop    %esi
  801f41:	5f                   	pop    %edi
  801f42:	5d                   	pop    %ebp
  801f43:	c3                   	ret    

00801f44 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	56                   	push   %esi
  801f48:	53                   	push   %ebx
  801f49:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f4f:	50                   	push   %eax
  801f50:	e8 ce f1 ff ff       	call   801123 <fd_alloc>
  801f55:	83 c4 10             	add    $0x10,%esp
  801f58:	89 c2                	mov    %eax,%edx
  801f5a:	85 c0                	test   %eax,%eax
  801f5c:	0f 88 2c 01 00 00    	js     80208e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f62:	83 ec 04             	sub    $0x4,%esp
  801f65:	68 07 04 00 00       	push   $0x407
  801f6a:	ff 75 f4             	pushl  -0xc(%ebp)
  801f6d:	6a 00                	push   $0x0
  801f6f:	e8 b9 ec ff ff       	call   800c2d <sys_page_alloc>
  801f74:	83 c4 10             	add    $0x10,%esp
  801f77:	89 c2                	mov    %eax,%edx
  801f79:	85 c0                	test   %eax,%eax
  801f7b:	0f 88 0d 01 00 00    	js     80208e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f81:	83 ec 0c             	sub    $0xc,%esp
  801f84:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f87:	50                   	push   %eax
  801f88:	e8 96 f1 ff ff       	call   801123 <fd_alloc>
  801f8d:	89 c3                	mov    %eax,%ebx
  801f8f:	83 c4 10             	add    $0x10,%esp
  801f92:	85 c0                	test   %eax,%eax
  801f94:	0f 88 e2 00 00 00    	js     80207c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f9a:	83 ec 04             	sub    $0x4,%esp
  801f9d:	68 07 04 00 00       	push   $0x407
  801fa2:	ff 75 f0             	pushl  -0x10(%ebp)
  801fa5:	6a 00                	push   $0x0
  801fa7:	e8 81 ec ff ff       	call   800c2d <sys_page_alloc>
  801fac:	89 c3                	mov    %eax,%ebx
  801fae:	83 c4 10             	add    $0x10,%esp
  801fb1:	85 c0                	test   %eax,%eax
  801fb3:	0f 88 c3 00 00 00    	js     80207c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801fb9:	83 ec 0c             	sub    $0xc,%esp
  801fbc:	ff 75 f4             	pushl  -0xc(%ebp)
  801fbf:	e8 48 f1 ff ff       	call   80110c <fd2data>
  801fc4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fc6:	83 c4 0c             	add    $0xc,%esp
  801fc9:	68 07 04 00 00       	push   $0x407
  801fce:	50                   	push   %eax
  801fcf:	6a 00                	push   $0x0
  801fd1:	e8 57 ec ff ff       	call   800c2d <sys_page_alloc>
  801fd6:	89 c3                	mov    %eax,%ebx
  801fd8:	83 c4 10             	add    $0x10,%esp
  801fdb:	85 c0                	test   %eax,%eax
  801fdd:	0f 88 89 00 00 00    	js     80206c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fe3:	83 ec 0c             	sub    $0xc,%esp
  801fe6:	ff 75 f0             	pushl  -0x10(%ebp)
  801fe9:	e8 1e f1 ff ff       	call   80110c <fd2data>
  801fee:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ff5:	50                   	push   %eax
  801ff6:	6a 00                	push   $0x0
  801ff8:	56                   	push   %esi
  801ff9:	6a 00                	push   $0x0
  801ffb:	e8 70 ec ff ff       	call   800c70 <sys_page_map>
  802000:	89 c3                	mov    %eax,%ebx
  802002:	83 c4 20             	add    $0x20,%esp
  802005:	85 c0                	test   %eax,%eax
  802007:	78 55                	js     80205e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802009:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80200f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802012:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802014:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802017:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80201e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802024:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802027:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802029:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80202c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802033:	83 ec 0c             	sub    $0xc,%esp
  802036:	ff 75 f4             	pushl  -0xc(%ebp)
  802039:	e8 be f0 ff ff       	call   8010fc <fd2num>
  80203e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802041:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802043:	83 c4 04             	add    $0x4,%esp
  802046:	ff 75 f0             	pushl  -0x10(%ebp)
  802049:	e8 ae f0 ff ff       	call   8010fc <fd2num>
  80204e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802051:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802054:	83 c4 10             	add    $0x10,%esp
  802057:	ba 00 00 00 00       	mov    $0x0,%edx
  80205c:	eb 30                	jmp    80208e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80205e:	83 ec 08             	sub    $0x8,%esp
  802061:	56                   	push   %esi
  802062:	6a 00                	push   $0x0
  802064:	e8 49 ec ff ff       	call   800cb2 <sys_page_unmap>
  802069:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80206c:	83 ec 08             	sub    $0x8,%esp
  80206f:	ff 75 f0             	pushl  -0x10(%ebp)
  802072:	6a 00                	push   $0x0
  802074:	e8 39 ec ff ff       	call   800cb2 <sys_page_unmap>
  802079:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80207c:	83 ec 08             	sub    $0x8,%esp
  80207f:	ff 75 f4             	pushl  -0xc(%ebp)
  802082:	6a 00                	push   $0x0
  802084:	e8 29 ec ff ff       	call   800cb2 <sys_page_unmap>
  802089:	83 c4 10             	add    $0x10,%esp
  80208c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80208e:	89 d0                	mov    %edx,%eax
  802090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802093:	5b                   	pop    %ebx
  802094:	5e                   	pop    %esi
  802095:	5d                   	pop    %ebp
  802096:	c3                   	ret    

00802097 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802097:	55                   	push   %ebp
  802098:	89 e5                	mov    %esp,%ebp
  80209a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80209d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a0:	50                   	push   %eax
  8020a1:	ff 75 08             	pushl  0x8(%ebp)
  8020a4:	e8 c9 f0 ff ff       	call   801172 <fd_lookup>
  8020a9:	83 c4 10             	add    $0x10,%esp
  8020ac:	85 c0                	test   %eax,%eax
  8020ae:	78 18                	js     8020c8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8020b0:	83 ec 0c             	sub    $0xc,%esp
  8020b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8020b6:	e8 51 f0 ff ff       	call   80110c <fd2data>
	return _pipeisclosed(fd, p);
  8020bb:	89 c2                	mov    %eax,%edx
  8020bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c0:	e8 21 fd ff ff       	call   801de6 <_pipeisclosed>
  8020c5:	83 c4 10             	add    $0x10,%esp
}
  8020c8:	c9                   	leave  
  8020c9:	c3                   	ret    

008020ca <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020ca:	55                   	push   %ebp
  8020cb:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    

008020d4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020d4:	55                   	push   %ebp
  8020d5:	89 e5                	mov    %esp,%ebp
  8020d7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8020da:	68 0f 2c 80 00       	push   $0x802c0f
  8020df:	ff 75 0c             	pushl  0xc(%ebp)
  8020e2:	e8 43 e7 ff ff       	call   80082a <strcpy>
	return 0;
}
  8020e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8020ec:	c9                   	leave  
  8020ed:	c3                   	ret    

008020ee <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020ee:	55                   	push   %ebp
  8020ef:	89 e5                	mov    %esp,%ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020fa:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020ff:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802105:	eb 2d                	jmp    802134 <devcons_write+0x46>
		m = n - tot;
  802107:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80210a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80210c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80210f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802114:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802117:	83 ec 04             	sub    $0x4,%esp
  80211a:	53                   	push   %ebx
  80211b:	03 45 0c             	add    0xc(%ebp),%eax
  80211e:	50                   	push   %eax
  80211f:	57                   	push   %edi
  802120:	e8 97 e8 ff ff       	call   8009bc <memmove>
		sys_cputs(buf, m);
  802125:	83 c4 08             	add    $0x8,%esp
  802128:	53                   	push   %ebx
  802129:	57                   	push   %edi
  80212a:	e8 42 ea ff ff       	call   800b71 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80212f:	01 de                	add    %ebx,%esi
  802131:	83 c4 10             	add    $0x10,%esp
  802134:	89 f0                	mov    %esi,%eax
  802136:	3b 75 10             	cmp    0x10(%ebp),%esi
  802139:	72 cc                	jb     802107 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80213b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80213e:	5b                   	pop    %ebx
  80213f:	5e                   	pop    %esi
  802140:	5f                   	pop    %edi
  802141:	5d                   	pop    %ebp
  802142:	c3                   	ret    

00802143 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802143:	55                   	push   %ebp
  802144:	89 e5                	mov    %esp,%ebp
  802146:	83 ec 08             	sub    $0x8,%esp
  802149:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80214e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802152:	74 2a                	je     80217e <devcons_read+0x3b>
  802154:	eb 05                	jmp    80215b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802156:	e8 b3 ea ff ff       	call   800c0e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80215b:	e8 2f ea ff ff       	call   800b8f <sys_cgetc>
  802160:	85 c0                	test   %eax,%eax
  802162:	74 f2                	je     802156 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802164:	85 c0                	test   %eax,%eax
  802166:	78 16                	js     80217e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802168:	83 f8 04             	cmp    $0x4,%eax
  80216b:	74 0c                	je     802179 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80216d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802170:	88 02                	mov    %al,(%edx)
	return 1;
  802172:	b8 01 00 00 00       	mov    $0x1,%eax
  802177:	eb 05                	jmp    80217e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802179:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80217e:	c9                   	leave  
  80217f:	c3                   	ret    

00802180 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  802180:	55                   	push   %ebp
  802181:	89 e5                	mov    %esp,%ebp
  802183:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802186:	8b 45 08             	mov    0x8(%ebp),%eax
  802189:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80218c:	6a 01                	push   $0x1
  80218e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802191:	50                   	push   %eax
  802192:	e8 da e9 ff ff       	call   800b71 <sys_cputs>
}
  802197:	83 c4 10             	add    $0x10,%esp
  80219a:	c9                   	leave  
  80219b:	c3                   	ret    

0080219c <getchar>:

int
getchar(void)
{
  80219c:	55                   	push   %ebp
  80219d:	89 e5                	mov    %esp,%ebp
  80219f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021a2:	6a 01                	push   $0x1
  8021a4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021a7:	50                   	push   %eax
  8021a8:	6a 00                	push   $0x0
  8021aa:	e8 29 f2 ff ff       	call   8013d8 <read>
	if (r < 0)
  8021af:	83 c4 10             	add    $0x10,%esp
  8021b2:	85 c0                	test   %eax,%eax
  8021b4:	78 0f                	js     8021c5 <getchar+0x29>
		return r;
	if (r < 1)
  8021b6:	85 c0                	test   %eax,%eax
  8021b8:	7e 06                	jle    8021c0 <getchar+0x24>
		return -E_EOF;
	return c;
  8021ba:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8021be:	eb 05                	jmp    8021c5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8021c0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8021c5:	c9                   	leave  
  8021c6:	c3                   	ret    

008021c7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8021c7:	55                   	push   %ebp
  8021c8:	89 e5                	mov    %esp,%ebp
  8021ca:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021d0:	50                   	push   %eax
  8021d1:	ff 75 08             	pushl  0x8(%ebp)
  8021d4:	e8 99 ef ff ff       	call   801172 <fd_lookup>
  8021d9:	83 c4 10             	add    $0x10,%esp
  8021dc:	85 c0                	test   %eax,%eax
  8021de:	78 11                	js     8021f1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021e9:	39 10                	cmp    %edx,(%eax)
  8021eb:	0f 94 c0             	sete   %al
  8021ee:	0f b6 c0             	movzbl %al,%eax
}
  8021f1:	c9                   	leave  
  8021f2:	c3                   	ret    

008021f3 <opencons>:

int
opencons(void)
{
  8021f3:	55                   	push   %ebp
  8021f4:	89 e5                	mov    %esp,%ebp
  8021f6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021fc:	50                   	push   %eax
  8021fd:	e8 21 ef ff ff       	call   801123 <fd_alloc>
  802202:	83 c4 10             	add    $0x10,%esp
		return r;
  802205:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802207:	85 c0                	test   %eax,%eax
  802209:	78 3e                	js     802249 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80220b:	83 ec 04             	sub    $0x4,%esp
  80220e:	68 07 04 00 00       	push   $0x407
  802213:	ff 75 f4             	pushl  -0xc(%ebp)
  802216:	6a 00                	push   $0x0
  802218:	e8 10 ea ff ff       	call   800c2d <sys_page_alloc>
  80221d:	83 c4 10             	add    $0x10,%esp
		return r;
  802220:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802222:	85 c0                	test   %eax,%eax
  802224:	78 23                	js     802249 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802226:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80222c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80222f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802231:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802234:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80223b:	83 ec 0c             	sub    $0xc,%esp
  80223e:	50                   	push   %eax
  80223f:	e8 b8 ee ff ff       	call   8010fc <fd2num>
  802244:	89 c2                	mov    %eax,%edx
  802246:	83 c4 10             	add    $0x10,%esp
}
  802249:	89 d0                	mov    %edx,%eax
  80224b:	c9                   	leave  
  80224c:	c3                   	ret    

0080224d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80224d:	55                   	push   %ebp
  80224e:	89 e5                	mov    %esp,%ebp
  802250:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802253:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80225a:	75 4a                	jne    8022a6 <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  80225c:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802261:	8b 40 48             	mov    0x48(%eax),%eax
  802264:	83 ec 04             	sub    $0x4,%esp
  802267:	6a 07                	push   $0x7
  802269:	68 00 f0 bf ee       	push   $0xeebff000
  80226e:	50                   	push   %eax
  80226f:	e8 b9 e9 ff ff       	call   800c2d <sys_page_alloc>
  802274:	83 c4 10             	add    $0x10,%esp
  802277:	85 c0                	test   %eax,%eax
  802279:	79 12                	jns    80228d <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  80227b:	50                   	push   %eax
  80227c:	68 1b 2c 80 00       	push   $0x802c1b
  802281:	6a 21                	push   $0x21
  802283:	68 33 2c 80 00       	push   $0x802c33
  802288:	e8 c0 de ff ff       	call   80014d <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80228d:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802292:	8b 40 48             	mov    0x48(%eax),%eax
  802295:	83 ec 08             	sub    $0x8,%esp
  802298:	68 b0 22 80 00       	push   $0x8022b0
  80229d:	50                   	push   %eax
  80229e:	e8 d5 ea ff ff       	call   800d78 <sys_env_set_pgfault_upcall>
  8022a3:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a9:	a3 00 70 80 00       	mov    %eax,0x807000
  8022ae:	c9                   	leave  
  8022af:	c3                   	ret    

008022b0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8022b0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022b1:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8022b6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022b8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  8022bb:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  8022be:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  8022c2:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  8022c7:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  8022cb:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8022cd:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  8022ce:	83 c4 04             	add    $0x4,%esp
	popfl
  8022d1:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8022d2:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  8022d3:	c3                   	ret    

008022d4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022d4:	55                   	push   %ebp
  8022d5:	89 e5                	mov    %esp,%ebp
  8022d7:	56                   	push   %esi
  8022d8:	53                   	push   %ebx
  8022d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8022dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  8022e2:	85 c0                	test   %eax,%eax
  8022e4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8022e9:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  8022ec:	83 ec 0c             	sub    $0xc,%esp
  8022ef:	50                   	push   %eax
  8022f0:	e8 e8 ea ff ff       	call   800ddd <sys_ipc_recv>
  8022f5:	83 c4 10             	add    $0x10,%esp
  8022f8:	85 c0                	test   %eax,%eax
  8022fa:	79 16                	jns    802312 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  8022fc:	85 f6                	test   %esi,%esi
  8022fe:	74 06                	je     802306 <ipc_recv+0x32>
            *from_env_store = 0;
  802300:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  802306:	85 db                	test   %ebx,%ebx
  802308:	74 2c                	je     802336 <ipc_recv+0x62>
            *perm_store = 0;
  80230a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802310:	eb 24                	jmp    802336 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  802312:	85 f6                	test   %esi,%esi
  802314:	74 0a                	je     802320 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  802316:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80231b:	8b 40 74             	mov    0x74(%eax),%eax
  80231e:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  802320:	85 db                	test   %ebx,%ebx
  802322:	74 0a                	je     80232e <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  802324:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802329:	8b 40 78             	mov    0x78(%eax),%eax
  80232c:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  80232e:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802333:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  802336:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802339:	5b                   	pop    %ebx
  80233a:	5e                   	pop    %esi
  80233b:	5d                   	pop    %ebp
  80233c:	c3                   	ret    

0080233d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80233d:	55                   	push   %ebp
  80233e:	89 e5                	mov    %esp,%ebp
  802340:	57                   	push   %edi
  802341:	56                   	push   %esi
  802342:	53                   	push   %ebx
  802343:	83 ec 0c             	sub    $0xc,%esp
  802346:	8b 7d 08             	mov    0x8(%ebp),%edi
  802349:	8b 75 0c             	mov    0xc(%ebp),%esi
  80234c:	8b 45 10             	mov    0x10(%ebp),%eax
  80234f:	85 c0                	test   %eax,%eax
  802351:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802356:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  802359:	eb 1c                	jmp    802377 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  80235b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80235e:	74 12                	je     802372 <ipc_send+0x35>
  802360:	50                   	push   %eax
  802361:	68 41 2c 80 00       	push   $0x802c41
  802366:	6a 3b                	push   $0x3b
  802368:	68 57 2c 80 00       	push   $0x802c57
  80236d:	e8 db dd ff ff       	call   80014d <_panic>
		sys_yield();
  802372:	e8 97 e8 ff ff       	call   800c0e <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  802377:	ff 75 14             	pushl  0x14(%ebp)
  80237a:	53                   	push   %ebx
  80237b:	56                   	push   %esi
  80237c:	57                   	push   %edi
  80237d:	e8 38 ea ff ff       	call   800dba <sys_ipc_try_send>
  802382:	83 c4 10             	add    $0x10,%esp
  802385:	85 c0                	test   %eax,%eax
  802387:	78 d2                	js     80235b <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  802389:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80238c:	5b                   	pop    %ebx
  80238d:	5e                   	pop    %esi
  80238e:	5f                   	pop    %edi
  80238f:	5d                   	pop    %ebp
  802390:	c3                   	ret    

00802391 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802391:	55                   	push   %ebp
  802392:	89 e5                	mov    %esp,%ebp
  802394:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802397:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80239c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80239f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023a5:	8b 52 50             	mov    0x50(%edx),%edx
  8023a8:	39 ca                	cmp    %ecx,%edx
  8023aa:	75 0d                	jne    8023b9 <ipc_find_env+0x28>
			return envs[i].env_id;
  8023ac:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023af:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023b4:	8b 40 48             	mov    0x48(%eax),%eax
  8023b7:	eb 0f                	jmp    8023c8 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023b9:	83 c0 01             	add    $0x1,%eax
  8023bc:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023c1:	75 d9                	jne    80239c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023c8:	5d                   	pop    %ebp
  8023c9:	c3                   	ret    

008023ca <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023ca:	55                   	push   %ebp
  8023cb:	89 e5                	mov    %esp,%ebp
  8023cd:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023d0:	89 d0                	mov    %edx,%eax
  8023d2:	c1 e8 16             	shr    $0x16,%eax
  8023d5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023dc:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023e1:	f6 c1 01             	test   $0x1,%cl
  8023e4:	74 1d                	je     802403 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023e6:	c1 ea 0c             	shr    $0xc,%edx
  8023e9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023f0:	f6 c2 01             	test   $0x1,%dl
  8023f3:	74 0e                	je     802403 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023f5:	c1 ea 0c             	shr    $0xc,%edx
  8023f8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023ff:	ef 
  802400:	0f b7 c0             	movzwl %ax,%eax
}
  802403:	5d                   	pop    %ebp
  802404:	c3                   	ret    
  802405:	66 90                	xchg   %ax,%ax
  802407:	66 90                	xchg   %ax,%ax
  802409:	66 90                	xchg   %ax,%ax
  80240b:	66 90                	xchg   %ax,%ax
  80240d:	66 90                	xchg   %ax,%ax
  80240f:	90                   	nop

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
