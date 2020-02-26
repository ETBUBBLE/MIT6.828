
obj/user/testtime.debug：     文件格式 elf32-i386


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
  80002c:	e8 c8 00 00 00       	call   8000f9 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sleep>:
#include <inc/lib.h>
#include <inc/x86.h>

void
sleep(int sec)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
	unsigned now = sys_time_msec();
  80003a:	e8 eb 0d 00 00       	call   800e2a <sys_time_msec>
	unsigned end = now + sec * 1000;
  80003f:	69 5d 08 e8 03 00 00 	imul   $0x3e8,0x8(%ebp),%ebx
  800046:	01 c3                	add    %eax,%ebx

	if ((int)now < 0 && (int)now > -MAXERROR)
  800048:	89 c2                	mov    %eax,%edx
  80004a:	c1 ea 1f             	shr    $0x1f,%edx
  80004d:	84 d2                	test   %dl,%dl
  80004f:	74 17                	je     800068 <sleep+0x35>
  800051:	83 f8 f1             	cmp    $0xfffffff1,%eax
  800054:	7c 12                	jl     800068 <sleep+0x35>
		panic("sys_time_msec: %e", (int)now);
  800056:	50                   	push   %eax
  800057:	68 80 23 80 00       	push   $0x802380
  80005c:	6a 0b                	push   $0xb
  80005e:	68 92 23 80 00       	push   $0x802392
  800063:	e8 f1 00 00 00       	call   800159 <_panic>
	if (end < now)
  800068:	39 d8                	cmp    %ebx,%eax
  80006a:	76 19                	jbe    800085 <sleep+0x52>
		panic("sleep: wrap");
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 a2 23 80 00       	push   $0x8023a2
  800074:	6a 0d                	push   $0xd
  800076:	68 92 23 80 00       	push   $0x802392
  80007b:	e8 d9 00 00 00       	call   800159 <_panic>

	while (sys_time_msec() < end)
		sys_yield();
  800080:	e8 95 0b 00 00       	call   800c1a <sys_yield>
	if ((int)now < 0 && (int)now > -MAXERROR)
		panic("sys_time_msec: %e", (int)now);
	if (end < now)
		panic("sleep: wrap");

	while (sys_time_msec() < end)
  800085:	e8 a0 0d 00 00       	call   800e2a <sys_time_msec>
  80008a:	39 c3                	cmp    %eax,%ebx
  80008c:	77 f2                	ja     800080 <sleep+0x4d>
		sys_yield();
}
  80008e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800091:	c9                   	leave  
  800092:	c3                   	ret    

00800093 <umain>:

void
umain(int argc, char **argv)
{
  800093:	55                   	push   %ebp
  800094:	89 e5                	mov    %esp,%ebp
  800096:	53                   	push   %ebx
  800097:	83 ec 04             	sub    $0x4,%esp
  80009a:	bb 32 00 00 00       	mov    $0x32,%ebx
	int i;

	// Wait for the console to calm down
	for (i = 0; i < 50; i++)
		sys_yield();
  80009f:	e8 76 0b 00 00       	call   800c1a <sys_yield>
umain(int argc, char **argv)
{
	int i;

	// Wait for the console to calm down
	for (i = 0; i < 50; i++)
  8000a4:	83 eb 01             	sub    $0x1,%ebx
  8000a7:	75 f6                	jne    80009f <umain+0xc>
		sys_yield();

	cprintf("starting count down: ");
  8000a9:	83 ec 0c             	sub    $0xc,%esp
  8000ac:	68 ae 23 80 00       	push   $0x8023ae
  8000b1:	e8 7c 01 00 00       	call   800232 <cprintf>
  8000b6:	83 c4 10             	add    $0x10,%esp
	for (i = 5; i >= 0; i--) {
  8000b9:	bb 05 00 00 00       	mov    $0x5,%ebx
		cprintf("%d ", i);
  8000be:	83 ec 08             	sub    $0x8,%esp
  8000c1:	53                   	push   %ebx
  8000c2:	68 c4 23 80 00       	push   $0x8023c4
  8000c7:	e8 66 01 00 00       	call   800232 <cprintf>
		sleep(1);
  8000cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000d3:	e8 5b ff ff ff       	call   800033 <sleep>
	// Wait for the console to calm down
	for (i = 0; i < 50; i++)
		sys_yield();

	cprintf("starting count down: ");
	for (i = 5; i >= 0; i--) {
  8000d8:	83 eb 01             	sub    $0x1,%ebx
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	83 fb ff             	cmp    $0xffffffff,%ebx
  8000e1:	75 db                	jne    8000be <umain+0x2b>
		cprintf("%d ", i);
		sleep(1);
	}
	cprintf("\n");
  8000e3:	83 ec 0c             	sub    $0xc,%esp
  8000e6:	68 44 28 80 00       	push   $0x802844
  8000eb:	e8 42 01 00 00       	call   800232 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8000f0:	cc                   	int3   
	breakpoint();
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f7:	c9                   	leave  
  8000f8:	c3                   	ret    

008000f9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	56                   	push   %esi
  8000fd:	53                   	push   %ebx
  8000fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800101:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800104:	e8 f2 0a 00 00       	call   800bfb <sys_getenvid>
  800109:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800111:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800116:	a3 08 40 80 00       	mov    %eax,0x804008

    // save the name of the program so that panic() can use it
    if (argc > 0)
  80011b:	85 db                	test   %ebx,%ebx
  80011d:	7e 07                	jle    800126 <libmain+0x2d>
        binaryname = argv[0];
  80011f:	8b 06                	mov    (%esi),%eax
  800121:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  800126:	83 ec 08             	sub    $0x8,%esp
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
  80012b:	e8 63 ff ff ff       	call   800093 <umain>

    // exit gracefully
    exit();
  800130:	e8 0a 00 00 00       	call   80013f <exit>
}
  800135:	83 c4 10             	add    $0x10,%esp
  800138:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013b:	5b                   	pop    %ebx
  80013c:	5e                   	pop    %esi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800145:	e8 ea 0e 00 00       	call   801034 <close_all>
	sys_env_destroy(0);
  80014a:	83 ec 0c             	sub    $0xc,%esp
  80014d:	6a 00                	push   $0x0
  80014f:	e8 66 0a 00 00       	call   800bba <sys_env_destroy>
}
  800154:	83 c4 10             	add    $0x10,%esp
  800157:	c9                   	leave  
  800158:	c3                   	ret    

00800159 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	56                   	push   %esi
  80015d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800161:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800167:	e8 8f 0a 00 00       	call   800bfb <sys_getenvid>
  80016c:	83 ec 0c             	sub    $0xc,%esp
  80016f:	ff 75 0c             	pushl  0xc(%ebp)
  800172:	ff 75 08             	pushl  0x8(%ebp)
  800175:	56                   	push   %esi
  800176:	50                   	push   %eax
  800177:	68 d4 23 80 00       	push   $0x8023d4
  80017c:	e8 b1 00 00 00       	call   800232 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800181:	83 c4 18             	add    $0x18,%esp
  800184:	53                   	push   %ebx
  800185:	ff 75 10             	pushl  0x10(%ebp)
  800188:	e8 54 00 00 00       	call   8001e1 <vcprintf>
	cprintf("\n");
  80018d:	c7 04 24 44 28 80 00 	movl   $0x802844,(%esp)
  800194:	e8 99 00 00 00       	call   800232 <cprintf>
  800199:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019c:	cc                   	int3   
  80019d:	eb fd                	jmp    80019c <_panic+0x43>

0080019f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 04             	sub    $0x4,%esp
  8001a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a9:	8b 13                	mov    (%ebx),%edx
  8001ab:	8d 42 01             	lea    0x1(%edx),%eax
  8001ae:	89 03                	mov    %eax,(%ebx)
  8001b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bc:	75 1a                	jne    8001d8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001be:	83 ec 08             	sub    $0x8,%esp
  8001c1:	68 ff 00 00 00       	push   $0xff
  8001c6:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c9:	50                   	push   %eax
  8001ca:	e8 ae 09 00 00       	call   800b7d <sys_cputs>
		b->idx = 0;
  8001cf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001df:	c9                   	leave  
  8001e0:	c3                   	ret    

008001e1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ea:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f1:	00 00 00 
	b.cnt = 0;
  8001f4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fe:	ff 75 0c             	pushl  0xc(%ebp)
  800201:	ff 75 08             	pushl  0x8(%ebp)
  800204:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020a:	50                   	push   %eax
  80020b:	68 9f 01 80 00       	push   $0x80019f
  800210:	e8 1a 01 00 00       	call   80032f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800215:	83 c4 08             	add    $0x8,%esp
  800218:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800224:	50                   	push   %eax
  800225:	e8 53 09 00 00       	call   800b7d <sys_cputs>

	return b.cnt;
}
  80022a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800238:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023b:	50                   	push   %eax
  80023c:	ff 75 08             	pushl  0x8(%ebp)
  80023f:	e8 9d ff ff ff       	call   8001e1 <vcprintf>
	va_end(ap);

	return cnt;
}
  800244:	c9                   	leave  
  800245:	c3                   	ret    

00800246 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	57                   	push   %edi
  80024a:	56                   	push   %esi
  80024b:	53                   	push   %ebx
  80024c:	83 ec 1c             	sub    $0x1c,%esp
  80024f:	89 c7                	mov    %eax,%edi
  800251:	89 d6                	mov    %edx,%esi
  800253:	8b 45 08             	mov    0x8(%ebp),%eax
  800256:	8b 55 0c             	mov    0xc(%ebp),%edx
  800259:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800262:	bb 00 00 00 00       	mov    $0x0,%ebx
  800267:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80026a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026d:	39 d3                	cmp    %edx,%ebx
  80026f:	72 05                	jb     800276 <printnum+0x30>
  800271:	39 45 10             	cmp    %eax,0x10(%ebp)
  800274:	77 45                	ja     8002bb <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800276:	83 ec 0c             	sub    $0xc,%esp
  800279:	ff 75 18             	pushl  0x18(%ebp)
  80027c:	8b 45 14             	mov    0x14(%ebp),%eax
  80027f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800282:	53                   	push   %ebx
  800283:	ff 75 10             	pushl  0x10(%ebp)
  800286:	83 ec 08             	sub    $0x8,%esp
  800289:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028c:	ff 75 e0             	pushl  -0x20(%ebp)
  80028f:	ff 75 dc             	pushl  -0x24(%ebp)
  800292:	ff 75 d8             	pushl  -0x28(%ebp)
  800295:	e8 56 1e 00 00       	call   8020f0 <__udivdi3>
  80029a:	83 c4 18             	add    $0x18,%esp
  80029d:	52                   	push   %edx
  80029e:	50                   	push   %eax
  80029f:	89 f2                	mov    %esi,%edx
  8002a1:	89 f8                	mov    %edi,%eax
  8002a3:	e8 9e ff ff ff       	call   800246 <printnum>
  8002a8:	83 c4 20             	add    $0x20,%esp
  8002ab:	eb 18                	jmp    8002c5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	56                   	push   %esi
  8002b1:	ff 75 18             	pushl  0x18(%ebp)
  8002b4:	ff d7                	call   *%edi
  8002b6:	83 c4 10             	add    $0x10,%esp
  8002b9:	eb 03                	jmp    8002be <printnum+0x78>
  8002bb:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002be:	83 eb 01             	sub    $0x1,%ebx
  8002c1:	85 db                	test   %ebx,%ebx
  8002c3:	7f e8                	jg     8002ad <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c5:	83 ec 08             	sub    $0x8,%esp
  8002c8:	56                   	push   %esi
  8002c9:	83 ec 04             	sub    $0x4,%esp
  8002cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d8:	e8 43 1f 00 00       	call   802220 <__umoddi3>
  8002dd:	83 c4 14             	add    $0x14,%esp
  8002e0:	0f be 80 f7 23 80 00 	movsbl 0x8023f7(%eax),%eax
  8002e7:	50                   	push   %eax
  8002e8:	ff d7                	call   *%edi
}
  8002ea:	83 c4 10             	add    $0x10,%esp
  8002ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f0:	5b                   	pop    %ebx
  8002f1:	5e                   	pop    %esi
  8002f2:	5f                   	pop    %edi
  8002f3:	5d                   	pop    %ebp
  8002f4:	c3                   	ret    

008002f5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ff:	8b 10                	mov    (%eax),%edx
  800301:	3b 50 04             	cmp    0x4(%eax),%edx
  800304:	73 0a                	jae    800310 <sprintputch+0x1b>
		*b->buf++ = ch;
  800306:	8d 4a 01             	lea    0x1(%edx),%ecx
  800309:	89 08                	mov    %ecx,(%eax)
  80030b:	8b 45 08             	mov    0x8(%ebp),%eax
  80030e:	88 02                	mov    %al,(%edx)
}
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    

00800312 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800318:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031b:	50                   	push   %eax
  80031c:	ff 75 10             	pushl  0x10(%ebp)
  80031f:	ff 75 0c             	pushl  0xc(%ebp)
  800322:	ff 75 08             	pushl  0x8(%ebp)
  800325:	e8 05 00 00 00       	call   80032f <vprintfmt>
	va_end(ap);
}
  80032a:	83 c4 10             	add    $0x10,%esp
  80032d:	c9                   	leave  
  80032e:	c3                   	ret    

