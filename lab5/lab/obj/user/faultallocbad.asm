
obj/user/faultallocbad.debug：     文件格式 elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800040:	68 20 1f 80 00       	push   $0x801f20
  800045:	e8 a4 01 00 00       	call   8001ee <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 97 0b 00 00       	call   800bf5 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 40 1f 80 00       	push   $0x801f40
  80006f:	6a 0f                	push   $0xf
  800071:	68 2a 1f 80 00       	push   $0x801f2a
  800076:	e8 9a 00 00 00       	call   800115 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 6c 1f 80 00       	push   $0x801f6c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 16 07 00 00       	call   80079f <snprintf>
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
  80009c:	e8 45 0d 00 00       	call   800de6 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 89 0a 00 00       	call   800b39 <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 f2 0a 00 00       	call   800bb7 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004

    // save the name of the program so that panic() can use it
    if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
        binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

    // exit gracefully
    exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 32 0f 00 00       	call   801038 <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 66 0a 00 00       	call   800b76 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80011a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80011d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800123:	e8 8f 0a 00 00       	call   800bb7 <sys_getenvid>
  800128:	83 ec 0c             	sub    $0xc,%esp
  80012b:	ff 75 0c             	pushl  0xc(%ebp)
  80012e:	ff 75 08             	pushl  0x8(%ebp)
  800131:	56                   	push   %esi
  800132:	50                   	push   %eax
  800133:	68 98 1f 80 00       	push   $0x801f98
  800138:	e8 b1 00 00 00       	call   8001ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013d:	83 c4 18             	add    $0x18,%esp
  800140:	53                   	push   %ebx
  800141:	ff 75 10             	pushl  0x10(%ebp)
  800144:	e8 54 00 00 00       	call   80019d <vcprintf>
	cprintf("\n");
  800149:	c7 04 24 eb 23 80 00 	movl   $0x8023eb,(%esp)
  800150:	e8 99 00 00 00       	call   8001ee <cprintf>
  800155:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800158:	cc                   	int3   
  800159:	eb fd                	jmp    800158 <_panic+0x43>

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800165:	8b 13                	mov    (%ebx),%edx
  800167:	8d 42 01             	lea    0x1(%edx),%eax
  80016a:	89 03                	mov    %eax,(%ebx)
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800173:	3d ff 00 00 00       	cmp    $0xff,%eax
  800178:	75 1a                	jne    800194 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017a:	83 ec 08             	sub    $0x8,%esp
  80017d:	68 ff 00 00 00       	push   $0xff
  800182:	8d 43 08             	lea    0x8(%ebx),%eax
  800185:	50                   	push   %eax
  800186:	e8 ae 09 00 00       	call   800b39 <sys_cputs>
		b->idx = 0;
  80018b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800191:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800194:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800198:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ad:	00 00 00 
	b.cnt = 0;
  8001b0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ba:	ff 75 0c             	pushl  0xc(%ebp)
  8001bd:	ff 75 08             	pushl  0x8(%ebp)
  8001c0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	68 5b 01 80 00       	push   $0x80015b
  8001cc:	e8 1a 01 00 00       	call   8002eb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d1:	83 c4 08             	add    $0x8,%esp
  8001d4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e0:	50                   	push   %eax
  8001e1:	e8 53 09 00 00       	call   800b39 <sys_cputs>

	return b.cnt;
}
  8001e6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    

008001ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f7:	50                   	push   %eax
  8001f8:	ff 75 08             	pushl  0x8(%ebp)
  8001fb:	e8 9d ff ff ff       	call   80019d <vcprintf>
	va_end(ap);

	return cnt;
}
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	57                   	push   %edi
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	83 ec 1c             	sub    $0x1c,%esp
  80020b:	89 c7                	mov    %eax,%edi
  80020d:	89 d6                	mov    %edx,%esi
  80020f:	8b 45 08             	mov    0x8(%ebp),%eax
  800212:	8b 55 0c             	mov    0xc(%ebp),%edx
  800215:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800218:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80021e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800223:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800226:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800229:	39 d3                	cmp    %edx,%ebx
  80022b:	72 05                	jb     800232 <printnum+0x30>
  80022d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800230:	77 45                	ja     800277 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800232:	83 ec 0c             	sub    $0xc,%esp
  800235:	ff 75 18             	pushl  0x18(%ebp)
  800238:	8b 45 14             	mov    0x14(%ebp),%eax
  80023b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80023e:	53                   	push   %ebx
  80023f:	ff 75 10             	pushl  0x10(%ebp)
  800242:	83 ec 08             	sub    $0x8,%esp
  800245:	ff 75 e4             	pushl  -0x1c(%ebp)
  800248:	ff 75 e0             	pushl  -0x20(%ebp)
  80024b:	ff 75 dc             	pushl  -0x24(%ebp)
  80024e:	ff 75 d8             	pushl  -0x28(%ebp)
  800251:	e8 3a 1a 00 00       	call   801c90 <__udivdi3>
  800256:	83 c4 18             	add    $0x18,%esp
  800259:	52                   	push   %edx
  80025a:	50                   	push   %eax
  80025b:	89 f2                	mov    %esi,%edx
  80025d:	89 f8                	mov    %edi,%eax
  80025f:	e8 9e ff ff ff       	call   800202 <printnum>
  800264:	83 c4 20             	add    $0x20,%esp
  800267:	eb 18                	jmp    800281 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	56                   	push   %esi
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	ff d7                	call   *%edi
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 03                	jmp    80027a <printnum+0x78>
  800277:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027a:	83 eb 01             	sub    $0x1,%ebx
  80027d:	85 db                	test   %ebx,%ebx
  80027f:	7f e8                	jg     800269 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	56                   	push   %esi
  800285:	83 ec 04             	sub    $0x4,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 27 1b 00 00       	call   801dc0 <__umoddi3>
  800299:	83 c4 14             	add    $0x14,%esp
  80029c:	0f be 80 bb 1f 80 00 	movsbl 0x801fbb(%eax),%eax
  8002a3:	50                   	push   %eax
  8002a4:	ff d7                	call   *%edi
}
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bb:	8b 10                	mov    (%eax),%edx
  8002bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c0:	73 0a                	jae    8002cc <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ca:	88 02                	mov    %al,(%edx)
}
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d7:	50                   	push   %eax
  8002d8:	ff 75 10             	pushl  0x10(%ebp)
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	e8 05 00 00 00       	call   8002eb <vprintfmt>
	va_end(ap);
}
  8002e6:	83 c4 10             	add    $0x10,%esp
  8002e9:	c9                   	leave  
  8002ea:	c3                   	ret    

