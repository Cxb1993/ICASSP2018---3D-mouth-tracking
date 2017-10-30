function xd = apply_distortion(x,k,alpha)

  if ~exist( 'alpha', 'var' )
    % Default: no skew distorsion
    alpha = 0;
  end

  % Complete the distortion vector if you are using the simple distortion model:
  k = k(:);
  length_k = length(k);
  if length_k < 5 ,
    k = [k ; zeros(5-length_k,1)];
  end;
  

  [m,n] = size(x);

  % Add distortion:

  r2 = x(1,:).^2 + x(2,:).^2;

  r4 = r2.^2;

  r6 = r2.^3;


  % Radial distortion:

  cdist = 1 + k(1) * r2 + k(2) * r4 + k(5) * r6;

  xd1 = x .* (ones(2,1)*cdist);

  coeff = (reshape([cdist;cdist],2*n,1)*ones(1,3));

  % tangential distortion:

  a1 = 2.*x(1,:).*x(2,:);
  a2 = r2 + 2*x(1,:).^2;
  a3 = r2 + 2*x(2,:).^2;

  delta_x = [k(3)*a1 + k(4)*a2 ;
	     k(3) * a3 + k(4)*a1];

  aa = (2*k(3)*x(2,:)+6*k(4)*x(1,:))'*ones(1,3);
  bb = (2*k(3)*x(1,:)+2*k(4)*x(2,:))'*ones(1,3);
  cc = (6*k(3)*x(2,:)+2*k(4)*x(1,:))'*ones(1,3);

  xd2 = xd1 + delta_x;

  % skew distortion

  xd2( 1,: ) = xd2( 1,: ) + alpha * xd2( 2, : );

  % Return value

  xd = xd2;
