function drawax3D(a)
    % x
    quiver3(0,0,0,-a,0,0,'k'), hold on
    quiver3(0,0,0,a,0,0,'k')
    text(a,0,0,'X','Color','k');
    
    % y
    quiver3(0,0,0,0,-a,0,'k')
    quiver3(0,0,0,0,a,0,'k')
    text(0,a,0,'Y','Color','k');
    
    % z
    quiver3(0,0,0,0,0,-a,'k')
    quiver3(0,0,0,0,0,a,'k')
    text(0,0,a,'Z','Color','k');
    hold off
    
    xlim(a*[-1,1])
    ylim(a*[-1,1])
    zlim(a*[-1,1])
end