008002eb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
  8002f1:	83 ec 2c             	sub    $0x2c,%esp
  8002f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fd:	eb 12                	jmp    800311 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ff:	85 c0                	test   %eax,%eax
  800301:	0f 84 42 04 00 00    	je     800749 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	53                   	push   %ebx
  80030b:	50                   	push   %eax
  80030c:	ff d6                	call   *%esi
  80030e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800311:	83 c7 01             	add    $0x1,%edi
  800314:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800318:	83 f8 25             	cmp    $0x25,%eax
  80031b:	75 e2                	jne    8002ff <vprintfmt+0x14>
  80031d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800321:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800328:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800336:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033b:	eb 07                	jmp    800344 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800340:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8d 47 01             	lea    0x1(%edi),%eax
  800347:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034a:	0f b6 07             	movzbl (%edi),%eax
  80034d:	0f b6 d0             	movzbl %al,%edx
  800350:	83 e8 23             	sub    $0x23,%eax
  800353:	3c 55                	cmp    $0x55,%al
  800355:	0f 87 d3 03 00 00    	ja     80072e <vprintfmt+0x443>
  80035b:	0f b6 c0             	movzbl %al,%eax
  80035e:	ff 24 85 00 21 80 00 	jmp    *0x802100(,%eax,4)
  800365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800368:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036c:	eb d6                	jmp    800344 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800371:	b8 00 00 00 00       	mov    $0x0,%eax
  800376:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800379:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800380:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800383:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800386:	83 f9 09             	cmp    $0x9,%ecx
  800389:	77 3f                	ja     8003ca <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038e:	eb e9                	jmp    800379 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8b 00                	mov    (%eax),%eax
  800395:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800398:	8b 45 14             	mov    0x14(%ebp),%eax
  80039b:	8d 40 04             	lea    0x4(%eax),%eax
  80039e:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a4:	eb 2a                	jmp    8003d0 <vprintfmt+0xe5>
  8003a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a9:	85 c0                	test   %eax,%eax
  8003ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b0:	0f 49 d0             	cmovns %eax,%edx
  8003b3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b9:	eb 89                	jmp    800344 <vprintfmt+0x59>
  8003bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003be:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c5:	e9 7a ff ff ff       	jmp    800344 <vprintfmt+0x59>
  8003ca:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003cd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003d0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d4:	0f 89 6a ff ff ff    	jns    800344 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003da:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e7:	e9 58 ff ff ff       	jmp    800344 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ec:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f2:	e9 4d ff ff ff       	jmp    800344 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fa:	8d 78 04             	lea    0x4(%eax),%edi
  8003fd:	83 ec 08             	sub    $0x8,%esp
  800400:	53                   	push   %ebx
  800401:	ff 30                	pushl  (%eax)
  800403:	ff d6                	call   *%esi
			break;
  800405:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800408:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80040e:	e9 fe fe ff ff       	jmp    800311 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800413:	8b 45 14             	mov    0x14(%ebp),%eax
  800416:	8d 78 04             	lea    0x4(%eax),%edi
  800419:	8b 00                	mov    (%eax),%eax
  80041b:	99                   	cltd   
  80041c:	31 d0                	xor    %edx,%eax
  80041e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800420:	83 f8 0f             	cmp    $0xf,%eax
  800423:	7f 0b                	jg     800430 <vprintfmt+0x145>
  800425:	8b 14 85 60 22 80 00 	mov    0x802260(,%eax,4),%edx
  80042c:	85 d2                	test   %edx,%edx
  80042e:	75 1b                	jne    80044b <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800430:	50                   	push   %eax
  800431:	68 d3 1f 80 00       	push   $0x801fd3
  800436:	53                   	push   %ebx
  800437:	56                   	push   %esi
  800438:	e8 91 fe ff ff       	call   8002ce <printfmt>
  80043d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800440:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800443:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800446:	e9 c6 fe ff ff       	jmp    800311 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80044b:	52                   	push   %edx
  80044c:	68 b9 23 80 00       	push   $0x8023b9
  800451:	53                   	push   %ebx
  800452:	56                   	push   %esi
  800453:	e8 76 fe ff ff       	call   8002ce <printfmt>
  800458:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800461:	e9 ab fe ff ff       	jmp    800311 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	83 c0 04             	add    $0x4,%eax
  80046c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80046f:	8b 45 14             	mov    0x14(%ebp),%eax
  800472:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800474:	85 ff                	test   %edi,%edi
  800476:	b8 cc 1f 80 00       	mov    $0x801fcc,%eax
  80047b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80047e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800482:	0f 8e 94 00 00 00    	jle    80051c <vprintfmt+0x231>
  800488:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80048c:	0f 84 98 00 00 00    	je     80052a <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800492:	83 ec 08             	sub    $0x8,%esp
  800495:	ff 75 d0             	pushl  -0x30(%ebp)
  800498:	57                   	push   %edi
  800499:	e8 33 03 00 00       	call   8007d1 <strnlen>
  80049e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a1:	29 c1                	sub    %eax,%ecx
  8004a3:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004a6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004a9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004b3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b5:	eb 0f                	jmp    8004c6 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004b7:	83 ec 08             	sub    $0x8,%esp
  8004ba:	53                   	push   %ebx
  8004bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8004be:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c0:	83 ef 01             	sub    $0x1,%edi
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	85 ff                	test   %edi,%edi
  8004c8:	7f ed                	jg     8004b7 <vprintfmt+0x1cc>
  8004ca:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004cd:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004d0:	85 c9                	test   %ecx,%ecx
  8004d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d7:	0f 49 c1             	cmovns %ecx,%eax
  8004da:	29 c1                	sub    %eax,%ecx
  8004dc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004df:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e5:	89 cb                	mov    %ecx,%ebx
  8004e7:	eb 4d                	jmp    800536 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ed:	74 1b                	je     80050a <vprintfmt+0x21f>
  8004ef:	0f be c0             	movsbl %al,%eax
  8004f2:	83 e8 20             	sub    $0x20,%eax
  8004f5:	83 f8 5e             	cmp    $0x5e,%eax
  8004f8:	76 10                	jbe    80050a <vprintfmt+0x21f>
					putch('?', putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	ff 75 0c             	pushl  0xc(%ebp)
  800500:	6a 3f                	push   $0x3f
  800502:	ff 55 08             	call   *0x8(%ebp)
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	eb 0d                	jmp    800517 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	ff 75 0c             	pushl  0xc(%ebp)
  800510:	52                   	push   %edx
  800511:	ff 55 08             	call   *0x8(%ebp)
  800514:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800517:	83 eb 01             	sub    $0x1,%ebx
  80051a:	eb 1a                	jmp    800536 <vprintfmt+0x24b>
  80051c:	89 75 08             	mov    %esi,0x8(%ebp)
  80051f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800522:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800525:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800528:	eb 0c                	jmp    800536 <vprintfmt+0x24b>
  80052a:	89 75 08             	mov    %esi,0x8(%ebp)
  80052d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800530:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800533:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800536:	83 c7 01             	add    $0x1,%edi
  800539:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80053d:	0f be d0             	movsbl %al,%edx
  800540:	85 d2                	test   %edx,%edx
  800542:	74 23                	je     800567 <vprintfmt+0x27c>
  800544:	85 f6                	test   %esi,%esi
  800546:	78 a1                	js     8004e9 <vprintfmt+0x1fe>
  800548:	83 ee 01             	sub    $0x1,%esi
  80054b:	79 9c                	jns    8004e9 <vprintfmt+0x1fe>
  80054d:	89 df                	mov    %ebx,%edi
  80054f:	8b 75 08             	mov    0x8(%ebp),%esi
  800552:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800555:	eb 18                	jmp    80056f <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	53                   	push   %ebx
  80055b:	6a 20                	push   $0x20
  80055d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055f:	83 ef 01             	sub    $0x1,%edi
  800562:	83 c4 10             	add    $0x10,%esp
  800565:	eb 08                	jmp    80056f <vprintfmt+0x284>
  800567:	89 df                	mov    %ebx,%edi
  800569:	8b 75 08             	mov    0x8(%ebp),%esi
  80056c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056f:	85 ff                	test   %edi,%edi
  800571:	7f e4                	jg     800557 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800573:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800576:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800579:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80057c:	e9 90 fd ff ff       	jmp    800311 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800581:	83 f9 01             	cmp    $0x1,%ecx
  800584:	7e 19                	jle    80059f <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8b 50 04             	mov    0x4(%eax),%edx
  80058c:	8b 00                	mov    (%eax),%eax
  80058e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800591:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 40 08             	lea    0x8(%eax),%eax
  80059a:	89 45 14             	mov    %eax,0x14(%ebp)
  80059d:	eb 38                	jmp    8005d7 <vprintfmt+0x2ec>
	else if (lflag)
  80059f:	85 c9                	test   %ecx,%ecx
  8005a1:	74 1b                	je     8005be <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8b 00                	mov    (%eax),%eax
  8005a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ab:	89 c1                	mov    %eax,%ecx
  8005ad:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b6:	8d 40 04             	lea    0x4(%eax),%eax
  8005b9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bc:	eb 19                	jmp    8005d7 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8b 00                	mov    (%eax),%eax
  8005c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c6:	89 c1                	mov    %eax,%ecx
  8005c8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005cb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8d 40 04             	lea    0x4(%eax),%eax
  8005d4:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005d7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005da:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005dd:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005e6:	0f 89 0e 01 00 00    	jns    8006fa <vprintfmt+0x40f>
				putch('-', putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	53                   	push   %ebx
  8005f0:	6a 2d                	push   $0x2d
  8005f2:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005fa:	f7 da                	neg    %edx
  8005fc:	83 d1 00             	adc    $0x0,%ecx
  8005ff:	f7 d9                	neg    %ecx
  800601:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800604:	b8 0a 00 00 00       	mov    $0xa,%eax
  800609:	e9 ec 00 00 00       	jmp    8006fa <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80060e:	83 f9 01             	cmp    $0x1,%ecx
  800611:	7e 18                	jle    80062b <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8b 10                	mov    (%eax),%edx
  800618:	8b 48 04             	mov    0x4(%eax),%ecx
  80061b:	8d 40 08             	lea    0x8(%eax),%eax
  80061e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800621:	b8 0a 00 00 00       	mov    $0xa,%eax
  800626:	e9 cf 00 00 00       	jmp    8006fa <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80062b:	85 c9                	test   %ecx,%ecx
  80062d:	74 1a                	je     800649 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8b 10                	mov    (%eax),%edx
  800634:	b9 00 00 00 00       	mov    $0x0,%ecx
  800639:	8d 40 04             	lea    0x4(%eax),%eax
  80063c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80063f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800644:	e9 b1 00 00 00       	jmp    8006fa <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8b 10                	mov    (%eax),%edx
  80064e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800653:	8d 40 04             	lea    0x4(%eax),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800659:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065e:	e9 97 00 00 00       	jmp    8006fa <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	53                   	push   %ebx
  800667:	6a 58                	push   $0x58
  800669:	ff d6                	call   *%esi
			putch('X', putdat);
  80066b:	83 c4 08             	add    $0x8,%esp
  80066e:	53                   	push   %ebx
  80066f:	6a 58                	push   $0x58
  800671:	ff d6                	call   *%esi
			putch('X', putdat);
  800673:	83 c4 08             	add    $0x8,%esp
  800676:	53                   	push   %ebx
  800677:	6a 58                	push   $0x58
  800679:	ff d6                	call   *%esi
			break;
  80067b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800681:	e9 8b fc ff ff       	jmp    800311 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	6a 30                	push   $0x30
  80068c:	ff d6                	call   *%esi
			putch('x', putdat);
  80068e:	83 c4 08             	add    $0x8,%esp
  800691:	53                   	push   %ebx
  800692:	6a 78                	push   $0x78
  800694:	ff d6                	call   *%esi
			num = (unsigned long long)
  800696:	8b 45 14             	mov    0x14(%ebp),%eax
  800699:	8b 10                	mov    (%eax),%edx
  80069b:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a0:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a3:	8d 40 04             	lea    0x4(%eax),%eax
  8006a6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a9:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006ae:	eb 4a                	jmp    8006fa <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b0:	83 f9 01             	cmp    $0x1,%ecx
  8006b3:	7e 15                	jle    8006ca <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8b 10                	mov    (%eax),%edx
  8006ba:	8b 48 04             	mov    0x4(%eax),%ecx
  8006bd:	8d 40 08             	lea    0x8(%eax),%eax
  8006c0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006c3:	b8 10 00 00 00       	mov    $0x10,%eax
  8006c8:	eb 30                	jmp    8006fa <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006ca:	85 c9                	test   %ecx,%ecx
  8006cc:	74 17                	je     8006e5 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8b 10                	mov    (%eax),%edx
  8006d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d8:	8d 40 04             	lea    0x4(%eax),%eax
  8006db:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006de:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e3:	eb 15                	jmp    8006fa <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e8:	8b 10                	mov    (%eax),%edx
  8006ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ef:	8d 40 04             	lea    0x4(%eax),%eax
  8006f2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006f5:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006fa:	83 ec 0c             	sub    $0xc,%esp
  8006fd:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800701:	57                   	push   %edi
  800702:	ff 75 e0             	pushl  -0x20(%ebp)
  800705:	50                   	push   %eax
  800706:	51                   	push   %ecx
  800707:	52                   	push   %edx
  800708:	89 da                	mov    %ebx,%edx
  80070a:	89 f0                	mov    %esi,%eax
  80070c:	e8 f1 fa ff ff       	call   800202 <printnum>
			break;
  800711:	83 c4 20             	add    $0x20,%esp
  800714:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800717:	e9 f5 fb ff ff       	jmp    800311 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	53                   	push   %ebx
  800720:	52                   	push   %edx
  800721:	ff d6                	call   *%esi
			break;
  800723:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800729:	e9 e3 fb ff ff       	jmp    800311 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	53                   	push   %ebx
  800732:	6a 25                	push   $0x25
  800734:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800736:	83 c4 10             	add    $0x10,%esp
  800739:	eb 03                	jmp    80073e <vprintfmt+0x453>
  80073b:	83 ef 01             	sub    $0x1,%edi
  80073e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800742:	75 f7                	jne    80073b <vprintfmt+0x450>
  800744:	e9 c8 fb ff ff       	jmp    800311 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800749:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074c:	5b                   	pop    %ebx
  80074d:	5e                   	pop    %esi
  80074e:	5f                   	pop    %edi
  80074f:	5d                   	pop    %ebp
  800750:	c3                   	ret    

00800751 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	83 ec 18             	sub    $0x18,%esp
  800757:	8b 45 08             	mov    0x8(%ebp),%eax
  80075a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800760:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800764:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800767:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076e:	85 c0                	test   %eax,%eax
  800770:	74 26                	je     800798 <vsnprintf+0x47>
  800772:	85 d2                	test   %edx,%edx
  800774:	7e 22                	jle    800798 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800776:	ff 75 14             	pushl  0x14(%ebp)
  800779:	ff 75 10             	pushl  0x10(%ebp)
  80077c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077f:	50                   	push   %eax
  800780:	68 b1 02 80 00       	push   $0x8002b1
  800785:	e8 61 fb ff ff       	call   8002eb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800790:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800793:	83 c4 10             	add    $0x10,%esp
  800796:	eb 05                	jmp    80079d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800798:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079d:	c9                   	leave  
  80079e:	c3                   	ret    

0080079f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a8:	50                   	push   %eax
  8007a9:	ff 75 10             	pushl  0x10(%ebp)
  8007ac:	ff 75 0c             	pushl  0xc(%ebp)
  8007af:	ff 75 08             	pushl  0x8(%ebp)
  8007b2:	e8 9a ff ff ff       	call   800751 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    

008007b9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c4:	eb 03                	jmp    8007c9 <strlen+0x10>
		n++;
  8007c6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007cd:	75 f7                	jne    8007c6 <strlen+0xd>
		n++;
	return n;
}
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007da:	ba 00 00 00 00       	mov    $0x0,%edx
  8007df:	eb 03                	jmp    8007e4 <strnlen+0x13>
		n++;
  8007e1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e4:	39 c2                	cmp    %eax,%edx
  8007e6:	74 08                	je     8007f0 <strnlen+0x1f>
  8007e8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ec:	75 f3                	jne    8007e1 <strnlen+0x10>
  8007ee:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fc:	89 c2                	mov    %eax,%edx
  8007fe:	83 c2 01             	add    $0x1,%edx
  800801:	83 c1 01             	add    $0x1,%ecx
  800804:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800808:	88 5a ff             	mov    %bl,-0x1(%edx)
  80080b:	84 db                	test   %bl,%bl
  80080d:	75 ef                	jne    8007fe <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80080f:	5b                   	pop    %ebx
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	53                   	push   %ebx
  800816:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800819:	53                   	push   %ebx
  80081a:	e8 9a ff ff ff       	call   8007b9 <strlen>
  80081f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800822:	ff 75 0c             	pushl  0xc(%ebp)
  800825:	01 d8                	add    %ebx,%eax
  800827:	50                   	push   %eax
  800828:	e8 c5 ff ff ff       	call   8007f2 <strcpy>
	return dst;
}
  80082d:	89 d8                	mov    %ebx,%eax
  80082f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800832:	c9                   	leave  
  800833:	c3                   	ret    

00800834 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	56                   	push   %esi
  800838:	53                   	push   %ebx
  800839:	8b 75 08             	mov    0x8(%ebp),%esi
  80083c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083f:	89 f3                	mov    %esi,%ebx
  800841:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800844:	89 f2                	mov    %esi,%edx
  800846:	eb 0f                	jmp    800857 <strncpy+0x23>
		*dst++ = *src;
  800848:	83 c2 01             	add    $0x1,%edx
  80084b:	0f b6 01             	movzbl (%ecx),%eax
  80084e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800851:	80 39 01             	cmpb   $0x1,(%ecx)
  800854:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800857:	39 da                	cmp    %ebx,%edx
  800859:	75 ed                	jne    800848 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085b:	89 f0                	mov    %esi,%eax
  80085d:	5b                   	pop    %ebx
  80085e:	5e                   	pop    %esi
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	56                   	push   %esi
  800865:	53                   	push   %ebx
  800866:	8b 75 08             	mov    0x8(%ebp),%esi
  800869:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086c:	8b 55 10             	mov    0x10(%ebp),%edx
  80086f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800871:	85 d2                	test   %edx,%edx
  800873:	74 21                	je     800896 <strlcpy+0x35>
  800875:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800879:	89 f2                	mov    %esi,%edx
  80087b:	eb 09                	jmp    800886 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087d:	83 c2 01             	add    $0x1,%edx
  800880:	83 c1 01             	add    $0x1,%ecx
  800883:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800886:	39 c2                	cmp    %eax,%edx
  800888:	74 09                	je     800893 <strlcpy+0x32>
  80088a:	0f b6 19             	movzbl (%ecx),%ebx
  80088d:	84 db                	test   %bl,%bl
  80088f:	75 ec                	jne    80087d <strlcpy+0x1c>
  800891:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800893:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800896:	29 f0                	sub    %esi,%eax
}
  800898:	5b                   	pop    %ebx
  800899:	5e                   	pop    %esi
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a5:	eb 06                	jmp    8008ad <strcmp+0x11>
		p++, q++;
  8008a7:	83 c1 01             	add    $0x1,%ecx
  8008aa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ad:	0f b6 01             	movzbl (%ecx),%eax
  8008b0:	84 c0                	test   %al,%al
  8008b2:	74 04                	je     8008b8 <strcmp+0x1c>
  8008b4:	3a 02                	cmp    (%edx),%al
  8008b6:	74 ef                	je     8008a7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b8:	0f b6 c0             	movzbl %al,%eax
  8008bb:	0f b6 12             	movzbl (%edx),%edx
  8008be:	29 d0                	sub    %edx,%eax
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	53                   	push   %ebx
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cc:	89 c3                	mov    %eax,%ebx
  8008ce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d1:	eb 06                	jmp    8008d9 <strncmp+0x17>
		n--, p++, q++;
  8008d3:	83 c0 01             	add    $0x1,%eax
  8008d6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d9:	39 d8                	cmp    %ebx,%eax
  8008db:	74 15                	je     8008f2 <strncmp+0x30>
  8008dd:	0f b6 08             	movzbl (%eax),%ecx
  8008e0:	84 c9                	test   %cl,%cl
  8008e2:	74 04                	je     8008e8 <strncmp+0x26>
  8008e4:	3a 0a                	cmp    (%edx),%cl
  8008e6:	74 eb                	je     8008d3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e8:	0f b6 00             	movzbl (%eax),%eax
  8008eb:	0f b6 12             	movzbl (%edx),%edx
  8008ee:	29 d0                	sub    %edx,%eax
  8008f0:	eb 05                	jmp    8008f7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f7:	5b                   	pop    %ebx
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800904:	eb 07                	jmp    80090d <strchr+0x13>
		if (*s == c)
  800906:	38 ca                	cmp    %cl,%dl
  800908:	74 0f                	je     800919 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090a:	83 c0 01             	add    $0x1,%eax
  80090d:	0f b6 10             	movzbl (%eax),%edx
  800910:	84 d2                	test   %dl,%dl
  800912:	75 f2                	jne    800906 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800925:	eb 03                	jmp    80092a <strfind+0xf>
  800927:	83 c0 01             	add    $0x1,%eax
  80092a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092d:	38 ca                	cmp    %cl,%dl
  80092f:	74 04                	je     800935 <strfind+0x1a>
  800931:	84 d2                	test   %dl,%dl
  800933:	75 f2                	jne    800927 <strfind+0xc>
			break;
	return (char *) s;
}
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	57                   	push   %edi
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800940:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800943:	85 c9                	test   %ecx,%ecx
  800945:	74 36                	je     80097d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800947:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094d:	75 28                	jne    800977 <memset+0x40>
  80094f:	f6 c1 03             	test   $0x3,%cl
  800952:	75 23                	jne    800977 <memset+0x40>
		c &= 0xFF;
  800954:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800958:	89 d3                	mov    %edx,%ebx
  80095a:	c1 e3 08             	shl    $0x8,%ebx
  80095d:	89 d6                	mov    %edx,%esi
  80095f:	c1 e6 18             	shl    $0x18,%esi
  800962:	89 d0                	mov    %edx,%eax
  800964:	c1 e0 10             	shl    $0x10,%eax
  800967:	09 f0                	or     %esi,%eax
  800969:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80096b:	89 d8                	mov    %ebx,%eax
  80096d:	09 d0                	or     %edx,%eax
  80096f:	c1 e9 02             	shr    $0x2,%ecx
  800972:	fc                   	cld    
  800973:	f3 ab                	rep stos %eax,%es:(%edi)
  800975:	eb 06                	jmp    80097d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800977:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097a:	fc                   	cld    
  80097b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097d:	89 f8                	mov    %edi,%eax
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	5f                   	pop    %edi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	57                   	push   %edi
  800988:	56                   	push   %esi
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800992:	39 c6                	cmp    %eax,%esi
  800994:	73 35                	jae    8009cb <memmove+0x47>
  800996:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800999:	39 d0                	cmp    %edx,%eax
  80099b:	73 2e                	jae    8009cb <memmove+0x47>
		s += n;
		d += n;
  80099d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a0:	89 d6                	mov    %edx,%esi
  8009a2:	09 fe                	or     %edi,%esi
  8009a4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009aa:	75 13                	jne    8009bf <memmove+0x3b>
  8009ac:	f6 c1 03             	test   $0x3,%cl
  8009af:	75 0e                	jne    8009bf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009b1:	83 ef 04             	sub    $0x4,%edi
  8009b4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b7:	c1 e9 02             	shr    $0x2,%ecx
  8009ba:	fd                   	std    
  8009bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bd:	eb 09                	jmp    8009c8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009bf:	83 ef 01             	sub    $0x1,%edi
  8009c2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009c5:	fd                   	std    
  8009c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c8:	fc                   	cld    
  8009c9:	eb 1d                	jmp    8009e8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cb:	89 f2                	mov    %esi,%edx
  8009cd:	09 c2                	or     %eax,%edx
  8009cf:	f6 c2 03             	test   $0x3,%dl
  8009d2:	75 0f                	jne    8009e3 <memmove+0x5f>
  8009d4:	f6 c1 03             	test   $0x3,%cl
  8009d7:	75 0a                	jne    8009e3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009d9:	c1 e9 02             	shr    $0x2,%ecx
  8009dc:	89 c7                	mov    %eax,%edi
  8009de:	fc                   	cld    
  8009df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e1:	eb 05                	jmp    8009e8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e3:	89 c7                	mov    %eax,%edi
  8009e5:	fc                   	cld    
  8009e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e8:	5e                   	pop    %esi
  8009e9:	5f                   	pop    %edi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ef:	ff 75 10             	pushl  0x10(%ebp)
  8009f2:	ff 75 0c             	pushl  0xc(%ebp)
  8009f5:	ff 75 08             	pushl  0x8(%ebp)
  8009f8:	e8 87 ff ff ff       	call   800984 <memmove>
}
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    

