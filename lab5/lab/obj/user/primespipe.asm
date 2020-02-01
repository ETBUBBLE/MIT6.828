
obj/user/primespipe.debug：     文件格式 elf32-i386


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
  80002c:	e8 07 02 00 00       	call   800238 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	6a 04                	push   $0x4
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	e8 24 15 00 00       	call   801575 <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	74 20                	je     800079 <primeproc+0x46>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  800059:	83 ec 0c             	sub    $0xc,%esp
  80005c:	85 c0                	test   %eax,%eax
  80005e:	ba 00 00 00 00       	mov    $0x0,%edx
  800063:	0f 4e d0             	cmovle %eax,%edx
  800066:	52                   	push   %edx
  800067:	50                   	push   %eax
  800068:	68 40 23 80 00       	push   $0x802340
  80006d:	6a 15                	push   $0x15
  80006f:	68 6f 23 80 00       	push   $0x80236f
  800074:	e8 1f 02 00 00       	call   800298 <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 81 23 80 00       	push   $0x802381
  800084:	e8 e8 02 00 00       	call   800371 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 58 1b 00 00       	call   801be9 <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 85 23 80 00       	push   $0x802385
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 6f 23 80 00       	push   $0x80236f
  8000a8:	e8 eb 01 00 00       	call   800298 <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 a9 0f 00 00       	call   80105b <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 8e 23 80 00       	push   $0x80238e
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 6f 23 80 00       	push   $0x80236f
  8000c3:	e8 d0 01 00 00       	call   800298 <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 d3 12 00 00       	call   8013a8 <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 c8 12 00 00       	call   8013a8 <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 b2 12 00 00       	call   8013a8 <close>
	wfd = pfd[1];
  8000f6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f9:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000fc:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000ff:	83 ec 04             	sub    $0x4,%esp
  800102:	6a 04                	push   $0x4
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
  800106:	e8 6a 14 00 00       	call   801575 <readn>
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	83 f8 04             	cmp    $0x4,%eax
  800111:	74 24                	je     800137 <primeproc+0x104>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800113:	83 ec 04             	sub    $0x4,%esp
  800116:	85 c0                	test   %eax,%eax
  800118:	ba 00 00 00 00       	mov    $0x0,%edx
  80011d:	0f 4e d0             	cmovle %eax,%edx
  800120:	52                   	push   %edx
  800121:	50                   	push   %eax
  800122:	53                   	push   %ebx
  800123:	ff 75 e0             	pushl  -0x20(%ebp)
  800126:	68 97 23 80 00       	push   $0x802397
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 6f 23 80 00       	push   $0x80236f
  800132:	e8 61 01 00 00       	call   800298 <_panic>
		if (i%p)
  800137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80013a:	99                   	cltd   
  80013b:	f7 7d e0             	idivl  -0x20(%ebp)
  80013e:	85 d2                	test   %edx,%edx
  800140:	74 bd                	je     8000ff <primeproc+0xcc>
			if ((r=write(wfd, &i, 4)) != 4)
  800142:	83 ec 04             	sub    $0x4,%esp
  800145:	6a 04                	push   $0x4
  800147:	56                   	push   %esi
  800148:	57                   	push   %edi
  800149:	e8 70 14 00 00       	call   8015be <write>
  80014e:	83 c4 10             	add    $0x10,%esp
  800151:	83 f8 04             	cmp    $0x4,%eax
  800154:	74 a9                	je     8000ff <primeproc+0xcc>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  800156:	83 ec 08             	sub    $0x8,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
  800160:	0f 4e d0             	cmovle %eax,%edx
  800163:	52                   	push   %edx
  800164:	50                   	push   %eax
  800165:	ff 75 e0             	pushl  -0x20(%ebp)
  800168:	68 b3 23 80 00       	push   $0x8023b3
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 6f 23 80 00       	push   $0x80236f
  800174:	e8 1f 01 00 00       	call   800298 <_panic>

00800179 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	53                   	push   %ebx
  80017d:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800180:	c7 05 00 30 80 00 cd 	movl   $0x8023cd,0x803000
  800187:	23 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 56 1a 00 00       	call   801be9 <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 85 23 80 00       	push   $0x802385
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 6f 23 80 00       	push   $0x80236f
  8001aa:	e8 e9 00 00 00       	call   800298 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 a7 0e 00 00       	call   80105b <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 8e 23 80 00       	push   $0x80238e
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 6f 23 80 00       	push   $0x80236f
  8001c5:	e8 ce 00 00 00       	call   800298 <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 cf 11 00 00       	call   8013a8 <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 b9 11 00 00       	call   8013a8 <close>

	// feed all the integers through
	for (i=2;; i++)
  8001ef:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f6:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001f9:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001fc:	83 ec 04             	sub    $0x4,%esp
  8001ff:	6a 04                	push   $0x4
  800201:	53                   	push   %ebx
  800202:	ff 75 f0             	pushl  -0x10(%ebp)
  800205:	e8 b4 13 00 00       	call   8015be <write>
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	83 f8 04             	cmp    $0x4,%eax
  800210:	74 20                	je     800232 <umain+0xb9>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	85 c0                	test   %eax,%eax
  800217:	ba 00 00 00 00       	mov    $0x0,%edx
  80021c:	0f 4e d0             	cmovle %eax,%edx
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	68 d8 23 80 00       	push   $0x8023d8
  800226:	6a 4a                	push   $0x4a
  800228:	68 6f 23 80 00       	push   $0x80236f
  80022d:	e8 66 00 00 00       	call   800298 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  800232:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  800236:	eb c4                	jmp    8001fc <umain+0x83>

00800238 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800240:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800243:	e8 f2 0a 00 00       	call   800d3a <sys_getenvid>
  800248:	25 ff 03 00 00       	and    $0x3ff,%eax
  80024d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800250:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800255:	a3 04 40 80 00       	mov    %eax,0x804004

    // save the name of the program so that panic() can use it
    if (argc > 0)
  80025a:	85 db                	test   %ebx,%ebx
  80025c:	7e 07                	jle    800265 <libmain+0x2d>
        binaryname = argv[0];
  80025e:	8b 06                	mov    (%esi),%eax
  800260:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	e8 0a ff ff ff       	call   800179 <umain>

    // exit gracefully
    exit();
  80026f:	e8 0a 00 00 00       	call   80027e <exit>
}
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800284:	e8 4a 11 00 00       	call   8013d3 <close_all>
	sys_env_destroy(0);
  800289:	83 ec 0c             	sub    $0xc,%esp
  80028c:	6a 00                	push   $0x0
  80028e:	e8 66 0a 00 00       	call   800cf9 <sys_env_destroy>
}
  800293:	83 c4 10             	add    $0x10,%esp
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80029d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002a0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002a6:	e8 8f 0a 00 00       	call   800d3a <sys_getenvid>
  8002ab:	83 ec 0c             	sub    $0xc,%esp
  8002ae:	ff 75 0c             	pushl  0xc(%ebp)
  8002b1:	ff 75 08             	pushl  0x8(%ebp)
  8002b4:	56                   	push   %esi
  8002b5:	50                   	push   %eax
  8002b6:	68 fc 23 80 00       	push   $0x8023fc
  8002bb:	e8 b1 00 00 00       	call   800371 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c0:	83 c4 18             	add    $0x18,%esp
  8002c3:	53                   	push   %ebx
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	e8 54 00 00 00       	call   800320 <vcprintf>
	cprintf("\n");
  8002cc:	c7 04 24 83 23 80 00 	movl   $0x802383,(%esp)
  8002d3:	e8 99 00 00 00       	call   800371 <cprintf>
  8002d8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002db:	cc                   	int3   
  8002dc:	eb fd                	jmp    8002db <_panic+0x43>

008002de <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	53                   	push   %ebx
  8002e2:	83 ec 04             	sub    $0x4,%esp
  8002e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e8:	8b 13                	mov    (%ebx),%edx
  8002ea:	8d 42 01             	lea    0x1(%edx),%eax
  8002ed:	89 03                	mov    %eax,(%ebx)
  8002ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002fb:	75 1a                	jne    800317 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002fd:	83 ec 08             	sub    $0x8,%esp
  800300:	68 ff 00 00 00       	push   $0xff
  800305:	8d 43 08             	lea    0x8(%ebx),%eax
  800308:	50                   	push   %eax
  800309:	e8 ae 09 00 00       	call   800cbc <sys_cputs>
		b->idx = 0;
  80030e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800314:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800317:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80031b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800329:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800330:	00 00 00 
	b.cnt = 0;
  800333:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80033a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033d:	ff 75 0c             	pushl  0xc(%ebp)
  800340:	ff 75 08             	pushl  0x8(%ebp)
  800343:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800349:	50                   	push   %eax
  80034a:	68 de 02 80 00       	push   $0x8002de
  80034f:	e8 1a 01 00 00       	call   80046e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800354:	83 c4 08             	add    $0x8,%esp
  800357:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80035d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800363:	50                   	push   %eax
  800364:	e8 53 09 00 00       	call   800cbc <sys_cputs>

	return b.cnt;
}
  800369:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800377:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80037a:	50                   	push   %eax
  80037b:	ff 75 08             	pushl  0x8(%ebp)
  80037e:	e8 9d ff ff ff       	call   800320 <vcprintf>
	va_end(ap);

	return cnt;
}
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	57                   	push   %edi
  800389:	56                   	push   %esi
  80038a:	53                   	push   %ebx
  80038b:	83 ec 1c             	sub    $0x1c,%esp
  80038e:	89 c7                	mov    %eax,%edi
  800390:	89 d6                	mov    %edx,%esi
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	8b 55 0c             	mov    0xc(%ebp),%edx
  800398:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80039e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003ac:	39 d3                	cmp    %edx,%ebx
  8003ae:	72 05                	jb     8003b5 <printnum+0x30>
  8003b0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003b3:	77 45                	ja     8003fa <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b5:	83 ec 0c             	sub    $0xc,%esp
  8003b8:	ff 75 18             	pushl  0x18(%ebp)
  8003bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003be:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003c1:	53                   	push   %ebx
  8003c2:	ff 75 10             	pushl  0x10(%ebp)
  8003c5:	83 ec 08             	sub    $0x8,%esp
  8003c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d4:	e8 d7 1c 00 00       	call   8020b0 <__udivdi3>
  8003d9:	83 c4 18             	add    $0x18,%esp
  8003dc:	52                   	push   %edx
  8003dd:	50                   	push   %eax
  8003de:	89 f2                	mov    %esi,%edx
  8003e0:	89 f8                	mov    %edi,%eax
  8003e2:	e8 9e ff ff ff       	call   800385 <printnum>
  8003e7:	83 c4 20             	add    $0x20,%esp
  8003ea:	eb 18                	jmp    800404 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003ec:	83 ec 08             	sub    $0x8,%esp
  8003ef:	56                   	push   %esi
  8003f0:	ff 75 18             	pushl  0x18(%ebp)
  8003f3:	ff d7                	call   *%edi
  8003f5:	83 c4 10             	add    $0x10,%esp
  8003f8:	eb 03                	jmp    8003fd <printnum+0x78>
  8003fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003fd:	83 eb 01             	sub    $0x1,%ebx
  800400:	85 db                	test   %ebx,%ebx
  800402:	7f e8                	jg     8003ec <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	56                   	push   %esi
  800408:	83 ec 04             	sub    $0x4,%esp
  80040b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80040e:	ff 75 e0             	pushl  -0x20(%ebp)
  800411:	ff 75 dc             	pushl  -0x24(%ebp)
  800414:	ff 75 d8             	pushl  -0x28(%ebp)
  800417:	e8 c4 1d 00 00       	call   8021e0 <__umoddi3>
  80041c:	83 c4 14             	add    $0x14,%esp
  80041f:	0f be 80 1f 24 80 00 	movsbl 0x80241f(%eax),%eax
  800426:	50                   	push   %eax
  800427:	ff d7                	call   *%edi
}
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042f:	5b                   	pop    %ebx
  800430:	5e                   	pop    %esi
  800431:	5f                   	pop    %edi
  800432:	5d                   	pop    %ebp
  800433:	c3                   	ret    

00800434 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80043a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80043e:	8b 10                	mov    (%eax),%edx
  800440:	3b 50 04             	cmp    0x4(%eax),%edx
  800443:	73 0a                	jae    80044f <sprintputch+0x1b>
		*b->buf++ = ch;
  800445:	8d 4a 01             	lea    0x1(%edx),%ecx
  800448:	89 08                	mov    %ecx,(%eax)
  80044a:	8b 45 08             	mov    0x8(%ebp),%eax
  80044d:	88 02                	mov    %al,(%edx)
}
  80044f:	5d                   	pop    %ebp
  800450:	c3                   	ret    

00800451 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800451:	55                   	push   %ebp
  800452:	89 e5                	mov    %esp,%ebp
  800454:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800457:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80045a:	50                   	push   %eax
  80045b:	ff 75 10             	pushl  0x10(%ebp)
  80045e:	ff 75 0c             	pushl  0xc(%ebp)
  800461:	ff 75 08             	pushl  0x8(%ebp)
  800464:	e8 05 00 00 00       	call   80046e <vprintfmt>
	va_end(ap);
}
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	c9                   	leave  
  80046d:	c3                   	ret    

