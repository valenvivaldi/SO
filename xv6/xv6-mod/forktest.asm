
_forktest:     formato del fichero elf32-i386


Desensamblado de la sección .text:

00000000 <printf>:

#define N  1000

void
printf(int fd, char *s, ...)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 08             	sub    $0x8,%esp
  write(fd, s, strlen(s));
   6:	83 ec 0c             	sub    $0xc,%esp
   9:	ff 75 0c             	pushl  0xc(%ebp)
   c:	e8 a2 01 00 00       	call   1b3 <strlen>
  11:	83 c4 10             	add    $0x10,%esp
  14:	83 ec 04             	sub    $0x4,%esp
  17:	50                   	push   %eax
  18:	ff 75 0c             	pushl  0xc(%ebp)
  1b:	ff 75 08             	pushl  0x8(%ebp)
  1e:	e8 72 03 00 00       	call   395 <write>
  23:	83 c4 10             	add    $0x10,%esp
}
  26:	90                   	nop
  27:	c9                   	leave  
  28:	c3                   	ret    

00000029 <forktest>:

void
forktest(void)
{
  29:	55                   	push   %ebp
  2a:	89 e5                	mov    %esp,%ebp
  2c:	83 ec 18             	sub    $0x18,%esp
  int n, pid;

  printf(1, "fork test\n");
  2f:	83 ec 08             	sub    $0x8,%esp
  32:	68 48 04 00 00       	push   $0x448
  37:	6a 01                	push   $0x1
  39:	e8 c2 ff ff ff       	call   0 <printf>
  3e:	83 c4 10             	add    $0x10,%esp

  for(n=0; n<N; n++){
  41:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  48:	eb 28                	jmp    72 <forktest+0x49>
    if(n==5){     //en la sexta iteracion del ciclo, se ejecuta procstat
  4a:	83 7d f4 05          	cmpl   $0x5,-0xc(%ebp)
  4e:	75 05                	jne    55 <forktest+0x2c>
      procstat();
  50:	e8 c0 03 00 00       	call   415 <procstat>
    }
    pid = fork();
  55:	e8 13 03 00 00       	call   36d <fork>
  5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0)
  5d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  61:	78 1a                	js     7d <forktest+0x54>
      break;
    if(pid == 0)
  63:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  67:	75 05                	jne    6e <forktest+0x45>
     exit();
  69:	e8 07 03 00 00       	call   375 <exit>
{
  int n, pid;

  printf(1, "fork test\n");

  for(n=0; n<N; n++){
  6e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  72:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
  79:	7e cf                	jle    4a <forktest+0x21>
  7b:	eb 01                	jmp    7e <forktest+0x55>
    if(n==5){     //en la sexta iteracion del ciclo, se ejecuta procstat
      procstat();
    }
    pid = fork();
    if(pid < 0)
      break;
  7d:	90                   	nop
    if(pid == 0)
     exit();
  }
  
  if(n == N){
  7e:	81 7d f4 e8 03 00 00 	cmpl   $0x3e8,-0xc(%ebp)
  85:	75 40                	jne    c7 <forktest+0x9e>
    printf(1, "fork claimed to work N times!\n", N);
  87:	83 ec 04             	sub    $0x4,%esp
  8a:	68 e8 03 00 00       	push   $0x3e8
  8f:	68 54 04 00 00       	push   $0x454
  94:	6a 01                	push   $0x1
  96:	e8 65 ff ff ff       	call   0 <printf>
  9b:	83 c4 10             	add    $0x10,%esp
    exit();
  9e:	e8 d2 02 00 00       	call   375 <exit>
  }
  
  for(; n > 0; n--){
    if(wait() < 0){
  a3:	e8 d5 02 00 00       	call   37d <wait>
  a8:	85 c0                	test   %eax,%eax
  aa:	79 17                	jns    c3 <forktest+0x9a>
      printf(1, "wait stopped early\n");
  ac:	83 ec 08             	sub    $0x8,%esp
  af:	68 73 04 00 00       	push   $0x473
  b4:	6a 01                	push   $0x1
  b6:	e8 45 ff ff ff       	call   0 <printf>
  bb:	83 c4 10             	add    $0x10,%esp
      exit();
  be:	e8 b2 02 00 00       	call   375 <exit>
  if(n == N){
    printf(1, "fork claimed to work N times!\n", N);
    exit();
  }
  
  for(; n > 0; n--){
  c3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  cb:	7f d6                	jg     a3 <forktest+0x7a>
      printf(1, "wait stopped early\n");
      exit();
    }
  }
  
  if(wait() != -1){
  cd:	e8 ab 02 00 00       	call   37d <wait>
  d2:	83 f8 ff             	cmp    $0xffffffff,%eax
  d5:	74 17                	je     ee <forktest+0xc5>
    printf(1, "wait got too many\n");
  d7:	83 ec 08             	sub    $0x8,%esp
  da:	68 87 04 00 00       	push   $0x487
  df:	6a 01                	push   $0x1
  e1:	e8 1a ff ff ff       	call   0 <printf>
  e6:	83 c4 10             	add    $0x10,%esp
    exit();
  e9:	e8 87 02 00 00       	call   375 <exit>
  }
  
  printf(1, "fork test OK\n");
  ee:	83 ec 08             	sub    $0x8,%esp
  f1:	68 9a 04 00 00       	push   $0x49a
  f6:	6a 01                	push   $0x1
  f8:	e8 03 ff ff ff       	call   0 <printf>
  fd:	83 c4 10             	add    $0x10,%esp
}
 100:	90                   	nop
 101:	c9                   	leave  
 102:	c3                   	ret    

00000103 <main>:

int
main(void)
{
 103:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 107:	83 e4 f0             	and    $0xfffffff0,%esp
 10a:	ff 71 fc             	pushl  -0x4(%ecx)
 10d:	55                   	push   %ebp
 10e:	89 e5                	mov    %esp,%ebp
 110:	51                   	push   %ecx
 111:	83 ec 04             	sub    $0x4,%esp
  forktest();
 114:	e8 10 ff ff ff       	call   29 <forktest>
  exit();
 119:	e8 57 02 00 00       	call   375 <exit>

0000011e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 11e:	55                   	push   %ebp
 11f:	89 e5                	mov    %esp,%ebp
 121:	57                   	push   %edi
 122:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 123:	8b 4d 08             	mov    0x8(%ebp),%ecx
 126:	8b 55 10             	mov    0x10(%ebp),%edx
 129:	8b 45 0c             	mov    0xc(%ebp),%eax
 12c:	89 cb                	mov    %ecx,%ebx
 12e:	89 df                	mov    %ebx,%edi
 130:	89 d1                	mov    %edx,%ecx
 132:	fc                   	cld    
 133:	f3 aa                	rep stos %al,%es:(%edi)
 135:	89 ca                	mov    %ecx,%edx
 137:	89 fb                	mov    %edi,%ebx
 139:	89 5d 08             	mov    %ebx,0x8(%ebp)
 13c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 13f:	90                   	nop
 140:	5b                   	pop    %ebx
 141:	5f                   	pop    %edi
 142:	5d                   	pop    %ebp
 143:	c3                   	ret    

00000144 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 144:	55                   	push   %ebp
 145:	89 e5                	mov    %esp,%ebp
 147:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 14a:	8b 45 08             	mov    0x8(%ebp),%eax
 14d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 150:	90                   	nop
 151:	8b 45 08             	mov    0x8(%ebp),%eax
 154:	8d 50 01             	lea    0x1(%eax),%edx
 157:	89 55 08             	mov    %edx,0x8(%ebp)
 15a:	8b 55 0c             	mov    0xc(%ebp),%edx
 15d:	8d 4a 01             	lea    0x1(%edx),%ecx
 160:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 163:	0f b6 12             	movzbl (%edx),%edx
 166:	88 10                	mov    %dl,(%eax)
 168:	0f b6 00             	movzbl (%eax),%eax
 16b:	84 c0                	test   %al,%al
 16d:	75 e2                	jne    151 <strcpy+0xd>
    ;
  return os;
 16f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 172:	c9                   	leave  
 173:	c3                   	ret    

00000174 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 174:	55                   	push   %ebp
 175:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 177:	eb 08                	jmp    181 <strcmp+0xd>
    p++, q++;
 179:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 17d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 181:	8b 45 08             	mov    0x8(%ebp),%eax
 184:	0f b6 00             	movzbl (%eax),%eax
 187:	84 c0                	test   %al,%al
 189:	74 10                	je     19b <strcmp+0x27>
 18b:	8b 45 08             	mov    0x8(%ebp),%eax
 18e:	0f b6 10             	movzbl (%eax),%edx
 191:	8b 45 0c             	mov    0xc(%ebp),%eax
 194:	0f b6 00             	movzbl (%eax),%eax
 197:	38 c2                	cmp    %al,%dl
 199:	74 de                	je     179 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 19b:	8b 45 08             	mov    0x8(%ebp),%eax
 19e:	0f b6 00             	movzbl (%eax),%eax
 1a1:	0f b6 d0             	movzbl %al,%edx
 1a4:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a7:	0f b6 00             	movzbl (%eax),%eax
 1aa:	0f b6 c0             	movzbl %al,%eax
 1ad:	29 c2                	sub    %eax,%edx
 1af:	89 d0                	mov    %edx,%eax
}
 1b1:	5d                   	pop    %ebp
 1b2:	c3                   	ret    

000001b3 <strlen>:

uint
strlen(char *s)
{
 1b3:	55                   	push   %ebp
 1b4:	89 e5                	mov    %esp,%ebp
 1b6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1b9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1c0:	eb 04                	jmp    1c6 <strlen+0x13>
 1c2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1c6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1c9:	8b 45 08             	mov    0x8(%ebp),%eax
 1cc:	01 d0                	add    %edx,%eax
 1ce:	0f b6 00             	movzbl (%eax),%eax
 1d1:	84 c0                	test   %al,%al
 1d3:	75 ed                	jne    1c2 <strlen+0xf>
    ;
  return n;
 1d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1d8:	c9                   	leave  
 1d9:	c3                   	ret    

000001da <memset>:

void*
memset(void *dst, int c, uint n)
{
 1da:	55                   	push   %ebp
 1db:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1dd:	8b 45 10             	mov    0x10(%ebp),%eax
 1e0:	50                   	push   %eax
 1e1:	ff 75 0c             	pushl  0xc(%ebp)
 1e4:	ff 75 08             	pushl  0x8(%ebp)
 1e7:	e8 32 ff ff ff       	call   11e <stosb>
 1ec:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1ef:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1f2:	c9                   	leave  
 1f3:	c3                   	ret    

000001f4 <strchr>:

char*
strchr(const char *s, char c)
{
 1f4:	55                   	push   %ebp
 1f5:	89 e5                	mov    %esp,%ebp
 1f7:	83 ec 04             	sub    $0x4,%esp
 1fa:	8b 45 0c             	mov    0xc(%ebp),%eax
 1fd:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 200:	eb 14                	jmp    216 <strchr+0x22>
    if(*s == c)
 202:	8b 45 08             	mov    0x8(%ebp),%eax
 205:	0f b6 00             	movzbl (%eax),%eax
 208:	3a 45 fc             	cmp    -0x4(%ebp),%al
 20b:	75 05                	jne    212 <strchr+0x1e>
      return (char*)s;
 20d:	8b 45 08             	mov    0x8(%ebp),%eax
 210:	eb 13                	jmp    225 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 212:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 216:	8b 45 08             	mov    0x8(%ebp),%eax
 219:	0f b6 00             	movzbl (%eax),%eax
 21c:	84 c0                	test   %al,%al
 21e:	75 e2                	jne    202 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 220:	b8 00 00 00 00       	mov    $0x0,%eax
}
 225:	c9                   	leave  
 226:	c3                   	ret    

00000227 <gets>:

char*
gets(char *buf, int max)
{
 227:	55                   	push   %ebp
 228:	89 e5                	mov    %esp,%ebp
 22a:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 22d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 234:	eb 42                	jmp    278 <gets+0x51>
    cc = read(0, &c, 1);
 236:	83 ec 04             	sub    $0x4,%esp
 239:	6a 01                	push   $0x1
 23b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 23e:	50                   	push   %eax
 23f:	6a 00                	push   $0x0
 241:	e8 47 01 00 00       	call   38d <read>
 246:	83 c4 10             	add    $0x10,%esp
 249:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 24c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 250:	7e 33                	jle    285 <gets+0x5e>
      break;
    buf[i++] = c;
 252:	8b 45 f4             	mov    -0xc(%ebp),%eax
 255:	8d 50 01             	lea    0x1(%eax),%edx
 258:	89 55 f4             	mov    %edx,-0xc(%ebp)
 25b:	89 c2                	mov    %eax,%edx
 25d:	8b 45 08             	mov    0x8(%ebp),%eax
 260:	01 c2                	add    %eax,%edx
 262:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 266:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 268:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 26c:	3c 0a                	cmp    $0xa,%al
 26e:	74 16                	je     286 <gets+0x5f>
 270:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 274:	3c 0d                	cmp    $0xd,%al
 276:	74 0e                	je     286 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 278:	8b 45 f4             	mov    -0xc(%ebp),%eax
 27b:	83 c0 01             	add    $0x1,%eax
 27e:	3b 45 0c             	cmp    0xc(%ebp),%eax
 281:	7c b3                	jl     236 <gets+0xf>
 283:	eb 01                	jmp    286 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 285:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 286:	8b 55 f4             	mov    -0xc(%ebp),%edx
 289:	8b 45 08             	mov    0x8(%ebp),%eax
 28c:	01 d0                	add    %edx,%eax
 28e:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 291:	8b 45 08             	mov    0x8(%ebp),%eax
}
 294:	c9                   	leave  
 295:	c3                   	ret    

00000296 <stat>:

int
stat(char *n, struct stat *st)
{
 296:	55                   	push   %ebp
 297:	89 e5                	mov    %esp,%ebp
 299:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 29c:	83 ec 08             	sub    $0x8,%esp
 29f:	6a 00                	push   $0x0
 2a1:	ff 75 08             	pushl  0x8(%ebp)
 2a4:	e8 0c 01 00 00       	call   3b5 <open>
 2a9:	83 c4 10             	add    $0x10,%esp
 2ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2b3:	79 07                	jns    2bc <stat+0x26>
    return -1;
 2b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2ba:	eb 25                	jmp    2e1 <stat+0x4b>
  r = fstat(fd, st);
 2bc:	83 ec 08             	sub    $0x8,%esp
 2bf:	ff 75 0c             	pushl  0xc(%ebp)
 2c2:	ff 75 f4             	pushl  -0xc(%ebp)
 2c5:	e8 03 01 00 00       	call   3cd <fstat>
 2ca:	83 c4 10             	add    $0x10,%esp
 2cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2d0:	83 ec 0c             	sub    $0xc,%esp
 2d3:	ff 75 f4             	pushl  -0xc(%ebp)
 2d6:	e8 c2 00 00 00       	call   39d <close>
 2db:	83 c4 10             	add    $0x10,%esp
  return r;
 2de:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2e1:	c9                   	leave  
 2e2:	c3                   	ret    

000002e3 <atoi>:

int
atoi(const char *s)
{
 2e3:	55                   	push   %ebp
 2e4:	89 e5                	mov    %esp,%ebp
 2e6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2e9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2f0:	eb 25                	jmp    317 <atoi+0x34>
    n = n*10 + *s++ - '0';
 2f2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2f5:	89 d0                	mov    %edx,%eax
 2f7:	c1 e0 02             	shl    $0x2,%eax
 2fa:	01 d0                	add    %edx,%eax
 2fc:	01 c0                	add    %eax,%eax
 2fe:	89 c1                	mov    %eax,%ecx
 300:	8b 45 08             	mov    0x8(%ebp),%eax
 303:	8d 50 01             	lea    0x1(%eax),%edx
 306:	89 55 08             	mov    %edx,0x8(%ebp)
 309:	0f b6 00             	movzbl (%eax),%eax
 30c:	0f be c0             	movsbl %al,%eax
 30f:	01 c8                	add    %ecx,%eax
 311:	83 e8 30             	sub    $0x30,%eax
 314:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 317:	8b 45 08             	mov    0x8(%ebp),%eax
 31a:	0f b6 00             	movzbl (%eax),%eax
 31d:	3c 2f                	cmp    $0x2f,%al
 31f:	7e 0a                	jle    32b <atoi+0x48>
 321:	8b 45 08             	mov    0x8(%ebp),%eax
 324:	0f b6 00             	movzbl (%eax),%eax
 327:	3c 39                	cmp    $0x39,%al
 329:	7e c7                	jle    2f2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 32b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 32e:	c9                   	leave  
 32f:	c3                   	ret    

00000330 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 330:	55                   	push   %ebp
 331:	89 e5                	mov    %esp,%ebp
 333:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 336:	8b 45 08             	mov    0x8(%ebp),%eax
 339:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 33c:	8b 45 0c             	mov    0xc(%ebp),%eax
 33f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 342:	eb 17                	jmp    35b <memmove+0x2b>
    *dst++ = *src++;
 344:	8b 45 fc             	mov    -0x4(%ebp),%eax
 347:	8d 50 01             	lea    0x1(%eax),%edx
 34a:	89 55 fc             	mov    %edx,-0x4(%ebp)
 34d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 350:	8d 4a 01             	lea    0x1(%edx),%ecx
 353:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 356:	0f b6 12             	movzbl (%edx),%edx
 359:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 35b:	8b 45 10             	mov    0x10(%ebp),%eax
 35e:	8d 50 ff             	lea    -0x1(%eax),%edx
 361:	89 55 10             	mov    %edx,0x10(%ebp)
 364:	85 c0                	test   %eax,%eax
 366:	7f dc                	jg     344 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 368:	8b 45 08             	mov    0x8(%ebp),%eax
}
 36b:	c9                   	leave  
 36c:	c3                   	ret    

0000036d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 36d:	b8 01 00 00 00       	mov    $0x1,%eax
 372:	cd 40                	int    $0x40
 374:	c3                   	ret    

00000375 <exit>:
SYSCALL(exit)
 375:	b8 02 00 00 00       	mov    $0x2,%eax
 37a:	cd 40                	int    $0x40
 37c:	c3                   	ret    

0000037d <wait>:
SYSCALL(wait)
 37d:	b8 03 00 00 00       	mov    $0x3,%eax
 382:	cd 40                	int    $0x40
 384:	c3                   	ret    

00000385 <pipe>:
SYSCALL(pipe)
 385:	b8 04 00 00 00       	mov    $0x4,%eax
 38a:	cd 40                	int    $0x40
 38c:	c3                   	ret    

0000038d <read>:
SYSCALL(read)
 38d:	b8 05 00 00 00       	mov    $0x5,%eax
 392:	cd 40                	int    $0x40
 394:	c3                   	ret    

00000395 <write>:
SYSCALL(write)
 395:	b8 10 00 00 00       	mov    $0x10,%eax
 39a:	cd 40                	int    $0x40
 39c:	c3                   	ret    

0000039d <close>:
SYSCALL(close)
 39d:	b8 15 00 00 00       	mov    $0x15,%eax
 3a2:	cd 40                	int    $0x40
 3a4:	c3                   	ret    

000003a5 <kill>:
SYSCALL(kill)
 3a5:	b8 06 00 00 00       	mov    $0x6,%eax
 3aa:	cd 40                	int    $0x40
 3ac:	c3                   	ret    

000003ad <exec>:
SYSCALL(exec)
 3ad:	b8 07 00 00 00       	mov    $0x7,%eax
 3b2:	cd 40                	int    $0x40
 3b4:	c3                   	ret    

000003b5 <open>:
SYSCALL(open)
 3b5:	b8 0f 00 00 00       	mov    $0xf,%eax
 3ba:	cd 40                	int    $0x40
 3bc:	c3                   	ret    

000003bd <mknod>:
SYSCALL(mknod)
 3bd:	b8 11 00 00 00       	mov    $0x11,%eax
 3c2:	cd 40                	int    $0x40
 3c4:	c3                   	ret    

000003c5 <unlink>:
SYSCALL(unlink)
 3c5:	b8 12 00 00 00       	mov    $0x12,%eax
 3ca:	cd 40                	int    $0x40
 3cc:	c3                   	ret    

000003cd <fstat>:
SYSCALL(fstat)
 3cd:	b8 08 00 00 00       	mov    $0x8,%eax
 3d2:	cd 40                	int    $0x40
 3d4:	c3                   	ret    

000003d5 <link>:
SYSCALL(link)
 3d5:	b8 13 00 00 00       	mov    $0x13,%eax
 3da:	cd 40                	int    $0x40
 3dc:	c3                   	ret    

000003dd <mkdir>:
SYSCALL(mkdir)
 3dd:	b8 14 00 00 00       	mov    $0x14,%eax
 3e2:	cd 40                	int    $0x40
 3e4:	c3                   	ret    

000003e5 <chdir>:
SYSCALL(chdir)
 3e5:	b8 09 00 00 00       	mov    $0x9,%eax
 3ea:	cd 40                	int    $0x40
 3ec:	c3                   	ret    

000003ed <dup>:
SYSCALL(dup)
 3ed:	b8 0a 00 00 00       	mov    $0xa,%eax
 3f2:	cd 40                	int    $0x40
 3f4:	c3                   	ret    

000003f5 <getpid>:
SYSCALL(getpid)
 3f5:	b8 0b 00 00 00       	mov    $0xb,%eax
 3fa:	cd 40                	int    $0x40
 3fc:	c3                   	ret    

000003fd <sbrk>:
SYSCALL(sbrk)
 3fd:	b8 0c 00 00 00       	mov    $0xc,%eax
 402:	cd 40                	int    $0x40
 404:	c3                   	ret    

00000405 <sleep>:
SYSCALL(sleep)
 405:	b8 0d 00 00 00       	mov    $0xd,%eax
 40a:	cd 40                	int    $0x40
 40c:	c3                   	ret    

0000040d <uptime>:
SYSCALL(uptime)
 40d:	b8 0e 00 00 00       	mov    $0xe,%eax
 412:	cd 40                	int    $0x40
 414:	c3                   	ret    

00000415 <procstat>:
SYSCALL(procstat)
 415:	b8 16 00 00 00       	mov    $0x16,%eax
 41a:	cd 40                	int    $0x40
 41c:	c3                   	ret    

0000041d <setpriority>:
SYSCALL(setpriority)
 41d:	b8 17 00 00 00       	mov    $0x17,%eax
 422:	cd 40                	int    $0x40
 424:	c3                   	ret    

00000425 <semget>:
SYSCALL(semget)
 425:	b8 18 00 00 00       	mov    $0x18,%eax
 42a:	cd 40                	int    $0x40
 42c:	c3                   	ret    

0000042d <semfree>:
SYSCALL(semfree)
 42d:	b8 19 00 00 00       	mov    $0x19,%eax
 432:	cd 40                	int    $0x40
 434:	c3                   	ret    

00000435 <semdown>:
SYSCALL(semdown)
 435:	b8 1a 00 00 00       	mov    $0x1a,%eax
 43a:	cd 40                	int    $0x40
 43c:	c3                   	ret    

0000043d <semup>:
SYSCALL(semup)
 43d:	b8 1b 00 00 00       	mov    $0x1b,%eax
 442:	cd 40                	int    $0x40
 444:	c3                   	ret    
