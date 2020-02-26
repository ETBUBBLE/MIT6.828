
obj/user/faultalloc.debug：     文件格式 elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 e0 23 80 00       	push   $0x8023e0
  800045:	e8 b9 01 00 00       	call   800203 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 ac 0b 00 00       	call   800c0a <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 00 24 80 00       	push   $0x802400
  80006f:	6a 0e                	push   $0xe
  800071:	68 ea 23 80 00       	push   $0x8023ea
  800076:	e8 af 00 00 00       	call   80012a <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 2c 24 80 00       	push   $0x80242c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 2b 07 00 00       	call   8007b4 <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 99 0d 00 00       	call   800e3a <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 fc 23 80 00       	push   $0x8023fc
  8000ae:	e8 50 01 00 00       	call   800203 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 fc 23 80 00       	push   $0x8023fc
  8000c0:	e8 3e 01 00 00       	call   800203 <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8000d5:	e8 f2 0a 00 00       	call   800bcc <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 08 40 80 00       	mov    %eax,0x804008

    // save the name of the program so that panic() can use it
    if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
        binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

    // exit gracefully
    exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800116:	e8 71 0f 00 00       	call   80108c <close_all>
	sys_env_destroy(0);
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	6a 00                	push   $0x0
  800120:	e8 66 0a 00 00       	call   800b8b <sys_env_destroy>
}
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	c9                   	leave  
  800129:	c3                   	ret    

0080012a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	56                   	push   %esi
  80012e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80012f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800132:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800138:	e8 8f 0a 00 00       	call   800bcc <sys_getenvid>
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	ff 75 0c             	pushl  0xc(%ebp)
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	56                   	push   %esi
  800147:	50                   	push   %eax
  800148:	68 58 24 80 00       	push   $0x802458
  80014d:	e8 b1 00 00 00       	call   800203 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800152:	83 c4 18             	add    $0x18,%esp
  800155:	53                   	push   %ebx
  800156:	ff 75 10             	pushl  0x10(%ebp)
  800159:	e8 54 00 00 00       	call   8001b2 <vcprintf>
	cprintf("\n");
  80015e:	c7 04 24 e8 28 80 00 	movl   $0x8028e8,(%esp)
  800165:	e8 99 00 00 00       	call   800203 <cprintf>
  80016a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016d:	cc                   	int3   
  80016e:	eb fd                	jmp    80016d <_panic+0x43>

00800170 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	53                   	push   %ebx
  800174:	83 ec 04             	sub    $0x4,%esp
  800177:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017a:	8b 13                	mov    (%ebx),%edx
  80017c:	8d 42 01             	lea    0x1(%edx),%eax
  80017f:	89 03                	mov    %eax,(%ebx)
  800181:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800184:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800188:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018d:	75 1a                	jne    8001a9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018f:	83 ec 08             	sub    $0x8,%esp
  800192:	68 ff 00 00 00       	push   $0xff
  800197:	8d 43 08             	lea    0x8(%ebx),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 ae 09 00 00       	call   800b4e <sys_cputs>
		b->idx = 0;
  8001a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b0:	c9                   	leave  
  8001b1:	c3                   	ret    

008001b2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c2:	00 00 00 
	b.cnt = 0;
  8001c5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cf:	ff 75 0c             	pushl  0xc(%ebp)
  8001d2:	ff 75 08             	pushl  0x8(%ebp)
  8001d5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001db:	50                   	push   %eax
  8001dc:	68 70 01 80 00       	push   $0x800170
  8001e1:	e8 1a 01 00 00       	call   800300 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e6:	83 c4 08             	add    $0x8,%esp
  8001e9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ef:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f5:	50                   	push   %eax
  8001f6:	e8 53 09 00 00       	call   800b4e <sys_cputs>

	return b.cnt;
}
  8001fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800209:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020c:	50                   	push   %eax
  80020d:	ff 75 08             	pushl  0x8(%ebp)
  800210:	e8 9d ff ff ff       	call   8001b2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800215:	c9                   	leave  
  800216:	c3                   	ret    

00800217 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	57                   	push   %edi
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
  80021d:	83 ec 1c             	sub    $0x1c,%esp
  800220:	89 c7                	mov    %eax,%edi
  800222:	89 d6                	mov    %edx,%esi
  800224:	8b 45 08             	mov    0x8(%ebp),%eax
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800230:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80023b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80023e:	39 d3                	cmp    %edx,%ebx
  800240:	72 05                	jb     800247 <printnum+0x30>
  800242:	39 45 10             	cmp    %eax,0x10(%ebp)
  800245:	77 45                	ja     80028c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800247:	83 ec 0c             	sub    $0xc,%esp
  80024a:	ff 75 18             	pushl  0x18(%ebp)
  80024d:	8b 45 14             	mov    0x14(%ebp),%eax
  800250:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800253:	53                   	push   %ebx
  800254:	ff 75 10             	pushl  0x10(%ebp)
  800257:	83 ec 08             	sub    $0x8,%esp
  80025a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025d:	ff 75 e0             	pushl  -0x20(%ebp)
  800260:	ff 75 dc             	pushl  -0x24(%ebp)
  800263:	ff 75 d8             	pushl  -0x28(%ebp)
  800266:	e8 e5 1e 00 00       	call   802150 <__udivdi3>
  80026b:	83 c4 18             	add    $0x18,%esp
  80026e:	52                   	push   %edx
  80026f:	50                   	push   %eax
  800270:	89 f2                	mov    %esi,%edx
  800272:	89 f8                	mov    %edi,%eax
  800274:	e8 9e ff ff ff       	call   800217 <printnum>
  800279:	83 c4 20             	add    $0x20,%esp
  80027c:	eb 18                	jmp    800296 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027e:	83 ec 08             	sub    $0x8,%esp
  800281:	56                   	push   %esi
  800282:	ff 75 18             	pushl  0x18(%ebp)
  800285:	ff d7                	call   *%edi
  800287:	83 c4 10             	add    $0x10,%esp
  80028a:	eb 03                	jmp    80028f <printnum+0x78>
  80028c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028f:	83 eb 01             	sub    $0x1,%ebx
  800292:	85 db                	test   %ebx,%ebx
  800294:	7f e8                	jg     80027e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800296:	83 ec 08             	sub    $0x8,%esp
  800299:	56                   	push   %esi
  80029a:	83 ec 04             	sub    $0x4,%esp
  80029d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a9:	e8 d2 1f 00 00       	call   802280 <__umoddi3>
  8002ae:	83 c4 14             	add    $0x14,%esp
  8002b1:	0f be 80 7b 24 80 00 	movsbl 0x80247b(%eax),%eax
  8002b8:	50                   	push   %eax
  8002b9:	ff d7                	call   *%edi
}
  8002bb:	83 c4 10             	add    $0x10,%esp
  8002be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002cc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d5:	73 0a                	jae    8002e1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002da:	89 08                	mov    %ecx,(%eax)
  8002dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002df:	88 02                	mov    %al,(%edx)
}
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002e9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ec:	50                   	push   %eax
  8002ed:	ff 75 10             	pushl  0x10(%ebp)
  8002f0:	ff 75 0c             	pushl  0xc(%ebp)
  8002f3:	ff 75 08             	pushl  0x8(%ebp)
  8002f6:	e8 05 00 00 00       	call   800300 <vprintfmt>
	va_end(ap);
}
  8002fb:	83 c4 10             	add    $0x10,%esp
  8002fe:	c9                   	leave  
  8002ff:	c3                   	ret    

00800300 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	57                   	push   %edi
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
  800306:	83 ec 2c             	sub    $0x2c,%esp
  800309:	8b 75 08             	mov    0x8(%ebp),%esi
  80030c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80030f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800312:	eb 12                	jmp    800326 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800314:	85 c0                	test   %eax,%eax
  800316:	0f 84 42 04 00 00    	je     80075e <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80031c:	83 ec 08             	sub    $0x8,%esp
  80031f:	53                   	push   %ebx
  800320:	50                   	push   %eax
  800321:	ff d6                	call   *%esi
  800323:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800326:	83 c7 01             	add    $0x1,%edi
  800329:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80032d:	83 f8 25             	cmp    $0x25,%eax
  800330:	75 e2                	jne    800314 <vprintfmt+0x14>
  800332:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800336:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80033d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800344:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80034b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800350:	eb 07                	jmp    800359 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800355:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800359:	8d 47 01             	lea    0x1(%edi),%eax
  80035c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035f:	0f b6 07             	movzbl (%edi),%eax
  800362:	0f b6 d0             	movzbl %al,%edx
  800365:	83 e8 23             	sub    $0x23,%eax
  800368:	3c 55                	cmp    $0x55,%al
  80036a:	0f 87 d3 03 00 00    	ja     800743 <vprintfmt+0x443>
  800370:	0f b6 c0             	movzbl %al,%eax
  800373:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80037d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800381:	eb d6                	jmp    800359 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800386:	b8 00 00 00 00       	mov    $0x0,%eax
  80038b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80038e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800391:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800395:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800398:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80039b:	83 f9 09             	cmp    $0x9,%ecx
  80039e:	77 3f                	ja     8003df <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a3:	eb e9                	jmp    80038e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a8:	8b 00                	mov    (%eax),%eax
  8003aa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b0:	8d 40 04             	lea    0x4(%eax),%eax
  8003b3:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b9:	eb 2a                	jmp    8003e5 <vprintfmt+0xe5>
  8003bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003be:	85 c0                	test   %eax,%eax
  8003c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c5:	0f 49 d0             	cmovns %eax,%edx
  8003c8:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ce:	eb 89                	jmp    800359 <vprintfmt+0x59>
  8003d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003d3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003da:	e9 7a ff ff ff       	jmp    800359 <vprintfmt+0x59>
  8003df:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003e2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e9:	0f 89 6a ff ff ff    	jns    800359 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ef:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003fc:	e9 58 ff ff ff       	jmp    800359 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800401:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800407:	e9 4d ff ff ff       	jmp    800359 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 78 04             	lea    0x4(%eax),%edi
  800412:	83 ec 08             	sub    $0x8,%esp
  800415:	53                   	push   %ebx
  800416:	ff 30                	pushl  (%eax)
  800418:	ff d6                	call   *%esi
			break;
  80041a:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80041d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800423:	e9 fe fe ff ff       	jmp    800326 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8d 78 04             	lea    0x4(%eax),%edi
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	99                   	cltd   
  800431:	31 d0                	xor    %edx,%eax
  800433:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800435:	83 f8 0f             	cmp    $0xf,%eax
  800438:	7f 0b                	jg     800445 <vprintfmt+0x145>
  80043a:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  800441:	85 d2                	test   %edx,%edx
  800443:	75 1b                	jne    800460 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800445:	50                   	push   %eax
  800446:	68 93 24 80 00       	push   $0x802493
  80044b:	53                   	push   %ebx
  80044c:	56                   	push   %esi
  80044d:	e8 91 fe ff ff       	call   8002e3 <printfmt>
  800452:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800455:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800458:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80045b:	e9 c6 fe ff ff       	jmp    800326 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800460:	52                   	push   %edx
  800461:	68 7d 28 80 00       	push   $0x80287d
  800466:	53                   	push   %ebx
  800467:	56                   	push   %esi
  800468:	e8 76 fe ff ff       	call   8002e3 <printfmt>
  80046d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800470:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800476:	e9 ab fe ff ff       	jmp    800326 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047b:	8b 45 14             	mov    0x14(%ebp),%eax
  80047e:	83 c0 04             	add    $0x4,%eax
  800481:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800484:	8b 45 14             	mov    0x14(%ebp),%eax
  800487:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800489:	85 ff                	test   %edi,%edi
  80048b:	b8 8c 24 80 00       	mov    $0x80248c,%eax
  800490:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800493:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800497:	0f 8e 94 00 00 00    	jle    800531 <vprintfmt+0x231>
  80049d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a1:	0f 84 98 00 00 00    	je     80053f <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ad:	57                   	push   %edi
  8004ae:	e8 33 03 00 00       	call   8007e6 <strnlen>
  8004b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b6:	29 c1                	sub    %eax,%ecx
  8004b8:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004bb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004be:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	eb 0f                	jmp    8004db <vprintfmt+0x1db>
					putch(padc, putdat);
  8004cc:	83 ec 08             	sub    $0x8,%esp
  8004cf:	53                   	push   %ebx
  8004d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	83 ef 01             	sub    $0x1,%edi
  8004d8:	83 c4 10             	add    $0x10,%esp
  8004db:	85 ff                	test   %edi,%edi
  8004dd:	7f ed                	jg     8004cc <vprintfmt+0x1cc>
  8004df:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004e5:	85 c9                	test   %ecx,%ecx
  8004e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ec:	0f 49 c1             	cmovns %ecx,%eax
  8004ef:	29 c1                	sub    %eax,%ecx
  8004f1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fa:	89 cb                	mov    %ecx,%ebx
  8004fc:	eb 4d                	jmp    80054b <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fe:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800502:	74 1b                	je     80051f <vprintfmt+0x21f>
  800504:	0f be c0             	movsbl %al,%eax
  800507:	83 e8 20             	sub    $0x20,%eax
  80050a:	83 f8 5e             	cmp    $0x5e,%eax
  80050d:	76 10                	jbe    80051f <vprintfmt+0x21f>
					putch('?', putdat);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	ff 75 0c             	pushl  0xc(%ebp)
  800515:	6a 3f                	push   $0x3f
  800517:	ff 55 08             	call   *0x8(%ebp)
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	eb 0d                	jmp    80052c <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	ff 75 0c             	pushl  0xc(%ebp)
  800525:	52                   	push   %edx
  800526:	ff 55 08             	call   *0x8(%ebp)
  800529:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052c:	83 eb 01             	sub    $0x1,%ebx
  80052f:	eb 1a                	jmp    80054b <vprintfmt+0x24b>
  800531:	89 75 08             	mov    %esi,0x8(%ebp)
  800534:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800537:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053d:	eb 0c                	jmp    80054b <vprintfmt+0x24b>
  80053f:	89 75 08             	mov    %esi,0x8(%ebp)
  800542:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800545:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800548:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054b:	83 c7 01             	add    $0x1,%edi
  80054e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800552:	0f be d0             	movsbl %al,%edx
  800555:	85 d2                	test   %edx,%edx
  800557:	74 23                	je     80057c <vprintfmt+0x27c>
  800559:	85 f6                	test   %esi,%esi
  80055b:	78 a1                	js     8004fe <vprintfmt+0x1fe>
  80055d:	83 ee 01             	sub    $0x1,%esi
  800560:	79 9c                	jns    8004fe <vprintfmt+0x1fe>
  800562:	89 df                	mov    %ebx,%edi
  800564:	8b 75 08             	mov    0x8(%ebp),%esi
  800567:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056a:	eb 18                	jmp    800584 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	53                   	push   %ebx
  800570:	6a 20                	push   $0x20
  800572:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800574:	83 ef 01             	sub    $0x1,%edi
  800577:	83 c4 10             	add    $0x10,%esp
  80057a:	eb 08                	jmp    800584 <vprintfmt+0x284>
  80057c:	89 df                	mov    %ebx,%edi
  80057e:	8b 75 08             	mov    0x8(%ebp),%esi
  800581:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800584:	85 ff                	test   %edi,%edi
  800586:	7f e4                	jg     80056c <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800588:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80058b:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800591:	e9 90 fd ff ff       	jmp    800326 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800596:	83 f9 01             	cmp    $0x1,%ecx
  800599:	7e 19                	jle    8005b4 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8b 50 04             	mov    0x4(%eax),%edx
  8005a1:	8b 00                	mov    (%eax),%eax
  8005a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8d 40 08             	lea    0x8(%eax),%eax
  8005af:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b2:	eb 38                	jmp    8005ec <vprintfmt+0x2ec>
	else if (lflag)
  8005b4:	85 c9                	test   %ecx,%ecx
  8005b6:	74 1b                	je     8005d3 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8b 00                	mov    (%eax),%eax
  8005bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c0:	89 c1                	mov    %eax,%ecx
  8005c2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 40 04             	lea    0x4(%eax),%eax
  8005ce:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d1:	eb 19                	jmp    8005ec <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8b 00                	mov    (%eax),%eax
  8005d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005db:	89 c1                	mov    %eax,%ecx
  8005dd:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 40 04             	lea    0x4(%eax),%eax
  8005e9:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ec:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ef:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f2:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005f7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005fb:	0f 89 0e 01 00 00    	jns    80070f <vprintfmt+0x40f>
				putch('-', putdat);
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	53                   	push   %ebx
  800605:	6a 2d                	push   $0x2d
  800607:	ff d6                	call   *%esi
				num = -(long long) num;
  800609:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80060c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80060f:	f7 da                	neg    %edx
  800611:	83 d1 00             	adc    $0x0,%ecx
  800614:	f7 d9                	neg    %ecx
  800616:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800619:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061e:	e9 ec 00 00 00       	jmp    80070f <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800623:	83 f9 01             	cmp    $0x1,%ecx
  800626:	7e 18                	jle    800640 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8b 10                	mov    (%eax),%edx
  80062d:	8b 48 04             	mov    0x4(%eax),%ecx
  800630:	8d 40 08             	lea    0x8(%eax),%eax
  800633:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800636:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063b:	e9 cf 00 00 00       	jmp    80070f <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800640:	85 c9                	test   %ecx,%ecx
  800642:	74 1a                	je     80065e <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8b 10                	mov    (%eax),%edx
  800649:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064e:	8d 40 04             	lea    0x4(%eax),%eax
  800651:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800654:	b8 0a 00 00 00       	mov    $0xa,%eax
  800659:	e9 b1 00 00 00       	jmp    80070f <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8b 10                	mov    (%eax),%edx
  800663:	b9 00 00 00 00       	mov    $0x0,%ecx
  800668:	8d 40 04             	lea    0x4(%eax),%eax
  80066b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80066e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800673:	e9 97 00 00 00       	jmp    80070f <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800678:	83 ec 08             	sub    $0x8,%esp
  80067b:	53                   	push   %ebx
  80067c:	6a 58                	push   $0x58
  80067e:	ff d6                	call   *%esi
			putch('X', putdat);
  800680:	83 c4 08             	add    $0x8,%esp
  800683:	53                   	push   %ebx
  800684:	6a 58                	push   $0x58
  800686:	ff d6                	call   *%esi
			putch('X', putdat);
  800688:	83 c4 08             	add    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 58                	push   $0x58
  80068e:	ff d6                	call   *%esi
			break;
  800690:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800693:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800696:	e9 8b fc ff ff       	jmp    800326 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	53                   	push   %ebx
  80069f:	6a 30                	push   $0x30
  8006a1:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a3:	83 c4 08             	add    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	6a 78                	push   $0x78
  8006a9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ae:	8b 10                	mov    (%eax),%edx
  8006b0:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b5:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b8:	8d 40 04             	lea    0x4(%eax),%eax
  8006bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006be:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006c3:	eb 4a                	jmp    80070f <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c5:	83 f9 01             	cmp    $0x1,%ecx
  8006c8:	7e 15                	jle    8006df <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8b 10                	mov    (%eax),%edx
  8006cf:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d2:	8d 40 08             	lea    0x8(%eax),%eax
  8006d5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006d8:	b8 10 00 00 00       	mov    $0x10,%eax
  8006dd:	eb 30                	jmp    80070f <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006df:	85 c9                	test   %ecx,%ecx
  8006e1:	74 17                	je     8006fa <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8b 10                	mov    (%eax),%edx
  8006e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ed:	8d 40 04             	lea    0x4(%eax),%eax
  8006f0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006f3:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f8:	eb 15                	jmp    80070f <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8b 10                	mov    (%eax),%edx
  8006ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800704:	8d 40 04             	lea    0x4(%eax),%eax
  800707:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80070a:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80070f:	83 ec 0c             	sub    $0xc,%esp
  800712:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800716:	57                   	push   %edi
  800717:	ff 75 e0             	pushl  -0x20(%ebp)
  80071a:	50                   	push   %eax
  80071b:	51                   	push   %ecx
  80071c:	52                   	push   %edx
  80071d:	89 da                	mov    %ebx,%edx
  80071f:	89 f0                	mov    %esi,%eax
  800721:	e8 f1 fa ff ff       	call   800217 <printnum>
			break;
  800726:	83 c4 20             	add    $0x20,%esp
  800729:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80072c:	e9 f5 fb ff ff       	jmp    800326 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	53                   	push   %ebx
  800735:	52                   	push   %edx
  800736:	ff d6                	call   *%esi
			break;
  800738:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80073e:	e9 e3 fb ff ff       	jmp    800326 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800743:	83 ec 08             	sub    $0x8,%esp
  800746:	53                   	push   %ebx
  800747:	6a 25                	push   $0x25
  800749:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80074b:	83 c4 10             	add    $0x10,%esp
  80074e:	eb 03                	jmp    800753 <vprintfmt+0x453>
  800750:	83 ef 01             	sub    $0x1,%edi
  800753:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800757:	75 f7                	jne    800750 <vprintfmt+0x450>
  800759:	e9 c8 fb ff ff       	jmp    800326 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80075e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800761:	5b                   	pop    %ebx
  800762:	5e                   	pop    %esi
  800763:	5f                   	pop    %edi
  800764:	5d                   	pop    %ebp
  800765:	c3                   	ret    

