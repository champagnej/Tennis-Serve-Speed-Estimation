function out = coordstoimage(in,x,y)
    
    out = zeros(size(in));
    
    for i=1:length(x)
        j=x(i);
        k=y(i);
        out(k,j)=in(k,j);
    end
end