import Router from '@koa/router'
import type {Context} from 'koa'

export async function initRouter(): Promise<Router> {
  const router = new Router().get('/', pong)

  return router
}

export async function pong(context: Context): Promise<void> {
  context.body = JSON.stringify({message: 'pong'})
  context.status = 200
}
