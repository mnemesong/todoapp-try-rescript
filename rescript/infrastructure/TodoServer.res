%%raw(`
const express = require("express")
const app = express();
const sessions = require("express-session")
app.use(
  sessions({
    secret: '98n9ub87g80',
    cookie: {
      maxAge: 1000 * 60 * 60 * 24, // 24 hours
    },
    resave: true,
    saveUninitialized: false,
  })
);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
const unregisteredRedirectPath = '/login';
const registeredRedirectPath = '/';
`)

type access = [ #anyone | #guest | #registered]

type serverReq = [ #get | #post ]

type serverRespType = [ #html | #json | #redirect ]

type serverResp = {
    tp: serverRespType,
    data: string,
}

type session = {
    userid: string,
}

type request<'a> = {
    session: session,
    body: 'a,
}

let handle: (
    string, 
    access, 
    serverReq, 
    (request<'a>) => serverResp
) => unit = %raw(`
function(path, access, serverReq, pipe) {
    const handler = (req, res) => {
        if(access === 'registered') {
            if (!req.session['userid']) {
                return res.redirect(unregisteredRedirectPath);
            }
        }
        if(access === 'guest') {
            if (req.session['userid']) {
                return res.redirect(registeredRedirectPath);
            }
        }
        const pipeResult = pipe(req);
        if(pipeResult.tp === 'html') {
            res.setHeader('Content-Type', 'text/HTML');
            res.write(pipeResult.data);
            res.end();
        }
        if(pipeResult.tp === 'json') {
            res.setHeader('Content-Type', 'application/json');
            res.write(pipeResult.data);
            res.end();
        }
        if(pipeResult.tp === 'redirect') {
            res.redirect(pipeResult.data);
        }
    }
    if(serverReq === 'get') {
        app.get(path, handler);
    }
    if(serverReq === 'post') {
        spp.post(path, handler);
    }
}   
`)

handle("/", #registered, #get, (req: request<unknown>) => {
    tp: #html,
    data: `
    <h1>Welcome back ${req.session.userid}</h1>
    <a href="/logout">Logout</a>
`
})

handle("/login", #guest, #get, (req: request<unknown>) => {
    tp: #html,
    data: `
    <h1>Login</h1>
    <form method="post" action="/process-login">
      <input type="text" name="username" placeholder="Username" /> <br>
      <input type="password" name="password" placeholder="Password" /> <br>
      <button type="submit">Login</button>
    </form>
`
})

%%raw(`

app.post('/process-login', (req, res) => {
  if (req.body.username !== 'admin' || req.body.password !== 'admin') {
    return res.send('Invalid username or password');
  }
  req.session['userid'] = req.body.username;
  res.redirect('/');
})

app.get('/logout', (req, res) => {
  req.session.destroy((e) => {console.log("Session destory erorr: ", e)});
  res.redirect('/');
})
`)

let run: (int) => unit = %raw(`
function(port) {
    app.listen(port, () => {
      console.log('Server Running at port ' + port);
    });
}
`)

run(3000)