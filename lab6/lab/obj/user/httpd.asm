
obj/user/httpd.debug：     文件格式 elf32-i386


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
  80002c:	e8 53 07 00 00       	call   800784 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <die>:
	{404, "Not Found"},
};

static void
die(char *m)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("%s\n", m);
  800039:	50                   	push   %eax
  80003a:	68 a0 2c 80 00       	push   $0x802ca0
  80003f:	e8 79 08 00 00       	call   8008bd <cprintf>
	exit();
  800044:	e8 81 07 00 00       	call   8007ca <exit>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <send_error>:
	return 0;
}

static int
send_error(struct http_request *req, int code)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	81 ec 0c 02 00 00    	sub    $0x20c,%esp
	char buf[512];
	int r;

	struct error_messages *e = errors;
  80005a:	b9 00 40 80 00       	mov    $0x804000,%ecx
	while (e->code != 0 && e->msg != 0) {
  80005f:	eb 03                	jmp    800064 <send_error+0x16>
		if (e->code == code)
			break;
		e++;
  800061:	83 c1 08             	add    $0x8,%ecx
{
	char buf[512];
	int r;

	struct error_messages *e = errors;
	while (e->code != 0 && e->msg != 0) {
  800064:	8b 19                	mov    (%ecx),%ebx
  800066:	85 db                	test   %ebx,%ebx
  800068:	74 49                	je     8000b3 <send_error+0x65>
		if (e->code == code)
  80006a:	83 79 04 00          	cmpl   $0x0,0x4(%ecx)
  80006e:	74 04                	je     800074 <send_error+0x26>
  800070:	39 d3                	cmp    %edx,%ebx
  800072:	75 ed                	jne    800061 <send_error+0x13>
  800074:	89 c6                	mov    %eax,%esi
	}

	if (e->code == 0)
		return -1;

	r = snprintf(buf, 512, "HTTP/" HTTP_VERSION" %d %s\r\n"
  800076:	8b 41 04             	mov    0x4(%ecx),%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	50                   	push   %eax
  80007f:	53                   	push   %ebx
  800080:	68 60 2d 80 00       	push   $0x802d60
  800085:	68 00 02 00 00       	push   $0x200
  80008a:	8d bd e8 fd ff ff    	lea    -0x218(%ebp),%edi
  800090:	57                   	push   %edi
  800091:	e8 d8 0d 00 00       	call   800e6e <snprintf>
  800096:	89 c3                	mov    %eax,%ebx
			       "Content-type: text/html\r\n"
			       "\r\n"
			       "<html><body><p>%d - %s</p></body></html>\r\n",
			       e->code, e->msg, e->code, e->msg);

	if (write(req->sock, buf, r) != r)
  800098:	83 c4 1c             	add    $0x1c,%esp
  80009b:	50                   	push   %eax
  80009c:	57                   	push   %edi
  80009d:	ff 36                	pushl  (%esi)
  80009f:	e8 06 18 00 00       	call   8018aa <write>
  8000a4:	83 c4 10             	add    $0x10,%esp
  8000a7:	39 c3                	cmp    %eax,%ebx
  8000a9:	0f 95 c0             	setne  %al
  8000ac:	0f b6 c0             	movzbl %al,%eax
  8000af:	f7 d8                	neg    %eax
  8000b1:	eb 05                	jmp    8000b8 <send_error+0x6a>
			break;
		e++;
	}

	if (e->code == 0)
		return -1;
  8000b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	if (write(req->sock, buf, r) != r)
		return -1;

	return 0;
}
  8000b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <handle_client>:
	return r;
}

static void
handle_client(int sock)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
  8000c6:	81 ec c0 04 00 00    	sub    $0x4c0,%esp
  8000cc:	89 c7                	mov    %eax,%edi
	struct http_request *req = &con_d;

	while (1)
	{
		// Receive message
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  8000ce:	68 00 02 00 00       	push   $0x200
  8000d3:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  8000d9:	50                   	push   %eax
  8000da:	57                   	push   %edi
  8000db:	e8 f0 16 00 00       	call   8017d0 <read>
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	85 c0                	test   %eax,%eax
  8000e5:	79 17                	jns    8000fe <handle_client+0x3e>
			panic("failed to read");
  8000e7:	83 ec 04             	sub    $0x4,%esp
  8000ea:	68 a4 2c 80 00       	push   $0x802ca4
  8000ef:	68 16 01 00 00       	push   $0x116
  8000f4:	68 b3 2c 80 00       	push   $0x802cb3
  8000f9:	e8 e6 06 00 00       	call   8007e4 <_panic>

		memset(req, 0, sizeof(*req));
  8000fe:	83 ec 04             	sub    $0x4,%esp
  800101:	6a 0c                	push   $0xc
  800103:	6a 00                	push   $0x0
  800105:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	e8 f8 0e 00 00       	call   801006 <memset>

		req->sock = sock;
  80010e:	89 7d dc             	mov    %edi,-0x24(%ebp)
	int url_len, version_len;

	if (!req)
		return -1;

	if (strncmp(request, "GET ", 4) != 0)
  800111:	83 c4 0c             	add    $0xc,%esp
  800114:	6a 04                	push   $0x4
  800116:	68 c0 2c 80 00       	push   $0x802cc0
  80011b:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  800121:	50                   	push   %eax
  800122:	e8 6a 0e 00 00       	call   800f91 <strncmp>
  800127:	83 c4 10             	add    $0x10,%esp
  80012a:	85 c0                	test   %eax,%eax
  80012c:	0f 85 4e 02 00 00    	jne    800380 <handle_client+0x2c0>
  800132:	8d 9d e0 fd ff ff    	lea    -0x220(%ebp),%ebx
  800138:	eb 03                	jmp    80013d <handle_client+0x7d>
	request += 4;

	// get the url
	url = request;
	while (*request && *request != ' ')
		request++;
  80013a:	83 c3 01             	add    $0x1,%ebx
	// skip GET
	request += 4;

	// get the url
	url = request;
	while (*request && *request != ' ')
  80013d:	f6 03 df             	testb  $0xdf,(%ebx)
  800140:	75 f8                	jne    80013a <handle_client+0x7a>
		request++;
	url_len = request - url;
  800142:	89 de                	mov    %ebx,%esi
  800144:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
  80014a:	29 c6                	sub    %eax,%esi

	req->url = malloc(url_len + 1);
  80014c:	83 ec 0c             	sub    $0xc,%esp
  80014f:	8d 46 01             	lea    0x1(%esi),%eax
  800152:	50                   	push   %eax
  800153:	e8 bc 20 00 00       	call   802214 <malloc>
  800158:	89 45 e0             	mov    %eax,-0x20(%ebp)
	memmove(req->url, url, url_len);
  80015b:	83 c4 0c             	add    $0xc,%esp
  80015e:	56                   	push   %esi
  80015f:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  800165:	51                   	push   %ecx
  800166:	50                   	push   %eax
  800167:	e8 e7 0e 00 00       	call   801053 <memmove>
	req->url[url_len] = '\0';
  80016c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80016f:	c6 04 30 00          	movb   $0x0,(%eax,%esi,1)

	// skip space
	request++;
  800173:	83 c3 01             	add    $0x1,%ebx
  800176:	83 c4 10             	add    $0x10,%esp
  800179:	89 d8                	mov    %ebx,%eax
  80017b:	eb 03                	jmp    800180 <handle_client+0xc0>

	version = request;
	while (*request && *request != '\n')
		request++;
  80017d:	83 c0 01             	add    $0x1,%eax

	// skip space
	request++;

	version = request;
	while (*request && *request != '\n')
  800180:	0f b6 10             	movzbl (%eax),%edx
  800183:	84 d2                	test   %dl,%dl
  800185:	74 05                	je     80018c <handle_client+0xcc>
  800187:	80 fa 0a             	cmp    $0xa,%dl
  80018a:	75 f1                	jne    80017d <handle_client+0xbd>
		request++;
	version_len = request - version;
  80018c:	29 d8                	sub    %ebx,%eax
  80018e:	89 c6                	mov    %eax,%esi

	req->version = malloc(version_len + 1);
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	8d 40 01             	lea    0x1(%eax),%eax
  800196:	50                   	push   %eax
  800197:	e8 78 20 00 00       	call   802214 <malloc>
  80019c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	memmove(req->version, version, version_len);
  80019f:	83 c4 0c             	add    $0xc,%esp
  8001a2:	56                   	push   %esi
  8001a3:	53                   	push   %ebx
  8001a4:	50                   	push   %eax
  8001a5:	e8 a9 0e 00 00       	call   801053 <memmove>
	req->version[version_len] = '\0';
  8001aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001ad:	c6 04 30 00          	movb   $0x0,(%eax,%esi,1)
	// if the file does not exist, send a 404 error using send_error
	// if the file is a directory, send a 404 error using send_error
	// set file_size to the size of the file

	// LAB 6: Your code here.
		if ((fd = open(req->url, O_RDONLY)) < 0) {
  8001b1:	83 c4 08             	add    $0x8,%esp
  8001b4:	6a 00                	push   $0x0
  8001b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b9:	e8 9d 1a 00 00       	call   801c5b <open>
  8001be:	89 c6                	mov    %eax,%esi
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	79 12                	jns    8001d9 <handle_client+0x119>
		send_error(req, 404);
  8001c7:	ba 94 01 00 00       	mov    $0x194,%edx
  8001cc:	8d 45 dc             	lea    -0x24(%ebp),%eax
  8001cf:	e8 7a fe ff ff       	call   80004e <send_error>
  8001d4:	e9 7b 01 00 00       	jmp    800354 <handle_client+0x294>
		goto end;
	}

	struct Stat stat;
	fstat(fd, &stat);
  8001d9:	83 ec 08             	sub    $0x8,%esp
  8001dc:	8d 85 50 fb ff ff    	lea    -0x4b0(%ebp),%eax
  8001e2:	50                   	push   %eax
  8001e3:	56                   	push   %esi
  8001e4:	e8 ff 17 00 00       	call   8019e8 <fstat>
	if (stat.st_isdir) {
  8001e9:	83 c4 10             	add    $0x10,%esp
  8001ec:	bb 10 40 80 00       	mov    $0x804010,%ebx
  8001f1:	83 bd d4 fb ff ff 00 	cmpl   $0x0,-0x42c(%ebp)
  8001f8:	74 15                	je     80020f <handle_client+0x14f>
		send_error(req, 404);
  8001fa:	ba 94 01 00 00       	mov    $0x194,%edx
  8001ff:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800202:	e8 47 fe ff ff       	call   80004e <send_error>
  800207:	e9 48 01 00 00       	jmp    800354 <handle_client+0x294>
{
	struct responce_header *h = headers;
	while (h->code != 0 && h->header!= 0) {
		if (h->code == code)
			break;
		h++;
  80020c:	83 c3 08             	add    $0x8,%ebx

static int
send_header(struct http_request *req, int code)
{
	struct responce_header *h = headers;
	while (h->code != 0 && h->header!= 0) {
  80020f:	8b 03                	mov    (%ebx),%eax
  800211:	85 c0                	test   %eax,%eax
  800213:	0f 84 3b 01 00 00    	je     800354 <handle_client+0x294>
		if (h->code == code)
  800219:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  80021d:	74 07                	je     800226 <handle_client+0x166>
  80021f:	3d c8 00 00 00       	cmp    $0xc8,%eax
  800224:	75 e6                	jne    80020c <handle_client+0x14c>
	}

	if (h->code == 0)
		return -1;

	int len = strlen(h->header);
  800226:	83 ec 0c             	sub    $0xc,%esp
  800229:	ff 73 04             	pushl  0x4(%ebx)
  80022c:	e8 57 0c 00 00       	call   800e88 <strlen>
	if (write(req->sock, h->header, len) != len) {
  800231:	83 c4 0c             	add    $0xc,%esp
  800234:	89 85 44 fb ff ff    	mov    %eax,-0x4bc(%ebp)
  80023a:	50                   	push   %eax
  80023b:	ff 73 04             	pushl  0x4(%ebx)
  80023e:	ff 75 dc             	pushl  -0x24(%ebp)
  800241:	e8 64 16 00 00       	call   8018aa <write>
  800246:	83 c4 10             	add    $0x10,%esp
  800249:	39 85 44 fb ff ff    	cmp    %eax,-0x4bc(%ebp)
  80024f:	0f 84 3a 01 00 00    	je     80038f <handle_client+0x2cf>
		die("Failed to send bytes to client");
  800255:	b8 dc 2d 80 00       	mov    $0x802ddc,%eax
  80025a:	e8 d4 fd ff ff       	call   800033 <die>
  80025f:	e9 2b 01 00 00       	jmp    80038f <handle_client+0x2cf>
	char buf[64];
	int r;

	r = snprintf(buf, 64, "Content-Length: %ld\r\n", (long)size);
	if (r > 63)
		panic("buffer too small!");
  800264:	83 ec 04             	sub    $0x4,%esp
  800267:	68 c5 2c 80 00       	push   $0x802cc5
  80026c:	6a 63                	push   $0x63
  80026e:	68 b3 2c 80 00       	push   $0x802cb3
  800273:	e8 6c 05 00 00       	call   8007e4 <_panic>

	if (write(req->sock, buf, r) != r)
  800278:	83 ec 04             	sub    $0x4,%esp
  80027b:	53                   	push   %ebx
  80027c:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
  800282:	50                   	push   %eax
  800283:	ff 75 dc             	pushl  -0x24(%ebp)
  800286:	e8 1f 16 00 00       	call   8018aa <write>
	}
	//panic("send_file not implemented");
	if ((r = send_header(req, 200)) < 0)
		goto end;

	if ((r = send_size(req, file_size)) < 0)
  80028b:	83 c4 10             	add    $0x10,%esp
  80028e:	39 c3                	cmp    %eax,%ebx
  800290:	0f 85 be 00 00 00    	jne    800354 <handle_client+0x294>

	type = mime_type(req->url);
	if (!type)
		return -1;

	r = snprintf(buf, 128, "Content-Type: %s\r\n", type);
  800296:	68 d7 2c 80 00       	push   $0x802cd7
  80029b:	68 e1 2c 80 00       	push   $0x802ce1
  8002a0:	68 80 00 00 00       	push   $0x80
  8002a5:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
  8002ab:	50                   	push   %eax
  8002ac:	e8 bd 0b 00 00       	call   800e6e <snprintf>
  8002b1:	89 c3                	mov    %eax,%ebx
	if (r > 127)
  8002b3:	83 c4 10             	add    $0x10,%esp
  8002b6:	83 f8 7f             	cmp    $0x7f,%eax
  8002b9:	7e 14                	jle    8002cf <handle_client+0x20f>
		panic("buffer too small!");
  8002bb:	83 ec 04             	sub    $0x4,%esp
  8002be:	68 c5 2c 80 00       	push   $0x802cc5
  8002c3:	6a 7f                	push   $0x7f
  8002c5:	68 b3 2c 80 00       	push   $0x802cb3
  8002ca:	e8 15 05 00 00       	call   8007e4 <_panic>

	if (write(req->sock, buf, r) != r)
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	50                   	push   %eax
  8002d3:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
  8002d9:	50                   	push   %eax
  8002da:	ff 75 dc             	pushl  -0x24(%ebp)
  8002dd:	e8 c8 15 00 00       	call   8018aa <write>
		goto end;

	if ((r = send_size(req, file_size)) < 0)
		goto end;

	if ((r = send_content_type(req)) < 0)
  8002e2:	83 c4 10             	add    $0x10,%esp
  8002e5:	39 c3                	cmp    %eax,%ebx
  8002e7:	75 6b                	jne    800354 <handle_client+0x294>

static int
send_header_fin(struct http_request *req)
{
	const char *fin = "\r\n";
	int fin_len = strlen(fin);
  8002e9:	83 ec 0c             	sub    $0xc,%esp
  8002ec:	68 25 2d 80 00       	push   $0x802d25
  8002f1:	e8 92 0b 00 00       	call   800e88 <strlen>
  8002f6:	89 c3                	mov    %eax,%ebx

	if (write(req->sock, fin, fin_len) != fin_len)
  8002f8:	83 c4 0c             	add    $0xc,%esp
  8002fb:	50                   	push   %eax
  8002fc:	68 25 2d 80 00       	push   $0x802d25
  800301:	ff 75 dc             	pushl  -0x24(%ebp)
  800304:	e8 a1 15 00 00       	call   8018aa <write>
		goto end;

	if ((r = send_content_type(req)) < 0)
		goto end;

	if ((r = send_header_fin(req)) < 0)
  800309:	83 c4 10             	add    $0x10,%esp
  80030c:	39 c3                	cmp    %eax,%ebx
  80030e:	75 44                	jne    800354 <handle_client+0x294>
  800310:	eb 24                	jmp    800336 <handle_client+0x276>
{
	// LAB 6: Your code here.
	int n;
	char buf[BUFFSIZE];
	while((n=read(fd,buf,(long)sizeof(buf)))>0){
		if(write(req->sock,buf,n)!=n){
  800312:	83 ec 04             	sub    $0x4,%esp
  800315:	53                   	push   %ebx
  800316:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
  80031c:	50                   	push   %eax
  80031d:	ff 75 dc             	pushl  -0x24(%ebp)
  800320:	e8 85 15 00 00       	call   8018aa <write>
  800325:	83 c4 10             	add    $0x10,%esp
  800328:	39 c3                	cmp    %eax,%ebx
  80032a:	74 0a                	je     800336 <handle_client+0x276>
			die("Failed to send file to client");
  80032c:	b8 f4 2c 80 00       	mov    $0x802cf4,%eax
  800331:	e8 fd fc ff ff       	call   800033 <die>
send_data(struct http_request *req, int fd)
{
	// LAB 6: Your code here.
	int n;
	char buf[BUFFSIZE];
	while((n=read(fd,buf,(long)sizeof(buf)))>0){
  800336:	83 ec 04             	sub    $0x4,%esp
  800339:	68 00 02 00 00       	push   $0x200
  80033e:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
  800344:	50                   	push   %eax
  800345:	56                   	push   %esi
  800346:	e8 85 14 00 00       	call   8017d0 <read>
  80034b:	89 c3                	mov    %eax,%ebx
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	85 c0                	test   %eax,%eax
  800352:	7f be                	jg     800312 <handle_client+0x252>
		goto end;

	r = send_data(req, fd);

end:
	close(fd);
  800354:	83 ec 0c             	sub    $0xc,%esp
  800357:	56                   	push   %esi
  800358:	e8 37 13 00 00       	call   801694 <close>
  80035d:	83 c4 10             	add    $0x10,%esp
}

static void
req_free(struct http_request *req)
{
	free(req->url);
  800360:	83 ec 0c             	sub    $0xc,%esp
  800363:	ff 75 e0             	pushl  -0x20(%ebp)
  800366:	e8 fb 1d 00 00       	call   802166 <free>
	free(req->version);
  80036b:	83 c4 04             	add    $0x4,%esp
  80036e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800371:	e8 f0 1d 00 00       	call   802166 <free>

		// no keep alive
		break;
	}

	close(sock);
  800376:	89 3c 24             	mov    %edi,(%esp)
  800379:	e8 16 13 00 00       	call   801694 <close>
}
  80037e:	eb 37                	jmp    8003b7 <handle_client+0x2f7>

		req->sock = sock;

		r = http_request_parse(req, buffer);
		if (r == -E_BAD_REQ)
			send_error(req, 400);
  800380:	ba 90 01 00 00       	mov    $0x190,%edx
  800385:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800388:	e8 c1 fc ff ff       	call   80004e <send_error>
  80038d:	eb d1                	jmp    800360 <handle_client+0x2a0>
send_size(struct http_request *req, off_t size)
{
	char buf[64];
	int r;

	r = snprintf(buf, 64, "Content-Length: %ld\r\n", (long)size);
  80038f:	6a ff                	push   $0xffffffff
  800391:	68 12 2d 80 00       	push   $0x802d12
  800396:	6a 40                	push   $0x40
  800398:	8d 85 dc fb ff ff    	lea    -0x424(%ebp),%eax
  80039e:	50                   	push   %eax
  80039f:	e8 ca 0a 00 00       	call   800e6e <snprintf>
  8003a4:	89 c3                	mov    %eax,%ebx
	if (r > 63)
  8003a6:	83 c4 10             	add    $0x10,%esp
  8003a9:	83 f8 3f             	cmp    $0x3f,%eax
  8003ac:	0f 8e c6 fe ff ff    	jle    800278 <handle_client+0x1b8>
  8003b2:	e9 ad fe ff ff       	jmp    800264 <handle_client+0x1a4>
		// no keep alive
		break;
	}

	close(sock);
}
  8003b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ba:	5b                   	pop    %ebx
  8003bb:	5e                   	pop    %esi
  8003bc:	5f                   	pop    %edi
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    

008003bf <umain>:

void
umain(int argc, char **argv)
{
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
  8003c2:	57                   	push   %edi
  8003c3:	56                   	push   %esi
  8003c4:	53                   	push   %ebx
  8003c5:	83 ec 40             	sub    $0x40,%esp
	int serversock, clientsock;
	struct sockaddr_in server, client;

	binaryname = "jhttpd";
  8003c8:	c7 05 20 40 80 00 28 	movl   $0x802d28,0x804020
  8003cf:	2d 80 00 

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  8003d2:	6a 06                	push   $0x6
  8003d4:	6a 01                	push   $0x1
  8003d6:	6a 02                	push   $0x2
  8003d8:	e8 11 1b 00 00       	call   801eee <socket>
  8003dd:	89 c6                	mov    %eax,%esi
  8003df:	83 c4 10             	add    $0x10,%esp
  8003e2:	85 c0                	test   %eax,%eax
  8003e4:	79 0a                	jns    8003f0 <umain+0x31>
		die("Failed to create socket");
  8003e6:	b8 2f 2d 80 00       	mov    $0x802d2f,%eax
  8003eb:	e8 43 fc ff ff       	call   800033 <die>

	// Construct the server sockaddr_in structure
	memset(&server, 0, sizeof(server));		// Clear struct
  8003f0:	83 ec 04             	sub    $0x4,%esp
  8003f3:	6a 10                	push   $0x10
  8003f5:	6a 00                	push   $0x0
  8003f7:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  8003fa:	53                   	push   %ebx
  8003fb:	e8 06 0c 00 00       	call   801006 <memset>
	server.sin_family = AF_INET;			// Internet/IP
  800400:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	server.sin_addr.s_addr = htonl(INADDR_ANY);	// IP address
  800404:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80040b:	e8 43 01 00 00       	call   800553 <htonl>
  800410:	89 45 dc             	mov    %eax,-0x24(%ebp)
	server.sin_port = htons(PORT);			// server port
  800413:	c7 04 24 50 00 00 00 	movl   $0x50,(%esp)
  80041a:	e8 1a 01 00 00       	call   800539 <htons>
  80041f:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &server,
  800423:	83 c4 0c             	add    $0xc,%esp
  800426:	6a 10                	push   $0x10
  800428:	53                   	push   %ebx
  800429:	56                   	push   %esi
  80042a:	e8 2d 1a 00 00       	call   801e5c <bind>
  80042f:	83 c4 10             	add    $0x10,%esp
  800432:	85 c0                	test   %eax,%eax
  800434:	79 0a                	jns    800440 <umain+0x81>
		 sizeof(server)) < 0)
	{
		die("Failed to bind the server socket");
  800436:	b8 fc 2d 80 00       	mov    $0x802dfc,%eax
  80043b:	e8 f3 fb ff ff       	call   800033 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  800440:	83 ec 08             	sub    $0x8,%esp
  800443:	6a 05                	push   $0x5
  800445:	56                   	push   %esi
  800446:	e8 80 1a 00 00       	call   801ecb <listen>
  80044b:	83 c4 10             	add    $0x10,%esp
  80044e:	85 c0                	test   %eax,%eax
  800450:	79 0a                	jns    80045c <umain+0x9d>
		die("Failed to listen on server socket");
  800452:	b8 20 2e 80 00       	mov    $0x802e20,%eax
  800457:	e8 d7 fb ff ff       	call   800033 <die>

	cprintf("Waiting for http connections...\n");
  80045c:	83 ec 0c             	sub    $0xc,%esp
  80045f:	68 44 2e 80 00       	push   $0x802e44
  800464:	e8 54 04 00 00       	call   8008bd <cprintf>
  800469:	83 c4 10             	add    $0x10,%esp

	while (1) {
		unsigned int clientlen = sizeof(client);
		// Wait for client connection
		if ((clientsock = accept(serversock,
  80046c:	8d 7d c4             	lea    -0x3c(%ebp),%edi
		die("Failed to listen on server socket");

	cprintf("Waiting for http connections...\n");

	while (1) {
		unsigned int clientlen = sizeof(client);
  80046f:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		// Wait for client connection
		if ((clientsock = accept(serversock,
  800476:	83 ec 04             	sub    $0x4,%esp
  800479:	57                   	push   %edi
  80047a:	8d 45 c8             	lea    -0x38(%ebp),%eax
  80047d:	50                   	push   %eax
  80047e:	56                   	push   %esi
  80047f:	e8 a1 19 00 00       	call   801e25 <accept>
  800484:	89 c3                	mov    %eax,%ebx
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	85 c0                	test   %eax,%eax
  80048b:	79 0a                	jns    800497 <umain+0xd8>
					 (struct sockaddr *) &client,
					 &clientlen)) < 0)
		{
			die("Failed to accept client connection");
  80048d:	b8 68 2e 80 00       	mov    $0x802e68,%eax
  800492:	e8 9c fb ff ff       	call   800033 <die>
		}
		handle_client(clientsock);
  800497:	89 d8                	mov    %ebx,%eax
  800499:	e8 22 fc ff ff       	call   8000c0 <handle_client>
	}
  80049e:	eb cf                	jmp    80046f <umain+0xb0>

008004a0 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8004a0:	55                   	push   %ebp
  8004a1:	89 e5                	mov    %esp,%ebp
  8004a3:	57                   	push   %edi
  8004a4:	56                   	push   %esi
  8004a5:	53                   	push   %ebx
  8004a6:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8004a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  8004af:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  8004b2:	c7 45 e0 00 50 80 00 	movl   $0x805000,-0x20(%ebp)
  8004b9:	0f b6 0f             	movzbl (%edi),%ecx
  8004bc:	ba 00 00 00 00       	mov    $0x0,%edx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8004c1:	0f b6 d9             	movzbl %cl,%ebx
  8004c4:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8004c7:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
  8004ca:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004cd:	66 c1 e8 0b          	shr    $0xb,%ax
  8004d1:	89 c3                	mov    %eax,%ebx
  8004d3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004d6:	01 c0                	add    %eax,%eax
  8004d8:	29 c1                	sub    %eax,%ecx
  8004da:	89 c8                	mov    %ecx,%eax
      *ap /= (u8_t)10;
  8004dc:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  8004de:	8d 72 01             	lea    0x1(%edx),%esi
  8004e1:	0f b6 d2             	movzbl %dl,%edx
  8004e4:	83 c0 30             	add    $0x30,%eax
  8004e7:	88 44 15 ed          	mov    %al,-0x13(%ebp,%edx,1)
  8004eb:	89 f2                	mov    %esi,%edx
    } while(*ap);
  8004ed:	84 db                	test   %bl,%bl
  8004ef:	75 d0                	jne    8004c1 <inet_ntoa+0x21>
  8004f1:	c6 07 00             	movb   $0x0,(%edi)
  8004f4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f7:	eb 0d                	jmp    800506 <inet_ntoa+0x66>
    while(i--)
      *rp++ = inv[i];
  8004f9:	0f b6 c2             	movzbl %dl,%eax
  8004fc:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  800501:	88 01                	mov    %al,(%ecx)
  800503:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  800506:	83 ea 01             	sub    $0x1,%edx
  800509:	80 fa ff             	cmp    $0xff,%dl
  80050c:	75 eb                	jne    8004f9 <inet_ntoa+0x59>
  80050e:	89 f0                	mov    %esi,%eax
  800510:	0f b6 f0             	movzbl %al,%esi
  800513:	03 75 e0             	add    -0x20(%ebp),%esi
      *rp++ = inv[i];
    *rp++ = '.';
  800516:	8d 46 01             	lea    0x1(%esi),%eax
  800519:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80051c:	c6 06 2e             	movb   $0x2e,(%esi)
    ap++;
  80051f:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  800522:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800525:	39 c7                	cmp    %eax,%edi
  800527:	75 90                	jne    8004b9 <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  800529:	c6 06 00             	movb   $0x0,(%esi)
  return str;
}
  80052c:	b8 00 50 80 00       	mov    $0x805000,%eax
  800531:	83 c4 14             	add    $0x14,%esp
  800534:	5b                   	pop    %ebx
  800535:	5e                   	pop    %esi
  800536:	5f                   	pop    %edi
  800537:	5d                   	pop    %ebp
  800538:	c3                   	ret    

00800539 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  800539:	55                   	push   %ebp
  80053a:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  80053c:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800540:	66 c1 c0 08          	rol    $0x8,%ax
}
  800544:	5d                   	pop    %ebp
  800545:	c3                   	ret    

00800546 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  800546:	55                   	push   %ebp
  800547:	89 e5                	mov    %esp,%ebp
  return htons(n);
  800549:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80054d:	66 c1 c0 08          	rol    $0x8,%ax
}
  800551:	5d                   	pop    %ebp
  800552:	c3                   	ret    

00800553 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  800553:	55                   	push   %ebp
  800554:	89 e5                	mov    %esp,%ebp
  800556:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  800559:	89 d1                	mov    %edx,%ecx
  80055b:	c1 e1 18             	shl    $0x18,%ecx
  80055e:	89 d0                	mov    %edx,%eax
  800560:	c1 e8 18             	shr    $0x18,%eax
  800563:	09 c8                	or     %ecx,%eax
  800565:	89 d1                	mov    %edx,%ecx
  800567:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  80056d:	c1 e1 08             	shl    $0x8,%ecx
  800570:	09 c8                	or     %ecx,%eax
  800572:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  800578:	c1 ea 08             	shr    $0x8,%edx
  80057b:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  80057d:	5d                   	pop    %ebp
  80057e:	c3                   	ret    

0080057f <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  80057f:	55                   	push   %ebp
  800580:	89 e5                	mov    %esp,%ebp
  800582:	57                   	push   %edi
  800583:	56                   	push   %esi
  800584:	53                   	push   %ebx
  800585:	83 ec 20             	sub    $0x20,%esp
  800588:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  80058b:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  80058e:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  800591:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  800594:	0f b6 ca             	movzbl %dl,%ecx
  800597:	83 e9 30             	sub    $0x30,%ecx
  80059a:	83 f9 09             	cmp    $0x9,%ecx
  80059d:	0f 87 94 01 00 00    	ja     800737 <inet_aton+0x1b8>
      return (0);
    val = 0;
    base = 10;
  8005a3:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
    if (c == '0') {
  8005aa:	83 fa 30             	cmp    $0x30,%edx
  8005ad:	75 2b                	jne    8005da <inet_aton+0x5b>
      c = *++cp;
  8005af:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  8005b3:	89 d1                	mov    %edx,%ecx
  8005b5:	83 e1 df             	and    $0xffffffdf,%ecx
  8005b8:	80 f9 58             	cmp    $0x58,%cl
  8005bb:	74 0f                	je     8005cc <inet_aton+0x4d>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  8005bd:	83 c0 01             	add    $0x1,%eax
  8005c0:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  8005c3:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  8005ca:	eb 0e                	jmp    8005da <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  8005cc:	0f be 50 02          	movsbl 0x2(%eax),%edx
  8005d0:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  8005d3:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  8005da:	83 c0 01             	add    $0x1,%eax
  8005dd:	be 00 00 00 00       	mov    $0x0,%esi
  8005e2:	eb 03                	jmp    8005e7 <inet_aton+0x68>
  8005e4:	83 c0 01             	add    $0x1,%eax
  8005e7:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  8005ea:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005ed:	0f b6 fa             	movzbl %dl,%edi
  8005f0:	8d 4f d0             	lea    -0x30(%edi),%ecx
  8005f3:	83 f9 09             	cmp    $0x9,%ecx
  8005f6:	77 0d                	ja     800605 <inet_aton+0x86>
        val = (val * base) + (int)(c - '0');
  8005f8:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  8005fc:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  800600:	0f be 10             	movsbl (%eax),%edx
  800603:	eb df                	jmp    8005e4 <inet_aton+0x65>
      } else if (base == 16 && isxdigit(c)) {
  800605:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  800609:	75 32                	jne    80063d <inet_aton+0xbe>
  80060b:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  80060e:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800611:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800614:	81 e1 df 00 00 00    	and    $0xdf,%ecx
  80061a:	83 e9 41             	sub    $0x41,%ecx
  80061d:	83 f9 05             	cmp    $0x5,%ecx
  800620:	77 1b                	ja     80063d <inet_aton+0xbe>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  800622:	c1 e6 04             	shl    $0x4,%esi
  800625:	83 c2 0a             	add    $0xa,%edx
  800628:	83 7d d8 1a          	cmpl   $0x1a,-0x28(%ebp)
  80062c:	19 c9                	sbb    %ecx,%ecx
  80062e:	83 e1 20             	and    $0x20,%ecx
  800631:	83 c1 41             	add    $0x41,%ecx
  800634:	29 ca                	sub    %ecx,%edx
  800636:	09 d6                	or     %edx,%esi
        c = *++cp;
  800638:	0f be 10             	movsbl (%eax),%edx
  80063b:	eb a7                	jmp    8005e4 <inet_aton+0x65>
      } else
        break;
    }
    if (c == '.') {
  80063d:	83 fa 2e             	cmp    $0x2e,%edx
  800640:	75 23                	jne    800665 <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  800642:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800645:	8d 7d f0             	lea    -0x10(%ebp),%edi
  800648:	39 f8                	cmp    %edi,%eax
  80064a:	0f 84 ee 00 00 00    	je     80073e <inet_aton+0x1bf>
        return (0);
      *pp++ = val;
  800650:	83 c0 04             	add    $0x4,%eax
  800653:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800656:	89 70 fc             	mov    %esi,-0x4(%eax)
      c = *++cp;
  800659:	8d 43 01             	lea    0x1(%ebx),%eax
  80065c:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  800660:	e9 2f ff ff ff       	jmp    800594 <inet_aton+0x15>
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  800665:	85 d2                	test   %edx,%edx
  800667:	74 25                	je     80068e <inet_aton+0x10f>
  800669:	8d 4f e0             	lea    -0x20(%edi),%ecx
    return (0);
  80066c:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  800671:	83 f9 5f             	cmp    $0x5f,%ecx
  800674:	0f 87 d0 00 00 00    	ja     80074a <inet_aton+0x1cb>
  80067a:	83 fa 20             	cmp    $0x20,%edx
  80067d:	74 0f                	je     80068e <inet_aton+0x10f>
  80067f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800682:	83 ea 09             	sub    $0x9,%edx
  800685:	83 fa 04             	cmp    $0x4,%edx
  800688:	0f 87 bc 00 00 00    	ja     80074a <inet_aton+0x1cb>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  80068e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800691:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800694:	29 c2                	sub    %eax,%edx
  800696:	c1 fa 02             	sar    $0x2,%edx
  800699:	83 c2 01             	add    $0x1,%edx
  80069c:	83 fa 02             	cmp    $0x2,%edx
  80069f:	74 20                	je     8006c1 <inet_aton+0x142>
  8006a1:	83 fa 02             	cmp    $0x2,%edx
  8006a4:	7f 0f                	jg     8006b5 <inet_aton+0x136>

  case 0:
    return (0);       /* initial nondigit */
  8006a6:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8006ab:	85 d2                	test   %edx,%edx
  8006ad:	0f 84 97 00 00 00    	je     80074a <inet_aton+0x1cb>
  8006b3:	eb 67                	jmp    80071c <inet_aton+0x19d>
  8006b5:	83 fa 03             	cmp    $0x3,%edx
  8006b8:	74 1e                	je     8006d8 <inet_aton+0x159>
  8006ba:	83 fa 04             	cmp    $0x4,%edx
  8006bd:	74 38                	je     8006f7 <inet_aton+0x178>
  8006bf:	eb 5b                	jmp    80071c <inet_aton+0x19d>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  8006c1:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  8006c6:	81 fe ff ff ff 00    	cmp    $0xffffff,%esi
  8006cc:	77 7c                	ja     80074a <inet_aton+0x1cb>
      return (0);
    val |= parts[0] << 24;
  8006ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006d1:	c1 e0 18             	shl    $0x18,%eax
  8006d4:	09 c6                	or     %eax,%esi
    break;
  8006d6:	eb 44                	jmp    80071c <inet_aton+0x19d>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  8006d8:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  8006dd:	81 fe ff ff 00 00    	cmp    $0xffff,%esi
  8006e3:	77 65                	ja     80074a <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  8006e5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006e8:	c1 e2 18             	shl    $0x18,%edx
  8006eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006ee:	c1 e0 10             	shl    $0x10,%eax
  8006f1:	09 d0                	or     %edx,%eax
  8006f3:	09 c6                	or     %eax,%esi
    break;
  8006f5:	eb 25                	jmp    80071c <inet_aton+0x19d>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  8006f7:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  8006fc:	81 fe ff 00 00 00    	cmp    $0xff,%esi
  800702:	77 46                	ja     80074a <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  800704:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800707:	c1 e2 18             	shl    $0x18,%edx
  80070a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80070d:	c1 e0 10             	shl    $0x10,%eax
  800710:	09 c2                	or     %eax,%edx
  800712:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800715:	c1 e0 08             	shl    $0x8,%eax
  800718:	09 d0                	or     %edx,%eax
  80071a:	09 c6                	or     %eax,%esi
    break;
  }
  if (addr)
  80071c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800720:	74 23                	je     800745 <inet_aton+0x1c6>
    addr->s_addr = htonl(val);
  800722:	56                   	push   %esi
  800723:	e8 2b fe ff ff       	call   800553 <htonl>
  800728:	83 c4 04             	add    $0x4,%esp
  80072b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80072e:	89 03                	mov    %eax,(%ebx)
  return (1);
  800730:	b8 01 00 00 00       	mov    $0x1,%eax
  800735:	eb 13                	jmp    80074a <inet_aton+0x1cb>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  800737:	b8 00 00 00 00       	mov    $0x0,%eax
  80073c:	eb 0c                	jmp    80074a <inet_aton+0x1cb>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  80073e:	b8 00 00 00 00       	mov    $0x0,%eax
  800743:	eb 05                	jmp    80074a <inet_aton+0x1cb>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  800745:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80074a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074d:	5b                   	pop    %ebx
  80074e:	5e                   	pop    %esi
  80074f:	5f                   	pop    %edi
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  800758:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80075b:	50                   	push   %eax
  80075c:	ff 75 08             	pushl  0x8(%ebp)
  80075f:	e8 1b fe ff ff       	call   80057f <inet_aton>
  800764:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  800767:	85 c0                	test   %eax,%eax
  800769:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80076e:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  800772:	c9                   	leave  
  800773:	c3                   	ret    

00800774 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  800777:	ff 75 08             	pushl  0x8(%ebp)
  80077a:	e8 d4 fd ff ff       	call   800553 <htonl>
  80077f:	83 c4 04             	add    $0x4,%esp
}
  800782:	c9                   	leave  
  800783:	c3                   	ret    

00800784 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	56                   	push   %esi
  800788:	53                   	push   %ebx
  800789:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80078c:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  80078f:	e8 f2 0a 00 00       	call   801286 <sys_getenvid>
  800794:	25 ff 03 00 00       	and    $0x3ff,%eax
  800799:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80079c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8007a1:	a3 1c 50 80 00       	mov    %eax,0x80501c

    // save the name of the program so that panic() can use it
    if (argc > 0)
  8007a6:	85 db                	test   %ebx,%ebx
  8007a8:	7e 07                	jle    8007b1 <libmain+0x2d>
        binaryname = argv[0];
  8007aa:	8b 06                	mov    (%esi),%eax
  8007ac:	a3 20 40 80 00       	mov    %eax,0x804020

    // call user main routine
    umain(argc, argv);
  8007b1:	83 ec 08             	sub    $0x8,%esp
  8007b4:	56                   	push   %esi
  8007b5:	53                   	push   %ebx
  8007b6:	e8 04 fc ff ff       	call   8003bf <umain>

    // exit gracefully
    exit();
  8007bb:	e8 0a 00 00 00       	call   8007ca <exit>
}
  8007c0:	83 c4 10             	add    $0x10,%esp
  8007c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007c6:	5b                   	pop    %ebx
  8007c7:	5e                   	pop    %esi
  8007c8:	5d                   	pop    %ebp
  8007c9:	c3                   	ret    

008007ca <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8007d0:	e8 ea 0e 00 00       	call   8016bf <close_all>
	sys_env_destroy(0);
  8007d5:	83 ec 0c             	sub    $0xc,%esp
  8007d8:	6a 00                	push   $0x0
  8007da:	e8 66 0a 00 00       	call   801245 <sys_env_destroy>
}
  8007df:	83 c4 10             	add    $0x10,%esp
  8007e2:	c9                   	leave  
  8007e3:	c3                   	ret    

008007e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	56                   	push   %esi
  8007e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8007e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8007ec:	8b 35 20 40 80 00    	mov    0x804020,%esi
  8007f2:	e8 8f 0a 00 00       	call   801286 <sys_getenvid>
  8007f7:	83 ec 0c             	sub    $0xc,%esp
  8007fa:	ff 75 0c             	pushl  0xc(%ebp)
  8007fd:	ff 75 08             	pushl  0x8(%ebp)
  800800:	56                   	push   %esi
  800801:	50                   	push   %eax
  800802:	68 bc 2e 80 00       	push   $0x802ebc
  800807:	e8 b1 00 00 00       	call   8008bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80080c:	83 c4 18             	add    $0x18,%esp
  80080f:	53                   	push   %ebx
  800810:	ff 75 10             	pushl  0x10(%ebp)
  800813:	e8 54 00 00 00       	call   80086c <vcprintf>
	cprintf("\n");
  800818:	c7 04 24 26 2d 80 00 	movl   $0x802d26,(%esp)
  80081f:	e8 99 00 00 00       	call   8008bd <cprintf>
  800824:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800827:	cc                   	int3   
  800828:	eb fd                	jmp    800827 <_panic+0x43>

0080082a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	53                   	push   %ebx
  80082e:	83 ec 04             	sub    $0x4,%esp
  800831:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800834:	8b 13                	mov    (%ebx),%edx
  800836:	8d 42 01             	lea    0x1(%edx),%eax
  800839:	89 03                	mov    %eax,(%ebx)
  80083b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800842:	3d ff 00 00 00       	cmp    $0xff,%eax
  800847:	75 1a                	jne    800863 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800849:	83 ec 08             	sub    $0x8,%esp
  80084c:	68 ff 00 00 00       	push   $0xff
  800851:	8d 43 08             	lea    0x8(%ebx),%eax
  800854:	50                   	push   %eax
  800855:	e8 ae 09 00 00       	call   801208 <sys_cputs>
		b->idx = 0;
  80085a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800860:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800863:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800867:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086a:	c9                   	leave  
  80086b:	c3                   	ret    

0080086c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800875:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80087c:	00 00 00 
	b.cnt = 0;
  80087f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800886:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800889:	ff 75 0c             	pushl  0xc(%ebp)
  80088c:	ff 75 08             	pushl  0x8(%ebp)
  80088f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800895:	50                   	push   %eax
  800896:	68 2a 08 80 00       	push   $0x80082a
  80089b:	e8 1a 01 00 00       	call   8009ba <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8008a0:	83 c4 08             	add    $0x8,%esp
  8008a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8008a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8008af:	50                   	push   %eax
  8008b0:	e8 53 09 00 00       	call   801208 <sys_cputs>

	return b.cnt;
}
  8008b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8008c3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8008c6:	50                   	push   %eax
  8008c7:	ff 75 08             	pushl  0x8(%ebp)
  8008ca:	e8 9d ff ff ff       	call   80086c <vcprintf>
	va_end(ap);

	return cnt;
}
  8008cf:	c9                   	leave  
  8008d0:	c3                   	ret    

008008d1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	57                   	push   %edi
  8008d5:	56                   	push   %esi
  8008d6:	53                   	push   %ebx
  8008d7:	83 ec 1c             	sub    $0x1c,%esp
  8008da:	89 c7                	mov    %eax,%edi
  8008dc:	89 d6                	mov    %edx,%esi
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8008ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8008f5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8008f8:	39 d3                	cmp    %edx,%ebx
  8008fa:	72 05                	jb     800901 <printnum+0x30>
  8008fc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8008ff:	77 45                	ja     800946 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800901:	83 ec 0c             	sub    $0xc,%esp
  800904:	ff 75 18             	pushl  0x18(%ebp)
  800907:	8b 45 14             	mov    0x14(%ebp),%eax
  80090a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80090d:	53                   	push   %ebx
  80090e:	ff 75 10             	pushl  0x10(%ebp)
  800911:	83 ec 08             	sub    $0x8,%esp
  800914:	ff 75 e4             	pushl  -0x1c(%ebp)
  800917:	ff 75 e0             	pushl  -0x20(%ebp)
  80091a:	ff 75 dc             	pushl  -0x24(%ebp)
  80091d:	ff 75 d8             	pushl  -0x28(%ebp)
  800920:	e8 eb 20 00 00       	call   802a10 <__udivdi3>
  800925:	83 c4 18             	add    $0x18,%esp
  800928:	52                   	push   %edx
  800929:	50                   	push   %eax
  80092a:	89 f2                	mov    %esi,%edx
  80092c:	89 f8                	mov    %edi,%eax
  80092e:	e8 9e ff ff ff       	call   8008d1 <printnum>
  800933:	83 c4 20             	add    $0x20,%esp
  800936:	eb 18                	jmp    800950 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800938:	83 ec 08             	sub    $0x8,%esp
  80093b:	56                   	push   %esi
  80093c:	ff 75 18             	pushl  0x18(%ebp)
  80093f:	ff d7                	call   *%edi
  800941:	83 c4 10             	add    $0x10,%esp
  800944:	eb 03                	jmp    800949 <printnum+0x78>
  800946:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800949:	83 eb 01             	sub    $0x1,%ebx
  80094c:	85 db                	test   %ebx,%ebx
  80094e:	7f e8                	jg     800938 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800950:	83 ec 08             	sub    $0x8,%esp
  800953:	56                   	push   %esi
  800954:	83 ec 04             	sub    $0x4,%esp
  800957:	ff 75 e4             	pushl  -0x1c(%ebp)
  80095a:	ff 75 e0             	pushl  -0x20(%ebp)
  80095d:	ff 75 dc             	pushl  -0x24(%ebp)
  800960:	ff 75 d8             	pushl  -0x28(%ebp)
  800963:	e8 d8 21 00 00       	call   802b40 <__umoddi3>
  800968:	83 c4 14             	add    $0x14,%esp
  80096b:	0f be 80 df 2e 80 00 	movsbl 0x802edf(%eax),%eax
  800972:	50                   	push   %eax
  800973:	ff d7                	call   *%edi
}
  800975:	83 c4 10             	add    $0x10,%esp
  800978:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5f                   	pop    %edi
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800986:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80098a:	8b 10                	mov    (%eax),%edx
  80098c:	3b 50 04             	cmp    0x4(%eax),%edx
  80098f:	73 0a                	jae    80099b <sprintputch+0x1b>
		*b->buf++ = ch;
  800991:	8d 4a 01             	lea    0x1(%edx),%ecx
  800994:	89 08                	mov    %ecx,(%eax)
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	88 02                	mov    %al,(%edx)
}
  80099b:	5d                   	pop    %ebp
  80099c:	c3                   	ret    