0080032f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	57                   	push   %edi
  800333:	56                   	push   %esi
  800334:	53                   	push   %ebx
  800335:	83 ec 2c             	sub    $0x2c,%esp
  800338:	8b 75 08             	mov    0x8(%ebp),%esi
  80033b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80033e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800341:	eb 12                	jmp    800355 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800343:	85 c0                	test   %eax,%eax
  800345:	0f 84 42 04 00 00    	je     80078d <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80034b:	83 ec 08             	sub    $0x8,%esp
  80034e:	53                   	push   %ebx
  80034f:	50                   	push   %eax
  800350:	ff d6                	call   *%esi
  800352:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800355:	83 c7 01             	add    $0x1,%edi
  800358:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80035c:	83 f8 25             	cmp    $0x25,%eax
  80035f:	75 e2                	jne    800343 <vprintfmt+0x14>
  800361:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800365:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80036c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800373:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80037a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037f:	eb 07                	jmp    800388 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800384:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800388:	8d 47 01             	lea    0x1(%edi),%eax
  80038b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038e:	0f b6 07             	movzbl (%edi),%eax
  800391:	0f b6 d0             	movzbl %al,%edx
  800394:	83 e8 23             	sub    $0x23,%eax
  800397:	3c 55                	cmp    $0x55,%al
  800399:	0f 87 d3 03 00 00    	ja     800772 <vprintfmt+0x443>
  80039f:	0f b6 c0             	movzbl %al,%eax
  8003a2:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  8003a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ac:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b0:	eb d6                	jmp    800388 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ba:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003bd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003c4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003c7:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003ca:	83 f9 09             	cmp    $0x9,%ecx
  8003cd:	77 3f                	ja     80040e <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003cf:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d2:	eb e9                	jmp    8003bd <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d7:	8b 00                	mov    (%eax),%eax
  8003d9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003df:	8d 40 04             	lea    0x4(%eax),%eax
  8003e2:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e8:	eb 2a                	jmp    800414 <vprintfmt+0xe5>
  8003ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f4:	0f 49 d0             	cmovns %eax,%edx
  8003f7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003fd:	eb 89                	jmp    800388 <vprintfmt+0x59>
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800402:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800409:	e9 7a ff ff ff       	jmp    800388 <vprintfmt+0x59>
  80040e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800411:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800414:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800418:	0f 89 6a ff ff ff    	jns    800388 <vprintfmt+0x59>
				width = precision, precision = -1;
  80041e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800421:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800424:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80042b:	e9 58 ff ff ff       	jmp    800388 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800430:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800433:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800436:	e9 4d ff ff ff       	jmp    800388 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80043b:	8b 45 14             	mov    0x14(%ebp),%eax
  80043e:	8d 78 04             	lea    0x4(%eax),%edi
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	53                   	push   %ebx
  800445:	ff 30                	pushl  (%eax)
  800447:	ff d6                	call   *%esi
			break;
  800449:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80044c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800452:	e9 fe fe ff ff       	jmp    800355 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800457:	8b 45 14             	mov    0x14(%ebp),%eax
  80045a:	8d 78 04             	lea    0x4(%eax),%edi
  80045d:	8b 00                	mov    (%eax),%eax
  80045f:	99                   	cltd   
  800460:	31 d0                	xor    %edx,%eax
  800462:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800464:	83 f8 0f             	cmp    $0xf,%eax
  800467:	7f 0b                	jg     800474 <vprintfmt+0x145>
  800469:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  800470:	85 d2                	test   %edx,%edx
  800472:	75 1b                	jne    80048f <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800474:	50                   	push   %eax
  800475:	68 0f 24 80 00       	push   $0x80240f
  80047a:	53                   	push   %ebx
  80047b:	56                   	push   %esi
  80047c:	e8 91 fe ff ff       	call   800312 <printfmt>
  800481:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800484:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800487:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80048a:	e9 c6 fe ff ff       	jmp    800355 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80048f:	52                   	push   %edx
  800490:	68 d9 27 80 00       	push   $0x8027d9
  800495:	53                   	push   %ebx
  800496:	56                   	push   %esi
  800497:	e8 76 fe ff ff       	call   800312 <printfmt>
  80049c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80049f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a5:	e9 ab fe ff ff       	jmp    800355 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ad:	83 c0 04             	add    $0x4,%eax
  8004b0:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004b8:	85 ff                	test   %edi,%edi
  8004ba:	b8 08 24 80 00       	mov    $0x802408,%eax
  8004bf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004c2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c6:	0f 8e 94 00 00 00    	jle    800560 <vprintfmt+0x231>
  8004cc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004d0:	0f 84 98 00 00 00    	je     80056e <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d6:	83 ec 08             	sub    $0x8,%esp
  8004d9:	ff 75 d0             	pushl  -0x30(%ebp)
  8004dc:	57                   	push   %edi
  8004dd:	e8 33 03 00 00       	call   800815 <strnlen>
  8004e2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e5:	29 c1                	sub    %eax,%ecx
  8004e7:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004ea:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ed:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f9:	eb 0f                	jmp    80050a <vprintfmt+0x1db>
					putch(padc, putdat);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	53                   	push   %ebx
  8004ff:	ff 75 e0             	pushl  -0x20(%ebp)
  800502:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800504:	83 ef 01             	sub    $0x1,%edi
  800507:	83 c4 10             	add    $0x10,%esp
  80050a:	85 ff                	test   %edi,%edi
  80050c:	7f ed                	jg     8004fb <vprintfmt+0x1cc>
  80050e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800511:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800514:	85 c9                	test   %ecx,%ecx
  800516:	b8 00 00 00 00       	mov    $0x0,%eax
  80051b:	0f 49 c1             	cmovns %ecx,%eax
  80051e:	29 c1                	sub    %eax,%ecx
  800520:	89 75 08             	mov    %esi,0x8(%ebp)
  800523:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800526:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800529:	89 cb                	mov    %ecx,%ebx
  80052b:	eb 4d                	jmp    80057a <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80052d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800531:	74 1b                	je     80054e <vprintfmt+0x21f>
  800533:	0f be c0             	movsbl %al,%eax
  800536:	83 e8 20             	sub    $0x20,%eax
  800539:	83 f8 5e             	cmp    $0x5e,%eax
  80053c:	76 10                	jbe    80054e <vprintfmt+0x21f>
					putch('?', putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	ff 75 0c             	pushl  0xc(%ebp)
  800544:	6a 3f                	push   $0x3f
  800546:	ff 55 08             	call   *0x8(%ebp)
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	eb 0d                	jmp    80055b <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80054e:	83 ec 08             	sub    $0x8,%esp
  800551:	ff 75 0c             	pushl  0xc(%ebp)
  800554:	52                   	push   %edx
  800555:	ff 55 08             	call   *0x8(%ebp)
  800558:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055b:	83 eb 01             	sub    $0x1,%ebx
  80055e:	eb 1a                	jmp    80057a <vprintfmt+0x24b>
  800560:	89 75 08             	mov    %esi,0x8(%ebp)
  800563:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800566:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800569:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056c:	eb 0c                	jmp    80057a <vprintfmt+0x24b>
  80056e:	89 75 08             	mov    %esi,0x8(%ebp)
  800571:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800574:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800577:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057a:	83 c7 01             	add    $0x1,%edi
  80057d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800581:	0f be d0             	movsbl %al,%edx
  800584:	85 d2                	test   %edx,%edx
  800586:	74 23                	je     8005ab <vprintfmt+0x27c>
  800588:	85 f6                	test   %esi,%esi
  80058a:	78 a1                	js     80052d <vprintfmt+0x1fe>
  80058c:	83 ee 01             	sub    $0x1,%esi
  80058f:	79 9c                	jns    80052d <vprintfmt+0x1fe>
  800591:	89 df                	mov    %ebx,%edi
  800593:	8b 75 08             	mov    0x8(%ebp),%esi
  800596:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800599:	eb 18                	jmp    8005b3 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059b:	83 ec 08             	sub    $0x8,%esp
  80059e:	53                   	push   %ebx
  80059f:	6a 20                	push   $0x20
  8005a1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a3:	83 ef 01             	sub    $0x1,%edi
  8005a6:	83 c4 10             	add    $0x10,%esp
  8005a9:	eb 08                	jmp    8005b3 <vprintfmt+0x284>
  8005ab:	89 df                	mov    %ebx,%edi
  8005ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b3:	85 ff                	test   %edi,%edi
  8005b5:	7f e4                	jg     80059b <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b7:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005ba:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c0:	e9 90 fd ff ff       	jmp    800355 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c5:	83 f9 01             	cmp    $0x1,%ecx
  8005c8:	7e 19                	jle    8005e3 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8b 50 04             	mov    0x4(%eax),%edx
  8005d0:	8b 00                	mov    (%eax),%eax
  8005d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005db:	8d 40 08             	lea    0x8(%eax),%eax
  8005de:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e1:	eb 38                	jmp    80061b <vprintfmt+0x2ec>
	else if (lflag)
  8005e3:	85 c9                	test   %ecx,%ecx
  8005e5:	74 1b                	je     800602 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8b 00                	mov    (%eax),%eax
  8005ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ef:	89 c1                	mov    %eax,%ecx
  8005f1:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8d 40 04             	lea    0x4(%eax),%eax
  8005fd:	89 45 14             	mov    %eax,0x14(%ebp)
  800600:	eb 19                	jmp    80061b <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8b 00                	mov    (%eax),%eax
  800607:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060a:	89 c1                	mov    %eax,%ecx
  80060c:	c1 f9 1f             	sar    $0x1f,%ecx
  80060f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 40 04             	lea    0x4(%eax),%eax
  800618:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80061e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800621:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800626:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062a:	0f 89 0e 01 00 00    	jns    80073e <vprintfmt+0x40f>
				putch('-', putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	53                   	push   %ebx
  800634:	6a 2d                	push   $0x2d
  800636:	ff d6                	call   *%esi
				num = -(long long) num;
  800638:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80063b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80063e:	f7 da                	neg    %edx
  800640:	83 d1 00             	adc    $0x0,%ecx
  800643:	f7 d9                	neg    %ecx
  800645:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800648:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064d:	e9 ec 00 00 00       	jmp    80073e <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800652:	83 f9 01             	cmp    $0x1,%ecx
  800655:	7e 18                	jle    80066f <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8b 10                	mov    (%eax),%edx
  80065c:	8b 48 04             	mov    0x4(%eax),%ecx
  80065f:	8d 40 08             	lea    0x8(%eax),%eax
  800662:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800665:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066a:	e9 cf 00 00 00       	jmp    80073e <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80066f:	85 c9                	test   %ecx,%ecx
  800671:	74 1a                	je     80068d <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8b 10                	mov    (%eax),%edx
  800678:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067d:	8d 40 04             	lea    0x4(%eax),%eax
  800680:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800683:	b8 0a 00 00 00       	mov    $0xa,%eax
  800688:	e9 b1 00 00 00       	jmp    80073e <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8b 10                	mov    (%eax),%edx
  800692:	b9 00 00 00 00       	mov    $0x0,%ecx
  800697:	8d 40 04             	lea    0x4(%eax),%eax
  80069a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80069d:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a2:	e9 97 00 00 00       	jmp    80073e <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	6a 58                	push   $0x58
  8006ad:	ff d6                	call   *%esi
			putch('X', putdat);
  8006af:	83 c4 08             	add    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	6a 58                	push   $0x58
  8006b5:	ff d6                	call   *%esi
			putch('X', putdat);
  8006b7:	83 c4 08             	add    $0x8,%esp
  8006ba:	53                   	push   %ebx
  8006bb:	6a 58                	push   $0x58
  8006bd:	ff d6                	call   *%esi
			break;
  8006bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006c5:	e9 8b fc ff ff       	jmp    800355 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8006ca:	83 ec 08             	sub    $0x8,%esp
  8006cd:	53                   	push   %ebx
  8006ce:	6a 30                	push   $0x30
  8006d0:	ff d6                	call   *%esi
			putch('x', putdat);
  8006d2:	83 c4 08             	add    $0x8,%esp
  8006d5:	53                   	push   %ebx
  8006d6:	6a 78                	push   $0x78
  8006d8:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006da:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dd:	8b 10                	mov    (%eax),%edx
  8006df:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006e4:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006e7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ed:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006f2:	eb 4a                	jmp    80073e <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006f4:	83 f9 01             	cmp    $0x1,%ecx
  8006f7:	7e 15                	jle    80070e <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fc:	8b 10                	mov    (%eax),%edx
  8006fe:	8b 48 04             	mov    0x4(%eax),%ecx
  800701:	8d 40 08             	lea    0x8(%eax),%eax
  800704:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800707:	b8 10 00 00 00       	mov    $0x10,%eax
  80070c:	eb 30                	jmp    80073e <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80070e:	85 c9                	test   %ecx,%ecx
  800710:	74 17                	je     800729 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8b 10                	mov    (%eax),%edx
  800717:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071c:	8d 40 04             	lea    0x4(%eax),%eax
  80071f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800722:	b8 10 00 00 00       	mov    $0x10,%eax
  800727:	eb 15                	jmp    80073e <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800729:	8b 45 14             	mov    0x14(%ebp),%eax
  80072c:	8b 10                	mov    (%eax),%edx
  80072e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800733:	8d 40 04             	lea    0x4(%eax),%eax
  800736:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800739:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80073e:	83 ec 0c             	sub    $0xc,%esp
  800741:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800745:	57                   	push   %edi
  800746:	ff 75 e0             	pushl  -0x20(%ebp)
  800749:	50                   	push   %eax
  80074a:	51                   	push   %ecx
  80074b:	52                   	push   %edx
  80074c:	89 da                	mov    %ebx,%edx
  80074e:	89 f0                	mov    %esi,%eax
  800750:	e8 f1 fa ff ff       	call   800246 <printnum>
			break;
  800755:	83 c4 20             	add    $0x20,%esp
  800758:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075b:	e9 f5 fb ff ff       	jmp    800355 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800760:	83 ec 08             	sub    $0x8,%esp
  800763:	53                   	push   %ebx
  800764:	52                   	push   %edx
  800765:	ff d6                	call   *%esi
			break;
  800767:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80076d:	e9 e3 fb ff ff       	jmp    800355 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800772:	83 ec 08             	sub    $0x8,%esp
  800775:	53                   	push   %ebx
  800776:	6a 25                	push   $0x25
  800778:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80077a:	83 c4 10             	add    $0x10,%esp
  80077d:	eb 03                	jmp    800782 <vprintfmt+0x453>
  80077f:	83 ef 01             	sub    $0x1,%edi
  800782:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800786:	75 f7                	jne    80077f <vprintfmt+0x450>
  800788:	e9 c8 fb ff ff       	jmp    800355 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80078d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800790:	5b                   	pop    %ebx
  800791:	5e                   	pop    %esi
  800792:	5f                   	pop    %edi
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	83 ec 18             	sub    $0x18,%esp
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
  80079e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	74 26                	je     8007dc <vsnprintf+0x47>
  8007b6:	85 d2                	test   %edx,%edx
  8007b8:	7e 22                	jle    8007dc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ba:	ff 75 14             	pushl  0x14(%ebp)
  8007bd:	ff 75 10             	pushl  0x10(%ebp)
  8007c0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c3:	50                   	push   %eax
  8007c4:	68 f5 02 80 00       	push   $0x8002f5
  8007c9:	e8 61 fb ff ff       	call   80032f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d7:	83 c4 10             	add    $0x10,%esp
  8007da:	eb 05                	jmp    8007e1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007e1:	c9                   	leave  
  8007e2:	c3                   	ret    

008007e3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007e9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ec:	50                   	push   %eax
  8007ed:	ff 75 10             	pushl  0x10(%ebp)
  8007f0:	ff 75 0c             	pushl  0xc(%ebp)
  8007f3:	ff 75 08             	pushl  0x8(%ebp)
  8007f6:	e8 9a ff ff ff       	call   800795 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    

008007fd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800803:	b8 00 00 00 00       	mov    $0x0,%eax
  800808:	eb 03                	jmp    80080d <strlen+0x10>
		n++;
  80080a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80080d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800811:	75 f7                	jne    80080a <strlen+0xd>
		n++;
	return n;
}
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081e:	ba 00 00 00 00       	mov    $0x0,%edx
  800823:	eb 03                	jmp    800828 <strnlen+0x13>
		n++;
  800825:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800828:	39 c2                	cmp    %eax,%edx
  80082a:	74 08                	je     800834 <strnlen+0x1f>
  80082c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800830:	75 f3                	jne    800825 <strnlen+0x10>
  800832:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	53                   	push   %ebx
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800840:	89 c2                	mov    %eax,%edx
  800842:	83 c2 01             	add    $0x1,%edx
  800845:	83 c1 01             	add    $0x1,%ecx
  800848:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80084c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80084f:	84 db                	test   %bl,%bl
  800851:	75 ef                	jne    800842 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800853:	5b                   	pop    %ebx
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	53                   	push   %ebx
  80085a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085d:	53                   	push   %ebx
  80085e:	e8 9a ff ff ff       	call   8007fd <strlen>
  800863:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800866:	ff 75 0c             	pushl  0xc(%ebp)
  800869:	01 d8                	add    %ebx,%eax
  80086b:	50                   	push   %eax
  80086c:	e8 c5 ff ff ff       	call   800836 <strcpy>
	return dst;
}
  800871:	89 d8                	mov    %ebx,%eax
  800873:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800876:	c9                   	leave  
  800877:	c3                   	ret    

00800878 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	56                   	push   %esi
  80087c:	53                   	push   %ebx
  80087d:	8b 75 08             	mov    0x8(%ebp),%esi
  800880:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800883:	89 f3                	mov    %esi,%ebx
  800885:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800888:	89 f2                	mov    %esi,%edx
  80088a:	eb 0f                	jmp    80089b <strncpy+0x23>
		*dst++ = *src;
  80088c:	83 c2 01             	add    $0x1,%edx
  80088f:	0f b6 01             	movzbl (%ecx),%eax
  800892:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800895:	80 39 01             	cmpb   $0x1,(%ecx)
  800898:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089b:	39 da                	cmp    %ebx,%edx
  80089d:	75 ed                	jne    80088c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80089f:	89 f0                	mov    %esi,%eax
  8008a1:	5b                   	pop    %ebx
  8008a2:	5e                   	pop    %esi
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	56                   	push   %esi
  8008a9:	53                   	push   %ebx
  8008aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b0:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b5:	85 d2                	test   %edx,%edx
  8008b7:	74 21                	je     8008da <strlcpy+0x35>
  8008b9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008bd:	89 f2                	mov    %esi,%edx
  8008bf:	eb 09                	jmp    8008ca <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c1:	83 c2 01             	add    $0x1,%edx
  8008c4:	83 c1 01             	add    $0x1,%ecx
  8008c7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ca:	39 c2                	cmp    %eax,%edx
  8008cc:	74 09                	je     8008d7 <strlcpy+0x32>
  8008ce:	0f b6 19             	movzbl (%ecx),%ebx
  8008d1:	84 db                	test   %bl,%bl
  8008d3:	75 ec                	jne    8008c1 <strlcpy+0x1c>
  8008d5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008d7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008da:	29 f0                	sub    %esi,%eax
}
  8008dc:	5b                   	pop    %ebx
  8008dd:	5e                   	pop    %esi
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e9:	eb 06                	jmp    8008f1 <strcmp+0x11>
		p++, q++;
  8008eb:	83 c1 01             	add    $0x1,%ecx
  8008ee:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008f1:	0f b6 01             	movzbl (%ecx),%eax
  8008f4:	84 c0                	test   %al,%al
  8008f6:	74 04                	je     8008fc <strcmp+0x1c>
  8008f8:	3a 02                	cmp    (%edx),%al
  8008fa:	74 ef                	je     8008eb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fc:	0f b6 c0             	movzbl %al,%eax
  8008ff:	0f b6 12             	movzbl (%edx),%edx
  800902:	29 d0                	sub    %edx,%eax
}
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	53                   	push   %ebx
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800910:	89 c3                	mov    %eax,%ebx
  800912:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800915:	eb 06                	jmp    80091d <strncmp+0x17>
		n--, p++, q++;
  800917:	83 c0 01             	add    $0x1,%eax
  80091a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80091d:	39 d8                	cmp    %ebx,%eax
  80091f:	74 15                	je     800936 <strncmp+0x30>
  800921:	0f b6 08             	movzbl (%eax),%ecx
  800924:	84 c9                	test   %cl,%cl
  800926:	74 04                	je     80092c <strncmp+0x26>
  800928:	3a 0a                	cmp    (%edx),%cl
  80092a:	74 eb                	je     800917 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092c:	0f b6 00             	movzbl (%eax),%eax
  80092f:	0f b6 12             	movzbl (%edx),%edx
  800932:	29 d0                	sub    %edx,%eax
  800934:	eb 05                	jmp    80093b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800936:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80093b:	5b                   	pop    %ebx
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800948:	eb 07                	jmp    800951 <strchr+0x13>
		if (*s == c)
  80094a:	38 ca                	cmp    %cl,%dl
  80094c:	74 0f                	je     80095d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80094e:	83 c0 01             	add    $0x1,%eax
  800951:	0f b6 10             	movzbl (%eax),%edx
  800954:	84 d2                	test   %dl,%dl
  800956:	75 f2                	jne    80094a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800958:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800969:	eb 03                	jmp    80096e <strfind+0xf>
  80096b:	83 c0 01             	add    $0x1,%eax
  80096e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800971:	38 ca                	cmp    %cl,%dl
  800973:	74 04                	je     800979 <strfind+0x1a>
  800975:	84 d2                	test   %dl,%dl
  800977:	75 f2                	jne    80096b <strfind+0xc>
			break;
	return (char *) s;
}
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	57                   	push   %edi
  80097f:	56                   	push   %esi
  800980:	53                   	push   %ebx
  800981:	8b 7d 08             	mov    0x8(%ebp),%edi
  800984:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800987:	85 c9                	test   %ecx,%ecx
  800989:	74 36                	je     8009c1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800991:	75 28                	jne    8009bb <memset+0x40>
  800993:	f6 c1 03             	test   $0x3,%cl
  800996:	75 23                	jne    8009bb <memset+0x40>
		c &= 0xFF;
  800998:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80099c:	89 d3                	mov    %edx,%ebx
  80099e:	c1 e3 08             	shl    $0x8,%ebx
  8009a1:	89 d6                	mov    %edx,%esi
  8009a3:	c1 e6 18             	shl    $0x18,%esi
  8009a6:	89 d0                	mov    %edx,%eax
  8009a8:	c1 e0 10             	shl    $0x10,%eax
  8009ab:	09 f0                	or     %esi,%eax
  8009ad:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009af:	89 d8                	mov    %ebx,%eax
  8009b1:	09 d0                	or     %edx,%eax
  8009b3:	c1 e9 02             	shr    $0x2,%ecx
  8009b6:	fc                   	cld    
  8009b7:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b9:	eb 06                	jmp    8009c1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009be:	fc                   	cld    
  8009bf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c1:	89 f8                	mov    %edi,%eax
  8009c3:	5b                   	pop    %ebx
  8009c4:	5e                   	pop    %esi
  8009c5:	5f                   	pop    %edi
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	57                   	push   %edi
  8009cc:	56                   	push   %esi
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d6:	39 c6                	cmp    %eax,%esi
  8009d8:	73 35                	jae    800a0f <memmove+0x47>
  8009da:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009dd:	39 d0                	cmp    %edx,%eax
  8009df:	73 2e                	jae    800a0f <memmove+0x47>
		s += n;
		d += n;
  8009e1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e4:	89 d6                	mov    %edx,%esi
  8009e6:	09 fe                	or     %edi,%esi
  8009e8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ee:	75 13                	jne    800a03 <memmove+0x3b>
  8009f0:	f6 c1 03             	test   $0x3,%cl
  8009f3:	75 0e                	jne    800a03 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009f5:	83 ef 04             	sub    $0x4,%edi
  8009f8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009fb:	c1 e9 02             	shr    $0x2,%ecx
  8009fe:	fd                   	std    
  8009ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a01:	eb 09                	jmp    800a0c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a03:	83 ef 01             	sub    $0x1,%edi
  800a06:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a09:	fd                   	std    
  800a0a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a0c:	fc                   	cld    
  800a0d:	eb 1d                	jmp    800a2c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0f:	89 f2                	mov    %esi,%edx
  800a11:	09 c2                	or     %eax,%edx
  800a13:	f6 c2 03             	test   $0x3,%dl
  800a16:	75 0f                	jne    800a27 <memmove+0x5f>
  800a18:	f6 c1 03             	test   $0x3,%cl
  800a1b:	75 0a                	jne    800a27 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a1d:	c1 e9 02             	shr    $0x2,%ecx
  800a20:	89 c7                	mov    %eax,%edi
  800a22:	fc                   	cld    
  800a23:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a25:	eb 05                	jmp    800a2c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a27:	89 c7                	mov    %eax,%edi
  800a29:	fc                   	cld    
  800a2a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a2c:	5e                   	pop    %esi
  800a2d:	5f                   	pop    %edi
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a33:	ff 75 10             	pushl  0x10(%ebp)
  800a36:	ff 75 0c             	pushl  0xc(%ebp)
  800a39:	ff 75 08             	pushl  0x8(%ebp)
  800a3c:	e8 87 ff ff ff       	call   8009c8 <memmove>
}
  800a41:	c9                   	leave  
  800a42:	c3                   	ret    

