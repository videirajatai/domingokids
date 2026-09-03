         function showLoading(show) { 
              document.getElementById('loading').style.display = show ? 'flex' : 'none'; }

          function showToast(msg, isError) { 
              const t=document.getElementById('toast'); 
              t.textContent=msg; 
              t.className=`fixed top-5 right-5 px-6 py-3 rounded-lg shadow-xl text-white font-medium z-50 ${isError?'bg-red-600':'bg-slate-800'}`; 
              t.style.display='block'; 
              setTimeout(()=>t.style.display='none',3000); 
          }