008009ff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
  800a07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0a:	89 c6                	mov    %eax,%esi
  800a0c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0f:	eb 1a                	jmp    800a2b <memcmp+0x2c>
		if (*s1 != *s2)
  800a11:	0f b6 08             	movzbl (%eax),%ecx
  800a14:	0f b6 1a             	movzbl (%edx),%ebx
  800a17:	38 d9                	cmp    %bl,%cl
  800a19:	74 0a                	je     800a25 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a1b:	0f b6 c1             	movzbl %cl,%eax
  800a1e:	0f b6 db             	movzbl %bl,%ebx
  800a21:	29 d8                	sub    %ebx,%eax
  800a23:	eb 0f                	jmp    800a34 <memcmp+0x35>
		s1++, s2++;
  800a25:	83 c0 01             	add    $0x1,%eax
  800a28:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2b:	39 f0                	cmp    %esi,%eax
  800a2d:	75 e2                	jne    800a11 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a34:	5b                   	pop    %ebx
  800a35:	5e                   	pop    %esi
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    

00800a38 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	53                   	push   %ebx
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a3f:	89 c1                	mov    %eax,%ecx
  800a41:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a44:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a48:	eb 0a                	jmp    800a54 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4a:	0f b6 10             	movzbl (%eax),%edx
  800a4d:	39 da                	cmp    %ebx,%edx
  800a4f:	74 07                	je     800a58 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a51:	83 c0 01             	add    $0x1,%eax
  800a54:	39 c8                	cmp    %ecx,%eax
  800a56:	72 f2                	jb     800a4a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a58:	5b                   	pop    %ebx
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	57                   	push   %edi
  800a5f:	56                   	push   %esi
  800a60:	53                   	push   %ebx
  800a61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a64:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a67:	eb 03                	jmp    800a6c <strtol+0x11>
		s++;
  800a69:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6c:	0f b6 01             	movzbl (%ecx),%eax
  800a6f:	3c 20                	cmp    $0x20,%al
  800a71:	74 f6                	je     800a69 <strtol+0xe>
  800a73:	3c 09                	cmp    $0x9,%al
  800a75:	74 f2                	je     800a69 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a77:	3c 2b                	cmp    $0x2b,%al
  800a79:	75 0a                	jne    800a85 <strtol+0x2a>
		s++;
  800a7b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a83:	eb 11                	jmp    800a96 <strtol+0x3b>
  800a85:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8a:	3c 2d                	cmp    $0x2d,%al
  800a8c:	75 08                	jne    800a96 <strtol+0x3b>
		s++, neg = 1;
  800a8e:	83 c1 01             	add    $0x1,%ecx
  800a91:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a96:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9c:	75 15                	jne    800ab3 <strtol+0x58>
  800a9e:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa1:	75 10                	jne    800ab3 <strtol+0x58>
  800aa3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa7:	75 7c                	jne    800b25 <strtol+0xca>
		s += 2, base = 16;
  800aa9:	83 c1 02             	add    $0x2,%ecx
  800aac:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab1:	eb 16                	jmp    800ac9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ab3:	85 db                	test   %ebx,%ebx
  800ab5:	75 12                	jne    800ac9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abc:	80 39 30             	cmpb   $0x30,(%ecx)
  800abf:	75 08                	jne    800ac9 <strtol+0x6e>
		s++, base = 8;
  800ac1:	83 c1 01             	add    $0x1,%ecx
  800ac4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ac9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ace:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad1:	0f b6 11             	movzbl (%ecx),%edx
  800ad4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad7:	89 f3                	mov    %esi,%ebx
  800ad9:	80 fb 09             	cmp    $0x9,%bl
  800adc:	77 08                	ja     800ae6 <strtol+0x8b>
			dig = *s - '0';
  800ade:	0f be d2             	movsbl %dl,%edx
  800ae1:	83 ea 30             	sub    $0x30,%edx
  800ae4:	eb 22                	jmp    800b08 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ae6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae9:	89 f3                	mov    %esi,%ebx
  800aeb:	80 fb 19             	cmp    $0x19,%bl
  800aee:	77 08                	ja     800af8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800af0:	0f be d2             	movsbl %dl,%edx
  800af3:	83 ea 57             	sub    $0x57,%edx
  800af6:	eb 10                	jmp    800b08 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800af8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800afb:	89 f3                	mov    %esi,%ebx
  800afd:	80 fb 19             	cmp    $0x19,%bl
  800b00:	77 16                	ja     800b18 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b02:	0f be d2             	movsbl %dl,%edx
  800b05:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b08:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b0b:	7d 0b                	jge    800b18 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b0d:	83 c1 01             	add    $0x1,%ecx
  800b10:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b14:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b16:	eb b9                	jmp    800ad1 <strtol+0x76>

	if (endptr)
  800b18:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1c:	74 0d                	je     800b2b <strtol+0xd0>
		*endptr = (char *) s;
  800b1e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b21:	89 0e                	mov    %ecx,(%esi)
  800b23:	eb 06                	jmp    800b2b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b25:	85 db                	test   %ebx,%ebx
  800b27:	74 98                	je     800ac1 <strtol+0x66>
  800b29:	eb 9e                	jmp    800ac9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b2b:	89 c2                	mov    %eax,%edx
  800b2d:	f7 da                	neg    %edx
  800b2f:	85 ff                	test   %edi,%edi
  800b31:	0f 45 c2             	cmovne %edx,%eax
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b47:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4a:	89 c3                	mov    %eax,%ebx
  800b4c:	89 c7                	mov    %eax,%edi
  800b4e:	89 c6                	mov    %eax,%esi
  800b50:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b62:	b8 01 00 00 00       	mov    $0x1,%eax
  800b67:	89 d1                	mov    %edx,%ecx
  800b69:	89 d3                	mov    %edx,%ebx
  800b6b:	89 d7                	mov    %edx,%edi
  800b6d:	89 d6                	mov    %edx,%esi
  800b6f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
  800b7c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b84:	b8 03 00 00 00       	mov    $0x3,%eax
  800b89:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8c:	89 cb                	mov    %ecx,%ebx
  800b8e:	89 cf                	mov    %ecx,%edi
  800b90:	89 ce                	mov    %ecx,%esi
  800b92:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b94:	85 c0                	test   %eax,%eax
  800b96:	7e 17                	jle    800baf <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b98:	83 ec 0c             	sub    $0xc,%esp
  800b9b:	50                   	push   %eax
  800b9c:	6a 03                	push   $0x3
  800b9e:	68 bf 22 80 00       	push   $0x8022bf
  800ba3:	6a 23                	push   $0x23
  800ba5:	68 dc 22 80 00       	push   $0x8022dc
  800baa:	e8 66 f5 ff ff       	call   800115 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800baf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc2:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc7:	89 d1                	mov    %edx,%ecx
  800bc9:	89 d3                	mov    %edx,%ebx
  800bcb:	89 d7                	mov    %edx,%edi
  800bcd:	89 d6                	mov    %edx,%esi
  800bcf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_yield>:

void
sys_yield(void)
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
  800be1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be6:	89 d1                	mov    %edx,%ecx
  800be8:	89 d3                	mov    %edx,%ebx
  800bea:	89 d7                	mov    %edx,%edi
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800bfe:	be 00 00 00 00       	mov    $0x0,%esi
  800c03:	b8 04 00 00 00       	mov    $0x4,%eax
  800c08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c11:	89 f7                	mov    %esi,%edi
  800c13:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c15:	85 c0                	test   %eax,%eax
  800c17:	7e 17                	jle    800c30 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c19:	83 ec 0c             	sub    $0xc,%esp
  800c1c:	50                   	push   %eax
  800c1d:	6a 04                	push   $0x4
  800c1f:	68 bf 22 80 00       	push   $0x8022bf
  800c24:	6a 23                	push   $0x23
  800c26:	68 dc 22 80 00       	push   $0x8022dc
  800c2b:	e8 e5 f4 ff ff       	call   800115 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800c41:	b8 05 00 00 00       	mov    $0x5,%eax
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c52:	8b 75 18             	mov    0x18(%ebp),%esi
  800c55:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c57:	85 c0                	test   %eax,%eax
  800c59:	7e 17                	jle    800c72 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5b:	83 ec 0c             	sub    $0xc,%esp
  800c5e:	50                   	push   %eax
  800c5f:	6a 05                	push   $0x5
  800c61:	68 bf 22 80 00       	push   $0x8022bf
  800c66:	6a 23                	push   $0x23
  800c68:	68 dc 22 80 00       	push   $0x8022dc
  800c6d:	e8 a3 f4 ff ff       	call   800115 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
  800c80:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c88:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	89 df                	mov    %ebx,%edi
  800c95:	89 de                	mov    %ebx,%esi
  800c97:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	7e 17                	jle    800cb4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	83 ec 0c             	sub    $0xc,%esp
  800ca0:	50                   	push   %eax
  800ca1:	6a 06                	push   $0x6
  800ca3:	68 bf 22 80 00       	push   $0x8022bf
  800ca8:	6a 23                	push   $0x23
  800caa:	68 dc 22 80 00       	push   $0x8022dc
  800caf:	e8 61 f4 ff ff       	call   800115 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cca:	b8 08 00 00 00       	mov    $0x8,%eax
  800ccf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	89 df                	mov    %ebx,%edi
  800cd7:	89 de                	mov    %ebx,%esi
  800cd9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	7e 17                	jle    800cf6 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdf:	83 ec 0c             	sub    $0xc,%esp
  800ce2:	50                   	push   %eax
  800ce3:	6a 08                	push   $0x8
  800ce5:	68 bf 22 80 00       	push   $0x8022bf
  800cea:	6a 23                	push   $0x23
  800cec:	68 dc 22 80 00       	push   $0x8022dc
  800cf1:	e8 1f f4 ff ff       	call   800115 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	89 df                	mov    %ebx,%edi
  800d19:	89 de                	mov    %ebx,%esi
  800d1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	7e 17                	jle    800d38 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d21:	83 ec 0c             	sub    $0xc,%esp
  800d24:	50                   	push   %eax
  800d25:	6a 09                	push   $0x9
  800d27:	68 bf 22 80 00       	push   $0x8022bf
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 dc 22 80 00       	push   $0x8022dc
  800d33:	e8 dd f3 ff ff       	call   800115 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	57                   	push   %edi
  800d44:	56                   	push   %esi
  800d45:	53                   	push   %ebx
  800d46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	89 df                	mov    %ebx,%edi
  800d5b:	89 de                	mov    %ebx,%esi
  800d5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	7e 17                	jle    800d7a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	50                   	push   %eax
  800d67:	6a 0a                	push   $0xa
  800d69:	68 bf 22 80 00       	push   $0x8022bf
  800d6e:	6a 23                	push   $0x23
  800d70:	68 dc 22 80 00       	push   $0x8022dc
  800d75:	e8 9b f3 ff ff       	call   800115 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d88:	be 00 00 00 00       	mov    $0x0,%esi
  800d8d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	8b 55 08             	mov    0x8(%ebp),%edx
  800d98:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
  800dab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	89 cb                	mov    %ecx,%ebx
  800dbd:	89 cf                	mov    %ecx,%edi
  800dbf:	89 ce                	mov    %ecx,%esi
  800dc1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	7e 17                	jle    800dde <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc7:	83 ec 0c             	sub    $0xc,%esp
  800dca:	50                   	push   %eax
  800dcb:	6a 0d                	push   $0xd
  800dcd:	68 bf 22 80 00       	push   $0x8022bf
  800dd2:	6a 23                	push   $0x23
  800dd4:	68 dc 22 80 00       	push   $0x8022dc
  800dd9:	e8 37 f3 ff ff       	call   800115 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800dec:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800df3:	75 4a                	jne    800e3f <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  800df5:	a1 04 40 80 00       	mov    0x804004,%eax
  800dfa:	8b 40 48             	mov    0x48(%eax),%eax
  800dfd:	83 ec 04             	sub    $0x4,%esp
  800e00:	6a 07                	push   $0x7
  800e02:	68 00 f0 bf ee       	push   $0xeebff000
  800e07:	50                   	push   %eax
  800e08:	e8 e8 fd ff ff       	call   800bf5 <sys_page_alloc>
  800e0d:	83 c4 10             	add    $0x10,%esp
  800e10:	85 c0                	test   %eax,%eax
  800e12:	79 12                	jns    800e26 <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  800e14:	50                   	push   %eax
  800e15:	68 ea 22 80 00       	push   $0x8022ea
  800e1a:	6a 21                	push   $0x21
  800e1c:	68 02 23 80 00       	push   $0x802302
  800e21:	e8 ef f2 ff ff       	call   800115 <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800e26:	a1 04 40 80 00       	mov    0x804004,%eax
  800e2b:	8b 40 48             	mov    0x48(%eax),%eax
  800e2e:	83 ec 08             	sub    $0x8,%esp
  800e31:	68 49 0e 80 00       	push   $0x800e49
  800e36:	50                   	push   %eax
  800e37:	e8 04 ff ff ff       	call   800d40 <sys_env_set_pgfault_upcall>
  800e3c:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e42:	a3 08 40 80 00       	mov    %eax,0x804008
  800e47:	c9                   	leave  
  800e48:	c3                   	ret    

