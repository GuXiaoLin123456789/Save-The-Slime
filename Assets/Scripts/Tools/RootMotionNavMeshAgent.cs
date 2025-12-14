using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.AI;
#if UNITY_EDITOR
using UnityEditor;
#endif

public enum RemainingDistanceType
{
    /// <summary>
    /// 如果角色指定了目的地，此模式代表角色位置到目的地之间的距离。
    /// 如果角色指定了移动路径，此模式代表角色位置到移动路径终点之间的距离。
    /// </summary>
    PathEnd,

    /// <summary>
    /// 如果角色指定了目的地，此模式代表角色位置到目的地之间的距离。
    /// 如果角色指定了移动路径，此模式代表角色位置到下一个路径点之间的距离。
    /// </summary>
    WayPoint,

    /// <summary>
    /// 角色位置到下一个转向点之间的位置。
    /// 转向点可能是移动轨迹中的任意位置，不一定是给定的路径中的路径点。
    /// </summary>
    SteeringPoint
}


[DisallowMultipleComponent]
[RequireComponent(typeof(Animator))]
[RequireComponent(typeof(NavMeshAgent))]
public class RootMotionNavMeshAgent : MonoBehaviour
{
    /// <summary>
    /// 若角色当前朝向与目标朝向之间的夹角小于此角度，则使角色停止转向。
    /// </summary>
    public const float RotateStopAngle = 1f;

    /// <summary>
    /// 设置是否激活组件。
    /// </summary>
    public bool Enabled
    {
        get
        {
            return enabled;
        }
        set
        {
            if (enabled && value == false)
            {
                StopMoving();
            }

            enabled = value;
        }
    }

    /// <summary>
    /// 目标朝向。
    /// </summary>
    public Vector3? TargetForward { get; private set; }

    /// <summary>
    /// 目的地。
    /// </summary>
    public Vector3? Destination { get; private set; }

    /// <summary>
    /// 导航路径点（由 <see cref="NavMeshAgent"/> 计算得出）。
    /// </summary>
    public IEnumerable<Vector3> NavPathCorners { get { return _navMeshAgent.path.corners; } }

    /// <summary>
    /// 移动路径点（由外部指定）。
    /// </summary>
    public IEnumerable<Vector3> MovingPath { get { return _movingPath; } }

    /// <summary>
    /// 转身速度（角度/秒）。
    /// </summary>
    public float AngularSpeed
    {
        get { return _navMeshAgent.angularSpeed; }
        set { _navMeshAgent.angularSpeed = value; }
    }

    /// <summary>
    /// 若角色当前位置与目的地的距离（<see cref="GetRemainingLinearDistance"/>）小于此值（米），则视为到达目的地，使角色停止移动。
    /// </summary>
    public float StoppingDistance
    {
        get { return _navMeshAgent.stoppingDistance; }
        set { _navMeshAgent.stoppingDistance = value; }
    }

    /// <summary>
    /// 若角色当前位置与目的地的距离（<see cref="GetRemainingLinearDistance"/>）小于此值（米），则视为接近目标点，使角色开始减速。
    /// 若沿给定路径点移动，则在接近目标点时，使角色开始向路径中的下一个目标点移动。
    /// </summary>
    public float ApproachDistance
    {
        get { return _approachDistance; }
        set { _approachDistance = value; }
    }

    /// <summary>
    /// 控制角色移动的动画参数名称。
    /// </summary>
    public string AnimationLocomotionParam
    {
        get { return _animationLocomotionParam; }
        set
        {
            _animationLocomotionParam = value;
            _animationLocomotionParamHash = Animator.StringToHash(_animationLocomotionParam);
        }
    }

    /// <summary>
    /// 使角色原地站立的动画参数值。
    /// </summary>
    public float AnimationStandingValue
    {
        get { return _animationStandingValue; }
        set { _animationStandingValue = value; }
    }

    /// <summary>
    /// 使角色向前移动的动画参数值。
    /// </summary>
    public float AnimationMovingValue
    {
        get { return _animationMovingValue; }
        set { _animationMovingValue = value; }
    }

