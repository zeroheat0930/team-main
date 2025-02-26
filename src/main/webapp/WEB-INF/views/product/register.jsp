<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="u" tagdir="/WEB-INF/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link rel="stylesheet"
  href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<script
  src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script
  src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
<script
  src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
<script src="https://kit.fontawesome.com/a076d05399.js"></script>

<script>
var appRoot = '${root }';
var productSeq = '${product.product_seq}';
var userSeq = '${authUser.user_seq}';
</script>
<script src="${root }/resources/product_js/category.js"></script>
<script>
	$(document).ready(function(){
				
		/* 카테고리 대분류를 선택하면 소분류를 ajax로 넘겨줘서가져옴-js파일사용 */
		$("#categoryMainSelectBox").on( 'change', function(){
			var categoryMain = $(this).find("option:selected").val();
			
			categoryService.getCategorySubList(categoryMain, function(list) {
				var subBox = $("#categorySubSelectBox");
				subBox.empty();
					subBox.append(
						'<option>===소분류===</option>'
					);
				for (var i = 0; i < list.length; i++) {
					subBox.append(
						'<option value="'+list[i]+'" >'+list[i]+'</option>'
					);
				}
			})
		});
		/* 카테고리 소분류를 선택하면 대분류+소분류에 맞는 seq를 가져와야함 */
		$("#categorySubSelectBox").on( 'change', function(){
			var categoryMain = $("#categoryMainSelectBox").find("option:selected").val();
			var categorySub = $(this).find("option:selected").val();
			var data = {category_main : categoryMain, category_sub : categorySub};
			categoryService.getCategorySeq(data, function(categorySeq) {
				$("#categorySeq").val(categorySeq);
			})
		});
			
		/*모달창함수설정(+redirect시 넘어온 메세지도 출력)  */
		var message = '${message}';
		checkModal(message);
/* 		history.replaceState({}, null, null); */
		function checkModal(message){
			if (message && history.state == null) {
				$("#myModal .modal-body p").html(message)
				$("#myModal").modal("show");
			}
		}
		
		/*모달창-전송누르기전에 항목이 비어있으면 안넘어감
			+ 수량가격에 소수점있으면 안넘어가게끔 */
		$("#btn_submit").click(function(e){
			e.preventDefault(); // 전송버튼 막기
				message = null;
				/*비어있으면 메세지넣고모달창호출  */
				if ($("#product_name").val().trim() == ""){
					message = "상품이름 항목이 비어있음";
				}
				if ($("#product_info").val().trim() == ""){
					message = "상품정보 항목이 비어있음";
				}
				
				$("input[name=po_quantity], input[name=po_price]").each(function(){
					var element = $(this).val();
					var element2 = Math.floor(element);
					
					if(element != element2){
						message = "수량 또는 가격에 소수점이 포함되어있음";
					}
					if(element <= 0){
						message = "수량 또는 가격이 0 이하임";
					}
					if(element.toString().length > 19){
						message = "수량 또는 가격의 자릿수가 너무 큽니다.";
					}
				});
				
				/* 바이트리턴하는 함수 object.byteLength()로 사용*/
				String.prototype.byteLength = function() {
				    var l= 0;
				     
				    for(var idx=0; idx < this.length; idx++) {
				        var c = escape(this.charAt(idx));
				         
				        if( c.length==1 ) l ++;
				        else if( c.indexOf("%u")!=-1 ) l += 2;
				        else if( c.indexOf("%")!=-1 ) l += c.length/3;
				    }
				    return l;
				};
				/* 제목 내용 상품옵션이름 바이트제한*/
				$("input[name=po_name], input[name=product_name], textarea[name=product_info]").each(function(){
					var element = $(this).val();
					console.log(element.byteLength());
					if(element.byteLength() > 255){
						message = "글자 길이가 너무 깁니다";
					}
				});
				
				checkModal(message);
	  	 		if(message == null){
				$("#form_id").submit();
			}
			
		})
		
		/* 클릭시 옵션추가 */
		$("#addOption_btn").click(function(){
			$("#optionBox").append(
				'<div class="input-group">'+
					'<div class="d-flex col-5">'+
					  '<input name="po_name" type="text" class="form-control" placeholder="상품옵션이름" >'+
					'</div>'+
					'<div class="d-flex col-2">'+
					  '<input min="1" name="po_quantity" type="number" class="form-control" placeholder="수량" >'+
					'</div>'+
					'<div class="d-flex col-2">'+
					 ' <input min="1" name="po_price" type="number" class="form-control" placeholder="개당가격" >'+
					'</div>'+
					'<div class="d-flex col-3 justify-content-end">'+
					'</div>'+
				'</div>'
			);
		});
				
		/* 클릭시 옵션제거 */
		$("#removeOption_btn").click(function(){
			var block = $("#optionBox div.input-group").length;
			if(block > 1){
				$("#optionBox div.input-group:last-child").remove();			
			}
		});
	});
	
</script>

<style>
#container {
    clear: both;
    position: relative;
    margin: 30px auto 0px;
    padding: 0 0 50px 0;
    width: 1000px;
    z-index: 1;
}
	.btn_add {
    color: #fff;
    font-size: 15px;
    border: none;
    background: #1e263c;
    padding: 0px 20px;
    margin: 0 0px;
    line-height: 45px;
    float: right;
	}