00800766 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	83 ec 18             	sub    $0x18,%esp
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800772:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800775:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800779:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80077c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800783:	85 c0                	test   %eax,%eax
  800785:	74 26                	je     8007ad <vsnprintf+0x47>
  800787:	85 d2                	test   %edx,%edx
  800789:	7e 22                	jle    8007ad <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078b:	ff 75 14             	pushl  0x14(%ebp)
  80078e:	ff 75 10             	pushl  0x10(%ebp)
  800791:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800794:	50                   	push   %eax
  800795:	68 c6 02 80 00       	push   $0x8002c6
  80079a:	e8 61 fb ff ff       	call   800300 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80079f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a8:	83 c4 10             	add    $0x10,%esp
  8007ab:	eb 05                	jmp    8007b2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ba:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007bd:	50                   	push   %eax
  8007be:	ff 75 10             	pushl  0x10(%ebp)
  8007c1:	ff 75 0c             	pushl  0xc(%ebp)
  8007c4:	ff 75 08             	pushl  0x8(%ebp)
  8007c7:	e8 9a ff ff ff       	call   800766 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007cc:	c9                   	leave  
  8007cd:	c3                   	ret    

008007ce <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d9:	eb 03                	jmp    8007de <strlen+0x10>
		n++;
  8007db:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007de:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e2:	75 f7                	jne    8007db <strlen+0xd>
		n++;
	return n;
}
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f4:	eb 03                	jmp    8007f9 <strnlen+0x13>
		n++;
  8007f6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f9:	39 c2                	cmp    %eax,%edx
  8007fb:	74 08                	je     800805 <strnlen+0x1f>
  8007fd:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800801:	75 f3                	jne    8007f6 <strnlen+0x10>
  800803:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800811:	89 c2                	mov    %eax,%edx
  800813:	83 c2 01             	add    $0x1,%edx
  800816:	83 c1 01             	add    $0x1,%ecx
  800819:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80081d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800820:	84 db                	test   %bl,%bl
  800822:	75 ef                	jne    800813 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800824:	5b                   	pop    %ebx
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082e:	53                   	push   %ebx
  80082f:	e8 9a ff ff ff       	call   8007ce <strlen>
  800834:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800837:	ff 75 0c             	pushl  0xc(%ebp)
  80083a:	01 d8                	add    %ebx,%eax
  80083c:	50                   	push   %eax
  80083d:	e8 c5 ff ff ff       	call   800807 <strcpy>
	return dst;
}
  800842:	89 d8                	mov    %ebx,%eax
  800844:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800847:	c9                   	leave  
  800848:	c3                   	ret    

00800849 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	56                   	push   %esi
  80084d:	53                   	push   %ebx
  80084e:	8b 75 08             	mov    0x8(%ebp),%esi
  800851:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800854:	89 f3                	mov    %esi,%ebx
  800856:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800859:	89 f2                	mov    %esi,%edx
  80085b:	eb 0f                	jmp    80086c <strncpy+0x23>
		*dst++ = *src;
  80085d:	83 c2 01             	add    $0x1,%edx
  800860:	0f b6 01             	movzbl (%ecx),%eax
  800863:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800866:	80 39 01             	cmpb   $0x1,(%ecx)
  800869:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086c:	39 da                	cmp    %ebx,%edx
  80086e:	75 ed                	jne    80085d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800870:	89 f0                	mov    %esi,%eax
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	8b 75 08             	mov    0x8(%ebp),%esi
  80087e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800881:	8b 55 10             	mov    0x10(%ebp),%edx
  800884:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800886:	85 d2                	test   %edx,%edx
  800888:	74 21                	je     8008ab <strlcpy+0x35>
  80088a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80088e:	89 f2                	mov    %esi,%edx
  800890:	eb 09                	jmp    80089b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800892:	83 c2 01             	add    $0x1,%edx
  800895:	83 c1 01             	add    $0x1,%ecx
  800898:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80089b:	39 c2                	cmp    %eax,%edx
  80089d:	74 09                	je     8008a8 <strlcpy+0x32>
  80089f:	0f b6 19             	movzbl (%ecx),%ebx
  8008a2:	84 db                	test   %bl,%bl
  8008a4:	75 ec                	jne    800892 <strlcpy+0x1c>
  8008a6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008a8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ab:	29 f0                	sub    %esi,%eax
}
  8008ad:	5b                   	pop    %ebx
  8008ae:	5e                   	pop    %esi
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ba:	eb 06                	jmp    8008c2 <strcmp+0x11>
		p++, q++;
  8008bc:	83 c1 01             	add    $0x1,%ecx
  8008bf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c2:	0f b6 01             	movzbl (%ecx),%eax
  8008c5:	84 c0                	test   %al,%al
  8008c7:	74 04                	je     8008cd <strcmp+0x1c>
  8008c9:	3a 02                	cmp    (%edx),%al
  8008cb:	74 ef                	je     8008bc <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cd:	0f b6 c0             	movzbl %al,%eax
  8008d0:	0f b6 12             	movzbl (%edx),%edx
  8008d3:	29 d0                	sub    %edx,%eax
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	53                   	push   %ebx
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e1:	89 c3                	mov    %eax,%ebx
  8008e3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e6:	eb 06                	jmp    8008ee <strncmp+0x17>
		n--, p++, q++;
  8008e8:	83 c0 01             	add    $0x1,%eax
  8008eb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ee:	39 d8                	cmp    %ebx,%eax
  8008f0:	74 15                	je     800907 <strncmp+0x30>
  8008f2:	0f b6 08             	movzbl (%eax),%ecx
  8008f5:	84 c9                	test   %cl,%cl
  8008f7:	74 04                	je     8008fd <strncmp+0x26>
  8008f9:	3a 0a                	cmp    (%edx),%cl
  8008fb:	74 eb                	je     8008e8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fd:	0f b6 00             	movzbl (%eax),%eax
  800900:	0f b6 12             	movzbl (%edx),%edx
  800903:	29 d0                	sub    %edx,%eax
  800905:	eb 05                	jmp    80090c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800907:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80090c:	5b                   	pop    %ebx
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800919:	eb 07                	jmp    800922 <strchr+0x13>
		if (*s == c)
  80091b:	38 ca                	cmp    %cl,%dl
  80091d:	74 0f                	je     80092e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80091f:	83 c0 01             	add    $0x1,%eax
  800922:	0f b6 10             	movzbl (%eax),%edx
  800925:	84 d2                	test   %dl,%dl
  800927:	75 f2                	jne    80091b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800929:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093a:	eb 03                	jmp    80093f <strfind+0xf>
  80093c:	83 c0 01             	add    $0x1,%eax
  80093f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800942:	38 ca                	cmp    %cl,%dl
  800944:	74 04                	je     80094a <strfind+0x1a>
  800946:	84 d2                	test   %dl,%dl
  800948:	75 f2                	jne    80093c <strfind+0xc>
			break;
	return (char *) s;
}
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	57                   	push   %edi
  800950:	56                   	push   %esi
  800951:	53                   	push   %ebx
  800952:	8b 7d 08             	mov    0x8(%ebp),%edi
  800955:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800958:	85 c9                	test   %ecx,%ecx
  80095a:	74 36                	je     800992 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800962:	75 28                	jne    80098c <memset+0x40>
  800964:	f6 c1 03             	test   $0x3,%cl
  800967:	75 23                	jne    80098c <memset+0x40>
		c &= 0xFF;
  800969:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80096d:	89 d3                	mov    %edx,%ebx
  80096f:	c1 e3 08             	shl    $0x8,%ebx
  800972:	89 d6                	mov    %edx,%esi
  800974:	c1 e6 18             	shl    $0x18,%esi
  800977:	89 d0                	mov    %edx,%eax
  800979:	c1 e0 10             	shl    $0x10,%eax
  80097c:	09 f0                	or     %esi,%eax
  80097e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800980:	89 d8                	mov    %ebx,%eax
  800982:	09 d0                	or     %edx,%eax
  800984:	c1 e9 02             	shr    $0x2,%ecx
  800987:	fc                   	cld    
  800988:	f3 ab                	rep stos %eax,%es:(%edi)
  80098a:	eb 06                	jmp    800992 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80098c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098f:	fc                   	cld    
  800990:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800992:	89 f8                	mov    %edi,%eax
  800994:	5b                   	pop    %ebx
  800995:	5e                   	pop    %esi
  800996:	5f                   	pop    %edi
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	57                   	push   %edi
  80099d:	56                   	push   %esi
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a7:	39 c6                	cmp    %eax,%esi
  8009a9:	73 35                	jae    8009e0 <memmove+0x47>
  8009ab:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ae:	39 d0                	cmp    %edx,%eax
  8009b0:	73 2e                	jae    8009e0 <memmove+0x47>
		s += n;
		d += n;
  8009b2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b5:	89 d6                	mov    %edx,%esi
  8009b7:	09 fe                	or     %edi,%esi
  8009b9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009bf:	75 13                	jne    8009d4 <memmove+0x3b>
  8009c1:	f6 c1 03             	test   $0x3,%cl
  8009c4:	75 0e                	jne    8009d4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009c6:	83 ef 04             	sub    $0x4,%edi
  8009c9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009cc:	c1 e9 02             	shr    $0x2,%ecx
  8009cf:	fd                   	std    
  8009d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d2:	eb 09                	jmp    8009dd <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d4:	83 ef 01             	sub    $0x1,%edi
  8009d7:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009da:	fd                   	std    
  8009db:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009dd:	fc                   	cld    
  8009de:	eb 1d                	jmp    8009fd <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e0:	89 f2                	mov    %esi,%edx
  8009e2:	09 c2                	or     %eax,%edx
  8009e4:	f6 c2 03             	test   $0x3,%dl
  8009e7:	75 0f                	jne    8009f8 <memmove+0x5f>
  8009e9:	f6 c1 03             	test   $0x3,%cl
  8009ec:	75 0a                	jne    8009f8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009ee:	c1 e9 02             	shr    $0x2,%ecx
  8009f1:	89 c7                	mov    %eax,%edi
  8009f3:	fc                   	cld    
  8009f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f6:	eb 05                	jmp    8009fd <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f8:	89 c7                	mov    %eax,%edi
  8009fa:	fc                   	cld    
  8009fb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009fd:	5e                   	pop    %esi
  8009fe:	5f                   	pop    %edi
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a04:	ff 75 10             	pushl  0x10(%ebp)
  800a07:	ff 75 0c             	pushl  0xc(%ebp)
  800a0a:	ff 75 08             	pushl  0x8(%ebp)
  800a0d:	e8 87 ff ff ff       	call   800999 <memmove>
}
  800a12:	c9                   	leave  
  800a13:	c3                   	ret    