0080099d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8009a3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8009a6:	50                   	push   %eax
  8009a7:	ff 75 10             	pushl  0x10(%ebp)
  8009aa:	ff 75 0c             	pushl  0xc(%ebp)
  8009ad:	ff 75 08             	pushl  0x8(%ebp)
  8009b0:	e8 05 00 00 00       	call   8009ba <vprintfmt>
	va_end(ap);
}
  8009b5:	83 c4 10             	add    $0x10,%esp
  8009b8:	c9                   	leave  
  8009b9:	c3                   	ret    

008009ba <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	57                   	push   %edi
  8009be:	56                   	push   %esi
  8009bf:	53                   	push   %ebx
  8009c0:	83 ec 2c             	sub    $0x2c,%esp
  8009c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009c9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8009cc:	eb 12                	jmp    8009e0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8009ce:	85 c0                	test   %eax,%eax
  8009d0:	0f 84 42 04 00 00    	je     800e18 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8009d6:	83 ec 08             	sub    $0x8,%esp
  8009d9:	53                   	push   %ebx
  8009da:	50                   	push   %eax
  8009db:	ff d6                	call   *%esi
  8009dd:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8009e0:	83 c7 01             	add    $0x1,%edi
  8009e3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8009e7:	83 f8 25             	cmp    $0x25,%eax
  8009ea:	75 e2                	jne    8009ce <vprintfmt+0x14>
  8009ec:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8009f0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8009f7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8009fe:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800a05:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a0a:	eb 07                	jmp    800a13 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a0c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800a0f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a13:	8d 47 01             	lea    0x1(%edi),%eax
  800a16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a19:	0f b6 07             	movzbl (%edi),%eax
  800a1c:	0f b6 d0             	movzbl %al,%edx
  800a1f:	83 e8 23             	sub    $0x23,%eax
  800a22:	3c 55                	cmp    $0x55,%al
  800a24:	0f 87 d3 03 00 00    	ja     800dfd <vprintfmt+0x443>
  800a2a:	0f b6 c0             	movzbl %al,%eax
  800a2d:	ff 24 85 20 30 80 00 	jmp    *0x803020(,%eax,4)
  800a34:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800a37:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800a3b:	eb d6                	jmp    800a13 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a40:	b8 00 00 00 00       	mov    $0x0,%eax
  800a45:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800a48:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800a4b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800a4f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800a52:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800a55:	83 f9 09             	cmp    $0x9,%ecx
  800a58:	77 3f                	ja     800a99 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800a5a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800a5d:	eb e9                	jmp    800a48 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800a5f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a62:	8b 00                	mov    (%eax),%eax
  800a64:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800a67:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6a:	8d 40 04             	lea    0x4(%eax),%eax
  800a6d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a70:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800a73:	eb 2a                	jmp    800a9f <vprintfmt+0xe5>
  800a75:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a78:	85 c0                	test   %eax,%eax
  800a7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7f:	0f 49 d0             	cmovns %eax,%edx
  800a82:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a85:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a88:	eb 89                	jmp    800a13 <vprintfmt+0x59>
  800a8a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800a8d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800a94:	e9 7a ff ff ff       	jmp    800a13 <vprintfmt+0x59>
  800a99:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800a9c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800a9f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800aa3:	0f 89 6a ff ff ff    	jns    800a13 <vprintfmt+0x59>
				width = precision, precision = -1;
  800aa9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800aac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800aaf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800ab6:	e9 58 ff ff ff       	jmp    800a13 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800abb:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800abe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800ac1:	e9 4d ff ff ff       	jmp    800a13 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800ac6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac9:	8d 78 04             	lea    0x4(%eax),%edi
  800acc:	83 ec 08             	sub    $0x8,%esp
  800acf:	53                   	push   %ebx
  800ad0:	ff 30                	pushl  (%eax)
  800ad2:	ff d6                	call   *%esi
			break;
  800ad4:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800ad7:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ada:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800add:	e9 fe fe ff ff       	jmp    8009e0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800ae2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae5:	8d 78 04             	lea    0x4(%eax),%edi
  800ae8:	8b 00                	mov    (%eax),%eax
  800aea:	99                   	cltd   
  800aeb:	31 d0                	xor    %edx,%eax
  800aed:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800aef:	83 f8 0f             	cmp    $0xf,%eax
  800af2:	7f 0b                	jg     800aff <vprintfmt+0x145>
  800af4:	8b 14 85 80 31 80 00 	mov    0x803180(,%eax,4),%edx
  800afb:	85 d2                	test   %edx,%edx
  800afd:	75 1b                	jne    800b1a <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800aff:	50                   	push   %eax
  800b00:	68 f7 2e 80 00       	push   $0x802ef7
  800b05:	53                   	push   %ebx
  800b06:	56                   	push   %esi
  800b07:	e8 91 fe ff ff       	call   80099d <printfmt>
  800b0c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800b0f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b12:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800b15:	e9 c6 fe ff ff       	jmp    8009e0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800b1a:	52                   	push   %edx
  800b1b:	68 b5 32 80 00       	push   $0x8032b5
  800b20:	53                   	push   %ebx
  800b21:	56                   	push   %esi
  800b22:	e8 76 fe ff ff       	call   80099d <printfmt>
  800b27:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800b2a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b2d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b30:	e9 ab fe ff ff       	jmp    8009e0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800b35:	8b 45 14             	mov    0x14(%ebp),%eax
  800b38:	83 c0 04             	add    $0x4,%eax
  800b3b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800b3e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b41:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800b43:	85 ff                	test   %edi,%edi
  800b45:	b8 f0 2e 80 00       	mov    $0x802ef0,%eax
  800b4a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800b4d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b51:	0f 8e 94 00 00 00    	jle    800beb <vprintfmt+0x231>
  800b57:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800b5b:	0f 84 98 00 00 00    	je     800bf9 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800b61:	83 ec 08             	sub    $0x8,%esp
  800b64:	ff 75 d0             	pushl  -0x30(%ebp)
  800b67:	57                   	push   %edi
  800b68:	e8 33 03 00 00       	call   800ea0 <strnlen>
  800b6d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800b70:	29 c1                	sub    %eax,%ecx
  800b72:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800b75:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800b78:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800b7c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b7f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800b82:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b84:	eb 0f                	jmp    800b95 <vprintfmt+0x1db>
					putch(padc, putdat);
  800b86:	83 ec 08             	sub    $0x8,%esp
  800b89:	53                   	push   %ebx
  800b8a:	ff 75 e0             	pushl  -0x20(%ebp)
  800b8d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b8f:	83 ef 01             	sub    $0x1,%edi
  800b92:	83 c4 10             	add    $0x10,%esp
  800b95:	85 ff                	test   %edi,%edi
  800b97:	7f ed                	jg     800b86 <vprintfmt+0x1cc>
  800b99:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800b9c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800b9f:	85 c9                	test   %ecx,%ecx
  800ba1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba6:	0f 49 c1             	cmovns %ecx,%eax
  800ba9:	29 c1                	sub    %eax,%ecx
  800bab:	89 75 08             	mov    %esi,0x8(%ebp)
  800bae:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800bb1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800bb4:	89 cb                	mov    %ecx,%ebx
  800bb6:	eb 4d                	jmp    800c05 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800bb8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800bbc:	74 1b                	je     800bd9 <vprintfmt+0x21f>
  800bbe:	0f be c0             	movsbl %al,%eax
  800bc1:	83 e8 20             	sub    $0x20,%eax
  800bc4:	83 f8 5e             	cmp    $0x5e,%eax
  800bc7:	76 10                	jbe    800bd9 <vprintfmt+0x21f>
					putch('?', putdat);
  800bc9:	83 ec 08             	sub    $0x8,%esp
  800bcc:	ff 75 0c             	pushl  0xc(%ebp)
  800bcf:	6a 3f                	push   $0x3f
  800bd1:	ff 55 08             	call   *0x8(%ebp)
  800bd4:	83 c4 10             	add    $0x10,%esp
  800bd7:	eb 0d                	jmp    800be6 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800bd9:	83 ec 08             	sub    $0x8,%esp
  800bdc:	ff 75 0c             	pushl  0xc(%ebp)
  800bdf:	52                   	push   %edx
  800be0:	ff 55 08             	call   *0x8(%ebp)
  800be3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800be6:	83 eb 01             	sub    $0x1,%ebx
  800be9:	eb 1a                	jmp    800c05 <vprintfmt+0x24b>
  800beb:	89 75 08             	mov    %esi,0x8(%ebp)
  800bee:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800bf1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800bf4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800bf7:	eb 0c                	jmp    800c05 <vprintfmt+0x24b>
  800bf9:	89 75 08             	mov    %esi,0x8(%ebp)
  800bfc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800bff:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800c02:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800c05:	83 c7 01             	add    $0x1,%edi
  800c08:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c0c:	0f be d0             	movsbl %al,%edx
  800c0f:	85 d2                	test   %edx,%edx
  800c11:	74 23                	je     800c36 <vprintfmt+0x27c>
  800c13:	85 f6                	test   %esi,%esi
  800c15:	78 a1                	js     800bb8 <vprintfmt+0x1fe>
  800c17:	83 ee 01             	sub    $0x1,%esi
  800c1a:	79 9c                	jns    800bb8 <vprintfmt+0x1fe>
  800c1c:	89 df                	mov    %ebx,%edi
  800c1e:	8b 75 08             	mov    0x8(%ebp),%esi
  800c21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c24:	eb 18                	jmp    800c3e <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800c26:	83 ec 08             	sub    $0x8,%esp
  800c29:	53                   	push   %ebx
  800c2a:	6a 20                	push   $0x20
  800c2c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800c2e:	83 ef 01             	sub    $0x1,%edi
  800c31:	83 c4 10             	add    $0x10,%esp
  800c34:	eb 08                	jmp    800c3e <vprintfmt+0x284>
  800c36:	89 df                	mov    %ebx,%edi
  800c38:	8b 75 08             	mov    0x8(%ebp),%esi
  800c3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c3e:	85 ff                	test   %edi,%edi
  800c40:	7f e4                	jg     800c26 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800c42:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800c45:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c48:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c4b:	e9 90 fd ff ff       	jmp    8009e0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c50:	83 f9 01             	cmp    $0x1,%ecx
  800c53:	7e 19                	jle    800c6e <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800c55:	8b 45 14             	mov    0x14(%ebp),%eax
  800c58:	8b 50 04             	mov    0x4(%eax),%edx
  800c5b:	8b 00                	mov    (%eax),%eax
  800c5d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c60:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800c63:	8b 45 14             	mov    0x14(%ebp),%eax
  800c66:	8d 40 08             	lea    0x8(%eax),%eax
  800c69:	89 45 14             	mov    %eax,0x14(%ebp)
  800c6c:	eb 38                	jmp    800ca6 <vprintfmt+0x2ec>
	else if (lflag)
  800c6e:	85 c9                	test   %ecx,%ecx
  800c70:	74 1b                	je     800c8d <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800c72:	8b 45 14             	mov    0x14(%ebp),%eax
  800c75:	8b 00                	mov    (%eax),%eax
  800c77:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c7a:	89 c1                	mov    %eax,%ecx
  800c7c:	c1 f9 1f             	sar    $0x1f,%ecx
  800c7f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800c82:	8b 45 14             	mov    0x14(%ebp),%eax
  800c85:	8d 40 04             	lea    0x4(%eax),%eax
  800c88:	89 45 14             	mov    %eax,0x14(%ebp)
  800c8b:	eb 19                	jmp    800ca6 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800c8d:	8b 45 14             	mov    0x14(%ebp),%eax
  800c90:	8b 00                	mov    (%eax),%eax
  800c92:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c95:	89 c1                	mov    %eax,%ecx
  800c97:	c1 f9 1f             	sar    $0x1f,%ecx
  800c9a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800c9d:	8b 45 14             	mov    0x14(%ebp),%eax
  800ca0:	8d 40 04             	lea    0x4(%eax),%eax
  800ca3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ca6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ca9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800cac:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800cb1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800cb5:	0f 89 0e 01 00 00    	jns    800dc9 <vprintfmt+0x40f>
				putch('-', putdat);
  800cbb:	83 ec 08             	sub    $0x8,%esp
  800cbe:	53                   	push   %ebx
  800cbf:	6a 2d                	push   $0x2d
  800cc1:	ff d6                	call   *%esi
				num = -(long long) num;
  800cc3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800cc6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800cc9:	f7 da                	neg    %edx
  800ccb:	83 d1 00             	adc    $0x0,%ecx
  800cce:	f7 d9                	neg    %ecx
  800cd0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800cd3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd8:	e9 ec 00 00 00       	jmp    800dc9 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800cdd:	83 f9 01             	cmp    $0x1,%ecx
  800ce0:	7e 18                	jle    800cfa <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800ce2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ce5:	8b 10                	mov    (%eax),%edx
  800ce7:	8b 48 04             	mov    0x4(%eax),%ecx
  800cea:	8d 40 08             	lea    0x8(%eax),%eax
  800ced:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800cf0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf5:	e9 cf 00 00 00       	jmp    800dc9 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800cfa:	85 c9                	test   %ecx,%ecx
  800cfc:	74 1a                	je     800d18 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800cfe:	8b 45 14             	mov    0x14(%ebp),%eax
  800d01:	8b 10                	mov    (%eax),%edx
  800d03:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d08:	8d 40 04             	lea    0x4(%eax),%eax
  800d0b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800d0e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d13:	e9 b1 00 00 00       	jmp    800dc9 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800d18:	8b 45 14             	mov    0x14(%ebp),%eax
  800d1b:	8b 10                	mov    (%eax),%edx
  800d1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d22:	8d 40 04             	lea    0x4(%eax),%eax
  800d25:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800d28:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d2d:	e9 97 00 00 00       	jmp    800dc9 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800d32:	83 ec 08             	sub    $0x8,%esp
  800d35:	53                   	push   %ebx
  800d36:	6a 58                	push   $0x58
  800d38:	ff d6                	call   *%esi
			putch('X', putdat);
  800d3a:	83 c4 08             	add    $0x8,%esp
  800d3d:	53                   	push   %ebx
  800d3e:	6a 58                	push   $0x58
  800d40:	ff d6                	call   *%esi
			putch('X', putdat);
  800d42:	83 c4 08             	add    $0x8,%esp
  800d45:	53                   	push   %ebx
  800d46:	6a 58                	push   $0x58
  800d48:	ff d6                	call   *%esi
			break;
  800d4a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d4d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800d50:	e9 8b fc ff ff       	jmp    8009e0 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800d55:	83 ec 08             	sub    $0x8,%esp
  800d58:	53                   	push   %ebx
  800d59:	6a 30                	push   $0x30
  800d5b:	ff d6                	call   *%esi
			putch('x', putdat);
  800d5d:	83 c4 08             	add    $0x8,%esp
  800d60:	53                   	push   %ebx
  800d61:	6a 78                	push   $0x78
  800d63:	ff d6                	call   *%esi
			num = (unsigned long long)
  800d65:	8b 45 14             	mov    0x14(%ebp),%eax
  800d68:	8b 10                	mov    (%eax),%edx
  800d6a:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800d6f:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800d72:	8d 40 04             	lea    0x4(%eax),%eax
  800d75:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800d78:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800d7d:	eb 4a                	jmp    800dc9 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800d7f:	83 f9 01             	cmp    $0x1,%ecx
  800d82:	7e 15                	jle    800d99 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800d84:	8b 45 14             	mov    0x14(%ebp),%eax
  800d87:	8b 10                	mov    (%eax),%edx
  800d89:	8b 48 04             	mov    0x4(%eax),%ecx
  800d8c:	8d 40 08             	lea    0x8(%eax),%eax
  800d8f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800d92:	b8 10 00 00 00       	mov    $0x10,%eax
  800d97:	eb 30                	jmp    800dc9 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800d99:	85 c9                	test   %ecx,%ecx
  800d9b:	74 17                	je     800db4 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800d9d:	8b 45 14             	mov    0x14(%ebp),%eax
  800da0:	8b 10                	mov    (%eax),%edx
  800da2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da7:	8d 40 04             	lea    0x4(%eax),%eax
  800daa:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800dad:	b8 10 00 00 00       	mov    $0x10,%eax
  800db2:	eb 15                	jmp    800dc9 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800db4:	8b 45 14             	mov    0x14(%ebp),%eax
  800db7:	8b 10                	mov    (%eax),%edx
  800db9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbe:	8d 40 04             	lea    0x4(%eax),%eax
  800dc1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800dc4:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800dc9:	83 ec 0c             	sub    $0xc,%esp
  800dcc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800dd0:	57                   	push   %edi
  800dd1:	ff 75 e0             	pushl  -0x20(%ebp)
  800dd4:	50                   	push   %eax
  800dd5:	51                   	push   %ecx
  800dd6:	52                   	push   %edx
  800dd7:	89 da                	mov    %ebx,%edx
  800dd9:	89 f0                	mov    %esi,%eax
  800ddb:	e8 f1 fa ff ff       	call   8008d1 <printnum>
			break;
  800de0:	83 c4 20             	add    $0x20,%esp
  800de3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800de6:	e9 f5 fb ff ff       	jmp    8009e0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800deb:	83 ec 08             	sub    $0x8,%esp
  800dee:	53                   	push   %ebx
  800def:	52                   	push   %edx
  800df0:	ff d6                	call   *%esi
			break;
  800df2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800df5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800df8:	e9 e3 fb ff ff       	jmp    8009e0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800dfd:	83 ec 08             	sub    $0x8,%esp
  800e00:	53                   	push   %ebx
  800e01:	6a 25                	push   $0x25
  800e03:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800e05:	83 c4 10             	add    $0x10,%esp
  800e08:	eb 03                	jmp    800e0d <vprintfmt+0x453>
  800e0a:	83 ef 01             	sub    $0x1,%edi
  800e0d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800e11:	75 f7                	jne    800e0a <vprintfmt+0x450>
  800e13:	e9 c8 fb ff ff       	jmp    8009e0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800e18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1b:	5b                   	pop    %ebx
  800e1c:	5e                   	pop    %esi
  800e1d:	5f                   	pop    %edi
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    