00800a43 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	56                   	push   %esi
  800a47:	53                   	push   %ebx
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4e:	89 c6                	mov    %eax,%esi
  800a50:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a53:	eb 1a                	jmp    800a6f <memcmp+0x2c>
		if (*s1 != *s2)
  800a55:	0f b6 08             	movzbl (%eax),%ecx
  800a58:	0f b6 1a             	movzbl (%edx),%ebx
  800a5b:	38 d9                	cmp    %bl,%cl
  800a5d:	74 0a                	je     800a69 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a5f:	0f b6 c1             	movzbl %cl,%eax
  800a62:	0f b6 db             	movzbl %bl,%ebx
  800a65:	29 d8                	sub    %ebx,%eax
  800a67:	eb 0f                	jmp    800a78 <memcmp+0x35>
		s1++, s2++;
  800a69:	83 c0 01             	add    $0x1,%eax
  800a6c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6f:	39 f0                	cmp    %esi,%eax
  800a71:	75 e2                	jne    800a55 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	53                   	push   %ebx
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a83:	89 c1                	mov    %eax,%ecx
  800a85:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a88:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a8c:	eb 0a                	jmp    800a98 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8e:	0f b6 10             	movzbl (%eax),%edx
  800a91:	39 da                	cmp    %ebx,%edx
  800a93:	74 07                	je     800a9c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a95:	83 c0 01             	add    $0x1,%eax
  800a98:	39 c8                	cmp    %ecx,%eax
  800a9a:	72 f2                	jb     800a8e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	57                   	push   %edi
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aab:	eb 03                	jmp    800ab0 <strtol+0x11>
		s++;
  800aad:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab0:	0f b6 01             	movzbl (%ecx),%eax
  800ab3:	3c 20                	cmp    $0x20,%al
  800ab5:	74 f6                	je     800aad <strtol+0xe>
  800ab7:	3c 09                	cmp    $0x9,%al
  800ab9:	74 f2                	je     800aad <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800abb:	3c 2b                	cmp    $0x2b,%al
  800abd:	75 0a                	jne    800ac9 <strtol+0x2a>
		s++;
  800abf:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac7:	eb 11                	jmp    800ada <strtol+0x3b>
  800ac9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ace:	3c 2d                	cmp    $0x2d,%al
  800ad0:	75 08                	jne    800ada <strtol+0x3b>
		s++, neg = 1;
  800ad2:	83 c1 01             	add    $0x1,%ecx
  800ad5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ada:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae0:	75 15                	jne    800af7 <strtol+0x58>
  800ae2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae5:	75 10                	jne    800af7 <strtol+0x58>
  800ae7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aeb:	75 7c                	jne    800b69 <strtol+0xca>
		s += 2, base = 16;
  800aed:	83 c1 02             	add    $0x2,%ecx
  800af0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af5:	eb 16                	jmp    800b0d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800af7:	85 db                	test   %ebx,%ebx
  800af9:	75 12                	jne    800b0d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800afb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b00:	80 39 30             	cmpb   $0x30,(%ecx)
  800b03:	75 08                	jne    800b0d <strtol+0x6e>
		s++, base = 8;
  800b05:	83 c1 01             	add    $0x1,%ecx
  800b08:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b12:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b15:	0f b6 11             	movzbl (%ecx),%edx
  800b18:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b1b:	89 f3                	mov    %esi,%ebx
  800b1d:	80 fb 09             	cmp    $0x9,%bl
  800b20:	77 08                	ja     800b2a <strtol+0x8b>
			dig = *s - '0';
  800b22:	0f be d2             	movsbl %dl,%edx
  800b25:	83 ea 30             	sub    $0x30,%edx
  800b28:	eb 22                	jmp    800b4c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b2a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b2d:	89 f3                	mov    %esi,%ebx
  800b2f:	80 fb 19             	cmp    $0x19,%bl
  800b32:	77 08                	ja     800b3c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b34:	0f be d2             	movsbl %dl,%edx
  800b37:	83 ea 57             	sub    $0x57,%edx
  800b3a:	eb 10                	jmp    800b4c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b3c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b3f:	89 f3                	mov    %esi,%ebx
  800b41:	80 fb 19             	cmp    $0x19,%bl
  800b44:	77 16                	ja     800b5c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b46:	0f be d2             	movsbl %dl,%edx
  800b49:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b4c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b4f:	7d 0b                	jge    800b5c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b51:	83 c1 01             	add    $0x1,%ecx
  800b54:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b58:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b5a:	eb b9                	jmp    800b15 <strtol+0x76>

	if (endptr)
  800b5c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b60:	74 0d                	je     800b6f <strtol+0xd0>
		*endptr = (char *) s;
  800b62:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b65:	89 0e                	mov    %ecx,(%esi)
  800b67:	eb 06                	jmp    800b6f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b69:	85 db                	test   %ebx,%ebx
  800b6b:	74 98                	je     800b05 <strtol+0x66>
  800b6d:	eb 9e                	jmp    800b0d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b6f:	89 c2                	mov    %eax,%edx
  800b71:	f7 da                	neg    %edx
  800b73:	85 ff                	test   %edi,%edi
  800b75:	0f 45 c2             	cmovne %edx,%eax
}
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
  800b88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8e:	89 c3                	mov    %eax,%ebx
  800b90:	89 c7                	mov    %eax,%edi
  800b92:	89 c6                	mov    %eax,%esi
  800b94:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba6:	b8 01 00 00 00       	mov    $0x1,%eax
  800bab:	89 d1                	mov    %edx,%ecx
  800bad:	89 d3                	mov    %edx,%ebx
  800baf:	89 d7                	mov    %edx,%edi
  800bb1:	89 d6                	mov    %edx,%esi
  800bb3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
  800bc0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc8:	b8 03 00 00 00       	mov    $0x3,%eax
  800bcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd0:	89 cb                	mov    %ecx,%ebx
  800bd2:	89 cf                	mov    %ecx,%edi
  800bd4:	89 ce                	mov    %ecx,%esi
  800bd6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	7e 17                	jle    800bf3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	50                   	push   %eax
  800be0:	6a 03                	push   $0x3
  800be2:	68 ff 26 80 00       	push   $0x8026ff
  800be7:	6a 23                	push   $0x23
  800be9:	68 1c 27 80 00       	push   $0x80271c
  800bee:	e8 66 f5 ff ff       	call   800159 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c01:	ba 00 00 00 00       	mov    $0x0,%edx
  800c06:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0b:	89 d1                	mov    %edx,%ecx
  800c0d:	89 d3                	mov    %edx,%ebx
  800c0f:	89 d7                	mov    %edx,%edi
  800c11:	89 d6                	mov    %edx,%esi
  800c13:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <sys_yield>:

void
sys_yield(void)
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
  800c25:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c2a:	89 d1                	mov    %edx,%ecx
  800c2c:	89 d3                	mov    %edx,%ebx
  800c2e:	89 d7                	mov    %edx,%edi
  800c30:	89 d6                	mov    %edx,%esi
  800c32:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c42:	be 00 00 00 00       	mov    $0x0,%esi
  800c47:	b8 04 00 00 00       	mov    $0x4,%eax
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c55:	89 f7                	mov    %esi,%edi
  800c57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c59:	85 c0                	test   %eax,%eax
  800c5b:	7e 17                	jle    800c74 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5d:	83 ec 0c             	sub    $0xc,%esp
  800c60:	50                   	push   %eax
  800c61:	6a 04                	push   $0x4
  800c63:	68 ff 26 80 00       	push   $0x8026ff
  800c68:	6a 23                	push   $0x23
  800c6a:	68 1c 27 80 00       	push   $0x80271c
  800c6f:	e8 e5 f4 ff ff       	call   800159 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	53                   	push   %ebx
  800c82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c85:	b8 05 00 00 00       	mov    $0x5,%eax
  800c8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c93:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c96:	8b 75 18             	mov    0x18(%ebp),%esi
  800c99:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9b:	85 c0                	test   %eax,%eax
  800c9d:	7e 17                	jle    800cb6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9f:	83 ec 0c             	sub    $0xc,%esp
  800ca2:	50                   	push   %eax
  800ca3:	6a 05                	push   $0x5
  800ca5:	68 ff 26 80 00       	push   $0x8026ff
  800caa:	6a 23                	push   $0x23
  800cac:	68 1c 27 80 00       	push   $0x80271c
  800cb1:	e8 a3 f4 ff ff       	call   800159 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
  800cc4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccc:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	89 df                	mov    %ebx,%edi
  800cd9:	89 de                	mov    %ebx,%esi
  800cdb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdd:	85 c0                	test   %eax,%eax
  800cdf:	7e 17                	jle    800cf8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce1:	83 ec 0c             	sub    $0xc,%esp
  800ce4:	50                   	push   %eax
  800ce5:	6a 06                	push   $0x6
  800ce7:	68 ff 26 80 00       	push   $0x8026ff
  800cec:	6a 23                	push   $0x23
  800cee:	68 1c 27 80 00       	push   $0x80271c
  800cf3:	e8 61 f4 ff ff       	call   800159 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
  800d06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0e:	b8 08 00 00 00       	mov    $0x8,%eax
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	89 df                	mov    %ebx,%edi
  800d1b:	89 de                	mov    %ebx,%esi
  800d1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	7e 17                	jle    800d3a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d23:	83 ec 0c             	sub    $0xc,%esp
  800d26:	50                   	push   %eax
  800d27:	6a 08                	push   $0x8
  800d29:	68 ff 26 80 00       	push   $0x8026ff
  800d2e:	6a 23                	push   $0x23
  800d30:	68 1c 27 80 00       	push   $0x80271c
  800d35:	e8 1f f4 ff ff       	call   800159 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	57                   	push   %edi
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d50:	b8 09 00 00 00       	mov    $0x9,%eax
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	89 df                	mov    %ebx,%edi
  800d5d:	89 de                	mov    %ebx,%esi
  800d5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	7e 17                	jle    800d7c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d65:	83 ec 0c             	sub    $0xc,%esp
  800d68:	50                   	push   %eax
  800d69:	6a 09                	push   $0x9
  800d6b:	68 ff 26 80 00       	push   $0x8026ff
  800d70:	6a 23                	push   $0x23
  800d72:	68 1c 27 80 00       	push   $0x80271c
  800d77:	e8 dd f3 ff ff       	call   800159 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	57                   	push   %edi
  800d88:	56                   	push   %esi
  800d89:	53                   	push   %ebx
  800d8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d92:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	89 df                	mov    %ebx,%edi
  800d9f:	89 de                	mov    %ebx,%esi
  800da1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da3:	85 c0                	test   %eax,%eax
  800da5:	7e 17                	jle    800dbe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da7:	83 ec 0c             	sub    $0xc,%esp
  800daa:	50                   	push   %eax
  800dab:	6a 0a                	push   $0xa
  800dad:	68 ff 26 80 00       	push   $0x8026ff
  800db2:	6a 23                	push   $0x23
  800db4:	68 1c 27 80 00       	push   $0x80271c
  800db9:	e8 9b f3 ff ff       	call   800159 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	57                   	push   %edi
  800dca:	56                   	push   %esi
  800dcb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcc:	be 00 00 00 00       	mov    $0x0,%esi
  800dd1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ddf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de4:	5b                   	pop    %ebx
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	57                   	push   %edi
  800ded:	56                   	push   %esi
  800dee:	53                   	push   %ebx
  800def:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	89 cb                	mov    %ecx,%ebx
  800e01:	89 cf                	mov    %ecx,%edi
  800e03:	89 ce                	mov    %ecx,%esi
  800e05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e07:	85 c0                	test   %eax,%eax
  800e09:	7e 17                	jle    800e22 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0b:	83 ec 0c             	sub    $0xc,%esp
  800e0e:	50                   	push   %eax
  800e0f:	6a 0d                	push   $0xd
  800e11:	68 ff 26 80 00       	push   $0x8026ff
  800e16:	6a 23                	push   $0x23
  800e18:	68 1c 27 80 00       	push   $0x80271c
  800e1d:	e8 37 f3 ff ff       	call   800159 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e30:	ba 00 00 00 00       	mov    $0x0,%edx
  800e35:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e3a:	89 d1                	mov    %edx,%ecx
  800e3c:	89 d3                	mov    %edx,%ebx
  800e3e:	89 d7                	mov    %edx,%edi
  800e40:	89 d6                	mov    %edx,%esi
  800e42:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e54:	b8 10 00 00 00       	mov    $0x10,%eax
  800e59:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5c:	89 cb                	mov    %ecx,%ebx
  800e5e:	89 cf                	mov    %ecx,%edi
  800e60:	89 ce                	mov    %ecx,%esi
  800e62:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6f:	05 00 00 00 30       	add    $0x30000000,%eax
  800e74:	c1 e8 0c             	shr    $0xc,%eax
}
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    

00800e79 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7f:	05 00 00 00 30       	add    $0x30000000,%eax
  800e84:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e89:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e96:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e9b:	89 c2                	mov    %eax,%edx
  800e9d:	c1 ea 16             	shr    $0x16,%edx
  800ea0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea7:	f6 c2 01             	test   $0x1,%dl
  800eaa:	74 11                	je     800ebd <fd_alloc+0x2d>
  800eac:	89 c2                	mov    %eax,%edx
  800eae:	c1 ea 0c             	shr    $0xc,%edx
  800eb1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb8:	f6 c2 01             	test   $0x1,%dl
  800ebb:	75 09                	jne    800ec6 <fd_alloc+0x36>
			*fd_store = fd;
  800ebd:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ebf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec4:	eb 17                	jmp    800edd <fd_alloc+0x4d>
  800ec6:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ecb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ed0:	75 c9                	jne    800e9b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ed2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ed8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800edd:	5d                   	pop    %ebp
  800ede:	c3                   	ret    

