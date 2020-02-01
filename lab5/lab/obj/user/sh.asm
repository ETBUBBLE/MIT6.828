
obj/user/sh.debug：     文件格式 elf32-i386


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
  80002c:	e8 83 09 00 00       	call   8009b4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int t;

	if (s == 0) {
  800042:	85 db                	test   %ebx,%ebx
  800044:	75 2c                	jne    800072 <_gettoken+0x3f>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
_gettoken(char *s, char **p1, char **p2)
{
	int t;

	if (s == 0) {
		if (debug > 1)
  80004b:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800052:	0f 8e 3e 01 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("GETTOKEN NULL\n");
  800058:	83 ec 0c             	sub    $0xc,%esp
  80005b:	68 c0 32 80 00       	push   $0x8032c0
  800060:	e8 88 0a 00 00       	call   800aed <cprintf>
  800065:	83 c4 10             	add    $0x10,%esp
		return 0;
  800068:	b8 00 00 00 00       	mov    $0x0,%eax
  80006d:	e9 24 01 00 00       	jmp    800196 <_gettoken+0x163>
	}

	if (debug > 1)
  800072:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800079:	7e 11                	jle    80008c <_gettoken+0x59>
		cprintf("GETTOKEN: %s\n", s);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	53                   	push   %ebx
  80007f:	68 cf 32 80 00       	push   $0x8032cf
  800084:	e8 64 0a 00 00       	call   800aed <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp

	*p1 = 0;
  80008c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	*p2 = 0;
  800092:	8b 45 10             	mov    0x10(%ebp),%eax
  800095:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80009b:	eb 07                	jmp    8000a4 <_gettoken+0x71>
		*s++ = 0;
  80009d:	83 c3 01             	add    $0x1,%ebx
  8000a0:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	0f be 03             	movsbl (%ebx),%eax
  8000aa:	50                   	push   %eax
  8000ab:	68 dd 32 80 00       	push   $0x8032dd
  8000b0:	e8 37 12 00 00       	call   8012ec <strchr>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	85 c0                	test   %eax,%eax
  8000ba:	75 e1                	jne    80009d <_gettoken+0x6a>
		*s++ = 0;
	if (*s == 0) {
  8000bc:	0f b6 03             	movzbl (%ebx),%eax
  8000bf:	84 c0                	test   %al,%al
  8000c1:	75 2c                	jne    8000ef <_gettoken+0xbc>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
  8000c8:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000cf:	0f 8e c1 00 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("EOL\n");
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	68 e2 32 80 00       	push   $0x8032e2
  8000dd:	e8 0b 0a 00 00       	call   800aed <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ea:	e9 a7 00 00 00       	jmp    800196 <_gettoken+0x163>
	}
	if (strchr(SYMBOLS, *s)) {
  8000ef:	83 ec 08             	sub    $0x8,%esp
  8000f2:	0f be c0             	movsbl %al,%eax
  8000f5:	50                   	push   %eax
  8000f6:	68 f3 32 80 00       	push   $0x8032f3
  8000fb:	e8 ec 11 00 00       	call   8012ec <strchr>
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	85 c0                	test   %eax,%eax
  800105:	74 30                	je     800137 <_gettoken+0x104>
		t = *s;
  800107:	0f be 3b             	movsbl (%ebx),%edi
		*p1 = s;
  80010a:	89 1e                	mov    %ebx,(%esi)
		*s++ = 0;
  80010c:	c6 03 00             	movb   $0x0,(%ebx)
		*p2 = s;
  80010f:	83 c3 01             	add    $0x1,%ebx
  800112:	8b 45 10             	mov    0x10(%ebp),%eax
  800115:	89 18                	mov    %ebx,(%eax)
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
  800117:	89 f8                	mov    %edi,%eax
	if (strchr(SYMBOLS, *s)) {
		t = *s;
		*p1 = s;
		*s++ = 0;
		*p2 = s;
		if (debug > 1)
  800119:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800120:	7e 74                	jle    800196 <_gettoken+0x163>
			cprintf("TOK %c\n", t);
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	57                   	push   %edi
  800126:	68 e7 32 80 00       	push   $0x8032e7
  80012b:	e8 bd 09 00 00       	call   800aed <cprintf>
  800130:	83 c4 10             	add    $0x10,%esp
		return t;
  800133:	89 f8                	mov    %edi,%eax
  800135:	eb 5f                	jmp    800196 <_gettoken+0x163>
	}
	*p1 = s;
  800137:	89 1e                	mov    %ebx,(%esi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800139:	eb 03                	jmp    80013e <_gettoken+0x10b>
		s++;
  80013b:	83 c3 01             	add    $0x1,%ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80013e:	0f b6 03             	movzbl (%ebx),%eax
  800141:	84 c0                	test   %al,%al
  800143:	74 18                	je     80015d <_gettoken+0x12a>
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	0f be c0             	movsbl %al,%eax
  80014b:	50                   	push   %eax
  80014c:	68 ef 32 80 00       	push   $0x8032ef
  800151:	e8 96 11 00 00       	call   8012ec <strchr>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	74 de                	je     80013b <_gettoken+0x108>
		s++;
	*p2 = s;
  80015d:	8b 45 10             	mov    0x10(%ebp),%eax
  800160:	89 18                	mov    %ebx,(%eax)
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  800162:	b8 77 00 00 00       	mov    $0x77,%eax
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
		s++;
	*p2 = s;
	if (debug > 1) {
  800167:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80016e:	7e 26                	jle    800196 <_gettoken+0x163>
		t = **p2;
  800170:	0f b6 3b             	movzbl (%ebx),%edi
		**p2 = 0;
  800173:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  800176:	83 ec 08             	sub    $0x8,%esp
  800179:	ff 36                	pushl  (%esi)
  80017b:	68 fb 32 80 00       	push   $0x8032fb
  800180:	e8 68 09 00 00       	call   800aed <cprintf>
		**p2 = t;
  800185:	8b 45 10             	mov    0x10(%ebp),%eax
  800188:	8b 00                	mov    (%eax),%eax
  80018a:	89 fa                	mov    %edi,%edx
  80018c:	88 10                	mov    %dl,(%eax)
  80018e:	83 c4 10             	add    $0x10,%esp
	}
	return 'w';
  800191:	b8 77 00 00 00       	mov    $0x77,%eax
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <gettoken>:

int
gettoken(char *s, char **p1)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	74 22                	je     8001cd <gettoken+0x2f>
		nc = _gettoken(s, &np1, &np2);
  8001ab:	83 ec 04             	sub    $0x4,%esp
  8001ae:	68 0c 50 80 00       	push   $0x80500c
  8001b3:	68 10 50 80 00       	push   $0x805010
  8001b8:	50                   	push   %eax
  8001b9:	e8 75 fe ff ff       	call   800033 <_gettoken>
  8001be:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8001cb:	eb 3a                	jmp    800207 <gettoken+0x69>
	}
	c = nc;
  8001cd:	a1 08 50 80 00       	mov    0x805008,%eax
  8001d2:	a3 04 50 80 00       	mov    %eax,0x805004
	*p1 = np1;
  8001d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001da:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001e0:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001e2:	83 ec 04             	sub    $0x4,%esp
  8001e5:	68 0c 50 80 00       	push   $0x80500c
  8001ea:	68 10 50 80 00       	push   $0x805010
  8001ef:	ff 35 0c 50 80 00    	pushl  0x80500c
  8001f5:	e8 39 fe ff ff       	call   800033 <_gettoken>
  8001fa:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  8001ff:	a1 04 50 80 00       	mov    0x805004,%eax
  800204:	83 c4 10             	add    $0x10,%esp
}
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	81 ec 64 04 00 00    	sub    $0x464,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  800215:	6a 00                	push   $0x0
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	e8 7f ff ff ff       	call   80019e <gettoken>
  80021f:	83 c4 10             	add    $0x10,%esp

again:
	argc = 0;
	while (1) {
		switch ((c = gettoken(0, &t))) {
  800222:	8d 5d a4             	lea    -0x5c(%ebp),%ebx

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  800225:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	53                   	push   %ebx
  80022e:	6a 00                	push   $0x0
  800230:	e8 69 ff ff ff       	call   80019e <gettoken>
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	83 f8 3e             	cmp    $0x3e,%eax
  80023b:	0f 84 cb 00 00 00    	je     80030c <runcmd+0x103>
  800241:	83 f8 3e             	cmp    $0x3e,%eax
  800244:	7f 12                	jg     800258 <runcmd+0x4f>
  800246:	85 c0                	test   %eax,%eax
  800248:	0f 84 3a 02 00 00    	je     800488 <runcmd+0x27f>
  80024e:	83 f8 3c             	cmp    $0x3c,%eax
  800251:	74 3e                	je     800291 <runcmd+0x88>
  800253:	e9 1e 02 00 00       	jmp    800476 <runcmd+0x26d>
  800258:	83 f8 77             	cmp    $0x77,%eax
  80025b:	74 0e                	je     80026b <runcmd+0x62>
  80025d:	83 f8 7c             	cmp    $0x7c,%eax
  800260:	0f 84 24 01 00 00    	je     80038a <runcmd+0x181>
  800266:	e9 0b 02 00 00       	jmp    800476 <runcmd+0x26d>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  80026b:	83 fe 10             	cmp    $0x10,%esi
  80026e:	75 15                	jne    800285 <runcmd+0x7c>
				cprintf("too many arguments\n");
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	68 05 33 80 00       	push   $0x803305
  800278:	e8 70 08 00 00       	call   800aed <cprintf>
				exit();
  80027d:	e8 78 07 00 00       	call   8009fa <exit>
  800282:	83 c4 10             	add    $0x10,%esp
			}
			argv[argc++] = t;
  800285:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800288:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  80028c:	8d 76 01             	lea    0x1(%esi),%esi
			break;
  80028f:	eb 99                	jmp    80022a <runcmd+0x21>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	53                   	push   %ebx
  800295:	6a 00                	push   $0x0
  800297:	e8 02 ff ff ff       	call   80019e <gettoken>
  80029c:	83 c4 10             	add    $0x10,%esp
  80029f:	83 f8 77             	cmp    $0x77,%eax
  8002a2:	74 15                	je     8002b9 <runcmd+0xb0>
				cprintf("syntax error: < not followed by word\n");
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	68 44 34 80 00       	push   $0x803444
  8002ac:	e8 3c 08 00 00       	call   800aed <cprintf>
				exit();
  8002b1:	e8 44 07 00 00       	call   8009fa <exit>
  8002b6:	83 c4 10             	add    $0x10,%esp
			// then check whether 'fd' is 0.
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			if ((fd = open(t, O_RDONLY)) < 0) {
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	6a 00                	push   $0x0
  8002be:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002c1:	e8 6c 20 00 00       	call   802332 <open>
  8002c6:	89 c7                	mov    %eax,%edi
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	79 19                	jns    8002e8 <runcmd+0xdf>
				cprintf("open %s for write: %e", t, fd);
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	50                   	push   %eax
  8002d3:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d6:	68 19 33 80 00       	push   $0x803319
  8002db:	e8 0d 08 00 00       	call   800aed <cprintf>
				exit();
  8002e0:	e8 15 07 00 00       	call   8009fa <exit>
  8002e5:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  8002e8:	83 ff 01             	cmp    $0x1,%edi
  8002eb:	0f 84 39 ff ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 0);
  8002f1:	83 ec 08             	sub    $0x8,%esp
  8002f4:	6a 00                	push   $0x0
  8002f6:	57                   	push   %edi
  8002f7:	e8 bf 1a 00 00       	call   801dbb <dup>
				close(fd);
  8002fc:	89 3c 24             	mov    %edi,(%esp)
  8002ff:	e8 67 1a 00 00       	call   801d6b <close>
  800304:	83 c4 10             	add    $0x10,%esp
  800307:	e9 1e ff ff ff       	jmp    80022a <runcmd+0x21>
			//panic("< redirection not implemented");
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  80030c:	83 ec 08             	sub    $0x8,%esp
  80030f:	53                   	push   %ebx
  800310:	6a 00                	push   $0x0
  800312:	e8 87 fe ff ff       	call   80019e <gettoken>
  800317:	83 c4 10             	add    $0x10,%esp
  80031a:	83 f8 77             	cmp    $0x77,%eax
  80031d:	74 15                	je     800334 <runcmd+0x12b>
				cprintf("syntax error: > not followed by word\n");
  80031f:	83 ec 0c             	sub    $0xc,%esp
  800322:	68 6c 34 80 00       	push   $0x80346c
  800327:	e8 c1 07 00 00       	call   800aed <cprintf>
				exit();
  80032c:	e8 c9 06 00 00       	call   8009fa <exit>
  800331:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800334:	83 ec 08             	sub    $0x8,%esp
  800337:	68 01 03 00 00       	push   $0x301
  80033c:	ff 75 a4             	pushl  -0x5c(%ebp)
  80033f:	e8 ee 1f 00 00       	call   802332 <open>
  800344:	89 c7                	mov    %eax,%edi
  800346:	83 c4 10             	add    $0x10,%esp
  800349:	85 c0                	test   %eax,%eax
  80034b:	79 19                	jns    800366 <runcmd+0x15d>
				cprintf("open %s for write: %e", t, fd);
  80034d:	83 ec 04             	sub    $0x4,%esp
  800350:	50                   	push   %eax
  800351:	ff 75 a4             	pushl  -0x5c(%ebp)
  800354:	68 19 33 80 00       	push   $0x803319
  800359:	e8 8f 07 00 00       	call   800aed <cprintf>
				exit();
  80035e:	e8 97 06 00 00       	call   8009fa <exit>
  800363:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  800366:	83 ff 01             	cmp    $0x1,%edi
  800369:	0f 84 bb fe ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 1);
  80036f:	83 ec 08             	sub    $0x8,%esp
  800372:	6a 01                	push   $0x1
  800374:	57                   	push   %edi
  800375:	e8 41 1a 00 00       	call   801dbb <dup>
				close(fd);
  80037a:	89 3c 24             	mov    %edi,(%esp)
  80037d:	e8 e9 19 00 00       	call   801d6b <close>
  800382:	83 c4 10             	add    $0x10,%esp
  800385:	e9 a0 fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038a:	83 ec 0c             	sub    $0xc,%esp
  80038d:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800393:	50                   	push   %eax
  800394:	e8 fe 28 00 00       	call   802c97 <pipe>
  800399:	83 c4 10             	add    $0x10,%esp
  80039c:	85 c0                	test   %eax,%eax
  80039e:	79 16                	jns    8003b6 <runcmd+0x1ad>
				cprintf("pipe: %e", r);
  8003a0:	83 ec 08             	sub    $0x8,%esp
  8003a3:	50                   	push   %eax
  8003a4:	68 2f 33 80 00       	push   $0x80332f
  8003a9:	e8 3f 07 00 00       	call   800aed <cprintf>
				exit();
  8003ae:	e8 47 06 00 00       	call   8009fa <exit>
  8003b3:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  8003b6:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8003bd:	74 1c                	je     8003db <runcmd+0x1d2>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003bf:	83 ec 04             	sub    $0x4,%esp
  8003c2:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003c8:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003ce:	68 38 33 80 00       	push   $0x803338
  8003d3:	e8 15 07 00 00       	call   800aed <cprintf>
  8003d8:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003db:	e8 ea 14 00 00       	call   8018ca <fork>
  8003e0:	89 c7                	mov    %eax,%edi
  8003e2:	85 c0                	test   %eax,%eax
  8003e4:	79 16                	jns    8003fc <runcmd+0x1f3>
				cprintf("fork: %e", r);
  8003e6:	83 ec 08             	sub    $0x8,%esp
  8003e9:	50                   	push   %eax
  8003ea:	68 45 33 80 00       	push   $0x803345
  8003ef:	e8 f9 06 00 00       	call   800aed <cprintf>
				exit();
  8003f4:	e8 01 06 00 00       	call   8009fa <exit>
  8003f9:	83 c4 10             	add    $0x10,%esp
			}
			if (r == 0) {
  8003fc:	85 ff                	test   %edi,%edi
  8003fe:	75 3c                	jne    80043c <runcmd+0x233>
				if (p[0] != 0) {
  800400:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800406:	85 c0                	test   %eax,%eax
  800408:	74 1c                	je     800426 <runcmd+0x21d>
					dup(p[0], 0);
  80040a:	83 ec 08             	sub    $0x8,%esp
  80040d:	6a 00                	push   $0x0
  80040f:	50                   	push   %eax
  800410:	e8 a6 19 00 00       	call   801dbb <dup>
					close(p[0]);
  800415:	83 c4 04             	add    $0x4,%esp
  800418:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80041e:	e8 48 19 00 00       	call   801d6b <close>
  800423:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800426:	83 ec 0c             	sub    $0xc,%esp
  800429:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80042f:	e8 37 19 00 00       	call   801d6b <close>
				goto again;
  800434:	83 c4 10             	add    $0x10,%esp
  800437:	e9 e9 fd ff ff       	jmp    800225 <runcmd+0x1c>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  80043c:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800442:	83 f8 01             	cmp    $0x1,%eax
  800445:	74 1c                	je     800463 <runcmd+0x25a>
					dup(p[1], 1);
  800447:	83 ec 08             	sub    $0x8,%esp
  80044a:	6a 01                	push   $0x1
  80044c:	50                   	push   %eax
  80044d:	e8 69 19 00 00       	call   801dbb <dup>
					close(p[1]);
  800452:	83 c4 04             	add    $0x4,%esp
  800455:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80045b:	e8 0b 19 00 00       	call   801d6b <close>
  800460:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800463:	83 ec 0c             	sub    $0xc,%esp
  800466:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80046c:	e8 fa 18 00 00       	call   801d6b <close>
				goto runit;
  800471:	83 c4 10             	add    $0x10,%esp
  800474:	eb 17                	jmp    80048d <runcmd+0x284>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800476:	50                   	push   %eax
  800477:	68 4e 33 80 00       	push   $0x80334e
  80047c:	6a 78                	push   $0x78
  80047e:	68 6a 33 80 00       	push   $0x80336a
  800483:	e8 8c 05 00 00       	call   800a14 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  800488:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  80048d:	85 f6                	test   %esi,%esi
  80048f:	75 22                	jne    8004b3 <runcmd+0x2aa>
		if (debug)
  800491:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800498:	0f 84 96 01 00 00    	je     800634 <runcmd+0x42b>
			cprintf("EMPTY COMMAND\n");
  80049e:	83 ec 0c             	sub    $0xc,%esp
  8004a1:	68 74 33 80 00       	push   $0x803374
  8004a6:	e8 42 06 00 00       	call   800aed <cprintf>
  8004ab:	83 c4 10             	add    $0x10,%esp
  8004ae:	e9 81 01 00 00       	jmp    800634 <runcmd+0x42b>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  8004b3:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004b6:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004b9:	74 23                	je     8004de <runcmd+0x2d5>
		argv0buf[0] = '/';
  8004bb:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004c2:	83 ec 08             	sub    $0x8,%esp
  8004c5:	50                   	push   %eax
  8004c6:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004cc:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004d2:	50                   	push   %eax
  8004d3:	e8 0c 0d 00 00       	call   8011e4 <strcpy>
		argv[0] = argv0buf;
  8004d8:	89 5d a8             	mov    %ebx,-0x58(%ebp)
  8004db:	83 c4 10             	add    $0x10,%esp
	}
	argv[argc] = 0;
  8004de:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004e5:	00 

	// Print the command.
	if (debug) {
  8004e6:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004ed:	74 49                	je     800538 <runcmd+0x32f>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004ef:	a1 24 54 80 00       	mov    0x805424,%eax
  8004f4:	8b 40 48             	mov    0x48(%eax),%eax
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	50                   	push   %eax
  8004fb:	68 83 33 80 00       	push   $0x803383
  800500:	e8 e8 05 00 00       	call   800aed <cprintf>
  800505:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	eb 11                	jmp    80051e <runcmd+0x315>
			cprintf(" %s", argv[i]);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	50                   	push   %eax
  800511:	68 0b 34 80 00       	push   $0x80340b
  800516:	e8 d2 05 00 00       	call   800aed <cprintf>
  80051b:	83 c4 10             	add    $0x10,%esp
  80051e:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  800521:	8b 43 fc             	mov    -0x4(%ebx),%eax
  800524:	85 c0                	test   %eax,%eax
  800526:	75 e5                	jne    80050d <runcmd+0x304>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  800528:	83 ec 0c             	sub    $0xc,%esp
  80052b:	68 e0 32 80 00       	push   $0x8032e0
  800530:	e8 b8 05 00 00       	call   800aed <cprintf>
  800535:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800538:	83 ec 08             	sub    $0x8,%esp
  80053b:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80053e:	50                   	push   %eax
  80053f:	ff 75 a8             	pushl  -0x58(%ebp)
  800542:	e8 9f 1f 00 00       	call   8024e6 <spawn>
  800547:	89 c3                	mov    %eax,%ebx
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	85 c0                	test   %eax,%eax
  80054e:	0f 89 c3 00 00 00    	jns    800617 <runcmd+0x40e>
		cprintf("spawn %s: %e\n", argv[0], r);
  800554:	83 ec 04             	sub    $0x4,%esp
  800557:	50                   	push   %eax
  800558:	ff 75 a8             	pushl  -0x58(%ebp)
  80055b:	68 91 33 80 00       	push   $0x803391
  800560:	e8 88 05 00 00       	call   800aed <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800565:	e8 2c 18 00 00       	call   801d96 <close_all>
  80056a:	83 c4 10             	add    $0x10,%esp
  80056d:	eb 4c                	jmp    8005bb <runcmd+0x3b2>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  80056f:	a1 24 54 80 00       	mov    0x805424,%eax
  800574:	8b 40 48             	mov    0x48(%eax),%eax
  800577:	53                   	push   %ebx
  800578:	ff 75 a8             	pushl  -0x58(%ebp)
  80057b:	50                   	push   %eax
  80057c:	68 9f 33 80 00       	push   $0x80339f
  800581:	e8 67 05 00 00       	call   800aed <cprintf>
  800586:	83 c4 10             	add    $0x10,%esp
		wait(r);
  800589:	83 ec 0c             	sub    $0xc,%esp
  80058c:	53                   	push   %ebx
  80058d:	e8 8b 28 00 00       	call   802e1d <wait>
		if (debug)
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80059c:	0f 84 8c 00 00 00    	je     80062e <runcmd+0x425>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005a2:	a1 24 54 80 00       	mov    0x805424,%eax
  8005a7:	8b 40 48             	mov    0x48(%eax),%eax
  8005aa:	83 ec 08             	sub    $0x8,%esp
  8005ad:	50                   	push   %eax
  8005ae:	68 b4 33 80 00       	push   $0x8033b4
  8005b3:	e8 35 05 00 00       	call   800aed <cprintf>
  8005b8:	83 c4 10             	add    $0x10,%esp
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005bb:	85 ff                	test   %edi,%edi
  8005bd:	74 51                	je     800610 <runcmd+0x407>
		if (debug)
  8005bf:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005c6:	74 1a                	je     8005e2 <runcmd+0x3d9>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005c8:	a1 24 54 80 00       	mov    0x805424,%eax
  8005cd:	8b 40 48             	mov    0x48(%eax),%eax
  8005d0:	83 ec 04             	sub    $0x4,%esp
  8005d3:	57                   	push   %edi
  8005d4:	50                   	push   %eax
  8005d5:	68 ca 33 80 00       	push   $0x8033ca
  8005da:	e8 0e 05 00 00       	call   800aed <cprintf>
  8005df:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005e2:	83 ec 0c             	sub    $0xc,%esp
  8005e5:	57                   	push   %edi
  8005e6:	e8 32 28 00 00       	call   802e1d <wait>
		if (debug)
  8005eb:	83 c4 10             	add    $0x10,%esp
  8005ee:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005f5:	74 19                	je     800610 <runcmd+0x407>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005f7:	a1 24 54 80 00       	mov    0x805424,%eax
  8005fc:	8b 40 48             	mov    0x48(%eax),%eax
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	50                   	push   %eax
  800603:	68 b4 33 80 00       	push   $0x8033b4
  800608:	e8 e0 04 00 00       	call   800aed <cprintf>
  80060d:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  800610:	e8 e5 03 00 00       	call   8009fa <exit>
  800615:	eb 1d                	jmp    800634 <runcmd+0x42b>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800617:	e8 7a 17 00 00       	call   801d96 <close_all>
	if (r >= 0) {
		if (debug)
  80061c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800623:	0f 84 60 ff ff ff    	je     800589 <runcmd+0x380>
  800629:	e9 41 ff ff ff       	jmp    80056f <runcmd+0x366>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  80062e:	85 ff                	test   %edi,%edi
  800630:	75 b0                	jne    8005e2 <runcmd+0x3d9>
  800632:	eb dc                	jmp    800610 <runcmd+0x407>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// Done!
	exit();
}
  800634:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800637:	5b                   	pop    %ebx
  800638:	5e                   	pop    %esi
  800639:	5f                   	pop    %edi
  80063a:	5d                   	pop    %ebp
  80063b:	c3                   	ret    

0080063c <usage>:
}


void
usage(void)
{
  80063c:	55                   	push   %ebp
  80063d:	89 e5                	mov    %esp,%ebp
  80063f:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800642:	68 94 34 80 00       	push   $0x803494
  800647:	e8 a1 04 00 00       	call   800aed <cprintf>
	exit();
  80064c:	e8 a9 03 00 00       	call   8009fa <exit>
}
  800651:	83 c4 10             	add    $0x10,%esp
  800654:	c9                   	leave  
  800655:	c3                   	ret    

00800656 <umain>:

void
umain(int argc, char **argv)
{
  800656:	55                   	push   %ebp
  800657:	89 e5                	mov    %esp,%ebp
  800659:	57                   	push   %edi
  80065a:	56                   	push   %esi
  80065b:	53                   	push   %ebx
  80065c:	83 ec 30             	sub    $0x30,%esp
  80065f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  800662:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800665:	50                   	push   %eax
  800666:	57                   	push   %edi
  800667:	8d 45 08             	lea    0x8(%ebp),%eax
  80066a:	50                   	push   %eax
  80066b:	e8 07 14 00 00       	call   801a77 <argstart>
	while ((r = argnext(&args)) >= 0)
  800670:	83 c4 10             	add    $0x10,%esp
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800673:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80067a:	be 3f 00 00 00       	mov    $0x3f,%esi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  80067f:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800682:	eb 2f                	jmp    8006b3 <umain+0x5d>
		switch (r) {
  800684:	83 f8 69             	cmp    $0x69,%eax
  800687:	74 25                	je     8006ae <umain+0x58>
  800689:	83 f8 78             	cmp    $0x78,%eax
  80068c:	74 07                	je     800695 <umain+0x3f>
  80068e:	83 f8 64             	cmp    $0x64,%eax
  800691:	75 14                	jne    8006a7 <umain+0x51>
  800693:	eb 09                	jmp    80069e <umain+0x48>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  800695:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  80069c:	eb 15                	jmp    8006b3 <umain+0x5d>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  80069e:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
			break;
  8006a5:	eb 0c                	jmp    8006b3 <umain+0x5d>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  8006a7:	e8 90 ff ff ff       	call   80063c <usage>
  8006ac:	eb 05                	jmp    8006b3 <umain+0x5d>
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006ae:	be 01 00 00 00       	mov    $0x1,%esi
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  8006b3:	83 ec 0c             	sub    $0xc,%esp
  8006b6:	53                   	push   %ebx
  8006b7:	e8 eb 13 00 00       	call   801aa7 <argnext>
  8006bc:	83 c4 10             	add    $0x10,%esp
  8006bf:	85 c0                	test   %eax,%eax
  8006c1:	79 c1                	jns    800684 <umain+0x2e>
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006c3:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006c7:	7e 05                	jle    8006ce <umain+0x78>
		usage();
  8006c9:	e8 6e ff ff ff       	call   80063c <usage>
	if (argc == 2) {
  8006ce:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006d2:	75 56                	jne    80072a <umain+0xd4>
		close(0);
  8006d4:	83 ec 0c             	sub    $0xc,%esp
  8006d7:	6a 00                	push   $0x0
  8006d9:	e8 8d 16 00 00       	call   801d6b <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006de:	83 c4 08             	add    $0x8,%esp
  8006e1:	6a 00                	push   $0x0
  8006e3:	ff 77 04             	pushl  0x4(%edi)
  8006e6:	e8 47 1c 00 00       	call   802332 <open>
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	85 c0                	test   %eax,%eax
  8006f0:	79 1b                	jns    80070d <umain+0xb7>
			panic("open %s: %e", argv[1], r);
  8006f2:	83 ec 0c             	sub    $0xc,%esp
  8006f5:	50                   	push   %eax
  8006f6:	ff 77 04             	pushl  0x4(%edi)
  8006f9:	68 e7 33 80 00       	push   $0x8033e7
  8006fe:	68 28 01 00 00       	push   $0x128
  800703:	68 6a 33 80 00       	push   $0x80336a
  800708:	e8 07 03 00 00       	call   800a14 <_panic>
		assert(r == 0);
  80070d:	85 c0                	test   %eax,%eax
  80070f:	74 19                	je     80072a <umain+0xd4>
  800711:	68 f3 33 80 00       	push   $0x8033f3
  800716:	68 fa 33 80 00       	push   $0x8033fa
  80071b:	68 29 01 00 00       	push   $0x129
  800720:	68 6a 33 80 00       	push   $0x80336a
  800725:	e8 ea 02 00 00       	call   800a14 <_panic>
	}
	if (interactive == '?')
  80072a:	83 fe 3f             	cmp    $0x3f,%esi
  80072d:	75 0f                	jne    80073e <umain+0xe8>
		interactive = iscons(0);
  80072f:	83 ec 0c             	sub    $0xc,%esp
  800732:	6a 00                	push   $0x0
  800734:	e8 f5 01 00 00       	call   80092e <iscons>
  800739:	89 c6                	mov    %eax,%esi
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	85 f6                	test   %esi,%esi
  800740:	b8 00 00 00 00       	mov    $0x0,%eax
  800745:	bf 0f 34 80 00       	mov    $0x80340f,%edi
  80074a:	0f 44 f8             	cmove  %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  80074d:	83 ec 0c             	sub    $0xc,%esp
  800750:	57                   	push   %edi
  800751:	e8 62 09 00 00       	call   8010b8 <readline>
  800756:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800758:	83 c4 10             	add    $0x10,%esp
  80075b:	85 c0                	test   %eax,%eax
  80075d:	75 1e                	jne    80077d <umain+0x127>
			if (debug)
  80075f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800766:	74 10                	je     800778 <umain+0x122>
				cprintf("EXITING\n");
  800768:	83 ec 0c             	sub    $0xc,%esp
  80076b:	68 12 34 80 00       	push   $0x803412
  800770:	e8 78 03 00 00       	call   800aed <cprintf>
  800775:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  800778:	e8 7d 02 00 00       	call   8009fa <exit>
		}
		if (debug)
  80077d:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800784:	74 11                	je     800797 <umain+0x141>
			cprintf("LINE: %s\n", buf);
  800786:	83 ec 08             	sub    $0x8,%esp
  800789:	53                   	push   %ebx
  80078a:	68 1b 34 80 00       	push   $0x80341b
  80078f:	e8 59 03 00 00       	call   800aed <cprintf>
  800794:	83 c4 10             	add    $0x10,%esp
		if (buf[0] == '#')
  800797:	80 3b 23             	cmpb   $0x23,(%ebx)
  80079a:	74 b1                	je     80074d <umain+0xf7>
			continue;
		if (echocmds)
  80079c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007a0:	74 11                	je     8007b3 <umain+0x15d>
			printf("# %s\n", buf);
  8007a2:	83 ec 08             	sub    $0x8,%esp
  8007a5:	53                   	push   %ebx
  8007a6:	68 25 34 80 00       	push   $0x803425
  8007ab:	e8 20 1d 00 00       	call   8024d0 <printf>
  8007b0:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007b3:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007ba:	74 10                	je     8007cc <umain+0x176>
			cprintf("BEFORE FORK\n");
  8007bc:	83 ec 0c             	sub    $0xc,%esp
  8007bf:	68 2b 34 80 00       	push   $0x80342b
  8007c4:	e8 24 03 00 00       	call   800aed <cprintf>
  8007c9:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007cc:	e8 f9 10 00 00       	call   8018ca <fork>
  8007d1:	89 c6                	mov    %eax,%esi
  8007d3:	85 c0                	test   %eax,%eax
  8007d5:	79 15                	jns    8007ec <umain+0x196>
			panic("fork: %e", r);
  8007d7:	50                   	push   %eax
  8007d8:	68 45 33 80 00       	push   $0x803345
  8007dd:	68 40 01 00 00       	push   $0x140
  8007e2:	68 6a 33 80 00       	push   $0x80336a
  8007e7:	e8 28 02 00 00       	call   800a14 <_panic>
		if (debug)
  8007ec:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007f3:	74 11                	je     800806 <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  8007f5:	83 ec 08             	sub    $0x8,%esp
  8007f8:	50                   	push   %eax
  8007f9:	68 38 34 80 00       	push   $0x803438
  8007fe:	e8 ea 02 00 00       	call   800aed <cprintf>
  800803:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  800806:	85 f6                	test   %esi,%esi
  800808:	75 16                	jne    800820 <umain+0x1ca>
			runcmd(buf);
  80080a:	83 ec 0c             	sub    $0xc,%esp
  80080d:	53                   	push   %ebx
  80080e:	e8 f6 f9 ff ff       	call   800209 <runcmd>
			exit();
  800813:	e8 e2 01 00 00       	call   8009fa <exit>
  800818:	83 c4 10             	add    $0x10,%esp
  80081b:	e9 2d ff ff ff       	jmp    80074d <umain+0xf7>
		} else
			wait(r);
  800820:	83 ec 0c             	sub    $0xc,%esp
  800823:	56                   	push   %esi
  800824:	e8 f4 25 00 00       	call   802e1d <wait>
  800829:	83 c4 10             	add    $0x10,%esp
  80082c:	e9 1c ff ff ff       	jmp    80074d <umain+0xf7>

00800831 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800834:	b8 00 00 00 00       	mov    $0x0,%eax
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800841:	68 b5 34 80 00       	push   $0x8034b5
  800846:	ff 75 0c             	pushl  0xc(%ebp)
  800849:	e8 96 09 00 00       	call   8011e4 <strcpy>
	return 0;
}
  80084e:	b8 00 00 00 00       	mov    $0x0,%eax
  800853:	c9                   	leave  
  800854:	c3                   	ret    

00800855 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	57                   	push   %edi
  800859:	56                   	push   %esi
  80085a:	53                   	push   %ebx
  80085b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800861:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800866:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80086c:	eb 2d                	jmp    80089b <devcons_write+0x46>
		m = n - tot;
  80086e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800871:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800873:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800876:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80087b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80087e:	83 ec 04             	sub    $0x4,%esp
  800881:	53                   	push   %ebx
  800882:	03 45 0c             	add    0xc(%ebp),%eax
  800885:	50                   	push   %eax
  800886:	57                   	push   %edi
  800887:	e8 ea 0a 00 00       	call   801376 <memmove>
		sys_cputs(buf, m);
  80088c:	83 c4 08             	add    $0x8,%esp
  80088f:	53                   	push   %ebx
  800890:	57                   	push   %edi
  800891:	e8 95 0c 00 00       	call   80152b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800896:	01 de                	add    %ebx,%esi
  800898:	83 c4 10             	add    $0x10,%esp
  80089b:	89 f0                	mov    %esi,%eax
  80089d:	3b 75 10             	cmp    0x10(%ebp),%esi
  8008a0:	72 cc                	jb     80086e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8008a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a5:	5b                   	pop    %ebx
  8008a6:	5e                   	pop    %esi
  8008a7:	5f                   	pop    %edi
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	83 ec 08             	sub    $0x8,%esp
  8008b0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8008b5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008b9:	74 2a                	je     8008e5 <devcons_read+0x3b>
  8008bb:	eb 05                	jmp    8008c2 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008bd:	e8 06 0d 00 00       	call   8015c8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008c2:	e8 82 0c 00 00       	call   801549 <sys_cgetc>
  8008c7:	85 c0                	test   %eax,%eax
  8008c9:	74 f2                	je     8008bd <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8008cb:	85 c0                	test   %eax,%eax
  8008cd:	78 16                	js     8008e5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8008cf:	83 f8 04             	cmp    $0x4,%eax
  8008d2:	74 0c                	je     8008e0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8008d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d7:	88 02                	mov    %al,(%edx)
	return 1;
  8008d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8008de:	eb 05                	jmp    8008e5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008e0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008e5:	c9                   	leave  
  8008e6:	c3                   	ret    

008008e7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8008f3:	6a 01                	push   $0x1
  8008f5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008f8:	50                   	push   %eax
  8008f9:	e8 2d 0c 00 00       	call   80152b <sys_cputs>
}
  8008fe:	83 c4 10             	add    $0x10,%esp
  800901:	c9                   	leave  
  800902:	c3                   	ret    

