if typeof String.prototype.trim is "undefined"
  String.prototype.trim=->
    String(this).replace /^\s+|\s+$/g, ''

$ = (id) -> document.getElementById id

parse_cardno = (cardno) ->
  cardno = cardno.replace(/\s+/g, '').replace(/-/g, '')
  if cardno.length is 16
    (cardno.substring x,x+4 for x in [0..12] by 4).join "-"
  else cardno

parse_dt=(dt)->
  [year,month,date] = dt.replace(/\./g, "-").replace(/\//g, "-").replace(/\s+/g, '').split('-')
  lpad=(val)-> if val.length is 1 then "0"+val else val
  (lpad(x) for x in [year,month,date]).join("-")

gen_script=(cardno, icno, name, begdt, expdt) ->
  template = "\
UPDATE lyt_card \n\
   SET begdt = TO_DATE ('$begdt 00:00:00', 'yyyy-mm-dd hh24:mi:ss'), \n\
       expdt = TO_DATE ('$expdt 23:59:59', 'yyyy-mm-dd hh24:mi:ss'), \n\
       name = '$name', \n\
       icno = '$icno' \n\
 WHERE cardno IN ('$cardno');\n\
UPDATE lyt_cardgift \n\
   SET expdt = TO_DATE ('$expdt 23:59:59', 'yyyy-mm-dd hh24:mi:ss') \n\
 WHERE cardctlno IN (SELECT cardctlno \n\
                       FROM lyt_card \n\
                      WHERE cardno IN ('$cardno'));\n\
COMMIT;\n";
  cfg = [
    [/\$cardno/g,cardno]
    [/\$icno/g,icno]
    [/\$name/g,name]
    [/\$begdt/g,begdt]
    [/\$expdt/g,expdt]
  ]
  h=(pattern,val)-> template= template.replace pattern, val
  h(x[0],x[1]) for x in cfg
  template

form_inc=(()->
  _cont=0
  ()->
    ++_cont
  )()

add_record=()->
  row_template = $ 'row_template'
  container = $ 'container'
  form = document.createElement "FORM"
  formid = "form_" + form_inc()
  form.id = form.name = formid
  form.innerHTML = row_template.innerHTML
  container.appendChild form
  form["btn_remove"].onclick=()->
    if confirm "really delete?"
      form["btn_remove"]=null
      container.removeChild(form)


$('btn_add').onclick = add_record
$('btn_gen').onclick =()->
  format_dt=(dt)->
    lpad=(val)-> if val <10 then "0"+val else val
    h=[
      ()->this.getFullYear()
      ()->lpad(this.getMonth() + 1)
      ()->lpad this.getDate()
      ()->"T"
      ()->lpad this.getHours()
      ()->lpad this.getMinutes()
      ()->lpad this.getSeconds()
    ]
    (x.call(dt) for x in h).join('')
  $("txt_filename").value = format_dt(new Date()) + ".sql"

  val=(form,field)->form[field].value.trim()

  get_script=(form)->
    gen_script(
      parse_cardno(val(form, "txt_cardno")),
      val(form, "txt_icno"),
      val(form, "txt_name"),
      parse_dt(val(form, "txt_begdt")),
      parse_dt(val(form, "txt_expdt")))

  scripts=(get_script(form) for form in document.forms when form.name isnt "form_out")

  $("txt_out").value = ("--#{i+1}\n#{s}" for s,i in scripts).join("\n");

add_record()