00800edf <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ee5:	83 f8 1f             	cmp    $0x1f,%eax
  800ee8:	77 36                	ja     800f20 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eea:	c1 e0 0c             	shl    $0xc,%eax
  800eed:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ef2:	89 c2                	mov    %eax,%edx
  800ef4:	c1 ea 16             	shr    $0x16,%edx
  800ef7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800efe:	f6 c2 01             	test   $0x1,%dl
  800f01:	74 24                	je     800f27 <fd_lookup+0x48>
  800f03:	89 c2                	mov    %eax,%edx
  800f05:	c1 ea 0c             	shr    $0xc,%edx
  800f08:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f0f:	f6 c2 01             	test   $0x1,%dl
  800f12:	74 1a                	je     800f2e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f14:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f17:	89 02                	mov    %eax,(%edx)
	return 0;
  800f19:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1e:	eb 13                	jmp    800f33 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f20:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f25:	eb 0c                	jmp    800f33 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f27:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f2c:	eb 05                	jmp    800f33 <fd_lookup+0x54>
  800f2e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    

00800f35 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	83 ec 08             	sub    $0x8,%esp
  800f3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f3e:	ba ac 27 80 00       	mov    $0x8027ac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f43:	eb 13                	jmp    800f58 <dev_lookup+0x23>
  800f45:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f48:	39 08                	cmp    %ecx,(%eax)
  800f4a:	75 0c                	jne    800f58 <dev_lookup+0x23>
			*dev = devtab[i];
  800f4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f51:	b8 00 00 00 00       	mov    $0x0,%eax
  800f56:	eb 2e                	jmp    800f86 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f58:	8b 02                	mov    (%edx),%eax
  800f5a:	85 c0                	test   %eax,%eax
  800f5c:	75 e7                	jne    800f45 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f5e:	a1 08 40 80 00       	mov    0x804008,%eax
  800f63:	8b 40 48             	mov    0x48(%eax),%eax
  800f66:	83 ec 04             	sub    $0x4,%esp
  800f69:	51                   	push   %ecx
  800f6a:	50                   	push   %eax
  800f6b:	68 2c 27 80 00       	push   $0x80272c
  800f70:	e8 bd f2 ff ff       	call   800232 <cprintf>
	*dev = 0;
  800f75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f78:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f7e:	83 c4 10             	add    $0x10,%esp
  800f81:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f86:	c9                   	leave  
  800f87:	c3                   	ret    

00800f88 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	56                   	push   %esi
  800f8c:	53                   	push   %ebx
  800f8d:	83 ec 10             	sub    $0x10,%esp
  800f90:	8b 75 08             	mov    0x8(%ebp),%esi
  800f93:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f99:	50                   	push   %eax
  800f9a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fa0:	c1 e8 0c             	shr    $0xc,%eax
  800fa3:	50                   	push   %eax
  800fa4:	e8 36 ff ff ff       	call   800edf <fd_lookup>
  800fa9:	83 c4 08             	add    $0x8,%esp
  800fac:	85 c0                	test   %eax,%eax
  800fae:	78 05                	js     800fb5 <fd_close+0x2d>
	    || fd != fd2)
  800fb0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fb3:	74 0c                	je     800fc1 <fd_close+0x39>
		return (must_exist ? r : 0);
  800fb5:	84 db                	test   %bl,%bl
  800fb7:	ba 00 00 00 00       	mov    $0x0,%edx
  800fbc:	0f 44 c2             	cmove  %edx,%eax
  800fbf:	eb 41                	jmp    801002 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fc1:	83 ec 08             	sub    $0x8,%esp
  800fc4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fc7:	50                   	push   %eax
  800fc8:	ff 36                	pushl  (%esi)
  800fca:	e8 66 ff ff ff       	call   800f35 <dev_lookup>
  800fcf:	89 c3                	mov    %eax,%ebx
  800fd1:	83 c4 10             	add    $0x10,%esp
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	78 1a                	js     800ff2 <fd_close+0x6a>
		if (dev->dev_close)
  800fd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fdb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fde:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	74 0b                	je     800ff2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fe7:	83 ec 0c             	sub    $0xc,%esp
  800fea:	56                   	push   %esi
  800feb:	ff d0                	call   *%eax
  800fed:	89 c3                	mov    %eax,%ebx
  800fef:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ff2:	83 ec 08             	sub    $0x8,%esp
  800ff5:	56                   	push   %esi
  800ff6:	6a 00                	push   $0x0
  800ff8:	e8 c1 fc ff ff       	call   800cbe <sys_page_unmap>
	return r;
  800ffd:	83 c4 10             	add    $0x10,%esp
  801000:	89 d8                	mov    %ebx,%eax
}
  801002:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801005:	5b                   	pop    %ebx
  801006:	5e                   	pop    %esi
  801007:	5d                   	pop    %ebp
  801008:	c3                   	ret    

00801009 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80100f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801012:	50                   	push   %eax
  801013:	ff 75 08             	pushl  0x8(%ebp)
  801016:	e8 c4 fe ff ff       	call   800edf <fd_lookup>
  80101b:	83 c4 08             	add    $0x8,%esp
  80101e:	85 c0                	test   %eax,%eax
  801020:	78 10                	js     801032 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801022:	83 ec 08             	sub    $0x8,%esp
  801025:	6a 01                	push   $0x1
  801027:	ff 75 f4             	pushl  -0xc(%ebp)
  80102a:	e8 59 ff ff ff       	call   800f88 <fd_close>
  80102f:	83 c4 10             	add    $0x10,%esp
}
  801032:	c9                   	leave  
  801033:	c3                   	ret    

00801034 <close_all>:

void
close_all(void)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	53                   	push   %ebx
  801038:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80103b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801040:	83 ec 0c             	sub    $0xc,%esp
  801043:	53                   	push   %ebx
  801044:	e8 c0 ff ff ff       	call   801009 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801049:	83 c3 01             	add    $0x1,%ebx
  80104c:	83 c4 10             	add    $0x10,%esp
  80104f:	83 fb 20             	cmp    $0x20,%ebx
  801052:	75 ec                	jne    801040 <close_all+0xc>
		close(i);
}
  801054:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801057:	c9                   	leave  
  801058:	c3                   	ret    

00801059 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
  80105c:	57                   	push   %edi
  80105d:	56                   	push   %esi
  80105e:	53                   	push   %ebx
  80105f:	83 ec 2c             	sub    $0x2c,%esp
  801062:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801065:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801068:	50                   	push   %eax
  801069:	ff 75 08             	pushl  0x8(%ebp)
  80106c:	e8 6e fe ff ff       	call   800edf <fd_lookup>
  801071:	83 c4 08             	add    $0x8,%esp
  801074:	85 c0                	test   %eax,%eax
  801076:	0f 88 c1 00 00 00    	js     80113d <dup+0xe4>
		return r;
	close(newfdnum);
  80107c:	83 ec 0c             	sub    $0xc,%esp
  80107f:	56                   	push   %esi
  801080:	e8 84 ff ff ff       	call   801009 <close>

	newfd = INDEX2FD(newfdnum);
  801085:	89 f3                	mov    %esi,%ebx
  801087:	c1 e3 0c             	shl    $0xc,%ebx
  80108a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801090:	83 c4 04             	add    $0x4,%esp
  801093:	ff 75 e4             	pushl  -0x1c(%ebp)
  801096:	e8 de fd ff ff       	call   800e79 <fd2data>
  80109b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80109d:	89 1c 24             	mov    %ebx,(%esp)
  8010a0:	e8 d4 fd ff ff       	call   800e79 <fd2data>
  8010a5:	83 c4 10             	add    $0x10,%esp
  8010a8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010ab:	89 f8                	mov    %edi,%eax
  8010ad:	c1 e8 16             	shr    $0x16,%eax
  8010b0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010b7:	a8 01                	test   $0x1,%al
  8010b9:	74 37                	je     8010f2 <dup+0x99>
  8010bb:	89 f8                	mov    %edi,%eax
  8010bd:	c1 e8 0c             	shr    $0xc,%eax
  8010c0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010c7:	f6 c2 01             	test   $0x1,%dl
  8010ca:	74 26                	je     8010f2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010cc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d3:	83 ec 0c             	sub    $0xc,%esp
  8010d6:	25 07 0e 00 00       	and    $0xe07,%eax
  8010db:	50                   	push   %eax
  8010dc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010df:	6a 00                	push   $0x0
  8010e1:	57                   	push   %edi
  8010e2:	6a 00                	push   $0x0
  8010e4:	e8 93 fb ff ff       	call   800c7c <sys_page_map>
  8010e9:	89 c7                	mov    %eax,%edi
  8010eb:	83 c4 20             	add    $0x20,%esp
  8010ee:	85 c0                	test   %eax,%eax
  8010f0:	78 2e                	js     801120 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010f5:	89 d0                	mov    %edx,%eax
  8010f7:	c1 e8 0c             	shr    $0xc,%eax
  8010fa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801101:	83 ec 0c             	sub    $0xc,%esp
  801104:	25 07 0e 00 00       	and    $0xe07,%eax
  801109:	50                   	push   %eax
  80110a:	53                   	push   %ebx
  80110b:	6a 00                	push   $0x0
  80110d:	52                   	push   %edx
  80110e:	6a 00                	push   $0x0
  801110:	e8 67 fb ff ff       	call   800c7c <sys_page_map>
  801115:	89 c7                	mov    %eax,%edi
  801117:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80111a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80111c:	85 ff                	test   %edi,%edi
  80111e:	79 1d                	jns    80113d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801120:	83 ec 08             	sub    $0x8,%esp
  801123:	53                   	push   %ebx
  801124:	6a 00                	push   $0x0
  801126:	e8 93 fb ff ff       	call   800cbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  80112b:	83 c4 08             	add    $0x8,%esp
  80112e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801131:	6a 00                	push   $0x0
  801133:	e8 86 fb ff ff       	call   800cbe <sys_page_unmap>
	return r;
  801138:	83 c4 10             	add    $0x10,%esp
  80113b:	89 f8                	mov    %edi,%eax
}
  80113d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801140:	5b                   	pop    %ebx
  801141:	5e                   	pop    %esi
  801142:	5f                   	pop    %edi
  801143:	5d                   	pop    %ebp
  801144:	c3                   	ret    

00801145 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	53                   	push   %ebx
  801149:	83 ec 14             	sub    $0x14,%esp
  80114c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80114f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801152:	50                   	push   %eax
  801153:	53                   	push   %ebx
  801154:	e8 86 fd ff ff       	call   800edf <fd_lookup>
  801159:	83 c4 08             	add    $0x8,%esp
  80115c:	89 c2                	mov    %eax,%edx
  80115e:	85 c0                	test   %eax,%eax
  801160:	78 6d                	js     8011cf <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801162:	83 ec 08             	sub    $0x8,%esp
  801165:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801168:	50                   	push   %eax
  801169:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116c:	ff 30                	pushl  (%eax)
  80116e:	e8 c2 fd ff ff       	call   800f35 <dev_lookup>
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	85 c0                	test   %eax,%eax
  801178:	78 4c                	js     8011c6 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80117a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80117d:	8b 42 08             	mov    0x8(%edx),%eax
  801180:	83 e0 03             	and    $0x3,%eax
  801183:	83 f8 01             	cmp    $0x1,%eax
  801186:	75 21                	jne    8011a9 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801188:	a1 08 40 80 00       	mov    0x804008,%eax
  80118d:	8b 40 48             	mov    0x48(%eax),%eax
  801190:	83 ec 04             	sub    $0x4,%esp
  801193:	53                   	push   %ebx
  801194:	50                   	push   %eax
  801195:	68 70 27 80 00       	push   $0x802770
  80119a:	e8 93 f0 ff ff       	call   800232 <cprintf>
		return -E_INVAL;
  80119f:	83 c4 10             	add    $0x10,%esp
  8011a2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011a7:	eb 26                	jmp    8011cf <read+0x8a>
	}
	if (!dev->dev_read)
  8011a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ac:	8b 40 08             	mov    0x8(%eax),%eax
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	74 17                	je     8011ca <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011b3:	83 ec 04             	sub    $0x4,%esp
  8011b6:	ff 75 10             	pushl  0x10(%ebp)
  8011b9:	ff 75 0c             	pushl  0xc(%ebp)
  8011bc:	52                   	push   %edx
  8011bd:	ff d0                	call   *%eax
  8011bf:	89 c2                	mov    %eax,%edx
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	eb 09                	jmp    8011cf <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c6:	89 c2                	mov    %eax,%edx
  8011c8:	eb 05                	jmp    8011cf <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011ca:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011cf:	89 d0                	mov    %edx,%eax
  8011d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d4:	c9                   	leave  
  8011d5:	c3                   	ret    

008011d6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	57                   	push   %edi
  8011da:	56                   	push   %esi
  8011db:	53                   	push   %ebx
  8011dc:	83 ec 0c             	sub    $0xc,%esp
  8011df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011e2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ea:	eb 21                	jmp    80120d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011ec:	83 ec 04             	sub    $0x4,%esp
  8011ef:	89 f0                	mov    %esi,%eax
  8011f1:	29 d8                	sub    %ebx,%eax
  8011f3:	50                   	push   %eax
  8011f4:	89 d8                	mov    %ebx,%eax
  8011f6:	03 45 0c             	add    0xc(%ebp),%eax
  8011f9:	50                   	push   %eax
  8011fa:	57                   	push   %edi
  8011fb:	e8 45 ff ff ff       	call   801145 <read>
		if (m < 0)
  801200:	83 c4 10             	add    $0x10,%esp
  801203:	85 c0                	test   %eax,%eax
  801205:	78 10                	js     801217 <readn+0x41>
			return m;
		if (m == 0)
  801207:	85 c0                	test   %eax,%eax
  801209:	74 0a                	je     801215 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80120b:	01 c3                	add    %eax,%ebx
  80120d:	39 f3                	cmp    %esi,%ebx
  80120f:	72 db                	jb     8011ec <readn+0x16>
  801211:	89 d8                	mov    %ebx,%eax
  801213:	eb 02                	jmp    801217 <readn+0x41>
  801215:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801217:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121a:	5b                   	pop    %ebx
  80121b:	5e                   	pop    %esi
  80121c:	5f                   	pop    %edi
  80121d:	5d                   	pop    %ebp
  80121e:	c3                   	ret    

0080121f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	53                   	push   %ebx
  801223:	83 ec 14             	sub    $0x14,%esp
  801226:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801229:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122c:	50                   	push   %eax
  80122d:	53                   	push   %ebx
  80122e:	e8 ac fc ff ff       	call   800edf <fd_lookup>
  801233:	83 c4 08             	add    $0x8,%esp
  801236:	89 c2                	mov    %eax,%edx
  801238:	85 c0                	test   %eax,%eax
  80123a:	78 68                	js     8012a4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123c:	83 ec 08             	sub    $0x8,%esp
  80123f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801242:	50                   	push   %eax
  801243:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801246:	ff 30                	pushl  (%eax)
  801248:	e8 e8 fc ff ff       	call   800f35 <dev_lookup>
  80124d:	83 c4 10             	add    $0x10,%esp
  801250:	85 c0                	test   %eax,%eax
  801252:	78 47                	js     80129b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801254:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801257:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80125b:	75 21                	jne    80127e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80125d:	a1 08 40 80 00       	mov    0x804008,%eax
  801262:	8b 40 48             	mov    0x48(%eax),%eax
  801265:	83 ec 04             	sub    $0x4,%esp
  801268:	53                   	push   %ebx
  801269:	50                   	push   %eax
  80126a:	68 8c 27 80 00       	push   $0x80278c
  80126f:	e8 be ef ff ff       	call   800232 <cprintf>
		return -E_INVAL;
  801274:	83 c4 10             	add    $0x10,%esp
  801277:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80127c:	eb 26                	jmp    8012a4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80127e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801281:	8b 52 0c             	mov    0xc(%edx),%edx
  801284:	85 d2                	test   %edx,%edx
  801286:	74 17                	je     80129f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801288:	83 ec 04             	sub    $0x4,%esp
  80128b:	ff 75 10             	pushl  0x10(%ebp)
  80128e:	ff 75 0c             	pushl  0xc(%ebp)
  801291:	50                   	push   %eax
  801292:	ff d2                	call   *%edx
  801294:	89 c2                	mov    %eax,%edx
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	eb 09                	jmp    8012a4 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80129b:	89 c2                	mov    %eax,%edx
  80129d:	eb 05                	jmp    8012a4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80129f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012a4:	89 d0                	mov    %edx,%eax
  8012a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a9:	c9                   	leave  
  8012aa:	c3                   	ret    

008012ab <seek>:

int
seek(int fdnum, off_t offset)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
  8012ae:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012b1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012b4:	50                   	push   %eax
  8012b5:	ff 75 08             	pushl  0x8(%ebp)
  8012b8:	e8 22 fc ff ff       	call   800edf <fd_lookup>
  8012bd:	83 c4 08             	add    $0x8,%esp
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	78 0e                	js     8012d2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ca:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012d2:	c9                   	leave  
  8012d3:	c3                   	ret    