0080046e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	57                   	push   %edi
  800472:	56                   	push   %esi
  800473:	53                   	push   %ebx
  800474:	83 ec 2c             	sub    $0x2c,%esp
  800477:	8b 75 08             	mov    0x8(%ebp),%esi
  80047a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80047d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800480:	eb 12                	jmp    800494 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800482:	85 c0                	test   %eax,%eax
  800484:	0f 84 42 04 00 00    	je     8008cc <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80048a:	83 ec 08             	sub    $0x8,%esp
  80048d:	53                   	push   %ebx
  80048e:	50                   	push   %eax
  80048f:	ff d6                	call   *%esi
  800491:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800494:	83 c7 01             	add    $0x1,%edi
  800497:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80049b:	83 f8 25             	cmp    $0x25,%eax
  80049e:	75 e2                	jne    800482 <vprintfmt+0x14>
  8004a0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004a4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004ab:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004b2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004be:	eb 07                	jmp    8004c7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004c3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8d 47 01             	lea    0x1(%edi),%eax
  8004ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004cd:	0f b6 07             	movzbl (%edi),%eax
  8004d0:	0f b6 d0             	movzbl %al,%edx
  8004d3:	83 e8 23             	sub    $0x23,%eax
  8004d6:	3c 55                	cmp    $0x55,%al
  8004d8:	0f 87 d3 03 00 00    	ja     8008b1 <vprintfmt+0x443>
  8004de:	0f b6 c0             	movzbl %al,%eax
  8004e1:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  8004e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004eb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004ef:	eb d6                	jmp    8004c7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004fc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004ff:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800503:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800506:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800509:	83 f9 09             	cmp    $0x9,%ecx
  80050c:	77 3f                	ja     80054d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80050e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800511:	eb e9                	jmp    8004fc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8b 00                	mov    (%eax),%eax
  800518:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 40 04             	lea    0x4(%eax),%eax
  800521:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800524:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800527:	eb 2a                	jmp    800553 <vprintfmt+0xe5>
  800529:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80052c:	85 c0                	test   %eax,%eax
  80052e:	ba 00 00 00 00       	mov    $0x0,%edx
  800533:	0f 49 d0             	cmovns %eax,%edx
  800536:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800539:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80053c:	eb 89                	jmp    8004c7 <vprintfmt+0x59>
  80053e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800541:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800548:	e9 7a ff ff ff       	jmp    8004c7 <vprintfmt+0x59>
  80054d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800550:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800553:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800557:	0f 89 6a ff ff ff    	jns    8004c7 <vprintfmt+0x59>
				width = precision, precision = -1;
  80055d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800560:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800563:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80056a:	e9 58 ff ff ff       	jmp    8004c7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80056f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800572:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800575:	e9 4d ff ff ff       	jmp    8004c7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8d 78 04             	lea    0x4(%eax),%edi
  800580:	83 ec 08             	sub    $0x8,%esp
  800583:	53                   	push   %ebx
  800584:	ff 30                	pushl  (%eax)
  800586:	ff d6                	call   *%esi
			break;
  800588:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80058b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800591:	e9 fe fe ff ff       	jmp    800494 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8d 78 04             	lea    0x4(%eax),%edi
  80059c:	8b 00                	mov    (%eax),%eax
  80059e:	99                   	cltd   
  80059f:	31 d0                	xor    %edx,%eax
  8005a1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005a3:	83 f8 0f             	cmp    $0xf,%eax
  8005a6:	7f 0b                	jg     8005b3 <vprintfmt+0x145>
  8005a8:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  8005af:	85 d2                	test   %edx,%edx
  8005b1:	75 1b                	jne    8005ce <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8005b3:	50                   	push   %eax
  8005b4:	68 37 24 80 00       	push   $0x802437
  8005b9:	53                   	push   %ebx
  8005ba:	56                   	push   %esi
  8005bb:	e8 91 fe ff ff       	call   800451 <printfmt>
  8005c0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005c3:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005c9:	e9 c6 fe ff ff       	jmp    800494 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005ce:	52                   	push   %edx
  8005cf:	68 99 28 80 00       	push   $0x802899
  8005d4:	53                   	push   %ebx
  8005d5:	56                   	push   %esi
  8005d6:	e8 76 fe ff ff       	call   800451 <printfmt>
  8005db:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005de:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e4:	e9 ab fe ff ff       	jmp    800494 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	83 c0 04             	add    $0x4,%eax
  8005ef:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005f7:	85 ff                	test   %edi,%edi
  8005f9:	b8 30 24 80 00       	mov    $0x802430,%eax
  8005fe:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800601:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800605:	0f 8e 94 00 00 00    	jle    80069f <vprintfmt+0x231>
  80060b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80060f:	0f 84 98 00 00 00    	je     8006ad <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800615:	83 ec 08             	sub    $0x8,%esp
  800618:	ff 75 d0             	pushl  -0x30(%ebp)
  80061b:	57                   	push   %edi
  80061c:	e8 33 03 00 00       	call   800954 <strnlen>
  800621:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800624:	29 c1                	sub    %eax,%ecx
  800626:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800629:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80062c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800630:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800633:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800636:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800638:	eb 0f                	jmp    800649 <vprintfmt+0x1db>
					putch(padc, putdat);
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	53                   	push   %ebx
  80063e:	ff 75 e0             	pushl  -0x20(%ebp)
  800641:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800643:	83 ef 01             	sub    $0x1,%edi
  800646:	83 c4 10             	add    $0x10,%esp
  800649:	85 ff                	test   %edi,%edi
  80064b:	7f ed                	jg     80063a <vprintfmt+0x1cc>
  80064d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800650:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800653:	85 c9                	test   %ecx,%ecx
  800655:	b8 00 00 00 00       	mov    $0x0,%eax
  80065a:	0f 49 c1             	cmovns %ecx,%eax
  80065d:	29 c1                	sub    %eax,%ecx
  80065f:	89 75 08             	mov    %esi,0x8(%ebp)
  800662:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800665:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800668:	89 cb                	mov    %ecx,%ebx
  80066a:	eb 4d                	jmp    8006b9 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80066c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800670:	74 1b                	je     80068d <vprintfmt+0x21f>
  800672:	0f be c0             	movsbl %al,%eax
  800675:	83 e8 20             	sub    $0x20,%eax
  800678:	83 f8 5e             	cmp    $0x5e,%eax
  80067b:	76 10                	jbe    80068d <vprintfmt+0x21f>
					putch('?', putdat);
  80067d:	83 ec 08             	sub    $0x8,%esp
  800680:	ff 75 0c             	pushl  0xc(%ebp)
  800683:	6a 3f                	push   $0x3f
  800685:	ff 55 08             	call   *0x8(%ebp)
  800688:	83 c4 10             	add    $0x10,%esp
  80068b:	eb 0d                	jmp    80069a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	ff 75 0c             	pushl  0xc(%ebp)
  800693:	52                   	push   %edx
  800694:	ff 55 08             	call   *0x8(%ebp)
  800697:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069a:	83 eb 01             	sub    $0x1,%ebx
  80069d:	eb 1a                	jmp    8006b9 <vprintfmt+0x24b>
  80069f:	89 75 08             	mov    %esi,0x8(%ebp)
  8006a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006a8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006ab:	eb 0c                	jmp    8006b9 <vprintfmt+0x24b>
  8006ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006b6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006b9:	83 c7 01             	add    $0x1,%edi
  8006bc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006c0:	0f be d0             	movsbl %al,%edx
  8006c3:	85 d2                	test   %edx,%edx
  8006c5:	74 23                	je     8006ea <vprintfmt+0x27c>
  8006c7:	85 f6                	test   %esi,%esi
  8006c9:	78 a1                	js     80066c <vprintfmt+0x1fe>
  8006cb:	83 ee 01             	sub    $0x1,%esi
  8006ce:	79 9c                	jns    80066c <vprintfmt+0x1fe>
  8006d0:	89 df                	mov    %ebx,%edi
  8006d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d8:	eb 18                	jmp    8006f2 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006da:	83 ec 08             	sub    $0x8,%esp
  8006dd:	53                   	push   %ebx
  8006de:	6a 20                	push   $0x20
  8006e0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e2:	83 ef 01             	sub    $0x1,%edi
  8006e5:	83 c4 10             	add    $0x10,%esp
  8006e8:	eb 08                	jmp    8006f2 <vprintfmt+0x284>
  8006ea:	89 df                	mov    %ebx,%edi
  8006ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f2:	85 ff                	test   %edi,%edi
  8006f4:	7f e4                	jg     8006da <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006f6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006f9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ff:	e9 90 fd ff ff       	jmp    800494 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800704:	83 f9 01             	cmp    $0x1,%ecx
  800707:	7e 19                	jle    800722 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800709:	8b 45 14             	mov    0x14(%ebp),%eax
  80070c:	8b 50 04             	mov    0x4(%eax),%edx
  80070f:	8b 00                	mov    (%eax),%eax
  800711:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800714:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800717:	8b 45 14             	mov    0x14(%ebp),%eax
  80071a:	8d 40 08             	lea    0x8(%eax),%eax
  80071d:	89 45 14             	mov    %eax,0x14(%ebp)
  800720:	eb 38                	jmp    80075a <vprintfmt+0x2ec>
	else if (lflag)
  800722:	85 c9                	test   %ecx,%ecx
  800724:	74 1b                	je     800741 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8b 00                	mov    (%eax),%eax
  80072b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80072e:	89 c1                	mov    %eax,%ecx
  800730:	c1 f9 1f             	sar    $0x1f,%ecx
  800733:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800736:	8b 45 14             	mov    0x14(%ebp),%eax
  800739:	8d 40 04             	lea    0x4(%eax),%eax
  80073c:	89 45 14             	mov    %eax,0x14(%ebp)
  80073f:	eb 19                	jmp    80075a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800741:	8b 45 14             	mov    0x14(%ebp),%eax
  800744:	8b 00                	mov    (%eax),%eax
  800746:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800749:	89 c1                	mov    %eax,%ecx
  80074b:	c1 f9 1f             	sar    $0x1f,%ecx
  80074e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800751:	8b 45 14             	mov    0x14(%ebp),%eax
  800754:	8d 40 04             	lea    0x4(%eax),%eax
  800757:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80075a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80075d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800760:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800765:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800769:	0f 89 0e 01 00 00    	jns    80087d <vprintfmt+0x40f>
				putch('-', putdat);
  80076f:	83 ec 08             	sub    $0x8,%esp
  800772:	53                   	push   %ebx
  800773:	6a 2d                	push   $0x2d
  800775:	ff d6                	call   *%esi
				num = -(long long) num;
  800777:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80077a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80077d:	f7 da                	neg    %edx
  80077f:	83 d1 00             	adc    $0x0,%ecx
  800782:	f7 d9                	neg    %ecx
  800784:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800787:	b8 0a 00 00 00       	mov    $0xa,%eax
  80078c:	e9 ec 00 00 00       	jmp    80087d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800791:	83 f9 01             	cmp    $0x1,%ecx
  800794:	7e 18                	jle    8007ae <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800796:	8b 45 14             	mov    0x14(%ebp),%eax
  800799:	8b 10                	mov    (%eax),%edx
  80079b:	8b 48 04             	mov    0x4(%eax),%ecx
  80079e:	8d 40 08             	lea    0x8(%eax),%eax
  8007a1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007a4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007a9:	e9 cf 00 00 00       	jmp    80087d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007ae:	85 c9                	test   %ecx,%ecx
  8007b0:	74 1a                	je     8007cc <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	8b 10                	mov    (%eax),%edx
  8007b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007bc:	8d 40 04             	lea    0x4(%eax),%eax
  8007bf:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007c7:	e9 b1 00 00 00       	jmp    80087d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8007cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cf:	8b 10                	mov    (%eax),%edx
  8007d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d6:	8d 40 04             	lea    0x4(%eax),%eax
  8007d9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e1:	e9 97 00 00 00       	jmp    80087d <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8007e6:	83 ec 08             	sub    $0x8,%esp
  8007e9:	53                   	push   %ebx
  8007ea:	6a 58                	push   $0x58
  8007ec:	ff d6                	call   *%esi
			putch('X', putdat);
  8007ee:	83 c4 08             	add    $0x8,%esp
  8007f1:	53                   	push   %ebx
  8007f2:	6a 58                	push   $0x58
  8007f4:	ff d6                	call   *%esi
			putch('X', putdat);
  8007f6:	83 c4 08             	add    $0x8,%esp
  8007f9:	53                   	push   %ebx
  8007fa:	6a 58                	push   $0x58
  8007fc:	ff d6                	call   *%esi
			break;
  8007fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800801:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800804:	e9 8b fc ff ff       	jmp    800494 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800809:	83 ec 08             	sub    $0x8,%esp
  80080c:	53                   	push   %ebx
  80080d:	6a 30                	push   $0x30
  80080f:	ff d6                	call   *%esi
			putch('x', putdat);
  800811:	83 c4 08             	add    $0x8,%esp
  800814:	53                   	push   %ebx
  800815:	6a 78                	push   $0x78
  800817:	ff d6                	call   *%esi
			num = (unsigned long long)
  800819:	8b 45 14             	mov    0x14(%ebp),%eax
  80081c:	8b 10                	mov    (%eax),%edx
  80081e:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800823:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800826:	8d 40 04             	lea    0x4(%eax),%eax
  800829:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80082c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800831:	eb 4a                	jmp    80087d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800833:	83 f9 01             	cmp    $0x1,%ecx
  800836:	7e 15                	jle    80084d <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800838:	8b 45 14             	mov    0x14(%ebp),%eax
  80083b:	8b 10                	mov    (%eax),%edx
  80083d:	8b 48 04             	mov    0x4(%eax),%ecx
  800840:	8d 40 08             	lea    0x8(%eax),%eax
  800843:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800846:	b8 10 00 00 00       	mov    $0x10,%eax
  80084b:	eb 30                	jmp    80087d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80084d:	85 c9                	test   %ecx,%ecx
  80084f:	74 17                	je     800868 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800851:	8b 45 14             	mov    0x14(%ebp),%eax
  800854:	8b 10                	mov    (%eax),%edx
  800856:	b9 00 00 00 00       	mov    $0x0,%ecx
  80085b:	8d 40 04             	lea    0x4(%eax),%eax
  80085e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800861:	b8 10 00 00 00       	mov    $0x10,%eax
  800866:	eb 15                	jmp    80087d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800868:	8b 45 14             	mov    0x14(%ebp),%eax
  80086b:	8b 10                	mov    (%eax),%edx
  80086d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800872:	8d 40 04             	lea    0x4(%eax),%eax
  800875:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800878:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80087d:	83 ec 0c             	sub    $0xc,%esp
  800880:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800884:	57                   	push   %edi
  800885:	ff 75 e0             	pushl  -0x20(%ebp)
  800888:	50                   	push   %eax
  800889:	51                   	push   %ecx
  80088a:	52                   	push   %edx
  80088b:	89 da                	mov    %ebx,%edx
  80088d:	89 f0                	mov    %esi,%eax
  80088f:	e8 f1 fa ff ff       	call   800385 <printnum>
			break;
  800894:	83 c4 20             	add    $0x20,%esp
  800897:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80089a:	e9 f5 fb ff ff       	jmp    800494 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80089f:	83 ec 08             	sub    $0x8,%esp
  8008a2:	53                   	push   %ebx
  8008a3:	52                   	push   %edx
  8008a4:	ff d6                	call   *%esi
			break;
  8008a6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008ac:	e9 e3 fb ff ff       	jmp    800494 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008b1:	83 ec 08             	sub    $0x8,%esp
  8008b4:	53                   	push   %ebx
  8008b5:	6a 25                	push   $0x25
  8008b7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b9:	83 c4 10             	add    $0x10,%esp
  8008bc:	eb 03                	jmp    8008c1 <vprintfmt+0x453>
  8008be:	83 ef 01             	sub    $0x1,%edi
  8008c1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008c5:	75 f7                	jne    8008be <vprintfmt+0x450>
  8008c7:	e9 c8 fb ff ff       	jmp    800494 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008cf:	5b                   	pop    %ebx
  8008d0:	5e                   	pop    %esi
  8008d1:	5f                   	pop    %edi
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	83 ec 18             	sub    $0x18,%esp
  8008da:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008e3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008e7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008f1:	85 c0                	test   %eax,%eax
  8008f3:	74 26                	je     80091b <vsnprintf+0x47>
  8008f5:	85 d2                	test   %edx,%edx
  8008f7:	7e 22                	jle    80091b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f9:	ff 75 14             	pushl  0x14(%ebp)
  8008fc:	ff 75 10             	pushl  0x10(%ebp)
  8008ff:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800902:	50                   	push   %eax
  800903:	68 34 04 80 00       	push   $0x800434
  800908:	e8 61 fb ff ff       	call   80046e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80090d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800910:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800913:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800916:	83 c4 10             	add    $0x10,%esp
  800919:	eb 05                	jmp    800920 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80091b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800920:	c9                   	leave  
  800921:	c3                   	ret    

00800922 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800928:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80092b:	50                   	push   %eax
  80092c:	ff 75 10             	pushl  0x10(%ebp)
  80092f:	ff 75 0c             	pushl  0xc(%ebp)
  800932:	ff 75 08             	pushl  0x8(%ebp)
  800935:	e8 9a ff ff ff       	call   8008d4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80093a:	c9                   	leave  
  80093b:	c3                   	ret    

0080093c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800942:	b8 00 00 00 00       	mov    $0x0,%eax
  800947:	eb 03                	jmp    80094c <strlen+0x10>
		n++;
  800949:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80094c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800950:	75 f7                	jne    800949 <strlen+0xd>
		n++;
	return n;
}
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80095d:	ba 00 00 00 00       	mov    $0x0,%edx
  800962:	eb 03                	jmp    800967 <strnlen+0x13>
		n++;
  800964:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800967:	39 c2                	cmp    %eax,%edx
  800969:	74 08                	je     800973 <strnlen+0x1f>
  80096b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80096f:	75 f3                	jne    800964 <strnlen+0x10>
  800971:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	53                   	push   %ebx
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80097f:	89 c2                	mov    %eax,%edx
  800981:	83 c2 01             	add    $0x1,%edx
  800984:	83 c1 01             	add    $0x1,%ecx
  800987:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80098b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80098e:	84 db                	test   %bl,%bl
  800990:	75 ef                	jne    800981 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800992:	5b                   	pop    %ebx
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	53                   	push   %ebx
  800999:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80099c:	53                   	push   %ebx
  80099d:	e8 9a ff ff ff       	call   80093c <strlen>
  8009a2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009a5:	ff 75 0c             	pushl  0xc(%ebp)
  8009a8:	01 d8                	add    %ebx,%eax
  8009aa:	50                   	push   %eax
  8009ab:	e8 c5 ff ff ff       	call   800975 <strcpy>
	return dst;
}
  8009b0:	89 d8                	mov    %ebx,%eax
  8009b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b5:	c9                   	leave  
  8009b6:	c3                   	ret    