    /// <summary>
    /// 使角色向前移动的动画参数最小值。
    /// </summary>
    public float AnimationMovingMinValue
    {
        get { return _animationMovingMinValue; }
        set { _animationMovingMinValue = value; }
    }

    /// <summary>
    /// 角色移动动画参数的Damp时长（秒）。
    /// </summary>
    public float AnimationLocomotionValueDampTime
    {
        get { return _animationLocomotionValueDampTime; }
        set { _animationLocomotionValueDampTime = value; }
    }

    /// <summary>
    /// 根据给定点在NavMesh上采样位置时，可以使用的最大偏移距离（米）。
    /// </summary>
    public float MaxNavMeshSampleDistance
    {
        get { return _maxNavMeshSampleDistance; }
        set { _maxNavMeshSampleDistance = value; }
    }

    /// <summary>
    /// 在NavMesh上采样位置时，使用的区域遮罩。
    /// </summary>
    public int NavMeshAreaMask
    {
        get { return _navMeshAreaMask; }
        set { _navMeshAreaMask = value; }
    }


    /// <summary>
    /// 控制角色移动的动画参数名称。
    /// </summary>
    [SerializeField]
    private string _animationLocomotionParam = "F_MoveSpeed";

    /// <summary>
    /// 使角色原地站立的动画参数值。
    /// </summary>
    [SerializeField]
    private float _animationStandingValue = 0.0f;

    /// <summary>
    /// 使角色向前移动的动画参数值。
    /// </summary>
    [SerializeField]
    private float _animationMovingValue = 1.0f;

    /// <summary>
    /// 使角色向前移动的动画参数最小值。
    /// </summary>
    [SerializeField]
    private float _animationMovingMinValue = 0.3f;

    /// <summary>
    /// 角色移动动画参数的Damp时长（秒）。
    /// </summary>
    [Range(0f, 0.5f)]
    [SerializeField]
    private float _animationLocomotionValueDampTime = 0.1f;

    /// <summary>
    /// 根据给定点在NavMesh上采样位置时，可以使用的最大偏移距离（米）。
    /// </summary>
    [SerializeField]
    private float _maxNavMeshSampleDistance = 0.5f;

    /// <summary>
    /// 在NavMesh上采样位置时，使用的区域遮罩。
    /// </summary>
    [SerializeField]
    private int _navMeshAreaMask = NavMesh.AllAreas;

    /// <summary>
    /// 若角色当前位置与目的地的距离（<see cref="GetRemainingLinearDistance"/>）小于此值（米），则视为接近目标点，使角色开始减速。
    /// 若沿给定路径点移动，则在接近目标点时，使角色开始向路径中的下一个目标点移动。
    /// </summary>
    [SerializeField]
    private float _approachDistance = 0.8f;

    /// <summary>
    /// 动画机。
    /// </summary>
    private Animator _animator;

    /// <summary>
    /// 导航代理。
    /// </summary>
    private NavMeshAgent _navMeshAgent;

    /// <summary>
    /// 移动路径点（由外部指定）。
    /// </summary>
    private readonly Queue<Vector3> _movingPath = new Queue<Vector3>();

    /// <summary>
    /// 转向停止时的回调。
    /// 参数1：是否已转到目标方向。
    /// </summary>
    private Action<bool> _rotateStopCallback;

    /// <summary>
    /// 移动停止时的回调。
    /// 参数1：是否抵达目的地。
    /// </summary>
    private Action<bool> _moveStopCallback;

    /// <summary>
    /// 控制角色移动的动画参数Hash。
    /// </summary>
    private int _animationLocomotionParamHash;

    /// <summary>
    /// 动画机移动参数值。
    /// </summary>
    private float _animationLocomotionValue;

    /// <summary>
    /// 动画机移动参数值Damp辅助字段。
    /// </summary>
    private float _animationLocomotionValueDampVelocity;

    // 测试代码
    //[SerializeField]
    //private List<Vector3> _pathBuffer = new List<Vector3>();