00800e49 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e49:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e4a:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e4f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e51:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  800e54:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  800e57:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  800e5b:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  800e60:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  800e64:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  800e66:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  800e67:	83 c4 04             	add    $0x4,%esp
	popfl
  800e6a:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e6b:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  800e6c:	c3                   	ret    

00800e6d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e70:	8b 45 08             	mov    0x8(%ebp),%eax
  800e73:	05 00 00 00 30       	add    $0x30000000,%eax
  800e78:	c1 e8 0c             	shr    $0xc,%eax
}
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    

00800e7d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e80:	8b 45 08             	mov    0x8(%ebp),%eax
  800e83:	05 00 00 00 30       	add    $0x30000000,%eax
  800e88:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e8d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    

00800e94 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e9a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e9f:	89 c2                	mov    %eax,%edx
  800ea1:	c1 ea 16             	shr    $0x16,%edx
  800ea4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eab:	f6 c2 01             	test   $0x1,%dl
  800eae:	74 11                	je     800ec1 <fd_alloc+0x2d>
  800eb0:	89 c2                	mov    %eax,%edx
  800eb2:	c1 ea 0c             	shr    $0xc,%edx
  800eb5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ebc:	f6 c2 01             	test   $0x1,%dl
  800ebf:	75 09                	jne    800eca <fd_alloc+0x36>
			*fd_store = fd;
  800ec1:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ec3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec8:	eb 17                	jmp    800ee1 <fd_alloc+0x4d>
  800eca:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ecf:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ed4:	75 c9                	jne    800e9f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ed6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800edc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    

00800ee3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ee9:	83 f8 1f             	cmp    $0x1f,%eax
  800eec:	77 36                	ja     800f24 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eee:	c1 e0 0c             	shl    $0xc,%eax
  800ef1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ef6:	89 c2                	mov    %eax,%edx
  800ef8:	c1 ea 16             	shr    $0x16,%edx
  800efb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f02:	f6 c2 01             	test   $0x1,%dl
  800f05:	74 24                	je     800f2b <fd_lookup+0x48>
  800f07:	89 c2                	mov    %eax,%edx
  800f09:	c1 ea 0c             	shr    $0xc,%edx
  800f0c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f13:	f6 c2 01             	test   $0x1,%dl
  800f16:	74 1a                	je     800f32 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f18:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f1b:	89 02                	mov    %eax,(%edx)
	return 0;
  800f1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f22:	eb 13                	jmp    800f37 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f24:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f29:	eb 0c                	jmp    800f37 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f2b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f30:	eb 05                	jmp    800f37 <fd_lookup+0x54>
  800f32:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    

00800f39 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	83 ec 08             	sub    $0x8,%esp
  800f3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f42:	ba 90 23 80 00       	mov    $0x802390,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f47:	eb 13                	jmp    800f5c <dev_lookup+0x23>
  800f49:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f4c:	39 08                	cmp    %ecx,(%eax)
  800f4e:	75 0c                	jne    800f5c <dev_lookup+0x23>
			*dev = devtab[i];
  800f50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f53:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f55:	b8 00 00 00 00       	mov    $0x0,%eax
  800f5a:	eb 2e                	jmp    800f8a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f5c:	8b 02                	mov    (%edx),%eax
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	75 e7                	jne    800f49 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f62:	a1 04 40 80 00       	mov    0x804004,%eax
  800f67:	8b 40 48             	mov    0x48(%eax),%eax
  800f6a:	83 ec 04             	sub    $0x4,%esp
  800f6d:	51                   	push   %ecx
  800f6e:	50                   	push   %eax
  800f6f:	68 10 23 80 00       	push   $0x802310
  800f74:	e8 75 f2 ff ff       	call   8001ee <cprintf>
	*dev = 0;
  800f79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f7c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f82:	83 c4 10             	add    $0x10,%esp
  800f85:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f8a:	c9                   	leave  
  800f8b:	c3                   	ret    

00800f8c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	56                   	push   %esi
  800f90:	53                   	push   %ebx
  800f91:	83 ec 10             	sub    $0x10,%esp
  800f94:	8b 75 08             	mov    0x8(%ebp),%esi
  800f97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9d:	50                   	push   %eax
  800f9e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fa4:	c1 e8 0c             	shr    $0xc,%eax
  800fa7:	50                   	push   %eax
  800fa8:	e8 36 ff ff ff       	call   800ee3 <fd_lookup>
  800fad:	83 c4 08             	add    $0x8,%esp
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	78 05                	js     800fb9 <fd_close+0x2d>
	    || fd != fd2)
  800fb4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fb7:	74 0c                	je     800fc5 <fd_close+0x39>
		return (must_exist ? r : 0);
  800fb9:	84 db                	test   %bl,%bl
  800fbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc0:	0f 44 c2             	cmove  %edx,%eax
  800fc3:	eb 41                	jmp    801006 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fc5:	83 ec 08             	sub    $0x8,%esp
  800fc8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fcb:	50                   	push   %eax
  800fcc:	ff 36                	pushl  (%esi)
  800fce:	e8 66 ff ff ff       	call   800f39 <dev_lookup>
  800fd3:	89 c3                	mov    %eax,%ebx
  800fd5:	83 c4 10             	add    $0x10,%esp
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	78 1a                	js     800ff6 <fd_close+0x6a>
		if (dev->dev_close)
  800fdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fdf:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fe2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	74 0b                	je     800ff6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800feb:	83 ec 0c             	sub    $0xc,%esp
  800fee:	56                   	push   %esi
  800fef:	ff d0                	call   *%eax
  800ff1:	89 c3                	mov    %eax,%ebx
  800ff3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ff6:	83 ec 08             	sub    $0x8,%esp
  800ff9:	56                   	push   %esi
  800ffa:	6a 00                	push   $0x0
  800ffc:	e8 79 fc ff ff       	call   800c7a <sys_page_unmap>
	return r;
  801001:	83 c4 10             	add    $0x10,%esp
  801004:	89 d8                	mov    %ebx,%eax
}
  801006:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801009:	5b                   	pop    %ebx
  80100a:	5e                   	pop    %esi
  80100b:	5d                   	pop    %ebp
  80100c:	c3                   	ret    

0080100d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80100d:	55                   	push   %ebp
  80100e:	89 e5                	mov    %esp,%ebp
  801010:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801013:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801016:	50                   	push   %eax
  801017:	ff 75 08             	pushl  0x8(%ebp)
  80101a:	e8 c4 fe ff ff       	call   800ee3 <fd_lookup>
  80101f:	83 c4 08             	add    $0x8,%esp
  801022:	85 c0                	test   %eax,%eax
  801024:	78 10                	js     801036 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801026:	83 ec 08             	sub    $0x8,%esp
  801029:	6a 01                	push   $0x1
  80102b:	ff 75 f4             	pushl  -0xc(%ebp)
  80102e:	e8 59 ff ff ff       	call   800f8c <fd_close>
  801033:	83 c4 10             	add    $0x10,%esp
}
  801036:	c9                   	leave  
  801037:	c3                   	ret    

00801038 <close_all>:

void
close_all(void)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	53                   	push   %ebx
  80103c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80103f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801044:	83 ec 0c             	sub    $0xc,%esp
  801047:	53                   	push   %ebx
  801048:	e8 c0 ff ff ff       	call   80100d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80104d:	83 c3 01             	add    $0x1,%ebx
  801050:	83 c4 10             	add    $0x10,%esp
  801053:	83 fb 20             	cmp    $0x20,%ebx
  801056:	75 ec                	jne    801044 <close_all+0xc>
		close(i);
}
  801058:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80105b:	c9                   	leave  
  80105c:	c3                   	ret    

0080105d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	57                   	push   %edi
  801061:	56                   	push   %esi
  801062:	53                   	push   %ebx
  801063:	83 ec 2c             	sub    $0x2c,%esp
  801066:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801069:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80106c:	50                   	push   %eax
  80106d:	ff 75 08             	pushl  0x8(%ebp)
  801070:	e8 6e fe ff ff       	call   800ee3 <fd_lookup>
  801075:	83 c4 08             	add    $0x8,%esp
  801078:	85 c0                	test   %eax,%eax
  80107a:	0f 88 c1 00 00 00    	js     801141 <dup+0xe4>
		return r;
	close(newfdnum);
  801080:	83 ec 0c             	sub    $0xc,%esp
  801083:	56                   	push   %esi
  801084:	e8 84 ff ff ff       	call   80100d <close>

	newfd = INDEX2FD(newfdnum);
  801089:	89 f3                	mov    %esi,%ebx
  80108b:	c1 e3 0c             	shl    $0xc,%ebx
  80108e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801094:	83 c4 04             	add    $0x4,%esp
  801097:	ff 75 e4             	pushl  -0x1c(%ebp)
  80109a:	e8 de fd ff ff       	call   800e7d <fd2data>
  80109f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010a1:	89 1c 24             	mov    %ebx,(%esp)
  8010a4:	e8 d4 fd ff ff       	call   800e7d <fd2data>
  8010a9:	83 c4 10             	add    $0x10,%esp
  8010ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010af:	89 f8                	mov    %edi,%eax
  8010b1:	c1 e8 16             	shr    $0x16,%eax
  8010b4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010bb:	a8 01                	test   $0x1,%al
  8010bd:	74 37                	je     8010f6 <dup+0x99>
  8010bf:	89 f8                	mov    %edi,%eax
  8010c1:	c1 e8 0c             	shr    $0xc,%eax
  8010c4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010cb:	f6 c2 01             	test   $0x1,%dl
  8010ce:	74 26                	je     8010f6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d7:	83 ec 0c             	sub    $0xc,%esp
  8010da:	25 07 0e 00 00       	and    $0xe07,%eax
  8010df:	50                   	push   %eax
  8010e0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010e3:	6a 00                	push   $0x0
  8010e5:	57                   	push   %edi
  8010e6:	6a 00                	push   $0x0
  8010e8:	e8 4b fb ff ff       	call   800c38 <sys_page_map>
  8010ed:	89 c7                	mov    %eax,%edi
  8010ef:	83 c4 20             	add    $0x20,%esp
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	78 2e                	js     801124 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010f6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010f9:	89 d0                	mov    %edx,%eax
  8010fb:	c1 e8 0c             	shr    $0xc,%eax
  8010fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801105:	83 ec 0c             	sub    $0xc,%esp
  801108:	25 07 0e 00 00       	and    $0xe07,%eax
  80110d:	50                   	push   %eax
  80110e:	53                   	push   %ebx
  80110f:	6a 00                	push   $0x0
  801111:	52                   	push   %edx
  801112:	6a 00                	push   $0x0
  801114:	e8 1f fb ff ff       	call   800c38 <sys_page_map>
  801119:	89 c7                	mov    %eax,%edi
  80111b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80111e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801120:	85 ff                	test   %edi,%edi
  801122:	79 1d                	jns    801141 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801124:	83 ec 08             	sub    $0x8,%esp
  801127:	53                   	push   %ebx
  801128:	6a 00                	push   $0x0
  80112a:	e8 4b fb ff ff       	call   800c7a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80112f:	83 c4 08             	add    $0x8,%esp
  801132:	ff 75 d4             	pushl  -0x2c(%ebp)
  801135:	6a 00                	push   $0x0
  801137:	e8 3e fb ff ff       	call   800c7a <sys_page_unmap>
	return r;
  80113c:	83 c4 10             	add    $0x10,%esp
  80113f:	89 f8                	mov    %edi,%eax
}
  801141:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801144:	5b                   	pop    %ebx
  801145:	5e                   	pop    %esi
  801146:	5f                   	pop    %edi
  801147:	5d                   	pop    %ebp
  801148:	c3                   	ret    

00801149 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	53                   	push   %ebx
  80114d:	83 ec 14             	sub    $0x14,%esp
  801150:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801153:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801156:	50                   	push   %eax
  801157:	53                   	push   %ebx
  801158:	e8 86 fd ff ff       	call   800ee3 <fd_lookup>
  80115d:	83 c4 08             	add    $0x8,%esp
  801160:	89 c2                	mov    %eax,%edx
  801162:	85 c0                	test   %eax,%eax
  801164:	78 6d                	js     8011d3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801166:	83 ec 08             	sub    $0x8,%esp
  801169:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80116c:	50                   	push   %eax
  80116d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801170:	ff 30                	pushl  (%eax)
  801172:	e8 c2 fd ff ff       	call   800f39 <dev_lookup>
  801177:	83 c4 10             	add    $0x10,%esp
  80117a:	85 c0                	test   %eax,%eax
  80117c:	78 4c                	js     8011ca <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80117e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801181:	8b 42 08             	mov    0x8(%edx),%eax
  801184:	83 e0 03             	and    $0x3,%eax
  801187:	83 f8 01             	cmp    $0x1,%eax
  80118a:	75 21                	jne    8011ad <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80118c:	a1 04 40 80 00       	mov    0x804004,%eax
  801191:	8b 40 48             	mov    0x48(%eax),%eax
  801194:	83 ec 04             	sub    $0x4,%esp
  801197:	53                   	push   %ebx
  801198:	50                   	push   %eax
  801199:	68 54 23 80 00       	push   $0x802354
  80119e:	e8 4b f0 ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  8011a3:	83 c4 10             	add    $0x10,%esp
  8011a6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011ab:	eb 26                	jmp    8011d3 <read+0x8a>
	}
	if (!dev->dev_read)
  8011ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b0:	8b 40 08             	mov    0x8(%eax),%eax
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	74 17                	je     8011ce <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011b7:	83 ec 04             	sub    $0x4,%esp
  8011ba:	ff 75 10             	pushl  0x10(%ebp)
  8011bd:	ff 75 0c             	pushl  0xc(%ebp)
  8011c0:	52                   	push   %edx
  8011c1:	ff d0                	call   *%eax
  8011c3:	89 c2                	mov    %eax,%edx
  8011c5:	83 c4 10             	add    $0x10,%esp
  8011c8:	eb 09                	jmp    8011d3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ca:	89 c2                	mov    %eax,%edx
  8011cc:	eb 05                	jmp    8011d3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011ce:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011d3:	89 d0                	mov    %edx,%eax
  8011d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d8:	c9                   	leave  
  8011d9:	c3                   	ret    

