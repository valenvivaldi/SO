
_pagestest:     formato del fichero elf32-i386


Desensamblado de la sección .text:

00000000 <printf>:

int array[100];

void
printf(int fd, char *s, ...)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 08             	sub    $0x8,%esp
  write(fd, s, strlen(s));
   6:	83 ec 0c             	sub    $0xc,%esp
   9:	ff 75 0c             	pushl  0xc(%ebp)
   c:	e8 9f 01 00 00       	call   1b0 <strlen>
  11:	83 c4 10             	add    $0x10,%esp
  14:	83 ec 04             	sub    $0x4,%esp
  17:	50                   	push   %eax
  18:	ff 75 0c             	pushl  0xc(%ebp)
  1b:	ff 75 08             	pushl  0x8(%ebp)
  1e:	e8 6f 03 00 00       	call   392 <write>
  23:	83 c4 10             	add    $0x10,%esp
}
  26:	90                   	nop
  27:	c9                   	leave  
  28:	c3                   	ret    

00000029 <pagestest>:

void
pagestest(int a)
{
  29:	55                   	push   %ebp
  2a:	89 e5                	mov    %esp,%ebp
  2c:	83 ec 28             	sub    $0x28,%esp
  if(a==0){
  2f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  33:	75 14                	jne    49 <pagestest+0x20>
    printf(1,"caso base de la recursion!\n");
  35:	83 ec 08             	sub    $0x8,%esp
  38:	68 42 04 00 00       	push   $0x442
  3d:	6a 01                	push   $0x1
  3f:	e8 bc ff ff ff       	call   0 <printf>
  44:	83 c4 10             	add    $0x10,%esp
    i=a+h;
    i++;
    printf(1,"llamada recusiva!\n");
    pagestest(a-1);
  }
}
  47:	eb 7b                	jmp    c4 <pagestest+0x9b>
{
  if(a==0){
    printf(1,"caso base de la recursion!\n");
  }else{
    int b,c,d,e,f,g,h,i  ;
    b=a;
  49:	8b 45 08             	mov    0x8(%ebp),%eax
  4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    c=a+b;
  4f:	8b 55 08             	mov    0x8(%ebp),%edx
  52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  55:	01 d0                	add    %edx,%eax
  57:	89 45 f0             	mov    %eax,-0x10(%ebp)
    d=a+c;
  5a:	8b 55 08             	mov    0x8(%ebp),%edx
  5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  60:	01 d0                	add    %edx,%eax
  62:	89 45 ec             	mov    %eax,-0x14(%ebp)
    e=a+d;
  65:	8b 55 08             	mov    0x8(%ebp),%edx
  68:	8b 45 ec             	mov    -0x14(%ebp),%eax
  6b:	01 d0                	add    %edx,%eax
  6d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    f=a+e;
  70:	8b 55 08             	mov    0x8(%ebp),%edx
  73:	8b 45 e8             	mov    -0x18(%ebp),%eax
  76:	01 d0                	add    %edx,%eax
  78:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    g=a+f;
  7b:	8b 55 08             	mov    0x8(%ebp),%edx
  7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  81:	01 d0                	add    %edx,%eax
  83:	89 45 e0             	mov    %eax,-0x20(%ebp)
    h=a+g;
  86:	8b 55 08             	mov    0x8(%ebp),%edx
  89:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8c:	01 d0                	add    %edx,%eax
  8e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    i=a+h;
  91:	8b 55 08             	mov    0x8(%ebp),%edx
  94:	8b 45 dc             	mov    -0x24(%ebp),%eax
  97:	01 d0                	add    %edx,%eax
  99:	89 45 d8             	mov    %eax,-0x28(%ebp)
    i++;
  9c:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
    printf(1,"llamada recusiva!\n");
  a0:	83 ec 08             	sub    $0x8,%esp
  a3:	68 5e 04 00 00       	push   $0x45e
  a8:	6a 01                	push   $0x1
  aa:	e8 51 ff ff ff       	call   0 <printf>
  af:	83 c4 10             	add    $0x10,%esp
    pagestest(a-1);
  b2:	8b 45 08             	mov    0x8(%ebp),%eax
  b5:	83 e8 01             	sub    $0x1,%eax
  b8:	83 ec 0c             	sub    $0xc,%esp
  bb:	50                   	push   %eax
  bc:	e8 68 ff ff ff       	call   29 <pagestest>
  c1:	83 c4 10             	add    $0x10,%esp
  }
}
  c4:	90                   	nop
  c5:	c9                   	leave  
  c6:	c3                   	ret    

