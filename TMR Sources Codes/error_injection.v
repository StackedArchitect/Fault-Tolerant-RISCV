`timescale 1ns / 1ps

// Enhanced error injection module that can inject errors into encoded data
module error_injection_enhanced(
    input clk,
    input rst,
    input inject_enable,
    input [1:0] error_type,        // 00=none, 01=single, 10=double, 11=random
    input [5:0] error_position,
    input [31:0] data_in,
    input [67:0] encoded_in,       // Full encoded data
    input use_encoded,             // Select between data_in and encoded_in
    output reg [31:0] data_out,
    output reg [67:0] encoded_out
);

    reg [31:0] error_mask_data;
    reg [67:0] error_mask_encoded;
    
    always @(posedge clk) begin
        if (rst) begin
            data_out <= 32'h0;
            encoded_out <= 68'h0;
            error_mask_data <= 32'h0;
            error_mask_encoded <= 68'h0;
        end else begin
            // Generate error masks
            error_mask_data <= 32'h0;
            error_mask_encoded <= 68'h0;
            
            if (inject_enable) begin
                case (error_type)
                    2'b01: begin // Single bit error - flips selected bit
                        if (use_encoded && error_position < 68) begin
                            error_mask_encoded[error_position] <= 1'b1;
                        end else if (!use_encoded && error_position < 32) begin
                            error_mask_data[error_position] <= 1'b1;
                        end
                    end
                    
                    2'b10: begin // Double bit error
                        if (use_encoded && error_position < 67) begin
                            error_mask_encoded[error_position] <= 1'b1;
                            error_mask_encoded[error_position + 1] <= 1'b1;
                        end else if (!use_encoded && error_position < 31) begin
                            error_mask_data[error_position] <= 1'b1;
                            error_mask_data[error_position + 1] <= 1'b1;
                        end
                    end
                    
                    2'b11: begin // Random errors
                        if (use_encoded) begin
                            error_mask_encoded <= {$random, $random} & 68'h3FFFFFFFFFFFFFFFF;
                        end else begin
                            error_mask_data <= $random;
                        end
                    end
                endcase
            end
            
            // Apply error masks
            data_out <= data_in ^ error_mask_data;
            encoded_out <= encoded_in ^ error_mask_encoded;
        end
    end

endmodule