008011da <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	57                   	push   %edi
  8011de:	56                   	push   %esi
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 0c             	sub    $0xc,%esp
  8011e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011e6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ee:	eb 21                	jmp    801211 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011f0:	83 ec 04             	sub    $0x4,%esp
  8011f3:	89 f0                	mov    %esi,%eax
  8011f5:	29 d8                	sub    %ebx,%eax
  8011f7:	50                   	push   %eax
  8011f8:	89 d8                	mov    %ebx,%eax
  8011fa:	03 45 0c             	add    0xc(%ebp),%eax
  8011fd:	50                   	push   %eax
  8011fe:	57                   	push   %edi
  8011ff:	e8 45 ff ff ff       	call   801149 <read>
		if (m < 0)
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	85 c0                	test   %eax,%eax
  801209:	78 10                	js     80121b <readn+0x41>
			return m;
		if (m == 0)
  80120b:	85 c0                	test   %eax,%eax
  80120d:	74 0a                	je     801219 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80120f:	01 c3                	add    %eax,%ebx
  801211:	39 f3                	cmp    %esi,%ebx
  801213:	72 db                	jb     8011f0 <readn+0x16>
  801215:	89 d8                	mov    %ebx,%eax
  801217:	eb 02                	jmp    80121b <readn+0x41>
  801219:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80121b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121e:	5b                   	pop    %ebx
  80121f:	5e                   	pop    %esi
  801220:	5f                   	pop    %edi
  801221:	5d                   	pop    %ebp
  801222:	c3                   	ret    

00801223 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801223:	55                   	push   %ebp
  801224:	89 e5                	mov    %esp,%ebp
  801226:	53                   	push   %ebx
  801227:	83 ec 14             	sub    $0x14,%esp
  80122a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80122d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801230:	50                   	push   %eax
  801231:	53                   	push   %ebx
  801232:	e8 ac fc ff ff       	call   800ee3 <fd_lookup>
  801237:	83 c4 08             	add    $0x8,%esp
  80123a:	89 c2                	mov    %eax,%edx
  80123c:	85 c0                	test   %eax,%eax
  80123e:	78 68                	js     8012a8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801240:	83 ec 08             	sub    $0x8,%esp
  801243:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801246:	50                   	push   %eax
  801247:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124a:	ff 30                	pushl  (%eax)
  80124c:	e8 e8 fc ff ff       	call   800f39 <dev_lookup>
  801251:	83 c4 10             	add    $0x10,%esp
  801254:	85 c0                	test   %eax,%eax
  801256:	78 47                	js     80129f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801258:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80125f:	75 21                	jne    801282 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801261:	a1 04 40 80 00       	mov    0x804004,%eax
  801266:	8b 40 48             	mov    0x48(%eax),%eax
  801269:	83 ec 04             	sub    $0x4,%esp
  80126c:	53                   	push   %ebx
  80126d:	50                   	push   %eax
  80126e:	68 70 23 80 00       	push   $0x802370
  801273:	e8 76 ef ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  801278:	83 c4 10             	add    $0x10,%esp
  80127b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801280:	eb 26                	jmp    8012a8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801282:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801285:	8b 52 0c             	mov    0xc(%edx),%edx
  801288:	85 d2                	test   %edx,%edx
  80128a:	74 17                	je     8012a3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80128c:	83 ec 04             	sub    $0x4,%esp
  80128f:	ff 75 10             	pushl  0x10(%ebp)
  801292:	ff 75 0c             	pushl  0xc(%ebp)
  801295:	50                   	push   %eax
  801296:	ff d2                	call   *%edx
  801298:	89 c2                	mov    %eax,%edx
  80129a:	83 c4 10             	add    $0x10,%esp
  80129d:	eb 09                	jmp    8012a8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80129f:	89 c2                	mov    %eax,%edx
  8012a1:	eb 05                	jmp    8012a8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012a3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012a8:	89 d0                	mov    %edx,%eax
  8012aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ad:	c9                   	leave  
  8012ae:	c3                   	ret    

008012af <seek>:

int
seek(int fdnum, off_t offset)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012b5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012b8:	50                   	push   %eax
  8012b9:	ff 75 08             	pushl  0x8(%ebp)
  8012bc:	e8 22 fc ff ff       	call   800ee3 <fd_lookup>
  8012c1:	83 c4 08             	add    $0x8,%esp
  8012c4:	85 c0                	test   %eax,%eax
  8012c6:	78 0e                	js     8012d6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ce:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012d6:	c9                   	leave  
  8012d7:	c3                   	ret    

008012d8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	53                   	push   %ebx
  8012dc:	83 ec 14             	sub    $0x14,%esp
  8012df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e5:	50                   	push   %eax
  8012e6:	53                   	push   %ebx
  8012e7:	e8 f7 fb ff ff       	call   800ee3 <fd_lookup>
  8012ec:	83 c4 08             	add    $0x8,%esp
  8012ef:	89 c2                	mov    %eax,%edx
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	78 65                	js     80135a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f5:	83 ec 08             	sub    $0x8,%esp
  8012f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012fb:	50                   	push   %eax
  8012fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ff:	ff 30                	pushl  (%eax)
  801301:	e8 33 fc ff ff       	call   800f39 <dev_lookup>
  801306:	83 c4 10             	add    $0x10,%esp
  801309:	85 c0                	test   %eax,%eax
  80130b:	78 44                	js     801351 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80130d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801310:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801314:	75 21                	jne    801337 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801316:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80131b:	8b 40 48             	mov    0x48(%eax),%eax
  80131e:	83 ec 04             	sub    $0x4,%esp
  801321:	53                   	push   %ebx
  801322:	50                   	push   %eax
  801323:	68 30 23 80 00       	push   $0x802330
  801328:	e8 c1 ee ff ff       	call   8001ee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801335:	eb 23                	jmp    80135a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801337:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80133a:	8b 52 18             	mov    0x18(%edx),%edx
  80133d:	85 d2                	test   %edx,%edx
  80133f:	74 14                	je     801355 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801341:	83 ec 08             	sub    $0x8,%esp
  801344:	ff 75 0c             	pushl  0xc(%ebp)
  801347:	50                   	push   %eax
  801348:	ff d2                	call   *%edx
  80134a:	89 c2                	mov    %eax,%edx
  80134c:	83 c4 10             	add    $0x10,%esp
  80134f:	eb 09                	jmp    80135a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801351:	89 c2                	mov    %eax,%edx
  801353:	eb 05                	jmp    80135a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801355:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80135a:	89 d0                	mov    %edx,%eax
  80135c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135f:	c9                   	leave  
  801360:	c3                   	ret    

00801361 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
  801364:	53                   	push   %ebx
  801365:	83 ec 14             	sub    $0x14,%esp
  801368:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80136b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80136e:	50                   	push   %eax
  80136f:	ff 75 08             	pushl  0x8(%ebp)
  801372:	e8 6c fb ff ff       	call   800ee3 <fd_lookup>
  801377:	83 c4 08             	add    $0x8,%esp
  80137a:	89 c2                	mov    %eax,%edx
  80137c:	85 c0                	test   %eax,%eax
  80137e:	78 58                	js     8013d8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801380:	83 ec 08             	sub    $0x8,%esp
  801383:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801386:	50                   	push   %eax
  801387:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138a:	ff 30                	pushl  (%eax)
  80138c:	e8 a8 fb ff ff       	call   800f39 <dev_lookup>
  801391:	83 c4 10             	add    $0x10,%esp
  801394:	85 c0                	test   %eax,%eax
  801396:	78 37                	js     8013cf <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801398:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80139f:	74 32                	je     8013d3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013a1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013a4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013ab:	00 00 00 
	stat->st_isdir = 0;
  8013ae:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013b5:	00 00 00 
	stat->st_dev = dev;
  8013b8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013be:	83 ec 08             	sub    $0x8,%esp
  8013c1:	53                   	push   %ebx
  8013c2:	ff 75 f0             	pushl  -0x10(%ebp)
  8013c5:	ff 50 14             	call   *0x14(%eax)
  8013c8:	89 c2                	mov    %eax,%edx
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	eb 09                	jmp    8013d8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013cf:	89 c2                	mov    %eax,%edx
  8013d1:	eb 05                	jmp    8013d8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013d3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013d8:	89 d0                	mov    %edx,%eax
  8013da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013dd:	c9                   	leave  
  8013de:	c3                   	ret    

008013df <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	56                   	push   %esi
  8013e3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013e4:	83 ec 08             	sub    $0x8,%esp
  8013e7:	6a 00                	push   $0x0
  8013e9:	ff 75 08             	pushl  0x8(%ebp)
  8013ec:	e8 e3 01 00 00       	call   8015d4 <open>
  8013f1:	89 c3                	mov    %eax,%ebx
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	78 1b                	js     801415 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013fa:	83 ec 08             	sub    $0x8,%esp
  8013fd:	ff 75 0c             	pushl  0xc(%ebp)
  801400:	50                   	push   %eax
  801401:	e8 5b ff ff ff       	call   801361 <fstat>
  801406:	89 c6                	mov    %eax,%esi
	close(fd);
  801408:	89 1c 24             	mov    %ebx,(%esp)
  80140b:	e8 fd fb ff ff       	call   80100d <close>
	return r;
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	89 f0                	mov    %esi,%eax
}
  801415:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801418:	5b                   	pop    %ebx
  801419:	5e                   	pop    %esi
  80141a:	5d                   	pop    %ebp
  80141b:	c3                   	ret    

0080141c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	56                   	push   %esi
  801420:	53                   	push   %ebx
  801421:	89 c6                	mov    %eax,%esi
  801423:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801425:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80142c:	75 12                	jne    801440 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80142e:	83 ec 0c             	sub    $0xc,%esp
  801431:	6a 01                	push   $0x1
  801433:	e8 dc 07 00 00       	call   801c14 <ipc_find_env>
  801438:	a3 00 40 80 00       	mov    %eax,0x804000
  80143d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801440:	6a 07                	push   $0x7
  801442:	68 00 50 80 00       	push   $0x805000
  801447:	56                   	push   %esi
  801448:	ff 35 00 40 80 00    	pushl  0x804000
  80144e:	e8 6d 07 00 00       	call   801bc0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801453:	83 c4 0c             	add    $0xc,%esp
  801456:	6a 00                	push   $0x0
  801458:	53                   	push   %ebx
  801459:	6a 00                	push   $0x0
  80145b:	e8 f7 06 00 00       	call   801b57 <ipc_recv>
}
  801460:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801463:	5b                   	pop    %ebx
  801464:	5e                   	pop    %esi
  801465:	5d                   	pop    %ebp
  801466:	c3                   	ret    

00801467 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801467:	55                   	push   %ebp
  801468:	89 e5                	mov    %esp,%ebp
  80146a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80146d:	8b 45 08             	mov    0x8(%ebp),%eax
  801470:	8b 40 0c             	mov    0xc(%eax),%eax
  801473:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801478:	8b 45 0c             	mov    0xc(%ebp),%eax
  80147b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801480:	ba 00 00 00 00       	mov    $0x0,%edx
  801485:	b8 02 00 00 00       	mov    $0x2,%eax
  80148a:	e8 8d ff ff ff       	call   80141c <fsipc>
}
  80148f:	c9                   	leave  
  801490:	c3                   	ret    

00801491 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
  801494:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801497:	8b 45 08             	mov    0x8(%ebp),%eax
  80149a:	8b 40 0c             	mov    0xc(%eax),%eax
  80149d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a7:	b8 06 00 00 00       	mov    $0x6,%eax
  8014ac:	e8 6b ff ff ff       	call   80141c <fsipc>
}
  8014b1:	c9                   	leave  
  8014b2:	c3                   	ret    

008014b3 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014b3:	55                   	push   %ebp
  8014b4:	89 e5                	mov    %esp,%ebp
  8014b6:	53                   	push   %ebx
  8014b7:	83 ec 04             	sub    $0x4,%esp
  8014ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8014d2:	e8 45 ff ff ff       	call   80141c <fsipc>
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	78 2c                	js     801507 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014db:	83 ec 08             	sub    $0x8,%esp
  8014de:	68 00 50 80 00       	push   $0x805000
  8014e3:	53                   	push   %ebx
  8014e4:	e8 09 f3 ff ff       	call   8007f2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014e9:	a1 80 50 80 00       	mov    0x805080,%eax
  8014ee:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014f4:	a1 84 50 80 00       	mov    0x805084,%eax
  8014f9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801507:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150a:	c9                   	leave  
  80150b:	c3                   	ret    

0080150c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	83 ec 0c             	sub    $0xc,%esp
  801512:	8b 45 10             	mov    0x10(%ebp),%eax
  801515:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80151a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80151f:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801522:	8b 55 08             	mov    0x8(%ebp),%edx
  801525:	8b 52 0c             	mov    0xc(%edx),%edx
  801528:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80152e:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801533:	50                   	push   %eax
  801534:	ff 75 0c             	pushl  0xc(%ebp)
  801537:	68 08 50 80 00       	push   $0x805008
  80153c:	e8 43 f4 ff ff       	call   800984 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801541:	ba 00 00 00 00       	mov    $0x0,%edx
  801546:	b8 04 00 00 00       	mov    $0x4,%eax
  80154b:	e8 cc fe ff ff       	call   80141c <fsipc>
	//panic("devfile_write not implemented");
}
  801550:	c9                   	leave  
  801551:	c3                   	ret    

