function Mc = make_cruise_mask(xcruise,ycruise,grid,M3d,w,orient)
%MAKE_CRUISE_MASK Build a 3-D averaging mask along a cruise track.
%
% Syntax
%   Mc = make_cruise_mask(xcruise,ycruise,grid,M3d,w,orient)
%
% Description
%   Creates a binary mask aligned with the model grid to average fields
%   along a cruise track. The mask is constructed on the surface layer and
%   then replicated through depth. The cross-track width is ±w grid cells
%   around the nearest-gridline path obtained by interpolating the cruise
%   coordinates onto the grid axis set by ORIENT.
%
% Inputs
%   xcruise   Vector of cruise longitudes (same length as ycruise)
%   ycruise   Vector of cruise latitudes
%   grid      Grid struct with coordinate vectors:
%               .xt (1×nx) longitudes, .yt (1×ny) latitudes
%   M3d       ny×nx×nz ocean mask (used for size/template)
%   w         Half-width (in grid cells) for the averaging swath (integer)
%   orient    'zonal' or 'merid'
%               'zonal' : interpolate y(x) onto grid.xt, build bands in y
%               'merid' : interpolate x(y) onto grid.yt, build bands in x
%
% Output
%   Mc        ny×nx×nz mask with ones along the track swath, NaN elsewhere
%
% Notes
%   • The function does not clip swath indices to grid bounds; choose w so
%     that (iy(i)±w) or (ix(i)±w) remain within 1..ny or 1..nx for your grid.
%   • Duplicate x (or y) samples are collapsed with UNIQUE before 1-D interp.
%   • The mask is created on the surface layer and replicated to all nz.
%

[ny,nx,nz] = size(M3d);

switch orient
    case 'zonal'
        
        % find x and y indices
        [jnk,Iq] = unique(xcruise);
        yy = interp1(xcruise(Iq),ycruise(Iq),grid.xt);
        ix = find(~isnan(yy));
        iy = interp1(grid.yt,1:ny,yy(ix),'nearest');
        
        % make averaging mask
        Mc = M3d(:,:,1)*NaN;
        for i = 1:length(ix);
            Mc((iy(i)-w):(iy(i)+w),ix(i)) = 1;
        end
        Mc = repmat(Mc,[1 1 nz]);
 
        
    case 'merid'
        
        % find x and y indices
        [jnk,Iq] = unique(ycruise);
        xx = interp1(ycruise(Iq),xcruise(Iq),grid.yt);
        iy = find(~isnan(xx));
        ix = interp1(grid.xt,1:nx,xx(iy),'nearest');
        
        % make averaging mask
        Mc = M3d(:,:,1)*NaN;
        for i = 1:length(iy)
            Mc(iy(i),(ix(i)-w):(ix(i)+w)) = 1;
        end
        Mc = repmat(Mc,[1 1 nz]);
        
end