000000c7 <main>:



int
main(void)
{
  c7:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  cb:	83 e4 f0             	and    $0xfffffff0,%esp
  ce:	ff 71 fc             	pushl  -0x4(%ecx)
  d1:	55                   	push   %ebp
  d2:	89 e5                	mov    %esp,%ebp
  d4:	51                   	push   %ecx
  d5:	83 ec 04             	sub    $0x4,%esp
  array[0]=1;
  d8:	c7 05 60 06 00 00 01 	movl   $0x1,0x660
  df:	00 00 00 

  printf(1, "pages test started!\n");
  e2:	83 ec 08             	sub    $0x8,%esp
  e5:	68 71 04 00 00       	push   $0x471
  ea:	6a 01                	push   $0x1
  ec:	e8 0f ff ff ff       	call   0 <printf>
  f1:	83 c4 10             	add    $0x10,%esp
  pagestest(N);
  f4:	83 ec 0c             	sub    $0xc,%esp
  f7:	68 2c 01 00 00       	push   $0x12c
  fc:	e8 28 ff ff ff       	call   29 <pagestest>
 101:	83 c4 10             	add    $0x10,%esp
  printf(1, "pages test finished!\n");
 104:	83 ec 08             	sub    $0x8,%esp
 107:	68 86 04 00 00       	push   $0x486
 10c:	6a 01                	push   $0x1
 10e:	e8 ed fe ff ff       	call   0 <printf>
 113:	83 c4 10             	add    $0x10,%esp
  exit();
 116:	e8 57 02 00 00       	call   372 <exit>

0000011b <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 11b:	55                   	push   %ebp
 11c:	89 e5                	mov    %esp,%ebp
 11e:	57                   	push   %edi
 11f:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 120:	8b 4d 08             	mov    0x8(%ebp),%ecx
 123:	8b 55 10             	mov    0x10(%ebp),%edx
 126:	8b 45 0c             	mov    0xc(%ebp),%eax
 129:	89 cb                	mov    %ecx,%ebx
 12b:	89 df                	mov    %ebx,%edi
 12d:	89 d1                	mov    %edx,%ecx
 12f:	fc                   	cld    
 130:	f3 aa                	rep stos %al,%es:(%edi)
 132:	89 ca                	mov    %ecx,%edx
 134:	89 fb                	mov    %edi,%ebx
 136:	89 5d 08             	mov    %ebx,0x8(%ebp)
 139:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 13c:	90                   	nop
 13d:	5b                   	pop    %ebx
 13e:	5f                   	pop    %edi
 13f:	5d                   	pop    %ebp
 140:	c3                   	ret    

00000141 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 141:	55                   	push   %ebp
 142:	89 e5                	mov    %esp,%ebp
 144:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 147:	8b 45 08             	mov    0x8(%ebp),%eax
 14a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 14d:	90                   	nop
 14e:	8b 45 08             	mov    0x8(%ebp),%eax
 151:	8d 50 01             	lea    0x1(%eax),%edx
 154:	89 55 08             	mov    %edx,0x8(%ebp)
 157:	8b 55 0c             	mov    0xc(%ebp),%edx
 15a:	8d 4a 01             	lea    0x1(%edx),%ecx
 15d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 160:	0f b6 12             	movzbl (%edx),%edx
 163:	88 10                	mov    %dl,(%eax)
 165:	0f b6 00             	movzbl (%eax),%eax
 168:	84 c0                	test   %al,%al
 16a:	75 e2                	jne    14e <strcpy+0xd>
    ;
  return os;
 16c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 16f:	c9                   	leave  
 170:	c3                   	ret    

00000171 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 171:	55                   	push   %ebp
 172:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 174:	eb 08                	jmp    17e <strcmp+0xd>
    p++, q++;
 176:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 17a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 17e:	8b 45 08             	mov    0x8(%ebp),%eax
 181:	0f b6 00             	movzbl (%eax),%eax
 184:	84 c0                	test   %al,%al
 186:	74 10                	je     198 <strcmp+0x27>
 188:	8b 45 08             	mov    0x8(%ebp),%eax
 18b:	0f b6 10             	movzbl (%eax),%edx
 18e:	8b 45 0c             	mov    0xc(%ebp),%eax
 191:	0f b6 00             	movzbl (%eax),%eax
 194:	38 c2                	cmp    %al,%dl
 196:	74 de                	je     176 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 198:	8b 45 08             	mov    0x8(%ebp),%eax
 19b:	0f b6 00             	movzbl (%eax),%eax
 19e:	0f b6 d0             	movzbl %al,%edx
 1a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a4:	0f b6 00             	movzbl (%eax),%eax
 1a7:	0f b6 c0             	movzbl %al,%eax
 1aa:	29 c2                	sub    %eax,%edx
 1ac:	89 d0                	mov    %edx,%eax
}
 1ae:	5d                   	pop    %ebp
 1af:	c3                   	ret    

