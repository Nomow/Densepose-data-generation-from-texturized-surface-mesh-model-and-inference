function [u, v, w] = barycentric_coordinates(p, a, b, c)
    v0 = b - a;
    v1 = c - a;
    v2 = p - a;
    d00 = dot(v0, v0, 2);
    d01 = dot(v0, v1, 2);
    d11 = dot(v1, v1, 2);
    d20 = dot(v2, v0, 2);
    d21 = dot(v2, v1, 2);
    denom = d00 .* d11 - d01 .* d01;
    v = (d11 .* d20 - d01 .* d21) ./ denom;
    w = (d00 .* d21 - d01 .* d20) ./ denom;
    u = repmat(1, size(p, 1), 1) - v - w;
end

