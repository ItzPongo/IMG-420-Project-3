using Godot;
using System;
using System.Collections.Generic;

public partial class EnemyBoid : RigidBody2D
{
	[Signal] public delegate void EnemyDiedEventHandler(EnemyBoid enemy);
	[Export] public float MaxSpeed = 100f;
	[Export] public float SeparationWeight = 3.5f;
	[Export] public float AlignmentWeight = 1.0f;
	[Export] public float CohesionWeight = 0.5f;
	[Export] public float FollowWeight = 50.0f;
	[Export] public float FollowRadius = 30.0f;

	[Export] public int MaxHealth = 100;
	private int _currentHealth;
	private ProgressBar _healthBar;

	private List<EnemyBoid> _neighbors = new();
	private Area2D _detectionArea;
	private Node2D _target;
	private Vector2 _velocity = Vector2.Zero;

	private AnimatedSprite2D _sprite;

	public override void _Ready()
	{
		AddToGroup("enemies");
		_detectionArea = GetNode<Area2D>("HitArea");
		_detectionArea.BodyEntered += OnBodyEntered;
		_detectionArea.BodyExited += OnBodyExited;

		_healthBar = GetNode<ProgressBar>("HealthBar");
		_currentHealth = MaxHealth;
		_healthBar.MaxValue = MaxHealth;
		_healthBar.Value = _currentHealth;

		_sprite = GetNode<AnimatedSprite2D>("EnemySprite");
		var animations = _sprite.SpriteFrames.GetAnimationNames();
		_sprite.Animation = animations[GD.Randi() % animations.Length];
		_sprite.Play();

		var viewportRect = GetViewportRect();
		Position = new Vector2(GD.Randf() * viewportRect.Size.X, GD.Randf() * viewportRect.Size.Y);

		var angle = GD.Randf() * Mathf.Pi * 2;
		_velocity = new Vector2(Mathf.Cos(angle), Mathf.Sin(angle)) * MaxSpeed;
	}

	public void SetTarget(Node2D target) => _target = target;

	public override void _PhysicsProcess(double delta)
	{
		Vector2 separation = Separation() * SeparationWeight;
		Vector2 alignment = Alignment() * AlignmentWeight;
		Vector2 cohesion = Cohesion() * CohesionWeight;
		Vector2 follow = Centralization() * FollowWeight;

		_velocity += (separation + alignment + cohesion + follow) * (float)delta;
		_velocity = _velocity.LimitLength(MaxSpeed);

		LinearVelocity = _velocity;

		if (_velocity.Length() > 1)
			Rotation = _velocity.Angle();
	}

	private void OnBodyEntered(Node2D body)
	{
		if (body is EnemyBoid boid && boid != this)
			_neighbors.Add(boid);
	}

	private void OnBodyExited(Node2D body)
	{
		if (body is EnemyBoid boid && boid != this)
			_neighbors.Remove(boid);
	}

	public void TakeDamage(int amount)
	{
		_currentHealth -= amount;
		_healthBar.Value = _currentHealth;

		if (_currentHealth <= 0)
			Die();
	}

	private void Die()
	{
		EmitSignal(nameof(EnemyDied), this);
		QueueFree();
	}

	private Vector2 Separation()
	{
		if (_neighbors.Count == 0) return Vector2.Zero;
		Vector2 steer = Vector2.Zero;
		foreach (var neighbor in _neighbors)
		{
			Vector2 diff = Position - neighbor.Position;
			steer += diff.Normalized() / diff.Length();
		}
		return steer.Normalized();
	}

	private Vector2 Alignment()
	{
		if (_neighbors.Count == 0) return Vector2.Zero;
		Vector2 avgVel = Vector2.Zero;
		foreach (var neighbor in _neighbors)
			avgVel += neighbor._velocity;
		avgVel /= _neighbors.Count;
		return avgVel.Normalized();
	}

	private Vector2 Cohesion()
	{
		if (_neighbors.Count == 0) return Vector2.Zero;
		Vector2 center = Vector2.Zero;
		foreach (var neighbor in _neighbors)
			center += neighbor.Position;
		center /= _neighbors.Count;
		return (center - Position).Normalized();
	}

	private Vector2 Centralization()
	{
		if (_target == null) return Vector2.Zero;
		if (Position.DistanceTo(_target.Position) < FollowRadius) return Vector2.Zero;
		return (_target.Position - Position).Normalized();
	}

	public void OnHit(int damage)
	{
		TakeDamage(damage);
	}
}
