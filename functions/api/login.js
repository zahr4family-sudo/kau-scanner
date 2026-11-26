import {json,sha,clean,rand,settings,quotas,createUserSession} from './_utils.js';
export async function onRequestPost({request,env}){try{
const b=await request.json(),email=clean(b.email,180).toLowerCase();
if(!/^\S+@gmail\.com$/i.test(email))return json({error:'Masukkan Gmail akun KAU yang terdaftar.'},400);
const u=await env.DB.prepare('SELECT * FROM users WHERE email=?').bind(email).first();
if(!u)return json({error:'Gmail belum terdaftar. Lakukan pendaftaran pertama dan verifikasi OTP.'},404);
if(u.status!=='ACTIVE')return json({error:'Akun diblokir admin.'},403);
const fingerprint=clean(b.deviceFingerprint,240);if(!fingerprint)return json({error:'Identitas perangkat tidak terbaca.'},400);
const hash=await sha(fingerprint),device=await env.DB.prepare('SELECT * FROM user_devices WHERE fingerprint_hash=?').bind(hash).first();
if(device&&device.user_id!==u.id)return json({error:'Perangkat ini telah terikat pada Gmail lain. Hubungi admin untuk meminta izin penggunaan akun pada perangkat ini.'},403);
const found=device&&device.user_id===u.id,promo=await settings(env,'promotion_mode')==='true',q=quotas(u);
if(!found){const count=await env.DB.prepare('SELECT COUNT(*) n FROM user_devices WHERE user_id=? AND status=\'ACTIVE\'').bind(u.id).first();if(!promo&&!u.vip&&count.n>=q.devices)return json({error:'Batas perangkat tercapai. Hubungi admin untuk meminta tambahan perangkat.',limit:q.devices},403);
await env.DB.prepare('INSERT INTO user_devices(id,user_id,fingerprint_hash,label,status,created_at,last_seen) VALUES(?,?,?,?,?,?,?)').bind(rand(12),u.id,hash,clean(b.deviceLabel,80),'ACTIVE',Date.now(),Date.now()).run();
}else await env.DB.prepare('UPDATE user_devices SET last_seen=? WHERE id=?').bind(Date.now(),found.id).run();
const sessionToken=await createUserSession(env,u.id);return json({ok:true,userId:u.id,sessionToken,profile:{teacher_name:u.teacher_name,school:u.school,nip:u.nip,email:u.email,whatsapp:u.whatsapp,teacher_type:u.teacher_type,level:u.level},quotas:q,promotionMode:promo});
}catch(e){return json({error:'Login gagal. '+(e.message||'')},500)}}