table.type05 {
  border-collapse: separate;
  border-spacing: 1px;
  text-align: left;
  line-height: 1.5;
  border-top: 1px solid #ccc;
}
table.type05 th {
  width: 200px;
  padding: 10px;
  font-weight: bold;
  vertical-align: top;
  border-bottom: 1px solid #ccc;
  background: #efefef;
}
table.type05 td {
  width: 350px;
  padding: 10px;
  vertical-align: top;
  border-bottom: 1px solid #ccc;
}
 /* 카테고리옵션 */
#categorySubSelectBox, #categoryMainSelectBox {
 width: 405px;
}
</style>

<title>상품 등록 페이지</title>
</head>
<body>

<u:mainNav/>
<div class="container">
	<section id="container">
	
		<h3>상품 등록</h3>
			<form id="form_id" action="${root }/product/register" method="post" enctype="multipart/form-data">
				<table class="type05">
					<tbody>
						<tr>
							<th scope="row">상품 이름 *</th>
							<td><input class="inputTop form-control" id="product_name" name="product_name" type="text" value="${product.product_name }"></td>
						</tr>
						<tr>
							<th scope="row">상품 판매자</th>
							<td><input class="inputTop form-control" id="user_nickname" name="user_nickname" type="text" value="${authUser.user_nickname }" style="background-color:silver;"readonly>
								<input id="product_seller" name="product_seller" type="text" value="${authUser.user_seq }" hidden="hidden">
							</td>
						</tr>
						<tr>
							<th scope="row">카테고리 선택 *</th>
							<td> 
								<div class="d-flex">
									<select class="custom-select" id="categoryMainSelectBox">
										<option>===대분류===</option>
										<c:forEach items="${ categoryMainList}" var="categoryMain" >
											<option value="${categoryMain }" >${categoryMain }</option>
										</c:forEach>
									</select>
									<select class="custom-select" id="categorySubSelectBox">
										<option>===소분류===</option>
									</select>
									<input id="categorySeq" name="category_seq" type="text" value="0" hidden="hidden">
								</div>
							</td>
						</tr>
						<tr>
							<th scope="row">상품 설명 *</th>
							<td><textarea class="inputTop form-control" style="resize: none;" id="product_info" name="product_info" rows="15" cols="50">${product.product_info }</textarea></td>
						</tr>
					</tbody>
				</table>
				
				<h5 class="my-3">상품 옵션 (첫번째 입력항목이 메인에 띄워집니다.)</h5>
				
				<div id="optionBox">
					<div class="input-group">
						<div class="d-flex col-5">
						  <input name="po_name" type="text" class="form-control" placeholder="상품옵션이름" >
						</div>
						<div class="d-flex col-2">
						  <input min="1" name="po_quantity" type="number" class="form-control" placeholder="수량" >
						</div>
						<div class="d-flex col-2">
						  <input min="1" name="po_price" type="number" class="form-control" placeholder="개당가격" >
						</div>
						<div class="d-flex col-3 justify-content-end">
						  <div class="input-group-append" id="button-addon4">
						    <button id="addOption_btn"  class="btn btn-outline-secondary" type="button">옵션추가</button>
						    <button id="removeOption_btn" class="btn btn-outline-secondary" type="button">옵션제거</button>
						  </div>
						</div>
					</div>

				</div>
				
				<h5 class="my-3">상품이미지 첨부* (반드시 한 개 이상의 이미지를 올려야합니다.)</h5>
				
				<!--이미지첨부시작  -->
					
					<div class = "input-group-text">
						 <input type="file" name="upload" id="input_imgs" multiple="multiple" accept="image/*"/>
					</div>	
					<div class="imgs_wrap">
						<img id="img"/>
					</div>
				
					<script>
					  
					  $("#input_imgs").on("change", handleImgFileSelect);
					  //이미지셀렉트
					  function handleImgFileSelect(e){
							//이미지 정보를 초기화
							$(".imgs_wrap").empty();
							
							var files = e.target.files;
							var filesArr = Array.prototype.slice.call(files);
						
							filesArr.forEach(function(f){
								if(!f.type.match("image.*")){
									
									// 이전에 쓰던 모달창 복붙한거로나오게
									var message = "그림파일형석만 허용됩니다";
									function checkModal(message){
										if (message && history.state == null) {
											$("#myModal .modal-body p").html(message)
											$("#myModal").modal("show");
										}
									}
									checkModal(message);
									
									return;
								}
								
								var reader = new FileReader();
								reader.onload = function(e){
									
									 var html = "<div><img width=\"500\" src=\""+e.target.result+"\"></div>";
									$(".imgs_wrap").append(html);
								
								}
								reader.readAsDataURL(f);
							});
					 }
				 	</script>
				<!--이미지첨부끝 -->
				
				<button id="btn_submit" class="btn_add">상품 등록</button>
				
			</form>

	
  </section>
</div>

	<!--모달창시작-->
	<div id="myModal" class="modal" tabindex="-1">
	  <div class="modal-dialog">
	    <div class="modal-content">
	      <div class="modal-header">
	        <h5 class="modal-title">알림</h5>
	        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
	          <span aria-hidden="true">&times;</span>
	        </button>
	      </div>
	      <div class="modal-body">
	        <p>처리가완료되었습니다</p>
	      </div>
	      <div class="modal-footer">
	        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
	      </div>
	    </div>
	  </div>
	</div>
	<!--모달창끝-->
<u:footer/>
</body>
</html>