00800903 <getchar>:

int
getchar(void)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800909:	6a 01                	push   $0x1
  80090b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80090e:	50                   	push   %eax
  80090f:	6a 00                	push   $0x0
  800911:	e8 91 15 00 00       	call   801ea7 <read>
	if (r < 0)
  800916:	83 c4 10             	add    $0x10,%esp
  800919:	85 c0                	test   %eax,%eax
  80091b:	78 0f                	js     80092c <getchar+0x29>
		return r;
	if (r < 1)
  80091d:	85 c0                	test   %eax,%eax
  80091f:	7e 06                	jle    800927 <getchar+0x24>
		return -E_EOF;
	return c;
  800921:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800925:	eb 05                	jmp    80092c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800927:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80092c:	c9                   	leave  
  80092d:	c3                   	ret    

0080092e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800934:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800937:	50                   	push   %eax
  800938:	ff 75 08             	pushl  0x8(%ebp)
  80093b:	e8 01 13 00 00       	call   801c41 <fd_lookup>
  800940:	83 c4 10             	add    $0x10,%esp
  800943:	85 c0                	test   %eax,%eax
  800945:	78 11                	js     800958 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800947:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800950:	39 10                	cmp    %edx,(%eax)
  800952:	0f 94 c0             	sete   %al
  800955:	0f b6 c0             	movzbl %al,%eax
}
  800958:	c9                   	leave  
  800959:	c3                   	ret    

0080095a <opencons>:

int
opencons(void)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800960:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800963:	50                   	push   %eax
  800964:	e8 89 12 00 00       	call   801bf2 <fd_alloc>
  800969:	83 c4 10             	add    $0x10,%esp
		return r;
  80096c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80096e:	85 c0                	test   %eax,%eax
  800970:	78 3e                	js     8009b0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800972:	83 ec 04             	sub    $0x4,%esp
  800975:	68 07 04 00 00       	push   $0x407
  80097a:	ff 75 f4             	pushl  -0xc(%ebp)
  80097d:	6a 00                	push   $0x0
  80097f:	e8 63 0c 00 00       	call   8015e7 <sys_page_alloc>
  800984:	83 c4 10             	add    $0x10,%esp
		return r;
  800987:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800989:	85 c0                	test   %eax,%eax
  80098b:	78 23                	js     8009b0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80098d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800993:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800996:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800998:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009a2:	83 ec 0c             	sub    $0xc,%esp
  8009a5:	50                   	push   %eax
  8009a6:	e8 20 12 00 00       	call   801bcb <fd2num>
  8009ab:	89 c2                	mov    %eax,%edx
  8009ad:	83 c4 10             	add    $0x10,%esp
}
  8009b0:	89 d0                	mov    %edx,%eax
  8009b2:	c9                   	leave  
  8009b3:	c3                   	ret    

008009b4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	56                   	push   %esi
  8009b8:	53                   	push   %ebx
  8009b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009bc:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8009bf:	e8 e5 0b 00 00       	call   8015a9 <sys_getenvid>
  8009c4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009c9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8009cc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009d1:	a3 24 54 80 00       	mov    %eax,0x805424

    // save the name of the program so that panic() can use it
    if (argc > 0)
  8009d6:	85 db                	test   %ebx,%ebx
  8009d8:	7e 07                	jle    8009e1 <libmain+0x2d>
        binaryname = argv[0];
  8009da:	8b 06                	mov    (%esi),%eax
  8009dc:	a3 1c 40 80 00       	mov    %eax,0x80401c

    // call user main routine
    umain(argc, argv);
  8009e1:	83 ec 08             	sub    $0x8,%esp
  8009e4:	56                   	push   %esi
  8009e5:	53                   	push   %ebx
  8009e6:	e8 6b fc ff ff       	call   800656 <umain>

    // exit gracefully
    exit();
  8009eb:	e8 0a 00 00 00       	call   8009fa <exit>
}
  8009f0:	83 c4 10             	add    $0x10,%esp
  8009f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009f6:	5b                   	pop    %ebx
  8009f7:	5e                   	pop    %esi
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a00:	e8 91 13 00 00       	call   801d96 <close_all>
	sys_env_destroy(0);
  800a05:	83 ec 0c             	sub    $0xc,%esp
  800a08:	6a 00                	push   $0x0
  800a0a:	e8 59 0b 00 00       	call   801568 <sys_env_destroy>
}
  800a0f:	83 c4 10             	add    $0x10,%esp
  800a12:	c9                   	leave  
  800a13:	c3                   	ret    

00800a14 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a19:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a1c:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a22:	e8 82 0b 00 00       	call   8015a9 <sys_getenvid>
  800a27:	83 ec 0c             	sub    $0xc,%esp
  800a2a:	ff 75 0c             	pushl  0xc(%ebp)
  800a2d:	ff 75 08             	pushl  0x8(%ebp)
  800a30:	56                   	push   %esi
  800a31:	50                   	push   %eax
  800a32:	68 cc 34 80 00       	push   $0x8034cc
  800a37:	e8 b1 00 00 00       	call   800aed <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a3c:	83 c4 18             	add    $0x18,%esp
  800a3f:	53                   	push   %ebx
  800a40:	ff 75 10             	pushl  0x10(%ebp)
  800a43:	e8 54 00 00 00       	call   800a9c <vcprintf>
	cprintf("\n");
  800a48:	c7 04 24 e0 32 80 00 	movl   $0x8032e0,(%esp)
  800a4f:	e8 99 00 00 00       	call   800aed <cprintf>
  800a54:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a57:	cc                   	int3   
  800a58:	eb fd                	jmp    800a57 <_panic+0x43>

00800a5a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	53                   	push   %ebx
  800a5e:	83 ec 04             	sub    $0x4,%esp
  800a61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a64:	8b 13                	mov    (%ebx),%edx
  800a66:	8d 42 01             	lea    0x1(%edx),%eax
  800a69:	89 03                	mov    %eax,(%ebx)
  800a6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a72:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a77:	75 1a                	jne    800a93 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800a79:	83 ec 08             	sub    $0x8,%esp
  800a7c:	68 ff 00 00 00       	push   $0xff
  800a81:	8d 43 08             	lea    0x8(%ebx),%eax
  800a84:	50                   	push   %eax
  800a85:	e8 a1 0a 00 00       	call   80152b <sys_cputs>
		b->idx = 0;
  800a8a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800a90:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800a93:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800a97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9a:	c9                   	leave  
  800a9b:	c3                   	ret    

00800a9c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800aa5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800aac:	00 00 00 
	b.cnt = 0;
  800aaf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ab6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800ab9:	ff 75 0c             	pushl  0xc(%ebp)
  800abc:	ff 75 08             	pushl  0x8(%ebp)
  800abf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800ac5:	50                   	push   %eax
  800ac6:	68 5a 0a 80 00       	push   $0x800a5a
  800acb:	e8 1a 01 00 00       	call   800bea <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800ad0:	83 c4 08             	add    $0x8,%esp
  800ad3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800ad9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800adf:	50                   	push   %eax
  800ae0:	e8 46 0a 00 00       	call   80152b <sys_cputs>

	return b.cnt;
}
  800ae5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800aeb:	c9                   	leave  
  800aec:	c3                   	ret    

00800aed <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800af3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800af6:	50                   	push   %eax
  800af7:	ff 75 08             	pushl  0x8(%ebp)
  800afa:	e8 9d ff ff ff       	call   800a9c <vcprintf>
	va_end(ap);

	return cnt;
}
  800aff:	c9                   	leave  
  800b00:	c3                   	ret    

00800b01 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	83 ec 1c             	sub    $0x1c,%esp
  800b0a:	89 c7                	mov    %eax,%edi
  800b0c:	89 d6                	mov    %edx,%esi
  800b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b11:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b14:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b17:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b22:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800b25:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800b28:	39 d3                	cmp    %edx,%ebx
  800b2a:	72 05                	jb     800b31 <printnum+0x30>
  800b2c:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b2f:	77 45                	ja     800b76 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b31:	83 ec 0c             	sub    $0xc,%esp
  800b34:	ff 75 18             	pushl  0x18(%ebp)
  800b37:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800b3d:	53                   	push   %ebx
  800b3e:	ff 75 10             	pushl  0x10(%ebp)
  800b41:	83 ec 08             	sub    $0x8,%esp
  800b44:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b47:	ff 75 e0             	pushl  -0x20(%ebp)
  800b4a:	ff 75 dc             	pushl  -0x24(%ebp)
  800b4d:	ff 75 d8             	pushl  -0x28(%ebp)
  800b50:	e8 db 24 00 00       	call   803030 <__udivdi3>
  800b55:	83 c4 18             	add    $0x18,%esp
  800b58:	52                   	push   %edx
  800b59:	50                   	push   %eax
  800b5a:	89 f2                	mov    %esi,%edx
  800b5c:	89 f8                	mov    %edi,%eax
  800b5e:	e8 9e ff ff ff       	call   800b01 <printnum>
  800b63:	83 c4 20             	add    $0x20,%esp
  800b66:	eb 18                	jmp    800b80 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b68:	83 ec 08             	sub    $0x8,%esp
  800b6b:	56                   	push   %esi
  800b6c:	ff 75 18             	pushl  0x18(%ebp)
  800b6f:	ff d7                	call   *%edi
  800b71:	83 c4 10             	add    $0x10,%esp
  800b74:	eb 03                	jmp    800b79 <printnum+0x78>
  800b76:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b79:	83 eb 01             	sub    $0x1,%ebx
  800b7c:	85 db                	test   %ebx,%ebx
  800b7e:	7f e8                	jg     800b68 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b80:	83 ec 08             	sub    $0x8,%esp
  800b83:	56                   	push   %esi
  800b84:	83 ec 04             	sub    $0x4,%esp
  800b87:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b8a:	ff 75 e0             	pushl  -0x20(%ebp)
  800b8d:	ff 75 dc             	pushl  -0x24(%ebp)
  800b90:	ff 75 d8             	pushl  -0x28(%ebp)
  800b93:	e8 c8 25 00 00       	call   803160 <__umoddi3>
  800b98:	83 c4 14             	add    $0x14,%esp
  800b9b:	0f be 80 ef 34 80 00 	movsbl 0x8034ef(%eax),%eax
  800ba2:	50                   	push   %eax
  800ba3:	ff d7                	call   *%edi
}
  800ba5:	83 c4 10             	add    $0x10,%esp
  800ba8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5f                   	pop    %edi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800bb6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800bba:	8b 10                	mov    (%eax),%edx
  800bbc:	3b 50 04             	cmp    0x4(%eax),%edx
  800bbf:	73 0a                	jae    800bcb <sprintputch+0x1b>
		*b->buf++ = ch;
  800bc1:	8d 4a 01             	lea    0x1(%edx),%ecx
  800bc4:	89 08                	mov    %ecx,(%eax)
  800bc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc9:	88 02                	mov    %al,(%edx)
}
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800bd3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800bd6:	50                   	push   %eax
  800bd7:	ff 75 10             	pushl  0x10(%ebp)
  800bda:	ff 75 0c             	pushl  0xc(%ebp)
  800bdd:	ff 75 08             	pushl  0x8(%ebp)
  800be0:	e8 05 00 00 00       	call   800bea <vprintfmt>
	va_end(ap);
}
  800be5:	83 c4 10             	add    $0x10,%esp
  800be8:	c9                   	leave  
  800be9:	c3                   	ret    