00800a14 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1f:	89 c6                	mov    %eax,%esi
  800a21:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a24:	eb 1a                	jmp    800a40 <memcmp+0x2c>
		if (*s1 != *s2)
  800a26:	0f b6 08             	movzbl (%eax),%ecx
  800a29:	0f b6 1a             	movzbl (%edx),%ebx
  800a2c:	38 d9                	cmp    %bl,%cl
  800a2e:	74 0a                	je     800a3a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a30:	0f b6 c1             	movzbl %cl,%eax
  800a33:	0f b6 db             	movzbl %bl,%ebx
  800a36:	29 d8                	sub    %ebx,%eax
  800a38:	eb 0f                	jmp    800a49 <memcmp+0x35>
		s1++, s2++;
  800a3a:	83 c0 01             	add    $0x1,%eax
  800a3d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a40:	39 f0                	cmp    %esi,%eax
  800a42:	75 e2                	jne    800a26 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a49:	5b                   	pop    %ebx
  800a4a:	5e                   	pop    %esi
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	53                   	push   %ebx
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a54:	89 c1                	mov    %eax,%ecx
  800a56:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a59:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5d:	eb 0a                	jmp    800a69 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5f:	0f b6 10             	movzbl (%eax),%edx
  800a62:	39 da                	cmp    %ebx,%edx
  800a64:	74 07                	je     800a6d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a66:	83 c0 01             	add    $0x1,%eax
  800a69:	39 c8                	cmp    %ecx,%eax
  800a6b:	72 f2                	jb     800a5f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a6d:	5b                   	pop    %ebx
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	57                   	push   %edi
  800a74:	56                   	push   %esi
  800a75:	53                   	push   %ebx
  800a76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a79:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7c:	eb 03                	jmp    800a81 <strtol+0x11>
		s++;
  800a7e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a81:	0f b6 01             	movzbl (%ecx),%eax
  800a84:	3c 20                	cmp    $0x20,%al
  800a86:	74 f6                	je     800a7e <strtol+0xe>
  800a88:	3c 09                	cmp    $0x9,%al
  800a8a:	74 f2                	je     800a7e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a8c:	3c 2b                	cmp    $0x2b,%al
  800a8e:	75 0a                	jne    800a9a <strtol+0x2a>
		s++;
  800a90:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a93:	bf 00 00 00 00       	mov    $0x0,%edi
  800a98:	eb 11                	jmp    800aab <strtol+0x3b>
  800a9a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a9f:	3c 2d                	cmp    $0x2d,%al
  800aa1:	75 08                	jne    800aab <strtol+0x3b>
		s++, neg = 1;
  800aa3:	83 c1 01             	add    $0x1,%ecx
  800aa6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aab:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ab1:	75 15                	jne    800ac8 <strtol+0x58>
  800ab3:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab6:	75 10                	jne    800ac8 <strtol+0x58>
  800ab8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800abc:	75 7c                	jne    800b3a <strtol+0xca>
		s += 2, base = 16;
  800abe:	83 c1 02             	add    $0x2,%ecx
  800ac1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac6:	eb 16                	jmp    800ade <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ac8:	85 db                	test   %ebx,%ebx
  800aca:	75 12                	jne    800ade <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800acc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad1:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad4:	75 08                	jne    800ade <strtol+0x6e>
		s++, base = 8;
  800ad6:	83 c1 01             	add    $0x1,%ecx
  800ad9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ade:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae6:	0f b6 11             	movzbl (%ecx),%edx
  800ae9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aec:	89 f3                	mov    %esi,%ebx
  800aee:	80 fb 09             	cmp    $0x9,%bl
  800af1:	77 08                	ja     800afb <strtol+0x8b>
			dig = *s - '0';
  800af3:	0f be d2             	movsbl %dl,%edx
  800af6:	83 ea 30             	sub    $0x30,%edx
  800af9:	eb 22                	jmp    800b1d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800afb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800afe:	89 f3                	mov    %esi,%ebx
  800b00:	80 fb 19             	cmp    $0x19,%bl
  800b03:	77 08                	ja     800b0d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b05:	0f be d2             	movsbl %dl,%edx
  800b08:	83 ea 57             	sub    $0x57,%edx
  800b0b:	eb 10                	jmp    800b1d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b0d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b10:	89 f3                	mov    %esi,%ebx
  800b12:	80 fb 19             	cmp    $0x19,%bl
  800b15:	77 16                	ja     800b2d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b17:	0f be d2             	movsbl %dl,%edx
  800b1a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b1d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b20:	7d 0b                	jge    800b2d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b22:	83 c1 01             	add    $0x1,%ecx
  800b25:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b29:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b2b:	eb b9                	jmp    800ae6 <strtol+0x76>

	if (endptr)
  800b2d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b31:	74 0d                	je     800b40 <strtol+0xd0>
		*endptr = (char *) s;
  800b33:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b36:	89 0e                	mov    %ecx,(%esi)
  800b38:	eb 06                	jmp    800b40 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b3a:	85 db                	test   %ebx,%ebx
  800b3c:	74 98                	je     800ad6 <strtol+0x66>
  800b3e:	eb 9e                	jmp    800ade <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b40:	89 c2                	mov    %eax,%edx
  800b42:	f7 da                	neg    %edx
  800b44:	85 ff                	test   %edi,%edi
  800b46:	0f 45 c2             	cmovne %edx,%eax
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b54:	b8 00 00 00 00       	mov    $0x0,%eax
  800b59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5f:	89 c3                	mov    %eax,%ebx
  800b61:	89 c7                	mov    %eax,%edi
  800b63:	89 c6                	mov    %eax,%esi
  800b65:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <sys_cgetc>:

int
sys_cgetc(void)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b72:	ba 00 00 00 00       	mov    $0x0,%edx
  800b77:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7c:	89 d1                	mov    %edx,%ecx
  800b7e:	89 d3                	mov    %edx,%ebx
  800b80:	89 d7                	mov    %edx,%edi
  800b82:	89 d6                	mov    %edx,%esi
  800b84:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	57                   	push   %edi
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
  800b91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b99:	b8 03 00 00 00       	mov    $0x3,%eax
  800b9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba1:	89 cb                	mov    %ecx,%ebx
  800ba3:	89 cf                	mov    %ecx,%edi
  800ba5:	89 ce                	mov    %ecx,%esi
  800ba7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba9:	85 c0                	test   %eax,%eax
  800bab:	7e 17                	jle    800bc4 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bad:	83 ec 0c             	sub    $0xc,%esp
  800bb0:	50                   	push   %eax
  800bb1:	6a 03                	push   $0x3
  800bb3:	68 7f 27 80 00       	push   $0x80277f
  800bb8:	6a 23                	push   $0x23
  800bba:	68 9c 27 80 00       	push   $0x80279c
  800bbf:	e8 66 f5 ff ff       	call   80012a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5f                   	pop    %edi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd7:	b8 02 00 00 00       	mov    $0x2,%eax
  800bdc:	89 d1                	mov    %edx,%ecx
  800bde:	89 d3                	mov    %edx,%ebx
  800be0:	89 d7                	mov    %edx,%edi
  800be2:	89 d6                	mov    %edx,%esi
  800be4:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be6:	5b                   	pop    %ebx
  800be7:	5e                   	pop    %esi
  800be8:	5f                   	pop    %edi
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <sys_yield>:

void
sys_yield(void)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bfb:	89 d1                	mov    %edx,%ecx
  800bfd:	89 d3                	mov    %edx,%ebx
  800bff:	89 d7                	mov    %edx,%edi
  800c01:	89 d6                	mov    %edx,%esi
  800c03:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
  800c10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c13:	be 00 00 00 00       	mov    $0x0,%esi
  800c18:	b8 04 00 00 00       	mov    $0x4,%eax
  800c1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c20:	8b 55 08             	mov    0x8(%ebp),%edx
  800c23:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c26:	89 f7                	mov    %esi,%edi
  800c28:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	7e 17                	jle    800c45 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2e:	83 ec 0c             	sub    $0xc,%esp
  800c31:	50                   	push   %eax
  800c32:	6a 04                	push   $0x4
  800c34:	68 7f 27 80 00       	push   $0x80277f
  800c39:	6a 23                	push   $0x23
  800c3b:	68 9c 27 80 00       	push   $0x80279c
  800c40:	e8 e5 f4 ff ff       	call   80012a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	57                   	push   %edi
  800c51:	56                   	push   %esi
  800c52:	53                   	push   %ebx
  800c53:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c56:	b8 05 00 00 00       	mov    $0x5,%eax
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c64:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c67:	8b 75 18             	mov    0x18(%ebp),%esi
  800c6a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	7e 17                	jle    800c87 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c70:	83 ec 0c             	sub    $0xc,%esp
  800c73:	50                   	push   %eax
  800c74:	6a 05                	push   $0x5
  800c76:	68 7f 27 80 00       	push   $0x80277f
  800c7b:	6a 23                	push   $0x23
  800c7d:	68 9c 27 80 00       	push   $0x80279c
  800c82:	e8 a3 f4 ff ff       	call   80012a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c98:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9d:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca8:	89 df                	mov    %ebx,%edi
  800caa:	89 de                	mov    %ebx,%esi
  800cac:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cae:	85 c0                	test   %eax,%eax
  800cb0:	7e 17                	jle    800cc9 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb2:	83 ec 0c             	sub    $0xc,%esp
  800cb5:	50                   	push   %eax
  800cb6:	6a 06                	push   $0x6
  800cb8:	68 7f 27 80 00       	push   $0x80277f
  800cbd:	6a 23                	push   $0x23
  800cbf:	68 9c 27 80 00       	push   $0x80279c
  800cc4:	e8 61 f4 ff ff       	call   80012a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdf:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cea:	89 df                	mov    %ebx,%edi
  800cec:	89 de                	mov    %ebx,%esi
  800cee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	7e 17                	jle    800d0b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf4:	83 ec 0c             	sub    $0xc,%esp
  800cf7:	50                   	push   %eax
  800cf8:	6a 08                	push   $0x8
  800cfa:	68 7f 27 80 00       	push   $0x80277f
  800cff:	6a 23                	push   $0x23
  800d01:	68 9c 27 80 00       	push   $0x80279c
  800d06:	e8 1f f4 ff ff       	call   80012a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
  800d19:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d21:	b8 09 00 00 00       	mov    $0x9,%eax
  800d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d29:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2c:	89 df                	mov    %ebx,%edi
  800d2e:	89 de                	mov    %ebx,%esi
  800d30:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d32:	85 c0                	test   %eax,%eax
  800d34:	7e 17                	jle    800d4d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d36:	83 ec 0c             	sub    $0xc,%esp
  800d39:	50                   	push   %eax
  800d3a:	6a 09                	push   $0x9
  800d3c:	68 7f 27 80 00       	push   $0x80277f
  800d41:	6a 23                	push   $0x23
  800d43:	68 9c 27 80 00       	push   $0x80279c
  800d48:	e8 dd f3 ff ff       	call   80012a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	57                   	push   %edi
  800d59:	56                   	push   %esi
  800d5a:	53                   	push   %ebx
  800d5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d63:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6e:	89 df                	mov    %ebx,%edi
  800d70:	89 de                	mov    %ebx,%esi
  800d72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d74:	85 c0                	test   %eax,%eax
  800d76:	7e 17                	jle    800d8f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d78:	83 ec 0c             	sub    $0xc,%esp
  800d7b:	50                   	push   %eax
  800d7c:	6a 0a                	push   $0xa
  800d7e:	68 7f 27 80 00       	push   $0x80277f
  800d83:	6a 23                	push   $0x23
  800d85:	68 9c 27 80 00       	push   $0x80279c
  800d8a:	e8 9b f3 ff ff       	call   80012a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5f                   	pop    %edi
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    

00800d97 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	57                   	push   %edi
  800d9b:	56                   	push   %esi
  800d9c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9d:	be 00 00 00 00       	mov    $0x0,%esi
  800da2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    

00800dba <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	57                   	push   %edi
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
  800dc0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd0:	89 cb                	mov    %ecx,%ebx
  800dd2:	89 cf                	mov    %ecx,%edi
  800dd4:	89 ce                	mov    %ecx,%esi
  800dd6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd8:	85 c0                	test   %eax,%eax
  800dda:	7e 17                	jle    800df3 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddc:	83 ec 0c             	sub    $0xc,%esp
  800ddf:	50                   	push   %eax
  800de0:	6a 0d                	push   $0xd
  800de2:	68 7f 27 80 00       	push   $0x80277f
  800de7:	6a 23                	push   $0x23
  800de9:	68 9c 27 80 00       	push   $0x80279c
  800dee:	e8 37 f3 ff ff       	call   80012a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800df3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df6:	5b                   	pop    %ebx
  800df7:	5e                   	pop    %esi
  800df8:	5f                   	pop    %edi
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	57                   	push   %edi
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e01:	ba 00 00 00 00       	mov    $0x0,%edx
  800e06:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e0b:	89 d1                	mov    %edx,%ecx
  800e0d:	89 d3                	mov    %edx,%ebx
  800e0f:	89 d7                	mov    %edx,%edi
  800e11:	89 d6                	mov    %edx,%esi
  800e13:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    

00800e1a <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	57                   	push   %edi
  800e1e:	56                   	push   %esi
  800e1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e20:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e25:	b8 10 00 00 00       	mov    $0x10,%eax
  800e2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2d:	89 cb                	mov    %ecx,%ebx
  800e2f:	89 cf                	mov    %ecx,%edi
  800e31:	89 ce                	mov    %ecx,%esi
  800e33:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    

00800e3a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e40:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800e47:	75 4a                	jne    800e93 <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  800e49:	a1 08 40 80 00       	mov    0x804008,%eax
  800e4e:	8b 40 48             	mov    0x48(%eax),%eax
  800e51:	83 ec 04             	sub    $0x4,%esp
  800e54:	6a 07                	push   $0x7
  800e56:	68 00 f0 bf ee       	push   $0xeebff000
  800e5b:	50                   	push   %eax
  800e5c:	e8 a9 fd ff ff       	call   800c0a <sys_page_alloc>
  800e61:	83 c4 10             	add    $0x10,%esp
  800e64:	85 c0                	test   %eax,%eax
  800e66:	79 12                	jns    800e7a <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  800e68:	50                   	push   %eax
  800e69:	68 aa 27 80 00       	push   $0x8027aa
  800e6e:	6a 21                	push   $0x21
  800e70:	68 c2 27 80 00       	push   $0x8027c2
  800e75:	e8 b0 f2 ff ff       	call   80012a <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800e7a:	a1 08 40 80 00       	mov    0x804008,%eax
  800e7f:	8b 40 48             	mov    0x48(%eax),%eax
  800e82:	83 ec 08             	sub    $0x8,%esp
  800e85:	68 9d 0e 80 00       	push   $0x800e9d
  800e8a:	50                   	push   %eax
  800e8b:	e8 c5 fe ff ff       	call   800d55 <sys_env_set_pgfault_upcall>
  800e90:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e93:	8b 45 08             	mov    0x8(%ebp),%eax
  800e96:	a3 0c 40 80 00       	mov    %eax,0x80400c
  800e9b:	c9                   	leave  
  800e9c:	c3                   	ret    

00800e9d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e9d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e9e:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800ea3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800ea5:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  800ea8:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  800eab:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  800eaf:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  800eb4:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  800eb8:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  800eba:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  800ebb:	83 c4 04             	add    $0x4,%esp
	popfl
  800ebe:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800ebf:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  800ec0:	c3                   	ret    

00800ec1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec7:	05 00 00 00 30       	add    $0x30000000,%eax
  800ecc:	c1 e8 0c             	shr    $0xc,%eax
}
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    

00800ed1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ed4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed7:	05 00 00 00 30       	add    $0x30000000,%eax
  800edc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ee1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    

00800ee8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eee:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ef3:	89 c2                	mov    %eax,%edx
  800ef5:	c1 ea 16             	shr    $0x16,%edx
  800ef8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eff:	f6 c2 01             	test   $0x1,%dl
  800f02:	74 11                	je     800f15 <fd_alloc+0x2d>
  800f04:	89 c2                	mov    %eax,%edx
  800f06:	c1 ea 0c             	shr    $0xc,%edx
  800f09:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f10:	f6 c2 01             	test   $0x1,%dl
  800f13:	75 09                	jne    800f1e <fd_alloc+0x36>
			*fd_store = fd;
  800f15:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f17:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1c:	eb 17                	jmp    800f35 <fd_alloc+0x4d>
  800f1e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f23:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f28:	75 c9                	jne    800ef3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f2a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f30:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f35:	5d                   	pop    %ebp
  800f36:	c3                   	ret    

00800f37 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f3d:	83 f8 1f             	cmp    $0x1f,%eax
  800f40:	77 36                	ja     800f78 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f42:	c1 e0 0c             	shl    $0xc,%eax
  800f45:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f4a:	89 c2                	mov    %eax,%edx
  800f4c:	c1 ea 16             	shr    $0x16,%edx
  800f4f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f56:	f6 c2 01             	test   $0x1,%dl
  800f59:	74 24                	je     800f7f <fd_lookup+0x48>
  800f5b:	89 c2                	mov    %eax,%edx
  800f5d:	c1 ea 0c             	shr    $0xc,%edx
  800f60:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f67:	f6 c2 01             	test   $0x1,%dl
  800f6a:	74 1a                	je     800f86 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f6f:	89 02                	mov    %eax,(%edx)
	return 0;
  800f71:	b8 00 00 00 00       	mov    $0x0,%eax
  800f76:	eb 13                	jmp    800f8b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f78:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f7d:	eb 0c                	jmp    800f8b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f7f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f84:	eb 05                	jmp    800f8b <fd_lookup+0x54>
  800f86:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	83 ec 08             	sub    $0x8,%esp
  800f93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f96:	ba 50 28 80 00       	mov    $0x802850,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f9b:	eb 13                	jmp    800fb0 <dev_lookup+0x23>
  800f9d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800fa0:	39 08                	cmp    %ecx,(%eax)
  800fa2:	75 0c                	jne    800fb0 <dev_lookup+0x23>
			*dev = devtab[i];
  800fa4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa7:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fa9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fae:	eb 2e                	jmp    800fde <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fb0:	8b 02                	mov    (%edx),%eax
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	75 e7                	jne    800f9d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fb6:	a1 08 40 80 00       	mov    0x804008,%eax
  800fbb:	8b 40 48             	mov    0x48(%eax),%eax
  800fbe:	83 ec 04             	sub    $0x4,%esp
  800fc1:	51                   	push   %ecx
  800fc2:	50                   	push   %eax
  800fc3:	68 d0 27 80 00       	push   $0x8027d0
  800fc8:	e8 36 f2 ff ff       	call   800203 <cprintf>
	*dev = 0;
  800fcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fd6:	83 c4 10             	add    $0x10,%esp
  800fd9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fde:	c9                   	leave  
  800fdf:	c3                   	ret    