00800e20 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	83 ec 18             	sub    $0x18,%esp
  800e26:	8b 45 08             	mov    0x8(%ebp),%eax
  800e29:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800e2c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e2f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800e33:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800e36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800e3d:	85 c0                	test   %eax,%eax
  800e3f:	74 26                	je     800e67 <vsnprintf+0x47>
  800e41:	85 d2                	test   %edx,%edx
  800e43:	7e 22                	jle    800e67 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800e45:	ff 75 14             	pushl  0x14(%ebp)
  800e48:	ff 75 10             	pushl  0x10(%ebp)
  800e4b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800e4e:	50                   	push   %eax
  800e4f:	68 80 09 80 00       	push   $0x800980
  800e54:	e8 61 fb ff ff       	call   8009ba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800e59:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e5c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800e5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e62:	83 c4 10             	add    $0x10,%esp
  800e65:	eb 05                	jmp    800e6c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800e67:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800e6c:	c9                   	leave  
  800e6d:	c3                   	ret    

00800e6e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800e74:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800e77:	50                   	push   %eax
  800e78:	ff 75 10             	pushl  0x10(%ebp)
  800e7b:	ff 75 0c             	pushl  0xc(%ebp)
  800e7e:	ff 75 08             	pushl  0x8(%ebp)
  800e81:	e8 9a ff ff ff       	call   800e20 <vsnprintf>
	va_end(ap);

	return rc;
}
  800e86:	c9                   	leave  
  800e87:	c3                   	ret    

00800e88 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800e8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e93:	eb 03                	jmp    800e98 <strlen+0x10>
		n++;
  800e95:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800e98:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800e9c:	75 f7                	jne    800e95 <strlen+0xd>
		n++;
	return n;
}
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ea9:	ba 00 00 00 00       	mov    $0x0,%edx
  800eae:	eb 03                	jmp    800eb3 <strnlen+0x13>
		n++;
  800eb0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800eb3:	39 c2                	cmp    %eax,%edx
  800eb5:	74 08                	je     800ebf <strnlen+0x1f>
  800eb7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800ebb:	75 f3                	jne    800eb0 <strnlen+0x10>
  800ebd:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    

00800ec1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	53                   	push   %ebx
  800ec5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ecb:	89 c2                	mov    %eax,%edx
  800ecd:	83 c2 01             	add    $0x1,%edx
  800ed0:	83 c1 01             	add    $0x1,%ecx
  800ed3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800ed7:	88 5a ff             	mov    %bl,-0x1(%edx)
  800eda:	84 db                	test   %bl,%bl
  800edc:	75 ef                	jne    800ecd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ede:	5b                   	pop    %ebx
  800edf:	5d                   	pop    %ebp
  800ee0:	c3                   	ret    

00800ee1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	53                   	push   %ebx
  800ee5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ee8:	53                   	push   %ebx
  800ee9:	e8 9a ff ff ff       	call   800e88 <strlen>
  800eee:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800ef1:	ff 75 0c             	pushl  0xc(%ebp)
  800ef4:	01 d8                	add    %ebx,%eax
  800ef6:	50                   	push   %eax
  800ef7:	e8 c5 ff ff ff       	call   800ec1 <strcpy>
	return dst;
}
  800efc:	89 d8                	mov    %ebx,%eax
  800efe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f01:	c9                   	leave  
  800f02:	c3                   	ret    

00800f03 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	56                   	push   %esi
  800f07:	53                   	push   %ebx
  800f08:	8b 75 08             	mov    0x8(%ebp),%esi
  800f0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0e:	89 f3                	mov    %esi,%ebx
  800f10:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f13:	89 f2                	mov    %esi,%edx
  800f15:	eb 0f                	jmp    800f26 <strncpy+0x23>
		*dst++ = *src;
  800f17:	83 c2 01             	add    $0x1,%edx
  800f1a:	0f b6 01             	movzbl (%ecx),%eax
  800f1d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800f20:	80 39 01             	cmpb   $0x1,(%ecx)
  800f23:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f26:	39 da                	cmp    %ebx,%edx
  800f28:	75 ed                	jne    800f17 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800f2a:	89 f0                	mov    %esi,%eax
  800f2c:	5b                   	pop    %ebx
  800f2d:	5e                   	pop    %esi
  800f2e:	5d                   	pop    %ebp
  800f2f:	c3                   	ret    

00800f30 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	56                   	push   %esi
  800f34:	53                   	push   %ebx
  800f35:	8b 75 08             	mov    0x8(%ebp),%esi
  800f38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3b:	8b 55 10             	mov    0x10(%ebp),%edx
  800f3e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800f40:	85 d2                	test   %edx,%edx
  800f42:	74 21                	je     800f65 <strlcpy+0x35>
  800f44:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800f48:	89 f2                	mov    %esi,%edx
  800f4a:	eb 09                	jmp    800f55 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800f4c:	83 c2 01             	add    $0x1,%edx
  800f4f:	83 c1 01             	add    $0x1,%ecx
  800f52:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800f55:	39 c2                	cmp    %eax,%edx
  800f57:	74 09                	je     800f62 <strlcpy+0x32>
  800f59:	0f b6 19             	movzbl (%ecx),%ebx
  800f5c:	84 db                	test   %bl,%bl
  800f5e:	75 ec                	jne    800f4c <strlcpy+0x1c>
  800f60:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800f62:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800f65:	29 f0                	sub    %esi,%eax
}
  800f67:	5b                   	pop    %ebx
  800f68:	5e                   	pop    %esi
  800f69:	5d                   	pop    %ebp
  800f6a:	c3                   	ret    

00800f6b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f71:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800f74:	eb 06                	jmp    800f7c <strcmp+0x11>
		p++, q++;
  800f76:	83 c1 01             	add    $0x1,%ecx
  800f79:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800f7c:	0f b6 01             	movzbl (%ecx),%eax
  800f7f:	84 c0                	test   %al,%al
  800f81:	74 04                	je     800f87 <strcmp+0x1c>
  800f83:	3a 02                	cmp    (%edx),%al
  800f85:	74 ef                	je     800f76 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800f87:	0f b6 c0             	movzbl %al,%eax
  800f8a:	0f b6 12             	movzbl (%edx),%edx
  800f8d:	29 d0                	sub    %edx,%eax
}
  800f8f:	5d                   	pop    %ebp
  800f90:	c3                   	ret    

00800f91 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800f91:	55                   	push   %ebp
  800f92:	89 e5                	mov    %esp,%ebp
  800f94:	53                   	push   %ebx
  800f95:	8b 45 08             	mov    0x8(%ebp),%eax
  800f98:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f9b:	89 c3                	mov    %eax,%ebx
  800f9d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800fa0:	eb 06                	jmp    800fa8 <strncmp+0x17>
		n--, p++, q++;
  800fa2:	83 c0 01             	add    $0x1,%eax
  800fa5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800fa8:	39 d8                	cmp    %ebx,%eax
  800faa:	74 15                	je     800fc1 <strncmp+0x30>
  800fac:	0f b6 08             	movzbl (%eax),%ecx
  800faf:	84 c9                	test   %cl,%cl
  800fb1:	74 04                	je     800fb7 <strncmp+0x26>
  800fb3:	3a 0a                	cmp    (%edx),%cl
  800fb5:	74 eb                	je     800fa2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800fb7:	0f b6 00             	movzbl (%eax),%eax
  800fba:	0f b6 12             	movzbl (%edx),%edx
  800fbd:	29 d0                	sub    %edx,%eax
  800fbf:	eb 05                	jmp    800fc6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800fc1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800fc6:	5b                   	pop    %ebx
  800fc7:	5d                   	pop    %ebp
  800fc8:	c3                   	ret    

00800fc9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fcf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800fd3:	eb 07                	jmp    800fdc <strchr+0x13>
		if (*s == c)
  800fd5:	38 ca                	cmp    %cl,%dl
  800fd7:	74 0f                	je     800fe8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800fd9:	83 c0 01             	add    $0x1,%eax
  800fdc:	0f b6 10             	movzbl (%eax),%edx
  800fdf:	84 d2                	test   %dl,%dl
  800fe1:	75 f2                	jne    800fd5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800fe3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fe8:	5d                   	pop    %ebp
  800fe9:	c3                   	ret    

00800fea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ff4:	eb 03                	jmp    800ff9 <strfind+0xf>
  800ff6:	83 c0 01             	add    $0x1,%eax
  800ff9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ffc:	38 ca                	cmp    %cl,%dl
  800ffe:	74 04                	je     801004 <strfind+0x1a>
  801000:	84 d2                	test   %dl,%dl
  801002:	75 f2                	jne    800ff6 <strfind+0xc>
			break;
	return (char *) s;
}
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    

00801006 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	57                   	push   %edi
  80100a:	56                   	push   %esi
  80100b:	53                   	push   %ebx
  80100c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80100f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801012:	85 c9                	test   %ecx,%ecx
  801014:	74 36                	je     80104c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801016:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80101c:	75 28                	jne    801046 <memset+0x40>
  80101e:	f6 c1 03             	test   $0x3,%cl
  801021:	75 23                	jne    801046 <memset+0x40>
		c &= 0xFF;
  801023:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801027:	89 d3                	mov    %edx,%ebx
  801029:	c1 e3 08             	shl    $0x8,%ebx
  80102c:	89 d6                	mov    %edx,%esi
  80102e:	c1 e6 18             	shl    $0x18,%esi
  801031:	89 d0                	mov    %edx,%eax
  801033:	c1 e0 10             	shl    $0x10,%eax
  801036:	09 f0                	or     %esi,%eax
  801038:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80103a:	89 d8                	mov    %ebx,%eax
  80103c:	09 d0                	or     %edx,%eax
  80103e:	c1 e9 02             	shr    $0x2,%ecx
  801041:	fc                   	cld    
  801042:	f3 ab                	rep stos %eax,%es:(%edi)
  801044:	eb 06                	jmp    80104c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801046:	8b 45 0c             	mov    0xc(%ebp),%eax
  801049:	fc                   	cld    
  80104a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80104c:	89 f8                	mov    %edi,%eax
  80104e:	5b                   	pop    %ebx
  80104f:	5e                   	pop    %esi
  801050:	5f                   	pop    %edi
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    

00801053 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	57                   	push   %edi
  801057:	56                   	push   %esi
  801058:	8b 45 08             	mov    0x8(%ebp),%eax
  80105b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80105e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801061:	39 c6                	cmp    %eax,%esi
  801063:	73 35                	jae    80109a <memmove+0x47>
  801065:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801068:	39 d0                	cmp    %edx,%eax
  80106a:	73 2e                	jae    80109a <memmove+0x47>
		s += n;
		d += n;
  80106c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80106f:	89 d6                	mov    %edx,%esi
  801071:	09 fe                	or     %edi,%esi
  801073:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801079:	75 13                	jne    80108e <memmove+0x3b>
  80107b:	f6 c1 03             	test   $0x3,%cl
  80107e:	75 0e                	jne    80108e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801080:	83 ef 04             	sub    $0x4,%edi
  801083:	8d 72 fc             	lea    -0x4(%edx),%esi
  801086:	c1 e9 02             	shr    $0x2,%ecx
  801089:	fd                   	std    
  80108a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80108c:	eb 09                	jmp    801097 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80108e:	83 ef 01             	sub    $0x1,%edi
  801091:	8d 72 ff             	lea    -0x1(%edx),%esi
  801094:	fd                   	std    
  801095:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801097:	fc                   	cld    
  801098:	eb 1d                	jmp    8010b7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80109a:	89 f2                	mov    %esi,%edx
  80109c:	09 c2                	or     %eax,%edx
  80109e:	f6 c2 03             	test   $0x3,%dl
  8010a1:	75 0f                	jne    8010b2 <memmove+0x5f>
  8010a3:	f6 c1 03             	test   $0x3,%cl
  8010a6:	75 0a                	jne    8010b2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8010a8:	c1 e9 02             	shr    $0x2,%ecx
  8010ab:	89 c7                	mov    %eax,%edi
  8010ad:	fc                   	cld    
  8010ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8010b0:	eb 05                	jmp    8010b7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8010b2:	89 c7                	mov    %eax,%edi
  8010b4:	fc                   	cld    
  8010b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8010b7:	5e                   	pop    %esi
  8010b8:	5f                   	pop    %edi
  8010b9:	5d                   	pop    %ebp
  8010ba:	c3                   	ret    