008009b7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	56                   	push   %esi
  8009bb:	53                   	push   %ebx
  8009bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8009bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c2:	89 f3                	mov    %esi,%ebx
  8009c4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c7:	89 f2                	mov    %esi,%edx
  8009c9:	eb 0f                	jmp    8009da <strncpy+0x23>
		*dst++ = *src;
  8009cb:	83 c2 01             	add    $0x1,%edx
  8009ce:	0f b6 01             	movzbl (%ecx),%eax
  8009d1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009d4:	80 39 01             	cmpb   $0x1,(%ecx)
  8009d7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009da:	39 da                	cmp    %ebx,%edx
  8009dc:	75 ed                	jne    8009cb <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009de:	89 f0                	mov    %esi,%eax
  8009e0:	5b                   	pop    %ebx
  8009e1:	5e                   	pop    %esi
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
  8009e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ef:	8b 55 10             	mov    0x10(%ebp),%edx
  8009f2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009f4:	85 d2                	test   %edx,%edx
  8009f6:	74 21                	je     800a19 <strlcpy+0x35>
  8009f8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009fc:	89 f2                	mov    %esi,%edx
  8009fe:	eb 09                	jmp    800a09 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a00:	83 c2 01             	add    $0x1,%edx
  800a03:	83 c1 01             	add    $0x1,%ecx
  800a06:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a09:	39 c2                	cmp    %eax,%edx
  800a0b:	74 09                	je     800a16 <strlcpy+0x32>
  800a0d:	0f b6 19             	movzbl (%ecx),%ebx
  800a10:	84 db                	test   %bl,%bl
  800a12:	75 ec                	jne    800a00 <strlcpy+0x1c>
  800a14:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a16:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a19:	29 f0                	sub    %esi,%eax
}
  800a1b:	5b                   	pop    %ebx
  800a1c:	5e                   	pop    %esi
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a25:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a28:	eb 06                	jmp    800a30 <strcmp+0x11>
		p++, q++;
  800a2a:	83 c1 01             	add    $0x1,%ecx
  800a2d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a30:	0f b6 01             	movzbl (%ecx),%eax
  800a33:	84 c0                	test   %al,%al
  800a35:	74 04                	je     800a3b <strcmp+0x1c>
  800a37:	3a 02                	cmp    (%edx),%al
  800a39:	74 ef                	je     800a2a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a3b:	0f b6 c0             	movzbl %al,%eax
  800a3e:	0f b6 12             	movzbl (%edx),%edx
  800a41:	29 d0                	sub    %edx,%eax
}
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	53                   	push   %ebx
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4f:	89 c3                	mov    %eax,%ebx
  800a51:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a54:	eb 06                	jmp    800a5c <strncmp+0x17>
		n--, p++, q++;
  800a56:	83 c0 01             	add    $0x1,%eax
  800a59:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a5c:	39 d8                	cmp    %ebx,%eax
  800a5e:	74 15                	je     800a75 <strncmp+0x30>
  800a60:	0f b6 08             	movzbl (%eax),%ecx
  800a63:	84 c9                	test   %cl,%cl
  800a65:	74 04                	je     800a6b <strncmp+0x26>
  800a67:	3a 0a                	cmp    (%edx),%cl
  800a69:	74 eb                	je     800a56 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a6b:	0f b6 00             	movzbl (%eax),%eax
  800a6e:	0f b6 12             	movzbl (%edx),%edx
  800a71:	29 d0                	sub    %edx,%eax
  800a73:	eb 05                	jmp    800a7a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a75:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a7a:	5b                   	pop    %ebx
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a87:	eb 07                	jmp    800a90 <strchr+0x13>
		if (*s == c)
  800a89:	38 ca                	cmp    %cl,%dl
  800a8b:	74 0f                	je     800a9c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a8d:	83 c0 01             	add    $0x1,%eax
  800a90:	0f b6 10             	movzbl (%eax),%edx
  800a93:	84 d2                	test   %dl,%dl
  800a95:	75 f2                	jne    800a89 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa8:	eb 03                	jmp    800aad <strfind+0xf>
  800aaa:	83 c0 01             	add    $0x1,%eax
  800aad:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ab0:	38 ca                	cmp    %cl,%dl
  800ab2:	74 04                	je     800ab8 <strfind+0x1a>
  800ab4:	84 d2                	test   %dl,%dl
  800ab6:	75 f2                	jne    800aaa <strfind+0xc>
			break;
	return (char *) s;
}
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
  800ac0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ac3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ac6:	85 c9                	test   %ecx,%ecx
  800ac8:	74 36                	je     800b00 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aca:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ad0:	75 28                	jne    800afa <memset+0x40>
  800ad2:	f6 c1 03             	test   $0x3,%cl
  800ad5:	75 23                	jne    800afa <memset+0x40>
		c &= 0xFF;
  800ad7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800adb:	89 d3                	mov    %edx,%ebx
  800add:	c1 e3 08             	shl    $0x8,%ebx
  800ae0:	89 d6                	mov    %edx,%esi
  800ae2:	c1 e6 18             	shl    $0x18,%esi
  800ae5:	89 d0                	mov    %edx,%eax
  800ae7:	c1 e0 10             	shl    $0x10,%eax
  800aea:	09 f0                	or     %esi,%eax
  800aec:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800aee:	89 d8                	mov    %ebx,%eax
  800af0:	09 d0                	or     %edx,%eax
  800af2:	c1 e9 02             	shr    $0x2,%ecx
  800af5:	fc                   	cld    
  800af6:	f3 ab                	rep stos %eax,%es:(%edi)
  800af8:	eb 06                	jmp    800b00 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800afa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afd:	fc                   	cld    
  800afe:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b00:	89 f8                	mov    %edi,%eax
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	57                   	push   %edi
  800b0b:	56                   	push   %esi
  800b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b12:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b15:	39 c6                	cmp    %eax,%esi
  800b17:	73 35                	jae    800b4e <memmove+0x47>
  800b19:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b1c:	39 d0                	cmp    %edx,%eax
  800b1e:	73 2e                	jae    800b4e <memmove+0x47>
		s += n;
		d += n;
  800b20:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b23:	89 d6                	mov    %edx,%esi
  800b25:	09 fe                	or     %edi,%esi
  800b27:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b2d:	75 13                	jne    800b42 <memmove+0x3b>
  800b2f:	f6 c1 03             	test   $0x3,%cl
  800b32:	75 0e                	jne    800b42 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b34:	83 ef 04             	sub    $0x4,%edi
  800b37:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b3a:	c1 e9 02             	shr    $0x2,%ecx
  800b3d:	fd                   	std    
  800b3e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b40:	eb 09                	jmp    800b4b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b42:	83 ef 01             	sub    $0x1,%edi
  800b45:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b48:	fd                   	std    
  800b49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b4b:	fc                   	cld    
  800b4c:	eb 1d                	jmp    800b6b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4e:	89 f2                	mov    %esi,%edx
  800b50:	09 c2                	or     %eax,%edx
  800b52:	f6 c2 03             	test   $0x3,%dl
  800b55:	75 0f                	jne    800b66 <memmove+0x5f>
  800b57:	f6 c1 03             	test   $0x3,%cl
  800b5a:	75 0a                	jne    800b66 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b5c:	c1 e9 02             	shr    $0x2,%ecx
  800b5f:	89 c7                	mov    %eax,%edi
  800b61:	fc                   	cld    
  800b62:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b64:	eb 05                	jmp    800b6b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b66:	89 c7                	mov    %eax,%edi
  800b68:	fc                   	cld    
  800b69:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b6b:	5e                   	pop    %esi
  800b6c:	5f                   	pop    %edi
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    

00800b6f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b72:	ff 75 10             	pushl  0x10(%ebp)
  800b75:	ff 75 0c             	pushl  0xc(%ebp)
  800b78:	ff 75 08             	pushl  0x8(%ebp)
  800b7b:	e8 87 ff ff ff       	call   800b07 <memmove>
}
  800b80:	c9                   	leave  
  800b81:	c3                   	ret    

00800b82 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
  800b87:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8d:	89 c6                	mov    %eax,%esi
  800b8f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b92:	eb 1a                	jmp    800bae <memcmp+0x2c>
		if (*s1 != *s2)
  800b94:	0f b6 08             	movzbl (%eax),%ecx
  800b97:	0f b6 1a             	movzbl (%edx),%ebx
  800b9a:	38 d9                	cmp    %bl,%cl
  800b9c:	74 0a                	je     800ba8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b9e:	0f b6 c1             	movzbl %cl,%eax
  800ba1:	0f b6 db             	movzbl %bl,%ebx
  800ba4:	29 d8                	sub    %ebx,%eax
  800ba6:	eb 0f                	jmp    800bb7 <memcmp+0x35>
		s1++, s2++;
  800ba8:	83 c0 01             	add    $0x1,%eax
  800bab:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bae:	39 f0                	cmp    %esi,%eax
  800bb0:	75 e2                	jne    800b94 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	53                   	push   %ebx
  800bbf:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bc2:	89 c1                	mov    %eax,%ecx
  800bc4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bcb:	eb 0a                	jmp    800bd7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bcd:	0f b6 10             	movzbl (%eax),%edx
  800bd0:	39 da                	cmp    %ebx,%edx
  800bd2:	74 07                	je     800bdb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd4:	83 c0 01             	add    $0x1,%eax
  800bd7:	39 c8                	cmp    %ecx,%eax
  800bd9:	72 f2                	jb     800bcd <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bdb:	5b                   	pop    %ebx
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bea:	eb 03                	jmp    800bef <strtol+0x11>
		s++;
  800bec:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bef:	0f b6 01             	movzbl (%ecx),%eax
  800bf2:	3c 20                	cmp    $0x20,%al
  800bf4:	74 f6                	je     800bec <strtol+0xe>
  800bf6:	3c 09                	cmp    $0x9,%al
  800bf8:	74 f2                	je     800bec <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bfa:	3c 2b                	cmp    $0x2b,%al
  800bfc:	75 0a                	jne    800c08 <strtol+0x2a>
		s++;
  800bfe:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c01:	bf 00 00 00 00       	mov    $0x0,%edi
  800c06:	eb 11                	jmp    800c19 <strtol+0x3b>
  800c08:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c0d:	3c 2d                	cmp    $0x2d,%al
  800c0f:	75 08                	jne    800c19 <strtol+0x3b>
		s++, neg = 1;
  800c11:	83 c1 01             	add    $0x1,%ecx
  800c14:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c19:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c1f:	75 15                	jne    800c36 <strtol+0x58>
  800c21:	80 39 30             	cmpb   $0x30,(%ecx)
  800c24:	75 10                	jne    800c36 <strtol+0x58>
  800c26:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c2a:	75 7c                	jne    800ca8 <strtol+0xca>
		s += 2, base = 16;
  800c2c:	83 c1 02             	add    $0x2,%ecx
  800c2f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c34:	eb 16                	jmp    800c4c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c36:	85 db                	test   %ebx,%ebx
  800c38:	75 12                	jne    800c4c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c3a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c3f:	80 39 30             	cmpb   $0x30,(%ecx)
  800c42:	75 08                	jne    800c4c <strtol+0x6e>
		s++, base = 8;
  800c44:	83 c1 01             	add    $0x1,%ecx
  800c47:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c51:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c54:	0f b6 11             	movzbl (%ecx),%edx
  800c57:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c5a:	89 f3                	mov    %esi,%ebx
  800c5c:	80 fb 09             	cmp    $0x9,%bl
  800c5f:	77 08                	ja     800c69 <strtol+0x8b>
			dig = *s - '0';
  800c61:	0f be d2             	movsbl %dl,%edx
  800c64:	83 ea 30             	sub    $0x30,%edx
  800c67:	eb 22                	jmp    800c8b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c69:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c6c:	89 f3                	mov    %esi,%ebx
  800c6e:	80 fb 19             	cmp    $0x19,%bl
  800c71:	77 08                	ja     800c7b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c73:	0f be d2             	movsbl %dl,%edx
  800c76:	83 ea 57             	sub    $0x57,%edx
  800c79:	eb 10                	jmp    800c8b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c7b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c7e:	89 f3                	mov    %esi,%ebx
  800c80:	80 fb 19             	cmp    $0x19,%bl
  800c83:	77 16                	ja     800c9b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c85:	0f be d2             	movsbl %dl,%edx
  800c88:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c8b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c8e:	7d 0b                	jge    800c9b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c90:	83 c1 01             	add    $0x1,%ecx
  800c93:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c97:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c99:	eb b9                	jmp    800c54 <strtol+0x76>

	if (endptr)
  800c9b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c9f:	74 0d                	je     800cae <strtol+0xd0>
		*endptr = (char *) s;
  800ca1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca4:	89 0e                	mov    %ecx,(%esi)
  800ca6:	eb 06                	jmp    800cae <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca8:	85 db                	test   %ebx,%ebx
  800caa:	74 98                	je     800c44 <strtol+0x66>
  800cac:	eb 9e                	jmp    800c4c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cae:	89 c2                	mov    %eax,%edx
  800cb0:	f7 da                	neg    %edx
  800cb2:	85 ff                	test   %edi,%edi
  800cb4:	0f 45 c2             	cmovne %edx,%eax
}
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccd:	89 c3                	mov    %eax,%ebx
  800ccf:	89 c7                	mov    %eax,%edi
  800cd1:	89 c6                	mov    %eax,%esi
  800cd3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_cgetc>:

int
sys_cgetc(void)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce5:	b8 01 00 00 00       	mov    $0x1,%eax
  800cea:	89 d1                	mov    %edx,%ecx
  800cec:	89 d3                	mov    %edx,%ebx
  800cee:	89 d7                	mov    %edx,%edi
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800d02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d07:	b8 03 00 00 00       	mov    $0x3,%eax
  800d0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0f:	89 cb                	mov    %ecx,%ebx
  800d11:	89 cf                	mov    %ecx,%edi
  800d13:	89 ce                	mov    %ecx,%esi
  800d15:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d17:	85 c0                	test   %eax,%eax
  800d19:	7e 17                	jle    800d32 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1b:	83 ec 0c             	sub    $0xc,%esp
  800d1e:	50                   	push   %eax
  800d1f:	6a 03                	push   $0x3
  800d21:	68 1f 27 80 00       	push   $0x80271f
  800d26:	6a 23                	push   $0x23
  800d28:	68 3c 27 80 00       	push   $0x80273c
  800d2d:	e8 66 f5 ff ff       	call   800298 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d40:	ba 00 00 00 00       	mov    $0x0,%edx
  800d45:	b8 02 00 00 00       	mov    $0x2,%eax
  800d4a:	89 d1                	mov    %edx,%ecx
  800d4c:	89 d3                	mov    %edx,%ebx
  800d4e:	89 d7                	mov    %edx,%edi
  800d50:	89 d6                	mov    %edx,%esi
  800d52:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <sys_yield>:

void
sys_yield(void)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d64:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d69:	89 d1                	mov    %edx,%ecx
  800d6b:	89 d3                	mov    %edx,%ebx
  800d6d:	89 d7                	mov    %edx,%edi
  800d6f:	89 d6                	mov    %edx,%esi
  800d71:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800d81:	be 00 00 00 00       	mov    $0x0,%esi
  800d86:	b8 04 00 00 00       	mov    $0x4,%eax
  800d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d94:	89 f7                	mov    %esi,%edi
  800d96:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	7e 17                	jle    800db3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9c:	83 ec 0c             	sub    $0xc,%esp
  800d9f:	50                   	push   %eax
  800da0:	6a 04                	push   $0x4
  800da2:	68 1f 27 80 00       	push   $0x80271f
  800da7:	6a 23                	push   $0x23
  800da9:	68 3c 27 80 00       	push   $0x80273c
  800dae:	e8 e5 f4 ff ff       	call   800298 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800db3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db6:	5b                   	pop    %ebx
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	57                   	push   %edi
  800dbf:	56                   	push   %esi
  800dc0:	53                   	push   %ebx
  800dc1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc4:	b8 05 00 00 00       	mov    $0x5,%eax
  800dc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd5:	8b 75 18             	mov    0x18(%ebp),%esi
  800dd8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	7e 17                	jle    800df5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dde:	83 ec 0c             	sub    $0xc,%esp
  800de1:	50                   	push   %eax
  800de2:	6a 05                	push   $0x5
  800de4:	68 1f 27 80 00       	push   $0x80271f
  800de9:	6a 23                	push   $0x23
  800deb:	68 3c 27 80 00       	push   $0x80273c
  800df0:	e8 a3 f4 ff ff       	call   800298 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800df5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df8:	5b                   	pop    %ebx
  800df9:	5e                   	pop    %esi
  800dfa:	5f                   	pop    %edi
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	57                   	push   %edi
  800e01:	56                   	push   %esi
  800e02:	53                   	push   %ebx
  800e03:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0b:	b8 06 00 00 00       	mov    $0x6,%eax
  800e10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e13:	8b 55 08             	mov    0x8(%ebp),%edx
  800e16:	89 df                	mov    %ebx,%edi
  800e18:	89 de                	mov    %ebx,%esi
  800e1a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e1c:	85 c0                	test   %eax,%eax
  800e1e:	7e 17                	jle    800e37 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e20:	83 ec 0c             	sub    $0xc,%esp
  800e23:	50                   	push   %eax
  800e24:	6a 06                	push   $0x6
  800e26:	68 1f 27 80 00       	push   $0x80271f
  800e2b:	6a 23                	push   $0x23
  800e2d:	68 3c 27 80 00       	push   $0x80273c
  800e32:	e8 61 f4 ff ff       	call   800298 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3a:	5b                   	pop    %ebx
  800e3b:	5e                   	pop    %esi
  800e3c:	5f                   	pop    %edi
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	57                   	push   %edi
  800e43:	56                   	push   %esi
  800e44:	53                   	push   %ebx
  800e45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4d:	b8 08 00 00 00       	mov    $0x8,%eax
  800e52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e55:	8b 55 08             	mov    0x8(%ebp),%edx
  800e58:	89 df                	mov    %ebx,%edi
  800e5a:	89 de                	mov    %ebx,%esi
  800e5c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	7e 17                	jle    800e79 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e62:	83 ec 0c             	sub    $0xc,%esp
  800e65:	50                   	push   %eax
  800e66:	6a 08                	push   $0x8
  800e68:	68 1f 27 80 00       	push   $0x80271f
  800e6d:	6a 23                	push   $0x23
  800e6f:	68 3c 27 80 00       	push   $0x80273c
  800e74:	e8 1f f4 ff ff       	call   800298 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7c:	5b                   	pop    %ebx
  800e7d:	5e                   	pop    %esi
  800e7e:	5f                   	pop    %edi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	57                   	push   %edi
  800e85:	56                   	push   %esi
  800e86:	53                   	push   %ebx
  800e87:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8f:	b8 09 00 00 00       	mov    $0x9,%eax
  800e94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e97:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9a:	89 df                	mov    %ebx,%edi
  800e9c:	89 de                	mov    %ebx,%esi
  800e9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	7e 17                	jle    800ebb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea4:	83 ec 0c             	sub    $0xc,%esp
  800ea7:	50                   	push   %eax
  800ea8:	6a 09                	push   $0x9
  800eaa:	68 1f 27 80 00       	push   $0x80271f
  800eaf:	6a 23                	push   $0x23
  800eb1:	68 3c 27 80 00       	push   $0x80273c
  800eb6:	e8 dd f3 ff ff       	call   800298 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ebb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	57                   	push   %edi
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
  800ec9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ed6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	89 df                	mov    %ebx,%edi
  800ede:	89 de                	mov    %ebx,%esi
  800ee0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	7e 17                	jle    800efd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee6:	83 ec 0c             	sub    $0xc,%esp
  800ee9:	50                   	push   %eax
  800eea:	6a 0a                	push   $0xa
  800eec:	68 1f 27 80 00       	push   $0x80271f
  800ef1:	6a 23                	push   $0x23
  800ef3:	68 3c 27 80 00       	push   $0x80273c
  800ef8:	e8 9b f3 ff ff       	call   800298 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800efd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f00:	5b                   	pop    %ebx
  800f01:	5e                   	pop    %esi
  800f02:	5f                   	pop    %edi
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    