00800bea <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
  800bf0:	83 ec 2c             	sub    $0x2c,%esp
  800bf3:	8b 75 08             	mov    0x8(%ebp),%esi
  800bf6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bf9:	8b 7d 10             	mov    0x10(%ebp),%edi
  800bfc:	eb 12                	jmp    800c10 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800bfe:	85 c0                	test   %eax,%eax
  800c00:	0f 84 42 04 00 00    	je     801048 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800c06:	83 ec 08             	sub    $0x8,%esp
  800c09:	53                   	push   %ebx
  800c0a:	50                   	push   %eax
  800c0b:	ff d6                	call   *%esi
  800c0d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c10:	83 c7 01             	add    $0x1,%edi
  800c13:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c17:	83 f8 25             	cmp    $0x25,%eax
  800c1a:	75 e2                	jne    800bfe <vprintfmt+0x14>
  800c1c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800c20:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c27:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800c2e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800c35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3a:	eb 07                	jmp    800c43 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c3c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800c3f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c43:	8d 47 01             	lea    0x1(%edi),%eax
  800c46:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c49:	0f b6 07             	movzbl (%edi),%eax
  800c4c:	0f b6 d0             	movzbl %al,%edx
  800c4f:	83 e8 23             	sub    $0x23,%eax
  800c52:	3c 55                	cmp    $0x55,%al
  800c54:	0f 87 d3 03 00 00    	ja     80102d <vprintfmt+0x443>
  800c5a:	0f b6 c0             	movzbl %al,%eax
  800c5d:	ff 24 85 40 36 80 00 	jmp    *0x803640(,%eax,4)
  800c64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800c67:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800c6b:	eb d6                	jmp    800c43 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c6d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c70:	b8 00 00 00 00       	mov    $0x0,%eax
  800c75:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800c78:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800c7b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800c7f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800c82:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800c85:	83 f9 09             	cmp    $0x9,%ecx
  800c88:	77 3f                	ja     800cc9 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800c8a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800c8d:	eb e9                	jmp    800c78 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800c8f:	8b 45 14             	mov    0x14(%ebp),%eax
  800c92:	8b 00                	mov    (%eax),%eax
  800c94:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800c97:	8b 45 14             	mov    0x14(%ebp),%eax
  800c9a:	8d 40 04             	lea    0x4(%eax),%eax
  800c9d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800ca3:	eb 2a                	jmp    800ccf <vprintfmt+0xe5>
  800ca5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ca8:	85 c0                	test   %eax,%eax
  800caa:	ba 00 00 00 00       	mov    $0x0,%edx
  800caf:	0f 49 d0             	cmovns %eax,%edx
  800cb2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cb5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cb8:	eb 89                	jmp    800c43 <vprintfmt+0x59>
  800cba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800cbd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800cc4:	e9 7a ff ff ff       	jmp    800c43 <vprintfmt+0x59>
  800cc9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800ccc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800ccf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800cd3:	0f 89 6a ff ff ff    	jns    800c43 <vprintfmt+0x59>
				width = precision, precision = -1;
  800cd9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800cdc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800cdf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800ce6:	e9 58 ff ff ff       	jmp    800c43 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800ceb:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800cf1:	e9 4d ff ff ff       	jmp    800c43 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800cf6:	8b 45 14             	mov    0x14(%ebp),%eax
  800cf9:	8d 78 04             	lea    0x4(%eax),%edi
  800cfc:	83 ec 08             	sub    $0x8,%esp
  800cff:	53                   	push   %ebx
  800d00:	ff 30                	pushl  (%eax)
  800d02:	ff d6                	call   *%esi
			break;
  800d04:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d07:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d0a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d0d:	e9 fe fe ff ff       	jmp    800c10 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d12:	8b 45 14             	mov    0x14(%ebp),%eax
  800d15:	8d 78 04             	lea    0x4(%eax),%edi
  800d18:	8b 00                	mov    (%eax),%eax
  800d1a:	99                   	cltd   
  800d1b:	31 d0                	xor    %edx,%eax
  800d1d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d1f:	83 f8 0f             	cmp    $0xf,%eax
  800d22:	7f 0b                	jg     800d2f <vprintfmt+0x145>
  800d24:	8b 14 85 a0 37 80 00 	mov    0x8037a0(,%eax,4),%edx
  800d2b:	85 d2                	test   %edx,%edx
  800d2d:	75 1b                	jne    800d4a <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800d2f:	50                   	push   %eax
  800d30:	68 07 35 80 00       	push   $0x803507
  800d35:	53                   	push   %ebx
  800d36:	56                   	push   %esi
  800d37:	e8 91 fe ff ff       	call   800bcd <printfmt>
  800d3c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d3f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d42:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d45:	e9 c6 fe ff ff       	jmp    800c10 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800d4a:	52                   	push   %edx
  800d4b:	68 0c 34 80 00       	push   $0x80340c
  800d50:	53                   	push   %ebx
  800d51:	56                   	push   %esi
  800d52:	e8 76 fe ff ff       	call   800bcd <printfmt>
  800d57:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d5a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d5d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d60:	e9 ab fe ff ff       	jmp    800c10 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d65:	8b 45 14             	mov    0x14(%ebp),%eax
  800d68:	83 c0 04             	add    $0x4,%eax
  800d6b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800d6e:	8b 45 14             	mov    0x14(%ebp),%eax
  800d71:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800d73:	85 ff                	test   %edi,%edi
  800d75:	b8 00 35 80 00       	mov    $0x803500,%eax
  800d7a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800d7d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d81:	0f 8e 94 00 00 00    	jle    800e1b <vprintfmt+0x231>
  800d87:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800d8b:	0f 84 98 00 00 00    	je     800e29 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800d91:	83 ec 08             	sub    $0x8,%esp
  800d94:	ff 75 d0             	pushl  -0x30(%ebp)
  800d97:	57                   	push   %edi
  800d98:	e8 26 04 00 00       	call   8011c3 <strnlen>
  800d9d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800da0:	29 c1                	sub    %eax,%ecx
  800da2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800da5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800da8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800dac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800daf:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800db2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800db4:	eb 0f                	jmp    800dc5 <vprintfmt+0x1db>
					putch(padc, putdat);
  800db6:	83 ec 08             	sub    $0x8,%esp
  800db9:	53                   	push   %ebx
  800dba:	ff 75 e0             	pushl  -0x20(%ebp)
  800dbd:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800dbf:	83 ef 01             	sub    $0x1,%edi
  800dc2:	83 c4 10             	add    $0x10,%esp
  800dc5:	85 ff                	test   %edi,%edi
  800dc7:	7f ed                	jg     800db6 <vprintfmt+0x1cc>
  800dc9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800dcc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800dcf:	85 c9                	test   %ecx,%ecx
  800dd1:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd6:	0f 49 c1             	cmovns %ecx,%eax
  800dd9:	29 c1                	sub    %eax,%ecx
  800ddb:	89 75 08             	mov    %esi,0x8(%ebp)
  800dde:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800de1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800de4:	89 cb                	mov    %ecx,%ebx
  800de6:	eb 4d                	jmp    800e35 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800de8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800dec:	74 1b                	je     800e09 <vprintfmt+0x21f>
  800dee:	0f be c0             	movsbl %al,%eax
  800df1:	83 e8 20             	sub    $0x20,%eax
  800df4:	83 f8 5e             	cmp    $0x5e,%eax
  800df7:	76 10                	jbe    800e09 <vprintfmt+0x21f>
					putch('?', putdat);
  800df9:	83 ec 08             	sub    $0x8,%esp
  800dfc:	ff 75 0c             	pushl  0xc(%ebp)
  800dff:	6a 3f                	push   $0x3f
  800e01:	ff 55 08             	call   *0x8(%ebp)
  800e04:	83 c4 10             	add    $0x10,%esp
  800e07:	eb 0d                	jmp    800e16 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800e09:	83 ec 08             	sub    $0x8,%esp
  800e0c:	ff 75 0c             	pushl  0xc(%ebp)
  800e0f:	52                   	push   %edx
  800e10:	ff 55 08             	call   *0x8(%ebp)
  800e13:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e16:	83 eb 01             	sub    $0x1,%ebx
  800e19:	eb 1a                	jmp    800e35 <vprintfmt+0x24b>
  800e1b:	89 75 08             	mov    %esi,0x8(%ebp)
  800e1e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e21:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e24:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e27:	eb 0c                	jmp    800e35 <vprintfmt+0x24b>
  800e29:	89 75 08             	mov    %esi,0x8(%ebp)
  800e2c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e2f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e32:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e35:	83 c7 01             	add    $0x1,%edi
  800e38:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e3c:	0f be d0             	movsbl %al,%edx
  800e3f:	85 d2                	test   %edx,%edx
  800e41:	74 23                	je     800e66 <vprintfmt+0x27c>
  800e43:	85 f6                	test   %esi,%esi
  800e45:	78 a1                	js     800de8 <vprintfmt+0x1fe>
  800e47:	83 ee 01             	sub    $0x1,%esi
  800e4a:	79 9c                	jns    800de8 <vprintfmt+0x1fe>
  800e4c:	89 df                	mov    %ebx,%edi
  800e4e:	8b 75 08             	mov    0x8(%ebp),%esi
  800e51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e54:	eb 18                	jmp    800e6e <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e56:	83 ec 08             	sub    $0x8,%esp
  800e59:	53                   	push   %ebx
  800e5a:	6a 20                	push   $0x20
  800e5c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e5e:	83 ef 01             	sub    $0x1,%edi
  800e61:	83 c4 10             	add    $0x10,%esp
  800e64:	eb 08                	jmp    800e6e <vprintfmt+0x284>
  800e66:	89 df                	mov    %ebx,%edi
  800e68:	8b 75 08             	mov    0x8(%ebp),%esi
  800e6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e6e:	85 ff                	test   %edi,%edi
  800e70:	7f e4                	jg     800e56 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800e72:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800e75:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e78:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800e7b:	e9 90 fd ff ff       	jmp    800c10 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800e80:	83 f9 01             	cmp    $0x1,%ecx
  800e83:	7e 19                	jle    800e9e <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800e85:	8b 45 14             	mov    0x14(%ebp),%eax
  800e88:	8b 50 04             	mov    0x4(%eax),%edx
  800e8b:	8b 00                	mov    (%eax),%eax
  800e8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800e90:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800e93:	8b 45 14             	mov    0x14(%ebp),%eax
  800e96:	8d 40 08             	lea    0x8(%eax),%eax
  800e99:	89 45 14             	mov    %eax,0x14(%ebp)
  800e9c:	eb 38                	jmp    800ed6 <vprintfmt+0x2ec>
	else if (lflag)
  800e9e:	85 c9                	test   %ecx,%ecx
  800ea0:	74 1b                	je     800ebd <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800ea2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ea5:	8b 00                	mov    (%eax),%eax
  800ea7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800eaa:	89 c1                	mov    %eax,%ecx
  800eac:	c1 f9 1f             	sar    $0x1f,%ecx
  800eaf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800eb2:	8b 45 14             	mov    0x14(%ebp),%eax
  800eb5:	8d 40 04             	lea    0x4(%eax),%eax
  800eb8:	89 45 14             	mov    %eax,0x14(%ebp)
  800ebb:	eb 19                	jmp    800ed6 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800ebd:	8b 45 14             	mov    0x14(%ebp),%eax
  800ec0:	8b 00                	mov    (%eax),%eax
  800ec2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ec5:	89 c1                	mov    %eax,%ecx
  800ec7:	c1 f9 1f             	sar    $0x1f,%ecx
  800eca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ecd:	8b 45 14             	mov    0x14(%ebp),%eax
  800ed0:	8d 40 04             	lea    0x4(%eax),%eax
  800ed3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ed6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ed9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800edc:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ee1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ee5:	0f 89 0e 01 00 00    	jns    800ff9 <vprintfmt+0x40f>
				putch('-', putdat);
  800eeb:	83 ec 08             	sub    $0x8,%esp
  800eee:	53                   	push   %ebx
  800eef:	6a 2d                	push   $0x2d
  800ef1:	ff d6                	call   *%esi
				num = -(long long) num;
  800ef3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ef6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800ef9:	f7 da                	neg    %edx
  800efb:	83 d1 00             	adc    $0x0,%ecx
  800efe:	f7 d9                	neg    %ecx
  800f00:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800f03:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f08:	e9 ec 00 00 00       	jmp    800ff9 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800f0d:	83 f9 01             	cmp    $0x1,%ecx
  800f10:	7e 18                	jle    800f2a <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800f12:	8b 45 14             	mov    0x14(%ebp),%eax
  800f15:	8b 10                	mov    (%eax),%edx
  800f17:	8b 48 04             	mov    0x4(%eax),%ecx
  800f1a:	8d 40 08             	lea    0x8(%eax),%eax
  800f1d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800f20:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f25:	e9 cf 00 00 00       	jmp    800ff9 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800f2a:	85 c9                	test   %ecx,%ecx
  800f2c:	74 1a                	je     800f48 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800f2e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f31:	8b 10                	mov    (%eax),%edx
  800f33:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f38:	8d 40 04             	lea    0x4(%eax),%eax
  800f3b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800f3e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f43:	e9 b1 00 00 00       	jmp    800ff9 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800f48:	8b 45 14             	mov    0x14(%ebp),%eax
  800f4b:	8b 10                	mov    (%eax),%edx
  800f4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f52:	8d 40 04             	lea    0x4(%eax),%eax
  800f55:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800f58:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f5d:	e9 97 00 00 00       	jmp    800ff9 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800f62:	83 ec 08             	sub    $0x8,%esp
  800f65:	53                   	push   %ebx
  800f66:	6a 58                	push   $0x58
  800f68:	ff d6                	call   *%esi
			putch('X', putdat);
  800f6a:	83 c4 08             	add    $0x8,%esp
  800f6d:	53                   	push   %ebx
  800f6e:	6a 58                	push   $0x58
  800f70:	ff d6                	call   *%esi
			putch('X', putdat);
  800f72:	83 c4 08             	add    $0x8,%esp
  800f75:	53                   	push   %ebx
  800f76:	6a 58                	push   $0x58
  800f78:	ff d6                	call   *%esi
			break;
  800f7a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f7d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800f80:	e9 8b fc ff ff       	jmp    800c10 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800f85:	83 ec 08             	sub    $0x8,%esp
  800f88:	53                   	push   %ebx
  800f89:	6a 30                	push   $0x30
  800f8b:	ff d6                	call   *%esi
			putch('x', putdat);
  800f8d:	83 c4 08             	add    $0x8,%esp
  800f90:	53                   	push   %ebx
  800f91:	6a 78                	push   $0x78
  800f93:	ff d6                	call   *%esi
			num = (unsigned long long)
  800f95:	8b 45 14             	mov    0x14(%ebp),%eax
  800f98:	8b 10                	mov    (%eax),%edx
  800f9a:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800f9f:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800fa2:	8d 40 04             	lea    0x4(%eax),%eax
  800fa5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800fa8:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800fad:	eb 4a                	jmp    800ff9 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800faf:	83 f9 01             	cmp    $0x1,%ecx
  800fb2:	7e 15                	jle    800fc9 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800fb4:	8b 45 14             	mov    0x14(%ebp),%eax
  800fb7:	8b 10                	mov    (%eax),%edx
  800fb9:	8b 48 04             	mov    0x4(%eax),%ecx
  800fbc:	8d 40 08             	lea    0x8(%eax),%eax
  800fbf:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800fc2:	b8 10 00 00 00       	mov    $0x10,%eax
  800fc7:	eb 30                	jmp    800ff9 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800fc9:	85 c9                	test   %ecx,%ecx
  800fcb:	74 17                	je     800fe4 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800fcd:	8b 45 14             	mov    0x14(%ebp),%eax
  800fd0:	8b 10                	mov    (%eax),%edx
  800fd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fd7:	8d 40 04             	lea    0x4(%eax),%eax
  800fda:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800fdd:	b8 10 00 00 00       	mov    $0x10,%eax
  800fe2:	eb 15                	jmp    800ff9 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800fe4:	8b 45 14             	mov    0x14(%ebp),%eax
  800fe7:	8b 10                	mov    (%eax),%edx
  800fe9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fee:	8d 40 04             	lea    0x4(%eax),%eax
  800ff1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800ff4:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ff9:	83 ec 0c             	sub    $0xc,%esp
  800ffc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801000:	57                   	push   %edi
  801001:	ff 75 e0             	pushl  -0x20(%ebp)
  801004:	50                   	push   %eax
  801005:	51                   	push   %ecx
  801006:	52                   	push   %edx
  801007:	89 da                	mov    %ebx,%edx
  801009:	89 f0                	mov    %esi,%eax
  80100b:	e8 f1 fa ff ff       	call   800b01 <printnum>
			break;
  801010:	83 c4 20             	add    $0x20,%esp
  801013:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801016:	e9 f5 fb ff ff       	jmp    800c10 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80101b:	83 ec 08             	sub    $0x8,%esp
  80101e:	53                   	push   %ebx
  80101f:	52                   	push   %edx
  801020:	ff d6                	call   *%esi
			break;
  801022:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801025:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801028:	e9 e3 fb ff ff       	jmp    800c10 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80102d:	83 ec 08             	sub    $0x8,%esp
  801030:	53                   	push   %ebx
  801031:	6a 25                	push   $0x25
  801033:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801035:	83 c4 10             	add    $0x10,%esp
  801038:	eb 03                	jmp    80103d <vprintfmt+0x453>
  80103a:	83 ef 01             	sub    $0x1,%edi
  80103d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801041:	75 f7                	jne    80103a <vprintfmt+0x450>
  801043:	e9 c8 fb ff ff       	jmp    800c10 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801048:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104b:	5b                   	pop    %ebx
  80104c:	5e                   	pop    %esi
  80104d:	5f                   	pop    %edi
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    

00801050 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	83 ec 18             	sub    $0x18,%esp
  801056:	8b 45 08             	mov    0x8(%ebp),%eax
  801059:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80105c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80105f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801063:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801066:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80106d:	85 c0                	test   %eax,%eax
  80106f:	74 26                	je     801097 <vsnprintf+0x47>
  801071:	85 d2                	test   %edx,%edx
  801073:	7e 22                	jle    801097 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801075:	ff 75 14             	pushl  0x14(%ebp)
  801078:	ff 75 10             	pushl  0x10(%ebp)
  80107b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80107e:	50                   	push   %eax
  80107f:	68 b0 0b 80 00       	push   $0x800bb0
  801084:	e8 61 fb ff ff       	call   800bea <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801089:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80108c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80108f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801092:	83 c4 10             	add    $0x10,%esp
  801095:	eb 05                	jmp    80109c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801097:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80109c:	c9                   	leave  
  80109d:	c3                   	ret    

0080109e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80109e:	55                   	push   %ebp
  80109f:	89 e5                	mov    %esp,%ebp
  8010a1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8010a4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8010a7:	50                   	push   %eax
  8010a8:	ff 75 10             	pushl  0x10(%ebp)
  8010ab:	ff 75 0c             	pushl  0xc(%ebp)
  8010ae:	ff 75 08             	pushl  0x8(%ebp)
  8010b1:	e8 9a ff ff ff       	call   801050 <vsnprintf>
	va_end(ap);

	return rc;
}
  8010b6:	c9                   	leave  
  8010b7:	c3                   	ret    

008010b8 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	57                   	push   %edi
  8010bc:	56                   	push   %esi
  8010bd:	53                   	push   %ebx
  8010be:	83 ec 0c             	sub    $0xc,%esp
  8010c1:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	74 13                	je     8010db <readline+0x23>
		fprintf(1, "%s", prompt);
  8010c8:	83 ec 04             	sub    $0x4,%esp
  8010cb:	50                   	push   %eax
  8010cc:	68 0c 34 80 00       	push   $0x80340c
  8010d1:	6a 01                	push   $0x1
  8010d3:	e8 e1 13 00 00       	call   8024b9 <fprintf>
  8010d8:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  8010db:	83 ec 0c             	sub    $0xc,%esp
  8010de:	6a 00                	push   $0x0
  8010e0:	e8 49 f8 ff ff       	call   80092e <iscons>
  8010e5:	89 c7                	mov    %eax,%edi
  8010e7:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  8010ea:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8010ef:	e8 0f f8 ff ff       	call   800903 <getchar>
  8010f4:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	79 29                	jns    801123 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  8010fa:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  8010ff:	83 fb f8             	cmp    $0xfffffff8,%ebx
  801102:	0f 84 9b 00 00 00    	je     8011a3 <readline+0xeb>
				cprintf("read error: %e\n", c);
  801108:	83 ec 08             	sub    $0x8,%esp
  80110b:	53                   	push   %ebx
  80110c:	68 ff 37 80 00       	push   $0x8037ff
  801111:	e8 d7 f9 ff ff       	call   800aed <cprintf>
  801116:	83 c4 10             	add    $0x10,%esp
			return NULL;
  801119:	b8 00 00 00 00       	mov    $0x0,%eax
  80111e:	e9 80 00 00 00       	jmp    8011a3 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  801123:	83 f8 08             	cmp    $0x8,%eax
  801126:	0f 94 c2             	sete   %dl
  801129:	83 f8 7f             	cmp    $0x7f,%eax
  80112c:	0f 94 c0             	sete   %al
  80112f:	08 c2                	or     %al,%dl
  801131:	74 1a                	je     80114d <readline+0x95>
  801133:	85 f6                	test   %esi,%esi
  801135:	7e 16                	jle    80114d <readline+0x95>
			if (echoing)
  801137:	85 ff                	test   %edi,%edi
  801139:	74 0d                	je     801148 <readline+0x90>
				cputchar('\b');
  80113b:	83 ec 0c             	sub    $0xc,%esp
  80113e:	6a 08                	push   $0x8
  801140:	e8 a2 f7 ff ff       	call   8008e7 <cputchar>
  801145:	83 c4 10             	add    $0x10,%esp
			i--;
  801148:	83 ee 01             	sub    $0x1,%esi
  80114b:	eb a2                	jmp    8010ef <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  80114d:	83 fb 1f             	cmp    $0x1f,%ebx
  801150:	7e 26                	jle    801178 <readline+0xc0>
  801152:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  801158:	7f 1e                	jg     801178 <readline+0xc0>
			if (echoing)
  80115a:	85 ff                	test   %edi,%edi
  80115c:	74 0c                	je     80116a <readline+0xb2>
				cputchar(c);
  80115e:	83 ec 0c             	sub    $0xc,%esp
  801161:	53                   	push   %ebx
  801162:	e8 80 f7 ff ff       	call   8008e7 <cputchar>
  801167:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  80116a:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  801170:	8d 76 01             	lea    0x1(%esi),%esi
  801173:	e9 77 ff ff ff       	jmp    8010ef <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  801178:	83 fb 0a             	cmp    $0xa,%ebx
  80117b:	74 09                	je     801186 <readline+0xce>
  80117d:	83 fb 0d             	cmp    $0xd,%ebx
  801180:	0f 85 69 ff ff ff    	jne    8010ef <readline+0x37>
			if (echoing)
  801186:	85 ff                	test   %edi,%edi
  801188:	74 0d                	je     801197 <readline+0xdf>
				cputchar('\n');
  80118a:	83 ec 0c             	sub    $0xc,%esp
  80118d:	6a 0a                	push   $0xa
  80118f:	e8 53 f7 ff ff       	call   8008e7 <cputchar>
  801194:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  801197:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  80119e:	b8 20 50 80 00       	mov    $0x805020,%eax
		}
	}
}
  8011a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a6:	5b                   	pop    %ebx
  8011a7:	5e                   	pop    %esi
  8011a8:	5f                   	pop    %edi
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    

008011ab <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
  8011ae:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8011b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b6:	eb 03                	jmp    8011bb <strlen+0x10>
		n++;
  8011b8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8011bb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8011bf:	75 f7                	jne    8011b8 <strlen+0xd>
		n++;
	return n;
}
  8011c1:	5d                   	pop    %ebp
  8011c2:	c3                   	ret    

008011c3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d1:	eb 03                	jmp    8011d6 <strnlen+0x13>
		n++;
  8011d3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011d6:	39 c2                	cmp    %eax,%edx
  8011d8:	74 08                	je     8011e2 <strnlen+0x1f>
  8011da:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8011de:	75 f3                	jne    8011d3 <strnlen+0x10>
  8011e0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    

008011e4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
  8011e7:	53                   	push   %ebx
  8011e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8011ee:	89 c2                	mov    %eax,%edx
  8011f0:	83 c2 01             	add    $0x1,%edx
  8011f3:	83 c1 01             	add    $0x1,%ecx
  8011f6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8011fa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8011fd:	84 db                	test   %bl,%bl
  8011ff:	75 ef                	jne    8011f0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801201:	5b                   	pop    %ebx
  801202:	5d                   	pop    %ebp
  801203:	c3                   	ret    

00801204 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
  801207:	53                   	push   %ebx
  801208:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80120b:	53                   	push   %ebx
  80120c:	e8 9a ff ff ff       	call   8011ab <strlen>
  801211:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801214:	ff 75 0c             	pushl  0xc(%ebp)
  801217:	01 d8                	add    %ebx,%eax
  801219:	50                   	push   %eax
  80121a:	e8 c5 ff ff ff       	call   8011e4 <strcpy>
	return dst;
}
  80121f:	89 d8                	mov    %ebx,%eax
  801221:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801224:	c9                   	leave  
  801225:	c3                   	ret    

00801226 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	56                   	push   %esi
  80122a:	53                   	push   %ebx
  80122b:	8b 75 08             	mov    0x8(%ebp),%esi
  80122e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801231:	89 f3                	mov    %esi,%ebx
  801233:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801236:	89 f2                	mov    %esi,%edx
  801238:	eb 0f                	jmp    801249 <strncpy+0x23>
		*dst++ = *src;
  80123a:	83 c2 01             	add    $0x1,%edx
  80123d:	0f b6 01             	movzbl (%ecx),%eax
  801240:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801243:	80 39 01             	cmpb   $0x1,(%ecx)
  801246:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801249:	39 da                	cmp    %ebx,%edx
  80124b:	75 ed                	jne    80123a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80124d:	89 f0                	mov    %esi,%eax
  80124f:	5b                   	pop    %ebx
  801250:	5e                   	pop    %esi
  801251:	5d                   	pop    %ebp
  801252:	c3                   	ret    

00801253 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	56                   	push   %esi
  801257:	53                   	push   %ebx
  801258:	8b 75 08             	mov    0x8(%ebp),%esi
  80125b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80125e:	8b 55 10             	mov    0x10(%ebp),%edx
  801261:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801263:	85 d2                	test   %edx,%edx
  801265:	74 21                	je     801288 <strlcpy+0x35>
  801267:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80126b:	89 f2                	mov    %esi,%edx
  80126d:	eb 09                	jmp    801278 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80126f:	83 c2 01             	add    $0x1,%edx
  801272:	83 c1 01             	add    $0x1,%ecx
  801275:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801278:	39 c2                	cmp    %eax,%edx
  80127a:	74 09                	je     801285 <strlcpy+0x32>
  80127c:	0f b6 19             	movzbl (%ecx),%ebx
  80127f:	84 db                	test   %bl,%bl
  801281:	75 ec                	jne    80126f <strlcpy+0x1c>
  801283:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801285:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801288:	29 f0                	sub    %esi,%eax
}
  80128a:	5b                   	pop    %ebx
  80128b:	5e                   	pop    %esi
  80128c:	5d                   	pop    %ebp
  80128d:	c3                   	ret    

0080128e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80128e:	55                   	push   %ebp
  80128f:	89 e5                	mov    %esp,%ebp
  801291:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801294:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801297:	eb 06                	jmp    80129f <strcmp+0x11>
		p++, q++;
  801299:	83 c1 01             	add    $0x1,%ecx
  80129c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80129f:	0f b6 01             	movzbl (%ecx),%eax
  8012a2:	84 c0                	test   %al,%al
  8012a4:	74 04                	je     8012aa <strcmp+0x1c>
  8012a6:	3a 02                	cmp    (%edx),%al
  8012a8:	74 ef                	je     801299 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8012aa:	0f b6 c0             	movzbl %al,%eax
  8012ad:	0f b6 12             	movzbl (%edx),%edx
  8012b0:	29 d0                	sub    %edx,%eax
}
  8012b2:	5d                   	pop    %ebp
  8012b3:	c3                   	ret    

008012b4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
  8012b7:	53                   	push   %ebx
  8012b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012be:	89 c3                	mov    %eax,%ebx
  8012c0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8012c3:	eb 06                	jmp    8012cb <strncmp+0x17>
		n--, p++, q++;
  8012c5:	83 c0 01             	add    $0x1,%eax
  8012c8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8012cb:	39 d8                	cmp    %ebx,%eax
  8012cd:	74 15                	je     8012e4 <strncmp+0x30>
  8012cf:	0f b6 08             	movzbl (%eax),%ecx
  8012d2:	84 c9                	test   %cl,%cl
  8012d4:	74 04                	je     8012da <strncmp+0x26>
  8012d6:	3a 0a                	cmp    (%edx),%cl
  8012d8:	74 eb                	je     8012c5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8012da:	0f b6 00             	movzbl (%eax),%eax
  8012dd:	0f b6 12             	movzbl (%edx),%edx
  8012e0:	29 d0                	sub    %edx,%eax
  8012e2:	eb 05                	jmp    8012e9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8012e4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8012e9:	5b                   	pop    %ebx
  8012ea:	5d                   	pop    %ebp
  8012eb:	c3                   	ret    

008012ec <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8012ec:	55                   	push   %ebp
  8012ed:	89 e5                	mov    %esp,%ebp
  8012ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8012f6:	eb 07                	jmp    8012ff <strchr+0x13>
		if (*s == c)
  8012f8:	38 ca                	cmp    %cl,%dl
  8012fa:	74 0f                	je     80130b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8012fc:	83 c0 01             	add    $0x1,%eax
  8012ff:	0f b6 10             	movzbl (%eax),%edx
  801302:	84 d2                	test   %dl,%dl
  801304:	75 f2                	jne    8012f8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801306:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80130b:	5d                   	pop    %ebp
  80130c:	c3                   	ret    

0080130d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80130d:	55                   	push   %ebp
  80130e:	89 e5                	mov    %esp,%ebp
  801310:	8b 45 08             	mov    0x8(%ebp),%eax
  801313:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801317:	eb 03                	jmp    80131c <strfind+0xf>
  801319:	83 c0 01             	add    $0x1,%eax
  80131c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80131f:	38 ca                	cmp    %cl,%dl
  801321:	74 04                	je     801327 <strfind+0x1a>
  801323:	84 d2                	test   %dl,%dl
  801325:	75 f2                	jne    801319 <strfind+0xc>
			break;
	return (char *) s;
}
  801327:	5d                   	pop    %ebp
  801328:	c3                   	ret    

00801329 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801329:	55                   	push   %ebp
  80132a:	89 e5                	mov    %esp,%ebp
  80132c:	57                   	push   %edi
  80132d:	56                   	push   %esi
  80132e:	53                   	push   %ebx
  80132f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801332:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801335:	85 c9                	test   %ecx,%ecx
  801337:	74 36                	je     80136f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801339:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80133f:	75 28                	jne    801369 <memset+0x40>
  801341:	f6 c1 03             	test   $0x3,%cl
  801344:	75 23                	jne    801369 <memset+0x40>
		c &= 0xFF;
  801346:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80134a:	89 d3                	mov    %edx,%ebx
  80134c:	c1 e3 08             	shl    $0x8,%ebx
  80134f:	89 d6                	mov    %edx,%esi
  801351:	c1 e6 18             	shl    $0x18,%esi
  801354:	89 d0                	mov    %edx,%eax
  801356:	c1 e0 10             	shl    $0x10,%eax
  801359:	09 f0                	or     %esi,%eax
  80135b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80135d:	89 d8                	mov    %ebx,%eax
  80135f:	09 d0                	or     %edx,%eax
  801361:	c1 e9 02             	shr    $0x2,%ecx
  801364:	fc                   	cld    
  801365:	f3 ab                	rep stos %eax,%es:(%edi)
  801367:	eb 06                	jmp    80136f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801369:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136c:	fc                   	cld    
  80136d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80136f:	89 f8                	mov    %edi,%eax
  801371:	5b                   	pop    %ebx
  801372:	5e                   	pop    %esi
  801373:	5f                   	pop    %edi
  801374:	5d                   	pop    %ebp
  801375:	c3                   	ret    

00801376 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
  801379:	57                   	push   %edi
  80137a:	56                   	push   %esi
  80137b:	8b 45 08             	mov    0x8(%ebp),%eax
  80137e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801381:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801384:	39 c6                	cmp    %eax,%esi
  801386:	73 35                	jae    8013bd <memmove+0x47>
  801388:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80138b:	39 d0                	cmp    %edx,%eax
  80138d:	73 2e                	jae    8013bd <memmove+0x47>
		s += n;
		d += n;
  80138f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801392:	89 d6                	mov    %edx,%esi
  801394:	09 fe                	or     %edi,%esi
  801396:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80139c:	75 13                	jne    8013b1 <memmove+0x3b>
  80139e:	f6 c1 03             	test   $0x3,%cl
  8013a1:	75 0e                	jne    8013b1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8013a3:	83 ef 04             	sub    $0x4,%edi
  8013a6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8013a9:	c1 e9 02             	shr    $0x2,%ecx
  8013ac:	fd                   	std    
  8013ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8013af:	eb 09                	jmp    8013ba <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8013b1:	83 ef 01             	sub    $0x1,%edi
  8013b4:	8d 72 ff             	lea    -0x1(%edx),%esi
  8013b7:	fd                   	std    
  8013b8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8013ba:	fc                   	cld    
  8013bb:	eb 1d                	jmp    8013da <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013bd:	89 f2                	mov    %esi,%edx
  8013bf:	09 c2                	or     %eax,%edx
  8013c1:	f6 c2 03             	test   $0x3,%dl
  8013c4:	75 0f                	jne    8013d5 <memmove+0x5f>
  8013c6:	f6 c1 03             	test   $0x3,%cl
  8013c9:	75 0a                	jne    8013d5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8013cb:	c1 e9 02             	shr    $0x2,%ecx
  8013ce:	89 c7                	mov    %eax,%edi
  8013d0:	fc                   	cld    
  8013d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8013d3:	eb 05                	jmp    8013da <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8013d5:	89 c7                	mov    %eax,%edi
  8013d7:	fc                   	cld    
  8013d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8013da:	5e                   	pop    %esi
  8013db:	5f                   	pop    %edi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8013e1:	ff 75 10             	pushl  0x10(%ebp)
  8013e4:	ff 75 0c             	pushl  0xc(%ebp)
  8013e7:	ff 75 08             	pushl  0x8(%ebp)
  8013ea:	e8 87 ff ff ff       	call   801376 <memmove>
}
  8013ef:	c9                   	leave  
  8013f0:	c3                   	ret    