008010bb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8010be:	ff 75 10             	pushl  0x10(%ebp)
  8010c1:	ff 75 0c             	pushl  0xc(%ebp)
  8010c4:	ff 75 08             	pushl  0x8(%ebp)
  8010c7:	e8 87 ff ff ff       	call   801053 <memmove>
}
  8010cc:	c9                   	leave  
  8010cd:	c3                   	ret    

008010ce <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
  8010d1:	56                   	push   %esi
  8010d2:	53                   	push   %ebx
  8010d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d9:	89 c6                	mov    %eax,%esi
  8010db:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010de:	eb 1a                	jmp    8010fa <memcmp+0x2c>
		if (*s1 != *s2)
  8010e0:	0f b6 08             	movzbl (%eax),%ecx
  8010e3:	0f b6 1a             	movzbl (%edx),%ebx
  8010e6:	38 d9                	cmp    %bl,%cl
  8010e8:	74 0a                	je     8010f4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8010ea:	0f b6 c1             	movzbl %cl,%eax
  8010ed:	0f b6 db             	movzbl %bl,%ebx
  8010f0:	29 d8                	sub    %ebx,%eax
  8010f2:	eb 0f                	jmp    801103 <memcmp+0x35>
		s1++, s2++;
  8010f4:	83 c0 01             	add    $0x1,%eax
  8010f7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010fa:	39 f0                	cmp    %esi,%eax
  8010fc:	75 e2                	jne    8010e0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8010fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801103:	5b                   	pop    %ebx
  801104:	5e                   	pop    %esi
  801105:	5d                   	pop    %ebp
  801106:	c3                   	ret    

00801107 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	53                   	push   %ebx
  80110b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80110e:	89 c1                	mov    %eax,%ecx
  801110:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801113:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801117:	eb 0a                	jmp    801123 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801119:	0f b6 10             	movzbl (%eax),%edx
  80111c:	39 da                	cmp    %ebx,%edx
  80111e:	74 07                	je     801127 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801120:	83 c0 01             	add    $0x1,%eax
  801123:	39 c8                	cmp    %ecx,%eax
  801125:	72 f2                	jb     801119 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801127:	5b                   	pop    %ebx
  801128:	5d                   	pop    %ebp
  801129:	c3                   	ret    

0080112a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	57                   	push   %edi
  80112e:	56                   	push   %esi
  80112f:	53                   	push   %ebx
  801130:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801133:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801136:	eb 03                	jmp    80113b <strtol+0x11>
		s++;
  801138:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80113b:	0f b6 01             	movzbl (%ecx),%eax
  80113e:	3c 20                	cmp    $0x20,%al
  801140:	74 f6                	je     801138 <strtol+0xe>
  801142:	3c 09                	cmp    $0x9,%al
  801144:	74 f2                	je     801138 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801146:	3c 2b                	cmp    $0x2b,%al
  801148:	75 0a                	jne    801154 <strtol+0x2a>
		s++;
  80114a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80114d:	bf 00 00 00 00       	mov    $0x0,%edi
  801152:	eb 11                	jmp    801165 <strtol+0x3b>
  801154:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801159:	3c 2d                	cmp    $0x2d,%al
  80115b:	75 08                	jne    801165 <strtol+0x3b>
		s++, neg = 1;
  80115d:	83 c1 01             	add    $0x1,%ecx
  801160:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801165:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80116b:	75 15                	jne    801182 <strtol+0x58>
  80116d:	80 39 30             	cmpb   $0x30,(%ecx)
  801170:	75 10                	jne    801182 <strtol+0x58>
  801172:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801176:	75 7c                	jne    8011f4 <strtol+0xca>
		s += 2, base = 16;
  801178:	83 c1 02             	add    $0x2,%ecx
  80117b:	bb 10 00 00 00       	mov    $0x10,%ebx
  801180:	eb 16                	jmp    801198 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801182:	85 db                	test   %ebx,%ebx
  801184:	75 12                	jne    801198 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801186:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80118b:	80 39 30             	cmpb   $0x30,(%ecx)
  80118e:	75 08                	jne    801198 <strtol+0x6e>
		s++, base = 8;
  801190:	83 c1 01             	add    $0x1,%ecx
  801193:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801198:	b8 00 00 00 00       	mov    $0x0,%eax
  80119d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8011a0:	0f b6 11             	movzbl (%ecx),%edx
  8011a3:	8d 72 d0             	lea    -0x30(%edx),%esi
  8011a6:	89 f3                	mov    %esi,%ebx
  8011a8:	80 fb 09             	cmp    $0x9,%bl
  8011ab:	77 08                	ja     8011b5 <strtol+0x8b>
			dig = *s - '0';
  8011ad:	0f be d2             	movsbl %dl,%edx
  8011b0:	83 ea 30             	sub    $0x30,%edx
  8011b3:	eb 22                	jmp    8011d7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8011b5:	8d 72 9f             	lea    -0x61(%edx),%esi
  8011b8:	89 f3                	mov    %esi,%ebx
  8011ba:	80 fb 19             	cmp    $0x19,%bl
  8011bd:	77 08                	ja     8011c7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8011bf:	0f be d2             	movsbl %dl,%edx
  8011c2:	83 ea 57             	sub    $0x57,%edx
  8011c5:	eb 10                	jmp    8011d7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8011c7:	8d 72 bf             	lea    -0x41(%edx),%esi
  8011ca:	89 f3                	mov    %esi,%ebx
  8011cc:	80 fb 19             	cmp    $0x19,%bl
  8011cf:	77 16                	ja     8011e7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8011d1:	0f be d2             	movsbl %dl,%edx
  8011d4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8011d7:	3b 55 10             	cmp    0x10(%ebp),%edx
  8011da:	7d 0b                	jge    8011e7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8011dc:	83 c1 01             	add    $0x1,%ecx
  8011df:	0f af 45 10          	imul   0x10(%ebp),%eax
  8011e3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8011e5:	eb b9                	jmp    8011a0 <strtol+0x76>

	if (endptr)
  8011e7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011eb:	74 0d                	je     8011fa <strtol+0xd0>
		*endptr = (char *) s;
  8011ed:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011f0:	89 0e                	mov    %ecx,(%esi)
  8011f2:	eb 06                	jmp    8011fa <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8011f4:	85 db                	test   %ebx,%ebx
  8011f6:	74 98                	je     801190 <strtol+0x66>
  8011f8:	eb 9e                	jmp    801198 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8011fa:	89 c2                	mov    %eax,%edx
  8011fc:	f7 da                	neg    %edx
  8011fe:	85 ff                	test   %edi,%edi
  801200:	0f 45 c2             	cmovne %edx,%eax
}
  801203:	5b                   	pop    %ebx
  801204:	5e                   	pop    %esi
  801205:	5f                   	pop    %edi
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	57                   	push   %edi
  80120c:	56                   	push   %esi
  80120d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80120e:	b8 00 00 00 00       	mov    $0x0,%eax
  801213:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801216:	8b 55 08             	mov    0x8(%ebp),%edx
  801219:	89 c3                	mov    %eax,%ebx
  80121b:	89 c7                	mov    %eax,%edi
  80121d:	89 c6                	mov    %eax,%esi
  80121f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801221:	5b                   	pop    %ebx
  801222:	5e                   	pop    %esi
  801223:	5f                   	pop    %edi
  801224:	5d                   	pop    %ebp
  801225:	c3                   	ret    

00801226 <sys_cgetc>:

int
sys_cgetc(void)
{
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	57                   	push   %edi
  80122a:	56                   	push   %esi
  80122b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80122c:	ba 00 00 00 00       	mov    $0x0,%edx
  801231:	b8 01 00 00 00       	mov    $0x1,%eax
  801236:	89 d1                	mov    %edx,%ecx
  801238:	89 d3                	mov    %edx,%ebx
  80123a:	89 d7                	mov    %edx,%edi
  80123c:	89 d6                	mov    %edx,%esi
  80123e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801240:	5b                   	pop    %ebx
  801241:	5e                   	pop    %esi
  801242:	5f                   	pop    %edi
  801243:	5d                   	pop    %ebp
  801244:	c3                   	ret    

00801245 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	57                   	push   %edi
  801249:	56                   	push   %esi
  80124a:	53                   	push   %ebx
  80124b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80124e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801253:	b8 03 00 00 00       	mov    $0x3,%eax
  801258:	8b 55 08             	mov    0x8(%ebp),%edx
  80125b:	89 cb                	mov    %ecx,%ebx
  80125d:	89 cf                	mov    %ecx,%edi
  80125f:	89 ce                	mov    %ecx,%esi
  801261:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801263:	85 c0                	test   %eax,%eax
  801265:	7e 17                	jle    80127e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801267:	83 ec 0c             	sub    $0xc,%esp
  80126a:	50                   	push   %eax
  80126b:	6a 03                	push   $0x3
  80126d:	68 df 31 80 00       	push   $0x8031df
  801272:	6a 23                	push   $0x23
  801274:	68 fc 31 80 00       	push   $0x8031fc
  801279:	e8 66 f5 ff ff       	call   8007e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80127e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801281:	5b                   	pop    %ebx
  801282:	5e                   	pop    %esi
  801283:	5f                   	pop    %edi
  801284:	5d                   	pop    %ebp
  801285:	c3                   	ret    

00801286 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801286:	55                   	push   %ebp
  801287:	89 e5                	mov    %esp,%ebp
  801289:	57                   	push   %edi
  80128a:	56                   	push   %esi
  80128b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80128c:	ba 00 00 00 00       	mov    $0x0,%edx
  801291:	b8 02 00 00 00       	mov    $0x2,%eax
  801296:	89 d1                	mov    %edx,%ecx
  801298:	89 d3                	mov    %edx,%ebx
  80129a:	89 d7                	mov    %edx,%edi
  80129c:	89 d6                	mov    %edx,%esi
  80129e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8012a0:	5b                   	pop    %ebx
  8012a1:	5e                   	pop    %esi
  8012a2:	5f                   	pop    %edi
  8012a3:	5d                   	pop    %ebp
  8012a4:	c3                   	ret    

008012a5 <sys_yield>:

void
sys_yield(void)
{
  8012a5:	55                   	push   %ebp
  8012a6:	89 e5                	mov    %esp,%ebp
  8012a8:	57                   	push   %edi
  8012a9:	56                   	push   %esi
  8012aa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b0:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012b5:	89 d1                	mov    %edx,%ecx
  8012b7:	89 d3                	mov    %edx,%ebx
  8012b9:	89 d7                	mov    %edx,%edi
  8012bb:	89 d6                	mov    %edx,%esi
  8012bd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8012bf:	5b                   	pop    %ebx
  8012c0:	5e                   	pop    %esi
  8012c1:	5f                   	pop    %edi
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    

008012c4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	57                   	push   %edi
  8012c8:	56                   	push   %esi
  8012c9:	53                   	push   %ebx
  8012ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012cd:	be 00 00 00 00       	mov    $0x0,%esi
  8012d2:	b8 04 00 00 00       	mov    $0x4,%eax
  8012d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012da:	8b 55 08             	mov    0x8(%ebp),%edx
  8012dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012e0:	89 f7                	mov    %esi,%edi
  8012e2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	7e 17                	jle    8012ff <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012e8:	83 ec 0c             	sub    $0xc,%esp
  8012eb:	50                   	push   %eax
  8012ec:	6a 04                	push   $0x4
  8012ee:	68 df 31 80 00       	push   $0x8031df
  8012f3:	6a 23                	push   $0x23
  8012f5:	68 fc 31 80 00       	push   $0x8031fc
  8012fa:	e8 e5 f4 ff ff       	call   8007e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8012ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801302:	5b                   	pop    %ebx
  801303:	5e                   	pop    %esi
  801304:	5f                   	pop    %edi
  801305:	5d                   	pop    %ebp
  801306:	c3                   	ret    

00801307 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801307:	55                   	push   %ebp
  801308:	89 e5                	mov    %esp,%ebp
  80130a:	57                   	push   %edi
  80130b:	56                   	push   %esi
  80130c:	53                   	push   %ebx
  80130d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801310:	b8 05 00 00 00       	mov    $0x5,%eax
  801315:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801318:	8b 55 08             	mov    0x8(%ebp),%edx
  80131b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80131e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801321:	8b 75 18             	mov    0x18(%ebp),%esi
  801324:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801326:	85 c0                	test   %eax,%eax
  801328:	7e 17                	jle    801341 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80132a:	83 ec 0c             	sub    $0xc,%esp
  80132d:	50                   	push   %eax
  80132e:	6a 05                	push   $0x5
  801330:	68 df 31 80 00       	push   $0x8031df
  801335:	6a 23                	push   $0x23
  801337:	68 fc 31 80 00       	push   $0x8031fc
  80133c:	e8 a3 f4 ff ff       	call   8007e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801341:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801344:	5b                   	pop    %ebx
  801345:	5e                   	pop    %esi
  801346:	5f                   	pop    %edi
  801347:	5d                   	pop    %ebp
  801348:	c3                   	ret    

00801349 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	57                   	push   %edi
  80134d:	56                   	push   %esi
  80134e:	53                   	push   %ebx
  80134f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801352:	bb 00 00 00 00       	mov    $0x0,%ebx
  801357:	b8 06 00 00 00       	mov    $0x6,%eax
  80135c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80135f:	8b 55 08             	mov    0x8(%ebp),%edx
  801362:	89 df                	mov    %ebx,%edi
  801364:	89 de                	mov    %ebx,%esi
  801366:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801368:	85 c0                	test   %eax,%eax
  80136a:	7e 17                	jle    801383 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80136c:	83 ec 0c             	sub    $0xc,%esp
  80136f:	50                   	push   %eax
  801370:	6a 06                	push   $0x6
  801372:	68 df 31 80 00       	push   $0x8031df
  801377:	6a 23                	push   $0x23
  801379:	68 fc 31 80 00       	push   $0x8031fc
  80137e:	e8 61 f4 ff ff       	call   8007e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801383:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801386:	5b                   	pop    %ebx
  801387:	5e                   	pop    %esi
  801388:	5f                   	pop    %edi
  801389:	5d                   	pop    %ebp
  80138a:	c3                   	ret    

0080138b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80138b:	55                   	push   %ebp
  80138c:	89 e5                	mov    %esp,%ebp
  80138e:	57                   	push   %edi
  80138f:	56                   	push   %esi
  801390:	53                   	push   %ebx
  801391:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801394:	bb 00 00 00 00       	mov    $0x0,%ebx
  801399:	b8 08 00 00 00       	mov    $0x8,%eax
  80139e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8013a4:	89 df                	mov    %ebx,%edi
  8013a6:	89 de                	mov    %ebx,%esi
  8013a8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8013aa:	85 c0                	test   %eax,%eax
  8013ac:	7e 17                	jle    8013c5 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013ae:	83 ec 0c             	sub    $0xc,%esp
  8013b1:	50                   	push   %eax
  8013b2:	6a 08                	push   $0x8
  8013b4:	68 df 31 80 00       	push   $0x8031df
  8013b9:	6a 23                	push   $0x23
  8013bb:	68 fc 31 80 00       	push   $0x8031fc
  8013c0:	e8 1f f4 ff ff       	call   8007e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8013c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c8:	5b                   	pop    %ebx
  8013c9:	5e                   	pop    %esi
  8013ca:	5f                   	pop    %edi
  8013cb:	5d                   	pop    %ebp
  8013cc:	c3                   	ret    

008013cd <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	57                   	push   %edi
  8013d1:	56                   	push   %esi
  8013d2:	53                   	push   %ebx
  8013d3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013db:	b8 09 00 00 00       	mov    $0x9,%eax
  8013e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8013e6:	89 df                	mov    %ebx,%edi
  8013e8:	89 de                	mov    %ebx,%esi
  8013ea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8013ec:	85 c0                	test   %eax,%eax
  8013ee:	7e 17                	jle    801407 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013f0:	83 ec 0c             	sub    $0xc,%esp
  8013f3:	50                   	push   %eax
  8013f4:	6a 09                	push   $0x9
  8013f6:	68 df 31 80 00       	push   $0x8031df
  8013fb:	6a 23                	push   $0x23
  8013fd:	68 fc 31 80 00       	push   $0x8031fc
  801402:	e8 dd f3 ff ff       	call   8007e4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801407:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80140a:	5b                   	pop    %ebx
  80140b:	5e                   	pop    %esi
  80140c:	5f                   	pop    %edi
  80140d:	5d                   	pop    %ebp
  80140e:	c3                   	ret    

0080140f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80140f:	55                   	push   %ebp
  801410:	89 e5                	mov    %esp,%ebp
  801412:	57                   	push   %edi
  801413:	56                   	push   %esi
  801414:	53                   	push   %ebx
  801415:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801418:	bb 00 00 00 00       	mov    $0x0,%ebx
  80141d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801422:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801425:	8b 55 08             	mov    0x8(%ebp),%edx
  801428:	89 df                	mov    %ebx,%edi
  80142a:	89 de                	mov    %ebx,%esi
  80142c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80142e:	85 c0                	test   %eax,%eax
  801430:	7e 17                	jle    801449 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801432:	83 ec 0c             	sub    $0xc,%esp
  801435:	50                   	push   %eax
  801436:	6a 0a                	push   $0xa
  801438:	68 df 31 80 00       	push   $0x8031df
  80143d:	6a 23                	push   $0x23
  80143f:	68 fc 31 80 00       	push   $0x8031fc
  801444:	e8 9b f3 ff ff       	call   8007e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801449:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80144c:	5b                   	pop    %ebx
  80144d:	5e                   	pop    %esi
  80144e:	5f                   	pop    %edi
  80144f:	5d                   	pop    %ebp
  801450:	c3                   	ret    

00801451 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	57                   	push   %edi
  801455:	56                   	push   %esi
  801456:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801457:	be 00 00 00 00       	mov    $0x0,%esi
  80145c:	b8 0c 00 00 00       	mov    $0xc,%eax
  801461:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801464:	8b 55 08             	mov    0x8(%ebp),%edx
  801467:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80146a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80146d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80146f:	5b                   	pop    %ebx
  801470:	5e                   	pop    %esi
  801471:	5f                   	pop    %edi
  801472:	5d                   	pop    %ebp
  801473:	c3                   	ret    

00801474 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	57                   	push   %edi
  801478:	56                   	push   %esi
  801479:	53                   	push   %ebx
  80147a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80147d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801482:	b8 0d 00 00 00       	mov    $0xd,%eax
  801487:	8b 55 08             	mov    0x8(%ebp),%edx
  80148a:	89 cb                	mov    %ecx,%ebx
  80148c:	89 cf                	mov    %ecx,%edi
  80148e:	89 ce                	mov    %ecx,%esi
  801490:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801492:	85 c0                	test   %eax,%eax
  801494:	7e 17                	jle    8014ad <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801496:	83 ec 0c             	sub    $0xc,%esp
  801499:	50                   	push   %eax
  80149a:	6a 0d                	push   $0xd
  80149c:	68 df 31 80 00       	push   $0x8031df
  8014a1:	6a 23                	push   $0x23
  8014a3:	68 fc 31 80 00       	push   $0x8031fc
  8014a8:	e8 37 f3 ff ff       	call   8007e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8014ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b0:	5b                   	pop    %ebx
  8014b1:	5e                   	pop    %esi
  8014b2:	5f                   	pop    %edi
  8014b3:	5d                   	pop    %ebp
  8014b4:	c3                   	ret    

008014b5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	57                   	push   %edi
  8014b9:	56                   	push   %esi
  8014ba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c0:	b8 0e 00 00 00       	mov    $0xe,%eax
  8014c5:	89 d1                	mov    %edx,%ecx
  8014c7:	89 d3                	mov    %edx,%ebx
  8014c9:	89 d7                	mov    %edx,%edi
  8014cb:	89 d6                	mov    %edx,%esi
  8014cd:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8014cf:	5b                   	pop    %ebx
  8014d0:	5e                   	pop    %esi
  8014d1:	5f                   	pop    %edi
  8014d2:	5d                   	pop    %ebp
  8014d3:	c3                   	ret    

008014d4 <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  8014d4:	55                   	push   %ebp
  8014d5:	89 e5                	mov    %esp,%ebp
  8014d7:	57                   	push   %edi
  8014d8:	56                   	push   %esi
  8014d9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014df:	b8 10 00 00 00       	mov    $0x10,%eax
  8014e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8014e7:	89 cb                	mov    %ecx,%ebx
  8014e9:	89 cf                	mov    %ecx,%edi
  8014eb:	89 ce                	mov    %ecx,%esi
  8014ed:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  8014ef:	5b                   	pop    %ebx
  8014f0:	5e                   	pop    %esi
  8014f1:	5f                   	pop    %edi
  8014f2:	5d                   	pop    %ebp
  8014f3:	c3                   	ret    

008014f4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fa:	05 00 00 00 30       	add    $0x30000000,%eax
  8014ff:	c1 e8 0c             	shr    $0xc,%eax
}
  801502:	5d                   	pop    %ebp
  801503:	c3                   	ret    

00801504 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801507:	8b 45 08             	mov    0x8(%ebp),%eax
  80150a:	05 00 00 00 30       	add    $0x30000000,%eax
  80150f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801514:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801519:	5d                   	pop    %ebp
  80151a:	c3                   	ret    

0080151b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80151b:	55                   	push   %ebp
  80151c:	89 e5                	mov    %esp,%ebp
  80151e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801521:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801526:	89 c2                	mov    %eax,%edx
  801528:	c1 ea 16             	shr    $0x16,%edx
  80152b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801532:	f6 c2 01             	test   $0x1,%dl
  801535:	74 11                	je     801548 <fd_alloc+0x2d>
  801537:	89 c2                	mov    %eax,%edx
  801539:	c1 ea 0c             	shr    $0xc,%edx
  80153c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801543:	f6 c2 01             	test   $0x1,%dl
  801546:	75 09                	jne    801551 <fd_alloc+0x36>
			*fd_store = fd;
  801548:	89 01                	mov    %eax,(%ecx)
			return 0;
  80154a:	b8 00 00 00 00       	mov    $0x0,%eax
  80154f:	eb 17                	jmp    801568 <fd_alloc+0x4d>
  801551:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801556:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80155b:	75 c9                	jne    801526 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80155d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801563:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801568:	5d                   	pop    %ebp
  801569:	c3                   	ret    

0080156a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801570:	83 f8 1f             	cmp    $0x1f,%eax
  801573:	77 36                	ja     8015ab <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801575:	c1 e0 0c             	shl    $0xc,%eax
  801578:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80157d:	89 c2                	mov    %eax,%edx
  80157f:	c1 ea 16             	shr    $0x16,%edx
  801582:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801589:	f6 c2 01             	test   $0x1,%dl
  80158c:	74 24                	je     8015b2 <fd_lookup+0x48>
  80158e:	89 c2                	mov    %eax,%edx
  801590:	c1 ea 0c             	shr    $0xc,%edx
  801593:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80159a:	f6 c2 01             	test   $0x1,%dl
  80159d:	74 1a                	je     8015b9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80159f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015a2:	89 02                	mov    %eax,(%edx)
	return 0;
  8015a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a9:	eb 13                	jmp    8015be <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015b0:	eb 0c                	jmp    8015be <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015b7:	eb 05                	jmp    8015be <fd_lookup+0x54>
  8015b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015be:	5d                   	pop    %ebp
  8015bf:	c3                   	ret    

008015c0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	83 ec 08             	sub    $0x8,%esp
  8015c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015c9:	ba 88 32 80 00       	mov    $0x803288,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8015ce:	eb 13                	jmp    8015e3 <dev_lookup+0x23>
  8015d0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8015d3:	39 08                	cmp    %ecx,(%eax)
  8015d5:	75 0c                	jne    8015e3 <dev_lookup+0x23>
			*dev = devtab[i];
  8015d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015da:	89 01                	mov    %eax,(%ecx)
			return 0;
  8015dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e1:	eb 2e                	jmp    801611 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015e3:	8b 02                	mov    (%edx),%eax
  8015e5:	85 c0                	test   %eax,%eax
  8015e7:	75 e7                	jne    8015d0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015e9:	a1 1c 50 80 00       	mov    0x80501c,%eax
  8015ee:	8b 40 48             	mov    0x48(%eax),%eax
  8015f1:	83 ec 04             	sub    $0x4,%esp
  8015f4:	51                   	push   %ecx
  8015f5:	50                   	push   %eax
  8015f6:	68 0c 32 80 00       	push   $0x80320c
  8015fb:	e8 bd f2 ff ff       	call   8008bd <cprintf>
	*dev = 0;
  801600:	8b 45 0c             	mov    0xc(%ebp),%eax
  801603:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801611:	c9                   	leave  
  801612:	c3                   	ret    

00801613 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	56                   	push   %esi
  801617:	53                   	push   %ebx
  801618:	83 ec 10             	sub    $0x10,%esp
  80161b:	8b 75 08             	mov    0x8(%ebp),%esi
  80161e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801621:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801624:	50                   	push   %eax
  801625:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80162b:	c1 e8 0c             	shr    $0xc,%eax
  80162e:	50                   	push   %eax
  80162f:	e8 36 ff ff ff       	call   80156a <fd_lookup>
  801634:	83 c4 08             	add    $0x8,%esp
  801637:	85 c0                	test   %eax,%eax
  801639:	78 05                	js     801640 <fd_close+0x2d>
	    || fd != fd2)
  80163b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80163e:	74 0c                	je     80164c <fd_close+0x39>
		return (must_exist ? r : 0);
  801640:	84 db                	test   %bl,%bl
  801642:	ba 00 00 00 00       	mov    $0x0,%edx
  801647:	0f 44 c2             	cmove  %edx,%eax
  80164a:	eb 41                	jmp    80168d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80164c:	83 ec 08             	sub    $0x8,%esp
  80164f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801652:	50                   	push   %eax
  801653:	ff 36                	pushl  (%esi)
  801655:	e8 66 ff ff ff       	call   8015c0 <dev_lookup>
  80165a:	89 c3                	mov    %eax,%ebx
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	85 c0                	test   %eax,%eax
  801661:	78 1a                	js     80167d <fd_close+0x6a>
		if (dev->dev_close)
  801663:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801666:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801669:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80166e:	85 c0                	test   %eax,%eax
  801670:	74 0b                	je     80167d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801672:	83 ec 0c             	sub    $0xc,%esp
  801675:	56                   	push   %esi
  801676:	ff d0                	call   *%eax
  801678:	89 c3                	mov    %eax,%ebx
  80167a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80167d:	83 ec 08             	sub    $0x8,%esp
  801680:	56                   	push   %esi
  801681:	6a 00                	push   $0x0
  801683:	e8 c1 fc ff ff       	call   801349 <sys_page_unmap>
	return r;
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	89 d8                	mov    %ebx,%eax
}
  80168d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801690:	5b                   	pop    %ebx
  801691:	5e                   	pop    %esi
  801692:	5d                   	pop    %ebp
  801693:	c3                   	ret    