00800f05 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	57                   	push   %edi
  800f09:	56                   	push   %esi
  800f0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0b:	be 00 00 00 00       	mov    $0x0,%esi
  800f10:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f18:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f1e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f21:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f23:	5b                   	pop    %ebx
  800f24:	5e                   	pop    %esi
  800f25:	5f                   	pop    %edi
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    

00800f28 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	57                   	push   %edi
  800f2c:	56                   	push   %esi
  800f2d:	53                   	push   %ebx
  800f2e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f31:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f36:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3e:	89 cb                	mov    %ecx,%ebx
  800f40:	89 cf                	mov    %ecx,%edi
  800f42:	89 ce                	mov    %ecx,%esi
  800f44:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f46:	85 c0                	test   %eax,%eax
  800f48:	7e 17                	jle    800f61 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4a:	83 ec 0c             	sub    $0xc,%esp
  800f4d:	50                   	push   %eax
  800f4e:	6a 0d                	push   $0xd
  800f50:	68 1f 27 80 00       	push   $0x80271f
  800f55:	6a 23                	push   $0x23
  800f57:	68 3c 27 80 00       	push   $0x80273c
  800f5c:	e8 37 f3 ff ff       	call   800298 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    

00800f69 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	53                   	push   %ebx
  800f6d:	83 ec 04             	sub    $0x4,%esp
  800f70:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f73:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800f75:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f79:	74 2d                	je     800fa8 <pgfault+0x3f>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800f7b:	89 d8                	mov    %ebx,%eax
  800f7d:	c1 e8 16             	shr    $0x16,%eax
  800f80:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f87:	a8 01                	test   $0x1,%al
  800f89:	74 1d                	je     800fa8 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800f8b:	89 d8                	mov    %ebx,%eax
  800f8d:	c1 e8 0c             	shr    $0xc,%eax
  800f90:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800f97:	f6 c2 01             	test   $0x1,%dl
  800f9a:	74 0c                	je     800fa8 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800f9c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800fa3:	f6 c4 08             	test   $0x8,%ah
  800fa6:	75 14                	jne    800fbc <pgfault+0x53>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
	)) panic("Neither the fault is a write nor copy-on-write page.\n");
  800fa8:	83 ec 04             	sub    $0x4,%esp
  800fab:	68 4c 27 80 00       	push   $0x80274c
  800fb0:	6a 1f                	push   $0x1f
  800fb2:	68 82 27 80 00       	push   $0x802782
  800fb7:	e8 dc f2 ff ff       	call   800298 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if((r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W)) < 0){
  800fbc:	83 ec 04             	sub    $0x4,%esp
  800fbf:	6a 07                	push   $0x7
  800fc1:	68 00 f0 7f 00       	push   $0x7ff000
  800fc6:	6a 00                	push   $0x0
  800fc8:	e8 ab fd ff ff       	call   800d78 <sys_page_alloc>
  800fcd:	83 c4 10             	add    $0x10,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	79 12                	jns    800fe6 <pgfault+0x7d>
		 panic("sys_page_alloc: %e\n", r);
  800fd4:	50                   	push   %eax
  800fd5:	68 8d 27 80 00       	push   $0x80278d
  800fda:	6a 29                	push   $0x29
  800fdc:	68 82 27 80 00       	push   $0x802782
  800fe1:	e8 b2 f2 ff ff       	call   800298 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800fe6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800fec:	83 ec 04             	sub    $0x4,%esp
  800fef:	68 00 10 00 00       	push   $0x1000
  800ff4:	53                   	push   %ebx
  800ff5:	68 00 f0 7f 00       	push   $0x7ff000
  800ffa:	e8 70 fb ff ff       	call   800b6f <memcpy>
	if ((r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  800fff:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801006:	53                   	push   %ebx
  801007:	6a 00                	push   $0x0
  801009:	68 00 f0 7f 00       	push   $0x7ff000
  80100e:	6a 00                	push   $0x0
  801010:	e8 a6 fd ff ff       	call   800dbb <sys_page_map>
  801015:	83 c4 20             	add    $0x20,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	79 12                	jns    80102e <pgfault+0xc5>
        panic("sys_page_map: %e\n", r);
  80101c:	50                   	push   %eax
  80101d:	68 a1 27 80 00       	push   $0x8027a1
  801022:	6a 2e                	push   $0x2e
  801024:	68 82 27 80 00       	push   $0x802782
  801029:	e8 6a f2 ff ff       	call   800298 <_panic>
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  80102e:	83 ec 08             	sub    $0x8,%esp
  801031:	68 00 f0 7f 00       	push   $0x7ff000
  801036:	6a 00                	push   $0x0
  801038:	e8 c0 fd ff ff       	call   800dfd <sys_page_unmap>
  80103d:	83 c4 10             	add    $0x10,%esp
  801040:	85 c0                	test   %eax,%eax
  801042:	79 12                	jns    801056 <pgfault+0xed>
        panic("sys_page_unmap: %e\n", r);
  801044:	50                   	push   %eax
  801045:	68 b3 27 80 00       	push   $0x8027b3
  80104a:	6a 30                	push   $0x30
  80104c:	68 82 27 80 00       	push   $0x802782
  801051:	e8 42 f2 ff ff       	call   800298 <_panic>
	//panic("pgfault not implemented");
}
  801056:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801059:	c9                   	leave  
  80105a:	c3                   	ret    

0080105b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	57                   	push   %edi
  80105f:	56                   	push   %esi
  801060:	53                   	push   %ebx
  801061:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	envid_t cenvid;
    unsigned pn;
    int r;
	set_pgfault_handler(pgfault);
  801064:	68 69 0f 80 00       	push   $0x800f69
  801069:	e8 84 0e 00 00       	call   801ef2 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80106e:	b8 07 00 00 00       	mov    $0x7,%eax
  801073:	cd 30                	int    $0x30
  801075:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((cenvid = sys_exofork()) < 0){
  801078:	83 c4 10             	add    $0x10,%esp
  80107b:	85 c0                	test   %eax,%eax
  80107d:	79 14                	jns    801093 <fork+0x38>
		panic("sys_exofork failed");
  80107f:	83 ec 04             	sub    $0x4,%esp
  801082:	68 c7 27 80 00       	push   $0x8027c7
  801087:	6a 6f                	push   $0x6f
  801089:	68 82 27 80 00       	push   $0x802782
  80108e:	e8 05 f2 ff ff       	call   800298 <_panic>
  801093:	89 c7                	mov    %eax,%edi
		return cenvid;
	}
	if(cenvid>0){
  801095:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801099:	0f 8e 2b 01 00 00    	jle    8011ca <fork+0x16f>
  80109f:	bb 00 08 00 00       	mov    $0x800,%ebx
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
  8010a4:	89 d8                	mov    %ebx,%eax
  8010a6:	c1 e8 0a             	shr    $0xa,%eax
  8010a9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010b0:	a8 01                	test   $0x1,%al
  8010b2:	0f 84 bf 00 00 00    	je     801177 <fork+0x11c>
  8010b8:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8010bf:	a8 01                	test   $0x1,%al
  8010c1:	0f 84 b0 00 00 00    	je     801177 <fork+0x11c>
  8010c7:	89 de                	mov    %ebx,%esi
  8010c9:	c1 e6 0c             	shl    $0xc,%esi
{
	int r;

	// LAB 4: Your code here.
	void* vaddr=(void*)(pn*PGSIZE);
	if(uvpt[pn]&PTE_SHARE){
  8010cc:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8010d3:	f6 c4 04             	test   $0x4,%ah
  8010d6:	74 29                	je     801101 <fork+0xa6>
		if((r=sys_page_map(0,vaddr,envid,vaddr,uvpt[pn]&PTE_SYSCALL))<0)return r;
  8010d8:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8010df:	83 ec 0c             	sub    $0xc,%esp
  8010e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8010e7:	50                   	push   %eax
  8010e8:	56                   	push   %esi
  8010e9:	57                   	push   %edi
  8010ea:	56                   	push   %esi
  8010eb:	6a 00                	push   $0x0
  8010ed:	e8 c9 fc ff ff       	call   800dbb <sys_page_map>
  8010f2:	83 c4 20             	add    $0x20,%esp
  8010f5:	85 c0                	test   %eax,%eax
  8010f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8010fc:	0f 4f c2             	cmovg  %edx,%eax
  8010ff:	eb 72                	jmp    801173 <fork+0x118>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  801101:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801108:	a8 02                	test   $0x2,%al
  80110a:	75 0c                	jne    801118 <fork+0xbd>
  80110c:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801113:	f6 c4 08             	test   $0x8,%ah
  801116:	74 3f                	je     801157 <fork+0xfc>
		if ((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  801118:	83 ec 0c             	sub    $0xc,%esp
  80111b:	68 05 08 00 00       	push   $0x805
  801120:	56                   	push   %esi
  801121:	57                   	push   %edi
  801122:	56                   	push   %esi
  801123:	6a 00                	push   $0x0
  801125:	e8 91 fc ff ff       	call   800dbb <sys_page_map>
  80112a:	83 c4 20             	add    $0x20,%esp
  80112d:	85 c0                	test   %eax,%eax
  80112f:	0f 88 b1 00 00 00    	js     8011e6 <fork+0x18b>
            return r;
        if ((r = sys_page_map(0, vaddr, 0, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  801135:	83 ec 0c             	sub    $0xc,%esp
  801138:	68 05 08 00 00       	push   $0x805
  80113d:	56                   	push   %esi
  80113e:	6a 00                	push   $0x0
  801140:	56                   	push   %esi
  801141:	6a 00                	push   $0x0
  801143:	e8 73 fc ff ff       	call   800dbb <sys_page_map>
  801148:	83 c4 20             	add    $0x20,%esp
  80114b:	85 c0                	test   %eax,%eax
  80114d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801152:	0f 4f c1             	cmovg  %ecx,%eax
  801155:	eb 1c                	jmp    801173 <fork+0x118>
            return r;
	}
	else if((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U)) < 0) {
  801157:	83 ec 0c             	sub    $0xc,%esp
  80115a:	6a 05                	push   $0x5
  80115c:	56                   	push   %esi
  80115d:	57                   	push   %edi
  80115e:	56                   	push   %esi
  80115f:	6a 00                	push   $0x0
  801161:	e8 55 fc ff ff       	call   800dbb <sys_page_map>
  801166:	83 c4 20             	add    $0x20,%esp
  801169:	85 c0                	test   %eax,%eax
  80116b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801170:	0f 4f c1             	cmovg  %ecx,%eax
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
  801173:	85 c0                	test   %eax,%eax
  801175:	78 6f                	js     8011e6 <fork+0x18b>
	if ((cenvid = sys_exofork()) < 0){
		panic("sys_exofork failed");
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  801177:	83 c3 01             	add    $0x1,%ebx
  80117a:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801180:	0f 85 1e ff ff ff    	jne    8010a4 <fork+0x49>
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
                    return r;
		}
		if ((r = sys_page_alloc(cenvid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  801186:	83 ec 04             	sub    $0x4,%esp
  801189:	6a 07                	push   $0x7
  80118b:	68 00 f0 bf ee       	push   $0xeebff000
  801190:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801193:	57                   	push   %edi
  801194:	e8 df fb ff ff       	call   800d78 <sys_page_alloc>
  801199:	83 c4 10             	add    $0x10,%esp
  80119c:	85 c0                	test   %eax,%eax
  80119e:	78 46                	js     8011e6 <fork+0x18b>
            return r;
		extern void _pgfault_upcall(void);
		if ((r = sys_env_set_pgfault_upcall(cenvid, _pgfault_upcall)) < 0)
  8011a0:	83 ec 08             	sub    $0x8,%esp
  8011a3:	68 55 1f 80 00       	push   $0x801f55
  8011a8:	57                   	push   %edi
  8011a9:	e8 15 fd ff ff       	call   800ec3 <sys_env_set_pgfault_upcall>
  8011ae:	83 c4 10             	add    $0x10,%esp
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	78 31                	js     8011e6 <fork+0x18b>
            return r;
		if ((r = sys_env_set_status(cenvid, ENV_RUNNABLE)) < 0)
  8011b5:	83 ec 08             	sub    $0x8,%esp
  8011b8:	6a 02                	push   $0x2
  8011ba:	57                   	push   %edi
  8011bb:	e8 7f fc ff ff       	call   800e3f <sys_env_set_status>
  8011c0:	83 c4 10             	add    $0x10,%esp
            return r;
        return cenvid;
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	0f 49 c7             	cmovns %edi,%eax
  8011c8:	eb 1c                	jmp    8011e6 <fork+0x18b>
	}
	else {
		thisenv = &envs[ENVX(sys_getenvid())];
  8011ca:	e8 6b fb ff ff       	call   800d3a <sys_getenvid>
  8011cf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011d4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011d7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011dc:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8011e1:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//panic("fork not implemented");
	
}
  8011e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e9:	5b                   	pop    %ebx
  8011ea:	5e                   	pop    %esi
  8011eb:	5f                   	pop    %edi
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    

008011ee <sfork>:

// Challenge!
int
sfork(void)
{
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011f4:	68 da 27 80 00       	push   $0x8027da
  8011f9:	68 8d 00 00 00       	push   $0x8d
  8011fe:	68 82 27 80 00       	push   $0x802782
  801203:	e8 90 f0 ff ff       	call   800298 <_panic>

00801208 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80120b:	8b 45 08             	mov    0x8(%ebp),%eax
  80120e:	05 00 00 00 30       	add    $0x30000000,%eax
  801213:	c1 e8 0c             	shr    $0xc,%eax
}
  801216:	5d                   	pop    %ebp
  801217:	c3                   	ret    

00801218 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80121b:	8b 45 08             	mov    0x8(%ebp),%eax
  80121e:	05 00 00 00 30       	add    $0x30000000,%eax
  801223:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801228:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80122d:	5d                   	pop    %ebp
  80122e:	c3                   	ret    

0080122f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801235:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80123a:	89 c2                	mov    %eax,%edx
  80123c:	c1 ea 16             	shr    $0x16,%edx
  80123f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801246:	f6 c2 01             	test   $0x1,%dl
  801249:	74 11                	je     80125c <fd_alloc+0x2d>
  80124b:	89 c2                	mov    %eax,%edx
  80124d:	c1 ea 0c             	shr    $0xc,%edx
  801250:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801257:	f6 c2 01             	test   $0x1,%dl
  80125a:	75 09                	jne    801265 <fd_alloc+0x36>
			*fd_store = fd;
  80125c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80125e:	b8 00 00 00 00       	mov    $0x0,%eax
  801263:	eb 17                	jmp    80127c <fd_alloc+0x4d>
  801265:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80126a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80126f:	75 c9                	jne    80123a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801271:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801277:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80127c:	5d                   	pop    %ebp
  80127d:	c3                   	ret    

0080127e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801284:	83 f8 1f             	cmp    $0x1f,%eax
  801287:	77 36                	ja     8012bf <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801289:	c1 e0 0c             	shl    $0xc,%eax
  80128c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801291:	89 c2                	mov    %eax,%edx
  801293:	c1 ea 16             	shr    $0x16,%edx
  801296:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80129d:	f6 c2 01             	test   $0x1,%dl
  8012a0:	74 24                	je     8012c6 <fd_lookup+0x48>
  8012a2:	89 c2                	mov    %eax,%edx
  8012a4:	c1 ea 0c             	shr    $0xc,%edx
  8012a7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ae:	f6 c2 01             	test   $0x1,%dl
  8012b1:	74 1a                	je     8012cd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b6:	89 02                	mov    %eax,(%edx)
	return 0;
  8012b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012bd:	eb 13                	jmp    8012d2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c4:	eb 0c                	jmp    8012d2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012cb:	eb 05                	jmp    8012d2 <fd_lookup+0x54>
  8012cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012d2:	5d                   	pop    %ebp
  8012d3:	c3                   	ret    

008012d4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	83 ec 08             	sub    $0x8,%esp
  8012da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012dd:	ba 70 28 80 00       	mov    $0x802870,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012e2:	eb 13                	jmp    8012f7 <dev_lookup+0x23>
  8012e4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012e7:	39 08                	cmp    %ecx,(%eax)
  8012e9:	75 0c                	jne    8012f7 <dev_lookup+0x23>
			*dev = devtab[i];
  8012eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ee:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f5:	eb 2e                	jmp    801325 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012f7:	8b 02                	mov    (%edx),%eax
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	75 e7                	jne    8012e4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012fd:	a1 04 40 80 00       	mov    0x804004,%eax
  801302:	8b 40 48             	mov    0x48(%eax),%eax
  801305:	83 ec 04             	sub    $0x4,%esp
  801308:	51                   	push   %ecx
  801309:	50                   	push   %eax
  80130a:	68 f0 27 80 00       	push   $0x8027f0
  80130f:	e8 5d f0 ff ff       	call   800371 <cprintf>
	*dev = 0;
  801314:	8b 45 0c             	mov    0xc(%ebp),%eax
  801317:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80131d:	83 c4 10             	add    $0x10,%esp
  801320:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801325:	c9                   	leave  
  801326:	c3                   	ret    

00801327 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801327:	55                   	push   %ebp
  801328:	89 e5                	mov    %esp,%ebp
  80132a:	56                   	push   %esi
  80132b:	53                   	push   %ebx
  80132c:	83 ec 10             	sub    $0x10,%esp
  80132f:	8b 75 08             	mov    0x8(%ebp),%esi
  801332:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801335:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801338:	50                   	push   %eax
  801339:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80133f:	c1 e8 0c             	shr    $0xc,%eax
  801342:	50                   	push   %eax
  801343:	e8 36 ff ff ff       	call   80127e <fd_lookup>
  801348:	83 c4 08             	add    $0x8,%esp
  80134b:	85 c0                	test   %eax,%eax
  80134d:	78 05                	js     801354 <fd_close+0x2d>
	    || fd != fd2)
  80134f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801352:	74 0c                	je     801360 <fd_close+0x39>
		return (must_exist ? r : 0);
  801354:	84 db                	test   %bl,%bl
  801356:	ba 00 00 00 00       	mov    $0x0,%edx
  80135b:	0f 44 c2             	cmove  %edx,%eax
  80135e:	eb 41                	jmp    8013a1 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801360:	83 ec 08             	sub    $0x8,%esp
  801363:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801366:	50                   	push   %eax
  801367:	ff 36                	pushl  (%esi)
  801369:	e8 66 ff ff ff       	call   8012d4 <dev_lookup>
  80136e:	89 c3                	mov    %eax,%ebx
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	85 c0                	test   %eax,%eax
  801375:	78 1a                	js     801391 <fd_close+0x6a>
		if (dev->dev_close)
  801377:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80137d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801382:	85 c0                	test   %eax,%eax
  801384:	74 0b                	je     801391 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801386:	83 ec 0c             	sub    $0xc,%esp
  801389:	56                   	push   %esi
  80138a:	ff d0                	call   *%eax
  80138c:	89 c3                	mov    %eax,%ebx
  80138e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801391:	83 ec 08             	sub    $0x8,%esp
  801394:	56                   	push   %esi
  801395:	6a 00                	push   $0x0
  801397:	e8 61 fa ff ff       	call   800dfd <sys_page_unmap>
	return r;
  80139c:	83 c4 10             	add    $0x10,%esp
  80139f:	89 d8                	mov    %ebx,%eax
}
  8013a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a4:	5b                   	pop    %ebx
  8013a5:	5e                   	pop    %esi
  8013a6:	5d                   	pop    %ebp
  8013a7:	c3                   	ret    

008013a8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b1:	50                   	push   %eax
  8013b2:	ff 75 08             	pushl  0x8(%ebp)
  8013b5:	e8 c4 fe ff ff       	call   80127e <fd_lookup>
  8013ba:	83 c4 08             	add    $0x8,%esp
  8013bd:	85 c0                	test   %eax,%eax
  8013bf:	78 10                	js     8013d1 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013c1:	83 ec 08             	sub    $0x8,%esp
  8013c4:	6a 01                	push   $0x1
  8013c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8013c9:	e8 59 ff ff ff       	call   801327 <fd_close>
  8013ce:	83 c4 10             	add    $0x10,%esp
}
  8013d1:	c9                   	leave  
  8013d2:	c3                   	ret    

008013d3 <close_all>:

void
close_all(void)
{
  8013d3:	55                   	push   %ebp
  8013d4:	89 e5                	mov    %esp,%ebp
  8013d6:	53                   	push   %ebx
  8013d7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013da:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013df:	83 ec 0c             	sub    $0xc,%esp
  8013e2:	53                   	push   %ebx
  8013e3:	e8 c0 ff ff ff       	call   8013a8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013e8:	83 c3 01             	add    $0x1,%ebx
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	83 fb 20             	cmp    $0x20,%ebx
  8013f1:	75 ec                	jne    8013df <close_all+0xc>
		close(i);
}
  8013f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f6:	c9                   	leave  
  8013f7:	c3                   	ret    

008013f8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	57                   	push   %edi
  8013fc:	56                   	push   %esi
  8013fd:	53                   	push   %ebx
  8013fe:	83 ec 2c             	sub    $0x2c,%esp
  801401:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801404:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801407:	50                   	push   %eax
  801408:	ff 75 08             	pushl  0x8(%ebp)
  80140b:	e8 6e fe ff ff       	call   80127e <fd_lookup>
  801410:	83 c4 08             	add    $0x8,%esp
  801413:	85 c0                	test   %eax,%eax
  801415:	0f 88 c1 00 00 00    	js     8014dc <dup+0xe4>
		return r;
	close(newfdnum);
  80141b:	83 ec 0c             	sub    $0xc,%esp
  80141e:	56                   	push   %esi
  80141f:	e8 84 ff ff ff       	call   8013a8 <close>

	newfd = INDEX2FD(newfdnum);
  801424:	89 f3                	mov    %esi,%ebx
  801426:	c1 e3 0c             	shl    $0xc,%ebx
  801429:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80142f:	83 c4 04             	add    $0x4,%esp
  801432:	ff 75 e4             	pushl  -0x1c(%ebp)
  801435:	e8 de fd ff ff       	call   801218 <fd2data>
  80143a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80143c:	89 1c 24             	mov    %ebx,(%esp)
  80143f:	e8 d4 fd ff ff       	call   801218 <fd2data>
  801444:	83 c4 10             	add    $0x10,%esp
  801447:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80144a:	89 f8                	mov    %edi,%eax
  80144c:	c1 e8 16             	shr    $0x16,%eax
  80144f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801456:	a8 01                	test   $0x1,%al
  801458:	74 37                	je     801491 <dup+0x99>
  80145a:	89 f8                	mov    %edi,%eax
  80145c:	c1 e8 0c             	shr    $0xc,%eax
  80145f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801466:	f6 c2 01             	test   $0x1,%dl
  801469:	74 26                	je     801491 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80146b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801472:	83 ec 0c             	sub    $0xc,%esp
  801475:	25 07 0e 00 00       	and    $0xe07,%eax
  80147a:	50                   	push   %eax
  80147b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80147e:	6a 00                	push   $0x0
  801480:	57                   	push   %edi
  801481:	6a 00                	push   $0x0
  801483:	e8 33 f9 ff ff       	call   800dbb <sys_page_map>
  801488:	89 c7                	mov    %eax,%edi
  80148a:	83 c4 20             	add    $0x20,%esp
  80148d:	85 c0                	test   %eax,%eax
  80148f:	78 2e                	js     8014bf <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801491:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801494:	89 d0                	mov    %edx,%eax
  801496:	c1 e8 0c             	shr    $0xc,%eax
  801499:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014a0:	83 ec 0c             	sub    $0xc,%esp
  8014a3:	25 07 0e 00 00       	and    $0xe07,%eax
  8014a8:	50                   	push   %eax
  8014a9:	53                   	push   %ebx
  8014aa:	6a 00                	push   $0x0
  8014ac:	52                   	push   %edx
  8014ad:	6a 00                	push   $0x0
  8014af:	e8 07 f9 ff ff       	call   800dbb <sys_page_map>
  8014b4:	89 c7                	mov    %eax,%edi
  8014b6:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014b9:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014bb:	85 ff                	test   %edi,%edi
  8014bd:	79 1d                	jns    8014dc <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014bf:	83 ec 08             	sub    $0x8,%esp
  8014c2:	53                   	push   %ebx
  8014c3:	6a 00                	push   $0x0
  8014c5:	e8 33 f9 ff ff       	call   800dfd <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014ca:	83 c4 08             	add    $0x8,%esp
  8014cd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014d0:	6a 00                	push   $0x0
  8014d2:	e8 26 f9 ff ff       	call   800dfd <sys_page_unmap>
	return r;
  8014d7:	83 c4 10             	add    $0x10,%esp
  8014da:	89 f8                	mov    %edi,%eax
}
  8014dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014df:	5b                   	pop    %ebx
  8014e0:	5e                   	pop    %esi
  8014e1:	5f                   	pop    %edi
  8014e2:	5d                   	pop    %ebp
  8014e3:	c3                   	ret    

008014e4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	53                   	push   %ebx
  8014e8:	83 ec 14             	sub    $0x14,%esp
  8014eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f1:	50                   	push   %eax
  8014f2:	53                   	push   %ebx
  8014f3:	e8 86 fd ff ff       	call   80127e <fd_lookup>
  8014f8:	83 c4 08             	add    $0x8,%esp
  8014fb:	89 c2                	mov    %eax,%edx
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	78 6d                	js     80156e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801501:	83 ec 08             	sub    $0x8,%esp
  801504:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801507:	50                   	push   %eax
  801508:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150b:	ff 30                	pushl  (%eax)
  80150d:	e8 c2 fd ff ff       	call   8012d4 <dev_lookup>
  801512:	83 c4 10             	add    $0x10,%esp
  801515:	85 c0                	test   %eax,%eax
  801517:	78 4c                	js     801565 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801519:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80151c:	8b 42 08             	mov    0x8(%edx),%eax
  80151f:	83 e0 03             	and    $0x3,%eax
  801522:	83 f8 01             	cmp    $0x1,%eax
  801525:	75 21                	jne    801548 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801527:	a1 04 40 80 00       	mov    0x804004,%eax
  80152c:	8b 40 48             	mov    0x48(%eax),%eax
  80152f:	83 ec 04             	sub    $0x4,%esp
  801532:	53                   	push   %ebx
  801533:	50                   	push   %eax
  801534:	68 34 28 80 00       	push   $0x802834
  801539:	e8 33 ee ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  80153e:	83 c4 10             	add    $0x10,%esp
  801541:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801546:	eb 26                	jmp    80156e <read+0x8a>
	}
	if (!dev->dev_read)
  801548:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154b:	8b 40 08             	mov    0x8(%eax),%eax
  80154e:	85 c0                	test   %eax,%eax
  801550:	74 17                	je     801569 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801552:	83 ec 04             	sub    $0x4,%esp
  801555:	ff 75 10             	pushl  0x10(%ebp)
  801558:	ff 75 0c             	pushl  0xc(%ebp)
  80155b:	52                   	push   %edx
  80155c:	ff d0                	call   *%eax
  80155e:	89 c2                	mov    %eax,%edx
  801560:	83 c4 10             	add    $0x10,%esp
  801563:	eb 09                	jmp    80156e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801565:	89 c2                	mov    %eax,%edx
  801567:	eb 05                	jmp    80156e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801569:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80156e:	89 d0                	mov    %edx,%eax
  801570:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801573:	c9                   	leave  
  801574:	c3                   	ret    

00801575 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	57                   	push   %edi
  801579:	56                   	push   %esi
  80157a:	53                   	push   %ebx
  80157b:	83 ec 0c             	sub    $0xc,%esp
  80157e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801581:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801584:	bb 00 00 00 00       	mov    $0x0,%ebx
  801589:	eb 21                	jmp    8015ac <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80158b:	83 ec 04             	sub    $0x4,%esp
  80158e:	89 f0                	mov    %esi,%eax
  801590:	29 d8                	sub    %ebx,%eax
  801592:	50                   	push   %eax
  801593:	89 d8                	mov    %ebx,%eax
  801595:	03 45 0c             	add    0xc(%ebp),%eax
  801598:	50                   	push   %eax
  801599:	57                   	push   %edi
  80159a:	e8 45 ff ff ff       	call   8014e4 <read>
		if (m < 0)
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	85 c0                	test   %eax,%eax
  8015a4:	78 10                	js     8015b6 <readn+0x41>
			return m;
		if (m == 0)
  8015a6:	85 c0                	test   %eax,%eax
  8015a8:	74 0a                	je     8015b4 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015aa:	01 c3                	add    %eax,%ebx
  8015ac:	39 f3                	cmp    %esi,%ebx
  8015ae:	72 db                	jb     80158b <readn+0x16>
  8015b0:	89 d8                	mov    %ebx,%eax
  8015b2:	eb 02                	jmp    8015b6 <readn+0x41>
  8015b4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b9:	5b                   	pop    %ebx
  8015ba:	5e                   	pop    %esi
  8015bb:	5f                   	pop    %edi
  8015bc:	5d                   	pop    %ebp
  8015bd:	c3                   	ret    

008015be <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015be:	55                   	push   %ebp
  8015bf:	89 e5                	mov    %esp,%ebp
  8015c1:	53                   	push   %ebx
  8015c2:	83 ec 14             	sub    $0x14,%esp
  8015c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015cb:	50                   	push   %eax
  8015cc:	53                   	push   %ebx
  8015cd:	e8 ac fc ff ff       	call   80127e <fd_lookup>
  8015d2:	83 c4 08             	add    $0x8,%esp
  8015d5:	89 c2                	mov    %eax,%edx
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	78 68                	js     801643 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015db:	83 ec 08             	sub    $0x8,%esp
  8015de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e1:	50                   	push   %eax
  8015e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e5:	ff 30                	pushl  (%eax)
  8015e7:	e8 e8 fc ff ff       	call   8012d4 <dev_lookup>
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	78 47                	js     80163a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015fa:	75 21                	jne    80161d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015fc:	a1 04 40 80 00       	mov    0x804004,%eax
  801601:	8b 40 48             	mov    0x48(%eax),%eax
  801604:	83 ec 04             	sub    $0x4,%esp
  801607:	53                   	push   %ebx
  801608:	50                   	push   %eax
  801609:	68 50 28 80 00       	push   $0x802850
  80160e:	e8 5e ed ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  801613:	83 c4 10             	add    $0x10,%esp
  801616:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80161b:	eb 26                	jmp    801643 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80161d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801620:	8b 52 0c             	mov    0xc(%edx),%edx
  801623:	85 d2                	test   %edx,%edx
  801625:	74 17                	je     80163e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801627:	83 ec 04             	sub    $0x4,%esp
  80162a:	ff 75 10             	pushl  0x10(%ebp)
  80162d:	ff 75 0c             	pushl  0xc(%ebp)
  801630:	50                   	push   %eax
  801631:	ff d2                	call   *%edx
  801633:	89 c2                	mov    %eax,%edx
  801635:	83 c4 10             	add    $0x10,%esp
  801638:	eb 09                	jmp    801643 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163a:	89 c2                	mov    %eax,%edx
  80163c:	eb 05                	jmp    801643 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80163e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801643:	89 d0                	mov    %edx,%eax
  801645:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801648:	c9                   	leave  
  801649:	c3                   	ret    

0080164a <seek>:

int
seek(int fdnum, off_t offset)
{
  80164a:	55                   	push   %ebp
  80164b:	89 e5                	mov    %esp,%ebp
  80164d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801650:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801653:	50                   	push   %eax
  801654:	ff 75 08             	pushl  0x8(%ebp)
  801657:	e8 22 fc ff ff       	call   80127e <fd_lookup>
  80165c:	83 c4 08             	add    $0x8,%esp
  80165f:	85 c0                	test   %eax,%eax
  801661:	78 0e                	js     801671 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801663:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801666:	8b 55 0c             	mov    0xc(%ebp),%edx
  801669:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80166c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801671:	c9                   	leave  
  801672:	c3                   	ret    

00801673 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	53                   	push   %ebx
  801677:	83 ec 14             	sub    $0x14,%esp
  80167a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801680:	50                   	push   %eax
  801681:	53                   	push   %ebx
  801682:	e8 f7 fb ff ff       	call   80127e <fd_lookup>
  801687:	83 c4 08             	add    $0x8,%esp
  80168a:	89 c2                	mov    %eax,%edx
  80168c:	85 c0                	test   %eax,%eax
  80168e:	78 65                	js     8016f5 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801690:	83 ec 08             	sub    $0x8,%esp
  801693:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801696:	50                   	push   %eax
  801697:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169a:	ff 30                	pushl  (%eax)
  80169c:	e8 33 fc ff ff       	call   8012d4 <dev_lookup>
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	78 44                	js     8016ec <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ab:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016af:	75 21                	jne    8016d2 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016b1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016b6:	8b 40 48             	mov    0x48(%eax),%eax
  8016b9:	83 ec 04             	sub    $0x4,%esp
  8016bc:	53                   	push   %ebx
  8016bd:	50                   	push   %eax
  8016be:	68 10 28 80 00       	push   $0x802810
  8016c3:	e8 a9 ec ff ff       	call   800371 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016c8:	83 c4 10             	add    $0x10,%esp
  8016cb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016d0:	eb 23                	jmp    8016f5 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016d5:	8b 52 18             	mov    0x18(%edx),%edx
  8016d8:	85 d2                	test   %edx,%edx
  8016da:	74 14                	je     8016f0 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016dc:	83 ec 08             	sub    $0x8,%esp
  8016df:	ff 75 0c             	pushl  0xc(%ebp)
  8016e2:	50                   	push   %eax
  8016e3:	ff d2                	call   *%edx
  8016e5:	89 c2                	mov    %eax,%edx
  8016e7:	83 c4 10             	add    $0x10,%esp
  8016ea:	eb 09                	jmp    8016f5 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ec:	89 c2                	mov    %eax,%edx
  8016ee:	eb 05                	jmp    8016f5 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016f0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016f5:	89 d0                	mov    %edx,%eax
  8016f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fa:	c9                   	leave  
  8016fb:	c3                   	ret    

008016fc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	53                   	push   %ebx
  801700:	83 ec 14             	sub    $0x14,%esp
  801703:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801706:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801709:	50                   	push   %eax
  80170a:	ff 75 08             	pushl  0x8(%ebp)
  80170d:	e8 6c fb ff ff       	call   80127e <fd_lookup>
  801712:	83 c4 08             	add    $0x8,%esp
  801715:	89 c2                	mov    %eax,%edx
  801717:	85 c0                	test   %eax,%eax
  801719:	78 58                	js     801773 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171b:	83 ec 08             	sub    $0x8,%esp
  80171e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801721:	50                   	push   %eax
  801722:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801725:	ff 30                	pushl  (%eax)
  801727:	e8 a8 fb ff ff       	call   8012d4 <dev_lookup>
  80172c:	83 c4 10             	add    $0x10,%esp
  80172f:	85 c0                	test   %eax,%eax
  801731:	78 37                	js     80176a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801733:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801736:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80173a:	74 32                	je     80176e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80173c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80173f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801746:	00 00 00 
	stat->st_isdir = 0;
  801749:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801750:	00 00 00 
	stat->st_dev = dev;
  801753:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801759:	83 ec 08             	sub    $0x8,%esp
  80175c:	53                   	push   %ebx
  80175d:	ff 75 f0             	pushl  -0x10(%ebp)
  801760:	ff 50 14             	call   *0x14(%eax)
  801763:	89 c2                	mov    %eax,%edx
  801765:	83 c4 10             	add    $0x10,%esp
  801768:	eb 09                	jmp    801773 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176a:	89 c2                	mov    %eax,%edx
  80176c:	eb 05                	jmp    801773 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80176e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801773:	89 d0                	mov    %edx,%eax
  801775:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801778:	c9                   	leave  
  801779:	c3                   	ret    

0080177a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80177a:	55                   	push   %ebp
  80177b:	89 e5                	mov    %esp,%ebp
  80177d:	56                   	push   %esi
  80177e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80177f:	83 ec 08             	sub    $0x8,%esp
  801782:	6a 00                	push   $0x0
  801784:	ff 75 08             	pushl  0x8(%ebp)
  801787:	e8 e3 01 00 00       	call   80196f <open>
  80178c:	89 c3                	mov    %eax,%ebx
  80178e:	83 c4 10             	add    $0x10,%esp
  801791:	85 c0                	test   %eax,%eax
  801793:	78 1b                	js     8017b0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801795:	83 ec 08             	sub    $0x8,%esp
  801798:	ff 75 0c             	pushl  0xc(%ebp)
  80179b:	50                   	push   %eax
  80179c:	e8 5b ff ff ff       	call   8016fc <fstat>
  8017a1:	89 c6                	mov    %eax,%esi
	close(fd);
  8017a3:	89 1c 24             	mov    %ebx,(%esp)
  8017a6:	e8 fd fb ff ff       	call   8013a8 <close>
	return r;
  8017ab:	83 c4 10             	add    $0x10,%esp
  8017ae:	89 f0                	mov    %esi,%eax
}
  8017b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b3:	5b                   	pop    %ebx
  8017b4:	5e                   	pop    %esi
  8017b5:	5d                   	pop    %ebp
  8017b6:	c3                   	ret    

008017b7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	56                   	push   %esi
  8017bb:	53                   	push   %ebx
  8017bc:	89 c6                	mov    %eax,%esi
  8017be:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017c0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017c7:	75 12                	jne    8017db <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017c9:	83 ec 0c             	sub    $0xc,%esp
  8017cc:	6a 01                	push   $0x1
  8017ce:	e8 63 08 00 00       	call   802036 <ipc_find_env>
  8017d3:	a3 00 40 80 00       	mov    %eax,0x804000
  8017d8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017db:	6a 07                	push   $0x7
  8017dd:	68 00 50 80 00       	push   $0x805000
  8017e2:	56                   	push   %esi
  8017e3:	ff 35 00 40 80 00    	pushl  0x804000
  8017e9:	e8 f4 07 00 00       	call   801fe2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017ee:	83 c4 0c             	add    $0xc,%esp
  8017f1:	6a 00                	push   $0x0
  8017f3:	53                   	push   %ebx
  8017f4:	6a 00                	push   $0x0
  8017f6:	e8 7e 07 00 00       	call   801f79 <ipc_recv>
}
  8017fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017fe:	5b                   	pop    %ebx
  8017ff:	5e                   	pop    %esi
  801800:	5d                   	pop    %ebp
  801801:	c3                   	ret    

00801802 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801802:	55                   	push   %ebp
  801803:	89 e5                	mov    %esp,%ebp
  801805:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801808:	8b 45 08             	mov    0x8(%ebp),%eax
  80180b:	8b 40 0c             	mov    0xc(%eax),%eax
  80180e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801813:	8b 45 0c             	mov    0xc(%ebp),%eax
  801816:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80181b:	ba 00 00 00 00       	mov    $0x0,%edx
  801820:	b8 02 00 00 00       	mov    $0x2,%eax
  801825:	e8 8d ff ff ff       	call   8017b7 <fsipc>
}
  80182a:	c9                   	leave  
  80182b:	c3                   	ret    

0080182c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801832:	8b 45 08             	mov    0x8(%ebp),%eax
  801835:	8b 40 0c             	mov    0xc(%eax),%eax
  801838:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80183d:	ba 00 00 00 00       	mov    $0x0,%edx
  801842:	b8 06 00 00 00       	mov    $0x6,%eax
  801847:	e8 6b ff ff ff       	call   8017b7 <fsipc>
}
  80184c:	c9                   	leave  
  80184d:	c3                   	ret    

0080184e <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	53                   	push   %ebx
  801852:	83 ec 04             	sub    $0x4,%esp
  801855:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801858:	8b 45 08             	mov    0x8(%ebp),%eax
  80185b:	8b 40 0c             	mov    0xc(%eax),%eax
  80185e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801863:	ba 00 00 00 00       	mov    $0x0,%edx
  801868:	b8 05 00 00 00       	mov    $0x5,%eax
  80186d:	e8 45 ff ff ff       	call   8017b7 <fsipc>
  801872:	85 c0                	test   %eax,%eax
  801874:	78 2c                	js     8018a2 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801876:	83 ec 08             	sub    $0x8,%esp
  801879:	68 00 50 80 00       	push   $0x805000
  80187e:	53                   	push   %ebx
  80187f:	e8 f1 f0 ff ff       	call   800975 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801884:	a1 80 50 80 00       	mov    0x805080,%eax
  801889:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80188f:	a1 84 50 80 00       	mov    0x805084,%eax
  801894:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80189a:	83 c4 10             	add    $0x10,%esp
  80189d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a5:	c9                   	leave  
  8018a6:	c3                   	ret    

008018a7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	83 ec 0c             	sub    $0xc,%esp
  8018ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8018b0:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018b5:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018ba:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8018c0:	8b 52 0c             	mov    0xc(%edx),%edx
  8018c3:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018c9:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018ce:	50                   	push   %eax
  8018cf:	ff 75 0c             	pushl  0xc(%ebp)
  8018d2:	68 08 50 80 00       	push   $0x805008
  8018d7:	e8 2b f2 ff ff       	call   800b07 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e1:	b8 04 00 00 00       	mov    $0x4,%eax
  8018e6:	e8 cc fe ff ff       	call   8017b7 <fsipc>
	//panic("devfile_write not implemented");
}
  8018eb:	c9                   	leave  
  8018ec:	c3                   	ret    

008018ed <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
  8018f0:	56                   	push   %esi
  8018f1:	53                   	push   %ebx
  8018f2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018fb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801900:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801906:	ba 00 00 00 00       	mov    $0x0,%edx
  80190b:	b8 03 00 00 00       	mov    $0x3,%eax
  801910:	e8 a2 fe ff ff       	call   8017b7 <fsipc>
  801915:	89 c3                	mov    %eax,%ebx
  801917:	85 c0                	test   %eax,%eax
  801919:	78 4b                	js     801966 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80191b:	39 c6                	cmp    %eax,%esi
  80191d:	73 16                	jae    801935 <devfile_read+0x48>
  80191f:	68 80 28 80 00       	push   $0x802880
  801924:	68 87 28 80 00       	push   $0x802887
  801929:	6a 7c                	push   $0x7c
  80192b:	68 9c 28 80 00       	push   $0x80289c
  801930:	e8 63 e9 ff ff       	call   800298 <_panic>
	assert(r <= PGSIZE);
  801935:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80193a:	7e 16                	jle    801952 <devfile_read+0x65>
  80193c:	68 a7 28 80 00       	push   $0x8028a7
  801941:	68 87 28 80 00       	push   $0x802887
  801946:	6a 7d                	push   $0x7d
  801948:	68 9c 28 80 00       	push   $0x80289c
  80194d:	e8 46 e9 ff ff       	call   800298 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801952:	83 ec 04             	sub    $0x4,%esp
  801955:	50                   	push   %eax
  801956:	68 00 50 80 00       	push   $0x805000
  80195b:	ff 75 0c             	pushl  0xc(%ebp)
  80195e:	e8 a4 f1 ff ff       	call   800b07 <memmove>
	return r;
  801963:	83 c4 10             	add    $0x10,%esp
}
  801966:	89 d8                	mov    %ebx,%eax
  801968:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80196b:	5b                   	pop    %ebx
  80196c:	5e                   	pop    %esi
  80196d:	5d                   	pop    %ebp
  80196e:	c3                   	ret    

0080196f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80196f:	55                   	push   %ebp
  801970:	89 e5                	mov    %esp,%ebp
  801972:	53                   	push   %ebx
  801973:	83 ec 20             	sub    $0x20,%esp
  801976:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801979:	53                   	push   %ebx
  80197a:	e8 bd ef ff ff       	call   80093c <strlen>
  80197f:	83 c4 10             	add    $0x10,%esp
  801982:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801987:	7f 67                	jg     8019f0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801989:	83 ec 0c             	sub    $0xc,%esp
  80198c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198f:	50                   	push   %eax
  801990:	e8 9a f8 ff ff       	call   80122f <fd_alloc>
  801995:	83 c4 10             	add    $0x10,%esp
		return r;
  801998:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80199a:	85 c0                	test   %eax,%eax
  80199c:	78 57                	js     8019f5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80199e:	83 ec 08             	sub    $0x8,%esp
  8019a1:	53                   	push   %ebx
  8019a2:	68 00 50 80 00       	push   $0x805000
  8019a7:	e8 c9 ef ff ff       	call   800975 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019af:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019b7:	b8 01 00 00 00       	mov    $0x1,%eax
  8019bc:	e8 f6 fd ff ff       	call   8017b7 <fsipc>
  8019c1:	89 c3                	mov    %eax,%ebx
  8019c3:	83 c4 10             	add    $0x10,%esp
  8019c6:	85 c0                	test   %eax,%eax
  8019c8:	79 14                	jns    8019de <open+0x6f>
		fd_close(fd, 0);
  8019ca:	83 ec 08             	sub    $0x8,%esp
  8019cd:	6a 00                	push   $0x0
  8019cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d2:	e8 50 f9 ff ff       	call   801327 <fd_close>
		return r;
  8019d7:	83 c4 10             	add    $0x10,%esp
  8019da:	89 da                	mov    %ebx,%edx
  8019dc:	eb 17                	jmp    8019f5 <open+0x86>
	}

	return fd2num(fd);
  8019de:	83 ec 0c             	sub    $0xc,%esp
  8019e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e4:	e8 1f f8 ff ff       	call   801208 <fd2num>
  8019e9:	89 c2                	mov    %eax,%edx
  8019eb:	83 c4 10             	add    $0x10,%esp
  8019ee:	eb 05                	jmp    8019f5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019f0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019f5:	89 d0                	mov    %edx,%eax
  8019f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019fa:	c9                   	leave  
  8019fb:	c3                   	ret    