008013f1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	56                   	push   %esi
  8013f5:	53                   	push   %ebx
  8013f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013fc:	89 c6                	mov    %eax,%esi
  8013fe:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801401:	eb 1a                	jmp    80141d <memcmp+0x2c>
		if (*s1 != *s2)
  801403:	0f b6 08             	movzbl (%eax),%ecx
  801406:	0f b6 1a             	movzbl (%edx),%ebx
  801409:	38 d9                	cmp    %bl,%cl
  80140b:	74 0a                	je     801417 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80140d:	0f b6 c1             	movzbl %cl,%eax
  801410:	0f b6 db             	movzbl %bl,%ebx
  801413:	29 d8                	sub    %ebx,%eax
  801415:	eb 0f                	jmp    801426 <memcmp+0x35>
		s1++, s2++;
  801417:	83 c0 01             	add    $0x1,%eax
  80141a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80141d:	39 f0                	cmp    %esi,%eax
  80141f:	75 e2                	jne    801403 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801421:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801426:	5b                   	pop    %ebx
  801427:	5e                   	pop    %esi
  801428:	5d                   	pop    %ebp
  801429:	c3                   	ret    

0080142a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	53                   	push   %ebx
  80142e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801431:	89 c1                	mov    %eax,%ecx
  801433:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801436:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80143a:	eb 0a                	jmp    801446 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80143c:	0f b6 10             	movzbl (%eax),%edx
  80143f:	39 da                	cmp    %ebx,%edx
  801441:	74 07                	je     80144a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801443:	83 c0 01             	add    $0x1,%eax
  801446:	39 c8                	cmp    %ecx,%eax
  801448:	72 f2                	jb     80143c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80144a:	5b                   	pop    %ebx
  80144b:	5d                   	pop    %ebp
  80144c:	c3                   	ret    

0080144d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80144d:	55                   	push   %ebp
  80144e:	89 e5                	mov    %esp,%ebp
  801450:	57                   	push   %edi
  801451:	56                   	push   %esi
  801452:	53                   	push   %ebx
  801453:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801456:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801459:	eb 03                	jmp    80145e <strtol+0x11>
		s++;
  80145b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80145e:	0f b6 01             	movzbl (%ecx),%eax
  801461:	3c 20                	cmp    $0x20,%al
  801463:	74 f6                	je     80145b <strtol+0xe>
  801465:	3c 09                	cmp    $0x9,%al
  801467:	74 f2                	je     80145b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801469:	3c 2b                	cmp    $0x2b,%al
  80146b:	75 0a                	jne    801477 <strtol+0x2a>
		s++;
  80146d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801470:	bf 00 00 00 00       	mov    $0x0,%edi
  801475:	eb 11                	jmp    801488 <strtol+0x3b>
  801477:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80147c:	3c 2d                	cmp    $0x2d,%al
  80147e:	75 08                	jne    801488 <strtol+0x3b>
		s++, neg = 1;
  801480:	83 c1 01             	add    $0x1,%ecx
  801483:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801488:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80148e:	75 15                	jne    8014a5 <strtol+0x58>
  801490:	80 39 30             	cmpb   $0x30,(%ecx)
  801493:	75 10                	jne    8014a5 <strtol+0x58>
  801495:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801499:	75 7c                	jne    801517 <strtol+0xca>
		s += 2, base = 16;
  80149b:	83 c1 02             	add    $0x2,%ecx
  80149e:	bb 10 00 00 00       	mov    $0x10,%ebx
  8014a3:	eb 16                	jmp    8014bb <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8014a5:	85 db                	test   %ebx,%ebx
  8014a7:	75 12                	jne    8014bb <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8014a9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8014ae:	80 39 30             	cmpb   $0x30,(%ecx)
  8014b1:	75 08                	jne    8014bb <strtol+0x6e>
		s++, base = 8;
  8014b3:	83 c1 01             	add    $0x1,%ecx
  8014b6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8014bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8014c3:	0f b6 11             	movzbl (%ecx),%edx
  8014c6:	8d 72 d0             	lea    -0x30(%edx),%esi
  8014c9:	89 f3                	mov    %esi,%ebx
  8014cb:	80 fb 09             	cmp    $0x9,%bl
  8014ce:	77 08                	ja     8014d8 <strtol+0x8b>
			dig = *s - '0';
  8014d0:	0f be d2             	movsbl %dl,%edx
  8014d3:	83 ea 30             	sub    $0x30,%edx
  8014d6:	eb 22                	jmp    8014fa <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8014d8:	8d 72 9f             	lea    -0x61(%edx),%esi
  8014db:	89 f3                	mov    %esi,%ebx
  8014dd:	80 fb 19             	cmp    $0x19,%bl
  8014e0:	77 08                	ja     8014ea <strtol+0x9d>
			dig = *s - 'a' + 10;
  8014e2:	0f be d2             	movsbl %dl,%edx
  8014e5:	83 ea 57             	sub    $0x57,%edx
  8014e8:	eb 10                	jmp    8014fa <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8014ea:	8d 72 bf             	lea    -0x41(%edx),%esi
  8014ed:	89 f3                	mov    %esi,%ebx
  8014ef:	80 fb 19             	cmp    $0x19,%bl
  8014f2:	77 16                	ja     80150a <strtol+0xbd>
			dig = *s - 'A' + 10;
  8014f4:	0f be d2             	movsbl %dl,%edx
  8014f7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8014fa:	3b 55 10             	cmp    0x10(%ebp),%edx
  8014fd:	7d 0b                	jge    80150a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8014ff:	83 c1 01             	add    $0x1,%ecx
  801502:	0f af 45 10          	imul   0x10(%ebp),%eax
  801506:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801508:	eb b9                	jmp    8014c3 <strtol+0x76>

	if (endptr)
  80150a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80150e:	74 0d                	je     80151d <strtol+0xd0>
		*endptr = (char *) s;
  801510:	8b 75 0c             	mov    0xc(%ebp),%esi
  801513:	89 0e                	mov    %ecx,(%esi)
  801515:	eb 06                	jmp    80151d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801517:	85 db                	test   %ebx,%ebx
  801519:	74 98                	je     8014b3 <strtol+0x66>
  80151b:	eb 9e                	jmp    8014bb <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80151d:	89 c2                	mov    %eax,%edx
  80151f:	f7 da                	neg    %edx
  801521:	85 ff                	test   %edi,%edi
  801523:	0f 45 c2             	cmovne %edx,%eax
}
  801526:	5b                   	pop    %ebx
  801527:	5e                   	pop    %esi
  801528:	5f                   	pop    %edi
  801529:	5d                   	pop    %ebp
  80152a:	c3                   	ret    

0080152b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	57                   	push   %edi
  80152f:	56                   	push   %esi
  801530:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801531:	b8 00 00 00 00       	mov    $0x0,%eax
  801536:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801539:	8b 55 08             	mov    0x8(%ebp),%edx
  80153c:	89 c3                	mov    %eax,%ebx
  80153e:	89 c7                	mov    %eax,%edi
  801540:	89 c6                	mov    %eax,%esi
  801542:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801544:	5b                   	pop    %ebx
  801545:	5e                   	pop    %esi
  801546:	5f                   	pop    %edi
  801547:	5d                   	pop    %ebp
  801548:	c3                   	ret    

00801549 <sys_cgetc>:

int
sys_cgetc(void)
{
  801549:	55                   	push   %ebp
  80154a:	89 e5                	mov    %esp,%ebp
  80154c:	57                   	push   %edi
  80154d:	56                   	push   %esi
  80154e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80154f:	ba 00 00 00 00       	mov    $0x0,%edx
  801554:	b8 01 00 00 00       	mov    $0x1,%eax
  801559:	89 d1                	mov    %edx,%ecx
  80155b:	89 d3                	mov    %edx,%ebx
  80155d:	89 d7                	mov    %edx,%edi
  80155f:	89 d6                	mov    %edx,%esi
  801561:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801563:	5b                   	pop    %ebx
  801564:	5e                   	pop    %esi
  801565:	5f                   	pop    %edi
  801566:	5d                   	pop    %ebp
  801567:	c3                   	ret    

00801568 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801568:	55                   	push   %ebp
  801569:	89 e5                	mov    %esp,%ebp
  80156b:	57                   	push   %edi
  80156c:	56                   	push   %esi
  80156d:	53                   	push   %ebx
  80156e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801571:	b9 00 00 00 00       	mov    $0x0,%ecx
  801576:	b8 03 00 00 00       	mov    $0x3,%eax
  80157b:	8b 55 08             	mov    0x8(%ebp),%edx
  80157e:	89 cb                	mov    %ecx,%ebx
  801580:	89 cf                	mov    %ecx,%edi
  801582:	89 ce                	mov    %ecx,%esi
  801584:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801586:	85 c0                	test   %eax,%eax
  801588:	7e 17                	jle    8015a1 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80158a:	83 ec 0c             	sub    $0xc,%esp
  80158d:	50                   	push   %eax
  80158e:	6a 03                	push   $0x3
  801590:	68 0f 38 80 00       	push   $0x80380f
  801595:	6a 23                	push   $0x23
  801597:	68 2c 38 80 00       	push   $0x80382c
  80159c:	e8 73 f4 ff ff       	call   800a14 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8015a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a4:	5b                   	pop    %ebx
  8015a5:	5e                   	pop    %esi
  8015a6:	5f                   	pop    %edi
  8015a7:	5d                   	pop    %ebp
  8015a8:	c3                   	ret    

008015a9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	57                   	push   %edi
  8015ad:	56                   	push   %esi
  8015ae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015af:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b4:	b8 02 00 00 00       	mov    $0x2,%eax
  8015b9:	89 d1                	mov    %edx,%ecx
  8015bb:	89 d3                	mov    %edx,%ebx
  8015bd:	89 d7                	mov    %edx,%edi
  8015bf:	89 d6                	mov    %edx,%esi
  8015c1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8015c3:	5b                   	pop    %ebx
  8015c4:	5e                   	pop    %esi
  8015c5:	5f                   	pop    %edi
  8015c6:	5d                   	pop    %ebp
  8015c7:	c3                   	ret    

008015c8 <sys_yield>:

void
sys_yield(void)
{
  8015c8:	55                   	push   %ebp
  8015c9:	89 e5                	mov    %esp,%ebp
  8015cb:	57                   	push   %edi
  8015cc:	56                   	push   %esi
  8015cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8015d8:	89 d1                	mov    %edx,%ecx
  8015da:	89 d3                	mov    %edx,%ebx
  8015dc:	89 d7                	mov    %edx,%edi
  8015de:	89 d6                	mov    %edx,%esi
  8015e0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8015e2:	5b                   	pop    %ebx
  8015e3:	5e                   	pop    %esi
  8015e4:	5f                   	pop    %edi
  8015e5:	5d                   	pop    %ebp
  8015e6:	c3                   	ret    

008015e7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8015e7:	55                   	push   %ebp
  8015e8:	89 e5                	mov    %esp,%ebp
  8015ea:	57                   	push   %edi
  8015eb:	56                   	push   %esi
  8015ec:	53                   	push   %ebx
  8015ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015f0:	be 00 00 00 00       	mov    $0x0,%esi
  8015f5:	b8 04 00 00 00       	mov    $0x4,%eax
  8015fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015fd:	8b 55 08             	mov    0x8(%ebp),%edx
  801600:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801603:	89 f7                	mov    %esi,%edi
  801605:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801607:	85 c0                	test   %eax,%eax
  801609:	7e 17                	jle    801622 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80160b:	83 ec 0c             	sub    $0xc,%esp
  80160e:	50                   	push   %eax
  80160f:	6a 04                	push   $0x4
  801611:	68 0f 38 80 00       	push   $0x80380f
  801616:	6a 23                	push   $0x23
  801618:	68 2c 38 80 00       	push   $0x80382c
  80161d:	e8 f2 f3 ff ff       	call   800a14 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801622:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801625:	5b                   	pop    %ebx
  801626:	5e                   	pop    %esi
  801627:	5f                   	pop    %edi
  801628:	5d                   	pop    %ebp
  801629:	c3                   	ret    

0080162a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	57                   	push   %edi
  80162e:	56                   	push   %esi
  80162f:	53                   	push   %ebx
  801630:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801633:	b8 05 00 00 00       	mov    $0x5,%eax
  801638:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80163b:	8b 55 08             	mov    0x8(%ebp),%edx
  80163e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801641:	8b 7d 14             	mov    0x14(%ebp),%edi
  801644:	8b 75 18             	mov    0x18(%ebp),%esi
  801647:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801649:	85 c0                	test   %eax,%eax
  80164b:	7e 17                	jle    801664 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80164d:	83 ec 0c             	sub    $0xc,%esp
  801650:	50                   	push   %eax
  801651:	6a 05                	push   $0x5
  801653:	68 0f 38 80 00       	push   $0x80380f
  801658:	6a 23                	push   $0x23
  80165a:	68 2c 38 80 00       	push   $0x80382c
  80165f:	e8 b0 f3 ff ff       	call   800a14 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801664:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801667:	5b                   	pop    %ebx
  801668:	5e                   	pop    %esi
  801669:	5f                   	pop    %edi
  80166a:	5d                   	pop    %ebp
  80166b:	c3                   	ret    

0080166c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	57                   	push   %edi
  801670:	56                   	push   %esi
  801671:	53                   	push   %ebx
  801672:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801675:	bb 00 00 00 00       	mov    $0x0,%ebx
  80167a:	b8 06 00 00 00       	mov    $0x6,%eax
  80167f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801682:	8b 55 08             	mov    0x8(%ebp),%edx
  801685:	89 df                	mov    %ebx,%edi
  801687:	89 de                	mov    %ebx,%esi
  801689:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80168b:	85 c0                	test   %eax,%eax
  80168d:	7e 17                	jle    8016a6 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80168f:	83 ec 0c             	sub    $0xc,%esp
  801692:	50                   	push   %eax
  801693:	6a 06                	push   $0x6
  801695:	68 0f 38 80 00       	push   $0x80380f
  80169a:	6a 23                	push   $0x23
  80169c:	68 2c 38 80 00       	push   $0x80382c
  8016a1:	e8 6e f3 ff ff       	call   800a14 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8016a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a9:	5b                   	pop    %ebx
  8016aa:	5e                   	pop    %esi
  8016ab:	5f                   	pop    %edi
  8016ac:	5d                   	pop    %ebp
  8016ad:	c3                   	ret    

008016ae <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	57                   	push   %edi
  8016b2:	56                   	push   %esi
  8016b3:	53                   	push   %ebx
  8016b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016bc:	b8 08 00 00 00       	mov    $0x8,%eax
  8016c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8016c7:	89 df                	mov    %ebx,%edi
  8016c9:	89 de                	mov    %ebx,%esi
  8016cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016cd:	85 c0                	test   %eax,%eax
  8016cf:	7e 17                	jle    8016e8 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016d1:	83 ec 0c             	sub    $0xc,%esp
  8016d4:	50                   	push   %eax
  8016d5:	6a 08                	push   $0x8
  8016d7:	68 0f 38 80 00       	push   $0x80380f
  8016dc:	6a 23                	push   $0x23
  8016de:	68 2c 38 80 00       	push   $0x80382c
  8016e3:	e8 2c f3 ff ff       	call   800a14 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8016e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016eb:	5b                   	pop    %ebx
  8016ec:	5e                   	pop    %esi
  8016ed:	5f                   	pop    %edi
  8016ee:	5d                   	pop    %ebp
  8016ef:	c3                   	ret    

008016f0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	57                   	push   %edi
  8016f4:	56                   	push   %esi
  8016f5:	53                   	push   %ebx
  8016f6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016fe:	b8 09 00 00 00       	mov    $0x9,%eax
  801703:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801706:	8b 55 08             	mov    0x8(%ebp),%edx
  801709:	89 df                	mov    %ebx,%edi
  80170b:	89 de                	mov    %ebx,%esi
  80170d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80170f:	85 c0                	test   %eax,%eax
  801711:	7e 17                	jle    80172a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801713:	83 ec 0c             	sub    $0xc,%esp
  801716:	50                   	push   %eax
  801717:	6a 09                	push   $0x9
  801719:	68 0f 38 80 00       	push   $0x80380f
  80171e:	6a 23                	push   $0x23
  801720:	68 2c 38 80 00       	push   $0x80382c
  801725:	e8 ea f2 ff ff       	call   800a14 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80172a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172d:	5b                   	pop    %ebx
  80172e:	5e                   	pop    %esi
  80172f:	5f                   	pop    %edi
  801730:	5d                   	pop    %ebp
  801731:	c3                   	ret    

00801732 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	57                   	push   %edi
  801736:	56                   	push   %esi
  801737:	53                   	push   %ebx
  801738:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80173b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801740:	b8 0a 00 00 00       	mov    $0xa,%eax
  801745:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801748:	8b 55 08             	mov    0x8(%ebp),%edx
  80174b:	89 df                	mov    %ebx,%edi
  80174d:	89 de                	mov    %ebx,%esi
  80174f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801751:	85 c0                	test   %eax,%eax
  801753:	7e 17                	jle    80176c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801755:	83 ec 0c             	sub    $0xc,%esp
  801758:	50                   	push   %eax
  801759:	6a 0a                	push   $0xa
  80175b:	68 0f 38 80 00       	push   $0x80380f
  801760:	6a 23                	push   $0x23
  801762:	68 2c 38 80 00       	push   $0x80382c
  801767:	e8 a8 f2 ff ff       	call   800a14 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80176c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80176f:	5b                   	pop    %ebx
  801770:	5e                   	pop    %esi
  801771:	5f                   	pop    %edi
  801772:	5d                   	pop    %ebp
  801773:	c3                   	ret    

00801774 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	57                   	push   %edi
  801778:	56                   	push   %esi
  801779:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80177a:	be 00 00 00 00       	mov    $0x0,%esi
  80177f:	b8 0c 00 00 00       	mov    $0xc,%eax
  801784:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801787:	8b 55 08             	mov    0x8(%ebp),%edx
  80178a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80178d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801790:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801792:	5b                   	pop    %ebx
  801793:	5e                   	pop    %esi
  801794:	5f                   	pop    %edi
  801795:	5d                   	pop    %ebp
  801796:	c3                   	ret    

00801797 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	57                   	push   %edi
  80179b:	56                   	push   %esi
  80179c:	53                   	push   %ebx
  80179d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017a5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8017aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8017ad:	89 cb                	mov    %ecx,%ebx
  8017af:	89 cf                	mov    %ecx,%edi
  8017b1:	89 ce                	mov    %ecx,%esi
  8017b3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	7e 17                	jle    8017d0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017b9:	83 ec 0c             	sub    $0xc,%esp
  8017bc:	50                   	push   %eax
  8017bd:	6a 0d                	push   $0xd
  8017bf:	68 0f 38 80 00       	push   $0x80380f
  8017c4:	6a 23                	push   $0x23
  8017c6:	68 2c 38 80 00       	push   $0x80382c
  8017cb:	e8 44 f2 ff ff       	call   800a14 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8017d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017d3:	5b                   	pop    %ebx
  8017d4:	5e                   	pop    %esi
  8017d5:	5f                   	pop    %edi
  8017d6:	5d                   	pop    %ebp
  8017d7:	c3                   	ret    

008017d8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8017d8:	55                   	push   %ebp
  8017d9:	89 e5                	mov    %esp,%ebp
  8017db:	53                   	push   %ebx
  8017dc:	83 ec 04             	sub    $0x4,%esp
  8017df:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8017e2:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  8017e4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8017e8:	74 2d                	je     801817 <pgfault+0x3f>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  8017ea:	89 d8                	mov    %ebx,%eax
  8017ec:	c1 e8 16             	shr    $0x16,%eax
  8017ef:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8017f6:	a8 01                	test   $0x1,%al
  8017f8:	74 1d                	je     801817 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  8017fa:	89 d8                	mov    %ebx,%eax
  8017fc:	c1 e8 0c             	shr    $0xc,%eax
  8017ff:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  801806:	f6 c2 01             	test   $0x1,%dl
  801809:	74 0c                	je     801817 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  80180b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  801812:	f6 c4 08             	test   $0x8,%ah
  801815:	75 14                	jne    80182b <pgfault+0x53>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
	)) panic("Neither the fault is a write nor copy-on-write page.\n");
  801817:	83 ec 04             	sub    $0x4,%esp
  80181a:	68 3c 38 80 00       	push   $0x80383c
  80181f:	6a 1f                	push   $0x1f
  801821:	68 72 38 80 00       	push   $0x803872
  801826:	e8 e9 f1 ff ff       	call   800a14 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if((r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W)) < 0){
  80182b:	83 ec 04             	sub    $0x4,%esp
  80182e:	6a 07                	push   $0x7
  801830:	68 00 f0 7f 00       	push   $0x7ff000
  801835:	6a 00                	push   $0x0
  801837:	e8 ab fd ff ff       	call   8015e7 <sys_page_alloc>
  80183c:	83 c4 10             	add    $0x10,%esp
  80183f:	85 c0                	test   %eax,%eax
  801841:	79 12                	jns    801855 <pgfault+0x7d>
		 panic("sys_page_alloc: %e\n", r);
  801843:	50                   	push   %eax
  801844:	68 7d 38 80 00       	push   $0x80387d
  801849:	6a 29                	push   $0x29
  80184b:	68 72 38 80 00       	push   $0x803872
  801850:	e8 bf f1 ff ff       	call   800a14 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  801855:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP, addr, PGSIZE);
  80185b:	83 ec 04             	sub    $0x4,%esp
  80185e:	68 00 10 00 00       	push   $0x1000
  801863:	53                   	push   %ebx
  801864:	68 00 f0 7f 00       	push   $0x7ff000
  801869:	e8 70 fb ff ff       	call   8013de <memcpy>
	if ((r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  80186e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801875:	53                   	push   %ebx
  801876:	6a 00                	push   $0x0
  801878:	68 00 f0 7f 00       	push   $0x7ff000
  80187d:	6a 00                	push   $0x0
  80187f:	e8 a6 fd ff ff       	call   80162a <sys_page_map>
  801884:	83 c4 20             	add    $0x20,%esp
  801887:	85 c0                	test   %eax,%eax
  801889:	79 12                	jns    80189d <pgfault+0xc5>
        panic("sys_page_map: %e\n", r);
  80188b:	50                   	push   %eax
  80188c:	68 91 38 80 00       	push   $0x803891
  801891:	6a 2e                	push   $0x2e
  801893:	68 72 38 80 00       	push   $0x803872
  801898:	e8 77 f1 ff ff       	call   800a14 <_panic>
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  80189d:	83 ec 08             	sub    $0x8,%esp
  8018a0:	68 00 f0 7f 00       	push   $0x7ff000
  8018a5:	6a 00                	push   $0x0
  8018a7:	e8 c0 fd ff ff       	call   80166c <sys_page_unmap>
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	79 12                	jns    8018c5 <pgfault+0xed>
        panic("sys_page_unmap: %e\n", r);
  8018b3:	50                   	push   %eax
  8018b4:	68 a3 38 80 00       	push   $0x8038a3
  8018b9:	6a 30                	push   $0x30
  8018bb:	68 72 38 80 00       	push   $0x803872
  8018c0:	e8 4f f1 ff ff       	call   800a14 <_panic>
	//panic("pgfault not implemented");
}
  8018c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c8:	c9                   	leave  
  8018c9:	c3                   	ret    

008018ca <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	57                   	push   %edi
  8018ce:	56                   	push   %esi
  8018cf:	53                   	push   %ebx
  8018d0:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	envid_t cenvid;
    unsigned pn;
    int r;
	set_pgfault_handler(pgfault);
  8018d3:	68 d8 17 80 00       	push   $0x8017d8
  8018d8:	e8 8f 15 00 00       	call   802e6c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8018dd:	b8 07 00 00 00       	mov    $0x7,%eax
  8018e2:	cd 30                	int    $0x30
  8018e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((cenvid = sys_exofork()) < 0){
  8018e7:	83 c4 10             	add    $0x10,%esp
  8018ea:	85 c0                	test   %eax,%eax
  8018ec:	79 14                	jns    801902 <fork+0x38>
		panic("sys_exofork failed");
  8018ee:	83 ec 04             	sub    $0x4,%esp
  8018f1:	68 b7 38 80 00       	push   $0x8038b7
  8018f6:	6a 6f                	push   $0x6f
  8018f8:	68 72 38 80 00       	push   $0x803872
  8018fd:	e8 12 f1 ff ff       	call   800a14 <_panic>
  801902:	89 c7                	mov    %eax,%edi
		return cenvid;
	}
	if(cenvid>0){
  801904:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801908:	0f 8e 2b 01 00 00    	jle    801a39 <fork+0x16f>
  80190e:	bb 00 08 00 00       	mov    $0x800,%ebx
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
  801913:	89 d8                	mov    %ebx,%eax
  801915:	c1 e8 0a             	shr    $0xa,%eax
  801918:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80191f:	a8 01                	test   $0x1,%al
  801921:	0f 84 bf 00 00 00    	je     8019e6 <fork+0x11c>
  801927:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80192e:	a8 01                	test   $0x1,%al
  801930:	0f 84 b0 00 00 00    	je     8019e6 <fork+0x11c>
  801936:	89 de                	mov    %ebx,%esi
  801938:	c1 e6 0c             	shl    $0xc,%esi
{
	int r;

	// LAB 4: Your code here.
	void* vaddr=(void*)(pn*PGSIZE);
	if(uvpt[pn]&PTE_SHARE){
  80193b:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801942:	f6 c4 04             	test   $0x4,%ah
  801945:	74 29                	je     801970 <fork+0xa6>
		if((r=sys_page_map(0,vaddr,envid,vaddr,uvpt[pn]&PTE_SYSCALL))<0)return r;
  801947:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80194e:	83 ec 0c             	sub    $0xc,%esp
  801951:	25 07 0e 00 00       	and    $0xe07,%eax
  801956:	50                   	push   %eax
  801957:	56                   	push   %esi
  801958:	57                   	push   %edi
  801959:	56                   	push   %esi
  80195a:	6a 00                	push   $0x0
  80195c:	e8 c9 fc ff ff       	call   80162a <sys_page_map>
  801961:	83 c4 20             	add    $0x20,%esp
  801964:	85 c0                	test   %eax,%eax
  801966:	ba 00 00 00 00       	mov    $0x0,%edx
  80196b:	0f 4f c2             	cmovg  %edx,%eax
  80196e:	eb 72                	jmp    8019e2 <fork+0x118>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  801970:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801977:	a8 02                	test   $0x2,%al
  801979:	75 0c                	jne    801987 <fork+0xbd>
  80197b:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801982:	f6 c4 08             	test   $0x8,%ah
  801985:	74 3f                	je     8019c6 <fork+0xfc>
		if ((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  801987:	83 ec 0c             	sub    $0xc,%esp
  80198a:	68 05 08 00 00       	push   $0x805
  80198f:	56                   	push   %esi
  801990:	57                   	push   %edi
  801991:	56                   	push   %esi
  801992:	6a 00                	push   $0x0
  801994:	e8 91 fc ff ff       	call   80162a <sys_page_map>
  801999:	83 c4 20             	add    $0x20,%esp
  80199c:	85 c0                	test   %eax,%eax
  80199e:	0f 88 b1 00 00 00    	js     801a55 <fork+0x18b>
            return r;
        if ((r = sys_page_map(0, vaddr, 0, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  8019a4:	83 ec 0c             	sub    $0xc,%esp
  8019a7:	68 05 08 00 00       	push   $0x805
  8019ac:	56                   	push   %esi
  8019ad:	6a 00                	push   $0x0
  8019af:	56                   	push   %esi
  8019b0:	6a 00                	push   $0x0
  8019b2:	e8 73 fc ff ff       	call   80162a <sys_page_map>
  8019b7:	83 c4 20             	add    $0x20,%esp
  8019ba:	85 c0                	test   %eax,%eax
  8019bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019c1:	0f 4f c1             	cmovg  %ecx,%eax
  8019c4:	eb 1c                	jmp    8019e2 <fork+0x118>
            return r;
	}
	else if((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U)) < 0) {
  8019c6:	83 ec 0c             	sub    $0xc,%esp
  8019c9:	6a 05                	push   $0x5
  8019cb:	56                   	push   %esi
  8019cc:	57                   	push   %edi
  8019cd:	56                   	push   %esi
  8019ce:	6a 00                	push   $0x0
  8019d0:	e8 55 fc ff ff       	call   80162a <sys_page_map>
  8019d5:	83 c4 20             	add    $0x20,%esp
  8019d8:	85 c0                	test   %eax,%eax
  8019da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019df:	0f 4f c1             	cmovg  %ecx,%eax
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
  8019e2:	85 c0                	test   %eax,%eax
  8019e4:	78 6f                	js     801a55 <fork+0x18b>
	if ((cenvid = sys_exofork()) < 0){
		panic("sys_exofork failed");
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  8019e6:	83 c3 01             	add    $0x1,%ebx
  8019e9:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  8019ef:	0f 85 1e ff ff ff    	jne    801913 <fork+0x49>
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
                    return r;
		}
		if ((r = sys_page_alloc(cenvid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  8019f5:	83 ec 04             	sub    $0x4,%esp
  8019f8:	6a 07                	push   $0x7
  8019fa:	68 00 f0 bf ee       	push   $0xeebff000
  8019ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a02:	57                   	push   %edi
  801a03:	e8 df fb ff ff       	call   8015e7 <sys_page_alloc>
  801a08:	83 c4 10             	add    $0x10,%esp
  801a0b:	85 c0                	test   %eax,%eax
  801a0d:	78 46                	js     801a55 <fork+0x18b>
            return r;
		extern void _pgfault_upcall(void);
		if ((r = sys_env_set_pgfault_upcall(cenvid, _pgfault_upcall)) < 0)
  801a0f:	83 ec 08             	sub    $0x8,%esp
  801a12:	68 cf 2e 80 00       	push   $0x802ecf
  801a17:	57                   	push   %edi
  801a18:	e8 15 fd ff ff       	call   801732 <sys_env_set_pgfault_upcall>
  801a1d:	83 c4 10             	add    $0x10,%esp
  801a20:	85 c0                	test   %eax,%eax
  801a22:	78 31                	js     801a55 <fork+0x18b>
            return r;
		if ((r = sys_env_set_status(cenvid, ENV_RUNNABLE)) < 0)
  801a24:	83 ec 08             	sub    $0x8,%esp
  801a27:	6a 02                	push   $0x2
  801a29:	57                   	push   %edi
  801a2a:	e8 7f fc ff ff       	call   8016ae <sys_env_set_status>
  801a2f:	83 c4 10             	add    $0x10,%esp
            return r;
        return cenvid;
  801a32:	85 c0                	test   %eax,%eax
  801a34:	0f 49 c7             	cmovns %edi,%eax
  801a37:	eb 1c                	jmp    801a55 <fork+0x18b>
	}
	else {
		thisenv = &envs[ENVX(sys_getenvid())];
  801a39:	e8 6b fb ff ff       	call   8015a9 <sys_getenvid>
  801a3e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a43:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a46:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a4b:	a3 24 54 80 00       	mov    %eax,0x805424
		return 0;
  801a50:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//panic("fork not implemented");
	
}
  801a55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a58:	5b                   	pop    %ebx
  801a59:	5e                   	pop    %esi
  801a5a:	5f                   	pop    %edi
  801a5b:	5d                   	pop    %ebp
  801a5c:	c3                   	ret    

00801a5d <sfork>:

// Challenge!
int
sfork(void)
{
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801a63:	68 ca 38 80 00       	push   $0x8038ca
  801a68:	68 8d 00 00 00       	push   $0x8d
  801a6d:	68 72 38 80 00       	push   $0x803872
  801a72:	e8 9d ef ff ff       	call   800a14 <_panic>

00801a77 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801a77:	55                   	push   %ebp
  801a78:	89 e5                	mov    %esp,%ebp
  801a7a:	8b 55 08             	mov    0x8(%ebp),%edx
  801a7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a80:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801a83:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801a85:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801a88:	83 3a 01             	cmpl   $0x1,(%edx)
  801a8b:	7e 09                	jle    801a96 <argstart+0x1f>
  801a8d:	ba e1 32 80 00       	mov    $0x8032e1,%edx
  801a92:	85 c9                	test   %ecx,%ecx
  801a94:	75 05                	jne    801a9b <argstart+0x24>
  801a96:	ba 00 00 00 00       	mov    $0x0,%edx
  801a9b:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801a9e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801aa5:	5d                   	pop    %ebp
  801aa6:	c3                   	ret    

00801aa7 <argnext>:

int
argnext(struct Argstate *args)
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	53                   	push   %ebx
  801aab:	83 ec 04             	sub    $0x4,%esp
  801aae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801ab1:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801ab8:	8b 43 08             	mov    0x8(%ebx),%eax
  801abb:	85 c0                	test   %eax,%eax
  801abd:	74 6f                	je     801b2e <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801abf:	80 38 00             	cmpb   $0x0,(%eax)
  801ac2:	75 4e                	jne    801b12 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801ac4:	8b 0b                	mov    (%ebx),%ecx
  801ac6:	83 39 01             	cmpl   $0x1,(%ecx)
  801ac9:	74 55                	je     801b20 <argnext+0x79>
		    || args->argv[1][0] != '-'
  801acb:	8b 53 04             	mov    0x4(%ebx),%edx
  801ace:	8b 42 04             	mov    0x4(%edx),%eax
  801ad1:	80 38 2d             	cmpb   $0x2d,(%eax)
  801ad4:	75 4a                	jne    801b20 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801ad6:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801ada:	74 44                	je     801b20 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801adc:	83 c0 01             	add    $0x1,%eax
  801adf:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801ae2:	83 ec 04             	sub    $0x4,%esp
  801ae5:	8b 01                	mov    (%ecx),%eax
  801ae7:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801aee:	50                   	push   %eax
  801aef:	8d 42 08             	lea    0x8(%edx),%eax
  801af2:	50                   	push   %eax
  801af3:	83 c2 04             	add    $0x4,%edx
  801af6:	52                   	push   %edx
  801af7:	e8 7a f8 ff ff       	call   801376 <memmove>
		(*args->argc)--;
  801afc:	8b 03                	mov    (%ebx),%eax
  801afe:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801b01:	8b 43 08             	mov    0x8(%ebx),%eax
  801b04:	83 c4 10             	add    $0x10,%esp
  801b07:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b0a:	75 06                	jne    801b12 <argnext+0x6b>
  801b0c:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b10:	74 0e                	je     801b20 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801b12:	8b 53 08             	mov    0x8(%ebx),%edx
  801b15:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801b18:	83 c2 01             	add    $0x1,%edx
  801b1b:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801b1e:	eb 13                	jmp    801b33 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801b20:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801b27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b2c:	eb 05                	jmp    801b33 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801b2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801b33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b36:	c9                   	leave  
  801b37:	c3                   	ret    

00801b38 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	53                   	push   %ebx
  801b3c:	83 ec 04             	sub    $0x4,%esp
  801b3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801b42:	8b 43 08             	mov    0x8(%ebx),%eax
  801b45:	85 c0                	test   %eax,%eax
  801b47:	74 58                	je     801ba1 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801b49:	80 38 00             	cmpb   $0x0,(%eax)
  801b4c:	74 0c                	je     801b5a <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801b4e:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801b51:	c7 43 08 e1 32 80 00 	movl   $0x8032e1,0x8(%ebx)
  801b58:	eb 42                	jmp    801b9c <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801b5a:	8b 13                	mov    (%ebx),%edx
  801b5c:	83 3a 01             	cmpl   $0x1,(%edx)
  801b5f:	7e 2d                	jle    801b8e <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801b61:	8b 43 04             	mov    0x4(%ebx),%eax
  801b64:	8b 48 04             	mov    0x4(%eax),%ecx
  801b67:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b6a:	83 ec 04             	sub    $0x4,%esp
  801b6d:	8b 12                	mov    (%edx),%edx
  801b6f:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801b76:	52                   	push   %edx
  801b77:	8d 50 08             	lea    0x8(%eax),%edx
  801b7a:	52                   	push   %edx
  801b7b:	83 c0 04             	add    $0x4,%eax
  801b7e:	50                   	push   %eax
  801b7f:	e8 f2 f7 ff ff       	call   801376 <memmove>
		(*args->argc)--;
  801b84:	8b 03                	mov    (%ebx),%eax
  801b86:	83 28 01             	subl   $0x1,(%eax)
  801b89:	83 c4 10             	add    $0x10,%esp
  801b8c:	eb 0e                	jmp    801b9c <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801b8e:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801b95:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801b9c:	8b 43 0c             	mov    0xc(%ebx),%eax
  801b9f:	eb 05                	jmp    801ba6 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801ba1:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801ba6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba9:	c9                   	leave  
  801baa:	c3                   	ret    

00801bab <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	83 ec 08             	sub    $0x8,%esp
  801bb1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801bb4:	8b 51 0c             	mov    0xc(%ecx),%edx
  801bb7:	89 d0                	mov    %edx,%eax
  801bb9:	85 d2                	test   %edx,%edx
  801bbb:	75 0c                	jne    801bc9 <argvalue+0x1e>
  801bbd:	83 ec 0c             	sub    $0xc,%esp
  801bc0:	51                   	push   %ecx
  801bc1:	e8 72 ff ff ff       	call   801b38 <argnextvalue>
  801bc6:	83 c4 10             	add    $0x10,%esp
}
  801bc9:	c9                   	leave  
  801bca:	c3                   	ret    

00801bcb <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801bcb:	55                   	push   %ebp
  801bcc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801bce:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd1:	05 00 00 00 30       	add    $0x30000000,%eax
  801bd6:	c1 e8 0c             	shr    $0xc,%eax
}
  801bd9:	5d                   	pop    %ebp
  801bda:	c3                   	ret    

00801bdb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801bde:	8b 45 08             	mov    0x8(%ebp),%eax
  801be1:	05 00 00 00 30       	add    $0x30000000,%eax
  801be6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801beb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801bf0:	5d                   	pop    %ebp
  801bf1:	c3                   	ret    

00801bf2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801bfd:	89 c2                	mov    %eax,%edx
  801bff:	c1 ea 16             	shr    $0x16,%edx
  801c02:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c09:	f6 c2 01             	test   $0x1,%dl
  801c0c:	74 11                	je     801c1f <fd_alloc+0x2d>
  801c0e:	89 c2                	mov    %eax,%edx
  801c10:	c1 ea 0c             	shr    $0xc,%edx
  801c13:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c1a:	f6 c2 01             	test   $0x1,%dl
  801c1d:	75 09                	jne    801c28 <fd_alloc+0x36>
			*fd_store = fd;
  801c1f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801c21:	b8 00 00 00 00       	mov    $0x0,%eax
  801c26:	eb 17                	jmp    801c3f <fd_alloc+0x4d>
  801c28:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801c2d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801c32:	75 c9                	jne    801bfd <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801c34:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801c3a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801c3f:	5d                   	pop    %ebp
  801c40:	c3                   	ret    

00801c41 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801c41:	55                   	push   %ebp
  801c42:	89 e5                	mov    %esp,%ebp
  801c44:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801c47:	83 f8 1f             	cmp    $0x1f,%eax
  801c4a:	77 36                	ja     801c82 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801c4c:	c1 e0 0c             	shl    $0xc,%eax
  801c4f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801c54:	89 c2                	mov    %eax,%edx
  801c56:	c1 ea 16             	shr    $0x16,%edx
  801c59:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c60:	f6 c2 01             	test   $0x1,%dl
  801c63:	74 24                	je     801c89 <fd_lookup+0x48>
  801c65:	89 c2                	mov    %eax,%edx
  801c67:	c1 ea 0c             	shr    $0xc,%edx
  801c6a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c71:	f6 c2 01             	test   $0x1,%dl
  801c74:	74 1a                	je     801c90 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801c76:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c79:	89 02                	mov    %eax,(%edx)
	return 0;
  801c7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c80:	eb 13                	jmp    801c95 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c82:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c87:	eb 0c                	jmp    801c95 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c89:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c8e:	eb 05                	jmp    801c95 <fd_lookup+0x54>
  801c90:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801c95:	5d                   	pop    %ebp
  801c96:	c3                   	ret    

00801c97 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	83 ec 08             	sub    $0x8,%esp
  801c9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca0:	ba 5c 39 80 00       	mov    $0x80395c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801ca5:	eb 13                	jmp    801cba <dev_lookup+0x23>
  801ca7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801caa:	39 08                	cmp    %ecx,(%eax)
  801cac:	75 0c                	jne    801cba <dev_lookup+0x23>
			*dev = devtab[i];
  801cae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cb1:	89 01                	mov    %eax,(%ecx)
			return 0;
  801cb3:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb8:	eb 2e                	jmp    801ce8 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801cba:	8b 02                	mov    (%edx),%eax
  801cbc:	85 c0                	test   %eax,%eax
  801cbe:	75 e7                	jne    801ca7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801cc0:	a1 24 54 80 00       	mov    0x805424,%eax
  801cc5:	8b 40 48             	mov    0x48(%eax),%eax
  801cc8:	83 ec 04             	sub    $0x4,%esp
  801ccb:	51                   	push   %ecx
  801ccc:	50                   	push   %eax
  801ccd:	68 e0 38 80 00       	push   $0x8038e0
  801cd2:	e8 16 ee ff ff       	call   800aed <cprintf>
	*dev = 0;
  801cd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cda:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801ce0:	83 c4 10             	add    $0x10,%esp
  801ce3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801ce8:	c9                   	leave  
  801ce9:	c3                   	ret    

00801cea <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801cea:	55                   	push   %ebp
  801ceb:	89 e5                	mov    %esp,%ebp
  801ced:	56                   	push   %esi
  801cee:	53                   	push   %ebx
  801cef:	83 ec 10             	sub    $0x10,%esp
  801cf2:	8b 75 08             	mov    0x8(%ebp),%esi
  801cf5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801cf8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cfb:	50                   	push   %eax
  801cfc:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801d02:	c1 e8 0c             	shr    $0xc,%eax
  801d05:	50                   	push   %eax
  801d06:	e8 36 ff ff ff       	call   801c41 <fd_lookup>
  801d0b:	83 c4 08             	add    $0x8,%esp
  801d0e:	85 c0                	test   %eax,%eax
  801d10:	78 05                	js     801d17 <fd_close+0x2d>
	    || fd != fd2)
  801d12:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801d15:	74 0c                	je     801d23 <fd_close+0x39>
		return (must_exist ? r : 0);
  801d17:	84 db                	test   %bl,%bl
  801d19:	ba 00 00 00 00       	mov    $0x0,%edx
  801d1e:	0f 44 c2             	cmove  %edx,%eax
  801d21:	eb 41                	jmp    801d64 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d23:	83 ec 08             	sub    $0x8,%esp
  801d26:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d29:	50                   	push   %eax
  801d2a:	ff 36                	pushl  (%esi)
  801d2c:	e8 66 ff ff ff       	call   801c97 <dev_lookup>
  801d31:	89 c3                	mov    %eax,%ebx
  801d33:	83 c4 10             	add    $0x10,%esp
  801d36:	85 c0                	test   %eax,%eax
  801d38:	78 1a                	js     801d54 <fd_close+0x6a>
		if (dev->dev_close)
  801d3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d3d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801d40:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801d45:	85 c0                	test   %eax,%eax
  801d47:	74 0b                	je     801d54 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801d49:	83 ec 0c             	sub    $0xc,%esp
  801d4c:	56                   	push   %esi
  801d4d:	ff d0                	call   *%eax
  801d4f:	89 c3                	mov    %eax,%ebx
  801d51:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801d54:	83 ec 08             	sub    $0x8,%esp
  801d57:	56                   	push   %esi
  801d58:	6a 00                	push   $0x0
  801d5a:	e8 0d f9 ff ff       	call   80166c <sys_page_unmap>
	return r;
  801d5f:	83 c4 10             	add    $0x10,%esp
  801d62:	89 d8                	mov    %ebx,%eax
}
  801d64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d67:	5b                   	pop    %ebx
  801d68:	5e                   	pop    %esi
  801d69:	5d                   	pop    %ebp
  801d6a:	c3                   	ret    

00801d6b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d74:	50                   	push   %eax
  801d75:	ff 75 08             	pushl  0x8(%ebp)
  801d78:	e8 c4 fe ff ff       	call   801c41 <fd_lookup>
  801d7d:	83 c4 08             	add    $0x8,%esp
  801d80:	85 c0                	test   %eax,%eax
  801d82:	78 10                	js     801d94 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801d84:	83 ec 08             	sub    $0x8,%esp
  801d87:	6a 01                	push   $0x1
  801d89:	ff 75 f4             	pushl  -0xc(%ebp)
  801d8c:	e8 59 ff ff ff       	call   801cea <fd_close>
  801d91:	83 c4 10             	add    $0x10,%esp
}
  801d94:	c9                   	leave  
  801d95:	c3                   	ret    

00801d96 <close_all>:

void
close_all(void)
{
  801d96:	55                   	push   %ebp
  801d97:	89 e5                	mov    %esp,%ebp
  801d99:	53                   	push   %ebx
  801d9a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801d9d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801da2:	83 ec 0c             	sub    $0xc,%esp
  801da5:	53                   	push   %ebx
  801da6:	e8 c0 ff ff ff       	call   801d6b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801dab:	83 c3 01             	add    $0x1,%ebx
  801dae:	83 c4 10             	add    $0x10,%esp
  801db1:	83 fb 20             	cmp    $0x20,%ebx
  801db4:	75 ec                	jne    801da2 <close_all+0xc>
		close(i);
}
  801db6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801db9:	c9                   	leave  
  801dba:	c3                   	ret    

00801dbb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	57                   	push   %edi
  801dbf:	56                   	push   %esi
  801dc0:	53                   	push   %ebx
  801dc1:	83 ec 2c             	sub    $0x2c,%esp
  801dc4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801dc7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801dca:	50                   	push   %eax
  801dcb:	ff 75 08             	pushl  0x8(%ebp)
  801dce:	e8 6e fe ff ff       	call   801c41 <fd_lookup>
  801dd3:	83 c4 08             	add    $0x8,%esp
  801dd6:	85 c0                	test   %eax,%eax
  801dd8:	0f 88 c1 00 00 00    	js     801e9f <dup+0xe4>
		return r;
	close(newfdnum);
  801dde:	83 ec 0c             	sub    $0xc,%esp
  801de1:	56                   	push   %esi
  801de2:	e8 84 ff ff ff       	call   801d6b <close>

	newfd = INDEX2FD(newfdnum);
  801de7:	89 f3                	mov    %esi,%ebx
  801de9:	c1 e3 0c             	shl    $0xc,%ebx
  801dec:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801df2:	83 c4 04             	add    $0x4,%esp
  801df5:	ff 75 e4             	pushl  -0x1c(%ebp)
  801df8:	e8 de fd ff ff       	call   801bdb <fd2data>
  801dfd:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801dff:	89 1c 24             	mov    %ebx,(%esp)
  801e02:	e8 d4 fd ff ff       	call   801bdb <fd2data>
  801e07:	83 c4 10             	add    $0x10,%esp
  801e0a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801e0d:	89 f8                	mov    %edi,%eax
  801e0f:	c1 e8 16             	shr    $0x16,%eax
  801e12:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e19:	a8 01                	test   $0x1,%al
  801e1b:	74 37                	je     801e54 <dup+0x99>
  801e1d:	89 f8                	mov    %edi,%eax
  801e1f:	c1 e8 0c             	shr    $0xc,%eax
  801e22:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e29:	f6 c2 01             	test   $0x1,%dl
  801e2c:	74 26                	je     801e54 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801e2e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e35:	83 ec 0c             	sub    $0xc,%esp
  801e38:	25 07 0e 00 00       	and    $0xe07,%eax
  801e3d:	50                   	push   %eax
  801e3e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e41:	6a 00                	push   $0x0
  801e43:	57                   	push   %edi
  801e44:	6a 00                	push   $0x0
  801e46:	e8 df f7 ff ff       	call   80162a <sys_page_map>
  801e4b:	89 c7                	mov    %eax,%edi
  801e4d:	83 c4 20             	add    $0x20,%esp
  801e50:	85 c0                	test   %eax,%eax
  801e52:	78 2e                	js     801e82 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e54:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801e57:	89 d0                	mov    %edx,%eax
  801e59:	c1 e8 0c             	shr    $0xc,%eax
  801e5c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e63:	83 ec 0c             	sub    $0xc,%esp
  801e66:	25 07 0e 00 00       	and    $0xe07,%eax
  801e6b:	50                   	push   %eax
  801e6c:	53                   	push   %ebx
  801e6d:	6a 00                	push   $0x0
  801e6f:	52                   	push   %edx
  801e70:	6a 00                	push   $0x0
  801e72:	e8 b3 f7 ff ff       	call   80162a <sys_page_map>
  801e77:	89 c7                	mov    %eax,%edi
  801e79:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801e7c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e7e:	85 ff                	test   %edi,%edi
  801e80:	79 1d                	jns    801e9f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801e82:	83 ec 08             	sub    $0x8,%esp
  801e85:	53                   	push   %ebx
  801e86:	6a 00                	push   $0x0
  801e88:	e8 df f7 ff ff       	call   80166c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801e8d:	83 c4 08             	add    $0x8,%esp
  801e90:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e93:	6a 00                	push   $0x0
  801e95:	e8 d2 f7 ff ff       	call   80166c <sys_page_unmap>
	return r;
  801e9a:	83 c4 10             	add    $0x10,%esp
  801e9d:	89 f8                	mov    %edi,%eax
}
  801e9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ea2:	5b                   	pop    %ebx
  801ea3:	5e                   	pop    %esi
  801ea4:	5f                   	pop    %edi
  801ea5:	5d                   	pop    %ebp
  801ea6:	c3                   	ret    

00801ea7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	53                   	push   %ebx
  801eab:	83 ec 14             	sub    $0x14,%esp
  801eae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801eb1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801eb4:	50                   	push   %eax
  801eb5:	53                   	push   %ebx
  801eb6:	e8 86 fd ff ff       	call   801c41 <fd_lookup>
  801ebb:	83 c4 08             	add    $0x8,%esp
  801ebe:	89 c2                	mov    %eax,%edx
  801ec0:	85 c0                	test   %eax,%eax
  801ec2:	78 6d                	js     801f31 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ec4:	83 ec 08             	sub    $0x8,%esp
  801ec7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eca:	50                   	push   %eax
  801ecb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ece:	ff 30                	pushl  (%eax)
  801ed0:	e8 c2 fd ff ff       	call   801c97 <dev_lookup>
  801ed5:	83 c4 10             	add    $0x10,%esp
  801ed8:	85 c0                	test   %eax,%eax
  801eda:	78 4c                	js     801f28 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801edc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801edf:	8b 42 08             	mov    0x8(%edx),%eax
  801ee2:	83 e0 03             	and    $0x3,%eax
  801ee5:	83 f8 01             	cmp    $0x1,%eax
  801ee8:	75 21                	jne    801f0b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801eea:	a1 24 54 80 00       	mov    0x805424,%eax
  801eef:	8b 40 48             	mov    0x48(%eax),%eax
  801ef2:	83 ec 04             	sub    $0x4,%esp
  801ef5:	53                   	push   %ebx
  801ef6:	50                   	push   %eax
  801ef7:	68 21 39 80 00       	push   $0x803921
  801efc:	e8 ec eb ff ff       	call   800aed <cprintf>
		return -E_INVAL;
  801f01:	83 c4 10             	add    $0x10,%esp
  801f04:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801f09:	eb 26                	jmp    801f31 <read+0x8a>
	}
	if (!dev->dev_read)
  801f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0e:	8b 40 08             	mov    0x8(%eax),%eax
  801f11:	85 c0                	test   %eax,%eax
  801f13:	74 17                	je     801f2c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801f15:	83 ec 04             	sub    $0x4,%esp
  801f18:	ff 75 10             	pushl  0x10(%ebp)
  801f1b:	ff 75 0c             	pushl  0xc(%ebp)
  801f1e:	52                   	push   %edx
  801f1f:	ff d0                	call   *%eax
  801f21:	89 c2                	mov    %eax,%edx
  801f23:	83 c4 10             	add    $0x10,%esp
  801f26:	eb 09                	jmp    801f31 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f28:	89 c2                	mov    %eax,%edx
  801f2a:	eb 05                	jmp    801f31 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801f2c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801f31:	89 d0                	mov    %edx,%eax
  801f33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f36:	c9                   	leave  
  801f37:	c3                   	ret    

00801f38 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	57                   	push   %edi
  801f3c:	56                   	push   %esi
  801f3d:	53                   	push   %ebx
  801f3e:	83 ec 0c             	sub    $0xc,%esp
  801f41:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f44:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f47:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f4c:	eb 21                	jmp    801f6f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801f4e:	83 ec 04             	sub    $0x4,%esp
  801f51:	89 f0                	mov    %esi,%eax
  801f53:	29 d8                	sub    %ebx,%eax
  801f55:	50                   	push   %eax
  801f56:	89 d8                	mov    %ebx,%eax
  801f58:	03 45 0c             	add    0xc(%ebp),%eax
  801f5b:	50                   	push   %eax
  801f5c:	57                   	push   %edi
  801f5d:	e8 45 ff ff ff       	call   801ea7 <read>
		if (m < 0)
  801f62:	83 c4 10             	add    $0x10,%esp
  801f65:	85 c0                	test   %eax,%eax
  801f67:	78 10                	js     801f79 <readn+0x41>
			return m;
		if (m == 0)
  801f69:	85 c0                	test   %eax,%eax
  801f6b:	74 0a                	je     801f77 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f6d:	01 c3                	add    %eax,%ebx
  801f6f:	39 f3                	cmp    %esi,%ebx
  801f71:	72 db                	jb     801f4e <readn+0x16>
  801f73:	89 d8                	mov    %ebx,%eax
  801f75:	eb 02                	jmp    801f79 <readn+0x41>
  801f77:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801f79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f7c:	5b                   	pop    %ebx
  801f7d:	5e                   	pop    %esi
  801f7e:	5f                   	pop    %edi
  801f7f:	5d                   	pop    %ebp
  801f80:	c3                   	ret    

00801f81 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801f81:	55                   	push   %ebp
  801f82:	89 e5                	mov    %esp,%ebp
  801f84:	53                   	push   %ebx
  801f85:	83 ec 14             	sub    $0x14,%esp
  801f88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f8b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f8e:	50                   	push   %eax
  801f8f:	53                   	push   %ebx
  801f90:	e8 ac fc ff ff       	call   801c41 <fd_lookup>
  801f95:	83 c4 08             	add    $0x8,%esp
  801f98:	89 c2                	mov    %eax,%edx
  801f9a:	85 c0                	test   %eax,%eax
  801f9c:	78 68                	js     802006 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f9e:	83 ec 08             	sub    $0x8,%esp
  801fa1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa4:	50                   	push   %eax
  801fa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fa8:	ff 30                	pushl  (%eax)
  801faa:	e8 e8 fc ff ff       	call   801c97 <dev_lookup>
  801faf:	83 c4 10             	add    $0x10,%esp
  801fb2:	85 c0                	test   %eax,%eax
  801fb4:	78 47                	js     801ffd <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801fb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fb9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801fbd:	75 21                	jne    801fe0 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801fbf:	a1 24 54 80 00       	mov    0x805424,%eax
  801fc4:	8b 40 48             	mov    0x48(%eax),%eax
  801fc7:	83 ec 04             	sub    $0x4,%esp
  801fca:	53                   	push   %ebx
  801fcb:	50                   	push   %eax
  801fcc:	68 3d 39 80 00       	push   $0x80393d
  801fd1:	e8 17 eb ff ff       	call   800aed <cprintf>
		return -E_INVAL;
  801fd6:	83 c4 10             	add    $0x10,%esp
  801fd9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801fde:	eb 26                	jmp    802006 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801fe0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fe3:	8b 52 0c             	mov    0xc(%edx),%edx
  801fe6:	85 d2                	test   %edx,%edx
  801fe8:	74 17                	je     802001 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801fea:	83 ec 04             	sub    $0x4,%esp
  801fed:	ff 75 10             	pushl  0x10(%ebp)
  801ff0:	ff 75 0c             	pushl  0xc(%ebp)
  801ff3:	50                   	push   %eax
  801ff4:	ff d2                	call   *%edx
  801ff6:	89 c2                	mov    %eax,%edx
  801ff8:	83 c4 10             	add    $0x10,%esp
  801ffb:	eb 09                	jmp    802006 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ffd:	89 c2                	mov    %eax,%edx
  801fff:	eb 05                	jmp    802006 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802001:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802006:	89 d0                	mov    %edx,%eax
  802008:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80200b:	c9                   	leave  
  80200c:	c3                   	ret    

0080200d <seek>:

int
seek(int fdnum, off_t offset)
{
  80200d:	55                   	push   %ebp
  80200e:	89 e5                	mov    %esp,%ebp
  802010:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802013:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802016:	50                   	push   %eax
  802017:	ff 75 08             	pushl  0x8(%ebp)
  80201a:	e8 22 fc ff ff       	call   801c41 <fd_lookup>
  80201f:	83 c4 08             	add    $0x8,%esp
  802022:	85 c0                	test   %eax,%eax
  802024:	78 0e                	js     802034 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802026:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802029:	8b 55 0c             	mov    0xc(%ebp),%edx
  80202c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80202f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802034:	c9                   	leave  
  802035:	c3                   	ret    

00802036 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802036:	55                   	push   %ebp
  802037:	89 e5                	mov    %esp,%ebp
  802039:	53                   	push   %ebx
  80203a:	83 ec 14             	sub    $0x14,%esp
  80203d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802040:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802043:	50                   	push   %eax
  802044:	53                   	push   %ebx
  802045:	e8 f7 fb ff ff       	call   801c41 <fd_lookup>
  80204a:	83 c4 08             	add    $0x8,%esp
  80204d:	89 c2                	mov    %eax,%edx
  80204f:	85 c0                	test   %eax,%eax
  802051:	78 65                	js     8020b8 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802053:	83 ec 08             	sub    $0x8,%esp
  802056:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802059:	50                   	push   %eax
  80205a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80205d:	ff 30                	pushl  (%eax)
  80205f:	e8 33 fc ff ff       	call   801c97 <dev_lookup>
  802064:	83 c4 10             	add    $0x10,%esp
  802067:	85 c0                	test   %eax,%eax
  802069:	78 44                	js     8020af <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80206b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80206e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802072:	75 21                	jne    802095 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802074:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802079:	8b 40 48             	mov    0x48(%eax),%eax
  80207c:	83 ec 04             	sub    $0x4,%esp
  80207f:	53                   	push   %ebx
  802080:	50                   	push   %eax
  802081:	68 00 39 80 00       	push   $0x803900
  802086:	e8 62 ea ff ff       	call   800aed <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80208b:	83 c4 10             	add    $0x10,%esp
  80208e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802093:	eb 23                	jmp    8020b8 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802095:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802098:	8b 52 18             	mov    0x18(%edx),%edx
  80209b:	85 d2                	test   %edx,%edx
  80209d:	74 14                	je     8020b3 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80209f:	83 ec 08             	sub    $0x8,%esp
  8020a2:	ff 75 0c             	pushl  0xc(%ebp)
  8020a5:	50                   	push   %eax
  8020a6:	ff d2                	call   *%edx
  8020a8:	89 c2                	mov    %eax,%edx
  8020aa:	83 c4 10             	add    $0x10,%esp
  8020ad:	eb 09                	jmp    8020b8 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020af:	89 c2                	mov    %eax,%edx
  8020b1:	eb 05                	jmp    8020b8 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8020b3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8020b8:	89 d0                	mov    %edx,%eax
  8020ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020bd:	c9                   	leave  
  8020be:	c3                   	ret    

008020bf <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8020bf:	55                   	push   %ebp
  8020c0:	89 e5                	mov    %esp,%ebp
  8020c2:	53                   	push   %ebx
  8020c3:	83 ec 14             	sub    $0x14,%esp
  8020c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8020c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020cc:	50                   	push   %eax
  8020cd:	ff 75 08             	pushl  0x8(%ebp)
  8020d0:	e8 6c fb ff ff       	call   801c41 <fd_lookup>
  8020d5:	83 c4 08             	add    $0x8,%esp
  8020d8:	89 c2                	mov    %eax,%edx
  8020da:	85 c0                	test   %eax,%eax
  8020dc:	78 58                	js     802136 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020de:	83 ec 08             	sub    $0x8,%esp
  8020e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020e4:	50                   	push   %eax
  8020e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020e8:	ff 30                	pushl  (%eax)
  8020ea:	e8 a8 fb ff ff       	call   801c97 <dev_lookup>
  8020ef:	83 c4 10             	add    $0x10,%esp
  8020f2:	85 c0                	test   %eax,%eax
  8020f4:	78 37                	js     80212d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8020f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8020fd:	74 32                	je     802131 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8020ff:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802102:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802109:	00 00 00 
	stat->st_isdir = 0;
  80210c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802113:	00 00 00 
	stat->st_dev = dev;
  802116:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80211c:	83 ec 08             	sub    $0x8,%esp
  80211f:	53                   	push   %ebx
  802120:	ff 75 f0             	pushl  -0x10(%ebp)
  802123:	ff 50 14             	call   *0x14(%eax)
  802126:	89 c2                	mov    %eax,%edx
  802128:	83 c4 10             	add    $0x10,%esp
  80212b:	eb 09                	jmp    802136 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80212d:	89 c2                	mov    %eax,%edx
  80212f:	eb 05                	jmp    802136 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802131:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802136:	89 d0                	mov    %edx,%eax
  802138:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80213b:	c9                   	leave  
  80213c:	c3                   	ret    

0080213d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80213d:	55                   	push   %ebp
  80213e:	89 e5                	mov    %esp,%ebp
  802140:	56                   	push   %esi
  802141:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802142:	83 ec 08             	sub    $0x8,%esp
  802145:	6a 00                	push   $0x0
  802147:	ff 75 08             	pushl  0x8(%ebp)
  80214a:	e8 e3 01 00 00       	call   802332 <open>
  80214f:	89 c3                	mov    %eax,%ebx
  802151:	83 c4 10             	add    $0x10,%esp
  802154:	85 c0                	test   %eax,%eax
  802156:	78 1b                	js     802173 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802158:	83 ec 08             	sub    $0x8,%esp
  80215b:	ff 75 0c             	pushl  0xc(%ebp)
  80215e:	50                   	push   %eax
  80215f:	e8 5b ff ff ff       	call   8020bf <fstat>
  802164:	89 c6                	mov    %eax,%esi
	close(fd);
  802166:	89 1c 24             	mov    %ebx,(%esp)
  802169:	e8 fd fb ff ff       	call   801d6b <close>
	return r;
  80216e:	83 c4 10             	add    $0x10,%esp
  802171:	89 f0                	mov    %esi,%eax
}
  802173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802176:	5b                   	pop    %ebx
  802177:	5e                   	pop    %esi
  802178:	5d                   	pop    %ebp
  802179:	c3                   	ret    

0080217a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80217a:	55                   	push   %ebp
  80217b:	89 e5                	mov    %esp,%ebp
  80217d:	56                   	push   %esi
  80217e:	53                   	push   %ebx
  80217f:	89 c6                	mov    %eax,%esi
  802181:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802183:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  80218a:	75 12                	jne    80219e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80218c:	83 ec 0c             	sub    $0xc,%esp
  80218f:	6a 01                	push   $0x1
  802191:	e8 1a 0e 00 00       	call   802fb0 <ipc_find_env>
  802196:	a3 20 54 80 00       	mov    %eax,0x805420
  80219b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80219e:	6a 07                	push   $0x7
  8021a0:	68 00 60 80 00       	push   $0x806000
  8021a5:	56                   	push   %esi
  8021a6:	ff 35 20 54 80 00    	pushl  0x805420
  8021ac:	e8 ab 0d 00 00       	call   802f5c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8021b1:	83 c4 0c             	add    $0xc,%esp
  8021b4:	6a 00                	push   $0x0
  8021b6:	53                   	push   %ebx
  8021b7:	6a 00                	push   $0x0
  8021b9:	e8 35 0d 00 00       	call   802ef3 <ipc_recv>
}
  8021be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021c1:	5b                   	pop    %ebx
  8021c2:	5e                   	pop    %esi
  8021c3:	5d                   	pop    %ebp
  8021c4:	c3                   	ret    

008021c5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8021c5:	55                   	push   %ebp
  8021c6:	89 e5                	mov    %esp,%ebp
  8021c8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8021cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8021d1:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8021d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021d9:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8021de:	ba 00 00 00 00       	mov    $0x0,%edx
  8021e3:	b8 02 00 00 00       	mov    $0x2,%eax
  8021e8:	e8 8d ff ff ff       	call   80217a <fsipc>
}
  8021ed:	c9                   	leave  
  8021ee:	c3                   	ret    

008021ef <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8021ef:	55                   	push   %ebp
  8021f0:	89 e5                	mov    %esp,%ebp
  8021f2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8021f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f8:	8b 40 0c             	mov    0xc(%eax),%eax
  8021fb:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802200:	ba 00 00 00 00       	mov    $0x0,%edx
  802205:	b8 06 00 00 00       	mov    $0x6,%eax
  80220a:	e8 6b ff ff ff       	call   80217a <fsipc>
}
  80220f:	c9                   	leave  
  802210:	c3                   	ret    

00802211 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802211:	55                   	push   %ebp
  802212:	89 e5                	mov    %esp,%ebp
  802214:	53                   	push   %ebx
  802215:	83 ec 04             	sub    $0x4,%esp
  802218:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80221b:	8b 45 08             	mov    0x8(%ebp),%eax
  80221e:	8b 40 0c             	mov    0xc(%eax),%eax
  802221:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802226:	ba 00 00 00 00       	mov    $0x0,%edx
  80222b:	b8 05 00 00 00       	mov    $0x5,%eax
  802230:	e8 45 ff ff ff       	call   80217a <fsipc>
  802235:	85 c0                	test   %eax,%eax
  802237:	78 2c                	js     802265 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802239:	83 ec 08             	sub    $0x8,%esp
  80223c:	68 00 60 80 00       	push   $0x806000
  802241:	53                   	push   %ebx
  802242:	e8 9d ef ff ff       	call   8011e4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802247:	a1 80 60 80 00       	mov    0x806080,%eax
  80224c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802252:	a1 84 60 80 00       	mov    0x806084,%eax
  802257:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80225d:	83 c4 10             	add    $0x10,%esp
  802260:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802265:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802268:	c9                   	leave  
  802269:	c3                   	ret    

0080226a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80226a:	55                   	push   %ebp
  80226b:	89 e5                	mov    %esp,%ebp
  80226d:	83 ec 0c             	sub    $0xc,%esp
  802270:	8b 45 10             	mov    0x10(%ebp),%eax
  802273:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802278:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80227d:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802280:	8b 55 08             	mov    0x8(%ebp),%edx
  802283:	8b 52 0c             	mov    0xc(%edx),%edx
  802286:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  80228c:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  802291:	50                   	push   %eax
  802292:	ff 75 0c             	pushl  0xc(%ebp)
  802295:	68 08 60 80 00       	push   $0x806008
  80229a:	e8 d7 f0 ff ff       	call   801376 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80229f:	ba 00 00 00 00       	mov    $0x0,%edx
  8022a4:	b8 04 00 00 00       	mov    $0x4,%eax
  8022a9:	e8 cc fe ff ff       	call   80217a <fsipc>
	//panic("devfile_write not implemented");
}
  8022ae:	c9                   	leave  
  8022af:	c3                   	ret    