00801694 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80169a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80169d:	50                   	push   %eax
  80169e:	ff 75 08             	pushl  0x8(%ebp)
  8016a1:	e8 c4 fe ff ff       	call   80156a <fd_lookup>
  8016a6:	83 c4 08             	add    $0x8,%esp
  8016a9:	85 c0                	test   %eax,%eax
  8016ab:	78 10                	js     8016bd <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8016ad:	83 ec 08             	sub    $0x8,%esp
  8016b0:	6a 01                	push   $0x1
  8016b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b5:	e8 59 ff ff ff       	call   801613 <fd_close>
  8016ba:	83 c4 10             	add    $0x10,%esp
}
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    

008016bf <close_all>:

void
close_all(void)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	53                   	push   %ebx
  8016c3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016c6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016cb:	83 ec 0c             	sub    $0xc,%esp
  8016ce:	53                   	push   %ebx
  8016cf:	e8 c0 ff ff ff       	call   801694 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016d4:	83 c3 01             	add    $0x1,%ebx
  8016d7:	83 c4 10             	add    $0x10,%esp
  8016da:	83 fb 20             	cmp    $0x20,%ebx
  8016dd:	75 ec                	jne    8016cb <close_all+0xc>
		close(i);
}
  8016df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e2:	c9                   	leave  
  8016e3:	c3                   	ret    

008016e4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	57                   	push   %edi
  8016e8:	56                   	push   %esi
  8016e9:	53                   	push   %ebx
  8016ea:	83 ec 2c             	sub    $0x2c,%esp
  8016ed:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016f3:	50                   	push   %eax
  8016f4:	ff 75 08             	pushl  0x8(%ebp)
  8016f7:	e8 6e fe ff ff       	call   80156a <fd_lookup>
  8016fc:	83 c4 08             	add    $0x8,%esp
  8016ff:	85 c0                	test   %eax,%eax
  801701:	0f 88 c1 00 00 00    	js     8017c8 <dup+0xe4>
		return r;
	close(newfdnum);
  801707:	83 ec 0c             	sub    $0xc,%esp
  80170a:	56                   	push   %esi
  80170b:	e8 84 ff ff ff       	call   801694 <close>

	newfd = INDEX2FD(newfdnum);
  801710:	89 f3                	mov    %esi,%ebx
  801712:	c1 e3 0c             	shl    $0xc,%ebx
  801715:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80171b:	83 c4 04             	add    $0x4,%esp
  80171e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801721:	e8 de fd ff ff       	call   801504 <fd2data>
  801726:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801728:	89 1c 24             	mov    %ebx,(%esp)
  80172b:	e8 d4 fd ff ff       	call   801504 <fd2data>
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801736:	89 f8                	mov    %edi,%eax
  801738:	c1 e8 16             	shr    $0x16,%eax
  80173b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801742:	a8 01                	test   $0x1,%al
  801744:	74 37                	je     80177d <dup+0x99>
  801746:	89 f8                	mov    %edi,%eax
  801748:	c1 e8 0c             	shr    $0xc,%eax
  80174b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801752:	f6 c2 01             	test   $0x1,%dl
  801755:	74 26                	je     80177d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801757:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80175e:	83 ec 0c             	sub    $0xc,%esp
  801761:	25 07 0e 00 00       	and    $0xe07,%eax
  801766:	50                   	push   %eax
  801767:	ff 75 d4             	pushl  -0x2c(%ebp)
  80176a:	6a 00                	push   $0x0
  80176c:	57                   	push   %edi
  80176d:	6a 00                	push   $0x0
  80176f:	e8 93 fb ff ff       	call   801307 <sys_page_map>
  801774:	89 c7                	mov    %eax,%edi
  801776:	83 c4 20             	add    $0x20,%esp
  801779:	85 c0                	test   %eax,%eax
  80177b:	78 2e                	js     8017ab <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80177d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801780:	89 d0                	mov    %edx,%eax
  801782:	c1 e8 0c             	shr    $0xc,%eax
  801785:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80178c:	83 ec 0c             	sub    $0xc,%esp
  80178f:	25 07 0e 00 00       	and    $0xe07,%eax
  801794:	50                   	push   %eax
  801795:	53                   	push   %ebx
  801796:	6a 00                	push   $0x0
  801798:	52                   	push   %edx
  801799:	6a 00                	push   $0x0
  80179b:	e8 67 fb ff ff       	call   801307 <sys_page_map>
  8017a0:	89 c7                	mov    %eax,%edi
  8017a2:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8017a5:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017a7:	85 ff                	test   %edi,%edi
  8017a9:	79 1d                	jns    8017c8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017ab:	83 ec 08             	sub    $0x8,%esp
  8017ae:	53                   	push   %ebx
  8017af:	6a 00                	push   $0x0
  8017b1:	e8 93 fb ff ff       	call   801349 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017b6:	83 c4 08             	add    $0x8,%esp
  8017b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8017bc:	6a 00                	push   $0x0
  8017be:	e8 86 fb ff ff       	call   801349 <sys_page_unmap>
	return r;
  8017c3:	83 c4 10             	add    $0x10,%esp
  8017c6:	89 f8                	mov    %edi,%eax
}
  8017c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017cb:	5b                   	pop    %ebx
  8017cc:	5e                   	pop    %esi
  8017cd:	5f                   	pop    %edi
  8017ce:	5d                   	pop    %ebp
  8017cf:	c3                   	ret    

008017d0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	53                   	push   %ebx
  8017d4:	83 ec 14             	sub    $0x14,%esp
  8017d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017dd:	50                   	push   %eax
  8017de:	53                   	push   %ebx
  8017df:	e8 86 fd ff ff       	call   80156a <fd_lookup>
  8017e4:	83 c4 08             	add    $0x8,%esp
  8017e7:	89 c2                	mov    %eax,%edx
  8017e9:	85 c0                	test   %eax,%eax
  8017eb:	78 6d                	js     80185a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ed:	83 ec 08             	sub    $0x8,%esp
  8017f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f3:	50                   	push   %eax
  8017f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f7:	ff 30                	pushl  (%eax)
  8017f9:	e8 c2 fd ff ff       	call   8015c0 <dev_lookup>
  8017fe:	83 c4 10             	add    $0x10,%esp
  801801:	85 c0                	test   %eax,%eax
  801803:	78 4c                	js     801851 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801805:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801808:	8b 42 08             	mov    0x8(%edx),%eax
  80180b:	83 e0 03             	and    $0x3,%eax
  80180e:	83 f8 01             	cmp    $0x1,%eax
  801811:	75 21                	jne    801834 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801813:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801818:	8b 40 48             	mov    0x48(%eax),%eax
  80181b:	83 ec 04             	sub    $0x4,%esp
  80181e:	53                   	push   %ebx
  80181f:	50                   	push   %eax
  801820:	68 4d 32 80 00       	push   $0x80324d
  801825:	e8 93 f0 ff ff       	call   8008bd <cprintf>
		return -E_INVAL;
  80182a:	83 c4 10             	add    $0x10,%esp
  80182d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801832:	eb 26                	jmp    80185a <read+0x8a>
	}
	if (!dev->dev_read)
  801834:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801837:	8b 40 08             	mov    0x8(%eax),%eax
  80183a:	85 c0                	test   %eax,%eax
  80183c:	74 17                	je     801855 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80183e:	83 ec 04             	sub    $0x4,%esp
  801841:	ff 75 10             	pushl  0x10(%ebp)
  801844:	ff 75 0c             	pushl  0xc(%ebp)
  801847:	52                   	push   %edx
  801848:	ff d0                	call   *%eax
  80184a:	89 c2                	mov    %eax,%edx
  80184c:	83 c4 10             	add    $0x10,%esp
  80184f:	eb 09                	jmp    80185a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801851:	89 c2                	mov    %eax,%edx
  801853:	eb 05                	jmp    80185a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801855:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80185a:	89 d0                	mov    %edx,%eax
  80185c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185f:	c9                   	leave  
  801860:	c3                   	ret    

00801861 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	57                   	push   %edi
  801865:	56                   	push   %esi
  801866:	53                   	push   %ebx
  801867:	83 ec 0c             	sub    $0xc,%esp
  80186a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80186d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801870:	bb 00 00 00 00       	mov    $0x0,%ebx
  801875:	eb 21                	jmp    801898 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801877:	83 ec 04             	sub    $0x4,%esp
  80187a:	89 f0                	mov    %esi,%eax
  80187c:	29 d8                	sub    %ebx,%eax
  80187e:	50                   	push   %eax
  80187f:	89 d8                	mov    %ebx,%eax
  801881:	03 45 0c             	add    0xc(%ebp),%eax
  801884:	50                   	push   %eax
  801885:	57                   	push   %edi
  801886:	e8 45 ff ff ff       	call   8017d0 <read>
		if (m < 0)
  80188b:	83 c4 10             	add    $0x10,%esp
  80188e:	85 c0                	test   %eax,%eax
  801890:	78 10                	js     8018a2 <readn+0x41>
			return m;
		if (m == 0)
  801892:	85 c0                	test   %eax,%eax
  801894:	74 0a                	je     8018a0 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801896:	01 c3                	add    %eax,%ebx
  801898:	39 f3                	cmp    %esi,%ebx
  80189a:	72 db                	jb     801877 <readn+0x16>
  80189c:	89 d8                	mov    %ebx,%eax
  80189e:	eb 02                	jmp    8018a2 <readn+0x41>
  8018a0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8018a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018a5:	5b                   	pop    %ebx
  8018a6:	5e                   	pop    %esi
  8018a7:	5f                   	pop    %edi
  8018a8:	5d                   	pop    %ebp
  8018a9:	c3                   	ret    

008018aa <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	53                   	push   %ebx
  8018ae:	83 ec 14             	sub    $0x14,%esp
  8018b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b7:	50                   	push   %eax
  8018b8:	53                   	push   %ebx
  8018b9:	e8 ac fc ff ff       	call   80156a <fd_lookup>
  8018be:	83 c4 08             	add    $0x8,%esp
  8018c1:	89 c2                	mov    %eax,%edx
  8018c3:	85 c0                	test   %eax,%eax
  8018c5:	78 68                	js     80192f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c7:	83 ec 08             	sub    $0x8,%esp
  8018ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018cd:	50                   	push   %eax
  8018ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d1:	ff 30                	pushl  (%eax)
  8018d3:	e8 e8 fc ff ff       	call   8015c0 <dev_lookup>
  8018d8:	83 c4 10             	add    $0x10,%esp
  8018db:	85 c0                	test   %eax,%eax
  8018dd:	78 47                	js     801926 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018e6:	75 21                	jne    801909 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018e8:	a1 1c 50 80 00       	mov    0x80501c,%eax
  8018ed:	8b 40 48             	mov    0x48(%eax),%eax
  8018f0:	83 ec 04             	sub    $0x4,%esp
  8018f3:	53                   	push   %ebx
  8018f4:	50                   	push   %eax
  8018f5:	68 69 32 80 00       	push   $0x803269
  8018fa:	e8 be ef ff ff       	call   8008bd <cprintf>
		return -E_INVAL;
  8018ff:	83 c4 10             	add    $0x10,%esp
  801902:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801907:	eb 26                	jmp    80192f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801909:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80190c:	8b 52 0c             	mov    0xc(%edx),%edx
  80190f:	85 d2                	test   %edx,%edx
  801911:	74 17                	je     80192a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801913:	83 ec 04             	sub    $0x4,%esp
  801916:	ff 75 10             	pushl  0x10(%ebp)
  801919:	ff 75 0c             	pushl  0xc(%ebp)
  80191c:	50                   	push   %eax
  80191d:	ff d2                	call   *%edx
  80191f:	89 c2                	mov    %eax,%edx
  801921:	83 c4 10             	add    $0x10,%esp
  801924:	eb 09                	jmp    80192f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801926:	89 c2                	mov    %eax,%edx
  801928:	eb 05                	jmp    80192f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80192a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80192f:	89 d0                	mov    %edx,%eax
  801931:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801934:	c9                   	leave  
  801935:	c3                   	ret    

00801936 <seek>:

int
seek(int fdnum, off_t offset)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80193c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80193f:	50                   	push   %eax
  801940:	ff 75 08             	pushl  0x8(%ebp)
  801943:	e8 22 fc ff ff       	call   80156a <fd_lookup>
  801948:	83 c4 08             	add    $0x8,%esp
  80194b:	85 c0                	test   %eax,%eax
  80194d:	78 0e                	js     80195d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80194f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801952:	8b 55 0c             	mov    0xc(%ebp),%edx
  801955:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801958:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80195d:	c9                   	leave  
  80195e:	c3                   	ret    

0080195f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
  801962:	53                   	push   %ebx
  801963:	83 ec 14             	sub    $0x14,%esp
  801966:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801969:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80196c:	50                   	push   %eax
  80196d:	53                   	push   %ebx
  80196e:	e8 f7 fb ff ff       	call   80156a <fd_lookup>
  801973:	83 c4 08             	add    $0x8,%esp
  801976:	89 c2                	mov    %eax,%edx
  801978:	85 c0                	test   %eax,%eax
  80197a:	78 65                	js     8019e1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80197c:	83 ec 08             	sub    $0x8,%esp
  80197f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801982:	50                   	push   %eax
  801983:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801986:	ff 30                	pushl  (%eax)
  801988:	e8 33 fc ff ff       	call   8015c0 <dev_lookup>
  80198d:	83 c4 10             	add    $0x10,%esp
  801990:	85 c0                	test   %eax,%eax
  801992:	78 44                	js     8019d8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801994:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801997:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80199b:	75 21                	jne    8019be <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80199d:	a1 1c 50 80 00       	mov    0x80501c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019a2:	8b 40 48             	mov    0x48(%eax),%eax
  8019a5:	83 ec 04             	sub    $0x4,%esp
  8019a8:	53                   	push   %ebx
  8019a9:	50                   	push   %eax
  8019aa:	68 2c 32 80 00       	push   $0x80322c
  8019af:	e8 09 ef ff ff       	call   8008bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019b4:	83 c4 10             	add    $0x10,%esp
  8019b7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8019bc:	eb 23                	jmp    8019e1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8019be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019c1:	8b 52 18             	mov    0x18(%edx),%edx
  8019c4:	85 d2                	test   %edx,%edx
  8019c6:	74 14                	je     8019dc <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019c8:	83 ec 08             	sub    $0x8,%esp
  8019cb:	ff 75 0c             	pushl  0xc(%ebp)
  8019ce:	50                   	push   %eax
  8019cf:	ff d2                	call   *%edx
  8019d1:	89 c2                	mov    %eax,%edx
  8019d3:	83 c4 10             	add    $0x10,%esp
  8019d6:	eb 09                	jmp    8019e1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019d8:	89 c2                	mov    %eax,%edx
  8019da:	eb 05                	jmp    8019e1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019dc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8019e1:	89 d0                	mov    %edx,%eax
  8019e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e6:	c9                   	leave  
  8019e7:	c3                   	ret    

008019e8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	53                   	push   %ebx
  8019ec:	83 ec 14             	sub    $0x14,%esp
  8019ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019f5:	50                   	push   %eax
  8019f6:	ff 75 08             	pushl  0x8(%ebp)
  8019f9:	e8 6c fb ff ff       	call   80156a <fd_lookup>
  8019fe:	83 c4 08             	add    $0x8,%esp
  801a01:	89 c2                	mov    %eax,%edx
  801a03:	85 c0                	test   %eax,%eax
  801a05:	78 58                	js     801a5f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a07:	83 ec 08             	sub    $0x8,%esp
  801a0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a0d:	50                   	push   %eax
  801a0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a11:	ff 30                	pushl  (%eax)
  801a13:	e8 a8 fb ff ff       	call   8015c0 <dev_lookup>
  801a18:	83 c4 10             	add    $0x10,%esp
  801a1b:	85 c0                	test   %eax,%eax
  801a1d:	78 37                	js     801a56 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a22:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a26:	74 32                	je     801a5a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a28:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a2b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a32:	00 00 00 
	stat->st_isdir = 0;
  801a35:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a3c:	00 00 00 
	stat->st_dev = dev;
  801a3f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a45:	83 ec 08             	sub    $0x8,%esp
  801a48:	53                   	push   %ebx
  801a49:	ff 75 f0             	pushl  -0x10(%ebp)
  801a4c:	ff 50 14             	call   *0x14(%eax)
  801a4f:	89 c2                	mov    %eax,%edx
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	eb 09                	jmp    801a5f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a56:	89 c2                	mov    %eax,%edx
  801a58:	eb 05                	jmp    801a5f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a5a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a5f:	89 d0                	mov    %edx,%eax
  801a61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a64:	c9                   	leave  
  801a65:	c3                   	ret    

00801a66 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	56                   	push   %esi
  801a6a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a6b:	83 ec 08             	sub    $0x8,%esp
  801a6e:	6a 00                	push   $0x0
  801a70:	ff 75 08             	pushl  0x8(%ebp)
  801a73:	e8 e3 01 00 00       	call   801c5b <open>
  801a78:	89 c3                	mov    %eax,%ebx
  801a7a:	83 c4 10             	add    $0x10,%esp
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	78 1b                	js     801a9c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a81:	83 ec 08             	sub    $0x8,%esp
  801a84:	ff 75 0c             	pushl  0xc(%ebp)
  801a87:	50                   	push   %eax
  801a88:	e8 5b ff ff ff       	call   8019e8 <fstat>
  801a8d:	89 c6                	mov    %eax,%esi
	close(fd);
  801a8f:	89 1c 24             	mov    %ebx,(%esp)
  801a92:	e8 fd fb ff ff       	call   801694 <close>
	return r;
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	89 f0                	mov    %esi,%eax
}
  801a9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a9f:	5b                   	pop    %ebx
  801aa0:	5e                   	pop    %esi
  801aa1:	5d                   	pop    %ebp
  801aa2:	c3                   	ret    

00801aa3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	56                   	push   %esi
  801aa7:	53                   	push   %ebx
  801aa8:	89 c6                	mov    %eax,%esi
  801aaa:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801aac:	83 3d 10 50 80 00 00 	cmpl   $0x0,0x805010
  801ab3:	75 12                	jne    801ac7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ab5:	83 ec 0c             	sub    $0xc,%esp
  801ab8:	6a 01                	push   $0x1
  801aba:	e8 d1 0e 00 00       	call   802990 <ipc_find_env>
  801abf:	a3 10 50 80 00       	mov    %eax,0x805010
  801ac4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ac7:	6a 07                	push   $0x7
  801ac9:	68 00 60 80 00       	push   $0x806000
  801ace:	56                   	push   %esi
  801acf:	ff 35 10 50 80 00    	pushl  0x805010
  801ad5:	e8 62 0e 00 00       	call   80293c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ada:	83 c4 0c             	add    $0xc,%esp
  801add:	6a 00                	push   $0x0
  801adf:	53                   	push   %ebx
  801ae0:	6a 00                	push   $0x0
  801ae2:	e8 ec 0d 00 00       	call   8028d3 <ipc_recv>
}
  801ae7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aea:	5b                   	pop    %ebx
  801aeb:	5e                   	pop    %esi
  801aec:	5d                   	pop    %ebp
  801aed:	c3                   	ret    

00801aee <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801af4:	8b 45 08             	mov    0x8(%ebp),%eax
  801af7:	8b 40 0c             	mov    0xc(%eax),%eax
  801afa:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801aff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b02:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b07:	ba 00 00 00 00       	mov    $0x0,%edx
  801b0c:	b8 02 00 00 00       	mov    $0x2,%eax
  801b11:	e8 8d ff ff ff       	call   801aa3 <fsipc>
}
  801b16:	c9                   	leave  
  801b17:	c3                   	ret    

00801b18 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b21:	8b 40 0c             	mov    0xc(%eax),%eax
  801b24:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b29:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2e:	b8 06 00 00 00       	mov    $0x6,%eax
  801b33:	e8 6b ff ff ff       	call   801aa3 <fsipc>
}
  801b38:	c9                   	leave  
  801b39:	c3                   	ret    

00801b3a <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	53                   	push   %ebx
  801b3e:	83 ec 04             	sub    $0x4,%esp
  801b41:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b44:	8b 45 08             	mov    0x8(%ebp),%eax
  801b47:	8b 40 0c             	mov    0xc(%eax),%eax
  801b4a:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b4f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b54:	b8 05 00 00 00       	mov    $0x5,%eax
  801b59:	e8 45 ff ff ff       	call   801aa3 <fsipc>
  801b5e:	85 c0                	test   %eax,%eax
  801b60:	78 2c                	js     801b8e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b62:	83 ec 08             	sub    $0x8,%esp
  801b65:	68 00 60 80 00       	push   $0x806000
  801b6a:	53                   	push   %ebx
  801b6b:	e8 51 f3 ff ff       	call   800ec1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b70:	a1 80 60 80 00       	mov    0x806080,%eax
  801b75:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b7b:	a1 84 60 80 00       	mov    0x806084,%eax
  801b80:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b86:	83 c4 10             	add    $0x10,%esp
  801b89:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b91:	c9                   	leave  
  801b92:	c3                   	ret    

00801b93 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	83 ec 0c             	sub    $0xc,%esp
  801b99:	8b 45 10             	mov    0x10(%ebp),%eax
  801b9c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ba1:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801ba6:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ba9:	8b 55 08             	mov    0x8(%ebp),%edx
  801bac:	8b 52 0c             	mov    0xc(%edx),%edx
  801baf:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801bb5:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801bba:	50                   	push   %eax
  801bbb:	ff 75 0c             	pushl  0xc(%ebp)
  801bbe:	68 08 60 80 00       	push   $0x806008
  801bc3:	e8 8b f4 ff ff       	call   801053 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801bc8:	ba 00 00 00 00       	mov    $0x0,%edx
  801bcd:	b8 04 00 00 00       	mov    $0x4,%eax
  801bd2:	e8 cc fe ff ff       	call   801aa3 <fsipc>
	//panic("devfile_write not implemented");
}
  801bd7:	c9                   	leave  
  801bd8:	c3                   	ret    

00801bd9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bd9:	55                   	push   %ebp
  801bda:	89 e5                	mov    %esp,%ebp
  801bdc:	56                   	push   %esi
  801bdd:	53                   	push   %ebx
  801bde:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801be1:	8b 45 08             	mov    0x8(%ebp),%eax
  801be4:	8b 40 0c             	mov    0xc(%eax),%eax
  801be7:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801bec:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bf2:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf7:	b8 03 00 00 00       	mov    $0x3,%eax
  801bfc:	e8 a2 fe ff ff       	call   801aa3 <fsipc>
  801c01:	89 c3                	mov    %eax,%ebx
  801c03:	85 c0                	test   %eax,%eax
  801c05:	78 4b                	js     801c52 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801c07:	39 c6                	cmp    %eax,%esi
  801c09:	73 16                	jae    801c21 <devfile_read+0x48>
  801c0b:	68 9c 32 80 00       	push   $0x80329c
  801c10:	68 a3 32 80 00       	push   $0x8032a3
  801c15:	6a 7c                	push   $0x7c
  801c17:	68 b8 32 80 00       	push   $0x8032b8
  801c1c:	e8 c3 eb ff ff       	call   8007e4 <_panic>
	assert(r <= PGSIZE);
  801c21:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c26:	7e 16                	jle    801c3e <devfile_read+0x65>
  801c28:	68 c3 32 80 00       	push   $0x8032c3
  801c2d:	68 a3 32 80 00       	push   $0x8032a3
  801c32:	6a 7d                	push   $0x7d
  801c34:	68 b8 32 80 00       	push   $0x8032b8
  801c39:	e8 a6 eb ff ff       	call   8007e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c3e:	83 ec 04             	sub    $0x4,%esp
  801c41:	50                   	push   %eax
  801c42:	68 00 60 80 00       	push   $0x806000
  801c47:	ff 75 0c             	pushl  0xc(%ebp)
  801c4a:	e8 04 f4 ff ff       	call   801053 <memmove>
	return r;
  801c4f:	83 c4 10             	add    $0x10,%esp
}
  801c52:	89 d8                	mov    %ebx,%eax
  801c54:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c57:	5b                   	pop    %ebx
  801c58:	5e                   	pop    %esi
  801c59:	5d                   	pop    %ebp
  801c5a:	c3                   	ret    