008019fc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a02:	ba 00 00 00 00       	mov    $0x0,%edx
  801a07:	b8 08 00 00 00       	mov    $0x8,%eax
  801a0c:	e8 a6 fd ff ff       	call   8017b7 <fsipc>
}
  801a11:	c9                   	leave  
  801a12:	c3                   	ret    

00801a13 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	56                   	push   %esi
  801a17:	53                   	push   %ebx
  801a18:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a1b:	83 ec 0c             	sub    $0xc,%esp
  801a1e:	ff 75 08             	pushl  0x8(%ebp)
  801a21:	e8 f2 f7 ff ff       	call   801218 <fd2data>
  801a26:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a28:	83 c4 08             	add    $0x8,%esp
  801a2b:	68 b3 28 80 00       	push   $0x8028b3
  801a30:	53                   	push   %ebx
  801a31:	e8 3f ef ff ff       	call   800975 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a36:	8b 46 04             	mov    0x4(%esi),%eax
  801a39:	2b 06                	sub    (%esi),%eax
  801a3b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a41:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a48:	00 00 00 
	stat->st_dev = &devpipe;
  801a4b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a52:	30 80 00 
	return 0;
}
  801a55:	b8 00 00 00 00       	mov    $0x0,%eax
  801a5a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a5d:	5b                   	pop    %ebx
  801a5e:	5e                   	pop    %esi
  801a5f:	5d                   	pop    %ebp
  801a60:	c3                   	ret    