008022b0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8022b0:	55                   	push   %ebp
  8022b1:	89 e5                	mov    %esp,%ebp
  8022b3:	56                   	push   %esi
  8022b4:	53                   	push   %ebx
  8022b5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8022b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8022be:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8022c3:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8022c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8022ce:	b8 03 00 00 00       	mov    $0x3,%eax
  8022d3:	e8 a2 fe ff ff       	call   80217a <fsipc>
  8022d8:	89 c3                	mov    %eax,%ebx
  8022da:	85 c0                	test   %eax,%eax
  8022dc:	78 4b                	js     802329 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8022de:	39 c6                	cmp    %eax,%esi
  8022e0:	73 16                	jae    8022f8 <devfile_read+0x48>
  8022e2:	68 6c 39 80 00       	push   $0x80396c
  8022e7:	68 fa 33 80 00       	push   $0x8033fa
  8022ec:	6a 7c                	push   $0x7c
  8022ee:	68 73 39 80 00       	push   $0x803973
  8022f3:	e8 1c e7 ff ff       	call   800a14 <_panic>
	assert(r <= PGSIZE);
  8022f8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8022fd:	7e 16                	jle    802315 <devfile_read+0x65>
  8022ff:	68 7e 39 80 00       	push   $0x80397e
  802304:	68 fa 33 80 00       	push   $0x8033fa
  802309:	6a 7d                	push   $0x7d
  80230b:	68 73 39 80 00       	push   $0x803973
  802310:	e8 ff e6 ff ff       	call   800a14 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802315:	83 ec 04             	sub    $0x4,%esp
  802318:	50                   	push   %eax
  802319:	68 00 60 80 00       	push   $0x806000
  80231e:	ff 75 0c             	pushl  0xc(%ebp)
  802321:	e8 50 f0 ff ff       	call   801376 <memmove>
	return r;
  802326:	83 c4 10             	add    $0x10,%esp
}
  802329:	89 d8                	mov    %ebx,%eax
  80232b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80232e:	5b                   	pop    %ebx
  80232f:	5e                   	pop    %esi
  802330:	5d                   	pop    %ebp
  802331:	c3                   	ret    

00802332 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802332:	55                   	push   %ebp
  802333:	89 e5                	mov    %esp,%ebp
  802335:	53                   	push   %ebx
  802336:	83 ec 20             	sub    $0x20,%esp
  802339:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80233c:	53                   	push   %ebx
  80233d:	e8 69 ee ff ff       	call   8011ab <strlen>
  802342:	83 c4 10             	add    $0x10,%esp
  802345:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80234a:	7f 67                	jg     8023b3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80234c:	83 ec 0c             	sub    $0xc,%esp
  80234f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802352:	50                   	push   %eax
  802353:	e8 9a f8 ff ff       	call   801bf2 <fd_alloc>
  802358:	83 c4 10             	add    $0x10,%esp
		return r;
  80235b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80235d:	85 c0                	test   %eax,%eax
  80235f:	78 57                	js     8023b8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802361:	83 ec 08             	sub    $0x8,%esp
  802364:	53                   	push   %ebx
  802365:	68 00 60 80 00       	push   $0x806000
  80236a:	e8 75 ee ff ff       	call   8011e4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80236f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802372:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802377:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80237a:	b8 01 00 00 00       	mov    $0x1,%eax
  80237f:	e8 f6 fd ff ff       	call   80217a <fsipc>
  802384:	89 c3                	mov    %eax,%ebx
  802386:	83 c4 10             	add    $0x10,%esp
  802389:	85 c0                	test   %eax,%eax
  80238b:	79 14                	jns    8023a1 <open+0x6f>
		fd_close(fd, 0);
  80238d:	83 ec 08             	sub    $0x8,%esp
  802390:	6a 00                	push   $0x0
  802392:	ff 75 f4             	pushl  -0xc(%ebp)
  802395:	e8 50 f9 ff ff       	call   801cea <fd_close>
		return r;
  80239a:	83 c4 10             	add    $0x10,%esp
  80239d:	89 da                	mov    %ebx,%edx
  80239f:	eb 17                	jmp    8023b8 <open+0x86>
	}

	return fd2num(fd);
  8023a1:	83 ec 0c             	sub    $0xc,%esp
  8023a4:	ff 75 f4             	pushl  -0xc(%ebp)
  8023a7:	e8 1f f8 ff ff       	call   801bcb <fd2num>
  8023ac:	89 c2                	mov    %eax,%edx
  8023ae:	83 c4 10             	add    $0x10,%esp
  8023b1:	eb 05                	jmp    8023b8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8023b3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8023b8:	89 d0                	mov    %edx,%eax
  8023ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023bd:	c9                   	leave  
  8023be:	c3                   	ret    

008023bf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8023bf:	55                   	push   %ebp
  8023c0:	89 e5                	mov    %esp,%ebp
  8023c2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8023c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8023ca:	b8 08 00 00 00       	mov    $0x8,%eax
  8023cf:	e8 a6 fd ff ff       	call   80217a <fsipc>
}
  8023d4:	c9                   	leave  
  8023d5:	c3                   	ret    

008023d6 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8023d6:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8023da:	7e 37                	jle    802413 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8023dc:	55                   	push   %ebp
  8023dd:	89 e5                	mov    %esp,%ebp
  8023df:	53                   	push   %ebx
  8023e0:	83 ec 08             	sub    $0x8,%esp
  8023e3:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8023e5:	ff 70 04             	pushl  0x4(%eax)
  8023e8:	8d 40 10             	lea    0x10(%eax),%eax
  8023eb:	50                   	push   %eax
  8023ec:	ff 33                	pushl  (%ebx)
  8023ee:	e8 8e fb ff ff       	call   801f81 <write>
		if (result > 0)
  8023f3:	83 c4 10             	add    $0x10,%esp
  8023f6:	85 c0                	test   %eax,%eax
  8023f8:	7e 03                	jle    8023fd <writebuf+0x27>
			b->result += result;
  8023fa:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8023fd:	3b 43 04             	cmp    0x4(%ebx),%eax
  802400:	74 0d                	je     80240f <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  802402:	85 c0                	test   %eax,%eax
  802404:	ba 00 00 00 00       	mov    $0x0,%edx
  802409:	0f 4f c2             	cmovg  %edx,%eax
  80240c:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80240f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802412:	c9                   	leave  
  802413:	f3 c3                	repz ret 

00802415 <putch>:

static void
putch(int ch, void *thunk)
{
  802415:	55                   	push   %ebp
  802416:	89 e5                	mov    %esp,%ebp
  802418:	53                   	push   %ebx
  802419:	83 ec 04             	sub    $0x4,%esp
  80241c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80241f:	8b 53 04             	mov    0x4(%ebx),%edx
  802422:	8d 42 01             	lea    0x1(%edx),%eax
  802425:	89 43 04             	mov    %eax,0x4(%ebx)
  802428:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80242b:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80242f:	3d 00 01 00 00       	cmp    $0x100,%eax
  802434:	75 0e                	jne    802444 <putch+0x2f>
		writebuf(b);
  802436:	89 d8                	mov    %ebx,%eax
  802438:	e8 99 ff ff ff       	call   8023d6 <writebuf>
		b->idx = 0;
  80243d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  802444:	83 c4 04             	add    $0x4,%esp
  802447:	5b                   	pop    %ebx
  802448:	5d                   	pop    %ebp
  802449:	c3                   	ret    

0080244a <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80244a:	55                   	push   %ebp
  80244b:	89 e5                	mov    %esp,%ebp
  80244d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  802453:	8b 45 08             	mov    0x8(%ebp),%eax
  802456:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80245c:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  802463:	00 00 00 
	b.result = 0;
  802466:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80246d:	00 00 00 
	b.error = 1;
  802470:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  802477:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80247a:	ff 75 10             	pushl  0x10(%ebp)
  80247d:	ff 75 0c             	pushl  0xc(%ebp)
  802480:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802486:	50                   	push   %eax
  802487:	68 15 24 80 00       	push   $0x802415
  80248c:	e8 59 e7 ff ff       	call   800bea <vprintfmt>
	if (b.idx > 0)
  802491:	83 c4 10             	add    $0x10,%esp
  802494:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80249b:	7e 0b                	jle    8024a8 <vfprintf+0x5e>
		writebuf(&b);
  80249d:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024a3:	e8 2e ff ff ff       	call   8023d6 <writebuf>

	return (b.result ? b.result : b.error);
  8024a8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8024ae:	85 c0                	test   %eax,%eax
  8024b0:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8024b7:	c9                   	leave  
  8024b8:	c3                   	ret    

008024b9 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8024b9:	55                   	push   %ebp
  8024ba:	89 e5                	mov    %esp,%ebp
  8024bc:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024bf:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8024c2:	50                   	push   %eax
  8024c3:	ff 75 0c             	pushl  0xc(%ebp)
  8024c6:	ff 75 08             	pushl  0x8(%ebp)
  8024c9:	e8 7c ff ff ff       	call   80244a <vfprintf>
	va_end(ap);

	return cnt;
}
  8024ce:	c9                   	leave  
  8024cf:	c3                   	ret    

008024d0 <printf>:

int
printf(const char *fmt, ...)
{
  8024d0:	55                   	push   %ebp
  8024d1:	89 e5                	mov    %esp,%ebp
  8024d3:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8024d9:	50                   	push   %eax
  8024da:	ff 75 08             	pushl  0x8(%ebp)
  8024dd:	6a 01                	push   $0x1
  8024df:	e8 66 ff ff ff       	call   80244a <vfprintf>
	va_end(ap);

	return cnt;
}
  8024e4:	c9                   	leave  
  8024e5:	c3                   	ret    