    /// <summary>
    /// 设置角色朝向。
    /// </summary>
    /// <param name="forward">目标朝向。</param>
    /// <param name="stopMoving">是否停止正在进行的导航。</param>
    /// <param name="onRotateStop">转向停止时的回调，参数1：是否已转到目标方向。</param>
    /// <returns></returns>
    public bool SetForward(Vector3 forward, bool stopMoving = false, Action<bool> onRotateStop = null)
    {
        StopRotating();

        forward.y = 0;

        if (forward.sqrMagnitude < Mathf.Epsilon)
        {
            Debug.LogError("ERROR: Can't set forward to zero.");
            onRotateStop?.Invoke(true);
            return false;
        }

        if (Destination.HasValue)
        {
            if (stopMoving)
            {
                StopMoving();
            }
            else
            {
                Debug.LogError("ERROR: Can't set forward during the navigation.");
                onRotateStop?.Invoke(false);
                return false;
            }
        }

        TargetForward = forward.normalized;
        _rotateStopCallback = onRotateStop;

        return true;
    }

    /// <summary>
    /// 设置目的地。
    /// </summary>
    /// <param name="destination">目的地。</param>
    /// <param name="onMovingStop">导航停止时的回调，参数1：是否到达目的地。</param>
    /// <returns></returns>
    public bool SetDestination(Vector3 destination, Action<bool> onMovingStop = null)
    {
        StopMoving();

        if (_navMeshAgent.SetDestination(destination))
        {
            // 注意不要直接使用 destination ，它可能不在NavMesh上
            Destination = _navMeshAgent.destination;
            _moveStopCallback = onMovingStop;

            return true;
        }

        onMovingStop?.Invoke(false);

        return false;
    }

    /// <summary>
    /// 设置移动路径。
    /// </summary>
    /// <param name="wayPoints">移动路径。</param>
    /// <param name="onMovingStop">导航停止时的回调，参数1：是否到达目的地。</param>
    public void SetPath(IEnumerable<Vector3> wayPoints, Action<bool> onMovingStop = null)
    {
        StopMoving();

        _movingPath.Clear();
        foreach (var wayPoint in wayPoints)
        {
            _movingPath.Enqueue(wayPoint);
        }

        if (_movingPath.Count == 0)
        {
            onMovingStop?.Invoke(true);
            return;
        }

        while (_movingPath.Count > 0)
        {
            Destination = _movingPath.Dequeue();
            if (_navMeshAgent.SetDestination(Destination.Value))
            {
                Destination = _navMeshAgent.destination;
                _moveStopCallback = onMovingStop;
                return;
            }

            Debug.LogError($"ERROR: Skip unreachable moving path point `{Destination.Value}`.", gameObject);
        }

        Debug.LogError("ERROR: There is no reachable point in path.", gameObject);

        // 所有路径点在导航网格上都不可达
        Destination = null;
        onMovingStop?.Invoke(false);
    }

    /// <summary>
    /// 停止转向。
    /// </summary>
    public void StopRotating()
    {
        if (!TargetForward.HasValue)
        {
            return;
        }

        if (_rotateStopCallback == null)
        {
           //Debug.LogError(Vector3.Angle(transform.forward, TargetForward.Value) < RotateStopAngle ? "### 转向完成" : "### 转向中断");

           TargetForward = null;
            return;
        }

        var deflectionAngle = Vector3.Angle(transform.forward, TargetForward.Value);
        var tempRotateStopCallback = _rotateStopCallback;

       //Debug.LogError(deflectionAngle < RotateStopAngle ? "### 转向完成" : "### 转向中断");

       _rotateStopCallback = null;
        TargetForward = null;
        tempRotateStopCallback(deflectionAngle < RotateStopAngle);
    }

    /// <summary>
    /// 停止移动。
    /// </summary>
    public void StopMoving()
    {
        if (!Destination.HasValue)
        {
            return;
        }

        if (_moveStopCallback == null)
        {
           //if (GetRemainingLinearSqrDistance(RemainingDistanceType.PathEnd) > StoppingDistance * StoppingDistance)
           //{
           //    Debug.LogError("### NavStop: 未到达");
           //}
           //else
           //{
           //    Debug.LogError("### NavStop: 到达");
           //}

           Destination = null;
            _movingPath.Clear();
            _navMeshAgent.ResetPath();

            return;
        }

        var tempNavStopCallback = _moveStopCallback;
        _moveStopCallback = null;
        _navMeshAgent.ResetPath();

        if (GetRemainingLinearSqrDistance(RemainingDistanceType.PathEnd) > StoppingDistance * StoppingDistance)
        {
           //Debug.LogError("### NavStop: 未到达");

           Destination = null;
            _movingPath.Clear();
            tempNavStopCallback(false);
        }
        else
        {
           //Debug.LogError("### NavStop: 到达");

           Destination = null;
            _movingPath.Clear();
            tempNavStopCallback(true);
        }
    }