00801a61 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	53                   	push   %ebx
  801a65:	83 ec 0c             	sub    $0xc,%esp
  801a68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a6b:	53                   	push   %ebx
  801a6c:	6a 00                	push   $0x0
  801a6e:	e8 8a f3 ff ff       	call   800dfd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a73:	89 1c 24             	mov    %ebx,(%esp)
  801a76:	e8 9d f7 ff ff       	call   801218 <fd2data>
  801a7b:	83 c4 08             	add    $0x8,%esp
  801a7e:	50                   	push   %eax
  801a7f:	6a 00                	push   $0x0
  801a81:	e8 77 f3 ff ff       	call   800dfd <sys_page_unmap>
}
  801a86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a89:	c9                   	leave  
  801a8a:	c3                   	ret    

00801a8b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	57                   	push   %edi
  801a8f:	56                   	push   %esi
  801a90:	53                   	push   %ebx
  801a91:	83 ec 1c             	sub    $0x1c,%esp
  801a94:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a97:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a99:	a1 04 40 80 00       	mov    0x804004,%eax
  801a9e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801aa1:	83 ec 0c             	sub    $0xc,%esp
  801aa4:	ff 75 e0             	pushl  -0x20(%ebp)
  801aa7:	e8 c3 05 00 00       	call   80206f <pageref>
  801aac:	89 c3                	mov    %eax,%ebx
  801aae:	89 3c 24             	mov    %edi,(%esp)
  801ab1:	e8 b9 05 00 00       	call   80206f <pageref>
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	39 c3                	cmp    %eax,%ebx
  801abb:	0f 94 c1             	sete   %cl
  801abe:	0f b6 c9             	movzbl %cl,%ecx
  801ac1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ac4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801aca:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801acd:	39 ce                	cmp    %ecx,%esi
  801acf:	74 1b                	je     801aec <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ad1:	39 c3                	cmp    %eax,%ebx
  801ad3:	75 c4                	jne    801a99 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ad5:	8b 42 58             	mov    0x58(%edx),%eax
  801ad8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801adb:	50                   	push   %eax
  801adc:	56                   	push   %esi
  801add:	68 ba 28 80 00       	push   $0x8028ba
  801ae2:	e8 8a e8 ff ff       	call   800371 <cprintf>
  801ae7:	83 c4 10             	add    $0x10,%esp
  801aea:	eb ad                	jmp    801a99 <_pipeisclosed+0xe>
	}
}
  801aec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af2:	5b                   	pop    %ebx
  801af3:	5e                   	pop    %esi
  801af4:	5f                   	pop    %edi
  801af5:	5d                   	pop    %ebp
  801af6:	c3                   	ret    

00801af7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	57                   	push   %edi
  801afb:	56                   	push   %esi
  801afc:	53                   	push   %ebx
  801afd:	83 ec 28             	sub    $0x28,%esp
  801b00:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b03:	56                   	push   %esi
  801b04:	e8 0f f7 ff ff       	call   801218 <fd2data>
  801b09:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	bf 00 00 00 00       	mov    $0x0,%edi
  801b13:	eb 4b                	jmp    801b60 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b15:	89 da                	mov    %ebx,%edx
  801b17:	89 f0                	mov    %esi,%eax
  801b19:	e8 6d ff ff ff       	call   801a8b <_pipeisclosed>
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	75 48                	jne    801b6a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b22:	e8 32 f2 ff ff       	call   800d59 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b27:	8b 43 04             	mov    0x4(%ebx),%eax
  801b2a:	8b 0b                	mov    (%ebx),%ecx
  801b2c:	8d 51 20             	lea    0x20(%ecx),%edx
  801b2f:	39 d0                	cmp    %edx,%eax
  801b31:	73 e2                	jae    801b15 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b36:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b3a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b3d:	89 c2                	mov    %eax,%edx
  801b3f:	c1 fa 1f             	sar    $0x1f,%edx
  801b42:	89 d1                	mov    %edx,%ecx
  801b44:	c1 e9 1b             	shr    $0x1b,%ecx
  801b47:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b4a:	83 e2 1f             	and    $0x1f,%edx
  801b4d:	29 ca                	sub    %ecx,%edx
  801b4f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b53:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b57:	83 c0 01             	add    $0x1,%eax
  801b5a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b5d:	83 c7 01             	add    $0x1,%edi
  801b60:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b63:	75 c2                	jne    801b27 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b65:	8b 45 10             	mov    0x10(%ebp),%eax
  801b68:	eb 05                	jmp    801b6f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b6a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b72:	5b                   	pop    %ebx
  801b73:	5e                   	pop    %esi
  801b74:	5f                   	pop    %edi
  801b75:	5d                   	pop    %ebp
  801b76:	c3                   	ret    

