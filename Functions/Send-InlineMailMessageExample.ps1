    $images = @{ 
        image1 = 'C:\TEMP\backup_images\backup_10-10_to_10-27_2014.PNG' 
        image2 = 'C:\TEMP\backup_images\backup_1-10_to_1-21_2014.PNG' 
    }  
    
    $body = '<html>  
               <body>  
                 <img src="cid:image1"><br> 
                 <img src="cid:image2"> 
               </body>  
             </html>'  
    
    $params = @{ 
        InlineAttachments = $images 
        Body              = $body 
        BodyAsHtml        = $true 
        Subject           = 'Test email' 
        From              = 'poshalerts@sonymusic.com' 
        To                = 'sconnea@sonymusic.com' 
        SmtpServer        = 'ussmtp01.bmg.bagint.com'
    } 
    
    Send-InlineMailMessage @params