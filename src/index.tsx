import index from "./index.html";
import { Elysia } from 'elysia';


const app = new Elysia({

})
	.get('/*', index)
  .get("/api/hello", async(req) =>{

    return {
      message: "Hello, world!",
      method: "GET",
    }
  })
  .get('/api/hello/:name', async(req) => {
    const name = req.params.name;
    return {
      message: `Hello, ${name}!`,
    }
  })
	.listen(3000)


console.log(`🚀 Server running at ${app.server?.url}`);