00801552 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801552:	55                   	push   %ebp
  801553:	89 e5                	mov    %esp,%ebp
  801555:	56                   	push   %esi
  801556:	53                   	push   %ebx
  801557:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80155a:	8b 45 08             	mov    0x8(%ebp),%eax
  80155d:	8b 40 0c             	mov    0xc(%eax),%eax
  801560:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801565:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80156b:	ba 00 00 00 00       	mov    $0x0,%edx
  801570:	b8 03 00 00 00       	mov    $0x3,%eax
  801575:	e8 a2 fe ff ff       	call   80141c <fsipc>
  80157a:	89 c3                	mov    %eax,%ebx
  80157c:	85 c0                	test   %eax,%eax
  80157e:	78 4b                	js     8015cb <devfile_read+0x79>
		return r;
	assert(r <= n);
  801580:	39 c6                	cmp    %eax,%esi
  801582:	73 16                	jae    80159a <devfile_read+0x48>
  801584:	68 a0 23 80 00       	push   $0x8023a0
  801589:	68 a7 23 80 00       	push   $0x8023a7
  80158e:	6a 7c                	push   $0x7c
  801590:	68 bc 23 80 00       	push   $0x8023bc
  801595:	e8 7b eb ff ff       	call   800115 <_panic>
	assert(r <= PGSIZE);
  80159a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80159f:	7e 16                	jle    8015b7 <devfile_read+0x65>
  8015a1:	68 c7 23 80 00       	push   $0x8023c7
  8015a6:	68 a7 23 80 00       	push   $0x8023a7
  8015ab:	6a 7d                	push   $0x7d
  8015ad:	68 bc 23 80 00       	push   $0x8023bc
  8015b2:	e8 5e eb ff ff       	call   800115 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015b7:	83 ec 04             	sub    $0x4,%esp
  8015ba:	50                   	push   %eax
  8015bb:	68 00 50 80 00       	push   $0x805000
  8015c0:	ff 75 0c             	pushl  0xc(%ebp)
  8015c3:	e8 bc f3 ff ff       	call   800984 <memmove>
	return r;
  8015c8:	83 c4 10             	add    $0x10,%esp
}
  8015cb:	89 d8                	mov    %ebx,%eax
  8015cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d0:	5b                   	pop    %ebx
  8015d1:	5e                   	pop    %esi
  8015d2:	5d                   	pop    %ebp
  8015d3:	c3                   	ret    

008015d4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015d4:	55                   	push   %ebp
  8015d5:	89 e5                	mov    %esp,%ebp
  8015d7:	53                   	push   %ebx
  8015d8:	83 ec 20             	sub    $0x20,%esp
  8015db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015de:	53                   	push   %ebx
  8015df:	e8 d5 f1 ff ff       	call   8007b9 <strlen>
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015ec:	7f 67                	jg     801655 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015ee:	83 ec 0c             	sub    $0xc,%esp
  8015f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f4:	50                   	push   %eax
  8015f5:	e8 9a f8 ff ff       	call   800e94 <fd_alloc>
  8015fa:	83 c4 10             	add    $0x10,%esp
		return r;
  8015fd:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015ff:	85 c0                	test   %eax,%eax
  801601:	78 57                	js     80165a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801603:	83 ec 08             	sub    $0x8,%esp
  801606:	53                   	push   %ebx
  801607:	68 00 50 80 00       	push   $0x805000
  80160c:	e8 e1 f1 ff ff       	call   8007f2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801611:	8b 45 0c             	mov    0xc(%ebp),%eax
  801614:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801619:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161c:	b8 01 00 00 00       	mov    $0x1,%eax
  801621:	e8 f6 fd ff ff       	call   80141c <fsipc>
  801626:	89 c3                	mov    %eax,%ebx
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	85 c0                	test   %eax,%eax
  80162d:	79 14                	jns    801643 <open+0x6f>
		fd_close(fd, 0);
  80162f:	83 ec 08             	sub    $0x8,%esp
  801632:	6a 00                	push   $0x0
  801634:	ff 75 f4             	pushl  -0xc(%ebp)
  801637:	e8 50 f9 ff ff       	call   800f8c <fd_close>
		return r;
  80163c:	83 c4 10             	add    $0x10,%esp
  80163f:	89 da                	mov    %ebx,%edx
  801641:	eb 17                	jmp    80165a <open+0x86>
	}

	return fd2num(fd);
  801643:	83 ec 0c             	sub    $0xc,%esp
  801646:	ff 75 f4             	pushl  -0xc(%ebp)
  801649:	e8 1f f8 ff ff       	call   800e6d <fd2num>
  80164e:	89 c2                	mov    %eax,%edx
  801650:	83 c4 10             	add    $0x10,%esp
  801653:	eb 05                	jmp    80165a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801655:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80165a:	89 d0                	mov    %edx,%eax
  80165c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165f:	c9                   	leave  
  801660:	c3                   	ret    

00801661 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801667:	ba 00 00 00 00       	mov    $0x0,%edx
  80166c:	b8 08 00 00 00       	mov    $0x8,%eax
  801671:	e8 a6 fd ff ff       	call   80141c <fsipc>
}
  801676:	c9                   	leave  
  801677:	c3                   	ret    

00801678 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801678:	55                   	push   %ebp
  801679:	89 e5                	mov    %esp,%ebp
  80167b:	56                   	push   %esi
  80167c:	53                   	push   %ebx
  80167d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801680:	83 ec 0c             	sub    $0xc,%esp
  801683:	ff 75 08             	pushl  0x8(%ebp)
  801686:	e8 f2 f7 ff ff       	call   800e7d <fd2data>
  80168b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80168d:	83 c4 08             	add    $0x8,%esp
  801690:	68 d3 23 80 00       	push   $0x8023d3
  801695:	53                   	push   %ebx
  801696:	e8 57 f1 ff ff       	call   8007f2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80169b:	8b 46 04             	mov    0x4(%esi),%eax
  80169e:	2b 06                	sub    (%esi),%eax
  8016a0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016a6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016ad:	00 00 00 
	stat->st_dev = &devpipe;
  8016b0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016b7:	30 80 00 
	return 0;
}
  8016ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8016bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c2:	5b                   	pop    %ebx
  8016c3:	5e                   	pop    %esi
  8016c4:	5d                   	pop    %ebp
  8016c5:	c3                   	ret    

008016c6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	53                   	push   %ebx
  8016ca:	83 ec 0c             	sub    $0xc,%esp
  8016cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016d0:	53                   	push   %ebx
  8016d1:	6a 00                	push   $0x0
  8016d3:	e8 a2 f5 ff ff       	call   800c7a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016d8:	89 1c 24             	mov    %ebx,(%esp)
  8016db:	e8 9d f7 ff ff       	call   800e7d <fd2data>
  8016e0:	83 c4 08             	add    $0x8,%esp
  8016e3:	50                   	push   %eax
  8016e4:	6a 00                	push   $0x0
  8016e6:	e8 8f f5 ff ff       	call   800c7a <sys_page_unmap>
}
  8016eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ee:	c9                   	leave  
  8016ef:	c3                   	ret    

008016f0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	57                   	push   %edi
  8016f4:	56                   	push   %esi
  8016f5:	53                   	push   %ebx
  8016f6:	83 ec 1c             	sub    $0x1c,%esp
  8016f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016fc:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016fe:	a1 04 40 80 00       	mov    0x804004,%eax
  801703:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801706:	83 ec 0c             	sub    $0xc,%esp
  801709:	ff 75 e0             	pushl  -0x20(%ebp)
  80170c:	e8 3c 05 00 00       	call   801c4d <pageref>
  801711:	89 c3                	mov    %eax,%ebx
  801713:	89 3c 24             	mov    %edi,(%esp)
  801716:	e8 32 05 00 00       	call   801c4d <pageref>
  80171b:	83 c4 10             	add    $0x10,%esp
  80171e:	39 c3                	cmp    %eax,%ebx
  801720:	0f 94 c1             	sete   %cl
  801723:	0f b6 c9             	movzbl %cl,%ecx
  801726:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801729:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80172f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801732:	39 ce                	cmp    %ecx,%esi
  801734:	74 1b                	je     801751 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801736:	39 c3                	cmp    %eax,%ebx
  801738:	75 c4                	jne    8016fe <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80173a:	8b 42 58             	mov    0x58(%edx),%eax
  80173d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801740:	50                   	push   %eax
  801741:	56                   	push   %esi
  801742:	68 da 23 80 00       	push   $0x8023da
  801747:	e8 a2 ea ff ff       	call   8001ee <cprintf>
  80174c:	83 c4 10             	add    $0x10,%esp
  80174f:	eb ad                	jmp    8016fe <_pipeisclosed+0xe>
	}
}
  801751:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801754:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801757:	5b                   	pop    %ebx
  801758:	5e                   	pop    %esi
  801759:	5f                   	pop    %edi
  80175a:	5d                   	pop    %ebp
  80175b:	c3                   	ret    

0080175c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	57                   	push   %edi
  801760:	56                   	push   %esi
  801761:	53                   	push   %ebx
  801762:	83 ec 28             	sub    $0x28,%esp
  801765:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801768:	56                   	push   %esi
  801769:	e8 0f f7 ff ff       	call   800e7d <fd2data>
  80176e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	bf 00 00 00 00       	mov    $0x0,%edi
  801778:	eb 4b                	jmp    8017c5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80177a:	89 da                	mov    %ebx,%edx
  80177c:	89 f0                	mov    %esi,%eax
  80177e:	e8 6d ff ff ff       	call   8016f0 <_pipeisclosed>
  801783:	85 c0                	test   %eax,%eax
  801785:	75 48                	jne    8017cf <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801787:	e8 4a f4 ff ff       	call   800bd6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80178c:	8b 43 04             	mov    0x4(%ebx),%eax
  80178f:	8b 0b                	mov    (%ebx),%ecx
  801791:	8d 51 20             	lea    0x20(%ecx),%edx
  801794:	39 d0                	cmp    %edx,%eax
  801796:	73 e2                	jae    80177a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801798:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80179b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80179f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017a2:	89 c2                	mov    %eax,%edx
  8017a4:	c1 fa 1f             	sar    $0x1f,%edx
  8017a7:	89 d1                	mov    %edx,%ecx
  8017a9:	c1 e9 1b             	shr    $0x1b,%ecx
  8017ac:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017af:	83 e2 1f             	and    $0x1f,%edx
  8017b2:	29 ca                	sub    %ecx,%edx
  8017b4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017b8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017bc:	83 c0 01             	add    $0x1,%eax
  8017bf:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017c2:	83 c7 01             	add    $0x1,%edi
  8017c5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017c8:	75 c2                	jne    80178c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8017cd:	eb 05                	jmp    8017d4 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017cf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017d7:	5b                   	pop    %ebx
  8017d8:	5e                   	pop    %esi
  8017d9:	5f                   	pop    %edi
  8017da:	5d                   	pop    %ebp
  8017db:	c3                   	ret    

008017dc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	57                   	push   %edi
  8017e0:	56                   	push   %esi
  8017e1:	53                   	push   %ebx
  8017e2:	83 ec 18             	sub    $0x18,%esp
  8017e5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017e8:	57                   	push   %edi
  8017e9:	e8 8f f6 ff ff       	call   800e7d <fd2data>
  8017ee:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017f0:	83 c4 10             	add    $0x10,%esp
  8017f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017f8:	eb 3d                	jmp    801837 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017fa:	85 db                	test   %ebx,%ebx
  8017fc:	74 04                	je     801802 <devpipe_read+0x26>
				return i;
  8017fe:	89 d8                	mov    %ebx,%eax
  801800:	eb 44                	jmp    801846 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801802:	89 f2                	mov    %esi,%edx
  801804:	89 f8                	mov    %edi,%eax
  801806:	e8 e5 fe ff ff       	call   8016f0 <_pipeisclosed>
  80180b:	85 c0                	test   %eax,%eax
  80180d:	75 32                	jne    801841 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80180f:	e8 c2 f3 ff ff       	call   800bd6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801814:	8b 06                	mov    (%esi),%eax
  801816:	3b 46 04             	cmp    0x4(%esi),%eax
  801819:	74 df                	je     8017fa <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80181b:	99                   	cltd   
  80181c:	c1 ea 1b             	shr    $0x1b,%edx
  80181f:	01 d0                	add    %edx,%eax
  801821:	83 e0 1f             	and    $0x1f,%eax
  801824:	29 d0                	sub    %edx,%eax
  801826:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80182b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80182e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801831:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801834:	83 c3 01             	add    $0x1,%ebx
  801837:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80183a:	75 d8                	jne    801814 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80183c:	8b 45 10             	mov    0x10(%ebp),%eax
  80183f:	eb 05                	jmp    801846 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801841:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801846:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801849:	5b                   	pop    %ebx
  80184a:	5e                   	pop    %esi
  80184b:	5f                   	pop    %edi
  80184c:	5d                   	pop    %ebp
  80184d:	c3                   	ret    