    /// <summary>
    /// 移动角色位置。
    /// 若角色尚未停止移动动画，则需要在 LateUpdate 方法中调用此方法。
    /// </summary>
    /// <param name="targetPosition">角色目标位置。</param>
    /// <param name="stopMoving">是否停止正在进行的导航。</param>
    /// <returns></returns>
    public bool MoveCharacter(Vector3 targetPosition, bool stopMoving = false)
    {
        if (NavMesh.SamplePosition(targetPosition, out var hit, MaxNavMeshSampleDistance, NavMeshAreaMask))
        {
            transform.position = hit.position;

            // 这两个方法会导致NavMeshAgent被中途的障碍物挡住
            //_navMeshAgent.nextPosition = hit.position;
            //_navMeshAgent.Move(hit.position - transform.position);

            if (stopMoving)
            {
                _navMeshAgent.Warp(hit.position);
                StopMoving();
            }
            else if (Destination.HasValue)
            {
                // Warp方法会导致导航停止
                _navMeshAgent.Warp(hit.position);
                _navMeshAgent.SetDestination(Destination.Value);
            }

            return true;
        }

        return false;
    }

    /// <summary>
    /// 获取角色当前所在位置到目的地的直线距离（米）。
    /// 注意此方法返回的不是 <see cref="NavMeshAgent.remainingDistance"/> ，两者之间有误差。
    /// </summary>
    /// <param name="distanceType">计算剩余距离的方式。</param>
    /// <returns></returns>
    public float GetRemainingLinearDistance(RemainingDistanceType distanceType)
    {
        return Mathf.Sqrt(GetRemainingLinearSqrDistance(distanceType));
    }

    /// <summary>
    /// 获取角色当前所在位置到目的地的直线距离（米）的平方。
    /// 注意此方法返回的不是 <see cref="NavMeshAgent.remainingDistance"/> 的平方值，两者之间有误差。
    /// </summary>
    /// <param name="distanceType">计算剩余距离的方式。</param>
    /// <returns></returns>
    public float GetRemainingLinearSqrDistance(RemainingDistanceType distanceType)
    {
        if (Destination.HasValue)
        {
            switch (distanceType)
            {
                case RemainingDistanceType.PathEnd:
                    if (_movingPath.Count > 0)
                    {
                        return Vector3.SqrMagnitude(transform.position - _movingPath.Last());
                    }
                    else
                    {
                        return Vector3.SqrMagnitude(transform.position - Destination.Value);
                    }

                case RemainingDistanceType.WayPoint:
                    return Vector3.SqrMagnitude(transform.position - Destination.Value);

                case RemainingDistanceType.SteeringPoint:
                    return Vector3.SqrMagnitude(transform.position - _navMeshAgent.steeringTarget);

                default:
                    throw new ArgumentOutOfRangeException(nameof(distanceType), distanceType, null);
            }
        }

        return 0;
    }


    private void Reset()
    {
        _navMeshAgent = GetComponent<NavMeshAgent>();

        if (ApproachDistance < StoppingDistance)
        {
            ApproachDistance = StoppingDistance + 1e-5f;
        }
    }

    private void OnValidate()
    {
        if (Application.isPlaying)
        {
            _animationLocomotionParamHash = Animator.StringToHash(AnimationLocomotionParam);
        }

        if (AnimationMovingMinValue < AnimationStandingValue)
        {
            AnimationMovingMinValue = AnimationStandingValue;
        }

        _navMeshAgent = GetComponent<NavMeshAgent>();
        if (ApproachDistance < StoppingDistance)
        {
            ApproachDistance = StoppingDistance + 1e-5f;
        }
    }