00801b77 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	57                   	push   %edi
  801b7b:	56                   	push   %esi
  801b7c:	53                   	push   %ebx
  801b7d:	83 ec 18             	sub    $0x18,%esp
  801b80:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b83:	57                   	push   %edi
  801b84:	e8 8f f6 ff ff       	call   801218 <fd2data>
  801b89:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b8b:	83 c4 10             	add    $0x10,%esp
  801b8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b93:	eb 3d                	jmp    801bd2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b95:	85 db                	test   %ebx,%ebx
  801b97:	74 04                	je     801b9d <devpipe_read+0x26>
				return i;
  801b99:	89 d8                	mov    %ebx,%eax
  801b9b:	eb 44                	jmp    801be1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b9d:	89 f2                	mov    %esi,%edx
  801b9f:	89 f8                	mov    %edi,%eax
  801ba1:	e8 e5 fe ff ff       	call   801a8b <_pipeisclosed>
  801ba6:	85 c0                	test   %eax,%eax
  801ba8:	75 32                	jne    801bdc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801baa:	e8 aa f1 ff ff       	call   800d59 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801baf:	8b 06                	mov    (%esi),%eax
  801bb1:	3b 46 04             	cmp    0x4(%esi),%eax
  801bb4:	74 df                	je     801b95 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bb6:	99                   	cltd   
  801bb7:	c1 ea 1b             	shr    $0x1b,%edx
  801bba:	01 d0                	add    %edx,%eax
  801bbc:	83 e0 1f             	and    $0x1f,%eax
  801bbf:	29 d0                	sub    %edx,%eax
  801bc1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bcc:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bcf:	83 c3 01             	add    $0x1,%ebx
  801bd2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bd5:	75 d8                	jne    801baf <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bd7:	8b 45 10             	mov    0x10(%ebp),%eax
  801bda:	eb 05                	jmp    801be1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bdc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801be1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be4:	5b                   	pop    %ebx
  801be5:	5e                   	pop    %esi
  801be6:	5f                   	pop    %edi
  801be7:	5d                   	pop    %ebp
  801be8:	c3                   	ret    

00801be9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	56                   	push   %esi
  801bed:	53                   	push   %ebx
  801bee:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bf1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf4:	50                   	push   %eax
  801bf5:	e8 35 f6 ff ff       	call   80122f <fd_alloc>
  801bfa:	83 c4 10             	add    $0x10,%esp
  801bfd:	89 c2                	mov    %eax,%edx
  801bff:	85 c0                	test   %eax,%eax
  801c01:	0f 88 2c 01 00 00    	js     801d33 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c07:	83 ec 04             	sub    $0x4,%esp
  801c0a:	68 07 04 00 00       	push   $0x407
  801c0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c12:	6a 00                	push   $0x0
  801c14:	e8 5f f1 ff ff       	call   800d78 <sys_page_alloc>
  801c19:	83 c4 10             	add    $0x10,%esp
  801c1c:	89 c2                	mov    %eax,%edx
  801c1e:	85 c0                	test   %eax,%eax
  801c20:	0f 88 0d 01 00 00    	js     801d33 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c26:	83 ec 0c             	sub    $0xc,%esp
  801c29:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c2c:	50                   	push   %eax
  801c2d:	e8 fd f5 ff ff       	call   80122f <fd_alloc>
  801c32:	89 c3                	mov    %eax,%ebx
  801c34:	83 c4 10             	add    $0x10,%esp
  801c37:	85 c0                	test   %eax,%eax
  801c39:	0f 88 e2 00 00 00    	js     801d21 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c3f:	83 ec 04             	sub    $0x4,%esp
  801c42:	68 07 04 00 00       	push   $0x407
  801c47:	ff 75 f0             	pushl  -0x10(%ebp)
  801c4a:	6a 00                	push   $0x0
  801c4c:	e8 27 f1 ff ff       	call   800d78 <sys_page_alloc>
  801c51:	89 c3                	mov    %eax,%ebx
  801c53:	83 c4 10             	add    $0x10,%esp
  801c56:	85 c0                	test   %eax,%eax
  801c58:	0f 88 c3 00 00 00    	js     801d21 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c5e:	83 ec 0c             	sub    $0xc,%esp
  801c61:	ff 75 f4             	pushl  -0xc(%ebp)
  801c64:	e8 af f5 ff ff       	call   801218 <fd2data>
  801c69:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c6b:	83 c4 0c             	add    $0xc,%esp
  801c6e:	68 07 04 00 00       	push   $0x407
  801c73:	50                   	push   %eax
  801c74:	6a 00                	push   $0x0
  801c76:	e8 fd f0 ff ff       	call   800d78 <sys_page_alloc>
  801c7b:	89 c3                	mov    %eax,%ebx
  801c7d:	83 c4 10             	add    $0x10,%esp
  801c80:	85 c0                	test   %eax,%eax
  801c82:	0f 88 89 00 00 00    	js     801d11 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c88:	83 ec 0c             	sub    $0xc,%esp
  801c8b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c8e:	e8 85 f5 ff ff       	call   801218 <fd2data>
  801c93:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c9a:	50                   	push   %eax
  801c9b:	6a 00                	push   $0x0
  801c9d:	56                   	push   %esi
  801c9e:	6a 00                	push   $0x0
  801ca0:	e8 16 f1 ff ff       	call   800dbb <sys_page_map>
  801ca5:	89 c3                	mov    %eax,%ebx
  801ca7:	83 c4 20             	add    $0x20,%esp
  801caa:	85 c0                	test   %eax,%eax
  801cac:	78 55                	js     801d03 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cae:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cbc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cc3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ccc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cd1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cd8:	83 ec 0c             	sub    $0xc,%esp
  801cdb:	ff 75 f4             	pushl  -0xc(%ebp)
  801cde:	e8 25 f5 ff ff       	call   801208 <fd2num>
  801ce3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ce6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ce8:	83 c4 04             	add    $0x4,%esp
  801ceb:	ff 75 f0             	pushl  -0x10(%ebp)
  801cee:	e8 15 f5 ff ff       	call   801208 <fd2num>
  801cf3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cf6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cf9:	83 c4 10             	add    $0x10,%esp
  801cfc:	ba 00 00 00 00       	mov    $0x0,%edx
  801d01:	eb 30                	jmp    801d33 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d03:	83 ec 08             	sub    $0x8,%esp
  801d06:	56                   	push   %esi
  801d07:	6a 00                	push   $0x0
  801d09:	e8 ef f0 ff ff       	call   800dfd <sys_page_unmap>
  801d0e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d11:	83 ec 08             	sub    $0x8,%esp
  801d14:	ff 75 f0             	pushl  -0x10(%ebp)
  801d17:	6a 00                	push   $0x0
  801d19:	e8 df f0 ff ff       	call   800dfd <sys_page_unmap>
  801d1e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d21:	83 ec 08             	sub    $0x8,%esp
  801d24:	ff 75 f4             	pushl  -0xc(%ebp)
  801d27:	6a 00                	push   $0x0
  801d29:	e8 cf f0 ff ff       	call   800dfd <sys_page_unmap>
  801d2e:	83 c4 10             	add    $0x10,%esp
  801d31:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d33:	89 d0                	mov    %edx,%eax
  801d35:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d38:	5b                   	pop    %ebx
  801d39:	5e                   	pop    %esi
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    

00801d3c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d45:	50                   	push   %eax
  801d46:	ff 75 08             	pushl  0x8(%ebp)
  801d49:	e8 30 f5 ff ff       	call   80127e <fd_lookup>
  801d4e:	83 c4 10             	add    $0x10,%esp
  801d51:	85 c0                	test   %eax,%eax
  801d53:	78 18                	js     801d6d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d55:	83 ec 0c             	sub    $0xc,%esp
  801d58:	ff 75 f4             	pushl  -0xc(%ebp)
  801d5b:	e8 b8 f4 ff ff       	call   801218 <fd2data>
	return _pipeisclosed(fd, p);
  801d60:	89 c2                	mov    %eax,%edx
  801d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d65:	e8 21 fd ff ff       	call   801a8b <_pipeisclosed>
  801d6a:	83 c4 10             	add    $0x10,%esp
}
  801d6d:	c9                   	leave  
  801d6e:	c3                   	ret    

00801d6f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d6f:	55                   	push   %ebp
  801d70:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d72:	b8 00 00 00 00       	mov    $0x0,%eax
  801d77:	5d                   	pop    %ebp
  801d78:	c3                   	ret    

00801d79 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d79:	55                   	push   %ebp
  801d7a:	89 e5                	mov    %esp,%ebp
  801d7c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d7f:	68 cd 28 80 00       	push   $0x8028cd
  801d84:	ff 75 0c             	pushl  0xc(%ebp)
  801d87:	e8 e9 eb ff ff       	call   800975 <strcpy>
	return 0;
}
  801d8c:	b8 00 00 00 00       	mov    $0x0,%eax
  801d91:	c9                   	leave  
  801d92:	c3                   	ret    

00801d93 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
  801d96:	57                   	push   %edi
  801d97:	56                   	push   %esi
  801d98:	53                   	push   %ebx
  801d99:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d9f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801da4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801daa:	eb 2d                	jmp    801dd9 <devcons_write+0x46>
		m = n - tot;
  801dac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801daf:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801db1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801db4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801db9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dbc:	83 ec 04             	sub    $0x4,%esp
  801dbf:	53                   	push   %ebx
  801dc0:	03 45 0c             	add    0xc(%ebp),%eax
  801dc3:	50                   	push   %eax
  801dc4:	57                   	push   %edi
  801dc5:	e8 3d ed ff ff       	call   800b07 <memmove>
		sys_cputs(buf, m);
  801dca:	83 c4 08             	add    $0x8,%esp
  801dcd:	53                   	push   %ebx
  801dce:	57                   	push   %edi
  801dcf:	e8 e8 ee ff ff       	call   800cbc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dd4:	01 de                	add    %ebx,%esi
  801dd6:	83 c4 10             	add    $0x10,%esp
  801dd9:	89 f0                	mov    %esi,%eax
  801ddb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dde:	72 cc                	jb     801dac <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801de0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de3:	5b                   	pop    %ebx
  801de4:	5e                   	pop    %esi
  801de5:	5f                   	pop    %edi
  801de6:	5d                   	pop    %ebp
  801de7:	c3                   	ret    

00801de8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	83 ec 08             	sub    $0x8,%esp
  801dee:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801df3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801df7:	74 2a                	je     801e23 <devcons_read+0x3b>
  801df9:	eb 05                	jmp    801e00 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dfb:	e8 59 ef ff ff       	call   800d59 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e00:	e8 d5 ee ff ff       	call   800cda <sys_cgetc>
  801e05:	85 c0                	test   %eax,%eax
  801e07:	74 f2                	je     801dfb <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e09:	85 c0                	test   %eax,%eax
  801e0b:	78 16                	js     801e23 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e0d:	83 f8 04             	cmp    $0x4,%eax
  801e10:	74 0c                	je     801e1e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e12:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e15:	88 02                	mov    %al,(%edx)
	return 1;
  801e17:	b8 01 00 00 00       	mov    $0x1,%eax
  801e1c:	eb 05                	jmp    801e23 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e1e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e23:	c9                   	leave  
  801e24:	c3                   	ret    

00801e25 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801e25:	55                   	push   %ebp
  801e26:	89 e5                	mov    %esp,%ebp
  801e28:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e31:	6a 01                	push   $0x1
  801e33:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e36:	50                   	push   %eax
  801e37:	e8 80 ee ff ff       	call   800cbc <sys_cputs>
}
  801e3c:	83 c4 10             	add    $0x10,%esp
  801e3f:	c9                   	leave  
  801e40:	c3                   	ret    

00801e41 <getchar>:

int
getchar(void)
{
  801e41:	55                   	push   %ebp
  801e42:	89 e5                	mov    %esp,%ebp
  801e44:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e47:	6a 01                	push   $0x1
  801e49:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e4c:	50                   	push   %eax
  801e4d:	6a 00                	push   $0x0
  801e4f:	e8 90 f6 ff ff       	call   8014e4 <read>
	if (r < 0)
  801e54:	83 c4 10             	add    $0x10,%esp
  801e57:	85 c0                	test   %eax,%eax
  801e59:	78 0f                	js     801e6a <getchar+0x29>
		return r;
	if (r < 1)
  801e5b:	85 c0                	test   %eax,%eax
  801e5d:	7e 06                	jle    801e65 <getchar+0x24>
		return -E_EOF;
	return c;
  801e5f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e63:	eb 05                	jmp    801e6a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e65:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e6a:	c9                   	leave  
  801e6b:	c3                   	ret    

00801e6c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e75:	50                   	push   %eax
  801e76:	ff 75 08             	pushl  0x8(%ebp)
  801e79:	e8 00 f4 ff ff       	call   80127e <fd_lookup>
  801e7e:	83 c4 10             	add    $0x10,%esp
  801e81:	85 c0                	test   %eax,%eax
  801e83:	78 11                	js     801e96 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e88:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e8e:	39 10                	cmp    %edx,(%eax)
  801e90:	0f 94 c0             	sete   %al
  801e93:	0f b6 c0             	movzbl %al,%eax
}
  801e96:	c9                   	leave  
  801e97:	c3                   	ret    

00801e98 <opencons>:

int
opencons(void)
{
  801e98:	55                   	push   %ebp
  801e99:	89 e5                	mov    %esp,%ebp
  801e9b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea1:	50                   	push   %eax
  801ea2:	e8 88 f3 ff ff       	call   80122f <fd_alloc>
  801ea7:	83 c4 10             	add    $0x10,%esp
		return r;
  801eaa:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eac:	85 c0                	test   %eax,%eax
  801eae:	78 3e                	js     801eee <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eb0:	83 ec 04             	sub    $0x4,%esp
  801eb3:	68 07 04 00 00       	push   $0x407
  801eb8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ebb:	6a 00                	push   $0x0
  801ebd:	e8 b6 ee ff ff       	call   800d78 <sys_page_alloc>
  801ec2:	83 c4 10             	add    $0x10,%esp
		return r;
  801ec5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ec7:	85 c0                	test   %eax,%eax
  801ec9:	78 23                	js     801eee <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ecb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ee0:	83 ec 0c             	sub    $0xc,%esp
  801ee3:	50                   	push   %eax
  801ee4:	e8 1f f3 ff ff       	call   801208 <fd2num>
  801ee9:	89 c2                	mov    %eax,%edx
  801eeb:	83 c4 10             	add    $0x10,%esp
}
  801eee:	89 d0                	mov    %edx,%eax
  801ef0:	c9                   	leave  
  801ef1:	c3                   	ret    

00801ef2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ef2:	55                   	push   %ebp
  801ef3:	89 e5                	mov    %esp,%ebp
  801ef5:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ef8:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801eff:	75 4a                	jne    801f4b <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  801f01:	a1 04 40 80 00       	mov    0x804004,%eax
  801f06:	8b 40 48             	mov    0x48(%eax),%eax
  801f09:	83 ec 04             	sub    $0x4,%esp
  801f0c:	6a 07                	push   $0x7
  801f0e:	68 00 f0 bf ee       	push   $0xeebff000
  801f13:	50                   	push   %eax
  801f14:	e8 5f ee ff ff       	call   800d78 <sys_page_alloc>
  801f19:	83 c4 10             	add    $0x10,%esp
  801f1c:	85 c0                	test   %eax,%eax
  801f1e:	79 12                	jns    801f32 <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  801f20:	50                   	push   %eax
  801f21:	68 d9 28 80 00       	push   $0x8028d9
  801f26:	6a 21                	push   $0x21
  801f28:	68 f1 28 80 00       	push   $0x8028f1
  801f2d:	e8 66 e3 ff ff       	call   800298 <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801f32:	a1 04 40 80 00       	mov    0x804004,%eax
  801f37:	8b 40 48             	mov    0x48(%eax),%eax
  801f3a:	83 ec 08             	sub    $0x8,%esp
  801f3d:	68 55 1f 80 00       	push   $0x801f55
  801f42:	50                   	push   %eax
  801f43:	e8 7b ef ff ff       	call   800ec3 <sys_env_set_pgfault_upcall>
  801f48:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4e:	a3 00 60 80 00       	mov    %eax,0x806000
  801f53:	c9                   	leave  
  801f54:	c3                   	ret    

00801f55 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f55:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f56:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f5b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f5d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  801f60:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  801f63:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  801f67:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  801f6c:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  801f70:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801f72:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  801f73:	83 c4 04             	add    $0x4,%esp
	popfl
  801f76:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f77:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  801f78:	c3                   	ret    

00801f79 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f79:	55                   	push   %ebp
  801f7a:	89 e5                	mov    %esp,%ebp
  801f7c:	56                   	push   %esi
  801f7d:	53                   	push   %ebx
  801f7e:	8b 75 08             	mov    0x8(%ebp),%esi
  801f81:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801f87:	85 c0                	test   %eax,%eax
  801f89:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f8e:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801f91:	83 ec 0c             	sub    $0xc,%esp
  801f94:	50                   	push   %eax
  801f95:	e8 8e ef ff ff       	call   800f28 <sys_ipc_recv>
  801f9a:	83 c4 10             	add    $0x10,%esp
  801f9d:	85 c0                	test   %eax,%eax
  801f9f:	79 16                	jns    801fb7 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801fa1:	85 f6                	test   %esi,%esi
  801fa3:	74 06                	je     801fab <ipc_recv+0x32>
            *from_env_store = 0;
  801fa5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801fab:	85 db                	test   %ebx,%ebx
  801fad:	74 2c                	je     801fdb <ipc_recv+0x62>
            *perm_store = 0;
  801faf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801fb5:	eb 24                	jmp    801fdb <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801fb7:	85 f6                	test   %esi,%esi
  801fb9:	74 0a                	je     801fc5 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801fbb:	a1 04 40 80 00       	mov    0x804004,%eax
  801fc0:	8b 40 74             	mov    0x74(%eax),%eax
  801fc3:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801fc5:	85 db                	test   %ebx,%ebx
  801fc7:	74 0a                	je     801fd3 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801fc9:	a1 04 40 80 00       	mov    0x804004,%eax
  801fce:	8b 40 78             	mov    0x78(%eax),%eax
  801fd1:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801fd3:	a1 04 40 80 00       	mov    0x804004,%eax
  801fd8:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801fdb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fde:	5b                   	pop    %ebx
  801fdf:	5e                   	pop    %esi
  801fe0:	5d                   	pop    %ebp
  801fe1:	c3                   	ret    