008012d4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	53                   	push   %ebx
  8012d8:	83 ec 14             	sub    $0x14,%esp
  8012db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e1:	50                   	push   %eax
  8012e2:	53                   	push   %ebx
  8012e3:	e8 f7 fb ff ff       	call   800edf <fd_lookup>
  8012e8:	83 c4 08             	add    $0x8,%esp
  8012eb:	89 c2                	mov    %eax,%edx
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	78 65                	js     801356 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f1:	83 ec 08             	sub    $0x8,%esp
  8012f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f7:	50                   	push   %eax
  8012f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fb:	ff 30                	pushl  (%eax)
  8012fd:	e8 33 fc ff ff       	call   800f35 <dev_lookup>
  801302:	83 c4 10             	add    $0x10,%esp
  801305:	85 c0                	test   %eax,%eax
  801307:	78 44                	js     80134d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801309:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801310:	75 21                	jne    801333 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801312:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801317:	8b 40 48             	mov    0x48(%eax),%eax
  80131a:	83 ec 04             	sub    $0x4,%esp
  80131d:	53                   	push   %ebx
  80131e:	50                   	push   %eax
  80131f:	68 4c 27 80 00       	push   $0x80274c
  801324:	e8 09 ef ff ff       	call   800232 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801329:	83 c4 10             	add    $0x10,%esp
  80132c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801331:	eb 23                	jmp    801356 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801333:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801336:	8b 52 18             	mov    0x18(%edx),%edx
  801339:	85 d2                	test   %edx,%edx
  80133b:	74 14                	je     801351 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80133d:	83 ec 08             	sub    $0x8,%esp
  801340:	ff 75 0c             	pushl  0xc(%ebp)
  801343:	50                   	push   %eax
  801344:	ff d2                	call   *%edx
  801346:	89 c2                	mov    %eax,%edx
  801348:	83 c4 10             	add    $0x10,%esp
  80134b:	eb 09                	jmp    801356 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134d:	89 c2                	mov    %eax,%edx
  80134f:	eb 05                	jmp    801356 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801351:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801356:	89 d0                	mov    %edx,%eax
  801358:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135b:	c9                   	leave  
  80135c:	c3                   	ret    

0080135d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	53                   	push   %ebx
  801361:	83 ec 14             	sub    $0x14,%esp
  801364:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801367:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80136a:	50                   	push   %eax
  80136b:	ff 75 08             	pushl  0x8(%ebp)
  80136e:	e8 6c fb ff ff       	call   800edf <fd_lookup>
  801373:	83 c4 08             	add    $0x8,%esp
  801376:	89 c2                	mov    %eax,%edx
  801378:	85 c0                	test   %eax,%eax
  80137a:	78 58                	js     8013d4 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80137c:	83 ec 08             	sub    $0x8,%esp
  80137f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801382:	50                   	push   %eax
  801383:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801386:	ff 30                	pushl  (%eax)
  801388:	e8 a8 fb ff ff       	call   800f35 <dev_lookup>
  80138d:	83 c4 10             	add    $0x10,%esp
  801390:	85 c0                	test   %eax,%eax
  801392:	78 37                	js     8013cb <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801394:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801397:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80139b:	74 32                	je     8013cf <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80139d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013a0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013a7:	00 00 00 
	stat->st_isdir = 0;
  8013aa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013b1:	00 00 00 
	stat->st_dev = dev;
  8013b4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013ba:	83 ec 08             	sub    $0x8,%esp
  8013bd:	53                   	push   %ebx
  8013be:	ff 75 f0             	pushl  -0x10(%ebp)
  8013c1:	ff 50 14             	call   *0x14(%eax)
  8013c4:	89 c2                	mov    %eax,%edx
  8013c6:	83 c4 10             	add    $0x10,%esp
  8013c9:	eb 09                	jmp    8013d4 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013cb:	89 c2                	mov    %eax,%edx
  8013cd:	eb 05                	jmp    8013d4 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013cf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013d4:	89 d0                	mov    %edx,%eax
  8013d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d9:	c9                   	leave  
  8013da:	c3                   	ret    

008013db <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
  8013de:	56                   	push   %esi
  8013df:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013e0:	83 ec 08             	sub    $0x8,%esp
  8013e3:	6a 00                	push   $0x0
  8013e5:	ff 75 08             	pushl  0x8(%ebp)
  8013e8:	e8 e3 01 00 00       	call   8015d0 <open>
  8013ed:	89 c3                	mov    %eax,%ebx
  8013ef:	83 c4 10             	add    $0x10,%esp
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	78 1b                	js     801411 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013f6:	83 ec 08             	sub    $0x8,%esp
  8013f9:	ff 75 0c             	pushl  0xc(%ebp)
  8013fc:	50                   	push   %eax
  8013fd:	e8 5b ff ff ff       	call   80135d <fstat>
  801402:	89 c6                	mov    %eax,%esi
	close(fd);
  801404:	89 1c 24             	mov    %ebx,(%esp)
  801407:	e8 fd fb ff ff       	call   801009 <close>
	return r;
  80140c:	83 c4 10             	add    $0x10,%esp
  80140f:	89 f0                	mov    %esi,%eax
}
  801411:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801414:	5b                   	pop    %ebx
  801415:	5e                   	pop    %esi
  801416:	5d                   	pop    %ebp
  801417:	c3                   	ret    

00801418 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801418:	55                   	push   %ebp
  801419:	89 e5                	mov    %esp,%ebp
  80141b:	56                   	push   %esi
  80141c:	53                   	push   %ebx
  80141d:	89 c6                	mov    %eax,%esi
  80141f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801421:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801428:	75 12                	jne    80143c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80142a:	83 ec 0c             	sub    $0xc,%esp
  80142d:	6a 01                	push   $0x1
  80142f:	e8 43 0c 00 00       	call   802077 <ipc_find_env>
  801434:	a3 00 40 80 00       	mov    %eax,0x804000
  801439:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80143c:	6a 07                	push   $0x7
  80143e:	68 00 50 80 00       	push   $0x805000
  801443:	56                   	push   %esi
  801444:	ff 35 00 40 80 00    	pushl  0x804000
  80144a:	e8 d4 0b 00 00       	call   802023 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80144f:	83 c4 0c             	add    $0xc,%esp
  801452:	6a 00                	push   $0x0
  801454:	53                   	push   %ebx
  801455:	6a 00                	push   $0x0
  801457:	e8 5e 0b 00 00       	call   801fba <ipc_recv>
}
  80145c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80145f:	5b                   	pop    %ebx
  801460:	5e                   	pop    %esi
  801461:	5d                   	pop    %ebp
  801462:	c3                   	ret    

00801463 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801463:	55                   	push   %ebp
  801464:	89 e5                	mov    %esp,%ebp
  801466:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801469:	8b 45 08             	mov    0x8(%ebp),%eax
  80146c:	8b 40 0c             	mov    0xc(%eax),%eax
  80146f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801474:	8b 45 0c             	mov    0xc(%ebp),%eax
  801477:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80147c:	ba 00 00 00 00       	mov    $0x0,%edx
  801481:	b8 02 00 00 00       	mov    $0x2,%eax
  801486:	e8 8d ff ff ff       	call   801418 <fsipc>
}
  80148b:	c9                   	leave  
  80148c:	c3                   	ret    

0080148d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80148d:	55                   	push   %ebp
  80148e:	89 e5                	mov    %esp,%ebp
  801490:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801493:	8b 45 08             	mov    0x8(%ebp),%eax
  801496:	8b 40 0c             	mov    0xc(%eax),%eax
  801499:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80149e:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a3:	b8 06 00 00 00       	mov    $0x6,%eax
  8014a8:	e8 6b ff ff ff       	call   801418 <fsipc>
}
  8014ad:	c9                   	leave  
  8014ae:	c3                   	ret    

008014af <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014af:	55                   	push   %ebp
  8014b0:	89 e5                	mov    %esp,%ebp
  8014b2:	53                   	push   %ebx
  8014b3:	83 ec 04             	sub    $0x4,%esp
  8014b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8014bf:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c9:	b8 05 00 00 00       	mov    $0x5,%eax
  8014ce:	e8 45 ff ff ff       	call   801418 <fsipc>
  8014d3:	85 c0                	test   %eax,%eax
  8014d5:	78 2c                	js     801503 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014d7:	83 ec 08             	sub    $0x8,%esp
  8014da:	68 00 50 80 00       	push   $0x805000
  8014df:	53                   	push   %ebx
  8014e0:	e8 51 f3 ff ff       	call   800836 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014e5:	a1 80 50 80 00       	mov    0x805080,%eax
  8014ea:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014f0:	a1 84 50 80 00       	mov    0x805084,%eax
  8014f5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014fb:	83 c4 10             	add    $0x10,%esp
  8014fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801503:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801506:	c9                   	leave  
  801507:	c3                   	ret    

00801508 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	83 ec 0c             	sub    $0xc,%esp
  80150e:	8b 45 10             	mov    0x10(%ebp),%eax
  801511:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801516:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80151b:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80151e:	8b 55 08             	mov    0x8(%ebp),%edx
  801521:	8b 52 0c             	mov    0xc(%edx),%edx
  801524:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80152a:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80152f:	50                   	push   %eax
  801530:	ff 75 0c             	pushl  0xc(%ebp)
  801533:	68 08 50 80 00       	push   $0x805008
  801538:	e8 8b f4 ff ff       	call   8009c8 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80153d:	ba 00 00 00 00       	mov    $0x0,%edx
  801542:	b8 04 00 00 00       	mov    $0x4,%eax
  801547:	e8 cc fe ff ff       	call   801418 <fsipc>
	//panic("devfile_write not implemented");
}
  80154c:	c9                   	leave  
  80154d:	c3                   	ret    

0080154e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80154e:	55                   	push   %ebp
  80154f:	89 e5                	mov    %esp,%ebp
  801551:	56                   	push   %esi
  801552:	53                   	push   %ebx
  801553:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801556:	8b 45 08             	mov    0x8(%ebp),%eax
  801559:	8b 40 0c             	mov    0xc(%eax),%eax
  80155c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801561:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801567:	ba 00 00 00 00       	mov    $0x0,%edx
  80156c:	b8 03 00 00 00       	mov    $0x3,%eax
  801571:	e8 a2 fe ff ff       	call   801418 <fsipc>
  801576:	89 c3                	mov    %eax,%ebx
  801578:	85 c0                	test   %eax,%eax
  80157a:	78 4b                	js     8015c7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80157c:	39 c6                	cmp    %eax,%esi
  80157e:	73 16                	jae    801596 <devfile_read+0x48>
  801580:	68 c0 27 80 00       	push   $0x8027c0
  801585:	68 c7 27 80 00       	push   $0x8027c7
  80158a:	6a 7c                	push   $0x7c
  80158c:	68 dc 27 80 00       	push   $0x8027dc
  801591:	e8 c3 eb ff ff       	call   800159 <_panic>
	assert(r <= PGSIZE);
  801596:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80159b:	7e 16                	jle    8015b3 <devfile_read+0x65>
  80159d:	68 e7 27 80 00       	push   $0x8027e7
  8015a2:	68 c7 27 80 00       	push   $0x8027c7
  8015a7:	6a 7d                	push   $0x7d
  8015a9:	68 dc 27 80 00       	push   $0x8027dc
  8015ae:	e8 a6 eb ff ff       	call   800159 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015b3:	83 ec 04             	sub    $0x4,%esp
  8015b6:	50                   	push   %eax
  8015b7:	68 00 50 80 00       	push   $0x805000
  8015bc:	ff 75 0c             	pushl  0xc(%ebp)
  8015bf:	e8 04 f4 ff ff       	call   8009c8 <memmove>
	return r;
  8015c4:	83 c4 10             	add    $0x10,%esp
}
  8015c7:	89 d8                	mov    %ebx,%eax
  8015c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015cc:	5b                   	pop    %ebx
  8015cd:	5e                   	pop    %esi
  8015ce:	5d                   	pop    %ebp
  8015cf:	c3                   	ret    

008015d0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	53                   	push   %ebx
  8015d4:	83 ec 20             	sub    $0x20,%esp
  8015d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015da:	53                   	push   %ebx
  8015db:	e8 1d f2 ff ff       	call   8007fd <strlen>
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015e8:	7f 67                	jg     801651 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015ea:	83 ec 0c             	sub    $0xc,%esp
  8015ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f0:	50                   	push   %eax
  8015f1:	e8 9a f8 ff ff       	call   800e90 <fd_alloc>
  8015f6:	83 c4 10             	add    $0x10,%esp
		return r;
  8015f9:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	78 57                	js     801656 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015ff:	83 ec 08             	sub    $0x8,%esp
  801602:	53                   	push   %ebx
  801603:	68 00 50 80 00       	push   $0x805000
  801608:	e8 29 f2 ff ff       	call   800836 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80160d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801610:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801615:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801618:	b8 01 00 00 00       	mov    $0x1,%eax
  80161d:	e8 f6 fd ff ff       	call   801418 <fsipc>
  801622:	89 c3                	mov    %eax,%ebx
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	85 c0                	test   %eax,%eax
  801629:	79 14                	jns    80163f <open+0x6f>
		fd_close(fd, 0);
  80162b:	83 ec 08             	sub    $0x8,%esp
  80162e:	6a 00                	push   $0x0
  801630:	ff 75 f4             	pushl  -0xc(%ebp)
  801633:	e8 50 f9 ff ff       	call   800f88 <fd_close>
		return r;
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	89 da                	mov    %ebx,%edx
  80163d:	eb 17                	jmp    801656 <open+0x86>
	}

	return fd2num(fd);
  80163f:	83 ec 0c             	sub    $0xc,%esp
  801642:	ff 75 f4             	pushl  -0xc(%ebp)
  801645:	e8 1f f8 ff ff       	call   800e69 <fd2num>
  80164a:	89 c2                	mov    %eax,%edx
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	eb 05                	jmp    801656 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801651:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801656:	89 d0                	mov    %edx,%eax
  801658:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165b:	c9                   	leave  
  80165c:	c3                   	ret    

0080165d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80165d:	55                   	push   %ebp
  80165e:	89 e5                	mov    %esp,%ebp
  801660:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801663:	ba 00 00 00 00       	mov    $0x0,%edx
  801668:	b8 08 00 00 00       	mov    $0x8,%eax
  80166d:	e8 a6 fd ff ff       	call   801418 <fsipc>
}
  801672:	c9                   	leave  
  801673:	c3                   	ret    

00801674 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80167a:	68 f3 27 80 00       	push   $0x8027f3
  80167f:	ff 75 0c             	pushl  0xc(%ebp)
  801682:	e8 af f1 ff ff       	call   800836 <strcpy>
	return 0;
}
  801687:	b8 00 00 00 00       	mov    $0x0,%eax
  80168c:	c9                   	leave  
  80168d:	c3                   	ret    

0080168e <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	53                   	push   %ebx
  801692:	83 ec 10             	sub    $0x10,%esp
  801695:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801698:	53                   	push   %ebx
  801699:	e8 12 0a 00 00       	call   8020b0 <pageref>
  80169e:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8016a1:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8016a6:	83 f8 01             	cmp    $0x1,%eax
  8016a9:	75 10                	jne    8016bb <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8016ab:	83 ec 0c             	sub    $0xc,%esp
  8016ae:	ff 73 0c             	pushl  0xc(%ebx)
  8016b1:	e8 c0 02 00 00       	call   801976 <nsipc_close>
  8016b6:	89 c2                	mov    %eax,%edx
  8016b8:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8016bb:	89 d0                	mov    %edx,%eax
  8016bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c0:	c9                   	leave  
  8016c1:	c3                   	ret    

008016c2 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8016c8:	6a 00                	push   $0x0
  8016ca:	ff 75 10             	pushl  0x10(%ebp)
  8016cd:	ff 75 0c             	pushl  0xc(%ebp)
  8016d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d3:	ff 70 0c             	pushl  0xc(%eax)
  8016d6:	e8 78 03 00 00       	call   801a53 <nsipc_send>
}
  8016db:	c9                   	leave  
  8016dc:	c3                   	ret    

008016dd <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8016dd:	55                   	push   %ebp
  8016de:	89 e5                	mov    %esp,%ebp
  8016e0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8016e3:	6a 00                	push   $0x0
  8016e5:	ff 75 10             	pushl  0x10(%ebp)
  8016e8:	ff 75 0c             	pushl  0xc(%ebp)
  8016eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ee:	ff 70 0c             	pushl  0xc(%eax)
  8016f1:	e8 f1 02 00 00       	call   8019e7 <nsipc_recv>
}
  8016f6:	c9                   	leave  
  8016f7:	c3                   	ret    

008016f8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8016fe:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801701:	52                   	push   %edx
  801702:	50                   	push   %eax
  801703:	e8 d7 f7 ff ff       	call   800edf <fd_lookup>
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	85 c0                	test   %eax,%eax
  80170d:	78 17                	js     801726 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80170f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801712:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801718:	39 08                	cmp    %ecx,(%eax)
  80171a:	75 05                	jne    801721 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80171c:	8b 40 0c             	mov    0xc(%eax),%eax
  80171f:	eb 05                	jmp    801726 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801721:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801726:	c9                   	leave  
  801727:	c3                   	ret    

00801728 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	56                   	push   %esi
  80172c:	53                   	push   %ebx
  80172d:	83 ec 1c             	sub    $0x1c,%esp
  801730:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801732:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801735:	50                   	push   %eax
  801736:	e8 55 f7 ff ff       	call   800e90 <fd_alloc>
  80173b:	89 c3                	mov    %eax,%ebx
  80173d:	83 c4 10             	add    $0x10,%esp
  801740:	85 c0                	test   %eax,%eax
  801742:	78 1b                	js     80175f <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801744:	83 ec 04             	sub    $0x4,%esp
  801747:	68 07 04 00 00       	push   $0x407
  80174c:	ff 75 f4             	pushl  -0xc(%ebp)
  80174f:	6a 00                	push   $0x0
  801751:	e8 e3 f4 ff ff       	call   800c39 <sys_page_alloc>
  801756:	89 c3                	mov    %eax,%ebx
  801758:	83 c4 10             	add    $0x10,%esp
  80175b:	85 c0                	test   %eax,%eax
  80175d:	79 10                	jns    80176f <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80175f:	83 ec 0c             	sub    $0xc,%esp
  801762:	56                   	push   %esi
  801763:	e8 0e 02 00 00       	call   801976 <nsipc_close>
		return r;
  801768:	83 c4 10             	add    $0x10,%esp
  80176b:	89 d8                	mov    %ebx,%eax
  80176d:	eb 24                	jmp    801793 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80176f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801775:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801778:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80177a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80177d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801784:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801787:	83 ec 0c             	sub    $0xc,%esp
  80178a:	50                   	push   %eax
  80178b:	e8 d9 f6 ff ff       	call   800e69 <fd2num>
  801790:	83 c4 10             	add    $0x10,%esp
}
  801793:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801796:	5b                   	pop    %ebx
  801797:	5e                   	pop    %esi
  801798:	5d                   	pop    %ebp
  801799:	c3                   	ret    