    private void Awake()
    {
        _animator = GetComponent<Animator>();
        _animationLocomotionParamHash = Animator.StringToHash(AnimationLocomotionParam);

        _navMeshAgent = GetComponent<NavMeshAgent>();
        _navMeshAgent.updatePosition = false;
        _navMeshAgent.updateRotation = false; // 导航转身太慢，手动转身

        if (ApproachDistance < StoppingDistance)
        {
            ApproachDistance = StoppingDistance + 1e-5f;
        }
    }


    public void SetCanUpDatePosition(bool canUpDate) {
        _navMeshAgent.updatePosition = canUpDate;
    }

    bool isLife = true;
    public void SetIsLife(bool islife)
    {
        this.isLife = islife;
        _navMeshAgent.enabled = false;
    }

    public void SetStopDistance(float distance)
    {
        _navMeshAgent.stoppingDistance = distance;
        ApproachDistance = distance;
    }

    public void CleanCallBack() {
        _moveStopCallback = null;
    }


    private void Update()
    {
        if (isLife==false) {
            return;
        }
        // 处理角色转向
        RotateCharacter(out float deflectionAngle);

        // 如果无目的地，停止移动
        if (!Destination.HasValue)
        {
            SetAnimationLocomotionValueWithDamp(AnimationStandingValue);
            return;
        }

        // 计算剩余距离
        var remainingSqrDistance = GetRemainingLinearSqrDistance(RemainingDistanceType.WayPoint);

        // 优先处理路径，因为路径也会使用 NavDestination 属性
        if (_movingPath.Count > 0)
        {
            if (remainingSqrDistance < ApproachDistance * ApproachDistance)
            {
                var hasDestination = false;
                while (_movingPath.Count > 0)
                {
                    Destination = _movingPath.Dequeue();
                    if (_navMeshAgent.SetDestination(Destination.Value))
                    {
                        Destination = _navMeshAgent.destination;
                        hasDestination = true;
                        break;
                    }

                    Debug.LogError($"ERROR: Skip unreachable moving path point `{Destination.Value}`.");
                }

                // 所有路径点在导航网格上都不可达，停止导航
                if (!hasDestination)
                {
                    StopMoving();
                    return;
                }
            }
        }
        // 次优处理单个目的地
        // 已到达目的地
        else if (remainingSqrDistance < StoppingDistance * StoppingDistance)
        {
            StopMoving();

            return;
        }

        // 处理转身速度衰减和接近目标点的速度衰减
        var animationMovingValue = Mathf.Min(DampMovingSpeedByDeflection(AnimationMovingValue, deflectionAngle),
            DampMovingSpeedByRemainingDistance());
        //var animationMovingValue = DampMovingSpeedByDeflection(AnimationMovingValue, deflectionAngle);

        // 设置移动参数
        SetAnimationLocomotionValueWithDamp(animationMovingValue);

    }

    private void OnAnimatorMove()
    {
        // 仅使用导航高度，使角色贴合导航网格
        var pos = _animator.rootPosition;
        var rotate = _animator.rootRotation;
        if (isLife)
        {
            pos.y = _navMeshAgent.nextPosition.y;
            // 使代理贴合根运动
            _navMeshAgent.nextPosition = transform.position;

            // 使用根运动速度驱动导航速度
            _navMeshAgent.velocity = _animator.velocity;
        }
        else {
            transform.rotation = rotate;
        }

        transform.position = pos;

       

    }



    /// <summary>
    /// 处理角色转向。
    /// </summary>
    /// <param name="deflectionAngle"></param>
    private void RotateCharacter(out float deflectionAngle)
    {
        deflectionAngle = 0;

        // 若有目的地，则朝向下一个要到达的路径点
        if (Destination.HasValue)
        {
            var targetForward = _navMeshAgent.steeringTarget - transform.position;
            targetForward.y = 0;
            targetForward.Normalize();

            // 处理转身
            transform.forward = Vector3.RotateTowards(transform.forward, targetForward,
                Time.deltaTime * AngularSpeed * Mathf.Deg2Rad, float.MaxValue);

            deflectionAngle = Vector3.Angle(transform.forward, targetForward);
        }
        // 否则朝向指定的方向
        else if (TargetForward.HasValue)
        {
            // 处理转身
            transform.forward = Vector3.RotateTowards(transform.forward, TargetForward.Value,
                Time.deltaTime * AngularSpeed * Mathf.Deg2Rad, float.MaxValue);

            deflectionAngle = Vector3.Angle(transform.forward, TargetForward.Value);
            if (deflectionAngle < RotateStopAngle)
            {
                //Debug.LogError("### 转向完成");

                if (_rotateStopCallback == null)
                {
                    TargetForward = null;
                }
                else
                {
                    var tempRotateStopCallback = _rotateStopCallback;
                    _rotateStopCallback = null;
                    TargetForward = null;
                    tempRotateStopCallback(true);
                }
            }
        }
    }