0080184e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	56                   	push   %esi
  801852:	53                   	push   %ebx
  801853:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801856:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801859:	50                   	push   %eax
  80185a:	e8 35 f6 ff ff       	call   800e94 <fd_alloc>
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	89 c2                	mov    %eax,%edx
  801864:	85 c0                	test   %eax,%eax
  801866:	0f 88 2c 01 00 00    	js     801998 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80186c:	83 ec 04             	sub    $0x4,%esp
  80186f:	68 07 04 00 00       	push   $0x407
  801874:	ff 75 f4             	pushl  -0xc(%ebp)
  801877:	6a 00                	push   $0x0
  801879:	e8 77 f3 ff ff       	call   800bf5 <sys_page_alloc>
  80187e:	83 c4 10             	add    $0x10,%esp
  801881:	89 c2                	mov    %eax,%edx
  801883:	85 c0                	test   %eax,%eax
  801885:	0f 88 0d 01 00 00    	js     801998 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80188b:	83 ec 0c             	sub    $0xc,%esp
  80188e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801891:	50                   	push   %eax
  801892:	e8 fd f5 ff ff       	call   800e94 <fd_alloc>
  801897:	89 c3                	mov    %eax,%ebx
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	85 c0                	test   %eax,%eax
  80189e:	0f 88 e2 00 00 00    	js     801986 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018a4:	83 ec 04             	sub    $0x4,%esp
  8018a7:	68 07 04 00 00       	push   $0x407
  8018ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8018af:	6a 00                	push   $0x0
  8018b1:	e8 3f f3 ff ff       	call   800bf5 <sys_page_alloc>
  8018b6:	89 c3                	mov    %eax,%ebx
  8018b8:	83 c4 10             	add    $0x10,%esp
  8018bb:	85 c0                	test   %eax,%eax
  8018bd:	0f 88 c3 00 00 00    	js     801986 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018c3:	83 ec 0c             	sub    $0xc,%esp
  8018c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c9:	e8 af f5 ff ff       	call   800e7d <fd2data>
  8018ce:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018d0:	83 c4 0c             	add    $0xc,%esp
  8018d3:	68 07 04 00 00       	push   $0x407
  8018d8:	50                   	push   %eax
  8018d9:	6a 00                	push   $0x0
  8018db:	e8 15 f3 ff ff       	call   800bf5 <sys_page_alloc>
  8018e0:	89 c3                	mov    %eax,%ebx
  8018e2:	83 c4 10             	add    $0x10,%esp
  8018e5:	85 c0                	test   %eax,%eax
  8018e7:	0f 88 89 00 00 00    	js     801976 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ed:	83 ec 0c             	sub    $0xc,%esp
  8018f0:	ff 75 f0             	pushl  -0x10(%ebp)
  8018f3:	e8 85 f5 ff ff       	call   800e7d <fd2data>
  8018f8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018ff:	50                   	push   %eax
  801900:	6a 00                	push   $0x0
  801902:	56                   	push   %esi
  801903:	6a 00                	push   $0x0
  801905:	e8 2e f3 ff ff       	call   800c38 <sys_page_map>
  80190a:	89 c3                	mov    %eax,%ebx
  80190c:	83 c4 20             	add    $0x20,%esp
  80190f:	85 c0                	test   %eax,%eax
  801911:	78 55                	js     801968 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801913:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801919:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80191c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80191e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801921:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801928:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80192e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801931:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801933:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801936:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80193d:	83 ec 0c             	sub    $0xc,%esp
  801940:	ff 75 f4             	pushl  -0xc(%ebp)
  801943:	e8 25 f5 ff ff       	call   800e6d <fd2num>
  801948:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80194b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80194d:	83 c4 04             	add    $0x4,%esp
  801950:	ff 75 f0             	pushl  -0x10(%ebp)
  801953:	e8 15 f5 ff ff       	call   800e6d <fd2num>
  801958:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80195b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80195e:	83 c4 10             	add    $0x10,%esp
  801961:	ba 00 00 00 00       	mov    $0x0,%edx
  801966:	eb 30                	jmp    801998 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801968:	83 ec 08             	sub    $0x8,%esp
  80196b:	56                   	push   %esi
  80196c:	6a 00                	push   $0x0
  80196e:	e8 07 f3 ff ff       	call   800c7a <sys_page_unmap>
  801973:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801976:	83 ec 08             	sub    $0x8,%esp
  801979:	ff 75 f0             	pushl  -0x10(%ebp)
  80197c:	6a 00                	push   $0x0
  80197e:	e8 f7 f2 ff ff       	call   800c7a <sys_page_unmap>
  801983:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801986:	83 ec 08             	sub    $0x8,%esp
  801989:	ff 75 f4             	pushl  -0xc(%ebp)
  80198c:	6a 00                	push   $0x0
  80198e:	e8 e7 f2 ff ff       	call   800c7a <sys_page_unmap>
  801993:	83 c4 10             	add    $0x10,%esp
  801996:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801998:	89 d0                	mov    %edx,%eax
  80199a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199d:	5b                   	pop    %ebx
  80199e:	5e                   	pop    %esi
  80199f:	5d                   	pop    %ebp
  8019a0:	c3                   	ret    

008019a1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019a1:	55                   	push   %ebp
  8019a2:	89 e5                	mov    %esp,%ebp
  8019a4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019aa:	50                   	push   %eax
  8019ab:	ff 75 08             	pushl  0x8(%ebp)
  8019ae:	e8 30 f5 ff ff       	call   800ee3 <fd_lookup>
  8019b3:	83 c4 10             	add    $0x10,%esp
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	78 18                	js     8019d2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019ba:	83 ec 0c             	sub    $0xc,%esp
  8019bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c0:	e8 b8 f4 ff ff       	call   800e7d <fd2data>
	return _pipeisclosed(fd, p);
  8019c5:	89 c2                	mov    %eax,%edx
  8019c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ca:	e8 21 fd ff ff       	call   8016f0 <_pipeisclosed>
  8019cf:	83 c4 10             	add    $0x10,%esp
}
  8019d2:	c9                   	leave  
  8019d3:	c3                   	ret    

008019d4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8019dc:	5d                   	pop    %ebp
  8019dd:	c3                   	ret    

008019de <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019e4:	68 f2 23 80 00       	push   $0x8023f2
  8019e9:	ff 75 0c             	pushl  0xc(%ebp)
  8019ec:	e8 01 ee ff ff       	call   8007f2 <strcpy>
	return 0;
}
  8019f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f6:	c9                   	leave  
  8019f7:	c3                   	ret    

008019f8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	57                   	push   %edi
  8019fc:	56                   	push   %esi
  8019fd:	53                   	push   %ebx
  8019fe:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a04:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a09:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a0f:	eb 2d                	jmp    801a3e <devcons_write+0x46>
		m = n - tot;
  801a11:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a14:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801a16:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a19:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a1e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a21:	83 ec 04             	sub    $0x4,%esp
  801a24:	53                   	push   %ebx
  801a25:	03 45 0c             	add    0xc(%ebp),%eax
  801a28:	50                   	push   %eax
  801a29:	57                   	push   %edi
  801a2a:	e8 55 ef ff ff       	call   800984 <memmove>
		sys_cputs(buf, m);
  801a2f:	83 c4 08             	add    $0x8,%esp
  801a32:	53                   	push   %ebx
  801a33:	57                   	push   %edi
  801a34:	e8 00 f1 ff ff       	call   800b39 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a39:	01 de                	add    %ebx,%esi
  801a3b:	83 c4 10             	add    $0x10,%esp
  801a3e:	89 f0                	mov    %esi,%eax
  801a40:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a43:	72 cc                	jb     801a11 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a48:	5b                   	pop    %ebx
  801a49:	5e                   	pop    %esi
  801a4a:	5f                   	pop    %edi
  801a4b:	5d                   	pop    %ebp
  801a4c:	c3                   	ret    

00801a4d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a4d:	55                   	push   %ebp
  801a4e:	89 e5                	mov    %esp,%ebp
  801a50:	83 ec 08             	sub    $0x8,%esp
  801a53:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a58:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a5c:	74 2a                	je     801a88 <devcons_read+0x3b>
  801a5e:	eb 05                	jmp    801a65 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a60:	e8 71 f1 ff ff       	call   800bd6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a65:	e8 ed f0 ff ff       	call   800b57 <sys_cgetc>
  801a6a:	85 c0                	test   %eax,%eax
  801a6c:	74 f2                	je     801a60 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	78 16                	js     801a88 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a72:	83 f8 04             	cmp    $0x4,%eax
  801a75:	74 0c                	je     801a83 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a77:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a7a:	88 02                	mov    %al,(%edx)
	return 1;
  801a7c:	b8 01 00 00 00       	mov    $0x1,%eax
  801a81:	eb 05                	jmp    801a88 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a83:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a88:	c9                   	leave  
  801a89:	c3                   	ret    

00801a8a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a90:	8b 45 08             	mov    0x8(%ebp),%eax
  801a93:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a96:	6a 01                	push   $0x1
  801a98:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a9b:	50                   	push   %eax
  801a9c:	e8 98 f0 ff ff       	call   800b39 <sys_cputs>
}
  801aa1:	83 c4 10             	add    $0x10,%esp
  801aa4:	c9                   	leave  
  801aa5:	c3                   	ret    

00801aa6 <getchar>:

int
getchar(void)
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801aac:	6a 01                	push   $0x1
  801aae:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ab1:	50                   	push   %eax
  801ab2:	6a 00                	push   $0x0
  801ab4:	e8 90 f6 ff ff       	call   801149 <read>
	if (r < 0)
  801ab9:	83 c4 10             	add    $0x10,%esp
  801abc:	85 c0                	test   %eax,%eax
  801abe:	78 0f                	js     801acf <getchar+0x29>
		return r;
	if (r < 1)
  801ac0:	85 c0                	test   %eax,%eax
  801ac2:	7e 06                	jle    801aca <getchar+0x24>
		return -E_EOF;
	return c;
  801ac4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ac8:	eb 05                	jmp    801acf <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801aca:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801acf:	c9                   	leave  
  801ad0:	c3                   	ret    

00801ad1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ad7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ada:	50                   	push   %eax
  801adb:	ff 75 08             	pushl  0x8(%ebp)
  801ade:	e8 00 f4 ff ff       	call   800ee3 <fd_lookup>
  801ae3:	83 c4 10             	add    $0x10,%esp
  801ae6:	85 c0                	test   %eax,%eax
  801ae8:	78 11                	js     801afb <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aed:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801af3:	39 10                	cmp    %edx,(%eax)
  801af5:	0f 94 c0             	sete   %al
  801af8:	0f b6 c0             	movzbl %al,%eax
}
  801afb:	c9                   	leave  
  801afc:	c3                   	ret    

00801afd <opencons>:

int
opencons(void)
{
  801afd:	55                   	push   %ebp
  801afe:	89 e5                	mov    %esp,%ebp
  801b00:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b06:	50                   	push   %eax
  801b07:	e8 88 f3 ff ff       	call   800e94 <fd_alloc>
  801b0c:	83 c4 10             	add    $0x10,%esp
		return r;
  801b0f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b11:	85 c0                	test   %eax,%eax
  801b13:	78 3e                	js     801b53 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b15:	83 ec 04             	sub    $0x4,%esp
  801b18:	68 07 04 00 00       	push   $0x407
  801b1d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b20:	6a 00                	push   $0x0
  801b22:	e8 ce f0 ff ff       	call   800bf5 <sys_page_alloc>
  801b27:	83 c4 10             	add    $0x10,%esp
		return r;
  801b2a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b2c:	85 c0                	test   %eax,%eax
  801b2e:	78 23                	js     801b53 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b30:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b39:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b3e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b45:	83 ec 0c             	sub    $0xc,%esp
  801b48:	50                   	push   %eax
  801b49:	e8 1f f3 ff ff       	call   800e6d <fd2num>
  801b4e:	89 c2                	mov    %eax,%edx
  801b50:	83 c4 10             	add    $0x10,%esp
}
  801b53:	89 d0                	mov    %edx,%eax
  801b55:	c9                   	leave  
  801b56:	c3                   	ret    

00801b57 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b57:	55                   	push   %ebp
  801b58:	89 e5                	mov    %esp,%ebp
  801b5a:	56                   	push   %esi
  801b5b:	53                   	push   %ebx
  801b5c:	8b 75 08             	mov    0x8(%ebp),%esi
  801b5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b62:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801b65:	85 c0                	test   %eax,%eax
  801b67:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b6c:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801b6f:	83 ec 0c             	sub    $0xc,%esp
  801b72:	50                   	push   %eax
  801b73:	e8 2d f2 ff ff       	call   800da5 <sys_ipc_recv>
  801b78:	83 c4 10             	add    $0x10,%esp
  801b7b:	85 c0                	test   %eax,%eax
  801b7d:	79 16                	jns    801b95 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801b7f:	85 f6                	test   %esi,%esi
  801b81:	74 06                	je     801b89 <ipc_recv+0x32>
            *from_env_store = 0;
  801b83:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801b89:	85 db                	test   %ebx,%ebx
  801b8b:	74 2c                	je     801bb9 <ipc_recv+0x62>
            *perm_store = 0;
  801b8d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b93:	eb 24                	jmp    801bb9 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801b95:	85 f6                	test   %esi,%esi
  801b97:	74 0a                	je     801ba3 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801b99:	a1 04 40 80 00       	mov    0x804004,%eax
  801b9e:	8b 40 74             	mov    0x74(%eax),%eax
  801ba1:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801ba3:	85 db                	test   %ebx,%ebx
  801ba5:	74 0a                	je     801bb1 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801ba7:	a1 04 40 80 00       	mov    0x804004,%eax
  801bac:	8b 40 78             	mov    0x78(%eax),%eax
  801baf:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801bb1:	a1 04 40 80 00       	mov    0x804004,%eax
  801bb6:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801bb9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bbc:	5b                   	pop    %ebx
  801bbd:	5e                   	pop    %esi
  801bbe:	5d                   	pop    %ebp
  801bbf:	c3                   	ret    

00801bc0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	57                   	push   %edi
  801bc4:	56                   	push   %esi
  801bc5:	53                   	push   %ebx
  801bc6:	83 ec 0c             	sub    $0xc,%esp
  801bc9:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bcc:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bcf:	8b 45 10             	mov    0x10(%ebp),%eax
  801bd2:	85 c0                	test   %eax,%eax
  801bd4:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801bd9:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801bdc:	eb 1c                	jmp    801bfa <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801bde:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801be1:	74 12                	je     801bf5 <ipc_send+0x35>
  801be3:	50                   	push   %eax
  801be4:	68 fe 23 80 00       	push   $0x8023fe
  801be9:	6a 3a                	push   $0x3a
  801beb:	68 14 24 80 00       	push   $0x802414
  801bf0:	e8 20 e5 ff ff       	call   800115 <_panic>
		sys_yield();
  801bf5:	e8 dc ef ff ff       	call   800bd6 <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801bfa:	ff 75 14             	pushl  0x14(%ebp)
  801bfd:	53                   	push   %ebx
  801bfe:	56                   	push   %esi
  801bff:	57                   	push   %edi
  801c00:	e8 7d f1 ff ff       	call   800d82 <sys_ipc_try_send>
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	85 c0                	test   %eax,%eax
  801c0a:	78 d2                	js     801bde <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801c0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0f:	5b                   	pop    %ebx
  801c10:	5e                   	pop    %esi
  801c11:	5f                   	pop    %edi
  801c12:	5d                   	pop    %ebp
  801c13:	c3                   	ret    

00801c14 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c14:	55                   	push   %ebp
  801c15:	89 e5                	mov    %esp,%ebp
  801c17:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c1a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c1f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c22:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c28:	8b 52 50             	mov    0x50(%edx),%edx
  801c2b:	39 ca                	cmp    %ecx,%edx
  801c2d:	75 0d                	jne    801c3c <ipc_find_env+0x28>
			return envs[i].env_id;
  801c2f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c32:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c37:	8b 40 48             	mov    0x48(%eax),%eax
  801c3a:	eb 0f                	jmp    801c4b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c3c:	83 c0 01             	add    $0x1,%eax
  801c3f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c44:	75 d9                	jne    801c1f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c46:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c4b:	5d                   	pop    %ebp
  801c4c:	c3                   	ret    

00801c4d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c4d:	55                   	push   %ebp
  801c4e:	89 e5                	mov    %esp,%ebp
  801c50:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c53:	89 d0                	mov    %edx,%eax
  801c55:	c1 e8 16             	shr    $0x16,%eax
  801c58:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c5f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c64:	f6 c1 01             	test   $0x1,%cl
  801c67:	74 1d                	je     801c86 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c69:	c1 ea 0c             	shr    $0xc,%edx
  801c6c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c73:	f6 c2 01             	test   $0x1,%dl
  801c76:	74 0e                	je     801c86 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c78:	c1 ea 0c             	shr    $0xc,%edx
  801c7b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c82:	ef 
  801c83:	0f b7 c0             	movzwl %ax,%eax
}
  801c86:	5d                   	pop    %ebp
  801c87:	c3                   	ret    
  801c88:	66 90                	xchg   %ax,%ax
  801c8a:	66 90                	xchg   %ax,%ax
  801c8c:	66 90                	xchg   %ax,%ax
  801c8e:	66 90                	xchg   %ax,%ax