00800fe0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	56                   	push   %esi
  800fe4:	53                   	push   %ebx
  800fe5:	83 ec 10             	sub    $0x10,%esp
  800fe8:	8b 75 08             	mov    0x8(%ebp),%esi
  800feb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff1:	50                   	push   %eax
  800ff2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ff8:	c1 e8 0c             	shr    $0xc,%eax
  800ffb:	50                   	push   %eax
  800ffc:	e8 36 ff ff ff       	call   800f37 <fd_lookup>
  801001:	83 c4 08             	add    $0x8,%esp
  801004:	85 c0                	test   %eax,%eax
  801006:	78 05                	js     80100d <fd_close+0x2d>
	    || fd != fd2)
  801008:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80100b:	74 0c                	je     801019 <fd_close+0x39>
		return (must_exist ? r : 0);
  80100d:	84 db                	test   %bl,%bl
  80100f:	ba 00 00 00 00       	mov    $0x0,%edx
  801014:	0f 44 c2             	cmove  %edx,%eax
  801017:	eb 41                	jmp    80105a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801019:	83 ec 08             	sub    $0x8,%esp
  80101c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80101f:	50                   	push   %eax
  801020:	ff 36                	pushl  (%esi)
  801022:	e8 66 ff ff ff       	call   800f8d <dev_lookup>
  801027:	89 c3                	mov    %eax,%ebx
  801029:	83 c4 10             	add    $0x10,%esp
  80102c:	85 c0                	test   %eax,%eax
  80102e:	78 1a                	js     80104a <fd_close+0x6a>
		if (dev->dev_close)
  801030:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801033:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801036:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80103b:	85 c0                	test   %eax,%eax
  80103d:	74 0b                	je     80104a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80103f:	83 ec 0c             	sub    $0xc,%esp
  801042:	56                   	push   %esi
  801043:	ff d0                	call   *%eax
  801045:	89 c3                	mov    %eax,%ebx
  801047:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80104a:	83 ec 08             	sub    $0x8,%esp
  80104d:	56                   	push   %esi
  80104e:	6a 00                	push   $0x0
  801050:	e8 3a fc ff ff       	call   800c8f <sys_page_unmap>
	return r;
  801055:	83 c4 10             	add    $0x10,%esp
  801058:	89 d8                	mov    %ebx,%eax
}
  80105a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80105d:	5b                   	pop    %ebx
  80105e:	5e                   	pop    %esi
  80105f:	5d                   	pop    %ebp
  801060:	c3                   	ret    

00801061 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801067:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80106a:	50                   	push   %eax
  80106b:	ff 75 08             	pushl  0x8(%ebp)
  80106e:	e8 c4 fe ff ff       	call   800f37 <fd_lookup>
  801073:	83 c4 08             	add    $0x8,%esp
  801076:	85 c0                	test   %eax,%eax
  801078:	78 10                	js     80108a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80107a:	83 ec 08             	sub    $0x8,%esp
  80107d:	6a 01                	push   $0x1
  80107f:	ff 75 f4             	pushl  -0xc(%ebp)
  801082:	e8 59 ff ff ff       	call   800fe0 <fd_close>
  801087:	83 c4 10             	add    $0x10,%esp
}
  80108a:	c9                   	leave  
  80108b:	c3                   	ret    

0080108c <close_all>:

void
close_all(void)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	53                   	push   %ebx
  801090:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801093:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801098:	83 ec 0c             	sub    $0xc,%esp
  80109b:	53                   	push   %ebx
  80109c:	e8 c0 ff ff ff       	call   801061 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010a1:	83 c3 01             	add    $0x1,%ebx
  8010a4:	83 c4 10             	add    $0x10,%esp
  8010a7:	83 fb 20             	cmp    $0x20,%ebx
  8010aa:	75 ec                	jne    801098 <close_all+0xc>
		close(i);
}
  8010ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010af:	c9                   	leave  
  8010b0:	c3                   	ret    

008010b1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010b1:	55                   	push   %ebp
  8010b2:	89 e5                	mov    %esp,%ebp
  8010b4:	57                   	push   %edi
  8010b5:	56                   	push   %esi
  8010b6:	53                   	push   %ebx
  8010b7:	83 ec 2c             	sub    $0x2c,%esp
  8010ba:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010bd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010c0:	50                   	push   %eax
  8010c1:	ff 75 08             	pushl  0x8(%ebp)
  8010c4:	e8 6e fe ff ff       	call   800f37 <fd_lookup>
  8010c9:	83 c4 08             	add    $0x8,%esp
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	0f 88 c1 00 00 00    	js     801195 <dup+0xe4>
		return r;
	close(newfdnum);
  8010d4:	83 ec 0c             	sub    $0xc,%esp
  8010d7:	56                   	push   %esi
  8010d8:	e8 84 ff ff ff       	call   801061 <close>

	newfd = INDEX2FD(newfdnum);
  8010dd:	89 f3                	mov    %esi,%ebx
  8010df:	c1 e3 0c             	shl    $0xc,%ebx
  8010e2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010e8:	83 c4 04             	add    $0x4,%esp
  8010eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ee:	e8 de fd ff ff       	call   800ed1 <fd2data>
  8010f3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010f5:	89 1c 24             	mov    %ebx,(%esp)
  8010f8:	e8 d4 fd ff ff       	call   800ed1 <fd2data>
  8010fd:	83 c4 10             	add    $0x10,%esp
  801100:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801103:	89 f8                	mov    %edi,%eax
  801105:	c1 e8 16             	shr    $0x16,%eax
  801108:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80110f:	a8 01                	test   $0x1,%al
  801111:	74 37                	je     80114a <dup+0x99>
  801113:	89 f8                	mov    %edi,%eax
  801115:	c1 e8 0c             	shr    $0xc,%eax
  801118:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80111f:	f6 c2 01             	test   $0x1,%dl
  801122:	74 26                	je     80114a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801124:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80112b:	83 ec 0c             	sub    $0xc,%esp
  80112e:	25 07 0e 00 00       	and    $0xe07,%eax
  801133:	50                   	push   %eax
  801134:	ff 75 d4             	pushl  -0x2c(%ebp)
  801137:	6a 00                	push   $0x0
  801139:	57                   	push   %edi
  80113a:	6a 00                	push   $0x0
  80113c:	e8 0c fb ff ff       	call   800c4d <sys_page_map>
  801141:	89 c7                	mov    %eax,%edi
  801143:	83 c4 20             	add    $0x20,%esp
  801146:	85 c0                	test   %eax,%eax
  801148:	78 2e                	js     801178 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80114a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80114d:	89 d0                	mov    %edx,%eax
  80114f:	c1 e8 0c             	shr    $0xc,%eax
  801152:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801159:	83 ec 0c             	sub    $0xc,%esp
  80115c:	25 07 0e 00 00       	and    $0xe07,%eax
  801161:	50                   	push   %eax
  801162:	53                   	push   %ebx
  801163:	6a 00                	push   $0x0
  801165:	52                   	push   %edx
  801166:	6a 00                	push   $0x0
  801168:	e8 e0 fa ff ff       	call   800c4d <sys_page_map>
  80116d:	89 c7                	mov    %eax,%edi
  80116f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801172:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801174:	85 ff                	test   %edi,%edi
  801176:	79 1d                	jns    801195 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801178:	83 ec 08             	sub    $0x8,%esp
  80117b:	53                   	push   %ebx
  80117c:	6a 00                	push   $0x0
  80117e:	e8 0c fb ff ff       	call   800c8f <sys_page_unmap>
	sys_page_unmap(0, nva);
  801183:	83 c4 08             	add    $0x8,%esp
  801186:	ff 75 d4             	pushl  -0x2c(%ebp)
  801189:	6a 00                	push   $0x0
  80118b:	e8 ff fa ff ff       	call   800c8f <sys_page_unmap>
	return r;
  801190:	83 c4 10             	add    $0x10,%esp
  801193:	89 f8                	mov    %edi,%eax
}
  801195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801198:	5b                   	pop    %ebx
  801199:	5e                   	pop    %esi
  80119a:	5f                   	pop    %edi
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	53                   	push   %ebx
  8011a1:	83 ec 14             	sub    $0x14,%esp
  8011a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011aa:	50                   	push   %eax
  8011ab:	53                   	push   %ebx
  8011ac:	e8 86 fd ff ff       	call   800f37 <fd_lookup>
  8011b1:	83 c4 08             	add    $0x8,%esp
  8011b4:	89 c2                	mov    %eax,%edx
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	78 6d                	js     801227 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ba:	83 ec 08             	sub    $0x8,%esp
  8011bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c0:	50                   	push   %eax
  8011c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c4:	ff 30                	pushl  (%eax)
  8011c6:	e8 c2 fd ff ff       	call   800f8d <dev_lookup>
  8011cb:	83 c4 10             	add    $0x10,%esp
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	78 4c                	js     80121e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011d2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011d5:	8b 42 08             	mov    0x8(%edx),%eax
  8011d8:	83 e0 03             	and    $0x3,%eax
  8011db:	83 f8 01             	cmp    $0x1,%eax
  8011de:	75 21                	jne    801201 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e0:	a1 08 40 80 00       	mov    0x804008,%eax
  8011e5:	8b 40 48             	mov    0x48(%eax),%eax
  8011e8:	83 ec 04             	sub    $0x4,%esp
  8011eb:	53                   	push   %ebx
  8011ec:	50                   	push   %eax
  8011ed:	68 14 28 80 00       	push   $0x802814
  8011f2:	e8 0c f0 ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  8011f7:	83 c4 10             	add    $0x10,%esp
  8011fa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011ff:	eb 26                	jmp    801227 <read+0x8a>
	}
	if (!dev->dev_read)
  801201:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801204:	8b 40 08             	mov    0x8(%eax),%eax
  801207:	85 c0                	test   %eax,%eax
  801209:	74 17                	je     801222 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80120b:	83 ec 04             	sub    $0x4,%esp
  80120e:	ff 75 10             	pushl  0x10(%ebp)
  801211:	ff 75 0c             	pushl  0xc(%ebp)
  801214:	52                   	push   %edx
  801215:	ff d0                	call   *%eax
  801217:	89 c2                	mov    %eax,%edx
  801219:	83 c4 10             	add    $0x10,%esp
  80121c:	eb 09                	jmp    801227 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80121e:	89 c2                	mov    %eax,%edx
  801220:	eb 05                	jmp    801227 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801222:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801227:	89 d0                	mov    %edx,%eax
  801229:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122c:	c9                   	leave  
  80122d:	c3                   	ret    

0080122e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	57                   	push   %edi
  801232:	56                   	push   %esi
  801233:	53                   	push   %ebx
  801234:	83 ec 0c             	sub    $0xc,%esp
  801237:	8b 7d 08             	mov    0x8(%ebp),%edi
  80123a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80123d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801242:	eb 21                	jmp    801265 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801244:	83 ec 04             	sub    $0x4,%esp
  801247:	89 f0                	mov    %esi,%eax
  801249:	29 d8                	sub    %ebx,%eax
  80124b:	50                   	push   %eax
  80124c:	89 d8                	mov    %ebx,%eax
  80124e:	03 45 0c             	add    0xc(%ebp),%eax
  801251:	50                   	push   %eax
  801252:	57                   	push   %edi
  801253:	e8 45 ff ff ff       	call   80119d <read>
		if (m < 0)
  801258:	83 c4 10             	add    $0x10,%esp
  80125b:	85 c0                	test   %eax,%eax
  80125d:	78 10                	js     80126f <readn+0x41>
			return m;
		if (m == 0)
  80125f:	85 c0                	test   %eax,%eax
  801261:	74 0a                	je     80126d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801263:	01 c3                	add    %eax,%ebx
  801265:	39 f3                	cmp    %esi,%ebx
  801267:	72 db                	jb     801244 <readn+0x16>
  801269:	89 d8                	mov    %ebx,%eax
  80126b:	eb 02                	jmp    80126f <readn+0x41>
  80126d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80126f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801272:	5b                   	pop    %ebx
  801273:	5e                   	pop    %esi
  801274:	5f                   	pop    %edi
  801275:	5d                   	pop    %ebp
  801276:	c3                   	ret    

00801277 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	53                   	push   %ebx
  80127b:	83 ec 14             	sub    $0x14,%esp
  80127e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801281:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801284:	50                   	push   %eax
  801285:	53                   	push   %ebx
  801286:	e8 ac fc ff ff       	call   800f37 <fd_lookup>
  80128b:	83 c4 08             	add    $0x8,%esp
  80128e:	89 c2                	mov    %eax,%edx
  801290:	85 c0                	test   %eax,%eax
  801292:	78 68                	js     8012fc <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801294:	83 ec 08             	sub    $0x8,%esp
  801297:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129a:	50                   	push   %eax
  80129b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129e:	ff 30                	pushl  (%eax)
  8012a0:	e8 e8 fc ff ff       	call   800f8d <dev_lookup>
  8012a5:	83 c4 10             	add    $0x10,%esp
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	78 47                	js     8012f3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012af:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012b3:	75 21                	jne    8012d6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012b5:	a1 08 40 80 00       	mov    0x804008,%eax
  8012ba:	8b 40 48             	mov    0x48(%eax),%eax
  8012bd:	83 ec 04             	sub    $0x4,%esp
  8012c0:	53                   	push   %ebx
  8012c1:	50                   	push   %eax
  8012c2:	68 30 28 80 00       	push   $0x802830
  8012c7:	e8 37 ef ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012d4:	eb 26                	jmp    8012fc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d9:	8b 52 0c             	mov    0xc(%edx),%edx
  8012dc:	85 d2                	test   %edx,%edx
  8012de:	74 17                	je     8012f7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012e0:	83 ec 04             	sub    $0x4,%esp
  8012e3:	ff 75 10             	pushl  0x10(%ebp)
  8012e6:	ff 75 0c             	pushl  0xc(%ebp)
  8012e9:	50                   	push   %eax
  8012ea:	ff d2                	call   *%edx
  8012ec:	89 c2                	mov    %eax,%edx
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	eb 09                	jmp    8012fc <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f3:	89 c2                	mov    %eax,%edx
  8012f5:	eb 05                	jmp    8012fc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012f7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012fc:	89 d0                	mov    %edx,%eax
  8012fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801301:	c9                   	leave  
  801302:	c3                   	ret    

00801303 <seek>:

int
seek(int fdnum, off_t offset)
{
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
  801306:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801309:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80130c:	50                   	push   %eax
  80130d:	ff 75 08             	pushl  0x8(%ebp)
  801310:	e8 22 fc ff ff       	call   800f37 <fd_lookup>
  801315:	83 c4 08             	add    $0x8,%esp
  801318:	85 c0                	test   %eax,%eax
  80131a:	78 0e                	js     80132a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80131c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80131f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801322:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801325:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80132a:	c9                   	leave  
  80132b:	c3                   	ret    

0080132c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	53                   	push   %ebx
  801330:	83 ec 14             	sub    $0x14,%esp
  801333:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801336:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801339:	50                   	push   %eax
  80133a:	53                   	push   %ebx
  80133b:	e8 f7 fb ff ff       	call   800f37 <fd_lookup>
  801340:	83 c4 08             	add    $0x8,%esp
  801343:	89 c2                	mov    %eax,%edx
  801345:	85 c0                	test   %eax,%eax
  801347:	78 65                	js     8013ae <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801349:	83 ec 08             	sub    $0x8,%esp
  80134c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134f:	50                   	push   %eax
  801350:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801353:	ff 30                	pushl  (%eax)
  801355:	e8 33 fc ff ff       	call   800f8d <dev_lookup>
  80135a:	83 c4 10             	add    $0x10,%esp
  80135d:	85 c0                	test   %eax,%eax
  80135f:	78 44                	js     8013a5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801361:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801364:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801368:	75 21                	jne    80138b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80136a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80136f:	8b 40 48             	mov    0x48(%eax),%eax
  801372:	83 ec 04             	sub    $0x4,%esp
  801375:	53                   	push   %ebx
  801376:	50                   	push   %eax
  801377:	68 f0 27 80 00       	push   $0x8027f0
  80137c:	e8 82 ee ff ff       	call   800203 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801381:	83 c4 10             	add    $0x10,%esp
  801384:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801389:	eb 23                	jmp    8013ae <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80138b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80138e:	8b 52 18             	mov    0x18(%edx),%edx
  801391:	85 d2                	test   %edx,%edx
  801393:	74 14                	je     8013a9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801395:	83 ec 08             	sub    $0x8,%esp
  801398:	ff 75 0c             	pushl  0xc(%ebp)
  80139b:	50                   	push   %eax
  80139c:	ff d2                	call   *%edx
  80139e:	89 c2                	mov    %eax,%edx
  8013a0:	83 c4 10             	add    $0x10,%esp
  8013a3:	eb 09                	jmp    8013ae <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a5:	89 c2                	mov    %eax,%edx
  8013a7:	eb 05                	jmp    8013ae <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013a9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013ae:	89 d0                	mov    %edx,%eax
  8013b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b3:	c9                   	leave  
  8013b4:	c3                   	ret    

008013b5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013b5:	55                   	push   %ebp
  8013b6:	89 e5                	mov    %esp,%ebp
  8013b8:	53                   	push   %ebx
  8013b9:	83 ec 14             	sub    $0x14,%esp
  8013bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c2:	50                   	push   %eax
  8013c3:	ff 75 08             	pushl  0x8(%ebp)
  8013c6:	e8 6c fb ff ff       	call   800f37 <fd_lookup>
  8013cb:	83 c4 08             	add    $0x8,%esp
  8013ce:	89 c2                	mov    %eax,%edx
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	78 58                	js     80142c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d4:	83 ec 08             	sub    $0x8,%esp
  8013d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013da:	50                   	push   %eax
  8013db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013de:	ff 30                	pushl  (%eax)
  8013e0:	e8 a8 fb ff ff       	call   800f8d <dev_lookup>
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	85 c0                	test   %eax,%eax
  8013ea:	78 37                	js     801423 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ef:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013f3:	74 32                	je     801427 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013f5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013f8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013ff:	00 00 00 
	stat->st_isdir = 0;
  801402:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801409:	00 00 00 
	stat->st_dev = dev;
  80140c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801412:	83 ec 08             	sub    $0x8,%esp
  801415:	53                   	push   %ebx
  801416:	ff 75 f0             	pushl  -0x10(%ebp)
  801419:	ff 50 14             	call   *0x14(%eax)
  80141c:	89 c2                	mov    %eax,%edx
  80141e:	83 c4 10             	add    $0x10,%esp
  801421:	eb 09                	jmp    80142c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801423:	89 c2                	mov    %eax,%edx
  801425:	eb 05                	jmp    80142c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801427:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80142c:	89 d0                	mov    %edx,%eax
  80142e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801431:	c9                   	leave  
  801432:	c3                   	ret    

00801433 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	56                   	push   %esi
  801437:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801438:	83 ec 08             	sub    $0x8,%esp
  80143b:	6a 00                	push   $0x0
  80143d:	ff 75 08             	pushl  0x8(%ebp)
  801440:	e8 e3 01 00 00       	call   801628 <open>
  801445:	89 c3                	mov    %eax,%ebx
  801447:	83 c4 10             	add    $0x10,%esp
  80144a:	85 c0                	test   %eax,%eax
  80144c:	78 1b                	js     801469 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80144e:	83 ec 08             	sub    $0x8,%esp
  801451:	ff 75 0c             	pushl  0xc(%ebp)
  801454:	50                   	push   %eax
  801455:	e8 5b ff ff ff       	call   8013b5 <fstat>
  80145a:	89 c6                	mov    %eax,%esi
	close(fd);
  80145c:	89 1c 24             	mov    %ebx,(%esp)
  80145f:	e8 fd fb ff ff       	call   801061 <close>
	return r;
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	89 f0                	mov    %esi,%eax
}
  801469:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80146c:	5b                   	pop    %ebx
  80146d:	5e                   	pop    %esi
  80146e:	5d                   	pop    %ebp
  80146f:	c3                   	ret    