    /// <summary>
    /// 按角色当前朝向与目标移动方向的偏转角处理移动速率衰减。
    /// </summary>
    /// <param name="originalSpeed">衰减前的移动速率（米/秒）。</param>
    /// <param name="deflectionAngle">偏转角（角度）。</param>
    /// <returns></returns>
    private float DampMovingSpeedByDeflection(float originalSpeed, float deflectionAngle)
    {
        deflectionAngle = Mathf.Abs(deflectionAngle);

        // 立方EaseOutIn衰减
        //var progress = 1 - deflectionAngle / 180;
        //var dampCoef = progress < 0.5f
        //    ? progress * 2 - Mathf.Pow(2, 3 - 1) * Mathf.Pow(progress, 3) // 2^(n-1)*(progress^n)
        //    : progress * 2 - (1 - Mathf.Pow(-2 * progress + 2, 3) / 2); // 1-((-2*x+2)^n)/2

        // 线性衰减
        var dampCoef = 1 - deflectionAngle / 180;

        var dampedSpeed = originalSpeed * dampCoef;

        return dampedSpeed;
    }

    /// <summary>
    /// 按角色当前距离导航目标点的距离来处理移动速率衰减。
    /// </summary>
    /// <returns></returns>
    private float DampMovingSpeedByRemainingDistance()
    {
        if (ApproachDistance < StoppingDistance)
        {
            Debug.LogError($"ERROR: {nameof(StoppingDistance)}({StoppingDistance}) should be less than {nameof(ApproachDistance)}({ApproachDistance}).", gameObject);
        }

        // 注意，应该根据角色移动速度来调整各项速度计算参数

        var remainingSqrDistance = GetRemainingLinearSqrDistance(RemainingDistanceType.WayPoint);
        if (remainingSqrDistance < StoppingDistance * StoppingDistance)
        {
            return 0;
        }

        if (remainingSqrDistance > ApproachDistance * ApproachDistance)
        {
            return AnimationMovingValue;
        }

        // 只在接近终点或者中途路径点时进行减速，由导航生成的steeringTarget不做减少处理（因为走过头了也没啥影响）

        // 四次方EaseOutIn衰减
        var remainingDistance = Mathf.Sqrt(remainingSqrDistance);
        var progress = remainingDistance / ApproachDistance;
        var dampCoef = progress < 0.5f
            ? progress * 2 - Mathf.Pow(2, 4 - 1) * Mathf.Pow(progress, 4) // 2^(n-1)*(progress^n)
            : progress * 2 - (1 - Mathf.Pow(-2 * progress + 2, 4) / 2); // 1-((-2*x+2)^n)/2

        // 线性衰减
        //var dampCoef = remainingDistance / approachDistance;

        // 避免接近目标点时无限减速
        var dampedSpeed = Mathf.Max(AnimationMovingValue * dampCoef, AnimationMovingMinValue);

        return dampedSpeed;
    }

    /// <summary>
    /// 以带有Damp的形式设置动画的移动参数。
    /// 需要每帧调用才能使Damp生效。
    /// </summary>
    /// <param name="value"></param>
    private void SetAnimationLocomotionValueWithDamp(float value)
    {
        _animationLocomotionValue = Mathf.SmoothDamp(_animationLocomotionValue, value,
            ref _animationLocomotionValueDampVelocity, AnimationLocomotionValueDampTime);

        _animator.SetFloat(_animationLocomotionParamHash, _animationLocomotionValue);
    }
}