00801c90 <__udivdi3>:
  801c90:	55                   	push   %ebp
  801c91:	57                   	push   %edi
  801c92:	56                   	push   %esi
  801c93:	53                   	push   %ebx
  801c94:	83 ec 1c             	sub    $0x1c,%esp
  801c97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ca3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ca7:	85 f6                	test   %esi,%esi
  801ca9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cad:	89 ca                	mov    %ecx,%edx
  801caf:	89 f8                	mov    %edi,%eax
  801cb1:	75 3d                	jne    801cf0 <__udivdi3+0x60>
  801cb3:	39 cf                	cmp    %ecx,%edi
  801cb5:	0f 87 c5 00 00 00    	ja     801d80 <__udivdi3+0xf0>
  801cbb:	85 ff                	test   %edi,%edi
  801cbd:	89 fd                	mov    %edi,%ebp
  801cbf:	75 0b                	jne    801ccc <__udivdi3+0x3c>
  801cc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cc6:	31 d2                	xor    %edx,%edx
  801cc8:	f7 f7                	div    %edi
  801cca:	89 c5                	mov    %eax,%ebp
  801ccc:	89 c8                	mov    %ecx,%eax
  801cce:	31 d2                	xor    %edx,%edx
  801cd0:	f7 f5                	div    %ebp
  801cd2:	89 c1                	mov    %eax,%ecx
  801cd4:	89 d8                	mov    %ebx,%eax
  801cd6:	89 cf                	mov    %ecx,%edi
  801cd8:	f7 f5                	div    %ebp
  801cda:	89 c3                	mov    %eax,%ebx
  801cdc:	89 d8                	mov    %ebx,%eax
  801cde:	89 fa                	mov    %edi,%edx
  801ce0:	83 c4 1c             	add    $0x1c,%esp
  801ce3:	5b                   	pop    %ebx
  801ce4:	5e                   	pop    %esi
  801ce5:	5f                   	pop    %edi
  801ce6:	5d                   	pop    %ebp
  801ce7:	c3                   	ret    
  801ce8:	90                   	nop
  801ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	39 ce                	cmp    %ecx,%esi
  801cf2:	77 74                	ja     801d68 <__udivdi3+0xd8>
  801cf4:	0f bd fe             	bsr    %esi,%edi
  801cf7:	83 f7 1f             	xor    $0x1f,%edi
  801cfa:	0f 84 98 00 00 00    	je     801d98 <__udivdi3+0x108>
  801d00:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d05:	89 f9                	mov    %edi,%ecx
  801d07:	89 c5                	mov    %eax,%ebp
  801d09:	29 fb                	sub    %edi,%ebx
  801d0b:	d3 e6                	shl    %cl,%esi
  801d0d:	89 d9                	mov    %ebx,%ecx
  801d0f:	d3 ed                	shr    %cl,%ebp
  801d11:	89 f9                	mov    %edi,%ecx
  801d13:	d3 e0                	shl    %cl,%eax
  801d15:	09 ee                	or     %ebp,%esi
  801d17:	89 d9                	mov    %ebx,%ecx
  801d19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d1d:	89 d5                	mov    %edx,%ebp
  801d1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d23:	d3 ed                	shr    %cl,%ebp
  801d25:	89 f9                	mov    %edi,%ecx
  801d27:	d3 e2                	shl    %cl,%edx
  801d29:	89 d9                	mov    %ebx,%ecx
  801d2b:	d3 e8                	shr    %cl,%eax
  801d2d:	09 c2                	or     %eax,%edx
  801d2f:	89 d0                	mov    %edx,%eax
  801d31:	89 ea                	mov    %ebp,%edx
  801d33:	f7 f6                	div    %esi
  801d35:	89 d5                	mov    %edx,%ebp
  801d37:	89 c3                	mov    %eax,%ebx
  801d39:	f7 64 24 0c          	mull   0xc(%esp)
  801d3d:	39 d5                	cmp    %edx,%ebp
  801d3f:	72 10                	jb     801d51 <__udivdi3+0xc1>
  801d41:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d45:	89 f9                	mov    %edi,%ecx
  801d47:	d3 e6                	shl    %cl,%esi
  801d49:	39 c6                	cmp    %eax,%esi
  801d4b:	73 07                	jae    801d54 <__udivdi3+0xc4>
  801d4d:	39 d5                	cmp    %edx,%ebp
  801d4f:	75 03                	jne    801d54 <__udivdi3+0xc4>
  801d51:	83 eb 01             	sub    $0x1,%ebx
  801d54:	31 ff                	xor    %edi,%edi
  801d56:	89 d8                	mov    %ebx,%eax
  801d58:	89 fa                	mov    %edi,%edx
  801d5a:	83 c4 1c             	add    $0x1c,%esp
  801d5d:	5b                   	pop    %ebx
  801d5e:	5e                   	pop    %esi
  801d5f:	5f                   	pop    %edi
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    
  801d62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d68:	31 ff                	xor    %edi,%edi
  801d6a:	31 db                	xor    %ebx,%ebx
  801d6c:	89 d8                	mov    %ebx,%eax
  801d6e:	89 fa                	mov    %edi,%edx
  801d70:	83 c4 1c             	add    $0x1c,%esp
  801d73:	5b                   	pop    %ebx
  801d74:	5e                   	pop    %esi
  801d75:	5f                   	pop    %edi
  801d76:	5d                   	pop    %ebp
  801d77:	c3                   	ret    
  801d78:	90                   	nop
  801d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d80:	89 d8                	mov    %ebx,%eax
  801d82:	f7 f7                	div    %edi
  801d84:	31 ff                	xor    %edi,%edi
  801d86:	89 c3                	mov    %eax,%ebx
  801d88:	89 d8                	mov    %ebx,%eax
  801d8a:	89 fa                	mov    %edi,%edx
  801d8c:	83 c4 1c             	add    $0x1c,%esp
  801d8f:	5b                   	pop    %ebx
  801d90:	5e                   	pop    %esi
  801d91:	5f                   	pop    %edi
  801d92:	5d                   	pop    %ebp
  801d93:	c3                   	ret    
  801d94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d98:	39 ce                	cmp    %ecx,%esi
  801d9a:	72 0c                	jb     801da8 <__udivdi3+0x118>
  801d9c:	31 db                	xor    %ebx,%ebx
  801d9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801da2:	0f 87 34 ff ff ff    	ja     801cdc <__udivdi3+0x4c>
  801da8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801dad:	e9 2a ff ff ff       	jmp    801cdc <__udivdi3+0x4c>
  801db2:	66 90                	xchg   %ax,%ax
  801db4:	66 90                	xchg   %ax,%ax
  801db6:	66 90                	xchg   %ax,%ax
  801db8:	66 90                	xchg   %ax,%ax
  801dba:	66 90                	xchg   %ax,%ax
  801dbc:	66 90                	xchg   %ax,%ax
  801dbe:	66 90                	xchg   %ax,%ax

00801dc0 <__umoddi3>:
  801dc0:	55                   	push   %ebp
  801dc1:	57                   	push   %edi
  801dc2:	56                   	push   %esi
  801dc3:	53                   	push   %ebx
  801dc4:	83 ec 1c             	sub    $0x1c,%esp
  801dc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801dcb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801dcf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dd7:	85 d2                	test   %edx,%edx
  801dd9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ddd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801de1:	89 f3                	mov    %esi,%ebx
  801de3:	89 3c 24             	mov    %edi,(%esp)
  801de6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dea:	75 1c                	jne    801e08 <__umoddi3+0x48>
  801dec:	39 f7                	cmp    %esi,%edi
  801dee:	76 50                	jbe    801e40 <__umoddi3+0x80>
  801df0:	89 c8                	mov    %ecx,%eax
  801df2:	89 f2                	mov    %esi,%edx
  801df4:	f7 f7                	div    %edi
  801df6:	89 d0                	mov    %edx,%eax
  801df8:	31 d2                	xor    %edx,%edx
  801dfa:	83 c4 1c             	add    $0x1c,%esp
  801dfd:	5b                   	pop    %ebx
  801dfe:	5e                   	pop    %esi
  801dff:	5f                   	pop    %edi
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    
  801e02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e08:	39 f2                	cmp    %esi,%edx
  801e0a:	89 d0                	mov    %edx,%eax
  801e0c:	77 52                	ja     801e60 <__umoddi3+0xa0>
  801e0e:	0f bd ea             	bsr    %edx,%ebp
  801e11:	83 f5 1f             	xor    $0x1f,%ebp
  801e14:	75 5a                	jne    801e70 <__umoddi3+0xb0>
  801e16:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e1a:	0f 82 e0 00 00 00    	jb     801f00 <__umoddi3+0x140>
  801e20:	39 0c 24             	cmp    %ecx,(%esp)
  801e23:	0f 86 d7 00 00 00    	jbe    801f00 <__umoddi3+0x140>
  801e29:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e2d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e31:	83 c4 1c             	add    $0x1c,%esp
  801e34:	5b                   	pop    %ebx
  801e35:	5e                   	pop    %esi
  801e36:	5f                   	pop    %edi
  801e37:	5d                   	pop    %ebp
  801e38:	c3                   	ret    
  801e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e40:	85 ff                	test   %edi,%edi
  801e42:	89 fd                	mov    %edi,%ebp
  801e44:	75 0b                	jne    801e51 <__umoddi3+0x91>
  801e46:	b8 01 00 00 00       	mov    $0x1,%eax
  801e4b:	31 d2                	xor    %edx,%edx
  801e4d:	f7 f7                	div    %edi
  801e4f:	89 c5                	mov    %eax,%ebp
  801e51:	89 f0                	mov    %esi,%eax
  801e53:	31 d2                	xor    %edx,%edx
  801e55:	f7 f5                	div    %ebp
  801e57:	89 c8                	mov    %ecx,%eax
  801e59:	f7 f5                	div    %ebp
  801e5b:	89 d0                	mov    %edx,%eax
  801e5d:	eb 99                	jmp    801df8 <__umoddi3+0x38>
  801e5f:	90                   	nop
  801e60:	89 c8                	mov    %ecx,%eax
  801e62:	89 f2                	mov    %esi,%edx
  801e64:	83 c4 1c             	add    $0x1c,%esp
  801e67:	5b                   	pop    %ebx
  801e68:	5e                   	pop    %esi
  801e69:	5f                   	pop    %edi
  801e6a:	5d                   	pop    %ebp
  801e6b:	c3                   	ret    
  801e6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e70:	8b 34 24             	mov    (%esp),%esi
  801e73:	bf 20 00 00 00       	mov    $0x20,%edi
  801e78:	89 e9                	mov    %ebp,%ecx
  801e7a:	29 ef                	sub    %ebp,%edi
  801e7c:	d3 e0                	shl    %cl,%eax
  801e7e:	89 f9                	mov    %edi,%ecx
  801e80:	89 f2                	mov    %esi,%edx
  801e82:	d3 ea                	shr    %cl,%edx
  801e84:	89 e9                	mov    %ebp,%ecx
  801e86:	09 c2                	or     %eax,%edx
  801e88:	89 d8                	mov    %ebx,%eax
  801e8a:	89 14 24             	mov    %edx,(%esp)
  801e8d:	89 f2                	mov    %esi,%edx
  801e8f:	d3 e2                	shl    %cl,%edx
  801e91:	89 f9                	mov    %edi,%ecx
  801e93:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e97:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e9b:	d3 e8                	shr    %cl,%eax
  801e9d:	89 e9                	mov    %ebp,%ecx
  801e9f:	89 c6                	mov    %eax,%esi
  801ea1:	d3 e3                	shl    %cl,%ebx
  801ea3:	89 f9                	mov    %edi,%ecx
  801ea5:	89 d0                	mov    %edx,%eax
  801ea7:	d3 e8                	shr    %cl,%eax
  801ea9:	89 e9                	mov    %ebp,%ecx
  801eab:	09 d8                	or     %ebx,%eax
  801ead:	89 d3                	mov    %edx,%ebx
  801eaf:	89 f2                	mov    %esi,%edx
  801eb1:	f7 34 24             	divl   (%esp)
  801eb4:	89 d6                	mov    %edx,%esi
  801eb6:	d3 e3                	shl    %cl,%ebx
  801eb8:	f7 64 24 04          	mull   0x4(%esp)
  801ebc:	39 d6                	cmp    %edx,%esi
  801ebe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ec2:	89 d1                	mov    %edx,%ecx
  801ec4:	89 c3                	mov    %eax,%ebx
  801ec6:	72 08                	jb     801ed0 <__umoddi3+0x110>
  801ec8:	75 11                	jne    801edb <__umoddi3+0x11b>
  801eca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801ece:	73 0b                	jae    801edb <__umoddi3+0x11b>
  801ed0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801ed4:	1b 14 24             	sbb    (%esp),%edx
  801ed7:	89 d1                	mov    %edx,%ecx
  801ed9:	89 c3                	mov    %eax,%ebx
  801edb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801edf:	29 da                	sub    %ebx,%edx
  801ee1:	19 ce                	sbb    %ecx,%esi
  801ee3:	89 f9                	mov    %edi,%ecx
  801ee5:	89 f0                	mov    %esi,%eax
  801ee7:	d3 e0                	shl    %cl,%eax
  801ee9:	89 e9                	mov    %ebp,%ecx
  801eeb:	d3 ea                	shr    %cl,%edx
  801eed:	89 e9                	mov    %ebp,%ecx
  801eef:	d3 ee                	shr    %cl,%esi
  801ef1:	09 d0                	or     %edx,%eax
  801ef3:	89 f2                	mov    %esi,%edx
  801ef5:	83 c4 1c             	add    $0x1c,%esp
  801ef8:	5b                   	pop    %ebx
  801ef9:	5e                   	pop    %esi
  801efa:	5f                   	pop    %edi
  801efb:	5d                   	pop    %ebp
  801efc:	c3                   	ret    
  801efd:	8d 76 00             	lea    0x0(%esi),%esi
  801f00:	29 f9                	sub    %edi,%ecx
  801f02:	19 d6                	sbb    %edx,%esi
  801f04:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f0c:	e9 18 ff ff ff       	jmp    801e29 <__umoddi3+0x69>
