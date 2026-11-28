import {json,settings} from '../_utils.js';export async function onRequestGet({env}){try{return json({enabled:await settings(env,'promotion_mode')==='true'})}catch{return json({enabled:false})}}