00801c5b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	53                   	push   %ebx
  801c5f:	83 ec 20             	sub    $0x20,%esp
  801c62:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c65:	53                   	push   %ebx
  801c66:	e8 1d f2 ff ff       	call   800e88 <strlen>
  801c6b:	83 c4 10             	add    $0x10,%esp
  801c6e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c73:	7f 67                	jg     801cdc <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c75:	83 ec 0c             	sub    $0xc,%esp
  801c78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c7b:	50                   	push   %eax
  801c7c:	e8 9a f8 ff ff       	call   80151b <fd_alloc>
  801c81:	83 c4 10             	add    $0x10,%esp
		return r;
  801c84:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c86:	85 c0                	test   %eax,%eax
  801c88:	78 57                	js     801ce1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c8a:	83 ec 08             	sub    $0x8,%esp
  801c8d:	53                   	push   %ebx
  801c8e:	68 00 60 80 00       	push   $0x806000
  801c93:	e8 29 f2 ff ff       	call   800ec1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c9b:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ca0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ca3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ca8:	e8 f6 fd ff ff       	call   801aa3 <fsipc>
  801cad:	89 c3                	mov    %eax,%ebx
  801caf:	83 c4 10             	add    $0x10,%esp
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	79 14                	jns    801cca <open+0x6f>
		fd_close(fd, 0);
  801cb6:	83 ec 08             	sub    $0x8,%esp
  801cb9:	6a 00                	push   $0x0
  801cbb:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbe:	e8 50 f9 ff ff       	call   801613 <fd_close>
		return r;
  801cc3:	83 c4 10             	add    $0x10,%esp
  801cc6:	89 da                	mov    %ebx,%edx
  801cc8:	eb 17                	jmp    801ce1 <open+0x86>
	}

	return fd2num(fd);
  801cca:	83 ec 0c             	sub    $0xc,%esp
  801ccd:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd0:	e8 1f f8 ff ff       	call   8014f4 <fd2num>
  801cd5:	89 c2                	mov    %eax,%edx
  801cd7:	83 c4 10             	add    $0x10,%esp
  801cda:	eb 05                	jmp    801ce1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801cdc:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ce1:	89 d0                	mov    %edx,%eax
  801ce3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ce6:	c9                   	leave  
  801ce7:	c3                   	ret    

00801ce8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cee:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf3:	b8 08 00 00 00       	mov    $0x8,%eax
  801cf8:	e8 a6 fd ff ff       	call   801aa3 <fsipc>
}
  801cfd:	c9                   	leave  
  801cfe:	c3                   	ret    

00801cff <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801cff:	55                   	push   %ebp
  801d00:	89 e5                	mov    %esp,%ebp
  801d02:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801d05:	68 cf 32 80 00       	push   $0x8032cf
  801d0a:	ff 75 0c             	pushl  0xc(%ebp)
  801d0d:	e8 af f1 ff ff       	call   800ec1 <strcpy>
	return 0;
}
  801d12:	b8 00 00 00 00       	mov    $0x0,%eax
  801d17:	c9                   	leave  
  801d18:	c3                   	ret    

00801d19 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801d19:	55                   	push   %ebp
  801d1a:	89 e5                	mov    %esp,%ebp
  801d1c:	53                   	push   %ebx
  801d1d:	83 ec 10             	sub    $0x10,%esp
  801d20:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d23:	53                   	push   %ebx
  801d24:	e8 a0 0c 00 00       	call   8029c9 <pageref>
  801d29:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801d2c:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801d31:	83 f8 01             	cmp    $0x1,%eax
  801d34:	75 10                	jne    801d46 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801d36:	83 ec 0c             	sub    $0xc,%esp
  801d39:	ff 73 0c             	pushl  0xc(%ebx)
  801d3c:	e8 c0 02 00 00       	call   802001 <nsipc_close>
  801d41:	89 c2                	mov    %eax,%edx
  801d43:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801d46:	89 d0                	mov    %edx,%eax
  801d48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d4b:	c9                   	leave  
  801d4c:	c3                   	ret    

00801d4d <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801d4d:	55                   	push   %ebp
  801d4e:	89 e5                	mov    %esp,%ebp
  801d50:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d53:	6a 00                	push   $0x0
  801d55:	ff 75 10             	pushl  0x10(%ebp)
  801d58:	ff 75 0c             	pushl  0xc(%ebp)
  801d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5e:	ff 70 0c             	pushl  0xc(%eax)
  801d61:	e8 78 03 00 00       	call   8020de <nsipc_send>
}
  801d66:	c9                   	leave  
  801d67:	c3                   	ret    

00801d68 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
  801d6b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d6e:	6a 00                	push   $0x0
  801d70:	ff 75 10             	pushl  0x10(%ebp)
  801d73:	ff 75 0c             	pushl  0xc(%ebp)
  801d76:	8b 45 08             	mov    0x8(%ebp),%eax
  801d79:	ff 70 0c             	pushl  0xc(%eax)
  801d7c:	e8 f1 02 00 00       	call   802072 <nsipc_recv>
}
  801d81:	c9                   	leave  
  801d82:	c3                   	ret    

00801d83 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d83:	55                   	push   %ebp
  801d84:	89 e5                	mov    %esp,%ebp
  801d86:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d89:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d8c:	52                   	push   %edx
  801d8d:	50                   	push   %eax
  801d8e:	e8 d7 f7 ff ff       	call   80156a <fd_lookup>
  801d93:	83 c4 10             	add    $0x10,%esp
  801d96:	85 c0                	test   %eax,%eax
  801d98:	78 17                	js     801db1 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9d:	8b 0d 40 40 80 00    	mov    0x804040,%ecx
  801da3:	39 08                	cmp    %ecx,(%eax)
  801da5:	75 05                	jne    801dac <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801da7:	8b 40 0c             	mov    0xc(%eax),%eax
  801daa:	eb 05                	jmp    801db1 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801dac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801db1:	c9                   	leave  
  801db2:	c3                   	ret    

00801db3 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801db3:	55                   	push   %ebp
  801db4:	89 e5                	mov    %esp,%ebp
  801db6:	56                   	push   %esi
  801db7:	53                   	push   %ebx
  801db8:	83 ec 1c             	sub    $0x1c,%esp
  801dbb:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801dbd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc0:	50                   	push   %eax
  801dc1:	e8 55 f7 ff ff       	call   80151b <fd_alloc>
  801dc6:	89 c3                	mov    %eax,%ebx
  801dc8:	83 c4 10             	add    $0x10,%esp
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	78 1b                	js     801dea <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801dcf:	83 ec 04             	sub    $0x4,%esp
  801dd2:	68 07 04 00 00       	push   $0x407
  801dd7:	ff 75 f4             	pushl  -0xc(%ebp)
  801dda:	6a 00                	push   $0x0
  801ddc:	e8 e3 f4 ff ff       	call   8012c4 <sys_page_alloc>
  801de1:	89 c3                	mov    %eax,%ebx
  801de3:	83 c4 10             	add    $0x10,%esp
  801de6:	85 c0                	test   %eax,%eax
  801de8:	79 10                	jns    801dfa <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801dea:	83 ec 0c             	sub    $0xc,%esp
  801ded:	56                   	push   %esi
  801dee:	e8 0e 02 00 00       	call   802001 <nsipc_close>
		return r;
  801df3:	83 c4 10             	add    $0x10,%esp
  801df6:	89 d8                	mov    %ebx,%eax
  801df8:	eb 24                	jmp    801e1e <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801dfa:	8b 15 40 40 80 00    	mov    0x804040,%edx
  801e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e03:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e08:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801e0f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801e12:	83 ec 0c             	sub    $0xc,%esp
  801e15:	50                   	push   %eax
  801e16:	e8 d9 f6 ff ff       	call   8014f4 <fd2num>
  801e1b:	83 c4 10             	add    $0x10,%esp
}
  801e1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e21:	5b                   	pop    %ebx
  801e22:	5e                   	pop    %esi
  801e23:	5d                   	pop    %ebp
  801e24:	c3                   	ret    

00801e25 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e25:	55                   	push   %ebp
  801e26:	89 e5                	mov    %esp,%ebp
  801e28:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2e:	e8 50 ff ff ff       	call   801d83 <fd2sockid>
		return r;
  801e33:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e35:	85 c0                	test   %eax,%eax
  801e37:	78 1f                	js     801e58 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e39:	83 ec 04             	sub    $0x4,%esp
  801e3c:	ff 75 10             	pushl  0x10(%ebp)
  801e3f:	ff 75 0c             	pushl  0xc(%ebp)
  801e42:	50                   	push   %eax
  801e43:	e8 12 01 00 00       	call   801f5a <nsipc_accept>
  801e48:	83 c4 10             	add    $0x10,%esp
		return r;
  801e4b:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e4d:	85 c0                	test   %eax,%eax
  801e4f:	78 07                	js     801e58 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801e51:	e8 5d ff ff ff       	call   801db3 <alloc_sockfd>
  801e56:	89 c1                	mov    %eax,%ecx
}
  801e58:	89 c8                	mov    %ecx,%eax
  801e5a:	c9                   	leave  
  801e5b:	c3                   	ret    

00801e5c <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e5c:	55                   	push   %ebp
  801e5d:	89 e5                	mov    %esp,%ebp
  801e5f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e62:	8b 45 08             	mov    0x8(%ebp),%eax
  801e65:	e8 19 ff ff ff       	call   801d83 <fd2sockid>
  801e6a:	85 c0                	test   %eax,%eax
  801e6c:	78 12                	js     801e80 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801e6e:	83 ec 04             	sub    $0x4,%esp
  801e71:	ff 75 10             	pushl  0x10(%ebp)
  801e74:	ff 75 0c             	pushl  0xc(%ebp)
  801e77:	50                   	push   %eax
  801e78:	e8 2d 01 00 00       	call   801faa <nsipc_bind>
  801e7d:	83 c4 10             	add    $0x10,%esp
}
  801e80:	c9                   	leave  
  801e81:	c3                   	ret    

00801e82 <shutdown>:

int
shutdown(int s, int how)
{
  801e82:	55                   	push   %ebp
  801e83:	89 e5                	mov    %esp,%ebp
  801e85:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e88:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8b:	e8 f3 fe ff ff       	call   801d83 <fd2sockid>
  801e90:	85 c0                	test   %eax,%eax
  801e92:	78 0f                	js     801ea3 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801e94:	83 ec 08             	sub    $0x8,%esp
  801e97:	ff 75 0c             	pushl  0xc(%ebp)
  801e9a:	50                   	push   %eax
  801e9b:	e8 3f 01 00 00       	call   801fdf <nsipc_shutdown>
  801ea0:	83 c4 10             	add    $0x10,%esp
}
  801ea3:	c9                   	leave  
  801ea4:	c3                   	ret    

00801ea5 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ea5:	55                   	push   %ebp
  801ea6:	89 e5                	mov    %esp,%ebp
  801ea8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eab:	8b 45 08             	mov    0x8(%ebp),%eax
  801eae:	e8 d0 fe ff ff       	call   801d83 <fd2sockid>
  801eb3:	85 c0                	test   %eax,%eax
  801eb5:	78 12                	js     801ec9 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801eb7:	83 ec 04             	sub    $0x4,%esp
  801eba:	ff 75 10             	pushl  0x10(%ebp)
  801ebd:	ff 75 0c             	pushl  0xc(%ebp)
  801ec0:	50                   	push   %eax
  801ec1:	e8 55 01 00 00       	call   80201b <nsipc_connect>
  801ec6:	83 c4 10             	add    $0x10,%esp
}
  801ec9:	c9                   	leave  
  801eca:	c3                   	ret    

00801ecb <listen>:

int
listen(int s, int backlog)
{
  801ecb:	55                   	push   %ebp
  801ecc:	89 e5                	mov    %esp,%ebp
  801ece:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ed1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed4:	e8 aa fe ff ff       	call   801d83 <fd2sockid>
  801ed9:	85 c0                	test   %eax,%eax
  801edb:	78 0f                	js     801eec <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801edd:	83 ec 08             	sub    $0x8,%esp
  801ee0:	ff 75 0c             	pushl  0xc(%ebp)
  801ee3:	50                   	push   %eax
  801ee4:	e8 67 01 00 00       	call   802050 <nsipc_listen>
  801ee9:	83 c4 10             	add    $0x10,%esp
}
  801eec:	c9                   	leave  
  801eed:	c3                   	ret    

00801eee <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801eee:	55                   	push   %ebp
  801eef:	89 e5                	mov    %esp,%ebp
  801ef1:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801ef4:	ff 75 10             	pushl  0x10(%ebp)
  801ef7:	ff 75 0c             	pushl  0xc(%ebp)
  801efa:	ff 75 08             	pushl  0x8(%ebp)
  801efd:	e8 3a 02 00 00       	call   80213c <nsipc_socket>
  801f02:	83 c4 10             	add    $0x10,%esp
  801f05:	85 c0                	test   %eax,%eax
  801f07:	78 05                	js     801f0e <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801f09:	e8 a5 fe ff ff       	call   801db3 <alloc_sockfd>
}
  801f0e:	c9                   	leave  
  801f0f:	c3                   	ret    

00801f10 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801f10:	55                   	push   %ebp
  801f11:	89 e5                	mov    %esp,%ebp
  801f13:	53                   	push   %ebx
  801f14:	83 ec 04             	sub    $0x4,%esp
  801f17:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801f19:	83 3d 14 50 80 00 00 	cmpl   $0x0,0x805014
  801f20:	75 12                	jne    801f34 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801f22:	83 ec 0c             	sub    $0xc,%esp
  801f25:	6a 02                	push   $0x2
  801f27:	e8 64 0a 00 00       	call   802990 <ipc_find_env>
  801f2c:	a3 14 50 80 00       	mov    %eax,0x805014
  801f31:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801f34:	6a 07                	push   $0x7
  801f36:	68 00 70 80 00       	push   $0x807000
  801f3b:	53                   	push   %ebx
  801f3c:	ff 35 14 50 80 00    	pushl  0x805014
  801f42:	e8 f5 09 00 00       	call   80293c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f47:	83 c4 0c             	add    $0xc,%esp
  801f4a:	6a 00                	push   $0x0
  801f4c:	6a 00                	push   $0x0
  801f4e:	6a 00                	push   $0x0
  801f50:	e8 7e 09 00 00       	call   8028d3 <ipc_recv>
}
  801f55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f58:	c9                   	leave  
  801f59:	c3                   	ret    

00801f5a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f5a:	55                   	push   %ebp
  801f5b:	89 e5                	mov    %esp,%ebp
  801f5d:	56                   	push   %esi
  801f5e:	53                   	push   %ebx
  801f5f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f62:	8b 45 08             	mov    0x8(%ebp),%eax
  801f65:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f6a:	8b 06                	mov    (%esi),%eax
  801f6c:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f71:	b8 01 00 00 00       	mov    $0x1,%eax
  801f76:	e8 95 ff ff ff       	call   801f10 <nsipc>
  801f7b:	89 c3                	mov    %eax,%ebx
  801f7d:	85 c0                	test   %eax,%eax
  801f7f:	78 20                	js     801fa1 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f81:	83 ec 04             	sub    $0x4,%esp
  801f84:	ff 35 10 70 80 00    	pushl  0x807010
  801f8a:	68 00 70 80 00       	push   $0x807000
  801f8f:	ff 75 0c             	pushl  0xc(%ebp)
  801f92:	e8 bc f0 ff ff       	call   801053 <memmove>
		*addrlen = ret->ret_addrlen;
  801f97:	a1 10 70 80 00       	mov    0x807010,%eax
  801f9c:	89 06                	mov    %eax,(%esi)
  801f9e:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801fa1:	89 d8                	mov    %ebx,%eax
  801fa3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fa6:	5b                   	pop    %ebx
  801fa7:	5e                   	pop    %esi
  801fa8:	5d                   	pop    %ebp
  801fa9:	c3                   	ret    

00801faa <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801faa:	55                   	push   %ebp
  801fab:	89 e5                	mov    %esp,%ebp
  801fad:	53                   	push   %ebx
  801fae:	83 ec 08             	sub    $0x8,%esp
  801fb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801fb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb7:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801fbc:	53                   	push   %ebx
  801fbd:	ff 75 0c             	pushl  0xc(%ebp)
  801fc0:	68 04 70 80 00       	push   $0x807004
  801fc5:	e8 89 f0 ff ff       	call   801053 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801fca:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801fd0:	b8 02 00 00 00       	mov    $0x2,%eax
  801fd5:	e8 36 ff ff ff       	call   801f10 <nsipc>
}
  801fda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fdd:	c9                   	leave  
  801fde:	c3                   	ret    

00801fdf <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801fdf:	55                   	push   %ebp
  801fe0:	89 e5                	mov    %esp,%ebp
  801fe2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801fe5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe8:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801fed:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff0:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801ff5:	b8 03 00 00 00       	mov    $0x3,%eax
  801ffa:	e8 11 ff ff ff       	call   801f10 <nsipc>
}
  801fff:	c9                   	leave  
  802000:	c3                   	ret    

00802001 <nsipc_close>:

int
nsipc_close(int s)
{
  802001:	55                   	push   %ebp
  802002:	89 e5                	mov    %esp,%ebp
  802004:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802007:	8b 45 08             	mov    0x8(%ebp),%eax
  80200a:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80200f:	b8 04 00 00 00       	mov    $0x4,%eax
  802014:	e8 f7 fe ff ff       	call   801f10 <nsipc>
}
  802019:	c9                   	leave  
  80201a:	c3                   	ret    

0080201b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80201b:	55                   	push   %ebp
  80201c:	89 e5                	mov    %esp,%ebp
  80201e:	53                   	push   %ebx
  80201f:	83 ec 08             	sub    $0x8,%esp
  802022:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802025:	8b 45 08             	mov    0x8(%ebp),%eax
  802028:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80202d:	53                   	push   %ebx
  80202e:	ff 75 0c             	pushl  0xc(%ebp)
  802031:	68 04 70 80 00       	push   $0x807004
  802036:	e8 18 f0 ff ff       	call   801053 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80203b:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802041:	b8 05 00 00 00       	mov    $0x5,%eax
  802046:	e8 c5 fe ff ff       	call   801f10 <nsipc>
}
  80204b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80204e:	c9                   	leave  
  80204f:	c3                   	ret    

00802050 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802056:	8b 45 08             	mov    0x8(%ebp),%eax
  802059:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80205e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802061:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802066:	b8 06 00 00 00       	mov    $0x6,%eax
  80206b:	e8 a0 fe ff ff       	call   801f10 <nsipc>
}
  802070:	c9                   	leave  
  802071:	c3                   	ret    

00802072 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802072:	55                   	push   %ebp
  802073:	89 e5                	mov    %esp,%ebp
  802075:	56                   	push   %esi
  802076:	53                   	push   %ebx
  802077:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80207a:	8b 45 08             	mov    0x8(%ebp),%eax
  80207d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802082:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802088:	8b 45 14             	mov    0x14(%ebp),%eax
  80208b:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802090:	b8 07 00 00 00       	mov    $0x7,%eax
  802095:	e8 76 fe ff ff       	call   801f10 <nsipc>
  80209a:	89 c3                	mov    %eax,%ebx
  80209c:	85 c0                	test   %eax,%eax
  80209e:	78 35                	js     8020d5 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8020a0:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8020a5:	7f 04                	jg     8020ab <nsipc_recv+0x39>
  8020a7:	39 c6                	cmp    %eax,%esi
  8020a9:	7d 16                	jge    8020c1 <nsipc_recv+0x4f>
  8020ab:	68 db 32 80 00       	push   $0x8032db
  8020b0:	68 a3 32 80 00       	push   $0x8032a3
  8020b5:	6a 62                	push   $0x62
  8020b7:	68 f0 32 80 00       	push   $0x8032f0
  8020bc:	e8 23 e7 ff ff       	call   8007e4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8020c1:	83 ec 04             	sub    $0x4,%esp
  8020c4:	50                   	push   %eax
  8020c5:	68 00 70 80 00       	push   $0x807000
  8020ca:	ff 75 0c             	pushl  0xc(%ebp)
  8020cd:	e8 81 ef ff ff       	call   801053 <memmove>
  8020d2:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8020d5:	89 d8                	mov    %ebx,%eax
  8020d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020da:	5b                   	pop    %ebx
  8020db:	5e                   	pop    %esi
  8020dc:	5d                   	pop    %ebp
  8020dd:	c3                   	ret    

008020de <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8020de:	55                   	push   %ebp
  8020df:	89 e5                	mov    %esp,%ebp
  8020e1:	53                   	push   %ebx
  8020e2:	83 ec 04             	sub    $0x4,%esp
  8020e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8020e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020eb:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8020f0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8020f6:	7e 16                	jle    80210e <nsipc_send+0x30>
  8020f8:	68 fc 32 80 00       	push   $0x8032fc
  8020fd:	68 a3 32 80 00       	push   $0x8032a3
  802102:	6a 6d                	push   $0x6d
  802104:	68 f0 32 80 00       	push   $0x8032f0
  802109:	e8 d6 e6 ff ff       	call   8007e4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80210e:	83 ec 04             	sub    $0x4,%esp
  802111:	53                   	push   %ebx
  802112:	ff 75 0c             	pushl  0xc(%ebp)
  802115:	68 0c 70 80 00       	push   $0x80700c
  80211a:	e8 34 ef ff ff       	call   801053 <memmove>
	nsipcbuf.send.req_size = size;
  80211f:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802125:	8b 45 14             	mov    0x14(%ebp),%eax
  802128:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80212d:	b8 08 00 00 00       	mov    $0x8,%eax
  802132:	e8 d9 fd ff ff       	call   801f10 <nsipc>
}
  802137:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80213a:	c9                   	leave  
  80213b:	c3                   	ret    

0080213c <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80213c:	55                   	push   %ebp
  80213d:	89 e5                	mov    %esp,%ebp
  80213f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802142:	8b 45 08             	mov    0x8(%ebp),%eax
  802145:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80214a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80214d:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802152:	8b 45 10             	mov    0x10(%ebp),%eax
  802155:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80215a:	b8 09 00 00 00       	mov    $0x9,%eax
  80215f:	e8 ac fd ff ff       	call   801f10 <nsipc>
}
  802164:	c9                   	leave  
  802165:	c3                   	ret    

00802166 <free>:
	return v;
}

void
free(void *v)
{
  802166:	55                   	push   %ebp
  802167:	89 e5                	mov    %esp,%ebp
  802169:	53                   	push   %ebx
  80216a:	83 ec 04             	sub    $0x4,%esp
  80216d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint8_t *c;
	uint32_t *ref;

	if (v == 0)
  802170:	85 db                	test   %ebx,%ebx
  802172:	0f 84 97 00 00 00    	je     80220f <free+0xa9>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);
  802178:	8d 83 00 00 00 f8    	lea    -0x8000000(%ebx),%eax
  80217e:	3d ff ff ff 07       	cmp    $0x7ffffff,%eax
  802183:	76 16                	jbe    80219b <free+0x35>
  802185:	68 08 33 80 00       	push   $0x803308
  80218a:	68 a3 32 80 00       	push   $0x8032a3
  80218f:	6a 7a                	push   $0x7a
  802191:	68 38 33 80 00       	push   $0x803338
  802196:	e8 49 e6 ff ff       	call   8007e4 <_panic>

	c = ROUNDDOWN(v, PGSIZE);
  80219b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	while (uvpt[PGNUM(c)] & PTE_CONTINUED) {
  8021a1:	eb 3a                	jmp    8021dd <free+0x77>
		sys_page_unmap(0, c);
  8021a3:	83 ec 08             	sub    $0x8,%esp
  8021a6:	53                   	push   %ebx
  8021a7:	6a 00                	push   $0x0
  8021a9:	e8 9b f1 ff ff       	call   801349 <sys_page_unmap>
		c += PGSIZE;
  8021ae:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(mbegin <= c && c < mend);
  8021b4:	8d 83 00 00 00 f8    	lea    -0x8000000(%ebx),%eax
  8021ba:	83 c4 10             	add    $0x10,%esp
  8021bd:	3d ff ff ff 07       	cmp    $0x7ffffff,%eax
  8021c2:	76 19                	jbe    8021dd <free+0x77>
  8021c4:	68 45 33 80 00       	push   $0x803345
  8021c9:	68 a3 32 80 00       	push   $0x8032a3
  8021ce:	68 81 00 00 00       	push   $0x81
  8021d3:	68 38 33 80 00       	push   $0x803338
  8021d8:	e8 07 e6 ff ff       	call   8007e4 <_panic>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);

	c = ROUNDDOWN(v, PGSIZE);

	while (uvpt[PGNUM(c)] & PTE_CONTINUED) {
  8021dd:	89 d8                	mov    %ebx,%eax
  8021df:	c1 e8 0c             	shr    $0xc,%eax
  8021e2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8021e9:	f6 c4 02             	test   $0x2,%ah
  8021ec:	75 b5                	jne    8021a3 <free+0x3d>
	/*
	 * c is just a piece of this page, so dec the ref count
	 * and maybe free the page.
	 */
	ref = (uint32_t*) (c + PGSIZE - 4);
	if (--(*ref) == 0)
  8021ee:	8b 83 fc 0f 00 00    	mov    0xffc(%ebx),%eax
  8021f4:	83 e8 01             	sub    $0x1,%eax
  8021f7:	89 83 fc 0f 00 00    	mov    %eax,0xffc(%ebx)
  8021fd:	85 c0                	test   %eax,%eax
  8021ff:	75 0e                	jne    80220f <free+0xa9>
		sys_page_unmap(0, c);
  802201:	83 ec 08             	sub    $0x8,%esp
  802204:	53                   	push   %ebx
  802205:	6a 00                	push   $0x0
  802207:	e8 3d f1 ff ff       	call   801349 <sys_page_unmap>
  80220c:	83 c4 10             	add    $0x10,%esp
}
  80220f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802212:	c9                   	leave  
  802213:	c3                   	ret    

00802214 <malloc>:
	return 1;
}