0080179a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a3:	e8 50 ff ff ff       	call   8016f8 <fd2sockid>
		return r;
  8017a8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017aa:	85 c0                	test   %eax,%eax
  8017ac:	78 1f                	js     8017cd <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017ae:	83 ec 04             	sub    $0x4,%esp
  8017b1:	ff 75 10             	pushl  0x10(%ebp)
  8017b4:	ff 75 0c             	pushl  0xc(%ebp)
  8017b7:	50                   	push   %eax
  8017b8:	e8 12 01 00 00       	call   8018cf <nsipc_accept>
  8017bd:	83 c4 10             	add    $0x10,%esp
		return r;
  8017c0:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017c2:	85 c0                	test   %eax,%eax
  8017c4:	78 07                	js     8017cd <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8017c6:	e8 5d ff ff ff       	call   801728 <alloc_sockfd>
  8017cb:	89 c1                	mov    %eax,%ecx
}
  8017cd:	89 c8                	mov    %ecx,%eax
  8017cf:	c9                   	leave  
  8017d0:	c3                   	ret    

008017d1 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017d1:	55                   	push   %ebp
  8017d2:	89 e5                	mov    %esp,%ebp
  8017d4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017da:	e8 19 ff ff ff       	call   8016f8 <fd2sockid>
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	78 12                	js     8017f5 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8017e3:	83 ec 04             	sub    $0x4,%esp
  8017e6:	ff 75 10             	pushl  0x10(%ebp)
  8017e9:	ff 75 0c             	pushl  0xc(%ebp)
  8017ec:	50                   	push   %eax
  8017ed:	e8 2d 01 00 00       	call   80191f <nsipc_bind>
  8017f2:	83 c4 10             	add    $0x10,%esp
}
  8017f5:	c9                   	leave  
  8017f6:	c3                   	ret    

008017f7 <shutdown>:

int
shutdown(int s, int how)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801800:	e8 f3 fe ff ff       	call   8016f8 <fd2sockid>
  801805:	85 c0                	test   %eax,%eax
  801807:	78 0f                	js     801818 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801809:	83 ec 08             	sub    $0x8,%esp
  80180c:	ff 75 0c             	pushl  0xc(%ebp)
  80180f:	50                   	push   %eax
  801810:	e8 3f 01 00 00       	call   801954 <nsipc_shutdown>
  801815:	83 c4 10             	add    $0x10,%esp
}
  801818:	c9                   	leave  
  801819:	c3                   	ret    

0080181a <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801820:	8b 45 08             	mov    0x8(%ebp),%eax
  801823:	e8 d0 fe ff ff       	call   8016f8 <fd2sockid>
  801828:	85 c0                	test   %eax,%eax
  80182a:	78 12                	js     80183e <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80182c:	83 ec 04             	sub    $0x4,%esp
  80182f:	ff 75 10             	pushl  0x10(%ebp)
  801832:	ff 75 0c             	pushl  0xc(%ebp)
  801835:	50                   	push   %eax
  801836:	e8 55 01 00 00       	call   801990 <nsipc_connect>
  80183b:	83 c4 10             	add    $0x10,%esp
}
  80183e:	c9                   	leave  
  80183f:	c3                   	ret    

00801840 <listen>:

int
listen(int s, int backlog)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801846:	8b 45 08             	mov    0x8(%ebp),%eax
  801849:	e8 aa fe ff ff       	call   8016f8 <fd2sockid>
  80184e:	85 c0                	test   %eax,%eax
  801850:	78 0f                	js     801861 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801852:	83 ec 08             	sub    $0x8,%esp
  801855:	ff 75 0c             	pushl  0xc(%ebp)
  801858:	50                   	push   %eax
  801859:	e8 67 01 00 00       	call   8019c5 <nsipc_listen>
  80185e:	83 c4 10             	add    $0x10,%esp
}
  801861:	c9                   	leave  
  801862:	c3                   	ret    

00801863 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801869:	ff 75 10             	pushl  0x10(%ebp)
  80186c:	ff 75 0c             	pushl  0xc(%ebp)
  80186f:	ff 75 08             	pushl  0x8(%ebp)
  801872:	e8 3a 02 00 00       	call   801ab1 <nsipc_socket>
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	85 c0                	test   %eax,%eax
  80187c:	78 05                	js     801883 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80187e:	e8 a5 fe ff ff       	call   801728 <alloc_sockfd>
}
  801883:	c9                   	leave  
  801884:	c3                   	ret    

00801885 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	53                   	push   %ebx
  801889:	83 ec 04             	sub    $0x4,%esp
  80188c:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80188e:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801895:	75 12                	jne    8018a9 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801897:	83 ec 0c             	sub    $0xc,%esp
  80189a:	6a 02                	push   $0x2
  80189c:	e8 d6 07 00 00       	call   802077 <ipc_find_env>
  8018a1:	a3 04 40 80 00       	mov    %eax,0x804004
  8018a6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8018a9:	6a 07                	push   $0x7
  8018ab:	68 00 60 80 00       	push   $0x806000
  8018b0:	53                   	push   %ebx
  8018b1:	ff 35 04 40 80 00    	pushl  0x804004
  8018b7:	e8 67 07 00 00       	call   802023 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8018bc:	83 c4 0c             	add    $0xc,%esp
  8018bf:	6a 00                	push   $0x0
  8018c1:	6a 00                	push   $0x0
  8018c3:	6a 00                	push   $0x0
  8018c5:	e8 f0 06 00 00       	call   801fba <ipc_recv>
}
  8018ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018cd:	c9                   	leave  
  8018ce:	c3                   	ret    

008018cf <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	56                   	push   %esi
  8018d3:	53                   	push   %ebx
  8018d4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8018d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018da:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8018df:	8b 06                	mov    (%esi),%eax
  8018e1:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8018e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8018eb:	e8 95 ff ff ff       	call   801885 <nsipc>
  8018f0:	89 c3                	mov    %eax,%ebx
  8018f2:	85 c0                	test   %eax,%eax
  8018f4:	78 20                	js     801916 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8018f6:	83 ec 04             	sub    $0x4,%esp
  8018f9:	ff 35 10 60 80 00    	pushl  0x806010
  8018ff:	68 00 60 80 00       	push   $0x806000
  801904:	ff 75 0c             	pushl  0xc(%ebp)
  801907:	e8 bc f0 ff ff       	call   8009c8 <memmove>
		*addrlen = ret->ret_addrlen;
  80190c:	a1 10 60 80 00       	mov    0x806010,%eax
  801911:	89 06                	mov    %eax,(%esi)
  801913:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801916:	89 d8                	mov    %ebx,%eax
  801918:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191b:	5b                   	pop    %ebx
  80191c:	5e                   	pop    %esi
  80191d:	5d                   	pop    %ebp
  80191e:	c3                   	ret    

0080191f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	53                   	push   %ebx
  801923:	83 ec 08             	sub    $0x8,%esp
  801926:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801929:	8b 45 08             	mov    0x8(%ebp),%eax
  80192c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801931:	53                   	push   %ebx
  801932:	ff 75 0c             	pushl  0xc(%ebp)
  801935:	68 04 60 80 00       	push   $0x806004
  80193a:	e8 89 f0 ff ff       	call   8009c8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80193f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801945:	b8 02 00 00 00       	mov    $0x2,%eax
  80194a:	e8 36 ff ff ff       	call   801885 <nsipc>
}
  80194f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801952:	c9                   	leave  
  801953:	c3                   	ret    

00801954 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80195a:	8b 45 08             	mov    0x8(%ebp),%eax
  80195d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801962:	8b 45 0c             	mov    0xc(%ebp),%eax
  801965:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  80196a:	b8 03 00 00 00       	mov    $0x3,%eax
  80196f:	e8 11 ff ff ff       	call   801885 <nsipc>
}
  801974:	c9                   	leave  
  801975:	c3                   	ret    

00801976 <nsipc_close>:

int
nsipc_close(int s)
{
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80197c:	8b 45 08             	mov    0x8(%ebp),%eax
  80197f:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801984:	b8 04 00 00 00       	mov    $0x4,%eax
  801989:	e8 f7 fe ff ff       	call   801885 <nsipc>
}
  80198e:	c9                   	leave  
  80198f:	c3                   	ret    

00801990 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	53                   	push   %ebx
  801994:	83 ec 08             	sub    $0x8,%esp
  801997:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80199a:	8b 45 08             	mov    0x8(%ebp),%eax
  80199d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8019a2:	53                   	push   %ebx
  8019a3:	ff 75 0c             	pushl  0xc(%ebp)
  8019a6:	68 04 60 80 00       	push   $0x806004
  8019ab:	e8 18 f0 ff ff       	call   8009c8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8019b0:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8019b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8019bb:	e8 c5 fe ff ff       	call   801885 <nsipc>
}
  8019c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c3:	c9                   	leave  
  8019c4:	c3                   	ret    

008019c5 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8019c5:	55                   	push   %ebp
  8019c6:	89 e5                	mov    %esp,%ebp
  8019c8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8019cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ce:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8019d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d6:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8019db:	b8 06 00 00 00       	mov    $0x6,%eax
  8019e0:	e8 a0 fe ff ff       	call   801885 <nsipc>
}
  8019e5:	c9                   	leave  
  8019e6:	c3                   	ret    

008019e7 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	56                   	push   %esi
  8019eb:	53                   	push   %ebx
  8019ec:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8019ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8019f7:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8019fd:	8b 45 14             	mov    0x14(%ebp),%eax
  801a00:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a05:	b8 07 00 00 00       	mov    $0x7,%eax
  801a0a:	e8 76 fe ff ff       	call   801885 <nsipc>
  801a0f:	89 c3                	mov    %eax,%ebx
  801a11:	85 c0                	test   %eax,%eax
  801a13:	78 35                	js     801a4a <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801a15:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801a1a:	7f 04                	jg     801a20 <nsipc_recv+0x39>
  801a1c:	39 c6                	cmp    %eax,%esi
  801a1e:	7d 16                	jge    801a36 <nsipc_recv+0x4f>
  801a20:	68 ff 27 80 00       	push   $0x8027ff
  801a25:	68 c7 27 80 00       	push   $0x8027c7
  801a2a:	6a 62                	push   $0x62
  801a2c:	68 14 28 80 00       	push   $0x802814
  801a31:	e8 23 e7 ff ff       	call   800159 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a36:	83 ec 04             	sub    $0x4,%esp
  801a39:	50                   	push   %eax
  801a3a:	68 00 60 80 00       	push   $0x806000
  801a3f:	ff 75 0c             	pushl  0xc(%ebp)
  801a42:	e8 81 ef ff ff       	call   8009c8 <memmove>
  801a47:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a4a:	89 d8                	mov    %ebx,%eax
  801a4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a4f:	5b                   	pop    %ebx
  801a50:	5e                   	pop    %esi
  801a51:	5d                   	pop    %ebp
  801a52:	c3                   	ret    

00801a53 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	53                   	push   %ebx
  801a57:	83 ec 04             	sub    $0x4,%esp
  801a5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a60:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801a65:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a6b:	7e 16                	jle    801a83 <nsipc_send+0x30>
  801a6d:	68 20 28 80 00       	push   $0x802820
  801a72:	68 c7 27 80 00       	push   $0x8027c7
  801a77:	6a 6d                	push   $0x6d
  801a79:	68 14 28 80 00       	push   $0x802814
  801a7e:	e8 d6 e6 ff ff       	call   800159 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a83:	83 ec 04             	sub    $0x4,%esp
  801a86:	53                   	push   %ebx
  801a87:	ff 75 0c             	pushl  0xc(%ebp)
  801a8a:	68 0c 60 80 00       	push   $0x80600c
  801a8f:	e8 34 ef ff ff       	call   8009c8 <memmove>
	nsipcbuf.send.req_size = size;
  801a94:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801a9a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a9d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801aa2:	b8 08 00 00 00       	mov    $0x8,%eax
  801aa7:	e8 d9 fd ff ff       	call   801885 <nsipc>
}
  801aac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aaf:	c9                   	leave  
  801ab0:	c3                   	ret    

00801ab1 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aba:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801abf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac2:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ac7:	8b 45 10             	mov    0x10(%ebp),%eax
  801aca:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801acf:	b8 09 00 00 00       	mov    $0x9,%eax
  801ad4:	e8 ac fd ff ff       	call   801885 <nsipc>
}
  801ad9:	c9                   	leave  
  801ada:	c3                   	ret    

00801adb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	56                   	push   %esi
  801adf:	53                   	push   %ebx
  801ae0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ae3:	83 ec 0c             	sub    $0xc,%esp
  801ae6:	ff 75 08             	pushl  0x8(%ebp)
  801ae9:	e8 8b f3 ff ff       	call   800e79 <fd2data>
  801aee:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801af0:	83 c4 08             	add    $0x8,%esp
  801af3:	68 2c 28 80 00       	push   $0x80282c
  801af8:	53                   	push   %ebx
  801af9:	e8 38 ed ff ff       	call   800836 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801afe:	8b 46 04             	mov    0x4(%esi),%eax
  801b01:	2b 06                	sub    (%esi),%eax
  801b03:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b09:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b10:	00 00 00 
	stat->st_dev = &devpipe;
  801b13:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b1a:	30 80 00 
	return 0;
}
  801b1d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b25:	5b                   	pop    %ebx
  801b26:	5e                   	pop    %esi
  801b27:	5d                   	pop    %ebp
  801b28:	c3                   	ret    

00801b29 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	53                   	push   %ebx
  801b2d:	83 ec 0c             	sub    $0xc,%esp
  801b30:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b33:	53                   	push   %ebx
  801b34:	6a 00                	push   $0x0
  801b36:	e8 83 f1 ff ff       	call   800cbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b3b:	89 1c 24             	mov    %ebx,(%esp)
  801b3e:	e8 36 f3 ff ff       	call   800e79 <fd2data>
  801b43:	83 c4 08             	add    $0x8,%esp
  801b46:	50                   	push   %eax
  801b47:	6a 00                	push   $0x0
  801b49:	e8 70 f1 ff ff       	call   800cbe <sys_page_unmap>
}
  801b4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b51:	c9                   	leave  
  801b52:	c3                   	ret    

00801b53 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	57                   	push   %edi
  801b57:	56                   	push   %esi
  801b58:	53                   	push   %ebx
  801b59:	83 ec 1c             	sub    $0x1c,%esp
  801b5c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b5f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b61:	a1 08 40 80 00       	mov    0x804008,%eax
  801b66:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b69:	83 ec 0c             	sub    $0xc,%esp
  801b6c:	ff 75 e0             	pushl  -0x20(%ebp)
  801b6f:	e8 3c 05 00 00       	call   8020b0 <pageref>
  801b74:	89 c3                	mov    %eax,%ebx
  801b76:	89 3c 24             	mov    %edi,(%esp)
  801b79:	e8 32 05 00 00       	call   8020b0 <pageref>
  801b7e:	83 c4 10             	add    $0x10,%esp
  801b81:	39 c3                	cmp    %eax,%ebx
  801b83:	0f 94 c1             	sete   %cl
  801b86:	0f b6 c9             	movzbl %cl,%ecx
  801b89:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b8c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b92:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b95:	39 ce                	cmp    %ecx,%esi
  801b97:	74 1b                	je     801bb4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b99:	39 c3                	cmp    %eax,%ebx
  801b9b:	75 c4                	jne    801b61 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b9d:	8b 42 58             	mov    0x58(%edx),%eax
  801ba0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ba3:	50                   	push   %eax
  801ba4:	56                   	push   %esi
  801ba5:	68 33 28 80 00       	push   $0x802833
  801baa:	e8 83 e6 ff ff       	call   800232 <cprintf>
  801baf:	83 c4 10             	add    $0x10,%esp
  801bb2:	eb ad                	jmp    801b61 <_pipeisclosed+0xe>
	}
}
  801bb4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bba:	5b                   	pop    %ebx
  801bbb:	5e                   	pop    %esi
  801bbc:	5f                   	pop    %edi
  801bbd:	5d                   	pop    %ebp
  801bbe:	c3                   	ret    

