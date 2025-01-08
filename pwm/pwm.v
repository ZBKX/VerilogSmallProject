module pwm
#(
    parameter A = 8
)
(
    input clk,
    input reset,
    input [A-1:0]period, //clock
    input [A-1:0]duty,  //duty <= period   
    output pwm_out
); 

    reg [A-1:0]period_count;
    reg [A-1:0]duty_count;
    reg real_out;

    always @(posedge clk or negedge reset) 
    begin
        if (~reset)
        begin
            period_count <= {A{1'b0}};
        end
        else
        begin
            if (period_count == (period - 1'd1))
            begin
                period_count <= {A{1'b0}};
            end
            else
            begin
                period_count <= period_count + 1'd1;
            end        
        end        
    end

    always @(posedge clk or negedge reset)
    begin
        if (~reset)
        begin
            duty_count <= {A{1'b0}};
        end
        else
        begin
            if (period_count == (period - 1'd1))
            begin
                duty_count <= {A{1'b0}};
            end    
            else 
            begin
                duty_count <= duty_count + 1'd1;                    
            end    
        end        
    end

    always @(*)
    begin
        if (duty_count >= duty)
        begin
            real_out = 1'b0;
        end
        else
        begin
            real_out = 1'b1;
        end        
    end    

    assign pwm_out = real_out;  
endmodule