void*
malloc(size_t n)
{
  802214:	55                   	push   %ebp
  802215:	89 e5                	mov    %esp,%ebp
  802217:	57                   	push   %edi
  802218:	56                   	push   %esi
  802219:	53                   	push   %ebx
  80221a:	83 ec 1c             	sub    $0x1c,%esp
	int i, cont;
	int nwrap;
	uint32_t *ref;
	void *v;

	if (mptr == 0)
  80221d:	a1 18 50 80 00       	mov    0x805018,%eax
  802222:	85 c0                	test   %eax,%eax
  802224:	75 22                	jne    802248 <malloc+0x34>
		mptr = mbegin;
  802226:	c7 05 18 50 80 00 00 	movl   $0x8000000,0x805018
  80222d:	00 00 08 

	n = ROUNDUP(n, 4);
  802230:	8b 45 08             	mov    0x8(%ebp),%eax
  802233:	83 c0 03             	add    $0x3,%eax
  802236:	83 e0 fc             	and    $0xfffffffc,%eax
  802239:	89 45 dc             	mov    %eax,-0x24(%ebp)

	if (n >= MAXMALLOC)
  80223c:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
  802241:	76 74                	jbe    8022b7 <malloc+0xa3>
  802243:	e9 7a 01 00 00       	jmp    8023c2 <malloc+0x1ae>
	void *v;

	if (mptr == 0)
		mptr = mbegin;

	n = ROUNDUP(n, 4);
  802248:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80224b:	8d 53 03             	lea    0x3(%ebx),%edx
  80224e:	83 e2 fc             	and    $0xfffffffc,%edx
  802251:	89 55 dc             	mov    %edx,-0x24(%ebp)

	if (n >= MAXMALLOC)
  802254:	81 fa ff ff 0f 00    	cmp    $0xfffff,%edx
  80225a:	0f 87 69 01 00 00    	ja     8023c9 <malloc+0x1b5>
		return 0;

	if ((uintptr_t) mptr % PGSIZE){
  802260:	a9 ff 0f 00 00       	test   $0xfff,%eax
  802265:	74 50                	je     8022b7 <malloc+0xa3>
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
  802267:	89 c1                	mov    %eax,%ecx
  802269:	c1 e9 0c             	shr    $0xc,%ecx
  80226c:	8d 54 10 03          	lea    0x3(%eax,%edx,1),%edx
  802270:	c1 ea 0c             	shr    $0xc,%edx
  802273:	39 d1                	cmp    %edx,%ecx
  802275:	75 20                	jne    802297 <malloc+0x83>
		/*
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
  802277:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  80227d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
			(*ref)++;
  802283:	83 42 fc 01          	addl   $0x1,-0x4(%edx)
			v = mptr;
			mptr += n;
  802287:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80228a:	01 c2                	add    %eax,%edx
  80228c:	89 15 18 50 80 00    	mov    %edx,0x805018
			return v;
  802292:	e9 55 01 00 00       	jmp    8023ec <malloc+0x1d8>
		}
		/*
		 * stop working on this page and move on.
		 */
		free(mptr);	/* drop reference to this page */
  802297:	83 ec 0c             	sub    $0xc,%esp
  80229a:	50                   	push   %eax
  80229b:	e8 c6 fe ff ff       	call   802166 <free>
		mptr = ROUNDDOWN(mptr + PGSIZE, PGSIZE);
  8022a0:	a1 18 50 80 00       	mov    0x805018,%eax
  8022a5:	05 00 10 00 00       	add    $0x1000,%eax
  8022aa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8022af:	a3 18 50 80 00       	mov    %eax,0x805018
  8022b4:	83 c4 10             	add    $0x10,%esp
  8022b7:	8b 35 18 50 80 00    	mov    0x805018,%esi
	return 1;
}

void*
malloc(size_t n)
{
  8022bd:	c7 45 d8 02 00 00 00 	movl   $0x2,-0x28(%ebp)
  8022c4:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
	 * runs of more than a page can't have ref counts so we
	 * flag the PTE entries instead.
	 */
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
  8022c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8022cb:	8d 78 04             	lea    0x4(%eax),%edi
  8022ce:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8022d1:	89 fb                	mov    %edi,%ebx
  8022d3:	8d 0c 37             	lea    (%edi,%esi,1),%ecx
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  8022d6:	89 f0                	mov    %esi,%eax
  8022d8:	eb 36                	jmp    802310 <malloc+0xfc>
		if (va >= (uintptr_t) mend
  8022da:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
  8022df:	0f 87 eb 00 00 00    	ja     8023d0 <malloc+0x1bc>
		    || ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)))
  8022e5:	89 c2                	mov    %eax,%edx
  8022e7:	c1 ea 16             	shr    $0x16,%edx
  8022ea:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8022f1:	f6 c2 01             	test   $0x1,%dl
  8022f4:	74 15                	je     80230b <malloc+0xf7>
  8022f6:	89 c2                	mov    %eax,%edx
  8022f8:	c1 ea 0c             	shr    $0xc,%edx
  8022fb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802302:	f6 c2 01             	test   $0x1,%dl
  802305:	0f 85 c5 00 00 00    	jne    8023d0 <malloc+0x1bc>
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  80230b:	05 00 10 00 00       	add    $0x1000,%eax
  802310:	39 c8                	cmp    %ecx,%eax
  802312:	72 c6                	jb     8022da <malloc+0xc6>
  802314:	eb 79                	jmp    80238f <malloc+0x17b>
	while (1) {
		if (isfree(mptr, n + 4))
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
			mptr = mbegin;
  802316:	be 00 00 00 08       	mov    $0x8000000,%esi
  80231b:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
			if (++nwrap == 2)
  80231f:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  802323:	75 a9                	jne    8022ce <malloc+0xba>
  802325:	c7 05 18 50 80 00 00 	movl   $0x8000000,0x805018
  80232c:	00 00 08 
				return 0;	/* out of address space */
  80232f:	b8 00 00 00 00       	mov    $0x0,%eax
  802334:	e9 b3 00 00 00       	jmp    8023ec <malloc+0x1d8>

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  802339:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
  80233f:	39 df                	cmp    %ebx,%edi
  802341:	19 c0                	sbb    %eax,%eax
  802343:	25 00 02 00 00       	and    $0x200,%eax
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
  802348:	83 ec 04             	sub    $0x4,%esp
  80234b:	83 c8 07             	or     $0x7,%eax
  80234e:	50                   	push   %eax
  80234f:	03 15 18 50 80 00    	add    0x805018,%edx
  802355:	52                   	push   %edx
  802356:	6a 00                	push   $0x0
  802358:	e8 67 ef ff ff       	call   8012c4 <sys_page_alloc>
  80235d:	83 c4 10             	add    $0x10,%esp
  802360:	85 c0                	test   %eax,%eax
  802362:	78 20                	js     802384 <malloc+0x170>
	}

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
  802364:	89 fe                	mov    %edi,%esi
  802366:	eb 3a                	jmp    8023a2 <malloc+0x18e>
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
				sys_page_unmap(0, mptr + i);
  802368:	83 ec 08             	sub    $0x8,%esp
  80236b:	89 f0                	mov    %esi,%eax
  80236d:	03 05 18 50 80 00    	add    0x805018,%eax
  802373:	50                   	push   %eax
  802374:	6a 00                	push   $0x0
  802376:	e8 ce ef ff ff       	call   801349 <sys_page_unmap>
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
  80237b:	81 ee 00 10 00 00    	sub    $0x1000,%esi
  802381:	83 c4 10             	add    $0x10,%esp
  802384:	85 f6                	test   %esi,%esi
  802386:	79 e0                	jns    802368 <malloc+0x154>
				sys_page_unmap(0, mptr + i);
			return 0;	/* out of physical memory */
  802388:	b8 00 00 00 00       	mov    $0x0,%eax
  80238d:	eb 5d                	jmp    8023ec <malloc+0x1d8>
  80238f:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  802393:	74 08                	je     80239d <malloc+0x189>
  802395:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802398:	a3 18 50 80 00       	mov    %eax,0x805018

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  80239d:	be 00 00 00 00       	mov    $0x0,%esi
	}

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
  8023a2:	89 f2                	mov    %esi,%edx
  8023a4:	39 f3                	cmp    %esi,%ebx
  8023a6:	77 91                	ja     802339 <malloc+0x125>
				sys_page_unmap(0, mptr + i);
			return 0;	/* out of physical memory */
		}
	}

	ref = (uint32_t*) (mptr + i - 4);
  8023a8:	a1 18 50 80 00       	mov    0x805018,%eax
	*ref = 2;	/* reference for mptr, reference for returned block */
  8023ad:	c7 44 30 fc 02 00 00 	movl   $0x2,-0x4(%eax,%esi,1)
  8023b4:	00 
	v = mptr;
	mptr += n;
  8023b5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8023b8:	01 c2                	add    %eax,%edx
  8023ba:	89 15 18 50 80 00    	mov    %edx,0x805018
	return v;
  8023c0:	eb 2a                	jmp    8023ec <malloc+0x1d8>
		mptr = mbegin;

	n = ROUNDUP(n, 4);

	if (n >= MAXMALLOC)
		return 0;
  8023c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8023c7:	eb 23                	jmp    8023ec <malloc+0x1d8>
  8023c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8023ce:	eb 1c                	jmp    8023ec <malloc+0x1d8>
  8023d0:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
  8023d6:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
  8023da:	89 c6                	mov    %eax,%esi
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
  8023dc:	3d 00 00 00 10       	cmp    $0x10000000,%eax
  8023e1:	0f 85 e7 fe ff ff    	jne    8022ce <malloc+0xba>
  8023e7:	e9 2a ff ff ff       	jmp    802316 <malloc+0x102>
	ref = (uint32_t*) (mptr + i - 4);
	*ref = 2;	/* reference for mptr, reference for returned block */
	v = mptr;
	mptr += n;
	return v;
}
  8023ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023ef:	5b                   	pop    %ebx
  8023f0:	5e                   	pop    %esi
  8023f1:	5f                   	pop    %edi
  8023f2:	5d                   	pop    %ebp
  8023f3:	c3                   	ret    

008023f4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8023f4:	55                   	push   %ebp
  8023f5:	89 e5                	mov    %esp,%ebp
  8023f7:	56                   	push   %esi
  8023f8:	53                   	push   %ebx
  8023f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8023fc:	83 ec 0c             	sub    $0xc,%esp
  8023ff:	ff 75 08             	pushl  0x8(%ebp)
  802402:	e8 fd f0 ff ff       	call   801504 <fd2data>
  802407:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802409:	83 c4 08             	add    $0x8,%esp
  80240c:	68 5d 33 80 00       	push   $0x80335d
  802411:	53                   	push   %ebx
  802412:	e8 aa ea ff ff       	call   800ec1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802417:	8b 46 04             	mov    0x4(%esi),%eax
  80241a:	2b 06                	sub    (%esi),%eax
  80241c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802422:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802429:	00 00 00 
	stat->st_dev = &devpipe;
  80242c:	c7 83 88 00 00 00 5c 	movl   $0x80405c,0x88(%ebx)
  802433:	40 80 00 
	return 0;
}
  802436:	b8 00 00 00 00       	mov    $0x0,%eax
  80243b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80243e:	5b                   	pop    %ebx
  80243f:	5e                   	pop    %esi
  802440:	5d                   	pop    %ebp
  802441:	c3                   	ret    

00802442 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802442:	55                   	push   %ebp
  802443:	89 e5                	mov    %esp,%ebp
  802445:	53                   	push   %ebx
  802446:	83 ec 0c             	sub    $0xc,%esp
  802449:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80244c:	53                   	push   %ebx
  80244d:	6a 00                	push   $0x0
  80244f:	e8 f5 ee ff ff       	call   801349 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802454:	89 1c 24             	mov    %ebx,(%esp)
  802457:	e8 a8 f0 ff ff       	call   801504 <fd2data>
  80245c:	83 c4 08             	add    $0x8,%esp
  80245f:	50                   	push   %eax
  802460:	6a 00                	push   $0x0
  802462:	e8 e2 ee ff ff       	call   801349 <sys_page_unmap>
}
  802467:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80246a:	c9                   	leave  
  80246b:	c3                   	ret    

0080246c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80246c:	55                   	push   %ebp
  80246d:	89 e5                	mov    %esp,%ebp
  80246f:	57                   	push   %edi
  802470:	56                   	push   %esi
  802471:	53                   	push   %ebx
  802472:	83 ec 1c             	sub    $0x1c,%esp
  802475:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802478:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80247a:	a1 1c 50 80 00       	mov    0x80501c,%eax
  80247f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802482:	83 ec 0c             	sub    $0xc,%esp
  802485:	ff 75 e0             	pushl  -0x20(%ebp)
  802488:	e8 3c 05 00 00       	call   8029c9 <pageref>
  80248d:	89 c3                	mov    %eax,%ebx
  80248f:	89 3c 24             	mov    %edi,(%esp)
  802492:	e8 32 05 00 00       	call   8029c9 <pageref>
  802497:	83 c4 10             	add    $0x10,%esp
  80249a:	39 c3                	cmp    %eax,%ebx
  80249c:	0f 94 c1             	sete   %cl
  80249f:	0f b6 c9             	movzbl %cl,%ecx
  8024a2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8024a5:	8b 15 1c 50 80 00    	mov    0x80501c,%edx
  8024ab:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8024ae:	39 ce                	cmp    %ecx,%esi
  8024b0:	74 1b                	je     8024cd <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8024b2:	39 c3                	cmp    %eax,%ebx
  8024b4:	75 c4                	jne    80247a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8024b6:	8b 42 58             	mov    0x58(%edx),%eax
  8024b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8024bc:	50                   	push   %eax
  8024bd:	56                   	push   %esi
  8024be:	68 64 33 80 00       	push   $0x803364
  8024c3:	e8 f5 e3 ff ff       	call   8008bd <cprintf>
  8024c8:	83 c4 10             	add    $0x10,%esp
  8024cb:	eb ad                	jmp    80247a <_pipeisclosed+0xe>
	}
}
  8024cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024d3:	5b                   	pop    %ebx
  8024d4:	5e                   	pop    %esi
  8024d5:	5f                   	pop    %edi
  8024d6:	5d                   	pop    %ebp
  8024d7:	c3                   	ret    

008024d8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8024d8:	55                   	push   %ebp
  8024d9:	89 e5                	mov    %esp,%ebp
  8024db:	57                   	push   %edi
  8024dc:	56                   	push   %esi
  8024dd:	53                   	push   %ebx
  8024de:	83 ec 28             	sub    $0x28,%esp
  8024e1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8024e4:	56                   	push   %esi
  8024e5:	e8 1a f0 ff ff       	call   801504 <fd2data>
  8024ea:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024ec:	83 c4 10             	add    $0x10,%esp
  8024ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8024f4:	eb 4b                	jmp    802541 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8024f6:	89 da                	mov    %ebx,%edx
  8024f8:	89 f0                	mov    %esi,%eax
  8024fa:	e8 6d ff ff ff       	call   80246c <_pipeisclosed>
  8024ff:	85 c0                	test   %eax,%eax
  802501:	75 48                	jne    80254b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802503:	e8 9d ed ff ff       	call   8012a5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802508:	8b 43 04             	mov    0x4(%ebx),%eax
  80250b:	8b 0b                	mov    (%ebx),%ecx
  80250d:	8d 51 20             	lea    0x20(%ecx),%edx
  802510:	39 d0                	cmp    %edx,%eax
  802512:	73 e2                	jae    8024f6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802514:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802517:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80251b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80251e:	89 c2                	mov    %eax,%edx
  802520:	c1 fa 1f             	sar    $0x1f,%edx
  802523:	89 d1                	mov    %edx,%ecx
  802525:	c1 e9 1b             	shr    $0x1b,%ecx
  802528:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80252b:	83 e2 1f             	and    $0x1f,%edx
  80252e:	29 ca                	sub    %ecx,%edx
  802530:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802534:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802538:	83 c0 01             	add    $0x1,%eax
  80253b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80253e:	83 c7 01             	add    $0x1,%edi
  802541:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802544:	75 c2                	jne    802508 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802546:	8b 45 10             	mov    0x10(%ebp),%eax
  802549:	eb 05                	jmp    802550 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80254b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802550:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802553:	5b                   	pop    %ebx
  802554:	5e                   	pop    %esi
  802555:	5f                   	pop    %edi
  802556:	5d                   	pop    %ebp
  802557:	c3                   	ret    

00802558 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802558:	55                   	push   %ebp
  802559:	89 e5                	mov    %esp,%ebp
  80255b:	57                   	push   %edi
  80255c:	56                   	push   %esi
  80255d:	53                   	push   %ebx
  80255e:	83 ec 18             	sub    $0x18,%esp
  802561:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802564:	57                   	push   %edi
  802565:	e8 9a ef ff ff       	call   801504 <fd2data>
  80256a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80256c:	83 c4 10             	add    $0x10,%esp
  80256f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802574:	eb 3d                	jmp    8025b3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802576:	85 db                	test   %ebx,%ebx
  802578:	74 04                	je     80257e <devpipe_read+0x26>
				return i;
  80257a:	89 d8                	mov    %ebx,%eax
  80257c:	eb 44                	jmp    8025c2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80257e:	89 f2                	mov    %esi,%edx
  802580:	89 f8                	mov    %edi,%eax
  802582:	e8 e5 fe ff ff       	call   80246c <_pipeisclosed>
  802587:	85 c0                	test   %eax,%eax
  802589:	75 32                	jne    8025bd <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80258b:	e8 15 ed ff ff       	call   8012a5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802590:	8b 06                	mov    (%esi),%eax
  802592:	3b 46 04             	cmp    0x4(%esi),%eax
  802595:	74 df                	je     802576 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802597:	99                   	cltd   
  802598:	c1 ea 1b             	shr    $0x1b,%edx
  80259b:	01 d0                	add    %edx,%eax
  80259d:	83 e0 1f             	and    $0x1f,%eax
  8025a0:	29 d0                	sub    %edx,%eax
  8025a2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8025a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025aa:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8025ad:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8025b0:	83 c3 01             	add    $0x1,%ebx
  8025b3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8025b6:	75 d8                	jne    802590 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8025b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8025bb:	eb 05                	jmp    8025c2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8025bd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8025c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025c5:	5b                   	pop    %ebx
  8025c6:	5e                   	pop    %esi
  8025c7:	5f                   	pop    %edi
  8025c8:	5d                   	pop    %ebp
  8025c9:	c3                   	ret    

008025ca <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8025ca:	55                   	push   %ebp
  8025cb:	89 e5                	mov    %esp,%ebp
  8025cd:	56                   	push   %esi
  8025ce:	53                   	push   %ebx
  8025cf:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8025d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025d5:	50                   	push   %eax
  8025d6:	e8 40 ef ff ff       	call   80151b <fd_alloc>
  8025db:	83 c4 10             	add    $0x10,%esp
  8025de:	89 c2                	mov    %eax,%edx
  8025e0:	85 c0                	test   %eax,%eax
  8025e2:	0f 88 2c 01 00 00    	js     802714 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025e8:	83 ec 04             	sub    $0x4,%esp
  8025eb:	68 07 04 00 00       	push   $0x407
  8025f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8025f3:	6a 00                	push   $0x0
  8025f5:	e8 ca ec ff ff       	call   8012c4 <sys_page_alloc>
  8025fa:	83 c4 10             	add    $0x10,%esp
  8025fd:	89 c2                	mov    %eax,%edx
  8025ff:	85 c0                	test   %eax,%eax
  802601:	0f 88 0d 01 00 00    	js     802714 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802607:	83 ec 0c             	sub    $0xc,%esp
  80260a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80260d:	50                   	push   %eax
  80260e:	e8 08 ef ff ff       	call   80151b <fd_alloc>
  802613:	89 c3                	mov    %eax,%ebx
  802615:	83 c4 10             	add    $0x10,%esp
  802618:	85 c0                	test   %eax,%eax
  80261a:	0f 88 e2 00 00 00    	js     802702 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802620:	83 ec 04             	sub    $0x4,%esp
  802623:	68 07 04 00 00       	push   $0x407
  802628:	ff 75 f0             	pushl  -0x10(%ebp)
  80262b:	6a 00                	push   $0x0
  80262d:	e8 92 ec ff ff       	call   8012c4 <sys_page_alloc>
  802632:	89 c3                	mov    %eax,%ebx
  802634:	83 c4 10             	add    $0x10,%esp
  802637:	85 c0                	test   %eax,%eax
  802639:	0f 88 c3 00 00 00    	js     802702 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80263f:	83 ec 0c             	sub    $0xc,%esp
  802642:	ff 75 f4             	pushl  -0xc(%ebp)
  802645:	e8 ba ee ff ff       	call   801504 <fd2data>
  80264a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80264c:	83 c4 0c             	add    $0xc,%esp
  80264f:	68 07 04 00 00       	push   $0x407
  802654:	50                   	push   %eax
  802655:	6a 00                	push   $0x0
  802657:	e8 68 ec ff ff       	call   8012c4 <sys_page_alloc>
  80265c:	89 c3                	mov    %eax,%ebx
  80265e:	83 c4 10             	add    $0x10,%esp
  802661:	85 c0                	test   %eax,%eax
  802663:	0f 88 89 00 00 00    	js     8026f2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802669:	83 ec 0c             	sub    $0xc,%esp
  80266c:	ff 75 f0             	pushl  -0x10(%ebp)
  80266f:	e8 90 ee ff ff       	call   801504 <fd2data>
  802674:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80267b:	50                   	push   %eax
  80267c:	6a 00                	push   $0x0
  80267e:	56                   	push   %esi
  80267f:	6a 00                	push   $0x0
  802681:	e8 81 ec ff ff       	call   801307 <sys_page_map>
  802686:	89 c3                	mov    %eax,%ebx
  802688:	83 c4 20             	add    $0x20,%esp
  80268b:	85 c0                	test   %eax,%eax
  80268d:	78 55                	js     8026e4 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80268f:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  802695:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802698:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80269a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80269d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8026a4:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  8026aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026ad:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8026af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026b2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8026b9:	83 ec 0c             	sub    $0xc,%esp
  8026bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8026bf:	e8 30 ee ff ff       	call   8014f4 <fd2num>
  8026c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026c7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8026c9:	83 c4 04             	add    $0x4,%esp
  8026cc:	ff 75 f0             	pushl  -0x10(%ebp)
  8026cf:	e8 20 ee ff ff       	call   8014f4 <fd2num>
  8026d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026d7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8026da:	83 c4 10             	add    $0x10,%esp
  8026dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8026e2:	eb 30                	jmp    802714 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8026e4:	83 ec 08             	sub    $0x8,%esp
  8026e7:	56                   	push   %esi
  8026e8:	6a 00                	push   $0x0
  8026ea:	e8 5a ec ff ff       	call   801349 <sys_page_unmap>
  8026ef:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8026f2:	83 ec 08             	sub    $0x8,%esp
  8026f5:	ff 75 f0             	pushl  -0x10(%ebp)
  8026f8:	6a 00                	push   $0x0
  8026fa:	e8 4a ec ff ff       	call   801349 <sys_page_unmap>
  8026ff:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802702:	83 ec 08             	sub    $0x8,%esp
  802705:	ff 75 f4             	pushl  -0xc(%ebp)
  802708:	6a 00                	push   $0x0
  80270a:	e8 3a ec ff ff       	call   801349 <sys_page_unmap>
  80270f:	83 c4 10             	add    $0x10,%esp
  802712:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802714:	89 d0                	mov    %edx,%eax
  802716:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802719:	5b                   	pop    %ebx
  80271a:	5e                   	pop    %esi
  80271b:	5d                   	pop    %ebp
  80271c:	c3                   	ret    

0080271d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80271d:	55                   	push   %ebp
  80271e:	89 e5                	mov    %esp,%ebp
  802720:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802723:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802726:	50                   	push   %eax
  802727:	ff 75 08             	pushl  0x8(%ebp)
  80272a:	e8 3b ee ff ff       	call   80156a <fd_lookup>
  80272f:	83 c4 10             	add    $0x10,%esp
  802732:	85 c0                	test   %eax,%eax
  802734:	78 18                	js     80274e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802736:	83 ec 0c             	sub    $0xc,%esp
  802739:	ff 75 f4             	pushl  -0xc(%ebp)
  80273c:	e8 c3 ed ff ff       	call   801504 <fd2data>
	return _pipeisclosed(fd, p);
  802741:	89 c2                	mov    %eax,%edx
  802743:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802746:	e8 21 fd ff ff       	call   80246c <_pipeisclosed>
  80274b:	83 c4 10             	add    $0x10,%esp
}
  80274e:	c9                   	leave  
  80274f:	c3                   	ret    

00802750 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802750:	55                   	push   %ebp
  802751:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802753:	b8 00 00 00 00       	mov    $0x0,%eax
  802758:	5d                   	pop    %ebp
  802759:	c3                   	ret    

0080275a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80275a:	55                   	push   %ebp
  80275b:	89 e5                	mov    %esp,%ebp
  80275d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802760:	68 7c 33 80 00       	push   $0x80337c
  802765:	ff 75 0c             	pushl  0xc(%ebp)
  802768:	e8 54 e7 ff ff       	call   800ec1 <strcpy>
	return 0;
}
  80276d:	b8 00 00 00 00       	mov    $0x0,%eax
  802772:	c9                   	leave  
  802773:	c3                   	ret    

00802774 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802774:	55                   	push   %ebp
  802775:	89 e5                	mov    %esp,%ebp
  802777:	57                   	push   %edi
  802778:	56                   	push   %esi
  802779:	53                   	push   %ebx
  80277a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802780:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802785:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80278b:	eb 2d                	jmp    8027ba <devcons_write+0x46>
		m = n - tot;
  80278d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802790:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802792:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802795:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80279a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80279d:	83 ec 04             	sub    $0x4,%esp
  8027a0:	53                   	push   %ebx
  8027a1:	03 45 0c             	add    0xc(%ebp),%eax
  8027a4:	50                   	push   %eax
  8027a5:	57                   	push   %edi
  8027a6:	e8 a8 e8 ff ff       	call   801053 <memmove>
		sys_cputs(buf, m);
  8027ab:	83 c4 08             	add    $0x8,%esp
  8027ae:	53                   	push   %ebx
  8027af:	57                   	push   %edi
  8027b0:	e8 53 ea ff ff       	call   801208 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027b5:	01 de                	add    %ebx,%esi
  8027b7:	83 c4 10             	add    $0x10,%esp
  8027ba:	89 f0                	mov    %esi,%eax
  8027bc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8027bf:	72 cc                	jb     80278d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8027c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027c4:	5b                   	pop    %ebx
  8027c5:	5e                   	pop    %esi
  8027c6:	5f                   	pop    %edi
  8027c7:	5d                   	pop    %ebp
  8027c8:	c3                   	ret    