00801470 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	56                   	push   %esi
  801474:	53                   	push   %ebx
  801475:	89 c6                	mov    %eax,%esi
  801477:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801479:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801480:	75 12                	jne    801494 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801482:	83 ec 0c             	sub    $0xc,%esp
  801485:	6a 01                	push   $0x1
  801487:	e8 43 0c 00 00       	call   8020cf <ipc_find_env>
  80148c:	a3 00 40 80 00       	mov    %eax,0x804000
  801491:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801494:	6a 07                	push   $0x7
  801496:	68 00 50 80 00       	push   $0x805000
  80149b:	56                   	push   %esi
  80149c:	ff 35 00 40 80 00    	pushl  0x804000
  8014a2:	e8 d4 0b 00 00       	call   80207b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014a7:	83 c4 0c             	add    $0xc,%esp
  8014aa:	6a 00                	push   $0x0
  8014ac:	53                   	push   %ebx
  8014ad:	6a 00                	push   $0x0
  8014af:	e8 5e 0b 00 00       	call   802012 <ipc_recv>
}
  8014b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b7:	5b                   	pop    %ebx
  8014b8:	5e                   	pop    %esi
  8014b9:	5d                   	pop    %ebp
  8014ba:	c3                   	ret    

008014bb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014cf:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d9:	b8 02 00 00 00       	mov    $0x2,%eax
  8014de:	e8 8d ff ff ff       	call   801470 <fsipc>
}
  8014e3:	c9                   	leave  
  8014e4:	c3                   	ret    

008014e5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ee:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fb:	b8 06 00 00 00       	mov    $0x6,%eax
  801500:	e8 6b ff ff ff       	call   801470 <fsipc>
}
  801505:	c9                   	leave  
  801506:	c3                   	ret    

00801507 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	53                   	push   %ebx
  80150b:	83 ec 04             	sub    $0x4,%esp
  80150e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801511:	8b 45 08             	mov    0x8(%ebp),%eax
  801514:	8b 40 0c             	mov    0xc(%eax),%eax
  801517:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80151c:	ba 00 00 00 00       	mov    $0x0,%edx
  801521:	b8 05 00 00 00       	mov    $0x5,%eax
  801526:	e8 45 ff ff ff       	call   801470 <fsipc>
  80152b:	85 c0                	test   %eax,%eax
  80152d:	78 2c                	js     80155b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80152f:	83 ec 08             	sub    $0x8,%esp
  801532:	68 00 50 80 00       	push   $0x805000
  801537:	53                   	push   %ebx
  801538:	e8 ca f2 ff ff       	call   800807 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80153d:	a1 80 50 80 00       	mov    0x805080,%eax
  801542:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801548:	a1 84 50 80 00       	mov    0x805084,%eax
  80154d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80155b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155e:	c9                   	leave  
  80155f:	c3                   	ret    

00801560 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801560:	55                   	push   %ebp
  801561:	89 e5                	mov    %esp,%ebp
  801563:	83 ec 0c             	sub    $0xc,%esp
  801566:	8b 45 10             	mov    0x10(%ebp),%eax
  801569:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80156e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801573:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801576:	8b 55 08             	mov    0x8(%ebp),%edx
  801579:	8b 52 0c             	mov    0xc(%edx),%edx
  80157c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801582:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801587:	50                   	push   %eax
  801588:	ff 75 0c             	pushl  0xc(%ebp)
  80158b:	68 08 50 80 00       	push   $0x805008
  801590:	e8 04 f4 ff ff       	call   800999 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801595:	ba 00 00 00 00       	mov    $0x0,%edx
  80159a:	b8 04 00 00 00       	mov    $0x4,%eax
  80159f:	e8 cc fe ff ff       	call   801470 <fsipc>
	//panic("devfile_write not implemented");
}
  8015a4:	c9                   	leave  
  8015a5:	c3                   	ret    

008015a6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015a6:	55                   	push   %ebp
  8015a7:	89 e5                	mov    %esp,%ebp
  8015a9:	56                   	push   %esi
  8015aa:	53                   	push   %ebx
  8015ab:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b1:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015b9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c4:	b8 03 00 00 00       	mov    $0x3,%eax
  8015c9:	e8 a2 fe ff ff       	call   801470 <fsipc>
  8015ce:	89 c3                	mov    %eax,%ebx
  8015d0:	85 c0                	test   %eax,%eax
  8015d2:	78 4b                	js     80161f <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015d4:	39 c6                	cmp    %eax,%esi
  8015d6:	73 16                	jae    8015ee <devfile_read+0x48>
  8015d8:	68 64 28 80 00       	push   $0x802864
  8015dd:	68 6b 28 80 00       	push   $0x80286b
  8015e2:	6a 7c                	push   $0x7c
  8015e4:	68 80 28 80 00       	push   $0x802880
  8015e9:	e8 3c eb ff ff       	call   80012a <_panic>
	assert(r <= PGSIZE);
  8015ee:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015f3:	7e 16                	jle    80160b <devfile_read+0x65>
  8015f5:	68 8b 28 80 00       	push   $0x80288b
  8015fa:	68 6b 28 80 00       	push   $0x80286b
  8015ff:	6a 7d                	push   $0x7d
  801601:	68 80 28 80 00       	push   $0x802880
  801606:	e8 1f eb ff ff       	call   80012a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80160b:	83 ec 04             	sub    $0x4,%esp
  80160e:	50                   	push   %eax
  80160f:	68 00 50 80 00       	push   $0x805000
  801614:	ff 75 0c             	pushl  0xc(%ebp)
  801617:	e8 7d f3 ff ff       	call   800999 <memmove>
	return r;
  80161c:	83 c4 10             	add    $0x10,%esp
}
  80161f:	89 d8                	mov    %ebx,%eax
  801621:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801624:	5b                   	pop    %ebx
  801625:	5e                   	pop    %esi
  801626:	5d                   	pop    %ebp
  801627:	c3                   	ret    

00801628 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801628:	55                   	push   %ebp
  801629:	89 e5                	mov    %esp,%ebp
  80162b:	53                   	push   %ebx
  80162c:	83 ec 20             	sub    $0x20,%esp
  80162f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801632:	53                   	push   %ebx
  801633:	e8 96 f1 ff ff       	call   8007ce <strlen>
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801640:	7f 67                	jg     8016a9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801642:	83 ec 0c             	sub    $0xc,%esp
  801645:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801648:	50                   	push   %eax
  801649:	e8 9a f8 ff ff       	call   800ee8 <fd_alloc>
  80164e:	83 c4 10             	add    $0x10,%esp
		return r;
  801651:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801653:	85 c0                	test   %eax,%eax
  801655:	78 57                	js     8016ae <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801657:	83 ec 08             	sub    $0x8,%esp
  80165a:	53                   	push   %ebx
  80165b:	68 00 50 80 00       	push   $0x805000
  801660:	e8 a2 f1 ff ff       	call   800807 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801665:	8b 45 0c             	mov    0xc(%ebp),%eax
  801668:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80166d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801670:	b8 01 00 00 00       	mov    $0x1,%eax
  801675:	e8 f6 fd ff ff       	call   801470 <fsipc>
  80167a:	89 c3                	mov    %eax,%ebx
  80167c:	83 c4 10             	add    $0x10,%esp
  80167f:	85 c0                	test   %eax,%eax
  801681:	79 14                	jns    801697 <open+0x6f>
		fd_close(fd, 0);
  801683:	83 ec 08             	sub    $0x8,%esp
  801686:	6a 00                	push   $0x0
  801688:	ff 75 f4             	pushl  -0xc(%ebp)
  80168b:	e8 50 f9 ff ff       	call   800fe0 <fd_close>
		return r;
  801690:	83 c4 10             	add    $0x10,%esp
  801693:	89 da                	mov    %ebx,%edx
  801695:	eb 17                	jmp    8016ae <open+0x86>
	}

	return fd2num(fd);
  801697:	83 ec 0c             	sub    $0xc,%esp
  80169a:	ff 75 f4             	pushl  -0xc(%ebp)
  80169d:	e8 1f f8 ff ff       	call   800ec1 <fd2num>
  8016a2:	89 c2                	mov    %eax,%edx
  8016a4:	83 c4 10             	add    $0x10,%esp
  8016a7:	eb 05                	jmp    8016ae <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016a9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016ae:	89 d0                	mov    %edx,%eax
  8016b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b3:	c9                   	leave  
  8016b4:	c3                   	ret    

008016b5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c0:	b8 08 00 00 00       	mov    $0x8,%eax
  8016c5:	e8 a6 fd ff ff       	call   801470 <fsipc>
}
  8016ca:	c9                   	leave  
  8016cb:	c3                   	ret    

008016cc <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8016d2:	68 97 28 80 00       	push   $0x802897
  8016d7:	ff 75 0c             	pushl  0xc(%ebp)
  8016da:	e8 28 f1 ff ff       	call   800807 <strcpy>
	return 0;
}
  8016df:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e4:	c9                   	leave  
  8016e5:	c3                   	ret    

008016e6 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	53                   	push   %ebx
  8016ea:	83 ec 10             	sub    $0x10,%esp
  8016ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8016f0:	53                   	push   %ebx
  8016f1:	e8 12 0a 00 00       	call   802108 <pageref>
  8016f6:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8016f9:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8016fe:	83 f8 01             	cmp    $0x1,%eax
  801701:	75 10                	jne    801713 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801703:	83 ec 0c             	sub    $0xc,%esp
  801706:	ff 73 0c             	pushl  0xc(%ebx)
  801709:	e8 c0 02 00 00       	call   8019ce <nsipc_close>
  80170e:	89 c2                	mov    %eax,%edx
  801710:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801713:	89 d0                	mov    %edx,%eax
  801715:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801718:	c9                   	leave  
  801719:	c3                   	ret    

0080171a <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801720:	6a 00                	push   $0x0
  801722:	ff 75 10             	pushl  0x10(%ebp)
  801725:	ff 75 0c             	pushl  0xc(%ebp)
  801728:	8b 45 08             	mov    0x8(%ebp),%eax
  80172b:	ff 70 0c             	pushl  0xc(%eax)
  80172e:	e8 78 03 00 00       	call   801aab <nsipc_send>
}
  801733:	c9                   	leave  
  801734:	c3                   	ret    

00801735 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80173b:	6a 00                	push   $0x0
  80173d:	ff 75 10             	pushl  0x10(%ebp)
  801740:	ff 75 0c             	pushl  0xc(%ebp)
  801743:	8b 45 08             	mov    0x8(%ebp),%eax
  801746:	ff 70 0c             	pushl  0xc(%eax)
  801749:	e8 f1 02 00 00       	call   801a3f <nsipc_recv>
}
  80174e:	c9                   	leave  
  80174f:	c3                   	ret    

00801750 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801756:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801759:	52                   	push   %edx
  80175a:	50                   	push   %eax
  80175b:	e8 d7 f7 ff ff       	call   800f37 <fd_lookup>
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	85 c0                	test   %eax,%eax
  801765:	78 17                	js     80177e <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801767:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80176a:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801770:	39 08                	cmp    %ecx,(%eax)
  801772:	75 05                	jne    801779 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801774:	8b 40 0c             	mov    0xc(%eax),%eax
  801777:	eb 05                	jmp    80177e <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801779:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80177e:	c9                   	leave  
  80177f:	c3                   	ret    

00801780 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	56                   	push   %esi
  801784:	53                   	push   %ebx
  801785:	83 ec 1c             	sub    $0x1c,%esp
  801788:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80178a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178d:	50                   	push   %eax
  80178e:	e8 55 f7 ff ff       	call   800ee8 <fd_alloc>
  801793:	89 c3                	mov    %eax,%ebx
  801795:	83 c4 10             	add    $0x10,%esp
  801798:	85 c0                	test   %eax,%eax
  80179a:	78 1b                	js     8017b7 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80179c:	83 ec 04             	sub    $0x4,%esp
  80179f:	68 07 04 00 00       	push   $0x407
  8017a4:	ff 75 f4             	pushl  -0xc(%ebp)
  8017a7:	6a 00                	push   $0x0
  8017a9:	e8 5c f4 ff ff       	call   800c0a <sys_page_alloc>
  8017ae:	89 c3                	mov    %eax,%ebx
  8017b0:	83 c4 10             	add    $0x10,%esp
  8017b3:	85 c0                	test   %eax,%eax
  8017b5:	79 10                	jns    8017c7 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8017b7:	83 ec 0c             	sub    $0xc,%esp
  8017ba:	56                   	push   %esi
  8017bb:	e8 0e 02 00 00       	call   8019ce <nsipc_close>
		return r;
  8017c0:	83 c4 10             	add    $0x10,%esp
  8017c3:	89 d8                	mov    %ebx,%eax
  8017c5:	eb 24                	jmp    8017eb <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8017c7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d0:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8017d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8017dc:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8017df:	83 ec 0c             	sub    $0xc,%esp
  8017e2:	50                   	push   %eax
  8017e3:	e8 d9 f6 ff ff       	call   800ec1 <fd2num>
  8017e8:	83 c4 10             	add    $0x10,%esp
}
  8017eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ee:	5b                   	pop    %ebx
  8017ef:	5e                   	pop    %esi
  8017f0:	5d                   	pop    %ebp
  8017f1:	c3                   	ret    

008017f2 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fb:	e8 50 ff ff ff       	call   801750 <fd2sockid>
		return r;
  801800:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801802:	85 c0                	test   %eax,%eax
  801804:	78 1f                	js     801825 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801806:	83 ec 04             	sub    $0x4,%esp
  801809:	ff 75 10             	pushl  0x10(%ebp)
  80180c:	ff 75 0c             	pushl  0xc(%ebp)
  80180f:	50                   	push   %eax
  801810:	e8 12 01 00 00       	call   801927 <nsipc_accept>
  801815:	83 c4 10             	add    $0x10,%esp
		return r;
  801818:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80181a:	85 c0                	test   %eax,%eax
  80181c:	78 07                	js     801825 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80181e:	e8 5d ff ff ff       	call   801780 <alloc_sockfd>
  801823:	89 c1                	mov    %eax,%ecx
}
  801825:	89 c8                	mov    %ecx,%eax
  801827:	c9                   	leave  
  801828:	c3                   	ret    

00801829 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801829:	55                   	push   %ebp
  80182a:	89 e5                	mov    %esp,%ebp
  80182c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80182f:	8b 45 08             	mov    0x8(%ebp),%eax
  801832:	e8 19 ff ff ff       	call   801750 <fd2sockid>
  801837:	85 c0                	test   %eax,%eax
  801839:	78 12                	js     80184d <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80183b:	83 ec 04             	sub    $0x4,%esp
  80183e:	ff 75 10             	pushl  0x10(%ebp)
  801841:	ff 75 0c             	pushl  0xc(%ebp)
  801844:	50                   	push   %eax
  801845:	e8 2d 01 00 00       	call   801977 <nsipc_bind>
  80184a:	83 c4 10             	add    $0x10,%esp
}
  80184d:	c9                   	leave  
  80184e:	c3                   	ret    

