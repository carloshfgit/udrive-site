import { defineConfig } from 'vite'
import { resolve } from 'path'

export default defineConfig({
  build: {
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index.html'),
        termos: resolve(__dirname, 'termos-uso.html'),
        privacidade: resolve(__dirname, 'politica-privacidade.html')
      }
    }
  }
})