000001b0 <strlen>:

uint
strlen(char *s)
{
 1b0:	55                   	push   %ebp
 1b1:	89 e5                	mov    %esp,%ebp
 1b3:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1b6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1bd:	eb 04                	jmp    1c3 <strlen+0x13>
 1bf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1c3:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1c6:	8b 45 08             	mov    0x8(%ebp),%eax
 1c9:	01 d0                	add    %edx,%eax
 1cb:	0f b6 00             	movzbl (%eax),%eax
 1ce:	84 c0                	test   %al,%al
 1d0:	75 ed                	jne    1bf <strlen+0xf>
    ;
  return n;
 1d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1d5:	c9                   	leave  
 1d6:	c3                   	ret    

000001d7 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1d7:	55                   	push   %ebp
 1d8:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1da:	8b 45 10             	mov    0x10(%ebp),%eax
 1dd:	50                   	push   %eax
 1de:	ff 75 0c             	pushl  0xc(%ebp)
 1e1:	ff 75 08             	pushl  0x8(%ebp)
 1e4:	e8 32 ff ff ff       	call   11b <stosb>
 1e9:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1ec:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ef:	c9                   	leave  
 1f0:	c3                   	ret    

000001f1 <strchr>:

char*
strchr(const char *s, char c)
{
 1f1:	55                   	push   %ebp
 1f2:	89 e5                	mov    %esp,%ebp
 1f4:	83 ec 04             	sub    $0x4,%esp
 1f7:	8b 45 0c             	mov    0xc(%ebp),%eax
 1fa:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1fd:	eb 14                	jmp    213 <strchr+0x22>
    if(*s == c)
 1ff:	8b 45 08             	mov    0x8(%ebp),%eax
 202:	0f b6 00             	movzbl (%eax),%eax
 205:	3a 45 fc             	cmp    -0x4(%ebp),%al
 208:	75 05                	jne    20f <strchr+0x1e>
      return (char*)s;
 20a:	8b 45 08             	mov    0x8(%ebp),%eax
 20d:	eb 13                	jmp    222 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 20f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 213:	8b 45 08             	mov    0x8(%ebp),%eax
 216:	0f b6 00             	movzbl (%eax),%eax
 219:	84 c0                	test   %al,%al
 21b:	75 e2                	jne    1ff <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 21d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 222:	c9                   	leave  
 223:	c3                   	ret    

00000224 <gets>:

char*
gets(char *buf, int max)
{
 224:	55                   	push   %ebp
 225:	89 e5                	mov    %esp,%ebp
 227:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 22a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 231:	eb 42                	jmp    275 <gets+0x51>
    cc = read(0, &c, 1);
 233:	83 ec 04             	sub    $0x4,%esp
 236:	6a 01                	push   $0x1
 238:	8d 45 ef             	lea    -0x11(%ebp),%eax
 23b:	50                   	push   %eax
 23c:	6a 00                	push   $0x0
 23e:	e8 47 01 00 00       	call   38a <read>
 243:	83 c4 10             	add    $0x10,%esp
 246:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 249:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 24d:	7e 33                	jle    282 <gets+0x5e>
      break;
    buf[i++] = c;
 24f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 252:	8d 50 01             	lea    0x1(%eax),%edx
 255:	89 55 f4             	mov    %edx,-0xc(%ebp)
 258:	89 c2                	mov    %eax,%edx
 25a:	8b 45 08             	mov    0x8(%ebp),%eax
 25d:	01 c2                	add    %eax,%edx
 25f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 263:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 265:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 269:	3c 0a                	cmp    $0xa,%al
 26b:	74 16                	je     283 <gets+0x5f>
 26d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 271:	3c 0d                	cmp    $0xd,%al
 273:	74 0e                	je     283 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 275:	8b 45 f4             	mov    -0xc(%ebp),%eax
 278:	83 c0 01             	add    $0x1,%eax
 27b:	3b 45 0c             	cmp    0xc(%ebp),%eax
 27e:	7c b3                	jl     233 <gets+0xf>
 280:	eb 01                	jmp    283 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 282:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 283:	8b 55 f4             	mov    -0xc(%ebp),%edx
 286:	8b 45 08             	mov    0x8(%ebp),%eax
 289:	01 d0                	add    %edx,%eax
 28b:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 28e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 291:	c9                   	leave  
 292:	c3                   	ret    

00000293 <stat>:

int
stat(char *n, struct stat *st)
{
 293:	55                   	push   %ebp
 294:	89 e5                	mov    %esp,%ebp
 296:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 299:	83 ec 08             	sub    $0x8,%esp
 29c:	6a 00                	push   $0x0
 29e:	ff 75 08             	pushl  0x8(%ebp)
 2a1:	e8 0c 01 00 00       	call   3b2 <open>
 2a6:	83 c4 10             	add    $0x10,%esp
 2a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2b0:	79 07                	jns    2b9 <stat+0x26>
    return -1;
 2b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2b7:	eb 25                	jmp    2de <stat+0x4b>
  r = fstat(fd, st);
 2b9:	83 ec 08             	sub    $0x8,%esp
 2bc:	ff 75 0c             	pushl  0xc(%ebp)
 2bf:	ff 75 f4             	pushl  -0xc(%ebp)
 2c2:	e8 03 01 00 00       	call   3ca <fstat>
 2c7:	83 c4 10             	add    $0x10,%esp
 2ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2cd:	83 ec 0c             	sub    $0xc,%esp
 2d0:	ff 75 f4             	pushl  -0xc(%ebp)
 2d3:	e8 c2 00 00 00       	call   39a <close>
 2d8:	83 c4 10             	add    $0x10,%esp
  return r;
 2db:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2de:	c9                   	leave  
 2df:	c3                   	ret    

000002e0 <atoi>:

int
atoi(const char *s)
{
 2e0:	55                   	push   %ebp
 2e1:	89 e5                	mov    %esp,%ebp
 2e3:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2e6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2ed:	eb 25                	jmp    314 <atoi+0x34>
    n = n*10 + *s++ - '0';
 2ef:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2f2:	89 d0                	mov    %edx,%eax
 2f4:	c1 e0 02             	shl    $0x2,%eax
 2f7:	01 d0                	add    %edx,%eax
 2f9:	01 c0                	add    %eax,%eax
 2fb:	89 c1                	mov    %eax,%ecx
 2fd:	8b 45 08             	mov    0x8(%ebp),%eax
 300:	8d 50 01             	lea    0x1(%eax),%edx
 303:	89 55 08             	mov    %edx,0x8(%ebp)
 306:	0f b6 00             	movzbl (%eax),%eax
 309:	0f be c0             	movsbl %al,%eax
 30c:	01 c8                	add    %ecx,%eax
 30e:	83 e8 30             	sub    $0x30,%eax
 311:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 314:	8b 45 08             	mov    0x8(%ebp),%eax
 317:	0f b6 00             	movzbl (%eax),%eax
 31a:	3c 2f                	cmp    $0x2f,%al
 31c:	7e 0a                	jle    328 <atoi+0x48>
 31e:	8b 45 08             	mov    0x8(%ebp),%eax
 321:	0f b6 00             	movzbl (%eax),%eax
 324:	3c 39                	cmp    $0x39,%al
 326:	7e c7                	jle    2ef <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 328:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 32b:	c9                   	leave  
 32c:	c3                   	ret    

0000032d <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 32d:	55                   	push   %ebp
 32e:	89 e5                	mov    %esp,%ebp
 330:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 333:	8b 45 08             	mov    0x8(%ebp),%eax
 336:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 339:	8b 45 0c             	mov    0xc(%ebp),%eax
 33c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 33f:	eb 17                	jmp    358 <memmove+0x2b>
    *dst++ = *src++;
 341:	8b 45 fc             	mov    -0x4(%ebp),%eax
 344:	8d 50 01             	lea    0x1(%eax),%edx
 347:	89 55 fc             	mov    %edx,-0x4(%ebp)
 34a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 34d:	8d 4a 01             	lea    0x1(%edx),%ecx
 350:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 353:	0f b6 12             	movzbl (%edx),%edx
 356:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 358:	8b 45 10             	mov    0x10(%ebp),%eax
 35b:	8d 50 ff             	lea    -0x1(%eax),%edx
 35e:	89 55 10             	mov    %edx,0x10(%ebp)
 361:	85 c0                	test   %eax,%eax
 363:	7f dc                	jg     341 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 365:	8b 45 08             	mov    0x8(%ebp),%eax
}
 368:	c9                   	leave  
 369:	c3                   	ret    

0000036a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 36a:	b8 01 00 00 00       	mov    $0x1,%eax
 36f:	cd 40                	int    $0x40
 371:	c3                   	ret    

00000372 <exit>:
SYSCALL(exit)
 372:	b8 02 00 00 00       	mov    $0x2,%eax
 377:	cd 40                	int    $0x40
 379:	c3                   	ret    

0000037a <wait>:
SYSCALL(wait)
 37a:	b8 03 00 00 00       	mov    $0x3,%eax
 37f:	cd 40                	int    $0x40
 381:	c3                   	ret    

00000382 <pipe>:
SYSCALL(pipe)
 382:	b8 04 00 00 00       	mov    $0x4,%eax
 387:	cd 40                	int    $0x40
 389:	c3                   	ret    

0000038a <read>:
SYSCALL(read)
 38a:	b8 05 00 00 00       	mov    $0x5,%eax
 38f:	cd 40                	int    $0x40
 391:	c3                   	ret    

00000392 <write>:
SYSCALL(write)
 392:	b8 10 00 00 00       	mov    $0x10,%eax
 397:	cd 40                	int    $0x40
 399:	c3                   	ret    

0000039a <close>:
SYSCALL(close)
 39a:	b8 15 00 00 00       	mov    $0x15,%eax
 39f:	cd 40                	int    $0x40
 3a1:	c3                   	ret    

000003a2 <kill>:
SYSCALL(kill)
 3a2:	b8 06 00 00 00       	mov    $0x6,%eax
 3a7:	cd 40                	int    $0x40
 3a9:	c3                   	ret    

000003aa <exec>:
SYSCALL(exec)
 3aa:	b8 07 00 00 00       	mov    $0x7,%eax
 3af:	cd 40                	int    $0x40
 3b1:	c3                   	ret    

000003b2 <open>:
SYSCALL(open)
 3b2:	b8 0f 00 00 00       	mov    $0xf,%eax
 3b7:	cd 40                	int    $0x40
 3b9:	c3                   	ret    

000003ba <mknod>:
SYSCALL(mknod)
 3ba:	b8 11 00 00 00       	mov    $0x11,%eax
 3bf:	cd 40                	int    $0x40
 3c1:	c3                   	ret    

000003c2 <unlink>:
SYSCALL(unlink)
 3c2:	b8 12 00 00 00       	mov    $0x12,%eax
 3c7:	cd 40                	int    $0x40
 3c9:	c3                   	ret    

000003ca <fstat>:
SYSCALL(fstat)
 3ca:	b8 08 00 00 00       	mov    $0x8,%eax
 3cf:	cd 40                	int    $0x40
 3d1:	c3                   	ret    

000003d2 <link>:
SYSCALL(link)
 3d2:	b8 13 00 00 00       	mov    $0x13,%eax
 3d7:	cd 40                	int    $0x40
 3d9:	c3                   	ret    

000003da <mkdir>:
SYSCALL(mkdir)
 3da:	b8 14 00 00 00       	mov    $0x14,%eax
 3df:	cd 40                	int    $0x40
 3e1:	c3                   	ret    

000003e2 <chdir>:
SYSCALL(chdir)
 3e2:	b8 09 00 00 00       	mov    $0x9,%eax
 3e7:	cd 40                	int    $0x40
 3e9:	c3                   	ret    

000003ea <dup>:
SYSCALL(dup)
 3ea:	b8 0a 00 00 00       	mov    $0xa,%eax
 3ef:	cd 40                	int    $0x40
 3f1:	c3                   	ret    

000003f2 <getpid>:
SYSCALL(getpid)
 3f2:	b8 0b 00 00 00       	mov    $0xb,%eax
 3f7:	cd 40                	int    $0x40
 3f9:	c3                   	ret    

000003fa <sbrk>:
SYSCALL(sbrk)
 3fa:	b8 0c 00 00 00       	mov    $0xc,%eax
 3ff:	cd 40                	int    $0x40
 401:	c3                   	ret    

00000402 <sleep>:
SYSCALL(sleep)
 402:	b8 0d 00 00 00       	mov    $0xd,%eax
 407:	cd 40                	int    $0x40
 409:	c3                   	ret    

0000040a <uptime>:
SYSCALL(uptime)
 40a:	b8 0e 00 00 00       	mov    $0xe,%eax
 40f:	cd 40                	int    $0x40
 411:	c3                   	ret    

00000412 <procstat>:
SYSCALL(procstat)
 412:	b8 16 00 00 00       	mov    $0x16,%eax
 417:	cd 40                	int    $0x40
 419:	c3                   	ret    

0000041a <setpriority>:
SYSCALL(setpriority)
 41a:	b8 17 00 00 00       	mov    $0x17,%eax
 41f:	cd 40                	int    $0x40
 421:	c3                   	ret    

00000422 <semget>:
SYSCALL(semget)
 422:	b8 18 00 00 00       	mov    $0x18,%eax
 427:	cd 40                	int    $0x40
 429:	c3                   	ret    

0000042a <semfree>:
SYSCALL(semfree)
 42a:	b8 19 00 00 00       	mov    $0x19,%eax
 42f:	cd 40                	int    $0x40
 431:	c3                   	ret    

00000432 <semdown>:
SYSCALL(semdown)
 432:	b8 1a 00 00 00       	mov    $0x1a,%eax
 437:	cd 40                	int    $0x40
 439:	c3                   	ret    

0000043a <semup>:
SYSCALL(semup)
 43a:	b8 1b 00 00 00       	mov    $0x1b,%eax
 43f:	cd 40                	int    $0x40
 441:	c3                   	ret    
