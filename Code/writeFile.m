function writeFile(file_name, positions, recovered_v, sigma_theta, Kr, gamma, edge_x, edge_y, noise_xy, noise_theta, k)
    fid = fopen( file_name, 'wt' );
    fprintf( fid, strcat("start positions = ",mat2str(positions),"\n"));
    fprintf( fid, strcat("recovered_v = ",mat2str(recovered_v),"\n"));
    fprintf( fid, strcat("sigma_theta = ",mat2str(sigma_theta),"\n"));
    fprintf( fid, strcat("Kr = ",mat2str(Kr),"\n"));
    fprintf( fid, strcat("gamma = ",mat2str(gamma),"\n"));
    fprintf( fid, strcat("edge_x = ",mat2str(edge_x),"\n"));
    fprintf( fid, strcat("edge_y = ",mat2str(edge_y),"\n"));
    fprintf( fid, strcat("noise_xy = ",mat2str(noise_xy),"\n"));
    fprintf( fid, strcat("noise_theta = ",mat2str(noise_theta),"\n"));
    fprintf( fid, strcat("k = ",mat2str(k),"\n"));
    
    fclose(fid);
end