00801bbf <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bbf:	55                   	push   %ebp
  801bc0:	89 e5                	mov    %esp,%ebp
  801bc2:	57                   	push   %edi
  801bc3:	56                   	push   %esi
  801bc4:	53                   	push   %ebx
  801bc5:	83 ec 28             	sub    $0x28,%esp
  801bc8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bcb:	56                   	push   %esi
  801bcc:	e8 a8 f2 ff ff       	call   800e79 <fd2data>
  801bd1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd3:	83 c4 10             	add    $0x10,%esp
  801bd6:	bf 00 00 00 00       	mov    $0x0,%edi
  801bdb:	eb 4b                	jmp    801c28 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bdd:	89 da                	mov    %ebx,%edx
  801bdf:	89 f0                	mov    %esi,%eax
  801be1:	e8 6d ff ff ff       	call   801b53 <_pipeisclosed>
  801be6:	85 c0                	test   %eax,%eax
  801be8:	75 48                	jne    801c32 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bea:	e8 2b f0 ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bef:	8b 43 04             	mov    0x4(%ebx),%eax
  801bf2:	8b 0b                	mov    (%ebx),%ecx
  801bf4:	8d 51 20             	lea    0x20(%ecx),%edx
  801bf7:	39 d0                	cmp    %edx,%eax
  801bf9:	73 e2                	jae    801bdd <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bfe:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c02:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c05:	89 c2                	mov    %eax,%edx
  801c07:	c1 fa 1f             	sar    $0x1f,%edx
  801c0a:	89 d1                	mov    %edx,%ecx
  801c0c:	c1 e9 1b             	shr    $0x1b,%ecx
  801c0f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c12:	83 e2 1f             	and    $0x1f,%edx
  801c15:	29 ca                	sub    %ecx,%edx
  801c17:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c1b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c1f:	83 c0 01             	add    $0x1,%eax
  801c22:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c25:	83 c7 01             	add    $0x1,%edi
  801c28:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c2b:	75 c2                	jne    801bef <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c2d:	8b 45 10             	mov    0x10(%ebp),%eax
  801c30:	eb 05                	jmp    801c37 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c32:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c3a:	5b                   	pop    %ebx
  801c3b:	5e                   	pop    %esi
  801c3c:	5f                   	pop    %edi
  801c3d:	5d                   	pop    %ebp
  801c3e:	c3                   	ret    

00801c3f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c3f:	55                   	push   %ebp
  801c40:	89 e5                	mov    %esp,%ebp
  801c42:	57                   	push   %edi
  801c43:	56                   	push   %esi
  801c44:	53                   	push   %ebx
  801c45:	83 ec 18             	sub    $0x18,%esp
  801c48:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c4b:	57                   	push   %edi
  801c4c:	e8 28 f2 ff ff       	call   800e79 <fd2data>
  801c51:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c53:	83 c4 10             	add    $0x10,%esp
  801c56:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c5b:	eb 3d                	jmp    801c9a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c5d:	85 db                	test   %ebx,%ebx
  801c5f:	74 04                	je     801c65 <devpipe_read+0x26>
				return i;
  801c61:	89 d8                	mov    %ebx,%eax
  801c63:	eb 44                	jmp    801ca9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c65:	89 f2                	mov    %esi,%edx
  801c67:	89 f8                	mov    %edi,%eax
  801c69:	e8 e5 fe ff ff       	call   801b53 <_pipeisclosed>
  801c6e:	85 c0                	test   %eax,%eax
  801c70:	75 32                	jne    801ca4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c72:	e8 a3 ef ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c77:	8b 06                	mov    (%esi),%eax
  801c79:	3b 46 04             	cmp    0x4(%esi),%eax
  801c7c:	74 df                	je     801c5d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c7e:	99                   	cltd   
  801c7f:	c1 ea 1b             	shr    $0x1b,%edx
  801c82:	01 d0                	add    %edx,%eax
  801c84:	83 e0 1f             	and    $0x1f,%eax
  801c87:	29 d0                	sub    %edx,%eax
  801c89:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c91:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c94:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c97:	83 c3 01             	add    $0x1,%ebx
  801c9a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c9d:	75 d8                	jne    801c77 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c9f:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca2:	eb 05                	jmp    801ca9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ca4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ca9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cac:	5b                   	pop    %ebx
  801cad:	5e                   	pop    %esi
  801cae:	5f                   	pop    %edi
  801caf:	5d                   	pop    %ebp
  801cb0:	c3                   	ret    

00801cb1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	56                   	push   %esi
  801cb5:	53                   	push   %ebx
  801cb6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbc:	50                   	push   %eax
  801cbd:	e8 ce f1 ff ff       	call   800e90 <fd_alloc>
  801cc2:	83 c4 10             	add    $0x10,%esp
  801cc5:	89 c2                	mov    %eax,%edx
  801cc7:	85 c0                	test   %eax,%eax
  801cc9:	0f 88 2c 01 00 00    	js     801dfb <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ccf:	83 ec 04             	sub    $0x4,%esp
  801cd2:	68 07 04 00 00       	push   $0x407
  801cd7:	ff 75 f4             	pushl  -0xc(%ebp)
  801cda:	6a 00                	push   $0x0
  801cdc:	e8 58 ef ff ff       	call   800c39 <sys_page_alloc>
  801ce1:	83 c4 10             	add    $0x10,%esp
  801ce4:	89 c2                	mov    %eax,%edx
  801ce6:	85 c0                	test   %eax,%eax
  801ce8:	0f 88 0d 01 00 00    	js     801dfb <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cee:	83 ec 0c             	sub    $0xc,%esp
  801cf1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cf4:	50                   	push   %eax
  801cf5:	e8 96 f1 ff ff       	call   800e90 <fd_alloc>
  801cfa:	89 c3                	mov    %eax,%ebx
  801cfc:	83 c4 10             	add    $0x10,%esp
  801cff:	85 c0                	test   %eax,%eax
  801d01:	0f 88 e2 00 00 00    	js     801de9 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d07:	83 ec 04             	sub    $0x4,%esp
  801d0a:	68 07 04 00 00       	push   $0x407
  801d0f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d12:	6a 00                	push   $0x0
  801d14:	e8 20 ef ff ff       	call   800c39 <sys_page_alloc>
  801d19:	89 c3                	mov    %eax,%ebx
  801d1b:	83 c4 10             	add    $0x10,%esp
  801d1e:	85 c0                	test   %eax,%eax
  801d20:	0f 88 c3 00 00 00    	js     801de9 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d26:	83 ec 0c             	sub    $0xc,%esp
  801d29:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2c:	e8 48 f1 ff ff       	call   800e79 <fd2data>
  801d31:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d33:	83 c4 0c             	add    $0xc,%esp
  801d36:	68 07 04 00 00       	push   $0x407
  801d3b:	50                   	push   %eax
  801d3c:	6a 00                	push   $0x0
  801d3e:	e8 f6 ee ff ff       	call   800c39 <sys_page_alloc>
  801d43:	89 c3                	mov    %eax,%ebx
  801d45:	83 c4 10             	add    $0x10,%esp
  801d48:	85 c0                	test   %eax,%eax
  801d4a:	0f 88 89 00 00 00    	js     801dd9 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d50:	83 ec 0c             	sub    $0xc,%esp
  801d53:	ff 75 f0             	pushl  -0x10(%ebp)
  801d56:	e8 1e f1 ff ff       	call   800e79 <fd2data>
  801d5b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d62:	50                   	push   %eax
  801d63:	6a 00                	push   $0x0
  801d65:	56                   	push   %esi
  801d66:	6a 00                	push   $0x0
  801d68:	e8 0f ef ff ff       	call   800c7c <sys_page_map>
  801d6d:	89 c3                	mov    %eax,%ebx
  801d6f:	83 c4 20             	add    $0x20,%esp
  801d72:	85 c0                	test   %eax,%eax
  801d74:	78 55                	js     801dcb <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d76:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d84:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d8b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d94:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d96:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d99:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801da0:	83 ec 0c             	sub    $0xc,%esp
  801da3:	ff 75 f4             	pushl  -0xc(%ebp)
  801da6:	e8 be f0 ff ff       	call   800e69 <fd2num>
  801dab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dae:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801db0:	83 c4 04             	add    $0x4,%esp
  801db3:	ff 75 f0             	pushl  -0x10(%ebp)
  801db6:	e8 ae f0 ff ff       	call   800e69 <fd2num>
  801dbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dbe:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801dc1:	83 c4 10             	add    $0x10,%esp
  801dc4:	ba 00 00 00 00       	mov    $0x0,%edx
  801dc9:	eb 30                	jmp    801dfb <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dcb:	83 ec 08             	sub    $0x8,%esp
  801dce:	56                   	push   %esi
  801dcf:	6a 00                	push   $0x0
  801dd1:	e8 e8 ee ff ff       	call   800cbe <sys_page_unmap>
  801dd6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dd9:	83 ec 08             	sub    $0x8,%esp
  801ddc:	ff 75 f0             	pushl  -0x10(%ebp)
  801ddf:	6a 00                	push   $0x0
  801de1:	e8 d8 ee ff ff       	call   800cbe <sys_page_unmap>
  801de6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801de9:	83 ec 08             	sub    $0x8,%esp
  801dec:	ff 75 f4             	pushl  -0xc(%ebp)
  801def:	6a 00                	push   $0x0
  801df1:	e8 c8 ee ff ff       	call   800cbe <sys_page_unmap>
  801df6:	83 c4 10             	add    $0x10,%esp
  801df9:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801dfb:	89 d0                	mov    %edx,%eax
  801dfd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e00:	5b                   	pop    %ebx
  801e01:	5e                   	pop    %esi
  801e02:	5d                   	pop    %ebp
  801e03:	c3                   	ret    

00801e04 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e04:	55                   	push   %ebp
  801e05:	89 e5                	mov    %esp,%ebp
  801e07:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e0d:	50                   	push   %eax
  801e0e:	ff 75 08             	pushl  0x8(%ebp)
  801e11:	e8 c9 f0 ff ff       	call   800edf <fd_lookup>
  801e16:	83 c4 10             	add    $0x10,%esp
  801e19:	85 c0                	test   %eax,%eax
  801e1b:	78 18                	js     801e35 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e1d:	83 ec 0c             	sub    $0xc,%esp
  801e20:	ff 75 f4             	pushl  -0xc(%ebp)
  801e23:	e8 51 f0 ff ff       	call   800e79 <fd2data>
	return _pipeisclosed(fd, p);
  801e28:	89 c2                	mov    %eax,%edx
  801e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2d:	e8 21 fd ff ff       	call   801b53 <_pipeisclosed>
  801e32:	83 c4 10             	add    $0x10,%esp
}
  801e35:	c9                   	leave  
  801e36:	c3                   	ret    

00801e37 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e37:	55                   	push   %ebp
  801e38:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801e3f:	5d                   	pop    %ebp
  801e40:	c3                   	ret    

00801e41 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e41:	55                   	push   %ebp
  801e42:	89 e5                	mov    %esp,%ebp
  801e44:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e47:	68 4b 28 80 00       	push   $0x80284b
  801e4c:	ff 75 0c             	pushl  0xc(%ebp)
  801e4f:	e8 e2 e9 ff ff       	call   800836 <strcpy>
	return 0;
}
  801e54:	b8 00 00 00 00       	mov    $0x0,%eax
  801e59:	c9                   	leave  
  801e5a:	c3                   	ret    

00801e5b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e5b:	55                   	push   %ebp
  801e5c:	89 e5                	mov    %esp,%ebp
  801e5e:	57                   	push   %edi
  801e5f:	56                   	push   %esi
  801e60:	53                   	push   %ebx
  801e61:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e67:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e6c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e72:	eb 2d                	jmp    801ea1 <devcons_write+0x46>
		m = n - tot;
  801e74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e77:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e79:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e7c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e81:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e84:	83 ec 04             	sub    $0x4,%esp
  801e87:	53                   	push   %ebx
  801e88:	03 45 0c             	add    0xc(%ebp),%eax
  801e8b:	50                   	push   %eax
  801e8c:	57                   	push   %edi
  801e8d:	e8 36 eb ff ff       	call   8009c8 <memmove>
		sys_cputs(buf, m);
  801e92:	83 c4 08             	add    $0x8,%esp
  801e95:	53                   	push   %ebx
  801e96:	57                   	push   %edi
  801e97:	e8 e1 ec ff ff       	call   800b7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e9c:	01 de                	add    %ebx,%esi
  801e9e:	83 c4 10             	add    $0x10,%esp
  801ea1:	89 f0                	mov    %esi,%eax
  801ea3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ea6:	72 cc                	jb     801e74 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ea8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eab:	5b                   	pop    %ebx
  801eac:	5e                   	pop    %esi
  801ead:	5f                   	pop    %edi
  801eae:	5d                   	pop    %ebp
  801eaf:	c3                   	ret    

00801eb0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801eb0:	55                   	push   %ebp
  801eb1:	89 e5                	mov    %esp,%ebp
  801eb3:	83 ec 08             	sub    $0x8,%esp
  801eb6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ebb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ebf:	74 2a                	je     801eeb <devcons_read+0x3b>
  801ec1:	eb 05                	jmp    801ec8 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ec3:	e8 52 ed ff ff       	call   800c1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ec8:	e8 ce ec ff ff       	call   800b9b <sys_cgetc>
  801ecd:	85 c0                	test   %eax,%eax
  801ecf:	74 f2                	je     801ec3 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ed1:	85 c0                	test   %eax,%eax
  801ed3:	78 16                	js     801eeb <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ed5:	83 f8 04             	cmp    $0x4,%eax
  801ed8:	74 0c                	je     801ee6 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801eda:	8b 55 0c             	mov    0xc(%ebp),%edx
  801edd:	88 02                	mov    %al,(%edx)
	return 1;
  801edf:	b8 01 00 00 00       	mov    $0x1,%eax
  801ee4:	eb 05                	jmp    801eeb <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ee6:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801eeb:	c9                   	leave  
  801eec:	c3                   	ret    

00801eed <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801eed:	55                   	push   %ebp
  801eee:	89 e5                	mov    %esp,%ebp
  801ef0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ef3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef6:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ef9:	6a 01                	push   $0x1
  801efb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801efe:	50                   	push   %eax
  801eff:	e8 79 ec ff ff       	call   800b7d <sys_cputs>
}
  801f04:	83 c4 10             	add    $0x10,%esp
  801f07:	c9                   	leave  
  801f08:	c3                   	ret    

00801f09 <getchar>:

int
getchar(void)
{
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
  801f0c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f0f:	6a 01                	push   $0x1
  801f11:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f14:	50                   	push   %eax
  801f15:	6a 00                	push   $0x0
  801f17:	e8 29 f2 ff ff       	call   801145 <read>
	if (r < 0)
  801f1c:	83 c4 10             	add    $0x10,%esp
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	78 0f                	js     801f32 <getchar+0x29>
		return r;
	if (r < 1)
  801f23:	85 c0                	test   %eax,%eax
  801f25:	7e 06                	jle    801f2d <getchar+0x24>
		return -E_EOF;
	return c;
  801f27:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f2b:	eb 05                	jmp    801f32 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f2d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f32:	c9                   	leave  
  801f33:	c3                   	ret    

00801f34 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f34:	55                   	push   %ebp
  801f35:	89 e5                	mov    %esp,%ebp
  801f37:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f3d:	50                   	push   %eax
  801f3e:	ff 75 08             	pushl  0x8(%ebp)
  801f41:	e8 99 ef ff ff       	call   800edf <fd_lookup>
  801f46:	83 c4 10             	add    $0x10,%esp
  801f49:	85 c0                	test   %eax,%eax
  801f4b:	78 11                	js     801f5e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f50:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f56:	39 10                	cmp    %edx,(%eax)
  801f58:	0f 94 c0             	sete   %al
  801f5b:	0f b6 c0             	movzbl %al,%eax
}
  801f5e:	c9                   	leave  
  801f5f:	c3                   	ret    

00801f60 <opencons>:

int
opencons(void)
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
  801f63:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f69:	50                   	push   %eax
  801f6a:	e8 21 ef ff ff       	call   800e90 <fd_alloc>
  801f6f:	83 c4 10             	add    $0x10,%esp
		return r;
  801f72:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f74:	85 c0                	test   %eax,%eax
  801f76:	78 3e                	js     801fb6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f78:	83 ec 04             	sub    $0x4,%esp
  801f7b:	68 07 04 00 00       	push   $0x407
  801f80:	ff 75 f4             	pushl  -0xc(%ebp)
  801f83:	6a 00                	push   $0x0
  801f85:	e8 af ec ff ff       	call   800c39 <sys_page_alloc>
  801f8a:	83 c4 10             	add    $0x10,%esp
		return r;
  801f8d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f8f:	85 c0                	test   %eax,%eax
  801f91:	78 23                	js     801fb6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f93:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fa8:	83 ec 0c             	sub    $0xc,%esp
  801fab:	50                   	push   %eax
  801fac:	e8 b8 ee ff ff       	call   800e69 <fd2num>
  801fb1:	89 c2                	mov    %eax,%edx
  801fb3:	83 c4 10             	add    $0x10,%esp
}
  801fb6:	89 d0                	mov    %edx,%eax
  801fb8:	c9                   	leave  
  801fb9:	c3                   	ret    

00801fba <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fba:	55                   	push   %ebp
  801fbb:	89 e5                	mov    %esp,%ebp
  801fbd:	56                   	push   %esi
  801fbe:	53                   	push   %ebx
  801fbf:	8b 75 08             	mov    0x8(%ebp),%esi
  801fc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801fc8:	85 c0                	test   %eax,%eax
  801fca:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fcf:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801fd2:	83 ec 0c             	sub    $0xc,%esp
  801fd5:	50                   	push   %eax
  801fd6:	e8 0e ee ff ff       	call   800de9 <sys_ipc_recv>
  801fdb:	83 c4 10             	add    $0x10,%esp
  801fde:	85 c0                	test   %eax,%eax
  801fe0:	79 16                	jns    801ff8 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801fe2:	85 f6                	test   %esi,%esi
  801fe4:	74 06                	je     801fec <ipc_recv+0x32>
            *from_env_store = 0;
  801fe6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801fec:	85 db                	test   %ebx,%ebx
  801fee:	74 2c                	je     80201c <ipc_recv+0x62>
            *perm_store = 0;
  801ff0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ff6:	eb 24                	jmp    80201c <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801ff8:	85 f6                	test   %esi,%esi
  801ffa:	74 0a                	je     802006 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801ffc:	a1 08 40 80 00       	mov    0x804008,%eax
  802001:	8b 40 74             	mov    0x74(%eax),%eax
  802004:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  802006:	85 db                	test   %ebx,%ebx
  802008:	74 0a                	je     802014 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  80200a:	a1 08 40 80 00       	mov    0x804008,%eax
  80200f:	8b 40 78             	mov    0x78(%eax),%eax
  802012:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  802014:	a1 08 40 80 00       	mov    0x804008,%eax
  802019:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  80201c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80201f:	5b                   	pop    %ebx
  802020:	5e                   	pop    %esi
  802021:	5d                   	pop    %ebp
  802022:	c3                   	ret    

