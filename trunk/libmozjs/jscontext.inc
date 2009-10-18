// this is additional code to js bridge which is supposed to get me to the frame pointer of JSContext which link to declared functons
// most of data are placeholders just to match the C objects
// warning, some types I only guess

//  PJSStackFrame = pointer;


  JSCList = record
    next : pointer;
    prev : pointer;
  end;
  

  JSStackFrame = record
    callobj: pointer;
    argsobj: pointer;
    varobj: pointer;
    script: pointer;
    fun : PJSFunction;   // toto je to co hladam
    
{    JSObject        *callobj;       /* lazily created Call object */
    JSObject        *argsobj;       /* lazily created arguments object */
    JSObject        *varobj;        /* variables object, where vars go */
    JSScript        *script;        /* script being interpreted */
    JSFunction      *fun;           /* function being called or null */
    JSObject        *thisp;         /* "this" pointer if in method */
    uintN           argc;           /* actual argument count */
    jsval           *argv;          /* base of argument stack slots */
    jsval           rval;           /* function return value */
    uintN           nvars;          /* local variable count */
    jsval           *vars;          /* base of variable stack slots */
    JSStackFrame    *down;          /* previous frame */
    void            *annotation;    /* used by Java security */
    JSObject        *scopeChain;    /* scope chain */
    jsbytecode      *pc;            /* program counter */
    jsval           *sp;            /* stack pointer */
    jsval           *spbase;        /* operand stack base */
    uintN           sharpDepth;     /* array/object initializer depth */
    JSObject        *sharpArray;    /* scope for #n= initializer vars */
    uint32          flags;          /* frame flags -- see below */
    JSStackFrame    *dormantNext;   /* next dormant frame chain */
    JSObject        *xmlNamespace;  /* null or default xml namespace in E4X */
    JSObject        *blockChain;    /* active compile-time block scopes */}
  end;
  
  PJSStackFrame = ^JSStackFrame;

  JSArena = record
    next : pointer; //JSArena     *next;          /* next arena for this lifetime */
    base: longword; //jsuword     base;           /* aligned base address, follows this header */
    limit: longword; //jsuword     limit;          /* one beyond last byte in arena */
    avail: longword; //jsuword     avail;          /* points to next available byte */
  end;
  
  JSArenaPool = record
    first: JSArena;//     first;          /* first arena in pool list */
    current: pointer; // JSArena     *current;       /* arena from which to allocate space */
    arenasize: longword; //size_t      arenasize;      /* net exact size of a new arena */
    mask: longword; //jsuword     mask;           /* alignment mask (power-of-2 - 1) */
//#ifdef JS_ARENAMETER
//    JSArenaStats stats;
//#endif}
  end;
  
  JSContext = record
    links: JSCList;
    
    // Interpreter activation count
    interpLevel: word; 

    // Limit pointer for checking stack consumption during recursion. */
    stackLimit: longword;

    // Runtime version control identifier and equality operators.
    version: word;
    jsop_eq: smallint;
    jsop_ne: smallint;

    // Data shared by threads in an address space. */
    runtime: PJSRuntime;

    // Stack arena pool and frame pointer register. */
    stackPool : JSArenaPool; //JSArenaPool         stackPool;  
    fp : PJSStackFrame;
    
  end;
  