0080184f <shutdown>:

int
shutdown(int s, int how)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801855:	8b 45 08             	mov    0x8(%ebp),%eax
  801858:	e8 f3 fe ff ff       	call   801750 <fd2sockid>
  80185d:	85 c0                	test   %eax,%eax
  80185f:	78 0f                	js     801870 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801861:	83 ec 08             	sub    $0x8,%esp
  801864:	ff 75 0c             	pushl  0xc(%ebp)
  801867:	50                   	push   %eax
  801868:	e8 3f 01 00 00       	call   8019ac <nsipc_shutdown>
  80186d:	83 c4 10             	add    $0x10,%esp
}
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801878:	8b 45 08             	mov    0x8(%ebp),%eax
  80187b:	e8 d0 fe ff ff       	call   801750 <fd2sockid>
  801880:	85 c0                	test   %eax,%eax
  801882:	78 12                	js     801896 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801884:	83 ec 04             	sub    $0x4,%esp
  801887:	ff 75 10             	pushl  0x10(%ebp)
  80188a:	ff 75 0c             	pushl  0xc(%ebp)
  80188d:	50                   	push   %eax
  80188e:	e8 55 01 00 00       	call   8019e8 <nsipc_connect>
  801893:	83 c4 10             	add    $0x10,%esp
}
  801896:	c9                   	leave  
  801897:	c3                   	ret    

00801898 <listen>:

int
listen(int s, int backlog)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80189e:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a1:	e8 aa fe ff ff       	call   801750 <fd2sockid>
  8018a6:	85 c0                	test   %eax,%eax
  8018a8:	78 0f                	js     8018b9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8018aa:	83 ec 08             	sub    $0x8,%esp
  8018ad:	ff 75 0c             	pushl  0xc(%ebp)
  8018b0:	50                   	push   %eax
  8018b1:	e8 67 01 00 00       	call   801a1d <nsipc_listen>
  8018b6:	83 c4 10             	add    $0x10,%esp
}
  8018b9:	c9                   	leave  
  8018ba:	c3                   	ret    

008018bb <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8018c1:	ff 75 10             	pushl  0x10(%ebp)
  8018c4:	ff 75 0c             	pushl  0xc(%ebp)
  8018c7:	ff 75 08             	pushl  0x8(%ebp)
  8018ca:	e8 3a 02 00 00       	call   801b09 <nsipc_socket>
  8018cf:	83 c4 10             	add    $0x10,%esp
  8018d2:	85 c0                	test   %eax,%eax
  8018d4:	78 05                	js     8018db <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8018d6:	e8 a5 fe ff ff       	call   801780 <alloc_sockfd>
}
  8018db:	c9                   	leave  
  8018dc:	c3                   	ret    

008018dd <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8018dd:	55                   	push   %ebp
  8018de:	89 e5                	mov    %esp,%ebp
  8018e0:	53                   	push   %ebx
  8018e1:	83 ec 04             	sub    $0x4,%esp
  8018e4:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8018e6:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8018ed:	75 12                	jne    801901 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8018ef:	83 ec 0c             	sub    $0xc,%esp
  8018f2:	6a 02                	push   $0x2
  8018f4:	e8 d6 07 00 00       	call   8020cf <ipc_find_env>
  8018f9:	a3 04 40 80 00       	mov    %eax,0x804004
  8018fe:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801901:	6a 07                	push   $0x7
  801903:	68 00 60 80 00       	push   $0x806000
  801908:	53                   	push   %ebx
  801909:	ff 35 04 40 80 00    	pushl  0x804004
  80190f:	e8 67 07 00 00       	call   80207b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801914:	83 c4 0c             	add    $0xc,%esp
  801917:	6a 00                	push   $0x0
  801919:	6a 00                	push   $0x0
  80191b:	6a 00                	push   $0x0
  80191d:	e8 f0 06 00 00       	call   802012 <ipc_recv>
}
  801922:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801925:	c9                   	leave  
  801926:	c3                   	ret    

00801927 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	56                   	push   %esi
  80192b:	53                   	push   %ebx
  80192c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80192f:	8b 45 08             	mov    0x8(%ebp),%eax
  801932:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801937:	8b 06                	mov    (%esi),%eax
  801939:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80193e:	b8 01 00 00 00       	mov    $0x1,%eax
  801943:	e8 95 ff ff ff       	call   8018dd <nsipc>
  801948:	89 c3                	mov    %eax,%ebx
  80194a:	85 c0                	test   %eax,%eax
  80194c:	78 20                	js     80196e <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80194e:	83 ec 04             	sub    $0x4,%esp
  801951:	ff 35 10 60 80 00    	pushl  0x806010
  801957:	68 00 60 80 00       	push   $0x806000
  80195c:	ff 75 0c             	pushl  0xc(%ebp)
  80195f:	e8 35 f0 ff ff       	call   800999 <memmove>
		*addrlen = ret->ret_addrlen;
  801964:	a1 10 60 80 00       	mov    0x806010,%eax
  801969:	89 06                	mov    %eax,(%esi)
  80196b:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80196e:	89 d8                	mov    %ebx,%eax
  801970:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801973:	5b                   	pop    %ebx
  801974:	5e                   	pop    %esi
  801975:	5d                   	pop    %ebp
  801976:	c3                   	ret    

00801977 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801977:	55                   	push   %ebp
  801978:	89 e5                	mov    %esp,%ebp
  80197a:	53                   	push   %ebx
  80197b:	83 ec 08             	sub    $0x8,%esp
  80197e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801981:	8b 45 08             	mov    0x8(%ebp),%eax
  801984:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801989:	53                   	push   %ebx
  80198a:	ff 75 0c             	pushl  0xc(%ebp)
  80198d:	68 04 60 80 00       	push   $0x806004
  801992:	e8 02 f0 ff ff       	call   800999 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801997:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80199d:	b8 02 00 00 00       	mov    $0x2,%eax
  8019a2:	e8 36 ff ff ff       	call   8018dd <nsipc>
}
  8019a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019aa:	c9                   	leave  
  8019ab:	c3                   	ret    

008019ac <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8019b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8019ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019bd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8019c2:	b8 03 00 00 00       	mov    $0x3,%eax
  8019c7:	e8 11 ff ff ff       	call   8018dd <nsipc>
}
  8019cc:	c9                   	leave  
  8019cd:	c3                   	ret    

008019ce <nsipc_close>:

int
nsipc_close(int s)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8019d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d7:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8019dc:	b8 04 00 00 00       	mov    $0x4,%eax
  8019e1:	e8 f7 fe ff ff       	call   8018dd <nsipc>
}
  8019e6:	c9                   	leave  
  8019e7:	c3                   	ret    

008019e8 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	53                   	push   %ebx
  8019ec:	83 ec 08             	sub    $0x8,%esp
  8019ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8019f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8019fa:	53                   	push   %ebx
  8019fb:	ff 75 0c             	pushl  0xc(%ebp)
  8019fe:	68 04 60 80 00       	push   $0x806004
  801a03:	e8 91 ef ff ff       	call   800999 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801a08:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801a0e:	b8 05 00 00 00       	mov    $0x5,%eax
  801a13:	e8 c5 fe ff ff       	call   8018dd <nsipc>
}
  801a18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1b:	c9                   	leave  
  801a1c:	c3                   	ret    

00801a1d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801a23:	8b 45 08             	mov    0x8(%ebp),%eax
  801a26:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801a2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801a33:	b8 06 00 00 00       	mov    $0x6,%eax
  801a38:	e8 a0 fe ff ff       	call   8018dd <nsipc>
}
  801a3d:	c9                   	leave  
  801a3e:	c3                   	ret    

00801a3f <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	56                   	push   %esi
  801a43:	53                   	push   %ebx
  801a44:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a47:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801a4f:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801a55:	8b 45 14             	mov    0x14(%ebp),%eax
  801a58:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a5d:	b8 07 00 00 00       	mov    $0x7,%eax
  801a62:	e8 76 fe ff ff       	call   8018dd <nsipc>
  801a67:	89 c3                	mov    %eax,%ebx
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	78 35                	js     801aa2 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801a6d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801a72:	7f 04                	jg     801a78 <nsipc_recv+0x39>
  801a74:	39 c6                	cmp    %eax,%esi
  801a76:	7d 16                	jge    801a8e <nsipc_recv+0x4f>
  801a78:	68 a3 28 80 00       	push   $0x8028a3
  801a7d:	68 6b 28 80 00       	push   $0x80286b
  801a82:	6a 62                	push   $0x62
  801a84:	68 b8 28 80 00       	push   $0x8028b8
  801a89:	e8 9c e6 ff ff       	call   80012a <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a8e:	83 ec 04             	sub    $0x4,%esp
  801a91:	50                   	push   %eax
  801a92:	68 00 60 80 00       	push   $0x806000
  801a97:	ff 75 0c             	pushl  0xc(%ebp)
  801a9a:	e8 fa ee ff ff       	call   800999 <memmove>
  801a9f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801aa2:	89 d8                	mov    %ebx,%eax
  801aa4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa7:	5b                   	pop    %ebx
  801aa8:	5e                   	pop    %esi
  801aa9:	5d                   	pop    %ebp
  801aaa:	c3                   	ret    

00801aab <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	53                   	push   %ebx
  801aaf:	83 ec 04             	sub    $0x4,%esp
  801ab2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ab5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab8:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801abd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ac3:	7e 16                	jle    801adb <nsipc_send+0x30>
  801ac5:	68 c4 28 80 00       	push   $0x8028c4
  801aca:	68 6b 28 80 00       	push   $0x80286b
  801acf:	6a 6d                	push   $0x6d
  801ad1:	68 b8 28 80 00       	push   $0x8028b8
  801ad6:	e8 4f e6 ff ff       	call   80012a <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801adb:	83 ec 04             	sub    $0x4,%esp
  801ade:	53                   	push   %ebx
  801adf:	ff 75 0c             	pushl  0xc(%ebp)
  801ae2:	68 0c 60 80 00       	push   $0x80600c
  801ae7:	e8 ad ee ff ff       	call   800999 <memmove>
	nsipcbuf.send.req_size = size;
  801aec:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801af2:	8b 45 14             	mov    0x14(%ebp),%eax
  801af5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801afa:	b8 08 00 00 00       	mov    $0x8,%eax
  801aff:	e8 d9 fd ff ff       	call   8018dd <nsipc>
}
  801b04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b07:	c9                   	leave  
  801b08:	c3                   	ret    

00801b09 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b12:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801b17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1a:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801b1f:	8b 45 10             	mov    0x10(%ebp),%eax
  801b22:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801b27:	b8 09 00 00 00       	mov    $0x9,%eax
  801b2c:	e8 ac fd ff ff       	call   8018dd <nsipc>
}
  801b31:	c9                   	leave  
  801b32:	c3                   	ret    

00801b33 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	56                   	push   %esi
  801b37:	53                   	push   %ebx
  801b38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b3b:	83 ec 0c             	sub    $0xc,%esp
  801b3e:	ff 75 08             	pushl  0x8(%ebp)
  801b41:	e8 8b f3 ff ff       	call   800ed1 <fd2data>
  801b46:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b48:	83 c4 08             	add    $0x8,%esp
  801b4b:	68 d0 28 80 00       	push   $0x8028d0
  801b50:	53                   	push   %ebx
  801b51:	e8 b1 ec ff ff       	call   800807 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b56:	8b 46 04             	mov    0x4(%esi),%eax
  801b59:	2b 06                	sub    (%esi),%eax
  801b5b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b61:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b68:	00 00 00 
	stat->st_dev = &devpipe;
  801b6b:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b72:	30 80 00 
	return 0;
}
  801b75:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b7d:	5b                   	pop    %ebx
  801b7e:	5e                   	pop    %esi
  801b7f:	5d                   	pop    %ebp
  801b80:	c3                   	ret    

00801b81 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	53                   	push   %ebx
  801b85:	83 ec 0c             	sub    $0xc,%esp
  801b88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b8b:	53                   	push   %ebx
  801b8c:	6a 00                	push   $0x0
  801b8e:	e8 fc f0 ff ff       	call   800c8f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b93:	89 1c 24             	mov    %ebx,(%esp)
  801b96:	e8 36 f3 ff ff       	call   800ed1 <fd2data>
  801b9b:	83 c4 08             	add    $0x8,%esp
  801b9e:	50                   	push   %eax
  801b9f:	6a 00                	push   $0x0
  801ba1:	e8 e9 f0 ff ff       	call   800c8f <sys_page_unmap>
}
  801ba6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba9:	c9                   	leave  
  801baa:	c3                   	ret    

00801bab <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	57                   	push   %edi
  801baf:	56                   	push   %esi
  801bb0:	53                   	push   %ebx
  801bb1:	83 ec 1c             	sub    $0x1c,%esp
  801bb4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bb7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bb9:	a1 08 40 80 00       	mov    0x804008,%eax
  801bbe:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bc1:	83 ec 0c             	sub    $0xc,%esp
  801bc4:	ff 75 e0             	pushl  -0x20(%ebp)
  801bc7:	e8 3c 05 00 00       	call   802108 <pageref>
  801bcc:	89 c3                	mov    %eax,%ebx
  801bce:	89 3c 24             	mov    %edi,(%esp)
  801bd1:	e8 32 05 00 00       	call   802108 <pageref>
  801bd6:	83 c4 10             	add    $0x10,%esp
  801bd9:	39 c3                	cmp    %eax,%ebx
  801bdb:	0f 94 c1             	sete   %cl
  801bde:	0f b6 c9             	movzbl %cl,%ecx
  801be1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801be4:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801bea:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bed:	39 ce                	cmp    %ecx,%esi
  801bef:	74 1b                	je     801c0c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bf1:	39 c3                	cmp    %eax,%ebx
  801bf3:	75 c4                	jne    801bb9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bf5:	8b 42 58             	mov    0x58(%edx),%eax
  801bf8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bfb:	50                   	push   %eax
  801bfc:	56                   	push   %esi
  801bfd:	68 d7 28 80 00       	push   $0x8028d7
  801c02:	e8 fc e5 ff ff       	call   800203 <cprintf>
  801c07:	83 c4 10             	add    $0x10,%esp
  801c0a:	eb ad                	jmp    801bb9 <_pipeisclosed+0xe>
	}
}
  801c0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c12:	5b                   	pop    %ebx
  801c13:	5e                   	pop    %esi
  801c14:	5f                   	pop    %edi
  801c15:	5d                   	pop    %ebp
  801c16:	c3                   	ret    

00801c17 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	57                   	push   %edi
  801c1b:	56                   	push   %esi
  801c1c:	53                   	push   %ebx
  801c1d:	83 ec 28             	sub    $0x28,%esp
  801c20:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c23:	56                   	push   %esi
  801c24:	e8 a8 f2 ff ff       	call   800ed1 <fd2data>
  801c29:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c2b:	83 c4 10             	add    $0x10,%esp
  801c2e:	bf 00 00 00 00       	mov    $0x0,%edi
  801c33:	eb 4b                	jmp    801c80 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c35:	89 da                	mov    %ebx,%edx
  801c37:	89 f0                	mov    %esi,%eax
  801c39:	e8 6d ff ff ff       	call   801bab <_pipeisclosed>
  801c3e:	85 c0                	test   %eax,%eax
  801c40:	75 48                	jne    801c8a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c42:	e8 a4 ef ff ff       	call   800beb <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c47:	8b 43 04             	mov    0x4(%ebx),%eax
  801c4a:	8b 0b                	mov    (%ebx),%ecx
  801c4c:	8d 51 20             	lea    0x20(%ecx),%edx
  801c4f:	39 d0                	cmp    %edx,%eax
  801c51:	73 e2                	jae    801c35 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c56:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c5a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c5d:	89 c2                	mov    %eax,%edx
  801c5f:	c1 fa 1f             	sar    $0x1f,%edx
  801c62:	89 d1                	mov    %edx,%ecx
  801c64:	c1 e9 1b             	shr    $0x1b,%ecx
  801c67:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c6a:	83 e2 1f             	and    $0x1f,%edx
  801c6d:	29 ca                	sub    %ecx,%edx
  801c6f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c73:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c77:	83 c0 01             	add    $0x1,%eax
  801c7a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c7d:	83 c7 01             	add    $0x1,%edi
  801c80:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c83:	75 c2                	jne    801c47 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c85:	8b 45 10             	mov    0x10(%ebp),%eax
  801c88:	eb 05                	jmp    801c8f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c8a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c92:	5b                   	pop    %ebx
  801c93:	5e                   	pop    %esi
  801c94:	5f                   	pop    %edi
  801c95:	5d                   	pop    %ebp
  801c96:	c3                   	ret    