008027c9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8027c9:	55                   	push   %ebp
  8027ca:	89 e5                	mov    %esp,%ebp
  8027cc:	83 ec 08             	sub    $0x8,%esp
  8027cf:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8027d4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8027d8:	74 2a                	je     802804 <devcons_read+0x3b>
  8027da:	eb 05                	jmp    8027e1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8027dc:	e8 c4 ea ff ff       	call   8012a5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8027e1:	e8 40 ea ff ff       	call   801226 <sys_cgetc>
  8027e6:	85 c0                	test   %eax,%eax
  8027e8:	74 f2                	je     8027dc <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8027ea:	85 c0                	test   %eax,%eax
  8027ec:	78 16                	js     802804 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8027ee:	83 f8 04             	cmp    $0x4,%eax
  8027f1:	74 0c                	je     8027ff <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8027f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8027f6:	88 02                	mov    %al,(%edx)
	return 1;
  8027f8:	b8 01 00 00 00       	mov    $0x1,%eax
  8027fd:	eb 05                	jmp    802804 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8027ff:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802804:	c9                   	leave  
  802805:	c3                   	ret    

00802806 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  802806:	55                   	push   %ebp
  802807:	89 e5                	mov    %esp,%ebp
  802809:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80280c:	8b 45 08             	mov    0x8(%ebp),%eax
  80280f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802812:	6a 01                	push   $0x1
  802814:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802817:	50                   	push   %eax
  802818:	e8 eb e9 ff ff       	call   801208 <sys_cputs>
}
  80281d:	83 c4 10             	add    $0x10,%esp
  802820:	c9                   	leave  
  802821:	c3                   	ret    

00802822 <getchar>:

int
getchar(void)
{
  802822:	55                   	push   %ebp
  802823:	89 e5                	mov    %esp,%ebp
  802825:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802828:	6a 01                	push   $0x1
  80282a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80282d:	50                   	push   %eax
  80282e:	6a 00                	push   $0x0
  802830:	e8 9b ef ff ff       	call   8017d0 <read>
	if (r < 0)
  802835:	83 c4 10             	add    $0x10,%esp
  802838:	85 c0                	test   %eax,%eax
  80283a:	78 0f                	js     80284b <getchar+0x29>
		return r;
	if (r < 1)
  80283c:	85 c0                	test   %eax,%eax
  80283e:	7e 06                	jle    802846 <getchar+0x24>
		return -E_EOF;
	return c;
  802840:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802844:	eb 05                	jmp    80284b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802846:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80284b:	c9                   	leave  
  80284c:	c3                   	ret    

0080284d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80284d:	55                   	push   %ebp
  80284e:	89 e5                	mov    %esp,%ebp
  802850:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802853:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802856:	50                   	push   %eax
  802857:	ff 75 08             	pushl  0x8(%ebp)
  80285a:	e8 0b ed ff ff       	call   80156a <fd_lookup>
  80285f:	83 c4 10             	add    $0x10,%esp
  802862:	85 c0                	test   %eax,%eax
  802864:	78 11                	js     802877 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802866:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802869:	8b 15 78 40 80 00    	mov    0x804078,%edx
  80286f:	39 10                	cmp    %edx,(%eax)
  802871:	0f 94 c0             	sete   %al
  802874:	0f b6 c0             	movzbl %al,%eax
}
  802877:	c9                   	leave  
  802878:	c3                   	ret    

00802879 <opencons>:

int
opencons(void)
{
  802879:	55                   	push   %ebp
  80287a:	89 e5                	mov    %esp,%ebp
  80287c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80287f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802882:	50                   	push   %eax
  802883:	e8 93 ec ff ff       	call   80151b <fd_alloc>
  802888:	83 c4 10             	add    $0x10,%esp
		return r;
  80288b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80288d:	85 c0                	test   %eax,%eax
  80288f:	78 3e                	js     8028cf <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802891:	83 ec 04             	sub    $0x4,%esp
  802894:	68 07 04 00 00       	push   $0x407
  802899:	ff 75 f4             	pushl  -0xc(%ebp)
  80289c:	6a 00                	push   $0x0
  80289e:	e8 21 ea ff ff       	call   8012c4 <sys_page_alloc>
  8028a3:	83 c4 10             	add    $0x10,%esp
		return r;
  8028a6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8028a8:	85 c0                	test   %eax,%eax
  8028aa:	78 23                	js     8028cf <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8028ac:	8b 15 78 40 80 00    	mov    0x804078,%edx
  8028b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028b5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8028b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028ba:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8028c1:	83 ec 0c             	sub    $0xc,%esp
  8028c4:	50                   	push   %eax
  8028c5:	e8 2a ec ff ff       	call   8014f4 <fd2num>
  8028ca:	89 c2                	mov    %eax,%edx
  8028cc:	83 c4 10             	add    $0x10,%esp
}
  8028cf:	89 d0                	mov    %edx,%eax
  8028d1:	c9                   	leave  
  8028d2:	c3                   	ret    

008028d3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8028d3:	55                   	push   %ebp
  8028d4:	89 e5                	mov    %esp,%ebp
  8028d6:	56                   	push   %esi
  8028d7:	53                   	push   %ebx
  8028d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8028db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028de:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  8028e1:	85 c0                	test   %eax,%eax
  8028e3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8028e8:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  8028eb:	83 ec 0c             	sub    $0xc,%esp
  8028ee:	50                   	push   %eax
  8028ef:	e8 80 eb ff ff       	call   801474 <sys_ipc_recv>
  8028f4:	83 c4 10             	add    $0x10,%esp
  8028f7:	85 c0                	test   %eax,%eax
  8028f9:	79 16                	jns    802911 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  8028fb:	85 f6                	test   %esi,%esi
  8028fd:	74 06                	je     802905 <ipc_recv+0x32>
            *from_env_store = 0;
  8028ff:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  802905:	85 db                	test   %ebx,%ebx
  802907:	74 2c                	je     802935 <ipc_recv+0x62>
            *perm_store = 0;
  802909:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80290f:	eb 24                	jmp    802935 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  802911:	85 f6                	test   %esi,%esi
  802913:	74 0a                	je     80291f <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  802915:	a1 1c 50 80 00       	mov    0x80501c,%eax
  80291a:	8b 40 74             	mov    0x74(%eax),%eax
  80291d:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  80291f:	85 db                	test   %ebx,%ebx
  802921:	74 0a                	je     80292d <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  802923:	a1 1c 50 80 00       	mov    0x80501c,%eax
  802928:	8b 40 78             	mov    0x78(%eax),%eax
  80292b:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  80292d:	a1 1c 50 80 00       	mov    0x80501c,%eax
  802932:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  802935:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802938:	5b                   	pop    %ebx
  802939:	5e                   	pop    %esi
  80293a:	5d                   	pop    %ebp
  80293b:	c3                   	ret    

0080293c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80293c:	55                   	push   %ebp
  80293d:	89 e5                	mov    %esp,%ebp
  80293f:	57                   	push   %edi
  802940:	56                   	push   %esi
  802941:	53                   	push   %ebx
  802942:	83 ec 0c             	sub    $0xc,%esp
  802945:	8b 7d 08             	mov    0x8(%ebp),%edi
  802948:	8b 75 0c             	mov    0xc(%ebp),%esi
  80294b:	8b 45 10             	mov    0x10(%ebp),%eax
  80294e:	85 c0                	test   %eax,%eax
  802950:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802955:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  802958:	eb 1c                	jmp    802976 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  80295a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80295d:	74 12                	je     802971 <ipc_send+0x35>
  80295f:	50                   	push   %eax
  802960:	68 88 33 80 00       	push   $0x803388
  802965:	6a 3b                	push   $0x3b
  802967:	68 9e 33 80 00       	push   $0x80339e
  80296c:	e8 73 de ff ff       	call   8007e4 <_panic>
		sys_yield();
  802971:	e8 2f e9 ff ff       	call   8012a5 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  802976:	ff 75 14             	pushl  0x14(%ebp)
  802979:	53                   	push   %ebx
  80297a:	56                   	push   %esi
  80297b:	57                   	push   %edi
  80297c:	e8 d0 ea ff ff       	call   801451 <sys_ipc_try_send>
  802981:	83 c4 10             	add    $0x10,%esp
  802984:	85 c0                	test   %eax,%eax
  802986:	78 d2                	js     80295a <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  802988:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80298b:	5b                   	pop    %ebx
  80298c:	5e                   	pop    %esi
  80298d:	5f                   	pop    %edi
  80298e:	5d                   	pop    %ebp
  80298f:	c3                   	ret    

00802990 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802990:	55                   	push   %ebp
  802991:	89 e5                	mov    %esp,%ebp
  802993:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802996:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80299b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80299e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8029a4:	8b 52 50             	mov    0x50(%edx),%edx
  8029a7:	39 ca                	cmp    %ecx,%edx
  8029a9:	75 0d                	jne    8029b8 <ipc_find_env+0x28>
			return envs[i].env_id;
  8029ab:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8029ae:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8029b3:	8b 40 48             	mov    0x48(%eax),%eax
  8029b6:	eb 0f                	jmp    8029c7 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8029b8:	83 c0 01             	add    $0x1,%eax
  8029bb:	3d 00 04 00 00       	cmp    $0x400,%eax
  8029c0:	75 d9                	jne    80299b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8029c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8029c7:	5d                   	pop    %ebp
  8029c8:	c3                   	ret    

008029c9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8029c9:	55                   	push   %ebp
  8029ca:	89 e5                	mov    %esp,%ebp
  8029cc:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8029cf:	89 d0                	mov    %edx,%eax
  8029d1:	c1 e8 16             	shr    $0x16,%eax
  8029d4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8029db:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8029e0:	f6 c1 01             	test   $0x1,%cl
  8029e3:	74 1d                	je     802a02 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8029e5:	c1 ea 0c             	shr    $0xc,%edx
  8029e8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8029ef:	f6 c2 01             	test   $0x1,%dl
  8029f2:	74 0e                	je     802a02 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8029f4:	c1 ea 0c             	shr    $0xc,%edx
  8029f7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8029fe:	ef 
  8029ff:	0f b7 c0             	movzwl %ax,%eax
}
  802a02:	5d                   	pop    %ebp
  802a03:	c3                   	ret    
  802a04:	66 90                	xchg   %ax,%ax
  802a06:	66 90                	xchg   %ax,%ax
  802a08:	66 90                	xchg   %ax,%ax
  802a0a:	66 90                	xchg   %ax,%ax
  802a0c:	66 90                	xchg   %ax,%ax
  802a0e:	66 90                	xchg   %ax,%ax

00802a10 <__udivdi3>:
  802a10:	55                   	push   %ebp
  802a11:	57                   	push   %edi
  802a12:	56                   	push   %esi
  802a13:	53                   	push   %ebx
  802a14:	83 ec 1c             	sub    $0x1c,%esp
  802a17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802a1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802a1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802a23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802a27:	85 f6                	test   %esi,%esi
  802a29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a2d:	89 ca                	mov    %ecx,%edx
  802a2f:	89 f8                	mov    %edi,%eax
  802a31:	75 3d                	jne    802a70 <__udivdi3+0x60>
  802a33:	39 cf                	cmp    %ecx,%edi
  802a35:	0f 87 c5 00 00 00    	ja     802b00 <__udivdi3+0xf0>
  802a3b:	85 ff                	test   %edi,%edi
  802a3d:	89 fd                	mov    %edi,%ebp
  802a3f:	75 0b                	jne    802a4c <__udivdi3+0x3c>
  802a41:	b8 01 00 00 00       	mov    $0x1,%eax
  802a46:	31 d2                	xor    %edx,%edx
  802a48:	f7 f7                	div    %edi
  802a4a:	89 c5                	mov    %eax,%ebp
  802a4c:	89 c8                	mov    %ecx,%eax
  802a4e:	31 d2                	xor    %edx,%edx
  802a50:	f7 f5                	div    %ebp
  802a52:	89 c1                	mov    %eax,%ecx
  802a54:	89 d8                	mov    %ebx,%eax
  802a56:	89 cf                	mov    %ecx,%edi
  802a58:	f7 f5                	div    %ebp
  802a5a:	89 c3                	mov    %eax,%ebx
  802a5c:	89 d8                	mov    %ebx,%eax
  802a5e:	89 fa                	mov    %edi,%edx
  802a60:	83 c4 1c             	add    $0x1c,%esp
  802a63:	5b                   	pop    %ebx
  802a64:	5e                   	pop    %esi
  802a65:	5f                   	pop    %edi
  802a66:	5d                   	pop    %ebp
  802a67:	c3                   	ret    
  802a68:	90                   	nop
  802a69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a70:	39 ce                	cmp    %ecx,%esi
  802a72:	77 74                	ja     802ae8 <__udivdi3+0xd8>
  802a74:	0f bd fe             	bsr    %esi,%edi
  802a77:	83 f7 1f             	xor    $0x1f,%edi
  802a7a:	0f 84 98 00 00 00    	je     802b18 <__udivdi3+0x108>
  802a80:	bb 20 00 00 00       	mov    $0x20,%ebx
  802a85:	89 f9                	mov    %edi,%ecx
  802a87:	89 c5                	mov    %eax,%ebp
  802a89:	29 fb                	sub    %edi,%ebx
  802a8b:	d3 e6                	shl    %cl,%esi
  802a8d:	89 d9                	mov    %ebx,%ecx
  802a8f:	d3 ed                	shr    %cl,%ebp
  802a91:	89 f9                	mov    %edi,%ecx
  802a93:	d3 e0                	shl    %cl,%eax
  802a95:	09 ee                	or     %ebp,%esi
  802a97:	89 d9                	mov    %ebx,%ecx
  802a99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802a9d:	89 d5                	mov    %edx,%ebp
  802a9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802aa3:	d3 ed                	shr    %cl,%ebp
  802aa5:	89 f9                	mov    %edi,%ecx
  802aa7:	d3 e2                	shl    %cl,%edx
  802aa9:	89 d9                	mov    %ebx,%ecx
  802aab:	d3 e8                	shr    %cl,%eax
  802aad:	09 c2                	or     %eax,%edx
  802aaf:	89 d0                	mov    %edx,%eax
  802ab1:	89 ea                	mov    %ebp,%edx
  802ab3:	f7 f6                	div    %esi
  802ab5:	89 d5                	mov    %edx,%ebp
  802ab7:	89 c3                	mov    %eax,%ebx
  802ab9:	f7 64 24 0c          	mull   0xc(%esp)
  802abd:	39 d5                	cmp    %edx,%ebp
  802abf:	72 10                	jb     802ad1 <__udivdi3+0xc1>
  802ac1:	8b 74 24 08          	mov    0x8(%esp),%esi
  802ac5:	89 f9                	mov    %edi,%ecx
  802ac7:	d3 e6                	shl    %cl,%esi
  802ac9:	39 c6                	cmp    %eax,%esi
  802acb:	73 07                	jae    802ad4 <__udivdi3+0xc4>
  802acd:	39 d5                	cmp    %edx,%ebp
  802acf:	75 03                	jne    802ad4 <__udivdi3+0xc4>
  802ad1:	83 eb 01             	sub    $0x1,%ebx
  802ad4:	31 ff                	xor    %edi,%edi
  802ad6:	89 d8                	mov    %ebx,%eax
  802ad8:	89 fa                	mov    %edi,%edx
  802ada:	83 c4 1c             	add    $0x1c,%esp
  802add:	5b                   	pop    %ebx
  802ade:	5e                   	pop    %esi
  802adf:	5f                   	pop    %edi
  802ae0:	5d                   	pop    %ebp
  802ae1:	c3                   	ret    
  802ae2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802ae8:	31 ff                	xor    %edi,%edi
  802aea:	31 db                	xor    %ebx,%ebx
  802aec:	89 d8                	mov    %ebx,%eax
  802aee:	89 fa                	mov    %edi,%edx
  802af0:	83 c4 1c             	add    $0x1c,%esp
  802af3:	5b                   	pop    %ebx
  802af4:	5e                   	pop    %esi
  802af5:	5f                   	pop    %edi
  802af6:	5d                   	pop    %ebp
  802af7:	c3                   	ret    
  802af8:	90                   	nop
  802af9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b00:	89 d8                	mov    %ebx,%eax
  802b02:	f7 f7                	div    %edi
  802b04:	31 ff                	xor    %edi,%edi
  802b06:	89 c3                	mov    %eax,%ebx
  802b08:	89 d8                	mov    %ebx,%eax
  802b0a:	89 fa                	mov    %edi,%edx
  802b0c:	83 c4 1c             	add    $0x1c,%esp
  802b0f:	5b                   	pop    %ebx
  802b10:	5e                   	pop    %esi
  802b11:	5f                   	pop    %edi
  802b12:	5d                   	pop    %ebp
  802b13:	c3                   	ret    
  802b14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b18:	39 ce                	cmp    %ecx,%esi
  802b1a:	72 0c                	jb     802b28 <__udivdi3+0x118>
  802b1c:	31 db                	xor    %ebx,%ebx
  802b1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802b22:	0f 87 34 ff ff ff    	ja     802a5c <__udivdi3+0x4c>
  802b28:	bb 01 00 00 00       	mov    $0x1,%ebx
  802b2d:	e9 2a ff ff ff       	jmp    802a5c <__udivdi3+0x4c>
  802b32:	66 90                	xchg   %ax,%ax
  802b34:	66 90                	xchg   %ax,%ax
  802b36:	66 90                	xchg   %ax,%ax
  802b38:	66 90                	xchg   %ax,%ax
  802b3a:	66 90                	xchg   %ax,%ax
  802b3c:	66 90                	xchg   %ax,%ax
  802b3e:	66 90                	xchg   %ax,%ax

00802b40 <__umoddi3>:
  802b40:	55                   	push   %ebp
  802b41:	57                   	push   %edi
  802b42:	56                   	push   %esi
  802b43:	53                   	push   %ebx
  802b44:	83 ec 1c             	sub    $0x1c,%esp
  802b47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802b4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802b4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802b53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802b57:	85 d2                	test   %edx,%edx
  802b59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802b5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b61:	89 f3                	mov    %esi,%ebx
  802b63:	89 3c 24             	mov    %edi,(%esp)
  802b66:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b6a:	75 1c                	jne    802b88 <__umoddi3+0x48>
  802b6c:	39 f7                	cmp    %esi,%edi
  802b6e:	76 50                	jbe    802bc0 <__umoddi3+0x80>
  802b70:	89 c8                	mov    %ecx,%eax
  802b72:	89 f2                	mov    %esi,%edx
  802b74:	f7 f7                	div    %edi
  802b76:	89 d0                	mov    %edx,%eax
  802b78:	31 d2                	xor    %edx,%edx
  802b7a:	83 c4 1c             	add    $0x1c,%esp
  802b7d:	5b                   	pop    %ebx
  802b7e:	5e                   	pop    %esi
  802b7f:	5f                   	pop    %edi
  802b80:	5d                   	pop    %ebp
  802b81:	c3                   	ret    
  802b82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802b88:	39 f2                	cmp    %esi,%edx
  802b8a:	89 d0                	mov    %edx,%eax
  802b8c:	77 52                	ja     802be0 <__umoddi3+0xa0>
  802b8e:	0f bd ea             	bsr    %edx,%ebp
  802b91:	83 f5 1f             	xor    $0x1f,%ebp
  802b94:	75 5a                	jne    802bf0 <__umoddi3+0xb0>
  802b96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802b9a:	0f 82 e0 00 00 00    	jb     802c80 <__umoddi3+0x140>
  802ba0:	39 0c 24             	cmp    %ecx,(%esp)
  802ba3:	0f 86 d7 00 00 00    	jbe    802c80 <__umoddi3+0x140>
  802ba9:	8b 44 24 08          	mov    0x8(%esp),%eax
  802bad:	8b 54 24 04          	mov    0x4(%esp),%edx
  802bb1:	83 c4 1c             	add    $0x1c,%esp
  802bb4:	5b                   	pop    %ebx
  802bb5:	5e                   	pop    %esi
  802bb6:	5f                   	pop    %edi
  802bb7:	5d                   	pop    %ebp
  802bb8:	c3                   	ret    
  802bb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802bc0:	85 ff                	test   %edi,%edi
  802bc2:	89 fd                	mov    %edi,%ebp
  802bc4:	75 0b                	jne    802bd1 <__umoddi3+0x91>
  802bc6:	b8 01 00 00 00       	mov    $0x1,%eax
  802bcb:	31 d2                	xor    %edx,%edx
  802bcd:	f7 f7                	div    %edi
  802bcf:	89 c5                	mov    %eax,%ebp
  802bd1:	89 f0                	mov    %esi,%eax
  802bd3:	31 d2                	xor    %edx,%edx
  802bd5:	f7 f5                	div    %ebp
  802bd7:	89 c8                	mov    %ecx,%eax
  802bd9:	f7 f5                	div    %ebp
  802bdb:	89 d0                	mov    %edx,%eax
  802bdd:	eb 99                	jmp    802b78 <__umoddi3+0x38>
  802bdf:	90                   	nop
  802be0:	89 c8                	mov    %ecx,%eax
  802be2:	89 f2                	mov    %esi,%edx
  802be4:	83 c4 1c             	add    $0x1c,%esp
  802be7:	5b                   	pop    %ebx
  802be8:	5e                   	pop    %esi
  802be9:	5f                   	pop    %edi
  802bea:	5d                   	pop    %ebp
  802beb:	c3                   	ret    
  802bec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802bf0:	8b 34 24             	mov    (%esp),%esi
  802bf3:	bf 20 00 00 00       	mov    $0x20,%edi
  802bf8:	89 e9                	mov    %ebp,%ecx
  802bfa:	29 ef                	sub    %ebp,%edi
  802bfc:	d3 e0                	shl    %cl,%eax
  802bfe:	89 f9                	mov    %edi,%ecx
  802c00:	89 f2                	mov    %esi,%edx
  802c02:	d3 ea                	shr    %cl,%edx
  802c04:	89 e9                	mov    %ebp,%ecx
  802c06:	09 c2                	or     %eax,%edx
  802c08:	89 d8                	mov    %ebx,%eax
  802c0a:	89 14 24             	mov    %edx,(%esp)
  802c0d:	89 f2                	mov    %esi,%edx
  802c0f:	d3 e2                	shl    %cl,%edx
  802c11:	89 f9                	mov    %edi,%ecx
  802c13:	89 54 24 04          	mov    %edx,0x4(%esp)
  802c17:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802c1b:	d3 e8                	shr    %cl,%eax
  802c1d:	89 e9                	mov    %ebp,%ecx
  802c1f:	89 c6                	mov    %eax,%esi
  802c21:	d3 e3                	shl    %cl,%ebx
  802c23:	89 f9                	mov    %edi,%ecx
  802c25:	89 d0                	mov    %edx,%eax
  802c27:	d3 e8                	shr    %cl,%eax
  802c29:	89 e9                	mov    %ebp,%ecx
  802c2b:	09 d8                	or     %ebx,%eax
  802c2d:	89 d3                	mov    %edx,%ebx
  802c2f:	89 f2                	mov    %esi,%edx
  802c31:	f7 34 24             	divl   (%esp)
  802c34:	89 d6                	mov    %edx,%esi
  802c36:	d3 e3                	shl    %cl,%ebx
  802c38:	f7 64 24 04          	mull   0x4(%esp)
  802c3c:	39 d6                	cmp    %edx,%esi
  802c3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802c42:	89 d1                	mov    %edx,%ecx
  802c44:	89 c3                	mov    %eax,%ebx
  802c46:	72 08                	jb     802c50 <__umoddi3+0x110>
  802c48:	75 11                	jne    802c5b <__umoddi3+0x11b>
  802c4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802c4e:	73 0b                	jae    802c5b <__umoddi3+0x11b>
  802c50:	2b 44 24 04          	sub    0x4(%esp),%eax
  802c54:	1b 14 24             	sbb    (%esp),%edx
  802c57:	89 d1                	mov    %edx,%ecx
  802c59:	89 c3                	mov    %eax,%ebx
  802c5b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802c5f:	29 da                	sub    %ebx,%edx
  802c61:	19 ce                	sbb    %ecx,%esi
  802c63:	89 f9                	mov    %edi,%ecx
  802c65:	89 f0                	mov    %esi,%eax
  802c67:	d3 e0                	shl    %cl,%eax
  802c69:	89 e9                	mov    %ebp,%ecx
  802c6b:	d3 ea                	shr    %cl,%edx
  802c6d:	89 e9                	mov    %ebp,%ecx
  802c6f:	d3 ee                	shr    %cl,%esi
  802c71:	09 d0                	or     %edx,%eax
  802c73:	89 f2                	mov    %esi,%edx
  802c75:	83 c4 1c             	add    $0x1c,%esp
  802c78:	5b                   	pop    %ebx
  802c79:	5e                   	pop    %esi
  802c7a:	5f                   	pop    %edi
  802c7b:	5d                   	pop    %ebp
  802c7c:	c3                   	ret    
  802c7d:	8d 76 00             	lea    0x0(%esi),%esi
  802c80:	29 f9                	sub    %edi,%ecx
  802c82:	19 d6                	sbb    %edx,%esi
  802c84:	89 74 24 04          	mov    %esi,0x4(%esp)
  802c88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802c8c:	e9 18 ff ff ff       	jmp    802ba9 <__umoddi3+0x69>