008024e6 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8024e6:	55                   	push   %ebp
  8024e7:	89 e5                	mov    %esp,%ebp
  8024e9:	57                   	push   %edi
  8024ea:	56                   	push   %esi
  8024eb:	53                   	push   %ebx
  8024ec:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8024f2:	6a 00                	push   $0x0
  8024f4:	ff 75 08             	pushl  0x8(%ebp)
  8024f7:	e8 36 fe ff ff       	call   802332 <open>
  8024fc:	89 c7                	mov    %eax,%edi
  8024fe:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802504:	83 c4 10             	add    $0x10,%esp
  802507:	85 c0                	test   %eax,%eax
  802509:	0f 88 82 04 00 00    	js     802991 <spawn+0x4ab>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80250f:	83 ec 04             	sub    $0x4,%esp
  802512:	68 00 02 00 00       	push   $0x200
  802517:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80251d:	50                   	push   %eax
  80251e:	57                   	push   %edi
  80251f:	e8 14 fa ff ff       	call   801f38 <readn>
  802524:	83 c4 10             	add    $0x10,%esp
  802527:	3d 00 02 00 00       	cmp    $0x200,%eax
  80252c:	75 0c                	jne    80253a <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80252e:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802535:	45 4c 46 
  802538:	74 33                	je     80256d <spawn+0x87>
		close(fd);
  80253a:	83 ec 0c             	sub    $0xc,%esp
  80253d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802543:	e8 23 f8 ff ff       	call   801d6b <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802548:	83 c4 0c             	add    $0xc,%esp
  80254b:	68 7f 45 4c 46       	push   $0x464c457f
  802550:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  802556:	68 8a 39 80 00       	push   $0x80398a
  80255b:	e8 8d e5 ff ff       	call   800aed <cprintf>
		return -E_NOT_EXEC;
  802560:	83 c4 10             	add    $0x10,%esp
  802563:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  802568:	e9 d7 04 00 00       	jmp    802a44 <spawn+0x55e>
  80256d:	b8 07 00 00 00       	mov    $0x7,%eax
  802572:	cd 30                	int    $0x30
  802574:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80257a:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802580:	85 c0                	test   %eax,%eax
  802582:	0f 88 14 04 00 00    	js     80299c <spawn+0x4b6>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  802588:	89 c6                	mov    %eax,%esi
  80258a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  802590:	6b f6 7c             	imul   $0x7c,%esi,%esi
  802593:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  802599:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80259f:	b9 11 00 00 00       	mov    $0x11,%ecx
  8025a4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8025a6:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8025ac:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025b2:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8025b7:	be 00 00 00 00       	mov    $0x0,%esi
  8025bc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025bf:	eb 13                	jmp    8025d4 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8025c1:	83 ec 0c             	sub    $0xc,%esp
  8025c4:	50                   	push   %eax
  8025c5:	e8 e1 eb ff ff       	call   8011ab <strlen>
  8025ca:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025ce:	83 c3 01             	add    $0x1,%ebx
  8025d1:	83 c4 10             	add    $0x10,%esp
  8025d4:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8025db:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8025de:	85 c0                	test   %eax,%eax
  8025e0:	75 df                	jne    8025c1 <spawn+0xdb>
  8025e2:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8025e8:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8025ee:	bf 00 10 40 00       	mov    $0x401000,%edi
  8025f3:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8025f5:	89 fa                	mov    %edi,%edx
  8025f7:	83 e2 fc             	and    $0xfffffffc,%edx
  8025fa:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  802601:	29 c2                	sub    %eax,%edx
  802603:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802609:	8d 42 f8             	lea    -0x8(%edx),%eax
  80260c:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802611:	0f 86 9b 03 00 00    	jbe    8029b2 <spawn+0x4cc>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802617:	83 ec 04             	sub    $0x4,%esp
  80261a:	6a 07                	push   $0x7
  80261c:	68 00 00 40 00       	push   $0x400000
  802621:	6a 00                	push   $0x0
  802623:	e8 bf ef ff ff       	call   8015e7 <sys_page_alloc>
  802628:	83 c4 10             	add    $0x10,%esp
  80262b:	85 c0                	test   %eax,%eax
  80262d:	0f 88 89 03 00 00    	js     8029bc <spawn+0x4d6>
  802633:	be 00 00 00 00       	mov    $0x0,%esi
  802638:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80263e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802641:	eb 30                	jmp    802673 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  802643:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802649:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  80264f:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  802652:	83 ec 08             	sub    $0x8,%esp
  802655:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802658:	57                   	push   %edi
  802659:	e8 86 eb ff ff       	call   8011e4 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80265e:	83 c4 04             	add    $0x4,%esp
  802661:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802664:	e8 42 eb ff ff       	call   8011ab <strlen>
  802669:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80266d:	83 c6 01             	add    $0x1,%esi
  802670:	83 c4 10             	add    $0x10,%esp
  802673:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  802679:	7f c8                	jg     802643 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80267b:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802681:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  802687:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80268e:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802694:	74 19                	je     8026af <spawn+0x1c9>
  802696:	68 14 3a 80 00       	push   $0x803a14
  80269b:	68 fa 33 80 00       	push   $0x8033fa
  8026a0:	68 f2 00 00 00       	push   $0xf2
  8026a5:	68 a4 39 80 00       	push   $0x8039a4
  8026aa:	e8 65 e3 ff ff       	call   800a14 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8026af:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  8026b5:	89 f8                	mov    %edi,%eax
  8026b7:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8026bc:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  8026bf:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8026c5:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8026c8:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  8026ce:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8026d4:	83 ec 0c             	sub    $0xc,%esp
  8026d7:	6a 07                	push   $0x7
  8026d9:	68 00 d0 bf ee       	push   $0xeebfd000
  8026de:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8026e4:	68 00 00 40 00       	push   $0x400000
  8026e9:	6a 00                	push   $0x0
  8026eb:	e8 3a ef ff ff       	call   80162a <sys_page_map>
  8026f0:	89 c3                	mov    %eax,%ebx
  8026f2:	83 c4 20             	add    $0x20,%esp
  8026f5:	85 c0                	test   %eax,%eax
  8026f7:	0f 88 35 03 00 00    	js     802a32 <spawn+0x54c>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8026fd:	83 ec 08             	sub    $0x8,%esp
  802700:	68 00 00 40 00       	push   $0x400000
  802705:	6a 00                	push   $0x0
  802707:	e8 60 ef ff ff       	call   80166c <sys_page_unmap>
  80270c:	89 c3                	mov    %eax,%ebx
  80270e:	83 c4 10             	add    $0x10,%esp
  802711:	85 c0                	test   %eax,%eax
  802713:	0f 88 19 03 00 00    	js     802a32 <spawn+0x54c>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802719:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  80271f:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  802726:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80272c:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  802733:	00 00 00 
  802736:	e9 88 01 00 00       	jmp    8028c3 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  80273b:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802741:	83 38 01             	cmpl   $0x1,(%eax)
  802744:	0f 85 6b 01 00 00    	jne    8028b5 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80274a:	89 c1                	mov    %eax,%ecx
  80274c:	8b 40 18             	mov    0x18(%eax),%eax
  80274f:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802755:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  802758:	83 f8 01             	cmp    $0x1,%eax
  80275b:	19 c0                	sbb    %eax,%eax
  80275d:	83 e0 fe             	and    $0xfffffffe,%eax
  802760:	83 c0 07             	add    $0x7,%eax
  802763:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802769:	89 c8                	mov    %ecx,%eax
  80276b:	8b 79 04             	mov    0x4(%ecx),%edi
  80276e:	89 f9                	mov    %edi,%ecx
  802770:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  802776:	8b 78 10             	mov    0x10(%eax),%edi
  802779:	8b 50 14             	mov    0x14(%eax),%edx
  80277c:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  802782:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802785:	89 f0                	mov    %esi,%eax
  802787:	25 ff 0f 00 00       	and    $0xfff,%eax
  80278c:	74 14                	je     8027a2 <spawn+0x2bc>
		va -= i;
  80278e:	29 c6                	sub    %eax,%esi
		memsz += i;
  802790:	01 c2                	add    %eax,%edx
  802792:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  802798:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  80279a:	29 c1                	sub    %eax,%ecx
  80279c:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8027a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027a7:	e9 f7 00 00 00       	jmp    8028a3 <spawn+0x3bd>
		if (i >= filesz) {
  8027ac:	39 fb                	cmp    %edi,%ebx
  8027ae:	72 27                	jb     8027d7 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8027b0:	83 ec 04             	sub    $0x4,%esp
  8027b3:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8027b9:	56                   	push   %esi
  8027ba:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8027c0:	e8 22 ee ff ff       	call   8015e7 <sys_page_alloc>
  8027c5:	83 c4 10             	add    $0x10,%esp
  8027c8:	85 c0                	test   %eax,%eax
  8027ca:	0f 89 c7 00 00 00    	jns    802897 <spawn+0x3b1>
  8027d0:	89 c3                	mov    %eax,%ebx
  8027d2:	e9 f6 01 00 00       	jmp    8029cd <spawn+0x4e7>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8027d7:	83 ec 04             	sub    $0x4,%esp
  8027da:	6a 07                	push   $0x7
  8027dc:	68 00 00 40 00       	push   $0x400000
  8027e1:	6a 00                	push   $0x0
  8027e3:	e8 ff ed ff ff       	call   8015e7 <sys_page_alloc>
  8027e8:	83 c4 10             	add    $0x10,%esp
  8027eb:	85 c0                	test   %eax,%eax
  8027ed:	0f 88 d0 01 00 00    	js     8029c3 <spawn+0x4dd>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8027f3:	83 ec 08             	sub    $0x8,%esp
  8027f6:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8027fc:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  802802:	50                   	push   %eax
  802803:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802809:	e8 ff f7 ff ff       	call   80200d <seek>
  80280e:	83 c4 10             	add    $0x10,%esp
  802811:	85 c0                	test   %eax,%eax
  802813:	0f 88 ae 01 00 00    	js     8029c7 <spawn+0x4e1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802819:	83 ec 04             	sub    $0x4,%esp
  80281c:	89 f8                	mov    %edi,%eax
  80281e:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  802824:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802829:	b9 00 10 00 00       	mov    $0x1000,%ecx
  80282e:	0f 47 c1             	cmova  %ecx,%eax
  802831:	50                   	push   %eax
  802832:	68 00 00 40 00       	push   $0x400000
  802837:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80283d:	e8 f6 f6 ff ff       	call   801f38 <readn>
  802842:	83 c4 10             	add    $0x10,%esp
  802845:	85 c0                	test   %eax,%eax
  802847:	0f 88 7e 01 00 00    	js     8029cb <spawn+0x4e5>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80284d:	83 ec 0c             	sub    $0xc,%esp
  802850:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802856:	56                   	push   %esi
  802857:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80285d:	68 00 00 40 00       	push   $0x400000
  802862:	6a 00                	push   $0x0
  802864:	e8 c1 ed ff ff       	call   80162a <sys_page_map>
  802869:	83 c4 20             	add    $0x20,%esp
  80286c:	85 c0                	test   %eax,%eax
  80286e:	79 15                	jns    802885 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  802870:	50                   	push   %eax
  802871:	68 b0 39 80 00       	push   $0x8039b0
  802876:	68 25 01 00 00       	push   $0x125
  80287b:	68 a4 39 80 00       	push   $0x8039a4
  802880:	e8 8f e1 ff ff       	call   800a14 <_panic>
			sys_page_unmap(0, UTEMP);
  802885:	83 ec 08             	sub    $0x8,%esp
  802888:	68 00 00 40 00       	push   $0x400000
  80288d:	6a 00                	push   $0x0
  80288f:	e8 d8 ed ff ff       	call   80166c <sys_page_unmap>
  802894:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802897:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80289d:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8028a3:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8028a9:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  8028af:	0f 82 f7 fe ff ff    	jb     8027ac <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8028b5:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8028bc:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8028c3:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8028ca:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8028d0:	0f 8c 65 fe ff ff    	jl     80273b <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8028d6:	83 ec 0c             	sub    $0xc,%esp
  8028d9:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8028df:	e8 87 f4 ff ff       	call   801d6b <close>
  8028e4:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r=0,pn=0;
	for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  8028e7:	bb 00 08 00 00       	mov    $0x800,%ebx
  8028ec:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
        if ((uvpd[pn >> 10] & PTE_P) &&uvpt[pn] & PTE_SHARE)
  8028f2:	89 d8                	mov    %ebx,%eax
  8028f4:	c1 f8 0a             	sar    $0xa,%eax
  8028f7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8028fe:	a8 01                	test   $0x1,%al
  802900:	74 3e                	je     802940 <spawn+0x45a>
  802902:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  802909:	f6 c4 04             	test   $0x4,%ah
  80290c:	74 32                	je     802940 <spawn+0x45a>
            if ( (r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), child, (void *)(pn*PGSIZE), uvpt[pn] & PTE_SYSCALL )) < 0)
  80290e:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  802915:	89 da                	mov    %ebx,%edx
  802917:	c1 e2 0c             	shl    $0xc,%edx
  80291a:	8b 0d 24 54 80 00    	mov    0x805424,%ecx
  802920:	8b 49 48             	mov    0x48(%ecx),%ecx
  802923:	83 ec 0c             	sub    $0xc,%esp
  802926:	25 07 0e 00 00       	and    $0xe07,%eax
  80292b:	50                   	push   %eax
  80292c:	52                   	push   %edx
  80292d:	56                   	push   %esi
  80292e:	52                   	push   %edx
  80292f:	51                   	push   %ecx
  802930:	e8 f5 ec ff ff       	call   80162a <sys_page_map>
  802935:	83 c4 20             	add    $0x20,%esp
  802938:	85 c0                	test   %eax,%eax
  80293a:	0f 88 dd 00 00 00    	js     802a1d <spawn+0x537>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r=0,pn=0;
	for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  802940:	83 c3 01             	add    $0x1,%ebx
  802943:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  802949:	75 a7                	jne    8028f2 <spawn+0x40c>
  80294b:	e9 9e 00 00 00       	jmp    8029ee <spawn+0x508>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  802950:	50                   	push   %eax
  802951:	68 cd 39 80 00       	push   $0x8039cd
  802956:	68 86 00 00 00       	push   $0x86
  80295b:	68 a4 39 80 00       	push   $0x8039a4
  802960:	e8 af e0 ff ff       	call   800a14 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802965:	83 ec 08             	sub    $0x8,%esp
  802968:	6a 02                	push   $0x2
  80296a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802970:	e8 39 ed ff ff       	call   8016ae <sys_env_set_status>
  802975:	83 c4 10             	add    $0x10,%esp
  802978:	85 c0                	test   %eax,%eax
  80297a:	79 2b                	jns    8029a7 <spawn+0x4c1>
		panic("sys_env_set_status: %e", r);
  80297c:	50                   	push   %eax
  80297d:	68 e7 39 80 00       	push   $0x8039e7
  802982:	68 89 00 00 00       	push   $0x89
  802987:	68 a4 39 80 00       	push   $0x8039a4
  80298c:	e8 83 e0 ff ff       	call   800a14 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802991:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  802997:	e9 a8 00 00 00       	jmp    802a44 <spawn+0x55e>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  80299c:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8029a2:	e9 9d 00 00 00       	jmp    802a44 <spawn+0x55e>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  8029a7:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8029ad:	e9 92 00 00 00       	jmp    802a44 <spawn+0x55e>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8029b2:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  8029b7:	e9 88 00 00 00       	jmp    802a44 <spawn+0x55e>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  8029bc:	89 c3                	mov    %eax,%ebx
  8029be:	e9 81 00 00 00       	jmp    802a44 <spawn+0x55e>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8029c3:	89 c3                	mov    %eax,%ebx
  8029c5:	eb 06                	jmp    8029cd <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8029c7:	89 c3                	mov    %eax,%ebx
  8029c9:	eb 02                	jmp    8029cd <spawn+0x4e7>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8029cb:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  8029cd:	83 ec 0c             	sub    $0xc,%esp
  8029d0:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029d6:	e8 8d eb ff ff       	call   801568 <sys_env_destroy>
	close(fd);
  8029db:	83 c4 04             	add    $0x4,%esp
  8029de:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8029e4:	e8 82 f3 ff ff       	call   801d6b <close>
	return r;
  8029e9:	83 c4 10             	add    $0x10,%esp
  8029ec:	eb 56                	jmp    802a44 <spawn+0x55e>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8029ee:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8029f5:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8029f8:	83 ec 08             	sub    $0x8,%esp
  8029fb:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802a01:	50                   	push   %eax
  802a02:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a08:	e8 e3 ec ff ff       	call   8016f0 <sys_env_set_trapframe>
  802a0d:	83 c4 10             	add    $0x10,%esp
  802a10:	85 c0                	test   %eax,%eax
  802a12:	0f 89 4d ff ff ff    	jns    802965 <spawn+0x47f>
  802a18:	e9 33 ff ff ff       	jmp    802950 <spawn+0x46a>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802a1d:	50                   	push   %eax
  802a1e:	68 fe 39 80 00       	push   $0x8039fe
  802a23:	68 82 00 00 00       	push   $0x82
  802a28:	68 a4 39 80 00       	push   $0x8039a4
  802a2d:	e8 e2 df ff ff       	call   800a14 <_panic>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802a32:	83 ec 08             	sub    $0x8,%esp
  802a35:	68 00 00 40 00       	push   $0x400000
  802a3a:	6a 00                	push   $0x0
  802a3c:	e8 2b ec ff ff       	call   80166c <sys_page_unmap>
  802a41:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802a44:	89 d8                	mov    %ebx,%eax
  802a46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a49:	5b                   	pop    %ebx
  802a4a:	5e                   	pop    %esi
  802a4b:	5f                   	pop    %edi
  802a4c:	5d                   	pop    %ebp
  802a4d:	c3                   	ret    

00802a4e <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802a4e:	55                   	push   %ebp
  802a4f:	89 e5                	mov    %esp,%ebp
  802a51:	56                   	push   %esi
  802a52:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a53:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802a56:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a5b:	eb 03                	jmp    802a60 <spawnl+0x12>
		argc++;
  802a5d:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a60:	83 c2 04             	add    $0x4,%edx
  802a63:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802a67:	75 f4                	jne    802a5d <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802a69:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802a70:	83 e2 f0             	and    $0xfffffff0,%edx
  802a73:	29 d4                	sub    %edx,%esp
  802a75:	8d 54 24 03          	lea    0x3(%esp),%edx
  802a79:	c1 ea 02             	shr    $0x2,%edx
  802a7c:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802a83:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802a85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a88:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802a8f:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802a96:	00 
  802a97:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802a99:	b8 00 00 00 00       	mov    $0x0,%eax
  802a9e:	eb 0a                	jmp    802aaa <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802aa0:	83 c0 01             	add    $0x1,%eax
  802aa3:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802aa7:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802aaa:	39 d0                	cmp    %edx,%eax
  802aac:	75 f2                	jne    802aa0 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802aae:	83 ec 08             	sub    $0x8,%esp
  802ab1:	56                   	push   %esi
  802ab2:	ff 75 08             	pushl  0x8(%ebp)
  802ab5:	e8 2c fa ff ff       	call   8024e6 <spawn>
}
  802aba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802abd:	5b                   	pop    %ebx
  802abe:	5e                   	pop    %esi
  802abf:	5d                   	pop    %ebp
  802ac0:	c3                   	ret    

00802ac1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802ac1:	55                   	push   %ebp
  802ac2:	89 e5                	mov    %esp,%ebp
  802ac4:	56                   	push   %esi
  802ac5:	53                   	push   %ebx
  802ac6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802ac9:	83 ec 0c             	sub    $0xc,%esp
  802acc:	ff 75 08             	pushl  0x8(%ebp)
  802acf:	e8 07 f1 ff ff       	call   801bdb <fd2data>
  802ad4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802ad6:	83 c4 08             	add    $0x8,%esp
  802ad9:	68 3c 3a 80 00       	push   $0x803a3c
  802ade:	53                   	push   %ebx
  802adf:	e8 00 e7 ff ff       	call   8011e4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802ae4:	8b 46 04             	mov    0x4(%esi),%eax
  802ae7:	2b 06                	sub    (%esi),%eax
  802ae9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802aef:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802af6:	00 00 00 
	stat->st_dev = &devpipe;
  802af9:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802b00:	40 80 00 
	return 0;
}
  802b03:	b8 00 00 00 00       	mov    $0x0,%eax
  802b08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b0b:	5b                   	pop    %ebx
  802b0c:	5e                   	pop    %esi
  802b0d:	5d                   	pop    %ebp
  802b0e:	c3                   	ret    

00802b0f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802b0f:	55                   	push   %ebp
  802b10:	89 e5                	mov    %esp,%ebp
  802b12:	53                   	push   %ebx
  802b13:	83 ec 0c             	sub    $0xc,%esp
  802b16:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802b19:	53                   	push   %ebx
  802b1a:	6a 00                	push   $0x0
  802b1c:	e8 4b eb ff ff       	call   80166c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802b21:	89 1c 24             	mov    %ebx,(%esp)
  802b24:	e8 b2 f0 ff ff       	call   801bdb <fd2data>
  802b29:	83 c4 08             	add    $0x8,%esp
  802b2c:	50                   	push   %eax
  802b2d:	6a 00                	push   $0x0
  802b2f:	e8 38 eb ff ff       	call   80166c <sys_page_unmap>
}
  802b34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b37:	c9                   	leave  
  802b38:	c3                   	ret    

00802b39 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802b39:	55                   	push   %ebp
  802b3a:	89 e5                	mov    %esp,%ebp
  802b3c:	57                   	push   %edi
  802b3d:	56                   	push   %esi
  802b3e:	53                   	push   %ebx
  802b3f:	83 ec 1c             	sub    $0x1c,%esp
  802b42:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802b45:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802b47:	a1 24 54 80 00       	mov    0x805424,%eax
  802b4c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802b4f:	83 ec 0c             	sub    $0xc,%esp
  802b52:	ff 75 e0             	pushl  -0x20(%ebp)
  802b55:	e8 8f 04 00 00       	call   802fe9 <pageref>
  802b5a:	89 c3                	mov    %eax,%ebx
  802b5c:	89 3c 24             	mov    %edi,(%esp)
  802b5f:	e8 85 04 00 00       	call   802fe9 <pageref>
  802b64:	83 c4 10             	add    $0x10,%esp
  802b67:	39 c3                	cmp    %eax,%ebx
  802b69:	0f 94 c1             	sete   %cl
  802b6c:	0f b6 c9             	movzbl %cl,%ecx
  802b6f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802b72:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802b78:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802b7b:	39 ce                	cmp    %ecx,%esi
  802b7d:	74 1b                	je     802b9a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802b7f:	39 c3                	cmp    %eax,%ebx
  802b81:	75 c4                	jne    802b47 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802b83:	8b 42 58             	mov    0x58(%edx),%eax
  802b86:	ff 75 e4             	pushl  -0x1c(%ebp)
  802b89:	50                   	push   %eax
  802b8a:	56                   	push   %esi
  802b8b:	68 43 3a 80 00       	push   $0x803a43
  802b90:	e8 58 df ff ff       	call   800aed <cprintf>
  802b95:	83 c4 10             	add    $0x10,%esp
  802b98:	eb ad                	jmp    802b47 <_pipeisclosed+0xe>
	}
}
  802b9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802b9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ba0:	5b                   	pop    %ebx
  802ba1:	5e                   	pop    %esi
  802ba2:	5f                   	pop    %edi
  802ba3:	5d                   	pop    %ebp
  802ba4:	c3                   	ret    

00802ba5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802ba5:	55                   	push   %ebp
  802ba6:	89 e5                	mov    %esp,%ebp
  802ba8:	57                   	push   %edi
  802ba9:	56                   	push   %esi
  802baa:	53                   	push   %ebx
  802bab:	83 ec 28             	sub    $0x28,%esp
  802bae:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802bb1:	56                   	push   %esi
  802bb2:	e8 24 f0 ff ff       	call   801bdb <fd2data>
  802bb7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802bb9:	83 c4 10             	add    $0x10,%esp
  802bbc:	bf 00 00 00 00       	mov    $0x0,%edi
  802bc1:	eb 4b                	jmp    802c0e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802bc3:	89 da                	mov    %ebx,%edx
  802bc5:	89 f0                	mov    %esi,%eax
  802bc7:	e8 6d ff ff ff       	call   802b39 <_pipeisclosed>
  802bcc:	85 c0                	test   %eax,%eax
  802bce:	75 48                	jne    802c18 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802bd0:	e8 f3 e9 ff ff       	call   8015c8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802bd5:	8b 43 04             	mov    0x4(%ebx),%eax
  802bd8:	8b 0b                	mov    (%ebx),%ecx
  802bda:	8d 51 20             	lea    0x20(%ecx),%edx
  802bdd:	39 d0                	cmp    %edx,%eax
  802bdf:	73 e2                	jae    802bc3 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802be1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802be4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802be8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802beb:	89 c2                	mov    %eax,%edx
  802bed:	c1 fa 1f             	sar    $0x1f,%edx
  802bf0:	89 d1                	mov    %edx,%ecx
  802bf2:	c1 e9 1b             	shr    $0x1b,%ecx
  802bf5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802bf8:	83 e2 1f             	and    $0x1f,%edx
  802bfb:	29 ca                	sub    %ecx,%edx
  802bfd:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802c01:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802c05:	83 c0 01             	add    $0x1,%eax
  802c08:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c0b:	83 c7 01             	add    $0x1,%edi
  802c0e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802c11:	75 c2                	jne    802bd5 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802c13:	8b 45 10             	mov    0x10(%ebp),%eax
  802c16:	eb 05                	jmp    802c1d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c18:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802c1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c20:	5b                   	pop    %ebx
  802c21:	5e                   	pop    %esi
  802c22:	5f                   	pop    %edi
  802c23:	5d                   	pop    %ebp
  802c24:	c3                   	ret    

00802c25 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802c25:	55                   	push   %ebp
  802c26:	89 e5                	mov    %esp,%ebp
  802c28:	57                   	push   %edi
  802c29:	56                   	push   %esi
  802c2a:	53                   	push   %ebx
  802c2b:	83 ec 18             	sub    $0x18,%esp
  802c2e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802c31:	57                   	push   %edi
  802c32:	e8 a4 ef ff ff       	call   801bdb <fd2data>
  802c37:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c39:	83 c4 10             	add    $0x10,%esp
  802c3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802c41:	eb 3d                	jmp    802c80 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802c43:	85 db                	test   %ebx,%ebx
  802c45:	74 04                	je     802c4b <devpipe_read+0x26>
				return i;
  802c47:	89 d8                	mov    %ebx,%eax
  802c49:	eb 44                	jmp    802c8f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802c4b:	89 f2                	mov    %esi,%edx
  802c4d:	89 f8                	mov    %edi,%eax
  802c4f:	e8 e5 fe ff ff       	call   802b39 <_pipeisclosed>
  802c54:	85 c0                	test   %eax,%eax
  802c56:	75 32                	jne    802c8a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802c58:	e8 6b e9 ff ff       	call   8015c8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802c5d:	8b 06                	mov    (%esi),%eax
  802c5f:	3b 46 04             	cmp    0x4(%esi),%eax
  802c62:	74 df                	je     802c43 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802c64:	99                   	cltd   
  802c65:	c1 ea 1b             	shr    $0x1b,%edx
  802c68:	01 d0                	add    %edx,%eax
  802c6a:	83 e0 1f             	and    $0x1f,%eax
  802c6d:	29 d0                	sub    %edx,%eax
  802c6f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c77:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802c7a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c7d:	83 c3 01             	add    $0x1,%ebx
  802c80:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802c83:	75 d8                	jne    802c5d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802c85:	8b 45 10             	mov    0x10(%ebp),%eax
  802c88:	eb 05                	jmp    802c8f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c8a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c92:	5b                   	pop    %ebx
  802c93:	5e                   	pop    %esi
  802c94:	5f                   	pop    %edi
  802c95:	5d                   	pop    %ebp
  802c96:	c3                   	ret    

00802c97 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802c97:	55                   	push   %ebp
  802c98:	89 e5                	mov    %esp,%ebp
  802c9a:	56                   	push   %esi
  802c9b:	53                   	push   %ebx
  802c9c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802c9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ca2:	50                   	push   %eax
  802ca3:	e8 4a ef ff ff       	call   801bf2 <fd_alloc>
  802ca8:	83 c4 10             	add    $0x10,%esp
  802cab:	89 c2                	mov    %eax,%edx
  802cad:	85 c0                	test   %eax,%eax
  802caf:	0f 88 2c 01 00 00    	js     802de1 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802cb5:	83 ec 04             	sub    $0x4,%esp
  802cb8:	68 07 04 00 00       	push   $0x407
  802cbd:	ff 75 f4             	pushl  -0xc(%ebp)
  802cc0:	6a 00                	push   $0x0
  802cc2:	e8 20 e9 ff ff       	call   8015e7 <sys_page_alloc>
  802cc7:	83 c4 10             	add    $0x10,%esp
  802cca:	89 c2                	mov    %eax,%edx
  802ccc:	85 c0                	test   %eax,%eax
  802cce:	0f 88 0d 01 00 00    	js     802de1 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802cd4:	83 ec 0c             	sub    $0xc,%esp
  802cd7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802cda:	50                   	push   %eax
  802cdb:	e8 12 ef ff ff       	call   801bf2 <fd_alloc>
  802ce0:	89 c3                	mov    %eax,%ebx
  802ce2:	83 c4 10             	add    $0x10,%esp
  802ce5:	85 c0                	test   %eax,%eax
  802ce7:	0f 88 e2 00 00 00    	js     802dcf <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802ced:	83 ec 04             	sub    $0x4,%esp
  802cf0:	68 07 04 00 00       	push   $0x407
  802cf5:	ff 75 f0             	pushl  -0x10(%ebp)
  802cf8:	6a 00                	push   $0x0
  802cfa:	e8 e8 e8 ff ff       	call   8015e7 <sys_page_alloc>
  802cff:	89 c3                	mov    %eax,%ebx
  802d01:	83 c4 10             	add    $0x10,%esp
  802d04:	85 c0                	test   %eax,%eax
  802d06:	0f 88 c3 00 00 00    	js     802dcf <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802d0c:	83 ec 0c             	sub    $0xc,%esp
  802d0f:	ff 75 f4             	pushl  -0xc(%ebp)
  802d12:	e8 c4 ee ff ff       	call   801bdb <fd2data>
  802d17:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d19:	83 c4 0c             	add    $0xc,%esp
  802d1c:	68 07 04 00 00       	push   $0x407
  802d21:	50                   	push   %eax
  802d22:	6a 00                	push   $0x0
  802d24:	e8 be e8 ff ff       	call   8015e7 <sys_page_alloc>
  802d29:	89 c3                	mov    %eax,%ebx
  802d2b:	83 c4 10             	add    $0x10,%esp
  802d2e:	85 c0                	test   %eax,%eax
  802d30:	0f 88 89 00 00 00    	js     802dbf <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d36:	83 ec 0c             	sub    $0xc,%esp
  802d39:	ff 75 f0             	pushl  -0x10(%ebp)
  802d3c:	e8 9a ee ff ff       	call   801bdb <fd2data>
  802d41:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802d48:	50                   	push   %eax
  802d49:	6a 00                	push   $0x0
  802d4b:	56                   	push   %esi
  802d4c:	6a 00                	push   $0x0
  802d4e:	e8 d7 e8 ff ff       	call   80162a <sys_page_map>
  802d53:	89 c3                	mov    %eax,%ebx
  802d55:	83 c4 20             	add    $0x20,%esp
  802d58:	85 c0                	test   %eax,%eax
  802d5a:	78 55                	js     802db1 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802d5c:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d65:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d6a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802d71:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802d77:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d7a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802d7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d7f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802d86:	83 ec 0c             	sub    $0xc,%esp
  802d89:	ff 75 f4             	pushl  -0xc(%ebp)
  802d8c:	e8 3a ee ff ff       	call   801bcb <fd2num>
  802d91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d94:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802d96:	83 c4 04             	add    $0x4,%esp
  802d99:	ff 75 f0             	pushl  -0x10(%ebp)
  802d9c:	e8 2a ee ff ff       	call   801bcb <fd2num>
  802da1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802da4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802da7:	83 c4 10             	add    $0x10,%esp
  802daa:	ba 00 00 00 00       	mov    $0x0,%edx
  802daf:	eb 30                	jmp    802de1 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802db1:	83 ec 08             	sub    $0x8,%esp
  802db4:	56                   	push   %esi
  802db5:	6a 00                	push   $0x0
  802db7:	e8 b0 e8 ff ff       	call   80166c <sys_page_unmap>
  802dbc:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802dbf:	83 ec 08             	sub    $0x8,%esp
  802dc2:	ff 75 f0             	pushl  -0x10(%ebp)
  802dc5:	6a 00                	push   $0x0
  802dc7:	e8 a0 e8 ff ff       	call   80166c <sys_page_unmap>
  802dcc:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802dcf:	83 ec 08             	sub    $0x8,%esp
  802dd2:	ff 75 f4             	pushl  -0xc(%ebp)
  802dd5:	6a 00                	push   $0x0
  802dd7:	e8 90 e8 ff ff       	call   80166c <sys_page_unmap>
  802ddc:	83 c4 10             	add    $0x10,%esp
  802ddf:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802de1:	89 d0                	mov    %edx,%eax
  802de3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802de6:	5b                   	pop    %ebx
  802de7:	5e                   	pop    %esi
  802de8:	5d                   	pop    %ebp
  802de9:	c3                   	ret    