00802023 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802023:	55                   	push   %ebp
  802024:	89 e5                	mov    %esp,%ebp
  802026:	57                   	push   %edi
  802027:	56                   	push   %esi
  802028:	53                   	push   %ebx
  802029:	83 ec 0c             	sub    $0xc,%esp
  80202c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80202f:	8b 75 0c             	mov    0xc(%ebp),%esi
  802032:	8b 45 10             	mov    0x10(%ebp),%eax
  802035:	85 c0                	test   %eax,%eax
  802037:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80203c:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80203f:	eb 1c                	jmp    80205d <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  802041:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802044:	74 12                	je     802058 <ipc_send+0x35>
  802046:	50                   	push   %eax
  802047:	68 57 28 80 00       	push   $0x802857
  80204c:	6a 3b                	push   $0x3b
  80204e:	68 6d 28 80 00       	push   $0x80286d
  802053:	e8 01 e1 ff ff       	call   800159 <_panic>
		sys_yield();
  802058:	e8 bd eb ff ff       	call   800c1a <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80205d:	ff 75 14             	pushl  0x14(%ebp)
  802060:	53                   	push   %ebx
  802061:	56                   	push   %esi
  802062:	57                   	push   %edi
  802063:	e8 5e ed ff ff       	call   800dc6 <sys_ipc_try_send>
  802068:	83 c4 10             	add    $0x10,%esp
  80206b:	85 c0                	test   %eax,%eax
  80206d:	78 d2                	js     802041 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  80206f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802072:	5b                   	pop    %ebx
  802073:	5e                   	pop    %esi
  802074:	5f                   	pop    %edi
  802075:	5d                   	pop    %ebp
  802076:	c3                   	ret    

00802077 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802077:	55                   	push   %ebp
  802078:	89 e5                	mov    %esp,%ebp
  80207a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80207d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802082:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802085:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80208b:	8b 52 50             	mov    0x50(%edx),%edx
  80208e:	39 ca                	cmp    %ecx,%edx
  802090:	75 0d                	jne    80209f <ipc_find_env+0x28>
			return envs[i].env_id;
  802092:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802095:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80209a:	8b 40 48             	mov    0x48(%eax),%eax
  80209d:	eb 0f                	jmp    8020ae <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80209f:	83 c0 01             	add    $0x1,%eax
  8020a2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020a7:	75 d9                	jne    802082 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020ae:	5d                   	pop    %ebp
  8020af:	c3                   	ret    

008020b0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020b0:	55                   	push   %ebp
  8020b1:	89 e5                	mov    %esp,%ebp
  8020b3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020b6:	89 d0                	mov    %edx,%eax
  8020b8:	c1 e8 16             	shr    $0x16,%eax
  8020bb:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020c2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020c7:	f6 c1 01             	test   $0x1,%cl
  8020ca:	74 1d                	je     8020e9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020cc:	c1 ea 0c             	shr    $0xc,%edx
  8020cf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020d6:	f6 c2 01             	test   $0x1,%dl
  8020d9:	74 0e                	je     8020e9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020db:	c1 ea 0c             	shr    $0xc,%edx
  8020de:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020e5:	ef 
  8020e6:	0f b7 c0             	movzwl %ax,%eax
}
  8020e9:	5d                   	pop    %ebp
  8020ea:	c3                   	ret    
  8020eb:	66 90                	xchg   %ax,%ax
  8020ed:	66 90                	xchg   %ax,%ax
  8020ef:	90                   	nop

008020f0 <__udivdi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 1c             	sub    $0x1c,%esp
  8020f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802103:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802107:	85 f6                	test   %esi,%esi
  802109:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80210d:	89 ca                	mov    %ecx,%edx
  80210f:	89 f8                	mov    %edi,%eax
  802111:	75 3d                	jne    802150 <__udivdi3+0x60>
  802113:	39 cf                	cmp    %ecx,%edi
  802115:	0f 87 c5 00 00 00    	ja     8021e0 <__udivdi3+0xf0>
  80211b:	85 ff                	test   %edi,%edi
  80211d:	89 fd                	mov    %edi,%ebp
  80211f:	75 0b                	jne    80212c <__udivdi3+0x3c>
  802121:	b8 01 00 00 00       	mov    $0x1,%eax
  802126:	31 d2                	xor    %edx,%edx
  802128:	f7 f7                	div    %edi
  80212a:	89 c5                	mov    %eax,%ebp
  80212c:	89 c8                	mov    %ecx,%eax
  80212e:	31 d2                	xor    %edx,%edx
  802130:	f7 f5                	div    %ebp
  802132:	89 c1                	mov    %eax,%ecx
  802134:	89 d8                	mov    %ebx,%eax
  802136:	89 cf                	mov    %ecx,%edi
  802138:	f7 f5                	div    %ebp
  80213a:	89 c3                	mov    %eax,%ebx
  80213c:	89 d8                	mov    %ebx,%eax
  80213e:	89 fa                	mov    %edi,%edx
  802140:	83 c4 1c             	add    $0x1c,%esp
  802143:	5b                   	pop    %ebx
  802144:	5e                   	pop    %esi
  802145:	5f                   	pop    %edi
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    
  802148:	90                   	nop
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	39 ce                	cmp    %ecx,%esi
  802152:	77 74                	ja     8021c8 <__udivdi3+0xd8>
  802154:	0f bd fe             	bsr    %esi,%edi
  802157:	83 f7 1f             	xor    $0x1f,%edi
  80215a:	0f 84 98 00 00 00    	je     8021f8 <__udivdi3+0x108>
  802160:	bb 20 00 00 00       	mov    $0x20,%ebx
  802165:	89 f9                	mov    %edi,%ecx
  802167:	89 c5                	mov    %eax,%ebp
  802169:	29 fb                	sub    %edi,%ebx
  80216b:	d3 e6                	shl    %cl,%esi
  80216d:	89 d9                	mov    %ebx,%ecx
  80216f:	d3 ed                	shr    %cl,%ebp
  802171:	89 f9                	mov    %edi,%ecx
  802173:	d3 e0                	shl    %cl,%eax
  802175:	09 ee                	or     %ebp,%esi
  802177:	89 d9                	mov    %ebx,%ecx
  802179:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80217d:	89 d5                	mov    %edx,%ebp
  80217f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802183:	d3 ed                	shr    %cl,%ebp
  802185:	89 f9                	mov    %edi,%ecx
  802187:	d3 e2                	shl    %cl,%edx
  802189:	89 d9                	mov    %ebx,%ecx
  80218b:	d3 e8                	shr    %cl,%eax
  80218d:	09 c2                	or     %eax,%edx
  80218f:	89 d0                	mov    %edx,%eax
  802191:	89 ea                	mov    %ebp,%edx
  802193:	f7 f6                	div    %esi
  802195:	89 d5                	mov    %edx,%ebp
  802197:	89 c3                	mov    %eax,%ebx
  802199:	f7 64 24 0c          	mull   0xc(%esp)
  80219d:	39 d5                	cmp    %edx,%ebp
  80219f:	72 10                	jb     8021b1 <__udivdi3+0xc1>
  8021a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021a5:	89 f9                	mov    %edi,%ecx
  8021a7:	d3 e6                	shl    %cl,%esi
  8021a9:	39 c6                	cmp    %eax,%esi
  8021ab:	73 07                	jae    8021b4 <__udivdi3+0xc4>
  8021ad:	39 d5                	cmp    %edx,%ebp
  8021af:	75 03                	jne    8021b4 <__udivdi3+0xc4>
  8021b1:	83 eb 01             	sub    $0x1,%ebx
  8021b4:	31 ff                	xor    %edi,%edi
  8021b6:	89 d8                	mov    %ebx,%eax
  8021b8:	89 fa                	mov    %edi,%edx
  8021ba:	83 c4 1c             	add    $0x1c,%esp
  8021bd:	5b                   	pop    %ebx
  8021be:	5e                   	pop    %esi
  8021bf:	5f                   	pop    %edi
  8021c0:	5d                   	pop    %ebp
  8021c1:	c3                   	ret    
  8021c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021c8:	31 ff                	xor    %edi,%edi
  8021ca:	31 db                	xor    %ebx,%ebx
  8021cc:	89 d8                	mov    %ebx,%eax
  8021ce:	89 fa                	mov    %edi,%edx
  8021d0:	83 c4 1c             	add    $0x1c,%esp
  8021d3:	5b                   	pop    %ebx
  8021d4:	5e                   	pop    %esi
  8021d5:	5f                   	pop    %edi
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    
  8021d8:	90                   	nop
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	89 d8                	mov    %ebx,%eax
  8021e2:	f7 f7                	div    %edi
  8021e4:	31 ff                	xor    %edi,%edi
  8021e6:	89 c3                	mov    %eax,%ebx
  8021e8:	89 d8                	mov    %ebx,%eax
  8021ea:	89 fa                	mov    %edi,%edx
  8021ec:	83 c4 1c             	add    $0x1c,%esp
  8021ef:	5b                   	pop    %ebx
  8021f0:	5e                   	pop    %esi
  8021f1:	5f                   	pop    %edi
  8021f2:	5d                   	pop    %ebp
  8021f3:	c3                   	ret    
  8021f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f8:	39 ce                	cmp    %ecx,%esi
  8021fa:	72 0c                	jb     802208 <__udivdi3+0x118>
  8021fc:	31 db                	xor    %ebx,%ebx
  8021fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802202:	0f 87 34 ff ff ff    	ja     80213c <__udivdi3+0x4c>
  802208:	bb 01 00 00 00       	mov    $0x1,%ebx
  80220d:	e9 2a ff ff ff       	jmp    80213c <__udivdi3+0x4c>
  802212:	66 90                	xchg   %ax,%ax
  802214:	66 90                	xchg   %ax,%ax
  802216:	66 90                	xchg   %ax,%ax
  802218:	66 90                	xchg   %ax,%ax
  80221a:	66 90                	xchg   %ax,%ax
  80221c:	66 90                	xchg   %ax,%ax
  80221e:	66 90                	xchg   %ax,%ax

00802220 <__umoddi3>:
  802220:	55                   	push   %ebp
  802221:	57                   	push   %edi
  802222:	56                   	push   %esi
  802223:	53                   	push   %ebx
  802224:	83 ec 1c             	sub    $0x1c,%esp
  802227:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80222b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80222f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802233:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802237:	85 d2                	test   %edx,%edx
  802239:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80223d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802241:	89 f3                	mov    %esi,%ebx
  802243:	89 3c 24             	mov    %edi,(%esp)
  802246:	89 74 24 04          	mov    %esi,0x4(%esp)
  80224a:	75 1c                	jne    802268 <__umoddi3+0x48>
  80224c:	39 f7                	cmp    %esi,%edi
  80224e:	76 50                	jbe    8022a0 <__umoddi3+0x80>
  802250:	89 c8                	mov    %ecx,%eax
  802252:	89 f2                	mov    %esi,%edx
  802254:	f7 f7                	div    %edi
  802256:	89 d0                	mov    %edx,%eax
  802258:	31 d2                	xor    %edx,%edx
  80225a:	83 c4 1c             	add    $0x1c,%esp
  80225d:	5b                   	pop    %ebx
  80225e:	5e                   	pop    %esi
  80225f:	5f                   	pop    %edi
  802260:	5d                   	pop    %ebp
  802261:	c3                   	ret    
  802262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802268:	39 f2                	cmp    %esi,%edx
  80226a:	89 d0                	mov    %edx,%eax
  80226c:	77 52                	ja     8022c0 <__umoddi3+0xa0>
  80226e:	0f bd ea             	bsr    %edx,%ebp
  802271:	83 f5 1f             	xor    $0x1f,%ebp
  802274:	75 5a                	jne    8022d0 <__umoddi3+0xb0>
  802276:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80227a:	0f 82 e0 00 00 00    	jb     802360 <__umoddi3+0x140>
  802280:	39 0c 24             	cmp    %ecx,(%esp)
  802283:	0f 86 d7 00 00 00    	jbe    802360 <__umoddi3+0x140>
  802289:	8b 44 24 08          	mov    0x8(%esp),%eax
  80228d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802291:	83 c4 1c             	add    $0x1c,%esp
  802294:	5b                   	pop    %ebx
  802295:	5e                   	pop    %esi
  802296:	5f                   	pop    %edi
  802297:	5d                   	pop    %ebp
  802298:	c3                   	ret    
  802299:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	85 ff                	test   %edi,%edi
  8022a2:	89 fd                	mov    %edi,%ebp
  8022a4:	75 0b                	jne    8022b1 <__umoddi3+0x91>
  8022a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022ab:	31 d2                	xor    %edx,%edx
  8022ad:	f7 f7                	div    %edi
  8022af:	89 c5                	mov    %eax,%ebp
  8022b1:	89 f0                	mov    %esi,%eax
  8022b3:	31 d2                	xor    %edx,%edx
  8022b5:	f7 f5                	div    %ebp
  8022b7:	89 c8                	mov    %ecx,%eax
  8022b9:	f7 f5                	div    %ebp
  8022bb:	89 d0                	mov    %edx,%eax
  8022bd:	eb 99                	jmp    802258 <__umoddi3+0x38>
  8022bf:	90                   	nop
  8022c0:	89 c8                	mov    %ecx,%eax
  8022c2:	89 f2                	mov    %esi,%edx
  8022c4:	83 c4 1c             	add    $0x1c,%esp
  8022c7:	5b                   	pop    %ebx
  8022c8:	5e                   	pop    %esi
  8022c9:	5f                   	pop    %edi
  8022ca:	5d                   	pop    %ebp
  8022cb:	c3                   	ret    
  8022cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	8b 34 24             	mov    (%esp),%esi
  8022d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022d8:	89 e9                	mov    %ebp,%ecx
  8022da:	29 ef                	sub    %ebp,%edi
  8022dc:	d3 e0                	shl    %cl,%eax
  8022de:	89 f9                	mov    %edi,%ecx
  8022e0:	89 f2                	mov    %esi,%edx
  8022e2:	d3 ea                	shr    %cl,%edx
  8022e4:	89 e9                	mov    %ebp,%ecx
  8022e6:	09 c2                	or     %eax,%edx
  8022e8:	89 d8                	mov    %ebx,%eax
  8022ea:	89 14 24             	mov    %edx,(%esp)
  8022ed:	89 f2                	mov    %esi,%edx
  8022ef:	d3 e2                	shl    %cl,%edx
  8022f1:	89 f9                	mov    %edi,%ecx
  8022f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022fb:	d3 e8                	shr    %cl,%eax
  8022fd:	89 e9                	mov    %ebp,%ecx
  8022ff:	89 c6                	mov    %eax,%esi
  802301:	d3 e3                	shl    %cl,%ebx
  802303:	89 f9                	mov    %edi,%ecx
  802305:	89 d0                	mov    %edx,%eax
  802307:	d3 e8                	shr    %cl,%eax
  802309:	89 e9                	mov    %ebp,%ecx
  80230b:	09 d8                	or     %ebx,%eax
  80230d:	89 d3                	mov    %edx,%ebx
  80230f:	89 f2                	mov    %esi,%edx
  802311:	f7 34 24             	divl   (%esp)
  802314:	89 d6                	mov    %edx,%esi
  802316:	d3 e3                	shl    %cl,%ebx
  802318:	f7 64 24 04          	mull   0x4(%esp)
  80231c:	39 d6                	cmp    %edx,%esi
  80231e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802322:	89 d1                	mov    %edx,%ecx
  802324:	89 c3                	mov    %eax,%ebx
  802326:	72 08                	jb     802330 <__umoddi3+0x110>
  802328:	75 11                	jne    80233b <__umoddi3+0x11b>
  80232a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80232e:	73 0b                	jae    80233b <__umoddi3+0x11b>
  802330:	2b 44 24 04          	sub    0x4(%esp),%eax
  802334:	1b 14 24             	sbb    (%esp),%edx
  802337:	89 d1                	mov    %edx,%ecx
  802339:	89 c3                	mov    %eax,%ebx
  80233b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80233f:	29 da                	sub    %ebx,%edx
  802341:	19 ce                	sbb    %ecx,%esi
  802343:	89 f9                	mov    %edi,%ecx
  802345:	89 f0                	mov    %esi,%eax
  802347:	d3 e0                	shl    %cl,%eax
  802349:	89 e9                	mov    %ebp,%ecx
  80234b:	d3 ea                	shr    %cl,%edx
  80234d:	89 e9                	mov    %ebp,%ecx
  80234f:	d3 ee                	shr    %cl,%esi
  802351:	09 d0                	or     %edx,%eax
  802353:	89 f2                	mov    %esi,%edx
  802355:	83 c4 1c             	add    $0x1c,%esp
  802358:	5b                   	pop    %ebx
  802359:	5e                   	pop    %esi
  80235a:	5f                   	pop    %edi
  80235b:	5d                   	pop    %ebp
  80235c:	c3                   	ret    
  80235d:	8d 76 00             	lea    0x0(%esi),%esi
  802360:	29 f9                	sub    %edi,%ecx
  802362:	19 d6                	sbb    %edx,%esi
  802364:	89 74 24 04          	mov    %esi,0x4(%esp)
  802368:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80236c:	e9 18 ff ff ff       	jmp    802289 <__umoddi3+0x69>
