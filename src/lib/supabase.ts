import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) throw new Error('Missing Supabase environment variables')

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

export async function loadSiteContent(): Promise<unknown | null> {
  const { data, error } = await supabase.from('site_content').select('content').eq('id', 'default').maybeSingle()
  if (error) { console.error('Could not load site content:', error); return null }
  return data?.content ?? null
}

export async function saveSiteContent(content: unknown): Promise<void> {
  const { error } = await supabase.from('site_content').upsert({ id: 'default', content, updated_at: new Date().toISOString() })
  if (error) console.error('Could not save site content:', error)
}

export async function uploadImage(file: File, folder: string): Promise<string> {
  const safeName = file.name.replace(/[^a-zA-Z0-9._-]/g, '-')
  const path = `${folder}/${crypto.randomUUID()}-${safeName}`
  const { error } = await supabase.storage.from('MIRATE-IMAGES').upload(path, file, { contentType: file.type, upsert: false })
  if (error) throw error
  return supabase.storage.from('MIRATE-IMAGES').getPublicUrl(path).data.publicUrl
}