00801fe2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fe2:	55                   	push   %ebp
  801fe3:	89 e5                	mov    %esp,%ebp
  801fe5:	57                   	push   %edi
  801fe6:	56                   	push   %esi
  801fe7:	53                   	push   %ebx
  801fe8:	83 ec 0c             	sub    $0xc,%esp
  801feb:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fee:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ff1:	8b 45 10             	mov    0x10(%ebp),%eax
  801ff4:	85 c0                	test   %eax,%eax
  801ff6:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ffb:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801ffe:	eb 1c                	jmp    80201c <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  802000:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802003:	74 12                	je     802017 <ipc_send+0x35>
  802005:	50                   	push   %eax
  802006:	68 ff 28 80 00       	push   $0x8028ff
  80200b:	6a 3a                	push   $0x3a
  80200d:	68 15 29 80 00       	push   $0x802915
  802012:	e8 81 e2 ff ff       	call   800298 <_panic>
		sys_yield();
  802017:	e8 3d ed ff ff       	call   800d59 <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80201c:	ff 75 14             	pushl  0x14(%ebp)
  80201f:	53                   	push   %ebx
  802020:	56                   	push   %esi
  802021:	57                   	push   %edi
  802022:	e8 de ee ff ff       	call   800f05 <sys_ipc_try_send>
  802027:	83 c4 10             	add    $0x10,%esp
  80202a:	85 c0                	test   %eax,%eax
  80202c:	78 d2                	js     802000 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  80202e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802031:	5b                   	pop    %ebx
  802032:	5e                   	pop    %esi
  802033:	5f                   	pop    %edi
  802034:	5d                   	pop    %ebp
  802035:	c3                   	ret    

00802036 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802036:	55                   	push   %ebp
  802037:	89 e5                	mov    %esp,%ebp
  802039:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80203c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802041:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802044:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80204a:	8b 52 50             	mov    0x50(%edx),%edx
  80204d:	39 ca                	cmp    %ecx,%edx
  80204f:	75 0d                	jne    80205e <ipc_find_env+0x28>
			return envs[i].env_id;
  802051:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802054:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802059:	8b 40 48             	mov    0x48(%eax),%eax
  80205c:	eb 0f                	jmp    80206d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80205e:	83 c0 01             	add    $0x1,%eax
  802061:	3d 00 04 00 00       	cmp    $0x400,%eax
  802066:	75 d9                	jne    802041 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802068:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80206d:	5d                   	pop    %ebp
  80206e:	c3                   	ret    

0080206f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80206f:	55                   	push   %ebp
  802070:	89 e5                	mov    %esp,%ebp
  802072:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802075:	89 d0                	mov    %edx,%eax
  802077:	c1 e8 16             	shr    $0x16,%eax
  80207a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802081:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802086:	f6 c1 01             	test   $0x1,%cl
  802089:	74 1d                	je     8020a8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80208b:	c1 ea 0c             	shr    $0xc,%edx
  80208e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802095:	f6 c2 01             	test   $0x1,%dl
  802098:	74 0e                	je     8020a8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80209a:	c1 ea 0c             	shr    $0xc,%edx
  80209d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020a4:	ef 
  8020a5:	0f b7 c0             	movzwl %ax,%eax
}
  8020a8:	5d                   	pop    %ebp
  8020a9:	c3                   	ret    
  8020aa:	66 90                	xchg   %ax,%ax
  8020ac:	66 90                	xchg   %ax,%ax
  8020ae:	66 90                	xchg   %ax,%ax

008020b0 <__udivdi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 1c             	sub    $0x1c,%esp
  8020b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020c7:	85 f6                	test   %esi,%esi
  8020c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020cd:	89 ca                	mov    %ecx,%edx
  8020cf:	89 f8                	mov    %edi,%eax
  8020d1:	75 3d                	jne    802110 <__udivdi3+0x60>
  8020d3:	39 cf                	cmp    %ecx,%edi
  8020d5:	0f 87 c5 00 00 00    	ja     8021a0 <__udivdi3+0xf0>
  8020db:	85 ff                	test   %edi,%edi
  8020dd:	89 fd                	mov    %edi,%ebp
  8020df:	75 0b                	jne    8020ec <__udivdi3+0x3c>
  8020e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e6:	31 d2                	xor    %edx,%edx
  8020e8:	f7 f7                	div    %edi
  8020ea:	89 c5                	mov    %eax,%ebp
  8020ec:	89 c8                	mov    %ecx,%eax
  8020ee:	31 d2                	xor    %edx,%edx
  8020f0:	f7 f5                	div    %ebp
  8020f2:	89 c1                	mov    %eax,%ecx
  8020f4:	89 d8                	mov    %ebx,%eax
  8020f6:	89 cf                	mov    %ecx,%edi
  8020f8:	f7 f5                	div    %ebp
  8020fa:	89 c3                	mov    %eax,%ebx
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	89 fa                	mov    %edi,%edx
  802100:	83 c4 1c             	add    $0x1c,%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    
  802108:	90                   	nop
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	39 ce                	cmp    %ecx,%esi
  802112:	77 74                	ja     802188 <__udivdi3+0xd8>
  802114:	0f bd fe             	bsr    %esi,%edi
  802117:	83 f7 1f             	xor    $0x1f,%edi
  80211a:	0f 84 98 00 00 00    	je     8021b8 <__udivdi3+0x108>
  802120:	bb 20 00 00 00       	mov    $0x20,%ebx
  802125:	89 f9                	mov    %edi,%ecx
  802127:	89 c5                	mov    %eax,%ebp
  802129:	29 fb                	sub    %edi,%ebx
  80212b:	d3 e6                	shl    %cl,%esi
  80212d:	89 d9                	mov    %ebx,%ecx
  80212f:	d3 ed                	shr    %cl,%ebp
  802131:	89 f9                	mov    %edi,%ecx
  802133:	d3 e0                	shl    %cl,%eax
  802135:	09 ee                	or     %ebp,%esi
  802137:	89 d9                	mov    %ebx,%ecx
  802139:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80213d:	89 d5                	mov    %edx,%ebp
  80213f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802143:	d3 ed                	shr    %cl,%ebp
  802145:	89 f9                	mov    %edi,%ecx
  802147:	d3 e2                	shl    %cl,%edx
  802149:	89 d9                	mov    %ebx,%ecx
  80214b:	d3 e8                	shr    %cl,%eax
  80214d:	09 c2                	or     %eax,%edx
  80214f:	89 d0                	mov    %edx,%eax
  802151:	89 ea                	mov    %ebp,%edx
  802153:	f7 f6                	div    %esi
  802155:	89 d5                	mov    %edx,%ebp
  802157:	89 c3                	mov    %eax,%ebx
  802159:	f7 64 24 0c          	mull   0xc(%esp)
  80215d:	39 d5                	cmp    %edx,%ebp
  80215f:	72 10                	jb     802171 <__udivdi3+0xc1>
  802161:	8b 74 24 08          	mov    0x8(%esp),%esi
  802165:	89 f9                	mov    %edi,%ecx
  802167:	d3 e6                	shl    %cl,%esi
  802169:	39 c6                	cmp    %eax,%esi
  80216b:	73 07                	jae    802174 <__udivdi3+0xc4>
  80216d:	39 d5                	cmp    %edx,%ebp
  80216f:	75 03                	jne    802174 <__udivdi3+0xc4>
  802171:	83 eb 01             	sub    $0x1,%ebx
  802174:	31 ff                	xor    %edi,%edi
  802176:	89 d8                	mov    %ebx,%eax
  802178:	89 fa                	mov    %edi,%edx
  80217a:	83 c4 1c             	add    $0x1c,%esp
  80217d:	5b                   	pop    %ebx
  80217e:	5e                   	pop    %esi
  80217f:	5f                   	pop    %edi
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    
  802182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802188:	31 ff                	xor    %edi,%edi
  80218a:	31 db                	xor    %ebx,%ebx
  80218c:	89 d8                	mov    %ebx,%eax
  80218e:	89 fa                	mov    %edi,%edx
  802190:	83 c4 1c             	add    $0x1c,%esp
  802193:	5b                   	pop    %ebx
  802194:	5e                   	pop    %esi
  802195:	5f                   	pop    %edi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    
  802198:	90                   	nop
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	89 d8                	mov    %ebx,%eax
  8021a2:	f7 f7                	div    %edi
  8021a4:	31 ff                	xor    %edi,%edi
  8021a6:	89 c3                	mov    %eax,%ebx
  8021a8:	89 d8                	mov    %ebx,%eax
  8021aa:	89 fa                	mov    %edi,%edx
  8021ac:	83 c4 1c             	add    $0x1c,%esp
  8021af:	5b                   	pop    %ebx
  8021b0:	5e                   	pop    %esi
  8021b1:	5f                   	pop    %edi
  8021b2:	5d                   	pop    %ebp
  8021b3:	c3                   	ret    
  8021b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	39 ce                	cmp    %ecx,%esi
  8021ba:	72 0c                	jb     8021c8 <__udivdi3+0x118>
  8021bc:	31 db                	xor    %ebx,%ebx
  8021be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021c2:	0f 87 34 ff ff ff    	ja     8020fc <__udivdi3+0x4c>
  8021c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021cd:	e9 2a ff ff ff       	jmp    8020fc <__udivdi3+0x4c>
  8021d2:	66 90                	xchg   %ax,%ax
  8021d4:	66 90                	xchg   %ax,%ax
  8021d6:	66 90                	xchg   %ax,%ax
  8021d8:	66 90                	xchg   %ax,%ax
  8021da:	66 90                	xchg   %ax,%ax
  8021dc:	66 90                	xchg   %ax,%ax
  8021de:	66 90                	xchg   %ax,%ax

008021e0 <__umoddi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 1c             	sub    $0x1c,%esp
  8021e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f7:	85 d2                	test   %edx,%edx
  8021f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802201:	89 f3                	mov    %esi,%ebx
  802203:	89 3c 24             	mov    %edi,(%esp)
  802206:	89 74 24 04          	mov    %esi,0x4(%esp)
  80220a:	75 1c                	jne    802228 <__umoddi3+0x48>
  80220c:	39 f7                	cmp    %esi,%edi
  80220e:	76 50                	jbe    802260 <__umoddi3+0x80>
  802210:	89 c8                	mov    %ecx,%eax
  802212:	89 f2                	mov    %esi,%edx
  802214:	f7 f7                	div    %edi
  802216:	89 d0                	mov    %edx,%eax
  802218:	31 d2                	xor    %edx,%edx
  80221a:	83 c4 1c             	add    $0x1c,%esp
  80221d:	5b                   	pop    %ebx
  80221e:	5e                   	pop    %esi
  80221f:	5f                   	pop    %edi
  802220:	5d                   	pop    %ebp
  802221:	c3                   	ret    
  802222:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802228:	39 f2                	cmp    %esi,%edx
  80222a:	89 d0                	mov    %edx,%eax
  80222c:	77 52                	ja     802280 <__umoddi3+0xa0>
  80222e:	0f bd ea             	bsr    %edx,%ebp
  802231:	83 f5 1f             	xor    $0x1f,%ebp
  802234:	75 5a                	jne    802290 <__umoddi3+0xb0>
  802236:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80223a:	0f 82 e0 00 00 00    	jb     802320 <__umoddi3+0x140>
  802240:	39 0c 24             	cmp    %ecx,(%esp)
  802243:	0f 86 d7 00 00 00    	jbe    802320 <__umoddi3+0x140>
  802249:	8b 44 24 08          	mov    0x8(%esp),%eax
  80224d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802251:	83 c4 1c             	add    $0x1c,%esp
  802254:	5b                   	pop    %ebx
  802255:	5e                   	pop    %esi
  802256:	5f                   	pop    %edi
  802257:	5d                   	pop    %ebp
  802258:	c3                   	ret    
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	85 ff                	test   %edi,%edi
  802262:	89 fd                	mov    %edi,%ebp
  802264:	75 0b                	jne    802271 <__umoddi3+0x91>
  802266:	b8 01 00 00 00       	mov    $0x1,%eax
  80226b:	31 d2                	xor    %edx,%edx
  80226d:	f7 f7                	div    %edi
  80226f:	89 c5                	mov    %eax,%ebp
  802271:	89 f0                	mov    %esi,%eax
  802273:	31 d2                	xor    %edx,%edx
  802275:	f7 f5                	div    %ebp
  802277:	89 c8                	mov    %ecx,%eax
  802279:	f7 f5                	div    %ebp
  80227b:	89 d0                	mov    %edx,%eax
  80227d:	eb 99                	jmp    802218 <__umoddi3+0x38>
  80227f:	90                   	nop
  802280:	89 c8                	mov    %ecx,%eax
  802282:	89 f2                	mov    %esi,%edx
  802284:	83 c4 1c             	add    $0x1c,%esp
  802287:	5b                   	pop    %ebx
  802288:	5e                   	pop    %esi
  802289:	5f                   	pop    %edi
  80228a:	5d                   	pop    %ebp
  80228b:	c3                   	ret    
  80228c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802290:	8b 34 24             	mov    (%esp),%esi
  802293:	bf 20 00 00 00       	mov    $0x20,%edi
  802298:	89 e9                	mov    %ebp,%ecx
  80229a:	29 ef                	sub    %ebp,%edi
  80229c:	d3 e0                	shl    %cl,%eax
  80229e:	89 f9                	mov    %edi,%ecx
  8022a0:	89 f2                	mov    %esi,%edx
  8022a2:	d3 ea                	shr    %cl,%edx
  8022a4:	89 e9                	mov    %ebp,%ecx
  8022a6:	09 c2                	or     %eax,%edx
  8022a8:	89 d8                	mov    %ebx,%eax
  8022aa:	89 14 24             	mov    %edx,(%esp)
  8022ad:	89 f2                	mov    %esi,%edx
  8022af:	d3 e2                	shl    %cl,%edx
  8022b1:	89 f9                	mov    %edi,%ecx
  8022b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022bb:	d3 e8                	shr    %cl,%eax
  8022bd:	89 e9                	mov    %ebp,%ecx
  8022bf:	89 c6                	mov    %eax,%esi
  8022c1:	d3 e3                	shl    %cl,%ebx
  8022c3:	89 f9                	mov    %edi,%ecx
  8022c5:	89 d0                	mov    %edx,%eax
  8022c7:	d3 e8                	shr    %cl,%eax
  8022c9:	89 e9                	mov    %ebp,%ecx
  8022cb:	09 d8                	or     %ebx,%eax
  8022cd:	89 d3                	mov    %edx,%ebx
  8022cf:	89 f2                	mov    %esi,%edx
  8022d1:	f7 34 24             	divl   (%esp)
  8022d4:	89 d6                	mov    %edx,%esi
  8022d6:	d3 e3                	shl    %cl,%ebx
  8022d8:	f7 64 24 04          	mull   0x4(%esp)
  8022dc:	39 d6                	cmp    %edx,%esi
  8022de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022e2:	89 d1                	mov    %edx,%ecx
  8022e4:	89 c3                	mov    %eax,%ebx
  8022e6:	72 08                	jb     8022f0 <__umoddi3+0x110>
  8022e8:	75 11                	jne    8022fb <__umoddi3+0x11b>
  8022ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ee:	73 0b                	jae    8022fb <__umoddi3+0x11b>
  8022f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022f4:	1b 14 24             	sbb    (%esp),%edx
  8022f7:	89 d1                	mov    %edx,%ecx
  8022f9:	89 c3                	mov    %eax,%ebx
  8022fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022ff:	29 da                	sub    %ebx,%edx
  802301:	19 ce                	sbb    %ecx,%esi
  802303:	89 f9                	mov    %edi,%ecx
  802305:	89 f0                	mov    %esi,%eax
  802307:	d3 e0                	shl    %cl,%eax
  802309:	89 e9                	mov    %ebp,%ecx
  80230b:	d3 ea                	shr    %cl,%edx
  80230d:	89 e9                	mov    %ebp,%ecx
  80230f:	d3 ee                	shr    %cl,%esi
  802311:	09 d0                	or     %edx,%eax
  802313:	89 f2                	mov    %esi,%edx
  802315:	83 c4 1c             	add    $0x1c,%esp
  802318:	5b                   	pop    %ebx
  802319:	5e                   	pop    %esi
  80231a:	5f                   	pop    %edi
  80231b:	5d                   	pop    %ebp
  80231c:	c3                   	ret    
  80231d:	8d 76 00             	lea    0x0(%esi),%esi
  802320:	29 f9                	sub    %edi,%ecx
  802322:	19 d6                	sbb    %edx,%esi
  802324:	89 74 24 04          	mov    %esi,0x4(%esp)
  802328:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80232c:	e9 18 ff ff ff       	jmp    802249 <__umoddi3+0x69>