00802dea <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802dea:	55                   	push   %ebp
  802deb:	89 e5                	mov    %esp,%ebp
  802ded:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802df0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802df3:	50                   	push   %eax
  802df4:	ff 75 08             	pushl  0x8(%ebp)
  802df7:	e8 45 ee ff ff       	call   801c41 <fd_lookup>
  802dfc:	83 c4 10             	add    $0x10,%esp
  802dff:	85 c0                	test   %eax,%eax
  802e01:	78 18                	js     802e1b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802e03:	83 ec 0c             	sub    $0xc,%esp
  802e06:	ff 75 f4             	pushl  -0xc(%ebp)
  802e09:	e8 cd ed ff ff       	call   801bdb <fd2data>
	return _pipeisclosed(fd, p);
  802e0e:	89 c2                	mov    %eax,%edx
  802e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e13:	e8 21 fd ff ff       	call   802b39 <_pipeisclosed>
  802e18:	83 c4 10             	add    $0x10,%esp
}
  802e1b:	c9                   	leave  
  802e1c:	c3                   	ret    

00802e1d <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802e1d:	55                   	push   %ebp
  802e1e:	89 e5                	mov    %esp,%ebp
  802e20:	56                   	push   %esi
  802e21:	53                   	push   %ebx
  802e22:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802e25:	85 f6                	test   %esi,%esi
  802e27:	75 16                	jne    802e3f <wait+0x22>
  802e29:	68 5b 3a 80 00       	push   $0x803a5b
  802e2e:	68 fa 33 80 00       	push   $0x8033fa
  802e33:	6a 09                	push   $0x9
  802e35:	68 66 3a 80 00       	push   $0x803a66
  802e3a:	e8 d5 db ff ff       	call   800a14 <_panic>
	e = &envs[ENVX(envid)];
  802e3f:	89 f3                	mov    %esi,%ebx
  802e41:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e47:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802e4a:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802e50:	eb 05                	jmp    802e57 <wait+0x3a>
		sys_yield();
  802e52:	e8 71 e7 ff ff       	call   8015c8 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e57:	8b 43 48             	mov    0x48(%ebx),%eax
  802e5a:	39 c6                	cmp    %eax,%esi
  802e5c:	75 07                	jne    802e65 <wait+0x48>
  802e5e:	8b 43 54             	mov    0x54(%ebx),%eax
  802e61:	85 c0                	test   %eax,%eax
  802e63:	75 ed                	jne    802e52 <wait+0x35>
		sys_yield();
}
  802e65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e68:	5b                   	pop    %ebx
  802e69:	5e                   	pop    %esi
  802e6a:	5d                   	pop    %ebp
  802e6b:	c3                   	ret    

00802e6c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802e6c:	55                   	push   %ebp
  802e6d:	89 e5                	mov    %esp,%ebp
  802e6f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802e72:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802e79:	75 4a                	jne    802ec5 <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  802e7b:	a1 24 54 80 00       	mov    0x805424,%eax
  802e80:	8b 40 48             	mov    0x48(%eax),%eax
  802e83:	83 ec 04             	sub    $0x4,%esp
  802e86:	6a 07                	push   $0x7
  802e88:	68 00 f0 bf ee       	push   $0xeebff000
  802e8d:	50                   	push   %eax
  802e8e:	e8 54 e7 ff ff       	call   8015e7 <sys_page_alloc>
  802e93:	83 c4 10             	add    $0x10,%esp
  802e96:	85 c0                	test   %eax,%eax
  802e98:	79 12                	jns    802eac <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  802e9a:	50                   	push   %eax
  802e9b:	68 71 3a 80 00       	push   $0x803a71
  802ea0:	6a 21                	push   $0x21
  802ea2:	68 89 3a 80 00       	push   $0x803a89
  802ea7:	e8 68 db ff ff       	call   800a14 <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  802eac:	a1 24 54 80 00       	mov    0x805424,%eax
  802eb1:	8b 40 48             	mov    0x48(%eax),%eax
  802eb4:	83 ec 08             	sub    $0x8,%esp
  802eb7:	68 cf 2e 80 00       	push   $0x802ecf
  802ebc:	50                   	push   %eax
  802ebd:	e8 70 e8 ff ff       	call   801732 <sys_env_set_pgfault_upcall>
  802ec2:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802ec5:	8b 45 08             	mov    0x8(%ebp),%eax
  802ec8:	a3 00 70 80 00       	mov    %eax,0x807000
  802ecd:	c9                   	leave  
  802ece:	c3                   	ret    

00802ecf <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802ecf:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802ed0:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802ed5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802ed7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  802eda:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  802edd:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  802ee1:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  802ee6:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  802eea:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  802eec:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  802eed:	83 c4 04             	add    $0x4,%esp
	popfl
  802ef0:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802ef1:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  802ef2:	c3                   	ret    

00802ef3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802ef3:	55                   	push   %ebp
  802ef4:	89 e5                	mov    %esp,%ebp
  802ef6:	56                   	push   %esi
  802ef7:	53                   	push   %ebx
  802ef8:	8b 75 08             	mov    0x8(%ebp),%esi
  802efb:	8b 45 0c             	mov    0xc(%ebp),%eax
  802efe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  802f01:	85 c0                	test   %eax,%eax
  802f03:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802f08:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  802f0b:	83 ec 0c             	sub    $0xc,%esp
  802f0e:	50                   	push   %eax
  802f0f:	e8 83 e8 ff ff       	call   801797 <sys_ipc_recv>
  802f14:	83 c4 10             	add    $0x10,%esp
  802f17:	85 c0                	test   %eax,%eax
  802f19:	79 16                	jns    802f31 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  802f1b:	85 f6                	test   %esi,%esi
  802f1d:	74 06                	je     802f25 <ipc_recv+0x32>
            *from_env_store = 0;
  802f1f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  802f25:	85 db                	test   %ebx,%ebx
  802f27:	74 2c                	je     802f55 <ipc_recv+0x62>
            *perm_store = 0;
  802f29:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802f2f:	eb 24                	jmp    802f55 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  802f31:	85 f6                	test   %esi,%esi
  802f33:	74 0a                	je     802f3f <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  802f35:	a1 24 54 80 00       	mov    0x805424,%eax
  802f3a:	8b 40 74             	mov    0x74(%eax),%eax
  802f3d:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  802f3f:	85 db                	test   %ebx,%ebx
  802f41:	74 0a                	je     802f4d <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  802f43:	a1 24 54 80 00       	mov    0x805424,%eax
  802f48:	8b 40 78             	mov    0x78(%eax),%eax
  802f4b:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  802f4d:	a1 24 54 80 00       	mov    0x805424,%eax
  802f52:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  802f55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f58:	5b                   	pop    %ebx
  802f59:	5e                   	pop    %esi
  802f5a:	5d                   	pop    %ebp
  802f5b:	c3                   	ret    

00802f5c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802f5c:	55                   	push   %ebp
  802f5d:	89 e5                	mov    %esp,%ebp
  802f5f:	57                   	push   %edi
  802f60:	56                   	push   %esi
  802f61:	53                   	push   %ebx
  802f62:	83 ec 0c             	sub    $0xc,%esp
  802f65:	8b 7d 08             	mov    0x8(%ebp),%edi
  802f68:	8b 75 0c             	mov    0xc(%ebp),%esi
  802f6b:	8b 45 10             	mov    0x10(%ebp),%eax
  802f6e:	85 c0                	test   %eax,%eax
  802f70:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802f75:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  802f78:	eb 1c                	jmp    802f96 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  802f7a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802f7d:	74 12                	je     802f91 <ipc_send+0x35>
  802f7f:	50                   	push   %eax
  802f80:	68 97 3a 80 00       	push   $0x803a97
  802f85:	6a 3a                	push   $0x3a
  802f87:	68 ad 3a 80 00       	push   $0x803aad
  802f8c:	e8 83 da ff ff       	call   800a14 <_panic>
		sys_yield();
  802f91:	e8 32 e6 ff ff       	call   8015c8 <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  802f96:	ff 75 14             	pushl  0x14(%ebp)
  802f99:	53                   	push   %ebx
  802f9a:	56                   	push   %esi
  802f9b:	57                   	push   %edi
  802f9c:	e8 d3 e7 ff ff       	call   801774 <sys_ipc_try_send>
  802fa1:	83 c4 10             	add    $0x10,%esp
  802fa4:	85 c0                	test   %eax,%eax
  802fa6:	78 d2                	js     802f7a <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  802fa8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802fab:	5b                   	pop    %ebx
  802fac:	5e                   	pop    %esi
  802fad:	5f                   	pop    %edi
  802fae:	5d                   	pop    %ebp
  802faf:	c3                   	ret    

00802fb0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802fb0:	55                   	push   %ebp
  802fb1:	89 e5                	mov    %esp,%ebp
  802fb3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802fb6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802fbb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802fbe:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802fc4:	8b 52 50             	mov    0x50(%edx),%edx
  802fc7:	39 ca                	cmp    %ecx,%edx
  802fc9:	75 0d                	jne    802fd8 <ipc_find_env+0x28>
			return envs[i].env_id;
  802fcb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802fce:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802fd3:	8b 40 48             	mov    0x48(%eax),%eax
  802fd6:	eb 0f                	jmp    802fe7 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802fd8:	83 c0 01             	add    $0x1,%eax
  802fdb:	3d 00 04 00 00       	cmp    $0x400,%eax
  802fe0:	75 d9                	jne    802fbb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802fe2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802fe7:	5d                   	pop    %ebp
  802fe8:	c3                   	ret    

00802fe9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802fe9:	55                   	push   %ebp
  802fea:	89 e5                	mov    %esp,%ebp
  802fec:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802fef:	89 d0                	mov    %edx,%eax
  802ff1:	c1 e8 16             	shr    $0x16,%eax
  802ff4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802ffb:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803000:	f6 c1 01             	test   $0x1,%cl
  803003:	74 1d                	je     803022 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803005:	c1 ea 0c             	shr    $0xc,%edx
  803008:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80300f:	f6 c2 01             	test   $0x1,%dl
  803012:	74 0e                	je     803022 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803014:	c1 ea 0c             	shr    $0xc,%edx
  803017:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80301e:	ef 
  80301f:	0f b7 c0             	movzwl %ax,%eax
}
  803022:	5d                   	pop    %ebp
  803023:	c3                   	ret    
  803024:	66 90                	xchg   %ax,%ax
  803026:	66 90                	xchg   %ax,%ax
  803028:	66 90                	xchg   %ax,%ax
  80302a:	66 90                	xchg   %ax,%ax
  80302c:	66 90                	xchg   %ax,%ax
  80302e:	66 90                	xchg   %ax,%ax

00803030 <__udivdi3>:
  803030:	55                   	push   %ebp
  803031:	57                   	push   %edi
  803032:	56                   	push   %esi
  803033:	53                   	push   %ebx
  803034:	83 ec 1c             	sub    $0x1c,%esp
  803037:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80303b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80303f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803043:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803047:	85 f6                	test   %esi,%esi
  803049:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80304d:	89 ca                	mov    %ecx,%edx
  80304f:	89 f8                	mov    %edi,%eax
  803051:	75 3d                	jne    803090 <__udivdi3+0x60>
  803053:	39 cf                	cmp    %ecx,%edi
  803055:	0f 87 c5 00 00 00    	ja     803120 <__udivdi3+0xf0>
  80305b:	85 ff                	test   %edi,%edi
  80305d:	89 fd                	mov    %edi,%ebp
  80305f:	75 0b                	jne    80306c <__udivdi3+0x3c>
  803061:	b8 01 00 00 00       	mov    $0x1,%eax
  803066:	31 d2                	xor    %edx,%edx
  803068:	f7 f7                	div    %edi
  80306a:	89 c5                	mov    %eax,%ebp
  80306c:	89 c8                	mov    %ecx,%eax
  80306e:	31 d2                	xor    %edx,%edx
  803070:	f7 f5                	div    %ebp
  803072:	89 c1                	mov    %eax,%ecx
  803074:	89 d8                	mov    %ebx,%eax
  803076:	89 cf                	mov    %ecx,%edi
  803078:	f7 f5                	div    %ebp
  80307a:	89 c3                	mov    %eax,%ebx
  80307c:	89 d8                	mov    %ebx,%eax
  80307e:	89 fa                	mov    %edi,%edx
  803080:	83 c4 1c             	add    $0x1c,%esp
  803083:	5b                   	pop    %ebx
  803084:	5e                   	pop    %esi
  803085:	5f                   	pop    %edi
  803086:	5d                   	pop    %ebp
  803087:	c3                   	ret    
  803088:	90                   	nop
  803089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803090:	39 ce                	cmp    %ecx,%esi
  803092:	77 74                	ja     803108 <__udivdi3+0xd8>
  803094:	0f bd fe             	bsr    %esi,%edi
  803097:	83 f7 1f             	xor    $0x1f,%edi
  80309a:	0f 84 98 00 00 00    	je     803138 <__udivdi3+0x108>
  8030a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8030a5:	89 f9                	mov    %edi,%ecx
  8030a7:	89 c5                	mov    %eax,%ebp
  8030a9:	29 fb                	sub    %edi,%ebx
  8030ab:	d3 e6                	shl    %cl,%esi
  8030ad:	89 d9                	mov    %ebx,%ecx
  8030af:	d3 ed                	shr    %cl,%ebp
  8030b1:	89 f9                	mov    %edi,%ecx
  8030b3:	d3 e0                	shl    %cl,%eax
  8030b5:	09 ee                	or     %ebp,%esi
  8030b7:	89 d9                	mov    %ebx,%ecx
  8030b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8030bd:	89 d5                	mov    %edx,%ebp
  8030bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8030c3:	d3 ed                	shr    %cl,%ebp
  8030c5:	89 f9                	mov    %edi,%ecx
  8030c7:	d3 e2                	shl    %cl,%edx
  8030c9:	89 d9                	mov    %ebx,%ecx
  8030cb:	d3 e8                	shr    %cl,%eax
  8030cd:	09 c2                	or     %eax,%edx
  8030cf:	89 d0                	mov    %edx,%eax
  8030d1:	89 ea                	mov    %ebp,%edx
  8030d3:	f7 f6                	div    %esi
  8030d5:	89 d5                	mov    %edx,%ebp
  8030d7:	89 c3                	mov    %eax,%ebx
  8030d9:	f7 64 24 0c          	mull   0xc(%esp)
  8030dd:	39 d5                	cmp    %edx,%ebp
  8030df:	72 10                	jb     8030f1 <__udivdi3+0xc1>
  8030e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8030e5:	89 f9                	mov    %edi,%ecx
  8030e7:	d3 e6                	shl    %cl,%esi
  8030e9:	39 c6                	cmp    %eax,%esi
  8030eb:	73 07                	jae    8030f4 <__udivdi3+0xc4>
  8030ed:	39 d5                	cmp    %edx,%ebp
  8030ef:	75 03                	jne    8030f4 <__udivdi3+0xc4>
  8030f1:	83 eb 01             	sub    $0x1,%ebx
  8030f4:	31 ff                	xor    %edi,%edi
  8030f6:	89 d8                	mov    %ebx,%eax
  8030f8:	89 fa                	mov    %edi,%edx
  8030fa:	83 c4 1c             	add    $0x1c,%esp
  8030fd:	5b                   	pop    %ebx
  8030fe:	5e                   	pop    %esi
  8030ff:	5f                   	pop    %edi
  803100:	5d                   	pop    %ebp
  803101:	c3                   	ret    
  803102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803108:	31 ff                	xor    %edi,%edi
  80310a:	31 db                	xor    %ebx,%ebx
  80310c:	89 d8                	mov    %ebx,%eax
  80310e:	89 fa                	mov    %edi,%edx
  803110:	83 c4 1c             	add    $0x1c,%esp
  803113:	5b                   	pop    %ebx
  803114:	5e                   	pop    %esi
  803115:	5f                   	pop    %edi
  803116:	5d                   	pop    %ebp
  803117:	c3                   	ret    
  803118:	90                   	nop
  803119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803120:	89 d8                	mov    %ebx,%eax
  803122:	f7 f7                	div    %edi
  803124:	31 ff                	xor    %edi,%edi
  803126:	89 c3                	mov    %eax,%ebx
  803128:	89 d8                	mov    %ebx,%eax
  80312a:	89 fa                	mov    %edi,%edx
  80312c:	83 c4 1c             	add    $0x1c,%esp
  80312f:	5b                   	pop    %ebx
  803130:	5e                   	pop    %esi
  803131:	5f                   	pop    %edi
  803132:	5d                   	pop    %ebp
  803133:	c3                   	ret    
  803134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803138:	39 ce                	cmp    %ecx,%esi
  80313a:	72 0c                	jb     803148 <__udivdi3+0x118>
  80313c:	31 db                	xor    %ebx,%ebx
  80313e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803142:	0f 87 34 ff ff ff    	ja     80307c <__udivdi3+0x4c>
  803148:	bb 01 00 00 00       	mov    $0x1,%ebx
  80314d:	e9 2a ff ff ff       	jmp    80307c <__udivdi3+0x4c>
  803152:	66 90                	xchg   %ax,%ax
  803154:	66 90                	xchg   %ax,%ax
  803156:	66 90                	xchg   %ax,%ax
  803158:	66 90                	xchg   %ax,%ax
  80315a:	66 90                	xchg   %ax,%ax
  80315c:	66 90                	xchg   %ax,%ax
  80315e:	66 90                	xchg   %ax,%ax

00803160 <__umoddi3>:
  803160:	55                   	push   %ebp
  803161:	57                   	push   %edi
  803162:	56                   	push   %esi
  803163:	53                   	push   %ebx
  803164:	83 ec 1c             	sub    $0x1c,%esp
  803167:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80316b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80316f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803173:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803177:	85 d2                	test   %edx,%edx
  803179:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80317d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803181:	89 f3                	mov    %esi,%ebx
  803183:	89 3c 24             	mov    %edi,(%esp)
  803186:	89 74 24 04          	mov    %esi,0x4(%esp)
  80318a:	75 1c                	jne    8031a8 <__umoddi3+0x48>
  80318c:	39 f7                	cmp    %esi,%edi
  80318e:	76 50                	jbe    8031e0 <__umoddi3+0x80>
  803190:	89 c8                	mov    %ecx,%eax
  803192:	89 f2                	mov    %esi,%edx
  803194:	f7 f7                	div    %edi
  803196:	89 d0                	mov    %edx,%eax
  803198:	31 d2                	xor    %edx,%edx
  80319a:	83 c4 1c             	add    $0x1c,%esp
  80319d:	5b                   	pop    %ebx
  80319e:	5e                   	pop    %esi
  80319f:	5f                   	pop    %edi
  8031a0:	5d                   	pop    %ebp
  8031a1:	c3                   	ret    
  8031a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8031a8:	39 f2                	cmp    %esi,%edx
  8031aa:	89 d0                	mov    %edx,%eax
  8031ac:	77 52                	ja     803200 <__umoddi3+0xa0>
  8031ae:	0f bd ea             	bsr    %edx,%ebp
  8031b1:	83 f5 1f             	xor    $0x1f,%ebp
  8031b4:	75 5a                	jne    803210 <__umoddi3+0xb0>
  8031b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8031ba:	0f 82 e0 00 00 00    	jb     8032a0 <__umoddi3+0x140>
  8031c0:	39 0c 24             	cmp    %ecx,(%esp)
  8031c3:	0f 86 d7 00 00 00    	jbe    8032a0 <__umoddi3+0x140>
  8031c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8031cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8031d1:	83 c4 1c             	add    $0x1c,%esp
  8031d4:	5b                   	pop    %ebx
  8031d5:	5e                   	pop    %esi
  8031d6:	5f                   	pop    %edi
  8031d7:	5d                   	pop    %ebp
  8031d8:	c3                   	ret    
  8031d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8031e0:	85 ff                	test   %edi,%edi
  8031e2:	89 fd                	mov    %edi,%ebp
  8031e4:	75 0b                	jne    8031f1 <__umoddi3+0x91>
  8031e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8031eb:	31 d2                	xor    %edx,%edx
  8031ed:	f7 f7                	div    %edi
  8031ef:	89 c5                	mov    %eax,%ebp
  8031f1:	89 f0                	mov    %esi,%eax
  8031f3:	31 d2                	xor    %edx,%edx
  8031f5:	f7 f5                	div    %ebp
  8031f7:	89 c8                	mov    %ecx,%eax
  8031f9:	f7 f5                	div    %ebp
  8031fb:	89 d0                	mov    %edx,%eax
  8031fd:	eb 99                	jmp    803198 <__umoddi3+0x38>
  8031ff:	90                   	nop
  803200:	89 c8                	mov    %ecx,%eax
  803202:	89 f2                	mov    %esi,%edx
  803204:	83 c4 1c             	add    $0x1c,%esp
  803207:	5b                   	pop    %ebx
  803208:	5e                   	pop    %esi
  803209:	5f                   	pop    %edi
  80320a:	5d                   	pop    %ebp
  80320b:	c3                   	ret    
  80320c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803210:	8b 34 24             	mov    (%esp),%esi
  803213:	bf 20 00 00 00       	mov    $0x20,%edi
  803218:	89 e9                	mov    %ebp,%ecx
  80321a:	29 ef                	sub    %ebp,%edi
  80321c:	d3 e0                	shl    %cl,%eax
  80321e:	89 f9                	mov    %edi,%ecx
  803220:	89 f2                	mov    %esi,%edx
  803222:	d3 ea                	shr    %cl,%edx
  803224:	89 e9                	mov    %ebp,%ecx
  803226:	09 c2                	or     %eax,%edx
  803228:	89 d8                	mov    %ebx,%eax
  80322a:	89 14 24             	mov    %edx,(%esp)
  80322d:	89 f2                	mov    %esi,%edx
  80322f:	d3 e2                	shl    %cl,%edx
  803231:	89 f9                	mov    %edi,%ecx
  803233:	89 54 24 04          	mov    %edx,0x4(%esp)
  803237:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80323b:	d3 e8                	shr    %cl,%eax
  80323d:	89 e9                	mov    %ebp,%ecx
  80323f:	89 c6                	mov    %eax,%esi
  803241:	d3 e3                	shl    %cl,%ebx
  803243:	89 f9                	mov    %edi,%ecx
  803245:	89 d0                	mov    %edx,%eax
  803247:	d3 e8                	shr    %cl,%eax
  803249:	89 e9                	mov    %ebp,%ecx
  80324b:	09 d8                	or     %ebx,%eax
  80324d:	89 d3                	mov    %edx,%ebx
  80324f:	89 f2                	mov    %esi,%edx
  803251:	f7 34 24             	divl   (%esp)
  803254:	89 d6                	mov    %edx,%esi
  803256:	d3 e3                	shl    %cl,%ebx
  803258:	f7 64 24 04          	mull   0x4(%esp)
  80325c:	39 d6                	cmp    %edx,%esi
  80325e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803262:	89 d1                	mov    %edx,%ecx
  803264:	89 c3                	mov    %eax,%ebx
  803266:	72 08                	jb     803270 <__umoddi3+0x110>
  803268:	75 11                	jne    80327b <__umoddi3+0x11b>
  80326a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80326e:	73 0b                	jae    80327b <__umoddi3+0x11b>
  803270:	2b 44 24 04          	sub    0x4(%esp),%eax
  803274:	1b 14 24             	sbb    (%esp),%edx
  803277:	89 d1                	mov    %edx,%ecx
  803279:	89 c3                	mov    %eax,%ebx
  80327b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80327f:	29 da                	sub    %ebx,%edx
  803281:	19 ce                	sbb    %ecx,%esi
  803283:	89 f9                	mov    %edi,%ecx
  803285:	89 f0                	mov    %esi,%eax
  803287:	d3 e0                	shl    %cl,%eax
  803289:	89 e9                	mov    %ebp,%ecx
  80328b:	d3 ea                	shr    %cl,%edx
  80328d:	89 e9                	mov    %ebp,%ecx
  80328f:	d3 ee                	shr    %cl,%esi
  803291:	09 d0                	or     %edx,%eax
  803293:	89 f2                	mov    %esi,%edx
  803295:	83 c4 1c             	add    $0x1c,%esp
  803298:	5b                   	pop    %ebx
  803299:	5e                   	pop    %esi
  80329a:	5f                   	pop    %edi
  80329b:	5d                   	pop    %ebp
  80329c:	c3                   	ret    
  80329d:	8d 76 00             	lea    0x0(%esi),%esi
  8032a0:	29 f9                	sub    %edi,%ecx
  8032a2:	19 d6                	sbb    %edx,%esi
  8032a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8032a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8032ac:	e9 18 ff ff ff       	jmp    8031c9 <__umoddi3+0x69>