00801c97 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	57                   	push   %edi
  801c9b:	56                   	push   %esi
  801c9c:	53                   	push   %ebx
  801c9d:	83 ec 18             	sub    $0x18,%esp
  801ca0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ca3:	57                   	push   %edi
  801ca4:	e8 28 f2 ff ff       	call   800ed1 <fd2data>
  801ca9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cab:	83 c4 10             	add    $0x10,%esp
  801cae:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cb3:	eb 3d                	jmp    801cf2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cb5:	85 db                	test   %ebx,%ebx
  801cb7:	74 04                	je     801cbd <devpipe_read+0x26>
				return i;
  801cb9:	89 d8                	mov    %ebx,%eax
  801cbb:	eb 44                	jmp    801d01 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cbd:	89 f2                	mov    %esi,%edx
  801cbf:	89 f8                	mov    %edi,%eax
  801cc1:	e8 e5 fe ff ff       	call   801bab <_pipeisclosed>
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	75 32                	jne    801cfc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cca:	e8 1c ef ff ff       	call   800beb <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ccf:	8b 06                	mov    (%esi),%eax
  801cd1:	3b 46 04             	cmp    0x4(%esi),%eax
  801cd4:	74 df                	je     801cb5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cd6:	99                   	cltd   
  801cd7:	c1 ea 1b             	shr    $0x1b,%edx
  801cda:	01 d0                	add    %edx,%eax
  801cdc:	83 e0 1f             	and    $0x1f,%eax
  801cdf:	29 d0                	sub    %edx,%eax
  801ce1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ce9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cec:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cef:	83 c3 01             	add    $0x1,%ebx
  801cf2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cf5:	75 d8                	jne    801ccf <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cf7:	8b 45 10             	mov    0x10(%ebp),%eax
  801cfa:	eb 05                	jmp    801d01 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cfc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d04:	5b                   	pop    %ebx
  801d05:	5e                   	pop    %esi
  801d06:	5f                   	pop    %edi
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    

00801d09 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d09:	55                   	push   %ebp
  801d0a:	89 e5                	mov    %esp,%ebp
  801d0c:	56                   	push   %esi
  801d0d:	53                   	push   %ebx
  801d0e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d14:	50                   	push   %eax
  801d15:	e8 ce f1 ff ff       	call   800ee8 <fd_alloc>
  801d1a:	83 c4 10             	add    $0x10,%esp
  801d1d:	89 c2                	mov    %eax,%edx
  801d1f:	85 c0                	test   %eax,%eax
  801d21:	0f 88 2c 01 00 00    	js     801e53 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d27:	83 ec 04             	sub    $0x4,%esp
  801d2a:	68 07 04 00 00       	push   $0x407
  801d2f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d32:	6a 00                	push   $0x0
  801d34:	e8 d1 ee ff ff       	call   800c0a <sys_page_alloc>
  801d39:	83 c4 10             	add    $0x10,%esp
  801d3c:	89 c2                	mov    %eax,%edx
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	0f 88 0d 01 00 00    	js     801e53 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d46:	83 ec 0c             	sub    $0xc,%esp
  801d49:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d4c:	50                   	push   %eax
  801d4d:	e8 96 f1 ff ff       	call   800ee8 <fd_alloc>
  801d52:	89 c3                	mov    %eax,%ebx
  801d54:	83 c4 10             	add    $0x10,%esp
  801d57:	85 c0                	test   %eax,%eax
  801d59:	0f 88 e2 00 00 00    	js     801e41 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d5f:	83 ec 04             	sub    $0x4,%esp
  801d62:	68 07 04 00 00       	push   $0x407
  801d67:	ff 75 f0             	pushl  -0x10(%ebp)
  801d6a:	6a 00                	push   $0x0
  801d6c:	e8 99 ee ff ff       	call   800c0a <sys_page_alloc>
  801d71:	89 c3                	mov    %eax,%ebx
  801d73:	83 c4 10             	add    $0x10,%esp
  801d76:	85 c0                	test   %eax,%eax
  801d78:	0f 88 c3 00 00 00    	js     801e41 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d7e:	83 ec 0c             	sub    $0xc,%esp
  801d81:	ff 75 f4             	pushl  -0xc(%ebp)
  801d84:	e8 48 f1 ff ff       	call   800ed1 <fd2data>
  801d89:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d8b:	83 c4 0c             	add    $0xc,%esp
  801d8e:	68 07 04 00 00       	push   $0x407
  801d93:	50                   	push   %eax
  801d94:	6a 00                	push   $0x0
  801d96:	e8 6f ee ff ff       	call   800c0a <sys_page_alloc>
  801d9b:	89 c3                	mov    %eax,%ebx
  801d9d:	83 c4 10             	add    $0x10,%esp
  801da0:	85 c0                	test   %eax,%eax
  801da2:	0f 88 89 00 00 00    	js     801e31 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da8:	83 ec 0c             	sub    $0xc,%esp
  801dab:	ff 75 f0             	pushl  -0x10(%ebp)
  801dae:	e8 1e f1 ff ff       	call   800ed1 <fd2data>
  801db3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dba:	50                   	push   %eax
  801dbb:	6a 00                	push   $0x0
  801dbd:	56                   	push   %esi
  801dbe:	6a 00                	push   $0x0
  801dc0:	e8 88 ee ff ff       	call   800c4d <sys_page_map>
  801dc5:	89 c3                	mov    %eax,%ebx
  801dc7:	83 c4 20             	add    $0x20,%esp
  801dca:	85 c0                	test   %eax,%eax
  801dcc:	78 55                	js     801e23 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dce:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ddc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801de3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801de9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dec:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801df1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801df8:	83 ec 0c             	sub    $0xc,%esp
  801dfb:	ff 75 f4             	pushl  -0xc(%ebp)
  801dfe:	e8 be f0 ff ff       	call   800ec1 <fd2num>
  801e03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e06:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e08:	83 c4 04             	add    $0x4,%esp
  801e0b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e0e:	e8 ae f0 ff ff       	call   800ec1 <fd2num>
  801e13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e16:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e19:	83 c4 10             	add    $0x10,%esp
  801e1c:	ba 00 00 00 00       	mov    $0x0,%edx
  801e21:	eb 30                	jmp    801e53 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e23:	83 ec 08             	sub    $0x8,%esp
  801e26:	56                   	push   %esi
  801e27:	6a 00                	push   $0x0
  801e29:	e8 61 ee ff ff       	call   800c8f <sys_page_unmap>
  801e2e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e31:	83 ec 08             	sub    $0x8,%esp
  801e34:	ff 75 f0             	pushl  -0x10(%ebp)
  801e37:	6a 00                	push   $0x0
  801e39:	e8 51 ee ff ff       	call   800c8f <sys_page_unmap>
  801e3e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e41:	83 ec 08             	sub    $0x8,%esp
  801e44:	ff 75 f4             	pushl  -0xc(%ebp)
  801e47:	6a 00                	push   $0x0
  801e49:	e8 41 ee ff ff       	call   800c8f <sys_page_unmap>
  801e4e:	83 c4 10             	add    $0x10,%esp
  801e51:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e53:	89 d0                	mov    %edx,%eax
  801e55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e58:	5b                   	pop    %ebx
  801e59:	5e                   	pop    %esi
  801e5a:	5d                   	pop    %ebp
  801e5b:	c3                   	ret    

00801e5c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e5c:	55                   	push   %ebp
  801e5d:	89 e5                	mov    %esp,%ebp
  801e5f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e65:	50                   	push   %eax
  801e66:	ff 75 08             	pushl  0x8(%ebp)
  801e69:	e8 c9 f0 ff ff       	call   800f37 <fd_lookup>
  801e6e:	83 c4 10             	add    $0x10,%esp
  801e71:	85 c0                	test   %eax,%eax
  801e73:	78 18                	js     801e8d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e75:	83 ec 0c             	sub    $0xc,%esp
  801e78:	ff 75 f4             	pushl  -0xc(%ebp)
  801e7b:	e8 51 f0 ff ff       	call   800ed1 <fd2data>
	return _pipeisclosed(fd, p);
  801e80:	89 c2                	mov    %eax,%edx
  801e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e85:	e8 21 fd ff ff       	call   801bab <_pipeisclosed>
  801e8a:	83 c4 10             	add    $0x10,%esp
}
  801e8d:	c9                   	leave  
  801e8e:	c3                   	ret    

00801e8f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e8f:	55                   	push   %ebp
  801e90:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e92:	b8 00 00 00 00       	mov    $0x0,%eax
  801e97:	5d                   	pop    %ebp
  801e98:	c3                   	ret    

00801e99 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e99:	55                   	push   %ebp
  801e9a:	89 e5                	mov    %esp,%ebp
  801e9c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e9f:	68 ef 28 80 00       	push   $0x8028ef
  801ea4:	ff 75 0c             	pushl  0xc(%ebp)
  801ea7:	e8 5b e9 ff ff       	call   800807 <strcpy>
	return 0;
}
  801eac:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb1:	c9                   	leave  
  801eb2:	c3                   	ret    

00801eb3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801eb3:	55                   	push   %ebp
  801eb4:	89 e5                	mov    %esp,%ebp
  801eb6:	57                   	push   %edi
  801eb7:	56                   	push   %esi
  801eb8:	53                   	push   %ebx
  801eb9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ebf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ec4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eca:	eb 2d                	jmp    801ef9 <devcons_write+0x46>
		m = n - tot;
  801ecc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ecf:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ed1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ed4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ed9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801edc:	83 ec 04             	sub    $0x4,%esp
  801edf:	53                   	push   %ebx
  801ee0:	03 45 0c             	add    0xc(%ebp),%eax
  801ee3:	50                   	push   %eax
  801ee4:	57                   	push   %edi
  801ee5:	e8 af ea ff ff       	call   800999 <memmove>
		sys_cputs(buf, m);
  801eea:	83 c4 08             	add    $0x8,%esp
  801eed:	53                   	push   %ebx
  801eee:	57                   	push   %edi
  801eef:	e8 5a ec ff ff       	call   800b4e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ef4:	01 de                	add    %ebx,%esi
  801ef6:	83 c4 10             	add    $0x10,%esp
  801ef9:	89 f0                	mov    %esi,%eax
  801efb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801efe:	72 cc                	jb     801ecc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f03:	5b                   	pop    %ebx
  801f04:	5e                   	pop    %esi
  801f05:	5f                   	pop    %edi
  801f06:	5d                   	pop    %ebp
  801f07:	c3                   	ret    

00801f08 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	83 ec 08             	sub    $0x8,%esp
  801f0e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f13:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f17:	74 2a                	je     801f43 <devcons_read+0x3b>
  801f19:	eb 05                	jmp    801f20 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f1b:	e8 cb ec ff ff       	call   800beb <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f20:	e8 47 ec ff ff       	call   800b6c <sys_cgetc>
  801f25:	85 c0                	test   %eax,%eax
  801f27:	74 f2                	je     801f1b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f29:	85 c0                	test   %eax,%eax
  801f2b:	78 16                	js     801f43 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f2d:	83 f8 04             	cmp    $0x4,%eax
  801f30:	74 0c                	je     801f3e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f32:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f35:	88 02                	mov    %al,(%edx)
	return 1;
  801f37:	b8 01 00 00 00       	mov    $0x1,%eax
  801f3c:	eb 05                	jmp    801f43 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f3e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f43:	c9                   	leave  
  801f44:	c3                   	ret    

00801f45 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801f45:	55                   	push   %ebp
  801f46:	89 e5                	mov    %esp,%ebp
  801f48:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f51:	6a 01                	push   $0x1
  801f53:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f56:	50                   	push   %eax
  801f57:	e8 f2 eb ff ff       	call   800b4e <sys_cputs>
}
  801f5c:	83 c4 10             	add    $0x10,%esp
  801f5f:	c9                   	leave  
  801f60:	c3                   	ret    

00801f61 <getchar>:

int
getchar(void)
{
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f67:	6a 01                	push   $0x1
  801f69:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f6c:	50                   	push   %eax
  801f6d:	6a 00                	push   $0x0
  801f6f:	e8 29 f2 ff ff       	call   80119d <read>
	if (r < 0)
  801f74:	83 c4 10             	add    $0x10,%esp
  801f77:	85 c0                	test   %eax,%eax
  801f79:	78 0f                	js     801f8a <getchar+0x29>
		return r;
	if (r < 1)
  801f7b:	85 c0                	test   %eax,%eax
  801f7d:	7e 06                	jle    801f85 <getchar+0x24>
		return -E_EOF;
	return c;
  801f7f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f83:	eb 05                	jmp    801f8a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f85:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f8a:	c9                   	leave  
  801f8b:	c3                   	ret    

00801f8c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f8c:	55                   	push   %ebp
  801f8d:	89 e5                	mov    %esp,%ebp
  801f8f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f95:	50                   	push   %eax
  801f96:	ff 75 08             	pushl  0x8(%ebp)
  801f99:	e8 99 ef ff ff       	call   800f37 <fd_lookup>
  801f9e:	83 c4 10             	add    $0x10,%esp
  801fa1:	85 c0                	test   %eax,%eax
  801fa3:	78 11                	js     801fb6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801fae:	39 10                	cmp    %edx,(%eax)
  801fb0:	0f 94 c0             	sete   %al
  801fb3:	0f b6 c0             	movzbl %al,%eax
}
  801fb6:	c9                   	leave  
  801fb7:	c3                   	ret    

00801fb8 <opencons>:

int
opencons(void)
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fbe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc1:	50                   	push   %eax
  801fc2:	e8 21 ef ff ff       	call   800ee8 <fd_alloc>
  801fc7:	83 c4 10             	add    $0x10,%esp
		return r;
  801fca:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fcc:	85 c0                	test   %eax,%eax
  801fce:	78 3e                	js     80200e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fd0:	83 ec 04             	sub    $0x4,%esp
  801fd3:	68 07 04 00 00       	push   $0x407
  801fd8:	ff 75 f4             	pushl  -0xc(%ebp)
  801fdb:	6a 00                	push   $0x0
  801fdd:	e8 28 ec ff ff       	call   800c0a <sys_page_alloc>
  801fe2:	83 c4 10             	add    $0x10,%esp
		return r;
  801fe5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fe7:	85 c0                	test   %eax,%eax
  801fe9:	78 23                	js     80200e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801feb:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802000:	83 ec 0c             	sub    $0xc,%esp
  802003:	50                   	push   %eax
  802004:	e8 b8 ee ff ff       	call   800ec1 <fd2num>
  802009:	89 c2                	mov    %eax,%edx
  80200b:	83 c4 10             	add    $0x10,%esp
}
  80200e:	89 d0                	mov    %edx,%eax
  802010:	c9                   	leave  
  802011:	c3                   	ret    

00802012 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802012:	55                   	push   %ebp
  802013:	89 e5                	mov    %esp,%ebp
  802015:	56                   	push   %esi
  802016:	53                   	push   %ebx
  802017:	8b 75 08             	mov    0x8(%ebp),%esi
  80201a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80201d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  802020:	85 c0                	test   %eax,%eax
  802022:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802027:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  80202a:	83 ec 0c             	sub    $0xc,%esp
  80202d:	50                   	push   %eax
  80202e:	e8 87 ed ff ff       	call   800dba <sys_ipc_recv>
  802033:	83 c4 10             	add    $0x10,%esp
  802036:	85 c0                	test   %eax,%eax
  802038:	79 16                	jns    802050 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  80203a:	85 f6                	test   %esi,%esi
  80203c:	74 06                	je     802044 <ipc_recv+0x32>
            *from_env_store = 0;
  80203e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  802044:	85 db                	test   %ebx,%ebx
  802046:	74 2c                	je     802074 <ipc_recv+0x62>
            *perm_store = 0;
  802048:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80204e:	eb 24                	jmp    802074 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  802050:	85 f6                	test   %esi,%esi
  802052:	74 0a                	je     80205e <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  802054:	a1 08 40 80 00       	mov    0x804008,%eax
  802059:	8b 40 74             	mov    0x74(%eax),%eax
  80205c:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  80205e:	85 db                	test   %ebx,%ebx
  802060:	74 0a                	je     80206c <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  802062:	a1 08 40 80 00       	mov    0x804008,%eax
  802067:	8b 40 78             	mov    0x78(%eax),%eax
  80206a:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  80206c:	a1 08 40 80 00       	mov    0x804008,%eax
  802071:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  802074:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802077:	5b                   	pop    %ebx
  802078:	5e                   	pop    %esi
  802079:	5d                   	pop    %ebp
  80207a:	c3                   	ret    

0080207b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80207b:	55                   	push   %ebp
  80207c:	89 e5                	mov    %esp,%ebp
  80207e:	57                   	push   %edi
  80207f:	56                   	push   %esi
  802080:	53                   	push   %ebx
  802081:	83 ec 0c             	sub    $0xc,%esp
  802084:	8b 7d 08             	mov    0x8(%ebp),%edi
  802087:	8b 75 0c             	mov    0xc(%ebp),%esi
  80208a:	8b 45 10             	mov    0x10(%ebp),%eax
  80208d:	85 c0                	test   %eax,%eax
  80208f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802094:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  802097:	eb 1c                	jmp    8020b5 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  802099:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80209c:	74 12                	je     8020b0 <ipc_send+0x35>
  80209e:	50                   	push   %eax
  80209f:	68 fb 28 80 00       	push   $0x8028fb
  8020a4:	6a 3b                	push   $0x3b
  8020a6:	68 11 29 80 00       	push   $0x802911
  8020ab:	e8 7a e0 ff ff       	call   80012a <_panic>
		sys_yield();
  8020b0:	e8 36 eb ff ff       	call   800beb <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  8020b5:	ff 75 14             	pushl  0x14(%ebp)
  8020b8:	53                   	push   %ebx
  8020b9:	56                   	push   %esi
  8020ba:	57                   	push   %edi
  8020bb:	e8 d7 ec ff ff       	call   800d97 <sys_ipc_try_send>
  8020c0:	83 c4 10             	add    $0x10,%esp
  8020c3:	85 c0                	test   %eax,%eax
  8020c5:	78 d2                	js     802099 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  8020c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ca:	5b                   	pop    %ebx
  8020cb:	5e                   	pop    %esi
  8020cc:	5f                   	pop    %edi
  8020cd:	5d                   	pop    %ebp
  8020ce:	c3                   	ret    

008020cf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020cf:	55                   	push   %ebp
  8020d0:	89 e5                	mov    %esp,%ebp
  8020d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020d5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020da:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020dd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020e3:	8b 52 50             	mov    0x50(%edx),%edx
  8020e6:	39 ca                	cmp    %ecx,%edx
  8020e8:	75 0d                	jne    8020f7 <ipc_find_env+0x28>
			return envs[i].env_id;
  8020ea:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020ed:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020f2:	8b 40 48             	mov    0x48(%eax),%eax
  8020f5:	eb 0f                	jmp    802106 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020f7:	83 c0 01             	add    $0x1,%eax
  8020fa:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020ff:	75 d9                	jne    8020da <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802101:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    

00802108 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
  80210b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80210e:	89 d0                	mov    %edx,%eax
  802110:	c1 e8 16             	shr    $0x16,%eax
  802113:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80211a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80211f:	f6 c1 01             	test   $0x1,%cl
  802122:	74 1d                	je     802141 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802124:	c1 ea 0c             	shr    $0xc,%edx
  802127:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80212e:	f6 c2 01             	test   $0x1,%dl
  802131:	74 0e                	je     802141 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802133:	c1 ea 0c             	shr    $0xc,%edx
  802136:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80213d:	ef 
  80213e:	0f b7 c0             	movzwl %ax,%eax
}
  802141:	5d                   	pop    %ebp
  802142:	c3                   	ret    
  802143:	66 90                	xchg   %ax,%ax
  802145:	66 90                	xchg   %ax,%ax
  802147:	66 90                	xchg   %ax,%ax
  802149:	66 90                	xchg   %ax,%ax
  80214b:	66 90                	xchg   %ax,%ax
  80214d:	66 90                	xchg   %ax,%ax
  80214f:	90                   	nop

00802150 <__udivdi3>:
  802150:	55                   	push   %ebp
  802151:	57                   	push   %edi
  802152:	56                   	push   %esi
  802153:	53                   	push   %ebx
  802154:	83 ec 1c             	sub    $0x1c,%esp
  802157:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80215b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80215f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802163:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802167:	85 f6                	test   %esi,%esi
  802169:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80216d:	89 ca                	mov    %ecx,%edx
  80216f:	89 f8                	mov    %edi,%eax
  802171:	75 3d                	jne    8021b0 <__udivdi3+0x60>
  802173:	39 cf                	cmp    %ecx,%edi
  802175:	0f 87 c5 00 00 00    	ja     802240 <__udivdi3+0xf0>
  80217b:	85 ff                	test   %edi,%edi
  80217d:	89 fd                	mov    %edi,%ebp
  80217f:	75 0b                	jne    80218c <__udivdi3+0x3c>
  802181:	b8 01 00 00 00       	mov    $0x1,%eax
  802186:	31 d2                	xor    %edx,%edx
  802188:	f7 f7                	div    %edi
  80218a:	89 c5                	mov    %eax,%ebp
  80218c:	89 c8                	mov    %ecx,%eax
  80218e:	31 d2                	xor    %edx,%edx
  802190:	f7 f5                	div    %ebp
  802192:	89 c1                	mov    %eax,%ecx
  802194:	89 d8                	mov    %ebx,%eax
  802196:	89 cf                	mov    %ecx,%edi
  802198:	f7 f5                	div    %ebp
  80219a:	89 c3                	mov    %eax,%ebx
  80219c:	89 d8                	mov    %ebx,%eax
  80219e:	89 fa                	mov    %edi,%edx
  8021a0:	83 c4 1c             	add    $0x1c,%esp
  8021a3:	5b                   	pop    %ebx
  8021a4:	5e                   	pop    %esi
  8021a5:	5f                   	pop    %edi
  8021a6:	5d                   	pop    %ebp
  8021a7:	c3                   	ret    
  8021a8:	90                   	nop
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	39 ce                	cmp    %ecx,%esi
  8021b2:	77 74                	ja     802228 <__udivdi3+0xd8>
  8021b4:	0f bd fe             	bsr    %esi,%edi
  8021b7:	83 f7 1f             	xor    $0x1f,%edi
  8021ba:	0f 84 98 00 00 00    	je     802258 <__udivdi3+0x108>
  8021c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021c5:	89 f9                	mov    %edi,%ecx
  8021c7:	89 c5                	mov    %eax,%ebp
  8021c9:	29 fb                	sub    %edi,%ebx
  8021cb:	d3 e6                	shl    %cl,%esi
  8021cd:	89 d9                	mov    %ebx,%ecx
  8021cf:	d3 ed                	shr    %cl,%ebp
  8021d1:	89 f9                	mov    %edi,%ecx
  8021d3:	d3 e0                	shl    %cl,%eax
  8021d5:	09 ee                	or     %ebp,%esi
  8021d7:	89 d9                	mov    %ebx,%ecx
  8021d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021dd:	89 d5                	mov    %edx,%ebp
  8021df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021e3:	d3 ed                	shr    %cl,%ebp
  8021e5:	89 f9                	mov    %edi,%ecx
  8021e7:	d3 e2                	shl    %cl,%edx
  8021e9:	89 d9                	mov    %ebx,%ecx
  8021eb:	d3 e8                	shr    %cl,%eax
  8021ed:	09 c2                	or     %eax,%edx
  8021ef:	89 d0                	mov    %edx,%eax
  8021f1:	89 ea                	mov    %ebp,%edx
  8021f3:	f7 f6                	div    %esi
  8021f5:	89 d5                	mov    %edx,%ebp
  8021f7:	89 c3                	mov    %eax,%ebx
  8021f9:	f7 64 24 0c          	mull   0xc(%esp)
  8021fd:	39 d5                	cmp    %edx,%ebp
  8021ff:	72 10                	jb     802211 <__udivdi3+0xc1>
  802201:	8b 74 24 08          	mov    0x8(%esp),%esi
  802205:	89 f9                	mov    %edi,%ecx
  802207:	d3 e6                	shl    %cl,%esi
  802209:	39 c6                	cmp    %eax,%esi
  80220b:	73 07                	jae    802214 <__udivdi3+0xc4>
  80220d:	39 d5                	cmp    %edx,%ebp
  80220f:	75 03                	jne    802214 <__udivdi3+0xc4>
  802211:	83 eb 01             	sub    $0x1,%ebx
  802214:	31 ff                	xor    %edi,%edi
  802216:	89 d8                	mov    %ebx,%eax
  802218:	89 fa                	mov    %edi,%edx
  80221a:	83 c4 1c             	add    $0x1c,%esp
  80221d:	5b                   	pop    %ebx
  80221e:	5e                   	pop    %esi
  80221f:	5f                   	pop    %edi
  802220:	5d                   	pop    %ebp
  802221:	c3                   	ret    
  802222:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802228:	31 ff                	xor    %edi,%edi
  80222a:	31 db                	xor    %ebx,%ebx
  80222c:	89 d8                	mov    %ebx,%eax
  80222e:	89 fa                	mov    %edi,%edx
  802230:	83 c4 1c             	add    $0x1c,%esp
  802233:	5b                   	pop    %ebx
  802234:	5e                   	pop    %esi
  802235:	5f                   	pop    %edi
  802236:	5d                   	pop    %ebp
  802237:	c3                   	ret    
  802238:	90                   	nop
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	89 d8                	mov    %ebx,%eax
  802242:	f7 f7                	div    %edi
  802244:	31 ff                	xor    %edi,%edi
  802246:	89 c3                	mov    %eax,%ebx
  802248:	89 d8                	mov    %ebx,%eax
  80224a:	89 fa                	mov    %edi,%edx
  80224c:	83 c4 1c             	add    $0x1c,%esp
  80224f:	5b                   	pop    %ebx
  802250:	5e                   	pop    %esi
  802251:	5f                   	pop    %edi
  802252:	5d                   	pop    %ebp
  802253:	c3                   	ret    
  802254:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802258:	39 ce                	cmp    %ecx,%esi
  80225a:	72 0c                	jb     802268 <__udivdi3+0x118>
  80225c:	31 db                	xor    %ebx,%ebx
  80225e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802262:	0f 87 34 ff ff ff    	ja     80219c <__udivdi3+0x4c>
  802268:	bb 01 00 00 00       	mov    $0x1,%ebx
  80226d:	e9 2a ff ff ff       	jmp    80219c <__udivdi3+0x4c>
  802272:	66 90                	xchg   %ax,%ax
  802274:	66 90                	xchg   %ax,%ax
  802276:	66 90                	xchg   %ax,%ax
  802278:	66 90                	xchg   %ax,%ax
  80227a:	66 90                	xchg   %ax,%ax
  80227c:	66 90                	xchg   %ax,%ax
  80227e:	66 90                	xchg   %ax,%ax

00802280 <__umoddi3>:
  802280:	55                   	push   %ebp
  802281:	57                   	push   %edi
  802282:	56                   	push   %esi
  802283:	53                   	push   %ebx
  802284:	83 ec 1c             	sub    $0x1c,%esp
  802287:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80228b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80228f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802293:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802297:	85 d2                	test   %edx,%edx
  802299:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80229d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022a1:	89 f3                	mov    %esi,%ebx
  8022a3:	89 3c 24             	mov    %edi,(%esp)
  8022a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022aa:	75 1c                	jne    8022c8 <__umoddi3+0x48>
  8022ac:	39 f7                	cmp    %esi,%edi
  8022ae:	76 50                	jbe    802300 <__umoddi3+0x80>
  8022b0:	89 c8                	mov    %ecx,%eax
  8022b2:	89 f2                	mov    %esi,%edx
  8022b4:	f7 f7                	div    %edi
  8022b6:	89 d0                	mov    %edx,%eax
  8022b8:	31 d2                	xor    %edx,%edx
  8022ba:	83 c4 1c             	add    $0x1c,%esp
  8022bd:	5b                   	pop    %ebx
  8022be:	5e                   	pop    %esi
  8022bf:	5f                   	pop    %edi
  8022c0:	5d                   	pop    %ebp
  8022c1:	c3                   	ret    
  8022c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022c8:	39 f2                	cmp    %esi,%edx
  8022ca:	89 d0                	mov    %edx,%eax
  8022cc:	77 52                	ja     802320 <__umoddi3+0xa0>
  8022ce:	0f bd ea             	bsr    %edx,%ebp
  8022d1:	83 f5 1f             	xor    $0x1f,%ebp
  8022d4:	75 5a                	jne    802330 <__umoddi3+0xb0>
  8022d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022da:	0f 82 e0 00 00 00    	jb     8023c0 <__umoddi3+0x140>
  8022e0:	39 0c 24             	cmp    %ecx,(%esp)
  8022e3:	0f 86 d7 00 00 00    	jbe    8023c0 <__umoddi3+0x140>
  8022e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022f1:	83 c4 1c             	add    $0x1c,%esp
  8022f4:	5b                   	pop    %ebx
  8022f5:	5e                   	pop    %esi
  8022f6:	5f                   	pop    %edi
  8022f7:	5d                   	pop    %ebp
  8022f8:	c3                   	ret    
  8022f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802300:	85 ff                	test   %edi,%edi
  802302:	89 fd                	mov    %edi,%ebp
  802304:	75 0b                	jne    802311 <__umoddi3+0x91>
  802306:	b8 01 00 00 00       	mov    $0x1,%eax
  80230b:	31 d2                	xor    %edx,%edx
  80230d:	f7 f7                	div    %edi
  80230f:	89 c5                	mov    %eax,%ebp
  802311:	89 f0                	mov    %esi,%eax
  802313:	31 d2                	xor    %edx,%edx
  802315:	f7 f5                	div    %ebp
  802317:	89 c8                	mov    %ecx,%eax
  802319:	f7 f5                	div    %ebp
  80231b:	89 d0                	mov    %edx,%eax
  80231d:	eb 99                	jmp    8022b8 <__umoddi3+0x38>
  80231f:	90                   	nop
  802320:	89 c8                	mov    %ecx,%eax
  802322:	89 f2                	mov    %esi,%edx
  802324:	83 c4 1c             	add    $0x1c,%esp
  802327:	5b                   	pop    %ebx
  802328:	5e                   	pop    %esi
  802329:	5f                   	pop    %edi
  80232a:	5d                   	pop    %ebp
  80232b:	c3                   	ret    
  80232c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802330:	8b 34 24             	mov    (%esp),%esi
  802333:	bf 20 00 00 00       	mov    $0x20,%edi
  802338:	89 e9                	mov    %ebp,%ecx
  80233a:	29 ef                	sub    %ebp,%edi
  80233c:	d3 e0                	shl    %cl,%eax
  80233e:	89 f9                	mov    %edi,%ecx
  802340:	89 f2                	mov    %esi,%edx
  802342:	d3 ea                	shr    %cl,%edx
  802344:	89 e9                	mov    %ebp,%ecx
  802346:	09 c2                	or     %eax,%edx
  802348:	89 d8                	mov    %ebx,%eax
  80234a:	89 14 24             	mov    %edx,(%esp)
  80234d:	89 f2                	mov    %esi,%edx
  80234f:	d3 e2                	shl    %cl,%edx
  802351:	89 f9                	mov    %edi,%ecx
  802353:	89 54 24 04          	mov    %edx,0x4(%esp)
  802357:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80235b:	d3 e8                	shr    %cl,%eax
  80235d:	89 e9                	mov    %ebp,%ecx
  80235f:	89 c6                	mov    %eax,%esi
  802361:	d3 e3                	shl    %cl,%ebx
  802363:	89 f9                	mov    %edi,%ecx
  802365:	89 d0                	mov    %edx,%eax
  802367:	d3 e8                	shr    %cl,%eax
  802369:	89 e9                	mov    %ebp,%ecx
  80236b:	09 d8                	or     %ebx,%eax
  80236d:	89 d3                	mov    %edx,%ebx
  80236f:	89 f2                	mov    %esi,%edx
  802371:	f7 34 24             	divl   (%esp)
  802374:	89 d6                	mov    %edx,%esi
  802376:	d3 e3                	shl    %cl,%ebx
  802378:	f7 64 24 04          	mull   0x4(%esp)
  80237c:	39 d6                	cmp    %edx,%esi
  80237e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802382:	89 d1                	mov    %edx,%ecx
  802384:	89 c3                	mov    %eax,%ebx
  802386:	72 08                	jb     802390 <__umoddi3+0x110>
  802388:	75 11                	jne    80239b <__umoddi3+0x11b>
  80238a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80238e:	73 0b                	jae    80239b <__umoddi3+0x11b>
  802390:	2b 44 24 04          	sub    0x4(%esp),%eax
  802394:	1b 14 24             	sbb    (%esp),%edx
  802397:	89 d1                	mov    %edx,%ecx
  802399:	89 c3                	mov    %eax,%ebx
  80239b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80239f:	29 da                	sub    %ebx,%edx
  8023a1:	19 ce                	sbb    %ecx,%esi
  8023a3:	89 f9                	mov    %edi,%ecx
  8023a5:	89 f0                	mov    %esi,%eax
  8023a7:	d3 e0                	shl    %cl,%eax
  8023a9:	89 e9                	mov    %ebp,%ecx
  8023ab:	d3 ea                	shr    %cl,%edx
  8023ad:	89 e9                	mov    %ebp,%ecx
  8023af:	d3 ee                	shr    %cl,%esi
  8023b1:	09 d0                	or     %edx,%eax
  8023b3:	89 f2                	mov    %esi,%edx
  8023b5:	83 c4 1c             	add    $0x1c,%esp
  8023b8:	5b                   	pop    %ebx
  8023b9:	5e                   	pop    %esi
  8023ba:	5f                   	pop    %edi
  8023bb:	5d                   	pop    %ebp
  8023bc:	c3                   	ret    
  8023bd:	8d 76 00             	lea    0x0(%esi),%esi
  8023c0:	29 f9                	sub    %edi,%ecx
  8023c2:	19 d6                	sbb    %edx,%esi
  8023c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023cc:	e9 18 ff ff ff       	jmp    8022e9 <__umoddi3+0x69>
